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
      Row(
        children: [
          Expanded(
              flex: 5, child: Text(label, style: CommonStyles.txStyF14CwFF6)),
          const Expanded(
              flex: 1, child: Text(':', style: CommonStyles.txStyF14CwFF6)),
          Expanded(
            flex: 5,
            child: Text(
              data,
              style: CommonStyles.txStyF14CwFF6.copyWith(
                color: dataTextColor,
              ),
            ),
          ),
        ],
      ),
      const SizedBox(height: 5),
    ],
  );
}
