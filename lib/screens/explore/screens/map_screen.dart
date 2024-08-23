// ignore_for_file: unused_field

import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:two_eight_two/models/models.dart';
import 'package:two_eight_two/repos/repos.dart';
import 'package:two_eight_two/screens/notifiers.dart';
import 'package:two_eight_two/screens/explore/widgets/widgets.dart';
import 'package:two_eight_two/screens/screens.dart';
import 'package:two_eight_two/services/services.dart';

class MapScreen extends StatefulWidget {
  final FocusNode searchFocusNode;
  const MapScreen({super.key, required this.searchFocusNode});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  bool loading = true;
  late GoogleMapController _googleMapController;
  BitmapDescriptor _completedIcon = BitmapDescriptor.defaultMarker;
  BitmapDescriptor _incompletedIcon = BitmapDescriptor.defaultMarker;
  BitmapDescriptor _selectedIcon = BitmapDescriptor.defaultMarker;
  double _currentZoom = 6.6;
  String? _selectedMunroID;
  bool showTerrain = false;

  @override
  void initState() {
    super.initState();
    loadData();
    addCustomIcon();
  }

  void loadData() async {
    showTerrain = await SharedPreferencesService.getMapTerrain();
    await MunroDatabase.loadBasicMunroData(context).then(
      (value) => setState(() => loading = false),
    );
  }

  Set<Marker> getMarkers({required MunroState munroState}) {
    Set<Marker> markers = {};
    for (var munro in munroState.filteredMunroList) {
      markers.add(
        Marker(
          markerId: MarkerId(
            munro.id.toString(),
          ),
          position: LatLng(munro.lat, munro.lng),
          visible: true,
          consumeTapEvents: true,
          icon: _selectedMunroID == munro.id
              ? _selectedIcon
              : munro.summited
                  ? _completedIcon
                  : _incompletedIcon,
          anchor: const Offset(0.5, 0.7),
          draggable: false,
          onTap: () {
            markerTapped(munro);
            setState(() {
              _selectedMunroID = munro.id;
            });

            munroState.setSelectedMunroId = munro.id;
          },
        ),
      );
    }
    return markers;
  }

  markerTapped(Munro munro) {
    final offsetLatLng = LatLng(
      munro.lat,
      munro.lng,
    );
    widget.searchFocusNode.unfocus();
    _googleMapController.animateCamera(CameraUpdate.newLatLng(offsetLatLng));
  }

  Future<Uint8List> getBytesFromAsset(String path, int width) async {
    ByteData data = await rootBundle.load(path);
    ui.Codec codec = await ui.instantiateImageCodec(data.buffer.asUint8List(), targetWidth: width);
    ui.FrameInfo fi = await codec.getNextFrame();
    return (await fi.image.toByteData(format: ui.ImageByteFormat.png))!.buffer.asUint8List();
  }

  Future addCustomIcon() async {
    final Uint8List incompleteMarkerIcon = await getBytesFromAsset(
      'assets/munro_incomplete.png',
      (_currentZoom * 7).round(),
    );
    final Uint8List completeMarkerIcon = await getBytesFromAsset(
      'assets/munro_complete.png',
      (_currentZoom * 7).round(),
    );
    final Uint8List selectedMarkerIcon = await getBytesFromAsset(
      'assets/munro_selected.png',
      (_currentZoom * 7).round(),
    );

    if (mounted) {
      setState(() {
        _incompletedIcon = BitmapDescriptor.fromBytes(incompleteMarkerIcon);
        _completedIcon = BitmapDescriptor.fromBytes(completeMarkerIcon);
        _selectedIcon = BitmapDescriptor.fromBytes(selectedMarkerIcon);
      });
    }
  }

  Widget _buildGoogleMap(MunroState munroState) {
    return GoogleMap(
      onMapCreated: (controller) {
        _googleMapController = controller;
        if (munroState.latLngBounds != null) {
          _googleMapController.animateCamera(CameraUpdate.newLatLngBounds(munroState.latLngBounds!, 0));
        }
      },
      initialCameraPosition: const CameraPosition(
        target: LatLng(56.8, -4.2),
        zoom: 6.6,
      ),
      onCameraMove: (position) async {
        if (_currentZoom < position.zoom - 1 || _currentZoom > position.zoom + 1) {
          _currentZoom = position.zoom;
          addCustomIcon();
        }
        LatLngBounds bounds = await _googleMapController.getVisibleRegion();
        munroState.setLatLngBounds = bounds;
      },
      cameraTargetBounds: CameraTargetBounds(
        LatLngBounds(
          northeast: const LatLng(58.5, -3),
          southwest: const LatLng(55, -6.4),
        ),
      ),
      onTap: (argument) {
        widget.searchFocusNode.unfocus();
        setState(() => _selectedMunroID = null);
        munroState.setSelectedMunroId = null;
      },
      minMaxZoomPreference: const MinMaxZoomPreference(6.6, 11.5),
      buildingsEnabled: false,
      trafficEnabled: false,
      liteModeEnabled: false,
      indoorViewEnabled: false,
      tiltGesturesEnabled: false,
      mapToolbarEnabled: false,
      compassEnabled: true,
      zoomControlsEnabled: false,
      mapType: showTerrain ? MapType.terrain : MapType.hybrid,
      padding: const EdgeInsets.all(20),
      markers: getMarkers(munroState: munroState),
      myLocationButtonEnabled: false,
      myLocationEnabled: false,
    );
  }

  @override
  Widget build(BuildContext context) {
    MunroState munroState = Provider.of<MunroState>(context, listen: true);
    return Scaffold(
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : Stack(
              children: [
                _buildGoogleMap(munroState),
                Align(alignment: Alignment.bottomCenter, child: MunroSummaryTile(munroId: _selectedMunroID)),
              ],
            ),
    );
  }
}
