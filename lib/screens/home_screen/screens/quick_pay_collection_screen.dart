import 'dart:convert';
import 'dart:ui';

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

import '../../../common_utils/SuccessDialog2.dart';
import '../../../services/models/MsgModel.dart';
import 'package:image/image.dart' as img;

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
  double? sumoftotalamounttopay;
  @override
  void initState() {
    super.initState();
    controller = SignatureController(
        penStrokeWidth: 2,
        penColor: CommonStyles.blackColor,
        exportBackgroundColor: CommonStyles.whiteColor);

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
    const apiUrl = '$baseUrl$quickPayRequest';
    final requestBody = jsonEncode({
      "districtId": districtId,
      "docDate": docDate,
      "farmerCode": farmerCode,
      "isSpecialPay": isSpecialPay,
      "quantity": quantity,
      "stateCode": stateCode,
    });

    try {
      final jsonResponse = await http.post(
        Uri.parse(apiUrl),
        headers: {
          'Content-Type': 'application/json',
        },
        body: requestBody,
      );

      if (jsonResponse.statusCode == 200) {
        final response = jsonDecode(jsonResponse.body);

        // Check if listResult is null or empty
        if (response['listResult'] == null || response['listResult'].isEmpty) {
          _showErrorDialog(tr(LocaleKeys.ffbratenorthere));
          throw Exception(
              'One of your Collections does not have Quick Pay Rate');
        }

        return response['listResult'][0];
      } else {
        throw Exception(
            'Failed to fetch Quick Pay details. Status code: ${jsonResponse.statusCode}');
      }
    } catch (e) {
      print('Error: ${e.toString()}');
      throw Exception('');
    }
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
    // Assuming sumOfTotalAmountToPay is a calculated value
    double sumOfTotalAmountToPay =
        sumoftotalamounttopay!; // Define this function to calculate
    if (sumOfTotalAmountToPay > 0) {
      // Get farmer information from shared preferences
      FarmerModel farmerData =
          await Future.value(getFarmerInfoFromSharedPrefs());

      // Get current date
      String currentDate = DateFormat('yyyy-MM-dd').format(DateTime.now());

      // API URL
      const apiUrl = '$baseUrl$addQuickpayRequest';

      String districtName;
      int? districtIdd;
      String CCstateCode = widget.unpaidCollections[0].stateCode ?? '';
      String CCstateName = widget.unpaidCollections[0].stateName ?? '';
      if (CCstateCode == "AP") {
        districtIdd =
            widget.unpaidCollections[0].districtId ?? 0; // Handle null safely
        districtName = widget.unpaidCollections[0].districtName ??
            'null'; // Default if districtName is null
      } else {
        // Assign default values if CCstateCode is not "AP"
        districtIdd = 0; // Default value if not "AP"
        districtName = 'null'; // Default if not "AP"
      }

      final requestBody = jsonEncode({
        "closingBalance": collections.isNotEmpty ? collections[0].dues : 0.0,
        "clusterId": farmerData.clusterId ?? '',
        "collectionCodes": collectionCodes(widget.unpaidCollections),
        "collectionIds": collectionIds(widget.unpaidCollections,
            await Future.value(collectionDetailsData)),
        "createdDate": currentDate,
        "createdByUserId": null,
        "districtId": districtIdd,
        "districtName": districtName,
        "farmerCode": farmerData.code ?? '',
        "farmerName": farmerData.firstName ?? '',
        "ffbCost": '${calculateDynamicSum(collections, 'quickPayCost')}',
        "fileLocation": "",
        "isFarmerRequest": true,
        "isSpecialPay": false,
        "netWeight": widget.unpaidCollections
            .fold(0.0, (sum, item) => sum + (item.quantity ?? 0.0)),
        "reqCreatedDate": currentDate,
        "signatureExtension": ".png",
        "signatureName": base64Signature,
        "stateCode": widget.unpaidCollections[0].stateCode ?? '',
        "stateName": widget.unpaidCollections[0].stateName ?? '',
        "updatedDate": currentDate,
        "updatedByUserId": null,
        "whsCode": widget.unpaidCollections.isNotEmpty
            ? widget.unpaidCollections[0].whsCode
            : '',
      });

      // Make the API call
      final jsonResponse = await http.post(
        Uri.parse(apiUrl),
        headers: {
          'Content-Type': 'application/json',
        },
        body: requestBody,
      );

      Navigator.of(context).pop();
      print('submitRequest: $apiUrl');
      print('submitRequest: $requestBody');
      print('submitRequest: ${jsonResponse.body}');

      if (jsonResponse.statusCode == 200) {
        final Map<String, dynamic> response = json.decode(jsonResponse.body);
        if (response['isSuccess']) {
          showPdfDialog(context, response['result']);
          print('result: ${response['result']}');
          return response['result'];
        } else {
          _showErrorDialog(response['endUserMessage']);
          throw Exception(
              'Something went wrong: ${response['endUserMessage']}');
        }
      } else {
        throw Exception('Failed to load data: ${jsonResponse.statusCode}');
      }
    } else {
      _showErrorDialog(tr(LocaleKeys.enter_loan_amount));

      throw Exception('Total amount to pay must be greater than 0.');
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
              Text(tr(LocaleKeys.collectionsdetails),
                  style: CommonStyles.txSty_16p_f5),
              const SizedBox(height: 5),
              collectionDetails(),
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
          return Text(
            snapshot.error.toString(),
            style: CommonStyles.txStyF16CpFF6,
          );
        } else if (!snapshot.hasData) {
          return const Text('No data');
        }

        final collections = snapshot.data as List<CollectionDetails>;
        sumoftotalamounttopay = collections[0].total;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(tr(LocaleKeys.quickpay_details),
                style: CommonStyles.txSty_16p_f5),
            const SizedBox(height: 5),
            Column(
              children: [
                buildQuickPayRow(
                    label: tr(LocaleKeys.amount_of_FFB),
                    data:
                        '${calculateDynamicSum(collections, 'quickPayCost')}'),
                buildQuickPayRow(
                  label: tr(LocaleKeys.convenience_charge),
                  data: collections[0].transactionFee! < 0
                      ? '0.00'
                      : '-${collections[0].transactionFee}',
                ),
                buildQuickPayRow(
                    label: tr(LocaleKeys.quick_pay),
                    data: '-${calculateDynamicSum(collections, 'quickPay')}'),
                buildQuickPayRow(
                  label: tr(LocaleKeys.closingBal),
                  data: collections[0].dues! < 0
                      ? '0.00'
                      : '-${collections[0].dues}',
                ),
                Container(
                  height: 0.5,
                  color: Colors.grey,
                ),
                buildQuickPayRow(
                    label: tr(LocaleKeys.total_amt_pay),
                    data: '${collections[0].total}',
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 6,
            child: Text(
              label,
              style: CommonStyles.txStyF14CbFF6.copyWith(
                color: color,
              ),
            ),
          ),
          Expanded(
            flex: 1,
            child: Text(
              ':',
              style: CommonStyles.txStyF14CbFF6.copyWith(
                color: color,
              ),
            ),
          ),
          Expanded(
            flex: 7,
            child: Text(
              '$data',
              style: CommonStyles.txStyF14CbFF6.copyWith(
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
      height: size.height * 0.28,
      child: FutureBuilder(
        future: collectionDetailsData,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return shimmerEffect();
          } else if (snapshot.hasError) {
            return Text(
              snapshot.error.toString(),
              style: CommonStyles.txStyF16CpFF6,
            );
          } else if (!snapshot.hasData) {
            return const Center(child: Text('No Collection found'));
          }

          final collections = snapshot.data as List<CollectionDetails>;

          return ListView.builder(
            itemCount: collections.length,
            shrinkWrap: true,
            itemBuilder: (context, index) {
              final collection = collections[index];
              return Container(
                // padding: const EdgeInsets.all(10),
                margin: const EdgeInsets.only(bottom: 10),
                decoration: BoxDecoration(
                  color:
                      index.isEven ? Colors.white : CommonStyles.listOddColor,
                  // color: Colors.lightGreenAccent,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Column(
                  children: [
                    buildQuickPayRow(
                        label: tr(LocaleKeys.collection_Id),
                        data: collection.collectionId),
                    buildQuickPayRow(
                      label: tr(LocaleKeys.quantity_mt),
                      data: formatNetWeight(collection.collectionQuantity),
                    ),
                    buildQuickPayRow(
                        label: tr(LocaleKeys.date_label),
                        data: formateDate(collection.date)),
                    buildQuickPayRow(
                        label: tr(LocaleKeys.ffb_flot),
                        data: collection.quickPayRate.toString()),
                    buildQuickPayRow(
                        label: tr(LocaleKeys.amount_of_FFB),
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

  String? formatNetWeight(double? quantity) {
    if (quantity == null) {
      return quantity.toString();
    } else {
      return quantity.toStringAsFixed(3);
    }
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
        Text(tr(LocaleKeys.terms_conditionsss),
            style: CommonStyles.txSty_16p_fb),
        const SizedBox(height: 5),
        AnimatedReadMoreText(
          tr(LocaleKeys.loan_message),
          maxLines: 3,
          readMoreText: tr(LocaleKeys.read_more),
          readLessText: '  ',
          textStyle: CommonStyles.txStyF14CbFF6,
          buttonTextStyle: CommonStyles.txStyF14CpFF6,
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
              Text(
                tr(LocaleKeys.terms_conditionss),
                style: CommonStyles.txStyF14CpFF6,
              ),
            ],
          ),
        ),
        const SizedBox(height: 5),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CustomBtn(
              label: tr(LocaleKeys.confirm_req),
              onPressed: () {
                processRequest();
              },
            ),
          ],
        ),
        const SizedBox(height: 10),
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
    final size = MediaQuery.of(context).size;
    CommonStyles.customDialog(
      context,
      Container(
        width: size.width * 0.7,
        height: size.height * 0.4,
        padding: const EdgeInsets.all(10.0),
        color: Colors.white,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                RichText(
                  text: TextSpan(
                    text: tr(LocaleKeys.digital_signature),
                    style: CommonStyles.txStyF16CbFF6,
                    children: <TextSpan>[
                      TextSpan(
                        text: ' *',
                        style: CommonStyles.txStyF14CwFF6.copyWith(
                          color: CommonStyles.formFieldErrorBorderColor,
                        ),
                      ),
                    ],
                  ),
                ),
                GestureDetector(
                    onTap: () {
                      controller?.clear();
                    },
                    child: Text(tr(LocaleKeys.clear),
                        style: CommonStyles.txStyF14CbFF6)),
              ],
            ),
            Expanded(
              child: Signature(
                // width: 300,
                // height: 200,
                backgroundColor: Colors.white,
                controller: controller!,
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CustomBtn(
                  label: tr(LocaleKeys.ok),
                  onPressed: () async {
                    // Assuming controller?.toPngBytes() returns Uint8List of the signature
                    Uint8List? signatureBytes = await controller?.toPngBytes();

                    if (signatureBytes != null) {
                      // Use the bitMapToBase64 method to convert to Base64
                      String base64Signature = bitMapToBase64(signatureBytes);

                      // Assuming collectionDetailsData is a Future
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

                // CustomBtn(
                //   label: 'Ok',
                //   onPressed: () async {
                //     Navigator.of(context).pop();
                //     Uint8List? signatureBytes = await controller?.toPngBytes();
                //     if (signatureBytes != null) {
                //       String base64Signature = base64Encode(signatureBytes);
                //       collectionDetailsData.then(
                //         (value) => submitRequest(value, base64Signature),
                //       );
                //       print('base64Signature:  $base64Signature');
                //     } else {
                //       ScaffoldMessenger.of(context).showSnackBar(
                //         const SnackBar(
                //           content: Text(
                //             'Please sign first.',
                //           ),
                //         ),
                //       );
                //     }
                //   },
                // ),
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

  bool isDialog = true;
  void showPdfDialog(BuildContext context, String pdfUrl) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return PopScope(canPop: false, child: PdfViewerPopup(pdfUrl: pdfUrl));
      },
    );
  }

  void _showErrorDialog(String message) {
    Future.delayed(Duration.zero, () {
      showquickDialog(context, message);
    });
  }

  void showquickDialog(BuildContext context, String msg) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(0.0),
            side: const BorderSide(
              color: Color(0x8D000000),
              width: 2.0, // Adding border to the dialog
            ),
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
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.close, color: Colors.white),
                      Text('  Error', style: CommonStyles.txSty_20w_fb),
                      SizedBox(
                          width: 24.0), // Spacer to align text in the center
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
                        onPressed: () {
                          // Close the dialog and navigate to the previous screen
                          Navigator.of(context).pop(); // Closes the dialog
                          List<MsgModel> displayList = [];

                          // Show success dialog
                          showSuccessDialog(context, displayList,
                              tr(LocaleKeys.qucick_success));
                          Navigator.of(context)
                              .pop(); // Navigates to the previous screen
                        },
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 35.0),
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20.0),
                          ),
                        ),
                        child: const Text(
                          'OK',
                          style: CommonStyles.txSty_16b_fb,
                        ),
                      ),
                    ),
                  ),
                )
              ],
            ),
          ),
        );
      },
    );
  }

  void showSuccessDialog(
      BuildContext context, List<MsgModel> displayList, String tr) {}

  String bitMapToBase64(Uint8List imageData) {
    // Decode the image data
    img.Image? decodedImage = img.decodeImage(imageData);

    if (decodedImage == null) {
      throw Exception("Could not decode image data");
    }

    // Encode the image to PNG format without specifying quality
    List<int> pngData = img.encodePng(decodedImage); // No quality parameter

    // Convert to Base64
    return base64Encode(pngData);
  }
