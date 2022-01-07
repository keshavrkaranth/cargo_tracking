import 'package:cargo_tracking/brand_colors.dart';
import 'package:flutter/material.dart';


class LoginPage extends StatelessWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                      const TextField(
                        keyboardType: TextInputType.emailAddress,
                        decoration: InputDecoration(
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
                      const TextField(
                        obscureText: true,
                        decoration: InputDecoration(
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
                      SizedBox(height: 40,),
                        RaisedButton(
                          onPressed: (){},
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
                FlatButton(onPressed: (){},
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
