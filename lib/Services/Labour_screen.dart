// ignore_for_file: public_member_api_docs, sort_constructors_first, must_be_immutable
import 'dart:convert';

import 'package:akshaya_flutter/common_utils/custom_btn.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import 'package:akshaya_flutter/Services/models/LabourRequest.dart';
import 'package:akshaya_flutter/Services/models/ResponseModel.dart';
import 'package:akshaya_flutter/Services/models/ServiceType.dart';
import 'package:akshaya_flutter/common_utils/SuccessDialog.dart';
import 'package:akshaya_flutter/common_utils/api_config.dart';
import 'package:akshaya_flutter/common_utils/common_styles.dart';
import 'package:akshaya_flutter/common_utils/shared_prefs_keys.dart';
import 'package:akshaya_flutter/localization/locale_keys.dart';
import 'package:akshaya_flutter/models/farmer_model.dart';
import 'package:akshaya_flutter/models/plot_details_model.dart';

import '../common_utils/DottedLine.dart';
import '../common_utils/custom_appbar.dart';
import 'models/MsgModel.dart';

class Labourscreen extends StatefulWidget {
  final PlotDetailsModel plotdata;

  const Labourscreen({super.key, required this.plotdata});

  @override
  State<Labourscreen> createState() => _LabourscreenScreenState();
}

class _LabourscreenScreenState extends State<Labourscreen> {
  List<ServiceType> ServiceType_list = [];
  List<ResponseModel> ResponseModel_list = [];
  final List<ServiceType> _selectedServiceTypes = [];
  List<DropdownMenuItem<String>> dropDownValues = [];
  late List<dynamic> appointmentsData;
  bool _isChecked = false;
  bool _isagreed = false;
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _commentController = TextEditingController();
  List<LabourRequest> _labourRequests = [];
  String? _selectedDesc;
  bool isharvestingamount = false;
  bool ispurningamount = false;
  double? harvestCost;
  double? servicePercentage;
  double? prunningCost;
  double? pruningWithIntercropCost;
  double? harvestingWithIntercropCost;
  late Future<FarmerModel> farmerData;
  String? selectedDropDownValue;
  late String farmerCode,
      farmerName,
      Statecode,
      StateName,
      servicename,
      service_id;
  int? Cluster_id;
  int? selectduration_id;

  bool harvestingCheck = false;
  bool pruningCheck = false;

  Set<int> selectedServiceIds = {}; // Track selected IDs
  String selectedServiceNames = ''; // Track selected service names
  // List<String>? service_id;

  @override
  void initState() {
    super.initState();
    getspinnerdata(widget.plotdata.plotcode!);

    fetchLabourRequests();
    _fetchData();
    farmerData = getFarmerInfoFromSharedPrefs();

    farmerData.then((farmer) {
      farmerCode = '${farmer.code}';
      farmerName =
          '${farmer.firstName} ${farmer.middleName ?? ''} ${farmer.lastName}';
      Cluster_id = farmer.clusterId!;
      Statecode = '${farmer.stateCode}';
      StateName = '${farmer.stateName}';
    });

    fetchlabourservicecost();
  }

  String getSelectedServiceIds(Set<int> selectedServiceIds) {
    if (selectedServiceIds.isEmpty) {
      // error dialog
      return '';
    } else if (selectedServiceIds.length == 1) {
      return selectedServiceIds.first.toString();
    } else {
      return selectedServiceIds.join(',');
    }
  }

