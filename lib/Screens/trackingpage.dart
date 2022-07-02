import 'dart:async';
import 'dart:convert';

import 'package:cargo_tracking/widgets/ProgressDialog.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'dart:io';
import '../brand_colors.dart';
import '../datamodels/directionsdetails.dart';
import '../helpers/helpermethods.dart';
import '../helpers/mapkithelper.dart';

class TrackingPage extends StatefulWidget {
  final String trackingId;
  const TrackingPage({Key? key,required this.trackingId}) : super(key: key);

  @override
  State<TrackingPage> createState() => _TrackingPageState();
}

class _TrackingPageState extends State<TrackingPage> {

  bool isLoading = false;
  final Completer<GoogleMapController> _controller = Completer();
  double mapBottomPadding = 0;
  GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  double rideDetailsHeight = 0; //(Platform.isAndroid) ? 235 : 200;
  double requestingSheetHeight = 0; //(Platform.isAndroid) ? 195 : 220;
  StreamSubscription<DatabaseEvent>? _onTempSubscription;

  late GoogleMapController mapController;
  List<LatLng> polyLineCoordinates = [];
  final Set<Polyline> polyLines = {};
  Set<Marker> markers = {};
  Set<Circle> circles = {};
  late DirectionDetails tripDirectionDetails;
  bool drawerCanOpen = true;
  bool nearByDriversKeysLoaded = false;
  late CameraPosition cp;

  var geoLocator = Geolocator();
  late Position currentPosition;
  late Query _ref;

  late BitmapDescriptor nearbyIcon;
  late LatLng pickupLatLng;
  late LatLng destinationLatLng;
  late Position myPosition;
  late GoogleMapController rideMapController;
  Set<Marker> _markers = Set<Marker>();


  Future<void> setupPositionLocator() async {
    setState(() {
      isLoading = true;
    });
    DatabaseReference ref = FirebaseDatabase.instance.ref('cargos').child(widget.trackingId);
    await ref.once().then((value) {
      final snapshot = value.snapshot;
      final myData = json.decode(json.encode(snapshot.value));
      pickupLatLng = LatLng(myData['from_lat_lng']['latitude'], myData['from_lat_lng']['longitude']);
      destinationLatLng = LatLng(myData['to_lat_lng']['lat'], myData['to_lat_lng']['lng']);
      cp = CameraPosition(target: pickupLatLng, zoom: 14);


    });
    setState(() {
      isLoading = false;
    });
  }


  void createMarker() {
    ImageConfiguration imageConfiguration =
    createLocalImageConfiguration(context, size: const Size(2, 2));
    BitmapDescriptor.fromAssetImage(imageConfiguration,
        (Platform.isIOS) ? 'images/car_ios.png' : 'images/car_android.png').then((icon) {
      nearbyIcon = icon;
    });
  }

  void asyncMethod()async{
    await setupPositionLocator();
    createMarker();
    // await getDirection();
    print("Cp is $cp");
  }

  void getLocationUpdates() async {
    LatLng oldPosition = LatLng(0, 0);
    DatabaseReference ref = FirebaseDatabase.instance.ref('cargos').child(widget.trackingId);
    ref.once().then((value) {
      final myData = json.decode(json.encode(value.snapshot.value));
      LatLng pos  = LatLng(myData['from_lat_lng']['latitude'], myData['from_lat_lng']['longitude']);
      var rotation = MapKitHelper.getMarkerRotation(oldPosition.latitude,
          oldPosition.longitude, pos.latitude, pos.longitude);

      Marker movingMarker = Marker(
          markerId: const MarkerId("moving"),
          position: pos,
          rotation: rotation,
          icon: nearbyIcon,
          infoWindow: const InfoWindow(title: "Current Location"));

      setState(() {
        CameraPosition cp = CameraPosition(target: pos, zoom: 17);
        rideMapController.animateCamera(CameraUpdate.newCameraPosition(cp));
        _markers.removeWhere((marker) => marker.markerId.value == 'moving');
        _markers.add(movingMarker);
        print("Set state called");
      });
      oldPosition = pos;
    });

    
  }

