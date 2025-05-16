// ignore_for_file: unused_field

import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:two_eight_two/models/models.dart';
import 'package:two_eight_two/repos/repos.dart';
import 'package:two_eight_two/screens/explore/screens/map_shimmer_loader.dart';
import 'package:two_eight_two/screens/notifiers.dart';
import 'package:two_eight_two/screens/explore/widgets/widgets.dart';
import 'package:two_eight_two/services/services.dart';

class MapScreen extends StatefulWidget {
  final FocusNode searchFocusNode;
  const MapScreen({super.key, required this.searchFocusNode});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  bool loading = true;
  late MapboxMap _mapboxMap;
  late PointAnnotationManager _annotationManager;
  List<PointAnnotation?> currentAnnotations = [];
  final Map<String, PointAnnotation> _annotationMap = {};

  double _zoom = 5.5;
  String? _selectedMunroID;
  bool showTerrain = false;
  bool _tappedAnnotation = false;

  CameraOptions camera = CameraOptions(
    center: Point(coordinates: Position(-98.0, 39.5)),
    zoom: 2,
    bearing: 0,
    pitch: 0,
  );

  @override
  void initState() {
    super.initState();

    loadData();
  }

  void loadData() async {
    await MunroDatabase.loadBasicMunroData(context).then(
      (value) => setState(() => loading = false),
    );
  }

  void _onMapCreated(MapboxMap mapboxMap, MunroState munroState) async {
    _mapboxMap = mapboxMap;
    await mapboxMap.compass.updateSettings(CompassSettings(enabled: false));
    await mapboxMap.scaleBar.updateSettings(ScaleBarSettings(enabled: false));

    _mapboxMap.setBounds(
      CameraBoundsOptions(
        bounds: CoordinateBounds(
          southwest: Point(
            coordinates: Position(-10, 53),
          ), // too north, too south, too zoomed out, not enough zoomed in

          northeast: Point(
            coordinates: Position(0, 62),
          ),
          infiniteBounds: false,
        ),
        minZoom: 4,
        maxZoom: 14,
      ),
    );
    _addMunroSymbols(munroState: munroState);
  }

  Future<void> _addMunroSymbols({required MunroState munroState}) async {
    final List<Munro> munros = munroState.filteredMunroList;

    final Uint8List incomplete = await _loadMarker('assets/munro_incomplete.png');
    final Uint8List complete = await _loadMarker('assets/munro_complete.png');
    final Uint8List selected = await _loadMarker('assets/munro_selected.png');

    _annotationManager = await _mapboxMap.annotations.createPointAnnotationManager();

    // 👇 Attach tap listener
    List<PointAnnotationOptions> markers = [];
    double iconSize = getIconSize();

    for (var munro in munros) {
      final icon = _selectedMunroID == munro.id
          ? selected
          : munro.summited
              ? complete
              : incomplete;

      markers.add(
        PointAnnotationOptions(
          geometry: Point(coordinates: Position(munro.lng, munro.lat)),
          image: icon,
          iconSize: 0.6, //iconSize,
        ),
      );
    }

    currentAnnotations = await _annotationManager.createMulti(markers);

    for (int i = 0; i < munros.length; i++) {
      _annotationMap[munros[i].id] = currentAnnotations[i]!;
    }

    _annotationManager.addOnPointAnnotationClickListener(
      MunroAnnotationClickListener(
        currentAnnotations: currentAnnotations,
        munros: munros,
        onMunroSelected: (id) async {
          print("🚀 ~ _MapScreenState ~ void _onMunroSelected ~ id: $id");
          setState(() {
            _selectedMunroID = id;
          });
          munroState.setSelectedMunroId = id;
          await _refreshAnnotations(munroState);
        },
        onAnnotationTap: () {
          _tappedAnnotation = true;
        },
      ),
    );
  }

  Future<void> _refreshAnnotations(MunroState munroState) async {
    await _annotationManager.deleteAll();
    await _addMunroSymbols(munroState: munroState);
  }

  void _updateMarkerSizes() {
    final newSize = getIconSize();

    for (var annotation in currentAnnotations) {
      if (annotation != null) {
        annotation.iconSize = newSize;

        print("🚀 ~ _MapScreenState ~ void_updateMarkerSizes ~ annotation: ${annotation.iconSize}");
        _annotationManager.update(annotation);
      }
    }
  }

  Future<Uint8List> _loadMarker(String assetPath) async {
    ByteData data = await rootBundle.load(assetPath);
    ui.Codec codec = await ui.instantiateImageCodec(data.buffer.asUint8List(), targetWidth: 100);
    ui.FrameInfo fi = await codec.getNextFrame();
    return (await fi.image.toByteData(format: ui.ImageByteFormat.png))!.buffer.asUint8List();
  }

  double getIconSize() {
    const m = 0.070588;
    const b = 0.1118;
    return m * _zoom + b;
  }

  @override
  Widget build(BuildContext context) {
    MunroState munroState = Provider.of<MunroState>(context, listen: true);
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
                      onMapCreated: (MapboxMap mapboxMap) => _onMapCreated(mapboxMap, munroState),
                      styleUri: "mapbox://styles/alastairm94/cmap1d7ho01le01s30cz9gt8v",
                      cameraOptions: CameraOptions(
                        center: Point(coordinates: Position(-4.2, 56.8)),
                        zoom: _zoom,
                      ),
                      onTapListener: (MapContentGestureContext eventData) async {
                        print("🚀 ~ _MapScreenState ~ void _onTapListener ~ _tappedAnnotation: $_tappedAnnotation");
                        if (_tappedAnnotation) {
                          _tappedAnnotation = false;
                          return;
                        }
                        widget.searchFocusNode.unfocus();
                        if (_selectedMunroID != null) {
                          setState(() => _selectedMunroID = null);
                          munroState.setSelectedMunroId = null;
                          await _refreshAnnotations(munroState);
                        }
                      },
                      // onCameraChangeListener: (eventData) async {
                      //   final cameraState = await _mapboxMap.getCameraState();
                      //   final newZoom = cameraState.zoom;

                      //   if ((newZoom - _zoom).abs() > 0.1) {
                      //     _zoom = newZoom;
                      //     // _updateMarkerSizes();
                      //   }
                      // },
                    ),
                    Align(
                      alignment: Alignment.bottomCenter,
                      child: MunroSummaryTile(munroId: _selectedMunroID),
                    ),
                  ],
                );
              },
            ),
    );
  }
}

class MunroAnnotationClickListener extends OnPointAnnotationClickListener {
  final List<PointAnnotation?> currentAnnotations;
  final List<Munro> munros;
  final Function(String) onMunroSelected;
  final VoidCallback onAnnotationTap;

  MunroAnnotationClickListener({
    required this.currentAnnotations,
    required this.munros,
    required this.onMunroSelected,
    required this.onAnnotationTap,
  });

  @override
  bool onPointAnnotationClick(PointAnnotation annotation) {
    onAnnotationTap(); // Set the flag in parent
    final index = currentAnnotations.indexOf(annotation);
    if (index != -1) {
      final tappedMunro = munros[index];
      onMunroSelected(tappedMunro.id);
    }
    return true;
  }
}
