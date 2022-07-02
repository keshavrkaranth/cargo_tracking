import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'dart:convert';
import '../datamodels/user.dart';

class ViewProfile extends StatefulWidget {
  const ViewProfile({Key? key}) : super(key: key);

  @override
  State<ViewProfile> createState() => _ViewProfileState();
}

class _ViewProfileState extends State<ViewProfile> {
  TextEditingController nameController = TextEditingController();
  TextEditingController? phoneController = TextEditingController();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    String? phone = FirebaseAuth.instance.currentUser?.phoneNumber;
    String uid = FirebaseAuth.instance.currentUser!.uid;
    DatabaseReference ref = FirebaseDatabase.instance.ref("users").child(uid);
    ref.once().then((value){
      final myData = json.decode(json.encode(value.snapshot.value));
      setState(() {
        nameController.text = myData['fullname'];
        phoneController?.text = phone!.substring(3);
      });
    });

  }
  Future<void> updateProfileToDB() async {
    DatabaseReference ref = FirebaseDatabase.instance.ref('users').child(FirebaseAuth.instance.currentUser!.uid);
    Map data  = {
      "fullname":nameController.text.toString(),
      "phone":phoneController!.text.toString(),
      "role":"USER",
    };
    ref.set(data);
    Fluttertoast.showToast(msg: "Updated");
  }
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(
          title: Text("Profile"),
          centerTitle: true,
        ),
        body: SingleChildScrollView(
          child: Column(
            children: <Widget>[
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(20.0),
                  child: CircleAvatar(
                    radius: 50.0,
                    backgroundImage: AssetImage('images/user_icon.png'),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(
                    left: 25, right: 25, bottom: 0, top: 25),
                child: TextField(
                  controller: nameController,
                  enabled: true,
                  keyboardType: TextInputType.text,
                  decoration: const InputDecoration(
                      border: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.teal),
                          borderRadius: BorderRadius.all(Radius.circular(25))),
                      labelText: 'Name',
                      labelStyle: TextStyle(
                        fontSize: 14.0,
                      ),
                      hintStyle: TextStyle(
                        color: Colors.grey,
                        fontSize: 10.0,
                      )),
                  style: const TextStyle(fontSize: 14),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(
                    left: 25, right: 25, bottom: 0, top: 25),
                child: TextField(
                  controller: phoneController,
                  enabled: false,
                  keyboardType: TextInputType.text,
                  decoration: const InputDecoration(
                      border: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.teal),
                          borderRadius: BorderRadius.all(Radius.circular(25))),
                      labelText: 'Phone number',
                      labelStyle: TextStyle(
                        fontSize: 14.0,
                      ),
                      hintStyle: TextStyle(
                        color: Colors.grey,
                        fontSize: 10.0,
                      )),
                  style: const TextStyle(fontSize: 14),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(
                    left: 25, right: 25, bottom: 0, top: 25),
                child: Center(
                  child: ElevatedButton(
                    onPressed: updateProfileToDB,
                    child: Text("Update"),

                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
