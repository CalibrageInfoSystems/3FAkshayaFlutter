import 'dart:convert';
import 'dart:convert';

import 'package:akshaya_flutter/Services/models/LabourRequest.dart';
import 'package:akshaya_flutter/Services/models/Popupmodel.dart';
import 'package:akshaya_flutter/Services/models/ResponseModel.dart';
import 'package:akshaya_flutter/Services/models/ServiceType.dart';
import 'package:akshaya_flutter/Services/product_card_screen.dart';
import 'package:akshaya_flutter/common_utils/SuccessDialog.dart';
import 'package:akshaya_flutter/common_utils/api_config.dart';
import 'package:akshaya_flutter/common_utils/common_styles.dart';
import 'package:akshaya_flutter/common_utils/shared_prefs_keys.dart';
import 'package:akshaya_flutter/localization/locale_keys.dart';
import 'package:akshaya_flutter/models/farmer_model.dart';
import 'package:akshaya_flutter/models/plot_details_model.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:multi_select_flutter/chip_display/multi_select_chip_display.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../common_utils/custom_appbar.dart';
import 'package:multi_select_flutter/util/multi_select_item.dart';
import 'package:multi_select_flutter/util/multi_select_list_type.dart';
import 'package:multi_select_flutter/dialog/multi_select_dialog_field.dart';

class Labourscreen extends StatefulWidget {
  final PlotDetailsModel plotdata;

  Labourscreen({super.key, required this.plotdata});

  @override
  State<Labourscreen> createState() => _LabourscreenScreenState();
}

class _LabourscreenScreenState extends State<Labourscreen> {
  List<ServiceType> ServiceType_list = [];
  List<ResponseModel> ResponseModel_list = [];
  List<ServiceType> _selectedServiceTypes = [];
  late List<dynamic> appointmentsData;
  bool _isChecked = false;
  bool _isagreed = false;
  TextEditingController _dateController = TextEditingController();
  TextEditingController _commentController = TextEditingController();
  List<LabourRequest> _labourRequests = [];
  String? _selectedDesc;
  bool isharvestingamount = false;
  bool ispurningamount = false;
  double? harvestCost;
  double? prunningCost;
  double? pruningWithIntercropCost;
  double? harvestingWithIntercropCost;
  late Future<FarmerModel> farmerData;
  late String farmerCode, farmerName, Statecode, StateName, servicename, service_id;
  late int Cluster_id;
  late int selectduration_id;

  // List<String>? service_id;

  @override
  void initState() {
    // TODO: implement initState
    getspinnerdata(widget.plotdata.plotcode!);
    fetchLabourRequests();
    _fetchData();
    farmerData = getFarmerInfoFromSharedPrefs();

    farmerData.then((farmer) {
      print('farmerData==${farmer.code}');
      farmerCode = '${farmer.code}';
      farmerName = '${farmer.firstName} ${farmer.middleName ?? ''} ${farmer.lastName}';
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
            inputDecorationTheme: InputDecorationTheme(
              enabledBorder: InputBorder.none, // Hide manual entry underline
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _dateController.text = "${picked.day}/${picked.month}/${picked.year}"; // Format the date
      });
    }
  }

