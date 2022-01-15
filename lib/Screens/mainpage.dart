import 'package:cargo_tracking/Screens/Searchpage.dart';
import 'package:cargo_tracking/brand_colors.dart';
import 'package:cargo_tracking/dataprovider/appdata.dart';
import 'package:cargo_tracking/helpers/helpermethods.dart';
import 'package:cargo_tracking/styles/styles.dart';
import 'package:cargo_tracking/widgets/BrandDivider.dart';
import 'package:cargo_tracking/widgets/ProgressDialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
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

class _MainPageState extends State<MainPage> {
  bool isLoading = false;
  final Completer<GoogleMapController> _controller = Completer();
  double mapBottomPadding = 0;
  double searchSheetHeight = (Platform.isIOS) ? 300 : 275;
  GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

  late GoogleMapController mapController;
  List<LatLng> polyLineCoordinates = [];
  Set<Polyline> polylines= {};

  var geoLocator = Geolocator();
  late Position currentPosition;

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
    CameraPosition cp = CameraPosition(target: pos, zoom: 14);
    setState(() {
      isLoading = false;
    });



  }
  @override
  void initState() {
    super.initState();
    setupPositionLocator();
  }

  @override
  Widget build(BuildContext context) {
    return isLoading ? const ProgressDialog(status: 'Loading...'): Scaffold(
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
              ],
            ),
          ),
        ),
        body: Stack(
          children: <Widget>[
            GoogleMap(
              padding: EdgeInsets.only(bottom: mapBottomPadding),
              // initialCameraPosition: _kGooglePlex,
              initialCameraPosition: CameraPosition(
                target: LatLng(currentPosition.latitude, currentPosition.longitude),
                zoom: 14.4746,
              ),
              myLocationEnabled: true,
              compassEnabled: true,
              zoomGesturesEnabled: true,
              mapType: MapType.normal,
              myLocationButtonEnabled: true,
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
                  scaffoldKey.currentState?.openDrawer();
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
                  child: const CircleAvatar(
                    backgroundColor: Colors.white,
                    radius: 20,
                    child: Icon(
                      Icons.menu,
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
              child: Container(
                height: searchSheetHeight,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(15),
                      topRight: Radius.circular(15)),
                ),
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
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
                        style:
                            TextStyle(fontSize: 18, fontFamily: 'Brand-Bold'),
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      GestureDetector(
                        onTap: () async{
                          var response = await Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => const SearchPage()));
                          if(response=='getDirection'){
                            await getDirection();
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
                            children:  <Widget>[
                              Container(
                                  width: MediaQuery.of(context).size.width * .75,
                                  child: Text((Provider.of<AppData>(context).pickupAddress !=null) ? Provider.of<AppData>(context,listen: false).pickupAddress.placeName :"Add Home",
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
          ],
        ));
  }

  Future<void> getDirection() async{
    var pickup = Provider.of<AppData>(context,listen: false).pickupAddress;
    var destination = Provider.of<AppData>(context,listen: false).destinationAddress;

    var pickupLatLng = LatLng(pickup.latitude, pickup.longitude);
    var destinationLatLng = LatLng(destination.latitude, destination.longitude);
    showDialog(
        context: context,
        builder: (BuildContext context)=>const ProgressDialog(status: 'Please wait...'),
      barrierDismissible: false
    );
    var thisDetails = await HelperMethods.getDirectionsDetails(pickupLatLng, destinationLatLng);
    Navigator.pop(context);
    PolylinePoints polylinePoints = PolylinePoints();
    List<PointLatLng> results = polylinePoints.decodePolyline(thisDetails!.encodedPoints);
  }
}
