import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cargo_tracking/datamodels/user.dart' as user;

String mapKey = 'AIzaSyDesMubxml8BIY1XrmziNdS6y6cNGoFBTs';

User currentFirebaseUser = FirebaseAuth.instance.currentUser!;

user.User currentUser = user.User();