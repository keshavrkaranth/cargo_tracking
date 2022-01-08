import 'package:cargo_tracking/Screens/loginpage.dart';
import 'package:cargo_tracking/Screens/registrationpage.dart';
import 'package:cargo_tracking/provider/google_sign_in.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class MainPage extends StatefulWidget {
  static const String id = 'main';
  const MainPage({Key? key}) : super(key: key);

  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser!;
    if (user.email == null){
      Navigator.pushNamedAndRemoveUntil(context, LoginPage.id, (route) => false);
    }
    return Scaffold(
      appBar: AppBar(
        title: const Text('Main Page'),
        centerTitle: true,
        actions: [
          TextButton(onPressed: (){
            final provider = Provider.of<GoogleSignInProvider>(context,listen: false);
            provider.logout();
            Navigator.pushNamedAndRemoveUntil(context, RegistrationPage.id, (route) => false);
          }, child: const Text('Logout',style: TextStyle(color: Colors.white,fontSize: 20),))
        ],
      ),
      body:  SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Center(
            child: Column(
              children: <Widget> [
                const SizedBox(height:20.0),
                const SizedBox(height: 30,),
                Text(
                  'Email: ${user.email!}',
                  style: const TextStyle(color: Colors.black,fontSize: 20),
                )
              ],

            ),
          ),
        ),
      ),
    );
  }
}
