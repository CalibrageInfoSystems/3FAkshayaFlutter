// ignore_for_file: unused_local_variable

import 'dart:convert';

import 'package:akshaya_flutter/common_utils/api_config.dart';
import 'package:akshaya_flutter/common_utils/common_styles.dart';
import 'package:akshaya_flutter/common_utils/common_widgets.dart';
import 'package:akshaya_flutter/common_utils/custom_appbar.dart';
import 'package:akshaya_flutter/common_utils/custom_btn.dart';
import 'package:akshaya_flutter/common_utils/shared_prefs_keys.dart';
import 'package:akshaya_flutter/gen/assets.gen.dart';
import 'package:akshaya_flutter/localization/locale_keys.dart';
import 'package:akshaya_flutter/main.dart';
import 'package:akshaya_flutter/models/passbook_transport_model.dart';
import 'package:akshaya_flutter/models/passbook_vendor_model.dart';
import 'package:auto_animated/auto_animated.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_custom_month_picker/flutter_custom_month_picker.dart';
// import 'package:flutter_custom_month_picker/flutter_custom_month_picker.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:open_filex/open_filex.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:io';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class FarmerPassbookInfo extends StatefulWidget {
  const FarmerPassbookInfo(
      {super.key,
      required this.accountHolderName,
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

  final String accountHolderName;
  final String accountNumber;
  final String bankName;
  final String branchName;
  final String district;
  final String farmerCode;
  final String guardianName;
  final String ifscCode;
  final String mandal;
  final String state;
  final String village;

  @override
  State<FarmerPassbookInfo> createState() => _FarmerPassbookInfoState();
}

class _FarmerPassbookInfoState extends State<FarmerPassbookInfo> {
  final List<String> dropdownItems = [
    tr(LocaleKeys.last_month),
    tr(LocaleKeys.last_threemonth),
    tr(LocaleKeys.currentfinicialP),
    tr(LocaleKeys.selectedP),
  ];

  String? selectedDropDownValue = tr(LocaleKeys.last_month);

  DateTime? selectedFromDate;
  DateTime? selectedToDate;
  String? displayFromDate;
  String? displayToDate;

  bool isTimePeriod = false;

  late PassbookData futureData;

  @override
  void initState() {
    super.initState();
    checkStoragePermission();
    futureData = getInitialData();
  }

  PassbookData getInitialData() {
    String fromDate = getFirstDayOfPreviousMonth();
    String toDate = getToDate();
    return PassbookData(
        passbookVendorModel: getVendorData(fromDate: fromDate, toDate: toDate),
        passbookTransportModel:
            getTransportData(fromDate: fromDate, toDate: toDate));
  }

  String getToDate() {
    DateFormat formatter = DateFormat('yyyy-MM-dd');
    String toDate =
        formatter.format(DateTime.now().add(const Duration(days: 60)));
    return toDate;
  }

  String getFirstDayOfPreviousMonth() {
    DateTime now = DateTime.now();
    DateTime previousMonth = DateTime(now.year, now.month - 1, 1);

    if (now.month == 1) {
      previousMonth = DateTime(now.year - 1, 12, 1);
    }

    return '${previousMonth.year}-${previousMonth.month.toString().padLeft(2, '0')}-${previousMonth.day}';
  }

  String getFirstDayOfThreeMonthsAgo() {
    DateTime now = DateTime.now();
    DateTime threeMonthsAgo = DateTime(now.year, now.month - 3, 1);

    if (now.month <= 3) {
      threeMonthsAgo = DateTime(now.year - 1, now.month + 9, 1);
    }
    return '${threeMonthsAgo.year}-${threeMonthsAgo.month.toString().padLeft(2, '0')}-${threeMonthsAgo.day}';
  }

  PassbookData getLastThreeMonthsData() {
    /* DateFormat formatter = DateFormat('yyyy-MM-dd');
    String fromDate =
        formatter.format(DateTime.now().subtract(const Duration(days: 90)));
    String toDate = formatter.format(DateTime.now()); */

    String fromDate = getFirstDayOfThreeMonthsAgo();
    String toDate = getToDate();

    return PassbookData(
      passbookVendorModel: getVendorData(fromDate: fromDate, toDate: toDate),
      passbookTransportModel:
          getTransportData(fromDate: fromDate, toDate: toDate),
    );
  }

  PassbookData getLastOneYearData() {
    DateFormat formatter = DateFormat('yyyy-MM-dd');
    String fromDate =
        formatter.format(DateTime.now().subtract(const Duration(days: 365)));
    String toDate = formatter.format(DateTime.now());

    return PassbookData(
      passbookVendorModel: getVendorData(fromDate: fromDate, toDate: toDate),
      passbookTransportModel:
          getTransportData(fromDate: fromDate, toDate: toDate),
    );
  }

  PassbookData getLastFinancialYearData() {
    DateTime now = DateTime.now();
    DateFormat formatter = DateFormat('yyyy-MM-dd');

    DateTime financialYearStart = DateTime(now.year, 4, 1);

    if (now.isBefore(financialYearStart)) {
      financialYearStart = DateTime(now.year - 1, 4, 1);
    }

    String fromDate = formatter.format(financialYearStart);
    String toDate = getToDate();

    return PassbookData(
      passbookVendorModel: getVendorData(fromDate: fromDate, toDate: toDate),
      passbookTransportModel:
          getTransportData(fromDate: fromDate, toDate: toDate),
    );
  }

  PassbookData getDataByCustomDates({String? fromDate, String? toDate}) {
    return PassbookData(
      passbookVendorModel: getVendorData(
          fromDate: fromDate, toDate: toDate, isCustomDates: false),
      passbookTransportModel: getTransportData(
          fromDate: fromDate, toDate: toDate, isCustomDates: false),
    );
  }

  Future<PassbookVendorModel> getVendorData(
      {required String? fromDate,
      required String? toDate,
      bool? isCustomDates = true}) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final code = prefs.getString(SharedPrefsKeys.farmerCode);
    final farmerCode = "V${code!.substring(2)}";
    final apiUrl = baseUrl + getvendordata;
    final requestBody = {
      "vendorCode": farmerCode,
      "fromDate": fromDate,
      "toDate": toDate,
    };

    final jsonResponse = await http
        .post(Uri.parse(apiUrl), body: jsonEncode(requestBody), headers: {
      'Content-Type': 'application/json',
    });

    print('passbook 1: $apiUrl');
    print('passbook 1: ${jsonEncode(requestBody)}');
    // print('passbook 1: ${jsonResponse.body}');

    if (jsonResponse.statusCode == 200) {
      if (isCustomDates!) {
        setState(() {
          isTimePeriod = false;
        });
      }

      Map<String, dynamic> response = jsonDecode(jsonResponse.body);
      if (response['result'] != null) {
        return passbookVendorModelFromJson(jsonResponse.body);
      } else {
        return throw Exception(tr(LocaleKeys.no_data));
      }
    } else {
      if (isCustomDates!) {
        setState(() {
          isTimePeriod = false;
        });
      }
      throw Exception(
          'Request failed with status: ${jsonResponse.statusCode}.');
    }
  }

  Future<PassbookTransportModel> getTransportData(
      {required String? fromDate,
      required String? toDate,
      bool? isCustomDates = true}) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final farmerCode = prefs.getString(SharedPrefsKeys.farmerCode);
    final apiUrl = baseUrl + getTranspotationdata;
    final requestBody = {
      "vendorCode": farmerCode,
      "fromDate": fromDate,
      "toDate": toDate,
    };

    final jsonResponse = await http
        .post(Uri.parse(apiUrl), body: jsonEncode(requestBody), headers: {
      'Content-Type': 'application/json',
    });

    print('passbook 2: $apiUrl');
    print('passbook 2: ${jsonEncode(requestBody)}');
    // print('passbook 2: ${jsonResponse.body}');

    if (jsonResponse.statusCode == 200) {
      if (isCustomDates!) {
        setState(() {
          isTimePeriod = false;
        });
      }
      return passbookTransportModelFromJson(jsonResponse.body);
    } else {
      if (isCustomDates!) {
        setState(() {
          isTimePeriod = false;
        });
      }
      throw Exception(
          'Request failed with status: ${jsonResponse.statusCode}.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: CommonStyles.screenBgColor,
        appBar: appBar(),
        body: Column(
          children: [
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    CommonStyles.appBarColor,
                    Color.fromARGB(255, 238, 145, 74),
                    CommonStyles.gradientColor2,
                    /*  CommonStyles.appBarColor, 
                    CommonStyles.gradientColor1,
                    CommonStyles.gradientColor2, */
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
              child: Column(
                children: [
                  dropdownSelector(),
                  if (isTimePeriod) datePickerSection(),
                  tabBar(),
                ],
              ),
            ),
            Expanded(
              child: tabView(),
            ),
          ],
        ),
      ),
    );
  }

  Widget tabBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: TabBar(
        labelStyle: CommonStyles.txStyF14CbFF6.copyWith(
          fontWeight: FontWeight.w400,
        ),
        dividerColor: Colors.transparent,
        // indicatorPadding: const EdgeInsets.only(bottom: 3),
        indicatorColor: CommonStyles.primaryTextColor,
        indicatorWeight: 10.0,
        indicatorSize: TabBarIndicatorSize.tab,
        labelColor: CommonStyles.primaryTextColor,
        unselectedLabelColor: CommonStyles.whiteColor,
        indicator: const BoxDecoration(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(10),
            topRight: Radius.circular(10),
          ),
          border: Border(
              bottom: BorderSide(
            color: Colors.redAccent,
            width: 1.4,
          )),
          color: CommonStyles.primaryColor,
        ),
        tabs: [
          Tab(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 10),
                Text(
                  tr(LocaleKeys.payments),
                  textAlign: TextAlign.center,
                  overflow: TextOverflow.visible,
                  style: tabLabelStyle(),
                ),
              ],
            ),
          ),
          Tab(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 10),
                Text(
                  tr(LocaleKeys.trans),
                  textAlign: TextAlign.center,
                  overflow: TextOverflow.visible,
                  style: tabLabelStyle(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  TextStyle tabLabelStyle() {
    return const TextStyle(
      height: 1.2,
      fontSize: 14,
      fontWeight: FontWeight.w500,
    );
  }

//MARK: datePickerSection
  Widget datePickerSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12).copyWith(bottom: 10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: CommonStyles.whiteColor),
        ),
        child: Row(
          children: [
            Expanded(
              child: datePickerBox(
                dateLabel: tr(LocaleKeys.fromDateWithOutStar),
                displaydate: displayFromDate,
                onTap: () {
                  final currentDate = DateTime.now();
                  final firstDate = DateTime(currentDate.year - 100);
                  launchFromDatePicker(context,
                      firstYear: firstDate.year,
                      lastYear: currentDate.year,
                      initialSelectedMonth: currentDate.month,
                      initialSelectedYear: currentDate.year);
                },
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
                child: datePickerBox(
              dateLabel: tr(LocaleKeys.toDateWithOutStar),
              // dateLabel: 'To Date',
              displaydate: displayToDate,
              onTap: () {
                final DateTime currentDate = DateTime.now();
                final DateTime firstDate = DateTime(currentDate.year - 100);
                launchToDatePicker(context,
                    firstYear: firstDate.year,
                    lastYear: currentDate.year,
                    initialSelectedMonth: currentDate.month,
                    initialSelectedYear: currentDate.year);
              },
            )),
            const SizedBox(width: 10),
            Expanded(
              flex: 1,
              child: CustomBtn(
                  label: tr(LocaleKeys.submit),
                  onPressed: () {
                    if (selectedFromDate == null || selectedToDate == null) {
                      return CommonStyles.errorDialog(context,
                          errorMessage: tr(LocaleKeys.enter_Date));
                    } else if (selectedToDate!.isBefore(selectedFromDate!)) {
                      return CommonStyles.errorDialog(context,
                          errorMessage: tr(LocaleKeys.datevalidation));
                    } else {
                      //MARK: Submit Btn
                      validateAndSubmit(
                          CommonStyles.formatApiDate(selectedFromDate),
                          CommonStyles.formatApiDate(selectedToDate));
                    }
                  }),
            ),
          ],
        ),
      ),
    );
  }

