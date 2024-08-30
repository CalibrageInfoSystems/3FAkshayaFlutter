import 'package:akshaya_flutter/common_utils/common_styles.dart';
import 'package:flutter/material.dart';

Widget custombox({
  required String label,
  required String data,
  Color? dataTextColor,
  Color? labelTextColor,
}) {
  return Column(
    children: [
      Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          children: [
            Expanded(
                flex: 5,
                child: Text(
                  label,
                  style: CommonStyles.txSty_14b_f5.copyWith(
                    color: labelTextColor,
                  ),
                )),
            const Expanded(flex: 1, child: Text(':')),
            Expanded(
                flex: 5,
                child: Text(
                  data,
                  style: CommonStyles.txF14Fw5Cb.copyWith(
                    color: dataTextColor,
                  ),
                )),
          ],
        ),
      ),
      const SizedBox(height: 5),
    ],
  );
}
