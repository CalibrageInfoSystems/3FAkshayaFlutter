import 'dart:convert';

import 'package:akshaya_flutter/Services/models/catogery_item_model.dart';
import 'package:akshaya_flutter/Services/select_products_screen.dart';
import 'package:akshaya_flutter/common_utils/common_styles.dart';
import 'package:akshaya_flutter/common_utils/custom_appbar.dart';
import 'package:akshaya_flutter/common_utils/custom_btn.dart';
import 'package:akshaya_flutter/localization/locale_keys.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../common_utils/api_config.dart';
import '../common_utils/shared_prefs_keys.dart';
import '../models/farmer_model.dart';
import '../screens/home_screen/home_screen.dart';
import 'models/RequestProductDetails.dart';
import 'models/SubsidyResponse.dart';

class ProductCardScreen extends StatefulWidget {
  final List<ProductWithQuantity> products;
  final String godownCode;
  final int godownid;
  const ProductCardScreen({super.key, required this.products, required this.godownCode,required this.godownid});

  @override
  State<ProductCardScreen> createState() => _ProductCardScreenState();
}

class _ProductCardScreenState extends State<ProductCardScreen> {
  int? selectedDropDownValue = -1;
 late double subsidyAmount = 0.0;
  late double payableAmount = 0.0;
  late Future<FarmerModel> farmerData;
  late String farmerCode,farmerName,Statecode,StateName;
    late int  Cluster_id;
  bool _isCheckboxChecked = false;
  int _selectedPaymentType = -1;
  late int  paymentmodeId = 0;
  // Initial value to indicate no selection
  @override
  void initState() {
    super.initState();
    farmerData = getFarmerInfoFromSharedPrefs();
    print('godownCode==${widget.godownCode}');
    print('godownid==${widget.godownid}');
    farmerData.then((farmer) {
      print('farmerData==${farmer.code}');
      farmerCode = '${farmer.code}';
      farmerName =  '${farmer.firstName} ${farmer.middleName ?? ''} ${farmer.lastName}';
      Cluster_id = farmer.clusterId!;
      Statecode = '${farmer.stateCode}';
      StateName = '${farmer.stateName}';


    });

  }

  Future<List<dynamic>> getDropdownData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final farmerCode = prefs.getString(SharedPrefsKeys.farmerCode);
    final apiUrl = '$baseUrl$GetPaymentsTypeByFarmerCode$farmerCode';
    print('GetPaymentsTypeByFarmerCode==$apiUrl');
   // const apiUrl = 'http://182.18.157.215/3FAkshaya/API/api/Farmer/GetPaymentsTypeByFarmerCode/APWGBDAB00010005';

    final jsonResponse = await http.get(Uri.parse(apiUrl));

