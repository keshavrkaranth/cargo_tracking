import 'package:cargo_tracking/Constants.dart';
import 'package:cargo_tracking/datamodels/address.dart';
import 'package:cargo_tracking/datamodels/directionsdetails.dart';
import 'package:cargo_tracking/dataprovider/appdata.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'requesthelper.dart';
import 'package:connectivity/connectivity.dart';
import 'package:geolocator/geolocator.dart';

class HelperMethods {
  static Future<String> findCordinateAddress(Position position, context) async {
    String placeAddress = '';
    var connectivityResult = await Connectivity().checkConnectivity();
    if (connectivityResult != ConnectivityResult.mobile &&
        connectivityResult != ConnectivityResult.wifi) {
      return placeAddress;
    }

    String url =
        'https://maps.googleapis.com/maps/api/geocode/json?latlng=${position.latitude},${position.longitude}&key=$mapKey';

    var response = await RequestHelper.getRequest(url);
    if (response != 'failed') {
      placeAddress = response['results'][0]['formatted_address'];

      Address pickupAddress = Address(
          longitude: position.longitude,
          latitude: position.latitude,
          placeName: placeAddress,
          placeId: '1',
          placeFormatAddress: placeAddress);

      Provider.of<AppData>(context, listen: false)
          .updatePickupAddress(pickupAddress);
    }
    return placeAddress;
  }

  static Future<DirectionDetails?> getDirectionsDetails(LatLng start,LatLng end) async{
    String url = 'https://maps.googleapis.com/maps/api/directions/json?origin=${start.latitude},${start.longitude}&destination=${end.latitude},${end.longitude}&mode=driving&key=$mapKey';
    print(url);
    var response = await RequestHelper.getRequest(url);
    if(response == 'failed'){
      return null;
    }
    DirectionDetails directionDetails = DirectionDetails(
      durationText: response['routes'][0]['legs'][0]['duration']['text'],
      durationValue: response['routes'][0]['legs'][0]['duration']['value'].toString(),
      distanceText: response['routes'][0]['legs'][0]['distance']['text'],
      distanceValue: response['routes'][0]['legs'][0]['distance']['value'].toString(),
      encodedPoints: response['routes'][0]['overview_polyline']['points'].toString()
    );
    return directionDetails;
  }
}