/* 
  Widget datePickerSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12).copyWith(bottom: 10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: CommonStyles.whiteColor),
        ),
        child: Row(
          children: [
            Expanded(
              child: datePickerBox(
                dateLabel: tr(LocaleKeys.from_date),
                displaydate: displayFromDate,
                onTap: () {
                  final DateTime currentDate = DateTime.now();
                  final DateTime firstDate = DateTime(currentDate.year - 100);
                  launchFromDatePicker(
                    context,
                    firstDate: firstDate,
                    lastDate: currentDate,
                  );
                },
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
                child: datePickerBox(
              dateLabel: tr(LocaleKeys.to_date),
              // dateLabel: 'To Date',
              displaydate: displayToDate,
              onTap: () {
                final DateTime currentDate = DateTime.now();
                final DateTime firstDate = DateTime(currentDate.year - 100);
                launchToDatePicker(context,
                    firstDate: selectedFromDate ?? firstDate,
                    lastDate: currentDate,
                    initialDate: selectedFromDate);
              },
            )),
            const SizedBox(width: 10),
            Expanded(
              flex: 1,
              child: CustomBtn(
                  label: tr(LocaleKeys.submit),
                  onPressed: () {
                    if (selectedFromDate == null || selectedToDate == null) {
                      return CommonStyles.errorDialog(context,
                          errorMessage: tr(LocaleKeys.enter_Date));
                    } else if (selectedToDate!.isBefore(selectedFromDate!)) {
                      return CommonStyles.errorDialog(context,
                          errorMessage: tr(LocaleKeys.datevalidation));
                    } else {
                      validateAndSubmit(
                          CommonStyles.formatApiDate(selectedFromDate),
                          CommonStyles.formatApiDate(selectedToDate));
                    }
                  }),
            ),
          ],
        ),
      ),
    );
  }
 */

  Future<void> launchFromDatePicker(
    BuildContext context, {
    required int? firstYear,
    required int? lastYear,
    int? initialSelectedMonth,
    int? initialSelectedYear,
  }) async {
    showMonthPicker(context,
        firstYear: firstYear,
        lastYear: lastYear,
        initialSelectedMonth: initialSelectedMonth,
        highlightColor: CommonStyles.appBarColor,
        textColor: CommonStyles.whiteColor,
        initialSelectedYear: initialSelectedYear, onSelected: (month, year) {
      setState(() {
        final selectedDate = '1/$month/$year';
        final formatDateTime = CommonStyles.parseDateString(selectedDate);

        if (formatDateTime != null) {
          if (formatDateTime.isBefore(DateTime.now()) ||
              formatDateTime.isAtSameMomentAs(DateTime.now())) {
            displayFromDate = selectedDate;
            selectedFromDate = formatDateTime;
          } else {
            showToastMsg(tr(LocaleKeys.unableselect));
          }
        }
      });
    });
  }

  void showToastMsg(String message) {
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      timeInSecForIosWeb: 1,
    );
  }

