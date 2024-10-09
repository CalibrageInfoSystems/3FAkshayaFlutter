import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import '../gen/assets.gen.dart';
import '../screens/main_screen.dart';
import 'common_styles.dart';
import 'custom_btn.dart';

class SuccessDialog2 extends StatelessWidget {

  final String title;

  const SuccessDialog2({super.key,  required this.title});


  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: const RoundedRectangleBorder(
        //  borderRadius: BorderRadius.circular(20.0),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              // Top Container with icon
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
                  ],
                ),
              ),

              const SizedBox(height: 10.0),

              // Content Container
              Flexible(
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    maxHeight: MediaQuery.of(context).size.height * 0.6,
                  ),
                  child: SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            title,
                            style: CommonStyles.txStyF16CpFF6
                                .copyWith(fontSize: 18),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 20.0),

                          // Scrollable ListView


                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              CustomBtn(
                                label: 'Ok',
                                onPressed: () {
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (context) => const MainScreen(),
                                    ),
                                  );
                                },
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  String formattedProducts(String value) {
    List<String> items = value.split(',').map((item) => item.trim()).toList();

    return items.join(',\n');
  }
}