import 'dart:convert';

import 'package:akshaya_flutter/common_utils/api_config.dart';
import 'package:akshaya_flutter/common_utils/common_styles.dart';
import 'package:akshaya_flutter/common_utils/common_widgets.dart';
import 'package:akshaya_flutter/common_utils/custom_appbar.dart';
import 'package:akshaya_flutter/common_utils/custom_btn.dart';
import 'package:akshaya_flutter/common_utils/shared_prefs_keys.dart';
import 'package:akshaya_flutter/gen/assets.gen.dart';
import 'package:akshaya_flutter/localization/locale_keys.dart';
import 'package:akshaya_flutter/models/passbook_transport_model.dart';
import 'package:akshaya_flutter/models/passbook_vendor_model.dart';
import 'package:akshaya_flutter/screens/home_screen/screens/ffb_collection_screen.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class TestScreen extends StatefulWidget {
  const TestScreen(
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
  State<TestScreen> createState() => _TestScreenState();
}

class _TestScreenState extends State<TestScreen> {
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
    futureData = getInitialData();
  }

  PassbookData getInitialData() {
    DateFormat formatter = DateFormat('yyyy-MM-dd');
    String fromDate =
        formatter.format(DateTime.now().subtract(const Duration(days: 30)));
    String toDate = formatter.format(DateTime.now());
    return PassbookData(
        passbookVendorModel: getVendorData(fromDate: fromDate, toDate: toDate),
        passbookTransportModel:
            getTransportData(fromDate: fromDate, toDate: toDate));
  }

  PassbookData getLastThreeMonthsData() {
    DateFormat formatter = DateFormat('yyyy-MM-dd');
    String fromDate =
        formatter.format(DateTime.now().subtract(const Duration(days: 90)));
    String toDate = formatter.format(DateTime.now());

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

    print('passbook: $apiUrl');
    print('passbook: ${jsonEncode(requestBody)}');
    print('passbook: ${jsonResponse.body}');

    if (jsonResponse.statusCode == 200) {
      if (isCustomDates!) {
        setState(() {
          isTimePeriod = false;
        });
      }
      return passbookVendorModelFromJson(jsonResponse.body);
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
    print('passbook 2: ${jsonResponse.body}');

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
        backgroundColor: CommonStyles.whiteColor,
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
                  isTimePeriod ? datePickerSection() : const SizedBox(),
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
        indicatorPadding: const EdgeInsets.only(bottom: 3),
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

  Future<void> launchFromDatePicker(BuildContext context,
      {required DateTime firstDate,
      required DateTime lastDate,
      DateTime? initialDate}) async {
    // final DateTime lastDate = DateTime.now();
    // final DateTime firstDate = DateTime(lastDate.year - 100);
    final DateTime? pickedDay = await showDatePicker(
      context: context,
      initialDate: initialDate ?? DateTime.now(),
      initialEntryMode: DatePickerEntryMode.calendarOnly,
      firstDate: firstDate,
      lastDate: lastDate,
      initialDatePickerMode: DatePickerMode.day,
    );
    if (pickedDay != null) {
      // Check if pickedDay is not in the future
      setState(() {
        selectedFromDate = pickedDay;
        displayFromDate = DateFormat('dd/MM/yyyy').format(selectedFromDate!);
      });
    }
    // return DateFormat('dd-MM-yyyy').format(selectedFromDate!);
  }

  Future<void> launchToDatePicker(BuildContext context,
      {required DateTime firstDate,
      required DateTime lastDate,
      DateTime? initialDate}) async {
    // final DateTime lastDate = DateTime.now();
    // final DateTime firstDate = DateTime(lastDate.year - 100);
    final DateTime? pickedDay = await showDatePicker(
      context: context,
      // initialDate: DateTime.now(),
      initialDate: initialDate ?? DateTime.now(),
      initialEntryMode: DatePickerEntryMode.calendarOnly,
      firstDate: firstDate,
      lastDate: lastDate,
      initialDatePickerMode: DatePickerMode.day,
    );

    if (pickedDay != null) {
      // Check if pickedDay is not in the future
      setState(() {
        selectedToDate = pickedDay;
        displayToDate = DateFormat('dd/MM/yyyy').format(selectedToDate!);
      });
    }
    // return DateFormat('dd-MM-yyyy').format(selectedToDate!);
  }

  Widget tabView() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10).copyWith(top: 10),
      child: TabBarView(
        children: [
          FarmerPassbookTabView(
            future: futureData.passbookVendorModel,
          ),
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
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12).copyWith(bottom: 10),
      child: Container(
        alignment: Alignment.center,
        padding: const EdgeInsets.only(right: 15),

        // padding: const EdgeInsets.symmetric(vertical: 15),
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
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
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
                print('passbook selectedDropDownValue: $selectedDropDownValue');
                /*   getCollectionAccordingToDropDownSelection(
                    dropdownItems.indexOf(selectedDropDownValue!)); */

                if (dropdownItems.indexOf(selectedDropDownValue!) == 3) {
                  setState(() {
                    isTimePeriod = true;
                  });
                } else {
                  setState(() {
                    isTimePeriod = false;
                    displayFromDate = null;
                    displayToDate = null;
                  });
                }
                filterVendorAndTransportDataBasedOnDates(
                    dropdownItems.indexOf(selectedDropDownValue!));
                print(
                    'passbook DropDownValue: ${dropdownItems.indexOf(selectedDropDownValue!)} | $selectedDropDownValue');
              });
            },
            dropdownStyleData: DropdownStyleData(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(14),
                color: CommonStyles.dropdownListBgColor,
                // color: Colors.black87,
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
          displaydate == null
              ? Row(
                  children: [
                    Text(dateLabel,
                        style: CommonStyles.txSty_14black
                            .copyWith(color: CommonStyles.whiteColor)),
                    // const SizedBox(width: 5),
                    // const Text('*', style: TextStyle(color: Colors.red)),
                  ],
                )
              : Text(displaydate,
                  style: CommonStyles.txSty_14black
                      .copyWith(color: CommonStyles.whiteColor)),
          const Divider(color: CommonStyles.whiteColor),
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
          futureData = getLastOneYearData();
        });
        break;
    }
  }
}

