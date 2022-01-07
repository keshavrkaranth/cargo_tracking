import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

class MainPage extends StatefulWidget {
  const MainPage({Key? key}) : super(key: key);

  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Main Page'),
      ),
      body: Center(
        child: MaterialButton(
          height: 50,
          minWidth: 300,
          color: Colors.green,
          child: const Text("Test Connection"),
          onPressed:(){
            DatabaseReference db = FirebaseDatabase.instance.reference().child('Test');
                db.set('IsConnected');
          },
        ),
      )
    );
  }
}
