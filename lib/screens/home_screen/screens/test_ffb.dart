import 'dart:convert';

import 'package:akshaya_flutter/common_utils/api_config.dart';
import 'package:akshaya_flutter/common_utils/common_styles.dart';
import 'package:akshaya_flutter/common_utils/custom_appbar.dart';
import 'package:akshaya_flutter/common_utils/custom_btn.dart';
import 'package:akshaya_flutter/common_utils/shared_prefs_keys.dart';
import 'package:akshaya_flutter/gen/assets.gen.dart';
import 'package:akshaya_flutter/localization/locale_keys.dart';
import 'package:akshaya_flutter/models/collection_count.dart';
import 'package:akshaya_flutter/models/collection_data_model.dart';
import 'package:akshaya_flutter/models/collection_info_model.dart';
import 'package:akshaya_flutter/screens/home_screen/screens/ffb_collection_screen.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class TestFfbCollectionScreen extends StatefulWidget {
  const TestFfbCollectionScreen({super.key});

  @override
  State<TestFfbCollectionScreen> createState() =>
      _TestFfbCollectionScreenState();
}

class _TestFfbCollectionScreenState extends State<TestFfbCollectionScreen> {
  final List<String> dropdownItems = [
    tr(LocaleKeys.thirty_days),
    tr(LocaleKeys.currentfinicial),
    tr(LocaleKeys.selected),
  ];

  String? selectedDropDownValue = tr(LocaleKeys.thirty_days);
  bool isSelectTimePeriod = false;
  late Future<CollectionResponse> apiCollectionData;

  DateTime? selectedFromDate;
  DateTime? selectedToDate;
  String? displayFromDate;
  String? displayToDate;

  @override
  void initState() {
    super.initState();
    apiCollectionData = getInitialData();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: CommonStyles.whiteColor,
      appBar: CustomAppBar(
        title: tr(LocaleKeys.collection),
      ),
      body: Column(
        children: [
          Container(
            height: dropdownItems.indexOf(selectedDropDownValue!) == 0
                ? (size.height / 2) - AppBar().preferredSize.height
                : null,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  CommonStyles.appBarColor,
                  CommonStyles.gradientColor1,
                  CommonStyles.gradientColor2,
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
            padding: const EdgeInsets.all(10),
            child: Column(
              children: [
                dropdownItems.indexOf(selectedDropDownValue!) != 2
                    ? dropdownSelector()
                    : timePeriodSelector(),
                const SizedBox(height: 10),
                if (!isSelectTimePeriod) collectionCount(),
              ],
            ),
          ),
          if (!isSelectTimePeriod) collectionData(context),
        ],
      ),
    );
  }

