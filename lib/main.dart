// ignore_for_file: deprecated_member_use

import 'dart:io';

import 'package:akshaya_flutter/common_utils/common_styles.dart';
import 'package:akshaya_flutter/localization/app_locale.dart';
import 'package:akshaya_flutter/screens/home_screen/screens/DataProvider.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';

import 'app_enterance/splash_screen.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

@pragma('vm:entry-point')
void notificationTapBackground(NotificationResponse notificationResponse) {
  print('notification(${notificationResponse.id}) action tapped: '
      '${notificationResponse.actionId} with'
      ' payload: ${notificationResponse.payload}');
  if (notificationResponse.input?.isNotEmpty ?? false) {
    print(
        'notification action tapped with input: ${notificationResponse.input}');
  }
}

FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await EasyLocalization.ensureInitialized();

  var initializationSettingsAndroid = const AndroidInitializationSettings(
      '@drawable/ic_logo'); // @mipmap/ic_launcher
  var initializationSettings =
      InitializationSettings(android: initializationSettingsAndroid);

  await flutterLocalNotificationsPlugin.initialize(
    initializationSettings,
    onDidReceiveNotificationResponse: (details) {
      // Process the payload from the notification
      if (details.payload != null) {
        handleNotification(details.payload!);
      }
    },
  );

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
    ),
  );
}

/* void handleNotification(String payload) {
  if (payload.isNotEmpty && Directory(payload).existsSync()) {
    print('Opening directory: $payload');
  } else {
    print('Error: Directory does not exist or path is empty');
  }
} */
Future<void> handleNotification(String payload) async {
  // Check if the directory path is provided
  if (payload.isNotEmpty) {
    // Request storage permission before accessing the directory
    PermissionStatus status = await Permission.storage.request();

    // Check if permission is granted
    if (status.isGranted) {
      // Verify if the directory exists
      if (Directory(payload).existsSync()) {
        print('Opening directory: $payload');
        // Add your code to open or use the directory here
      } else {
        print('Error: Directory does not exist.');
      }
    } else if (status.isDenied) {
      print('Error: Storage permission denied.');
      // Optionally, you can ask the user again or show a message
    } else if (status.isPermanentlyDenied) {
      print(
          'Error: Storage permission permanently denied. Please enable it from settings.');
      // You can prompt the user to open the app settings to manually grant permission.
      openAppSettings(); // This opens the app settings page
    }
  } else {
    print('Error: Payload (directory path) is empty.');
  }
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
