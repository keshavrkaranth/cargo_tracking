import 'dart:convert';

import 'package:cargo_tracking/Screens/trackingpage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_database/ui/firebase_animated_list.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class OnGoing extends StatefulWidget {
  const OnGoing({Key? key}) : super(key: key);

  @override
  State<OnGoing> createState() => _OnGoingState();
}

class _OnGoingState extends State<OnGoing> {
  bool isLoading = false;
  late String? phone;
  late Query _ref;
  Future<void> test() async{

    _ref =FirebaseDatabase.instance.ref().child('cargos').orderByChild('user_phone').equalTo(phone);
  }
  void asyncMethod() async {
    await test();
  }
  void setPhoneNumber(){
    phone = FirebaseAuth.instance.currentUser?.phoneNumber;
    phone = phone?.substring(3);
  }



  @override
  void initState() {
    super.initState();
    setPhoneNumber();
    asyncMethod();

  }
  Widget _buildCargoList({Object? data, String? key}) {
    final jsonData = json.decode(json.encode(data));
    if (jsonData['status'] == 'ongoing'){
      return Padding(
        padding: const EdgeInsets.all(20.0),
        child: Container(
          color: Colors.white,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: <Widget>[
                  const Text("Tracking ID:"),
                  const SizedBox(
                    width: 5,
                  ),
                  Expanded(
                    child: Text(
                      key!,
                      overflow: TextOverflow.ellipsis,
                      maxLines: 2,
                    ),
                  ),
                ],
              ),
              const SizedBox(
                height: 10,
              ),
              Row(
                children: <Widget>[
                  const Text("status"),
                  const SizedBox(
                    width: 5,
                  ),
                  Expanded(
                    child: Text(
                      jsonData['status'],
                      overflow: TextOverflow.ellipsis,
                      maxLines: 2,
                    ),
                  ),
                ],
              ),
              const SizedBox(
                height: 10,
              ),
              Row(
                children: <Widget>[
                  const Text("Driver Name:"),
                  const SizedBox(
                    width: 5,
                  ),
                  Expanded(
                    child: Text(
                      jsonData['driver'],
                      overflow: TextOverflow.ellipsis,
                      maxLines: 2,
                    ),
                  ),
                ],
              ),
              const SizedBox(
                height: 10,
              ),
              Row(
                children: <Widget>[
                  const Text("Driver Phone:"),
                  const SizedBox(
                    width: 5,
                  ),
                  Expanded(
                    child: Text(
                      jsonData['driver_phone'],
                      overflow: TextOverflow.ellipsis,
                      maxLines: 2,
                    ),
                  ),
                  const SizedBox(width: 20,),
                  GestureDetector(
                    child: const Icon(Icons.phone,),
                    onTap: ()async{
                      final Uri launchUri = Uri(
                        scheme: 'tel',
                        path: jsonData['user_phone'],
                      );
                      await launch(launchUri.toString());
                    },
                  ),


                ],
              ),
              Padding(
                padding: const EdgeInsets.only(top: 10.0),
                child: SizedBox(
                  width: double.infinity,
                  height: 40,
                  child: ElevatedButton(
                    onPressed: () {
                      print("Key before hitting is$key");
                      Navigator.push(context, MaterialPageRoute(builder: (context)=>TrackingPage(trackingId: key)));
                    },
                    child: const Text("Track"),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }
    else{
      return Container();
    }

  }
  @override
  Widget build(BuildContext context) {
    return SafeArea(child: Scaffold(
      appBar: AppBar(
        title: const Text("On going"),
      ),
      body: SizedBox(
        height: double.infinity,
        child: FirebaseAnimatedList(
          query: _ref,
          itemBuilder: (BuildContext context, DataSnapshot snapshot,
              Animation<double> animation, int index) {
            Object? data = snapshot.value;

            return _buildCargoList(data: data, key: snapshot.key);
          },
        ),
      ),
    ),);
  }
}
