import 'dart:convert';

import 'package:akshaya_flutter/common_utils/api_config.dart';
import 'package:akshaya_flutter/common_utils/common_styles.dart';
import 'package:akshaya_flutter/common_utils/custom_appbar.dart';
import 'package:akshaya_flutter/common_utils/custom_btn.dart';
import 'package:akshaya_flutter/common_utils/shared_prefs_keys.dart';
import 'package:akshaya_flutter/localization/locale_keys.dart';
import 'package:akshaya_flutter/models/collection_details_model.dart';
import 'package:akshaya_flutter/models/unpaid_collection_model.dart';
import 'package:digital_signature_flutter/digital_signature_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:animated_read_more_text/animated_read_more_text.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:shimmer/shimmer.dart';

class QuickPayCollectionScreen extends StatefulWidget {
  final List<UnpaidCollection> unpaidCollections;
  const QuickPayCollectionScreen({super.key, required this.unpaidCollections});

  @override
  State<QuickPayCollectionScreen> createState() =>
      _QuickPayCollectionScreenState();
}

class _QuickPayCollectionScreenState extends State<QuickPayCollectionScreen> {
// {"districtId":5,"docDate":"2024-06-14T00:00:00","farmerCode":"APWGTPBG00060006","isSpecialPay":false,"quantity":2.45,"stateCode":"AP"}

  late Future<List<CollectionDetails>> collectionDetailsData;
  int? districtId;
  String? statecode;
  bool isChecked = false;

  SignatureController? controller;
  Uint8List? signature;

  @override
  void initState() {
    super.initState();
    controller = SignatureController(penStrokeWidth: 2, penColor: Colors.black);

    collectionDetailsData = getCollectionDetails();
  }

  Future<List<CollectionDetails>> getCollectionDetails() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int? districtId = prefs.getInt(SharedPrefsKeys.districtId);
    String? farmerCode = prefs.getString(SharedPrefsKeys.farmerCode);
    String? statecode = prefs.getString(SharedPrefsKeys.statecode);

    List<CollectionDetails> details = await Future.wait(
      widget.unpaidCollections.map(
        (item) async {
          var value = await getQuickPayDetails(
            districtId: districtId,
            docDate: item.docDate,
            farmerCode: farmerCode,
            isSpecialPay: false,
            quantity: item.quantity,
            stateCode: statecode,
          );
          return CollectionDetails(
              collectionId: item.uColnid,
              collectionQuantity: item.quantity,
              date: item.docDate,
              quickPayRate: value['ffbFlatCharge'],
              quickPayCost: value['ffbCost'],
              transactionFee: value['convenienceCharge'],
              dues: value['closingBalance'],
              quickPay: value['quickPay'],
              total: value['total']);
        },
      ).toList(),
    );

    return details;
  }

