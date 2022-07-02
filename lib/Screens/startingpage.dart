import 'package:cargo_tracking/Screens/registrationpage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'mainpage.dart';

class InitialPage extends StatelessWidget {
  static const String id = 'starting';
  const InitialPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context,snapshot){
          if (snapshot.connectionState == ConnectionState.waiting){
            return const Center(child: CircularProgressIndicator(),);
          }
          else if(snapshot.hasData){
            return  MainPage();
          }
          else if(snapshot.hasError){
            return const Center(child: Text('Something went wrong!'));
          }
          else{
            return  RegistrationPage();
          }

      }
      ),
    );
  }
  }

