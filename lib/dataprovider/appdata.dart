import 'package:cargo_tracking/datamodels/address.dart';
import 'package:flutter/cupertino.dart';

class AppData extends ChangeNotifier{

  late Address pickupAddress;
  void updatePickupAddress(Address pickup){
    pickupAddress  = pickup;
    notifyListeners();
  }
}