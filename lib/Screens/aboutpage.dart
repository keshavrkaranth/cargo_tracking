import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("About Page"),
      ),
      body: const Center(
        child: Text("This app Developed For Major Project\n From TEAM P14",textAlign: TextAlign.center,style: TextStyle(fontSize: 18,),),
      ),
    );
  }
}
