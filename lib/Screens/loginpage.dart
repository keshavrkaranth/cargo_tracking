import 'package:cargo_tracking/Screens/mainpage.dart';
import 'package:cargo_tracking/Screens/registrationpage.dart';
import 'package:cargo_tracking/brand_colors.dart';
import 'package:cargo_tracking/widgets/ProgressDialog.dart';
import 'package:connectivity/connectivity.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';


class LoginPage extends StatefulWidget {
  static const String id = 'login';
  const LoginPage({Key? key}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  var emailController = TextEditingController();
  var passwordController = TextEditingController();
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  void showSnackBar(String title){
    final snackbar = SnackBar(
      content:Text(title,textAlign: TextAlign.center,style: const TextStyle(fontSize: 15),),
    );
    scaffoldKey.currentState?.showSnackBar(snackbar);
  }


  void login() async{

    // show dialog
    showDialog(context: context,
        builder: (BuildContext context)=> const ProgressDialog(status: 'Logging you in'));
    try{
      await _auth.signInWithEmailAndPassword(
          email: emailController.text, password: passwordController.text);
      Navigator.pop(context);
      Navigator.pushNamedAndRemoveUntil(context, MainPage.id, (route) => false);
    }on FirebaseAuthException catch(e){
      Navigator.pop(context);
     showSnackBar(e.message.toString());
    }
}
  @override
  Widget build(BuildContext context) {

    return Scaffold(
      key: scaffoldKey,
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children:  <Widget>[
                const SizedBox(height: 70),
                const Image(
                  alignment: Alignment.center,
                  height: 100.0,
                  width: 100.0,
                  image: AssetImage('images/logo.png'),
                ),
                const SizedBox(height: 40,),
                const Text('Sign In as a User',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 25,fontFamily: 'Brand-Bold'),
                ),
                Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    children:  <Widget> [
                       TextField(
                         controller: emailController,
                        keyboardType: TextInputType.emailAddress,
                        decoration: const InputDecoration(
                            labelText: 'Email Address',
                            labelStyle: TextStyle(
                              fontSize: 14.0,
                            ),
                            hintStyle: TextStyle(
                              color: Colors.grey,
                              fontSize: 10.0,
                            )
                        ),
                        style: const TextStyle(fontSize: 14),
                      ),
                      const SizedBox(height: 10,),
                       TextField(
                        controller: passwordController,
                        obscureText: true,
                        decoration: const InputDecoration(
                            labelText: 'Password',
                            labelStyle: TextStyle(
                              fontSize: 14.0,
                            ),
                            hintStyle: TextStyle(
                              color: Colors.grey,
                              fontSize: 10.0,
                            )
                        ),
                        style: const TextStyle(fontSize: 14),
                      ),
                      const SizedBox(height: 40,),
                        RaisedButton(
                          onPressed: () async{
                            // check for internet connectivity
                            var connectivityRes = await Connectivity().checkConnectivity();
                            if(connectivityRes!=ConnectivityResult.mobile && connectivityRes !=ConnectivityResult.wifi){
                              showSnackBar('No Internet Connection');
                              return;
                            }


                            if (!emailController.text.contains('@')){
                              showSnackBar("Enter Proper Email");
                              return;
                            }


                            // password validation
                            if(passwordController.text.length<6){
                              showSnackBar('Password Should be minimum 6 characters long!');
                              return;
                            }
                            login();

                          },
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25),
                        ),
                        color: BrandColors.colorGreen,
                        textColor: Colors.white,
                        child: const SizedBox(
                          height: 50,
                          child: Center(
                            child: Text(
                              'LOGIN',
                              style: TextStyle(fontSize: 18,fontFamily: 'Brand-Bold'),
                            ),
                          ),
                        ),

                      )
                    ],
                  ),
                ),
                FlatButton(onPressed: (){
                  Navigator.pushNamedAndRemoveUntil(context, RegistrationPage.id, (route) => false);
                },
                    child:const Text('Don\'t have an account,Sign up here'),
                )

              ],
            ),
          ),
        ),
      ),
    );
  }
}
