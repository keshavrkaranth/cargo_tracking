import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:cargo_tracking/Screens/phonelogin.dart';
import 'package:cargo_tracking/Screens/searchpage.dart';
import 'package:cargo_tracking/brand_colors.dart';
import 'package:cargo_tracking/constants.dart';
import 'package:cargo_tracking/datamodels/directionsdetails.dart';
import 'package:cargo_tracking/datamodels/nearbydriver.dart';
import 'package:cargo_tracking/dataprovider/appdata.dart';
import 'package:cargo_tracking/helpers/firehelper.dart';
import 'package:cargo_tracking/helpers/helpermethods.dart';
import 'package:cargo_tracking/styles/styles.dart';
import 'package:cargo_tracking/widgets/BrandDivider.dart';
import 'package:cargo_tracking/widgets/ProgressDialog.dart';
import 'package:cargo_tracking/widgets/TaxiButton.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_geofire/flutter_geofire.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'dart:async';
import 'dart:io';
import 'package:flutter/services.dart';

import 'package:provider/provider.dart';

class MainPage extends StatefulWidget {
  static const String id = 'main';
  MainPage({Key? key}) : super(key: key);

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> with TickerProviderStateMixin {
  bool isLoading = false;
  final Completer<GoogleMapController> _controller = Completer();
  double mapBottomPadding = 0;
  double searchSheetHeight = (Platform.isIOS) ? 300 : 275;
  GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  double rideDetailsHeight = 0; //(Platform.isAndroid) ? 235 : 200;
  double requestingSheetHeight = 0; //(Platform.isAndroid) ? 195 : 220;

  late DatabaseReference rideRef;

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


  late BitmapDescriptor nearbyIcon;

  Future<void> setupPositionLocator() async {
    setState(() {
      isLoading = true;
    });
    LocationPermission permission = await Geolocator.requestPermission();
    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.bestForNavigation);
    await HelperMethods.findCordinateAddress(position, context);
    setState(() {
      currentPosition = position;
    });
    LatLng pos = LatLng(position.latitude, position.longitude);
    cp = CameraPosition(target: pos, zoom: 14);
    setState(() {
      isLoading = false;
    });
    setGeoFireListner();
  }

  void showDetailsSheet() async {
    await getDirection();
    setState(() {
      searchSheetHeight = 0;
      rideDetailsHeight = (Platform.isAndroid) ? 235 : 260;
      mapBottomPadding = (Platform.isAndroid) ? 240 : 230;
      drawerCanOpen = false;
    });
  }

  void showRequestingSheet() {
    setState(() {
      rideDetailsHeight = 0;
      requestingSheetHeight = (Platform.isAndroid) ? 195 : 220;
      mapBottomPadding = (Platform.isAndroid) ? 200 : 190;
      drawerCanOpen = true;
    });
    createRideRequest();
  }

  void createMarker() {
      ImageConfiguration imageConfiguration =
          createLocalImageConfiguration(context, size: const Size(2, 2));
      BitmapDescriptor.fromAssetImage(imageConfiguration,
          (Platform.isIOS) ? 'images/car_ios.png' : 'images/car_android.png').then((icon) {
            nearbyIcon = icon;
      });
  }

  @override
  void initState() {
    super.initState();

    setupPositionLocator();
    tripDirectionDetails = DirectionDetails(
        distanceText: '0',
        durationText: '0',
        distanceValue: '0',
        durationValue: '0',
        encodedPoints: '0');
    HelperMethods.getCurrentUserInfo();

  }

