import 'package:akshaya_flutter/common_utils/api_config.dart';
import 'package:akshaya_flutter/common_utils/common_styles.dart';
import 'package:akshaya_flutter/models/FarmerResponseModel.dart';
import 'package:akshaya_flutter/navigation/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dio/dio.dart';
import 'package:qrscan/qrscan.dart' as scanner;
import 'package:fluttertoast/fluttertoast.dart';

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
    return Scaffold(
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
                    const Text('Welcome', style: CommonStyles.txSty_24w),
                    Padding(
                      padding: const EdgeInsets.only(
                          top: 22.0, left: 22.0, right: 22.0),
                      child: TextFormField(
                          controller: _farmercodeController,
                          decoration: InputDecoration(
                            hintText: 'Enter Farmer Id',
                            focusedBorder: OutlineInputBorder(
                              borderSide: const BorderSide(
                                color: Colors
                                    .white, // Set the border line color to white
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
                            hintStyle: CommonStyles.txSty_20hint_fb,
                            contentPadding: const EdgeInsets.symmetric(
                                vertical: 15, horizontal: 15),
                            // Add padding to center the hint text
                            alignLabelWithHint:
                                true, // Center-align the hint text
                          ),
                          textAlign: TextAlign.center,
                          style: CommonStyles.txSty_20wh_fb),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(
                          top: 22.0, left: 22.0, right: 22.0),
                      child: SizedBox(
                        width: double.infinity,
                        // Makes the button take up the full width of its parent
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
                              color: const Color(
                                  0xFFe86100), // Orange border color
                              width: 2.0,
                            ),
                          ),
                          child: ElevatedButton(
                            onPressed: () {
                              onLoginPressed();
                              // Handle language selection here
                            },
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 0),
                              backgroundColor: Colors
                                  .transparent, // Transparent to show the gradient
                              shadowColor:
                                  Colors.transparent, // Remove button shadow
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20.0),
                              ),
                            ),
                            child: const Text(
                              'Login',
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
                        child: const Text(
                          'OR',
                          style: TextStyle(
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
                              color: const Color(
                                  0xFFe86100), // Orange border color
                              width: 2.0,
                            ),
                          ),
                          child: ElevatedButton(
                            onPressed: () {
                              _scanQR();
                            },
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 0),
                              backgroundColor: Colors
                                  .transparent, // Transparent to show the gradient
                              shadowColor:
                                  Colors.transparent, // Remove button shadow
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20.0),
                              ),
                            ),
                            child: const Text(
                              'Scan QR',
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
    );
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
        GetLogin();
      } else {
        print("Please check your internet connection.");
        //showDialogMessage(context, "Please check your internet connection.");
      }
    } else {
      // showDialogMessage(context, "Please enter Farmer ID.");
    }
  }

  void GetLogin() async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
    });

    final dio = Dio();
    final farmerId = _farmercodeController.text.trim();
    print("farmerId==263: $farmerId");

    try {
      final response = await dio.get('$baseUrl$Farmer_ID_CHECK$farmerId/null');

      if (response.statusCode == 200) {
        final farmerResponseModel = FarmerResponseModel.fromJson(response.data);

        if (farmerResponseModel.isSuccess!) {
          setState(() {
            _isLoading = false;
          });

          if (farmerResponseModel.result != null) {
            _mobileNumber = farmerResponseModel.result!;
            print('mobile_number=== $_mobileNumber');

            // Navigator.push(
            //   context,
            //   MaterialPageRoute(
            //     builder: (context) => LoginOtpScreen(mobile: _mobileNumber),
            //   ),
            // );
            context.push(Routes.loginOtpScreen.path);
          } else {
            _showDialog('No Registered Mobile Number for Send Otp');
          }
        } else {
          _showDialog('Invalid');
        }
      } else {
        _showDialog('Server Error');
      }
    } on DioException catch (e) {
      print('Error: $e');
      _showDialog('Server Error');
    } finally {
      setState(() {
        _isLoading = false;
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

 Future<void> _scanQR() async {
   // Request camera permission
   var status = await Permission.camera.request();
   if (status.isGranted) {
     try {
       String? cameraScanResult = await scanner.scan();
       setState(() {
         if (cameraScanResult != null) {
           _farmercodeController.text = cameraScanResult;
         }
       });
     } on PlatformException catch (e) {
       print(e);
     }
   } else {
     // Handle permission denied
     setState(() {
       _farmercodeController.text = "Camera permission denied";
     });
   }
 }
}
