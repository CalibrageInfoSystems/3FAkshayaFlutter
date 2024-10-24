import 'package:akshaya_flutter/common_utils/custom_btn.dart';
import 'package:akshaya_flutter/localization/locale_keys.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import '../Services/models/MsgModel.dart';
import '../gen/assets.gen.dart';
import '../screens/main_screen.dart';
import 'common_styles.dart';

class SuccessDialog extends StatelessWidget {
  final List<MsgModel> msg;
  final String title;

  const SuccessDialog({super.key, required this.msg, required this.title});

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
                padding: const EdgeInsets.all(15.0),
                color: CommonStyles.successDialogHeaderColor,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SvgPicture.asset(
                      Assets.images.progressComplete.path,
                      width: 50,
                      height: 50,
                      fit: BoxFit.contain,
                      color: CommonStyles.whiteColor,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 10.0),

              // Content Container
              Flexible(
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    maxWidth: MediaQuery.of(context).size.width * 0.8,
                    maxHeight: MediaQuery.of(context).size.height * 0.6,
                  ),
                  child: SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
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
                          ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: msg.length,
                            itemBuilder: (context, index) {
                              return Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(
                                    flex: 1,
                                    child: Text(
                                      msg[index].key,
                                      style:
                                          CommonStyles.txStyF14CrFF6.copyWith(
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 20.0),
                                  Expanded(
                                    flex: 1,
                                    child: index != 1
                                        ? Text(
                                            msg[index].value,
                                            style: CommonStyles.txStyF14CrFF6
                                                .copyWith(
                                              fontWeight: FontWeight.w500,
                                              color: CommonStyles.dataTextColor,
                                            ),
                                          )
                                        : Text(
                                            formattedProducts(msg[index].value),
                                            style: CommonStyles.txStyF14CrFF6
                                                .copyWith(
                                              fontWeight: FontWeight.w500,
                                              color: CommonStyles.dataTextColor,
                                            ),
                                          ),
                                  ),
                                ],
                              );
                            },
                          ),
                          const SizedBox(height: 10.0),

                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              CustomBtn(
                                label: tr(LocaleKeys.ok),
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 30),
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