  @override
  Widget build(BuildContext context) {
  createMarker();

    return isLoading
        ? const ProgressDialog(status: 'Loading...')
        : Scaffold(
            key: scaffoldKey,
            drawer: Container(
              width: 250,
              color: Colors.white,
              // navigation drawer
              child: Drawer(
                child: ListView(
                  padding: const EdgeInsets.all(0),
                  children: <Widget>[
                    Container(
                      color: Colors.white,
                      height: 160,
                      child: DrawerHeader(
                        decoration: const BoxDecoration(
                          color: Colors.white,
                        ),
                        child: Row(
                          children: <Widget>[
                            Image.asset(
                              'images/user_icon.png',
                              height: 60,
                              width: 60,
                            ),
                            const SizedBox(
                              width: 15,
                            ),
                            Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: const <Widget>[
                                Text(
                                  'Keshav',
                                  style: TextStyle(
                                      fontSize: 20, fontFamily: 'Brand-Bold'),
                                ),
                                SizedBox(
                                  height: 5,
                                ),
                                Text('View Profile'),
                              ],
                            )
                          ],
                        ),
                      ),
                    ),
                    const BrandDivider(),
                    const SizedBox(
                      height: 10,
                    ),
                    const ListTile(
                      leading: Icon(Icons.navigation),
                      title: Text(
                        'Add a navigation',
                        style: kDrawerItemStyle,
                      ),
                    ),
                    const ListTile(
                      leading: Icon(Icons.history),
                      title: Text(
                        'Navigation History',
                        style: kDrawerItemStyle,
                      ),
                    ),
                    const ListTile(
                      leading: Icon(Icons.contact_support),
                      title: Text(
                        'Support',
                        style: kDrawerItemStyle,
                      ),
                    ),
                    const ListTile(
                      leading: Icon(Icons.info),
                      title: Text(
                        'About',
                        style: kDrawerItemStyle,
                      ),
                    ),
                     ListTile(
                       onTap: ()async {
                         await FirebaseAuth.instance.signOut();
                         Navigator.pushReplacement(context,
                         MaterialPageRoute(builder: (context)=>PhoneLogin()));
                       },
                      leading: const Icon(Icons.logout),
                      title: const Text(
                        'Logout',
                        style: kDrawerItemStyle,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            body: Stack(
              children: <Widget>[
                GoogleMap(
                  padding: EdgeInsets.only(bottom: mapBottomPadding),
                  // initialCameraPosition: _kGooglePlex,
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

                    setState(() {
                      mapBottomPadding = (Platform.isAndroid) ? 280 : 270;
                    });
                  },
                ),
                // menu button
                Positioned(
                  top: 44,
                  left: 20,
                  child: GestureDetector(
                    onTap: () {
                      if (drawerCanOpen) {
                        scaffoldKey.currentState?.openDrawer();
                      } else {
                        resetApp();
                      }
                    },
                    child: Container(
                      decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: const [
                            BoxShadow(
                                color: Colors.black26,
                                blurRadius: 5.0,
                                spreadRadius: 0.5,
                                offset: Offset(
                                  0.7,
                                  0.7,
                                )),
                          ]),
                      child: CircleAvatar(
                        backgroundColor: Colors.white,
                        radius: 20,
                        child: Icon(
                          (drawerCanOpen) ? Icons.menu : Icons.arrow_back,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                  ),
                ),
                // search sheet
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: AnimatedSize(
                    vsync: this,
                    duration: const Duration(microseconds: 150),
                    curve: Curves.easeIn,
                    child: Container(
                      height: searchSheetHeight,
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(15),
                            topRight: Radius.circular(15)),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 24, vertical: 18),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            const SizedBox(
                              height: 5,
                            ),
                            const Text(
                              'Nice to see you!',
                              style: TextStyle(fontSize: 10),
                            ),
                            const Text(
                              'Where are you going?',
                              style: TextStyle(
                                  fontSize: 18, fontFamily: 'Brand-Bold'),
                            ),
                            const SizedBox(
                              height: 20,
                            ),
                            GestureDetector(
                              onTap: () async {
                                var response = await Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            const SearchPage()));
                                if (response == 'getDirection') {
                                  showDetailsSheet();
                                }
                              },
                              child: Container(
                                decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(4),
                                    boxShadow: const [
                                      BoxShadow(
                                        color: Colors.black12,
                                        blurRadius: 5.0,
                                        spreadRadius: 0.5,
                                        offset: Offset(0.7, 0.7),
                                      )
                                    ]),
                                child: Padding(
                                  padding: const EdgeInsets.all(12.0),
                                  child: Row(
                                    children: const <Widget>[
                                      Icon(
                                        Icons.search,
                                        color: Colors.blueAccent,
                                      ),
                                      SizedBox(
                                        width: 10,
                                      ),
                                      Text('Search destination'),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(
                              height: 22,
                            ),
                            Row(
                              children: <Widget>[
                                const Icon(
                                  Icons.home,
                                  color: BrandColors.colorDimText,
                                ),
                                const SizedBox(
                                  width: 12,
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    Container(
                                        width:
                                            MediaQuery.of(context).size.width *
                                                .75,
                                        child: Text(
                                          (Provider.of<AppData>(context)
                                                      .pickupAddress !=
                                                  null)
                                              ? Provider.of<AppData>(context,
                                                      listen: false)
                                                  .pickupAddress
                                                  .placeName
                                              : "Add Home",
                                          overflow: TextOverflow.ellipsis,
                                          maxLines: 1,
                                        )),
                                    const SizedBox(
                                      height: 3,
                                    ),
                                    const Text(
                                      "Your residential address",
                                      style: TextStyle(
                                          fontSize: 11,
                                          color: BrandColors.colorDimText),
                                    ),
                                  ],
                                )
                              ],
                            ),
                            const SizedBox(
                              height: 10,
                            ),
                            const BrandDivider(),
                            const SizedBox(
                              height: 16,
                            ),
                            Row(
                              children: <Widget>[
                                const Icon(
                                  Icons.work,
                                  color: BrandColors.colorDimText,
                                ),
                                const SizedBox(
                                  width: 12,
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: const <Widget>[
                                    Text('Add Work'),
                                    SizedBox(
                                      height: 3,
                                    ),
                                    Text(
                                      "Your office address",
                                      style: TextStyle(
                                          fontSize: 11,
                                          color: BrandColors.colorDimText),
                                    ),
                                  ],
                                )
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                // ride details
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: AnimatedSize(
                    vsync: this,
                    duration: const Duration(milliseconds: 150),
                    child: Container(
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(15),
                            topRight: Radius.circular(15)),
                        boxShadow: [
                          BoxShadow(
                              color: Colors.black26,
                              blurRadius: 15.0,
                              spreadRadius: 0.5,
                              offset: Offset(0.7, 0.7))
                        ],
                      ),
                      height: rideDetailsHeight,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 18),
                        child: Column(
                          children: <Widget>[
                            Container(
                              width: double.infinity,
                              color: BrandColors.colorAccent1,
                              child: Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 16),
                                child: Row(
                                  children: <Widget>[
                                    Image.asset(
                                      'images/taxi.png',
                                      height: 70,
                                      width: 70,
                                    ),
                                    const SizedBox(
                                      width: 16,
                                    ),
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: <Widget>[
                                        const Text(
                                          'Taxi',
                                          style: TextStyle(
                                              fontSize: 18,
                                              fontFamily: 'Brand-Bold'),
                                        ),
                                        Text(
                                          (tripDirectionDetails != null)
                                              ? tripDirectionDetails
                                                  .distanceText
                                              : "12",
                                          style: const TextStyle(
                                              fontSize: 16,
                                              color:
                                                  BrandColors.colorTextLight),
                                        ),
                                      ],
                                    ),
                                    Expanded(child: Container()),
                                    Text(
                                      (tripDirectionDetails != null)
                                          ? '\$ ${HelperMethods.estimateFares(tripDirectionDetails)}'
                                          : "",
                                      style: const TextStyle(
                                          fontSize: 18,
                                          fontFamily: 'Brand-Bold'),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(
                              height: 22,
                            ),
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 16),
                              child: Row(
                                children: const <Widget>[
                                  Icon(
                                    FontAwesomeIcons.moneyBillAlt,
                                    size: 10,
                                    color: BrandColors.colorTextLight,
                                  ),
                                  SizedBox(
                                    width: 16,
                                  ),
                                  Text("Cash"),
                                  SizedBox(
                                    width: 5,
                                  ),
                                  Icon(
                                    Icons.keyboard_arrow_down,
                                    color: BrandColors.colorTextLight,
                                    size: 16,
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(
                              height: 22,
                            ),
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 16),
                              child: TaxiOutlineButton(
                                title: 'REQUEST CAB',
                                color: Colors.green,
                                onPressed: () {
                                  showRequestingSheet();
                                },
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                  ),
                ),

                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: AnimatedSize(
                    vsync: this,
                    duration: const Duration(milliseconds: 150),
                    child: GestureDetector(
                      onTap: () {
                        cancelRequest();
                        resetApp();
                      },
                      child: Container(
                        decoration: const BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(15),
                                topRight: Radius.circular(15)),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black26,
                                blurRadius: 15.0,
                                spreadRadius: 0.5,
                                offset: Offset(0.7, 0.7),
                              ),
                            ]),
                        height: requestingSheetHeight,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 24, vertical: 18),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: <Widget>[
                              const SizedBox(
                                height: 10,
                              ),
                              SizedBox(
                                width: double.infinity,
                                child: TextLiquidFill(
                                  text: 'Requesting a Ride...',
                                  waveColor: BrandColors.colorTextSemiLight,
                                  boxBackgroundColor: Colors.white,
                                  textStyle: const TextStyle(
                                    fontSize: 22,
                                    fontFamily: 'Brand-Bold',
                                  ),
                                  boxHeight: 40.0,
                                ),
                              ),
                              const SizedBox(
                                height: 20,
                              ),
                              Container(
                                height: 50,
                                width: 50,
                                decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(25),
                                    border: Border.all(
                                        width: 1.0,
                                        color: BrandColors.colorLightGrayFair)),
                                child: const Icon(
                                  Icons.close,
                                  size: 25,
                                ),
                              ),
                              Container(
                                width: double.infinity,
                                child: const Text(
                                  'Cancel Ride',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(fontSize: 12),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ));
  }

  Future<void> getDirection() async {
    var pickup = Provider.of<AppData>(context, listen: false).pickupAddress;
    var destination =
        Provider.of<AppData>(context, listen: false).destinationAddress;

    var pickupLatLng = LatLng(pickup.latitude, pickup.longitude);
    var destinationLatLng = LatLng(destination.latitude, destination.longitude);
    showDialog(
        context: context,
        builder: (BuildContext context) =>
            const ProgressDialog(status: 'Please wait...'),
        barrierDismissible: false);
    var thisDetails = await HelperMethods.getDirectionsDetails(
        pickupLatLng, destinationLatLng);
    setState(() {
      tripDirectionDetails = thisDetails!;
    });

    Navigator.pop(context);
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
    mapController.animateCamera(CameraUpdate.newLatLngBounds(bounds, 10));

    Marker pickupMarker = Marker(
      markerId: const MarkerId('pickup'),
      position: pickupLatLng,
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
      infoWindow: InfoWindow(title: pickup.placeName, snippet: 'My location'),
    );

    Marker destinationMarker = Marker(
      markerId: const MarkerId('pickup'),
      position: destinationLatLng,
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
      infoWindow:
          InfoWindow(title: destination.placeName, snippet: 'Destination'),
    );
    setState(() {
      markers.add(pickupMarker);
      markers.add(destinationMarker);
    });

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

  void setGeoFireListner() {
    Geofire.initialize('driversAvailable');
    Geofire.queryAtLocation(
            currentPosition.latitude, currentPosition.longitude, 20)!
        .listen((map) {
      if (map != null) {
        print(map);
        var callBack = map['callBack'];
        switch (callBack) {
          case Geofire.onKeyEntered:
            NearbyDriver nearbyDriver = NearbyDriver(
                key: map['key'],
                latitude: map['latitude'],
                longitude: map['longitude']);
            FireHelper.nearbyDriverList.add(nearbyDriver);
            if (nearByDriversKeysLoaded) {
              updateDriversOnmap();
            }

            break;

          case Geofire.onKeyExited:
            FireHelper.removeFromList(map['key']);
            updateDriversOnmap();
            break;

          case Geofire.onKeyMoved:
            NearbyDriver nearbyDriver = NearbyDriver(
                key: map['key'],
                latitude: map['latitude'],
                longitude: map['longitude']);
            print("CALLBACK CALLED1");
            FireHelper.updateNearbyLocation(nearbyDriver);
            updateDriversOnmap();
            break;

          case Geofire.onGeoQueryReady:
            nearByDriversKeysLoaded = true;
            print("CALLBACK CALLED");
            updateDriversOnmap();
            break;
        }
      }
    });
  }

  void updateDriversOnmap() {
    print("IN MARKERS");
    setState(() {
      markers.clear();
    });
    Set<Marker> tempMarkers = Set<Marker>();
    for (NearbyDriver driver in FireHelper.nearbyDriverList) {
      LatLng driversPosition = LatLng(driver.latitude, driver.longitude);
      Marker thisMarker = Marker(
        markerId: MarkerId("drivers${driver.key}"),
        position: driversPosition,
        icon: nearbyIcon,
        rotation: HelperMethods.generateRandomNumber(360),
      );

      tempMarkers.add(thisMarker);
    }
    setState(() {
      markers = tempMarkers;
    });
  }

  void createRideRequest() {
    rideRef = FirebaseDatabase.instance.reference().child('rideRequest').push();

    var pickup = Provider.of<AppData>(context, listen: false).pickupAddress;
    var destination =
        Provider.of<AppData>(context, listen: false).destinationAddress;

    Map pickupMap = {
      'latitude': pickup.latitude.toString(),
      'longitude': pickup.longitude.toString(),
    };

    Map destinationMap = {
      'latitude': destination.latitude.toString(),
      'longitude': destination.longitude.toString(),
    };

    Map rideMap = {
      'created_at': DateTime.now().toString(),
      'rider_name': currentUser.fullName,
      'rider_phone': currentUser.phone,
      'pickup_address': pickup.placeName,
      'destination_address': destination.placeName,
      'pickup': pickupMap,
      'destination': destinationMap,
      'payment_method': 'card',
      'driver_id': 'waiting..'
    };
    rideRef.set(rideMap);
  }

  void cancelRequest() {
    rideRef.remove();
  }

  resetApp() {
    setState(() {
      polyLineCoordinates.clear();
      polyLines.clear();
      markers.clear();
      circles.clear();
      rideDetailsHeight = 0;
      requestingSheetHeight = 0;
      searchSheetHeight = (Platform.isAndroid) ? 275 : 300;
      mapBottomPadding = (Platform.isAndroid) ? 280 : 270;
      drawerCanOpen = true;
    });
    setupPositionLocator();
  }
}
