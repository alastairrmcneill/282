import 'dart:math';
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

class MapboxMapScreen extends StatefulWidget {
  final FocusNode searchFocusNode;
  const MapboxMapScreen({super.key, required this.searchFocusNode});

  @override
  State<MapboxMapScreen> createState() => _MapboxMapScreenState();
}

class _MapboxMapScreenState extends State<MapboxMapScreen> {
  bool loading = true;
  late MapboxMap _mapboxMap;
  Map<String, PointAnnotation?> allAnnotations = {};
  String scotlandRegionId = "scotland-tile-region";
  String styleUri = "mapbox://styles/alastairm94/cmap1d7ho01le01s30cz9gt8v";

  PointAnnotation? selectedAnnotation;
  String? selectedMunroId;
  late PointAnnotationManager _annotationManager;
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

  late Uint8List incompleteIcon;
  late Uint8List completeIcon;
  late Uint8List selectedIcon;
  String mapAreaId = "full_map_area";

  @override
  void initState() {
    super.initState();
    checkAndDownloadMap();
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

  Future<void> checkAndDownloadMap() async {
    final OfflineManager offlineManager = await OfflineManager.create();
    final TileStore tileStore = await TileStore.createDefault();

    if (await _isRegionAlreadyDownloaded(tileStore)) {
      await _handleExistingRegion(offlineManager, tileStore);
    } else {
      await _downloadRegion(offlineManager, tileStore);
    }
  }

  Future<bool> _isRegionAlreadyDownloaded(TileStore tileStore) async {
    final List<TileRegion> regions = await tileStore.allTileRegions();
    return regions.any((region) => region.id == scotlandRegionId);
  }

  Future<void> _handleExistingRegion(OfflineManager offlineManager, TileStore tileStore) async {
    final List<TileRegion> regions = await tileStore.allTileRegions();
    final TileRegion region = regions.firstWhere((region) => region.id == scotlandRegionId);

    print("🚀 ~ region.completedResourceCount: ${region.completedResourceCount}");
    print("🚀 ~ region.requiredResourceCount: ${region.requiredResourceCount}");

    if (region.completedResourceCount < region.requiredResourceCount) {
      print("🚀 ~ removing region and starting again");
      await tileStore.removeRegion(scotlandRegionId);
      await _downloadRegion(offlineManager, tileStore);
    }
  }

  Future<void> _downloadRegion(OfflineManager offlineManager, TileStore tileStore) async {
    const double west = -6.3, south = 56, east = -2.9, north = 58.5;

    final scotlandPolygon = Polygon(coordinates: [
      [
        Position(west, south),
        Position(east, south),
        Position(east, north),
        Position(west, north),
        Position(west, south), // Close the ring
      ]
    ]);

    final regionGeometry = scotlandPolygon.toJson();
    final stylePackLoadOptions = StylePackLoadOptions(
      glyphsRasterizationMode: GlyphsRasterizationMode.IDEOGRAPHS_RASTERIZED_LOCALLY,
      metadata: {"tag": "scotland"},
      acceptExpired: false,
    );

    await offlineManager.loadStylePack(
      styleUri,
      stylePackLoadOptions,
      (progress) {},
    );

    final tileRegionLoadOptions = TileRegionLoadOptions(
      geometry: regionGeometry,
      descriptorsOptions: [
        TilesetDescriptorOptions(
          styleURI: styleUri,
          minZoom: 6,
          maxZoom: 7,
        ),
      ],
      metadata: {"tag": "scotland"},
      acceptExpired: true,
      networkRestriction: NetworkRestriction.NONE,
    );

    await tileStore.loadTileRegion(
      scotlandRegionId,
      tileRegionLoadOptions,
      (progress) {
        print("🚀 ~ progress.completedResourceCount: ${progress.completedResourceCount}");
        print("🚀 ~ progress.requiredResourceCount: ${progress.requiredResourceCount}");
      },
    );
  }

  void _onMapCreated(MapboxMap mapboxMap, MunroState munroState) async {
    _mapboxMap = mapboxMap;
    await mapboxMap.compass.updateSettings(CompassSettings(enabled: false));
    await mapboxMap.scaleBar.updateSettings(ScaleBarSettings(enabled: false));
    _mapboxMap.setBounds(cameraBounds);
    _addMunroSymbols(munroState: munroState);
  }

  Future<void> _addMunroSymbols({required MunroState munroState}) async {
    final List<Munro> munros = munroState.filteredMunroList;

    _annotationManager = await _mapboxMap.annotations.createPointAnnotationManager();

    List<PointAnnotationOptions> pointAnnotationOptions = [];

    for (var munro in munros) {
      final icon = selectedMunroId == munro.id
          ? selectedIcon
          : munro.summited
              ? completeIcon
              : incompleteIcon;

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

  Future<Uint8List> _loadMarker(String assetPath) async {
    ByteData data = await rootBundle.load(assetPath);
    ui.Codec codec = await ui.instantiateImageCodec(data.buffer.asUint8List(), targetWidth: 100);
    ui.FrameInfo fi = await codec.getNextFrame();
    return (await fi.image.toByteData(format: ui.ImageByteFormat.png))!.buffer.asUint8List();
  }

  void handleMapTap(ScreenCoordinate tapScreenPoint) async {
    const double threshold = 40.0;

    String? closestMunroId;
    PointAnnotation? closestAnnotation;
    double minDist = double.infinity;

    for (final entry in allAnnotations.entries) {
      final String munroId = entry.key;
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

    await deselectAnnotation();
    if (closestAnnotation != null && closestMunroId != null) {
      await selectAnnotation(closestMunroId, closestAnnotation);
    }
  }

  Future<void> deselectAnnotation() async {
    if (selectedAnnotation != null && selectedMunroId != null) {
      final MunroState munroState = Provider.of<MunroState>(context, listen: false);
      final Munro munro = munroState.munroList.firstWhere((munro) => munro.id == selectedMunroId);
      final PointAnnotationOptions oldAnnotationOptions = PointAnnotationOptions(
          geometry: selectedAnnotation!.geometry, image: munro.summited ? completeIcon : incompleteIcon, iconSize: 0.6);
      await _annotationManager.delete(selectedAnnotation!);
      var oldAnnotation = await _annotationManager.create(oldAnnotationOptions);
      allAnnotations[selectedMunroId!] = oldAnnotation;

      selectedAnnotation = null;
      munroState.setSelectedMunroId = null;
      setState(() {
        selectedMunroId = null;
      });
    }
  }

  Future<void> selectAnnotation(String munroId, PointAnnotation tappedAnnotation) async {
    final MunroState munroState = Provider.of<MunroState>(context, listen: false);
    final PointAnnotationOptions newAnnotationOptions = PointAnnotationOptions(
      geometry: tappedAnnotation.geometry,
      image: selectedIcon,
      iconSize: 0.7,
    );

    await _annotationManager.delete(tappedAnnotation);

    var newAnnotation = await _annotationManager.create(newAnnotationOptions);
    allAnnotations[munroId] = newAnnotation;
    selectedAnnotation = newAnnotation;
    munroState.setSelectedMunroId = munroId;
    setState(() {
      selectedMunroId = munroId;
    });

    await _mapboxMap.flyTo(
      CameraOptions(center: tappedAnnotation.geometry),
      MapAnimationOptions(duration: 1000),
    );
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
                      styleUri: styleUri,
                      cameraOptions: startingCamera,
                      onTapListener: (context) {
                        widget.searchFocusNode.unfocus();
                        handleMapTap(context.touchPosition);
                      },
                    ),
                    Align(
                      alignment: Alignment.bottomCenter,
                      child: MunroSummaryTile(munroId: selectedMunroId),
                    ),
                  ],
                );
              },
            ),
    );
  }
}
