import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:connectivity/connectivity.dart';

class CommonStyles {
  // colors
  static const statusBlueBg = Color(0xffc3c8cc);
  static const statusBlueText = Color(0xFF11528f);
  static const statusGreenBg = Color(0xFFe5ffeb);
  static const statusGreenText = Color(0xFF287d02);
  static const statusYellowBg = Color(0xfff8e7cb);
  static const statusYellowText = Color(0xFFd48202);
  static const statusRedBg = Color(0xFFffdedf);
  static const statusRedText = Color.fromARGB(255, 236, 62, 68);
  static const startColor = Color(0xFF59ca6b);

  static const blackColor = Colors.black;
  static const blackColorShade = Color(0xFF5f5f5f);
  static const primaryColor = Color(0xFFf7ebff);
  static const primaryTextColor = Color(0xFFe86100);
  static const formFieldErrorBorderColor = Color(0xFFff0000);
  static const blueColor = Color(0xFF0f75bc);
  static const branchBg = Color(0xFFcfeaff);
  static const primarylightColor = Color(0xffe2f0fd);
  static const greenColor = Colors.greenAccent;
  static const whiteColor = Colors.white;
  static const hintTextColor = Color(0xCBBEBEBE);
  // styles
  static const RedColor = Color(0xFFC93437);
  static const TextStyle txSty_12b_f5 = TextStyle(
    fontSize: 12,
    fontFamily: "hind_semibold",
    fontWeight: FontWeight.w500,
    color: blackColor,
  );
  static const TextStyle texthintstyle = TextStyle(
    fontSize: 14,
    fontFamily: "hind_semibold",
    fontWeight: FontWeight.w500,
    color: Colors.grey,
  );
  static const TextStyle texterrorstyle = TextStyle(
    fontSize: 14,
    fontFamily: "hind_semibold",
    fontWeight: FontWeight.w500,
    color: Color.fromARGB(255, 175, 15, 4),
  );
  static const TextStyle txSty_20wh_fb = TextStyle(
    fontSize: 20,
    fontFamily: "hind_semibold",
    fontWeight: FontWeight.w500,
    color: whiteColor,
  );
  static const TextStyle txSty_20hint_fb = TextStyle(
    fontSize: 20,
    fontFamily: "hind_semibold",
    fontWeight: FontWeight.w500,
    color: hintTextColor,
  );
  static const TextStyle txSty_14b_f5 = TextStyle(
    fontSize: 14,
    fontFamily: "hind_semibold",
    fontWeight: FontWeight.w500,
    color: blackColor,
  );
  static const TextStyle txSty_22b_f5 = TextStyle(
    fontSize: 22,
    fontFamily: "hind_semibold",
    fontWeight: FontWeight.w500,
    color: blackColor,
  );
  static const TextStyle txSty_14p_f5 = TextStyle(
    fontSize: 14,
    fontFamily: "hind_semibold",
    fontWeight: FontWeight.w500,
    color: primaryTextColor,
  );
  static const TextStyle txSty_14g_f5 = TextStyle(
    fontSize: 16,
    fontFamily: "hind_semibold",
    fontWeight: FontWeight.w600,
    color: statusGreenText,
  );
  static const TextStyle txSty_14blu_f5 = TextStyle(
    fontSize: 14,
    fontFamily: "hind_semibold",
    fontWeight: FontWeight.w500,
    color: Color(0xFF0f75bc),
  );
  static const TextStyle txSty_16blu_f5 = TextStyle(
    fontSize: 16,
    fontFamily: "hind_semibold",
    fontWeight: FontWeight.w500,
    color: Color(0xFF0f75bc),
  );
  static const TextStyle txSty_16black_f5 = TextStyle(
    fontSize: 16,
    fontFamily: "hind_semibold",
    fontWeight: FontWeight.w500,
    color: Color(0xFF5f5f5f),
  );
  static const TextStyle txSty_14black_f5 = TextStyle(
    fontSize: 14,
    fontFamily: "hind_semibold",
    fontWeight: FontWeight.w500,
    color: Color(0xFF5f5f5f),
  );
  static const TextStyle txSty_16p_fb = TextStyle(
    fontSize: 16,
    fontFamily: "hind_semibold",
    fontWeight: FontWeight.bold,
    color: primaryTextColor,
  );
  static const TextStyle txSty_18b_fb = TextStyle(
    fontSize: 18,
    color: Colors.black,
    fontWeight: FontWeight.w600,
    fontFamily: 'hind_semibold',
  );
  static const TextStyle txSty_16b6_fb = TextStyle(
    fontSize: 16,
    color: Colors.black,
    fontWeight: FontWeight.w700,
    fontFamily: 'hind_semibold',
  );
  static const TextStyle txSty_16b_fb = TextStyle(
    fontSize: 16,
    color: Colors.black,
    fontWeight: FontWeight.w500,
    fontFamily: 'hind_semibold',
  );
  static const TextStyle txSty_14b_fb = TextStyle(
    fontSize: 14,
    color: Colors.black,
    fontWeight: FontWeight.w500,
    fontFamily: 'hind_semibold',
  );
  static const TextStyle header_Styles = TextStyle(
    fontSize: 26,
    fontFamily: "hind_semibold",
    fontWeight: FontWeight.w700,
    color: Color(0xFF0f75bc),
  );
  static const TextStyle txSty_16w_fb = TextStyle(
    fontSize: 16,
    fontFamily: "hind_semibold",
    fontWeight: FontWeight.bold,
    color: whiteColor,
  );
  static const TextStyle txSty_24w = TextStyle(
      fontSize: 24,
      fontFamily: "hind_semibold",
      fontWeight: FontWeight.bold,
      color: whiteColor,
      letterSpacing: 1);
  static const TextStyle txSty_16p_f5 = TextStyle(
    fontSize: 16,
    fontFamily: "hind_semibold",
    fontWeight: FontWeight.w500,
    color: primaryTextColor,
  );
  static const TextStyle txSty_20p_fb = TextStyle(
    fontSize: 20,
    fontFamily: "hind_semibold",
    fontWeight: FontWeight.w700,
    color: primaryTextColor,
    letterSpacing: 2,
  );
  static const TextStyle txSty_20b_fb = TextStyle(
    fontSize: 20,
    fontFamily: "hind_semibold",
    fontWeight: FontWeight.bold,
    color: blackColor,
  );

