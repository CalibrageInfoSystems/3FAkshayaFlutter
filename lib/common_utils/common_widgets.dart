import 'package:akshaya_flutter/common_utils/common_styles.dart';
import 'package:akshaya_flutter/localization/locale_keys.dart';
import 'package:auto_animated/auto_animated.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

class CommonWidgets {
  static Widget commonRow({
    required String label,
    required String data,
    Color? labelTextColor,
    Color? dataTextColor = CommonStyles.dataTextColor,
    bool isColon = false,
    TextStyle? style,
    bool isSpace = true,
    List<int> flex = const [6, 1, 7],
  }) {
    return Column(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: flex[0],
              child: Text(
                label,
                style: style ??
                    CommonStyles.txStyF14CbFF6.copyWith(
                      color: labelTextColor,
                    ),
              ),
            ),
            isColon
                ? Expanded(
                    flex: flex[1],
                    child: Text(
                      ':',
                      style: style ?? CommonStyles.txStyF14CbFF6,
                    ))
                : const SizedBox(width: 10),
            Expanded(
              flex: flex[2],
              child: Text(
                data,
                style: style ??
                    CommonStyles.txStyF14CbFF6.copyWith(
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
          crossAxisAlignment: CrossAxisAlignment.start,
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
                textAlign: TextAlign.center,
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
                color: CommonStyles.listOddColor,
              ),
              child: Text(
                tr(LocaleKeys.complete_details),
                style: CommonStyles.txStyF16CbFF6.copyWith(
                    color: CommonStyles.viewMoreBtnTextColor,
                    fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ],
      ),
    );
  }

  static Widget customSlideAnimation(
      {required int itemCount,
      bool isSeparatorBuilder = false,
      required Widget Function(int index) childBuilder}) {
    return LiveList.options(
      options: const LiveOptions(
        delay: Duration(milliseconds: 100),
        showItemInterval: Duration(milliseconds: 100),
        showItemDuration: Duration(milliseconds: 500),
        reAnimateOnVisibility: false,
      ),
      itemCount: itemCount,
      separatorBuilder: (context, index) =>
          isSeparatorBuilder ? const SizedBox(height: 10) : const SizedBox(),
      itemBuilder: (context, index, animation) {
        return FadeTransition(
          opacity: animation,
          child: SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0, 0.3),
              end: Offset.zero,
            ).animate(animation),
            child: childBuilder(index),
          ),
        );
      },
    );
  }

  static Future<void> launchDatePicker(
    BuildContext context, {
    DateTime? initialDate,
    Function(DateTime? pickedDay)? onDateSelected,
  }) async {
    final DateTime currentDate = DateTime.now();
    final DateTime firstDate = DateTime(currentDate.year - 100);
    final DateTime? pickedDay = await showDatePicker(
        context: context,
        initialDate: initialDate ?? DateTime.now(),
        initialEntryMode: DatePickerEntryMode.calendarOnly,
        firstDate: firstDate,
        lastDate: currentDate,
        initialDatePickerMode: DatePickerMode.day,
        confirmText: tr(LocaleKeys.ok),
        cancelText: tr(LocaleKeys.cancel_capitalized));
    onDateSelected?.call(pickedDay);
  }

  static customDivider(
      {double? height = 0.5, Color? color = const Color(0xFFe86100)}) {
    return Container(
      height: height,
      color: color,
    );
  }
}
