import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class OtpActivity extends StatelessWidget {
  final String mobile;

  OtpActivity({required this.mobile});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('OTP Activity'),
      ),
      body: Center(
        child: Text('Mobile Number: $mobile'),
      ),
    );
  }
}