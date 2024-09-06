import 'package:akshaya_flutter/common_utils/common_styles.dart';
import 'package:flutter/material.dart';

// class CustomBtn extends StatelessWidget {
//   final String label;
//   final double borderRadius;
//   final Color borderColor;
//   final Color? backgroundColor;
//   final void Function()? onPressed;
//   const CustomBtn({
//     super.key,
//     required this.label,
//     this.borderRadius = 12,
//     this.onPressed,
//     this.backgroundColor = Colors.transparent,
//     this.borderColor = const Color(0xFFe86100),
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       height: 40.0,
//       padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
//       decoration: BoxDecoration(
//         borderRadius: BorderRadius.circular(borderRadius),
//         gradient: const LinearGradient(
//           begin: Alignment.topCenter,
//           end: Alignment.bottomCenter,
//           colors: [
//             Color(0xFFCCCCCC), // Start color (light gray)
//             Color(0xFFFFFFFF), // Center color (white)
//             Color(0xFFCCCCCC), // End color (light gray)
//           ],
//         ),
//         border: Border.all(
//           color: borderColor,
//           width: 2.0,
//         ),
//       ),
//       child: ElevatedButton(
//         onPressed: onPressed,
//         style: ElevatedButton.styleFrom(
//           padding: const EdgeInsets.symmetric(vertical: 0),
//           backgroundColor: backgroundColor,
//           shadowColor: Colors.transparent, // Remove button shadow
//           shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.circular(16.0),
//           ),
//         ),
//         child: Text(label, style: CommonStyles.txSty_14p_f5),
//       ),
//     );
//   }
// }
class CustomBtn extends StatelessWidget {
  final String label;
  final double borderRadius;
  final Color borderColor;
  final Color? backgroundColor;
  final void Function()? onPressed;
  final bool isLoading; // New property to manage loading state

  const CustomBtn({
    super.key,
    required this.label,
    this.borderRadius = 12,
    this.onPressed,
    this.backgroundColor = Colors.transparent,
    this.borderColor = const Color(0xFFe86100),
    this.isLoading = false, // Default loading state is false
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 40.0,
      padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(borderRadius),
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFFCCCCCC), // Start color (light gray)
            Color(0xFFFFFFFF), // Center color (white)
            Color(0xFFCCCCCC), // End color (light gray)
          ],
        ),
        border: Border.all(
          color: borderColor,
          width: 2.0,
        ),
      ),
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed, // Disable button if loading
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 0),
          backgroundColor: backgroundColor,
          shadowColor: Colors.transparent, // Remove button shadow
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.0),
          ),
        ),
        child: isLoading
            ? const SizedBox(
          height: 20,
          width: 20,
          child: CircularProgressIndicator(
            strokeWidth: 2.0,
            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
          ),
        )
            : Text(label, style: CommonStyles.txSty_14p_f5),
      ),
    );
  }
}
