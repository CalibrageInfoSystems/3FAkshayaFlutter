import 'package:akshaya_flutter/common_utils/common_styles.dart';
import 'package:akshaya_flutter/gen/assets.gen.dart';
import 'package:flutter/material.dart';
import 'package:toastification/toastification.dart';

class TestScreen extends StatelessWidget {
  const TestScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ElevatedButton(
          onPressed: () =>
              CommonStyles.showCustomToast(context, title: 'hello'),
          child: const Text('Show Toast')),
    );
  }
}