  Future<FarmerModel> getFarmerInfoFromSharedPrefs() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final result = prefs.getString(SharedPrefsKeys.farmerData);
    if (result != null) {}
    Map<String, dynamic> response = json.decode(result!);
    Map<String, dynamic> farmerResult = response['result']['farmerDetails'][0];
    return FarmerModel.fromJson(farmerResult);
  }

  Future<void> _selectDate(BuildContext context) async {
    DateTime initialDate = DateTime.now().add(const Duration(days: 3));
    DateTime? picked = await showDatePicker(
      initialEntryMode: DatePickerEntryMode.calendarOnly,
      context: context,
      initialDate: initialDate,
      firstDate: initialDate,
      cancelText: tr(LocaleKeys.cancel_capitalized),
      selectableDayPredicate: (DateTime date) {
        return date.weekday != DateTime.sunday;
      },
      lastDate: DateTime(DateTime.now().year + 100),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            inputDecorationTheme: const InputDecorationTheme(
              enabledBorder: InputBorder.none, // Hide manual entry underline
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _dateController.text = "${picked.day}/${picked.month}/${picked.year}";
      });
    }
  }

  Future<Api_Response> fetchLabourRequests() async {
    var url = baseUrl + getLabourDuration;
    final response = await http.get(
      Uri.parse(url),
    );

    if (response.statusCode == 200) {
      return Api_Response.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to load data');
    }
  }

  Future<void> _fetchData() async {
    try {
      Api_Response apiResponse = await fetchLabourRequests();
      setState(() {
        _labourRequests = apiResponse.listResult;
      });
    } catch (e) {
      print("Error fetching data: $e");
    }
  }

  ButtonStyle elevatedButtonStyle = ElevatedButton.styleFrom(
    padding: const EdgeInsets.symmetric(
        vertical: 16.0, horizontal: 32.0), // Adjust padding as needed
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(5), // Set border radius to 5
    ),
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CommonStyles.screenBgColor,
      appBar: CustomAppBar(
        title: tr(LocaleKeys.labour_lable),
      ),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            CropPlotDetails(
              plotdata: widget.plotdata,
              index: 0,
              isIconVisible: false,
            ),
            const SizedBox(height: 10),
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(4.0),
                  color: CommonStyles.labourTemplateColor,
                  // color: CommonStyles.screenBgColor,
                ),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Row(
                        children: [
                          Text(
                            tr(LocaleKeys.select_labour_type),
                            style: CommonStyles.txStyF14CwFF6,
                          ),
                          const SizedBox(
                            width: 5,
                          ),
                          const Icon(
                            Icons.star,
                            size: 8,
                            color: CommonStyles.formFieldErrorBorderColor,
                          )
                        ],
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      //MARK: Multi selecter
                      GestureDetector(
                        onTap: () {
                          // Open dialog when the container is tapped
                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return Dialog(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(2),
                                ),
                                child: StatefulBuilder(
                                  builder: (BuildContext context,
                                      StateSetter setDialogState) {
                                    return Container(
                                      width: MediaQuery.of(context).size.width *
                                          0.9,
                                      padding: const EdgeInsets.all(16),
                                      color: Colors.white,
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            children: [
                                              const SizedBox(width: 13),
                                              Text(
                                                tr(LocaleKeys.multistring),
                                                style: CommonStyles
                                                    .txStyF16CbFF6
                                                    .copyWith(
                                                  fontSize: 18,
                                                  fontWeight: FontWeight.w400,
                                                ),
                                              ),
                                            ],
                                          ),
                                          ...ServiceType_list.map((service) {
                                            return GestureDetector(
                                              onTap: () {
                                                setDialogState(() {
                                                  if (selectedServiceIds
                                                      .contains(
                                                          service.typeCdId)) {
                                                    selectedServiceIds.remove(
                                                        service.typeCdId);
                                                  } else {
                                                    selectedServiceIds
                                                        .add(service.typeCdId!);
                                                  }
                                                });
                                              },
                                              child: Row(
                                                children: [
                                                  Checkbox(
                                                    value: selectedServiceIds
                                                        .contains(
                                                            service.typeCdId),
                                                    activeColor: CommonStyles
                                                        .primaryTextColor,
                                                    onChanged: (value) {
                                                      setDialogState(() {
                                                        if (value == true) {
                                                          selectedServiceIds
                                                              .add(service
                                                                  .typeCdId!);
                                                        } else {
                                                          selectedServiceIds
                                                              .remove(service
                                                                  .typeCdId);
                                                        }
                                                      });
                                                    },
                                                  ),
                                                  const SizedBox(width: 12),
                                                  Text(
                                                    '${service.desc} ', // Assuming service has 'name' and 'localName'
                                                    style: CommonStyles
                                                        .txStyF16CbFF6
                                                        .copyWith(
                                                      fontWeight:
                                                          FontWeight.w400,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            );
                                          }),
                                          Row(
                                            children: [
                                              const Spacer(),
                                              ElevatedButton(
                                                onPressed: () {
                                                  Navigator.pop(context);
                                                },
                                                style: ElevatedButton.styleFrom(
                                                  backgroundColor:
                                                      Colors.transparent,
                                                  shadowColor:
                                                      Colors.transparent,
                                                  padding: const EdgeInsets
                                                      .symmetric(
                                                      vertical: 3.0,
                                                      horizontal: 10.0),
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            5),
                                                  ),
                                                ),
                                                child: const Text(
                                                  'CANCEL',
                                                  style: TextStyle(
                                                    color: CommonStyles
                                                        .primaryTextColor,
                                                  ),
                                                ),
                                              ),
                                              ElevatedButton(
                                                onPressed: () {
                                                  // Get the selected service names
                                                  List<String?> selectedNames =
                                                      ServiceType_list.where((service) =>
                                                              selectedServiceIds
                                                                  .contains(service
                                                                      .typeCdId!))
                                                          .map((service) =>
                                                              service.desc)
                                                          .toList();

                                                  // Update the state to display selected names
                                                  setState(() {
                                                    selectedServiceNames =
                                                        selectedNames
                                                            .join(', ');

                                                    // Check if pruning is selected and set pruningCheck to true
                                                    pruningCheck =
                                                        selectedServiceNames
                                                            .contains(
                                                                'Pruning (ప్రూనింగ్)');

                                                    // Check if harvesting is selected and set harvestingCheck to true
                                                    harvestingCheck =
                                                        selectedServiceNames
                                                            .contains(
                                                                'Harvesting (గెలల కోత)');
                                                    if (pruningCheck &&
                                                        harvestingCheck) {
                                                      selectedDropDownValue =
                                                          null;
                                                      selectduration_id = null;
                                                    } else if (pruningCheck) {
                                                      selectedDropDownValue =
                                                          '1 Day';
                                                      selectduration_id = 38;
                                                    }

                                                    dropDownValues =
                                                        setDropDownValues(
                                                            pruningCheck,
                                                            harvestingCheck);
                                                  });

                                                  Navigator.pop(
                                                      context); // Close the dialog
                                                },
                                                style: ElevatedButton.styleFrom(
                                                  backgroundColor: Colors.white,
                                                  shadowColor:
                                                      Colors.transparent,
                                                  padding: const EdgeInsets
                                                      .symmetric(
                                                      vertical: 3.0,
                                                      horizontal: 10.0),
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            5),
                                                  ),
                                                ),
                                                child: const Text(
                                                  'SUBMIT',
                                                  style: TextStyle(
                                                    color: CommonStyles
                                                        .primaryTextColor,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                ),
                              );
                            },
                          );
                        },
                        child: Container(
                          height: 48,
                          padding: const EdgeInsets.only(left: 13),
                          alignment: Alignment.centerLeft,
                          width: MediaQuery.of(context).size.width,
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.white, width: 1.5),
                            borderRadius: BorderRadius.circular(8.0),
                            color: Colors.transparent,
                          ),
                          // Display the selected options or placeholder text
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                selectedServiceNames.isNotEmpty
                                    ? selectedServiceNames
                                    : 'Tap to select', // Placeholder when no service selected
                                style: CommonStyles.txStyF14CwFF6,
                              ),
                              const Row(
                                children: [
                                  Icon(
                                    Icons.keyboard_arrow_down_rounded,
                                    color: Colors.white,
                                  ),
                                  SizedBox(
                                    width: 10,
                                  ),
                                ],
                              )
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(
                        height: 8,
                      ),
                      Visibility(
                        visible: harvestingCheck,
                        child: plotDetailsBox(
                          label: tr(LocaleKeys.harv_amount),
                          data: harvestCost != null
                              ? harvestCost!.toStringAsFixed(2)
                              : "0.00",
                        ),
                      ),
                      Visibility(
                        visible: pruningCheck,
                        child: Column(
                          children: [
                            const SizedBox(height: 4),
                            // MARK: Pruning Cost
                            plotDetailsBox(
                              label: tr(LocaleKeys.pru_amount),
                              data: prunningCost != null
                                  ? prunningCost!.toStringAsFixed(2)
                                  : "0.00",
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 10),
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            _isChecked = !_isChecked;
                          });
                        },
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            SizedBox(
                              width: 22,
                              height: 22,
                              child: Checkbox(
                                value: _isChecked,
                                onChanged: (value) {
                                  setState(() {
                                    _isChecked = value!;
                                  });
                                },
                                checkColor: Colors.grey,
                                fillColor:
                                    WidgetStateProperty.resolveWith<Color>(
                                        (states) {
                                  if (states.contains(WidgetState.selected)) {
                                    return Colors.white;
                                  }
                                  return Colors.transparent;
                                }),
                                side: const BorderSide(
                                  color: Colors.black,
                                  width: 2,
                                ),
                              ),
                            ),
                            const SizedBox(width: 5),
                            Text(
                              tr(LocaleKeys.have_pole),
                              style: CommonStyles.txStyF14CwFF6,
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 10),
/* 
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Checkbox(
                            value: _isChecked,
                            onChanged: (value) {
                              setState(() {
                                _isChecked = value!;
                              });
                            },
                            checkColor: Colors.grey,
                            fillColor: WidgetStateProperty.resolveWith<Color>(
                                (states) {
                              if (states.contains(WidgetState.selected)) {
                                return Colors.white;
                              }
                              return Colors.transparent;
                            }),
                            side: const BorderSide(
                              color: Colors.black,
                              width: 2,
                            ),
                          ),
                          Text(
                            tr(LocaleKeys.have_pole),
                            style: CommonStyles.txStyF14CwFF6,
                          ),
                        ],
                      ),
                     */

                      Row(
                        children: [
                          Text(
                            tr(LocaleKeys.startDate),
                            style: CommonStyles.txStyF14CwFF6,
                          ),
                          const SizedBox(
                            width: 5,
                          ),
                          const Icon(
                            Icons.star,
                            size: 8,
                            color: CommonStyles.formFieldErrorBorderColor,
                          )
                        ],
                      ),
                      Container(
                        height: 55,
                        padding:
                            const EdgeInsets.only(left: 0, top: 10.0, right: 0),
                        child: GestureDetector(
                          onTap: () async {
                            _selectDate(context);
                          },
                          child: Container(
                            height: 55,
                            width: MediaQuery.of(context).size.width,
                            decoration: BoxDecoration(
                              border:
                                  Border.all(color: Colors.white, width: 1.5),
                              borderRadius: BorderRadius.circular(8.0),
                              color: Colors.transparent,
                            ),
                            child: AbsorbPointer(
                              child: SizedBox(
                                height: 55,
                                child: TextFormField(
                                  controller: _dateController,
                                  style: CommonStyles.txStyF14CwFF6,
                                  decoration: InputDecoration(
                                    hintText: tr(LocaleKeys.slecteddate),
                                    hintStyle: CommonStyles.txStyF14CwFF6,
                                    contentPadding: const EdgeInsets.symmetric(
                                        horizontal: 16.0, vertical: 10.0),
                                    // Adjust padding as needed
                                    suffixIcon: const Padding(
                                      padding: EdgeInsets.all(8.0),
                                      child: Icon(
                                        Icons.calendar_today,
                                        color: Colors.white,
                                      ),
                                    ),
                                    border: InputBorder.none,
                                    isDense: true,
                                  ),
                                  textAlignVertical: TextAlignVertical.center,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(
                        height: 8,
                      ),
                      Row(
                        children: [
                          Text(
                            tr(LocaleKeys.labour_duration),
                            style: CommonStyles.txStyF14CwFF6,
                          ),
                          const SizedBox(
                            width: 5,
                          ),
                          const Icon(
                            Icons.star,
                            size: 8,
                            color: CommonStyles.formFieldErrorBorderColor,
                          )
                        ],
                      ),
                      const SizedBox(
                        height: 4,
                      ),

                      //MARK: DropdownButton2
                      Container(
                        height: 45,
                        padding: const EdgeInsets.only(right: 10),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                              color: CommonStyles.whiteColor, width: 1.5),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton2<String>(
                            value: selectedDropDownValue,
                            iconStyleData: const IconStyleData(
                              icon: Icon(
                                Icons.keyboard_arrow_down_rounded,
                                color: Colors.white,
                              ),
                            ),
                            isExpanded: true,
                            hint: const Text(
                              'Select',
                              style: CommonStyles.txStyF14CwFF6,
                            ),
                            items: dropDownValues,
                            onChanged: (String? newValue) {
                              setState(() {
                                selectedDropDownValue = newValue;
                                LabourRequest? selectedRequest =
                                    _labourRequests.firstWhere(
                                  (request) => request.desc == newValue,
                                );
                                selectduration_id = selectedRequest.typeCdId;
                                print(
                                    'DropDown Values: $selectedDropDownValue | $selectduration_id');
                              });
                            },
                            dropdownStyleData: DropdownStyleData(
                              decoration: const BoxDecoration(
                                // borderRadius: BorderRadius.circular(14),
                                borderRadius: BorderRadius.only(
                                    bottomRight: Radius.circular(12),
                                    bottomLeft: Radius.circular(12)),
                                color: CommonStyles.dropdownListBgColor,
                              ),
                              offset: const Offset(0, 0),
                              scrollbarTheme: ScrollbarThemeData(
                                radius: const Radius.circular(40),
                                thickness: WidgetStateProperty.all<double>(6),
                                thumbVisibility:
                                    WidgetStateProperty.all<bool>(true),
                              ),
                            ),
                            menuItemStyleData: const MenuItemStyleData(
                              height: 40,
                              padding: EdgeInsets.only(left: 20, right: 20),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(
                        height: 2,
                      ),

                      /*  if (_selectedDesc != null &&
                          (_selectedDesc == _labourRequests[1].desc ||
                              _selectedDesc == _labourRequests[2].desc ||
                              _selectedDesc == _labourRequests[3].desc)) */
                      if (selectedDropDownValue == '3 Months' ||
                          selectedDropDownValue == '6 Months' ||
                          selectedDropDownValue == '1 Year')
                        Padding(
                          padding: const EdgeInsets.all(0),
                          child: Text(
                            tr(LocaleKeys.text),
                            style: CommonStyles.txStyF14CpFF6.copyWith(
                                color: const Color.fromARGB(255, 3, 201, 105)),
                          ),
                        ),
                      const SizedBox(
                        height: 8,
                      ),
                      Row(
                        children: [
                          Text(
                            tr(LocaleKeys.comments),
                            style: CommonStyles.txStyF14CwFF6,
                          ),
                        ],
                      ),
                      const SizedBox(
                        height: 4,
                      ),
                      Container(
                        height: 45,
                        padding: const EdgeInsets.all(0.0),
                        child: TextFormField(
                          controller: _commentController,
                          decoration: InputDecoration(
                            contentPadding:
                                const EdgeInsets.only(top: 5, left: 15),
                            enabledBorder: OutlineInputBorder(
                              borderSide: const BorderSide(
                                  color: Colors.white,
                                  width: 1.5), // White border
                              borderRadius: BorderRadius.circular(8),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: const BorderSide(
                                  color: Colors.white,
                                  width: 1.5), // White border on focus
                              borderRadius: BorderRadius.circular(8),
                            ),
                            hintText: tr(LocaleKeys.comments),
                            hintStyle: CommonStyles.txStyF14CwFF6,
                          ),
                          style: CommonStyles.txStyF14CwFF6,
                        ),
                      ),
                      const SizedBox(height: 20),
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            _isagreed = !_isagreed;
                            if (_isagreed) {
                              showRateChartDialog(context);
                            }
                          });
                        },
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(
                              width: 22,
                              height: 22,
                              child: Checkbox(
                                value: _isagreed,
                                onChanged: (value) {
                                  setState(() {
                                    _isagreed = !_isagreed;
                                    if (_isagreed) {
                                      showRateChartDialog(context);
                                    }
                                  });
                                },
                                checkColor: Colors.grey,
                                fillColor:
                                    WidgetStateProperty.resolveWith<Color>(
                                        (states) {
                                  if (states.contains(WidgetState.selected)) {
                                    return Colors.white;
                                  }
                                  return Colors.transparent;
                                }),
                                side: const BorderSide(
                                  color: Colors.black,
                                  width: 2,
                                ),
                              ),
                            ),
                            const SizedBox(width: 5),
                            Flexible(
                              child: RichText(
                                text: TextSpan(
                                  children: <TextSpan>[
                                    TextSpan(
                                      text: tr(LocaleKeys.i_have_agree),
                                      style: CommonStyles.txStyF14CwFF6,
                                    ),
                                    TextSpan(
                                      text:
                                          ' ${tr(LocaleKeys.terms_conditions)}',
                                      style:
                                          CommonStyles.txStyF14CpFF6.copyWith(
                                        fontWeight: FontWeight.bold,
                                        color: CommonStyles.primaryTextColor,
                                      ),
                                      /*  recognizer: TapGestureRecognizer()
                                        ..onTap = () {
                                          showRateChartDialog(context);
                                        }, */
                                    ),
                                  ],
                                ),
                                softWrap: true,
                                overflow: TextOverflow.visible,
                              ),
                            )
                          ],
                        ),
                      ),
/* 
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(
                            width: 22,
                            height: 22,
                            child: Checkbox(
                              value: _isagreed,
                              onChanged: (value) {
                                setState(() {
                                  _isagreed = !_isagreed;
                                  if (_isagreed) {
                                    showRateChartDialog(context);
                                  }
                                });
                              },
                              checkColor: Colors.grey,
                              fillColor: WidgetStateProperty.resolveWith<Color>(
                                  (states) {
                                if (states.contains(WidgetState.selected)) {
                                  return Colors.white;
                                }
                                return Colors.transparent;
                              }),
                              side: const BorderSide(
                                color: Colors.black,
                                width: 2,
                              ),
                            ),
                          ),
                          const SizedBox(width: 5),
                          Flexible(
                            child: RichText(
                              text: TextSpan(
                                children: <TextSpan>[
                                  TextSpan(
                                    text: tr(LocaleKeys.i_have_agree),
                                    style: CommonStyles.txStyF14CwFF6,
                                  ),
                                  TextSpan(
                                    text:
                                        '  ${tr(LocaleKeys.terms_conditions)}',
                                    style: CommonStyles.txStyF14CpFF6.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: CommonStyles.primaryTextColor,
                                    ),
                                    // Wrap with GestureDetector for click action
                                    recognizer: TapGestureRecognizer()
                                      ..onTap = () {
                                        showRateChartDialog(
                                            context); // Correctly calling the function
                                      },
                                  ),
                                ],
                              ),
                              softWrap: true,
                              overflow: TextOverflow.visible,
                            ),
                          )
                        ],
                      ),
                      */

                      const SizedBox(height: 10),
                      submitBtn(context, tr(LocaleKeys.submit_req)),
                    ],
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  String? _getSelectedValue() {
    if (_selectedServiceTypes.any((service) => service.typeCdId == 19) &&
        !_selectedServiceTypes.any((service) => service.typeCdId == 20)) {
      return _labourRequests.isNotEmpty ? _labourRequests[0].desc : null;
    } else if (_selectedServiceTypes.any((service) => service.typeCdId == 20)) {
      return _selectedDesc;
    } else {
      return null;
    }
  }

//MARK: submitBtn
  Widget submitBtn(
    BuildContext context,
    String language,
  ) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        CustomBtn(
            label: language,
            btnTextColor: CommonStyles.primaryTextColor,
            onPressed: () async {
              bool validationSuccess = await validateLabourRequest();
              if (validationSuccess) {
                submitLabourRequest();
              }
            }),
      ],
    );
  }

/* 
  Widget submitBtn(
    BuildContext context,
    String language,
  ) {
    return SizedBox(
      //  width: double.infinity,
      child: Container(
        padding: const EdgeInsets.only(left: 10, right: 10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16.0),
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
        child: ElevatedButton(
          onPressed: () async {
            // bool validationSuccess = await isvalidations();
            /* if (validationSuccess) {
              submitLabourRequest();
            } */
            submitLabourRequest();
          },
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 0, horizontal: 30),
            backgroundColor: Colors.transparent,
            shadowColor: Colors.transparent,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16.0),
            ),
          ),
          child: Text(
            /* language,
            style: CommonStyles.txSty_16p_f5, */

            language,
            style: CommonStyles.txStyF14CpFF6,
          ),
        ),
      ),
    );
  }
 */
  void showSuccessDialog(
      BuildContext context, List<MsgModel> msg, String summary) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return PopScope(
            /*  onWillPop: () {
              return Future.value(false);
            }, */
            canPop: false,
            child: SuccessDialog(msg: msg, title: summary));
      },
    );
  }

  Widget plotDetailsBox(
      {required String label, required String data, Color? dataTextColor}) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
                flex: 7,
                child: Text(
                  label,
                  style: CommonStyles.text14white,
                )),
            const Expanded(
              flex: 1,
              child: Text(
                ':',
                style: TextStyle(color: Colors.white),
              ),
            ),
            Expanded(
                flex: 4,
                child: Text(
                  data,
                  style: CommonStyles.text14white.copyWith(
                    color: dataTextColor,
                  ),
                )),
          ],
        ),
        const SizedBox(height: 5),
      ],
    );
  }

  Future<void> getspinnerdata(String pc) async {
    final url = Uri.parse(baseUrl + getLabourServicetype + pc);
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);
        print('response==$responseData');
        if (responseData['result'] != null) {
          appointmentsData = responseData['result'];
          setState(() {
            ServiceType_list = appointmentsData
                .map((appointment) => ServiceType.fromJson(appointment))
                .toList();
          });
          print('ServiceType_list${appointmentsData.length}');
        } else {
          print('Failed to show Farmer plot details list');
        }
      } else {
        throw Exception('Failed to show Farmer plot details list');
      }
    } catch (error) {
      throw Exception('Failed to connect to the API $error');
    }
    return;
  }

  Future<bool> validateLabourRequest() async {
    print('_isagreed $_isagreed');
    if (selectedServiceNames.isEmpty) {
      CommonStyles.showCustomDialog(context, tr(LocaleKeys.Valid_service));
      return false;
    } else if (_dateController.text.isEmpty) {
      CommonStyles.showCustomDialog(context, tr(LocaleKeys.date_selectiomn));
      return false;
    } else if (selectedDropDownValue == null) {
      CommonStyles.showCustomDialog(context, tr(LocaleKeys.valid_pack));
      return false;
    } else if (!_isagreed) {
      CommonStyles.showCustomDialog(context, tr(LocaleKeys.terms_agree));
      return false;
    } else {
      return true;
    }
  }

  Future<void> fetchlabourservicecost() async {
    final url = Uri.parse(baseUrl + getLabourServiceCost);

    final request = {"dateOfPlanting": "${widget.plotdata.dateOfPlanting}"};

    try {
      final response = await http.post(
        url,
        body: json.encode(request),
        headers: {
          'Content-Type': 'application/json',
        },
      );
      print('fetchlabourservicecost: $url');
      print('fetchlabourservicecost: ${json.encode(request)}');
      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);

        if (responseData['result'] != null) {
          var result = responseData['result'];

          //MARK: Here
          setState(() {
            final harvestCostValue = result['harvestCost'];
            servicePercentage =
                (result['servicePercentage'] * harvestCostValue) / 100;

            harvestCost =
                (servicePercentage! + harvestCostValue).roundToDouble();

            final prunningCostValue = result['prunningCost'];
            servicePercentage =
                (result['servicePercentage'] * prunningCostValue) / 100;
            prunningCost =
                (servicePercentage! + prunningCostValue).roundToDouble();
            pruningWithIntercropCost = result['pruningWithIntercropCost'];
            harvestingWithIntercropCost = result['harvestingWithIntercropCost'];
          });
        } else {
          print('Failed to get labour service costs');
        }
      } else {
        throw Exception('Failed to get labour service costs');
      }
    } catch (error) {
      throw Exception('Failed to connect to the API: $error');
    }
  }

  Future<void> submitLabourRequest() async {
    final url = Uri.parse(baseUrl + addlabourequest);
    setState(() {
      CommonStyles.showHorizontalDotsLoadingDialog(context);
    });
    DateTime currentDate = DateTime.now();

    DateFormat inputFormat = DateFormat('dd/MM/yyyy');
    DateFormat outputFormat = DateFormat('yyyy-MM-dd');
    String prefdate = _dateController.text.toString();
    DateTime parsedDate = inputFormat.parse(prefdate);
    String formattedDate = outputFormat.format(parsedDate);

    String comments = _commentController.text.toString();

//MARK: Request Object
    final request = {
      "farmerCode": farmerCode,
      "farmerName": farmerName,
      "plotCode": "${widget.plotdata.plotcode}",
      "plotVillage": "${widget.plotdata.villageName}",
      "palmArea": widget.plotdata.palmArea,
      "isFarmerRequest": true,
      "comments": comments,
      "preferredDate": formattedDate,
      "durationId": selectduration_id,
      "serviceTypes": getSelectedServiceIds(selectedServiceIds),
      "createdByUserId": 1,
      "createdDate": CommonStyles.formatApiDate(currentDate),
      "updatedByUserId": 1,
      "updatedDate": CommonStyles.formatApiDate(currentDate),
      "amount": 1.1,
      "harvestingAmount": harvestingCheck ? harvestCost : null,
      "pruningAmount": pruningCheck ? prunningCost : null,
      "pruningWithIntercropAmount": 0.0,
      "harvestingWithIntercropAmount": 0.0,
      "yearofPlanting": "${widget.plotdata.dateOfPlanting}",
      "clusterId": Cluster_id,
      "ownPole": _isChecked,
      "services": selectedServiceNames,
      "package": selectedDropDownValue,
      "stateCode": Statecode,
      "stateName": StateName,
    };

    try {
      final response = await http.post(
        url,
        body: json.encode(request),
        headers: {
          'Content-Type': 'application/json',
        },
      );
      print('labourrequestsendbtn: $url');
      print('labourrequestsendbtn: ${json.encode(request)}');
      print('labourrequestsendbtn: ${response.body}');

      CommonStyles.hideHorizontalDotsLoadingDialog(context);
      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);
        if (responseData['isSuccess']) {
          String prningcost = prunningCost!.toStringAsFixed(2);
          String Harvestingcost = harvestCost!.toStringAsFixed(2);
          List<MsgModel> displayList = [
            MsgModel(
                key: tr(LocaleKeys.select_labour_type),
                value: selectedServiceNames),
            if (harvestingCheck)
              MsgModel(key: tr(LocaleKeys.harv_amount), value: Harvestingcost),
            if (pruningCheck)
              MsgModel(key: tr(LocaleKeys.pru_amount), value: prningcost),
            MsgModel(
                key: tr(LocaleKeys.Package), value: "$selectedDropDownValue"),
            MsgModel(key: tr(LocaleKeys.starttDate), value: prefdate),
          ];

          showSuccessDialog(
              context, displayList, tr(LocaleKeys.success_labour));
          print('responseData$responseData');
        } else {
          throw Exception('Request submission failed');
        }
      } else {
        print(
            'Request was not successful. Status code: ${response.statusCode}');
        CommonStyles.hideHorizontalDotsLoadingDialog(context);
      }
    } catch (e) {
      print('Error: $e');
      CommonStyles.hideHorizontalDotsLoadingDialog(context);
    }
  }

  void showRateChartDialog(BuildContext context) async {
    // Step 1: Fetch the data from the API
    const url =
        'http://182.18.157.215/3FAkshaya/API/api/LabourServiceCost/GetLabourServiceCost/null';
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      List<dynamic> listResult = data['listResult'];

      // Step 2: Show the dialog with dynamically generated table rows
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(1.0),
            ),
            child: SizedBox(
              //  padding: EdgeInsets.all(2),
              width: MediaQuery.of(context).size.width * 0.9,
              height: MediaQuery.of(context).size.height * 0.75,
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title
                    Container(
                      color: CommonStyles.primaryTextColor,
                      alignment: Alignment.center, // Center the title
                      padding: const EdgeInsets.all(
                          8), // Optional padding for better spacing
                      child: Text(
                        tr(LocaleKeys.terms_conditions),
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white, // Text color
                        ),
                      ),
                    ),
                    // Table

                    Column(
                      children: [
                        // Static Table Header
                        Table(
                          border: TableBorder.all(color: CommonStyles.lightgry),
                          columnWidths: const {
                            0: FlexColumnWidth(2),
                            1: FlexColumnWidth(2),
                            2: FlexColumnWidth(2),
                            3: FlexColumnWidth(2),
                            4: FlexColumnWidth(2),
                          },
                          defaultVerticalAlignment:
                              TableCellVerticalAlignment.middle,
                          children: [
                            TableRow(
                              //   decoration: BoxDecoration(color: CommonStyles.primaryTextColor),
                              children: [
                                tableHeader(tr(LocaleKeys.measurement)),
                                tableHeader(tr(LocaleKeys.pru_amount)),
                                tableHeader(tr(LocaleKeys.harv_amount)),
                                tableHeader(tr(LocaleKeys.intercrop_prunning)),
                                tableHeader(tr(LocaleKeys.harv_intercrop)),
                              ],
                            ),
                          ],
                        ),
                        // Scrollable Table Body
                        SizedBox(
                          height:
                              220, // Set the fixed height for the scrollable part
                          child: SingleChildScrollView(
                            scrollDirection: Axis.vertical,
                            child: Table(
                              border: const TableBorder(
                                verticalInside: BorderSide(
                                    color: CommonStyles
                                        .lightgry), // Add vertical border
                              ),
                              columnWidths: const {
                                0: FlexColumnWidth(2),
                                1: FlexColumnWidth(2),
                                2: FlexColumnWidth(2),
                                3: FlexColumnWidth(2),
                                4: FlexColumnWidth(2),
                              },
                              children: [
                                ...generateTableRows(listResult),
                              ],
                            ),
                          ),
                        ),
                        // SizedBox(
                        //   height: 300, // Set the fixed height for the scrollable part
                        //   child: SingleChildScrollView(
                        //     scrollDirection: Axis.vertical,
                        //     child: Table(
                        //       columnWidths: const {
                        //         0: FlexColumnWidth(2),
                        //         1: FlexColumnWidth(2),
                        //         2: FlexColumnWidth(2),
                        //         3: FlexColumnWidth(2),
                        //         4: FlexColumnWidth(2),
                        //       },
                        //       children: [
                        //         // Generate table rows with dotted lines
                        //         ...generateTableRows(listResult),
                        //       ],
                        //     ),
                        //   ),
                        // )
                      ],
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(5, 5, 5, 5),
                      child: Text(
                        tr(LocaleKeys.inter_coco),
                        style: CommonStyles.txStyF12CpFF6,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CustomBtn(
                            label: tr(LocaleKeys.got_it),
                            borderRadius: 22,
                            onPressed: () => Navigator.of(context).pop()),
                      ],
                    ),
                    const SizedBox(height: 10),
                  ],
                ),
              ),
            ),
          );
        },
      );
    } else {
      // Handle error in fetching data
      print("Failed to load data");
    }
  }

  List<TableRow> generateTableRows(List<dynamic> listResult) {
    List<TableRow> rows = [];

    // Loop for each year (c1 to c30 represent the values for years 1 to 30)
    for (int i = 1; i <= 30; i++) {
      // Create a TableRow for the data
      rows.add(
        TableRow(
          children: [
            Padding(
              padding: const EdgeInsets.all(2.0),
              child: Text(
                i == 1 ? '<= 1 Year' : '$i Years',
                style: CommonStyles.txStyhalfblack,
                textAlign: TextAlign.center,
              ), // Measurement
            ),
            Padding(
              padding: const EdgeInsets.all(2.0),
              child: Text(
                listResult[0]['c$i'].toStringAsFixed(2),
                style: CommonStyles.txStyhalfblack,
                textAlign: TextAlign.center,
              ), // Pruning Amount/Tree
            ),
            Padding(
              padding: const EdgeInsets.all(2.0),
              child: Text(
                listResult[1]['c$i'].toStringAsFixed(2),
                style: CommonStyles.txStyhalfblack,
                textAlign: TextAlign.center,
              ), // Harvesting Amount/Ton
            ),
            Padding(
              padding: const EdgeInsets.all(2.0),
              child: Text(
                listResult[2]['c$i'].toStringAsFixed(2),
                style: CommonStyles.txStyhalfblack,
                textAlign: TextAlign.center,
              ), // Pruning with Cocoa Intercrop/Tree
            ),
            Padding(
              padding: const EdgeInsets.all(2.0),
              child: Text(
                listResult[3]['c$i'].toStringAsFixed(2),
                style: CommonStyles.txStyhalfblack,
                textAlign: TextAlign.center,
              ), // Harvesting with Cocoa Intercrop/Ton
            ),
          ],
        ),
      );
    }

    return rows;
  }

