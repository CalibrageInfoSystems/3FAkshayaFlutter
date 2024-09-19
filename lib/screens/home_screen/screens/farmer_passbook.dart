import 'dart:convert';

import 'package:akshaya_flutter/common_utils/api_config.dart';
import 'package:akshaya_flutter/common_utils/common_styles.dart';
import 'package:akshaya_flutter/common_utils/custom_appbar.dart';
import 'package:akshaya_flutter/common_utils/custom_btn.dart';
import 'package:akshaya_flutter/common_utils/shared_prefs_keys.dart';
import 'package:akshaya_flutter/gen/assets.gen.dart';
import 'package:akshaya_flutter/localization/locale_keys.dart';
import 'package:akshaya_flutter/models/FarmerInfo.dart';
import 'package:akshaya_flutter/screens/home_screen/screens/farmer_passbook_2.dart';
import 'package:easy_localization/easy_localization.dart';

import 'package:http/http.dart' as http;

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../main_screen.dart';

class FarmerPassbookScreen_1 extends StatefulWidget {
  const FarmerPassbookScreen_1({super.key});

  @override
  _farmerpassbook createState() => _farmerpassbook();
}

class _farmerpassbook extends State<FarmerPassbookScreen_1> {
  String? accountholdername,
      accountnum,
      bankname,
      branchname,
      ifscode,
      farmercode;
  List<FarmerInfo> farmerinfolist = [];
  bool isLoading = true;
  late Future<FarmerInfo> _future;

  @override
  void initState() {
    getfarmercode();
    if (farmercode != null) {
      farmerbankdetails(farmercode!);
    }

    super.initState();
  }

