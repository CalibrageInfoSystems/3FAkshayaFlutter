import 'dart:convert';
import 'package:akshaya_flutter/Common/common_styles.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'HomeScreen.dart';


class LoginScreen extends StatefulWidget {
  @override
  _loginScreenState createState() => _loginScreenState();
}

class _loginScreenState extends State<LoginScreen> {
  TextEditingController _farmercodeController = TextEditingController();
  String farmercode = "";
  bool isLoading = true;
  String? farmerMobileNumber;


  @override
  void dispose() {
    _farmercodeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Container(
          height: MediaQuery.of(context).size.height,
          child: Stack(
            children: [
              Image.asset(
                'assets/appbg.png',
                width: double.infinity,
                height: double.infinity,
                fit: BoxFit.cover,
              ),
              Container(
                color: Color(0x8D000000),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 180.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [

                    Align(
                      alignment: Alignment.topCenter,
                      child: Image.asset(
                        'assets/ic_user.png',
                        width: 200,
                        height: 150,
                      ),
                    ),
                    Text(
                        'Welcome',
                        style:CommonStyles.txSty_24w
                    ),
                    Padding(
                      padding:  EdgeInsets.only(
                          top: 22.0, left: 22.0, right: 22.0),
                      child: TextFormField(
                          controller: _farmercodeController,
                          decoration: InputDecoration(
                            hintText: 'Enter Farmer Id',
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                color: Colors.white, // Set the border line color to white
                              ),
                              borderRadius: BorderRadius.circular(
                                  10.0), // Set the border radius
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                color: Colors.white, // Set the border line color to white
                              ),
                              borderRadius: BorderRadius.circular(
                                  10.0),
                            ),
                            hintStyle: CommonStyles.txSty_20hint_fb,
                            contentPadding: EdgeInsets.symmetric(
                                vertical: 15, horizontal: 15),
                            // Add padding to center the hint text
                            alignLabelWithHint: true, // Center-align the hint text
                          ),
                          textAlign: TextAlign.center,
                          style: CommonStyles.txSty_20wh_fb
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(
                          top: 22.0,
                          left: 22.0,
                          right: 22.0),
                      child:
                      SizedBox(
                        width: double.infinity,
                        // Makes the button take up the full width of its parent
                        child:
                        Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20.0), // Rounded corners
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Color(0xFFCCCCCC),  // Start color (light gray)
                                Color(0xFFFFFFFF),  // Center color (white)
                                Color(0xFFCCCCCC),  // End color (light gray)
                              ],
                            ),
                            border: Border.all(
                              color: Color(0xFFe86100), // Orange border color
                              width: 2.0,
                            ),
                          ),
                          child:
                          ElevatedButton(
                            onPressed: () {
                              Navigator.of(context).pushReplacement(
                                MaterialPageRoute(builder: (context) => HomeScreen()),
                              );
                              // Handle language selection here
                            },
                            style: ElevatedButton.styleFrom(
                              padding: EdgeInsets.symmetric(vertical: 0),
                              backgroundColor: Colors.transparent, // Transparent to show the gradient
                              shadowColor: Colors.transparent, // Remove button shadow
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20.0),
                              ),
                            ),
                            child: Text(
                              'Login',
                              style: CommonStyles.text18orange,
                            ),
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 6.0),
                      child: Container(
                        alignment: AlignmentDirectional.center,
                        child: Text(
                          'OR',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),

                    Padding(
                      padding: const EdgeInsets.only(
                          top: 10.0, left: 22.0, right: 22.0),
                      child:
                      SizedBox(
                        width: double.infinity,
                        // Makes the button take up the full width of its parent
                        child:
                        Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20.0), // Rounded corners
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Color(0xFFCCCCCC),  // Start color (light gray)
                                Color(0xFFFFFFFF),  // Center color (white)
                                Color(0xFFCCCCCC),  // End color (light gray)
                              ],
                            ),
                            border: Border.all(
                              color: Color(0xFFe86100), // Orange border color
                              width: 2.0,
                            ),
                          ),
                          child:
                          ElevatedButton(
                            onPressed: () {
                              Navigator.of(context).pushReplacement(
                                MaterialPageRoute(builder: (context) => LoginScreen()),
                              );
                              // Handle language selection here
                            },
                            style: ElevatedButton.styleFrom(
                              padding: EdgeInsets.symmetric(vertical: 0),
                              backgroundColor: Colors.transparent, // Transparent to show the gradient
                              shadowColor: Colors.transparent, // Remove button shadow
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20.0),
                              ),
                            ),
                            child: Text(
                              'Scan QR',
                              style: CommonStyles.text18orange,
                            ),
                          ),
                        ),
                      ),

                    ),
                    // Other Buttons
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }


}