// Helper widget for table headers
  Widget tableHeader(String title) {
    return Padding(
      padding: const EdgeInsets.all(3.0),
      child: Text(
        title,
        style: CommonStyles.txStyF12CpFF6,
        textAlign: TextAlign.center,
      ),
    );
  }

// Helper function for table rows
  TableRow tableRow(String age, String pruning, String harvesting,
      String cocoaPruning, String cocoaHarvesting) {
    return TableRow(
      children: [
        tableCell(age),
        tableCell(pruning),
        tableCell(harvesting),
        tableCell(cocoaPruning),
        tableCell(cocoaHarvesting),
      ],
    );
  }

// Helper widget for table cells
  Widget tableCell(String content) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Text(
        content,
        style: CommonStyles.txStyF12CbFF6,
        textAlign: TextAlign.center,
      ),
    );
  }

  //MARK: setDropDownValues
  List<DropdownMenuItem<String>> setDropDownValues(
      bool pruningCheck, bool harvestingCheck) {
    if (pruningCheck && harvestingCheck) {
      return _labourRequests
          .map((request) => DropdownMenuItem<String>(
                value: request.desc,
                child: Text(
                  request.desc,
                  style: CommonStyles.txStyF14CwFF6,
                ),
              ))
          .toList();
    } else if (harvestingCheck) {
      return _labourRequests
          .map((request) => DropdownMenuItem<String>(
                value: request.desc,
                child: Text(
                  request.desc,
                  style: CommonStyles.txStyF14CwFF6,
                ),
              ))
          .toList();
    } else {
      return _labourRequests
          .where((request) => request.typeCdId == 38)
          .map((request) => DropdownMenuItem<String>(
                value: request.desc,
                child: Text(
                  request.desc,
                  style: const TextStyle(color: Colors.white),
                ),
              ))
          .toList();
    }
  }

  // List<TableRow> generateTableRowsWithDottedLines(List<dynamic> listResult) {
  //   List<TableRow> rows = [];
  //
  //   // Loop for each year (c1 to c30 represent the values for years 1 to 30)
  //   for (int i = 1; i <= 30; i++) {
  //     rows.add(
  //       TableRow(
  //         children: [
  //           // Measurement
  //           TableCell(child: Padding(padding: const EdgeInsets.all(8.0), child: Text('$i Years'))),
  //           const DottedLine(height: 40, width: 1, color: CommonStyles.lightgry), // Dotted line
  //           // Pruning Amount/Tree
  //           TableCell(child: Padding(padding: const EdgeInsets.all(8.0), child: Text(listResult[0]['c$i'].toString()))),
  //           const DottedLine(height: 40, width: 1, color: CommonStyles.lightgry), // Dotted line
  //           // Harvesting Amount/Ton
  //           TableCell(child: Padding(padding: const EdgeInsets.all(8.0), child: Text(listResult[1]['c$i'].toString()))),
  //           const DottedLine(height: 40, width: 1, color: CommonStyles.lightgry), // Dotted line
  //           // Pruning with Cocoa Intercrop/Tree
  //           TableCell(child: Padding(padding: const EdgeInsets.all(8.0), child: Text(listResult[2]['c$i'].toString()))),
  //           const DottedLine(height: 40, width: 1, color: CommonStyles.lightgry), // Dotted line
  //           // Harvesting with Cocoa Intercrop/Ton
  //           TableCell(child: Padding(padding: const EdgeInsets.all(8.0), child: Text(listResult[3]['c$i'].toString()))),
  //         ],
  //       ),
  //     );
  //   }
  //
  //   return rows;
  // }
}

