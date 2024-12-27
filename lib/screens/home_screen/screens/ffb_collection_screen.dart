import 'dart:convert';

import 'package:akshaya_flutter/common_utils/api_config.dart';
import 'package:akshaya_flutter/common_utils/common_styles.dart';
import 'package:akshaya_flutter/common_utils/common_widgets.dart';
import 'package:akshaya_flutter/common_utils/custom_appbar.dart';
import 'package:akshaya_flutter/common_utils/custom_btn.dart';
import 'package:akshaya_flutter/common_utils/shared_prefs_keys.dart';
import 'package:akshaya_flutter/gen/assets.gen.dart';
import 'package:akshaya_flutter/localization/locale_keys.dart';
import 'package:akshaya_flutter/models/collection_count.dart';
import 'package:akshaya_flutter/models/collection_data_model.dart';
import 'package:akshaya_flutter/models/collection_info_model.dart';
import 'package:akshaya_flutter/screens/home_screen/screens/temp_ffb_collection_screen.dart';
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
          //MARK: header
          Container(
            // height: dropdownItems.indexOf(selectedDropDownValue!) == 0
            //     /* (dropdownItems.indexOf(selectedDropDownValue!) == 0 ||
            //         dropdownItems.indexOf(selectedDropDownValue!) == 1) */
            //     ? (size.height / 2) - AppBar().preferredSize.height
            //     : null,
               
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  CommonStyles.appBarColor,
                  // CommonStyles.gradientColor1,
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
          items: dropdownItems
              .map((String item) => DropdownMenuItem<String>(
                    value: item,
                    child: Center(
                      child: Text(
                        item,
                        style:
                            CommonStyles.txStyF14CwFF6.copyWith(fontSize: 15),
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
        const SizedBox(height: 5),
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
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(
            flex: 3,
            child: datePickerBox1(
              dateLabel: tr(LocaleKeys.from_date),
              displaydate: displayFromDate,
              onTap: () {
                CommonWidgets.launchDatePicker(
                  context,
                  onDateSelected: (pickedDay) {
                    if (pickedDay != null) {
                      setState(() {
                        selectedFromDate = pickedDay;
                        displayFromDate =
                            DateFormat('dd/MM/yyyy').format(selectedFromDate!);
                      });
                    }
                  },
                );
              },
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
              flex: 3,
              child: datePickerBox2(
                dateLabel: tr(LocaleKeys.to_date),
                // dateLabel: 'To Date',
                displaydate: displayToDate,
                onTap: () async {
                  /*  final DateTime currentDate = DateTime.now();
                  final DateTime firstDate = DateTime(currentDate.year - 100); */

                  CommonWidgets.launchDatePicker(context,
                      onDateSelected: (pickedDay) {
                    if (pickedDay != null) {
                      setState(() {
                        selectedToDate = pickedDay;
                        displayToDate =
                            DateFormat('dd/MM/yyyy').format(selectedToDate!);
                      });
                    }
                  });
                },
              )),
          const SizedBox(width: 8),
          //MARK: Submit Btn
          Expanded(
            flex: 3,
            child: CustomBtn(
                height: 45,
                padding: const EdgeInsets.symmetric(
                  horizontal: 22,
                ),
                label: tr(LocaleKeys.submit),
                btnTextColor: CommonStyles.primaryTextColor,
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
                  : Text(displaydate, style: CommonStyles.txStyF16CwFF6),
            ],
          ),
          const Divider(
            color: CommonStyles.dataTextColor2,
          ),
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
                  : Text(displaydate, style: CommonStyles.txStyF16CwFF6),
            ],
          ),
          const Divider(
            color: CommonStyles.dataTextColor2,
          ),
        ],
      ),
    );
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
                  textAlign: TextAlign.center,
                  snapshot.error.toString().replaceFirst('Exception: ', ''),
                  style: CommonStyles.txStyF16CpFF6),
            );
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
        padding: const EdgeInsets.all(12),
        // padding: const EdgeInsets.fromLTRB(10, 5, 12, 0),
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
                return Center(
                  child: Text(
                      textAlign: TextAlign.center,
                      snapshot.error.toString().replaceFirst('Exception: ', ''),
                      style: CommonStyles.txStyF16CpFF6),
                );
              } else {
                final collection = snapshot.data as CollectionResponse;

                if (collection.collectionData != null) {
                  /*  return ListView.builder(
                    itemCount: collection.collectionData!.length,
                    itemBuilder: (context, index) {
                      return collectionDataItem(
                          index: index,
                          data: collection.collectionData![index]);
                    },
                  ); */
                  return CommonWidgets.customSlideAnimation(
                    itemCount: collection.collectionData!.length,
                    childBuilder: (index) {
                      return collectionDataItem(
                          index: index,
                          data: collection.collectionData![index]);
                    },
                  );
                } else {
                  return Center(
                    child: Text(
                      tr(LocaleKeys.no_collections_found),
                      style: CommonStyles.txStyF16CpFF6.copyWith(
                        fontSize: 20,
                      ),
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
            cardRow(
              label1: tr(LocaleKeys.only_date),
              data1: '${CommonStyles.formatDate(data.docDate)}',
              label2: tr(LocaleKeys.weight),
              data2: formatText('${data.quantity}'),
            ),
            const SizedBox(height: 8),
            singleCardRow(label: tr(LocaleKeys.cc), data: '${data.whsName}'),
            const SizedBox(height: 8),
            singleCardRow(
              label: tr(LocaleKeys.status),
              data: data.uApaystat != 'Paid' ? 'Pending' : '${data.uApaystat}',
              dataStyle: CommonStyles.txStyF14CbFF6.copyWith(
                color: data.uApaystat == 'Paid'
                    ? CommonStyles.statusGreenText
                    : CommonStyles.RedColor,
              ),
            ),
          ],
        ));
  }

  Row singleCardRow(
      {required String label, required String data, TextStyle? dataStyle}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
            flex: 5,
            child: Text(
              label,
              style: CommonStyles.txStyF14CbFF6,
            )),
        Expanded(
          flex: 1,
          child: Text(
            ':',
            textAlign: TextAlign.center,
            style: CommonStyles.txStyF14CbFF6
                .copyWith(color: CommonStyles.dataTextColor),
          ),
        ),
        Expanded(
          flex: 22,
          child: Text(
            data,
            style: dataStyle ??
                CommonStyles.txStyF14CbFF6
                    .copyWith(color: CommonStyles.dataTextColor),
          ),
        ),
      ],
    );
  }

  Widget cardRow({
    required String label1,
    required String data1,
    required String label2,
    required String data2,
  }) {
    return Column(
      children: [
        const SizedBox(height: 8),
        Row(
          children: [
            dataItem(label: label1, data: data1),
            const SizedBox(width: 15),
            dataItem(label: label2, data: data2),
          ],
        ),
      ],
    );
  }

  Expanded dataItem({required String label, required String data}) {
    return Expanded(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
              flex: 4,
              child: Text(
                label,
                style: CommonStyles.txStyF14CbFF6,
              )),
          Expanded(
            flex: 1,
            child: Text(
              ':',
              textAlign: TextAlign.center,
              style: CommonStyles.txStyF14CbFF6
                  .copyWith(color: CommonStyles.dataTextColor),
            ),
          ),
          Expanded(
            flex: 6,
            child: Text(
              data,
              style: CommonStyles.txStyF14CbFF6
                  .copyWith(color: CommonStyles.dataTextColor),
            ),
          ),
        ],
      ),
    );
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
    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() {
        CommonStyles.showHorizontalDotsLoadingDialog(context);
      });
    });
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
    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() {
        CommonStyles.hideHorizontalDotsLoadingDialog(context);
      });
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

