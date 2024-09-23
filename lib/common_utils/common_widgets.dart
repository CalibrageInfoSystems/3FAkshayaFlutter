import 'package:akshaya_flutter/common_utils/common_styles.dart';
import 'package:flutter/material.dart';

class CommonWidgets {
  static Widget commonRow({
    required String label,
    required String data,
    Color? labelTextColor,
    Color? dataTextColor = CommonStyles.dataTextColor,
  }) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              flex: 4,
              child: Text(
                label,
                style: CommonStyles.txSty_14b_f5.copyWith(
                  color: labelTextColor,
                ),
              ),
            ),
            Expanded(
              flex: 6,
              child: Text(
                data,
                style: CommonStyles.txF14Fw5Cb.copyWith(
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
      bool isSpace = true}) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
                flex: 5,
                child: Text(
                  label,
                  style: CommonStyles.txStyF14CbFF6,
                )),
            const Expanded(
              flex: 1,
              child: Text(
                ':',
                style: CommonStyles.txStyF14CbFF6,
              ),
            ),
            Expanded(
              flex: 6,
              child: Text(
                data,
                style: CommonStyles.txStyF14CbFF6.copyWith(
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
            padding: const EdgeInsets.symmetric(horizontal: 10),
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
                'Click Here to See Complete Details',
                style: CommonStyles.txStyF16CbFF6.copyWith(
                    color: CommonStyles.viewMoreBtnTextColor, fontSize: 18),
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
