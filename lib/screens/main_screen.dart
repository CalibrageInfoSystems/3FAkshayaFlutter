// ignore_for_file: deprecated_member_use

import 'dart:convert';

import 'package:akshaya_flutter/common_utils/api_config.dart';
import 'package:akshaya_flutter/common_utils/common_styles.dart';
import 'package:akshaya_flutter/gen/assets.gen.dart';
import 'package:akshaya_flutter/localization/app_locale.dart';
import 'package:akshaya_flutter/localization/locale_keys.dart';
import 'package:akshaya_flutter/models/banner_model.dart';
import 'package:akshaya_flutter/models/farmer_model.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../common_utils/Constants.dart';
import '../common_utils/SharedPreferencesHelper.dart';
import '../navigation/app_routes.dart';

class MainScreen extends StatefulWidget {
  final StatefulNavigationShell navigationShell;
  const MainScreen({super.key, required this.navigationShell});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  late Future<FarmerModel> farmerData;

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.navigationShell.currentIndex;
    farmerData = getSharedPrefData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBar(),
      drawer: drawer(context),
      backgroundColor: Colors.transparent,
      body: SafeArea(child: widget.navigationShell),
      bottomNavigationBar: bottomNavigationBar(),
    );
  }

  BottomNavigationBar bottomNavigationBar() {
    return BottomNavigationBar(
      currentIndex: _selectedIndex,
      onTap: (index) {
        setState(() {
          _selectedIndex = index;
        });
        widget.navigationShell.goBranch(
          index,
          initialLocation: index == _selectedIndex,
        );
      },
      selectedItemColor: CommonStyles.primaryTextColor,
      items: <BottomNavigationBarItem>[
        BottomNavigationBarItem(
          icon: SvgPicture.asset(
            'assets/images/ic_home.svg',
            width: 20,
            height: 20,
            fit: BoxFit.contain,
          ),
          activeIcon: SvgPicture.asset(
            'assets/images/ic_home.svg',
            width: 20,
            height: 20,
            fit: BoxFit.contain,
            color: CommonStyles.primaryTextColor,
          ),
          label: 'Home',
        ),
        BottomNavigationBarItem(
          icon: SvgPicture.asset(
            'assets/images/ic_myprofile.svg',
            width: 20,
            height: 20,
            fit: BoxFit.contain,
          ),
          activeIcon: SvgPicture.asset(
            'assets/images/ic_myprofile.svg',
            width: 20,
            height: 20,
            fit: BoxFit.contain,
            color: CommonStyles.primaryTextColor,
          ),
          label: 'Profile',
        ),
        BottomNavigationBarItem(
          icon: SvgPicture.asset(
            'assets/images/ic_my.svg',
            width: 20,
            height: 20,
            fit: BoxFit.contain,
          ),
          activeIcon: SvgPicture.asset(
            'assets/images/ic_my.svg',
            width: 20,
            height: 20,
            fit: BoxFit.contain,
            color: CommonStyles.primaryTextColor,
          ),
          label: 'My 3F',
        ),
        BottomNavigationBarItem(
          icon: SvgPicture.asset(
            'assets/images/ic_request.svg',
            width: 20,
            height: 20,
            fit: BoxFit.contain,
          ),
          activeIcon: SvgPicture.asset(
            'assets/images/ic_request.svg',
            width: 20,
            height: 20,
            fit: BoxFit.contain,
            color: CommonStyles.primaryTextColor,
          ),
          label: 'Requests',
        ),
        BottomNavigationBarItem(
          icon: SvgPicture.asset(
            'assets/images/ic_care.svg',
            width: 20,
            height: 20,
            fit: BoxFit.contain,
          ),
          activeIcon: SvgPicture.asset(
            'assets/images/ic_care.svg',
            width: 20,
            height: 20,
            fit: BoxFit.contain,
            color: CommonStyles.primaryTextColor,
          ),
          label: 'Customer Care',
        ),
      ],
    );
  }

  AppBar appBar() {
    return AppBar(
      backgroundColor: const Color(0xffe46f5d),
      elevation: 0,
      leading: Builder(
        builder: (context) => IconButton(
          icon: const Icon(
            Icons.menu,
            color: CommonStyles.whiteColor,
          ), // Replace with your custom icon or widget
          onPressed: () {
            Scaffold.of(context).openDrawer();
          },
        ),
      ),
      title: const Text('data'),
    );
  }

  Drawer drawer(BuildContext context) {
    return Drawer(
      backgroundColor: Colors.black,
      child: FutureBuilder(
          future: farmerData,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Text('Error: ${snapshot.error}');
            } else if (!snapshot.hasData) {
              return const Text('No data available');
            } else {
              final farmer = snapshot.data as FarmerModel;
              return ListView(
                children: [
                  const SizedBox(height: 10),
                  Container(
                    width: 120.0,
                    height: 120.0,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                    ),
                    child: CircleAvatar(
                      backgroundColor: Colors.transparent,
                      child: Image.asset(
                        'assets/images/ic_user.png',
                        fit: BoxFit.fill,
                      ),
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '${farmer.firstName}',
                        style: const TextStyle(
                          fontSize: 16.0,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'hind_semibold',
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(
                        width: 5.0,
                      ),
                      Text(
                        '${farmer.lastName}',
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
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '${farmer.addressLine1}',
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
                        '${farmer.addressLine2}',
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
                      Assets.images.icHome.path,
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
                    leading: SvgPicture.asset(
                      Assets.images.icHome.path,
                      width: 20,
                      height: 20,
                      fit: BoxFit.contain,
                      color: Colors.white,
                    ),
                    title: Text(
                      tr(LocaleKeys.choose_language_str),
                      style: const TextStyle(
                        color: Colors.white,
                        //   fontSize: 16,
                        fontFamily: 'hind_semibold',
                      ),
                    ),
                    onTap: () {
                      openLanguageDialog(context);
                    },
                  ),
                  ListTile(
                    leading: SvgPicture.asset(
                      Assets.images.icMyprofile.path,
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
                      Assets.images.icMy.path,
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
                      Assets.images.icRequest.path,
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
                    leading: SvgPicture.asset(
                      Assets.images.icHome.path,
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
              );
            }
          }),
    );
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
      widget.navigationShell.goBranch(
        index,
        initialLocation: index == widget.navigationShell.currentIndex,
      );
    });
    Navigator.pop(context); // Close the drawer after selection
  }

  void logOutDialog(BuildContext context) {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: '',
      barrierColor: Colors.black54, // Background color when the dialog is open
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
    //  SharedPreferences prefs = await SharedPreferences.getInstance();
    SharedPreferencesHelper.putBool(Constants.isLogin, false);
    // CommonUtils.showCustomToastMessageLong("Logout Successful", context, 0, 3);
    context.go(Routes.loginScreen.path);
  }

  void openLanguageDialog(BuildContext context) {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: '',
      barrierColor: Colors.black54, // Background color when the dialog is open
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
                    saveDataAndChangeLanguage(context,
                        language: Constants.englishLanguage,
                        locale: AppLocal.englishLocale);
                  }),
                  languageBox('తెలుగు', onPressed: () {
                    saveDataAndChangeLanguage(context,
                        language: Constants.teluguLanguage,
                        locale: AppLocal.teluguLocale);
                  }),
                  languageBox('ಕನ್ನಡ', onPressed: () {
                    saveDataAndChangeLanguage(context,
                        language: Constants.kannadaLanguage,
                        locale: AppLocal.kannadaLocale);
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
              curve: Curves.easeOutBack, // Customize the animation curve here
            ),
          ),
          child: child,
        );
      },
    );
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

  Future<void> saveDataAndChangeLanguage(BuildContext context,
      {required String language, required Locale locale}) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool(Constants.welcome, true);
    prefs.setString(SharedPrefsKeys.language, language);
    context.setLocale(locale);
    Navigator.of(context).pop();
    setState(() {});
  }

  Future<FarmerModel> getSharedPrefData() async {
    print('getSharedPrefData() called');
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? farmerData = prefs.getString(SharedPrefsKeys.farmerData);

    if (farmerData != null && farmerData.isNotEmpty) {
      Map<String, dynamic> response =
          json.decode(farmerData)['result']['farmerDetails'][0];

      return FarmerModel.fromJson(response);
    } else {
      throw Exception('No farmer is saved in shared preferences');
    }
  }
}
