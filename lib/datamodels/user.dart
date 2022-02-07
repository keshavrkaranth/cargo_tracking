import 'package:firebase_database/firebase_database.dart';

class User{
  late String fullName;
  late String email;
  late String phone;
  late String id;
  User({
    required this.email,
    required this.fullName,
    required this.id,
    required this.phone
});
  User.fromSnapshot(DataSnapshot snapshot){
    if(snapshot.value !=null) {
      id = snapshot.key!;
      print("test1");
      print(snapshot.value);
      phone = 'qwerty';
      email='keshavarkarantha@gmail.com';
      fullName = 'keshavrkaranth';

    }
  }

}