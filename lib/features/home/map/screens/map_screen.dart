// ignore_for_file: unused_field

import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:two_eight_two/features/home/map/widgets/widgets.dart';
import 'package:two_eight_two/general/models/models.dart';
import 'package:two_eight_two/general/notifiers/notifiers.dart';
import 'package:two_eight_two/general/services/services.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  bool loading = true;
  late GoogleMapController _googleMapController;
  BitmapDescriptor _icon = BitmapDescriptor.defaultMarker;
  double _currentZoom = 6.6;
  Munro? _selectedMunro;

  @override
  void initState() {
    super.initState();
    loadData();
    addCustomIcon();
  }

  void loadData() async {
    await MunroDatabaseService.loadBasicMunroData(context).then(
      (value) => setState(() => loading = false),
    );
  }

  Set<Marker> getMarkers(MunroNotifier munroNotifier) {
    Set<Marker> markers = {};

    for (var munro in munroNotifier.munroList) {
      markers.add(
        Marker(
          markerId: MarkerId(
            munro.id.toString(),
          ),
          position: LatLng(munro.lat, munro.lng),
          visible: true,
          consumeTapEvents: true,
          icon: _icon,
          anchor: const Offset(0.5, 0.7),
          draggable: false,
          onTap: () => setState(() => _selectedMunro = munro),
        ),
      );
    }
    return markers;
  }

  Future<Uint8List> getBytesFromAsset(String path, int width) async {
    ByteData data = await rootBundle.load(path);
    ui.Codec codec =
        await ui.instantiateImageCodec(data.buffer.asUint8List(), targetWidth: width);
    ui.FrameInfo fi = await codec.getNextFrame();
    return (await fi.image.toByteData(format: ui.ImageByteFormat.png))!
        .buffer
        .asUint8List();
  }

  Future addCustomIcon() async {
    final Uint8List markerIcon = await getBytesFromAsset(
      'assets/munro_incomplete.png',
      (_currentZoom * 7).round(),
    );

    setState(() {
      _icon = BitmapDescriptor.fromBytes(markerIcon);
    });
  }

  Widget _buildGoogleMap(MunroNotifier munroNotifier) {
    return GoogleMap(
      onMapCreated: (controller) => _googleMapController = controller,
      initialCameraPosition: const CameraPosition(
        target: LatLng(56.8, -4.2),
        zoom: 6.6,
      ),
      onCameraMove: (position) {
        if (_currentZoom < position.zoom - 1 || _currentZoom > position.zoom + 1) {
          setState(() {
            _currentZoom = position.zoom;
            addCustomIcon();
          });
        }
      },
      cameraTargetBounds: CameraTargetBounds(
        LatLngBounds(
          northeast: const LatLng(57.5, -3),
          southwest: const LatLng(55, -5.5),
        ),
      ),
      onTap: (argument) => setState(() => _selectedMunro = null),
      minMaxZoomPreference: const MinMaxZoomPreference(6.6, 11),
      buildingsEnabled: false,
      trafficEnabled: false,
      liteModeEnabled: false,
      indoorViewEnabled: false,
      tiltGesturesEnabled: false,
      mapToolbarEnabled: false,
      compassEnabled: true,
      zoomControlsEnabled: false,
      mapType: MapType.terrain,
      padding: const EdgeInsets.all(20),
      markers: getMarkers(munroNotifier),
    );
  }

  @override
  Widget build(BuildContext context) {
    MunroNotifier munroNotifier = Provider.of<MunroNotifier>(context, listen: true);
    return Scaffold(
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : Stack(
              children: [
                _buildGoogleMap(munroNotifier),
                _selectedMunro != null
                    ? MunroBottomSheet(munro: _selectedMunro!)
                    : const SizedBox(),
              ],
            ),
    );
  }
}
