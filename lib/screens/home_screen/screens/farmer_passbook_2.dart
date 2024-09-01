import 'dart:convert';
import 'dart:io';
import 'package:akshaya_flutter/common_utils/SharedPreferencesHelper.dart';
import 'package:akshaya_flutter/common_utils/api_config.dart';
import 'package:akshaya_flutter/common_utils/common_styles.dart';
import 'package:akshaya_flutter/common_utils/custom_appbar.dart';
import 'package:akshaya_flutter/common_utils/custom_btn.dart';
import 'package:akshaya_flutter/common_utils/shared_prefs_keys.dart';
import 'package:akshaya_flutter/localization/locale_keys.dart';
import 'package:akshaya_flutter/models/PaymentDetailsResponse.dart';
import 'package:akshaya_flutter/models/TransportationCharge.dart';
import 'package:akshaya_flutter/screens/home_screen/screens/DataProvider.dart';
import 'package:device_info_plus/device_info_plus.dart';

// import 'package:device_info/device_info.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_custom_month_picker/flutter_custom_month_picker.dart';
import 'package:http/http.dart' as http;

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:open_filex/open_filex.dart';

class farmer_passbook_2 extends StatefulWidget {
  //  FarmerInfo farmerinfo;
  // farmer_passbook_2({required this.farmerinfo});
  String accountHolderName;
  String accountNumber;
  String bankName;
  String branchName;
  String district;
  String farmerCode;
  String guardianName;
  String ifscCode;
  String mandal;
  String state;
  String village;

  farmer_passbook_2(
      {required this.accountHolderName,
      required this.accountNumber,
      required this.bankName,
      required this.branchName,
      required this.district,
      required this.farmerCode,
      required this.guardianName,
      required this.ifscCode,
      required this.mandal,
      required this.state,
      required this.village});

  @override
  _farmer_passbook_2 createState() => _farmer_passbook_2();
}

class _farmer_passbook_2 extends State<farmer_passbook_2> with SingleTickerProviderStateMixin {
  String selectedValue = 'Option 1';
  double? selectedPosition = 0.0;
  bool datesavaiablity = false;
  String fc = '';
  TextEditingController fromDateController = TextEditingController();
  TextEditingController toDateController = TextEditingController();
  DateTime? fromDate;
  DateTime? toDate;
  String fromFormattedDate = ''; // Declare fromFormattedDate
  String toFormattedDate = '';
  String vendorcode = '';
  List<PaymentResponse> paymentDetailsResponse_list = [];
  String totalquantityffb = '';
  String closingbalance = '';
   double totalBalance=0.0, totalQuanitity=0.0, totalGRAmount=0.0, totalAdjusted=0.0, totalAmount=0.0;
  String? fromdatetosendtab2;
  String? todatetosendtab2;
  String? farmercode;
  String? modifiedCode;
  List<TransportationCharge> _transportationCharges = [];
  List<TransportRate> _transportRates = [];

  @override
  void initState() {
    listofdetails();
    checkStoragePermission();
  }

