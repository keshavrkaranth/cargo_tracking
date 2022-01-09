import 'package:flutter/material.dart';

class MainPage extends StatelessWidget {
  static const String id = 'main';
  const MainPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cargo Tracking'),
      ),
      body: const Center(
        child: Text("welcome to Cargo Tracking"),
      ),
    );
  }
}