class MultiDialogContent extends StatelessWidget {
  final void Function(bool?)? pruningOnChanged;
  final void Function()? pruningOnTap;
  final void Function(bool?)? harvestingOnChanged;
  final void Function()? harvestingOnTap;
  final void Function()? onSubmit;
  final bool? pruningCheck;
  final bool? harvestingCheck;

  const MultiDialogContent({
    super.key,
    this.pruningOnChanged,
    this.pruningOnTap,
    this.harvestingOnChanged,
    this.harvestingOnTap,
    this.onSubmit,
    this.pruningCheck,
    this.harvestingCheck,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width * 0.9,
      padding: const EdgeInsets.all(16),
      color: Colors.white,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const SizedBox(
                width: 13,
              ),
              Text(
                tr(LocaleKeys.multistring),
                style: CommonStyles.txStyF16CbFF6.copyWith(
                  fontSize: 20,
                ),
              ),
            ],
          ),
          GestureDetector(
            onTap: pruningOnTap,
            child: Row(
              children: [
                Checkbox(
                  value: pruningCheck,
                  activeColor: CommonStyles.primaryTextColor,
                  onChanged: pruningOnChanged,
                ),
                const SizedBox(width: 12),
                Text('Pruning (ప్రూనింగ్)',
                    style: CommonStyles.txStyF16CbFF6
                        .copyWith(fontWeight: FontWeight.w400)),
              ],
            ),
          ),
          GestureDetector(
            onTap: harvestingOnTap,
            child: Row(
              children: [
                Checkbox(
                  value: harvestingCheck,
                  activeColor: CommonStyles.primaryTextColor,
                  onChanged: harvestingOnChanged,
                ),
                const SizedBox(width: 12),
                Text(
                  'Harvesting (గెలల కోత)',
                  // 'Harvesting (data)',
                  style: CommonStyles.txStyF16CbFF6
                      .copyWith(fontWeight: FontWeight.w400),
                ),
              ],
            ),
          ),
          Row(
            children: [
              const Spacer(),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  padding: const EdgeInsets.symmetric(
                      vertical: 3.0, horizontal: 10.0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(5),
                  ),
                ),
                child: const Text(
                  'CANCEL',
                  style: TextStyle(color: CommonStyles.primaryTextColor),
                ),
              ),
              ElevatedButton(
                onPressed: onSubmit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  shadowColor: Colors.transparent,
                  padding: const EdgeInsets.symmetric(
                      vertical: 3.0, horizontal: 10.0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(5),
                  ),
                ),
                child: const Text(
                  'SUBMIT',
                  style: TextStyle(color: CommonStyles.primaryTextColor),
                ),
              )
            ],
          )
        ],
      ),
    );
  }
}

