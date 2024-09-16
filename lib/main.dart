import 'package:akshaya_flutter/common_utils/common_styles.dart';
import 'package:akshaya_flutter/localization/app_locale.dart';
import 'package:akshaya_flutter/screens/home_screen/screens/DataProvider.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

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
      child: ChangeNotifierProvider(
        create: (context) => DataProvider(),
        child: const MyApp(),
      ),

      //   MyApp()
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        textSelectionTheme: TextSelectionThemeData(
          cursorColor: CommonStyles.primaryTextColor,
          selectionColor: Colors.blue.withOpacity(0.3),
          selectionHandleColor: CommonStyles.primaryTextColor,
        ),
        /*  checkboxTheme: CheckboxThemeData(
          fillColor: WidgetStateProperty.all(CommonStyles.primaryTextColor),
        ), */
        progressIndicatorTheme: const ProgressIndicatorThemeData(
          color: CommonStyles.primaryTextColor,
        ),
      ),
      builder: (context, child) {
        final originalTextScaleFactor = MediaQuery.of(context).textScaleFactor;
        final boldText = MediaQuery.boldTextOf(context);

        final newMediaQueryData = MediaQuery.of(context).copyWith(
          boldText: boldText,
          textScaler:
              TextScaler.linear(originalTextScaleFactor.clamp(0.8, 1.0)),
        );

        return MediaQuery(
          data: newMediaQueryData,
          child: child!,
        );
      },
      localizationsDelegates: context.localizationDelegates,
      supportedLocales: context.supportedLocales,
      locale: context.locale,
      debugShowCheckedModeBanner: false,
      home: const SplashScreen(),
    );
  }
}
