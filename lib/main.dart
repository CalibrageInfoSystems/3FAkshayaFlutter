import 'package:akshaya_flutter/common_utils/common_styles.dart';
import 'package:akshaya_flutter/localization/app_locale.dart';
import 'package:akshaya_flutter/screens/home_screen/screens/DataProvider.dart';
import 'package:akshaya_flutter/screens/home_screen/screens/ffb_collection_screen.dart';
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
      // home: const FfbCollectionScreen(),
    );
  }
}

class CustomScreenLayout extends StatelessWidget {
  const CustomScreenLayout({super.key});

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final appBarHeight = AppBar().preferredSize.height; // Default AppBar height
    const bottomNavBarHeight =
        kBottomNavigationBarHeight; // Default BottomNavigationBar height
    final remainingHeight = screenHeight - appBarHeight - bottomNavBarHeight;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Custom Layout'),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(
              icon: Icon(Icons.business), label: 'Business'),
          BottomNavigationBarItem(icon: Icon(Icons.school), label: 'School'),
        ],
      ),
      body: Column(
        children: [
          // Header section - 20% of remaining height
          Container(
            height: remainingHeight * 0.2,
            color: Colors.blue,
            child: const Center(
              child: Text('Header', style: TextStyle(color: Colors.white)),
            ),
          ),

          // Services section - 30% of remaining height
          Container(
            height: remainingHeight * 0.3,
            color: Colors.green,
            child: const Center(
              child: Text('Services', style: TextStyle(color: Colors.white)),
            ),
          ),

          // Learnings section - 20% of remaining height
          Container(
            height: remainingHeight * 0.2,
            color: Colors.red,
            child: const Center(
              child: Text('Learnings', style: TextStyle(color: Colors.white)),
            ),
          ),

          // Marquee section - 4% of remaining height
          Container(
            height: remainingHeight * 0.04,
            color: Colors.orange,
            child: const Center(
              child: Text('Marquee', style: TextStyle(color: Colors.white)),
            ),
          ),

          // Carousel section - 20% of remaining height
          Expanded(
            child: Container(
              // height: remainingHeight * 0.2,
              color: Colors.purple,
              child: const Center(
                child: Text('Carousel', style: TextStyle(color: Colors.white)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class RequestServicesScreen extends StatelessWidget {
  const RequestServicesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: Center(
        child: Column(
          children: [
            Container(
              height: size.height * 0.2,
              color: Colors.orange,
            ),
            services(size.height * 0.3, size.width),
            services(size.height * 0.2, size.width, color: Colors.grey),
            Container(
              height: size.height * 0.3,
              color: Colors.tealAccent,
            ),
          ],
        ),
      ),
    );
  }

  Container services(double containerHeight, double screenWidth,
      {Color? color}) {
    return Container(
      color: color,
      height: containerHeight,
      width: screenWidth,
      child: Stack(
        children: [
          // Scrollable services
          SingleChildScrollView(
            child: Column(
              children: [
                // Ensure each row has a fixed height of 90
                buildRow(screenWidth, 140, [
                  ServiceItem(icon: Icons.local_florist, label: 'Fertilizer'),
                  ServiceItem(icon: Icons.build, label: 'Equipment'),
                  ServiceItem(icon: Icons.science, label: 'Bio Lab'),
                ]),
                const Divider(thickness: 1.0, color: Colors.black12),
                buildRow(screenWidth, 140, [
                  ServiceItem(icon: Icons.person, label: 'Labour'),
                  ServiceItem(icon: Icons.monetization_on, label: 'QuickPay'),
                  ServiceItem(icon: Icons.location_on, label: 'Visit'),
                ]),
                const Divider(thickness: 1.0, color: Colors.black12),
                buildRow(screenWidth, 140, [
                  ServiceItem(icon: Icons.credit_card, label: 'Loan'),
                  ServiceItem(icon: Icons.local_drink, label: 'Edible Oil'),
                  ServiceItem(icon: Icons.local_drink, label: 'Edible Oil'),
                ]),
                // Add more services here if needed
              ],
            ),
          ),
          // Positioned widgets for vertical lines
          Positioned(
            left: screenWidth / 3, // 1/3 of the screen width for the first line
            top: 0,
            bottom: 0,
            child: Container(
              width: 1,
              color: Colors.black12,
            ),
          ),
          Positioned(
            left: 2 *
                screenWidth /
                3, // 2/3 of the screen width for the second line
            top: 0,
            bottom: 0,
            child: Container(
              width: 1,
              color: Colors.black12,
            ),
          ),
        ],
      ),
    );
  }

  Widget buildRow(
      double screenWidth, double containerHeight, List<ServiceItem> items) {
    // Each row will have a height of 90
    return SizedBox(
      height: 90,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(items[0].icon, size: 50, color: Colors.orange),
                const SizedBox(height: 10),
                Text(items[0].label, style: const TextStyle(fontSize: 16)),
              ],
            ),
          ),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(items[1].icon, size: 50, color: Colors.orange),
                const SizedBox(height: 10),
                Text(items[1].label, style: const TextStyle(fontSize: 16)),
              ],
            ),
          ),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(items[2].icon, size: 50, color: Colors.orange),
                const SizedBox(height: 10),
                Text(items[2].label, style: const TextStyle(fontSize: 16)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class ServiceItem {
  final IconData icon;
  final String label;

  ServiceItem({required this.icon, required this.label});
}
