// ignore_for_file: deprecated_member_use

import 'package:akshaya_flutter/common_utils/common_styles.dart';
import 'package:akshaya_flutter/localization/app_locale.dart';
import 'package:akshaya_flutter/localization/locale_keys.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

import '../common_utils/Constants.dart';
import '../common_utils/SharedPreferencesHelper.dart';
import '../navigation/app_routes.dart';

class MainScreen extends StatelessWidget {
  final StatefulNavigationShell navigationShell;
  const MainScreen({super.key, required this.navigationShell});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBar(),
      drawer: drawer(context),
      backgroundColor: Colors.transparent,
      body: SafeArea(child: navigationShell),
      bottomNavigationBar: bottomNavigationBar(),
    );
  }

  BottomNavigationBar bottomNavigationBar() {
    return BottomNavigationBar(
      currentIndex: navigationShell.currentIndex,
      onTap: (index) {
        navigationShell.goBranch(
          index,
          initialLocation: index == navigationShell.currentIndex,
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
      child: ListView(
        children: [
          DrawerHeader(
              child: Container(
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
          )),
          const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'farmerName',
                style: TextStyle(
                  fontSize: 16.0,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'hind_semibold',
                  color: Colors.white,
                ),
              ),
              SizedBox(
                width: 10.0,
              ),
              Text(
                'farmerlastname',
                style: TextStyle(
                  fontSize: 16.0,
                  color: Colors.white,
                  fontFamily: 'hind_semibold',
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(
            height: 10.0,
          ),
          const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'address1',
                style: TextStyle(
                  fontSize: 16.0,
                  color: Colors.white,
                  fontFamily: 'hind_semibold',
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(
                width: 10.0,
              ),
              Text(
                'address2',
                style: TextStyle(
                  fontSize: 16.0,
                  color: Colors.white,
                  fontFamily: 'hind_semibold',
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
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
            title: const Text(
              'Home',
              style: TextStyle(
                color: Colors.white,
                //   fontSize: 16,
                fontFamily: 'hind_semibold',
              ),
            ),
            onTap: () {
              Navigator.pop(context); // Close the drawer
            },
          ),
          ListTile(
            leading: SvgPicture.asset(
              'assets/images/ic_home.svg',
              width: 20,
              height: 20,
              fit: BoxFit.contain,
              color: Colors.white,
            ),
            title: const Text(
              'Choose Language',
              style: TextStyle(
                color: Colors.white,
                //   fontSize: 16,
                fontFamily: 'hind_semibold',
              ),
            ),
            onTap: () {
              // Navigator.pop(context);

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
            title: const Text(
              'Profile',
              style: TextStyle(
                color: Colors.white,
                //   fontSize: 16,
                fontFamily: 'hind_semibold',
              ),
            ),
            onTap: () {
              Navigator.pop(context); // Close the drawer
            },
          ),
          ListTile(
            leading: SvgPicture.asset(
              'assets/images/ic_request.svg',
              width: 20,
              height: 20,
              fit: BoxFit.contain,
              color: Colors.white, // Set the icon color to white
            ),
            title: const Text(
              'Request',
              style: TextStyle(
                color: Colors.white,
                //   fontSize: 16,
                fontFamily: 'hind_semibold',
              ),
            ),
            onTap: () {
              // Implement the action when the My3F item is tapped
              Navigator.pop(context); // Close the drawer
            },
          ),
          ListTile(
            leading: SvgPicture.asset(
              'assets/images/ic_my.svg',
              width: 20,
              height: 20,
              fit: BoxFit.fill,
              color: Colors.white, // Set the icon color to white
            ),
            title: const Text(
              'My3F',
              style: TextStyle(
                color: Colors.white,
                //   fontSize: 16,
                fontFamily: 'hind_semibold',
              ),
            ),
            onTap: () {
              // Implement the action when the Requests item is tapped
              Navigator.pop(context); // Close the drawer
            },
          ),
          ListTile(
            leading: SvgPicture.asset(
              'assets/images/ic_home.svg',
              width: 20,
              height: 20,
              fit: BoxFit.contain,
              color: Colors.white, // Set the icon color to white
            ),
            title: const Text(
              'Logout',
              style: TextStyle(
                color: Colors.white,
                //   fontSize: 16,
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
  }

  void logOutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text(
            'Logout',
            style: CommonStyles.txSty_14b_fb,
          ),
          content: const Text('Are you sure you want to Logout?',
              style: CommonStyles.txSty_12b_fb),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text(
                'Cancel',
                style: CommonStyles.txSty_12b_fb,
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                onConfirmLogout(context);
              },
              child: const Text(
                'Logout',
                style: CommonStyles.txSty_12b_fb,
              ),
            ),
          ],
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
                    Navigator.of(context).pop();
                    context.setLocale(AppLocal.englishLocale);
                  }),
                  languageBox('తెలుగు', onPressed: () {
                    Navigator.of(context).pop();
                    context.setLocale(AppLocal.teluguLocale);
                  }),
                  languageBox('ಕನ್ನಡ', onPressed: () {
                    Navigator.of(context).pop();
                    context.setLocale(AppLocal.kannadaLocale);
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
}
