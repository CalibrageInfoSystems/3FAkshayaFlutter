// ignore_for_file: deprecated_member_use

import 'dart:convert';

import 'package:akshaya_flutter/authentication/login_screen.dart';
import 'package:akshaya_flutter/common_utils/common_styles.dart';
import 'package:akshaya_flutter/common_utils/shared_prefs_keys.dart';
import 'package:akshaya_flutter/gen/assets.gen.dart';
import 'package:akshaya_flutter/localization/app_locale.dart';
import 'package:akshaya_flutter/localization/locale_keys.dart';
import 'package:akshaya_flutter/models/farmer_model.dart';
import 'package:akshaya_flutter/screens/profile_screen/profile_screen.dart';
import 'package:akshaya_flutter/screens/requests_screen.dart/screens/requests_screen.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../common_utils/Constants.dart';
import '../common_utils/SharedPreferencesHelper.dart';
import '../navigation/app_routes.dart';
import 'home_screen/home_screen.dart';
import 'my3f_screen.dart/my3f_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenPageState();
}

class _MainScreenPageState extends State<MainScreen> {
  int _selectedIndex = 0;

  late Future<FarmerModel> farmerDetails;

  @override
  void initState() {
    super.initState();
    farmerDetails = getFarmerInfoFromSharedPrefs();
    print('_selectedIndex==$_selectedIndex');
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        onWillPop: () async {
          // Show a confirmation dialog
          if (_selectedIndex != 0) {
            setState(() {
              _selectedIndex = 0;
            });
            return Future.value(false);
          } else {
            SystemNavigator.pop();

            return Future.value(false);
          }
        },
        child: Scaffold(
          appBar: appBar(),
          drawer: drawer(context),
          backgroundColor: Colors.transparent,
          body: _buildScreens(_selectedIndex, context),
          bottomNavigationBar: bottomNavigationBar(),
        ));
  }

  BottomNavigationBar bottomNavigationBar() {
    return BottomNavigationBar(
      currentIndex: _selectedIndex,
      onTap: (index) {
        setState(() {
          _selectedIndex = index;
          print('_selectedIndex==143$_selectedIndex');
        });
      },
      selectedItemColor: CommonStyles.primaryTextColor,
      items: <BottomNavigationBarItem>[
        bottomNavItem(
          imagePath: Assets.images.icHome.path,
          label: tr(LocaleKeys.home),
        ),
        bottomNavItem(
          imagePath: Assets.images.icMyprofile.path,
          label: tr(LocaleKeys.profile),
        ),
        bottomNavItem(
          imagePath: Assets.images.icMySvg.path,
          label: tr(LocaleKeys.my3F),
        ),
        bottomNavItem(
          imagePath: Assets.images.icRequest.path,
          label: tr(LocaleKeys.requests),
        ),
        bottomNavItem(
          imagePath: Assets.images.icCare.path,
          label: tr(LocaleKeys.customer_care),
        ),
      ],
    );
  }

  BottomNavigationBarItem bottomNavItem(
      {required String imagePath, required String label}) {
    return BottomNavigationBarItem(
      icon: SvgPicture.asset(
        imagePath,
        width: 20,
        height: 20,
        fit: BoxFit.contain,
      ),
      activeIcon: SvgPicture.asset(
        imagePath,
        width: 20,
        height: 20,
        fit: BoxFit.contain,
        color: CommonStyles.primaryTextColor,
      ),
      label: label,
    );
  }

  AppBar appBar() {
    return AppBar(
      elevation: 0,
      backgroundColor: const Color(0xffe46f5d),
      leading: Builder(
        builder: (context) => IconButton(
          icon: const Icon(
            Icons.menu,
            color: CommonStyles.whiteColor,
          ),
          onPressed: () {
            Scaffold.of(context).openDrawer();
          },
        ),
      ),
      titleSpacing: 0.0,
      title: Row(
        mainAxisAlignment:
            MainAxisAlignment.start, // Aligns children to the start
        children: [
          Image.asset(
            'assets/images/logo_final.png',
            width: 40.0,
            height: 40.0,
          ),
          const SizedBox(width: 8.0), // Space adjustment if needed
          Expanded(
            child: Text(
              tr(LocaleKeys.app_name),
              style: CommonStyles.txSty_20w_fb,
            ),
          ),
        ],
      ),
    );
  }

  // AppBar appBar() {
  //   return AppBar(
  //     backgroundColor: const Color(0xffe46f5d),
  //     leading: SizedBox(
  //      width: 0.0, // Adjust width as needed to match the icon size
  //       child: IconButton(
  //         icon: const Icon(
  //           Icons.menu,
  //           color: CommonStyles.whiteColor,
  //         ),
  //         onPressed: () {
  //           Scaffold.of(context).openDrawer();
  //         },
  //       ),
  //     ),
  //     title: Row(
  //       children: [
  //         // App icon with no additional space before it
  //         Image.asset(
  //           'assets/images/logo_final.png', // Path to your app icon
  //           width: 40.0, // Adjust size as needed
  //           height: 40.0, // Adjust size as needed
  //         ),
  //         const SizedBox(width: 8.0), // Space between icon and text
  //         Expanded(
  //           child: Text(
  //             tr(LocaleKeys.app_name),
  //             style: CommonStyles.txSty_20w_fb,
  //           ),
  //         ),
  //       ],
  //     ),
  //    // toolbarHeight: 60.0, // Adjust if you need to control the height of the AppBar
  //   );
  // }

  Widget drawer(BuildContext context) {
    return FutureBuilder(
        future: farmerDetails,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            final farmer = snapshot.data as FarmerModel;
            return Drawer(
              backgroundColor: Colors.black,
              child: ListView(
                children: [
                  const SizedBox(
                    height: 10.0,
                  ),
                  Container(
                    width: 120.0,
                    height: 120.0,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                    ),
                    child: CircleAvatar(
                      backgroundColor: Colors.transparent,
                      child: Image.asset(
                        Assets.images.icUser.path,
                        fit: BoxFit.fill,
                      ),
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        farmer.firstName!,
                        style: const TextStyle(
                          fontSize: 16.0,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'hind_semibold',
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(
                        width: 10.0,
                      ),
                      Text(
                        farmer.lastName!,
                        style: const TextStyle(
                          fontSize: 16.0,
                          color: Colors.white,
                          fontFamily: 'hind_semibold',
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        farmer.addressLine1!,
                        style: const TextStyle(
                          fontSize: 16.0,
                          color: Colors.white,
                          fontFamily: 'hind_semibold',
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(
                        width: 10.0,
                      ),
                      Text(
                        farmer.addressLine2!,
                        style: const TextStyle(
                          fontSize: 16.0,
                          color: Colors.white,
                          fontFamily: 'hind_semibold',
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 5.0,
                  ),
                  Container(
                    height: 2.0,
                    width: 10.0,
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Color(0xFFFF4500),
                          Color(0xFFA678EF),
                          Color(0xFFFF4500),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.center,
                      ),
                    ),
                  ),
                  ListTile(
                    leading: SvgPicture.asset(
                      'assets/images/ic_home.svg',
                      width: 20,
                      height: 20,
                      fit: BoxFit.contain,
                      color: Colors.white,
                    ),
                    title: Text(
                      tr(LocaleKeys.home),
                      style: const TextStyle(
                        color: Colors.white,
                        fontFamily: 'hind_semibold',
                      ),
                    ),
                    onTap: () {
                      _onItemTapped(0);
                    },
                  ),
                  ListTile(
                    leading: Image.asset(
                      'assets/images/ic_lang.png',
                      width: 20,
                      height: 20,
                      fit: BoxFit.contain,
                      color: Colors.white,
                    ),
                    title: Text(
                      tr(LocaleKeys.choose_language_str),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16, // Uncommented to include font size
                        fontFamily: 'hind_semibold',
                      ),
                    ),
                    onTap: () {
                      //  Navigator.pop(context);  // Uncommented to pop the current screen
                      openLanguageDialog(context);
                    },
                  ),
                  ListTile(
                    leading: SvgPicture.asset(
                      'assets/images/ic_myprofile.svg',
                      width: 20,
                      height: 20,
                      fit: BoxFit.contain,
                      color: Colors.white,
                    ),
                    title: Text(
                      tr(LocaleKeys.profile),
                      style: const TextStyle(
                        color: Colors.white,
                        fontFamily: 'hind_semibold',
                      ),
                    ),
                    onTap: () {
                      _onItemTapped(1);
                    },
                  ),
                  ListTile(
                    leading: SvgPicture.asset(
                      'assets/images/ic_my.svg',
                      width: 20,
                      height: 20,
                      fit: BoxFit.fill,
                      color: Colors.white,
                    ),
                    title: Text(
                      tr(LocaleKeys.my3F),
                      style: const TextStyle(
                        color: Colors.white,
                        fontFamily: 'hind_semibold',
                      ),
                    ),
                    onTap: () {
                      _onItemTapped(2);
                    },
                  ),
                  ListTile(
                    leading: SvgPicture.asset(
                      'assets/images/ic_request.svg',
                      width: 20,
                      height: 20,
                      fit: BoxFit.contain,
                      color: Colors.white,
                    ),
                    title: Text(
                      tr(LocaleKeys.requests),
                      style: const TextStyle(
                        color: Colors.white,
                        fontFamily: 'hind_semibold',
                      ),
                    ),
                    onTap: () {
                      _onItemTapped(3);
                    },
                  ),
                  ListTile(
                    leading: Image.asset(
                      'assets/images/ic_logout.png',
                      width: 20,
                      height: 20,
                      fit: BoxFit.contain,
                      color: Colors.white,
                    ),
                    title: Text(
                      tr(LocaleKeys.logout),
                      style: const TextStyle(
                        color: Colors.white,
                        fontFamily: 'hind_semibold',
                      ),
                    ),
                    onTap: () async {
                      logOutDialog(context);
                    },
                  ),
                ],
              ),
            );
          } else if (snapshot.hasError) {
            return Text('Error: ${snapshot.error}');
          } else {
            return const Center(child: CircularProgressIndicator());
          }
        });
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    Navigator.pop(context);
  }

  Widget _buildScreens(int index, BuildContext context) {
    switch (index) {
      case 0:
        return const HomeScreen();

      case 1:
        return const ProfileScreen();

      case 2:
        return const My3fScreen();

      case 3:
        return const RequestsScreen();

      default:
        return const HomeScreen();
    }
  }

  Future<FarmerModel> getFarmerInfoFromSharedPrefs() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final result = prefs.getString(SharedPrefsKeys.farmerData);
    if (result != null) {}
    Map<String, dynamic> response = json.decode(result!);
    Map<String, dynamic> farmerResult = response['result']['farmerDetails'][0];
    return FarmerModel.fromJson(farmerResult);
  }

  void logOutDialog(BuildContext context) {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: '',
      barrierColor: Colors.black54,
      transitionDuration: const Duration(milliseconds: 500),
      pageBuilder: (context, animation1, animation2) {
        return Center(
          child: Material(
            color: Colors.transparent,
            child: Container(
              width: MediaQuery.of(context).size.width * 0.8,
              padding: const EdgeInsets.all(12.0),
              decoration: BoxDecoration(
                color: CommonStyles.blackColor,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: CommonStyles.primaryTextColor,
                  width: 1,
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(tr(LocaleKeys.confirmation),
                      style: CommonStyles.text18orange),
                  const SizedBox(height: 10),
                  Container(
                    height: 0.5,
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          CommonStyles.primaryTextColor,
                          Color.fromARGB(255, 110, 6, 228)
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'Are you sure you want to Logout?',
                    style: CommonStyles.text16white,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      // Cancel Button
                      Padding(
                        padding: const EdgeInsets.only(bottom: 10.0),
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius:
                                BorderRadius.circular(20.0), // Rounded corners
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
                              color: const Color(
                                  0xFFe86100), // Orange border color
                              width: 2.0,
                            ),
                          ),
                          child: SizedBox(
                            height: 30.0, // Set the desired height
                            child: ElevatedButton(
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                              style: ElevatedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 35.0),
                                backgroundColor: Colors.transparent,
                                shadowColor: Colors.transparent,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20.0),
                                ),
                              ),
                              child: const Text(
                                'Cancel',
                                style: CommonStyles.txSty_16p_f5,
                              ),
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(bottom: 10.0),
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius:
                                BorderRadius.circular(20.0), // Rounded corners
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
                              color: const Color(
                                  0xFFe86100), // Orange border color
                              width: 2.0,
                            ),
                          ),
                          child: SizedBox(
                            height: 30.0, // Set the desired height
                            child: ElevatedButton(
                              onPressed: () {
                                Navigator.of(context).pop();
                                onConfirmLogout(context);
                              },
                              style: ElevatedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 35.0),
                                backgroundColor: Colors.transparent,
                                shadowColor: Colors.transparent,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20.0),
                                ),
                              ),
                              child: const Text(
                                'OK',
                                style: CommonStyles.txSty_16p_f5,
                              ),
                            ),
                          ),
                        ),
                      )
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
      transitionBuilder: (context, animation1, animation2, child) {
        return ScaleTransition(
          scale: Tween<double>(begin: 0.0, end: 1.0).animate(
            CurvedAnimation(
              parent: animation1,
              curve: Curves.easeOutBack, // Customize the animation curve here
            ),
          ),
          child: child,
        );
      },
    );
  }

  Future<void> onConfirmLogout(BuildContext context) async {
    SharedPreferencesHelper.putBool(Constants.isLogin, false);
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const LoginScreen(),
      ),
    );
    //context.go(Routes.loginScreen.path);
  }

  void openLanguageDialog(BuildContext context) {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: '',
      barrierColor: Colors.black54,
      transitionDuration: const Duration(milliseconds: 500),
      pageBuilder: (context, animation1, animation2) {
        return Center(
          child: Material(
            color: Colors.transparent,
            child: Container(
              width: MediaQuery.of(context).size.width * 0.8,
              padding: const EdgeInsets.all(12.0),
              decoration: BoxDecoration(
                color: CommonStyles.blackColor,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: CommonStyles.primaryTextColor,
                  width: 1,
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(tr(LocaleKeys.choose_language_str),
                      style: CommonStyles.text18orange),
                  const SizedBox(height: 5),
                  languageBox('English', colors: [
                    CommonStyles.primaryTextColor,
                    const Color.fromARGB(255, 110, 6, 228)
                  ], onPressed: () {
                    changeLocaleLanguage(context, AppLocal.englishLocale);
                  }),
                  languageBox('తెలుగు', onPressed: () {
                    changeLocaleLanguage(context, AppLocal.teluguLocale);
                  }),
                  languageBox('ಕನ್ನಡ', onPressed: () {
                    changeLocaleLanguage(context, AppLocal.kannadaLocale);
                  }),
                ],
              ),
            ),
          ),
        );
      },
      transitionBuilder: (context, animation1, animation2, child) {
        return ScaleTransition(
          scale: Tween<double>(begin: 0.0, end: 1.0).animate(
            CurvedAnimation(
              parent: animation1,
              curve: Curves.easeOutBack,
            ),
          ),
          child: child,
        );
      },
    );
  }

  void changeLocaleLanguage(BuildContext context, Locale locale) {
    setState(() {
      context.setLocale(locale);

// Change the locale
    });
    Navigator.of(context).pop(); // Close the popup
    Navigator.of(context).pop(); // Close the side menu  // Trigger a rebuild
  }

  Container languageBox(String language,
      {List<Color> colors = const [Colors.grey, Colors.grey],
      required void Function()? onPressed}) {
    return Container(
      margin: const EdgeInsets.only(top: 10),
      child: Column(
        children: [
          Container(
            height: 0.5,
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: colors),
            ),
          ),
          const SizedBox(height: 10),
          ElevatedButton(
            onPressed: onPressed,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.transparent,
            ),
            child: Text(language, style: CommonStyles.txSty_16w_fb),
          ),
        ],
      ),
    );
  }
}
