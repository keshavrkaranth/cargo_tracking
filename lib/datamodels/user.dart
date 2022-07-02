import 'package:firebase_database/firebase_database.dart';

class User{
  late String?fullName;
  late String? email;
  late String? phone;
  late String? id;
  User({
    this.email,
     this.fullName,
     this.id,
      this.phone
});
  User.fromSnapshot(DataSnapshot snapshot){
    String fireBaseValue = snapshot.value.toString();
    var newValue = fireBaseValue.replaceAll("{", "").replaceAll("}", "");
    var dataSp = newValue.split(',');
    Map<String,String> mapData = {};
    for (var element in dataSp) {
      mapData[element.split(':')[0].trim()] = element.split(':')[1].trim();
    }
      id = snapshot.key!;
      phone = mapData['phone']!;
      email=mapData['email']!;
      fullName = mapData['fullname']!;


  }

}