  void getCurrentLocation() async{
    LatLng oldPosition = LatLng(0, 0);
    DatabaseReference ref = FirebaseDatabase.instance.ref('cargos').child(widget.trackingId);
    ref.onValue.listen((event) async {
      final myData = json.decode(json.encode(event.snapshot.value));
      LatLng pos  = LatLng(myData['from_lat_lng']['latitude'], myData['from_lat_lng']['longitude']);
      print("Pos is$pos");
      GoogleMapController googleMapController = await _controller.future;

      googleMapController.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(
            zoom: 13.5,
            target: LatLng(
              pos.latitude,
              pos.longitude,
            ),
          ),
        ),
      );
      var rotation = MapKitHelper.getMarkerRotation(oldPosition.latitude,
          oldPosition.longitude, pos.latitude, pos.longitude);
      Marker movingMarker = Marker(
          markerId: const MarkerId("moving"),
          position: pos,
          rotation: rotation,
          icon: nearbyIcon,
          infoWindow: const InfoWindow(title: "Current Location"));
      getDirection(pickupLatLng, destinationLatLng);
      if(mounted){
        setState(() {
          markers.removeWhere((marker) => marker.markerId.value == 'moving');
          markers.add(movingMarker);
          oldPosition = pos;
          pickupLatLng = pos;
        });
      }

    });
  }
  Future<void> getDirection(LatLng pickupLatLng, LatLng destinationLatLng) async {
    // showDialog(
    //     context: context,
    //     builder: (BuildContext context) =>
    //     const ProgressDialog(status: 'Please wait...'),
    //     barrierDismissible: false);
    var thisDetails = await HelperMethods.getDirectionsDetails(
        pickupLatLng, destinationLatLng);
    print("This details,$thisDetails");
    // Navigator.pop(context);

    PolylinePoints polylinePoints = PolylinePoints();
    List<PointLatLng> results =
    polylinePoints.decodePolyline(thisDetails!.encodedPoints);
    polyLineCoordinates.clear();
    if (results.isNotEmpty) {
      for (var point in results) {
        polyLineCoordinates.add(LatLng(point.latitude, point.longitude));
      }
    }
    polyLines.clear();
    setState(() {
      Polyline polyline = Polyline(
        polylineId: const PolylineId('polyid'),
        color: const Color.fromARGB(255, 95, 109, 237),
        points: polyLineCoordinates,
        jointType: JointType.round,
        width: 4,
        startCap: Cap.roundCap,
        endCap: Cap.roundCap,
        geodesic: true,
      );
      polyLines.add(polyline);
    });
    LatLngBounds bounds;
    if (pickupLatLng.latitude > destinationLatLng.latitude &&
        pickupLatLng.longitude > destinationLatLng.longitude) {
      bounds =
          LatLngBounds(southwest: destinationLatLng, northeast: pickupLatLng);
    } else if (pickupLatLng.longitude > destinationLatLng.longitude) {
      bounds = LatLngBounds(
          southwest: LatLng(pickupLatLng.latitude, destinationLatLng.longitude),
          northeast:
          LatLng(destinationLatLng.latitude, pickupLatLng.longitude));
    } else if (pickupLatLng.latitude > destinationLatLng.latitude) {
      bounds = LatLngBounds(
          southwest: LatLng(destinationLatLng.latitude, pickupLatLng.latitude),
          northeast:
          LatLng(pickupLatLng.latitude, destinationLatLng.longitude));
    } else {
      bounds =
          LatLngBounds(southwest: pickupLatLng, northeast: destinationLatLng);
    }
    rideMapController.animateCamera(CameraUpdate.newLatLngBounds(bounds, 10));

    Marker pickupMarker = Marker(
      markerId: const MarkerId('pickup'),
      position: pickupLatLng,
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
    );

    Marker destinationMarker = Marker(
      markerId: const MarkerId('drop'),
      position: destinationLatLng,
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
    );
    setState(() {
      markers.add(pickupMarker);
      markers.add(destinationMarker);
    });
    print("Markers,$_markers");

    Circle pickupCircle = Circle(
        circleId: const CircleId('pickup'),
        strokeColor: BrandColors.colorGreen,
        strokeWidth: 3,
        radius: 12,
        center: pickupLatLng,
        fillColor: BrandColors.colorGreen);

    Circle destinationCircle = Circle(
        circleId: const CircleId('destination'),
        strokeColor: BrandColors.colorAccentPurple,
        strokeWidth: 3,
        radius: 12,
        center: destinationLatLng,
        fillColor: BrandColors.colorAccentPurple);

    setState(() {
      circles.add(pickupCircle);
      circles.add(destinationCircle);
    });
  }


  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    asyncMethod();
    getCurrentLocation();


  }


  @override
  Widget build(BuildContext context) {
    return isLoading ? const ProgressDialog(status: 'Loading..'):Scaffold(
      body: Stack(
        children: <Widget>[
          GoogleMap(
            initialCameraPosition: cp,
            compassEnabled: true,
            zoomGesturesEnabled: true,
            mapType: MapType.normal,
            myLocationButtonEnabled: true,
            polylines: polyLines,
            markers: markers,
            circles: circles,
            onMapCreated: (GoogleMapController controller) {
              mapController = controller;
              _controller.complete(controller);
              getDirection(pickupLatLng, destinationLatLng);
            },
          ),
        ],
      ),
    );
  }
}