// Example of how to use the function
//   Future<String> convertImageToBase64(Image image) async {
//     // Convert Flutter Image widget to Uint8List
//     final byteData = await image.image.toByteData(format: ImageByteFormat.rawRgba);
//     final Uint8List imageData = byteData!.buffer.asUint8List();
//
//     return bitMapToBase64(imageData);
//   }

/*   String collectionIds(List<UnpaidCollection> unpaidCollections) {
    // "COL2024TAB205CCAPKLV074-2625|2.195|2024-06-13T00:00:00|6000.0,COL2024TAB205CCAPKLV075-2650|1.13|2024-06-14T00:00:00|6000.0",

    String collectionIds = '';
    for (var collection in unpaidCollections) {
      collectionIds += '${collection.uColnid!}|${collection.quantity}|${collection.docDate}|${collection.dueAmount},';
    }
    return collectionIds;
  } */
}

class PdfViewerPopup extends StatefulWidget {
  final String pdfUrl;

  const PdfViewerPopup({super.key, required this.pdfUrl});

  @override
  _PdfViewerPopupState createState() => _PdfViewerPopupState();
}

class _PdfViewerPopupState extends State<PdfViewerPopup> {
  bool isLoading = true;
  late final WebViewController _controller;

  bool _reloadPdf = false;

/*   @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageFinished: (String url) {
            setState(() {
              isLoading = false;
            });
          },
        ),
      )
      ..reload()
      ..loadRequest(Uri.parse(
          "https://docs.google.com/gview?embedded=true&url=${widget.pdfUrl}"));
  } */

