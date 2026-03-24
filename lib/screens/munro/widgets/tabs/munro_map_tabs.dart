import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:two_eight_two/models/models.dart';
import 'package:two_eight_two/screens/screens.dart';
import 'package:two_eight_two/support/theme.dart';

class MunroMapTabs extends StatelessWidget {
  final Munro munro;
  final bool showExpandButton;
  const MunroMapTabs({super.key, required this.munro, this.showExpandButton = false});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: SizedBox(
            height: 150,
            width: double.infinity,
            child: GestureDetector(
              onTap: () {
                if (!showExpandButton) {
                  Navigator.pushNamed(
                    context,
                    MunroMapScreen.route,
                    arguments: MunroMapScreenArgs(munro: munro),
                  );
                }
              },
              child: GoogleMap(
                initialCameraPosition: CameraPosition(
                  target: LatLng(munro.lat, munro.lng),
                  zoom: 7,
                ),
                cameraTargetBounds: CameraTargetBounds(
                  LatLngBounds(
                    northeast: LatLng(munro.lat + 0.5, munro.lng + 0.5),
                    southwest: LatLng(munro.lat - 0.5, munro.lng - 0.5),
                  ),
                ),
                minMaxZoomPreference: const MinMaxZoomPreference(7, 12),
                buildingsEnabled: false,
                trafficEnabled: false,
                liteModeEnabled: false,
                indoorViewEnabled: false,
                tiltGesturesEnabled: false,
                mapToolbarEnabled: false,
                compassEnabled: true,
                zoomControlsEnabled: false,
                mapType: MapType.terrain,
                padding: const EdgeInsets.all(200),
                onTap: (argument) {
                  Navigator.pushNamed(
                    context,
                    MunroMapScreen.route,
                    arguments: MunroMapScreenArgs(munro: munro),
                  );
                },
                markers: {
                  Marker(
                    markerId: MarkerId(
                      munro.id.toString(),
                    ),
                    position: LatLng(munro.lat, munro.lng),
                    visible: true,
                    consumeTapEvents: true,
                    draggable: false,
                    onTap: () => Navigator.pushNamed(
                      context,
                      MunroMapScreen.route,
                      arguments: MunroMapScreenArgs(munro: munro),
                    ),
                  ),
                },
                myLocationButtonEnabled: false,
                myLocationEnabled: false,
              ),
            ),
          ),
        ),
        if (showExpandButton)
          Positioned(
            top: 10,
            right: 10,
            child: InkWell(
              onTap: () => Navigator.pushNamed(
                context,
                MunroMapScreen.route,
                arguments: MunroMapScreenArgs(munro: munro),
              ),
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.8),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  PhosphorIconsRegular.arrowsOutSimple,
                  size: 20,
                  color: MyColors.subtitleColor,
                ),
              ),
            ),
          ),
      ],
    );
  }
}
