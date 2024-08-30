import 'package:akshaya_flutter/common_utils/common_styles.dart';
import 'package:akshaya_flutter/gen/assets.gen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final String? actionIcon;
  final void Function()? onTap;

  const CustomAppBar({
    super.key,
    required this.title,
    this.actionIcon,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: CommonStyles.gradientColor1,
      leading: GestureDetector(
        onTap: () {
          Navigator.pop(context);
        },
        child: Image.asset(Assets.images.icLeft.path),
      ),
      elevation: 0,
      title: Text(
        title,
        style: CommonStyles.txSty_14black_f5.copyWith(
          color: CommonStyles.whiteColor,
        ),
      ),
      actions: [
        GestureDetector(
          onTap: onTap,
          child: SvgPicture.asset(
            actionIcon ?? Assets.images.icHome.path,
            width: 20,
            height: 20,
            color: Colors.black,
            fit: BoxFit.contain,
          ),
        ),
        const SizedBox(width: 10),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
