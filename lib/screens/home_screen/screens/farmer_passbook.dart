import 'dart:convert';

import 'package:akshaya_flutter/common_utils/api_config.dart';
import 'package:akshaya_flutter/common_utils/common_styles.dart';
import 'package:akshaya_flutter/common_utils/custom_appbar.dart';
import 'package:akshaya_flutter/common_utils/custom_btn.dart';
import 'package:akshaya_flutter/common_utils/shared_prefs_keys.dart';
import 'package:akshaya_flutter/gen/assets.gen.dart';
import 'package:akshaya_flutter/localization/locale_keys.dart';
import 'package:akshaya_flutter/models/FarmerInfo.dart';
import 'package:akshaya_flutter/screens/home_screen/screens/farmer_passbook_infoscreen.dart';
import 'package:akshaya_flutter/Services/custom_product_card.dart';
import 'package:akshaya_flutter/test.dart';
import 'package:easy_localization/easy_localization.dart';

import 'package:http/http.dart' as http;

import 'package:flutter/material.dart';
// import 'package:flutter_custom_month_picker/flutter_custom_month_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FarmerPassbookScreen extends StatefulWidget {
  const FarmerPassbookScreen({super.key});

  @override
  State<FarmerPassbookScreen> createState() => _FarmerPassbookScreen();
}

class _FarmerPassbookScreen extends State<FarmerPassbookScreen> {
  String? accountholdername,
      accountnum,
      bankname,
      branchname,
      ifscode,
      farmercode;
  List<FarmerInfo> farmerinfolist = [];
  bool isLoading = true;

  @override
  void initState() {
    checkInternetConnection();
    getfarmercode();
    if (farmercode != null) {
      farmerbankdetails(farmercode!);
    }

    super.initState();
  }

  Future<void> checkInternetConnection() async {
    bool isConnected = await CommonStyles.checkInternetConnectivity();
    if (!isConnected) {
      return CommonStyles.errorDialog(context,
          errorMessage: 'Please check your internet connection.');
    }
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
          child: Container(
            width: size.width * 0.94,
            decoration: const BoxDecoration(
                color: Color(0x8D000000),
                borderRadius: BorderRadius.all(Radius.circular(8))),
            child: Column(
              mainAxisSize: MainAxisSize.min,
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
                Container(
                  height: 0.5,
                  margin: const EdgeInsets.symmetric(vertical: 2),
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Color(0xFFFF4500),
                        Color.fromARGB(255, 164, 114, 243),
                        Color(0xFFFF4500),
                      ],
                    ),
                  ),
                ),
                /*  CommonStyles.horizontalDivider(colors: [
                  const Color(0xFFFF4500),
                  const Color(0xFFA678EF),
                  const Color(0xFFFF4500),
                ]), */
                infoBox(
                    label: tr(LocaleKeys.bank_holder), data: accountholdername),
                infoBox(label: tr(LocaleKeys.account_no), data: accountnum),
                infoBox(label: tr(LocaleKeys.bank_name), data: bankname),
                infoBox(label: tr(LocaleKeys.branch_name), data: branchname),
                infoBox(label: tr(LocaleKeys.ifsc), data: ifscode),
                Padding(
                  padding: const EdgeInsets.all(15.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    // mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      /*   CustomBtn(
                        label: tr(LocaleKeys.App_version),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => TestScreen()),
                          );
                        },
                      ), */
                      CustomBtn(
                        label: tr(LocaleKeys.next),
                        btnTextColor: CommonStyles.primaryTextColor,
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => FarmerPassbookInfo(
                                accountHolderName:
                                    farmerinfolist[0].accountHolderName,
                                accountNumber: farmerinfolist[0].accountNumber,
                                bankName: farmerinfolist[0].bankName,
                                branchName: farmerinfolist[0].branchName,
                                district: farmerinfolist[0].district,
                                farmerCode: farmerinfolist[0].farmerCode,
                                guardianName: farmerinfolist[0].guardianName,
                                ifscCode: farmerinfolist[0].ifscCode,
                                mandal: farmerinfolist[0].mandal,
                                state: farmerinfolist[0].state,
                                village: farmerinfolist[0].village,
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Row infoBox({required String label, String? data}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 4,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(15, 15, 12, 5),
                child: Text(
                  label,
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
          flex: 5,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(0, 15, 0, 5),
                child: Text(
                  data ?? '',
                  style: CommonStyles.txStyF14CwFF6,
                ),
              ),
            ],
          ),
        ),
      ],
    );
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
