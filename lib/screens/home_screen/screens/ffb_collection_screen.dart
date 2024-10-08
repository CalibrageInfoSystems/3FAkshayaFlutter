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
import 'package:cached_network_image/cached_network_image.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class FfbCollectionScreen extends StatefulWidget {
  const FfbCollectionScreen({super.key});

  @override
  State<FfbCollectionScreen> createState() => _FfbCollectionScreenState();
}

class _FfbCollectionScreenState extends State<FfbCollectionScreen> {
  final List<String> dropdownItems = [
    tr(LocaleKeys.thirty_days),
    tr(LocaleKeys.currentfinicial),
    tr(LocaleKeys.selected),
  ];

/*   final List<String> dropdownItems = [
    'Last 30 days',
    'Current Financial Year',
    'Select Time Period',
  ]; */

  Map<String, String> dropdownValues = {
    'Last 30 days': tr(LocaleKeys.thirty_days),
    'Current Financial Year': tr(LocaleKeys.currentfinicial),
    'Select Time Period': tr(LocaleKeys.selected),
  };

  String? selectedDropDownValue = tr(LocaleKeys.thirty_days);
  bool isTimePeriod = false;
  late Future<CollectionResponse> apiCollectionData;

  DateTime? selectedFromDate;
  DateTime? selectedToDate;
  String? displayFromDate;
  String? displayToDate;

  @override
  void initState() {
    super.initState();
    apiCollectionData = getInitialData();
    // apiCollectionData = Future.value();
  }

  Future<CollectionResponse> getInitialData() async {
    DateFormat formatter = DateFormat('yyyy-MM-dd');
    String fromDate =
        formatter.format(DateTime.now().subtract(const Duration(days: 30)));
    // String toDate = formatter.format(DateTime.now());
    return getCollectionData(fromDate: fromDate);
  }

