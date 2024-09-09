import 'dart:convert';

import 'package:akshaya_flutter/common_utils/api_config.dart';
import 'package:akshaya_flutter/common_utils/common_styles.dart';
import 'package:akshaya_flutter/common_utils/custom_appbar.dart';
import 'package:akshaya_flutter/common_utils/custom_btn.dart';
import 'package:akshaya_flutter/common_utils/shared_prefs_keys.dart';
import 'package:akshaya_flutter/common_utils/shimmer.dart';
import 'package:akshaya_flutter/localization/locale_keys.dart';
import 'package:akshaya_flutter/models/unpaid_collection_model.dart';
import 'package:akshaya_flutter/screens/home_screen/screens/quick_pay_collection_screen.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class QuickPayScreen extends StatefulWidget {
  const QuickPayScreen({super.key});

  @override
  State<QuickPayScreen> createState() => _QuickPayScreenState();
}

/* 
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? userId = prefs.getString(SharedPrefsKeys.farmerCode);
        */

class _QuickPayScreenState extends State<QuickPayScreen> {
  late Future<List<UnpaidCollection>> futureUnpaidCollection;

  Future<List<UnpaidCollection>> getUnpaidCollection() async {
    // http://182.18.157.215/3FAkshaya/API/api/Farmer/GetUnPayedCollectionsByFarmerCode/APWGNJAP00150015
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? farmerCode = prefs.getString(SharedPrefsKeys.farmerCode);

    final apiUrl = '$baseUrl$getUnPaidCollections$farmerCode';
    final jsonResponse = await http.get(Uri.parse(apiUrl));
    print('apiUrl: $apiUrl');
    print('apiUrl: ${jsonResponse.body}');

    if (jsonResponse.statusCode == 200) {
      final Map<String, dynamic> response = jsonDecode(jsonResponse.body);
      if (response['listResult'] != null) {
        List<dynamic> result = response['listResult'];
        return result.map((item) => UnpaidCollection.fromJson(item)).toList();
      } else {
        throw Exception('No data found');
      }
    } else {
      throw Exception('Failed to load data: ${jsonResponse.statusCode}');
    }
  }

  @override
  void initState() {
    super.initState();
    futureUnpaidCollection = getUnpaidCollection();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: tr(LocaleKeys.quickPay)),
      body: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            children: [
              Expanded(
                child: FutureBuilder(
                  future: futureUnpaidCollection,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return shimmerCard();
                    } else if (snapshot.hasError) {
                      return Text('Error: ${snapshot.error}');
                    } else {
                      final data = snapshot.data as List<UnpaidCollection>;
                      return ListView.separated(
                        itemCount: data.length,
                        separatorBuilder: (context, index) {
                          return const SizedBox(height: 10);
                        },
                        itemBuilder: (context, index) {
                          return quickPayBox(index: index, data: data[index]);
                        },
                      );
                    }
                  },
                ),
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  CustomBtn(
                      label: 'Raise Request',
                      onPressed: () {
                        setState(() {
                          CommonStyles.showHorizontalDotsLoadingDialog(context);
                        });
                        futureUnpaidCollection.then(
                          (value) {
                            raiseRequest(value);
                          },
                        );
                      }),
                ],
              ),
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: Colors.greenAccent,
                ),
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Note', style: CommonStyles.txSty_14p_f5),
                    SizedBox(height: 5),
                    Text(
                        'Collections can take upto 2 hours to show. if Any Collections are missed, Please Contact Customer Care',
                        style: CommonStyles.txSty_12b_f5),
                  ],
                ),
              )
            ],
          )),
    );
  }

  Widget shimmerCard() {
    return ShimmerWid(
      child: Container(
        height: 130,
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.grey,
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  Container quickPayBox({required int index, required UnpaidCollection data}) {
    return Container(
      decoration: BoxDecoration(
        color: index % 2 == 0 ? Colors.white : Colors.grey.shade400,
        borderRadius: BorderRadius.circular(10.0),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      child: Column(
        children: [
          buildQuickPayRow(
              label: 'Collection ID',
              data: data.uColnid,
              datatextColor: CommonStyles.primaryTextColor),
          buildQuickPayRow(
            label: 'Net Weight',
            data: data.quantity.toString(),
          ),
          buildQuickPayRow(
            label: 'Date',
            data: formateDate(data.docDate),
          ),
          buildQuickPayRow(
            label: 'CC',
            data: data.whsName,
          ),
        ],
      ),
    );
  }

  String? formateDate(String? formateDate) {
    if (formateDate != null) {
      return DateFormat('dd-MM-yyyy').format(DateTime.parse(formateDate));
    }
    return null;
  }

  Widget buildQuickPayRow(
      {required String label, required String? data, Color? datatextColor}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Text(
              label,
              style: CommonStyles.txSty_12b_f5,
            ),
          ),
          const SizedBox(width: 20),
          Expanded(
            flex: 7,
            child: Text(
              '$data',
              style: CommonStyles.txSty_12b_f5.copyWith(
                color: datatextColor ?? Colors.grey,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> raiseRequest(List<UnpaidCollection> data) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? farmerCode = prefs.getString(SharedPrefsKeys.farmerCode);
    final apiUrl = '$baseUrl$raiseCollectionRequest$farmerCode/null/13';
    print('apiUrl: y $apiUrl');
    final jsonResponse = await http.get(Uri.parse(apiUrl));
    print('apiUrl: y ${jsonResponse.body}');
    setState(() {
      CommonStyles.hideHorizontalDotsLoadingDialog(context);
    });
    if (jsonResponse.statusCode == 200) {
      final Map<String, dynamic> response = jsonDecode(jsonResponse.body);
      if (response['isSuccess']) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => QuickPayCollectionScreen(
              unpaidCollections: data,
            ),
          ),
        );
      } else {
        CommonStyles.errorDialog(
          context,
          errorMessage: tr(LocaleKeys.quick_reqc),
        );
      }
    } else {
      throw Exception('Failed to load data: ${jsonResponse.statusCode}');
    }
  }
}