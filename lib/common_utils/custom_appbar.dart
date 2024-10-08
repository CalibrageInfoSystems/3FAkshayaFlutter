import 'package:akshaya_flutter/common_utils/common_styles.dart';
import 'package:akshaya_flutter/gen/assets.gen.dart';
import 'package:akshaya_flutter/screens/main_screen.dart';
import 'package:flutter/material.dart';

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
      backgroundColor: appBarColor,
      scrolledUnderElevation: 0,
      leading: GestureDetector(
        onTap: () {
          Navigator.pop(context);
        },
        child: Image.asset(Assets.images.icLeft.path),
      ),
      elevation: 0,
      title: Text(
        title,
        textAlign: TextAlign.center,
        style: CommonStyles.txStyF16CwFF6,
      ),
      actions: [
        actionIcon ??
            IconButton(
              icon: const Icon(
                Icons.home,
                color: Colors.white,
              ),
              onPressed: onPressed ??
                  () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const MainScreen(),
                      ),
                    );
                  },
            ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
