import 'dart:convert';
import 'dart:io';

import 'package:akshaya_flutter/common_utils/common_styles.dart';
import 'package:akshaya_flutter/common_utils/constants.dart';
import 'package:akshaya_flutter/common_utils/shared_prefs_keys.dart';
import 'package:akshaya_flutter/gen/assets.gen.dart';
import 'package:akshaya_flutter/localization/locale_keys.dart';
import 'package:akshaya_flutter/models/farmer_model.dart';
import 'package:http/http.dart' as http;
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../common_utils/api_config.dart';
import '../models/FarmerResponseModel.dart';
import '../screens/main_screen.dart';
import 'package:device_info_plus/device_info_plus.dart';

class LoginOtpScreen extends StatefulWidget {
  final String mobile;

  const LoginOtpScreen({super.key, required this.mobile});

  @override
  State<LoginOtpScreen> createState() => _LoginOtpScreenState();
}

class _LoginOtpScreenState extends State<LoginOtpScreen> {
  bool isLoading = false;
  String? farmerId;
  final TextEditingController otpController = TextEditingController();
  // final _dio = Dio();

  String fetchlast4Digits(String number) {
    return number.substring(number.length - 4);
  }

/*   @override
  void initState() {
    fetchDeviceIdentifier();
    super.initState();
  } */

  @override
  void dispose() {
    otpController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              Assets.images.appbg.path,
              // 'assets/images/appbg.png',
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
                  const SizedBox(height: 70),
                  // Split the mobile numbers and format the display
                  Text(
                    '${tr(LocaleKeys.otp_desc)} ${_formatMobileNumbers(widget.mobile)}',
                    style: CommonStyles.txStyF16CwFF6,
                  ),
                  const SizedBox(height: 30),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: PinCodeTextField(
                      controller: otpController,
                      appContext: context,
                      textStyle: CommonStyles.txStyF16CwFF6,
                      length: 6,
                      autoFocus: true,
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
                      enableActiveFill: true,
                      keyboardType: TextInputType.number,
                      beforeTextPaste: (text) {
                        print("Allowing to paste $text");
                        return true;
                      },
                    ),
                  ),
                  const SizedBox(height: 20),
                  submitBtn(context, tr(LocaleKeys.submit)),
                  const SizedBox(height: 10),
                  resendOtp()
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  Row resendOtp() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        GestureDetector(
          onTap: () {
            resendOTP();
          },
          child: Text(
            tr(LocaleKeys.re_send),
            style: CommonStyles.text14white.copyWith(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  Future<bool> isvalidations() async {
    bool isValid = true;
    if (otpController.text.isEmpty) {
      CommonStyles.showCustomDialog(context, 'Please Enter OTP');
      //  showCustomToastMessageLong('Please Enter OTP', context, 1, 4);
      isValid = false;
    }
    return isValid; // Return true if validation is successful, false otherwise
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
          onPressed: () async {
            // _verifyOtp();
            print('otpController: ${otpController.text}');
            bool validationSuccess = await isvalidations();
            if (validationSuccess) {
              _verifyOtp();
            }
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
      CommonStyles.showHorizontalDotsLoadingDialog(context);
    });

    final url = '$baseUrl$Farmer_otp${farmerId!}/${otpController.text}';
    print("otpsubmiturl==== $url");
    try {
      print("Sending request to URL: $url");
      final jsonResponse = await http.get(Uri.parse(url));

      print("Response status code: ${jsonResponse.statusCode}");
      if (jsonResponse.statusCode == 200) {
        final response = jsonDecode(jsonResponse.body);
        final Map<String, dynamic> data = response;
        print("Response data: $data");
        if (data['isSuccess']) {
          // Convert the complete response to a JSON string and save it
          String responseJson = json.encode(data);
          prefs.setString(SharedPrefsKeys.farmerData, responseJson);
          print("OTP validation successful");

          prefs.setBool(Constants.isLogin, true);
          prefs.setString(SharedPrefsKeys.farmerCode,
              data['result']['farmerDetails'][0]['code']);
          prefs.setString(SharedPrefsKeys.statecode,
              data['result']['farmerDetails'][0]['stateCode']);
          prefs.setInt(SharedPrefsKeys.districtId,
              data['result']['farmerDetails'][0]['districtId']);
          prefs.setString(SharedPrefsKeys.districtName,
              data['result']['farmerDetails'][0]['districtName']);

          print("Navigating to Home screen");

          // Hide loading dialog and stop loading before navigating
          CommonStyles.hideHorizontalDotsLoadingDialog(context);
          setState(() {
            isLoading = false;
          });
          // fetchUniqueIdentifierFromDeviceAndSave();
          try {
            print("Attempting to navigate to MainScreen");
            fetchUniqueIdentifierFromDeviceAndSave();
            await Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => const MainScreen(),
              ),
            );
            print("Navigation to MainScreen succeeded");
          } catch (e) {
            print("Navigation to MainScreen failed: $e");
          }
        } else {
          print("OTP validation failed: ${data['endUserMessage']}");
          _showErrorDialog(data['endUserMessage']);
        }
      } else {
        print("Server error: Status code ${jsonResponse.statusCode}");
        _showErrorDialog('Server error');
      }
    } catch (e) {
      print("Exception caught: $e");
      _showErrorDialog('Failed to load data');
    } finally {
      CommonStyles.hideHorizontalDotsLoadingDialog(context);
      setState(() {
        isLoading = false;
      });
    }
  }

  void _showErrorDialog(String message) {
    Future.delayed(Duration.zero, () {
      CommonStyles.showCustomDialog(context, message);
    });
  }

