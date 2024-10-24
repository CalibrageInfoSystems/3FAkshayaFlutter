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
                width: 30,
                height: 30,
                Assets.images.homeIcon2.path,
              ),
        ),
        const SizedBox(width: 20),
        /*  SvgPicture.asset(
              'assets/images/home_icon.svg',
              width: 25,
              height: 25,
              fit: BoxFit.contain,
              color: Colors.red,
            ), */
        /*  IconButton(
              icon: SvgPicture.asset( 
                Assets.images.homeIcon.path,
                // width: 25,
                // height: 25,
                fit: BoxFit.contain,
                color: Colors.red,
              ),

              /*  const Icon(
                Icons.home,
                color: Colors.white,
              ), */
              onPressed: onPressed ??
                  () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const MainScreen(),
                      ),
                    );
                  },
            ), */
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
