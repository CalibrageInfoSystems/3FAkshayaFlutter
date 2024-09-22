import 'dart:convert';

import 'package:akshaya_flutter/common_utils/api_config.dart';
import 'package:akshaya_flutter/common_utils/common_styles.dart';
import 'package:akshaya_flutter/common_utils/custom_appbar.dart';
import 'package:akshaya_flutter/common_utils/custom_btn.dart';
import 'package:akshaya_flutter/common_utils/shared_prefs_keys.dart';
import 'package:akshaya_flutter/localization/locale_keys.dart';
import 'package:akshaya_flutter/models/farmer_model.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../../../Services/models/MsgModel.dart';
import '../../../common_utils/SuccessDialog.dart';

class LoanRequestScreen extends StatefulWidget {
  final int clusterId;
  const LoanRequestScreen({super.key, required this.clusterId});

  @override
  State<LoanRequestScreen> createState() => _LoanRequestScreenState();
}

class _LoanRequestScreenState extends State<LoanRequestScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _loanAmountController = TextEditingController();
  final TextEditingController _reasonController = TextEditingController();
  bool _isAgree = false;

  @override
  void dispose() {
    _loanAmountController.dispose();
    _reasonController.dispose();
    super.dispose();
  }

  void submitForm() {
    FocusScope.of(context).unfocus();
    if (_loanAmountController.text.isEmpty) {
      CommonStyles.errorDialog(context,
          errorMessage: tr(LocaleKeys.str_enter_loan_amount));
    } else if (!_isAgree) {
      CommonStyles.errorDialog(context,
          errorMessage: tr(LocaleKeys.terms_agree));
    } else {
      loanRequestSubmit();
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

  Future<bool> loanRequestSubmit() async {
    const apiUrl = '$baseUrl$loanRequest';
    FarmerModel farmer = await getFarmerInfoFromSharedPrefs();
    final currentDate = DateFormat('yyyy-MM-dd').format(DateTime.now());
    final requestBody = jsonEncode({
      "clusterId": widget.clusterId,
      "comments": _reasonController.text,
      "createdDate": currentDate,
      "farmerCode": farmer.code,
      "farmerName": farmer.firstName,
      "isFarmerRequest": true,
      "requestCreatedDate": currentDate,
      "requestTypeId": 28,
      "stateCode": farmer.stateCode,
      "stateName": farmer.stateName,
      "statusTypeId": 15,
      "totalCost": _loanAmountController.text,
      "updatedDate": currentDate,
      "id": null,
      "requestCode": null,
      "plotCode": null,
      "reqCreatedDate": null,
      "createdByUserId": null,
      "updatedByUserId": null,
      "totalCostWithoutServiceCharge": null,
      "serviceChargeAmount": null,
      "parentRequestCode": null,
      "recoveryFarmerCode": null,
      "serverUpdatedStatus": null,
      "yearofPlanting": null,
    });

    print('loanRequestSubmit: $apiUrl');
    print('loanRequestSubmit: $requestBody');

    final jsonResponse = await http.post(
      Uri.parse(apiUrl),
      headers: {
        'Content-Type': 'application/json',
      },
      body: requestBody,
    );
    if (jsonResponse.statusCode == 200) {
      final response = jsonDecode(jsonResponse.body);
      List<MsgModel> displayList = [
        MsgModel(
            key: tr(LocaleKeys.loan_amount), value: _loanAmountController.text),
        MsgModel(
            key: tr(LocaleKeys.reason_loan), value: _reasonController.text),
      ];

      // Show success dialog
      showSuccessDialog(context, displayList, tr(LocaleKeys.success_Loan));
      // showSuccessDialog();
      print('loanRequestSubmit: ${response["isSuccess"]}');
      return response['isSuccess'] as bool;
    } else {
      throw Exception('Failed to load data');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CommonStyles.whiteColor,
      appBar: CustomAppBar(
        title: tr(LocaleKeys.req_loan),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: Form(
            key: _formKey,
            child: Container(
              padding: const EdgeInsets.all(12.0),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10.0),
                color: const Color(0xff6f6f6f),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  RichText(
                    text: TextSpan(
                      text: tr(LocaleKeys.loan_amount),
                      style: CommonStyles.txStyF14CwFF6,
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
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _loanAmountController,
                    style: CommonStyles.text14white,
                    decoration: InputDecoration(
                      hintText: tr(LocaleKeys.loan_amount),
                      hintStyle: CommonStyles.txStyF14CwFF6,
                      border: outlineInputBorder(),
                      enabledBorder: outlineInputBorder(),
                      focusedBorder: outlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 20),
                  Text(
                    tr(LocaleKeys.reason_loan),
                    style: CommonStyles.txStyF14CwFF6,
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _reasonController,
                    style: CommonStyles.text14white,
                    decoration: InputDecoration(
                      hintText: tr(LocaleKeys.reason_loan),
                      hintStyle: CommonStyles.txStyF14CwFF6,
                      border: outlineInputBorder(),
                      enabledBorder: outlineInputBorder(),
                      focusedBorder: outlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 5),
                  Row(
                    children: [
                      Checkbox(
                        value: _isAgree,
                        activeColor: CommonStyles.primaryTextColor,
                        onChanged: (bool? value) {
                          setState(() {
                            _isAgree = value!;
                            if (_isAgree) {
                              showTermsAndConditionsPopup();
                            }
                          });
                        },
                      ),
                      RichText(
                        text: TextSpan(
                          text: tr(LocaleKeys.i_have_agree),
                          style: CommonStyles.txStyF14CwFF6,
                          children: <TextSpan>[
                            TextSpan(
                              text: ' ${tr(LocaleKeys.terms_conditionsss)}',
                              style: CommonStyles.txStyF14CpFF6.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: CommonStyles.primaryTextColor2),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CustomBtn(
                        label: 'Submit Request',
                        onPressed: submitForm,
                        height: 50,
                        borderRadius: 16,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void showTermsAndConditionsPopup() {
    final Size size = MediaQuery.of(context).size;
    CommonStyles.customDialog(
      context,
      Container(
        width: size.width * 0.8,
        height: size.height * 0.5,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                color: CommonStyles.primaryTextColor,
                padding: const EdgeInsets.all(12),
                alignment: Alignment.center,
                child: Text(
                  tr(LocaleKeys.terms_conditionss),
                  style: CommonStyles.txStyF14CwFF6,
                ),
              ),
              Container(
                // height: size.height * 0.5,
                padding: const EdgeInsets.all(12),
                color: CommonStyles.whiteColor,
                alignment: Alignment.center,
                child: SingleChildScrollView(
                  child: Text(tr(LocaleKeys.loan_terms),
                      style: CommonStyles.txSty_14b_f5),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CustomBtn(
                        label: 'Got it',
                        onPressed: () => Navigator.pop(context)),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  OutlineInputBorder outlineInputBorder() {
    return const OutlineInputBorder(
      borderRadius: BorderRadius.all(Radius.circular(10)),
      borderSide: BorderSide(color: Colors.white),
    );
  }

// Function to show the dialog
  void showSuccessDialog(
      BuildContext context, List<MsgModel> msg, String summary) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return SuccessDialog(msg: msg, summary: summary);
      },
    );
  }
}