class CollectionResponse {
  final CollectionCount? collectionCount;
  final List<CollectionData>? collectionData;

  CollectionResponse(this.collectionCount, this.collectionData);
}

class InfoDialog extends StatelessWidget {
  final CollectionInfo? info;
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
      ),
      child: info != null
          ? Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(info!.code!, style: CommonStyles.txStyF14CpFF6),
                const SizedBox(height: 10),
                buildInfoRow(tr(LocaleKeys.driver_name), info!.driverName),
                buildInfoRow(
                    tr(LocaleKeys.vehicle_Number), info!.vehicleNumber),
                buildInfoRow(
                    tr(LocaleKeys.collectionCenter), info!.collectionCenter),
                buildInfoRow(
                    tr(LocaleKeys.grossWeight), info!.grossWeight.toString()),
                buildInfoRow(
                    tr(LocaleKeys.tareWeight), info!.tareWeight.toString()),
                buildInfoRow(
                    tr(LocaleKeys.net_weight), info!.netWeight.toString()),
                buildInfoRow(tr(LocaleKeys.only_date),
                    CommonStyles.formatDate(info!.receiptGeneratedDate)),
                buildInfoRow(tr(LocaleKeys.operatorName), info!.operatorName),
                if (info!.comments!.isNotEmpty)
                  buildInfoRow(tr(LocaleKeys.comments), info!.comments),
                const SizedBox(height: 10),
                Center(
                  child: TextButton(
                    onPressed: () {
                      CommonStyles.customDialognew(
                        context,
                        CachedNetworkImage(
                          imageUrl: info!.receiptImg!,
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
                        style: CommonStyles.txStyF14CpFF6),
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CustomBtn(
                      label: tr(LocaleKeys.close),
                      btnColor: CommonStyles.blackColor,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 40,
                      ),
                      borderRadius: 24,
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                    ),
                  ],
                ),
              ],
            )
          : Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(tr(LocaleKeys.comments),
                    style: CommonStyles.txStyF14CpFF6),
                const SizedBox(height: 10),
                buildInfoRow(tr(LocaleKeys.driver_name), ''),
                buildInfoRow(tr(LocaleKeys.vehicle_Number), ''),
                buildInfoRow(tr(LocaleKeys.collectionCenter), ''),
                buildInfoRow(tr(LocaleKeys.grossWeight), ''),
                buildInfoRow(tr(LocaleKeys.tareWeight), ''),
                buildInfoRow(tr(LocaleKeys.net_weight), ''),
                buildInfoRow(tr(LocaleKeys.only_date), ''),
                buildInfoRow(tr(LocaleKeys.operatorName), ''),
                buildInfoRow(tr(LocaleKeys.comments), ''),
                const SizedBox(height: 10),
                Center(
                  child: TextButton(
                    onPressed: () {
                      CommonStyles.customDialognew(
                        context,
                        Container(
                            color: CommonStyles.whiteColor,
                            width: MediaQuery.of(context).size.width * 0.7,
                            height: MediaQuery.of(context).size.height * 0.7,
                            child: const Center(
                              child: Text('No receipt found'),
                            )),
                        // CachedNetworkImage(
                        //   imageUrl: info!.receiptImg!,
                        //   placeholder: (context, url) =>
                        //       const CircularProgressIndicator(),
                        //   errorWidget: (context, url, error) => Image.asset(
                        //     Assets.images.icLogo.path,
                        //     fit: BoxFit.cover,
                        //   ),
                        // ),
                      );
                    },
                    child: Text(tr(LocaleKeys.recept),
                        style: CommonStyles.txStyF14CpFF6),
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CustomBtn(
                      label: tr(LocaleKeys.close),
                      /* height: 30,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 30,
                      ), */
                      borderRadius: 24,
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                    ),
                  ],
                ),
              ],
            ),
    );
  }

  Widget buildInfoRow(String label, String? value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 3,
            child: Text(label, style: CommonStyles.txStyF14CbFF6),
          ),
          const Expanded(
            flex: 1,
            child: Text(
              ':',
              style: CommonStyles.txStyF14CbFF6,
            ),
          ),
          Expanded(
            flex: 3,
            child: Text('$value', style: CommonStyles.txStyF14CbFF6),
          ),
        ],
      ),
    );
  }
}