  Future<Api_Response> fetchLabourRequests() async {
    var url = baseUrl + getLabourDuration;
    final response = await http.get(
      Uri.parse('$url'),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: tr(LocaleKeys.labour_lable),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            CropPlotDetails(
              plotdata: widget.plotdata,
              index: 0,
              isIconVisible: false,
            ),
            SingleChildScrollView(
                child: Container(
              padding: EdgeInsets.all(10),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(4.0),
                color: Colors.black54,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Row(
                    children: [
                      Text(
                        tr(LocaleKeys.select_labour_type),
                        style: TextStyle(
                          fontSize: 14,
                          fontFamily: "hind_semibold",
                          fontWeight: FontWeight.w500,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(
                        width: 5,
                      ),
                      Icon(
                        Icons.star,
                        size: 8,
                        color: Colors.red,
                      )
                    ],
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Container(
                    width: MediaQuery.of(context).size.width,
                    // height: 50,
                    child: MultiSelectDialogField(
                      listType: MultiSelectListType.LIST,
                      dialogHeight: MediaQuery.of(context).size.width / 4.10,
                      decoration: BoxDecoration(
                        color: Colors.transparent,
                        borderRadius: BorderRadius.all(Radius.circular(5)),
                        border: Border.all(
                          color: Colors.white,
                          width: 2,
                        ),
                      ),
                      title: Text("Services Types"),
                      buttonText: Text(
                        _selectedServiceTypes.isEmpty ? "Tap to select" : _selectedServiceTypes.map((e) => e.desc).join(', '),
                        style: TextStyle(
                          fontSize: 14,
                          fontFamily: "hind_semibold",
                          fontWeight: FontWeight.w500,
                          color: Colors.white,
                        ),
                        overflow: TextOverflow.ellipsis, // To handle long text
                      ),
                      items: ServiceType_list.map((service) => MultiSelectItem<ServiceType>(service, service.desc!)).toList(),
                      chipDisplay: MultiSelectChipDisplay.none(),
                      buttonIcon: Icon(
                        Icons.keyboard_arrow_down_sharp, // Replace with your desired icon
                        color: Colors.white,
                      ),
                      // This hides the chips below the field
                      onConfirm: (List<dynamic> selected) {
                        setState(() {
                          _selectedDesc = null;
                          _selectedServiceTypes = selected.cast<ServiceType>();
                        });
                        service_id = _selectedServiceTypes
                            .map((e) => e.typeCdId)
                            .where((id) => id != null) // Remove null values
                            .map((id) => id.toString()) // Convert each id to a string
                            .join(',');
                        servicename = _selectedServiceTypes.map((e) => e.desc).join(', ');
                        if (service_id == "19") {
                          selectduration_id = _labourRequests[0].typeCdId;
                          _selectedDesc = _labourRequests[0].desc;
                          print('selectduration_id$selectduration_id');
                        }
                        fetchlabourservicecost();
                      },
                    ),
                  ),
                  SizedBox(
                    height: 8,
                  ),
                  Visibility(
                    visible: _selectedServiceTypes.any((service) => service.typeCdId == 20),
                    child: plotDetailsBox(
                      label: tr(LocaleKeys.harv_amount),
                      data: "${harvestCost ?? 0.0}",
                    ),
                  ),
                  SizedBox(
                    height: 4,
                  ),
                  Visibility(
                    visible: _selectedServiceTypes.any((service) => service.typeCdId == 19),
                    child: plotDetailsBox(
                      label: tr(LocaleKeys.pru_amount),
                      data: '${prunningCost ?? 0.0}',
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
                        // Grey tick mark color
                        fillColor: MaterialStateProperty.resolveWith<Color>((states) {
                          if (states.contains(MaterialState.selected)) {
                            return Colors.white; // White background when checked
                          }
                          return Colors.transparent; // Transparent background when unchecked
                        }),
                        side: BorderSide(
                          color: Colors.black, // Black border when unchecked
                          width: 2, // Border width
                        ),
                      ),
                      //SizedBox(width: 8),
                      Text(
                        tr(LocaleKeys.have_pole),
                        style: TextStyle(
                          fontSize: 14,
                          fontFamily: "hind_semibold",
                          fontWeight: FontWeight.w500,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Text(
                        tr(LocaleKeys.startDate),
                        style: TextStyle(
                          fontSize: 14,
                          fontFamily: "hind_semibold",
                          fontWeight: FontWeight.w500,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(
                        width: 5,
                      ),
                      Icon(
                        Icons.star,
                        size: 8,
                        color: Colors.red,
                      )
                    ],
                  ),
                  Container(
                    height: 55,
                    padding: EdgeInsets.only(left: 0, top: 10.0, right: 0),
                    child: GestureDetector(
                      onTap: () async {
                        _selectDate(context);
                      },
                      child: Container(
                        height: 55,
                        width: MediaQuery.of(context).size.width,
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.white, width: 1.5),
                          borderRadius: BorderRadius.circular(5.0),
                          color: Colors.transparent, // Add white background color
                        ),
                        child: AbsorbPointer(
                          child: SizedBox(
                            height: 55,
                            child: TextFormField(
                              controller: _dateController,
                              style: TextStyle(fontFamily: 'Calibri', fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white),
                              decoration: InputDecoration(
                                hintText: 'Preferred Date',
                                hintStyle: TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  fontFamily: 'Calibri',
                                ),
                                contentPadding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
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
                  SizedBox(
                    height: 8,
                  ),
                  Row(
                    children: [
                      Text(
                        tr(LocaleKeys.labour_duration),
                        style: TextStyle(
                          fontSize: 14,
                          fontFamily: "hind_semibold",
                          fontWeight: FontWeight.w500,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(
                        width: 5,
                      ),
                      Icon(
                        Icons.star,
                        size: 8,
                        color: Colors.red,
                      )
                    ],
                  ),
                  SizedBox(
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
                      border: Border.all(color: CommonStyles.whiteColor, width: 1.5),
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
                        hint: Text(
                          'Select',
                          style: TextStyle(color: Colors.white),
                        ),
                        // items: _labourRequests
                        //     .asMap()
                        //     .entries
                        //     .map((entry) {
                        //       int index = entry.key;
                        //       LabourRequest request = entry.value;
                        //
                        //       // If service ID 19 is selected, only show the first item (index == 0)
                        //       if (_selectedServiceTypes.any((service) => service.typeCdId == 19) && !_selectedServiceTypes.any((service) => service.typeCdId == 20)) {
                        //         if (index == 0) {
                        //           if (_selectedDesc == null) {
                        //             // Set the default selection to the first item's description
                        //             _selectedDesc = request.desc;
                        //           }
                        //           return DropdownMenuItem<String>(
                        //             value: request.desc,
                        //             child: Text(
                        //               request.desc,
                        //               style: TextStyle(color: Colors.white),
                        //             ),
                        //           );
                        //         }
                        //       }
                        //       // If service ID 20 is selected, show all items
                        //       else if (_selectedServiceTypes.any((service) => service.typeCdId == 20) && !_selectedServiceTypes.any((service) => service.typeCdId == 19)) {
                        //         return DropdownMenuItem<String>(
                        //           value: request.desc,
                        //           child: Text(
                        //             request.desc,
                        //             style: TextStyle(color: Colors.white),
                        //           ),
                        //         );
                        //       }
                        //       // If both 19 and 20 are selected, show all items
                        //       else if (_selectedServiceTypes.any((service) => service.typeCdId == 19) && _selectedServiceTypes.any((service) => service.typeCdId == 20)) {
                        //         return DropdownMenuItem<String>(
                        //           value: request.desc,
                        //           child: Text(
                        //             request.desc,
                        //             style: TextStyle(color: Colors.white),
                        //           ),
                        //         );
                        //       }
                        //       return null; // Return null for items that shouldn't be shown
                        //     })
                        //     .where((item) => item != null) // Filter out null items
                        //     .cast<DropdownMenuItem<String>>() // Cast to non-nullable type
                        //     .toList(),
                        items: _getDropdownItems(),
                        onChanged: (String? newValue) {
                          setState(() {
                            _selectedDesc = newValue;
                            print('_selectedDesc$_selectedDesc');
                            LabourRequest? selectedRequest = _labourRequests.firstWhere(
                              (request) => request.desc == newValue,
                              orElse: () => null!,
                            );

                            if (selectedRequest != null) {
                              print('Selected typeCdId: ${selectedRequest.typeCdId}'); // Print the typeCdId
                              selectduration_id = selectedRequest.typeCdId;
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
                  ),
                  // DropdownButtonFormField<String>(
                  //
                  //         value: (_selectedServiceTypes.any((service) => service.typeCdId == 20) && !_selectedServiceTypes.any((service) => service.typeCdId == 19))
                  //             ? null // Show hint if 20 is selected
                  //             : _selectedDesc,
                  //         icon: Icon(Icons.arrow_drop_down, color: Colors.white),
                  //         decoration: InputDecoration(
                  //           enabledBorder: OutlineInputBorder(
                  //             borderSide: BorderSide(color: Colors.white,width: 1.5),
                  //             borderRadius: BorderRadius.circular(8),
                  //           ),
                  //           focusedBorder: OutlineInputBorder(
                  //             borderSide: BorderSide(color: Colors.white,width: 1.5),
                  //
                  //             borderRadius: BorderRadius.circular(8),
                  //           ),
                  //         ),
                  //         dropdownColor: Colors.grey[800],
                  //   isExpanded: true,
                  //         items: _labourRequests
                  //             .asMap()
                  //             .entries
                  //             .map((entry) {
                  //               int index = entry.key;
                  //               LabourRequest request = entry.value;
                  //
                  //               // If service ID 19 is selected, only show the first item (index == 0)
                  //               if (_selectedServiceTypes.any((service) => service.typeCdId == 19) && !_selectedServiceTypes.any((service) => service.typeCdId == 20)) {
                  //                 if (index == 0) {
                  //                   if (_selectedDesc == null) {
                  //                     // Set the default selection to the first item's description
                  //                     _selectedDesc = request.desc;
                  //                   }
                  //                   return DropdownMenuItem<String>(
                  //                     value: request.desc,
                  //                     child: Text(
                  //                       request.desc,
                  //                       style: TextStyle(color: Colors.white),
                  //                     ),
                  //                   );
                  //                 }
                  //               }
                  //               // If service ID 20 is selected, show all items
                  //               else if (_selectedServiceTypes.any((service) => service.typeCdId == 20) && !_selectedServiceTypes.any((service) => service.typeCdId == 19)) {
                  //                 return DropdownMenuItem<String>(
                  //                   value: request.desc,
                  //                   child: Text(
                  //                     request.desc,
                  //                     style: TextStyle(color: Colors.white),
                  //                   ),
                  //                 );
                  //               }
                  //               // If both 19 and 20 are selected, show all items
                  //               else if (_selectedServiceTypes.any((service) => service.typeCdId == 19) && _selectedServiceTypes.any((service) => service.typeCdId == 20)) {
                  //                 return DropdownMenuItem<String>(
                  //                   value: request.desc,
                  //                   child: Text(
                  //                     request.desc,
                  //                     style: TextStyle(color: Colors.white),
                  //                   ),
                  //                 );
                  //               }
                  //               return null; // Return null for items that shouldn't be shown
                  //             })
                  //             .where((item) => item != null) // Filter out null items
                  //             .cast<DropdownMenuItem<String>>() // Cast to non-nullable type
                  //             .toList(),
                  //         onChanged: (String? newValue) {
                  //           setState(() {
                  //             _selectedDesc = newValue;
                  //             print('_selectedDesc$_selectedDesc');
                  //             LabourRequest? selectedRequest = _labourRequests.firstWhere(
                  //               (request) => request.desc == newValue,
                  //               orElse: () => null!,
                  //             );
                  //
                  //             if (selectedRequest != null) {
                  //               print('Selected typeCdId: ${selectedRequest.typeCdId}'); // Print the typeCdId
                  //               selectduration_id = selectedRequest.typeCdId;
                  //             }
                  //           });
                  //         },
                  //         hint: Text(
                  //           'Select',
                  //           style: TextStyle(color: Colors.white),
                  //         ),
                  //       )),
                  SizedBox(
                    height: 2,
                  ),
                  if (_selectedDesc != null && (_selectedDesc == _labourRequests[1].desc || _selectedDesc == _labourRequests[2].desc || _selectedDesc == _labourRequests[3].desc))
                    Padding(
                      padding: EdgeInsets.all(0),
                      child: Text(
                        tr(LocaleKeys.text),
                        style: TextStyle(
                          fontFamily: "hind_semibold",
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF34A350),
                        ),
                      ),
                    ),
                  SizedBox(
                    height: 8,
                  ),
                  Row(
                    children: [
                      Text(
                        tr(LocaleKeys.comments),
                        style: TextStyle(
                          fontSize: 14,
                          fontFamily: "hind_semibold",
                          fontWeight: FontWeight.w500,
                          color: Colors.white,
                        ),
                      ),
                      // SizedBox(width: 5,),
                      // Icon(Icons.star,size: 8,color: Colors.red,)
                    ],
                  ),
                  SizedBox(
                    height: 4,
                  ),
                  Container(
                    height: 50,
                    padding: const EdgeInsets.all(0.0),
                    child: TextFormField(
                      controller: _commentController,
                      decoration: InputDecoration(
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.white, width: 1.5), // White border
                          borderRadius: BorderRadius.circular(8),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.white, width: 1.5), // White border on focus
                          borderRadius: BorderRadius.circular(8),
                        ),
                        hintText: 'comments',
                        hintStyle: TextStyle(color: Colors.white), // White hint text color
                      ),
                      style: TextStyle(color: Colors.white), // White input text color
                      // inputFormatters: [
                      //   FilteringTextInputFormatter.allow(RegExp("[a-zA-Z ]")), // Allow only letters and spaces
                      // ],
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
//Showalertdialog(context);
//                             showDialog(
//                               context: context,
//                               builder: (context) => TermsConditionsPopup(),
//                             );
                          });
                        },
                        checkColor: Colors.grey,
                        // Grey tick mark color
                        fillColor: MaterialStateProperty.resolveWith<Color>((states) {
                          if (states.contains(MaterialState.selected)) {
                            return Colors.white; // White background when checked
                          }
                          return Colors.transparent; // Transparent background when unchecked
                        }),
                        side: BorderSide(
                          color: Colors.black, // Black border when unchecked
                          width: 2, // Border width
                        ),
                      ),
                      //SizedBox(width: 8),
                      Text(
                        tr(LocaleKeys.i_have_agree),
                        style: TextStyle(
                          fontSize: 14,
                          fontFamily: "hind_semibold",
                          fontWeight: FontWeight.w500,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(
                        width: 4,
                      ),

                      Text(
                        tr(LocaleKeys.terms_conditions),
                        style: TextStyle(
                          fontSize: 14,
                          fontFamily: "hind_semibold",
                          fontWeight: FontWeight.w500,
                          color: CommonStyles.primaryTextColor,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 8,
                  ),
                  submitBtn(context, tr(LocaleKeys.submit_req)),
                ],
              ),
            )),
          ],
        ),
      ),
    );
  }

  String? _getSelectedValue() {
    if (_selectedServiceTypes.any((service) => service.typeCdId == 19) && !_selectedServiceTypes.any((service) => service.typeCdId == 20)) {
      return _labourRequests.isNotEmpty ? _labourRequests[0].desc : null;
    } else if (_selectedServiceTypes.any((service) => service.typeCdId == 20)) {
      return _selectedDesc;
    } else {
      return null;
    }
  }

  List<DropdownMenuItem<String>> _getDropdownItems() {
    if (_selectedServiceTypes.any((service) => service.typeCdId == 19) && !_selectedServiceTypes.any((service) => service.typeCdId == 20)) {
      return [_labourRequests[0]]
          .map((request) => DropdownMenuItem<String>(
                value: request.desc,
                child: Text(
                  request.desc,
                  style: TextStyle(color: Colors.white),
                ),
              ))
          .toList();
    } else {
      return _labourRequests
          .map((request) => DropdownMenuItem<String>(
                value: request.desc,
                child: Text(
                  request.desc,
                  style: TextStyle(color: Colors.white),
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
        padding: EdgeInsets.only(left: 10, right: 10),
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
            padding: const EdgeInsets.symmetric(vertical: 0),
            backgroundColor: Colors.transparent,
            shadowColor: Colors.transparent,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16.0),
            ),
          ),
          child: Text(
            language,
            style: CommonStyles.txSty_16p_f5,
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
        CommonStyles.showCustomDialog(context, "'You can't Raise the Request since Harvesting Amount is 0'");
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
  void showSuccessDialog(BuildContext context, List<MsgModel> msg, String summary) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return SuccessDialog(msg: msg, summary: summary);
      },
    );
  }

  Widget plotDetailsBox({required String label, required String data, Color? dataTextColor}) {
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
            Expanded(
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
            ServiceType_list = appointmentsData.map((appointment) => ServiceType.fromJson(appointment)).toList();
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
    return null;
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
      "package": "${_selectedDesc.toString()}",
      "clusterId": Cluster_id,
      "comments": "$comments",
      "createdDate": "$cuurentdate",
      "durationId": selectduration_id,
      "farmerCode": "$farmerCode",
      "farmerName": "$farmerName",
      "harvestingAmount": harvestCost,
      "harvestingWithIntercropAmount": harvestingWithIntercropCost,
      "isFarmerRequest": true,
      "ownPole": _isChecked,
      "palmArea": widget.plotdata.palmArea,
      "plotCode": "${widget.plotdata.plotcode}",
      "plotVillage": "${widget.plotdata.villageName}",
      "preferredDate": "$formattedDate",
      "pruningAmount": prunningCost,
      "pruningWithIntercropAmount": harvestingWithIntercropCost,
      "serviceTypes": "$service_id",
      "services": "$servicename",
      "stateCode": "$Statecode",
      "stateName": "$StateName",
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
        print('Request was not successful. Status code: ${response.statusCode}');
        CommonStyles.hideHorizontalDotsLoadingDialog(context);
      }
    } catch (e) {
      print('Error: $e');
      CommonStyles.hideHorizontalDotsLoadingDialog(context);
    }
  }
}

class CropPlotDetails extends StatelessWidget {
  final PlotDetailsModel plotdata;
  final int index;
  final void Function()? onTap;
  final bool isIconVisible;

  const CropPlotDetails({super.key, required this.plotdata, required this.index, this.onTap, this.isIconVisible = true});

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
      padding: const EdgeInsets.all(8),
      margin: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
          // border:
          //     Border.all(color: CommonStyles.primaryTextColor, width: 0.3),
          borderRadius: BorderRadius.circular(10),
          color: index % 2 == 0 ? Colors.transparent : Colors.grey.shade200),
      child: Stack(
        children: [plotCard(df, year), if (isIconVisible) const Positioned(top: 0, bottom: 0, right: 0, child: Icon(Icons.arrow_forward_ios_rounded))],
      ),
    );
  }

  Column plotCard(NumberFormat df, String year) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        plotDetailsBox(label: tr(LocaleKeys.plot_code), data: '${plotdata.plotcode}', dataTextColor: CommonStyles.primaryTextColor),
        plotDetailsBox(
          label: tr(LocaleKeys.plot_size),
          data: '${df.format(plotdata.palmArea)} Ha (${df.format(plotdata.palmArea! * 2.5)} Acre)',
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

  Widget plotDetailsBox({required String label, required String data, Color? dataTextColor}) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
                flex: 5,
                child: Text(
                  label,
                  style: CommonStyles.txSty_14b_f5,
                )),
            Expanded(
                flex: 6,
                child: Text(
                  data,
                  style: CommonStyles.txF14Fw5Cb.copyWith(
                    color: dataTextColor,
                  ),
                )),
          ],
        ),
        const SizedBox(height: 5),
      ],
    );
  }
}

