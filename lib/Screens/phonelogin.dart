import 'dart:async';
import 'dart:math';

import 'package:cargo_tracking/Screens/mainpage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:otp_text_field/otp_field.dart';
import 'package:otp_text_field/otp_field_style.dart';
import 'package:otp_text_field/style.dart';
import '../brand_colors.dart';

class PhoneLogin extends StatefulWidget {
  static const String id = 'phone';
  const PhoneLogin({Key? key}) : super(key: key);

  @override
  _PhoneLoginState createState() => _PhoneLoginState();
}

class _PhoneLoginState extends State<PhoneLogin> {

  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  var phoneController = TextEditingController();
  var otpController = TextEditingController();
  FirebaseAuth auth = FirebaseAuth.instance;
  String verificationIDFinal = "";
  int start = 60;
  late Timer timer;


  bool otpVisibility = false;

  void showSnackBar(String title){
    final snackbar = SnackBar(
      content:Text(title,textAlign: TextAlign.center,style: const TextStyle(fontSize: 15),),
    );
    scaffoldKey.currentState?.showSnackBar(snackbar);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      body: SingleChildScrollView(
        child:Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: <Widget> [
              const SizedBox(height: 70,),
              const Text("Login",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 25,fontFamily: 'Brand-Bold'),),
              Padding(
                  padding:EdgeInsets.all(20.0),
                child: Column(
                  children: <Widget>[
                    TextField(
                      maxLength: 10,
                      controller: phoneController,
                      keyboardType: TextInputType.phone,
                      decoration: const InputDecoration(
                        prefix: Padding(padding: EdgeInsets.all(4),child: Text("+91"),),
                        labelText: "Phone Number",
                        labelStyle: TextStyle(
                          fontSize: 14.0
                        ),
                        hintStyle: TextStyle(
                          color: Colors.grey,
                          fontSize: 10.0,
                        )
                      ),
                    ),
                    Visibility(
                        child: TextField(
                          keyboardType: TextInputType.number,
                          controller: otpController,
                          decoration: const InputDecoration(
                            helperText: 'OTP',
                            prefix: Padding(
                              padding: EdgeInsets.all(4),
                              child: Text(""),
                            ),
                          ),
                          maxLength: 6,

                        ),
                      visible: otpVisibility,

                    ),
                    const SizedBox(height: 20,),
                    Visibility(child: Row(
                      children: <Widget> [
                        GestureDetector(
                            child: const Text("Resend OTP?"),
                            onTap:(){
                              if(start==0){
                                setState(() {
                                  start = 60;
                                  startTimer();
                                  loginWithPhone();
                                });
                              }else{
                                showSnackBar("Wait till 60 sec to request new OTP");
                              }

                            }
                        ),
                        SizedBox(width: 50,),
                        Text("Send OTP again in"),
                        SizedBox(width: 3,),
                        Text("$start sec"),

                      ],
                    ),
                      visible: otpVisibility,
                    ),
                    SizedBox(height: 40,),
                    RaisedButton(onPressed: (){
                      if(phoneController.text.toString()==""){
                        showSnackBar("Phone number required");
                        return;
                      }
                      if(otpVisibility){
                        if (otpController.text.toString()==""){
                          showSnackBar("Enter your OTP");
                          return;
                        }
                          verifyOtp();
                      }else{
                        loginWithPhone();
                        startTimer();
                      }
                    },
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25),
                      ),
                      color:BrandColors.colorGreen ,
                      textColor: Colors.white,
                      child:  SizedBox(
                        height: 50,
                        child: Center(
                          child: Text(
                            otpVisibility ? "Verify" : "Request OTP",
                            style: const TextStyle(
                              fontSize: 18,
                              fontFamily: "Brand-Bold"
                            ),
                          ),
                        ),
                      ),
                    )
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  void startTimer() {
    const onsec = Duration(seconds: 1);
    timer = Timer.periodic(onsec, (timer) {
      if (start == 0) {
        setState(() {
          timer.cancel();
        });
      } else {
        setState(() {
          start--;
        });
      }
    });
  }

  void loginWithPhone() async{
    auth.verifyPhoneNumber(
        phoneNumber: "+91${phoneController.text.trim()}",
        verificationCompleted: (PhoneAuthCredential credential) async{
          await auth.signInWithCredential(credential).then((value){
            Navigator.pop(context);
            timer.cancel();
            Navigator.pushNamedAndRemoveUntil(context, MainPage.id, (route) => false);
          });
        },
        verificationFailed: (FirebaseAuthException ex){
          Navigator.pop(context);
          showSnackBar(ex.message.toString());
        },
        codeSent: (String verificationId,[int? resendToken]){
            otpVisibility = true;
            verificationIDFinal = verificationId;
            setState(() {});
        },
        codeAutoRetrievalTimeout: (String verificationId ){});
  }
  void verifyOtp() async{
    PhoneAuthCredential credential = PhoneAuthProvider.credential(
        verificationId: verificationIDFinal, smsCode: otpController.text.trim());

    await auth.signInWithCredential(credential).then((value){
      Fluttertoast.showToast(
        msg: "You are logged in successfully",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.CENTER,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.red,
        textColor: Colors.white,
        fontSize: 16.0,
      );
      timer.cancel();
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => MainPage()));
    }).catchError((err){
      showSnackBar(err.message.toString());
    });
  }

}
