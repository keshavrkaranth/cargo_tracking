import 'package:cargo_tracking/Screens/loginpage.dart';
import 'package:cargo_tracking/Screens/mainpage.dart';
import 'package:cargo_tracking/Screens/phonelogin.dart';
import 'package:cargo_tracking/Screens/registrationpage.dart';
import 'package:cargo_tracking/Screens/startingpage.dart';
import 'package:cargo_tracking/constants.dart';
import 'package:cargo_tracking/dataprovider/appdata.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:cargo_tracking/main.dart';
import 'package:flutter/foundation.dart' show defaultTargetPlatform, kIsWeb;
import 'package:provider/provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: const FirebaseOptions(
      apiKey: 'AIzaSyDesMubxml8BIY1XrmziNdS6y6cNGoFBTs',
      appId: '1:514277127247:android:83404ef68d2e034c66663a',
      messagingSenderId: '448618578101',
      projectId: 'cargo-tracking-815a8',
      databaseURL: 'https://cargo-tracking-815a8-default-rtdb.firebaseio.com',
      storageBucket: 'cargo-tracking-815a8.appspot.com',
    ),
  );
  currentFirebaseUser = FirebaseAuth.instance.currentUser!;


  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
        return ChangeNotifierProvider(
          create: (context) => AppData(),
          child: MaterialApp(
            debugShowCheckedModeBanner: false,
            title: 'Flutter Demo',
            theme: ThemeData(
              fontFamily: 'Brand-Regular',
              primarySwatch: Colors.blue,
            ),
            initialRoute:  (currentUser == null) ? PhoneLogin.id : MainPage.id,
            routes: {
              RegistrationPage.id: (context) =>  RegistrationPage(),
              LoginPage.id: (context) => const LoginPage(),
              MainPage.id: (context) =>  MainPage(),
              InitialPage.id: (context) => const InitialPage(),
              PhoneLogin.id :(context) => const PhoneLogin(),
            },
          ),
        );
}
}
//