//MARK: Dropdown
  Container dropdownSelector() {
    return Container(
      alignment: Alignment.center,
      padding: const EdgeInsets.only(right: 10),
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
                        style: CommonStyles.txStyF14CwFF6,
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

              if (dropdownItems.indexOf(selectedDropDownValue!) == 2) {
                isSelectTimePeriod = true;
              } else {
                isSelectTimePeriod = false;
                displayFromDate = null;
                displayToDate = null;
                selectedFromDate = null;
                selectedToDate = null;
              }

              getCollectionAccordingToDropDownSelection(
                  dropdownItems.indexOf(selectedDropDownValue!));
            });
          },
          dropdownStyleData: DropdownStyleData(
            decoration: const BoxDecoration(
              borderRadius: BorderRadius.only(
                  bottomRight: Radius.circular(12),
                  bottomLeft: Radius.circular(12)),
              color: CommonStyles.dropdownListBgColor,
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

  String getCurrentFinancialDate() {
    DateTime now = DateTime.now();

    DateTime financialYearStart;

    if (now.month < 4) {
      financialYearStart = DateTime(now.year - 1, 4, 1);
    } else {
      financialYearStart = DateTime(now.year, 4, 1);
    }
    return "${financialYearStart.year}-${financialYearStart.month.toString().padLeft(2, '0')}-${financialYearStart.day.toString().padLeft(2, '0')}";
  }

  Widget timePeriodSelector() {
    return Column(
      children: [
        dropdownSelector(),
        const SizedBox(height: 10),
        datePickerSection(),
      ],
    );
  }

  Widget datePickerSection() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 15),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: CommonStyles.whiteColor),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: datePickerBox1(
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
              flex: 3,
              child: datePickerBox2(
                dateLabel: tr(LocaleKeys.to_date),
                // dateLabel: 'To Date',
                displaydate: displayToDate,
                onTap: () async {
                  final DateTime currentDate = DateTime.now();
                  final DateTime firstDate = DateTime(currentDate.year - 100);
                  final DateTime? pickedDay = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    initialEntryMode: DatePickerEntryMode.calendarOnly,
                    firstDate: firstDate,
                    lastDate: DateTime.now(),
                    initialDatePickerMode: DatePickerMode.day,
                  );
                  if (pickedDay != null) {
                    setState(() {
                      selectedToDate = pickedDay;
                      displayToDate =
                          DateFormat('dd/MM/yyyy').format(selectedToDate!);
                    });
                  }
                },
              )),
          const SizedBox(width: 10),
          //MARK: Submit Btn
          Expanded(
            flex: 4,
            child: CustomBtn(
                padding: const EdgeInsets.symmetric(
                  horizontal: 5,
                ),
                label: tr(LocaleKeys.submit),
                onPressed: () {
                  validateAndSubmit(selectedFromDate, selectedToDate);
                }),
          ),
        ],
      ),
    );
  }

  Widget datePickerBox1(
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
                  ? Text(dateLabel,
                      style: CommonStyles.txSty_14black
                          .copyWith(color: CommonStyles.whiteColor))
                  : Text(displaydate,
                      style: CommonStyles.txSty_14black
                          .copyWith(color: CommonStyles.whiteColor)),
            ],
          ),
          const Divider(color: CommonStyles.whiteColor),
        ],
      ),
    );
  }

  Widget datePickerBox2(
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
                  ? Text(dateLabel,
                      style: CommonStyles.txSty_14black
                          .copyWith(color: CommonStyles.whiteColor))
                  : Text(displaydate,
                      style: CommonStyles.txSty_14black
                          .copyWith(color: CommonStyles.whiteColor)),
            ],
          ),
          const Divider(color: CommonStyles.whiteColor),
        ],
      ),
    );
  }

  Future<void> launchFromDatePicker(BuildContext context,
      {required DateTime firstDate,
      required DateTime lastDate,
      DateTime? initialDate}) async {
    final DateTime? pickedDay = await showDatePicker(
      context: context,
      initialDate: initialDate ?? DateTime.now(),
      initialEntryMode: DatePickerEntryMode.calendarOnly,
      firstDate: firstDate,
      lastDate: lastDate,
      initialDatePickerMode: DatePickerMode.day,
    );
    if (pickedDay != null) {
      setState(() {
        selectedFromDate = pickedDay;
        displayFromDate = DateFormat('dd/MM/yyyy').format(selectedFromDate!);
      });
    }
  }

  Future<void> launchToDatePicker(BuildContext context,
      {required DateTime firstDate,
      required DateTime lastDate,
      DateTime? initialDate}) async {
    final DateTime? pickedDay = await showDatePicker(
      context: context,
      initialDate: initialDate ?? DateTime.now(),
      initialEntryMode: DatePickerEntryMode.calendarOnly,
      firstDate: firstDate,
      lastDate: lastDate,
      initialDatePickerMode: DatePickerMode.day,
    );
    if (pickedDay != null) {
      setState(() {
        selectedToDate = pickedDay;
        displayToDate = DateFormat('dd/MM/yyyy').format(selectedToDate!);
      });
    }
  }

  void validateAndSubmit(DateTime? selectedFromDate, DateTime? selectedToDate) {
    if (selectedFromDate == null || selectedToDate == null) {
      return CommonStyles.showCustomDialog(context, tr(LocaleKeys.enter_Date));
    } else if (selectedToDate.isBefore(selectedFromDate)) {
      return CommonStyles.showCustomDialog(
          context, tr(LocaleKeys.datevalidation));
    }
    setState(() {
      apiCollectionData = getCollectionDataByCustomDates(
        fromDate: DateFormat('yyyy-MM-dd').format(selectedFromDate),
        toDate: DateFormat('yyyy-MM-dd').format(selectedToDate),
      );
      print('executed line');
    });
  }

