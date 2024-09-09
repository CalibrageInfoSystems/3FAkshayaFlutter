import 'dart:convert';

import 'package:akshaya_flutter/common_utils/api_config.dart';
import 'package:akshaya_flutter/common_utils/common_styles.dart';
import 'package:akshaya_flutter/common_utils/custom_appbar.dart';
import 'package:akshaya_flutter/common_utils/custom_btn.dart';
import 'package:akshaya_flutter/common_utils/shared_prefs_keys.dart';
import 'package:akshaya_flutter/localization/locale_keys.dart';
import 'package:akshaya_flutter/models/collection_details_model.dart';
import 'package:akshaya_flutter/models/farmer_model.dart';
import 'package:akshaya_flutter/models/unpaid_collection_model.dart';
import 'package:digital_signature_flutter/digital_signature_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:animated_read_more_text/animated_read_more_text.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:shimmer/shimmer.dart';
import 'package:webview_flutter/webview_flutter.dart';

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

  Future<FarmerModel> getFarmerInfoFromSharedPrefs() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final result = prefs.getString(SharedPrefsKeys.farmerData);
    if (result != null) {
      Map<String, dynamic> response = json.decode(result);
      Map<String, dynamic> farmerResult =
          response['result']['farmerDetails'][0];
      return FarmerModel.fromJson(farmerResult);
    }
    return FarmerModel();
  }

//MARK: Submit Request
  Future<String> submitRequest(
      List<CollectionDetails> collections, String base64Signature) async {
    FarmerModel farmerData = await Future.value(getFarmerInfoFromSharedPrefs());
    String currentDate = DateFormat('yyyy-MM-dd').format(DateTime.now());

    final apiUrl = '$baseUrl$addQuickpayRequest';
    final requestBody = jsonEncode({
      "closingBalance": collections[0].dues,
      "clusterId": farmerData.clusterId,
      "collectionCodes": collectionCodes(widget.unpaidCollections),
      // "COL2024TAB205CCAPKLV074-2625(2.195 MT),COL2024TAB205CCAPKLV075-2650(1.13 MT)",
      "collectionIds": collectionIds(
          widget.unpaidCollections, await Future.value(collectionDetailsData)),
      // "COL2024TAB205CCAPKLV074-2625|2.195|2024-06-13T00:00:00|6000.0,COL2024TAB205CCAPKLV075-2650|1.13|2024-06-14T00:00:00|6000.0",
      "createdDate": currentDate,
      "districtId": farmerData.districtId,
      "districtName": farmerData.districtName,
      "farmerCode": farmerData.code,
      "farmerName": farmerData.firstName,
      "ffbCost": '${calculateDynamicSum(collections, 'quickPayCost')}',
      "fileLocation": "",
      "isFarmerRequest": true,
      "isSpecialPay": false,
      "netWeight": widget.unpaidCollections
          .fold(0.0, (sum, item) => sum + (item.quantity ?? 0.0)),
      "reqCreatedDate": currentDate,
      "signatureExtension": ".png",
      "signatureName": base64Signature,
      "stateCode": farmerData.stateCode,
      "stateName": farmerData.stateName,
      "updatedDate": currentDate,
      "whsCode": widget.unpaidCollections[0].whsCode
    });

    final jsonResponse = await http.post(
      Uri.parse(apiUrl),
      headers: {
        'Content-Type': 'application/json',
      },
      body: requestBody,
    );

    print('submitRequest: $apiUrl');
    print('submitRequest: $requestBody');

    if (jsonResponse.statusCode == 200) {
      final Map<String, dynamic> response = json.decode(jsonResponse.body);
      if (response['isSuccess']) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Request submitted successfully'),
          ),
        );
        print('result: ${response['result']}');
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
        CustomBtn(
          label: 'Confirm Request',
          onPressed: () {
            test();
          },
          // onPressed: processRequest,
        ),
      ],
    );
  }

  void test() {
    CommonStyles.customDialog(
        context,
        Container(
          width: 200,
          height: 200,
          color: Colors.blue,
          child: const Text('Test'),
        ));
  }

  //MARK: loadPdf
  Future<void> loadPdf() {
    return WebViewController().loadRequest(
      Uri.parse(
          'https://www.adobe.com/support/products/enterprise/knowledgecenter/media/c4611_sample_explain.pdf'),
      method: LoadRequestMethod.get,
      body: Uint8List.fromList('Test Body'.codeUnits),
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
                      collectionDetailsData.then(
                        (value) => submitRequest(value, base64Signature),
                      );
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

  String collectionCodes(List<UnpaidCollection> unpaidCollections) {
    // "COL2024TAB205CCAPKLV074-2625(2.195 MT),COL2024TAB205CCAPKLV075-2650(1.13 MT)",

    String collectionCodes = '';
    for (var collection in unpaidCollections) {
      collectionCodes += '${collection.uColnid!}(${collection.quantity} MT)';
      if (unpaidCollections.last != collection) {
        collectionCodes += ',';
      }
    }
    return collectionCodes;
  }

  String collectionIds(List<UnpaidCollection> unpaidCollections,
      List<CollectionDetails> collectionDetailsData) {
    // "COL2024TAB205CCAPKLV074-2625|2.195|2024-06-13T00:00:00|6000.0,COL2024TAB205CCAPKLV075-2650|1.13|2024-06-14T00:00:00|6000.0",
    List<CollectionDetails> collectionDetails = collectionDetailsData;
    String collectionIds = '';
    for (int i = 0; i < unpaidCollections.length; i++) {
      collectionIds +=
          '${unpaidCollections[i].uColnid!}|${unpaidCollections[i].quantity}|${unpaidCollections[i].docDate}|${collectionDetails[i].quickPayRate}';
      if (i != unpaidCollections.length - 1) {
        collectionIds += ',';
      }
    }
    return collectionIds;
  }

/*   String collectionIds(List<UnpaidCollection> unpaidCollections) {
    // "COL2024TAB205CCAPKLV074-2625|2.195|2024-06-13T00:00:00|6000.0,COL2024TAB205CCAPKLV075-2650|1.13|2024-06-14T00:00:00|6000.0",

    String collectionIds = '';
    for (var collection in unpaidCollections) {
      collectionIds += '${collection.uColnid!}|${collection.quantity}|${collection.docDate}|${collection.dueAmount},';
    }
    return collectionIds;
  } */
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