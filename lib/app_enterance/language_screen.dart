import 'package:akshaya_flutter/common_utils/common_styles.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../common_utils/Constants.dart';
import '../navigation/app_routes.dart';


class LanguageScreen extends StatelessWidget {

  const LanguageScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              const Text(
                'Please Select Language Below:',
                style: CommonStyles.text18orange, // Assuming you have this style defined
              ),
              const SizedBox(height: 20),
              _buildLanguageButton(context, 'English'),
              const SizedBox(height: 16),
              _buildLanguageButton(context, 'Telugu'),
              const SizedBox(height: 16),
              _buildLanguageButton(context, 'Kannada'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLanguageButton(BuildContext context, String language)  {
    return SizedBox(
      width: double.infinity,
      // Makes the button take up the full width of its parent
      child:
      Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20.0), // Rounded corners
          gradient: const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFCCCCCC),  // Start color (light gray)
              Color(0xFFFFFFFF),  // Center color (white)
              Color(0xFFCCCCCC),  // End color (light gray)
            ],
          ),
          border: Border.all(
            color: const Color(0xFFe86100), // Orange border color
            width: 2.0,
          ),
        ),
        child:
        ElevatedButton(
          onPressed: () async {
            // Navigator.of(context).pushReplacement(
            //   MaterialPageRoute(builder: (context) => const LoginScreen()),
            // );
            SharedPreferences prefs = await SharedPreferences.getInstance();
            prefs.setBool(Constants.welcome, true);
      context.go(Routes.loginScreen.path);
            // Handle language selection here
          },
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 0),
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




