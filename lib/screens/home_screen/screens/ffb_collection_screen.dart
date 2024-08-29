import 'dart:convert';

import 'package:akshaya_flutter/common_utils/api_config.dart';
import 'package:akshaya_flutter/common_utils/common_styles.dart';
import 'package:akshaya_flutter/common_utils/custom_btn.dart';
import 'package:akshaya_flutter/common_utils/shared_prefs_keys.dart';
import 'package:akshaya_flutter/gen/assets.gen.dart';
import 'package:akshaya_flutter/models/collection_count.dart';
import 'package:akshaya_flutter/models/collection_data_model.dart';
import 'package:akshaya_flutter/models/collection_info_model.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class FfbCollectionScreen extends StatefulWidget {
  const FfbCollectionScreen({super.key});

  @override
  State<FfbCollectionScreen> createState() => _FfbCollectionScreenState();
}

class _FfbCollectionScreenState extends State<FfbCollectionScreen> {
  final List<String> dropdownItems = [
    'Last 30 days',
    'Current Financial Year',
    'Select Time Period',
  ];
  String? selectedDropDownValue = 'Last 30 days';
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

    print('getCollectionData: $fromDate, $toDate');
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final farmerCode = prefs.getString(SharedPrefsKeys.farmerCode);
    final apiUrl = baseUrl + getcollection;
    print('getCollectionData: $apiUrl');
    final requestBody = {
      "farmerCode": farmerCode,
      "fromDate": fromDate, // "2022-07-29",
      "toDate": toDate
    };
    print('getCollectionData: ${jsonEncode(requestBody)}');
    final jsonResponse = await http
        .post(Uri.parse(apiUrl), body: json.encode(requestBody), headers: {
      'Content-Type': 'application/json',
    });

