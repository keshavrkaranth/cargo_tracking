import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

import '../constants.dart';

class PushNotificationService {

  late FirebaseMessaging messaging;
  String rideId = "";


  Future<String> getToken(context) async {
    messaging = FirebaseMessaging.instance;
    String token;

    messaging.getToken().then((value) {
      token = value.toString();
      print("Token $token");
      DatabaseReference ref = FirebaseDatabase.instance.reference().child(
          'users/${currentFirebaseUser.uid}/token');
      ref.set(token);
      messaging.subscribeToTopic('allDrivers');
      messaging.subscribeToTopic('allUsers');
    });
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {

      print("Message Received");
      rideId = message.data['ride_id'];
      print("Rideid,$rideId");
    });
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print("message_data,${message.data}");
      rideId = message.data['ride_id'];
    });

    return '0';
  }


}
