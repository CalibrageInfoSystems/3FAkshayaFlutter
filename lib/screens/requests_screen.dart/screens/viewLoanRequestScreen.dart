import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class viewLoanRequestScreen extends StatefulWidget {


  viewLoanRequestScreen();

  @override
  _LoanRequestViewState createState() => _LoanRequestViewState();
}

class _LoanRequestViewState extends State<viewLoanRequestScreen> {


  @override
  void initState() {
    super.initState();

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Loan Request"),

      ),
      body: Stack(

      ),
    );
  }
}
