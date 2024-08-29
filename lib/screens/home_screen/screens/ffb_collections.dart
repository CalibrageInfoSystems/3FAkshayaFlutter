/* import 'dart:convert';
import 'package:akshaya_flutter/common_utils/api_config.dart';
import 'package:akshaya_flutter/common_utils/common_styles.dart';
import 'package:akshaya_flutter/gen/assets.gen.dart';
import 'package:akshaya_flutter/localization/locale_keys.dart';
import 'package:akshaya_flutter/models/CollectionReceipt.dart';
import 'package:akshaya_flutter/models/collection_data_model.dart';
import 'package:akshaya_flutter/models/farmer_model.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class FfbCollectionScreenXXXX extends StatefulWidget {
  const FfbCollectionScreenXXXX({super.key});

  @override
  State<FfbCollectionScreenXXXX> createState() =>
      _FfbCollectionScreenXXXXState();
}

class _FfbCollectionScreenXXXXState extends State<FfbCollectionScreenXXXX> {
  String? selectedValue,
      startDateString,
      fc,
      endDateString,
      totalcollections,
      totalnetweight,
      unpaidcollections,
      paidcollections,
      financialYearFrom,
      financialYearTo,
      fromDateStr,
      formattedDate,
      toDateStr,
      datefromapi,
      weightfromapi,
      nodata,
      u_colnidtext;
  List<dynamic> dropdownItems = [];
  String fromFormattedDate = ''; // Declare fromFormattedDate
  String toFormattedDate = '';
  int? selectedPosition;
  FarmerModel? catagoriesList;
  bool isInfoVisible = false; // Initially, set it to false
  bool datesavaiablity = false;
  bool nodatavisibility = false;
  TextEditingController fromDateController = TextEditingController();
  TextEditingController toDateController = TextEditingController();
  DateTime? fromDate;
  DateTime? toDate;
  bool isLoading = false;
  List<Collection> collectionlist = [];
  List<CollectionReceipt> collectionreceiptlist = [];
  String? userId;
  String dropdownValue = 'Last 30 days';

  @override
  void initState() {
    super.initState();
    listofdetails();
  }

  String formatDate(String inputDate) {
    final originalFormat = DateFormat("yyyy-MM-dd'T'HH:mm:ss");
    final desiredFormat = DateFormat("dd/MM/yyyy");

    DateTime date = originalFormat.parse(inputDate);
    String formattedDate = desiredFormat.format(date);

    return formattedDate;
  }

  listofdetails() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      userId = prefs.getString('user_id');
      print('FarmerCode -==$userId');
      selectedPosition = 0;
      callApiMethod(selectedPosition!);
    });
  }

  String formatDateToApi(DateTime date) {
    final DateFormat apiDateFormat = DateFormat('yyyy-MM-dd');
    return apiDateFormat.format(date);
  }

  Future<void> _selectDate(
      BuildContext context, TextEditingController controller) async {
    DateTime initialDate = DateTime.now(); // Default value

    if (controller == fromDateController && fromDate != null) {
      initialDate = fromDate!;
    } else if (controller == toDateController && toDate != null) {
      initialDate = toDate!;
    }

    final DateTime? selectedDate = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(1900), // Adjust the starting date as needed
      lastDate: DateTime.now(), // Restrict future dates
    );

    if (selectedDate != null) {
      // Remove the time portion from the selected date
      final DateTime dateWithoutTime = DateTime(
        selectedDate.year,
        selectedDate.month,
        selectedDate.day,
      );

      final DateFormat dateFormat = DateFormat('dd/MM/yyyy');
      final formattedDate = dateFormat.format(dateWithoutTime);

      setState(() {
        if (controller == fromDateController) {
          fromDate = dateWithoutTime;
          fromFormattedDate =
              formattedDate; // Store the formatted date for fromDate
          String formattedDateForApi =
              formatDateToApi(dateWithoutTime); // Format for API
          print(
              '--$fromFormattedDate'); // Print the formatted date for fromDate
          print('--$formattedDateForApi'); // Print the formatted date for API
        } else {
          toDate = dateWithoutTime;
          toFormattedDate =
              formattedDate; // Store the formatted date for toDate
          String formattedDateForApi =
              formatDateToApi(dateWithoutTime); // Format for API
          print('--$toFormattedDate'); // Print the formatted date for toDate
          print('--$formattedDateForApi'); // Print the formatted date for API
        }

        controller.text =
            formattedDate; // Format and set the selected date as a string
      });
    }
  }

  Future<void> callApiMethod(int position) async {
    // Implement your API call logic here
    setState(() {
      datesavaiablity = false;
      isInfoVisible = false;
      isLoading = true;
    });
    if (position == 0) {
      collectionlist.clear();

      setState(() {
        datesavaiablity = false;
        isInfoVisible = true;
      });

      // Calculate the date range for the "Last 30 Days" option
      DateTime currentDate = DateTime.now();
      print('currentDate: $currentDate');
      DateTime startDate = currentDate.subtract(const Duration(days: 30));
      DateFormat dateFormat = DateFormat('yyyy-MM-dd');
      startDateString = dateFormat.format(startDate);
      endDateString = dateFormat.format(currentDate);
      print('Start Date: $startDateString');
      print('End Date: $endDateString');

      get30days();
      isLoading = false;
      isInfoVisible = false;
      nodatavisibility = true;
    } else if (position == 1) {
      collectionlist.clear();

      nodatavisibility = false;
      setState(() {
        datesavaiablity = false;
        isInfoVisible = true;
      });

      // Handle other dropdown positions
      DateTime currentDate = DateTime.now();
      int currentYear = currentDate.year;
      int currentMonth = currentDate.month;

      print('currentYear: $currentYear');
      print('currentMonth: $currentMonth');
      if (currentMonth < 4) {
        financialYearFrom = '${currentYear - 1}-04-01';
        financialYearTo = '$currentYear-03-31';
      } else {
        financialYearFrom = '$currentYear-04-01';
        financialYearTo = '${currentYear + 1}-03-31';
      }
      print('financialYearFrom: $financialYearFrom');
      print('financialYearTo: $financialYearTo');

      getfinancialyear();
      isLoading = false;
    } else if (position == 2) {
      collectionlist.clear();
      nodatavisibility = false;
      isInfoVisible = false;
      datesavaiablity = true;
      isLoading = false;
      await getcustomcollections();

      setState(() {
        isInfoVisible = true;
        datesavaiablity = true;
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          titleSpacing: 0.0,
          title: Text(
            tr(LocaleKeys.collection),
            style: CommonStyles.text16white,
          ),
          leading: IconButton(
            icon: Image.asset('assets/images/ic_left.png'),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
          elevation: 0,
          actions: [
            IconButton(
              icon: Image.asset(Assets.images.icHome.path),
              onPressed: () {},
            ),
          ],
          flexibleSpace: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                stops: [1.0, 0.4],
                colors: [Color(0xFFDB5D4B), Color(0xFFE39A63)],
              ),
            ),
          ),
        ),
        body: isLoading
            ? const Center(
                child: CircularProgressIndicator(),
              )
            : Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    stops: [0.0126, 0.244, 0.4444, 0.2],
                    colors: [
                      Color(0xFFDB5D4B),
                      Color(0xFFE39A63),
                      Color(0xFFE39A63),
                      Color(0x0fffffff)
                    ],
                  ),
                ),
                child: Column(
                  children: [
                    SizedBox(
                      width: double.infinity,
                      child: Container(
                        alignment: Alignment.topCenter,
                        padding: const EdgeInsets.only(
                            top: 20.0, left: 12.0, right: 12.0),
                        child: DropdownButtonHideUnderline(
                          child: ButtonTheme(
                            alignedDropdown: true,
                            child: Container(
                                width: double.infinity,
                                decoration: BoxDecoration(
                                  border: Border.all(
                                      color: Colors.white, width: 1.0),
                                  borderRadius: BorderRadius.circular(6.0),
                                ),
                                child: DropdownButton<int>(
                                    alignment: Alignment.centerRight,
                                    value: selectedPosition ?? 0,
                                    icon: Image.asset(
                                      Assets.images.arrowDown.path,
                                      width: 20.0,
                                      height: 20.0,
                                    ),
                                    style: const TextStyle(
                                      color: Colors.black,
                                    ),
                                    onChanged: (position) {
                                      setState(() {
                                        selectedPosition = position;
                                        print(
                                            'selectedPosition $selectedPosition');
                                      });

                                      // Now, call your API method based on the selected position
                                      callApiMethod(selectedPosition!);
                                    },
                                    items: [
                                      DropdownMenuItem<int>(
                                        value: 0,
                                        child: Align(
                                          alignment: Alignment.center,
                                          child: Text(
                                            tr(LocaleKeys.thirty_days),
                                            style: CommonStyles.text16white,
                                          ),
                                        ),
                                      ),
                                      DropdownMenuItem<int>(
                                        value: 1,
                                        child: Align(
                                          alignment: Alignment.center,
                                          child: Text(
                                            tr(LocaleKeys.currentfinicial),
                                            style: CommonStyles.text16white,
                                          ),
                                        ),
                                      ),
                                      DropdownMenuItem<int>(
                                        value: 2,
                                        child: Align(
                                          alignment: Alignment.center,
                                          child: Text(
                                            tr(LocaleKeys.selected),
                                            style: CommonStyles.text16white,
                                          ),
                                        ),
                                      ),
                                    ],
                                    dropdownColor: const Color(
                                        0x8D000000) // Set the dropdown background color to grey
                                    )),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 10.0,
                    ),
                    isLoading
                        ? const Center(
                            child: CircularProgressIndicator(),
                          )
                        : Visibility(
                            visible: datesavaiablity,
                            child: Padding(
                              padding: const EdgeInsets.only(
                                  top: 4.0, left: 12.0, right: 12.0),
                              child: Column(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.only(
                                        top: 10.0,
                                        left: 12.0,
                                        right: 12.0,
                                        bottom: 10.0),
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                          color: Colors.white, width: 1.0),
                                      borderRadius: BorderRadius.circular(6.0),
                                    ),
                                    child: Flex(
                                      direction: Axis.horizontal,
                                      children: [
                                        Flexible(
                                          flex: 1,
                                          child: GestureDetector(
                                            onTap: () {
                                              print('clickedonfromdate');
                                              _selectDate(
                                                  context, fromDateController);
                                              // Handle From Date tap
                                            },
                                            child: TextField(
                                              controller: fromDateController,
                                              decoration: const InputDecoration(
                                                hintText: 'From Date',
                                                hintStyle: TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.black54,
                                                ),
                                                enabled: false,
                                              ),
                                              style: const TextStyle(
                                                  color: Colors.white),
                                            ),
                                          ),
                                        ),
                                        Flexible(
                                          flex: 1,
                                          child: GestureDetector(
                                            onTap: () {
                                              // Handle To Date tap
                                              print('clickedontodate');
                                              _selectDate(
                                                  context, toDateController);
                                            },
                                            child: TextField(
                                              controller: toDateController,
                                              decoration: const InputDecoration(
                                                hintText: 'To Date',
                                                hintStyle: TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.black54,
                                                ),
                                                enabled: false,
                                              ),
                                              style: const TextStyle(
                                                  color: Colors.white),
                                            ),
                                          ),
                                        ),
                                        Container(
                                          decoration: BoxDecoration(
                                            gradient: const LinearGradient(
                                              colors: [
                                                Color(0xFFCCCCCC),
                                                Color(0xFFFFFFFF),
                                                Color(0xFFCCCCCC),
                                              ],
                                              begin: Alignment.topCenter,
                                              end: Alignment.bottomCenter,
                                            ),
                                            borderRadius:
                                                BorderRadius.circular(10.0),
                                            border: Border.all(
                                              width: 2.0,
                                              color: const Color(0xFFe86100),
                                            ),
                                          ),
                                          child: ElevatedButton(
                                            onPressed: () {
                                              print('Submit button is clicked');
                                              datevalidation();
                                            },
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor:
                                                  Colors.transparent,
                                              elevation: 0,
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(10.0),
                                              ),
                                            ),
                                            child: const Text(
                                              'Submit',
                                              style: TextStyle(
                                                color: Color(0xFFe86100),
                                                fontSize: 16,
                                                fontFamily: 'hind_semibold',
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                    const SizedBox(
                      height: 10.0,
                    ),
                    isLoading
                        ? const Center(
                            child: CircularProgressIndicator(),
                          )
                        : Visibility(
                            visible: isInfoVisible,
                            child: Padding(
                                padding: const EdgeInsets.only(
                                    left: 12.0, right: 12.0),
                                child: Container(
                                    decoration: BoxDecoration(
                                      color: const Color(0x8D000000),
                                      borderRadius: BorderRadius.circular(6.0),
                                    ),
                                    child: Column(
                                      children: [
                                        Row(
                                          children: [
                                            const Expanded(
                                              flex: 5,
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Padding(
                                                    padding:
                                                        EdgeInsets.fromLTRB(
                                                            8, 10, 12, 0),
                                                    child: Text(
                                                      "Total Collections",
                                                      style: TextStyle(
                                                        color: Colors.white,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        fontFamily:
                                                            'hind_semibold',
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            const Expanded(
                                              flex: 1,
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.center,
                                                children: [
                                                  Padding(
                                                    padding:
                                                        EdgeInsets.fromLTRB(
                                                            0, 0, 0, 0),
                                                    child: Text(
                                                      ":",
                                                      style: TextStyle(
                                                        color: Colors.white,
                                                        fontSize: 16,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        fontFamily:
                                                            'hind_semibold',
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            Expanded(
                                              flex: 4,
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                mainAxisAlignment:
                                                    MainAxisAlignment.start,
                                                children: [
                                                  Padding(
                                                    padding: const EdgeInsets
                                                        .fromLTRB(0, 0, 0, 0),
                                                    child: Text(
                                                      totalcollections ?? '',
                                                      style: const TextStyle(
                                                        color: Colors.white,
                                                        fontSize: 16,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        fontFamily:
                                                            'hind_semibold',
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
                                              flex: 5,
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Padding(
                                                    padding:
                                                        EdgeInsets.fromLTRB(
                                                            8, 10, 12, 0),
                                                    child: Text(
                                                      "Total Net Weight",
                                                      style: TextStyle(
                                                        color: Colors.white,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        fontFamily:
                                                            'hind_semibold',
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            const Expanded(
                                              flex: 1,
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.center,
                                                children: [
                                                  Padding(
                                                    padding:
                                                        EdgeInsets.fromLTRB(
                                                            0, 0, 0, 0),
                                                    child: Text(
                                                      ":",
                                                      style: TextStyle(
                                                        color: Colors.white,
                                                        fontSize: 16,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        fontFamily:
                                                            'hind_semibold',
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            Expanded(
                                              flex: 4,
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                mainAxisAlignment:
                                                    MainAxisAlignment.start,
                                                children: [
                                                  Padding(
                                                    padding: const EdgeInsets
                                                        .fromLTRB(0, 0, 0, 0),
                                                    child: Text(
                                                      totalnetweight ?? '',
                                                      style: const TextStyle(
                                                        color: Colors.white,
                                                        fontSize: 16,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        fontFamily:
                                                            'hind_semibold',
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
                                              flex: 6,
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Padding(
                                                    padding:
                                                        EdgeInsets.fromLTRB(
                                                            8, 10, 0, 0),
                                                    child: Text(
                                                      "Unapid Collections Weight",
                                                      style: TextStyle(
                                                        color: Colors.white,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        fontFamily:
                                                            'hind_semibold',
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            const Expanded(
                                              flex: 1,
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.center,
                                                children: [
                                                  Padding(
                                                    padding:
                                                        EdgeInsets.fromLTRB(
                                                            4, 0, 0, 0),
                                                    child: Text(
                                                      ":",
                                                      style: TextStyle(
                                                        color: Colors.white,
                                                        fontSize: 16,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        fontFamily:
                                                            'hind_semibold',
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            Expanded(
                                              flex: 5,
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                mainAxisAlignment:
                                                    MainAxisAlignment.start,
                                                children: [
                                                  Padding(
                                                    padding: const EdgeInsets
                                                        .fromLTRB(5, 0, 0, 0),
                                                    child: Text(
                                                      unpaidcollections ?? '',
                                                      style: const TextStyle(
                                                        color: Colors.white,
                                                        fontSize: 16,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        fontFamily:
                                                            'hind_semibold',
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
                                              flex: 5,
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Padding(
                                                    padding:
                                                        EdgeInsets.fromLTRB(
                                                            8, 10, 12, 5),
                                                    child: Text(
                                                      "Paid Collections Weight",
                                                      style: TextStyle(
                                                        color: Colors.white,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        fontFamily:
                                                            'hind_semibold',
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            const Expanded(
                                              flex: 1,
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.center,
                                                children: [
                                                  Padding(
                                                    padding:
                                                        EdgeInsets.fromLTRB(
                                                            0, 0, 0, 5),
                                                    child: Text(
                                                      ":",
                                                      style: TextStyle(
                                                        color: Colors.white,
                                                        fontSize: 16,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        fontFamily:
                                                            'hind_semibold',
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            Expanded(
                                              flex: 4,
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                mainAxisAlignment:
                                                    MainAxisAlignment.start,
                                                children: [
                                                  Padding(
                                                    padding: const EdgeInsets
                                                        .fromLTRB(0, 0, 0, 5),
                                                    child: Text(
                                                      paidcollections ?? '',
                                                      style: const TextStyle(
                                                        color: Colors.white,
                                                        fontSize: 16,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        fontFamily:
                                                            'hind_semibold',
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    )))),
                    const SizedBox(
                      height: 50.0,
                    ),
                    Visibility(
                        visible: nodatavisibility,
                        child: const Expanded(
                          child: Center(
                            child: Text(
                              'No Collections Available',
                              style: TextStyle(
                                color: Colors.orangeAccent,
                                fontSize: 16,
                              ),
                            ),
                          ),
                          // child: Text(
                          //   " No Collection Data Found",
                          //   style: TextStyle(
                          //     color: Colors.black,
                          //     fontWeight: FontWeight.bold,
                          //     fontFamily: 'hind_semibold',
                          //   ),
                          // ),
                        )),
                    isLoading
                        ? const Center(
                            child: CircularProgressIndicator(),
                          )
                        : Expanded(
                            flex: 3,
                            child: ListView.builder(
                              shrinkWrap: true,
                              itemCount: collectionlist.length,
                              itemBuilder: (context, index) {
                                List<Color> cardColors = [
                                  Colors.white,
                                  const Color(0xFFDFDFDF)
                                ];
                                Color backgroundColor =
                                    cardColors[index % cardColors.length];
                                Collection collect = collectionlist[index];
                                late Color textColor;
                                String status = "";
                                String formattedDate =
                                    collect.docDate.toString();
                                datefromapi = formatDate(formattedDate);
                                String weight = "${collect.quantity}Kg";
                                status = collect.uApaystat.toString();
                                if (status == "Payment Pending") {
                                  textColor = Colors.red;
                                } else if (status == "Paid") {
                                  textColor = Colors.green;
                                }
                                return Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 0.0, vertical: 0.0),
                                  child: Card(
                                    color: backgroundColor,
                                    shadowColor: Colors.transparent,
                                    surfaceTintColor: Colors.transparent,
                                    child: Container(
                                      decoration: BoxDecoration(
                                        borderRadius:
                                            BorderRadius.circular(12.0),
                                      ),
                                      child: Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: [
                                          Expanded(
                                            child: Padding(
                                              padding: const EdgeInsets.only(
                                                  left: 15.0),
                                              child: Column(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.start,
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceBetween,
                                                    //        crossAxisAlignment: CrossAxisAlignment.start,
                                                    children: [
                                                      Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .only(
                                                                top: 15.0),
                                                        child: Text(
                                                          collect.uColnid,
                                                          style:
                                                              const TextStyle(
                                                            fontSize: 18,
                                                            color: Color(
                                                                0xFFFB4110),
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            fontFamily:
                                                                'Calibri',
                                                          ),
                                                        ),
                                                      ),
                                                      GestureDetector(
                                                          onTap: () {
                                                            collectionapi(
                                                                collect
                                                                    .uColnid);
                                                          },
                                                          child: Image.asset(
                                                            'assets/images/info_icon.png',
                                                            width: 25,
                                                            height: 25,
                                                          ))
                                                    ],
                                                  ),
                                                  const SizedBox(height: 4.0),
                                                  Row(
                                                    children: [
                                                      const Expanded(
                                                        flex: -1,
                                                        child: Column(
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .start,
                                                          children: [
                                                            Padding(
                                                              padding:
                                                                  EdgeInsets
                                                                      .fromLTRB(
                                                                          0,
                                                                          8,
                                                                          0,
                                                                          0),
                                                              child: Text(
                                                                "Date",
                                                                style:
                                                                    TextStyle(
                                                                  color: Colors
                                                                      .black,
                                                                  fontSize: 14,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold,
                                                                  fontFamily:
                                                                      'hind_semibold',
                                                                ),
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                      const Expanded(
                                                        flex: 0,
                                                        child: Column(
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .end,
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .end,
                                                          children: [
                                                            Padding(
                                                              padding:
                                                                  EdgeInsets
                                                                      .fromLTRB(
                                                                          40,
                                                                          8,
                                                                          5,
                                                                          0),
                                                              child: Text(
                                                                ":",
                                                                style:
                                                                    TextStyle(
                                                                  color: Colors
                                                                      .black54,
                                                                  fontSize: 14,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold,
                                                                  fontFamily:
                                                                      'hind_semibold',
                                                                ),
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                      Expanded(
                                                        flex: 2,
                                                        child: Column(
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .start,
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .start,
                                                          children: [
                                                            Padding(
                                                              padding:
                                                                  const EdgeInsets
                                                                      .fromLTRB(
                                                                      0,
                                                                      8,
                                                                      0,
                                                                      0),
                                                              child: Text(
                                                                '$datefromapi',
                                                                style:
                                                                    const TextStyle(
                                                                  color: Colors
                                                                      .black54,
                                                                  fontSize: 14,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold,
                                                                  fontFamily:
                                                                      'hind_semibold',
                                                                ),
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                      const SizedBox(
                                                          width: 8.0),
                                                      const Expanded(
                                                        flex: 0,
                                                        child: Column(
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .start,
                                                          children: [
                                                            Padding(
                                                              padding:
                                                                  EdgeInsets
                                                                      .fromLTRB(
                                                                          0,
                                                                          8,
                                                                          0,
                                                                          0),
                                                              child: Text(
                                                                'Weight',
                                                                style:
                                                                    TextStyle(
                                                                  color: Colors
                                                                      .black,
                                                                  fontSize: 14,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold,
                                                                  fontFamily:
                                                                      'hind_semibold',
                                                                ),
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                      const Expanded(
                                                        flex: 0,
                                                        child: Column(
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .end,
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .end,
                                                          children: [
                                                            Padding(
                                                              padding:
                                                                  EdgeInsets
                                                                      .fromLTRB(
                                                                          10,
                                                                          8,
                                                                          5,
                                                                          0),
                                                              child: Text(
                                                                ":",
                                                                style:
                                                                    TextStyle(
                                                                  color: Colors
                                                                      .black54,
                                                                  fontSize: 14,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold,
                                                                  fontFamily:
                                                                      'hind_semibold',
                                                                ),
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                      Expanded(
                                                        flex: 2,
                                                        child: Column(
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .start,
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .start,
                                                          children: [
                                                            Padding(
                                                              padding:
                                                                  const EdgeInsets
                                                                      .fromLTRB(
                                                                      0,
                                                                      8,
                                                                      0,
                                                                      0),
                                                              child: Text(
                                                                weight,
                                                                style:
                                                                    const TextStyle(
                                                                  color: Colors
                                                                      .black54,
                                                                  fontSize: 14,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold,
                                                                  fontFamily:
                                                                      'hind_semibold',
                                                                ),
                                                                //  controller: weightController, // Use a TextEditingController for weight
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                  Row(children: [
                                                    const Expanded(
                                                      flex: -1,
                                                      child: Column(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        children: [
                                                          Padding(
                                                            padding: EdgeInsets
                                                                .fromLTRB(
                                                                    0, 5, 0, 0),
                                                            child: Text(
                                                              "CC",
                                                              style: TextStyle(
                                                                color: Colors
                                                                    .black,
                                                                fontSize: 14,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                                fontFamily:
                                                                    'hind_semibold',
                                                              ),
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                    const Expanded(
                                                      flex: 0,
                                                      child: Column(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .end,
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .end,
                                                        children: [
                                                          Padding(
                                                            padding: EdgeInsets
                                                                .fromLTRB(51, 5,
                                                                    5, 0),
                                                            child: Text(
                                                              ":",
                                                              style: TextStyle(
                                                                color: Colors
                                                                    .black54,
                                                                fontSize: 14,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                                fontFamily:
                                                                    'hind_semibold',
                                                              ),
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                    Expanded(
                                                      flex: 2,
                                                      child: Column(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .start,
                                                        children: [
                                                          Padding(
                                                            padding:
                                                                const EdgeInsets
                                                                    .fromLTRB(
                                                                    0, 5, 0, 0),
                                                            child: Text(
                                                              collect.whsName,
                                                              style:
                                                                  const TextStyle(
                                                                color: Colors
                                                                    .black54,
                                                                fontSize: 14,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                                fontFamily:
                                                                    'hind_semibold',
                                                              ),
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ]),
                                                  Row(children: [
                                                    const Expanded(
                                                      flex: -1,
                                                      child: Column(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        children: [
                                                          Padding(
                                                            padding: EdgeInsets
                                                                .fromLTRB(
                                                                    0, 5, 0, 8),
                                                            child: Text(
                                                              "Status",
                                                              style: TextStyle(
                                                                color: Colors
                                                                    .black,
                                                                fontSize: 14,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                                fontFamily:
                                                                    'hind_semibold',
                                                              ),
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                    const Expanded(
                                                      flex: 0,
                                                      child: Column(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .end,
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .end,
                                                        children: [
                                                          Padding(
                                                            padding: EdgeInsets
                                                                .fromLTRB(32, 5,
                                                                    5, 8),
                                                            child: Text(
                                                              ":",
                                                              style: TextStyle(
                                                                color: Colors
                                                                    .black54,
                                                                fontSize: 14,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                                fontFamily:
                                                                    'hind_semibold',
                                                              ),
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                    Expanded(
                                                      flex: 2,
                                                      child: Column(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .start,
                                                        children: [
                                                          Padding(
                                                            padding:
                                                                const EdgeInsets
                                                                    .fromLTRB(
                                                                    0, 5, 0, 8),
                                                            child: Text(
                                                              status,
                                                              style: TextStyle(
                                                                color:
                                                                    textColor,
                                                                fontSize: 14,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                                fontFamily:
                                                                    'hind_semibold',
                                                              ),
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ]),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                  ],
                ),
              ));
  }

  Future<void> get30days() async {
    final url = Uri.parse(baseUrl + getcollection);
    print('url==>890: $url');
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      userId = prefs.getString('user_id');
      print('FarmerCode -==$userId');
    });
    final request = {
      "farmerCode": userId!,
      "fromDate": startDateString,
      "toDate": endDateString
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
        print('responseData: $responseData');
        if (responseData['result'] != null) {
          List<Collection> collections =
              (responseData['result']['collectioData'] as List)
                  .map((item) => Collection.fromJson(item))
                  .toList();
          CollectionCount collectionCount = CollectionCount.fromJson(
              responseData['result']['collectionCount'][0]);

          // Now, you can access the data within collections and collectionCount
          for (Collection collection in collections) {
            print('uColnid: ${collection.uColnid}');
            u_colnidtext = collection.uColnid.toString();
            String formattedDate = collection.docDate.toString();
            datefromapi = formatDate(formattedDate);
            print('u_colnidtext30days: $u_colnidtext');
            print('u_colniddatefromapi30days: $formattedDate');
            // Access other properties as needed
            setState(() {
              collectionlist = collections;
              datefromapi = formattedDate;
            });
          }

          // print('Collections Weight: ${collectionCount.collectionsWeight}');
          // print('Collections Count: ${collectionCount.collectionsCount}');
          // print('Paid Collections Weight: ${collectionCount.paidCollectionsWeight}');
          // print('Unpaid Collections Weight: ${collectionCount.unPaidCollectionsWeight}');
          totalcollections = '${collectionCount.collectionsCount}';
          totalnetweight = '${collectionCount.collectionsWeight} Kg';
          paidcollections = '${collectionCount.paidCollectionsWeight} Kg';
          unpaidcollections = ' ${collectionCount.unPaidCollectionsWeight}Kg';
          print('totalcollections-$totalcollections');
          print('totalnetweight-$totalnetweight');
          print('paidcollections-$paidcollections');
          print('unpaidcollections-$unpaidcollections');
        } else {
          print('Request was not successful');
          nodatavisibility = true;
        }
      } else {
        print(
            'Failed to send the request. Status code: ${response.statusCode}');
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  Future<void> getfinancialyear() async {
    setState(() {
      isLoading = true;
      // CommonStyles.showHorizontalDotsLoadingDialog(context);
    });
    collectionlist.clear();
    final url = Uri.parse(baseUrl + getcollection);
    print('url==>000: $url');
    final request = {
      "farmerCode": userId,
      "fromDate": financialYearFrom,
      "toDate": financialYearTo
    };
    print('request of the financialYear  : $request');
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
        print('responseDataFY: $responseData');
        if (responseData['result'] != null) {
          List<Collection> collections =
              (responseData['result']['collectioData'] as List)
                  .map((item) => Collection.fromJson(item))
                  .toList();
          CollectionCount collectionCount = CollectionCount.fromJson(
              responseData['result']['collectionCount'][0]);

          for (Collection collection in collections) {
            print('uColnid: ${collection.uColnid}');
            u_colnidtext = collection.uColnid.toString();
            print('u_colnidtextFY: $u_colnidtext');
            // Access other properties as needed
            setState(() {
              collectionlist = collections;
              //  CommonStyles.hideHorizontalDotsLoadingDialog(context);
              isLoading = false;
            });
          }
          totalcollections = '${collectionCount.collectionsCount}';
          totalnetweight = '${collectionCount.collectionsWeight} Kg';
          paidcollections = '${collectionCount.paidCollectionsWeight} Kg';
          unpaidcollections = ' ${collectionCount.unPaidCollectionsWeight}Kg';
          print('totalcollectionsFY-$totalcollections');
          print('totalnetweightFY-$totalnetweight');
          print('paidcollectionsFY-$paidcollections');
          print('unpaidcollectionsFY-$unpaidcollections');
        } else {
          setState(() {
            isLoading = false;
          });
          print('Request was not successfulFY');
        }
      } else {
        setState(() {
          isLoading = false;
        });
        print(
            'Failed to send the request. Status code: ${response.statusCode}');
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      print('Error FY: $e');
    }
  }

  void datevalidation() {
    if (fromDate == null || toDate == null) {
      //  showCustomToastMessageLong("Please select both FromDate and ToDate", context, 1, 5);
    } else if (toDate!.compareTo(fromDate!) < 0) {
      //showCustomToastMessageLong("To Date is less than From Date", context, 1, 5);
    } else {
      // Your submit logic here

      //showCustomToastMessageLong("You can hit the API", context, 0, 5);
      getcustomcollections();
      setState(() {
        isInfoVisible = true;
      });
    }
  }

  Future<void> getcustomcollections() async {
    collectionlist.clear();
    final url = Uri.parse(baseUrl + getcollection);
    print('url==>555: $url');
    final String fromFormattedDateApi = formatDateToApi(fromDate!);
    final String toFormattedDateApi = formatDateToApi(toDate!);
    print('fromFormattedDateApi: $fromFormattedDateApi');
    print('toFormattedDateApi: $toFormattedDateApi');
    final request = {
      "farmerCode": userId,
      "fromDate": fromFormattedDateApi,
      "toDate": toFormattedDateApi
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
        print('response_Customcollections: $responseData');
        if (responseData['result'] != null) {
          List<Collection> collections =
              (responseData['result']['collectioData'] as List)
                  .map((item) => Collection.fromJson(item))
                  .toList();
          CollectionCount collectionCount = CollectionCount.fromJson(
              responseData['result']['collectionCount'][0]);

          // Now, you can access the data within collections and collectionCount
          for (Collection collection in collections) {
            print('uColnid: ${collection.uColnid}');
            u_colnidtext = collection.uColnid.toString();
            print('u_colnidtextcustom: $u_colnidtext');
            // Access other properties as needed
            setState(() {
              collectionlist = collections;
            });
          }
          // print('Collections Weight: ${collectionCount.collectionsWeight}');
          // print('Collections Count: ${collectionCount.collectionsCount}');
          // print('Paid Collections Weight: ${collectionCount.paidCollectionsWeight}');
          // print('Unpaid Collections Weight: ${collectionCount.unPaidCollectionsWeight}');
          totalcollections = '${collectionCount.collectionsCount}';
          totalnetweight = '${collectionCount.collectionsWeight} Kg';
          paidcollections = '${collectionCount.paidCollectionsWeight} Kg';
          unpaidcollections = ' ${collectionCount.unPaidCollectionsWeight}Kg';
          print('totalcollections_custom-$totalcollections');
          print('totalnetweight_custom-$totalnetweight');
          print('paidcollections_custom-$paidcollections');
          print('unpaidcollections_custom-$unpaidcollections');
        } else {
          print('Request was not successful');
        }
      } else {
        print(
            'Failed to send the request. Status code: ${response.statusCode}');
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  void collectionapi(String collectionid) async {
    final url = Uri.parse("$baseUrl$getCollectionInfoById$collectionid");
    print('url==>555: $url');
    print('collectionid: $collectionid');

    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);
        print('response_collectionid: $responseData');
        if (responseData['result'] != null) {
          List<dynamic> listResult = responseData['result'];
          collectionreceiptlist = listResult
              .map((item) => CollectionReceipt.fromJson(item))
              .toList();
          // if(responseData['isSuccess']==true){
          //   Showdialogforicon(collectionreceiptlist);
          // }
        } else {
          print('Request was not successful');
        }
      } else {
        print(
            'Failed to send the request. Status code: ${response.statusCode}');
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  void Showdialogforicon(List<CollectionReceipt> receiptList) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
            backgroundColor: Colors.transparent,
            child: Container(
              width: MediaQuery.of(context).size.width / 1.5,
              color: Colors.white,
              // decoration: BoxDecoration(
              //   border: Border.all(color: Color(0xFFe86100),width: 1.5),
              //   borderRadius: BorderRadius.circular(
              //       10.0),
              // ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: MediaQuery.of(context).size.width,
                    padding: const EdgeInsets.fromLTRB(12, 10, 0, 0),
                    child: const Text(
                      'Comments',
                      textAlign: TextAlign.start,
                      style: TextStyle(
                          color: Color(0xFFe86100),
                          fontWeight: FontWeight.w500),
                    ),
                  ),
                  for (var receipt in receiptList)
                    Column(
                      children: [
                        Row(
                          children: [
                            const Expanded(
                              flex: 3,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Padding(
                                    padding: EdgeInsets.fromLTRB(12, 0, 0, 0),
                                    child: Text(
                                      "Driver Name",
                                      style: TextStyle(
                                          color: Colors.black,
                                          fontWeight: FontWeight.bold,
                                          fontFamily: 'hind_semibold'),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const Expanded(
                              flex: 1,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Padding(
                                    padding: EdgeInsets.fromLTRB(0, 0, 0, 0),
                                    child: Text(
                                      ":",
                                      style: TextStyle(
                                        color: Colors.black,
                                        fontSize: 16,
                                        fontFamily: 'hind_semibold',
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Expanded(
                              flex: 5,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Padding(
                                    padding:
                                        const EdgeInsets.fromLTRB(0, 0, 0, 0),
                                    child: Text(
                                      receipt.driverName,
                                      style: const TextStyle(
                                        color: Colors.black,
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        fontFamily: 'hind_semibold',
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            )
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
                                    padding: EdgeInsets.fromLTRB(12, 0, 0, 0),
                                    child: Text(
                                      "Vehicle Number",
                                      style: TextStyle(
                                          color: Colors.black,
                                          fontWeight: FontWeight.bold,
                                          fontFamily: 'hind_semibold'),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const Expanded(
                              flex: 1,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Padding(
                                    padding: EdgeInsets.fromLTRB(0, 0, 0, 0),
                                    child: Text(
                                      ":",
                                      style: TextStyle(
                                        color: Colors.black,
                                        fontSize: 16,
                                        fontFamily: 'hind_semibold',
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Expanded(
                              flex: 5,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Padding(
                                    padding:
                                        const EdgeInsets.fromLTRB(0, 0, 0, 0),
                                    child: Text(
                                      receipt.vehicleNumber,
                                      style: const TextStyle(
                                        color: Colors.black,
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        fontFamily: 'hind_semibold',
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            )
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
                                    padding: EdgeInsets.fromLTRB(12, 0, 0, 0),
                                    child: Text(
                                      "Collection Center",
                                      style: TextStyle(
                                          color: Colors.black,
                                          fontWeight: FontWeight.bold,
                                          fontFamily: 'hind_semibold'),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const Expanded(
                              flex: 1,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Padding(
                                    padding: EdgeInsets.fromLTRB(0, 0, 0, 0),
                                    child: Text(
                                      ":",
                                      style: TextStyle(
                                        color: Colors.black,
                                        fontSize: 16,
                                        fontFamily: 'hind_semibold',
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Expanded(
                              flex: 5,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Padding(
                                    padding:
                                        const EdgeInsets.fromLTRB(0, 0, 0, 0),
                                    child: Text(
                                      ' ${receipt.collectionCenter}',
                                      style: const TextStyle(
                                        color: Colors.black,
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        fontFamily: 'hind_semibold',
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            )
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
                                    padding: EdgeInsets.fromLTRB(12, 0, 0, 0),
                                    child: Text(
                                      "Gross Weight",
                                      style: TextStyle(
                                          color: Colors.black,
                                          fontWeight: FontWeight.bold,
                                          fontFamily: 'hind_semibold'),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const Expanded(
                              flex: 1,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Padding(
                                    padding: EdgeInsets.fromLTRB(0, 0, 0, 0),
                                    child: Text(
                                      ":",
                                      style: TextStyle(
                                        color: Colors.black,
                                        fontSize: 16,
                                        fontFamily: 'hind_semibold',
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Expanded(
                              flex: 5,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Padding(
                                    padding:
                                        const EdgeInsets.fromLTRB(0, 0, 0, 0),
                                    child: Text(
                                      '${receipt.grossWeight}',
                                      style: const TextStyle(
                                        color: Colors.black,
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        fontFamily: 'hind_semibold',
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            )
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
                                    padding: EdgeInsets.fromLTRB(12, 0, 0, 0),
                                    child: Text(
                                      "Tara Weight",
                                      style: TextStyle(
                                          color: Colors.black,
                                          fontWeight: FontWeight.bold,
                                          fontFamily: 'hind_semibold'),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const Expanded(
                              flex: 1,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Padding(
                                    padding: EdgeInsets.fromLTRB(0, 0, 0, 0),
                                    child: Text(
                                      ":",
                                      style: TextStyle(
                                        color: Colors.black,
                                        fontSize: 16,
                                        fontFamily: 'hind_semibold',
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Expanded(
                              flex: 5,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Padding(
                                    padding:
                                        const EdgeInsets.fromLTRB(0, 0, 0, 0),
                                    child: Text(
                                      '${receipt.tareWeight}',
                                      style: const TextStyle(
                                        color: Colors.black,
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        fontFamily: 'hind_semibold',
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            )
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
                                    padding: EdgeInsets.fromLTRB(12, 0, 0, 0),
                                    child: Text(
                                      "Net Weight",
                                      style: TextStyle(
                                          color: Colors.black,
                                          fontWeight: FontWeight.bold,
                                          fontFamily: 'hind_semibold'),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const Expanded(
                              flex: 1,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Padding(
                                    padding: EdgeInsets.fromLTRB(0, 0, 0, 0),
                                    child: Text(
                                      ":",
                                      style: TextStyle(
                                        color: Colors.black,
                                        fontSize: 16,
                                        fontFamily: 'hind_semibold',
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Expanded(
                              flex: 5,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Padding(
                                    padding:
                                        const EdgeInsets.fromLTRB(0, 0, 0, 0),
                                    child: Text(
                                      '${receipt.netWeight}',
                                      style: const TextStyle(
                                        color: Colors.black,
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        fontFamily: 'hind_semibold',
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            )
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
                                    padding: EdgeInsets.fromLTRB(12, 0, 0, 0),
                                    child: Text(
                                      "Date",
                                      style: TextStyle(
                                          color: Colors.black,
                                          fontWeight: FontWeight.bold,
                                          fontFamily: 'hind_semibold'),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const Expanded(
                              flex: 1,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Padding(
                                    padding: EdgeInsets.fromLTRB(0, 0, 0, 0),
                                    child: Text(
                                      ":",
                                      style: TextStyle(
                                        color: Colors.black,
                                        fontSize: 16,
                                        fontFamily: 'hind_semibold',
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Expanded(
                              flex: 5,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Padding(
                                    padding:
                                        const EdgeInsets.fromLTRB(0, 0, 0, 0),
                                    child: Text(
                                      '${receipt.receiptGeneratedDate}',
                                      style: const TextStyle(
                                        color: Colors.black,
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        fontFamily: 'hind_semibold',
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            )
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
                                    padding: EdgeInsets.fromLTRB(12, 0, 0, 0),
                                    child: Text(
                                      "3F OP Collection Officer Name",
                                      style: TextStyle(
                                          color: Colors.black,
                                          fontWeight: FontWeight.bold,
                                          fontFamily: 'hind_semibold'),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const Expanded(
                              flex: 1,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Padding(
                                    padding: EdgeInsets.fromLTRB(0, 0, 0, 0),
                                    child: Text(
                                      ":",
                                      style: TextStyle(
                                        color: Colors.black,
                                        fontSize: 16,
                                        fontFamily: 'hind_semibold',
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Expanded(
                              flex: 5,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Padding(
                                    padding:
                                        const EdgeInsets.fromLTRB(0, 0, 0, 0),
                                    child: Text(
                                      receipt.operatorName,
                                      style: const TextStyle(
                                        color: Colors.black,
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        fontFamily: 'hind_semibold',
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            )
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
                                    padding: EdgeInsets.fromLTRB(12, 0, 0, 0),
                                    child: Text(
                                      "Comments",
                                      style: TextStyle(
                                          color: Colors.black,
                                          fontWeight: FontWeight.bold,
                                          fontFamily: 'hind_semibold'),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const Expanded(
                              flex: 1,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Padding(
                                    padding: EdgeInsets.fromLTRB(0, 0, 0, 0),
                                    child: Text(
                                      ":",
                                      style: TextStyle(
                                        color: Colors.black,
                                        fontSize: 16,
                                        fontFamily: 'hind_semibold',
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Expanded(
                              flex: 5,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Padding(
                                    padding:
                                        const EdgeInsets.fromLTRB(0, 0, 0, 0),
                                    child: Text(
                                      receipt.comments,
                                      style: const TextStyle(
                                        color: Colors.black,
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        fontFamily: 'hind_semibold',
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            )
                          ],
                        ),
                      ],
                    ),
                  const SizedBox(
                    height: 10,
                  ),
                  GestureDetector(
                    onTap: () {},
                    child: SizedBox(
                      width: MediaQuery.of(context).size.width,
                      child: const Text(
                        'Click Here to See Receipt',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            color: Color(0xFFe86100),
                            fontWeight: FontWeight.w500),
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: const Text('Close'))
                ],
              ),
            ));
      },
    );
  }
}
 */