/*   Future<List<CollectionDetails>> getSharedPrefsData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    districtId = prefs.getInt(SharedPrefsKeys.districtId);
    statecode = prefs.getString(SharedPrefsKeys.statecode);
 
    widget.unpaidCollections.map(
      (item) async {
       return getQuickPayDetails(
                districtId: districtId,
                docDate: item.docDate,
                farmerCode: item.uColnid,
                isSpecialPay: false,
                quantity: item.quantity,
                stateCode: statecode)
            .then((value) {
          CollectionDetails(
              collectionId: item.uColnid,
              quantity: item.quantity,
              date: item.docDate,
              quickPayRate: value['ffbFlatCharge'],
              quickPayCost: value['ffbCost']);
        });
      },
    ).toList();
  }
 */
  Future<Map<String, dynamic>> getQuickPayDetails({
    required int? districtId,
    required String? docDate,
    required String? farmerCode,
    required bool? isSpecialPay,
    required double? quantity,
    required String? stateCode,
  }) async {
    final apiUrl = '$baseUrl$quickPayRequest';
    final requestBody = jsonEncode({
      "districtId": districtId,
      "docDate": docDate,
      "farmerCode": farmerCode,
      "isSpecialPay": isSpecialPay,
      "quantity": quantity,
      "stateCode": stateCode,
    });
    final jsonResponse = await http.post(
      Uri.parse(apiUrl),
      headers: {
        'Content-Type': 'application/json',
      },
      body: requestBody,
    );
    final response = jsonDecode(jsonResponse.body);
    return response['listResult'][0];
  }

  Future<String> submitRequest() async {
    final apiUrl = '$baseUrl$addQuickpayRequest';
    final requestBody = jsonEncode({
      "closingBalance": 0.0,
      "clusterId": 74,
      "collectionCodes":
          "COL2024TAB205CCAPKLV074-2625(2.195 MT),COL2024TAB205CCAPKLV075-2650(1.13 MT)",
      "collectionIds":
          "COL2024TAB205CCAPKLV074-2625|2.195|2024-06-13T00:00:00|6000.0,COL2024TAB205CCAPKLV075-2650|1.13|2024-06-14T00:00:00|6000.0",
      "createdDate": "2024-09-09",
      "districtId": 5,
      "districtName": "EAST GODAVARI",
      "farmerCode": "APWGCGKP00080096",
      "farmerName": "Sri lakshmi Burugupalli",
      "ffbCost": 6000.0,
      "fileLocation": "",
      "isFarmerRequest": true,
      "isSpecialPay": false,
      "netWeight": 3.3249999999999997,
      "reqCreatedDate": "2024-09-09",
      "signatureExtension": ".png",
      "signatureName":
          "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\nX5MIAAAAAElFTkSuQmCC\n",
      "stateCode": "AP",
      "stateName": "Andhra Pradesh",
      "updatedDate": "2024-09-09",
      "whsCode": "CCAPKLV"
    });

    final jsonResponse = await http.post(
      Uri.parse(apiUrl),
      headers: {
        'Content-Type': 'application/json',
      },
      body: requestBody,
    );

    if (jsonResponse.statusCode == 200) {
      final Map<String, dynamic> response = json.decode(jsonResponse.body);
      if (response['isSuccess']) {
        return response['result'];
      } else {
        throw Exception('Something went wrong: ${response['endUserMessage']}');
      }
    } else {
      throw Exception('Failed to load data: ${jsonResponse.statusCode}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: tr(LocaleKeys.quickPay)),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Collection Details',
                  style: CommonStyles.txSty_16p_f5),
              const SizedBox(height: 5),
              collectionDetails(),
              const SizedBox(height: 10),
              quickPayDetails(),
              const SizedBox(height: 10),
              termsAndConditions(),
            ],
          ),
        ),
      ),
    );
  }

  Widget quickPayDetails() {
    return FutureBuilder(
      future: collectionDetailsData,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return shimmerEffect();
        } else if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        } else if (!snapshot.hasData) {
          return const Text('No data');
        }

        final collections = snapshot.data as List<CollectionDetails>;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Quick Pay Details', style: CommonStyles.txSty_16p_f5),
            const SizedBox(height: 5),
            Column(
              children: [
                buildQuickPayRow(
                    label: 'QuickPay Cost (RS)',
                    data:
                        '${calculateDynamicSum(collections, 'quickPayCost')}'),
                buildQuickPayRow(
                    label: 'Transaction Fee (RS)',
                    data: '-${collections[0].transactionFee}'),
                buildQuickPayRow(
                    label: 'QuickPay Fee (RS)',
                    data: '-${calculateDynamicSum(collections, 'quickPay')}'),
                buildQuickPayRow(
                    label: 'Dues (RS)', data: '-${collections[0].dues}'),
                Container(
                  height: 0.5,
                  color: Colors.grey,
                ),
                buildQuickPayRow(
                    label: 'Total (RS)',
                    data: '${totalSum(collections)}',
                    // data: calculateDynamicSum(collections, 'total'),
                    color: CommonStyles.primaryTextColor),
                Container(
                  height: 0.5,
                  color: Colors.grey,
                ),
              ],
            ),
          ],
        );
      },
    );
  }

//  sumoftotalamounttopay = (totalFFBcost - totaltransactionfee - totalquickfee) - totalDueamount;
  double totalSum(List<CollectionDetails> collections) {
    return (calculateDynamicSum(collections, 'quickPayCost') -
            collections[0].transactionFee! -
            calculateDynamicSum(collections, 'quickPay')) -
        calculateDynamicSum(collections, 'dues');
  }

  Widget shimmerEffect() {
    return Shimmer.fromColors(
        baseColor: Colors.grey.shade300,
        highlightColor: Colors.grey.shade100,
        child: Container(
          height: 140,
          width: double.infinity,
          margin: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: Colors.grey.shade300,
            borderRadius: BorderRadius.circular(10.0),
          ),
        ));
  }

