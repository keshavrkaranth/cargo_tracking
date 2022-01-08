import 'package:cargo_tracking/Screens/loginpage.dart';
import 'package:cargo_tracking/provider/google_sign_in.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';


import '../brand_colors.dart';

class RegistrationPage extends StatelessWidget {
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  void showSnackBar(String title){
    final snackbar = SnackBar(
      content:Text(title,textAlign: TextAlign.center,style: const TextStyle(fontSize: 15),),
    );
    scaffoldKey.currentState?.showSnackBar(snackbar);
  }


  final FirebaseAuth _auth = FirebaseAuth.instance;
  static const String id = 'register';
  var fullNameController = TextEditingController();
  var phoneController = TextEditingController();
  var emailController = TextEditingController();
  var passwordController = TextEditingController();
  RegistrationPage({Key? key}) : super(key: key);

  void registerUser() async{

    final User? user = (await _auth.createUserWithEmailAndPassword(
      email:emailController.text,
      password:passwordController.text
    )).user;

    if (user!=null){
      print("Reg sucessfull");
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

                const SizedBox(height: 40,),
                const Text('Sign Up as a User',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 25,fontFamily: 'Brand-Bold'),
                ),
                Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    children:  <Widget> [
                      // Full Name
                       TextField(
                        controller: fullNameController,
                        keyboardType: TextInputType.text,
                        decoration: const InputDecoration(
                            labelText: 'Full Name',
                            labelStyle: TextStyle(
                              fontSize: 14.0,
                            ),
                            hintStyle: TextStyle(
                              color: Colors.grey,
                              fontSize: 10.0,
                            )
                        ),
                        style: TextStyle(fontSize: 14),
                      ),
                      const SizedBox(height: 10,),
                      // Email
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
                        style: TextStyle(fontSize: 14),
                      ),
                      const SizedBox(height: 10,),
                      // Phone Number
                       TextField(
                         controller: phoneController,
                        keyboardType: TextInputType.phone,
                        decoration: const InputDecoration(
                            labelText: 'Phone Number',
                            labelStyle: TextStyle(
                              fontSize: 14.0,
                            ),
                            hintStyle: TextStyle(
                              color: Colors.grey,
                              fontSize: 10.0,
                            )
                        ),
                        style: TextStyle(fontSize: 14),
                      ),
                      const SizedBox(height: 10,),
                      //password
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
                        style: TextStyle(fontSize: 14),
                      ),
                      const SizedBox(height: 40,),
                      RaisedButton(
                        onPressed: (){


                          if(fullNameController.text.isEmpty){
                            showSnackBar("Name is Required");
                            return;
                          }
                          if (!emailController.text.contains('@')){
                            showSnackBar("Enter Proper Email");
                            return;
                          }
                          if (phoneController.text.length<10 ||phoneController.text.length>10 ){
                            showSnackBar("Check your Phone number");
                            return;
                          }

                          registerUser();
                        },
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25),
                        ),
                        color: BrandColors.colorOrange,
                        textColor: Colors.white,
                        child: const SizedBox(
                          height: 50,
                          child: Center(
                            child: Text(
                              'REGISTER',
                              style: TextStyle(fontSize: 18,fontFamily: 'Brand-Bold'),
                            ),
                          ),
                        ),

                      ),
                      const SizedBox(height: 40,),
                      RaisedButton(
                        onPressed: (){
                          final provider = Provider.of<GoogleSignInProvider>(context,listen: false);
                          provider.googleLogin();
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
                              'Sign up with Google',
                              style: TextStyle(fontSize: 18,fontFamily: 'Brand-Bold'),
                            ),

                          ),
                        ),

                      ),

                    ],
                  ),
                ),
                FlatButton(onPressed: (){
                  Navigator.pushNamedAndRemoveUntil(context, LoginPage.id, (route) => false);
                },
                  child:const Text('Already have an account? Login'),
                )

              ],
            ),
          ),
        ),
      ),
    );
  }
}
