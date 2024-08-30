import 'package:akshaya_flutter/models/TransportationCharge.dart';
import 'package:flutter/cupertino.dart';

class DataProvider with ChangeNotifier {
  String _data1 = "fromdate";
  String _data2 = "todate";
  String _data3 = "farmercode";
  List<TransportRate> _transportrate=[];
  List<TransportationCharge> _transportationcharge=[];

  String get data1 => _data1;
  String get data2 => _data2;
  String get data3 => _data3;
  List<TransportRate> get transportratelist => _transportrate;
  List<TransportationCharge> get transportchargelist => _transportationcharge;

  void updateData(String newData1, String newData2, String newData3,List<TransportRate> transportrate,List<TransportationCharge> transportationCharge) {
    _data1 = newData1;
    _data2 = newData2;
    _data3 = newData3;
    _transportrate =transportrate;
    _transportationcharge =transportationCharge;

    notifyListeners();
  }
}