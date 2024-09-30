// ignore_for_file: public_member_api_docs, sort_constructors_first, must_be_immutable
import 'dart:convert';

import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:easy_localization/easy_localization.dart';
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
  double? prunningCost;
  double? pruningWithIntercropCost;
  double? harvestingWithIntercropCost;
  late Future<FarmerModel> farmerData;
  late String farmerCode,
      farmerName,
      Statecode,
      StateName,
      servicename,
      service_id;
  late int Cluster_id;
  late int selectduration_id;

  bool harvestingCheck = false;
  bool pruningCheck = false;

  // List<String>? service_id;

  @override
  void initState() {
    super.initState();
    getspinnerdata(widget.plotdata.plotcode!);
    fetchLabourRequests();
    _fetchData();
    farmerData = getFarmerInfoFromSharedPrefs();

    farmerData.then((farmer) {
      print('farmerData==${farmer.code}');
      farmerCode = '${farmer.code}';
      farmerName =
          '${farmer.firstName} ${farmer.middleName ?? ''} ${farmer.lastName}';
      Cluster_id = farmer.clusterId!;
      Statecode = '${farmer.stateCode}';
      StateName = '${farmer.stateName}';
    });
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
    DateTime? picked = await showDatePicker(
      initialEntryMode: DatePickerEntryMode.calendarOnly,
      context: context,
      initialDate: DateTime.now(),
      // Default date
      firstDate: DateTime.now(),
      // Disable past dates
      lastDate: DateTime(2101),
      // Maximum selectable date
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
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(4.0),
                color: CommonStyles.dropdownListBgColor,
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
                        CommonStyles.customDialog(
                            context,
                            borderRadius: BorderRadius.circular(2),
                            Container(
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
                                        style:
                                            CommonStyles.txStyF16CbFF6.copyWith(
                                          fontSize: 20,
                                        ),
                                      ),
                                    ],
                                  ),
                                  GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        pruningCheck = !pruningCheck;
                                      });
                                    },
                                    child: Row(
                                      children: [
                                        Checkbox(
                                          value: pruningCheck,
                                          activeColor:
                                              CommonStyles.primaryTextColor,
                                          onChanged: (value) {
                                            setState(() {
                                              pruningCheck = value!;
                                            });
                                          },
                                        ),
                                        const SizedBox(width: 12),
                                        Text('Pruning (ప్రూనింగ్)',
                                            style: CommonStyles.txStyF16CbFF6
                                                .copyWith(
                                                    fontWeight:
                                                        FontWeight.w400)),
                                      ],
                                    ),
                                  ),
                                  GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        harvestingCheck = !harvestingCheck;
                                      });
                                    },
                                    child: Row(
                                      children: [
                                        Checkbox(
                                          value: harvestingCheck,
                                          activeColor:
                                              CommonStyles.primaryTextColor,
                                          onChanged: (value) {
                                            setState(() {
                                              harvestingCheck = value!;
                                            });
                                          },
                                        ),
                                        const SizedBox(width: 12),
                                        Text(
                                          'Harvesting (గెలల కోత)',
                                          // 'Harvesting (data)',
                                          style: CommonStyles.txStyF16CbFF6
                                              .copyWith(
                                                  fontWeight: FontWeight.w400),
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
                                            borderRadius:
                                                BorderRadius.circular(5),
                                          ),
                                        ),
                                        child: const Text(
                                          'CANCEL',
                                          style: TextStyle(
                                              color: CommonStyles
                                                  .primaryTextColor),
                                        ),
                                      ),
                                      ElevatedButton(
                                        onPressed: () {
                                          print(
                                              'Submitted: pruningCheck: $pruningCheck, harvestingCheck: $harvestingCheck');
                                        },
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.white,
                                          shadowColor: Colors.transparent,
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 3.0, horizontal: 10.0),
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(5),
                                          ),
                                        ),
                                        child: const Text(
                                          'SUBMIT',
                                          style: TextStyle(
                                              color: CommonStyles
                                                  .primaryTextColor),
                                        ),
                                      )
                                    ],
                                  )
                                ],
                              ),
                            ));
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
                        child: const Text(
                          'Tap to select',
                          style: CommonStyles.txStyF14CwFF6,
                        ),
                      ),
                    ),
                    /* 
                                      SizedBox(
                                        width: MediaQuery.of(context).size.width,
                                        child: MultiSelectDialogField(
                                          listType: MultiSelectListType.LIST,
                                          dialogHeight: MediaQuery.of(context).size.width / 4.10,
                                          decoration: BoxDecoration(
                                            color: Colors.transparent,
                                            borderRadius:
                          const BorderRadius.all(Radius.circular(5)),
                                            border: Border.all(
                                              color: Colors.white,
                                              width: 2,
                                            ),
                                          ),
                                          title: const Text("Services Types"),
                                          buttonText: Text(
                                            _selectedServiceTypes.isEmpty
                          ? "Tap to select"
                          : _selectedServiceTypes
                              .map((e) => e.desc)
                              .join(', '),
                                            style: CommonStyles.txStyF14CwFF6,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          items: ServiceType_list.map((service) =>
                                              MultiSelectItem<ServiceType>(
                            service, service.desc!)).toList(),
                                          chipDisplay: MultiSelectChipDisplay.none(),
                                          buttonIcon: const Icon(
                                            Icons.keyboard_arrow_down_sharp,
                                            color: Colors.white,
                                          ),
                                          onConfirm: (List<dynamic> selected) {
                                            setState(() {
                                              _selectedDesc = null;
                                              _selectedServiceTypes = selected.cast<ServiceType>();
                                            });
                                            service_id = _selectedServiceTypes
                          .map((e) => e.typeCdId)
                          .where((id) => id != null)
                          .map((id) => id.toString())
                          .join(',');
                                            servicename =
                          _selectedServiceTypes.map((e) => e.desc).join(', ');
                                            if (service_id == "19") {
                                              selectduration_id = _labourRequests[0].typeCdId;
                                              _selectedDesc = _labourRequests[0].desc;
                                            }
                                            fetchlabourservicecost();
                                          },
                                        ),
                                      ),
                                       */

                    const SizedBox(
                      height: 8,
                    ),
                    Visibility(
                      visible: pruningCheck,
                      /*  visible: _selectedServiceTypes
                                            .any((service) => service.typeCdId == 19), */
                      child: Column(
                        children: [
                          const SizedBox(
                            height: 4,
                          ),
                          plotDetailsBox(
                            label: tr(LocaleKeys.pru_amount),
                            data: '${prunningCost ?? 0.0}',
                          ),
                        ],
                      ),
                    ),
                    Visibility(
                      visible: harvestingCheck,
                      /*  visible: _selectedServiceTypes
                                            .any((service) => service.typeCdId == 20), */
                      child: plotDetailsBox(
                        label: tr(LocaleKeys.harv_amount),
                        data: "${harvestCost ?? 0.0}",
                      ),
                    ),

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
                          fillColor:
                              WidgetStateProperty.resolveWith<Color>((states) {
                            if (states.contains(WidgetState.selected)) {
                              return Colors.white;
                            }
                            return Colors
                                .transparent; // Transparent background when unchecked
                          }),
                          side: const BorderSide(
                            color: Colors.black, // Black border when unchecked
                            width: 2, // Border width
                          ),
                        ),
                        //SizedBox(width: 8),
                        Text(
                          tr(LocaleKeys.have_pole),
                          style: CommonStyles.txStyF14CwFF6,
                        ),
                      ],
                    ),
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
                            border: Border.all(color: Colors.white, width: 1.5),
                            borderRadius: BorderRadius.circular(8.0),
                            color: Colors.transparent,
                          ),
                          child: AbsorbPointer(
                            child: SizedBox(
                              height: 55,
                              child: TextFormField(
                                controller: _dateController,
                                style: CommonStyles.txStyF14CwFF6,
                                decoration: const InputDecoration(
                                  hintText: 'Preferred Date',
                                  hintStyle: CommonStyles.txStyF14CwFF6,
                                  contentPadding: EdgeInsets.symmetric(
                                      horizontal: 16.0, vertical: 10.0),
                                  // Adjust padding as needed
                                  suffixIcon: Padding(
                                    padding: EdgeInsets.all(8.0),
                                    child: Icon(
                                      Icons.calendar_today,
                                      // Replace with your desired icon
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
                    // _labourRequests.isEmpty
                    //     ? CircularProgressIndicator() // Show loading indicator while data is being fetched
                    //     :
                    Container(
                      height: 45,
                      padding: const EdgeInsets.only(right: 10),
                      // padding: const EdgeInsets.symmetric(vertical: 15),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                            color: CommonStyles.whiteColor, width: 1.5),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton2<String>(
                          // value: (_selectedServiceTypes.any((service) => service.typeCdId == 20) && !_selectedServiceTypes.any((service) => service.typeCdId == 19))
                          //     ? null // Show hint if 20 is selected
                          //     : _selectedDesc,
                          value: _getSelectedValue(),
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
                          items: _getDropdownItems(),
                          onChanged: (String? newValue) {
                            setState(() {
                              _selectedDesc = newValue;
                              print('_selectedDesc$_selectedDesc');
                              LabourRequest? selectedRequest =
                                  _labourRequests.firstWhere(
                                (request) => request.desc == newValue,
                              );

                              print(
                                  'Selected typeCdId: ${selectedRequest.typeCdId}'); // Print the typeCdId
                              selectduration_id = selectedRequest.typeCdId;
                            });
                          },

                          dropdownStyleData: DropdownStyleData(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(14),
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
                    if (_selectedDesc != null &&
                        (_selectedDesc == _labourRequests[1].desc ||
                            _selectedDesc == _labourRequests[2].desc ||
                            _selectedDesc == _labourRequests[3].desc))
                      Padding(
                        padding: const EdgeInsets.all(0),
                        child: Text(
                          tr(LocaleKeys.text),
                          style: const TextStyle(
                            fontFamily: "hind_semibold",
                            fontWeight: FontWeight.w500,
                            color: Color(0xFF34A350),
                          ),
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
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Checkbox(
                          value: _isagreed,
                          onChanged: (value) {
                            setState(() {
                              _isagreed = value!;
                              showRateChartDialog(context);
                            });
                          },
                          checkColor: Colors.grey,
                          fillColor:
                              WidgetStateProperty.resolveWith<Color>((states) {
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
                          tr(LocaleKeys.i_have_agree),
                          style: CommonStyles.txStyF14CwFF6,
                        ),
                        const SizedBox(
                          width: 4,
                        ),
                        Text(
                          tr(LocaleKeys.terms_conditions),
                          style: CommonStyles.txStyF14CpFF6.copyWith(
                              fontWeight: FontWeight.bold,
                              color: CommonStyles.primaryTextColor2),
                        ),
                      ],
                    ),
                    const SizedBox(
                      height: 8,
                    ),
                    submitBtn(context, tr(LocaleKeys.submit_req)),
                  ],
                ),
              ),
            ),
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

  List<DropdownMenuItem<String>> _getDropdownItems() {
    if (_selectedServiceTypes.any((service) => service.typeCdId == 19) &&
        !_selectedServiceTypes.any((service) => service.typeCdId == 20)) {
      return [_labourRequests[0]]
          .map((request) => DropdownMenuItem<String>(
                value: request.desc,
                child: Text(
                  request.desc,
                  style: const TextStyle(color: Colors.white),
                ),
              ))
          .toList();
    } else {
      return _labourRequests
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
            bool validationSuccess = await isvalidations();
            if (validationSuccess) {
              labourrequestsendbtn();
            }
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

  Future<bool> isvalidations() async {
    bool isValid = true;

    if (_selectedServiceTypes.isEmpty) {
      CommonStyles.showCustomDialog(context, tr(LocaleKeys.multistring));

      return false;
    }
    if (_dateController.text.toString().isEmpty) {
      CommonStyles.showCustomDialog(context, tr(LocaleKeys.date_selectiomn));

      return false;
    }
    if (_selectedDesc!.isEmpty) {
      CommonStyles.showCustomDialog(context, tr(LocaleKeys.valid_pack));

      return false;
    }
    if (_isagreed == false) {
      CommonStyles.showCustomDialog(context, tr(LocaleKeys.terms_agree));
      return false;
    }
    if (service_id.contains('20')) {
      if (harvestCost == 0.0) {
        CommonStyles.showCustomDialog(context,
            "'You can't Raise the Request since Harvesting Amount is 0'");
        return false;
      }
    }

    if (service_id.contains('19')) {
      if (harvestCost == 0.0) {
        CommonStyles.showCustomDialog(context, tr(LocaleKeys.failmsg));
        return false;
      }
    }
    if (service_id.contains('33')) {
      if (pruningWithIntercropCost == 0.0) {
        CommonStyles.showCustomDialog(context, tr(LocaleKeys.failmsg));
        return false;
      }
    }
    if (service_id.contains('34')) {
      if (harvestingWithIntercropCost == 0.0) {
        CommonStyles.showCustomDialog(context, tr(LocaleKeys.failmsg));
        return false;
      }
    }
    return isValid; // Return true if validation is successful, false otherwise
  }

// Function to show the dialog
  void showSuccessDialog(
      BuildContext context, List<MsgModel> msg, String summary) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return SuccessDialog(msg: msg, summary: summary);
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
    print('$url');
    print('url$url');
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

  Future<void> fetchlabourservicecost() async {
    final url = Uri.parse(baseUrl + getLabourServiceCost);
    print('$url');

    final request = {"dateOfPlanting": "${widget.plotdata.dateOfPlanting}"};
    print('object:${json.encode(request)}');

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
        print('response==$responseData');

        if (responseData['result'] != null) {
          var result = responseData['result'];

          // Extract harvestCost and prunningCost
          setState(() {
            harvestCost = result['harvestCost'];
            prunningCost = result['prunningCost'];
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

  Future<void> labourrequestsendbtn() async {
    final url = Uri.parse(baseUrl + addlabourequest);
    print('url==>555: $url');
    setState(() {
      CommonStyles.showHorizontalDotsLoadingDialog(context);
    });
    DateTime cuurentdate = DateTime.now();

    DateFormat inputFormat = DateFormat('dd/MM/yyyy');
    DateFormat outputFormat = DateFormat('yyyy-MM-dd');
    String prefdate = _dateController.text.toString();
    DateTime parsedDate = inputFormat.parse(prefdate); // Parsing the date
    String formattedDate = outputFormat.format(parsedDate);

    String comments = _commentController.text.toString();

    final request = {
      "package": _selectedDesc.toString(),
      "clusterId": Cluster_id,
      "comments": comments,
      "createdDate": "$cuurentdate",
      "durationId": selectduration_id,
      "farmerCode": farmerCode,
      "farmerName": farmerName,
      "harvestingAmount": harvestCost,
      "harvestingWithIntercropAmount": harvestingWithIntercropCost,
      "isFarmerRequest": true,
      "ownPole": _isChecked,
      "palmArea": widget.plotdata.palmArea,
      "plotCode": "${widget.plotdata.plotcode}",
      "plotVillage": "${widget.plotdata.villageName}",
      "preferredDate": formattedDate,
      "pruningAmount": prunningCost,
      "pruningWithIntercropAmount": harvestingWithIntercropCost,
      "serviceTypes": service_id,
      "services": servicename,
      "stateCode": Statecode,
      "stateName": StateName,
      "updatedDate": "$cuurentdate",
      "yearofPlanting": "${widget.plotdata.dateOfPlanting}"
    };
    print('addreqestheader: ${json.encode(request)}');

    try {
      final response = await http.post(
        url,
        body: json.encode(request),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        CommonStyles.hideHorizontalDotsLoadingDialog(context);
        final Map<String, dynamic> responseData = jsonDecode(response.body);
        String prningcost = prunningCost.toString();
        List<MsgModel> displayList = [
          MsgModel(key: tr(LocaleKeys.select_labour_type), value: servicename),
          MsgModel(key: tr(LocaleKeys.pru_amount), value: prningcost),
          MsgModel(key: tr(LocaleKeys.Package), value: _selectedDesc!),
          MsgModel(key: tr(LocaleKeys.starttDate), value: prefdate),
        ];

        showSuccessDialog(context, displayList, tr(LocaleKeys.success_labour));
        print('responseData$responseData');
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
                      child: const Text(
                        'Rate Chart - Terms & Conditions',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white, // Text color
                        ),
                      ),
                    ),

                    //  SizedBox(height: 5),

                    // Table
                    Column(
                      children: [
                        // Static Table Header
                        Table(
                          border: TableBorder.all(color: Colors.orange),
                          columnWidths: const {
                            0: FlexColumnWidth(2),
                            1: FlexColumnWidth(2),
                            2: FlexColumnWidth(2),
                            3: FlexColumnWidth(2),
                            4: FlexColumnWidth(2),
                          },
                          children: [
                            TableRow(
                              //   decoration: BoxDecoration(color: CommonStyles.primaryTextColor),
                              children: [
                                tableHeader('Age'),
                                tableHeader('Pruning Amount/Tree (Rs)'),
                                tableHeader('Harvesting Amount/Ton (Rs)'),
                                tableHeader(
                                    'Pruning with Cocoa Intercrop/Tree (Rs)'),
                                tableHeader(
                                    'Harvesting with Cocoa Intercrop/Ton (Rs)'),
                              ],
                            ),
                          ],
                        ),
                        // Scrollable Table Body
                        SizedBox(
                          height:
                              300, // Set the fixed height for the scrollable part
                          child: SingleChildScrollView(
                            scrollDirection: Axis.vertical,
                            child: Table(
                              border: TableBorder.all(color: Colors.orange),
                              columnWidths: const {
                                0: FlexColumnWidth(2),
                                1: FlexColumnWidth(2),
                                2: FlexColumnWidth(2),
                                3: FlexColumnWidth(2),
                                4: FlexColumnWidth(2),
                              },
                              children: [
                                // Dynamically generated rows for each year based on API data
                                ...generateTableRows(listResult),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),

                    //SizedBox(height: 10),

                    // Terms and conditions text
                    Padding(
                      padding: const EdgeInsets.fromLTRB(
                          5, 5, 5, 5), // Add some padding for better spacing
                      child: Text(
                        tr(LocaleKeys.inter_coco),
                        style: CommonStyles
                            .txSty_14p_f5, // Your defined text style
                      ),
                    ),
                    const SizedBox(height: 10),

                    // Button to dismiss the popup
                    Align(
                      alignment: Alignment.center,
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
                            Navigator.of(context).pop();
                          },
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 0),
                            backgroundColor: Colors.transparent,
                            shadowColor: Colors.transparent,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16.0),
                            ),
                          ),
                          child: Text(
                            tr(LocaleKeys.got_it),
                            style: CommonStyles.txSty_16p_f5,
                          ),
                        ),

                        // CustomBtn(
                        //   label:tr(LocaleKeys.got_it),
                        //   borderColor: CommonStyles.primaryTextColor,
                        //   borderRadius: 12,
                        //   onPressed: () {
                        //     Navigator.of(context).pop(); // Close the dialog
                        //   },
                        //
                        //
                        // ),
                      ),
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

// Step 3: Helper function to generate table rows
  List<TableRow> generateTableRows(List<dynamic> listResult) {
    List<TableRow> rows = [];

    // Loop for each year (c1 to c30 represent the values for years 1 to 30)
    for (int i = 1; i <= 30; i++) {
      rows.add(
        tableRow(
          '$i Years', // Display the current year
          listResult[0]['c$i'].toString(), // Pruning Amount/Tree (Rs)
          listResult[1]['c$i'].toString(), // Harvesting Amount/Ton (Rs)
          listResult[2]['c$i']
              .toString(), // Pruning with Cocoa Intercrop/Tree (Rs)
          listResult[3]['c$i']
              .toString(), // Harvesting with Cocoa Intercrop/Ton (Rs)
        ),
      );
    }

    return rows;
  }

//

// Helper widget for table headers
  Widget tableHeader(String title) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Text(
        title,
        style: CommonStyles.text14orange,
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
        style: CommonStyles.txSty_12b_f5,
        textAlign: TextAlign.center,
      ),
    );
  }
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
          label: tr(LocaleKeys.address),
          data: '${plotdata.clusterName}',
        ),
        plotDetailsBox(
          label: tr(LocaleKeys.yop),
          data: year,
        ),
        plotDetailsBox(
          label: tr(LocaleKeys.intercrops),
          data: year,
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
