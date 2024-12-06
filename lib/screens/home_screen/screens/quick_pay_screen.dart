import 'dart:convert';

import 'package:akshaya_flutter/common_utils/api_config.dart';
import 'package:akshaya_flutter/common_utils/common_styles.dart';
import 'package:akshaya_flutter/common_utils/common_widgets.dart';
import 'package:akshaya_flutter/common_utils/custom_appbar.dart';
import 'package:akshaya_flutter/common_utils/custom_btn.dart';
import 'package:akshaya_flutter/common_utils/shared_prefs_keys.dart';
import 'package:akshaya_flutter/common_utils/shimmer.dart';
import 'package:akshaya_flutter/localization/locale_keys.dart';
import 'package:akshaya_flutter/models/unpaid_collection_model.dart';
import 'package:akshaya_flutter/screens/home_screen/screens/quick_pay_collection_screen.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

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

  @override
  void initState() {
    super.initState();
    futureUnpaidCollection = getUnpaidCollection();
  }

  Future<List<UnpaidCollection>> getUnpaidCollection() async {
    // http://182.18.157.215/3FAkshaya/API/api/Farmer/GetUnPayedCollectionsByFarmerCode/APWGNJAP00150015
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? farmerCode = prefs.getString(SharedPrefsKeys.farmerCode);

    final apiUrl = '$baseUrl$getUnPaidCollections$farmerCode';
    final jsonResponse = await http.get(Uri.parse(apiUrl));

    print('getUnpaidCollection: $apiUrl');

    if (jsonResponse.statusCode == 200) {
      final Map<String, dynamic> response = jsonDecode(jsonResponse.body);
      if (response['listResult'] != null && response['listResult'].isNotEmpty) {
        List<dynamic> result = response['listResult'];
        return checkHolidayForQuickPayRequest(
            stateCode: result[0]['stateCode'],
            districtId: result[0]['districtId'],
            result: result);
      } else {
        throw Exception(
          tr(LocaleKeys.no_unpaid_collections),
        );
      }
    } else {
      throw Exception('Failed to load data: ${jsonResponse.statusCode}');
    }
  }

  Future<List<UnpaidCollection>> checkHolidayForQuickPayRequest(
      {required String stateCode,
      required int districtId,
      required List<dynamic> result}) async {
    const apiUrl = '$baseUrl$isQuickPayBlockDate';
    if (stateCode != 'AP') {
      districtId = 0;
    }

    final docDate = DateFormat('yyyy-MM-dd').format(DateTime.now());

    final requestBody = jsonEncode({
      "districtId": districtId,
      "docDate": docDate,
      "isQuickPayBlocked": true,
      "stateCode": stateCode
    });

    final jsonResponse = await http.post(
      Uri.parse(apiUrl),
      headers: {
        'Content-Type': 'application/json',
      },
      body: requestBody,
    );

    print('checkHolidayForQuickPayRequest: $apiUrl');
    print('checkHolidayForQuickPayRequest: $requestBody');

    if (jsonResponse.statusCode == 200) {
      Map<String, dynamic> response = jsonDecode(jsonResponse.body);
      if (response['isSuccess']) {
        return result.map((item) => UnpaidCollection.fromJson(item)).toList();
      } else {
        showCustomDialog(context, response['endUserMessage']);
        return throw Exception('');
      }
    } else {
      throw Exception('Request failed with status: ${jsonResponse.statusCode}');
    }
  }

  void showCustomDialog(BuildContext context, String msg,
      {void Function()? onPressed, bool barrierDismissible = true}) {
    showGeneralDialog(
      context: context,
      barrierLabel: '',
      barrierDismissible: barrierDismissible,
      barrierColor: Colors.black54,
      transitionDuration: const Duration(milliseconds: 500),
      pageBuilder: (context, animation1, animation2) {
        return PopScope(
          canPop: false,
          child: Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(0.0),
              side: const BorderSide(
                  color: Color(0x8D000000),
                  width: 2.0), // Adding border to the dialog
            ),
            child: Container(
              color: CommonStyles.blackColor,
              padding: const EdgeInsets.all(0.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  // Header with "X" icon and "Error" text
                  Container(
                    padding: const EdgeInsets.all(10.0),
                    color: CommonStyles.RedColor,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.close, color: Colors.white),
                        const SizedBox(width: 12.0),
                        Text(tr(LocaleKeys.error),
                            style: CommonStyles.txStyF20CwFF6),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20.0),
                  // Message Text
                  Text(
                    msg,
                    textAlign: TextAlign.center,
                    style: CommonStyles.text16white,
                  ),
                  const SizedBox(height: 20.0),
                  // OK Button
                  Padding(
                    padding: const EdgeInsets.only(bottom: 10.0),
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius:
                            BorderRadius.circular(20.0), // Rounded corners
                        gradient: const LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Color(0xFFCCCCCC), // Start color (light gray)
                            Color(0xFFFFFFFF), // Center color (white)
                            Color(0xFFCCCCCC), // End color (light gray)
                          ],
                        ),
                        border: Border.all(
                          color: const Color(0xFFe86100), // Orange border color
                          width: 2.0,
                        ),
                      ),
                      child: SizedBox(
                        height: 30.0, // Set the desired height
                        child: ElevatedButton(
                          onPressed: onPressed ??
                              () {
                                Navigator.of(context).pop();
                                Navigator.of(context).pop();
                              },
                          style: ElevatedButton.styleFrom(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 35.0),
                            backgroundColor: Colors.transparent,
                            shadowColor: Colors.transparent,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20.0),
                            ),
                          ),
                          child: Text(
                            tr(LocaleKeys.ok),
                            style: CommonStyles.txStyF16CbFF6,
                          ),
                        ),
                      ),
                    ),
                  )
                ],
              ),
            ),
          ),
        );
      },
      transitionBuilder: (context, animation1, animation2, child) {
        return ScaleTransition(
          scale: Tween<double>(begin: 0.0, end: 1.0).animate(
            CurvedAnimation(
              parent: animation1,
              curve: Curves.easeOutBack, // Customize the animation curve here
            ),
          ),
          child: child,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CommonStyles.whiteColor,
      appBar: CustomAppBar(title: tr(LocaleKeys.quickPay)),
      body: Padding(
          padding: const EdgeInsets.all(12.0),
          child: FutureBuilder(
            future: futureUnpaidCollection,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return shimmerCard();
              } else if (snapshot.hasError) {
                return Center(
                  child: Text(
                    snapshot.error.toString().replaceFirst('Exception: ', ''),
                    textAlign: TextAlign.center,
                    style: CommonStyles.txStyF16CpFF6.copyWith(
                      fontSize: 20,
                    ),
                  ),
                );
              } else {
                final data = snapshot.data as List<UnpaidCollection>;
                return Column(
                  children: [
                    Expanded(
                      child: CommonWidgets.customSlideAnimation(
                        itemCount: data.length,
                        isSeparatorBuilder: true,
                        childBuilder: (index) {
                          return quickPayBox(index: index, data: data[index]);
                        },
                      ),

                      /* ListView.separated(
                        itemCount: data.length,
                        separatorBuilder: (context, index) {
                          return const SizedBox(height: 10);
                        },
                        itemBuilder: (context, index) {
                          return quickPayBox(index: index, data: data[index]);
                        },
                      ), */
                    ),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        CustomBtn(
                            label: tr(LocaleKeys.request_rise),
                            btnTextStyle: CommonStyles.txStyF14CpFF6,
                            onPressed: () {
                              setState(() {
                                CommonStyles.showHorizontalDotsLoadingDialog(
                                    context);
                              });
                              //    blockdate(data)
                              raiseRequest(data);
                            }),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: CommonStyles.noteColor,
                        border: Border.all(
                            color: CommonStyles.primaryTextColor, width: 0.5),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(tr(LocaleKeys.noteWithOutColon),
                              style: CommonStyles.txStyF14CpFF6),
                          const SizedBox(height: 5),
                          Text(tr(LocaleKeys.unpaid_note),
                              style: CommonStyles.txStyF14CbFF6),
                        ],
                      ),
                    )
                  ],
                );
              }
            },
          )),
    );
  }

  String extractException(String error) {
    return error.replaceAll('Exception: ', '');
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
        color: index.isEven
            ? CommonStyles.listEvenColor
            : CommonStyles.listOddColor,
        borderRadius: BorderRadius.circular(10.0),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      child: Column(
        children: [
          buildQuickPayRow(
              label: tr(LocaleKeys.collection_id),
              data: data.uColnid,
              datatextColor: CommonStyles.primaryTextColor),
          buildQuickPayRow(
            label: tr(LocaleKeys.net_weight),
            data: formatNetWeight(data.quantity),
            // data: data.quantity.toString(),
          ),
          buildQuickPayRow(
            label: tr(LocaleKeys.only_date),
            data: CommonStyles.formatDate(data.docDate),
          ),
          buildQuickPayRow(
            label: tr(LocaleKeys.cc),
            data: data.whsName,
          ),
        ],
      ),
    );
  }

  String? formatNetWeight(double? quantity) {
    if (quantity == null) {
      return quantity.toString();
    } else {
      return '${quantity.toStringAsFixed(3)} MT';
    }
  }

  String? formateDate(String? formateDate) {
    if (formateDate != null) {
      return DateFormat('dd-MM-yyyy').format(DateTime.parse(formateDate));
    }
    return null;
  }

  Widget buildQuickPayRow(
      {required String label,
      required String? data,
      Color? datatextColor = CommonStyles.dataTextColor}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Text(
              label,
              style: CommonStyles.txStyF14CbFF6.copyWith(fontSize: 14.1),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            flex: 8,
            child: Text(
              '$data',
              style: CommonStyles.txStyF14CbFF6
                  .copyWith(color: datatextColor, fontSize: 14.1),
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
    final jsonResponse = await http.get(Uri.parse(apiUrl));
    setState(() {
      CommonStyles.hideHorizontalDotsLoadingDialog(context);
    });
    print('raiseRequest: $apiUrl');
    print('raiseRequest: ${jsonResponse.body}');
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