class FarmerPassbookTabView extends StatelessWidget {
  const FarmerPassbookTabView({super.key, required this.future});
  final Future<PassbookVendorModel> future;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CommonStyles.whiteColor,
      body: Column(
        children: [
          Expanded(
            child: FutureBuilder(
              future: future,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return CommonStyles.rectangularShapeShimmerEffect();
                } else if (snapshot.hasError) {
                  return Text(
                      snapshot.error.toString().replaceFirst('Exception: ', ''),
                      style: CommonStyles.txStyF16CpFF6);
                } else {
                  final passbookVendor = snapshot.data as PassbookVendorModel;
                  if (passbookVendor.result == null &&
                      passbookVendor.result!.paymentResponce == null) {
                    return const Expanded(
                      child: Center(
                        child: Text('List is empty',
                            style: CommonStyles.txStyF16CpFF6),
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
                                child: ListView.separated(
                                  itemCount: passbookVendor
                                      .result!.paymentResponce!.length,
                                  itemBuilder: (context, index) {
                                    final itemData = passbookVendor
                                        .result!.paymentResponce![index];
                                    return item(index, itemData: itemData);
                                  },
                                  separatorBuilder: (context, index) =>
                                      const SizedBox(height: 10),
                                ),
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
                          '${CommonStyles.formatApiDate(itemData.refDate)}',
                          style: CommonStyles.txStyF14CbFF6
                              .copyWith(color: CommonStyles.dataTextColor),
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
                          if (itemData.amount != null && itemData.amount! > 0)
                            itemRow(
                                label: tr(LocaleKeys.amount),
                                data: '${itemData.amount?.toStringAsFixed(2)}'),
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
                                    '${itemData.gRAmount?.toStringAsFixed(2)}'),
                          if (itemData.quantity != null &&
                              itemData.quantity! > 0)
                            itemRow(
                                label: tr(LocaleKeys.ffb),
                                data:
                                    '${itemData.quantity?.toStringAsFixed(2)}'),
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
                                    '${itemData.invoiceRate?.toStringAsFixed(2)}'),
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
                              ),
                            ),
                            child: itemRow(
                                isSpace: false,
                                label: tr(LocaleKeys.balance),
                                data: formatDouble(itemData.balance)),
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

  Row downloadBtns() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
            child: CustomBtn(
          label: tr(LocaleKeys.download),
          padding: const EdgeInsets.all(0),
          height: 60,
          onPressed: () {},
        )),
        const SizedBox(width: 10),
        Expanded(
            child: CustomBtn(
          padding: const EdgeInsets.all(0),
          label: tr(LocaleKeys.click_downlad),
          height: 60,
          onPressed: () {},
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

class FarmerTransportTabView extends StatelessWidget {
  const FarmerTransportTabView({super.key, required this.future});
  final Future<PassbookTransportModel> future;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CommonStyles.whiteColor,
      body: Column(
        children: [
          Expanded(
            child: FutureBuilder(
              future: future,
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
                  final trasportRates = response.trasportRates;
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
                    return const Center(
                      child: Text('List is empty',
                          style: CommonStyles.txStyF16CpFF6),
                    );
                  }
                }
              },
            ),
          ),
          transportationRateBtns(),
          const SizedBox(height: 10),
          note(),
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
                          style: CommonStyles.txStyF14CbFF6
                              .copyWith(color: CommonStyles.dataTextColor),
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

  Row transportationRateBtns() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        CustomBtn(
          label: tr(LocaleKeys.transportationrates),
          // height: 60,
          onPressed: () {},
        ),
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