    if (jsonResponse.statusCode == 200) {
      final response = jsonDecode(jsonResponse.body);
      if (response['listResult'] != null) {
        return response['listResult'] as List<dynamic>;
      } else {
        throw Exception('listResult is empty');
      }
    } else {
      throw Exception('Failed to load data');
    }
  }

  @override
  Widget build(BuildContext context) {
    double totalProductCostGst = 0.0;
    double totalCGST = 0.0;
    double totalSGST = 0.0;
    double totalTransportCostwithgst = 0.0;
    double totalAmountWithGST = 0.0;
    double amountWithoutGst = 0.0;
    double totalGST = 0.0;
    double TransportamountWithoutGst = 0.0;
    double totalTransportGST = 0.0;
    double totalTransCGST = 0.0;
    double totalTrasSGST = 0.0;

    List<RequestProductDetails> productDetailsList = [];

    for (var productWithQuantity in widget.products) {
      if (productWithQuantity.quantity > 0) {
        final product = productWithQuantity.product;
        final quantity = productWithQuantity.quantity;

        final productCost = product.actualPriceInclGst! * quantity;
        totalProductCostGst += productCost;

        final transportCost = product.transPortActualPriceInclGst! * quantity;
        totalTransportCostwithgst += transportCost;

        // Calculate product amount without GST
        final productGSTPercentage = product.gstPercentage!;
        amountWithoutGst += productCost / (1 + (productGSTPercentage / 100));

        // Calculate total GST for products
        totalGST = totalProductCostGst - amountWithoutGst;
        totalCGST = totalGST / 2;
        totalSGST = totalGST / 2;

        // Calculate transport amount without GST
        final transportGSTPercentage = product.transportGstPercentage!;
        TransportamountWithoutGst += transportCost / (1 + (transportGSTPercentage / 100));

        // Calculate total GST for transport
        totalTransportGST = totalTransportCostwithgst - TransportamountWithoutGst;
        totalTransCGST = totalTransportGST / 2;
        totalTrasSGST = totalTransportGST / 2;

        // Add product details to the list
        productDetailsList.add(
          RequestProductDetails(
            productId: product.id!,
            quantity: quantity,
            bagCost: product.actualPriceInclGst!,
            size: product.size!,
            gstPersentage: product.gstPercentage!,
            productCode: product.code!,
            transGstPercentage: product.size!,
            transportCost: product.transPortActualPriceInclGst!,
          ),
        );
      }
    }

    // Calculate total amount with GST
    totalAmountWithGST = totalProductCostGst + totalTransportCostwithgst;

    getFertilizerSubsidies(totalAmountWithGST);

    return Scaffold(
      appBar: CustomAppBar(
        title: tr(LocaleKeys.product_req),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child:
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(tr(LocaleKeys.payment_mode), style: CommonStyles.txSty_16black_f5),
                  SizedBox(width: 5),
                  Text('*', style: TextStyle(color: Colors.red)),
                ],
              ),
              const SizedBox(height: 5),
              dropdownWidget(),

              // Conditionally display the checkbox
              if (paymentmodeId == 26)
                Row(
                  children: [
                    Checkbox(
                      value: _isCheckboxChecked,
                      onChanged: (bool? value) {
                        setState(() {
                          _isCheckboxChecked = value ?? false;
                        });
                      },
                    ),
                    Text(tr(LocaleKeys.imdpayment), style: CommonStyles.txSty_16black_f5),
                  ],
                ),
              const SizedBox(height: 10),

              Text(tr(LocaleKeys.product_details), style: CommonStyles.txSty_16black_f5),
              const SizedBox(height: 5),
              Column(
                children: [
                  ListView.builder(
                    itemCount: widget.products.length,
                    physics: const NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    itemBuilder: (context, index) {
                      return widget.products[index].quantity == 0
                          ? const SizedBox()
                          : productBox(widget.products[index]);
                    },
                  ),
                  const SizedBox(height: 20),
                  CommonStyles.horizontalGradientDivider(colors: [
                    const Color(0xFFFF4500),
                    const Color(0xFFA678EF),
                    const Color(0xFFFF4500),
                  ]),
                  noteBox(),
                  productCostbox(title: tr(LocaleKeys.amount), data: amountWithoutGst.toStringAsFixed(2)),
                  productCostbox(title: tr(LocaleKeys.cgst_amount), data: totalCGST.toStringAsFixed(2)),
                  productCostbox(title: tr(LocaleKeys.sgst_amount), data: totalSGST.toStringAsFixed(2)),
                  productCostbox(title: tr(LocaleKeys.total_amt), data: totalProductCostGst.toStringAsFixed(2)),
                  productCostbox(title: tr(LocaleKeys.transamount), data: TransportamountWithoutGst.toStringAsFixed(2)),
                  productCostbox(title: tr(LocaleKeys.tcgst_amount), data: totalTrasSGST.toStringAsFixed(2)),
                  productCostbox(title: tr(LocaleKeys.tsgst_amount), data: totalTrasSGST.toStringAsFixed(2)),
                  productCostbox(title: tr(LocaleKeys.trnstotal_amt), data: totalTransportCostwithgst.toStringAsFixed(2)),
                  productCostbox(title: tr(LocaleKeys.subsidy_amt), data: subsidyAmount.toStringAsFixed(2)),
                  productCostbox(title: tr(LocaleKeys.amount_payble), data: payableAmount.toStringAsFixed(2)),
                  CommonStyles.horizontalGradientDivider(colors: [
                    const Color(0xFFFF4500),
                    const Color(0xFFA678EF),
                    const Color(0xFFFF4500),
                  ]),
                  CustomBtn(
                    label: 'Submit',
                    borderColor: CommonStyles.primaryTextColor,
                    borderRadius: 12,
                    onPressed: () {
                      final request = FertilizerRequest(
                        id: 0,
                        requestTypeId: 12,
                        farmerCode: farmerCode,
                        farmerName: farmerName,
                        plotCode: null,
                        requestCreatedDate: DateTime.now().toIso8601String(),
                        isFarmerRequest: true,
                        createdByUserId: null,
                        createdDate: DateTime.now().toIso8601String(),
                        updatedByUserId: null,
                        updatedDate: DateTime.now().toIso8601String(),
                        godownId: widget.godownid!,
                        paymentModeType: paymentmodeId, // Use the selected payment mode type
                        isImmediatePayment: true,
                        fileName: null,
                        fileLocation:null,
                        fileExtension: null,
                        totalCost: totalAmountWithGST,
                        subcidyAmount: subsidyAmount,
                        paybleAmount: payableAmount,
                        transportPayableAmount: totalTransportCostwithgst,
                        comments: null,
                        cropMaintainceDate:null,
                        issueTypeId: null,
                        godownCode: '${widget.godownCode}',
                        requestProductDetails: productDetailsList, // Pass the dynamic product details
                        clusterId: Cluster_id,
                        stateCode: Statecode,
                        stateName: StateName
                      );
                      print('CHECK BOX VALUE: $_isCheckboxChecked');
                     submitFertilizerRequest(request);
                      // After successfully submitting the fertilizer request


                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }


  Widget productCostbox({
    required String title,
    required String data,
  }) {
    return Column(
      children: [
        CommonStyles.horizontalGradientDivider(colors: [
          const Color(0xFFFF4500),
          const Color(0xFFA678EF),
          const Color(0xFFFF4500),
        ]),
        Row(
          children: [
            Expanded(
                flex: 6,
                child: Text(
                  title,
                  style: CommonStyles.txSty_14p_f5,
                )),
            const Expanded(
                flex: 1,
                child: Text(
                  ':',
                  style: CommonStyles.txSty_14p_f5,
                )),
            Expanded(
                flex: 5,
                child: Text(
                  data,
                  style: CommonStyles.txSty_14p_f5,
                )),
          ],
        ),
      ],
    );
  }

  Container noteBox() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: const Color(0xfffefacb),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Note',
            style: CommonStyles.text18orangeeader,
          ),
          Text(
            'If the products has not been picked with in 5 days of requested date, Your order will be cancelled.',
            style: CommonStyles.txSty_14b_f5,
          ),
        ],
      ),
    );
  }


  Container dropdownWidget() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey),
      ),
      clipBehavior: Clip.antiAlias,
      child: FutureBuilder(
        future: getDropdownData(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            final paymentModes = snapshot.data as List<dynamic>;
            return filterDropDown(paymentModes);
          } else if (snapshot.hasError) {
            return Text('${tr(LocaleKeys.error)}: ${snapshot.error}');
          }
          return Container(
            padding: const EdgeInsets.all(10),
            child: const Center(child: Text('loading...')),
          );
        },
      ),
    );
  }

  Widget filterDropDown(List<dynamic> paymentModes) {
    return DropdownButtonHideUnderline(
      child: ButtonTheme(
        alignedDropdown: true,
        child: DropdownButton2<int>(
          isExpanded: true,
          items: [
            const DropdownMenuItem<int>(
              value: -1,
              child: Text(
                'Select',
                style: CommonStyles.txSty_14b_f6,
                textAlign: TextAlign.center,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            ...paymentModes.asMap().entries.map((entry) {
              final index = entry.key;
              final item = entry.value;
              return DropdownMenuItem<int>(
                value: index,
                child: Text(
                  item['desc'],
                  style: CommonStyles.txSty_14b_f6,
                  textAlign: TextAlign.center,
                  overflow: TextOverflow.ellipsis,
                ),
              );
            }),
          ].toList(),
          value: _selectedPaymentType,
          onChanged: (value) {
            setState(() {
              _selectedPaymentType = value!;
              if (_selectedPaymentType != -1) {
                 paymentmodeId = paymentModes[_selectedPaymentType]['typeCdId'];
                final paymentmodeName = paymentModes[_selectedPaymentType]['desc'];

                print('setState paymentmodeId: $paymentmodeId');


                // Adjust the condition for showing the checkbox based on the payment mode ID
                _isCheckboxChecked = false; // Reset the checkbox when changing payment mode
              }
            });
          },
          buttonStyleData: const ButtonStyleData(
            height: 45,
            width: double.infinity,
            padding: EdgeInsets.only(left: 14, right: 14),
          ),
          iconStyleData: const IconStyleData(
            icon: Icon(
              Icons.arrow_drop_down_sharp,
            ),
            iconSize: 24,
            iconEnabledColor: Color(0xFF11528f),
            iconDisabledColor: Color(0xFF11528f),
          ),
          dropdownStyleData: DropdownStyleData(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              color: Colors.grey,
            ),
            offset: const Offset(0, 0),
            scrollbarTheme: ScrollbarThemeData(
              radius: const Radius.circular(40),
              thickness: WidgetStateProperty.all<double>(6),
              thumbVisibility: WidgetStateProperty.all<bool>(true),
            ),
          ),
          menuItemStyleData: const MenuItemStyleData(
            height: 40,
            padding: EdgeInsets.only(left: 20, right: 20),
          ),
        ),
      ),
    );
  }


  Widget productBox(ProductWithQuantity productinfo) {
    final product = productinfo.product;
    final quantity = productinfo.quantity;
    final productQuantity = product.actualPriceInclGst! * quantity;
    final totalTrasport = product.transPortActualPriceInclGst! * quantity;
    final totalAmount = productQuantity + totalTrasport!;
    return Container(
      padding: const EdgeInsets.all(5),
      margin: const EdgeInsets.only(bottom: 5),
      decoration: BoxDecoration(
        // color: Colors.white,
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFFCCCCCC),
            Color(0xFFFFFFFF),
            Color(0xFFCCCCCC),
          ],
        ),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey.shade400),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
           Row(
            children: [
              Expanded(
                child: Text(tr(LocaleKeys.product), style: CommonStyles.txSty_14b_f5),
              ),
              SizedBox(width: 10),
              Expanded(
                child: Text('${product.name}', style: CommonStyles.txSty_14p_f5),
              ),
            ],
          ),
          productInfo(
            label1: 'Item Cost(Rs)',
            data1: '${product.actualPriceInclGst}',
            label2: 'GST(%)',
            data2: '${product.gstPercentage}',
          ),
          productInfo(
            label1: 'Quantity',
            data1: '$quantity',
            label2: 'Amount(Rs)',
            data2: '$productQuantity',
          ),
          productInfo(
            label1: 'Trasport Cost(Rs)',
            data1: '${product.transPortActualPriceInclGst}',
            label2: 'GST(%)',
            data2: '${product.transportGstPercentage}',
          ),
          productInfo(
            label1: 'Total Transport\nAmount (Rs)',
            data1: '$totalTrasport',
            label2: 'Total Amount',
            data2: '$totalAmount',
          ),
        ],
      ),
    );
  }
  Column productInfo({
    required String label1,
    required String data1,
    required String label2,
    required String data2,
  }) {
    return Column(
      children: [
        CommonStyles.horizontalGradientDivider(),
        Row(
          children: [
            Expanded(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Flexible(
                    flex: 4, // Adjust the flex value as needed for the label
                    child: Text(label1, style: CommonStyles.txSty_12b_f5),
                  ),
                  const SizedBox(width: 3), // Optional spacing between label and data
                  Expanded(
                    flex: 2, // Adjust the flex value as needed for the data
                    child: Text(data1, style: CommonStyles.txSty_12b_f5),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 5),
            Expanded(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Flexible(
                    flex: 4, // Adjust the flex value as needed for the label
                    child: Text(label2, style: CommonStyles.txSty_12b_f5),
                  ),
                  const SizedBox(width: 3), // Optional spacing between label and data
                  Expanded(
                    flex: 2, // Adjust the flex value as needed for the data
                    child: Text(data2, style: CommonStyles.txSty_12b_f5),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Future<void> getFertilizerSubsidies(double totalProductCostGst) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final farmerCode = prefs.getString(SharedPrefsKeys.farmerCode);
    final url = 'http://182.18.157.215/3FAkshaya/API/api/FertilizerSubsidies/$farmerCode';

    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        final SubsidyResponse subsidyResponse = SubsidyResponse.fromJson(data);

        if (subsidyResponse.isSuccess) {
          setState(() {
            subsidyAmount = subsidyResponse.result.remainingAmount;

            if (subsidyAmount > 0) {
              if (totalProductCostGst < subsidyAmount) {
                payableAmount = 0.0;
                subsidyAmount = totalProductCostGst;
              } else if (subsidyAmount < totalProductCostGst) {
                payableAmount = totalProductCostGst - subsidyAmount;
              } else {
                payableAmount = totalProductCostGst;
              }
            } else {
              subsidyAmount = 0.0;
              payableAmount = totalProductCostGst;
            }

            print("Subsidy Amount: $subsidyAmount");
            print("Payable Amount: $payableAmount");
          });
        }
      } else {
        print("Failed to load data");
      }
    } catch (e) {
      print("Error: $e");
    }
  }
  Future<void> submitFertilizerRequest(FertilizerRequest request) async {
    const url = 'http://182.18.157.215/3FAkshaya/API/api/FertilizerRequest';

    // Print the request object
    print('Submitting request:');
    print('Request Object: ${jsonEncode(request.toJson())}');

    final response = await http.post(
      Uri.parse(url),
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode(request.toJson()),
    );

    // Print the encoded JSON body
    print('Request JSON: ${jsonEncode(request.toJson())}');

    if (response.statusCode == 200) {
      // Successfully submitted request
      print('Request submitted successfully');
      // Print the response body
      print('Response Body: ${response.body}');
      List<MsgModel> displayList = [
        MsgModel(key: 'Godown', value: 'Yernagudem'),
        MsgModel(key: 'Product & Quantity', value: 'Urea : 2'),
        MsgModel(key: 'Amount (Rs)', value: '507.62'),
        // Add more items as required
      ];

      // Show the success dialog
      showSuccessDialog(context, displayList, 'Fertilizer Request Submitted Successfully');
    } else {
      // Handle error
      print('Failed to submit request: ${response.statusCode}');
      // Print the error response body
      print('Error Response: ${response.body}');
    }
  }

  Future<FarmerModel> getFarmerInfoFromSharedPrefs() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final result = prefs.getString(SharedPrefsKeys.farmerData);
    if (result != null) {}
    Map<String, dynamic> response = json.decode(result!);
    Map<String, dynamic> farmerResult = response['result']['farmerDetails'][0];
    return FarmerModel.fromJson(farmerResult);
  }

// Function to show the dialog
  void showSuccessDialog(BuildContext context, List<MsgModel> msg, String summary) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return SuccessDialog(msg: msg, summary: summary);
      },
    );
  }




}

class SuccessDialog extends StatelessWidget {
  final List<MsgModel> msg;
  final String summary;

  SuccessDialog({required this.msg, required this.summary});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20.0),
      ),
      child: Container(
        padding: EdgeInsets.all(20.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Summary Text
            Text(
              summary,
              style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold, color: Colors.orange),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 20.0),

            // List of messages
            ListView.builder(
              shrinkWrap: true,
              itemCount: msg.length,
              itemBuilder: (context, index) {
                return Row(
                  children: [
                    Expanded(
                      flex: 1,
                      child: Text(
                        msg[index].key,
                        style: TextStyle(color: Colors.red),
                      ),
                    ),
                    Expanded(
                      flex: 1,
                      child: Padding(
                        padding: const EdgeInsets.only(left: 10.0),
                        child: Text(
                          msg[index].value,
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
            SizedBox(height: 20.0),

            // OK Button
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();  // Dismiss the dialog
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => HomeScreen()), // Replace with your Home Screen
                      (Route<dynamic> route) => false,
                );
              },
              child: Text('OK'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange, // Button color
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Model to represent key-value pairs for the dialog
class MsgModel {
  final String key;
  final String value;

  MsgModel({required this.key, required this.value});
}
