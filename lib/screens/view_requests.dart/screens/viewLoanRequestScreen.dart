import 'package:flutter/material.dart';

class viewLoanRequestScreen extends StatefulWidget {
  const viewLoanRequestScreen({super.key});

  @override
  _LoanRequestViewState createState() => _LoanRequestViewState();
}

class _LoanRequestViewState extends State<viewLoanRequestScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Loan Request"),
      ),
      body: const Stack(),
    );
  }
}
