import 'dart:math';
import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:two_eight_two/models/models.dart';
import 'package:two_eight_two/screens/bulk_munro_updates/widgets/bulk_munro_map_summary_card.dart';
import 'package:two_eight_two/screens/notifiers.dart';

class BulkMunroMapScreen extends StatefulWidget {
  const BulkMunroMapScreen({super.key});

  @override
  State<BulkMunroMapScreen> createState() => _BulkMunroMapScreenState();
}

class _BulkMunroMapScreenState extends State<BulkMunroMapScreen> {
  static const String _lightStyleUri = "mapbox://styles/alastairm94/cmpcs9ivx002m01r110ljakxt";
  static const String _darkStyleUri = "mapbox://styles/alastairm94/cmpdpqwg2000001siaqwm3zx5";

  bool loading = true;
  bool _mapInitialized = false;
  late MapboxMap _mapboxMap;
  Brightness? _lastBrightness;
  Map<int, PointAnnotation?> allAnnotations = {};
  PointAnnotation? selectedAnnotation;
  int? _selectedMunroId;
  late PointAnnotationManager _annotationManager;
  List<int> _lastMunroIds = [];

  final CameraBoundsOptions cameraBounds = CameraBoundsOptions(
    bounds: CoordinateBounds(
      southwest: Point(coordinates: Position(-10, 53)),
      northeast: Point(coordinates: Position(0, 62)),
      infiniteBounds: false,
    ),
    minZoom: 4,
    maxZoom: 14,
  );

  final CameraOptions startingCamera = CameraOptions(
    center: Point(coordinates: Position(-4.559, 57.334)),
    zoom: 6.15,
  );

  Uint8List? incompleteIcon;
  Uint8List? completeIcon;
  Uint8List? selectedIcon;
  Uint8List? bulkSelectedIcon;

  String _activeStyleUri(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark ? _darkStyleUri : _lightStyleUri;
  }

  @override
  void initState() {
    super.initState();
    _loadIcons();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final brightness = Theme.of(context).brightness;
    if (_lastBrightness != null && _lastBrightness != brightness && _mapInitialized) {
      final uri = brightness == Brightness.dark ? _darkStyleUri : _lightStyleUri;
      _mapboxMap.loadStyleURI(uri);
    }
    _lastBrightness = brightness;
  }

  Future<void> _loadIcons() async {
    incompleteIcon = await _loadMarker('assets/munro_incomplete.png');
    completeIcon = await _loadMarker('assets/munro_complete.png');
    selectedIcon = await _loadMarker('assets/munro_selected.png');
    bulkSelectedIcon = await _loadMarker('assets/munro_bulk_selected.png');
    if (mounted) setState(() => loading = false);
  }

  Future<Uint8List> _loadMarker(String assetPath) async {
    ByteData data = await rootBundle.load(assetPath);
    ui.Codec codec = await ui.instantiateImageCodec(data.buffer.asUint8List(), targetWidth: 100);
    ui.FrameInfo fi = await codec.getNextFrame();
    return (await fi.image.toByteData(format: ui.ImageByteFormat.png))!.buffer.asUint8List();
  }

  void _onMapCreated(MapboxMap mapboxMap, MunroState munroState,
      MunroCompletionState munroCompletionState, BulkMunroUpdateState bulkMunroUpdateState) async {
    _mapboxMap = mapboxMap;
    await mapboxMap.compass.updateSettings(CompassSettings(enabled: false));
    await mapboxMap.scaleBar.updateSettings(ScaleBarSettings(enabled: false));
    _mapboxMap.setBounds(cameraBounds);
    await _addMunroSymbols(
      munros: munroState.munroList,
      munroCompletionState: munroCompletionState,
      bulkMunroUpdateState: bulkMunroUpdateState,
    );
    _lastMunroIds = munroState.munroList.map((m) => m.id).toList();
    _mapInitialized = true;
  }

  Future<void> _addMunroSymbols({
    required List<Munro> munros,
    required MunroCompletionState munroCompletionState,
    required BulkMunroUpdateState bulkMunroUpdateState,
  }) async {
    if (incompleteIcon == null || completeIcon == null || selectedIcon == null || bulkSelectedIcon == null) {
      return;
    }

    _annotationManager = await _mapboxMap.annotations.createPointAnnotationManager();

    final List<PointAnnotationOptions> options = [];
    for (final munro in munros) {
      options.add(PointAnnotationOptions(
        geometry: Point(coordinates: Position(munro.lng, munro.lat)),
        image: _iconFor(
          munroId: munro.id,
          munroCompletionState: munroCompletionState,
          bulkMunroUpdateState: bulkMunroUpdateState,
          isFocused: false,
        ),
        iconSize: 0.6,
      ));
    }

    final annotations = await _annotationManager.createMulti(options);
    for (var i = 0; i < annotations.length; i++) {
      allAnnotations[munros[i].id] = annotations[i];
    }
  }

