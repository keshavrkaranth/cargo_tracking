import 'package:cargo_tracking/Screens/loginpage.dart';
import 'package:cargo_tracking/Screens/mainpage.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:cargo_tracking/main.dart';
import 'package:flutter/foundation.dart' show defaultTargetPlatform, kIsWeb;



Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: const FirebaseOptions(
      apiKey: 'AIzaSyDesMubxml8BIY1XrmziNdS6y6cNGoFBTs',
      appId: '1:514277127247:android:83404ef68d2e034c66663a',
      messagingSenderId: '448618578101',
      projectId: 'react-native-firebase-testing',
      databaseURL: 'https://cargo-tracking-815a8-default-rtdb.firebaseio.com',
      storageBucket: 'cargo-tracking-815a8.appspot.com',
    ),
  );



  runApp(const MyApp());
}



class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        fontFamily: 'Brand-Regular',
        primarySwatch: Colors.blue,
      ),
      home: const LoginPage(),
    );
  }
}

