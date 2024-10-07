// import 'package:akshaya_flutter/common_utils/common_styles.dart';
// import 'package:akshaya_flutter/common_utils/custom_appbar.dart';
// import 'package:akshaya_flutter/common_utils/custom_btn.dart';
// import 'package:flutter/material.dart';

// class FarmerPassbookScreen extends StatelessWidget {
//   const FarmerPassbookScreen({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: const CustomAppBar(title: 'Farmer Passbook'),
//       body: Center(
//         child: Card(
//           shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.circular(8.0),
//           ),
//           color: Colors.grey[700],
//           child: Padding(
//             padding: const EdgeInsets.all(16.0),
//             child: Column(
//               mainAxisSize: MainAxisSize.min,
//               crossAxisAlignment: CrossAxisAlignment.center,
//               children: [
//                 const Icon(
//                   Icons.account_balance,
//                   size: 50,
//                   color: Colors.white,
//                 ),
//                 const SizedBox(height: 8),
//                 const Text('Bank Details', style: CommonStyles.txSty_20w_fb),
//                 const SizedBox(height: 8),
//                 const Divider(
//                   color: CommonStyles.primaryTextColor,
//                   thickness: 1,
//                   endIndent: 10,
//                   // indent: 10,
//                 ),
//                 const SizedBox(height: 16),
//                 _buildDetailRow(
//                     'Account Holder Name', 'Nekkanti Venkat Rao Ji'),
//                 _buildDetailRow('Account Number', '866810100004399'),
//                 _buildDetailRow('Bank Name', 'Bank of India'),
//                 _buildDetailRow('Branch Name', 'Dubacherla'),
//                 _buildDetailRow('IFSC Code', 'BKID0008668'),
//                 const SizedBox(height: 16),
//                 const Row(
//                   mainAxisAlignment: MainAxisAlignment.end,
//                   children: [
//                     CustomBtn(
//                       label: 'Next',
//                       // borderColor: CommonStyles.primaryTextColor,
//                       // btnColor: CommonStyles.primaryTextColor,
//                     ),
//                   ],
//                 ),
//                 /* ElevatedButton(
//                   onPressed: () {},
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: Colors.orange,
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(20.0),
//                     ),
//                     padding: const EdgeInsets.symmetric(
//                         horizontal: 30, vertical: 12),
//                   ),
//                   child: const Text('Next'),
//                 ), */
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildDetailRow(String label, String value) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(vertical: 6.0),
//       child: Row(
//         children: [
//           Expanded(
//             flex: 3,
//             child: Text(
//               label,
//               style: CommonStyles.txSty_12W_fb,
//             ),
//           ),
//           const Expanded(
//             flex: 1,
//             child: Text(
//               ':',
//               style: CommonStyles.txSty_12W_fb,
//             ),
//           ),
//           Expanded(
//             flex: 3,
//             child: Text(
//               value,
//               style: CommonStyles.txSty_12W_fb,
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
