import 'package:akshaya_flutter/localization/locale_keys.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class Constants {
  static const String profileUrl =
      "https://avatars2.githubusercontent.com/u/7047347?s=460&v=4";
  static const String isLogin = "login_verification";
  static const String userId = "userID";
  static const String welcome = "welcome";

  static const String defaultLanguage = "english";
  static const String englishLanguage = "english";
  static const String teluguLanguage = "telugu";
  static const String kannadaLanguage = "kannada";

/*   static Future<void> launchInBrowser(Uri url) async {
    if (!await launchUrl(
      url,
      mode: LaunchMode.externalApplication,
    )) {
      throw Exception('Could not launch $url');
    }
  } */

  static Future<void> launchMap(BuildContext context,
      {required double? latitude, required double? longitude}) async {
    final Uri mapUrl = Uri.parse(
        'https://www.google.com/maps/search/?api=1&query=$latitude,$longitude');

    if (latitude != null || longitude != null) {
      if (!await launchUrl(
        mapUrl,
        mode: LaunchMode.externalApplication,
      )) {
        throw Exception('Could not launch $mapUrl');
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No latitude or longitude found'),
        ),
      );
      print('Location not found'); // tr(LocaleKeys.App_version)
    }
  }
}
