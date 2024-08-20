import 'package:akshaya_flutter/Common/common_styles.dart';
import 'package:akshaya_flutter/login_screen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:flutter/material.dart';

import 'package:flutter/material.dart';

class LanguageScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(
                'Please Select Language Below:',
                style: CommonStyles.text18orange, // Assuming you have this style defined
              ),
              SizedBox(height: 20),
              _buildLanguageButton(context, 'English'),
              SizedBox(height: 16),
              _buildLanguageButton(context, 'Telugu'),
              SizedBox(height: 16),
              _buildLanguageButton(context, 'Kannada'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLanguageButton(BuildContext context, String language)  {
    return

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
            language,
            style: CommonStyles.text18orange,
          ),
        ),
      ),
    );
  }
}




