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
import 'package:akshaya_flutter/screens/view_requests.dart/requests_screen.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

import '../common_utils/Constants.dart';
import '../common_utils/SharedPreferencesHelper.dart';
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

  String _appVersion = '';

  @override
  void initState() {
    super.initState();
    farmerDetails = getFarmerInfoFromSharedPrefs();
    _getAppVersion();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    EasyLocalization.of(context)?.locale;
  }

  Future<void> _getAppVersion() async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();

    setState(() {
      _appVersion = '${packageInfo.version} (${packageInfo.buildNumber})';
    });
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
        if (index == 4) {
          _careDial(context);
        } else {
          setState(() {
            _selectedIndex = index;
            print('_selectedIndex==143 $_selectedIndex');
          });
        }
      },
      selectedItemColor: CommonStyles.primaryTextColor,
      selectedLabelStyle: CommonStyles.txStyF14CwFF6,
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
        width: 25,
        height: 25,
        fit: BoxFit.contain,
        color: Colors.black.withOpacity(0.6),
      ),
      activeIcon: SvgPicture.asset(
        imagePath,
        width: 25,
        height: 25,
        fit: BoxFit.contain,
        color: CommonStyles.primaryTextColor,
      ),
      label: label,
    );
  }

  AppBar appBar() {
    return AppBar(
      elevation: 0,
      scrolledUnderElevation: 0,
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
          const SizedBox(width: 5.0), // Space adjustment if needed
          Expanded(
            child: Text(
              tr(LocaleKeys.app_name),
              style: CommonStyles.txStyF16CwFF6,
            ),
          ),
        ],
      ),
    );
  }

  Widget drawer(BuildContext context) {
    return FutureBuilder(
        future: farmerDetails,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            final farmer = snapshot.data as FarmerModel;
            return Drawer(
              backgroundColor: Colors.black,
              child: SafeArea(
                child: Column(
                  children: [
                    Container(
                      width: 120.0,
                      height: 120.0,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                      ),
                      child: CircleAvatar(
                        backgroundColor: Colors.transparent,
                        child: farmer.farmerPictureLocation != null
                            ? Image.network(
                                farmer.farmerPictureLocation!,
                                fit: BoxFit.fill,
                                errorBuilder: (context, error, stackTrace) {
                                  // Show icUser image if there's an error loading the farmer image
                                  return Image.asset(
                                    Assets.images.icUser.path,
                                    fit: BoxFit.fill,
                                  );
                                },
                              )
                            : Image.asset(
                                Assets.images.icUser
                                    .path, // Placeholder image if farmerImage is null
                                fit: BoxFit.fill,
                              ),
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          '${'${farmer.firstName!} ' + (farmer.middleName ?? '')} ${farmer.lastName!}',
                          style: CommonStyles.txStyF16CwFF6,
                        ),
                      ],
                    ),
                    if (farmer.contactNumber != null)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            '${farmer.contactNumber}',
                            style: CommonStyles.txStyF14CwFF6,
                          ),
                        ],
                      ),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          "${farmer.addressLine1!} - ${farmer.addressLine2!}",
                          textAlign: TextAlign.center, // Center-align the text
                          style: CommonStyles.txStyF14CwFF6,
                        ),
                      ],
                    ),
                    const SizedBox(
                      height: 5.0,
                    ),
                    Container(
                      height: 1.0,
                      margin: const EdgeInsets.symmetric(horizontal: 15.0),
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Color(0xFFFF4500),
                            Color(0xFFA678EF),
                            Color(0xFFFF4500),
                          ],
                        ),
                      ),
                    ),
                    Expanded(
                      child: Column(
                        children: [
                          menuOption(
                              title: tr(LocaleKeys.home),
                              menuIcon: Assets.images.icHome.path,
                              onTap: () {
                                _onItemTapped(0);
                              }),
                          menuOption(
                              title: tr(LocaleKeys.choose_language_str),
                              menuIcon: Assets.images.icLang.path,
                              isPng: true,
                              onTap: () {
                                openLanguageDialog(context);
                              }),
                          menuOption(
                              title: tr(LocaleKeys.profile),
                              menuIcon: Assets.images.icMyprofile.path,
                              onTap: () {
                                _onItemTapped(1);
                              }),
                          menuOption(
                              title: tr(LocaleKeys.requests),
                              menuIcon: Assets.images.icRequest.path,
                              onTap: () {
                                _onItemTapped(3);
                              }),
                          menuOption(
                              title: tr(LocaleKeys.my3F),
                              menuIcon: Assets.images.icMySvg.path,
                              onTap: () {
                                _onItemTapped(2);
                              }),
                          menuOption(
                              title: tr(LocaleKeys.log_off),
                              menuIcon: Assets.images.icLogout.path,
                              isPng: true,
                              onTap: () {
                                logOutDialog(context);
                              }),
                        ],
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(tr(LocaleKeys.App_version),
                            style: CommonStyles.txStyF14CwFF6),
                        Text(' $_appVersion ',
                            style: CommonStyles.txStyF14CwFF6),
                      ],
                    ),
                    const SizedBox(
                      height: 20.0,
                    ),
                  ],
                ),
              ),
            );
          } else if (snapshot.hasError) {
            return Center(
              child: Text(
                  snapshot.error.toString().replaceFirst('Exception: ', ''),
                  style: CommonStyles.txStyF16CpFF6),
            );
          } else {
            return const Center(child: CircularProgressIndicator());
          }
        });
  }

  ListTile menuOption(
      {String? menuIcon,
      required String title,
      void Function()? onTap,
      bool isPng = false}) {
    return ListTile(
      leading: menuIcon != null
          ? (isPng
              ? Image.asset(
                  menuIcon,
                  width: 25,
                  height: 25,
                  fit: BoxFit.contain,
                  color: Colors.white,
                )
              : SvgPicture.asset(
                  menuIcon,
                  width: 25,
                  height: 25,
                  fit: BoxFit.contain,
                  color: Colors.white,
                ))
          : null,
      title: Text(
        title,
        style: CommonStyles.txStyF14CwFF6
            .copyWith(fontWeight: FontWeight.w500, fontSize: 15),
      ),
      onTap: onTap,
    );
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
                  languageBox(
                    'English',
                    colors: [
                      CommonStyles.primaryTextColor,
                      const Color.fromARGB(255, 110, 6, 228),
                    ],
                    onPressed: () {
                      changeLocaleLanguage(context, AppLocal.englishLocale);
                    },
                  ),
                  languageBox(
                    'తెలుగు',
                    onPressed: () {
                      changeLocaleLanguage(context, AppLocal.teluguLocale);
                    },
                  ),
                  languageBox(
                    'ಕನ್ನಡ',
                    onPressed: () {
                      changeLocaleLanguage(context, AppLocal.kannadaLocale);
                    },
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
              curve: Curves.easeOutBack,
            ),
          ),
          child: child,
        );
      },
    );
  }

  void changeLocaleLanguage(BuildContext context, Locale locale) {
    context.setLocale(locale); // Change the locale
    Navigator.of(context).pop(); // Close the popup
    // Close side menu only if open
    if (Navigator.of(context).canPop()) {
      Navigator.of(context)
          .pop(); // Close side menu or other dialog if applicable
    }
  }

  Widget languageBox(String language,
      {List<Color> colors = const [Colors.grey, Colors.grey],
      required void Function()? onPressed}) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 5),
        color: Colors.transparent,
        child: Column(
          children: [
            Container(
              height: 0.5,
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: colors),
              ),
            ),
            // const SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.only(top: 15, bottom: 10),
              child: Text(language, style: CommonStyles.txStyF16CwFF6),
            ), // txSty_16w_fb

            // const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

  void _careDial(BuildContext context) async {
    const phoneNumber = '040 23324733';
    final Uri uri = Uri(
      scheme: 'tel',
      path: phoneNumber,
    );
    try {
      if (await canLaunch(uri.toString())) {
        await launch(uri.toString());
      } else {
        throw 'Could not launch $uri';
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('SecurityException: $e')),
      );
    }
  }
}
