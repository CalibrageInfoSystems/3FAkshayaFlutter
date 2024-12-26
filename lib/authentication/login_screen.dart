// ignore_for_file: deprecated_member_use

import 'dart:convert';
import 'dart:io';

import 'package:akshaya_flutter/authentication/login_otp_screen.dart';
import 'package:akshaya_flutter/common_utils/api_config.dart';
import 'package:akshaya_flutter/common_utils/common_styles.dart';
import 'package:akshaya_flutter/localization/locale_keys.dart';
import 'package:akshaya_flutter/models/FarmerResponseModel.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
// import 'package:dio/dio.dart';
import 'package:http/http.dart' as http;
// import 'package:qrscan/qrscan.dart' as scanner;
import 'package:qrscan/qrscan.dart' as scanner;

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _farmercodeController = TextEditingController();
  String farmercode = "";

  String? farmerMobileNumber;
  bool _isLoading = false;
  late String _mobileNumber;

  @override
  void dispose() {
    _farmercodeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        onWillPop: () async {
          if (Platform.isAndroid) {
            // Close the app on Android
            SystemNavigator.pop();
            return Future.value(false); // Do not navigate back
          } else if (Platform.isIOS) {
            // Close the app on iOS
            exit(0);
          }
          return Future.value(
              true); // Default behavior (navigate back) if not Android or iOS
        },
        child: Scaffold(
          body: SingleChildScrollView(
            child: SizedBox(
              height: MediaQuery.of(context).size.height,
              child: Stack(
                children: [
                  Image.asset(
                    'assets/images/appbg.png',
                    width: double.infinity,
                    height: double.infinity,
                    fit: BoxFit.cover,
                  ),
                  Container(
                    color: const Color(0x8D000000),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 180.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Align(
                          alignment: Alignment.topCenter,
                          child: Image.asset(
                            'assets/images/ic_user.png',
                            width: 200,
                            height: 150,
                          ),
                        ),
                        Text(tr(LocaleKeys.welcome),
                            style: CommonStyles.txSty_24w),
                        Padding(
                          padding: const EdgeInsets.only(
                              top: 22.0, left: 22.0, right: 22.0),
                          child: TextFormField(
                            controller: _farmercodeController,
                            decoration: InputDecoration(
                              hintText: tr(LocaleKeys.farmar_id),

                              focusedBorder: OutlineInputBorder(
                                borderSide: const BorderSide(
                                  color: Colors.white,
                                ),
                                borderRadius: BorderRadius.circular(
                                    10.0), // Set the border radius
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderSide: const BorderSide(
                                  color: Colors
                                      .white, // Set the border line color to white
                                ),
                                borderRadius: BorderRadius.circular(10.0),
                              ),
                              hintStyle: CommonStyles.txStyF20CwFF6.copyWith(
                                color: Colors.grey.shade500,
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                  vertical: 15, horizontal: 15),
                              alignLabelWithHint:
                                  true, // Center-align the hint text
                            ),
                            textAlign: TextAlign.center,

                            style: CommonStyles.txStyF20CwFF6.copyWith(
                              // decoration: TextDecoration.underline,
                              decorationColor: Colors.white,
                            ),
                            textCapitalization: TextCapitalization
                                .characters, // Automatically enables CAPS lock
                            inputFormatters: [
                              FilteringTextInputFormatter.allow(RegExp(
                                  r'[A-Z0-9]')), // Allows only uppercase letters and numbers
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(
                              top: 22.0, left: 22.0, right: 22.0),
                          child: SizedBox(
                            width: double.infinity,
                            // Makes the button take up the full width of its parent
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(
                                    20.0), // Rounded corners
                                gradient: const LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: [
                                    Color(
                                        0xFFCCCCCC), // Start color (light gray)
                                    Color(0xFFFFFFFF), // Center color (white)
                                    Color(0xFFCCCCCC), // End color (light gray)
                                  ],
                                ),
                                border: Border.all(
                                  color: const Color(
                                      0xFFe86100), // Orange border color
                                  width: 2.0,
                                ),
                              ),
                              child: ElevatedButton(
                                onPressed: () async {
                                  FocusScope.of(context).unfocus();
                                  bool validationSuccess =
                                      await isvalidations();
                                  if (validationSuccess) {
                                    onLoginPressed();
                                  }
                                },
                                style: ElevatedButton.styleFrom(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 0),
                                  backgroundColor: Colors
                                      .transparent, // Transparent to show the gradient
                                  shadowColor: Colors
                                      .transparent, // Remove button shadow
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20.0),
                                  ),
                                ),
                                child: Text(
                                  tr(LocaleKeys.login),
                                  style: CommonStyles.text18orange,
                                ),
                              ),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 6.0),
                          child: Container(
                            alignment: AlignmentDirectional.center,
                            child: Text(
                              tr(LocaleKeys.or),
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),

                        Padding(
                          padding: const EdgeInsets.only(
                              top: 10.0, left: 22.0, right: 22.0),
                          child: SizedBox(
                            width: double.infinity,
                            // Makes the button take up the full width of its parent
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(
                                    20.0), // Rounded corners
                                gradient: const LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: [
                                    Color(
                                        0xFFCCCCCC), // Start color (light gray)
                                    Color(0xFFFFFFFF), // Center color (white)
                                    Color(0xFFCCCCCC), // End color (light gray)
                                  ],
                                ),
                                border: Border.all(
                                  color: const Color(
                                      0xFFe86100), // Orange border color
                                  width: 2.0,
                                ),
                              ),
                              child: ElevatedButton(
                                onPressed: () {
                                  print('scan btn clicked');
                                  _scanQR();
                                },
                                style: ElevatedButton.styleFrom(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 0),
                                  backgroundColor: Colors
                                      .transparent, // Transparent to show the gradient
                                  shadowColor: Colors
                                      .transparent, // Remove button shadow
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20.0),
                                  ),
                                ),
                                child: Text(
                                  tr(LocaleKeys.scan_qr),
                                  style: CommonStyles.text18orange,
                                ),
                              ),
                            ),
                          ),
                        ),
                        // Other Buttons
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ));
  }

  Future<void> onLoginPressed() async {
    String farmerIdText = _farmercodeController.text.trim();
    if (farmerIdText.isNotEmpty) {
      farmercode = farmerIdText.replaceAll(" ", "");
      print("former==id: $farmercode");

      SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs.setString('farmerid', farmercode);
      bool isConnected = await CommonStyles.checkInternetConnectivity();
      if (isConnected) {
        // Call your login function here
        getLogin();
      } else {
        print("Please check your internet connection.");
        //showDialogMessage(context, "Please check your internet connection.");
      }
    } else {
      // showDialogMessage(context, "Please enter Farmer ID.");
    }
  }

  void getLogin() async {
    // Ensure that the keyboard is hidden and the focus is removed
    FocusScope.of(context).unfocus();

    // Prevent further actions if already loading
    if (_isLoading) return;

    setState(() {
      CommonStyles.showHorizontalDotsLoadingDialog(
          context); // Show loading dialog
      _isLoading = true;
    });

    final farmerId = _farmercodeController.text.trim();
    print("farmerId==255: $farmerId");
    final apiUrl = '$baseUrl$Farmer_ID_CHECK$farmerId/null';
    try {
      final jsonResponse = await http.get(Uri.parse(apiUrl));
      print("farmerId==259: $jsonResponse");
      print("farmerId==260: ${jsonResponse.statusCode}");

      if (jsonResponse.statusCode == 200) {
        final response = jsonDecode(jsonResponse.body);
        final farmerResponseModel = FarmerResponseModel.fromJson(response);
        print("farmerId==266: ${farmerResponseModel.isSuccess!}");
        if (farmerResponseModel.isSuccess!) {
          if (farmerResponseModel.result != null) {
            _mobileNumber = farmerResponseModel.result!;
            print('mobile_number=== $_mobileNumber');
            CommonStyles.hideHorizontalDotsLoadingDialog(context);
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => LoginOtpScreen(mobile: _mobileNumber),
              ),
            );
            // context.go('${Routes.loginOtpScreen.path}/$_mobileNumber');
          } else {
            CommonStyles.hideHorizontalDotsLoadingDialog(context);
            _showErrorDialog('No Registered Mobile Number to Send OTP');
          }
        } else {
          CommonStyles.hideHorizontalDotsLoadingDialog(context);
          _showErrorDialog('Invalid Farmer');
        }
      } else {
        CommonStyles.hideHorizontalDotsLoadingDialog(context);
        _showErrorDialog('Server Error');
      }
    } catch (e) {
      print('Error: $e');
      CommonStyles.hideHorizontalDotsLoadingDialog(context);
      _showErrorDialog('Server Error');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _scanQR() async {
    String cameraScanResult = await FlutterBarcodeScanner.scanBarcode(
        "#ff6666", "Cancel", false, ScanMode.DEFAULT);
    print('cameraScanResult: $cameraScanResult');
    if (cameraScanResult != '-1') {
      setState(() {
        _farmercodeController.text = cameraScanResult;
      });
    }
  }

  // Future<void> _scanQR() async {
  //   try {
  //     var status = await Permission.camera.request();
  //     print('qrscan: status $status');

  //     if (status.isGranted) {
  //       String? cameraScanResult = await scanner.scan();

  //       setState(() {
  //         print('qrscan: cameraScanResult $cameraScanResult');
  //         if (cameraScanResult != null) {
  //           _farmercodeController.text = cameraScanResult;
  //         }
  //       });
  //     } else if (status == PermissionStatus.permanentlyDenied ||
  //         status == PermissionStatus.denied) {
  //       openAppSettings();
  //     } else {
  //       print('Camera permission is required.');
  //       CommonStyles.showCustomDialog(
  //           context, 'Camera permission is required.');
  //     }
  //   } catch (e) {
  //     print('qrscan: e $e');
  //   }
  // }

  // Future<void> _scanQR() async {
  //   // Request camera permission
  //   var status = await Permission.camera.isGranted;
  //   print('status: $status');
  //   if (status) {
  //     try {
  //       String? cameraScanResult = await scanner.scan();
  //       setState(() {
  //         if (cameraScanResult != null) {
  //           _farmercodeController.text = cameraScanResult;
  //         }
  //       });
  //     } on PlatformException catch (e) {
  //       print(e);
  //     }
  //   } else {
  //     // Handle permission denied
  //     setState(() {
  //       _farmercodeController.text = "Camera permission denied";
  //     });
  //   }
  // }

  Future<bool> isvalidations() async {
    bool isValid = true;

    if (_farmercodeController.text.isEmpty) {
      CommonStyles.showCustomDialog(context, ' Enter Farmer Id');
      isValid = false;
    }

    return isValid; // Return true if validation is successful, false otherwise
  }

  void _showErrorDialog(String message) {
    Future.delayed(Duration.zero, () {
      CommonStyles.showCustomDialog(context, message);
    });
  }
}