/* 
  Future<void> launchToDatePicker(
    BuildContext context, {
    required int? firstYear,
    required int? lastYear,
    int? initialSelectedMonth,
    int? initialSelectedYear,
  }) async {
    showMonthPicker(context,
        firstYear: firstYear,
        lastYear: lastYear,
        highlightColor: CommonStyles.appBarColor,
        textColor: CommonStyles.whiteColor,
        initialSelectedMonth: initialSelectedMonth,
        initialSelectedYear: initialSelectedYear, onSelected: (month, year) {
      setState(() {
        displayToDate = '31/$month/$year';
        selectedToDate = CommonStyles.parseDateString(displayToDate);
        print('custom Todate: $displayToDate');
        print(
            'custom Todate: ${selectedToDate!.year}-${selectedToDate!.month}-${selectedToDate!.day}');
        // apiFromDate = '$year-$month-1';
      });
    });
  }
 */
  Future<void> launchToDatePicker(
    BuildContext context, {
    required int? firstYear,
    required int? lastYear,
    int? initialSelectedMonth,
    int? initialSelectedYear,
  }) async {
    showMonthPicker(
      context,
      firstYear: firstYear,
      lastYear: lastYear,
      highlightColor: CommonStyles.appBarColor,
      textColor: CommonStyles.whiteColor,
      initialSelectedMonth: initialSelectedMonth,
      initialSelectedYear: initialSelectedYear,
      onSelected: (month, year) {
        /* setState(() {
          DateTime lastDayOfMonth = _getLastDayOfMonth(year, month);

          displayToDate =
              '${lastDayOfMonth.day}/${lastDayOfMonth.month}/${lastDayOfMonth.year}';

          selectedToDate = CommonStyles.parseDateString(displayToDate);

          print(
              'custom Todate: $displayToDate'); // Will print the last day of the selected month
          print(
              'custom Todate: ${selectedToDate!.year}-${selectedToDate!.month}-${selectedToDate!.day}');
        }); */
        setState(() {
          DateTime lastDayOfMonth = _getLastDayOfMonth(year, month);
          final selectedDate =
              '${lastDayOfMonth.day}/${lastDayOfMonth.month}/${lastDayOfMonth.year}';
          final formatDateTime = CommonStyles.parseDateString(selectedDate);

          if (formatDateTime != null) {
            if (formatDateTime.isBefore(DateTime.now()) ||
                formatDateTime.isAtSameMomentAs(DateTime.now())) {
              displayToDate = selectedDate;
              selectedToDate = formatDateTime;
            } else {
              showToastMsg(tr(LocaleKeys.unableselect));
            }
          }
        });
      },
    );
  }

  DateTime _getLastDayOfMonth(int year, int month) {
    if (month == 12) {
      return DateTime(year + 1, 1, 0);
    }
    return DateTime(year, month + 1, 0);
  }

  Widget tabView() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10).copyWith(top: 10),
      child: TabBarView(
        children: [
          FarmerPassbookTabView(
              future: futureData.passbookVendorModel,
              accountHolderName: widget.accountHolderName,
              accountNumber: widget.accountNumber,
              bankName: widget.bankName,
              branchName: widget.branchName,
              district: widget.district,
              farmerCode: widget.farmerCode,
              guardianName: widget.guardianName,
              ifscCode: widget.ifscCode,
              mandal: widget.mandal,
              state: widget.state,
              village: widget.village),
          FarmerTransportTabView(
            future: futureData.passbookTransportModel,
          ),
        ],
      ),
    );
  }

  CustomAppBar appBar() {
    return CustomAppBar(
      title: tr(LocaleKeys.payments),
    );
  }

  Widget dropdownSelector() {
    return Container(
      alignment: Alignment.center,
      margin: const EdgeInsets.symmetric(horizontal: 12).copyWith(bottom: 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: CommonStyles.whiteColor),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton2<String>(
          iconStyleData: const IconStyleData(
            icon: Icon(
              Icons.keyboard_arrow_down_rounded,
              color: Colors.white,
            ),
          ),
          isExpanded: true,
          hint: const Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Expanded(
                  child: Text(
                    'Select Item',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                    textAlign: TextAlign.center,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
          items: dropdownItems
              .map((String item) => DropdownMenuItem<String>(
                    value: item,
                    child: Center(
                      child: Text(
                        item,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                        textAlign: TextAlign.center,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ))
              .toList(),
          value: selectedDropDownValue,
          onChanged: (String? value) {
            setState(() {
              selectedDropDownValue = value;

              if (dropdownItems.indexOf(selectedDropDownValue!) == 3) {
                isTimePeriod = true;
              } else {
                isTimePeriod = false;
                displayFromDate = null;
                displayToDate = null;
              }
              filterVendorAndTransportDataBasedOnDates(
                  dropdownItems.indexOf(selectedDropDownValue!));
            });
          },
          dropdownStyleData: DropdownStyleData(
            decoration: const BoxDecoration(
              color: CommonStyles.dropdownListBgColor,
              borderRadius: BorderRadius.only(
                  bottomRight: Radius.circular(12),
                  bottomLeft: Radius.circular(12)),
            ),
            offset: const Offset(0, 0),
            scrollbarTheme: ScrollbarThemeData(
              radius: const Radius.circular(40),
              thickness: WidgetStateProperty.all<double>(6),
              thumbVisibility: WidgetStateProperty.all<bool>(true),
            ),
          ),
          menuItemStyleData: const MenuItemStyleData(
            height: 40,
            padding: EdgeInsets.only(left: 20, right: 20),
          ),
        ),
      ),
    );
  }

  void validateAndSubmit(String? selectedFromDate, String? selectedToDate) {
    setState(() {
      futureData = getDataByCustomDates(
        fromDate: selectedFromDate,
        toDate: selectedToDate,
      );
    });
  }

  Widget datePickerBox(
      {void Function()? onTap,
      required String dateLabel,
      required String? displaydate}) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              displaydate == null
                  ? RichText(
                      text: TextSpan(
                        text: dateLabel,
                        style: CommonStyles.txStyF16CbFF6.copyWith(
                          color: CommonStyles.dataTextColor2,
                        ),
                        children: const <TextSpan>[
                          TextSpan(
                            text: '*',
                            style: TextStyle(
                                color: CommonStyles.formFieldErrorBorderColor),
                          ),
                        ],
                      ),
                    )
                  : Text(displaydate, style: CommonStyles.txStyF16CbFF6),
            ],
          ),
          const Divider(
            color: CommonStyles.dataTextColor2,
          ),
        ],
      ),
    );
  }

  void filterVendorAndTransportDataBasedOnDates(int value) {
    switch (value) {
      case 0:
        setState(() {
          futureData = getInitialData();
        });
        break;
      case 1:
        setState(() {
          futureData = getLastThreeMonthsData();
        });
        break;
      case 2:
        setState(() {
          futureData = getLastFinancialYearData();
        });
        break;
    }
  }

  Future<void> checkStoragePermission() async {
    bool permissionStatus;
    final deviceInfo = await DeviceInfoPlugin().androidInfo;

    if (deviceInfo.version.sdkInt > 32) {
      permissionStatus = await Permission.storage.request().isGranted;
    } else {
      permissionStatus = await Permission.storage.request().isGranted;
    }
    if (await Permission.storage.request().isGranted) {
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
}

class FarmerPassbookTabView extends StatefulWidget {
  const FarmerPassbookTabView(
      {super.key,
      required this.future,
      required this.accountHolderName,
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
  final Future<PassbookVendorModel> future;
  final String accountHolderName;
  final String accountNumber;
  final String bankName;
  final String branchName;
  final String district;
  final String farmerCode;
  final String guardianName;
  final String ifscCode;
  final String mandal;
  final String state;
  final String village;

  @override
  State<FarmerPassbookTabView> createState() => _FarmerPassbookTabViewState();
}

class _FarmerPassbookTabViewState extends State<FarmerPassbookTabView> {
  void openDirectory() async {
    var status = await Permission.storage.request();
    if (!status.isGranted) {
      print('Storage permission not granted');
      return;
    }

    String folderPath = '/storage/emulated/0/Download/Srikar_Groups/ledger';
    Directory dir = Directory(folderPath);
    if (!(await dir.exists())) {
      await dir.create(recursive: true);
      print('Directory created at $folderPath');
    }
    OpenFilex.open(folderPath);
  }

  //MARK: requestBody
  void exportPaymentsAndDownloadFile() async {
    setState(() {
      CommonStyles.showHorizontalDotsLoadingDialog(context);
    });
    final data = await widget.future;

    List<Map<String, dynamic>> paymentResponce =
        data.result!.paymentResponce!.map((item) => item.toJson()).toList();
    Result? result = data.result;

    Map<String, dynamic> requestBody = {
      "bankDetails": {
        "accountHolderName": widget.accountHolderName,
        "accountNumber": widget.accountNumber,
        "bankName": widget.bankName,
        "branchName": widget.branchName,
        "district": widget.district,
        "farmerCode": widget.farmerCode,
        "guardianName": widget.guardianName,
        "ifscCode": widget.ifscCode,
        "mandal": widget.mandal,
        "state": widget.state,
        "village": widget.village,
      },
      "totalQuanitity": result!.totalQuanitity,
      "totalGRAmount": result.totalGrAmount,
      "totalAdjusted": result.totalAdjusted,
      "totalAmount": result.totalAmount,
      "totalBalance": result.totalBalance,
      "paymentResponce": paymentResponce
    };

    const apiUrl =
        'http://182.18.157.215/3FAkshaya/API/api/Payment/ExportPayments';

    try {
      final jsonResponse = await http.post(
        Uri.parse(apiUrl),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode(requestBody),
      );

      print('www: $apiUrl');
      print('www: ${jsonEncode(requestBody)}');
      print('www: ${jsonResponse.body}');

      if (jsonResponse.statusCode == 200) {
        final response = jsonDecode(jsonResponse.body);
        convertBase64ToExcelAndSaveIntoSpecificDirectory(response);
      } else {
        throw Exception('Failed to fetch data');
      }
    } catch (e) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        setState(() {
          CommonStyles.hideHorizontalDotsLoadingDialog(context);
        });
      });
      rethrow;
    }
  }

  Future<void> checkAndOpenDirectory() async {
    PermissionStatus status = await Permission.storage.status;

    if (status.isGranted) {
      String directoryPath = '/sdcard/Download/3FAkshaya/ledger';
      Directory directory = Directory(directoryPath);

      if (!await directory.exists()) {
        await directory.create(recursive: true);
      }

      await OpenFilex.open(directoryPath);
    } else if (status.isDenied || status.isLimited) {
      PermissionStatus requestStatus = await Permission.storage.request();

      if (requestStatus.isGranted) {
        String directoryPath = '/sdcard/Download/3FAkshaya/ledger';
        Directory directory = Directory(directoryPath);

        if (!await directory.exists()) {
          await directory.create(recursive: true);
        }

        await OpenFilex.open(directoryPath);
      } else if (requestStatus.isPermanentlyDenied) {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text("Permission Required"),
              content: const Text(
                  "Storage permission is required to access files. Please enable it in the app settings."),
              actions: [
                TextButton(
                  onPressed: () async {
                    Navigator.of(context).pop();
                    await openAppSettings();
                  },
                  child: const Text("Open Settings"),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text("Cancel"),
                ),
              ],
            );
          },
        );
      } else {
        PermissionStatus requestStatus = await Permission.storage.request();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Storage permission is required to access files"),
          ),
        );
      }
    }
  }

  Future<void> convertBase64ToExcelAndSaveIntoSpecificDirectory(
      String base64String) async {
    if (base64String.isEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        setState(() {
          CommonStyles.hideHorizontalDotsLoadingDialog(context);
        });
      });
      return;
    }
    String base64 = sanitizeBase64(base64String);
    final DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
    AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
    int sdkInt = androidInfo.version.sdkInt;
    //   if (await Permission.storage.request().isGranted) {

    List<int> excelBytes = base64Decode(base64);
    Directory directoryPath = Directory('/sdcard/Download/3FAkshaya/ledger');
    // Directory('/storage/emulated/0/Download/Srikar_Groups/ledger');
    if (!directoryPath.existsSync()) {
      directoryPath.createSync(recursive: true);
    }
    String filePath = directoryPath.path;
    String timestamp = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
    String fileName = "ledger_$timestamp.xlsx";

    final File file = File('$filePath/$fileName');

    // Force delete the file if it exists
    try {
      if (await file.exists()) {
        await file.delete();
      }
    } catch (e) {
      print('Error deleting existing file: $e');
    }

    // Create and write to the file
    await file.create(recursive: true);

    await file.writeAsBytes(excelBytes);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() {
        CommonStyles.hideHorizontalDotsLoadingDialog(context);
      });
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('File downloaded successfully'),
      ),
    );
    _showNotification(
        id: 1,
        title: file.path,
        message: 'File Downloaded Successfully',
        path: '/sdcard/Download/3FAkshaya/ledger');
  }

  String sanitizeBase64(String base64String) {
    return base64String.replaceAll(RegExp(r'\s+'), '').replaceAll('"', '');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CommonStyles.screenBgColor,
      // backgroundColor: CommonStyles.whiteColor,
      body: Column(
        children: [
          Expanded(
            child: FutureBuilder(
              future: widget.future,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return CommonStyles.rectangularShapeShimmerEffect();
                } else if (snapshot.hasError) {
                  return Expanded(
                    child: Center(
                      child: Text(
                          snapshot.error
                              .toString()
                              .replaceFirst('Exception: ', ''),
                          style: CommonStyles.txStyF16CpFF6),
                    ),
                  );
                } else {
                  final passbookVendor = snapshot.data as PassbookVendorModel;
                  if (passbookVendor.result != null &&
                          passbookVendor.result!.paymentResponce == null ||
                      passbookVendor.result!.paymentResponce!.isEmpty) {
                    return Expanded(
                      child: Center(
                        child: Text(
                          tr(LocaleKeys.no_payments_found),
                          // style: CommonStyles.txStyF16CpFF6,
                          style: CommonStyles.txStyF16CpFF6.copyWith(
                            fontSize: 20,
                          ),
                        ),
                      ),
                    );
                  } else {
                    return Column(
                      children: [
                        passbookVendor.result != null
                            ? quantityAndBalanceTemplate(passbookVendor.result!)
                            : const SizedBox(),
                        const SizedBox(height: 5),
                        passbookVendor.result!.paymentResponce != null
                            ? Expanded(
                                child: CommonWidgets.customSlideAnimation(
                                  itemCount: passbookVendor
                                      .result!.paymentResponce!.length,
                                  isSeparatorBuilder: true,
                                  childBuilder: (index) {
                                    final itemData = passbookVendor
                                        .result!.paymentResponce![index];
                                    return item(index, itemData: itemData);
                                  },
                                ),

                                /* ListView.separated(
                                  itemCount: passbookVendor
                                      .result!.paymentResponce!.length,
                                  itemBuilder: (context, index) {
                                    final itemData = passbookVendor
                                        .result!.paymentResponce![index];
                                    return item(index, itemData: itemData);
                                  },
                                  separatorBuilder: (context, index) =>
                                      const SizedBox(height: 10),
                                ), */
                              )
                            : const Expanded(
                                child: Center(
                                  child: Text('List is empty',
                                      style: CommonStyles.txStyF16CpFF6),
                                ),
                              ),
                        downloadBtns(),
                        const SizedBox(height: 10),
                      ],
                    );
                  }
                }
              },
            ),
          ),
          note(),
          const SizedBox(height: 5),
        ],
      ),
    );
  }

  Widget quantityAndBalanceTemplate(Result result) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: CommonStyles.dropdownListBgColor,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (result.totalQuanitity != null)
            commonRowWithColon(
                label: tr(LocaleKeys.ffb_qty),
                data: result.totalQuanitity!.toStringAsFixed(3),
                style: CommonStyles.txStyF14CwFF6,
                isSpace: false),
          if (result.totalQuanitity != null) const SizedBox(height: 5),
          if (result.totalBalance != null)
            commonRowWithColon(
                label: tr(LocaleKeys.totalBalance),
                // data: '${result.totalBalance}',
                data: result.totalBalance!.toInt().toString(),
                style: CommonStyles.txStyF14CwFF6,
                isSpace: false),
        ],
      ),
    );
  }

  Widget commonRowWithColon(
      {required String label,
      required String data,
      Color? dataTextColor,
      TextAlign? textAlign = TextAlign.start,
      TextStyle? style = CommonStyles.txStyF14CbFF6,
      bool isSpace = true}) {
    return Padding(
      padding: const EdgeInsets.only(left: 20),
      child: Row(
        children: [
          Expanded(
              flex: 5,
              child: Text(
                label,
                textAlign: textAlign,
                style: style,
              )),
          Expanded(
            flex: 2,
            child: Text(
              ':',
              style: style,
              textAlign: TextAlign.center,
            ),
          ),
          Expanded(
            flex: 5,
            child: Text(
              data,
              textAlign: textAlign,
              style: style?.copyWith(
                color: dataTextColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String? formatDouble(double? value) {
    if (value == null) {
      return null;
    }
    String formattedValue = value.abs().toStringAsFixed(2);
    if (value < 0) {
      return '($formattedValue)';
    } else {
      return formattedValue;
    }
  }

  Widget item(int index, {required PaymentResponce itemData}) {
    return IntrinsicHeight(
      child: ClipRRect(
          borderRadius: BorderRadius.circular(12.0),
          child: GestureDetector(
            onTap: () {},
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12.0),
              child: Container(
                padding: const EdgeInsets.all(10),
                color: index.isEven
                    ? Colors.transparent
                    : CommonStyles.listOddColor,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(7.0),
                          child: Image.asset(
                            Assets.images.icCalender.path,
                            height: 25,
                            width: 25,
                          ),
                        ),
                        const SizedBox(height: 2.0),
                        Text(
                          '${CommonStyles.formatDisplayDate(itemData.refDate)}',
                          style: CommonStyles.txStyF14CbFF6.copyWith(
                              // color: CommonStyles.dataTextColor,
                              fontWeight: FontWeight.w400),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                    Container(
                      width: 2,
                      margin: const EdgeInsets.symmetric(horizontal: 10),
                      decoration: const BoxDecoration(
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
                        child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                          if (itemData.amount != null &&
                              itemData.amount! != 0) // && itemData.amount! > 0
                            itemRow(
                                label: tr(LocaleKeys.amount),
                                // data: '${itemData.amount?.toStringAsFixed(2)}'),
                                data: '${itemData.amount?.toInt().toString()}'),
                          if (itemData.adjusted != null &&
                              itemData.adjusted! > 0)
                            itemRow(
                                label: tr(LocaleKeys.adjusted),
                                data:
                                    '${itemData.adjusted?.toStringAsFixed(2)}'),
                          if (itemData.gRAmount != null &&
                              itemData.gRAmount! > 0)
                            itemRow(
                                label: tr(LocaleKeys.gr),
                                data:
                                    '${itemData.gRAmount?.round().toString()}'),
                          if (itemData.quantity != null &&
                              itemData.quantity! > 0)
                            itemRow(
                                label: tr(LocaleKeys.ffb),
                                data:
                                    '${itemData.quantity?.toStringAsFixed(3)}'),
                          if (itemData.adhocRate != null &&
                              itemData.adhocRate! > 0)
                            itemRow(
                                label: tr(LocaleKeys.adhoc_rate),
                                data:
                                    '${itemData.adhocRate?.toStringAsFixed(2)}'),
                          if (itemData.invoiceRate != null &&
                              itemData.invoiceRate! > 0)
                            itemRow(
                                label: tr(LocaleKeys.invoice_rate),
                                data:
                                    '${itemData.invoiceRate?.round().toString()}'),
                          if (itemData.memo != null)
                            itemRow(
                                label: tr(LocaleKeys.descriptionn),
                                data: '${itemData.memo}'),
                          Container(
                            padding: const EdgeInsets.all(3),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10.0),
                              border: Border.all(
                                color: Colors.grey,
                                // color: CommonStyles.whiteColor,
                              ),
                            ),
                            child: itemRow(
                                isSpace: false,
                                label: tr(LocaleKeys.balance),
                                data: itemData.balance == null
                                    ? '0'
                                    : itemData.balance!.round().toString()),
                            // data: formatDouble(itemData.balance)),
                          ),
                        ]))
                  ],
                ),
              ),
            ),
          )),
    );
  }

  Widget itemRow({required String label, String? data, bool isSpace = true}) {
    return Column(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 8,
              child: Text(label, style: CommonStyles.txStyF14CbFF6),
            ),
            const Expanded(
              flex: 1,
              child: Text(":", style: CommonStyles.txStyF14CbFF6),
            ),
            Expanded(
              flex: 8,
              child: Text('$data', style: CommonStyles.txStyF14CbFF6),
            ),
          ],
        ),
        if (isSpace) const SizedBox(height: 5),
      ],
    );
  }

  //MARK: Notification Method
  Future<void> _showNotification(
      {required int id,
      required String title,
      required String message,
      String? path}) async {
    var androidPlatformChannelSpecifics = const AndroidNotificationDetails(
      'akshay_channel',
      'akshay_channel_name',
      importance: Importance.max,
      priority: Priority.high,
      ticker: 'akshay_ticker',
    );
    var platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);

    await flutterLocalNotificationsPlugin.show(
      id,
      title,
      message,
      platformChannelSpecifics,
      payload: path,
    );
  }

  Row downloadBtns() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
            child: CustomBtn(
          label: tr(LocaleKeys.download),
          padding: const EdgeInsets.all(0),
          height: 60,
          onPressed: checkAndOpenDirectory,
        )),
        const SizedBox(width: 10),
        Expanded(
            child: CustomBtn(
          padding: const EdgeInsets.all(0),
          label: tr(LocaleKeys.click_downlad),
          height: 60,
          onPressed: exportPaymentsAndDownloadFile,
        )),
      ],
    );
  }

  Widget note() {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: CommonStyles.noteColor,
        border: Border.all(color: CommonStyles.primaryTextColor, width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(tr(LocaleKeys.notee), style: CommonStyles.txStyF14CpFF6),
          const SizedBox(height: 5),
          Text(tr(LocaleKeys.paymentnote_note),
              style: CommonStyles.txStyF14CbFF6),
        ],
      ),
    );
  }
}

