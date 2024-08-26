// ignore_for_file: use_build_context_synchronously

import 'package:akshaya_flutter/common_utils/common_styles.dart';
import 'package:akshaya_flutter/localization/app_locale.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../authentication/login_screen.dart';
import '../common_utils/constants.dart';
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
                style: CommonStyles
                    .text18orange, // Assuming you have this style defined
              ),
              const SizedBox(height: 20),
              _buildLanguageButton(context, 'English', onPressed: () {
                saveDataAndNavigate(context,
                    language: Constants.englishLanguage,
                    locale: AppLocal.englishLocale);
              }),
              const SizedBox(height: 16),
              _buildLanguageButton(context, 'Telugu', onPressed: () {
                saveDataAndNavigate(context,
                    language: Constants.teluguLanguage,
                    locale: AppLocal.teluguLocale);
              }),
              const SizedBox(height: 16),
              _buildLanguageButton(context, 'Kannada', onPressed: () {
                saveDataAndNavigate(context,
                    language: Constants.kannadaLanguage,
                    locale: AppLocal.kannadaLocale);
              }),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLanguageButton(BuildContext context, String language,
      {required void Function()? onPressed}) {
    return SizedBox(
      width: double.infinity,
      // Makes the button take up the full width of its parent
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20.0), // Rounded corners
          gradient: const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFCCCCCC), // Start color (light gray)
              Color(0xFFFFFFFF), // Center color (white)
              Color(0xFFCCCCCC), // End color (light gray)
            ],
          ),
          border: Border.all(
            color: const Color(0xFFe86100), // Orange border color
            width: 2.0,
          ),
        ),
        child: ElevatedButton(
          onPressed: onPressed,

          /* () async {
            SharedPreferences prefs = await SharedPreferences.getInstance();
            prefs.setBool(Constants.welcome, true);
            context.go(Routes.loginScreen.path);
          }, */
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 0),
            backgroundColor:
                Colors.transparent, // Transparent to show the gradient
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

  Future<void> saveDataAndNavigate(BuildContext context,
      {required String language, required Locale locale}) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool(Constants.welcome, true);
    prefs.setString(SharedPrefsKeys.language, language);
    context.setLocale(locale);
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => LoginScreen(),
      ),
    );
 //   context.go(Routes.loginScreen.path);
  }
}
