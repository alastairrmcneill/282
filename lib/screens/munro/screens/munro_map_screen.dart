import 'package:flutter/material.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
import 'package:two_eight_two/helpers/helpers.dart';
import 'package:two_eight_two/models/models.dart';

class MunroMapScreenArgs {
  final Munro munro;
  MunroMapScreenArgs({required this.munro});
}

class MunroMapScreen extends StatefulWidget {
  final Munro munro;
  const MunroMapScreen({super.key, required this.munro});

  static const String route = '/munro/map';

  @override
  State<MunroMapScreen> createState() => _MunroMapScreenState();
}

class _MunroMapScreenState extends State<MunroMapScreen> {
  static const String _lightStyleUri = "mapbox://styles/alastairm94/cmrery5gw002e01sc228mf3ca";
  static const String _darkStyleUri = "mapbox://styles/alastairm94/cmresimnz003h01qwddir1nnh";

  MapboxMap? _mapboxMap;
  Brightness? _lastBrightness;

  String _activeStyleUri(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark ? _darkStyleUri : _lightStyleUri;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final brightness = Theme.of(context).brightness;
    if (_lastBrightness != null && _lastBrightness != brightness) {
      _mapboxMap?.loadStyleURI(brightness == Brightness.dark ? _darkStyleUri : _lightStyleUri);
    }
    _lastBrightness = brightness;
  }

  Future<void> _onMapCreated(MapboxMap mapboxMap) async {
    _mapboxMap = mapboxMap;

    final icon = await loadSvgMarker(
      'assets/munro-icons-svg/selected-${munroAreaSlug(widget.munro.area)}.svg',
    );
    final annotationManager = await mapboxMap.annotations.createPointAnnotationManager();
    await annotationManager.create(
      PointAnnotationOptions(
        geometry: Point(coordinates: Position(widget.munro.lng, widget.munro.lat)),
        image: icon,
        iconSize: 0.9,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: MapWidget(
        key: const ValueKey("munroMapScreen"),
        styleUri: _activeStyleUri(context),
        cameraOptions: CameraOptions(
          center: Point(coordinates: Position(widget.munro.lng, widget.munro.lat)),
          zoom: 7.5,
        ),
        onMapCreated: _onMapCreated,
      ),
    );
  }
}
