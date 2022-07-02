import 'dart:convert';

import 'package:cargo_tracking/Screens/aboutpage.dart';
import 'package:cargo_tracking/Screens/ongoinglist.dart';
import 'package:cargo_tracking/Screens/phonelogin.dart';
import 'package:cargo_tracking/Screens/viewprofile.dart';
import 'package:cargo_tracking/datamodels/user.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_database/ui/firebase_animated_list.dart';
import 'package:flutter/material.dart';

import '../constants.dart';
import '../styles/styles.dart';
import '../widgets/BrandDivider.dart';
import '../widgets/ProgressDialog.dart';

class CargoList extends StatefulWidget {
  static const String id = 'list';
  const CargoList({Key? key}) : super(key: key);

  @override
  State<CargoList> createState() => _CargoListState();
}

class _CargoListState extends State<CargoList> {
  @override
  bool isLoading = false;
  late String? phone;
  late Query _ref;
  String? name;
  Future<void> test() async {
    _ref = FirebaseDatabase.instance
        .ref()
        .child('cargos')
        .orderByChild('user_phone')
        .equalTo(phone);
  }

  void asyncMethod() async {
    await test();
  }

  void setPhoneNumber() {
    phone = FirebaseAuth.instance.currentUser?.phoneNumber;
    phone = phone?.substring(3);
  }

  @override
  void initState() {
    super.initState();
    setPhoneNumber();
    asyncMethod();
    currentFirebaseUser = FirebaseAuth.instance.currentUser!;
    DatabaseReference ref =
        FirebaseDatabase.instance.ref('users').child(currentFirebaseUser.uid);

    ref.once().then((value) {
      final myData = json.decode(json.encode(value.snapshot.value));
      name = myData['fullname'];
    });
  }

  void showDilogue(jsonData) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Expanded(
          child: AlertDialog(
            title: const Text('Details of Package'),
            content: Column(
              children: <Widget>[
                Row(
                  children: <Widget>[
                    const Text("Driver Name:"),
                    const SizedBox(
                      width: 10,
                    ),
                    Text(jsonData['driver'].toString().toUpperCase())
                  ],
                ),
                const SizedBox(
                  height: 10,
                ),
                Row(
                  children: <Widget>[
                    const Text("Company:"),
                    const SizedBox(
                      width: 10,
                    ),
                    Text(jsonData['company'].toString())
                  ],
                ),
                const SizedBox(
                  height: 10,
                ),
                Row(
                  children: <Widget>[
                    const Text("From Address:"),
                    const SizedBox(
                      width: 10,
                    ),
                    Expanded(
                      child: Text(
                        jsonData['from_address'],
                        overflow: TextOverflow.ellipsis,
                        maxLines: 3,
                      ),
                    ),
                  ],
                ),
                const SizedBox(
                  height: 10,
                ),
                Row(
                  children: <Widget>[
                    const Text("To Address:"),
                    const SizedBox(
                      width: 10,
                    ),
                    Expanded(
                      child: Text(
                        jsonData['to_address'],
                        overflow: TextOverflow.ellipsis,
                        maxLines: 4,
                      ),
                    ),
                  ],
                ),
                const SizedBox(
                  height: 10,
                ),
                Row(
                  children: <Widget>[
                    const Text("Total distance:"),
                    const SizedBox(
                      width: 10,
                    ),
                    Expanded(
                      child: Text(
                        jsonData['total_distance'],
                        overflow: TextOverflow.ellipsis,
                        maxLines: 3,
                      ),
                    ),
                  ],
                ),
                const SizedBox(
                  height: 10,
                ),
                Row(
                  children: <Widget>[
                    const Text("Total time:"),
                    const SizedBox(
                      width: 10,
                    ),
                    Expanded(
                      child: Text(
                        jsonData['total_time'],
                        overflow: TextOverflow.ellipsis,
                        maxLines: 3,
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
                      width: 10,
                    ),
                    Expanded(
                      child: Text(
                        jsonData.containsKey("driver_phone")
                            ? jsonData['driver_phone']
                            : "No number",
                        overflow: TextOverflow.ellipsis,
                        maxLines: 3,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            actions: [
              FlatButton(
                textColor: Colors.black,
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text('Return'),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildCargoList({Object? data, String? key}) {
    final jsonData = json.decode(json.encode(data));
    if (jsonData['status'] != 'ongoing') {
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
                  Padding(
                    padding: const EdgeInsets.only(top: 10.0),
                    child: SizedBox(
                      width: 80,
                      height: 20,
                      child: ElevatedButton(
                        onPressed: () => showDilogue(jsonData),
                        child: const Text("Details"),
                      ),
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
            ],
          ),
        ),
      );
    } else {
      return Container();
    }
  }

  Widget build(BuildContext context) {
    return isLoading
        ? const ProgressDialog(status: "Loading")
        : SafeArea(
            child: Scaffold(
              appBar: AppBar(
                title: const Text("History"),
              ),
              drawer: Container(
                width: 250,
                color: Colors.white,
                // navigation drawer
                child: Drawer(
                  child: ListView(
                    padding: const EdgeInsets.all(0),
                    children: <Widget>[
                      Container(
                        color: Colors.white,
                        height: 160,
                        child: DrawerHeader(
                          decoration: const BoxDecoration(
                            color: Colors.white,
                          ),
                          child: Row(
                            children: <Widget>[
                              Image.asset(
                                'images/user_icon.png',
                                height: 60,
                                width: 60,
                              ),
                              const SizedBox(
                                width: 15,
                              ),
                              Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: <Widget>[
                                  Text(
                                    "USER",
                                    style: const TextStyle(
                                        fontSize: 20, fontFamily: 'Brand-Bold'),
                                  ),
                                  const SizedBox(
                                    height: 5,
                                  ),
                                  GestureDetector(
                                    child: const Text('View Profile'),
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => ViewProfile(),
                                        ),
                                      );
                                    },
                                  )
                                ],
                              )
                            ],
                          ),
                        ),
                      ),
                      const BrandDivider(),
                      const SizedBox(
                        height: 10,
                      ),
                      ListTile(
                        leading: const Icon(Icons.navigation),
                        title: const Text(
                          'On going',
                          style: kDrawerItemStyle,
                        ),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const OnGoing(),
                            ),
                          );
                        },
                      ),
                      ListTile(
                        leading: const Icon(Icons.info),
                        title: const Text(
                          'About',
                          style: kDrawerItemStyle,
                        ),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const AboutPage(),
                            ),
                          );
                        },
                      ),
                      ListTile(
                        onTap: () async {
                          await FirebaseAuth.instance.signOut();
                          Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => const PhoneLogin()));
                        },
                        leading: const Icon(Icons.logout),
                        title: const Text(
                          'Logout',
                          style: kDrawerItemStyle,
                        ),
                      ),
                    ],
                  ),
                ),
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
            ),
          );
  }
}
