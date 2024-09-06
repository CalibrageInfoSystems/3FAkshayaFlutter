import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import '../Services/product_card_screen.dart';
import '../gen/assets.gen.dart';
import '../screens/main_screen.dart';
import 'common_styles.dart';

class SuccessDialog extends StatelessWidget {
  final List<MsgModel> msg;
  final String summary;

  SuccessDialog({required this.msg, required this.summary});

  @override
  Widget build(BuildContext context) {
    return Dialog(
        shape: RoundedRectangleBorder(
          //  borderRadius: BorderRadius.circular(20.0),
        ),
        child: Container(
          // padding: EdgeInsets.all(20.0),
          child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                // Header with "X" icon and "Error" text
                Container(
                  padding: const EdgeInsets.all(10.0),
                  color: CommonStyles.primaryTextColor,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SvgPicture.asset(
                        Assets.images.progressComplete.path,
                        width: 30,
                        height: 30,
                        fit: BoxFit.contain,
                        color: Colors.white,
                      ),
                     // Image.asset(Assets.images.progressComplete.path,color: Colors.white,), // Corrected from Icon to Image.asset
                     // const SizedBox(width: 24.0), // Spacer to align text in the center
                    ],
                  ),
                ),


                const SizedBox(height: 20.0),
                // Message Text

                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
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
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (context) => MainScreen(),
                                  ),
                                );
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
              ]),));
  }
}