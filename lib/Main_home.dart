import 'package:akshaya_flutter/common_utils/common_styles.dart';
import 'package:akshaya_flutter/localization/app_locale.dart';
import 'package:akshaya_flutter/localization/locale_keys.dart';
import 'package:akshaya_flutter/screens/home_screen/home_screen.dart';
import 'package:akshaya_flutter/screens/my3f_screen.dart/my3f_screen.dart';
import 'package:akshaya_flutter/screens/profile_screen/profile_screen.dart';
import 'package:akshaya_flutter/screens/requests_screen.dart/screens/requests_screen.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

import '../common_utils/Constants.dart';
import '../common_utils/SharedPreferencesHelper.dart';
import '../navigation/app_routes.dart';

// class MainScreen extends StatefulWidget {
//   final StatefulNavigationShell navigationShell;
//
//   const MainScreen({super.key, required this.navigationShell});
class Main_home extends StatefulWidget {

  @override
  _MainScreenPageState createState() => _MainScreenPageState();
}

class _MainScreenPageState extends State<Main_home> {
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();

    //  _selectedIndex = widget.navigationShell.currentIndex;
    print('_selectedIndex==$_selectedIndex');// Sync with initial index
  }



  @override
  Widget build(BuildContext context) {

    return WillPopScope(
      onWillPop: () {
        print('Backbutton pressed (device or appbar button), do whatever you want.');

        //trigger leaving and use own data
        Navigator.pop(context, false);

        //we need to return a future
        return Future.value(false);
      },


      child: Scaffold(
        appBar: appBar(),
     //   drawer: drawer(context),
        backgroundColor: Colors.transparent,
        body: _buildScreens(_selectedIndex, context),
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _selectedIndex,
          showSelectedLabels: true,
          showUnselectedLabels: false,
          backgroundColor: const Color(0xffffffff),
          onTap: (index) => setState(() {
            _selectedIndex = index;

          }),
          selectedItemColor:  Color(0xFF11528f),

          items: <BottomNavigationBarItem>[
            BottomNavigationBarItem(
              icon: SvgPicture.asset(
                'assets/home_new.svg',
                width: 20,
                height: 20,
                color: Colors.black.withOpacity(0.6),
              ),
              activeIcon: SvgPicture.asset(
                'assets/home_new.svg',
                width: 20,
                height: 20,
                color:  Color(0xFF11528f),
              ),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: SvgPicture.asset(
                'assets/invite-alt.svg',
                width: 20,
                height: 20,
                color: Colors.black.withOpacity(0.6),
              ),
              activeIcon: SvgPicture.asset(
                'assets/invite-alt.svg',
                width: 20,
                height: 20,
                color: Color(0xFF11528f),
              ),
              label: 'Appointments',
            ),
            BottomNavigationBarItem(
              icon: SvgPicture.asset(
                'assets/apps-add.svg',
                width: 20,
                height: 20,
                color: Colors.black.withOpacity(0.6),
              ),
              activeIcon: SvgPicture.asset(
                'assets/apps-add.svg',
                width: 20,
                height: 20,
                color: Color(0xFF11528f),
              ),
              label: 'Menu',
            ),
          ],
          selectedLabelStyle: CommonStyles.txSty_16p_f5,
          // unselectedLabelStyle: TextStyle(
          //   fontSize: 14,
          //   color: Colors.grey, // Customize the color as needed
          // ),
        ),
      ),
    );
  }

  // BottomNavigationBar bottomNavigationBar() {
  //   return BottomNavigationBar(
  //     currentIndex: _selectedIndex,
  //     onTap: (index) {
  //       setState(() {
  //
  //         _selectedIndex = index;
  //         print('_selectedIndex==143$_selectedIndex');
  //       });
  //       widget.navigationShell.goBranch(
  //         index,
  //         initialLocation: index == _selectedIndex,
  //       );
  //     },
  //     selectedItemColor: CommonStyles.primaryTextColor,
  //     items: <BottomNavigationBarItem>[
  //       BottomNavigationBarItem(
  //         icon: SvgPicture.asset(
  //           'assets/images/ic_home.svg',
  //           width: 20,
  //           height: 20,
  //           fit: BoxFit.contain,
  //         ),
  //         activeIcon: SvgPicture.asset(
  //           'assets/images/ic_home.svg',
  //           width: 20,
  //           height: 20,
  //           fit: BoxFit.contain,
  //           color: CommonStyles.primaryTextColor,
  //         ),
  //         label: 'Home',
  //       ),
  //       BottomNavigationBarItem(
  //         icon: SvgPicture.asset(
  //           'assets/images/ic_myprofile.svg',
  //           width: 20,
  //           height: 20,
  //           fit: BoxFit.contain,
  //         ),
  //         activeIcon: SvgPicture.asset(
  //           'assets/images/ic_myprofile.svg',
  //           width: 20,
  //           height: 20,
  //           fit: BoxFit.contain,
  //           color: CommonStyles.primaryTextColor,
  //         ),
  //         label: 'Profile',
  //       ),
  //       BottomNavigationBarItem(
  //         icon: SvgPicture.asset(
  //           'assets/images/ic_my.svg',
  //           width: 20,
  //           height: 20,
  //           fit: BoxFit.contain,
  //         ),
  //         activeIcon: SvgPicture.asset(
  //           'assets/images/ic_my.svg',
  //           width: 20,
  //           height: 20,
  //           fit: BoxFit.contain,
  //           color: CommonStyles.primaryTextColor,
  //         ),
  //         label: 'My 3F',
  //       ),
  //       BottomNavigationBarItem(
  //         icon: SvgPicture.asset(
  //           'assets/images/ic_request.svg',
  //           width: 20,
  //           height: 20,
  //           fit: BoxFit.contain,
  //         ),
  //         activeIcon: SvgPicture.asset(
  //           'assets/images/ic_request.svg',
  //           width: 20,
  //           height: 20,
  //           fit: BoxFit.contain,
  //           color: CommonStyles.primaryTextColor,
  //         ),
  //         label: 'Requests',
  //       ),
  //       BottomNavigationBarItem(
  //         icon: SvgPicture.asset(
  //           'assets/images/ic_care.svg',
  //           width: 20,
  //           height: 20,
  //           fit: BoxFit.contain,
  //         ),
  //         activeIcon: SvgPicture.asset(
  //           'assets/images/ic_care.svg',
  //           width: 20,
  //           height: 20,
  //           fit: BoxFit.contain,
  //           color: CommonStyles.primaryTextColor,
  //         ),
  //         label: 'Customer Care',
  //       ),
  //     ],
  //   );
  // }

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


  Widget _buildScreens(int index, BuildContext context) {
    switch (index) {
      case 0:
        return const HomeScreen();


      case 1:
      // Return the messages screen widget
        return const ProfileScreen();

      case 2:

      // Return the settings screen widget
        return const My3fScreen();
      case 3:
      // Return the settings screen widget
        return const RequestsScreen();

      default:
        return HomeScreen();
    }
  }




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
                Text(tr(LocaleKeys.confirmation), style: CommonStyles.text18orange),
                const SizedBox(height: 10),
                Container(
                  height: 0.5,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(colors:  [
                      CommonStyles.primaryTextColor,
                      const Color.fromARGB(255, 110, 6, 228)
                    ],),
                  ),
                ),
                const SizedBox(height: 10),
                Text(
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
                      padding: const EdgeInsets.only(
                          bottom: 10.0),
                      child:Container(
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
                              padding: EdgeInsets.symmetric(horizontal: 35.0),
                              backgroundColor: Colors.transparent,
                              shadowColor: Colors.transparent,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20.0),
                              ),
                            ),
                            child: const Text(
                              'Cancel',
                              style:  CommonStyles.txSty_16p_f5,
                            ),
                          ),
                        ),


                      ),

                    ),
                    Padding(
                      padding: const EdgeInsets.only(
                          bottom: 10.0),
                      child:Container(
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
                              padding: EdgeInsets.symmetric(horizontal: 35.0),
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