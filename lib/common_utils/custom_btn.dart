import 'package:akshaya_flutter/common_utils/common_styles.dart';
import 'package:akshaya_flutter/gen/fonts.gen.dart';
import 'package:flutter/material.dart';

class CustomBtn extends StatelessWidget {
  final String label;
  final double borderRadius;
  final Color borderColor;
  final Color? btnColor;
  final TextStyle? btnTextStyle;
  final double? height;
  final EdgeInsetsGeometry? padding;
  final void Function()? onPressed;
  final Widget? btnChild;
  const CustomBtn({
    super.key,
    required this.label,
    this.borderRadius = 12,
    this.onPressed,
    this.btnTextStyle,
    this.borderColor = CommonStyles.btnBorderColor,
    this.padding = const EdgeInsets.symmetric(
      horizontal: 20,
    ),
    this.height = 40.0,
    this.btnColor,
    this.btnChild,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        height: height,
        alignment: Alignment.center,
        padding: padding,
        decoration: BoxDecoration(
          color: btnColor,
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
        child: btnChild ??
            Text(
              label,
              style: btnTextStyle ??
                  const TextStyle(
                    fontSize: 14,
                    fontFamily: FontFamily.hind,
                    fontWeight: FontWeight.w600,
                    color: CommonStyles.primaryTextColor,
                  ),
            ),
      ),
    );
  }
}