  static const TextStyle txSty_12b_fb = TextStyle(
      fontFamily: 'hind_semibold',
      fontSize: 12,
      color: Color(0xFF000000),
      fontWeight: FontWeight.w500);
  static const TextStyle txSty_12bl_fb = TextStyle(
    fontFamily: 'hind_semibold',
    fontSize: 12,
    color: Color(0xA1000000),
  );
  static const TextStyle txSty_12W_fb = TextStyle(
    fontFamily: 'hind_semibold',
    fontSize: 12,
    color: whiteColor,
  );
  static const TextStyle txSty_12blu_fb = TextStyle(
    fontFamily: 'hind_semibold',
    fontSize: 12,
    color: Color(0xFF8d97e2),
  );
  static const TextStyle txSty_20black_fb = TextStyle(
    fontSize: 20,
    fontFamily: "hind_semibold",
    color: blackColor,
  );
  static const TextStyle txSty_20blu_fb = TextStyle(
    fontSize: 20,
    fontFamily: "hind_semibold",
    fontWeight: FontWeight.w700,
    color: primaryTextColor,
  );
  static const TextStyle txSty_20w_fb = TextStyle(
    fontSize: 20,
    fontFamily: "hind_semibold",
    color: whiteColor,
  );
  static const TextStyle text16white = TextStyle(
    fontSize: 16,
    fontFamily: "hind_semibold",
    fontWeight: FontWeight.w600,
    color: CommonStyles.whiteColor,
  );
  static const TextStyle text14white = TextStyle(
    fontSize: 14,
    fontFamily: "hind_semibold",
    fontWeight: FontWeight.w600,
    color: CommonStyles.whiteColor,
  );
  static TextStyle dayTextStyle =
      const TextStyle(color: Colors.black, fontWeight: FontWeight.w700);

  static const TextStyle text18orange = TextStyle(
    fontSize: 18,
    fontFamily: "hind_semibold",
    fontWeight: FontWeight.w600,
    color: primaryTextColor,
  );

  static Future<bool> checkInternetConnectivity() async {
    var connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult == ConnectivityResult.mobile ||
        connectivityResult == ConnectivityResult.wifi) {
      return true; // Connected to the internet
    } else {
      return false; // Not connected to the internet
    }
  }


  static void showCustomDialog(BuildContext context, String msg) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(0.0),
            side: BorderSide(color: Color(0x8D000000), width: 2.0), // Adding border to the dialog
          ),

          child: Container(
            color: blackColor,
            padding: EdgeInsets.all(0.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                // Header with "X" icon and "Error" text
                Container(
                  padding: EdgeInsets.all(10.0),
                  color: RedColor,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.close, color: Colors.white),
                      Text(
                        '  Error',
                        style: txSty_20w_fb
                      ),
                      SizedBox(width: 24.0), // Spacer to align text in the center
                    ],
                  ),
                ),
                SizedBox(height: 20.0),
                // Message Text
                Text(
                  msg,
                  textAlign: TextAlign.center,
                  style: text16white,
                ),
                SizedBox(height: 20.0),
                // OK Button
          Padding(
            padding: const EdgeInsets.only(
              bottom: 10.0),
            child:Container(
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
                  child: SizedBox(
                    height: 30.0, // Set the desired height
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.symmetric(horizontal: 35.0),
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20.0),
                        ),
                      ),
                      child: const Text(
                        'OK',
                        style: txSty_16b_fb,
                      ),
                    ),
                  ),

              // ElevatedButton(
              //       onPressed: ()  {
              //         Navigator.of(context).pop();
              //       },
              //
              //       style: ElevatedButton.styleFrom(
              //         padding: EdgeInsets.symmetric(horizontal: 30.0, vertical: 0.0),
              //         backgroundColor: Colors
              //             .transparent, // Transparent to show the gradient
              //         shadowColor:
              //         Colors.transparent, // Remove button shadow
              //         shape: RoundedRectangleBorder(
              //           borderRadius: BorderRadius.circular(20.0),
              //         ),
              //       ),
              //       child: const Text(
              //         'OK',
              //         style: txSty_16b_fb,
              //       ),
              //     ),
                ),
                // ElevatedButton(
                //   onPressed: () {
                //     Navigator.of(context).pop();
                //   },
                //   style: ElevatedButton.styleFrom(
                //     shape: RoundedRectangleBorder(
                //       borderRadius: BorderRadius.circular(12.0),
                //     ),
                //     padding: EdgeInsets.symmetric(horizontal: 30.0, vertical: 10.0),
                //   ),
                //   child: Text('OK'),
                // ),
          )  ],
            ),
          ),
        );
      },
    );
  }


}