  listofdetails() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final farmerCode = prefs.getString(SharedPrefsKeys.farmerCode);
    setState(() {
      farmercode = farmerCode;
      modifiedCode = "V" + farmercode!.substring(2);
      print('modifiedCode$modifiedCode');
      callApiMethod(selectedPosition!, modifiedCode!);
    });
  }

  // listofdetails() async {
  //   final loadedData = await SharedPreferencesHelper.getCategories();
  //   if (loadedData != null) {
  //     final farmerDetails = loadedData['result']['farmerDetails'];
  //     final loadedfarmercode = farmerDetails[0]['code'];
  //     setState(() {
  //       fc = loadedfarmercode;
  //       print('fcinfarmer_passsbook--$fc');
  //       selectedPosition = 0; //// Initialize selectedPosition to 0
  //
  //       // get30days();
  //       vendorcode = 'V' + '$fc';
  //       print('vendorcode--$vendorcode');
  //       callApiMethod(selectedPosition!, vendorcode);
  //     });
  //   }
  // }

  void updateData(String fromdate, String todate, String farmercode) {
    setState(() {
      // sharedData = newData;
      fromdatetosendtab2 = fromdate;
      todatetosendtab2 = fromdate;
      fc = farmercode;
    });
  }

  Future<void> callApiMethod(double position, String vc) async {
    setState(() {
      datesavaiablity = false;
      //  isLoading = true;
    });

    if (position == 0.0) {
      setState(() {
        datesavaiablity = false;
      });

      // Calculate the date range for the "Last 30 Days" option
      DateTime currentDate = DateTime.now();
      DateTime startDate = currentDate.subtract(Duration(days: 30));
      DateFormat dateFormat = DateFormat('yyyy-MM-dd');
      DateFormat dateFormat1 = DateFormat('yyyy-MM-dd');

      // Convert DateTime to String
      String currentDateString = dateFormat.format(currentDate);
      String startDateString = dateFormat1.format(startDate);

      setState(() {
        fromdatetosendtab2 = currentDateString;
        todatetosendtab2 = startDateString;
        _transportRates.clear();
        _transportationCharges.clear();
        Provider.of<DataProvider>(context, listen: false)
            .updateData(fromdatetosendtab2!, todatetosendtab2!, modifiedCode!, _transportRates, _transportationCharges);
        closingbalance = '';
        totalquantityffb = '';
        paymentlistapi(currentDate, startDate, modifiedCode!);
        //  transportlistapi(currentDate, startDate, vc);
      });

      print('Date range for   Last 30 Days: ${dateFormat.format(startDate)} to ${dateFormat.format(currentDate)}');
    } else if (position == 1.0) {
      setState(() {
        datesavaiablity = false;
      });

      // Calculate the date range for the "Last 3 Months" option
      DateTime currentDate = DateTime.now();
      //  DateTime startDate = DateTime(currentDate.year, currentDate.month - 3, currentDate.day);
      DateTime startDate = DateTime(currentDate.year, currentDate.month - 3, 1).month > 0
          ? DateTime(currentDate.year, currentDate.month - 3, 1)
          : DateTime(currentDate.year - 1, 12 + (currentDate.month - 3), 1);

      DateFormat dateFormat = DateFormat('yyyy-MM-dd');
      String strstartdate = dateFormat.format(startDate);
      String strtodate = dateFormat.format(currentDate);

      setState(() {
        fromdatetosendtab2 = strstartdate;
        todatetosendtab2 = strtodate;
        Provider.of<DataProvider>(context, listen: false)
            .updateData(fromdatetosendtab2!, todatetosendtab2!, modifiedCode!, _transportRates, _transportationCharges);
        print('Date range for Last 3 Months: ${dateFormat.format(startDate)} to ${dateFormat.format(currentDate)}');
        paymentDetailsResponse_list.clear();
        _transportRates.clear();
        _transportationCharges.clear();
        closingbalance = '';
        totalquantityffb = '';
        paymentlistapi(currentDate, startDate, modifiedCode!);
        //  transportlistapi(currentDate!, startDate!, vc);
      });
    } else if (position == 2.0) {
      datesavaiablity = false;

      // Calculate the date range for the "Last 1 Year" option
      DateTime currentDate = DateTime.now();
      DateTime startDate = DateTime(currentDate.year - 1, currentDate.month, currentDate.day);
      DateFormat dateFormat = DateFormat('yyyy-MM-dd');
      String strfystartdate = dateFormat.format(startDate);
      String strfytodate = dateFormat.format(currentDate);

      setState(() {
        fromdatetosendtab2 = strfystartdate;
        todatetosendtab2 = strfytodate;
        Provider.of<DataProvider>(context, listen: false)
            .updateData(fromdatetosendtab2!, todatetosendtab2!, modifiedCode!, _transportRates, _transportationCharges);
        paymentDetailsResponse_list.clear();
        _transportRates.clear();
        _transportationCharges.clear();
        closingbalance = '';
        totalquantityffb = '';
        paymentlistapi(currentDate, startDate, modifiedCode!);
        // transportlistapi(currentDate, startDate, vc);
      });

      print('Date range for Last 1 Year: ${dateFormat.format(startDate)} to ${dateFormat.format(currentDate)}');
    } else if (position == 3.0) {
      // fromDate =null;
      // toDate=null;

      setState(() {
        fromDateController.clear();
        toDateController.clear();
        closingbalance = '';
        totalquantityffb = '';
        paymentDetailsResponse_list.clear();
        _transportRates.clear();
        _transportationCharges.clear();
        datesavaiablity = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // double screenWidth = MediaQuery.of(context).size.width;
    // double containerWidth = (screenWidth - 35.0) / 2;
    List<double>? dynamicStops = calculateDynamicStops(selectedPosition!);

    return Scaffold(
        // appBar: AppBar(
        //   title: Text("Farmer PassBook"),
        //   // leading: IconButton(
        //   //   icon: Image.asset('assets/ic_left.png'),
        //   //   onPressed: () {
        //   //     Navigator.of(context).pop();
        //   //   },
        //   // ),
        //   elevation: 0,
        //   flexibleSpace: Container(
        //     decoration: BoxDecoration(
        //       gradient: LinearGradient(
        //         begin: Alignment.topCenter,
        //         end: Alignment.bottomCenter,
        //         stops: [1.0, 0.4],
        //         colors: [Color(0xFFDB5D4B), Color(0xFFE39A63)],
        //       ),
        //     ),
        //   ),
        // ),
              appBar:  CustomAppBar(title: 'Farmer Passbook'),

    body: SingleChildScrollView(
            child: Container(
          //height: MediaQuery.of(context).size.height,
          child: Column(children: [
            Container(
                width: double.infinity,
                child: Column(
                  children: [
                    Container(
                      alignment: Alignment.topCenter,
                      padding: EdgeInsets.only(top: 0.0, left: 12.0, right: 12.0),
                      child: DropdownButtonHideUnderline(
                        child: ButtonTheme(
                          alignedDropdown: true,
                          child: Container(
                            width: double.infinity,
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.white, width: 1.0),
                              borderRadius: BorderRadius.circular(6.0),
                            ),
                            child: DropdownButton<double>(
                              alignment: Alignment.center,
                              value: selectedPosition,
                              iconSize: 22,
                              icon: Icon(
                                Icons.arrow_drop_down,
                                color: Colors.white,
                              ),
                              style: TextStyle(
                                color: Colors.black,
                              ),
                              onChanged: (position) {
                                setState(() {
                                  selectedPosition = position;
                                  print('selectedposition $selectedPosition');
                                });
                                callApiMethod(selectedPosition!, vendorcode);

                                // Now, call your API method based on the selected position
                              },
                              isExpanded: true,
                              items: [
                                DropdownMenuItem<double>(
                                  value: 0.0,
                                  child: Center(
                                    //alignment: Alignment.center,
                                    child: Text(
                                      'Last One Month',
                                      style: TextStyle(
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ),
                                DropdownMenuItem<double>(
                                  value: 1.0,
                                  child: Center(
                                    //alignment: Alignment.center,
                                    child: Text(
                                      'Last Three Months',
                                      style: TextStyle(
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ),
                                DropdownMenuItem<double>(
                                  value: 2.0,
                                  child: Center(
                                    //alignment: Alignment.center,
                                    child: Text(
                                      'Last One Year',
                                      style: TextStyle(
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ),
                                DropdownMenuItem<double>(
                                  value: 3.0,
                                  child: Center(
                                    //alignment: Alignment.center,
                                    child: Text(
                                      'Select Time Period',
                                      style: TextStyle(
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                              dropdownColor: Colors.grey,
                            ),
                          ),
                        ),
                      ),
                    ),
                    Visibility(
                      visible: datesavaiablity,
                      child: Padding(
                        padding: EdgeInsets.only(top: 4.0, left: 12.0, right: 12.0),
                        child: Column(
                          children: [
                            Container(
                              //    padding: EdgeInsets.only(top: 10.0, left: 12.0, right: 12.0, bottom: 10.0),
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 15),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: CommonStyles.whiteColor),
                              ),
                              child: Flex(
                                direction: Axis.horizontal,
                                children: [
                                  Flexible(
                                    flex: 1,
                                    // child:
                                    // GestureDetector(
                                    //   onTap: () {
                                    //
                                    //     _selectDate(context, fromDateController);
                                    //     // Handle From Date tap
                                    //   },
                                    child: TextFormField(
                                      controller: fromDateController,
                                      onTap: () {
                                        _selectDate(context, fromDateController);
                                        print('clickedonfromdate');
                                      },
                                      readOnly: true,
                                      decoration: InputDecoration(
                                        hintText: 'From Date *',
                                        hintStyle: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                        enabled: true,
                                        enabledBorder: UnderlineInputBorder(
                                          borderSide: BorderSide(color: Colors.white),
                                        ),
                                        focusedBorder: UnderlineInputBorder(
                                          borderSide: BorderSide(color: Colors.white),
                                        ),
                                      ),
                                      style: TextStyle(color: Colors.white),
                                    ),
                                    //  ),
                                  ),
                                  SizedBox(
                                    width: 4,
                                  ),
                                  Flexible(
                                    flex: 1,
                                    // child: GestureDetector(
                                    //   onTap: () {
                                    //     // Handle To Date tap
                                    //     print('clickedontodate');
                                    //     _selectDate(context, toDateController);
                                    //   },
                                    child: TextFormField(
                                      onTap: () {
                                        print('clickedontodate');
                                        _selectDate(context, toDateController);
                                      },
                                      readOnly: true,
                                      controller: toDateController,
                                      decoration: InputDecoration(
                                        hintText: 'To Date *',
                                        hintStyle: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                        enabled: true,
                                        enabledBorder: UnderlineInputBorder(
                                          borderSide: BorderSide(color: Colors.white),
                                        ),
                                        focusedBorder: UnderlineInputBorder(
                                          borderSide: BorderSide(color: Colors.white),
                                        ),
                                      ),
                                      style: TextStyle(color: Colors.white),
                                    ),
                                    //  ),
                                  ),
                                  CustomBtn(
                                      label: tr(LocaleKeys.submit),
                                      // label: 'Submit',
                                      onPressed: () {
                                        datevalidation();
                                        //    validateAndSubmit(selectedFromDate, selectedToDate);
                                      }),
                                  // Container(
                                  //   decoration: BoxDecoration(
                                  //     gradient: LinearGradient(
                                  //       colors: [
                                  //         Color(0xFFCCCCCC),
                                  //         Color(0xFFFFFFFF),
                                  //         Color(0xFFCCCCCC),
                                  //       ],
                                  //       begin: Alignment.topCenter,
                                  //       end: Alignment.bottomCenter,
                                  //     ),
                                  //     borderRadius: BorderRadius.circular(10.0),
                                  //     border: Border.all(
                                  //       width: 2.0,
                                  //       color: Color(0xFFe86100),
                                  //     ),
                                  //   ),
                                  //   child: ElevatedButton(
                                  //     onPressed: () async {
                                  //       print('Submit button is clicked');
                                  //       // bool validation = await datevalidation();
                                  //       // if(validation){
                                  //       //   paymentlistapi(currentDate, startDate, vc);
                                  //       // }
                                  //
                                  //
                                  //     },
                                  //     child: Text(
                                  //       'Submit',
                                  //       style: TextStyle(
                                  //         color: Color(0xFFe86100),
                                  //         fontSize: 16,
                                  //         fontFamily: 'hind_semibold',
                                  //       ),
                                  //     ),
                                  //     style: ElevatedButton.styleFrom(
                                  //       backgroundColor: Colors.transparent,
                                  //       elevation: 0,
                                  //       shape: RoundedRectangleBorder(
                                  //         borderRadius: BorderRadius.circular(10.0),
                                  //       ),
                                  //     ),
                                  //   ),
                                  // ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                )),

            DefaultTabController(
              length: 2,
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(
                      top: 10.0,
                      // left: 0.0,
                      // right: 0.0,
                    ),
                    child: TabBar(
                      labelColor: Color(0xFFe86100),
                      unselectedLabelColor: Colors.white,
                      indicator: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(10.0),
                          topRight: Radius.circular(10.0),
                        ),
                      ),
                      tabs: [
                        Tab(
                            child: Container(
                                width: MediaQuery.of(context).size.width,
                                child: Text(
                                  'Farmer Details',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontFamily: 'hind_semibold',
                                  ),
                                ))),

                        Tab(
                            child: Container(
                                width: MediaQuery.of(context).size.width,
                                child: Text(
                                  'Direct Farmer Transport Reimbursement',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontFamily: 'hind_semibold',
                                  ),
                                ))),
                        // Tab(text: 'Direct Farmer Transport Reimbursement'),
                      ],
                    ),
                  ),
                  // SizedBox(
                  //   height: 10.0,
                  // ),

                  // SizedBox(
                  //   height: 10.0,
                  // ),
                  IntrinsicHeight(
                      child: Container(
                          height: MediaQuery.of(context).size.height * 0.75,
                          color: Colors.white,
                          child: IntrinsicHeight(
                            child: TabBarView(
                              children: [
                                //farmer_passbook( payemntlistresp: paymentDetailsResponse_list, totalffbcollections: '$totalquantityffb', closingbalance: '$closingbalance', accountHolderName: '',),
                                farmer_passbook(
                                  payemntlistresp: paymentDetailsResponse_list,
                                  totalffbcollections: '$totalquantityffb',
                                  closingbalance: closingbalance,
                                  accountHolderName: '${widget.accountHolderName}',
                                  accountNumber: '${widget.accountNumber}',
                                  bankName: '${widget.bankName}',
                                  district: '${widget.district}',
                                  farmerCode: '${widget.farmerCode}',
                                  guardianName: '${widget.guardianName}',
                                  ifscCode: '${widget.ifscCode}',
                                  mandal: '${widget.mandal}',
                                  state: '${widget.state}',
                                  village: '${widget.village}',
                                  totalAdjusted: totalAdjusted,
                                  totalAmount: totalAmount,
                                  totalBalance: totalBalance,
                                  totalGRAmount: totalGRAmount,
                                  totalQuanitity: totalQuanitity,
                                  branchname: '${widget.branchName}',
                                ),
                                // Center(
                                //   child: Text('Tab 1 Content'),
                                // ),

                                ///this is tab 2 code
                                // DirectFarmerTransport(FarmerTransportfromdate: '$fromdatetosendtab2', FarmerTransporttodate: '$todatetosendtab2', farmercode: '$fc',)
                                DirectFarmerTransport()
                              ],
                            ),
                          ))),
                ],
              ),
            ),
            // Expanded(
            //   //  child: SingleChildScrollView(
            //   child: Column(
            //     children: [
            //
            //
            //       Expanded(child:
            //      ),
            //     ],
            //   ),
            //   // ),
            // ),
          ]),
          // decoration: BoxDecoration(
          //   gradient: LinearGradient(
          //     begin: Alignment.topCenter,
          //     end: Alignment.bottomCenter,
          //     stops: dynamicStops,
          //     colors: [Color(0xFFDB5D4B), Color(0xFFE39A63), Color(0xFFE39A63), Color(0xFFFFFFF)],
          //   ),
          // ),
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [
                CommonStyles.gradientColor1,
                CommonStyles.gradientColor2,
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
        )));
  }



  Future<void> exportPayments(List<PaymentResponse> paymentResponse, BuildContext context) async {
    // API URL
    String url = 'http://182.18.157.215/3FAkshaya/API/api/Payment/ExportPayments';

    // List of payment responses
    List<Map<String, dynamic>> paymentResponseMaps = paymentResponse.map((response) => response.toJson()).toList();

    // API body data
    Map<String, dynamic> requestBody = {
      "bankDetails": {
        "accountHolderName": "${widget.accountHolderName}",
        "accountNumber": "${widget.accountNumber}",
        "bankName": "${widget.bankName}",
        "branchName": "${widget.branchName}",
        "district": "${widget.district}",
        "farmerCode": "${widget.farmerCode}",
        "guardianName": "${widget.guardianName}",
        "ifscCode": "${widget.ifscCode}",
        "mandal": "${widget.mandal}",
        "state": "${widget.state}",
        "village": "${widget.village}"
      },
      "paymentResponce": paymentResponseMaps,
      "totalAdjusted": totalAdjusted,
      "totalAmount": totalAmount,
      "totalBalance": totalBalance,
      "totalGRAmount": totalGRAmount,
      "totalQuanitity": totalQuanitity
    };

    // Convert the request body to JSON
    String jsonBody = json.encode(requestBody);

    try {
      // Make the POST request
      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonBody,
      );

      // Check if the request was successful
      if (response.statusCode == 200) {
        // Handle the response data here
        print('Response body: ${response.body}');
        String base64string = response.body;
        convertBase64ToExcel(base64string, context);
      } else {
        // Handle the error
        print('Failed to export payments. Status code: ${response.statusCode}');
      }
    } catch (e) {
      // Handle any exceptions that occur during the request
      print('Error: $e');
    }
  }

  // Future<void> convertBase64ToExcel(String base64String, BuildContext context) async {
  //   // Decode the Base64 String
  //   List<int> excelBytes = base64Decode(base64String);
  //
  //   // Get the directory to save the file (external storage for visibility)
  //   Directory? directory = await getExternalStorageDirectory();
  //
  //   // Define the folder and file path
  //   String folderName = 'MyExcelFiles';
  //   Directory newFolder = Directory('${directory!.path}/$folderName');
  //   if (!await newFolder.exists()) {
  //     await newFolder.create(recursive: true);
  //     print('Folder created at ${newFolder.path}');
  //   }
  //
  //   String filePath = '${newFolder.path}/output.xlsx';
  //   print('filePath $filePath');
  //
  //   // Write the data to the file
  //   File file = File(filePath);
  //   await file.writeAsBytes(excelBytes);
  //   print('File saved at $filePath');
  //
  //   // Notify the media scanner (Android only)
  //   if (Platform.isAndroid) {
  //     await Process.run('cmd', ['media', 'scan', filePath]);
  //   }
  //
  //   await openFile(filePath);
  // }
  String sanitizeBase64(String base64String) {
    return base64String.replaceAll(RegExp(r'\s+'), '').replaceAll('"', '');
  }

  Future<void> checkStoragePermission() async {
    print('ledger: checkStoragePermission');
    bool permissionStatus;
    final deviceInfo = await DeviceInfoPlugin().androidInfo;

    if (deviceInfo.version.sdkInt > 32) {
      permissionStatus = await Permission.storage.request().isGranted;
    } else {
      permissionStatus = await Permission.storage.request().isGranted;
    }
    print('Storage permission is granted $permissionStatus');
    if (await Permission.storage.request().isGranted) {
      print('Storage permission is granted');
    } else {
      Map<Permission, PermissionStatus> status = await [
        Permission.storage,
      ].request();

      if (status[Permission.storage] == PermissionStatus.granted) {
        print('Storage permission is granted');
      } else {
        print('Storage permission is denied');
      }
    }
  }

  Future<void> convertBase64ToExcel(String base64String, BuildContext context) async {
    String _base64String = sanitizeBase64(base64String);
    print('_base64String${_base64String}');
    // Decode the Base64 String
    List<int> excelBytes = base64Decode(_base64String);

    // Get the directory to save the file (external storage for visibility)
    //  Directory? directory = await getExternalStorageDirectory()!;

    // Define the folder and file path
    //   String folderName = 'MyExcelFiles';
    //   Directory newFolder = Directory('${directory!.path}/$folderName');
    //   if (!await newFolder.exists()) {
    //     await newFolder.create(recursive: true);
    //     print('Folder created at ${newFolder.path}');
    //   }
    Directory directoryPath = Directory('/storage/emulated/0/Download/Excel_Groups/ledger');
    if (!directoryPath.existsSync()) {
      directoryPath.createSync(recursive: true);
    }
    String filePath = directoryPath.path;
    String fileName = "Excel.xlsx";

    final File file = File('$filePath/$fileName');
    print('file${file}');
    await file.create(recursive: true);
    await file.writeAsBytes(excelBytes);

    // String filePath = '${newFolder.path}/output.xlsx';
    // print('filePath $filePath');
    //
    // // Write the data to the file
    // File file = File(filePath);
    // await file.writeAsBytes(excelBytes);
    // print('File saved at $filePath');
    //
    // // Notify the media scanner (Android only)
    // if (Platform.isAndroid) {
    //   await Process.run('cmd', ['media', 'scan', filePath]);
    // }

    await openFile(filePath);
  }

  Future<void> openFile(String filePath) async {
    final url = Uri.file(filePath).toString();
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      print('Could not open the file');
    }
  }

  List<double>? calculateDynamicStops(double position) {
    // Your dynamic calculation logic here
    // For example, you can use the selected position or any other criteria.
    if (position == 0.0) {
      // Handle the special case for zero position
      double doublePosition = position / 0.05;
      return [0.1225, doublePosition + 0.19, 0.1, 0.19];
    } else if (position == 1.0) {
      double doublePosition = position / 0.05;
      return [0.1225, 0.19, 0.1, 0.19];
    } else if (position == 2.0) {
      double doublePosition = position / 0.05;
      return [0.1225, 0.19, 0.1, 0.19];
    } else if (position == 3.0) {
      double doublePosition = position / 0.05;
      return [0.06, 0.29, 0.091, 0.19];
    }
    // double doublePosition = position / 0.05;
    // //double positionPercentage = (position + 0.005) * 0.005;
    // return [0.1225, doublePosition + 0.0325, doublePosition + 0.0545, doublePosition + 0.0765];
  }

  bool datevalidation() {
    bool isValid = true;
    if (fromDate == null || toDate == null) {
      print('Please select both FromDate and ToDate');
      //  showCustomToastMessageLong("Please select both FromDate and ToDate", context, 1, 5);
      isValid = false;
    } else if (toDate!.compareTo(fromDate!) < 0) {
      print('To Date is less than From Date');

      //showCustomToastMessageLong("To Date is less than From Date", context, 1, 5);
      isValid = false;
    }

    if (isValid) {
      print('the api hit');
      DateFormat dateFormat = DateFormat('yyyy-MM-dd');
      String strcustomstartdate = dateFormat.format(fromDate!);
      String strcustomtodate = dateFormat.format(toDate!);

      setState(() {
        fromdatetosendtab2 = strcustomstartdate;
        todatetosendtab2 = strcustomtodate;
        Provider.of<DataProvider>(context, listen: false)
            .updateData(fromdatetosendtab2!, todatetosendtab2!, modifiedCode!, _transportRates, _transportationCharges);
        transportlistapi(fromDate!, toDate!, modifiedCode!);
        paymentlistapi(fromDate!, toDate!, modifiedCode!);
      });
    }

    // else {
    //   // Your submit logic here
    //
    //   //showCustomToastMessageLong("You can hit the API", context, 0, 5);
    //
    //   // setState(() {
    //   //   isInfoVisible = true;
    //   // });
    // }
    return isValid;
  }

  Future<void> _selectDate(BuildContext context, TextEditingController controller) async {
    DateTime initialDate = DateTime.now(); // Default value

    if (controller == fromDateController && fromDate != null) {
      initialDate = fromDate!;
    } else if (controller == toDateController && toDate != null) {
      initialDate = toDate!;
    }

    DateTime currentDate = DateTime.now();
    int currentMonth = currentDate.month;
    int currentYear = currentDate.year;

    showMonthPicker(
      context,
      onSelected: (selectedMonth, selectedYear) {
        setState(() {
          DateTime dateWithoutTime;

          if (controller == fromDateController) {
            // Set the date to the 1st of the selected month
            dateWithoutTime = DateTime(
              selectedYear,
              selectedMonth,
              1,
            );
            fromDate = dateWithoutTime;
            fromFormattedDate = DateFormat('dd/MM/yyyy').format(dateWithoutTime);
            controller.text = fromFormattedDate;
          } else if (controller == toDateController) {
            // Set the date to the last day of the selected month
            dateWithoutTime = DateTime(
              selectedYear,
              selectedMonth + 1,
              0, // This automatically sets the date to the last day of the selected month
            );
            toDate = dateWithoutTime;
            toFormattedDate = DateFormat('dd/MM/yyyy').format(dateWithoutTime);
            controller.text = toFormattedDate;
          }
        });
      },
      initialSelectedMonth: currentMonth,
      initialSelectedYear: currentYear,
      firstEnabledMonth: 1,
      lastEnabledMonth: 12,
      firstYear: 2000,
      lastYear: 2025,
      selectButtonText: 'OK',
      cancelButtonText: 'Cancel',
      highlightColor: Colors.grey,
      textColor: Colors.black,
      contentBackgroundColor: Colors.white,
      dialogBackgroundColor: Colors.grey[200],
    );
  }

  // Future<void> _selectDate(BuildContext cc, TextEditingController controller) async {
  //   DateTime initialDate = DateTime.now(); // Default value
  //
  //   if (controller == fromDateController && fromDate != null) {
  //     initialDate = fromDate!;
  //   } else if (controller == toDateController && toDate != null) {
  //     initialDate = toDate!;
  //   }
  //
  //   // final selected = await showMonthYearPicker(
  //   //   context: context,
  //   //
  //   //   initialDate: DateTime.now(),
  //   //   firstDate: DateTime(2000),
  //   //   lastDate: DateTime(2050),
  //   // );
  //   DateTime currentDate = DateTime.now();
  //   int currentMonth = currentDate.month; // Get the current month (1-12)
  //   int? currentYear = currentDate.year;
  // final selected = await  showMonthPicker(
  //     cc,
  //     onSelected: (selectedMonth, selectedYear) {
  //
  //       setState(() {
  //         currentMonth = selectedMonth;
  //         currentYear = selectedYear;
  //       });
  //     },
  //     initialSelectedMonth: currentMonth,
  //     initialSelectedYear: currentYear,
  //     firstEnabledMonth: 3,
  //     lastEnabledMonth: 10,
  //     firstYear: 2000,
  //     lastYear: 3000,
  //     selectButtonText: 'OK',
  //     cancelButtonText: 'Cancel',
  //     highlightColor: Colors.purple,
  //     textColor: Colors.black,
  //     contentBackgroundColor: Colors.white,
  //     dialogBackgroundColor: Colors.grey[200],
  //   );
  //
  //
  //   if (selected != null) {
  //     // Remove the time portion from the selected date
  //     final DateTime dateWithoutTime = DateTime(
  //       selected.year,
  //       selected.month,
  //       selected.day,
  //     );
  //
  //     final DateFormat dateFormat = DateFormat('dd/MM/yyyy');
  //     final formattedDate = dateFormat.format(dateWithoutTime);
  //
  //     setState(() {
  //       if (controller == fromDateController) {
  //         fromDate = dateWithoutTime;
  //         fromFormattedDate = formattedDate;
  //
  //       } else {
  //         toDate = dateWithoutTime;
  //         toFormattedDate = formattedDate; // Store the formatted date for toDate
  //
  //       }
  //       controller.text = formattedDate; // Format and set the selected date as a string
  //     });
  //   }
  // }

  String formatDateToApi(DateTime date) {
    final DateFormat apiDateFormat = DateFormat('yyyy-MM-dd');
    return apiDateFormat.format(date);
  }

  // void paymentlistapi(DateTime from_date, DateTime to_date, String Farmervendorcode) async {
  //   final url = Uri.parse(baseUrl + getvendordata);
  //   print('url==>555: $url');
  //   final String fromFormattedDateApi = formatDateToApi(from_date);
  //   final String toFormattedDateApi = formatDateToApi(to_date);
  //   print('fromFormattedDateApi: $fromFormattedDateApi');
  //   print('toFormattedDateApi: $toFormattedDateApi');
  //   final request = {"vendorCode": "$Farmervendorcode", "fromDate": fromFormattedDateApi, "toDate": toFormattedDateApi};
  //   print('request of the 30 days: $request');
  //   try {
  //     final response = await http.post(
  //       url,
  //       body: json.encode(request),
  //       headers: {
  //         'Content-Type': 'application/json',
  //       },
  //     );
  //
  //     if (response.statusCode == 200) {
  //       final Map<String, dynamic> responseData = jsonDecode(response.body);
  //       print('Full response data: $responseData'); // Log the entire response data
  //
  //       if (responseData.containsKey('result') && responseData.containsKey('paymentResponce')) {
  //         if (responseData['result'] != null && responseData['paymentResponce'] != null) {
  //           List<PaymentResponse> paymentresponse = (responseData['paymentResponce'] as List).map((item) => PaymentResponse.fromJson(item)).toList();
  //           List<PaymentDetailsResponse> paymentcollectionslist = (responseData['result'] as List).map((item) => PaymentDetailsResponse.fromJson(item)).toList();
  //
  //           print('paymentresponse: ${paymentresponse.length}');
  //
  //           // Looping through paymentcollectionslist
  //           for (PaymentDetailsResponse collection in paymentcollectionslist) {
  //             print('totalQuantity: ${collection.totalQuantity}');
  //           }
  //
  //           setState(() {
  //             paymentDetailsResponse_list = paymentresponse;
  //           });
  //         } else {
  //           print('One of the fields (result or paymentResponce) is null');
  //         }
  //       } else {
  //         print('Response data does not contain required keys: result or paymentResponce');
  //       }
  //     } else {
  //       print('Request was not successful. Status code: ${response.statusCode}');
  //     }
  //   } catch (e) {
  //     print('Error: $e');
  //   }
  // }
  void paymentlistapi(DateTime fromDate, DateTime toDate, String farmervendorCode) async {
    final url = Uri.parse(baseUrl + getvendordata);
    print('url==>555: $url');
    final String fromFormattedDateApi = formatDateToApi(fromDate);
    final String toFormattedDateApi = formatDateToApi(toDate);
    print('fromFormattedDateApi: $fromFormattedDateApi');
    print('toFormattedDateApi: $toFormattedDateApi');

    final request = {
      "vendorCode": farmervendorCode,
      "fromDate": toFormattedDateApi,
      "toDate": fromFormattedDateApi,
    };
    print('request of the 30 days: $request');

    try {
      final response = await http.post(
        url,
        body: json.encode(request),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);
        print('Fullresponsedataforpayment:$responseData');

        if (responseData.containsKey('result')) {
          final result = responseData['result'];

          // Parsing paymentResponse list
          if (result.containsKey('paymentResponce')) {
            List<PaymentResponse> paymentresponse = (result['paymentResponce'] as List).map((item) => PaymentResponse.fromJson(item)).toList();
            totalBalance = responseData['result']['totalBalance'];
            totalQuanitity = responseData['result']['totalQuanitity'];
            totalGRAmount = responseData['result']['totalGRAmount'];
            totalAdjusted = responseData['result']['totalAdjusted'];
            totalAmount = responseData['result']['totalAmount'];
            String formattedtotalBalance = totalBalance!.toStringAsFixed(2);
            String formattedtotalQuanitity = totalQuanitity!.toStringAsFixed(2);

            print('paymentresponse: ${paymentresponse.length}');
            print('formattedtotalBalance: ${formattedtotalBalance}');
            print('formattedtotalQuanitity: ${formattedtotalQuanitity}');

            setState(() {
              closingbalance = formattedtotalBalance;
              totalquantityffb = formattedtotalQuanitity;
              paymentDetailsResponse_list = paymentresponse;
            });
          } else {
            print('Key paymentResponce not found in result');
          }

          // Parsing other fields like totalQuantity
          // if (result.containsKey('totalQuanitity')) {
          //   double totalQuantity = result['totalQuanitity'];
          //   print('Total Quantity: $totalQuantity');
          // } else {
          //   print('Key totalQuanitity not found in result');
          // }
        } else {
          print('Key result not found in response data');
        }
      } else {
        print('Request was not successful. Status code: ${response.statusCode}');
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  void transportlistapi(DateTime fromDate, DateTime toDate, String farmervendorCode) async {
    //  String url_ = 'http://103.241.144.240:9096/api/Payment/GetTranspotationChargesByFarmerCode';
    String url_ = baseUrl + getfarmerreimbursement;
    final url = Uri.parse(url_);
    print('url==>588: $url');
    final String fromFormattedDateApi = formatDateToApi(fromDate);
    final String toFormattedDateApi = formatDateToApi(toDate);
    print('fromFormattedDateApi: $fromFormattedDateApi');
    print('toFormattedDateApi: $toFormattedDateApi');

    final request = {
      "fromDate": fromFormattedDateApi,
      "toDate": toFormattedDateApi,

      /// "vendorCode": 'APWGCGCK00080012',
      "vendorCode": '$farmervendorCode',
    };
    print('request of the 30 days: $request');

    try {
      final response = await http.post(
        url,
        body: json.encode(request),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);
        print('Full response data: $responseData');
        final jsonData = jsonDecode(response.body);

        // Create an ApiResponse object from the JSON data
        final apiResponse = ApiResponse.fromJson(jsonData);
        print('transportationCharges ${apiResponse.transportationCharges}');
        // Print transportationCharges
        print('Transportation Charges:');
        for (var charge in apiResponse.transportationCharges) {
          print('Collection Code: ${charge.collectionCode}');
          print('Farmer Code: ${charge.farmerCode}');
          print('Farmer Name: ${charge.farmerName}');
          print('Tonnage Cost: ${charge.tonnageCost}');
          print('Rate: ${charge.rate}');
          print('Quantity: ${charge.qty}');
          print('Receipt Generated Date: ${charge.receiptGeneratedDate}');
          print('---');
        }

        // Print transportRates
        print('Transport Rates:');
        for (var rate in apiResponse.transportRates) {
          print('Farmer Code: ${rate.farmerCode}');
          print('Village: ${rate.village}');
          print('Mandal: ${rate.mandal}');
          print('Rate: ${rate.rate}');
          print('---');
        }
        setState(() {
          _transportationCharges = apiResponse.transportationCharges;
          _transportRates = apiResponse.transportRates;
        });

        // if (responseData.containsKey('result')) {
        // final result = responseData['result'];
        //
        // // Parsing paymentResponse list
        // if (result.containsKey('paymentResponce')) {
        //   List<PaymentResponse> paymentresponse = (result['paymentResponce'] as List).map((item) => PaymentResponse.fromJson(item)).toList();
        //   totalBalance = responseData['result']['totalBalance'];
        //   totalQuanitity = responseData['result']['totalQuanitity'];
        //   totalGRAmount = responseData['result']['totalGRAmount'];
        //   totalAdjusted = responseData['result']['totalAdjusted'];
        //   totalAmount = responseData['result']['totalAmount'];
        //   String formattedtotalBalance = totalBalance.toStringAsFixed(2);
        //   String formattedtotalQuanitity = totalQuanitity.toStringAsFixed(2);
        //
        //   print('paymentresponse: ${paymentresponse.length}');
        //
        //   setState(() {
        //     closingbalance = formattedtotalBalance;
        //     totalquantityffb = formattedtotalQuanitity;
        //     paymentDetailsResponse_list = paymentresponse;
        //   });
        // } else {
        //   print('Key paymentResponce not found in result');
        // }

        // Parsing other fields like totalQuantity
        // if (result.containsKey('totalQuanitity')) {
        //   double totalQuantity = result['totalQuanitity'];
        //   print('Total Quantity: $totalQuantity');
        // } else {
        //   print('Key totalQuanitity not found in result');
        // }
        // } else {
        //   print('Key result not found in response data');
        // }
      } else {
        print('Request was not successful. Status code: ${response.statusCode}');
      }
    } catch (e) {
      print('Error: $e');
    }
  }
}

class DirectFarmerTransport extends StatelessWidget {
  // final String FarmerTransportfromdate;
  // final String FarmerTransporttodate;
  // final String farmercode;

  // DirectFarmerTransport({required this.FarmerTransportfromdate,required this.FarmerTransporttodate,required this.farmercode});
  List<TransportRate> transportlistview = [];
  List<TransportationCharge> TransportationChargelistview = [];

  @override
  void initState() {}

  void transportlistapitabs(DateTime fromDate, DateTime toDate, String farmervendorCode) async {
    //  String url_ = 'http://103.241.144.240:9096/api/Payment/GetTranspotationChargesByFarmerCode';
    String url_ = baseUrl + getfarmerreimbursement;
    final url = Uri.parse(url_);
    print('url==>588: $url');
    final String fromFormattedDateApi = formatDateToApi(fromDate);
    final String toFormattedDateApi = formatDateToApi(toDate);
    print('fromFormattedDateApi: $fromFormattedDateApi');
    print('toFormattedDateApi: $toFormattedDateApi');

    final request = {
      "fromDate": fromFormattedDateApi,
      "toDate": toFormattedDateApi,

      /// "vendorCode": 'APWGCGCK00080012',
      "vendorCode": '$farmervendorCode',
    };
    print('request of the 30 days: $request');

    try {
      final response = await http.post(
        url,
        body: json.encode(request),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);
        print('Fullresponsedatafortransportrate: $responseData');
        final jsonData = jsonDecode(response.body);

        // Create an ApiResponse object from the JSON data
        final apiResponse = ApiResponse.fromJson(jsonData);
        //     print('transportationCharges ${apiResponse.transportationCharges}');
        // Print transportationCharges
        // print('Transportation Charges:');
        // for (var charge in apiResponse.transportationCharges) {
        //   print('Collection Code: ${charge.collectionCode}');
        //   print('Farmer Code: ${charge.farmerCode}');
        //   print('Farmer Name: ${charge.farmerName}');
        //   print('Tonnage Cost: ${charge.tonnageCost}');
        //   print('Rate: ${charge.rate}');
        //   print('Quantity: ${charge.qty}');
        //   print('Receipt Generated Date: ${charge.receiptGeneratedDate}');
        //   print('---');
        // }
        //
        // // Print transportRates
        // print('Transport Rates:');
        // for (var rate in apiResponse.transportRates) {
        //   print('Farmer Code: ${rate.farmerCode}');
        //   print('Village: ${rate.village}');
        //   print('Mandal: ${rate.mandal}');
        //   print('Rate: ${rate.rate}');
        //   print('---');
        // }
        TransportationChargelistview = apiResponse.transportationCharges;
        transportlistview = apiResponse.transportRates;
      } else {
        print('Request was not successful. Status code: ${response.statusCode}');
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  String formatDateToApi(DateTime date) {
    final DateFormat apiDateFormat = DateFormat('yyyy-MM-dd');
    return apiDateFormat.format(date);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Consumer<DataProvider>(
        builder: (context, dataProvider, child) {
          DateTime parsedDate = DateTime.parse(dataProvider.data1);
          DateTime parsedDate1 = DateTime.parse(dataProvider.data2);

          // Format the DateTime object into the desired format
          String formattedDate = DateFormat('dd/MM/yyyy').format(parsedDate);
          // final String fromFormattedDateApi = formatDateToApi(dataProvider.data1);
          // final String toFormattedDateApi = formatDateToApi(dataProvider.data2);
          transportlistapitabs(parsedDate, parsedDate1, dataProvider.data3);
          return Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (TransportationChargelistview != null && TransportationChargelistview.isNotEmpty)
                Expanded(
                  // flex: 3,
                  child: ListView.builder(
                    shrinkWrap: true,

                    ///     itemCount: dataProvider.transportchargelist.length,
                    itemCount: TransportationChargelistview.length,
                    itemBuilder: (context, index) {
                      //     BranchModel branch = brancheslist[index]; // Get the branch at the current index
                      //    DateTime dateTime = DateTime.parse(paymentDetailsResponse_list[index].refDate as String);

                      // Format the date to dd/MM/yyyy
                      //    String formattedDate = DateFormat('dd/MM/yyyy').format(dataProvider.transportchargelist[index].receiptGeneratedDate);
                      String formattedDate = DateFormat('dd/MM/yyyy').format(TransportationChargelistview[index].receiptGeneratedDate);
                      // String transportratelist = dataProvider.transportratelist[index].village;
                      // print('transportratelist$transportratelist');
                      //  if (TransportationChargelistview.length != 0) {
                      //
                      //  } else {
                      //    return Container(
                      //        height:MediaQuery.of(context).size.height/2,
                      //        child: Text('No Direct Farmer Transport Reimbursement Found',
                      //      style:  TextStyle(
                      //      fontSize: 16,
                      //      color: Color(0xFFFB4110),
                      //      fontWeight: FontWeight.bold,
                      //      fontFamily: 'Calibri',
                      //    ),));
                      //  }
                      return Padding(
                          //  padding: EdgeInsets.symmetric(horizontal: 0.0, vertical: 5.0),
                          padding: EdgeInsets.only(left: 10, right: 10),
                          child: IntrinsicHeight(
                            child: ClipRRect(
                                borderRadius: BorderRadius.circular(12.0),
                                child: GestureDetector(
                                  onTap: () {},
                                  child: Card(
                                    shadowColor: Colors.transparent,
                                    surfaceTintColor: Colors.transparent,
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(12.0),
                                      //surfaceTintColor : Colors.red,

                                      child: Container(
                                        color: index.isEven ? Colors.white : Colors.grey[300],
                                        child: Row(
                                          crossAxisAlignment: CrossAxisAlignment.center,
                                          children: [
                                            Padding(
                                              padding: EdgeInsets.only(left: 5.0, right: 5),
                                              child: Center(
                                                child: Column(
                                                  crossAxisAlignment: CrossAxisAlignment.center,
                                                  mainAxisAlignment: MainAxisAlignment.center,
                                                  children: [
                                                    Container(
                                                      margin: EdgeInsets.only(right: 10.0, left: 10),
                                                      child: ClipRRect(
                                                        borderRadius: BorderRadius.circular(7.0),
                                                        child: Image.asset(
                                                          'assets/ic_calender.png',
                                                          width: 30.0,
                                                          height: 30.0,
                                                          fit: BoxFit.cover,
                                                        ),
                                                      ),
                                                    ),
                                                    SizedBox(height: 2.0),
                                                    // Add some spacing between the image and text
                                                    Text(
                                                      '$formattedDate',
                                                      style: TextStyle(
                                                        color: Colors.grey,
                                                      ),
                                                      textAlign: TextAlign.center,
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                            Container(
                                              width: 2.0,
                                              // height: MediaQuery.of(context).size.height,
                                              padding: EdgeInsets.only(top: 10, bottom: 10),
                                              decoration: BoxDecoration(
                                                gradient: LinearGradient(
                                                  colors: [
                                                    Color(0xFFFF4500),
                                                    Color(0xFFA678EF),
                                                    Color(0xFFFF4500),
                                                  ],
                                                  end: Alignment.topRight,
                                                ),
                                              ),
                                            ),
                                            Expanded(
                                                child: Padding(
                                              padding: EdgeInsets.only(left: 5.0),
                                              child: Column(
                                                  mainAxisAlignment: MainAxisAlignment.start,
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [
                                                    Expanded(
                                                      child: Column(
                                                        children: [
                                                          Padding(
                                                            padding: const EdgeInsets.symmetric(horizontal: 0.0, vertical: 0.0),
                                                            child: Card(
                                                              //color: Colors.grey,
                                                              shadowColor: Colors.transparent,
                                                              surfaceTintColor: Colors.transparent,
                                                              child: Container(
                                                                decoration: BoxDecoration(
                                                                  borderRadius: BorderRadius.circular(12.0),
                                                                ),
                                                                child: Row(
                                                                  crossAxisAlignment: CrossAxisAlignment.center,
                                                                  children: [
                                                                    Expanded(
                                                                      child: Padding(
                                                                        padding: const EdgeInsets.only(left: 0.0),
                                                                        child: Column(
                                                                          mainAxisAlignment: MainAxisAlignment.start,
                                                                          crossAxisAlignment: CrossAxisAlignment.start,
                                                                          children: [
                                                                            Padding(
                                                                              padding: const EdgeInsets.only(top: 15.0),
                                                                              child: Text(
                                                                                TransportationChargelistview[index].collectionCode,
                                                                                style: TextStyle(
                                                                                  fontSize: 16,
                                                                                  color: Color(0xFFFB4110),
                                                                                  fontWeight: FontWeight.bold,
                                                                                  fontFamily: 'Calibri',
                                                                                ),
                                                                              ),
                                                                            ),
                                                                            const SizedBox(height: 4.0),
                                                                            Row(
                                                                              children: [
                                                                                const Expanded(
                                                                                  flex: 3,
                                                                                  child: Column(
                                                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                                                    children: [
                                                                                      Padding(
                                                                                        padding: EdgeInsets.fromLTRB(0, 8, 0, 0),
                                                                                        child: Text(
                                                                                          "Transportation Charges/Ton (Rs)",
                                                                                          style: TextStyle(
                                                                                            color: Colors.black,
                                                                                            fontSize: 14,
                                                                                            fontWeight: FontWeight.bold,
                                                                                            fontFamily: 'hind_semibold',
                                                                                          ),
                                                                                        ),
                                                                                      ),
                                                                                    ],
                                                                                  ),
                                                                                ),
                                                                                const Expanded(
                                                                                  flex: 0,
                                                                                  child: Column(
                                                                                    crossAxisAlignment: CrossAxisAlignment.end,
                                                                                    mainAxisAlignment: MainAxisAlignment.end,
                                                                                    children: [
                                                                                      Padding(
                                                                                        padding: EdgeInsets.fromLTRB(40, 8, 5, 0),
                                                                                        child: Text(
                                                                                          ":",
                                                                                          style: TextStyle(
                                                                                            color: Colors.black54,
                                                                                            fontSize: 14,
                                                                                            fontWeight: FontWeight.bold,
                                                                                            fontFamily: 'hind_semibold',
                                                                                          ),
                                                                                        ),
                                                                                      ),
                                                                                    ],
                                                                                  ),
                                                                                ),
                                                                                Expanded(
                                                                                  flex: 2,
                                                                                  child: Column(
                                                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                                                    mainAxisAlignment: MainAxisAlignment.start,
                                                                                    children: [
                                                                                      Padding(
                                                                                        padding: const EdgeInsets.fromLTRB(0, 8, 0, 0),
                                                                                        child: Text(
                                                                                          TransportationChargelistview[index]
                                                                                              .tonnageCost
                                                                                              .toStringAsFixed(2),
                                                                                          style: const TextStyle(
                                                                                            color: Colors.black54,
                                                                                            fontSize: 14,
                                                                                            fontWeight: FontWeight.bold,
                                                                                            fontFamily: 'hind_semibold',
                                                                                          ),
                                                                                        ),
                                                                                      ),
                                                                                    ],
                                                                                  ),
                                                                                ),
                                                                              ],
                                                                            ),
                                                                            Row(
                                                                              children: [
                                                                                const Expanded(
                                                                                  flex: 3,
                                                                                  child: Column(
                                                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                                                    children: [
                                                                                      Padding(
                                                                                        padding: EdgeInsets.fromLTRB(0, 8, 0, 0),
                                                                                        child: Text(
                                                                                          "Net Weight (Ton)",
                                                                                          style: TextStyle(
                                                                                            color: Colors.black,
                                                                                            fontSize: 14,
                                                                                            fontWeight: FontWeight.bold,
                                                                                            fontFamily: 'hind_semibold',
                                                                                          ),
                                                                                        ),
                                                                                      ),
                                                                                    ],
                                                                                  ),
                                                                                ),
                                                                                const Expanded(
                                                                                  flex: 0,
                                                                                  child: Column(
                                                                                    crossAxisAlignment: CrossAxisAlignment.end,
                                                                                    mainAxisAlignment: MainAxisAlignment.end,
                                                                                    children: [
                                                                                      Padding(
                                                                                        padding: EdgeInsets.fromLTRB(40, 8, 5, 0),
                                                                                        child: Text(
                                                                                          ":",
                                                                                          style: TextStyle(
                                                                                            color: Colors.black54,
                                                                                            fontSize: 14,
                                                                                            fontWeight: FontWeight.bold,
                                                                                            fontFamily: 'hind_semibold',
                                                                                          ),
                                                                                        ),
                                                                                      ),
                                                                                    ],
                                                                                  ),
                                                                                ),
                                                                                Expanded(
                                                                                  flex: 2,
                                                                                  child: Column(
                                                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                                                    mainAxisAlignment: MainAxisAlignment.start,
                                                                                    children: [
                                                                                      Padding(
                                                                                        padding: const EdgeInsets.fromLTRB(0, 8, 0, 0),
                                                                                        child: Text(
                                                                                          TransportationChargelistview[index].qty.toStringAsFixed(2),
                                                                                          style: const TextStyle(
                                                                                            color: Colors.black54,
                                                                                            fontSize: 14,
                                                                                            fontWeight: FontWeight.bold,
                                                                                            fontFamily: 'hind_semibold',
                                                                                          ),
                                                                                        ),
                                                                                      ),
                                                                                    ],
                                                                                  ),
                                                                                ),
                                                                              ],
                                                                            ),
                                                                            Row(
                                                                              children: [
                                                                                const Expanded(
                                                                                  flex: 3,
                                                                                  child: Column(
                                                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                                                    children: [
                                                                                      Padding(
                                                                                        padding: EdgeInsets.fromLTRB(0, 8, 0, 0),
                                                                                        child: Text(
                                                                                          "Total Amount (Rs)",
                                                                                          style: TextStyle(
                                                                                            color: Colors.black,
                                                                                            fontSize: 14,
                                                                                            fontWeight: FontWeight.bold,
                                                                                            fontFamily: 'hind_semibold',
                                                                                          ),
                                                                                        ),
                                                                                      ),
                                                                                    ],
                                                                                  ),
                                                                                ),
                                                                                const Expanded(
                                                                                  flex: 0,
                                                                                  child: Column(
                                                                                    crossAxisAlignment: CrossAxisAlignment.end,
                                                                                    mainAxisAlignment: MainAxisAlignment.end,
                                                                                    children: [
                                                                                      Padding(
                                                                                        padding: EdgeInsets.fromLTRB(40, 8, 5, 0),
                                                                                        child: Text(
                                                                                          ":",
                                                                                          style: TextStyle(
                                                                                            color: Colors.black54,
                                                                                            fontSize: 14,
                                                                                            fontWeight: FontWeight.bold,
                                                                                            fontFamily: 'hind_semibold',
                                                                                          ),
                                                                                        ),
                                                                                      ),
                                                                                    ],
                                                                                  ),
                                                                                ),
                                                                                Expanded(
                                                                                  flex: 2,
                                                                                  child: Column(
                                                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                                                    mainAxisAlignment: MainAxisAlignment.start,
                                                                                    children: [
                                                                                      Padding(
                                                                                        padding: const EdgeInsets.fromLTRB(0, 8, 0, 0),
                                                                                        child: Text(
                                                                                          TransportationChargelistview[index].rate.toStringAsFixed(2),
                                                                                          style: const TextStyle(
                                                                                            color: Colors.black54,
                                                                                            fontSize: 14,
                                                                                            fontWeight: FontWeight.bold,
                                                                                            fontFamily: 'hind_semibold',
                                                                                          ),
                                                                                        ),
                                                                                      ),
                                                                                    ],
                                                                                  ),
                                                                                ),
                                                                              ],
                                                                            ),
                                                                          ],
                                                                        ),
                                                                      ),
                                                                    ),
                                                                  ],
                                                                ),
                                                              ),
                                                            ),
                                                          )
                                                        ],
                                                      ),
                                                    ),
                                                  ]),
                                            ))
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                )),
                          ));
                    },
                  ),
                ),
              if (TransportationChargelistview == null || TransportationChargelistview.isEmpty)
                Expanded(
                    child: Center(
                        child: Container(
                            height: MediaQuery.of(context).size.height / 2,
                            child: Center(
                                child: Text(
                              'No Direct Farmer Transport Reimbursement Found',
                              style: TextStyle(
                                fontSize: 16,
                                color: Color(0xFFFB4110),
                                fontWeight: FontWeight.bold,
                                fontFamily: 'Calibri',
                              ),
                            ))))),

              Expanded(
                  // height: 200,
                  child: Padding(
                padding: EdgeInsets.all(10.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Expanded(
                          flex: 1,
                          child: Container(
                            //  width: 175,
                            height: 45,
                            // decoration: BoxDecoration(
                            //   gradient: LinearGradient(
                            //     colors: [
                            //       Color(0xFFCCCCCC),
                            //       Color(0xFFFFFFFF),
                            //       Color(0xFFCCCCCC),
                            //     ],
                            //     begin: Alignment.topCenter,
                            //     end: Alignment.bottomCenter,
                            //   ),
                            //   borderRadius: BorderRadius.circular(10.0),
                            //   border: Border.all(
                            //     width: 2.0,
                            //     color: Color(0xFFe86100),
                            //   ),
                            //    ),
                            child: ElevatedButton(
                              onPressed: () {
                                print('button1clicked');
                                //openFile();
                              },
                              child: Text(
                                '',
                                style: TextStyle(
                                  // color: Color(0xFFe86100),
                                  fontSize: 12,
                                  fontFamily: 'hind_semibold',
                                ),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.transparent,
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10.0),
                                ),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: 8.0),
                        Expanded(
                          flex: 1,
                          child: Container(
                            width: MediaQuery.of(context).size.width,
                            height: 45,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  Color(0xFFCCCCCC),
                                  Color(0xFFFFFFFF),
                                  Color(0xFFCCCCCC),
                                ],
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                              ),
                              borderRadius: BorderRadius.circular(10.0),
                              border: Border.all(
                                width: 2.0,
                                color: Color(0xFFe86100),
                              ),
                            ),
                            child: ElevatedButton(
                              onPressed: () {
                                print('transportlistview${transportlistview.length}');
                                Showdialogtransportrates(transportlistview, context);
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.transparent,
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10.0),
                                ),
                              ),
                              child: Container(
                                  alignment: Alignment.center,
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Image.asset('assets/delivery.png', height: 20, width: 20),
                                      SizedBox(
                                        width: 5,
                                      ),
                                      Text(
                                        'Transportation Rates',
                                        style: TextStyle(
                                          color: Color(0xFFe86100),
                                          fontSize: 12,
                                          fontFamily: 'hind_semibold',
                                        ),
                                        maxLines: 1,
                                        textAlign: TextAlign.center,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ],
                                  )),
                            ),
                          ),
                        ),
                      ],
                    ),

                    ///  SizedBox(height: 5.0),
                    Container(
                      /// flex: 1,

                      child: Card(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.0),
                          side: BorderSide(
                            color: Color(0xFFBE9747), // Border color
                          ),
                        ),
                        color: Color(0xFFFFFACB), // Background color
                        child: Column(
                          children: [
                            ListTile(
                              title: RichText(
                                text: TextSpan(
                                  text: 'Note: \n',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.normal,
                                    color: Color(0xFFe86100), // Color for "Note: \n"
                                  ),
                                  children: [
                                    TextSpan(
                                      text:
                                          'Unless Plot is declared during FFB Collection, all plots average transport rate is calculated based on age,size, & Expected FFB.',
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.normal,
                                        color: Colors.black, // Color for the rest of the text
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ))
              //  )
            ],
          );
        },
      ),
    );
  }

  void Showdialogtransportrates(List<TransportRate> transportratelist, BuildContext context) {
    showDialog(
      barrierDismissible: true,
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
            backgroundColor: Colors.white,
            content: IntrinsicHeight(
                //   width: MediaQuery.of(context).size.width,
                //height: MediaQuery.of(context).size.height / 3,
                //  padding: EdgeInsets.only(left: 10.0,right: 10,top: 6,bottom: 10),
                child: Column(
              children: [
                SizedBox(
                  height: 12.0,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      "Transportation Rates",
                      style: TextStyle(
                        fontSize: 16,
                        fontFamily: 'Calibri',
                        color: Color(0xFFf15f22),
                      ),
                    ),
                    // IconButton(
                    //   icon: Icon(Icons.close),
                    //   onPressed: () {
                    //     Navigator.of(context).pop();
                    //   },
                    // ),
                  ],
                ),
                Container(
                    width: MediaQuery.of(context).size.width,
                    height: MediaQuery.of(context).size.height / 5.0, // Adjust the height as needed
                    child: ListView.builder(
                      itemCount: transportratelist.length,
                      itemBuilder: (context, index) {
                        ///  var member = transportrate[index];
                        String transpporratelistvillage = transportratelist[index].village;
                        print('transpporratelistvillage$transpporratelistvillage');
                        return Card(
                            elevation: 2,
                            child: Container(
                                width: MediaQuery.of(context).size.width,
                                // height: MediaQuery.of(context).size.height / 3.0,
                                // height: MediaQuery.of(context).size.height, // Adjust the height as needed
                                padding: EdgeInsets.only(left: 5.0, right: 5, bottom: 5, top: 5),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        const Expanded(
                                          flex: 3,
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Padding(
                                                padding: EdgeInsets.fromLTRB(0, 8, 0, 0),
                                                child: Text(
                                                  "Village",
                                                  style: TextStyle(
                                                    color: Colors.black,
                                                    fontSize: 14,
                                                    fontWeight: FontWeight.bold,
                                                    fontFamily: 'hind_semibold',
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        Expanded(
                                          flex: 0,
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.end,
                                            mainAxisAlignment: MainAxisAlignment.end,
                                            children: [
                                              Padding(
                                                padding: EdgeInsets.fromLTRB(5, 8, 5, 0),
                                                child: Text(
                                                  ":",
                                                  style: TextStyle(
                                                    color: Colors.black54,
                                                    fontSize: 14,
                                                    fontWeight: FontWeight.bold,
                                                    fontFamily: 'hind_semibold',
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        Expanded(
                                          flex: 3,
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            mainAxisAlignment: MainAxisAlignment.start,
                                            children: [
                                              Padding(
                                                padding: const EdgeInsets.fromLTRB(5, 8, 0, 0),
                                                child: Text(
                                                  transportratelist[index].village,
                                                  style: const TextStyle(
                                                    color: Colors.black54,
                                                    fontSize: 14,
                                                    fontWeight: FontWeight.bold,
                                                    fontFamily: 'hind_semibold',
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                    Row(
                                      children: [
                                        const Expanded(
                                          flex: 3,
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Padding(
                                                padding: EdgeInsets.fromLTRB(0, 8, 0, 0),
                                                child: Text(
                                                  "Mandal",
                                                  style: TextStyle(
                                                    color: Colors.black,
                                                    fontSize: 14,
                                                    fontWeight: FontWeight.bold,
                                                    fontFamily: 'hind_semibold',
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        const Expanded(
                                          flex: 0,
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.end,
                                            mainAxisAlignment: MainAxisAlignment.end,
                                            children: [
                                              Padding(
                                                padding: EdgeInsets.fromLTRB(5, 8, 0, 0),
                                                child: Text(
                                                  ":",
                                                  style: TextStyle(
                                                    color: Colors.black54,
                                                    fontSize: 14,
                                                    fontWeight: FontWeight.bold,
                                                    fontFamily: 'hind_semibold',
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        Expanded(
                                          flex: 3,
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            mainAxisAlignment: MainAxisAlignment.start,
                                            children: [
                                              Padding(
                                                padding: const EdgeInsets.fromLTRB(5, 8, 0, 0),
                                                child: Text(
                                                  transportratelist[index].mandal,
                                                  style: const TextStyle(
                                                    color: Colors.black54,
                                                    fontSize: 14,
                                                    fontWeight: FontWeight.bold,
                                                    fontFamily: 'hind_semibold',
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                    Row(
                                      children: [
                                        const Expanded(
                                          flex: 3,
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Padding(
                                                padding: EdgeInsets.fromLTRB(0, 8, 0, 0),
                                                child: Text(
                                                  "Rate per Ton (Rs)",
                                                  style: TextStyle(
                                                    color: Colors.black,
                                                    fontSize: 14,
                                                    fontWeight: FontWeight.bold,
                                                    fontFamily: 'hind_semibold',
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        const Expanded(
                                          flex: 0,
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.end,
                                            mainAxisAlignment: MainAxisAlignment.end,
                                            children: [
                                              Padding(
                                                padding: EdgeInsets.fromLTRB(5, 8, 0, 0),
                                                child: Text(
                                                  ":",
                                                  style: TextStyle(
                                                    color: Colors.black54,
                                                    fontSize: 14,
                                                    fontWeight: FontWeight.bold,
                                                    fontFamily: 'hind_semibold',
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        Expanded(
                                          flex: 3,
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            mainAxisAlignment: MainAxisAlignment.start,
                                            children: [
                                              Padding(
                                                padding: const EdgeInsets.fromLTRB(5, 8, 0, 0),
                                                child: Text(
                                                  transportratelist[index].rate,
                                                  style: const TextStyle(
                                                    color: Colors.black54,
                                                    fontSize: 14,
                                                    fontWeight: FontWeight.bold,
                                                    fontFamily: 'hind_semibold',
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),

                                    // Adjust spacing between entries
                                  ],
                                )));
                      },
                    )),
                Container(
                  width: 60,
                  height: 30,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Color(0xFFCCCCCC),
                        Color(0xFFFFFFFF),
                        Color(0xFFCCCCCC),
                      ],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                    borderRadius: BorderRadius.circular(10.0),
                    border: Border.all(
                      width: 2.0,
                      color: Color(0xFFe86100),
                    ),
                  ),
                  child: ElevatedButton(
                    onPressed: () {
                      print('button1clicked');
                    },
                    child: Text(
                      'Ok',
                      style: TextStyle(
                        color: Color(0xFFe86100),
                        fontSize: 14,
                        fontFamily: 'hind_semibold',
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                    ),
                  ),
                ),
              ],
            )));
      },
    );
  }
}

class farmer_passbook extends StatefulWidget {
  // final String FarmerTransportfromdate;
  // final String FarmerTransporttodate;
  // final String farmercode;
  final List<PaymentResponse> payemntlistresp;
  final String totalffbcollections;
  final String closingbalance;

  final String accountHolderName;
  final String accountNumber;
  final String bankName;
  final String branchname;
  final String district;
  final String farmerCode;
  final String guardianName;
  final String ifscCode;
  final String mandal;
  final String state;
  final String village;
  final double totalAdjusted;
  final double totalAmount;
  final double totalBalance;
  final double totalGRAmount;
  final double totalQuanitity;

  farmer_passbook(
      {required this.payemntlistresp,
      required this.totalffbcollections,
      required this.closingbalance,
      required this.accountHolderName,
      required this.accountNumber,
      required this.bankName,
      required this.branchname,
      required this.district,
      required this.farmerCode,
      required this.guardianName,
      required this.ifscCode,
      required this.mandal,
      required this.state,
      required this.village,
      required this.totalAdjusted,
      required this.totalAmount,
      required this.totalBalance,
      required this.totalGRAmount,
      required this.totalQuanitity});

  @override
  farmer_passbookscreenstate createState() => farmer_passbookscreenstate();
}

class farmer_passbookscreenstate extends State<farmer_passbook> {
  @override
  void initState() {}

  String formatDateToApi(DateTime date) {
    final DateFormat apiDateFormat = DateFormat('yyyy-MM-dd');
    return apiDateFormat.format(date);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Consumer<DataProvider>(
        builder: (context, dataProvider, child) {
          // DateTime parsedDate = DateTime.parse(dataProvider.data1);
          // DateTime parsedDate1 = DateTime.parse(dataProvider.data2);
          //
          // // Format the DateTime object into the desired format
          // String formattedDate = DateFormat('dd/MM/yyyy').format(parsedDate);
          // final String fromFormattedDateApi = formatDateToApi(dataProvider.data1);
          // final String toFormattedDateApi = formatDateToApi(dataProvider.data2);
          // transportlistapitabs(parsedDate, parsedDate1, dataProvider.data3);
          return Container(
              // height: MediaQuery.of(context).size.height,
              child: Column(
            children: [
              Stack(
                children: [
                  Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                          height: 65,
                          width: MediaQuery.of(context).size.width,
                          decoration: BoxDecoration(
                            // color:  Color(0xFFe86100),
                            borderRadius: BorderRadius.circular(6.0),
                          ),
                          child: Padding(
                            padding: EdgeInsets.only(left: 12.0, right: 12.0, top: 12.0),
                            child: Container(
                              height: 50,
                              width: MediaQuery.of(context).size.width,
                              decoration: BoxDecoration(
                                color: Color(0x8D000000),
                                borderRadius: BorderRadius.circular(6.0),
                              ),
                              child: Column(children: [
                                Row(
                                  children: [
                                    Expanded(
                                      flex: 5,
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          const Padding(
                                            padding: EdgeInsets.fromLTRB(8, 7, 12, 0),
                                            child: Text(
                                              "Total FFB Qty (MT)",
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.bold,
                                                fontFamily: 'hind_semibold',
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Expanded(
                                      flex: 1,
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.center,
                                        children: [
                                          Padding(
                                            padding: EdgeInsets.fromLTRB(0, 7, 0, 0),
                                            child: Text(
                                              ":",
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold,
                                                fontFamily: 'hind_semibold',
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Expanded(
                                      flex: 4,
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        mainAxisAlignment: MainAxisAlignment.start,
                                        children: [
                                          Padding(
                                            padding: EdgeInsets.fromLTRB(0, 7, 0, 0),
                                            child: Text(
                                              '${widget.totalffbcollections ?? ''}',
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold,
                                                fontFamily: 'hind_semibold',
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                Row(
                                  children: [
                                    Expanded(
                                      flex: 5,
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          const Padding(
                                            padding: EdgeInsets.fromLTRB(8, 6, 12, 0),
                                            child: Text(
                                              "Closing Balance (Rs)",
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.bold,
                                                fontFamily: 'hind_semibold',
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Expanded(
                                      flex: 1,
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.center,
                                        children: [
                                          Padding(
                                            padding: EdgeInsets.fromLTRB(0, 0, 0, 0),
                                            child: Text(
                                              ":",
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold,
                                                fontFamily: 'hind_semibold',
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Expanded(
                                      flex: 4,
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        mainAxisAlignment: MainAxisAlignment.start,
                                        children: [
                                          Padding(
                                            padding: EdgeInsets.fromLTRB(0, 0, 0, 0),
                                            child: Text(
                                              '${widget.closingbalance ?? ''}',
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold,
                                                fontFamily: 'hind_semibold',
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ]),
                            ),
                          )),
                      Container(
                        height: MediaQuery.of(context).size.height / 2.5,
                        child: ListView.builder(
                          shrinkWrap: true,
                          itemCount: widget.payemntlistresp.length,
                          itemBuilder: (context, index) {
                            //     BranchModel branch = brancheslist[index]; // Get the branch at the current index
                            //    DateTime dateTime = DateTime.parse(paymentDetailsResponse_list[index].refDate as String);

                            // Format the date to dd/MM/yyyy
                            String formattedDate = DateFormat('dd/MM/yyyy').format(widget.payemntlistresp[index].refDate);
                            if (widget.payemntlistresp.length != 0) {
                              return Padding(
                                  //  padding: EdgeInsets.symmetric(horizontal: 0.0, vertical: 5.0),
                                  padding: EdgeInsets.only(left: 10, right: 10),
                                  child: IntrinsicHeight(
                                    child: ClipRRect(
                                        borderRadius: BorderRadius.circular(12.0),
                                        child: GestureDetector(
                                          onTap: () {},
                                          child: Card(
                                            shadowColor: Colors.transparent,
                                            surfaceTintColor: Colors.transparent,
                                            child: ClipRRect(
                                              borderRadius: BorderRadius.circular(12.0),
                                              //surfaceTintColor : Colors.red,

                                              child: Container(
                                                color: index.isEven ? Colors.white : Colors.grey[300],
                                                child: Row(
                                                  crossAxisAlignment: CrossAxisAlignment.center,
                                                  children: [
                                                    Container(
                                                        padding: EdgeInsets.all(12),
                                                        child: Row(
                                                          children: [
                                                            Center(
                                                              child: Column(
                                                                crossAxisAlignment: CrossAxisAlignment.center,
                                                                mainAxisAlignment: MainAxisAlignment.center,
                                                                children: [
                                                                  Container(
                                                                    //  margin: EdgeInsets.only(right: 10.0, left: 10),
                                                                    child: ClipRRect(
                                                                      borderRadius: BorderRadius.circular(7.0),
                                                                      // child: Image.asset(
                                                                      //   'assets/ic_calender.png',
                                                                      //   width: 30.0,
                                                                      //   height: 30.0,
                                                                      //   fit: BoxFit.cover,
                                                                      // ),
                                                                    ),
                                                                  ),
                                                                  SizedBox(height: 2.0),
                                                                  // Add some spacing between the image and text
                                                                  Text(
                                                                    '$formattedDate',
                                                                    style: TextStyle(
                                                                      color: Colors.grey,
                                                                    ),
                                                                    textAlign: TextAlign.center,
                                                                  ),
                                                                ],
                                                              ),
                                                            ),
                                                            SizedBox(width: 5.0),
                                                            Container(
                                                              width: 2.0,
                                                              padding: EdgeInsets.all(5),
                                                              // height: MediaQuery.of(context).size.height,
                                                              //  padding: EdgeInsets.only(top: 10, bottom: 10),
                                                              decoration: BoxDecoration(
                                                                gradient: LinearGradient(
                                                                  colors: [
                                                                    Color(0xFFFF4500),
                                                                    Color(0xFFA678EF),
                                                                    Color(0xFFFF4500),
                                                                  ],
                                                                  end: Alignment.topRight,
                                                                ),
                                                              ),
                                                            )
                                                          ],
                                                        )),
                                                    Expanded(
                                                        child: Padding(
                                                      padding: EdgeInsets.only(left: 0.0),
                                                      child: Column(
                                                          mainAxisAlignment: MainAxisAlignment.start,
                                                          crossAxisAlignment: CrossAxisAlignment.start,
                                                          children: [
                                                            Expanded(
                                                              child: Column(
                                                                children: [
                                                                  widget.payemntlistresp[index].amount != null &&
                                                                          widget.payemntlistresp[index].amount != 0
                                                                      ? Row(
                                                                          children: [
                                                                            Expanded(
                                                                              flex: 8,
                                                                              child: Column(
                                                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                                                children: [
                                                                                  const Padding(
                                                                                    padding: EdgeInsets.fromLTRB(5, 5, 12, 0),
                                                                                    child: Text(
                                                                                      "Amount (Rs)",
                                                                                      style: TextStyle(
                                                                                        color: Colors.grey,
                                                                                        fontWeight: FontWeight.bold,
                                                                                        fontSize: 14,
                                                                                        fontFamily: 'hind_semibold',
                                                                                      ),
                                                                                    ),
                                                                                  ),
                                                                                ],
                                                                              ),
                                                                            ),
                                                                            Expanded(
                                                                              flex: 1,
                                                                              child: Column(
                                                                                crossAxisAlignment: CrossAxisAlignment.center,
                                                                                children: [
                                                                                  Padding(
                                                                                    padding: EdgeInsets.fromLTRB(0, 5, 0, 0),
                                                                                    child: Text(
                                                                                      ":",
                                                                                      style: TextStyle(
                                                                                        color: Colors.grey,
                                                                                        fontSize: 14,
                                                                                        fontWeight: FontWeight.bold,
                                                                                        fontFamily: 'hind_semibold',
                                                                                      ),
                                                                                    ),
                                                                                  ),
                                                                                ],
                                                                              ),
                                                                            ),
                                                                            Expanded(
                                                                              flex: 8,
                                                                              child: Column(
                                                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                                                mainAxisAlignment: MainAxisAlignment.start,
                                                                                children: [
                                                                                  Padding(
                                                                                    padding: EdgeInsets.fromLTRB(0, 5, 0, 0),
                                                                                    child: Text(
                                                                                      '${widget.payemntlistresp[index].amount?.toStringAsFixed(2) ?? ''}',
                                                                                      style: TextStyle(
                                                                                        color: Colors.grey,
                                                                                        fontSize: 14,
                                                                                        fontWeight: FontWeight.bold,
                                                                                        fontFamily: 'hind_semibold',
                                                                                      ),
                                                                                    ),
                                                                                  ),
                                                                                ],
                                                                              ),
                                                                            ),
                                                                          ],
                                                                        )
                                                                      : SizedBox.shrink(),
                                                                  widget.payemntlistresp[index].adjusted != null &&
                                                                          widget.payemntlistresp[index].adjusted != 0
                                                                      ? Row(
                                                                          children: [
                                                                            Expanded(
                                                                              flex: 8,
                                                                              child: Column(
                                                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                                                children: [
                                                                                  const Padding(
                                                                                    padding: EdgeInsets.fromLTRB(5, 5, 12, 0),
                                                                                    child: Text(
                                                                                      "Adjusted (Rs)",
                                                                                      style: TextStyle(
                                                                                        color: Colors.grey,
                                                                                        fontWeight: FontWeight.bold,
                                                                                        fontSize: 14,
                                                                                        fontFamily: 'hind_semibold',
                                                                                      ),
                                                                                    ),
                                                                                  ),
                                                                                ],
                                                                              ),
                                                                            ),
                                                                            Expanded(
                                                                              flex: 1,
                                                                              child: Column(
                                                                                crossAxisAlignment: CrossAxisAlignment.center,
                                                                                children: [
                                                                                  Padding(
                                                                                    padding: EdgeInsets.fromLTRB(0, 5, 0, 0),
                                                                                    child: Text(
                                                                                      ":",
                                                                                      style: TextStyle(
                                                                                        color: Colors.grey,
                                                                                        fontSize: 14,
                                                                                        fontWeight: FontWeight.bold,
                                                                                        fontFamily: 'hind_semibold',
                                                                                      ),
                                                                                    ),
                                                                                  ),
                                                                                ],
                                                                              ),
                                                                            ),
                                                                            Expanded(
                                                                              flex: 8,
                                                                              child: Column(
                                                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                                                mainAxisAlignment: MainAxisAlignment.start,
                                                                                children: [
                                                                                  Padding(
                                                                                    padding: EdgeInsets.fromLTRB(0, 5, 0, 0),
                                                                                    child: Text(
                                                                                      '${widget.payemntlistresp[index].adjusted.toStringAsFixed(2) ?? ''}',
                                                                                      style: TextStyle(
                                                                                        color: Colors.grey,
                                                                                        fontSize: 14,
                                                                                        fontWeight: FontWeight.bold,
                                                                                        fontFamily: 'hind_semibold',
                                                                                      ),
                                                                                    ),
                                                                                  ),
                                                                                ],
                                                                              ),
                                                                            ),
                                                                          ],
                                                                        )
                                                                      : SizedBox.shrink(),
                                                                  widget.payemntlistresp[index].grAmount != null && widget.payemntlistresp[index].grAmount != 0
                                                                      ? Row(
                                                                          children: [
                                                                            Expanded(
                                                                              flex: 8,
                                                                              child: Column(
                                                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                                                children: [
                                                                                  const Padding(
                                                                                    padding: EdgeInsets.fromLTRB(5, 5, 12, 0),
                                                                                    child: Text(
                                                                                      "GB Amount (Rs)",
                                                                                      style: TextStyle(
                                                                                        color: Colors.grey,
                                                                                        fontWeight: FontWeight.bold,
                                                                                        fontSize: 14,
                                                                                        fontFamily: 'hind_semibold',
                                                                                      ),
                                                                                    ),
                                                                                  ),
                                                                                ],
                                                                              ),
                                                                            ),
                                                                            Expanded(
                                                                              flex: 1,
                                                                              child: Column(
                                                                                crossAxisAlignment: CrossAxisAlignment.center,
                                                                                children: [
                                                                                  Padding(
                                                                                    padding: EdgeInsets.fromLTRB(0, 5, 0, 0),
                                                                                    child: Text(
                                                                                      ":",
                                                                                      style: TextStyle(
                                                                                        color: Colors.grey,
                                                                                        fontSize: 14,
                                                                                        fontWeight: FontWeight.bold,
                                                                                        fontFamily: 'hind_semibold',
                                                                                      ),
                                                                                    ),
                                                                                  ),
                                                                                ],
                                                                              ),
                                                                            ),
                                                                            Expanded(
                                                                              flex: 8,
                                                                              child: Column(
                                                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                                                mainAxisAlignment: MainAxisAlignment.start,
                                                                                children: [
                                                                                  Padding(
                                                                                    padding: EdgeInsets.fromLTRB(0, 5, 0, 0),
                                                                                    child: Text(
                                                                                      '${widget.payemntlistresp[index].grAmount.toStringAsFixed(2) ?? ''}',
                                                                                      style: TextStyle(
                                                                                        color: Colors.grey,
                                                                                        fontSize: 14,
                                                                                        fontWeight: FontWeight.bold,
                                                                                        fontFamily: 'hind_semibold',
                                                                                      ),
                                                                                    ),
                                                                                  ),
                                                                                ],
                                                                              ),
                                                                            ),
                                                                          ],
                                                                        )
                                                                      : SizedBox.shrink(),
                                                                  widget.payemntlistresp[index].quantity != null && widget.payemntlistresp[index].quantity != 0
                                                                      ? Row(
                                                                          children: [
                                                                            Expanded(
                                                                              flex: 8,
                                                                              child: Column(
                                                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                                                children: [
                                                                                  const Padding(
                                                                                    padding: EdgeInsets.fromLTRB(5, 5, 12, 0),
                                                                                    child: Text(
                                                                                      "FFB Qty (MT)",
                                                                                      style: TextStyle(
                                                                                        color: Colors.grey,
                                                                                        fontWeight: FontWeight.bold,
                                                                                        fontSize: 14,
                                                                                        fontFamily: 'hind_semibold',
                                                                                      ),
                                                                                    ),
                                                                                  ),
                                                                                ],
                                                                              ),
                                                                            ),
                                                                            Expanded(
                                                                              flex: 1,
                                                                              child: Column(
                                                                                crossAxisAlignment: CrossAxisAlignment.center,
                                                                                children: [
                                                                                  Padding(
                                                                                    padding: EdgeInsets.fromLTRB(0, 5, 0, 0),
                                                                                    child: Text(
                                                                                      ":",
                                                                                      style: TextStyle(
                                                                                        color: Colors.grey,
                                                                                        fontSize: 14,
                                                                                        fontWeight: FontWeight.bold,
                                                                                        fontFamily: 'hind_semibold',
                                                                                      ),
                                                                                    ),
                                                                                  ),
                                                                                ],
                                                                              ),
                                                                            ),
                                                                            Expanded(
                                                                              flex: 8,
                                                                              child: Column(
                                                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                                                mainAxisAlignment: MainAxisAlignment.start,
                                                                                children: [
                                                                                  Padding(
                                                                                    padding: EdgeInsets.fromLTRB(0, 5, 0, 0),
                                                                                    child: Text(
                                                                                      '${widget.payemntlistresp[index].quantity.toStringAsFixed(2) ?? ''}',
                                                                                      style: TextStyle(
                                                                                        color: Colors.grey,
                                                                                        fontSize: 14,
                                                                                        fontWeight: FontWeight.bold,
                                                                                        fontFamily: 'hind_semibold',
                                                                                      ),
                                                                                    ),
                                                                                  ),
                                                                                ],
                                                                              ),
                                                                            ),
                                                                          ],
                                                                        )
                                                                      : SizedBox.shrink(),
                                                                  widget.payemntlistresp[index].adhocRate != null && widget.payemntlistresp[index].adhocRate != 0
                                                                      ? Row(
                                                                          children: [
                                                                            Expanded(
                                                                              flex: 8,
                                                                              child: Column(
                                                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                                                children: [
                                                                                  const Padding(
                                                                                    padding: EdgeInsets.fromLTRB(5, 5, 12, 0),
                                                                                    child: Text(
                                                                                      "Adhoc Rate per MT (Rs)",
                                                                                      style: TextStyle(
                                                                                        color: Colors.grey,
                                                                                        fontWeight: FontWeight.bold,
                                                                                        fontSize: 14,
                                                                                        fontFamily: 'hind_semibold',
                                                                                      ),
                                                                                    ),
                                                                                  ),
                                                                                ],
                                                                              ),
                                                                            ),
                                                                            Expanded(
                                                                              flex: 1,
                                                                              child: Column(
                                                                                crossAxisAlignment: CrossAxisAlignment.center,
                                                                                children: [
                                                                                  Padding(
                                                                                    padding: EdgeInsets.fromLTRB(0, 5, 0, 0),
                                                                                    child: Text(
                                                                                      ":",
                                                                                      style: TextStyle(
                                                                                        color: Colors.grey,
                                                                                        fontSize: 14,
                                                                                        fontWeight: FontWeight.bold,
                                                                                        fontFamily: 'hind_semibold',
                                                                                      ),
                                                                                    ),
                                                                                  ),
                                                                                ],
                                                                              ),
                                                                            ),
                                                                            Expanded(
                                                                              flex: 8,
                                                                              child: Column(
                                                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                                                mainAxisAlignment: MainAxisAlignment.start,
                                                                                children: [
                                                                                  Padding(
                                                                                    padding: EdgeInsets.fromLTRB(0, 5, 0, 0),
                                                                                    child: Text(
                                                                                      '${widget.payemntlistresp[index].adhocRate.toStringAsFixed(2) ?? ''}',
                                                                                      style: TextStyle(
                                                                                        color: Colors.grey,
                                                                                        fontSize: 14,
                                                                                        fontWeight: FontWeight.bold,
                                                                                        fontFamily: 'hind_semibold',
                                                                                      ),
                                                                                    ),
                                                                                  ),
                                                                                ],
                                                                              ),
                                                                            ),
                                                                          ],
                                                                        )
                                                                      : SizedBox.shrink(),
                                                                  widget.payemntlistresp[index].invoiceRate != null &&
                                                                      widget.payemntlistresp[index].invoiceRate != 0
                                                                      ? Row(
                                                                          children: [
                                                                            Expanded(
                                                                              flex: 8,
                                                                              child: Column(
                                                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                                                children: [
                                                                                  Padding(
                                                                                    padding: EdgeInsets.fromLTRB(5, 5, 12, 0),
                                                                                    child: Text(
                                                                                      "Invoice Rate per MT (Rs)",
                                                                                      style: TextStyle(
                                                                                        color: Colors.grey,
                                                                                        fontWeight: FontWeight.bold,
                                                                                        fontSize: 14,
                                                                                        fontFamily: 'hind_semibold',
                                                                                      ),
                                                                                    ),
                                                                                  ),
                                                                                ],
                                                                              ),
                                                                            ),
                                                                            Expanded(
                                                                              flex: 1,
                                                                              child: Column(
                                                                                crossAxisAlignment: CrossAxisAlignment.center,
                                                                                children: [
                                                                                  Padding(
                                                                                    padding: EdgeInsets.fromLTRB(0, 5, 0, 0),
                                                                                    child: Text(
                                                                                      ":",
                                                                                      style: TextStyle(
                                                                                        color: Colors.grey,
                                                                                        fontSize: 14,
                                                                                        fontWeight: FontWeight.bold,
                                                                                        fontFamily: 'hind_semibold',
                                                                                      ),
                                                                                    ),
                                                                                  ),
                                                                                ],
                                                                              ),
                                                                            ),
                                                                            Expanded(
                                                                              flex: 8,
                                                                              child: Column(
                                                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                                                mainAxisAlignment: MainAxisAlignment.start,
                                                                                children: [
                                                                                  Padding(
                                                                                    padding: EdgeInsets.fromLTRB(0, 5, 0, 0),
                                                                                    child: Text(
                                                                                      '${widget.payemntlistresp[index].invoiceRate.toStringAsFixed(2) ?? ''}',
                                                                                      style: TextStyle(
                                                                                        color: Colors.grey,
                                                                                        fontSize: 14,
                                                                                        fontWeight: FontWeight.bold,
                                                                                        fontFamily: 'hind_semibold',
                                                                                      ),
                                                                                    ),
                                                                                  ),
                                                                                ],
                                                                              ),
                                                                            ),
                                                                          ],
                                                                        )
                                                                      : SizedBox.shrink(),
                                                                  Row(
                                                                    children: [
                                                                      Expanded(
                                                                        flex: 8,
                                                                        child: Column(
                                                                          crossAxisAlignment: CrossAxisAlignment.start,
                                                                          children: [
                                                                            const Padding(
                                                                              padding: EdgeInsets.fromLTRB(5, 5, 12, 0),
                                                                              child: Text(
                                                                                "Description",
                                                                                style: TextStyle(
                                                                                  color: Colors.grey,
                                                                                  fontWeight: FontWeight.bold,
                                                                                  fontSize: 14,
                                                                                  fontFamily: 'hind_semibold',
                                                                                ),
                                                                              ),
                                                                            ),
                                                                          ],
                                                                        ),
                                                                      ),
                                                                      Expanded(
                                                                        flex: 1,
                                                                        child: Column(
                                                                          crossAxisAlignment: CrossAxisAlignment.center,
                                                                          children: [
                                                                            Padding(
                                                                              padding: EdgeInsets.fromLTRB(0, 5, 0, 0),
                                                                              child: Text(
                                                                                ":",
                                                                                style: TextStyle(
                                                                                  color: Colors.grey,
                                                                                  fontSize: 14,
                                                                                  fontWeight: FontWeight.bold,
                                                                                  fontFamily: 'hind_semibold',
                                                                                ),
                                                                              ),
                                                                            ),
                                                                          ],
                                                                        ),
                                                                      ),
                                                                      Expanded(
                                                                        flex: 8,
                                                                        child: Column(
                                                                          crossAxisAlignment: CrossAxisAlignment.start,
                                                                          mainAxisAlignment: MainAxisAlignment.start,
                                                                          children: [
                                                                            Padding(
                                                                              padding: EdgeInsets.fromLTRB(0, 5, 0, 0),
                                                                              child: Text(
                                                                                '${widget.payemntlistresp[index].memo}',
                                                                                style: TextStyle(
                                                                                  color: Colors.grey,
                                                                                  fontSize: 14,
                                                                                  fontWeight: FontWeight.bold,
                                                                                  fontFamily: 'hind_semibold',
                                                                                ),
                                                                              ),
                                                                            ),
                                                                          ],
                                                                        ),
                                                                      ),
                                                                    ],
                                                                  ),
                                                                  widget.payemntlistresp[index].balance != null && widget.payemntlistresp[index].balance != 0
                                                                      ? Row(
                                                                          children: [
                                                                            Expanded(
                                                                              flex: 8,
                                                                              child: Column(
                                                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                                                children: [
                                                                                  const Padding(
                                                                                    padding: EdgeInsets.fromLTRB(5, 5, 12, 0),
                                                                                    child: Text(
                                                                                      "Balance (Rs)",
                                                                                      style: TextStyle(
                                                                                        color: Colors.grey,
                                                                                        fontWeight: FontWeight.bold,
                                                                                        fontSize: 14,
                                                                                        fontFamily: 'hind_semibold',
                                                                                      ),
                                                                                    ),
                                                                                  ),
                                                                                ],
                                                                              ),
                                                                            ),
                                                                            Expanded(
                                                                              flex: 1,
                                                                              child: Column(
                                                                                crossAxisAlignment: CrossAxisAlignment.center,
                                                                                children: [
                                                                                  Padding(
                                                                                    padding: EdgeInsets.fromLTRB(0, 5, 0, 0),
                                                                                    child: Text(
                                                                                      ":",
                                                                                      style: TextStyle(
                                                                                        color: Colors.grey,
                                                                                        fontSize: 14,
                                                                                        fontWeight: FontWeight.bold,
                                                                                        fontFamily: 'hind_semibold',
                                                                                      ),
                                                                                    ),
                                                                                  ),
                                                                                ],
                                                                              ),
                                                                            ),
                                                                            Expanded(
                                                                              flex: 8,
                                                                              child: Column(
                                                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                                                mainAxisAlignment: MainAxisAlignment.start,
                                                                                children: [
                                                                                  Padding(
                                                                                    padding: EdgeInsets.fromLTRB(0, 5, 0, 0),
                                                                                    child: Text(
                                                                                      '${widget.payemntlistresp[index].balance.toStringAsFixed(2)}',
                                                                                      style: TextStyle(
                                                                                        color: Colors.grey,
                                                                                        fontSize: 14,
                                                                                        fontWeight: FontWeight.bold,
                                                                                        fontFamily: 'hind_semibold',
                                                                                      ),
                                                                                    ),
                                                                                  ),
                                                                                ],
                                                                              ),
                                                                            ),
                                                                          ],
                                                                        )
                                                                      : SizedBox.shrink(),
                                                                ],
                                                              ),
                                                            ),
                                                          ]),
                                                    ))
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ),
                                        )),
                                  ));
                            } else {
                              return Center(child: Text('No Farmer Passbook available'));
                            }
                          },
                        ),
                      ),
                      Align(
                          alignment: Alignment.bottomCenter,
                          child: Container(


                              // height: 200,
                              child:   Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Container(
                                  ///  padding: EdgeInsets.all(10),
                                    padding: EdgeInsets.only(left: 10,right:10,bottom: 5),

                                    child:  Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      children: [
                                        Expanded(
                                          flex: 1,
                                          child: Container(
                                            //  width: 175,
                                            height: 75,
                                            decoration: BoxDecoration(
                                              gradient: LinearGradient(
                                                colors: [
                                                  Color(0xFFCCCCCC),
                                                  Color(0xFFFFFFFF),
                                                  Color(0xFFCCCCCC),
                                                ],
                                                begin: Alignment.topCenter,
                                                end: Alignment.bottomCenter,
                                              ),
                                              borderRadius: BorderRadius.circular(10.0),
                                              border: Border.all(
                                                width: 2.0,
                                                color: Color(0xFFe86100),
                                              ),
                                            ),
                                            child: ElevatedButton(
                                              onPressed: () {
                                                print('button1clicked');
                                                //openFile();
                                              },
                                              child: Text(
                                                'Downloaded Files',
                                                style: TextStyle(
                                                  color: Color(0xFFe86100),
                                                  fontSize: 12,
                                                  fontFamily: 'hind_semibold',
                                                ),
                                              ),
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor: Colors.transparent,
                                                elevation: 0,
                                                shape: RoundedRectangleBorder(
                                                  borderRadius: BorderRadius.circular(10.0),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                        SizedBox(width: 8.0),
                                        Expanded(
                                          flex: 1,
                                          child: Container(
                                            width: MediaQuery.of(context).size.width,
                                            height: 75,
                                            decoration: BoxDecoration(
                                              gradient: LinearGradient(
                                                colors: [
                                                  Color(0xFFCCCCCC),
                                                  Color(0xFFFFFFFF),
                                                  Color(0xFFCCCCCC),
                                                ],
                                                begin: Alignment.topCenter,
                                                end: Alignment.bottomCenter,
                                              ),
                                              borderRadius: BorderRadius.circular(10.0),
                                              border: Border.all(
                                                width: 2.0,
                                                color: Color(0xFFe86100),
                                              ),
                                            ),
                                            child: ElevatedButton(
                                              onPressed: () {
                                                print('button2clicked');
                                                exportPayments(widget.payemntlistresp, context);
                                              },
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor: Colors.transparent,
                                                elevation: 0,
                                                shape: RoundedRectangleBorder(
                                                  borderRadius: BorderRadius.circular(10.0),
                                                ),
                                              ),
                                              child: Container(
                                                alignment: Alignment.center,
                                                child: Text(
                                                  'Click Here to Download',
                                                  style: TextStyle(
                                                    color: Color(0xFFe86100),
                                                    fontSize: 12,
                                                    fontFamily: 'hind_semibold',
                                                  ),
                                                  maxLines: 1,
                                                  textAlign: TextAlign.center,
                                                  overflow: TextOverflow.ellipsis,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),

                                  SizedBox(height: 5.0),
                                  Container(
                                    padding: EdgeInsets.only(left: 8,right:8),

                                    /// flex: 1,
                                    width: MediaQuery.of(context).size.width,
                                    child: Card(
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(10.0),
                                        side: BorderSide(
                                          color: Color(0xFFBE9747), // Border color
                                        ),
                                      ),
                                      color: Color(0xFFFFFACB),
                                      // Background color
                                      child: Column(
                                        children: [
                                          ListTile(
                                            title: RichText(
                                              text: TextSpan(
                                                text: 'Note: \n',
                                                style: TextStyle(
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.normal,
                                                  color: Color(0xFFe86100), // Color for "Note: \n"
                                                ),
                                                children: [
                                                  TextSpan(
                                                    text:
                                                    'FFB Collections which are still payment pending will not show, after Payment only they will start showing',
                                                    style: TextStyle(
                                                      fontSize: 14,
                                                      fontWeight: FontWeight.normal,
                                                      color: Colors.black, // Color for the rest of the text
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),))
                    ],
                  )
                ],
              )
            ],
          ));
        },
      ),
    );
  }

  // Future<void> exportPayments(List<PaymentResponse> paymentResponse, BuildContext context) async {
  //   // API URL
  //   String url = 'http://182.18.157.215/3FAkshaya/API/api/Payment/ExportPayments';
  //
  //   // List of payment responses
  //   List<Map<String, dynamic>> paymentResponseMaps = paymentResponse.map((response) => response.toJson()).toList();
  //
  //   // API body data
  //   Map<String, dynamic> requestBody = {
  //     "bankDetails": {
  //       "accountHolderName": "${widget.accountHolderName}",
  //       "accountNumber": "${widget.accountNumber}",
  //       "bankName": "${widget.bankName}",
  //       "branchName": "${widget.branchname}",
  //       "district": "${widget.district}",
  //       "farmerCode": "${widget.farmerCode}",
  //       "guardianName": "${widget.guardianName}",
  //       "ifscCode": "${widget.ifscCode}",
  //       "mandal": "${widget.mandal}",
  //       "state": "${widget.state}",
  //       "village": "${widget.village}"
  //     },
  //     "paymentResponce": paymentResponseMaps,
  //     "totalAdjusted": {widget.totalAdjusted},
  //     "totalAmount": {widget.totalAmount},
  //     "totalBalance": {widget.totalBalance},
  //     "totalGRAmount": {widget.totalGRAmount},
  //     "totalQuanitity": {widget.totalQuanitity}
  //   };
  //
  //   // Convert the request body to JSON
  //   String jsonBody = json.encode(requestBody);
  //
  //   try {
  //     // Make the POST request
  //     final response = await http.post(
  //       Uri.parse(url),
  //       headers: {
  //         'Content-Type': 'application/json',
  //       },
  //       body: jsonBody,
  //     );
  //
  //     // Check if the request was successful
  //     if (response.statusCode == 200) {
  //       // Handle the response data here
  //       print('Response body: ${response.body}');
  //       String base64string = response.body;
  //       convertBase64ToExcel(base64string, context);
  //     } else {
  //
  //       // Handle the error
  //       print('Failed to export payments. Status code: ${response.statusCode}');
  //     }
  //   } catch (e) {
  //     // Handle any exceptions that occur during the request
  //     print('Error: $e');
  //   }
  // }
  Future<void> exportPayments(List<PaymentResponse> paymentResponse, BuildContext context) async {
    // API URL
    String url = 'http://182.18.157.215/3FAkshaya/API/api/Payment/ExportPayments';

    // List of payment responses
    List<Map<String, dynamic>> paymentResponseMaps = paymentResponse.map((response) => response.toJson()).toList();

    // API body data
    Map<String, dynamic> requestBody = {
      "bankDetails": {
        "accountHolderName": widget.accountHolderName,
        "accountNumber": widget.accountNumber,
        "bankName": widget.bankName,
        "branchName": widget.branchname,
        "district": widget.district,
        "farmerCode": widget.farmerCode,
        "guardianName": widget.guardianName,
        "ifscCode": widget.ifscCode,
        "mandal": widget.mandal,
        "state": widget.state,
        "village": widget.village,
      },
      "paymentResponce": paymentResponseMaps,
      "totalAdjusted": widget.totalAdjusted,
      "totalAmount": widget.totalAmount,
      "totalBalance": widget.totalBalance,
      "totalGRAmount": widget.totalGRAmount,
      "totalQuanitity": widget.totalQuanitity,
    };

    // Convert the request body to JSON
    String jsonBody = json.encode(requestBody);

    try {
      // Make the POST request
      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonBody,
      );

      // Check if the request was successful
      if (response.statusCode == 200) {
        // Handle the response data here
        print('Response body: ${response.body}');
        String base64string = response.body;
        convertBase64ToExcel(base64string, context);
      } else {
        // Handle the error
        print('Failed to export payments. Status code: ${response.statusCode}');
      }
    } catch (e) {
      // Handle any exceptions that occur during the request
      print('Error: $e');
    }
  }

 Future<void> convertBase64ToExcel(String base64String, BuildContext context) async {
    String _base64String = sanitizeBase64(base64String);
    print('_base64String${_base64String}');
    // Decode the Base64 String
    List<int> excelBytes = base64Decode(_base64String);

    // Get the directory to save the file (external storage for visibility)
    //  Directory? directory = await getExternalStorageDirectory()!;

    // Define the folder and file path
    //   String folderName = 'MyExcelFiles';
    //   Directory newFolder = Directory('${directory!.path}/$folderName');
    //   if (!await newFolder.exists()) {
    //     await newFolder.create(recursive: true);
    //     print('Folder created at ${newFolder.path}');
    //   }
    Directory directoryPath = Directory('/storage/emulated/0/Download/Excel_Groups/ledger');
    if (!directoryPath.existsSync()) {
      directoryPath.createSync(recursive: true);
    }
    String filePath = directoryPath.path;
    String fileName = "Excel.xlsx";

    final File file = File('$filePath/$fileName');
    print('file${file}');
    await file.create(recursive: true);
    await file.writeAsBytes(excelBytes);

    // String filePath = '${newFolder.path}/output.xlsx';
    // print('filePath $filePath');
    //
    // // Write the data to the file
    // File file = File(filePath);
    // await file.writeAsBytes(excelBytes);
    // print('File saved at $filePath');
    //
    // // Notify the media scanner (Android only)
    // if (Platform.isAndroid) {
    //   await Process.run('cmd', ['media', 'scan', filePath]);
    // }

    await openFile(filePath);
  }

  Future<void> openFile(String filePath) async {
    final url = Uri.file(filePath).toString();
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      print('Could not open the file');
    }
  }
  String sanitizeBase64(String base64String) {
    return base64String.replaceAll(RegExp(r'\s+'), '').replaceAll('"', '');
  }
}
