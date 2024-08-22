import 'dart:convert';

import 'package:akshaya_flutter/common_utils/common_styles.dart';
import 'package:akshaya_flutter/screens/home_screen/home_screen.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:go_router/go_router.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../common_utils/Constants.dart';
import '../common_utils/api_config.dart';
import '../navigation/app_routes.dart';

class LoginOtpScreen extends StatefulWidget {
  final String mobile;
  const LoginOtpScreen({super.key, required this.mobile});

  @override
  State<LoginOtpScreen> createState() => _LoginOtpScreenState();
}

class _LoginOtpScreenState extends State<LoginOtpScreen> {
  bool isLoading = false;
  String? farmerId;
  final _dio = Dio();
  String fetchlast4Digits(String number) {
    return number.substring(number.length - 4);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            Positioned.fill(
              child: Image.asset(
                'assets/images/appbg.png',
                fit: BoxFit.cover,
              ),
            ),
            Positioned.fill(
              child: Container(
                color: const Color(0x8D000000),
              ),
            ),
            Align(
              alignment: Alignment.topCenter,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    const SizedBox(height: 30),
                    Text(
                      'Enter the 6 Digits Code Sent your Registered Mobile Number(s) ******${fetchlast4Digits(widget.mobile)}',
                      style: CommonStyles.txSty_16w_fb,
                    ),
                    const SizedBox(height: 30),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      child: PinCodeTextField(
                        appContext: context,
                        textStyle: CommonStyles.txSty_16w_fb,
                        length: 6,
                        obscureText: false,
                        animationType: AnimationType.fade,
                        pinTheme: PinTheme(
                          shape: PinCodeFieldShape.underline,
                          borderRadius: BorderRadius.circular(10),
                          fieldWidth: 45,
                          activeColor: CommonStyles.primaryTextColor,
                          selectedColor: CommonStyles.primaryTextColor,
                          selectedFillColor: Colors.transparent,
                          activeFillColor: Colors.transparent,
                          inactiveFillColor: Colors.transparent,
                          inactiveColor: Colors.white,
                        ),
                        animationDuration: const Duration(milliseconds: 300),
                        // backgroundColor: Colors
                        //     .blue.shade50, // Set background color
                        enableActiveFill: true,
                        // controller: _otpController,
                        // inputFormatters: [
                        //   FilteringTextInputFormatter.digitsOnly
                        // ],
                        keyboardType: TextInputType.number,
                        // validator: validateotp,
                        onCompleted: (v) {
                          print("Completed");
                        },
                        onChanged: (value) {
                          // setState(() {
                          //   currentText = value;
                          // });
                        },
                        beforeTextPaste: (text) {
                          print("Allowing to paste $text");
                          return true;
                        },
                      ),
                    ),
                    const SizedBox(height: 20),
                    submitBtn(context, 'Submit'),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text(
                          "Didn't receive code? ",
                          style: CommonStyles.text14white.copyWith(
                              color: const Color.fromARGB(255, 240, 237, 237)),
                        ),
                        Text(
                          "Resend OTP",
                          style: CommonStyles.text14white.copyWith(
                              fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                      ],
                    )
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget submitBtn(
    BuildContext context,
    String language,
  ) {
    return SizedBox(
      width: double.infinity,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16.0),
          gradient: const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFCCCCCC),
              Color(0xFFFFFFFF),
              Color(0xFFCCCCCC),
            ],
          ),
          border: Border.all(
            color: const Color(0xFFe86100),
            width: 2.0,
          ),
        ),
        child: ElevatedButton(
          onPressed: () {
            _verifyOtp();
            

          },
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 0),
            backgroundColor: Colors.transparent,
            shadowColor: Colors.transparent,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16.0),
            ),
          ),
          child: Text(
            language,
            style: CommonStyles.txSty_16p_f5,
          ),
        ),
      ),
    );
  }

  Future<void> _verifyOtp() async {
    // Call your login function here

    bool isConnected = await CommonStyles.checkInternetConnectivity();
    if (isConnected) {
      // Call your login function here
      _getOtp();
    } else {
      print("Please check your internet connection.");
      //showDialogMessage(context, "Please check your internet connection.");
    }

  }
  Future<void> _getOtp() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      farmerId = prefs.getString('farmerid');
      isLoading = true;
    });

    final url = baseUrl + Farmer_otp + farmerId! + "/123456";
    print("otpsubmiturl==== $url");
    try {
      print("Sending request to URL: $url");
      final response = await _dio.get(url);

      print("Response status code: ${response.statusCode}");
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = response.data;
        print("Response data: $data");
        if (data['isSuccess']) {
          // Convert the complete response to a JSON string and save it
          String responseJson = json.encode(data);
          prefs.setString('otp_response', responseJson);
          print("OTP validation successful");

          prefs.setBool(Constants.isLogin, true);
          prefs.setString('user_id', data['result']['farmerDetails'][0]['code']);
          prefs.setString('statecode', data['result']['farmerDetails'][0]['stateCode']);
          prefs.setInt('districtId', data['result']['farmerDetails'][0]['districtId']);
          prefs.setString('districtName', data['result']['farmerDetails'][0]['districtName']);

          print("Navigating to Home screen");
          // Navigator.push(
          //   context,
          //   MaterialPageRoute(
          //     builder: (context) => HomeScreen(),
          //   ),
          // );
          context.go(Routes.homeScreen.path);
        } else {
          print("OTP validation failed: ${data['endUserMessage']}");
          _showDialog(data['endUserMessage']);
        }
      } else {
        print("Server error: Status code ${response.statusCode}");
        _showDialog('Server error');
      }
    } catch (e) {
      print("Exception caught: $e");
      _showDialog('Failed to load data');
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }


  void _showDialog(String message) {
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_LONG,
      gravity: ToastGravity.CENTER,
      timeInSecForIosWeb: 1,
    );
  }
}


