import 'dart:math';
import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:two_eight_two/models/models.dart';
import 'package:two_eight_two/screens/explore/screens/map_shimmer_loader.dart';
import 'package:two_eight_two/screens/notifiers.dart';
import 'package:two_eight_two/screens/explore/widgets/widgets.dart';

class MapboxMapScreen extends StatefulWidget {
  final FocusNode searchFocusNode;
  const MapboxMapScreen({super.key, required this.searchFocusNode});

  @override
  State<MapboxMapScreen> createState() => _MapboxMapScreenState();
}

class _MapboxMapScreenState extends State<MapboxMapScreen> {
  static const String _lightStyleUri = "mapbox://styles/alastairm94/cmpcs9ivx002m01r110ljakxt";
  static const String _darkStyleUri = "mapbox://styles/alastairm94/cmpdpqwg2000001siaqwm3zx5";

  bool loading = true;
  bool _mapInitialized = false;
  late MapboxMap _mapboxMap;
  Brightness? _lastBrightness;
  Map<int, PointAnnotation?> allAnnotations = {};
  PointAnnotation? selectedAnnotation;
  late PointAnnotationManager _annotationManager;
  List<int> _lastFilteredIds = [];
  final CameraBoundsOptions cameraBounds = CameraBoundsOptions(
    bounds: CoordinateBounds(
      southwest: Point(
        coordinates: Position(-10, 53),
      ),
      northeast: Point(
        coordinates: Position(0, 62),
      ),
      infiniteBounds: false,
    ),
    minZoom: 4,
    maxZoom: 14,
  );
  bool showTerrain = false;

  CameraOptions startingCamera = CameraOptions(
    center: Point(coordinates: Position(-4.559, 57.334)),
    zoom: 6.15,
  );

  Uint8List? incompleteIcon;
  Uint8List? completeIcon;
  Uint8List? selectedIcon;

  String _activeStyleUri(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark ? _darkStyleUri : _lightStyleUri;
  }

  @override
  void initState() {
    super.initState();
    loadData();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final brightness = Theme.of(context).brightness;
    if (_lastBrightness != null && _lastBrightness != brightness) {
      final uri = brightness == Brightness.dark ? _darkStyleUri : _lightStyleUri;
      _mapboxMap.loadStyleURI(uri);
    }
    _lastBrightness = brightness;
  }

  void loadData() async {
    incompleteIcon = await _loadMarker('assets/munro_incomplete.png');
    completeIcon = await _loadMarker('assets/munro_complete.png');
    selectedIcon = await _loadMarker('assets/munro_selected.png');
    if (mounted) setState(() => loading = false);
  }

  void _onMapCreated(MapboxMap mapboxMap, MunroState munroState, MunroCompletionState munroCompletionState) async {
    _mapboxMap = mapboxMap;
    await mapboxMap.compass.updateSettings(CompassSettings(enabled: false));
    await mapboxMap.scaleBar.updateSettings(ScaleBarSettings(enabled: false));
    await mapboxMap.gestures.updateSettings(
      GesturesSettings(rotateEnabled: false, pitchEnabled: false),
    );
    _mapboxMap.setBounds(cameraBounds);
    await _addMunroSymbols(
      munroState: munroState,
      completedMunros: munroCompletionState.munroCompletions,
    );
    _lastFilteredIds = munroState.filteredMunroList.map((m) => m.id).toList();
    _mapInitialized = true;
  }

  Future<void> _addMunroSymbols(
      {required MunroState munroState, required List<MunroCompletion> completedMunros}) async {
    final List<Munro> munros = munroState.filteredMunroList;

    if (incompleteIcon == null || completeIcon == null || selectedIcon == null) {
      return;
    }

    _annotationManager = await _mapboxMap.annotations.createPointAnnotationManager();

    List<PointAnnotationOptions> pointAnnotationOptions = [];

    for (var munro in munros) {
      final summited = completedMunros.any((element) => element.munroId == munro.id);
      final icon = munroState.selectedMunroId == munro.id
          ? selectedIcon!
          : summited
              ? completeIcon!
              : incompleteIcon!;

      pointAnnotationOptions.add(
        PointAnnotationOptions(
          geometry: Point(coordinates: Position(munro.lng, munro.lat)),
          image: icon,
          iconSize: 0.6,
        ),
      );
    }

    var annotations = await _annotationManager.createMulti(pointAnnotationOptions);

    for (var i = 0; i < annotations.length; i++) {
      allAnnotations[munros[i].id] = annotations[i];
    }
  }

  Future<void> _refreshAnnotations(MunroState munroState, MunroCompletionState munroCompletionState) async {
    if (incompleteIcon == null || completeIcon == null || selectedIcon == null) return;

    await _annotationManager.deleteAll();
    allAnnotations.clear();
    selectedAnnotation = null;
    munroState.setSelectedMunroId = null;

    final munros = munroState.filteredMunroList;
    if (munros.isEmpty) return;

    List<PointAnnotationOptions> options = [];
    for (var munro in munros) {
      final summited = munroCompletionState.munroCompletions.any((e) => e.munroId == munro.id);
      options.add(PointAnnotationOptions(
        geometry: Point(coordinates: Position(munro.lng, munro.lat)),
        image: summited ? completeIcon! : incompleteIcon!,
        iconSize: 0.6,
      ));
    }

    var annotations = await _annotationManager.createMulti(options);
    for (var i = 0; i < annotations.length; i++) {
      allAnnotations[munros[i].id] = annotations[i];
    }
  }

