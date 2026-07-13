import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:two_eight_two/models/models.dart';

class MunroMapScreenArgs {
  final Munro munro;
  MunroMapScreenArgs({required this.munro});
}

class MunroMapScreen extends StatelessWidget {
  final Munro munro;
  const MunroMapScreen({super.key, required this.munro});

  static const String route = '/munro/map';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: GoogleMap(
        initialCameraPosition: CameraPosition(
          target: LatLng(munro.lat, munro.lng),
          zoom: 7.5,
        ),
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).padding.bottom,
        ),
        buildingsEnabled: false,
        trafficEnabled: false,
        liteModeEnabled: false,
        indoorViewEnabled: false,
        mapToolbarEnabled: false,
        compassEnabled: true,
        zoomControlsEnabled: true,
        mapType: MapType.terrain,
        markers: {
          Marker(
            markerId: MarkerId(munro.id.toString()),
            position: LatLng(munro.lat, munro.lng),
            visible: true,
          ),
        },
        myLocationButtonEnabled: false,
        myLocationEnabled: false,
      ),
    );
  }
}
