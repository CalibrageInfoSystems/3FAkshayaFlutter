import 'package:akshaya_flutter/localization/app_locale.dart';
import 'package:akshaya_flutter/navigation/navigation_config.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import 'app_enterance/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await EasyLocalization.ensureInitialized();
  runApp(
    EasyLocalization(
        supportedLocales: const [
          AppLocal.teluguLocale,
          AppLocal.englishLocale,
          AppLocal.kannadaLocale
        ],
        path: AppLocal.localePath,
        saveLocale: true,
        fallbackLocale: AppLocal.englishLocale,
        startLocale: AppLocal.englishLocale,
        child: const MyApp()),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: SplashScreen(),
    );

    // return MaterialApp.router(
    //   localizationsDelegates: context.localizationDelegates,
    //   supportedLocales: context.supportedLocales,
    //   locale: context.locale,
    //   debugShowCheckedModeBanner: false,
    //   routerDelegate: router.routerDelegate,
    //   routeInformationParser: router.routeInformationParser,
    //   routeInformationProvider: router.routeInformationProvider,
    // );
  }
}
