import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class viewLabourRequestScreen extends StatefulWidget {


  viewLabourRequestScreen();

  @override
  _LabourRequestViewState createState() => _LabourRequestViewState();
}

class _LabourRequestViewState extends State<viewLabourRequestScreen> {


  @override
  void initState() {
    super.initState();

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Labour Request"),

      ),
      body: Stack(

      ),
    );
  }
}
