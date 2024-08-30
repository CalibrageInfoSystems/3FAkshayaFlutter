import 'dart:convert';

import 'package:akshaya_flutter/common_utils/SharedPreferencesHelper.dart';
import 'package:akshaya_flutter/common_utils/api_config.dart';
import 'package:akshaya_flutter/common_utils/shared_prefs_keys.dart';
import 'package:akshaya_flutter/models/FarmerInfo.dart';
import 'package:akshaya_flutter/screens/home_screen/screens/farmer_passbook_2.dart';

import 'package:http/http.dart' as http;


import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';


class FarmerPassbookScreen_1 extends StatefulWidget {
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
    //
    // final loadedData = await SharedPreferencesHelper.getCategories();
    // if (loadedData != null) {
    //   final farmerDetails = loadedData['result']['farmerDetails'];
    //   final loadedfarmercode = farmerDetails[0]['code'];
    //
    // }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Color(0xFFDB5D4B),
          title: Text("Farmer Passbook"),
          leading: IconButton(
            icon: Image.asset('assets/ic_left.png'),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ),
        body: Center(
          child: Card(
            //  color: Color(0x8D000000),
            //width: MediaQuery.of(context).size.width,
            //height: 450,
            child: Container(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height/1.8,
              color: Color(0x8D000000),
              child: Column(
                children: [
                  Align(
                    alignment: Alignment.topCenter,
                    child: Padding(
                      padding: const EdgeInsets.only(top: 16.0),
                      child: Image.asset('assets/ic_bank_white.png'),
                    ),
                  ),
                  Align(
                    alignment: Alignment.center,
                    child: Padding(
                      padding: const EdgeInsets.only(top: 12.0),
                      child: Text(
                        "Bank Details",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                          fontFamily: 'hind_semibold',
                        ),
                      ),
                    ),
                  ),
                  Container(
                    height: 2.0,
                    width: MediaQuery.of(context).size.width,
                    decoration: BoxDecoration(
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
                  Row(
                    children: [
                      Expanded(
                        flex: 4,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Padding(
                              padding: EdgeInsets.fromLTRB(20, 15, 12, 5),
                              child: Text(
                                "Account Holder Name",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                  fontFamily: 'hind_semibold',
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        flex: 1,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Padding(
                              padding: EdgeInsets.fromLTRB(0, 15, 0, 5),
                              child: Text(
                                ":",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  fontFamily: 'hind_semibold',
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        flex: 4,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Padding(
                              padding: EdgeInsets.fromLTRB(0, 20, 0, 5),
                              child: Text(
                                '${accountholdername ?? ''}',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  fontFamily: 'hind_semibold',
                                ),
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
                        flex: 4,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Padding(
                              padding: EdgeInsets.fromLTRB(20, 15, 12, 5),
                              child: Text(
                                "Account Number",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  fontFamily: 'hind_semibold',
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        flex: 1,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Padding(
                              padding: EdgeInsets.fromLTRB(0, 15, 0, 5),
                              child: Text(
                                ":",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  fontFamily: 'hind_semibold',
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        flex: 4,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Padding(
                              padding: EdgeInsets.fromLTRB(0, 15, 0, 5),
                              child: Text(
                                '${accountnum??''}',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  fontFamily: 'hind_semibold',
                                ),
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
                        flex: 4,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Padding(
                              padding: EdgeInsets.fromLTRB(20, 15, 12, 5),
                              child: Text(
                                "Bank Name",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                  fontFamily: 'hind_semibold',
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        flex: 1,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Padding(
                              padding: EdgeInsets.fromLTRB(0, 15, 0, 5),
                              child: Text(
                                ":",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  fontFamily: 'hind_semibold',
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        flex: 4,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Padding(
                              padding: EdgeInsets.fromLTRB(0, 15, 0, 5),
                              child: Text(
                                '${bankname??''}',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  fontFamily: 'hind_semibold',
                                ),
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
                        flex: 4,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Padding(
                              padding: EdgeInsets.fromLTRB(20, 15, 12, 5),
                              child: Text(
                                "Branch Name",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                  fontFamily: 'hind_semibold',
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        flex: 1,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Padding(
                              padding: EdgeInsets.fromLTRB(0, 15, 0, 5),
                              child: Text(
                                ":",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  fontFamily: 'hind_semibold',
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        flex: 4,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Padding(
                              padding: EdgeInsets.fromLTRB(0, 15, 0, 5),
                              child: Text(
                                '${branchname??''}',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  fontFamily: 'hind_semibold',
                                ),
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
                        flex: 4,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Padding(
                              padding: EdgeInsets.fromLTRB(20, 15, 12, 5),
                              child: Text(
                                "IFSC Code",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  fontFamily: 'hind_semibold',
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        flex: 1,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Padding(
                              padding: EdgeInsets.fromLTRB(0, 15, 0, 5),
                              child: Text(
                                ":",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  fontFamily: 'hind_semibold',
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        flex: 4,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Padding(
                              padding: EdgeInsets.fromLTRB(0, 15, 0, 5),
                              child: Text(
                                '${ifscode??''}',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  fontFamily: 'hind_semibold',
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  Align(
                    alignment: Alignment.bottomRight,
                    child: Padding(
                      padding: const EdgeInsets.only(right: 18.0, top: 10.0),
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Color(0xFFCCCCCC),
                              Color(0xFFFFFFFF),
                              Color(0xFFCCCCCC),
                            ],
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                          ),
                          borderRadius: BorderRadius.circular(10.0),
                          border: Border.all(
                            width: 2.0,
                            color: Color(0xFFe86100),
                          ),
                        ),
                        child: ElevatedButton(
                          onPressed: () {
                            print('Next');
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => farmer_passbook_2(accountHolderName: farmerinfolist[0].accountHolderName, accountNumber: farmerinfolist[0].accountNumber, bankName: farmerinfolist[0].bankName,
                                        branchName: farmerinfolist[0].branchName, district: farmerinfolist[0].district, farmerCode: farmerinfolist[0].farmerCode,
                                        guardianName: farmerinfolist[0].guardianName, ifscCode: farmerinfolist[0].ifscCode, mandal: farmerinfolist[0].mandal,
                                        state: farmerinfolist[0].state, village: farmerinfolist[0].village)));
                          },
                          child: Text(
                            'Next',
                            style: TextStyle(
                              color: Color(0xFFe86100),
                              fontSize: 16,
                              fontFamily: 'hind_semibold',
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                          ),
                        ),
                      ),
                    ),
                  )
                ],
              ),
            ),
          ),
        ));
  }

  Future<FarmerInfo?> farmerbankdetails(String fc) async {
    final url = Uri.parse(baseUrl + getbankdetails + "$fc");
    print('farmerpassbook >> $url');

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);
        print('response == $responseData');

        if (responseData['listResult'] != null) {
          final List<dynamic> appointmentsData = responseData['listResult'];
          List<FarmerInfo> paymentresponse = (responseData['listResult'] as List)
              .map((item) => FarmerInfo.fromJson(item))
              .toList();
          setState(() {
            FarmerInfo farmer_info =
                FarmerInfo.fromJson(responseData['listResult'][0]);
            accountholdername = farmer_info.accountHolderName;
            accountnum = farmer_info.accountNumber;
            bankname = farmer_info.bankName;
            branchname = farmer_info.branchName;
            ifscode = farmer_info.ifscCode;
            farmerinfolist =paymentresponse;
            print('>$accountholdername');
          });
          print('farmerdetails ${appointmentsData.length}');
        } else {
          print('Failed to show Farmer plot details list');
          setState(() {
            isLoading = false; // Set loading to false
          });
        }
      } else {
        throw Exception('Failed to show Farmer plot details list');
      }
    } catch (error) {
      throw Exception('Failed to connect to the API $error');
    }
  }
}
