import 'dart:convert';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../common_utils/Constants.dart';
import '../common_utils/common_styles.dart';
import '../gen/assets.gen.dart';
import '../localization/locale_keys.dart';
import '../models/important_places_model.dart';
import 'Model/Godowndata.dart';
import 'package:http/http.dart' as http;

  class GodownSelectionScreen extends StatefulWidget {
  @override
  GodownSelection createState() => GodownSelection();
  }

  class GodownSelection extends State<GodownSelectionScreen> {
    List<Godowndata> godowndata = [];
    int? selectedIndex; // Track the selected index
    @override
    void initState() {
      super.initState();
      _fetchGodowndata();
    }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar:AppBar(
        titleSpacing: 0.0,
        title: Text(
          tr(LocaleKeys.select_godown),
          style: CommonStyles.text16white,
        ),
        leading: IconButton(
          icon: Image.asset('assets/images/ic_left.png'),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(
              Icons.home,
              color: Colors.white, // Set the color of the home icon to white
            ),
            onPressed: () {
              // Handle home button press
            },
          ),
        ],
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              stops: [1.0, 0.4],
              colors: [Color(0xFFDB5D4B), Color(0xFFE39A63)],
            ),
          ),
        ),
      ),

      body:ListView.builder(
        itemCount: godowndata.length,
        itemBuilder: (context, index) {
          return GestureDetector(
            onTap: () {
              setState(() {
                selectedIndex = index; // Update the selected index
              });
            },
            child: GoDownsCard(
              godown: godowndata[index],
              isSelected: selectedIndex == index, // Pass the selected status
            ),
          );
        },
      ),
    );
  }


  Future<void> _fetchGodowndata() async {

    final response = await http.get(Uri.parse('http://182.18.157.215/3FAkshaya/API/api/Godown/GetActiveGodowns/AP'));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final List<dynamic> listResult = data['listResult'];

      setState(() {
        godowndata = listResult.map((json) => Godowndata.fromJson(json)).toList();
      });
    } else {
      // Handle error
      throw Exception('Failed to load locations');
    }
  }
}

class GoDownsCard extends StatelessWidget {
  final Godowndata godown;
  final bool isSelected; // Add this parameter

  GoDownsCard({required this.godown, this.isSelected = false}); // Default is not selected

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            stops: [0.0, 0.5, 1.0],
            colors: [
              Color(0xFFCCCCCC), // top color: android:startColor="#FFCCCCCC"
              Color(0xFFFFFFFF), // middle color: android:centerColor="#FFFFFFFF"
              Color(0xFFCCCCCC), // bottom color: android:endColor="#FFCCCCCC"
            ],
          ),
          border: isSelected
              ? Border.all(color: CommonStyles.primaryTextColor, width: 2.0) // Border color when selected
              : null,
        ),
        // decoration: BoxDecoration(
        //   color: Colors.grey.shade100,
        //   borderRadius: BorderRadius.circular(5.0),
        //   border: isSelected
        //       ? Border.all(color: Colors.blue, width: 2.0) // Border color when selected
        //       : null,
        // ),
        margin: const EdgeInsets.only(bottom: 10),
        child: Row(
          children: [
            Expanded(
              flex: 3,
              child: Image.asset(
                Assets.images.icGodown.path,
                fit: BoxFit.contain,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              flex: 8,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('${godown.name!}', style: CommonStyles.txSty_14b_f5),
                  Container(
                    height: 1.0,
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Color(0XBEBEBE),
                          Color(0xFFe86100),
                          Color(0xCBBEBEBE),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.center,
                      ),
                    ),
                  ),
                  contentBox(label: tr(LocaleKeys.location), data: '${godown.location}'),
                  Container(
                    height: 1.0,
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Color(0XBEBEBE),
                          Color(0xFFe86100),
                          Color(0xCBBEBEBE),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.center,
                      ),
                    ),
                  ),
                  contentBox(label: tr(LocaleKeys.address), data: '${godown.address}'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget contentBox({required String label, required String? data}) {
    return Column(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
                flex: 4, child: Text(label, style: CommonStyles.txSty_12b_f5)),
            const Text(':  '),
            Expanded(
              flex: 6,
              child: Text('$data',
                  style: CommonStyles.txSty_12b_f5,
                  maxLines: 4,
                  overflow: TextOverflow.ellipsis),
            ),
          ],
        ),
      ],
    );
  }
}