  getfarmercode() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final farmerCode = prefs.getString(SharedPrefsKeys.farmerCode);
    setState(() {
      farmercode = farmerCode;
      print('fcinfarmerpassbook$farmercode');
      farmerbankdetails(farmercode!);
    });
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
        appBar: CustomAppBar(
          title: tr(LocaleKeys.payments),
        ),
        body: Center(
          child: Card(
            child: IntrinsicHeight(
                child: Container(
              width: size.width * 0.9,
              decoration: const BoxDecoration(
                  color: Color(0x8D000000),
                  borderRadius: BorderRadius.all(Radius.circular(8))),
              child: Column(
                children: [
                  const SizedBox(
                    height: 10,
                  ),
                  Image.asset(
                    Assets.images.icBankWhite.path,
                    height: 75,
                    width: 75,
                  ),
                  Align(
                    alignment: Alignment.center,
                    child: Padding(
                      padding: const EdgeInsets.only(top: 4.0),
                      child: Text(
                        tr(LocaleKeys.bank_details),
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                          fontFamily: 'hind_semibold',
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 5),
                  Container(
                    height: 1.0,
                    width: MediaQuery.of(context).size.width,
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Color(0xFFFF4500),
                          Color(0xFFA678EF),
                          Color(0xFFFF4500),
                        ],
                        end: Alignment.topRight,
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 8,
                  ),
                  Row(
                    children: [
                      Expanded(
                        flex: 3,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.fromLTRB(20, 15, 12, 5),
                              child: Text(
                                tr(LocaleKeys.bank_holder),
                                style: CommonStyles.txStyF14CwFF6,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Expanded(
                        flex: 1,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Padding(
                              padding: EdgeInsets.fromLTRB(0, 15, 0, 5),
                              child: Text(
                                ":",
                                style: CommonStyles.txStyF14CwFF6,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        flex: 3,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.fromLTRB(0, 20, 0, 5),
                              child: Text(
                                accountholdername ?? '',
                                style: CommonStyles.txStyF14CwFF6,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Expanded(
                        flex: 3,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.fromLTRB(20, 15, 12, 5),
                              child: Text(
                                tr(LocaleKeys.account_no),
                                style: CommonStyles.txStyF14CwFF6,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Expanded(
                        flex: 1,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Padding(
                              padding: EdgeInsets.fromLTRB(0, 15, 0, 5),
                              child: Text(
                                ":",
                                style: CommonStyles.txStyF14CwFF6,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        flex: 3,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.fromLTRB(0, 15, 0, 5),
                              child: Text(
                                accountnum ?? '',
                                style: CommonStyles.txStyF14CwFF6,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Expanded(
                        flex: 3,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.fromLTRB(20, 15, 12, 5),
                              child: Text(
                                tr(LocaleKeys.bank_name),
                                style: CommonStyles.txStyF14CwFF6,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Expanded(
                        flex: 1,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Padding(
                              padding: EdgeInsets.fromLTRB(0, 15, 0, 5),
                              child: Text(
                                ":",
                                style: CommonStyles.txStyF14CwFF6,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        flex: 3,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.fromLTRB(0, 15, 0, 5),
                              child: Text(
                                bankname ?? '',
                                style: CommonStyles.txStyF14CwFF6,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Expanded(
                        flex: 3,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.fromLTRB(20, 15, 12, 5),
                              child: Text(
                                tr(LocaleKeys.branch_name),
                                style: CommonStyles.txStyF14CwFF6,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Expanded(
                        flex: 1,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Padding(
                              padding: EdgeInsets.fromLTRB(0, 15, 0, 5),
                              child: Text(
                                ":",
                                style: CommonStyles.txStyF14CwFF6,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        flex: 3,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.fromLTRB(0, 15, 0, 5),
                              child: Text(
                                branchname ?? '',
                                style: CommonStyles.txStyF14CwFF6,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Expanded(
                        flex: 3,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.fromLTRB(20, 15, 12, 5),
                              child: Text(
                                tr(LocaleKeys.ifsc),
                                style: CommonStyles.txStyF14CwFF6,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Expanded(
                        flex: 1,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Padding(
                              padding: EdgeInsets.fromLTRB(0, 15, 0, 5),
                              child: Text(
                                ":",
                                style: CommonStyles.txStyF14CwFF6,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        flex: 3,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.fromLTRB(0, 15, 0, 5),
                              child: Text(
                                ifscode ?? '',
                                style: CommonStyles.txStyF14CwFF6,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.all(15.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        CustomBtn(
                          label: tr(LocaleKeys.next),
                          onPressed: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => farmer_passbook_2(
                                        accountHolderName:
                                            farmerinfolist[0].accountHolderName,
                                        accountNumber:
                                            farmerinfolist[0].accountNumber,
                                        bankName: farmerinfolist[0].bankName,
                                        branchName:
                                            farmerinfolist[0].branchName,
                                        district: farmerinfolist[0].district,
                                        farmerCode:
                                            farmerinfolist[0].farmerCode,
                                        guardianName:
                                            farmerinfolist[0].guardianName,
                                        ifscCode: farmerinfolist[0].ifscCode,
                                        mandal: farmerinfolist[0].mandal,
                                        state: farmerinfolist[0].state,
                                        village: farmerinfolist[0].village)));
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            )),
          ),
        ));
  }

  Future<FarmerInfo?> farmerbankdetails(String fc) async {
    final url = Uri.parse("$baseUrl$getbankdetails$fc");
    print('farmerpassbook >> $url');

    setState(() {
      CommonStyles.showHorizontalDotsLoadingDialog(context);
    });

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);
        print('response == $responseData');

        if (responseData['listResult'] != null) {
          final List<dynamic> appointmentsData = responseData['listResult'];
          List<FarmerInfo> paymentresponse =
              (responseData['listResult'] as List)
                  .map((item) => FarmerInfo.fromJson(item))
                  .toList();
          setState(() {
            FarmerInfo farmerInfo =
                FarmerInfo.fromJson(responseData['listResult'][0]);
            accountholdername = farmerInfo.accountHolderName;
            accountnum = farmerInfo.accountNumber;
            bankname = farmerInfo.bankName;
            branchname = farmerInfo.branchName;
            ifscode = farmerInfo.ifscCode;
            farmerinfolist = paymentresponse;
            print('>$accountholdername');
            CommonStyles.hideHorizontalDotsLoadingDialog(context);
          });
          print('farmerdetails ${appointmentsData.length}');
        } else {
          print('Failed to show Farmer plot details list');
          setState(() {
            CommonStyles.hideHorizontalDotsLoadingDialog(context);

            isLoading = false; // Set loading to false
          });
        }
      } else {
        CommonStyles.hideHorizontalDotsLoadingDialog(context);

        throw Exception('Failed to show Farmer plot details list');
      }
    } catch (error) {
      CommonStyles.hideHorizontalDotsLoadingDialog(context);

      throw Exception('Failed to connect to the API $error');
    }
    return null;
  }
}