class FarmerTransportTabView extends StatefulWidget {
  const FarmerTransportTabView({super.key, required this.future});
  final Future<PassbookTransportModel> future;

  @override
  State<FarmerTransportTabView> createState() => _FarmerTransportTabViewState();
}

class _FarmerTransportTabViewState extends State<FarmerTransportTabView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CommonStyles.screenBgColor,
      body: Column(
        children: [
          Expanded(
            child: FutureBuilder(
              future: widget.future,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return CommonStyles.rectangularShapeShimmerEffect();
                } else if (snapshot.hasError) {
                  return Text(
                      snapshot.error.toString().replaceFirst('Exception: ', ''),
                      style: CommonStyles.txStyF16CpFF6);
                } else {
                  final response = snapshot.data as PassbookTransportModel;
                  List<TranspotationCharge>? transportionData =
                      response.transpotationCharges;
                  List<TrasportRate>? trasportRates = response.trasportRates;

                  // return CommonStyles.rectangularShapeShimmerEffect();
                  if (transportionData != null && transportionData.isNotEmpty) {
                    return Column(
                      children: [
                        Expanded(
                          child: ListView.separated(
                            itemCount: transportionData.length,
                            itemBuilder: (context, index) {
                              final itemData = transportionData[index];

                              /* return const ListTile(
                                title: Text('data'),
                              ); */
                              return item(index, itemData: itemData);
                            },
                            separatorBuilder: (context, index) =>
                                const SizedBox(height: 10),
                          ),
                        ),
                      ],
                    );
                  } else {
                    return Expanded(
                      child: Center(
                        child: Text(tr(LocaleKeys.no_trans_found),
                            style: CommonStyles.txStyF16CpFF6
                                .copyWith(fontSize: 15)),
                      ),
                    );
                  }
                }
              },
            ),
          ),
          transportationRateBtn(widget.future),
          const SizedBox(height: 10),
          note(),
          const SizedBox(height: 5),
        ],
      ),
    );
  }

  Widget quantityAndBalanceTemplate(Result result) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: CommonStyles.dropdownListBgColor,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (result.totalQuanitity != null)
            commonRowWithColon(
                label: tr(LocaleKeys.ffb_qty),
                data: '${result.totalQuanitity}',
                style: CommonStyles.txStyF14CwFF6,
                isSpace: false),
          if (result.totalQuanitity != null) const SizedBox(height: 5),
          if (result.totalBalance != null)
            commonRowWithColon(
                label: tr(LocaleKeys.totalBalance),
                data: result.totalBalance!.toStringAsFixed(2),
                style: CommonStyles.txStyF14CwFF6,
                isSpace: false),
        ],
      ),
    );
  }

  Widget commonRowWithColon(
      {required String label,
      required String data,
      Color? dataTextColor,
      TextAlign? textAlign = TextAlign.start,
      TextStyle? style = CommonStyles.txStyF14CbFF6,
      bool isSpace = true}) {
    return Padding(
      padding: const EdgeInsets.only(left: 20),
      child: Row(
        children: [
          Expanded(
              flex: 5,
              child: Text(
                label,
                textAlign: textAlign,
                style: style,
              )),
          Expanded(
            flex: 2,
            child: Text(
              ':',
              style: style,
              textAlign: TextAlign.center,
            ),
          ),
          Expanded(
            flex: 5,
            child: Text(
              data,
              textAlign: textAlign,
              style: style?.copyWith(
                color: dataTextColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String? formatDouble(double? value) {
    if (value == null) {
      return null;
    }
    String formattedValue = value.abs().toStringAsFixed(2);
    if (value < 0) {
      return '($formattedValue)';
    } else {
      return formattedValue;
    }
  }

  Widget item(int index, {required TranspotationCharge itemData}) {
    return IntrinsicHeight(
      child: ClipRRect(
          borderRadius: BorderRadius.circular(12.0),
          child: GestureDetector(
            onTap: () {},
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12.0),
              child: Container(
                padding: const EdgeInsets.all(10),
                color: index.isEven
                    ? Colors.transparent
                    : CommonStyles.listOddColor,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(7.0),
                          child: Image.asset(
                            Assets.images.icCalender.path,
                            height: 25,
                            width: 25,
                          ),
                        ),
                        const SizedBox(height: 2.0),
                        Text(
                          '${CommonStyles.formatApiDate(itemData.receiptGeneratedDate)}',
                          style: CommonStyles.txStyF14CbFF6.copyWith(
                              // color: CommonStyles.dataTextColor,
                              fontWeight: FontWeight.w400),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                    Container(
                      width: 2,
                      margin: const EdgeInsets.symmetric(horizontal: 10),
                      decoration: const BoxDecoration(
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
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (itemData.collectionCode != null)
                            Column(
                              children: [
                                Text('${itemData.collectionCode}',
                                    style: CommonStyles.txStyF16CpFF6),
                                const SizedBox(height: 5),
                              ],
                            ),
                          if (itemData.tonnageCost != null &&
                              itemData.tonnageCost! > 0)
                            itemRow(
                                label: tr(LocaleKeys.amount),
                                data:
                                    '${itemData.tonnageCost?.toStringAsFixed(2)}'),
                          if (itemData.qty != null && itemData.qty! > 0)
                            itemRow(
                                label: tr(LocaleKeys.quantity),
                                data: '${itemData.qty?.toStringAsFixed(2)}'),
                          if (itemData.rate != null && itemData.rate! > 0)
                            itemRow(
                                label: tr(LocaleKeys.rate),
                                data: '${itemData.rate?.toStringAsFixed(2)}'),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          )),
    );
  }

  Widget itemRow({required String label, String? data, bool isSpace = true}) {
    return Column(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 8,
              child: Text(label, style: CommonStyles.txStyF14CbFF6),
            ),
            const Expanded(
              flex: 1,
              child: Text(":", style: CommonStyles.txStyF14CbFF6),
            ),
            Expanded(
              flex: 8,
              child: Text('$data', style: CommonStyles.txStyF14CbFF6),
            ),
          ],
        ),
        if (isSpace) const SizedBox(height: 5),
      ],
    );
  }

  Row transportationRateBtn(Future<PassbookTransportModel> future) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        CustomBtn(
          label: tr(LocaleKeys.transportationrates),
          padding: const EdgeInsets.symmetric(horizontal: 5),
          btnChild: Row(
            children: [
              Image.asset(
                Assets.images.delivery.path,
                height: 20,
                width: 20,
              ),
              const SizedBox(
                width: 5,
              ),
              Text(
                tr(LocaleKeys.transportationrates),
                style: CommonStyles.txStyF14CpFF6,
              ),
            ],
          ),
          onPressed: () => trasportRatesDialog(context, future),
        ),
      ],
    );
  }

  void trasportRatesDialog(
      BuildContext context, Future<PassbookTransportModel> future) {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: '',
      barrierColor: Colors.black54,
      transitionDuration: const Duration(milliseconds: 500),
      pageBuilder: (context, animation1, animation2) {
        return Center(
          child: Material(
            color: Colors.transparent,
            child: Container(
              width: MediaQuery.of(context).size.width * 0.8,
              padding: const EdgeInsets.all(12.0),
              decoration: BoxDecoration(
                color: CommonStyles.screenBgColor,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: CommonStyles.primaryTextColor,
                  width: 1,
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(tr(LocaleKeys.transportationrates),
                      style: CommonStyles.txStyF16CpFF6),
                  const SizedBox(height: 10),
                  Container(
                    height: 0.5,
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          CommonStyles.primaryTextColor,
                          Color.fromARGB(255, 110, 6, 228)
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  FutureBuilder(
                    future: future,
                    builder: (context, snapshot) {
                      final passBook = snapshot.data as PassbookTransportModel;
                      List<TrasportRate>? trasportRates =
                          passBook.trasportRates;
                      if (trasportRates != null) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          child: Column(
                            children: [
                              CommonWidgets.commonRowWithColon(
                                  flex: [5, 1, 6],
                                  label: tr(LocaleKeys.village),
                                  data: '${trasportRates[0].village}'),
                              CommonWidgets.commonRowWithColon(
                                  flex: [5, 1, 6],
                                  label: tr(LocaleKeys.mandal),
                                  data: '${trasportRates[0].mandal}'),
                              CommonWidgets.commonRowWithColon(
                                  flex: [5, 1, 6],
                                  label: tr(LocaleKeys.rate),
                                  data: '${trasportRates[0].rate}'),
                            ],
                          ),
                        );
                      } else {
                        return const SizedBox();
                      }
                    },
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(bottom: 10.0),
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20.0),
                            gradient: const LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Color(0xFFCCCCCC),
                                Color(0xFFFFFFFF),
                                Color(0xFFCCCCCC),
                              ],
                            ),
                            border: Border.all(
                              color: const Color(0xFFe86100),
                              width: 2.0,
                            ),
                          ),
                          child: SizedBox(
                            height: 30.0,
                            child: ElevatedButton(
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                              style: ElevatedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 35.0),
                                backgroundColor: Colors.transparent,
                                shadowColor: Colors.transparent,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20.0),
                                ),
                              ),
                              child: const Text(
                                'OK',
                                style: CommonStyles.txStyF14CpFF6,
                              ),
                            ),
                          ),
                        ),
                      )
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
      transitionBuilder: (context, animation1, animation2, child) {
        return ScaleTransition(
          scale: Tween<double>(begin: 0.0, end: 1.0).animate(
            CurvedAnimation(
              parent: animation1,
              curve: Curves.easeOutBack,
            ),
          ),
          child: child,
        );
      },
    );
  }

  Widget note() {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: CommonStyles.noteColor,
        border: Border.all(color: CommonStyles.primaryTextColor, width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(tr(LocaleKeys.notee), style: CommonStyles.txStyF14CpFF6),
          const SizedBox(height: 5),
          Text(tr(LocaleKeys.tansportation_note),
              style: CommonStyles.txStyF14CbFF6),
        ],
      ),
    );
  }
}

class PassbookData {
  final Future<PassbookVendorModel> passbookVendorModel;
  final Future<PassbookTransportModel> passbookTransportModel;

  PassbookData(
      {required this.passbookVendorModel,
      required this.passbookTransportModel});
}
