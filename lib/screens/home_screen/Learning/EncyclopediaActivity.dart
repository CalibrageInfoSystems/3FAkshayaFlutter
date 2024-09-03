import 'dart:convert';

import 'package:akshaya_flutter/gen/assets.gen.dart';
import 'package:akshaya_flutter/screens/home_screen/home_screen.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import '../../../common_utils/common_styles.dart';
import '../../../localization/locale_keys.dart';
import 'Model/AgeRecommendation.dart';
import 'Model/FertilizerRecommendation.dart';

class EncyclopediaActivity extends StatelessWidget {
  final List<String> tabNames;
  final String appBarTitle;

  EncyclopediaActivity({required this.tabNames, required this.appBarTitle});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
        length: tabNames.length,
        child: Scaffold(
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
                  bottom:   TabBar(
                    indicatorColor: CommonStyles.primaryTextColor,
                    indicatorWeight: 2.0,
                    indicatorSize: TabBarIndicatorSize.tab,
                    labelColor: CommonStyles.primaryTextColor,
                    unselectedLabelColor: CommonStyles.whiteColor,

                    indicator: const BoxDecoration(

                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(10),
                        topRight: Radius.circular(10),
                      ),
                      color: CommonStyles.primaryColor,
                    ),
                    tabs: [
                      Tab(text: tr(LocaleKeys.str_standard)),
                      Tab(text: tr(LocaleKeys.str_pdf)),
                      Tab(text: tr(LocaleKeys.str_videos)),
                    ],
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
class Standard extends StatefulWidget {
  @override
  _StandardState createState() => _StandardState();
}

class _StandardState extends State<Standard> {
  String? selectedAge;
  List<AgeRecommendation> ages = [];
  List<FertilizerRecommendation> fertilizers = [];

  @override
  void initState() {
    super.initState();
    _fetchAges();
    if (ages.isNotEmpty) {
      selectedAge = ages.first.displayName;
      _fetchFertilizers(selectedAge!); // Fetch fertilizers for the default selected age
    }
  }


  Future<void> _fetchAges() async {
    try {
      final fetchedAges = await fetchAgeRecommendations();
      setState(() {
        ages = fetchedAges;
        if (ages.isNotEmpty) {
          selectedAge = ages.first.displayName; // Set the first item by default
          _fetchFertilizers(selectedAge!); // Fetch data for the default selection
        }
      });
    } catch (e) {
      print('Error fetching ages: $e');
    }
  }

  Future<void> _fetchFertilizers(String age) async {
    print('===Selected age $age');
    try {
      final response = await http.get(Uri.parse('http://182.18.157.215/3FAkshaya/API/api/GetRecommendationsByAge/$age'));
      print('==response ${response.statusCode}');
      if (response.statusCode == 200) {
        final List<dynamic> jsonData = json.decode(response.body);
        print(response.body);
        print(jsonData);

        // Map JSON data to Dart model
        final fetchedFertilizers = jsonData.map((item) => FertilizerRecommendation.fromJson(item)).toList();

        setState(() {
          fertilizers = fetchedFertilizers;
        });
      } else {
        throw Exception('Failed to load fertilizers');
      }
    } catch (e) {
      print('Error fetching fertilizers: $e');
    }
  }
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(

            alignment: Alignment.topCenter,
            margin: EdgeInsets.symmetric(horizontal: 12,vertical: 12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.white),
            ),
            child:
            DropdownButtonHideUnderline(
              child: DropdownButton2<String>(
                iconStyleData: const IconStyleData(
                  icon: Icon(
                    Icons.keyboard_arrow_down_rounded,
                    color: Colors.white,
                  ),
                ),
                isExpanded: true,
                value: selectedAge,
                items: ages.map((age) {
                  return DropdownMenuItem<String>(
                    value: age.displayName,
                    child: Text(age.displayName, style: CommonStyles.txSty_12W_fb),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    selectedAge = value!;
                    print('selectedAge===,$selectedAge');
                  });
                  _fetchFertilizers(value!);
                  print('selectedAge===,$value');
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
                  padding: EdgeInsets.symmetric(horizontal: 20),
                ),
              ),
            )

          ),
      const SizedBox(height: 8), // Spacing between dropdown and note
     Container(
       margin: EdgeInsets.symmetric(horizontal: 12),

     child:  RichText(

        text: TextSpan(
          text: 'Note: ',
          style: CommonStyles.text18orangeeader,
          children: [
            TextSpan(
              text: 'Quantity in gm/plant/year',
              style: CommonStyles.text14white,
            ),
          ],
        ),
      ),
     ),
          const SizedBox(height: 8),
      Expanded(
        child: ListView.builder(
          itemCount: fertilizers.length,
          itemBuilder: (context, index) {
            final fertilizer = fertilizers[index];
            final isEvenIndex = index % 2 == 0;

            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 12), // Adding margin
              child: Card(
                color: isEvenIndex ? Colors.white : Colors.grey.shade300, // Alternate colors
                child: Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const SizedBox(
                            width: 100, // Equal space for the label
                            child: Text(
                              'Fertilizer',
                              style: CommonStyles.txSty_14b_f6
                            ),
                          ),
                          Expanded(
                            child: Text(
                              fertilizer.fertilizer,
                              style: CommonStyles.text18orangeeader,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const SizedBox(
                            width: 100, // Equal space for the label
                            child: Text(
                              'Quantity',
                              style: CommonStyles.txSty_14b_f6,
                            ),
                          ),
                          Expanded(
                            child: Text(
                              '${fertilizer.quantity}',
                                style: CommonStyles.txSty_14b_f5
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const SizedBox(
                            width: 100, // Equal space for the label
                            child: Text(
                              'Remarks',
                                style: CommonStyles.txSty_14b_f6
                            ),
                          ),
                          Expanded(
                            child: Text(
                              fertilizer.remarks,
                                style: CommonStyles.txSty_14b_f5
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),




      ],
      ),
    );
  }

  Future<List<AgeRecommendation>> fetchAgeRecommendations() async {
    final response = await http.get(Uri.parse('http://182.18.157.215/3FAkshaya/API/api/GetRecommendationAges'));

    if (response.statusCode == 200) {
      List<dynamic> jsonData = json.decode(response.body)['listResult'];
      return jsonData.map((data) => AgeRecommendation.fromJson(data)).toList();
    } else {
      throw Exception('Failed to load age recommendations');
    }
  }

  Future<List<FertilizerRecommendation>> fetchFertilizerRecommendations(String age) async {
    final response = await http.get(Uri.parse('http://182.18.157.215/3FAkshaya/API/api/GetRecommendationsByAge/Year 2'));

    if (response.statusCode == 200) {
      print(response.body);  // Add this line to print the raw JSON response
      List<dynamic> jsonData = json.decode(response.body)['listResult'];
      return jsonData.map((data) => FertilizerRecommendation.fromJson(data)).toList();
    } else {
      throw Exception('Failed to load fertilizer recommendations');
    }

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