  Future<Uint8List> _loadMarker(String assetPath) async {
    ByteData data = await rootBundle.load(assetPath);
    ui.Codec codec = await ui.instantiateImageCodec(data.buffer.asUint8List(), targetWidth: 100);
    ui.FrameInfo fi = await codec.getNextFrame();
    return (await fi.image.toByteData(format: ui.ImageByteFormat.png))!.buffer.asUint8List();
  }

  void handleMapTap(
      ScreenCoordinate tapScreenPoint, MunroState munroState, MunroCompletionState munroCompletionState) async {
    const double threshold = 40.0;

    int? closestMunroId;
    PointAnnotation? closestAnnotation;
    double minDist = double.infinity;

    for (final entry in allAnnotations.entries) {
      final int munroId = entry.key;
      final PointAnnotation? annotation = entry.value;

      if (annotation == null) continue;

      final geoCoord = annotation.geometry;

      final screen = await _mapboxMap.pixelForCoordinate(geoCoord);

      final dx = screen.x - tapScreenPoint.x;
      final dy = screen.y - tapScreenPoint.y;
      final dist = sqrt(dx * dx + dy * dy);

      if (dist < threshold && dist < minDist) {
        minDist = dist;
        closestMunroId = munroId;
        closestAnnotation = annotation;
      }
    }

    await deselectAnnotation(munroState, munroCompletionState.munroCompletions);
    if (closestAnnotation != null && closestMunroId != null) {
      await selectAnnotation(closestMunroId, closestAnnotation);
    }
  }

  Future<void> deselectAnnotation(MunroState munroState, List<MunroCompletion> munroCompletions) async {
    if (selectedAnnotation != null && munroState.selectedMunroId != null) {
      if (completeIcon == null || incompleteIcon == null) return;

      final Munro munro = munroState.munroList.firstWhere(
        (munro) => munro.id == munroState.selectedMunroId,
        orElse: () => Munro.empty,
      );
      final bool summited = munroCompletions.any((element) => element.munroId == munro.id);
      final PointAnnotationOptions oldAnnotationOptions = PointAnnotationOptions(
        geometry: selectedAnnotation!.geometry,
        image: summited ? completeIcon! : incompleteIcon!,
        iconSize: 0.6,
      );
      await _annotationManager.delete(selectedAnnotation!);
      var oldAnnotation = await _annotationManager.create(oldAnnotationOptions);
      allAnnotations[munroState.selectedMunroId!] = oldAnnotation;

      selectedAnnotation = null;
      munroState.setSelectedMunroId = null;
    }
  }

  Future<void> selectAnnotation(int munroId, PointAnnotation tappedAnnotation) async {
    if (selectedIcon == null) return;

    final munroState = context.read<MunroState>();
    final PointAnnotationOptions newAnnotationOptions = PointAnnotationOptions(
      geometry: tappedAnnotation.geometry,
      image: selectedIcon!,
      iconSize: 0.7,
    );

    await _annotationManager.delete(tappedAnnotation);

    var newAnnotation = await _annotationManager.create(newAnnotationOptions);
    allAnnotations[munroId] = newAnnotation;
    selectedAnnotation = newAnnotation;
    munroState.setSelectedMunroId = munroId;

    await _mapboxMap.flyTo(
      CameraOptions(center: tappedAnnotation.geometry),
      MapAnimationOptions(duration: 1000),
    );
  }

  @override
  Widget build(BuildContext context) {
    final munroState = context.watch<MunroState>();
    final munroCompletionState = context.read<MunroCompletionState>();

    if (_mapInitialized) {
      final currentIds = munroState.filteredMunroList.map((m) => m.id).toList();
      if (!listEquals(currentIds, _lastFilteredIds)) {
        _lastFilteredIds = currentIds;
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) _refreshAnnotations(munroState, munroCompletionState);
        });
      }
    }

    return Scaffold(
      body: loading
          ? MapShimmerLoader()
          : LayoutBuilder(
              builder: (context, constraints) {
                if (constraints.maxWidth == 0 || constraints.maxHeight == 0) {
                  return const SizedBox.shrink();
                }

                return Stack(
                  children: [
                    MapWidget(
                      key: const ValueKey("mapWidget"),
                      onMapCreated: (MapboxMap mapboxMap) => _onMapCreated(
                        mapboxMap,
                        munroState,
                        munroCompletionState,
                      ),
                      styleUri: _activeStyleUri(context),
                      cameraOptions: startingCamera,
                      onTapListener: (context) {
                        widget.searchFocusNode.unfocus();
                        handleMapTap(
                          context.touchPosition,
                          munroState,
                          munroCompletionState,
                        );
                      },
                    ),
                    Align(
                      alignment: Alignment.bottomCenter,
                      child: MunroSummaryTile(munroId: munroState.selectedMunroId),
                    ),
                  ],
                );
              },
            ),
    );
  }
}