class CropPlotDetails extends StatelessWidget {
  final PlotDetailsModel plotdata;
  final int index;
  final void Function()? onTap;
  final bool isIconVisible;

  const CropPlotDetails(
      {super.key,
      required this.plotdata,
      required this.index,
      this.onTap,
      this.isIconVisible = true});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        GestureDetector(onTap: onTap, child: plot(context)),
      ],
    );
  }

  Widget plot(BuildContext context) {
    final df = NumberFormat("#,##0.00");
    String? dateOfPlanting = plotdata.dateOfPlanting;
    DateTime parsedDate = DateTime.parse(dateOfPlanting!);
    String year = parsedDate.year.toString();
    return Container(
      // padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
          // border:
          //     Border.all(color: CommonStyles.primaryTextColor, width: 0.3),
          borderRadius: BorderRadius.circular(10),
          color: index % 2 == 0 ? Colors.transparent : Colors.grey.shade200),
      child: Stack(
        children: [
          plotCard(df, year),
          if (isIconVisible)
            const Positioned(
                top: 0,
                bottom: 0,
                right: 0,
                child: Icon(Icons.arrow_forward_ios_rounded))
        ],
      ),
    );
  }

  Column plotCard(NumberFormat df, String year) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        plotDetailsBox(
            label: tr(LocaleKeys.plot_code),
            data: '${plotdata.plotcode}',
            dataTextColor: CommonStyles.primaryTextColor),
        plotDetailsBox(
          label: tr(LocaleKeys.plot_size),
          data:
              '${df.format(plotdata.palmArea)} Ha (${df.format(plotdata.palmArea! * 2.5)} Acre)',
        ),
        plotDetailsBox(
          label: tr(LocaleKeys.village),
          data: '${plotdata.villageName}',
        ),
        plotDetailsBox(
          label: tr(LocaleKeys.land_mark),
          data: '${plotdata.landMark}',
        ),
        plotDetailsBox(
          label: tr(LocaleKeys.cluster_officer),
          data: '${plotdata.clusterName}',
        ),
        plotDetailsBox(
          label: tr(LocaleKeys.yop),
          data: year,
        ),
        if (plotdata.interCrops != null)
          plotDetailsBox(
            label: tr(LocaleKeys.intercrops),
            data: '${plotdata.interCrops}',
          ),
      ],
    );
  }

  Widget plotDetailsBox(
      {required String label,
      required String data,
      Color? dataTextColor = CommonStyles.dataTextColor}) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
                flex: 5,
                child: Text(
                  label,
                  style: CommonStyles.txStyF14CbFF6,
                )),
            Expanded(
                flex: 6,
                child: Text(data, style: CommonStyles.txStyF14CbFF6
                    /*  style: CommonStyles.txStyF14CbFF6.copyWith(
                    color: dataTextColor,
                  ), */
                    )),
          ],
        ),
        const SizedBox(height: 8),
      ],
    );
  }
}
