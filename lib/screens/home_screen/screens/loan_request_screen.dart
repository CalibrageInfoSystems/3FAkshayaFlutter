import 'dart:convert';

import 'package:akshaya_flutter/common_utils/api_config.dart';
import 'package:akshaya_flutter/common_utils/common_styles.dart';
import 'package:akshaya_flutter/common_utils/custom_appbar.dart';
import 'package:akshaya_flutter/common_utils/custom_btn.dart';
import 'package:akshaya_flutter/common_utils/shared_prefs_keys.dart';
import 'package:akshaya_flutter/gen/assets.gen.dart';
import 'package:akshaya_flutter/localization/locale_keys.dart';
import 'package:akshaya_flutter/models/farmer_model.dart';
import 'package:akshaya_flutter/screens/main_screen.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../../../Services/models/MsgModel.dart';

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

  void submitForm() async {
    bool isConnected = await CommonStyles.checkInternetConnectivity();
    if (isConnected) {
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
    } else {
      return CommonStyles.errorDialog(context,
          errorMessage: tr(LocaleKeys.Internet));
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

    final jsonResponse = await http.post(
      Uri.parse(apiUrl),
      headers: {
        'Content-Type': 'application/json',
      },
      body: requestBody,
    );

    print('loanRequestSubmit: $apiUrl');
    print('loanRequestSubmit: $requestBody');
    print('loanRequestSubmit: ${jsonResponse.body}');
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
                    style: CommonStyles.txStyF14CwFF6,
                    maxLength: 10,
                    decoration: InputDecoration(
                      counterText: '',
                      hintText: tr(LocaleKeys.loan_amount),
                      hintStyle: CommonStyles.txStyF14CwFF6,
                      border: outlineInputBorder(),
                      enabledBorder: outlineInputBorder(),
                      focusedBorder: outlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                    ],
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
                    maxLength: 250,
                    decoration: InputDecoration(
                      counterText: '',
                      hintText: tr(LocaleKeys.reason_loan),
                      hintStyle: CommonStyles.txStyF14CwFF6,
                      border: outlineInputBorder(),
                      enabledBorder: outlineInputBorder(),
                      focusedBorder: outlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      SizedBox(
                        width: 22,
                        height: 22,
                        child: Checkbox(
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
                      ),
                      const SizedBox(width: 5),
                      Flexible(
                        child: RichText(
                          text: TextSpan(
                            children: <TextSpan>[
                              TextSpan(
                                text: tr(LocaleKeys.i_have_agree),
                                style: CommonStyles.txStyF14CwFF6,
                              ),
                              TextSpan(
                                text: ' ${tr(LocaleKeys.terms_conditionsss)}',
                                style: CommonStyles.txStyF14CpFF6.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: CommonStyles.primaryTextColor),
                              ),
                            ],
                          ),
                          softWrap: true,
                          overflow: TextOverflow.visible,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CustomBtn(
                        label: tr(LocaleKeys.submit_req),
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
        height: size.height * 0.65,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              color: CommonStyles.primaryTextColor,
              padding: const EdgeInsets.all(12),
              alignment: Alignment.center,
              child: Text(
                tr(LocaleKeys.terms_conditionss),
                style: CommonStyles.txStyF16CwFF6,
              ),
            ),
            Expanded(
              child: Container(
                // height: size.height * 0.5,
                padding: const EdgeInsets.symmetric(horizontal: 12)
                    .copyWith(top: 12),
                color: Colors.transparent,
                alignment: Alignment.center,
                child: SingleChildScrollView(
                  child: Text(tr(LocaleKeys.loan_terms),
                      style: CommonStyles.txSty_14b_f5),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CustomBtn(
                      label: tr(LocaleKeys.got_it),
                      borderRadius: 20,
                      onPressed: () => Navigator.pop(context)),
                ],
              ),
            )
          ],
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

  void showSuccessDialog(
      BuildContext context, List<MsgModel> msg, String title) {
    CommonStyles.errorDialog(context,
        errorMessage: 'errorMessage',
        barrierDismissible: false,
        errorIcon: SvgPicture.asset(
          Assets.images.progressComplete.path,
          color: Colors.white,
        ),
        bodyBackgroundColor: Colors.white,
        errorLabel: 'errorLabel',
        borderColor: Colors.transparent,
        errorHeaderColor: CommonStyles.primaryTextColor,
        errorMessageColor: Colors.orange, onPressed: () {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const MainScreen()),
        (Route<dynamic> route) => false,
      );
    },
        errorBodyWidget: Container(
          child: Column(
            children: [
              Text(
                title,
                style: CommonStyles.txStyF16CpFF6.copyWith(
                  fontSize: 17,
                ),
              ),
              const SizedBox(height: 20.0),
              ...msg.map((msg) {
                return msg.value.isNotEmpty
                    ? Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              flex: 1,
                              child: Text(
                                msg.key,
                                style: CommonStyles.txStyF14CrFF6.copyWith(
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                            ),
                            const SizedBox(width: 20),
                            Expanded(
                              flex: 1,
                              child: Text(
                                msg.value,
                                style: CommonStyles.txStyF14CrFF6.copyWith(
                                  fontWeight: FontWeight.w500,
                                  color: CommonStyles.dataTextColor,
                                ),
                              ),
                            ),
                          ],
                        ),
                      )
                    : const SizedBox();
              }),
            ],
          ),
        ));
  }
}
