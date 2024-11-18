// ignore_for_file: deprecated_member_use

import 'dart:io';

import 'package:akshaya_flutter/common_utils/api_config.dart';
import 'package:akshaya_flutter/common_utils/common_styles.dart';
import 'package:akshaya_flutter/localization/app_locale.dart';
import 'package:akshaya_flutter/screens/home_screen/screens/DataProvider.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:open_filex/open_filex.dart';
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

  await initializeLocalNotification();

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

Future<void> initializeLocalNotification() async {
  var initializationSettingsAndroid =
      const AndroidInitializationSettings('@drawable/ic_logo');

  const DarwinInitializationSettings initializationSettingsDarwin =
      DarwinInitializationSettings(
    requestAlertPermission: false,
    requestBadgePermission: false,
    requestSoundPermission: false,
  );
  var initializationSettings = InitializationSettings(
    android: initializationSettingsAndroid,
    iOS: initializationSettingsDarwin,
  );

  await flutterLocalNotificationsPlugin.initialize(
    initializationSettings,
    onDidReceiveNotificationResponse: (details) {
      // Process the payload from the notification
      if (details.payload != null) {
        handleNotification(details.payload!);
      }
    },
    // onDidReceiveBackgroundNotificationResponse: notificationTapBackground,
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
  print('payload: $payload');
  if (payload.isNotEmpty) {
    PermissionStatus status = await Permission.storage.request();

    if (status.isGranted) {
      String folderPath = passbookFileLocation;
      Directory dir = Directory(folderPath);
      if (!(await dir.exists())) {
        await dir.create(recursive: true);
      }
      OpenFilex.open(payload);
    } else if (status.isDenied) {
      print('Error: Storage permission denied.');
    } else if (status.isPermanentlyDenied) {
      print(
          'Error: Storage permission permanently denied. Please enable it from settings.');
      openAppSettings();
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
        colorScheme: const ColorScheme.light(
          primary: CommonStyles.primaryTextColor,
          onPrimary: Colors.white,
          onSurface: CommonStyles.blackColor,
        ),
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
            foregroundColor: CommonStyles.primaryTextColor,
          ),
        ),
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
