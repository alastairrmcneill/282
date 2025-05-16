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
  PointAnnotation? _previousSelectedAnnotation;
  PointAnnotation? _selectedAnnotation;
  List<PointAnnotation?> currentAnnotations = [];
  final Map<String, PointAnnotation> _annotationMap = {};

  String? _selectedMunroID;
  bool showTerrain = false;
  bool _tappedAnnotation = false;

  CameraOptions startingCamera = CameraOptions(
    center: Point(coordinates: Position(-4.2, 56.8)),
    zoom: 5.5,
  );

  late Uint8List incompleteIcon;
  late Uint8List completeIcon;
  late Uint8List selectedIcon;

  @override
  void initState() {
    super.initState();

    loadData();
  }

  void loadData() async {
    incompleteIcon = await _loadMarker('assets/munro_incomplete.png');
    completeIcon = await _loadMarker('assets/munro_complete.png');
    selectedIcon = await _loadMarker('assets/munro_selected.png');

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
          ),
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

    _annotationManager = await _mapboxMap.annotations.createPointAnnotationManager();

    List<PointAnnotationOptions> markers = [];

    for (var munro in munros) {
      final icon = _selectedMunroID == munro.id
          ? selectedIcon
          : munro.summited
              ? completeIcon
              : incompleteIcon;

      markers.add(
        PointAnnotationOptions(
          geometry: Point(coordinates: Position(munro.lng, munro.lat)),
          image: icon,
          iconSize: 0.6,
        ),
      );
    }

    currentAnnotations = await _annotationManager.createMulti(markers);

    for (int i = 0; i < munros.length; i++) {
      _annotationMap[munros[i].id] = currentAnnotations[i]!;
    }

    _annotationManager.addOnPointAnnotationClickListener(
      MunroAnnotationClickListener(
        onMunroAnnotationSelected: (annotation) async {
          _tappedAnnotation = true;

          if (annotation.id == _selectedAnnotation?.id) {
            return true;
          }

          if (_previousSelectedAnnotation != null && _selectedAnnotation != null) {
            // Delete the previously selected annotation
            _annotationManager.delete(_selectedAnnotation!);

            // Create a new annotation with the original icon
            var newPreviouslySelectedAnnotation = PointAnnotationOptions(
              geometry: _previousSelectedAnnotation!.geometry,
              image: _previousSelectedAnnotation!.image,
              iconSize: 0.6,
            );

            var recreatedAnnotation = await _annotationManager.create(newPreviouslySelectedAnnotation);

            // Update the currentAnnotations list
            int previousIndex = currentAnnotations.indexWhere((element) => element?.id == _selectedAnnotation?.id);
            if (previousIndex != -1) {
              currentAnnotations[previousIndex] = recreatedAnnotation;
            }

            _previousSelectedAnnotation = null;
            _selectedAnnotation = null;
          }

          // Delete the one we just clicked
          _annotationManager.delete(annotation);

          var newAnnotation = PointAnnotationOptions(
            geometry: annotation.geometry,
            image: selectedIcon,
            iconSize: 0.6,
          );

          _previousSelectedAnnotation = annotation;
          _selectedAnnotation = await _annotationManager.create(newAnnotation);

          // Update the currentAnnotations list
          int clickedIndex = currentAnnotations.indexWhere((element) => element?.id == _previousSelectedAnnotation?.id);

          if (clickedIndex != -1) {
            currentAnnotations[clickedIndex] = _selectedAnnotation;
            _selectedMunroID = munros[clickedIndex].id;
            munroState.setSelectedMunroId = munros[clickedIndex].id;
          }
        },
      ),
    );
  }

  Future<Uint8List> _loadMarker(String assetPath) async {
    ByteData data = await rootBundle.load(assetPath);
    ui.Codec codec = await ui.instantiateImageCodec(data.buffer.asUint8List(), targetWidth: 100);
    ui.FrameInfo fi = await codec.getNextFrame();
    return (await fi.image.toByteData(format: ui.ImageByteFormat.png))!.buffer.asUint8List();
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
                      cameraOptions: startingCamera,
                      onTapListener: (MapContentGestureContext eventData) async {
                        widget.searchFocusNode.unfocus();

                        if (_tappedAnnotation) {
                          _tappedAnnotation = false;
                          return;
                        }

                        setState(() => _selectedMunroID = null);
                        munroState.setSelectedMunroId = null;

                        if (_previousSelectedAnnotation != null && _selectedAnnotation != null) {
                          // Delete the previously selected annotation
                          _annotationManager.delete(_selectedAnnotation!);

                          // Create a new annotation with the original icon
                          var newPreviouslySelectedAnnotation = PointAnnotationOptions(
                            geometry: _previousSelectedAnnotation!.geometry,
                            image: _previousSelectedAnnotation!.image,
                            iconSize: 0.6,
                          );

                          var recreatedAnnotation = await _annotationManager.create(newPreviouslySelectedAnnotation);

                          // Update the currentAnnotations list
                          int previousIndex =
                              currentAnnotations.indexWhere((element) => element?.id == _selectedAnnotation?.id);
                          if (previousIndex != -1) {
                            currentAnnotations[previousIndex] = recreatedAnnotation;
                          }

                          _previousSelectedAnnotation = null;
                          _selectedAnnotation = null;
                        }
                      },
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
  final Function(PointAnnotation) onMunroAnnotationSelected;

  MunroAnnotationClickListener({
    required this.onMunroAnnotationSelected,
  });

  @override
  bool onPointAnnotationClick(PointAnnotation annotation) {
    print("Annotation clicked: ${annotation.id}");
    onMunroAnnotationSelected(annotation);
    return true;
  }
}