    print('getCollectionData: ${jsonResponse.body}');
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
    return Scaffold(
      // backgroundColor: Colors.white,
      appBar: appBar(),
      body: Column(
        children: [
          Container(
            // color: CommonStyles.primaryTextColor,
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
            padding: const EdgeInsets.all(10),
            child: Column(
              children: [
                selectedDropDownValue != 'Select Time Period'
                    ? dropdownSelector()
                    : timePeriodSelector(),
                const SizedBox(height: 10),
                isTimePeriod ? const SizedBox() : collectionCount(),
                const SizedBox(height: 10),
              ],
            ),
          ),
          isTimePeriod ? const SizedBox() : collectionData(),
        ],
      ),
    );
  }

  Container collectionDataItem({
    required int index,
    required CollectionData data,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: index % 2 == 0 ? Colors.white : Colors.grey.shade200,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${data.uColnid}',
                style: CommonStyles.txSty_14p_f5
                    .copyWith(fontWeight: FontWeight.bold),
              ),
              IconButton(
                icon: const Icon(
                  Icons.info,
                  color: CommonStyles.primaryTextColor,
                ),
                onPressed: () {
                  getInfoCollectionInfo(data.uColnid!);
                },
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: Row(
                  children: [
                    const Expanded(
                        child: Text(
                      'Date',
                      style: CommonStyles.txSty_14b_f5,
                    )),
                    const Text(
                      ':  ',
                      style: CommonStyles.txF14Fw5Cb,
                    ),
                    Expanded(
                        child: Text(
                      '${CommonStyles.formateDate(data.docDate)}', //'${data.docDate}',
                      style: CommonStyles.txF14Fw5Cb,
                    )),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Row(
                  children: [
                    const Expanded(
                        child: Text(
                      'Weight',
                      style: CommonStyles.txSty_14b_f5,
                    )),
                    const Text(
                      ':  ',
                      style: CommonStyles.txF14Fw5Cb,
                    ),
                    Expanded(
                        child: Text(
                      '${data.quantity}',
                      style: CommonStyles.txF14Fw5Cb,
                    )),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 5),
          Row(
            children: [
              const Text(
                'CC',
                style: CommonStyles.txSty_14b_f5,
              ),
              const SizedBox(width: 60),
              const Text(
                ':  ',
                style: CommonStyles.txF14Fw5Cb,
              ),
              Text(
                '${data.uColnid}',
                style: CommonStyles.txF14Fw5Cb,
              ),
              const Spacer(),
            ],
          ),

          /* Row(
            children: [
              Expanded(
                child: Row(
                  children: [
                    const Expanded(
                        child: Text(
                      'CC',
                      style: CommonStyles.txSty_14b_f5,
                    )),
                    const Text(
                      ':  ',
                      style: CommonStyles.txF14Fw5Cb,
                    ),
                    Expanded(
                        child: Text(
                      '${data.uColnid}',
                      style: CommonStyles.txF14Fw5Cb,
                    )),
                  ],
                ),
              ),
              const Spacer(),
            ],
          ), */

          const SizedBox(height: 5),
          Row(
            children: [
              Expanded(
                child: Row(
                  children: [
                    const Expanded(
                        child: Text(
                      'Status',
                      style: CommonStyles.txSty_14b_f5,
                    )),
                    const Text(
                      ':  ',
                      style: CommonStyles.txF14Fw5Cb,
                    ),
                    Expanded(
                        child: Text(
                      '${data.uApaystat}',
                      style: CommonStyles.txF14Fw5Cb,
                    )),
                  ],
                ),
              ),
              const Expanded(
                child: SizedBox(),
              )
            ],
          ),
        ],
      ),
    );
  }

  Expanded collectionData() {
    return Expanded(
      child: Container(
        // color: Colors.teal,
        padding: const EdgeInsets.fromLTRB(10, 12, 12, 0),
        child: FutureBuilder(
            future: apiCollectionData,
            builder: (context, snapshot) {
              if (snapshot.hasData) {
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
                  return const Center(
                      child: Text(
                    'No Collections Available',
                    style: CommonStyles.txSty_16p_fb,
                  ));
                }
              }
              if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              }
              return const Center(child: CircularProgressIndicator());
            }),
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
                        title: 'Total Collections',
                        value: data.collectionsCount.toString()),
                    listRow(
                        title: 'Total New Weight',
                        value: data.collectionsWeight.toString()),
                    listRow(
                        title: 'Unpaid Collections Weight',
                        value: data.paidCollectionsWeight.toString()),
                    listRow(
                        title: 'Paid Collections Weight',
                        value: data.unPaidCollectionsWeight.toString()),
                  ],
                ),
              );
            } else {
              return const SizedBox();
            }
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          // return const Center(child: CircularProgressIndicator());
          return const SizedBox();
        });
  }

  Row listRow({
    required String title,
    required String value,
  }) {
    return Row(
      children: [
        Expanded(
            flex: 7,
            child: Text(
              title,
              style: CommonStyles.text14white,
            )),
        const Text(
          ':    ',
          style: CommonStyles.text14white,
        ),
        Expanded(
            flex: 5,
            child: Text(
              value,
              style: CommonStyles.text14white,
            )),
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
              print('selectedDropDownValue: $selectedDropDownValue');
              getCollectionAccordingToDropDownSelection(selectedDropDownValue!);

              if (selectedDropDownValue == 'Select Time Period') {
                setState(() {
                  isTimePeriod = true;
                });
              } else {
                setState(() {
                  isTimePeriod = false;
                });
              }
            });
          },
          dropdownStyleData: DropdownStyleData(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              color: Colors.black87,
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
    /*  
        DropdownButtonHideUnderline(
          child: DropdownButton2<String>(
            iconStyleData: const IconStyleData(
              icon: Icon(
                Icons.keyboard_arrow_down_rounded,
                color: Colors.white,
              ),
            ),
            isExpanded: true,
            hint: const Row(
              children: [
                Expanded(
                  child: Text(
                    'Select Item',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            items: dropdownItems
                .map((String item) => DropdownMenuItem<String>(
                      value: item,
                      child: Text(
                        item,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ))
                .toList(),
            value: selectedDropDownValue,
            onChanged: (String? value) {
              setState(() {
                selectedDropDownValue = value;
                print('selectedDropDownValue: $selectedDropDownValue');
                getCollectionAccordingToDropDownSelection(
                    selectedDropDownValue!);

                if (selectedDropDownValue == 'Select Time Period') {
                  setState(() {
                    isTimePeriod = true;
                  });
                } else {
                  setState(() {
                    isTimePeriod = false;
                  });
                }
                // getCollectionData(fromDate: fromDate);
              });
            },
            dropdownStyleData: DropdownStyleData(
              // maxHeight: 200,
              // width: 200,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(14),
                color: Colors.grey,
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
        ));
  */
  }

  AppBar appBar() {
    return AppBar(
      backgroundColor: CommonStyles.gradientColor1,
      leading: GestureDetector(
          onTap: () {
            Navigator.pop(context);
          },
          child: Image.asset(Assets.images.icLeft.path)),
      elevation: 0,
      title: Text(
        "FFB Collections",
        style: CommonStyles.txSty_14black_f5
            .copyWith(color: CommonStyles.whiteColor),
      ),
      actions: [
        SvgPicture.asset(
          Assets.images.icHome.path,
          width: 20,
          height: 20,
          color: Colors.black,
          fit: BoxFit.contain,
        ),
        const SizedBox(width: 10)
      ],
    );
  }