/*   String calculateDynamicSum(
      List<CollectionDetails> collections, String field) {
    return collections.fold(0.0, (sum, item) {
      var value = item.toJson()[field];
      return sum + (value ?? 0.0);
    }).toString();
  } */

  double calculateDynamicSum(
      List<CollectionDetails> collections, String field) {
    return collections.fold(0.0, (sum, item) {
      var value = item.toJson()[field];
      return sum + (value ?? 0.0);
    });
    // return double.parse(sum.toStringAsFixed(2));
  }

  Widget buildQuickPayRow(
      {required String label, required String? data, Color? color}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        children: [
          Expanded(
            flex: 6,
            child: Text(
              label,
              style: CommonStyles.txSty_14b_f5.copyWith(
                color: color,
              ),
            ),
          ),
          Expanded(
            flex: 1,
            child: Text(
              ':',
              style: CommonStyles.txSty_14b_f5.copyWith(
                color: color,
              ),
            ),
          ),
          Expanded(
            flex: 7,
            child: Text(
              '$data',
              style: CommonStyles.txSty_14b_f5.copyWith(
                color: color,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget collectionDetails() {
    final size = MediaQuery.of(context).size;
    return SizedBox(
      // color: Colors.lightGreenAccent,
      height: size.height * 0.28,
      child: FutureBuilder(
        future: collectionDetailsData,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return shimmerEffect();
          } else if (snapshot.hasError) {
            return Text('Error: ${snapshot.error}');
          } else if (!snapshot.hasData) {
            return const Text('No data');
          }

          final collections = snapshot.data as List<CollectionDetails>;

          return ListView.builder(
            itemCount: collections.length,
            shrinkWrap: true,
            itemBuilder: (context, index) {
              final collection = collections[index];
              return Container(
                padding: const EdgeInsets.all(10),
                margin: const EdgeInsets.only(bottom: 10),
                decoration: BoxDecoration(
                  color: index.isEven ? Colors.white : Colors.grey.shade300,
                  // color: Colors.lightGreenAccent,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Column(
                  children: [
                    buildQuickPayRow(
                        label: 'Collecton Id', data: collection.collectionId),
                    buildQuickPayRow(
                        label: 'Quantity (MT)',
                        data: collection.collectionQuantity.toString()),
                    buildQuickPayRow(
                        label: 'Date', data: formateDate(collection.date)),
                    buildQuickPayRow(
                        label: 'QuickPay Rate (RS)',
                        data: collection.quickPayRate.toString()),
                    buildQuickPayRow(
                        label: 'QuickPay Cost (RS)',
                        data: collection.quickPayCost.toString()),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  String? formateDate(String? formateDate) {
    if (formateDate != null) {
      return DateFormat('dd-MM-yyyy').format(DateTime.parse(formateDate));
    }
    return null;
  }

  Widget termsAndConditions() {
    return Column(
      children: [
        const Text('Terms & Conditions', style: CommonStyles.txSty_16p_fb),
        const SizedBox(height: 5),
        AnimatedReadMoreText(
          tr(LocaleKeys.loan_message),
          maxLines: 3,
          readMoreText: 'Read More',
          readLessText: 'Read Less',
          textStyle: CommonStyles.txSty_14b_f5,
          buttonTextStyle: CommonStyles.txSty_14p_f5,
        ),
        const SizedBox(height: 5),
        const Divider(),
        GestureDetector(
          onTap: () {
            isChecked = !isChecked;
          },
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Checkbox(
                value: isChecked,
                activeColor: CommonStyles.primaryTextColor,
                onChanged: (bool? value) {
                  setState(() {
                    isChecked = value ?? false;
                  });
                },
              ),
              const Text("I agree to the terms & conditions"),
            ],
          ),
        ),
        const SizedBox(height: 5),
        CustomBtn(label: 'Confirm Request', onPressed: processRequest),
      ],
    );
  }

  void processRequest() {
    if (isChecked) {
      showDigitalSignature();

      /* CommonStyles.errorDialog(
        context,
        errorIcon:
            const Icon(Icons.home, size: 30, color: CommonStyles.whiteColor),
        bodyBackgroundColor: CommonStyles.primaryColor,
        errorMessage: tr(LocaleKeys.qucick_success),
        errorMessageColor: CommonStyles.primaryTextColor,
      ); */
    } else {
      CommonStyles.errorDialog(
        context,
        errorMessage: tr(LocaleKeys.terms_agree),
      );
    }
  }

  void showDigitalSignature() {
    CommonStyles.customDialog(
      context,
      Container(
        height: 300,
        width: 300,
        padding: const EdgeInsets.all(10.0),
        color: Colors.white,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Digital Signature',
                    style: CommonStyles.txSty_16b_fb),
                GestureDetector(
                    onTap: () {
                      controller?.clear();
                    },
                    child:
                        const Text('Clear', style: CommonStyles.txSty_16p_fb)),
              ],
            ),
            Expanded(
              child: Signature(
                // width: 300,
                height: 200,
                backgroundColor: Colors.white,
                controller: controller!,
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                CustomBtn(
                  label: 'Ok',
                  onPressed: () async {
                    Uint8List? signatureBytes = await controller?.toPngBytes();
                    if (signatureBytes != null) {
                      String base64Signature = base64Encode(signatureBytes);
                      print('base64Signature:  $base64Signature');
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Please sign first.',
                          ),
                        ),
                      );
                    }
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}


/* 
 Signature(
              height: 200,
              width: 350,
              controller: controller!,
            ),
 */

/* CommonStyles.errorDialog(
                context,
                errorIcon: const Icon(Icons.home,
                    size: 30, color: CommonStyles.whiteColor),
                bodyBackgroundColor: CommonStyles.primaryColor,
                errorMessage: tr(LocaleKeys.qucick_success),
                errorMessageColor: CommonStyles.primaryTextColor,
              ); */