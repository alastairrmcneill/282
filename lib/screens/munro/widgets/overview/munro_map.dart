import 'package:flutter/material.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:two_eight_two/extensions/extensions.dart';
import 'package:two_eight_two/helpers/helpers.dart';
import 'package:two_eight_two/models/models.dart';
import 'package:two_eight_two/screens/screens.dart';

class MunroMapWidget extends StatefulWidget {
  final Munro munro;
  final bool showExpandButton;
  const MunroMapWidget({super.key, required this.munro, this.showExpandButton = false});

  @override
  State<MunroMapWidget> createState() => _MunroMapWidgetState();
}

class _MunroMapWidgetState extends State<MunroMapWidget> {
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

  void _openFullMap() {
    Navigator.pushNamed(
      context,
      MunroMapScreen.route,
      arguments: MunroMapScreenArgs(munro: widget.munro),
    );
  }

  Future<void> _onMapCreated(MapboxMap mapboxMap) async {
    _mapboxMap = mapboxMap;
    await mapboxMap.compass.updateSettings(CompassSettings(enabled: false));
    await mapboxMap.scaleBar.updateSettings(ScaleBarSettings(enabled: false));
    await mapboxMap.gestures.updateSettings(
      GesturesSettings(rotateEnabled: false, pitchEnabled: false),
    );
    await mapboxMap.setBounds(
      CameraBoundsOptions(
        bounds: CoordinateBounds(
          southwest: Point(coordinates: Position(widget.munro.lng - 0.5, widget.munro.lat - 0.5)),
          northeast: Point(coordinates: Position(widget.munro.lng + 0.5, widget.munro.lat + 0.5)),
          infiniteBounds: false,
        ),
        minZoom: 7,
        maxZoom: 12,
      ),
    );

    final icon = await loadSvgMarker(
      'assets/munro-icons-svg/selected-${munroAreaSlug(widget.munro.area)}.svg',
    );
    final annotationManager = await mapboxMap.annotations.createPointAnnotationManager();
    await annotationManager.create(
      PointAnnotationOptions(
        geometry: Point(coordinates: Position(widget.munro.lng, widget.munro.lat)),
        image: icon,
        iconSize: 0.9,
        iconAnchor: IconAnchor.BOTTOM,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: SizedBox(
            height: 150,
            width: double.infinity,
            child: MapWidget(
              key: const ValueKey("munroMapWidget"),
              styleUri: _activeStyleUri(context),
              cameraOptions: CameraOptions(
                center: Point(coordinates: Position(widget.munro.lng, widget.munro.lat)),
                zoom: 9,
              ),
              onMapCreated: _onMapCreated,
              onTapListener: (_) => _openFullMap(),
            ),
          ),
        ),
        if (widget.showExpandButton)
          Positioned(
            top: 10,
            right: 10,
            child: InkWell(
              onTap: _openFullMap,
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.8),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  PhosphorIconsRegular.arrowsOutSimple,
                  size: 20,
                  color: context.colors.textSubtitle,
                ),
              ),
            ),
          ),
      ],
    );
  }
}
