import 'package:akshaya_flutter/common_utils/common_styles.dart';
import 'package:flutter/material.dart';

class CustomBtn extends StatelessWidget {
  final String label;
  final double borderRadius;
  final Color borderColor;
  final TextStyle? btnTextStyle;
  final EdgeInsetsGeometry? padding;
  final void Function()? onPressed;
  const CustomBtn({
    super.key,
    required this.label,
    this.borderRadius = 12,
    this.onPressed,
    this.btnTextStyle = CommonStyles.txStyF12CpFF6,
    this.borderColor = const Color(0xFFe86100),
    this.padding = const EdgeInsets.symmetric(
      horizontal: 20,
    ),
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        height: 40.0,
        alignment: Alignment.center,
        padding: padding,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(borderRadius),
          gradient: const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFCCCCCC),
              Color(0xFFFFFFFF),
              Color(0xFFCCCCCC),
            ],
          ),
          border: Border.all(
            color: borderColor,
            width: 2.0,
          ),
        ),
        child: Text(
          label,
          style: btnTextStyle,
        ),
      ),
    );
  }
}
