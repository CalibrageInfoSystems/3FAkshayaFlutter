// ignore_for_file: file_names

import 'dart:convert';

import 'package:akshaya_flutter/Services/select_products_screen.dart';
import 'package:akshaya_flutter/common_utils/custom_appbar.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../common_utils/common_styles.dart';
import '../gen/assets.gen.dart';
import '../localization/locale_keys.dart';
import 'models/Godowndata.dart';
import 'package:http/http.dart' as http;

class GodownSelectionScreen extends StatefulWidget {
  const GodownSelectionScreen({super.key});

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
      appBar: CustomAppBar(
        title: tr(LocaleKeys.select_godown),
      ),
      // appBar:_appBar(context),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: ListView.builder(
          itemCount: godowndata.length,
          itemBuilder: (context, index) {
            return GestureDetector(
              onTap: () {
                setState(() {
                  selectedIndex = index;
                });

                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const SelectProductsScreen()),
                );
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
/* 
  AppBar _appBar(BuildContext context) {
    return AppBar(
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
          icon: const Icon(
            Icons.home,
            color: Colors.white,
          ),
          onPressed: () { },
        ),
      ],
      flexibleSpace: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            stops: [1.0, 0.4],
            colors: [Color(0xFFDB5D4B), Color(0xFFE39A63)],
          ),
        ),
      ),
    );
  }
 */

  Future<void> _fetchGodowndata() async {
    final response = await http.get(Uri.parse(
        'http://182.18.157.215/3FAkshaya/API/api/Godown/GetActiveGodowns/AP'));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final List<dynamic> listResult = data['listResult'];

      setState(() {
        godowndata =
            listResult.map((json) => Godowndata.fromJson(json)).toList();
      });
    } else {
      // Handle error
      throw Exception('Failed to load locations');
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
          borderRadius: BorderRadius.circular(5.0),
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
                  Text(godown.name!, style: CommonStyles.txSty_14b_f5),
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
                  child: Text(label, style: CommonStyles.txSty_12b_f5)),
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
      ),
    );
  }
}
