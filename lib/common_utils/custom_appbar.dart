import 'package:akshaya_flutter/common_utils/common_styles.dart';
import 'package:akshaya_flutter/gen/assets.gen.dart';
import 'package:akshaya_flutter/screens/main_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final Widget? actionIcon;
  final Color? appBarColor;
  final void Function()? onPressed;

  const CustomAppBar({
    super.key,
    required this.title,
    this.actionIcon,
    this.appBarColor = CommonStyles.appBarColor,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      shape: const RoundedRectangleBorder(
          side: BorderSide(
        color: Colors.transparent,
      )),
      backgroundColor: appBarColor,
      elevation: 0,
      scrolledUnderElevation: 0,
      leading: GestureDetector(
        onTap: () {
          Navigator.pop(context);
        },
        child: Image.asset(Assets.images.icLeft.path),
      ),
      title: Text(
        title,
        textAlign: TextAlign.center,
        style: CommonStyles.txStyF16CwFF6,
      ),
      actions: [
        GestureDetector(
          onTap: onPressed ??
              () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const MainScreen(),
                  ),
                );
              },
          child: actionIcon ??
              Image.asset(
                // width: 30,
                // height: 30,
                width: 24,
                height: 24,
                Assets.images.homeIcon2.path,
              ),
        ),
        const SizedBox(width: 20),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