  Future<CollectionResponse> getCollectionData(
      {required String fromDate, String? toDate}) async {
    // const apiUrl = 'http://182.18.157.215/3FAkshaya/API/api/Collection';
    DateFormat formatter = DateFormat('yyyy-MM-dd');
    toDate ??= formatter.format(DateTime.now());

    SharedPreferences prefs = await SharedPreferences.getInstance();
    final farmerCode = prefs.getString(SharedPrefsKeys.farmerCode);
    final apiUrl = baseUrl + getcollection;
    final requestBody = {
      "farmerCode": farmerCode,
      "fromDate": fromDate, // "2022-07-29",
      "toDate": toDate
    };
    final jsonResponse = await http
        .post(Uri.parse(apiUrl), body: json.encode(requestBody), headers: {
      'Content-Type': 'application/json',
    });

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
        setState(() {
          isTimePeriod = false;
        });
        return CollectionResponse(collectionCount, collectionData);
      }
      setState(() {
        isTimePeriod = false;
      });
      // throw Exception('No data found.');
      return CollectionResponse(null, null);
    } else {
      setState(() {
        isTimePeriod = false;
      });
      throw Exception(
          'Request failed with status: ${jsonResponse.statusCode}.');
    }
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
            // color: CommonStyles.primaryTextColor,
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
                // selectedDropDownValue != 'Select Time Period'
                dropdownItems.indexOf(selectedDropDownValue!) != 2
                    ? dropdownSelector()
                    : timePeriodSelector(),
                const SizedBox(height: 10),
                isTimePeriod ? const SizedBox() : collectionCount(),
                //const SizedBox(height: 10),
              ],
            ),
          ),
          isTimePeriod ? const SizedBox() : collectionData(context),
        ],
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
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${data.uColnid}',
                  style: CommonStyles.txStyF14CpFF6,
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

  Expanded collectionData(BuildContext context) {
    return Expanded(
      child: Container(
        // color: Colors.teal,
        padding: const EdgeInsets.fromLTRB(10, 5, 12, 0),
        child: FutureBuilder(
          future: apiCollectionData,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              // Show loading dialog
              WidgetsBinding.instance.addPostFrameCallback((_) {
                CommonStyles.showHorizontalDotsLoadingDialog(context);
              });
              return const SizedBox
                  .shrink(); // Return an empty widget while loading
            } else {
              // Hide loading dialog
              WidgetsBinding.instance.addPostFrameCallback((_) {
                CommonStyles.hideHorizontalDotsLoadingDialog(context);
              });
            }

            if (snapshot.hasData) {
              final collection = snapshot.data as CollectionResponse;

              if (collection.collectionData != null) {
                return ListView.builder(
                  itemCount: collection.collectionData!.length,
                  itemBuilder: (context, index) {
                    return collectionDataItem(
                        index: index, data: collection.collectionData![index]);
                  },
                );
              } else {
                return const Center(
                  child: Text(
                    'No Collections Available',
                    style: CommonStyles.txSty_16p_fb,
                  ),
                );
              }
            }

            if (snapshot.hasError) {
              return Center(
                  child: Text(
                'Error: ${snapshot.error}',
                style: CommonStyles.txStyF16CpFF6,
              ));
            }

            return const Center(child: CircularProgressIndicator());
          },
        ),
      ),
    );
  }

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

  Container dropdownSelector() {
    return Container(
      alignment: Alignment.center,
      padding: const EdgeInsets.only(right: 10),
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
              print('ffb selectedDropDownValue: $selectedDropDownValue');
              getCollectionAccordingToDropDownSelection(
                  dropdownItems.indexOf(selectedDropDownValue!));

              if (dropdownItems.indexOf(selectedDropDownValue!) == 2) {
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
            });
          },
          dropdownStyleData: DropdownStyleData(
            decoration: const BoxDecoration(
              // borderRadius: BorderRadius.circular(14),
              borderRadius: BorderRadius.only(
                  bottomRight: Radius.circular(12),
                  bottomLeft: Radius.circular(12)),
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
    );
  }

  void getCollectionAccordingToDropDownSelection(
      int selectedDropDownValueIndex) {
    print('dropdown index: $selectedDropDownValueIndex');
    switch (selectedDropDownValueIndex) {
      case 0:
        apiCollectionData = getInitialData();
        break;

      case 1:
        apiCollectionData =
            getCollectionData(fromDate: getCurrentFinancialDate());
        break;

      default:
        break;
    }
  }

  String getCurrentFinancialDate() {
    DateTime now = DateTime.now();

    // Define the month and day for the financial year start (April 1st)
    DateTime financialYearStart;

    if (now.month < 4) {
      // If the current month is before April, the financial year started last year
      financialYearStart = DateTime(now.year - 1, 4, 1);
    } else {
      // Otherwise, the financial year started this year
      financialYearStart = DateTime(now.year, 4, 1);
    }

    // Return the formatted date in YYYY-MM-DD format
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
          const SizedBox(width: 20),
          Expanded(
            flex: 1,
            child: CustomBtn(
                label: tr(LocaleKeys.submit),
                onPressed: () {
                  validateAndSubmit(selectedFromDate, selectedToDate);
                }),
          ),
        ],
      ),
    );
  }

  void errorDialog(BuildContext context, {required String errorMessage}) {
    final size = MediaQuery.of(context).size;
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: '',
      barrierColor: Colors.black54,
      transitionDuration: const Duration(milliseconds: 500),
      pageBuilder: (context, animation1, animation2) {
        return Center(
          child: Material(
              clipBehavior: Clip.antiAlias,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(6)),
              child: SizedBox(
                width: size.width * 0.7,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                        height: 60,
                        alignment: Alignment.center,
                        padding: const EdgeInsets.all(12.0),
                        color: CommonStyles.primaryTextColor,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.error_outline,
                                color: Colors.white),
                            const SizedBox(width: 5),
                            Text(tr(LocaleKeys.error),
                                style: CommonStyles.txSty_16w_fb),
                          ],
                        )),
                    Container(
                      alignment: Alignment.center,
                      padding: const EdgeInsets.all(12.0),
                      // height: 120,
                      color: CommonStyles.blackColor,
                      child: Column(
                        children: [
                          Text(
                            errorMessage,
                            // tr(LocaleKeys.enter_Date),
                            // tr(LocaleKeys.datevalidation),
                            style: CommonStyles.txSty_14b_f5
                                .copyWith(color: Colors.white),
                          ),
                          const SizedBox(height: 20),
                          CustomBtn(
                              label: tr(LocaleKeys.ok),
                              onPressed: () {
                                Navigator.of(context).pop();
                              }),
                        ],
                      ),
                    )
                  ],
                ),
              )),
        );
      },
      transitionBuilder: (context, animation1, animation2, child) {
        return ScaleTransition(
          scale: Tween<double>(begin: 0.0, end: 1.0).animate(
            CurvedAnimation(
              parent: animation1,
              curve: Curves.easeOutBack, // Customize the animation curve here
            ),
          ),
          child: child,
        );
      },
    );
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

  void validateAndSubmit(DateTime? selectedFromDate, DateTime? selectedToDate) {
    if (selectedFromDate == null || selectedToDate == null) {
      return _showErrorDialog(tr(LocaleKeys.enter_Date));

      // return errorDialog(
      //   context,
      //   errorMessage: tr(LocaleKeys.enter_Date),
      // );
    } else if (selectedToDate.isBefore(selectedFromDate)) {
      return _showErrorDialog(tr(LocaleKeys.datevalidation));
    }
    apiCollectionData = getCollectionData(
      fromDate: DateFormat('yyyy-MM-dd').format(selectedFromDate),
      toDate: DateFormat('yyyy-MM-dd').format(selectedToDate),
    );
  }

  Widget errorDialogContent({required String errorMessage}) {
    final size = MediaQuery.of(context).size;
    return SizedBox(
      width: size.width * 0.7,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
              height: 60,
              alignment: Alignment.center,
              padding: const EdgeInsets.all(12.0),
              color: CommonStyles.primaryTextColor,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, color: Colors.white),
                  const SizedBox(width: 5),
                  Text(tr(LocaleKeys.error), style: CommonStyles.txSty_16w_fb),
                ],
              )),
          Container(
            alignment: Alignment.center,
            padding: const EdgeInsets.all(12.0),
            // height: 120,
            color: CommonStyles.blackColor,
            child: Column(
              children: [
                Text(
                  errorMessage,
                  // tr(LocaleKeys.enter_Date),
                  // tr(LocaleKeys.datevalidation),
                  style:
                      CommonStyles.txSty_14b_f5.copyWith(color: Colors.white),
                ),
                const SizedBox(height: 20),
                CustomBtn(
                    label: tr(LocaleKeys.ok),
                    onPressed: () {
                      Navigator.of(context).pop();
                    }),
              ],
            ),
          )
        ],
      ),
    );
  }

  Future<void> getInfoCollectionInfo(String code) async {
    final apiUrl =
        'http://103.241.144.240:9096/api/Collection/CollectionInfoById/$code';

    final jsonResponse = await http.get(Uri.parse(apiUrl));

    if (jsonResponse.statusCode == 200) {
      final response = jsonDecode(jsonResponse.body);

      if (response['result'] != null) {
        CommonStyles.customDialog(context,
            InfoDialog(info: CollectionInfo.fromJson(response['result'])));
      }
    }
  }

  void _showErrorDialog(String message) {
    Future.delayed(Duration.zero, () {
      CommonStyles.showCustomDialog(context, message);
    });
  }
}

