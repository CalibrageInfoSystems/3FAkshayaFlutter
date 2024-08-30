import 'package:akshaya_flutter/common_utils/common_styles.dart';
import 'package:flutter/material.dart';

class CustomBtn extends StatelessWidget {
  final String label;
  final double borderRadius;
  final Color? btnColor;
  final Color? backgroundColor;
  final Color? borderColor;
  final void Function()? onPressed;
  const CustomBtn(
      {super.key,
      required this.label,
      this.borderRadius = 12,
      this.onPressed,
      this.btnColor,
      this.backgroundColor = Colors.white,
      this.borderColor});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor,
          // shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadius),
            side: BorderSide(color: borderColor ?? Colors.grey),
          ),
        ),
        child: Text(label,
            style: CommonStyles.txSty_14p_f5.copyWith(color: btnColor)));
  }
}
