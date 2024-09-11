import 'dart:convert';

import 'package:akshaya_flutter/common_utils/api_config.dart';
import 'package:akshaya_flutter/common_utils/common_styles.dart';
import 'package:akshaya_flutter/common_utils/custom_appbar.dart';
import 'package:akshaya_flutter/common_utils/custom_btn.dart';
import 'package:akshaya_flutter/common_utils/shared_prefs_keys.dart';
import 'package:akshaya_flutter/gen/assets.gen.dart';
import 'package:akshaya_flutter/localization/locale_keys.dart';
import 'package:akshaya_flutter/models/farmer_model.dart';
import 'package:akshaya_flutter/screens/home_screen/home_screen.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

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
      /*  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Please enter Loan Amount.'),
      )); */
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
      showSuccessDialog();
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
                      style: CommonStyles.txSty_16w_fb,
                      children: const <TextSpan>[
                        TextSpan(
                          text: ' *',
                          style: TextStyle(color: Colors.red),
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
                      hintStyle: const TextStyle(color: Colors.white),
                      border: outlineInputBorder(),
                      enabledBorder: outlineInputBorder(),
                      focusedBorder: outlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 20),
                  Text(
                    tr(LocaleKeys.reason_loan),
                    style: CommonStyles.txSty_16w_fb,
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _reasonController,
                    style: CommonStyles.text14white,
                    decoration: InputDecoration(
                      hintText: tr(LocaleKeys.reason_loan),
                      hintStyle: const TextStyle(color: Colors.white),
                      border: outlineInputBorder(),
                      enabledBorder: outlineInputBorder(),
                      focusedBorder: outlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 10),
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
                          text: 'I Agree ',
                          style: const TextStyle(color: Colors.white),
                          children: <TextSpan>[
                            TextSpan(
                              text: tr(LocaleKeys.terms_conditionsss),
                              style: const TextStyle(
                                  color: CommonStyles.primaryTextColor),
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
                style: CommonStyles.txSty_16w_fb,
              ),
            ),
            Container(
              height: size.height * 0.5,
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
                      label: 'Got it', onPressed: () => Navigator.pop(context)),
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

  void showSuccessDialog() {
    CommonStyles.errorDialog(
      context,
      errorMessage: 'errorMessage',
      errorIcon: SvgPicture.asset(Assets.images.progressComplete.path),
      bodyBackgroundColor: Colors.white,
      errorLabel: 'errorLabel',
      errorMessageColor: Colors.orange,
      onPressed: () {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => const HomeScreen(),
          ),
        );
      },
      errorBodyWidget: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(tr(LocaleKeys.success_Loan), style: CommonStyles.txSty_14p_f5),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Expanded(
                flex: 6,
                child: Text(tr(LocaleKeys.loan_amount),
                    style: CommonStyles.txSty_14b_f5),
              ),
              const Expanded(
                  flex: 1, child: Text(':', style: CommonStyles.txSty_14b_f5)),
              Expanded(
                flex: 5,
                child: Text(_loanAmountController.text,
                    style: CommonStyles.txSty_14b_f5),
              ),
            ],
          ),
          const SizedBox(
            height: 10,
          ),
          _reasonController.text.isNotEmpty
              ? Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Expanded(
                      flex: 6,
                      child: Text(tr(LocaleKeys.reason_loan),
                          style: CommonStyles.txSty_14p_f5),
                    ),
                    const Expanded(
                        flex: 1,
                        child: Text(':', style: CommonStyles.txSty_14p_f5)),
                    Expanded(
                      flex: 5,
                      child: Text(_reasonController.text,
                          style: CommonStyles.txF14Fw5Cb),
                    ),
                  ],
                )
              : const SizedBox(),
          const SizedBox(
            height: 10,
          ),
        ],
      ),
    );
  }
}
