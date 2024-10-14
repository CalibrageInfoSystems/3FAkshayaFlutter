import 'dart:convert';

import 'package:akshaya_flutter/common_utils/api_config.dart';
import 'package:akshaya_flutter/common_utils/shared_prefs_keys.dart';
import 'package:akshaya_flutter/common_utils/shimmer.dart';
import 'package:akshaya_flutter/models/important_contacts_model.dart';
import 'package:akshaya_flutter/models/important_places_model.dart';
import 'package:akshaya_flutter/screens/my3f_screen.dart/screens/important_contacts_screen.dart';
import 'package:akshaya_flutter/screens/my3f_screen.dart/screens/important_places_screen.dart';
import 'package:flutter/material.dart';
import 'package:akshaya_flutter/common_utils/common_styles.dart';
import 'package:akshaya_flutter/localization/locale_keys.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:http/http.dart' as http;

class My3fScreen extends StatefulWidget {
  const My3fScreen({super.key});

  @override
  State<My3fScreen> createState() => _My3fScreenState();
}

class _My3fScreenState extends State<My3fScreen> {
  late Future<WebViewController> webViewController;
  // late WebViewController controller;
  late Future<Map<String, dynamic>> importantData;

  @override
  void initState() {
    super.initState();
    // webViewController = loadContent(controller);
    importantData = getImportantContactsAndPlaces();
  }

  Future<Map<String, Object>> getImportantContactsAndPlaces() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? userId = prefs.getString(SharedPrefsKeys.farmerCode);
    final apiUrl = '$baseUrl$get3FInfo$userId/AP';

    final jsonResponse = await http.get(Uri.parse(apiUrl));

    print('api check: $apiUrl');
    print('api check: ${jsonResponse.body}');
    if (jsonResponse.statusCode == 200) {
      Map<String, dynamic> response = jsonDecode(jsonResponse.body);
      final importantContacts = response['result']['importantContacts'];
      final importantPlaces = response['result']['importantPlaces'];
      print(
          'important contacts: ${ImportantContacts.fromJson(importantContacts)}');
      print('important places: ${ImportantPlaces.fromJson(importantPlaces)}');

      /* return [
        ImportantContacts.fromJson(importantContacts),
        ImportantPlaces.fromJson(importantPlaces),
      ]; */
      return {
        'importantContacts': ImportantContacts.fromJson(importantContacts),
        'importantPlaces': ImportantPlaces.fromJson(importantPlaces),
      };
    } else {
      throw Exception('Failed to load to data: ${jsonResponse.statusCode}');
    }
  }

  Future<WebViewController> loadContent() async {
    const apiUrl =
        'http://182.18.157.215/3FAkshaya/API/api/ContactInfo/GetContactInfo/APWGBDAB00010005/AP';

    final jsonResponse = await http.get(Uri.parse(apiUrl));
    if (jsonResponse.statusCode == 200) {
      Map<String, dynamic> response = jsonDecode(jsonResponse.body);
      final result = response['listResult'][0]['description'];

      return WebViewController()
        ..setJavaScriptMode(JavaScriptMode.unrestricted)
        ..loadHtmlString(result)
        ..enableZoom(true)
        ..goForward()
        ..getScrollPosition()
        ..reload()
        ..setOnScrollPositionChange(
          (change) {
            // print('change: ${change.x} | ${change.y}');
            change.x;
            change.y;
          },
        )
        ..setNavigationDelegate(
          NavigationDelegate(
            onPageFinished: (String url) {
              WebViewController()
                  .runJavaScript("document.body.style.zoom = '4.5';");
            },
          ),
        );
    } else {
      throw Exception('Failed to get learning data');
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: tabBar(),
        body: tabView(),
      ),
    );
  }

  AppBar tabBar() {
    return AppBar(
      automaticallyImplyLeading: false,
      backgroundColor: CommonStyles.tabBarColor,
      elevation: 0,
      scrolledUnderElevation: 0,
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1),
        child: TabBar(
          labelStyle: CommonStyles.txStyF14CbFF6.copyWith(
            fontWeight: FontWeight.w400,
          ),
          // indicatorPadding: const EdgeInsets.only(bottom: 3),
          indicatorColor: CommonStyles.primaryTextColor,
          indicatorWeight: 2.0,
          indicatorSize: TabBarIndicatorSize.tab,
          labelColor: CommonStyles.primaryTextColor,
          unselectedLabelColor: CommonStyles.whiteColor,
          dividerColor: Colors.transparent,
          indicator: const BoxDecoration(
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(10),
              topRight: Radius.circular(10),
            ),
            border: Border(
                bottom: BorderSide(
              color: Colors.redAccent,
              width: 1.4,
            )),
            color: CommonStyles.primaryColor,
          ),
          tabs: [
            Tab(
              text: tr(LocaleKeys.basic_info),
            ),
            Tab(
              child: Text(
                tr(LocaleKeys.important_contacts),
                textAlign: TextAlign.center,
                overflow: TextOverflow.visible,
                style: const TextStyle(
                  height: 1.2,
                ),
              ),
            ),
            Tab(
              child: Text(
                tr(LocaleKeys.places),
                textAlign: TextAlign.center,
                overflow: TextOverflow.visible,
                style: const TextStyle(
                  height: 1.2,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget tabView() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 0), //12
      child: TabBarView(
        physics: const NeverScrollableScrollPhysics(),
        children: [
          webviewContent(),
          importantContactsContent(),
          importantPlacesContent(),
        ],
      ),
    );
  }

  FutureBuilder<Map<String, dynamic>> importantPlacesContent() {
    return FutureBuilder(
      future: importantData,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          // return const Center(child: CircularProgressIndicator.adaptive());
          return const ShimmerWid();
        }
        if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}',
              style: CommonStyles.txStyF16CpFF6);
        }
        final data = snapshot.data as Map<String, dynamic>;

        return ImportantPlacesScreen(
            data: data['importantPlaces'] as ImportantPlaces);
      },
    );
  }

  FutureBuilder<Map<String, dynamic>> importantContactsContent() {
    return FutureBuilder(
      future: importantData,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          // return const Center(child: CircularProgressIndicator.adaptive());
          return const ShimmerWid();
        }
        if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}',
              style: CommonStyles.txStyF16CpFF6);
        }
        final data = snapshot.data as Map<String, dynamic>;

        return ImportantContactsScreen(data: data['importantContacts']);
      },
    );
  }

  Widget webviewContent() {
    return FutureBuilder(
        future: loadContent(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator.adaptive());
          }
          if (snapshot.hasError) {
            return Text('Error: ${snapshot.error}',
                style: CommonStyles.txStyF16CpFF6);
          }
          final controller = snapshot.data as WebViewController;
          return Padding(
            padding: const EdgeInsets.all(12.0),
            child: WebViewWidget(
              controller: controller,
            ),
          );
        });
  }
}
