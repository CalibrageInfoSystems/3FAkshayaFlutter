import 'package:akshaya_flutter/common_utils/common_styles.dart';
import 'package:akshaya_flutter/localization/locale_keys.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

class CommonWidgets {
  static Widget commonRow({
    required String label,
    required String data,
    Color? labelTextColor,
    Color? dataTextColor = CommonStyles.dataTextColor,
    bool isColon = false,
    List<int> flex = const [6, 1, 7],
  }) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              flex: flex[0],
              child: Text(
                label,
                style: CommonStyles.txStyF14CbFF6.copyWith(
                  color: labelTextColor,
                ),
              ),
            ),
            isColon
                ? Expanded(
                    flex: flex[1],
                    child: const Text(
                      ':',
                      style: CommonStyles.txStyF14CbFF6,
                    ))
                : const SizedBox(width: 10),
            Expanded(
              flex: flex[2],
              child: Text(
                data,
                style: CommonStyles.txStyF14CbFF6.copyWith(
                  color: dataTextColor,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
      ],
    );
  }

  static Widget commonRowWithColon(
      {required String label,
      required String data,
      Color? dataTextColor,
      TextAlign? textAlign = TextAlign.start,
      TextStyle? style = CommonStyles.txStyF14CbFF6,
      List<int> flex = const [5, 1, 6],
      bool isSpace = true}) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
                flex: flex[0],
                child: Text(
                  label,
                  textAlign: textAlign,
                  style: style,
                )),
            Expanded(
              flex: flex[1],
              child: Text(
                ':',
                style: style,
              ),
            ),
            Expanded(
              flex: flex[2],
              child: Text(
                data,
                textAlign: textAlign,
                style: style?.copyWith(
                  color: dataTextColor,
                ),
              ),
            ),
          ],
        ),
        if (isSpace) const SizedBox(height: 10),
      ],
    );
  }

  static Widget viewTemplate({
    Color? bgColor = Colors.white,
    required Widget child,
    void Function()? onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(5),
        color: bgColor,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 10).copyWith(top: 10),
            child: child,
          ),
          GestureDetector(
            onTap: onTap,
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 10),
              alignment: Alignment.center,
              decoration: const BoxDecoration(
                // borderRadius: BorderRadius.circular(10),
                color: CommonStyles.listOddColor,
              ),
              child: Text(
                tr(LocaleKeys.complete_details),
                style: CommonStyles.txStyF16CbFF6.copyWith(
                    color: CommonStyles.viewMoreBtnTextColor,
                    fontSize: 18,
                    fontWeight: FontWeight.w600),
                /*  style: TextStyle(
                    fontWeight: FontWeight.w600), */
              ),
            ),
          ),
        ],
      ),
    );
  }
}
