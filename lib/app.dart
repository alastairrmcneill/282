import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:two_eight_two/general/notifiers/notifiers.dart';
import 'package:two_eight_two/general/services/services.dart';

class App extends StatelessWidget {
  final String flavor;
  late GoogleMapController _googleMapController;
  App({super.key, required this.flavor});

  @override
  Widget build(BuildContext context) {
    MunroDatabaseService.loadBasicMunroData();

    return MultiProvider(
      providers: [
        ChangeNotifierProvider<MunroNotifier>(
          create: (_) => MunroNotifier(),
        ),
      ],
      child: MaterialApp(
        home: GoogleMap(
          onMapCreated: (controller) {
            _googleMapController = controller;
          },
          initialCameraPosition: CameraPosition(
            target: LatLng(57, -4),
          ),
        ),
      ),
    );
  }
}
