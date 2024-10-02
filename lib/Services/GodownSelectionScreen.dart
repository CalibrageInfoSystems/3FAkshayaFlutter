// ignore_for_file: file_names

import 'dart:convert';

// import 'package:akshaya_flutter/Services/models/Godowndata.dart';
import 'package:akshaya_flutter/services/models/Godowndata.dart';

import 'package:akshaya_flutter/Services/select_products_screen.dart';
import 'package:akshaya_flutter/common_utils/custom_appbar.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../common_utils/api_config.dart';
import '../common_utils/common_styles.dart';
import '../gen/assets.gen.dart';
import '../localization/locale_keys.dart';
import 'package:akshaya_flutter/Services/SelectEquipProductsScreen.dart';
import 'package:akshaya_flutter/Services/SelectbioProductsScreen.dart';
import 'package:akshaya_flutter/Services/SelectedibleProductsScreen.dart';
import 'package:http/http.dart' as http;

class GodownSelectionScreen extends StatefulWidget {
  final String keyName;

  const GodownSelectionScreen({super.key, required this.keyName});

  @override
  GodownSelection createState() => GodownSelection();
}

class GodownSelection extends State<GodownSelectionScreen> {
  List<Godowndata> godowndata = [];
  int? selectedIndex; // Track the selected index
  bool isLoading = false; // Track loading state
  String? stateCode;
  @override
  void initState() {
    super.initState();
    _fetchGodowndata();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: tr(LocaleKeys.select_godown),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12).copyWith(top: 12),
        child: isLoading
            ? const SizedBox()
            : ListView.builder(
                itemCount: godowndata.length,
                itemBuilder: (context, index) {
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        selectedIndex = index;
                      });
                      navigateBasedOnKey(
                          context, widget.keyName, godowndata[index]);
                    },
                    child: GoDownsCard(
                      godown: godowndata[index],
                      isSelected: selectedIndex == index,
                    ),
                  );
                },
              ),
      ),
    );
  }

  Future<void> _fetchGodowndata() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      stateCode = prefs.getString('statecode');

      print('stateCode -==$stateCode');
    });
    setState(() {
      isLoading = true;
    });

    //Show loading dialog
    Future.delayed(Duration.zero, () {
      CommonStyles.showHorizontalDotsLoadingDialog(context);
    });
    // http://182.18.157.215/3FAkshaya/API/api/Godown/GetActiveGodowns/AP
    try {
      final response =
          await http.get(Uri.parse('$baseUrl$GetActivegodowns$stateCode'));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List<dynamic> listResult = data['listResult'];

        setState(() {
          godowndata =
              listResult.map((json) => Godowndata.fromJson(json)).toList();
          isLoading = false;
        });
      } else {
        throw Exception('Failed to load locations');
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      print(e);
    } finally {
      Navigator.pop(context);
    }
  }

  void navigateBasedOnKey(
      BuildContext context, String keyName, Godowndata selectedGodown) {
    if (keyName == 'Fertilizer') {
      Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => SelectProductsScreen(godown: selectedGodown)),
      );
    } else if (keyName == 'Pole') {
      Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) =>
                SelectEquipProductsScreen(godown: selectedGodown)),
      );
    } else if (keyName == 'BioLab') {
      Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) =>
                SelectbioProductsScreen(godown: selectedGodown)),
      );
    } else if (keyName == 'edibleoils') {
      Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) =>
                SelectedibleProductsScreen(godown: selectedGodown)),
      );
    }
  }
}

class GoDownsCard extends StatelessWidget {
  final Godowndata godown;
  final bool isSelected;

  const GoDownsCard({super.key, required this.godown, this.isSelected = false});

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(3.0),
          gradient: const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            stops: [0.0, 0.5, 1.0],
            colors: [
              Color(0xFFCCCCCC),
              Color(0xFFFFFFFF),
              Color(0xFFCCCCCC),
            ],
          ),
          border: isSelected
              ? Border.all(
                  color: CommonStyles.primaryTextColor,
                )
              : null,
        ),
        margin: const EdgeInsets.only(bottom: 10),
        child: Row(
          children: [
            Expanded(
              flex: 2,
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
                  Text(godown.name!,
                      style: CommonStyles.txStyF16CbFF6
                          .copyWith(color: CommonStyles.blackColorShade)),
                  Container(
                    height: 0.5,
                    margin: const EdgeInsets.symmetric(vertical: 5),
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Color(0xCBBEBEBE),
                          Color(0xFFe86100),
                          Color(0xCBBEBEBE),
                        ],
                      ),
                    ),
                  ),
                  contentBox(
                      label: tr(LocaleKeys.location), data: godown.location),
                  Container(
                    height: 0.5,
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Color(0x00bebebe),
                          Color(0xFFe86100),
                          Color(0xCBBEBEBE),
                        ],
                      ),
                    ),
                  ),
                  contentBox(
                      label: tr(LocaleKeys.address), data: godown.address),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget contentBox({required String label, required String? data}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 4,
                child: Text(label,
                    style: CommonStyles.txStyF14CbFF6
                        .copyWith(color: CommonStyles.blackColorShade)),
              ),
              Text(':  ',
                  style: CommonStyles.txStyF14CbFF6
                      .copyWith(color: CommonStyles.blackColorShade)),
              Expanded(
                flex: 7,
                child: Text('$data',
                    style: CommonStyles.txStyF14CbFF6
                        .copyWith(color: CommonStyles.blackColorShade),
                    maxLines: 4,
                    overflow: TextOverflow.ellipsis),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