class CollectionResponse {
  final CollectionCount? collectionCount;
  final List<CollectionData>? collectionData;

  CollectionResponse(this.collectionCount, this.collectionData);
}

class InfoDialog extends StatelessWidget {
  final CollectionInfo info;
  const InfoDialog({super.key, required this.info});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Container(
      width: size.width * 0.75,
      padding: const EdgeInsets.all(12.0),
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: Colors.grey[200],
        // borderRadius: BorderRadius.circular(5.0),
        // border: Border.all(color: Colors.orange, width: 2),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(info.code!, style: CommonStyles.text18orangeeader),
          const SizedBox(height: 10),
          buildInfoRow(tr(LocaleKeys.driver_name), info.driverName),
          buildInfoRow(tr(LocaleKeys.vehicle_Number), info.vehicleNumber),
          buildInfoRow(tr(LocaleKeys.collectionCenter), info.collectionCenter),
          buildInfoRow(tr(LocaleKeys.grossWeight), info.grossWeight.toString()),
          buildInfoRow(tr(LocaleKeys.tareWeight), info.tareWeight.toString()),
          buildInfoRow(tr(LocaleKeys.net_weight), info.netWeight.toString()),
          buildInfoRow(tr(LocaleKeys.only_date),
              CommonStyles.formatDate(info.receiptGeneratedDate)),
          buildInfoRow(tr(LocaleKeys.operatorName), info.operatorName),
          if (info.comments!.isNotEmpty)
            buildInfoRow(tr(LocaleKeys.comments), info.comments),
          const SizedBox(height: 10),
          Center(
            child: TextButton(
              onPressed: () {
                CommonStyles.customDialognew(
                  context,
                  CachedNetworkImage(
                    imageUrl: info.receiptImg!,
                    placeholder: (context, url) =>
                        const CircularProgressIndicator(),
                    errorWidget: (context, url, error) => Image.asset(
                      Assets.images.icLogo.path,
                      fit: BoxFit.cover,
                    ),
                  ),
                );
              },
              child: Text(tr(LocaleKeys.recept),
                  style: CommonStyles.text18orangeeader),
            ),
          ),
          Center(
            child: CustomBtn(
              label: tr(LocaleKeys.close),
              // label: 'Submit',
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget buildInfoRow(String label, String? value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.0),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Text(label, style: CommonStyles.txSty_14SB_fb),
          ),
          const Expanded(
            flex: 1,
            child: Text(
              ':',
              style: CommonStyles.txSty_14SB_fb,
            ),
          ),
          Expanded(
            flex: 3,
            child: Text('$value', style: CommonStyles.txSty_14SB_fb),
          ),
        ],
      ),
    );
  }
}