  void resendOTP() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      CommonStyles.showHorizontalDotsLoadingDialog(context);

      farmerId = prefs.getString('farmerid');
      isLoading = true;
    });

    // final dio = Dio();

    print("farmerId==263: $farmerId");

    String apiUrl = '$baseUrl$Farmer_ID_CHECK$farmerId/null';

    try {
      final jsonResponse = await http.get(Uri.parse(apiUrl));
      // final response = await dio.get('$baseUrl$Farmer_ID_CHECK$farmerId/null');

      if (jsonResponse.statusCode == 200) {
        final response = jsonDecode(jsonResponse.body);
        final farmerResponseModel = FarmerResponseModel.fromJson(response);

        if (farmerResponseModel.isSuccess!) {
          setState(() {
            // CommonStyles.hideHorizontalDotsLoadingDialog(context);
            isLoading = false;
          });

          if (farmerResponseModel.result != null) {
            String mobileNumber = farmerResponseModel.result!;
            print('mobile_number=== $mobileNumber');
            //otpsuccess
            Fluttertoast.showToast(
                msg: tr(LocaleKeys.otpsuccess),
                toastLength: Toast.LENGTH_LONG,
                gravity: ToastGravity.BOTTOM,
                timeInSecForIosWeb: 1,
                backgroundColor: Colors.black,
                textColor: Colors.white,
                fontSize: 16.0);

            /* CommonStyles.showCustomToast(
              context,
              title: tr(LocaleKeys.otpsuccess),
            ); */
          } else {
            CommonStyles.showCustomDialog(
                context, 'No Register Mobile Number for Send Otp');
            CommonStyles.hideHorizontalDotsLoadingDialog(context);
            // _showDialog('No Registered Mobile Number for Send Otp');
          }
        } else {
          CommonStyles.showCustomDialog(context, 'Invalid');
          //  CommonStyles.hideHorizontalDotsLoadingDialog(context);
          //_showDialog('Invalid');
        }
      } else {
        CommonStyles.showCustomDialog(context, 'Server Error');
        CommonStyles.hideHorizontalDotsLoadingDialog(context);
        // _showDialog('Server Error');
      }
    } catch (e) {
      print('Error: $e');
      CommonStyles.showCustomDialog(context, 'Server Error');
      //  _showDialog('Server Error');
    } finally {
      setState(() {
        CommonStyles.hideHorizontalDotsLoadingDialog(context);
        isLoading = false;
      });
    }
  }

// Function to format mobile numbers
  String _formatMobileNumbers(String mobileNumbers) {
    // Split the mobile numbers by comma
    List<String> numbersList = mobileNumbers.split(',');

    // Format each number to show last 4 digits
    String formattedNumbers = numbersList.map((number) {
      // Check if the number has at least 4 digits
      if (number.length >= 4) {
        return '****${number.substring(number.length - 4)}'; // Show last 4 digits with asterisks
      }
      return number; // Return as is if less than 4 digits
    }).join(', '); // Join with a comma

    return formattedNumbers;
  }

  Future<void> fetchUniqueIdentifierFromDeviceAndSave() async {
    String? uniqueIdentifier = await fetchDeviceIdentifier();
    SharedPreferences prefs = await SharedPreferences.getInstance();

    final result = prefs.getString(SharedPrefsKeys.farmerData);
    if (result == null) {
      throw Exception('No farmer data found in shared preferences');
    }
    Map<String, dynamic> response = json.decode(result);
    Map<String, dynamic> farmerResult = response['result']['farmerDetails'][0];
    final FarmerModel farmerModel = FarmerModel.fromJson(farmerResult);

    final currentDate = DateFormat('yyyy-MM-dd').format(DateTime.now());
    final apiUrl = Uri.parse('$baseUrl$addAppInstallation');

    final requestBody = jsonEncode({
      "id": 1,
      "farmerCode": farmerModel.code,
      "installedOn": currentDate,
      "imeiNumber": uniqueIdentifier,
      "lastLoginDate": currentDate,
      "isActive": true,
      "farmerName": farmerModel.firstName,
      "clusterId": farmerModel.clusterId,
      "stateCode": farmerModel.stateCode,
      "stateName": farmerModel.stateName
    });

    try {
      final jsonResponse = await http.post(apiUrl,
          headers: {'Content-Type': 'application/json'}, body: requestBody);

      print('fetchUniqueIdentifierFromDeviceAndSave: $uniqueIdentifier');
      print('fetchUniqueIdentifierFromDeviceAndSave: $apiUrl');
      print('fetchUniqueIdentifierFromDeviceAndSave: $requestBody');

      if (jsonResponse.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Unique identifier saved successfully!'),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to save unique identifier!'),
          ),
        );
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  Future<String?> fetchDeviceIdentifier() async {
    try {
      if (Platform.isAndroid) {
        return await _getAndroidIMEI();
      } else if (Platform.isIOS) {
        return await _getiOSUDID();
      } else {
        return "Unsupported Platform";
      }
    } catch (e) {
      print('catch: $e');
    }
    return null;
  }

  Future<String?> _getAndroidIMEI() async {
    try {
      final deviceInfo = DeviceInfoPlugin();
      AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;

      print('getDeviceData uniqueIdentifier: ${androidInfo.id}');
      return androidInfo.id;
    } catch (e) {
      return null;
    }
  }

  Future<String?> _getiOSUDID() async {
    try {
      final deviceInfo = DeviceInfoPlugin();
      IosDeviceInfo iosInfo = await deviceInfo.iosInfo;
      return iosInfo.identifierForVendor;
    } catch (e) {
      return null;
    }
  }
}