/*   String? formateDate(String? formateDate) {
    if (formateDate != null) {
      DateFormat formatter = DateFormat('dd-MM-yyyy');
      DateTime date = DateTime.parse(formateDate);
      return formatter.format(date);
    } else {
      return formateDate;
    }
  } */

  void getCollectionAccordingToDropDownSelection(String selectedDropDownValue) {
/* 'Last 30 days',
    'Current Financial Year',
    'Select Time Period', */

    switch (selectedDropDownValue) {
      case 'Last 30 days':
        apiCollectionData = getInitialData();
        break;

      case 'Current Financial Year':
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
              dateLabel: 'From Date',
              displaydate: displayFromDate,
              onTap: () {
                final DateTime currentDate = DateTime.now();
                final DateTime firstDate = DateTime(currentDate.year - 1);
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
            dateLabel: 'To Date',
            displaydate: displayToDate,
            onTap: () {
              final DateTime currentDate = DateTime.now();
              final DateTime firstDate = DateTime(currentDate.year - 1);
              launchToDatePicker(context,
                  firstDate: selectedFromDate ?? firstDate,
                  lastDate: currentDate,
                  initialDate: selectedFromDate);
            },
          )),
          const SizedBox(width: 10),
          CustomBtn(
              label: 'Submit',
              onPressed: () {
                validateAndSubmit(selectedFromDate, selectedToDate);
              }),
          /*  ElevatedButton(
              onPressed: () {
                validateAndSubmit(selectedFromDate, selectedToDate);
              },
              style: ElevatedButton.styleFrom(
                // padding: const EdgeInsets.symmetric(horizontal: 10),
                backgroundColor: Colors.white,
                shadowColor: Colors.transparent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: const BorderSide(color: Colors.grey),
                ),
              ),
              child: const Text('Submit', style: CommonStyles.txSty_14p_f5)) */
        ],
      ),
    );
  }

  void errorDialog(BuildContext context) {
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
              child: errorDialogContent()),
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
          displaydate == null
              ? Row(
                  children: [
                    Text(dateLabel,
                        style: CommonStyles.txSty_14black
                            .copyWith(color: CommonStyles.whiteColor)),
                    const SizedBox(width: 5),
                    const Text('*', style: TextStyle(color: Colors.red)),
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
        print('datepicker selectedFromDate $selectedFromDate');
        displayFromDate = DateFormat('dd-MM-yyyy').format(selectedFromDate!);
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
        print('datepicker selectedToDate $selectedToDate');
        displayToDate = DateFormat('dd-MM-yyyy').format(selectedToDate!);
      });
    }
    // return DateFormat('dd-MM-yyyy').format(selectedToDate!);
  }

  void validateAndSubmit(DateTime? selectedFromDate, DateTime? selectedToDate) {
    if (selectedFromDate == null || selectedToDate == null) {
      return errorDialog(context);
    }
    apiCollectionData = getCollectionData(
      fromDate: DateFormat('yyyy-MM-dd').format(selectedFromDate),
      toDate: DateFormat('yyyy-MM-dd').format(selectedToDate),
    );
  }

  Widget errorDialogContent() {
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
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, color: Colors.white),
                  SizedBox(width: 5),
                  Text('Error', style: CommonStyles.txSty_16w_fb),
                ],
              )),
          Container(
            alignment: Alignment.center,
            padding: const EdgeInsets.all(12.0),
            height: 120,
            color: CommonStyles.blackColor,
            child: Column(
              children: [
                Text(
                  'Please Enter From Date and To Date',
                  style:
                      CommonStyles.txSty_14b_f5.copyWith(color: Colors.white),
                ),
                const SizedBox(height: 20),
                CustomBtn(
                    label: 'Ok',
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
      width: size.width * 0.85,
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
          const Text(
            'Comments',
            style: TextStyle(
              color: Colors.redAccent,
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
          const SizedBox(height: 15),
          buildInfoRow('Driver Name', info.driverName),
          buildInfoRow('Vehicle Number', info.vehicleNumber),
          buildInfoRow('Collection Center', info.collectionCenter),
          buildInfoRow('Gross Weight', info.grossWeight.toString()),
          buildInfoRow('Tare Weight', info.tareWeight.toString()),
          buildInfoRow('Net Weight', info.netWeight.toString()),
          buildInfoRow(
              'Date', CommonStyles.formateDate(info.receiptGeneratedDate)),
          buildInfoRow('3F OP Collection Officer Name', info.operatorName),
          buildInfoRow('Comments', info.comments),
          const SizedBox(height: 20),
          Center(
            child: TextButton(
              onPressed: () {
                CommonStyles.customDialog(
                  context,
                  Image.network(
                    info.receiptImg!,
                    width: 300,
                    height: 300,
                    fit: BoxFit.contain,
                  ),
                );
              },
              child: const Text(
                'Click Here to See Receipt',
                style: TextStyle(
                  color: Colors.orange,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          Center(
            child: ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.black,
                backgroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                  side: const BorderSide(color: Colors.orange, width: 2),
                ),
              ),
              child: const Text('Close'),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildInfoRow(String label, String? value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
          const Expanded(
            flex: 1,
            child: Text(':'),
          ),
          Expanded(
            flex: 3,
            child: Text(
              '$value',
              style: const TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),
          ),
        ],
      ),
    );
  }
}



  /* ListView.builder(
                  itemCount: 22,
                  itemBuilder: (context, index) => const ListTile(
                    title: Text('data'),
                  ),
                ), 

  DropdownButtonHideUnderline dropdownSelector() {
    return DropdownButtonHideUnderline(
      child: DropdownButton2<String>(
        iconStyleData: const IconStyleData(
          icon: Icon(
            Icons.keyboard_arrow_down_rounded,
            color: Colors.white,
          ),
        ),
        isExpanded: true,
        hint: const Row(
          children: [
            Expanded(
              child: Text(
                'Select Item',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        items: items
            .map((String item) => DropdownMenuItem<String>(
                  value: item,
                  child: Text(
                    item,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ))
            .toList(),
        value: selectedDropDownValue,
        onChanged: (String? value) {
          setState(() {
            selectedDropDownValue = value;
          });
        },
        dropdownStyleData: DropdownStyleData(
          // maxHeight: 200,
          // width: 200,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            color: Colors.grey,
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
    );
  }
 */