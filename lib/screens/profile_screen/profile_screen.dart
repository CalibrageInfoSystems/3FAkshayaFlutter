import 'package:akshaya_flutter/localization/app_locale.dart';
import 'package:akshaya_flutter/localization/locale_keys.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(tr(LocaleKeys.home)),
            Text(tr(LocaleKeys.acceptedBunches)),
            Text(tr(LocaleKeys.visit_reqst)),
          ],
        ),
      ),
    );
  }
}
