import 'package:akshaya_flutter/gen/assets.gen.dart';
import 'package:akshaya_flutter/screens/home_screen/home_screen.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../common_utils/common_styles.dart';
import '../../../localization/locale_keys.dart';

class EncyclopediaActivity extends StatelessWidget {
  final List<String> tabNames;
  final String appBarTitle;

  EncyclopediaActivity({required this.tabNames, required this.appBarTitle});

  @override
  Widget build(BuildContext context) {
    return
      DefaultTabController(
        length: tabNames.length,
        child:
        Scaffold(
          body: Stack(
            children: [
              // Positioned gradient background
              Positioned(
                top: -90,
                bottom: 450, // Adjust as needed
                left: -60,
                right: -60,
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter, // 90 degrees
                      end: Alignment.bottomCenter,
                      colors: [
                        //Color(0xffDB5D4B),.
                        Color(0xFFDB5D4B),
                        Color(0xFFE39A63), // startColor
                         // endColor
                      ],
                    ),
                  ),
                ),
              ),

              // Main content with AppBar and TabBar
              Scaffold(
                backgroundColor: Colors.transparent, // To make the scaffold background transparent
                appBar: AppBar(
                  backgroundColor: Colors.transparent, // Transparent background for gradient to show through
                  leading: GestureDetector(
                    onTap: () {
                      Navigator.pop(context);
                    },
                    child: Image.asset(Assets.images.icLeft.path),
                  ),
                  elevation: 0,
                  title: Text(
                    appBarTitle,
                    style: CommonStyles.txSty_14black_f5.copyWith(
                      color: CommonStyles.whiteColor,
                    ),
                  ),
                  actions: [
                    IconButton(
                      icon: const Icon(
                        Icons.home,
                        color: Colors.white,
                      ),
                      onPressed: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>  HomeScreen(),
                          ),
                        );
                      },
                    ),
                  ],
                  bottom: TabBar(
                    labelColor: Color(0xFFe86100),
                    unselectedLabelColor: Colors.white,
                    indicator: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(10.0),
                        topRight: Radius.circular(10.0),
                      ),
                    ),
                    tabs: tabNames
                        .map((name) => Container(
                      width: MediaQuery.of(context).size.width / tabNames.length,
                      child: Tab(text: name),
                    )).toList(),
                  ),
                ),
                body: TabBarView(
                  children: [
                    Standard(),
                    Pdfs(),
                    Videos(),
                  ],
                ),
              ),
            ],
          ),
        ),
      );

  }
}
class Standard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(

      child: Column(
        children: [
          Container(
            alignment: Alignment.topCenter,
            margin: EdgeInsets.only(left: 12,right:12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: CommonStyles.whiteColor),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton2<double>(
                iconStyleData: const IconStyleData(
                  icon: Icon(
                    Icons.keyboard_arrow_down_rounded,
                    color: Colors.white,
                  ),
                ),
                isExpanded: true,
                onChanged: (position) {
                  // setState(() {
                  //   selectedPosition = position;
                  //   print('selectedposition $selectedPosition');
                  // });
                  // callApiMethod(selectedPosition!, vendorcode);

                  // Now, call your API method based on the selected position
                },
                dropdownStyleData: DropdownStyleData(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(14),
                    color: Colors.black87,
                  ),
                  offset: const Offset(0, 0),
                  scrollbarTheme: ScrollbarThemeData(
                    radius: const Radius.circular(40),
                    thickness: WidgetStateProperty.all<double>(6),
                    thumbVisibility: WidgetStateProperty.all<bool>(true),
                  ),
                ),
                menuItemStyleData: const MenuItemStyleData(
                  height: 40,
                  padding: EdgeInsets.only(left: 20, right: 20),
                ),
                //value: selectedPosition,
                items: [

                ],


              ),

            ),

          ),
        ],
      ),
    );
  }
}

class Pdfs extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text('Content for Tab 2'),
    );
  }
}

class Videos extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text('Content for Tab 3'),
    );
  }
}