  @override
/*************  ✨ Codeium Command ⭐  *************/
  /// Initialize the state of the widget.
  ///
  /// This method is called when the widget is inserted into the tree.
  ///
  /// It creates a [WebViewController] and sets its JavaScript mode to
  /// [JavaScriptMode.unrestricted] and its navigation delegate.
  ///
  /// The navigation delegate is used to handle page finished and web resource
  /// error events. When the page is finished, the [isLoading] flag is set to
  /// false. When a web resource error occurs, the page is reloaded.
  ///
  /// The page is loaded with the URL "https://docs.google.com/gview?embedded=true&url=<url>".
  ///
  /// The [isLoading] flag is used to show a loading indicator while the page is
  /// loading.
  ///
  /// The [_reloadPdf] flag is used to prevent infinite reloading of the page.
/******  163a2759-b024-4bd1-abf1-496403720b27  *******/
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageFinished: (String url) {
            setState(() {
              isLoading = false;
            });
          },
          onWebResourceError: (WebResourceError error) {
            if (!_reloadPdf) {
              _reloadPdf = true;
              _controller.loadRequest(Uri.parse(
                  "https://docs.google.com/gview?embedded=true&url=${widget.pdfUrl}"));
            }
          },
        ),
      )
      ..loadRequest(Uri.parse(
          "https://docs.google.com/gview?embedded=true&url=${widget.pdfUrl}"));
  }

  @override
  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(2.0),
      ),
      child: Container(
        height: MediaQuery.of(context).size.height * 0.7,
        color: const Color(0x8D000000), // Background color with transparency
        child: Column(
          children: <Widget>[
            // Header
            Container(
              padding: const EdgeInsets.all(8),
              color: CommonStyles.RedColor,
              width: double.infinity,
              child: const Center(
                child: Text(
                  'QuickPay Request PDF',
                  style: TextStyle(color: Colors.white, fontSize: 18),
                ),
              ),
            ),
            // WebView displaying PDF
            Expanded(
              child: Stack(
                children: [
                  WebViewWidget(controller: _controller),
                  if (isLoading)
                    const Center(child: CircularProgressIndicator()),
                ],
              ),
            ),
            // "OK" Button

            // Additional OK Button
            Padding(
              padding: const EdgeInsets.only(bottom: 10.0),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20.0), // Rounded corners
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
                    onPressed: () {
                      Navigator.of(context).pop();
                      showSuccessquikDialog(
                          context, tr(LocaleKeys.qucick_success));
                    },
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 35.0),
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20.0),
                      ),
                    ),
                    child: Text(
                      tr(LocaleKeys.ok),
                      style: CommonStyles.txStyF16CpFF6,
                    ),
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  void showSuccessquikDialog(BuildContext context, String summary) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return PopScope(canPop: false, child: SuccessDialog2(title: summary));
      },
    );
  }
}