/*   Widget collectionCount() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.black45,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          listRow(title: tr(LocaleKeys.collectionsCount), value: 'data'),
          listRow(
              title: tr(LocaleKeys.collectionsWeight),
              // title: 'Total Net Weight',
              value: 'data'),
          listRow(
              title: tr(LocaleKeys.unPaidCollectionsWeight),
              // title: 'Unpaid Collections Weight',
              value: 'data'),
          listRow(
              title: tr(LocaleKeys.paidCollectionsWeight),
              // title: 'Paid Collections Weight',
              value: 'data'),
        ],
      ),
    );
  } */

  Widget collectionCount() {
    return FutureBuilder(
        future: apiCollectionData,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            final collection = snapshot.data as CollectionResponse;

            if (collection.collectionCount != null) {
              CollectionCount data = collection.collectionCount!;
              return Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.black45,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  children: [
                    listRow(
                        title: tr(LocaleKeys.collectionsCount),
                        value: data.collectionsCount.toString()),
                    listRow(
                        title: tr(LocaleKeys.collectionsWeight),
                        // title: 'Total Net Weight',
                        value: formatText('${data.collectionsWeight}')),
                    listRow(
                        title: tr(LocaleKeys.unPaidCollectionsWeight),
                        // title: 'Unpaid Collections Weight',
                        value: formatText('${data.unPaidCollectionsWeight}')),
                    listRow(
                        title: tr(LocaleKeys.paidCollectionsWeight),
                        // title: 'Paid Collections Weight',
                        value: formatText('${data.paidCollectionsWeight}')),
                  ],
                ),
              );
            } else {
              return const SizedBox();
            }
          }
          if (snapshot.hasError) {
            return Center(
                child: Text(
              'Error: ${snapshot.error}',
              style: CommonStyles.txStyF16CpFF6,
            ));
          }
          // return const Center(child: CircularProgressIndicator());
          return const SizedBox();
        });
  }

  String formatText(String? value) {
    if (value == null) {
      return '0.00';
    }
    return '${double.parse(value).toStringAsFixed(2)} Kg';
  }

  Widget listRow({
    required String title,
    required String value,
  }) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
                flex: 7,
                child: Text(
                  title,
                  style: CommonStyles.txStyF14CwFF6,
                )),
            const Text(
              ':    ',
              style: CommonStyles.txStyF14CwFF6,
            ),
            Expanded(
                flex: 5,
                child: Text(
                  value,
                  style: CommonStyles.txStyF14CwFF6,
                )),
          ],
        ),
        const SizedBox(height: 5),
      ],
    );
  }

  Expanded collectionData(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.fromLTRB(10, 5, 12, 0),
        child: FutureBuilder(
          future: apiCollectionData,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              // return const CircularProgressIndicator.adaptive();
              // WidgetsBinding.instance.addPostFrameCallback((_) {
              //   CommonStyles.showHorizontalDotsLoadingDialog(context);
              // });
              return const SizedBox.shrink();
            } else {
              // WidgetsBinding.instance.addPostFrameCallback((_) {
              //   CommonStyles.hideHorizontalDotsLoadingDialog(context);
              // });
              if (snapshot.hasError) {
                return Text(
                    snapshot.error.toString().replaceFirst('Exception: ', ''),
                    style: CommonStyles.txStyF16CpFF6);
              } else {
                final collection = snapshot.data as CollectionResponse;

                if (collection.collectionData != null) {
                  return ListView.builder(
                    itemCount: collection.collectionData!.length,
                    itemBuilder: (context, index) {
                      return collectionDataItem(
                          index: index,
                          data: collection.collectionData![index]);
                    },
                  );
                } else {
                  return Center(
                    child: Text(
                      tr(LocaleKeys.no_collections_found),
                      style: CommonStyles.txStyF16CpFF6,
                    ),
                  );
                }
              }
            }
          },
        ),
      ),
    );
  }

  Container collectionDataItem({
    required int index,
    required CollectionData data,
  }) {
    return Container(
        padding: const EdgeInsets.all(10),
        margin: const EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(
          color:
              index % 2 == 0 ? CommonStyles.whiteColor : Colors.grey.shade300,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    '${data.uColnid}',
                    style: CommonStyles.txStyF14CpFF6,
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    getInfoCollectionInfo(data.uColnid!);
                  },
                  child: Image.asset(
                    Assets.images.infoIcon.path,
                    color: CommonStyles.primaryTextColor,
                    height: 25,
                    width: 25,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: Row(
                    children: [
                      Expanded(
                          child: Text(
                        tr(LocaleKeys.only_date),
                        style: CommonStyles.txStyF14CbFF6,
                      )),
                      Text(
                        ' :  ',
                        style: CommonStyles.txStyF14CbFF6
                            .copyWith(color: CommonStyles.dataTextColor),
                      ),
                      Expanded(
                          child: Text(
                        '${CommonStyles.formatDate(data.docDate)}',
                        style: CommonStyles.txStyF14CbFF6
                            .copyWith(color: CommonStyles.dataTextColor),
                      )),
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Row(
                    children: [
                      Expanded(
                          child: Text(
                        tr(LocaleKeys.weight),
                        style: CommonStyles.txStyF14CbFF6,
                      )),
                      Text(
                        ':  ',
                        style: CommonStyles.txStyF14CbFF6
                            .copyWith(color: CommonStyles.dataTextColor),
                      ),
                      Expanded(
                          child: Text(
                        formatText('${data.quantity}'),
                        style: CommonStyles.txStyF14CbFF6
                            .copyWith(color: CommonStyles.dataTextColor),
                      )),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                    flex: 7,
                    child: Text(
                      tr(LocaleKeys.cc),
                      style: CommonStyles.txStyF14CbFF6,
                    )),
                Text(
                  ':  ',
                  style: CommonStyles.txStyF14CbFF6
                      .copyWith(color: CommonStyles.dataTextColor),
                ),
                Expanded(
                    flex: 22,
                    child: Text(
                      '${data.whsName}',
                      style: CommonStyles.txStyF14CbFF6
                          .copyWith(color: CommonStyles.dataTextColor),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    )),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: Row(
                    children: [
                      Expanded(
                          child: Text(
                        tr(LocaleKeys.status),
                        style: CommonStyles.txSty_14b_f5,
                      )),
                      Text(
                        ':  ',
                        style: CommonStyles.txStyF14CbFF6
                            .copyWith(color: CommonStyles.dataTextColor),
                      ),
                      Expanded(
                          child: Text(
                        data.uApaystat != 'Paid'
                            ? 'Pending'
                            : '${data.uApaystat}',
                        style: CommonStyles.txF14Fw5Cb.copyWith(
                          color: data.uApaystat == 'Paid'
                              ? CommonStyles.statusGreenText
                              : CommonStyles.RedColor,
                        ),
                      )),
                    ],
                  ),
                ),
                const Expanded(
                  child: SizedBox(),
                ),
              ],
            ),
          ],
        ));
  }

  Future<void> getInfoCollectionInfo(String code) async {
    final apiUrl = '$baseUrl$collectionInfoById$code';

    final jsonResponse = await http.get(Uri.parse(apiUrl));
    if (jsonResponse.statusCode == 200) {
      final response = jsonDecode(jsonResponse.body);

      if (response['result'] != null) {
        CommonStyles.customDialog(context,
            InfoDialog(info: CollectionInfo.fromJson(response['result'])));
      } else {
        CommonStyles.customDialog(context, const InfoDialog(info: null));
      }
    }
  }

  Future<CollectionResponse> getInitialData() async {
    DateFormat formatter = DateFormat('yyyy-MM-dd');
    String fromDate =
        formatter.format(DateTime.now().subtract(const Duration(days: 30)));
    return getCollectionData(fromDate: fromDate);
  }

  Future<CollectionResponse> getCollectionData({
    required String fromDate,
    String? toDate,
  }) async {
    DateFormat formatter = DateFormat('yyyy-MM-dd');
    toDate ??= formatter.format(DateTime.now());

    SharedPreferences prefs = await SharedPreferences.getInstance();
    final farmerCode = prefs.getString(SharedPrefsKeys.farmerCode);
    final apiUrl = baseUrl + getcollection;

    final requestBody = {
      "farmerCode": farmerCode,
      "fromDate": fromDate,
      "toDate": toDate,
    };

    final jsonResponse = await http.post(
      Uri.parse(apiUrl),
      body: json.encode(requestBody),
      headers: {
        'Content-Type': 'application/json',
      },
    );

    print('ffb getCollectionData: $apiUrl');
    print('ffb getCollectionData: ${json.encode(requestBody)}');
    print('ffb getCollectionData: ${jsonResponse.body}');
    if (jsonResponse.statusCode == 200) {
      final Map<String, dynamic> response = json.decode(jsonResponse.body);
      if (response['result'] != null) {
        List<dynamic> collectionDataList = response['result']['collectioData'];
        Map<String, dynamic> collectionCountMap =
            response['result']['collectionCount'][0];
        CollectionCount collectionCount =
            CollectionCount.fromJson(collectionCountMap);
        List<CollectionData> collectionData = collectionDataList
            .map((item) => CollectionData.fromJson(item))
            .toList();
        return CollectionResponse(collectionCount, collectionData);
      } else {
        return CollectionResponse(null, null);
      }
    } else {
      throw Exception(
          'Request failed with status: ${jsonResponse.statusCode}.');
    }
  }

  Future<CollectionResponse> getCollectionDataByCustomDates({
    required String fromDate,
    String? toDate,
  }) async {
    DateFormat formatter = DateFormat('yyyy-MM-dd');
    toDate ??= formatter.format(DateTime.now());

    SharedPreferences prefs = await SharedPreferences.getInstance();
    final farmerCode = prefs.getString(SharedPrefsKeys.farmerCode);
    final apiUrl = baseUrl + getcollection;

    final requestBody = {
      "farmerCode": farmerCode,
      "fromDate": fromDate,
      "toDate": toDate,
    };

    final jsonResponse = await http.post(
      Uri.parse(apiUrl),
      body: json.encode(requestBody),
      headers: {
        'Content-Type': 'application/json',
      },
    );

    print('ffb getCollectionData: $apiUrl');
    print('ffb getCollectionData: ${json.encode(requestBody)}');
    print('ffb getCollectionData: ${jsonResponse.body}');
    if (jsonResponse.statusCode == 200) {
      setState(() {
        isSelectTimePeriod = false;
      });
      final Map<String, dynamic> response = json.decode(jsonResponse.body);
      if (response['result'] != null) {
        List<dynamic> collectionDataList = response['result']['collectioData'];
        Map<String, dynamic> collectionCountMap =
            response['result']['collectionCount'][0];
        CollectionCount collectionCount =
            CollectionCount.fromJson(collectionCountMap);
        List<CollectionData> collectionData = collectionDataList
            .map((item) => CollectionData.fromJson(item))
            .toList();
        return CollectionResponse(collectionCount, collectionData);
      } else {
        return CollectionResponse(null, null);
      }
    } else {
      setState(() {
        isSelectTimePeriod = false;
      });
      throw Exception(
          'Request failed with status: ${jsonResponse.statusCode}.');
    }
  }

  void getCollectionAccordingToDropDownSelection(
      int selectedDropDownValueIndex) {
    setState(() {
      switch (selectedDropDownValueIndex) {
        case 0:
          apiCollectionData = getInitialData();
          break;
        case 1:
          apiCollectionData =
              getCollectionData(fromDate: getCurrentFinancialDate());
          break;
      }
    });
  }
}
