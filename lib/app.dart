import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class App extends StatelessWidget {
  final String flavor;
  late GoogleMapController _googleMapController;
  App({super.key, required this.flavor});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: GoogleMap(
        onMapCreated: (controller) {
          _googleMapController = controller;
        },
        initialCameraPosition: CameraPosition(
          target: LatLng(57, -4),
        ),
      ),
    );
  }
}
