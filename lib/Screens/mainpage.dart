import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'dart:async';

class MainPage extends StatefulWidget {
  static const String id = 'main';
  MainPage({Key? key}) : super(key: key);


  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  Completer<GoogleMapController> _controller = Completer();


  late GoogleMapController mapController;

  var geoLocator = Geolocator();
  late Position currentPositin;

  void setupPositionLocator() async{
    print("bojja");
    LocationPermission permission;
    permission = await Geolocator.requestPermission();
    Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.bestForNavigation);
    currentPositin = position;
    print("Position:${position}");
    LatLng pos = LatLng(position.latitude, position.longitude);
    CameraPosition cp = CameraPosition(target: pos,zoom: 14);
    mapController.animateCamera(CameraUpdate.newCameraPosition(cp));
  }
  static const CameraPosition _kGooglePlex = CameraPosition(
    target: LatLng(37.42796133580664, -122.085749655962),
    zoom: 14.4746,
  );
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cargo Tracking'),
      ),
      body: Stack(
        children:<Widget> [
          GoogleMap(
          initialCameraPosition: _kGooglePlex,
          myLocationEnabled: true,
          zoomGesturesEnabled: true,
          mapType: MapType.normal,
          myLocationButtonEnabled: true,
            onMapCreated: (GoogleMapController controller){
              _controller.complete(controller);
              mapController=controller;
              setupPositionLocator();
            },
          ),
        ],
      )
    );
  }
}