class TermsConditionsPopup extends StatefulWidget {
  const TermsConditionsPopup({Key? key}) : super(key: key);

  @override
  State<TermsConditionsPopup> createState() => _TermsConditionsPopupState();
}

class _TermsConditionsPopupState extends State<TermsConditionsPopup> {
  List<Popup> popuplist = [];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    fetchpopup();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      child: Container(
        width: 350,
        height: MediaQuery.of(context).size.height,
        padding: EdgeInsets.all(0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              color: Colors.orange,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: const Text(
                      'Terms & Conditions',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  // Visibility Toggle for Close Button (if needed)
                  // IconButton(
                  //   icon: const Icon(Icons.close, color: Colors.white),
                  //   onPressed: () => Navigator.of(context).pop(),
                  // ),
                ],
              ),
            ),
            Container(
              padding: EdgeInsets.only(top: 2.0, bottom: 5),
              child: Table(
                border: TableBorder(
                  bottom: BorderSide(color: Colors.grey),
                  verticalInside: BorderSide(color: Colors.grey),
                ),
                columnWidths: {
                  0: FlexColumnWidth(1),
                  1: FixedColumnWidth(1),
                  2: FlexColumnWidth(1),
                  3: FixedColumnWidth(1),
                  4: FlexColumnWidth(1),
                  5: FixedColumnWidth(1),
                  6: FlexColumnWidth(1),
                  7: FixedColumnWidth(1),
                  8: FlexColumnWidth(1),
                },
                defaultVerticalAlignment: TableCellVerticalAlignment.middle,
                children: [
                  TableRow(
                    children: [
                      TableCell(
                        child: Container(
                          width: MediaQuery.of(context).size.width,
                          padding: EdgeInsets.only(left: 5, right: 5),
                          child: Center(
                            child: Text(
                              'Age',
                              style: TextStyle(fontSize: 14),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                      ),
                      Container(),
                      TableCell(
                        child: Container(
                          width: MediaQuery.of(context).size.width,
                          padding: EdgeInsets.only(left: 5, right: 5),
                          child: Center(
                            child: Text(
                              'Pruning Amount/ Tree (Rs)',
                              style: TextStyle(fontSize: 14),
                            ),
                          ),
                        ),
                      ),
                      Container(),
                      TableCell(
                        child: Container(
                          width: MediaQuery.of(context).size.width,
                          padding: EdgeInsets.only(left: 5, right: 5),
                          child: Center(
                            child: Text(
                              'Harvesting Amount/ Ton (Rs)',
                              style: TextStyle(fontSize: 14),
                            ),
                          ),
                        ),
                      ),
                      Container(),
                      TableCell(
                        child: Container(
                          width: MediaQuery.of(context).size.width,
                          padding: EdgeInsets.only(left: 5, right: 5),
                          child: Center(
                            child: Text(
                              'Pruning with Cocoa Intercrop Amount/ Tree (Rs)',
                              style: TextStyle(fontSize: 14),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                      ),
                      Container(),
                      TableCell(
                        child: Container(
                          width: MediaQuery.of(context).size.width,
                          padding: EdgeInsets.only(left: 5, right: 5),
                          child: Center(
                            child: Text(
                              'Harvesting With Cocoa Intercrop Amount/ Ton (Rs)',
                              style: TextStyle(fontSize: 14),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  TableRow(children: [
                    TableCell(child: Text("1.")),
                    TableCell(child: Text("Krishna Karki")),
                    TableCell(child: Text("Nepal, Kathmandu")),
                    TableCell(child: Text("Nepal"))
                  ]),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: ElevatedButton(
                onPressed: () => Navigator.of(context).pop(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                ),
                child: const Text('Got It'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Widget _buildServiceCostTable() {
  //   List<TableRow> rows = [];
  //
  //   // Iterate over each service in the popuplist and add a row for each
  //   for (var service in popuplist) {
  //     List<Widget> cells = [];
  //
  //     // Add the Age column which will display the description of the service
  //     // cells.add(_buildTableCell(service.desc));
  //
  //     // Add the space between columns
  //     cells.add(Container());
  //
  //     // Add values for c1 to c30 dynamically
  //     for (int i = 1; i <= 30; i++) {
  //       String costKey = 'c$i';
  //       double costValue = service.toJson()[costKey] ?? 0.0;
  //
  //       cells.add(_buildTableCell(costValue.toString()));
  //       cells.add(Container()); // space column
  //     }
  //
  //     // Add the row to the table
  //     rows.add(TableRow(children: cells));
  //   }
  //
  //   return Table(
  //     border: TableBorder(
  //       bottom: BorderSide(color: Colors.grey),
  //       verticalInside: BorderSide(color: Colors.grey),
  //     ),
  //     columnWidths: {
  //       0: FlexColumnWidth(1),
  //       1: FixedColumnWidth(1),
  //       2: FlexColumnWidth(1),
  //       3: FixedColumnWidth(1),
  //       4: FlexColumnWidth(1),
  //       5: FixedColumnWidth(1),
  //       6: FlexColumnWidth(1),
  //       7: FixedColumnWidth(1),
  //       8: FlexColumnWidth(1),
  //     },
  //     defaultVerticalAlignment: TableCellVerticalAlignment.middle,
  //     children: rows,
  //   );
  // }

  Widget _buildTableCell(String text) {
    return Container(
      padding: EdgeInsets.all(8),
      child: Text(
        text,
        style: TextStyle(fontSize: 12),
        textAlign: TextAlign.center,
      ),
    );
  }

  Future<void> fetchpopup() async {
    final url = Uri.parse(baseUrl + getlabourservicecost);
    print('$url');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);
        print('response==$responseData');
        if (responseData['listResult'] != null) {
          setState(() {
            popuplist = (responseData['listResult'] as List).map((appointment) => Popup.fromJson(appointment)).toList();
          });
        } else {
          print('Failed to show Farmer plot details list');
        }
      } else {
        throw Exception('Failed to show Farmer plot details list');
      }
    } catch (error) {
      throw Exception('Failed to connect to the API $error');
    }
  }
}