  Uint8List _iconFor({
    required int munroId,
    required MunroCompletionState munroCompletionState,
    required BulkMunroUpdateState bulkMunroUpdateState,
    required bool isFocused,
  }) {
    if (isFocused) return selectedIcon!;
    final existingCompletion =
        munroCompletionState.munroCompletions.any((c) => c.munroId == munroId);
    if (existingCompletion) return completeIcon!;
    final bulkSelected =
        bulkMunroUpdateState.addedMunroCompletions.any((c) => c.munroId == munroId);
    if (bulkSelected) return bulkSelectedIcon!;
    return incompleteIcon!;
  }

  void handleMapTap(ScreenCoordinate tapScreenPoint, MunroState munroState,
      MunroCompletionState munroCompletionState, BulkMunroUpdateState bulkMunroUpdateState) async {
    const double threshold = 40.0;

    int? closestMunroId;
    PointAnnotation? closestAnnotation;
    double minDist = double.infinity;

    for (final entry in allAnnotations.entries) {
      final annotation = entry.value;
      if (annotation == null) continue;

      final screen = await _mapboxMap.pixelForCoordinate(annotation.geometry);
      final dx = screen.x - tapScreenPoint.x;
      final dy = screen.y - tapScreenPoint.y;
      final dist = sqrt(dx * dx + dy * dy);

      if (dist < threshold && dist < minDist) {
        minDist = dist;
        closestMunroId = entry.key;
        closestAnnotation = annotation;
      }
    }

    await _deselectAnnotation(munroCompletionState, bulkMunroUpdateState);
    if (closestAnnotation != null && closestMunroId != null) {
      await _selectAnnotation(closestMunroId, closestAnnotation);
    }
  }

  Future<void> _deselectAnnotation(
      MunroCompletionState munroCompletionState, BulkMunroUpdateState bulkMunroUpdateState) async {
    if (selectedAnnotation == null || _selectedMunroId == null) return;

    final icon = _iconFor(
      munroId: _selectedMunroId!,
      munroCompletionState: munroCompletionState,
      bulkMunroUpdateState: bulkMunroUpdateState,
      isFocused: false,
    );

    await _annotationManager.delete(selectedAnnotation!);
    final restored = await _annotationManager.create(PointAnnotationOptions(
      geometry: selectedAnnotation!.geometry,
      image: icon,
      iconSize: 0.6,
    ));
    allAnnotations[_selectedMunroId!] = restored;

    selectedAnnotation = null;
    if (mounted) setState(() => _selectedMunroId = null);
  }

  Future<void> _selectAnnotation(int munroId, PointAnnotation tappedAnnotation) async {
    await _annotationManager.delete(tappedAnnotation);
    final newAnnotation = await _annotationManager.create(PointAnnotationOptions(
      geometry: tappedAnnotation.geometry,
      image: selectedIcon!,
      iconSize: 0.7,
    ));
    allAnnotations[munroId] = newAnnotation;
    selectedAnnotation = newAnnotation;

    if (mounted) setState(() => _selectedMunroId = munroId);

    await _mapboxMap.flyTo(
      CameraOptions(center: tappedAnnotation.geometry),
      MapAnimationOptions(duration: 500),
    );
  }

  @override
  Widget build(BuildContext context) {
    final munroState = context.watch<MunroState>();
    final munroCompletionState = context.read<MunroCompletionState>();
    final bulkMunroUpdateState = context.read<BulkMunroUpdateState>();

    if (_mapInitialized) {
      final currentIds = munroState.munroList.map((m) => m.id).toList();
      if (!listEquals(currentIds, _lastMunroIds)) {
        _lastMunroIds = currentIds;
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            _annotationManager.deleteAll();
            allAnnotations.clear();
            selectedAnnotation = null;
            setState(() => _selectedMunroId = null);
            _addMunroSymbols(
              munros: munroState.munroList,
              munroCompletionState: munroCompletionState,
              bulkMunroUpdateState: bulkMunroUpdateState,
            );
          }
        });
      }
    }

    if (loading) {
      return const Center(child: CircularProgressIndicator());
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth == 0 || constraints.maxHeight == 0) {
          return const SizedBox.shrink();
        }
        return Stack(
          children: [
            MapWidget(
              key: const ValueKey("bulkMunroMapWidget"),
              onMapCreated: (MapboxMap mapboxMap) => _onMapCreated(
                mapboxMap,
                munroState,
                munroCompletionState,
                bulkMunroUpdateState,
              ),
              styleUri: _activeStyleUri(context),
              cameraOptions: startingCamera,
              onTapListener: (mapContext) {
                handleMapTap(
                  mapContext.touchPosition,
                  munroState,
                  munroCompletionState,
                  bulkMunroUpdateState,
                );
              },
            ),
            if (_selectedMunroId != null)
              Align(
                alignment: Alignment.bottomCenter,
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: BulkMunroMapSummaryCard(munroId: _selectedMunroId!),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}
