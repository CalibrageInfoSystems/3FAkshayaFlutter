import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class viewQuickPayScreen extends StatefulWidget {


  viewQuickPayScreen();

  @override
  _QuickPayRequestViewState createState() => _QuickPayRequestViewState();
}

class _QuickPayRequestViewState extends State<viewQuickPayScreen> {


  @override
  void initState() {
    super.initState();

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Quick Pay Request"),

      ),
      body: Stack(

      ),
    );
  }
}
