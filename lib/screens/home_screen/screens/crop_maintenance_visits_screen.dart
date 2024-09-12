import 'dart:convert';
import 'package:akshaya_flutter/models/CropData.dart';
import 'package:akshaya_flutter/models/CropData.dart';
import 'package:http/http.dart' as http;
import 'package:akshaya_flutter/common_utils/api_config.dart';
import 'package:akshaya_flutter/common_utils/common_styles.dart';
import 'package:akshaya_flutter/common_utils/custom_appbar.dart';
import 'package:akshaya_flutter/common_utils/custom_box.dart';
import 'package:akshaya_flutter/common_utils/shared_prefs_keys.dart';
import 'package:akshaya_flutter/localization/locale_keys.dart';
import 'package:akshaya_flutter/models/plot_details_model.dart';
import 'package:akshaya_flutter/screens/home_screen/screens/plot_selection_screen.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CropMaintenanceVisitsScreen extends StatefulWidget {
  final PlotDetailsModel plotdata;

  const CropMaintenanceVisitsScreen({super.key, required this.plotdata});

  @override
  _CropMaintenanceVisitsScreen createState() => _CropMaintenanceVisitsScreen();
}

class _CropMaintenanceVisitsScreen extends State<CropMaintenanceVisitsScreen> {
  List<HealthPlantationData> healthplantationlist = [];
  List<NutrientData> NutrientDatalist = [];
  List<UprootmentData> UprootmentDatalist = [];
  List<PestData> PestDatalist = [];
  List<DiseaseData> DiseaseDatalist = [];
  List<PlotIrrigation> plotIrrigationlist = [];
  String updated = '';
  String treesAppearance = '';
  int plamscount = 0;
  double frequencyofharvest = 0.0;
  String? formattedDate;
  @override
  void initState() {
    super.initState();
    fetchcropmaintencelist();
  }

  Future<void> fetchcropmaintencelist() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? userId = prefs.getString(SharedPrefsKeys.farmerCode);

    String plotcode = widget.plotdata.plotcode!;

    //const apiUrl = 'http://182.18.157.215/3FAkshaya/API/api/GetCropMaintenanceHistoryDetailsByPlotCode/APT00123174004/APEGT13119166001';
    //  final apiUrl = '$baseUrl$getCropMaintenanceHistoryDetailsByPlotCode/$plotcode/$userId';
    final apiUrl =
        '$baseUrl$getCropMaintenanceHistoryDetailsByPlotCode/APT00123174004/APEGT13119166001';
    print('apiUrl$apiUrl');
    setState(() {
      CommonStyles.showHorizontalDotsLoadingDialog(context);
    });
    try {
      final jsonResponse = await http.get(Uri.parse(apiUrl));

      if (jsonResponse.statusCode == 200) {
        final response = jsonDecode(jsonResponse.body);

        setState(() {
          CommonStyles.hideHorizontalDotsLoadingDialog(context);
        });

        if (response['healthPlantationData'] != null) {
          // Assuming the list is under a key inside healthPlantationData
          var healthPlantationData = response['healthPlantationData'];
          var uproomtementdata = response['uprootmentData'];
          var frequency = response['frequencyOfHarvest'];

          // Print the structure for debugging
          print('healthPlantationData: $healthPlantationData');
          String updated = healthPlantationData['updatedDate'];
          var treessapprearance = healthPlantationData['treesAppearance'];
          var plamscount = uproomtementdata['plamsCount'];

          List<dynamic> pestdatalist = response['pestData'];
          List<dynamic> diseasedatalist = response['diseaseData'];
          List<dynamic> nutrientdatalist = response['nutrientData'];
          List<dynamic> plotIrrigationdatalist = response['plotIrrigation'];

          if (healthPlantationData['updatedDate'] != null) {
            setState(() {
              updated = updated;
              print('_updated$updated');
              print('updated$updated');
              treesAppearance = treessapprearance;
              plamscount = plamscount;
              frequencyofharvest = frequency;
              PestDatalist =
                  pestdatalist.map((item) => PestData.fromJson(item)).toList();
              DiseaseDatalist = diseasedatalist
                  .map((item) => DiseaseData.fromJson(item))
                  .toList();
              NutrientDatalist = nutrientdatalist
                  .map((item) => NutrientData.fromJson(item))
                  .toList();
              plotIrrigationlist = plotIrrigationdatalist
                  .map((item) => PlotIrrigation.fromJson(item))
                  .toList();

              print('healthplantationlist length: ${PestDatalist.length}');
            });
          }

          // } else {
          //   throw Exception('plotList is null');
          // }
        } else {
          throw Exception('healthPlantationData is null');
          CommonStyles.hideHorizontalDotsLoadingDialog(context);
        }
        //CommonStyles.hideHorizontalDotsLoadingDialog(context);
        throw Exception('list is empty');
      } else {
        CommonStyles.hideHorizontalDotsLoadingDialog(context);
        throw Exception(
            'Request failed with status: ${jsonResponse.statusCode}');
      }
    } catch (e) {
      rethrow;
    }
  }

  // String formatDateString(String dateString) {
  //   print('dateformat$dateString');
  //   DateTime parsedDate = DateTime.parse(dateString);
  //   String formattedDate = DateFormat('dd-MM-yyyy').format(parsedDate);
  //   return formattedDate;
  // }

  String formatDate(String dateStr, DateFormat inputFormat1,
      DateFormat inputFormat2, DateFormat outputFormat) {
    DateTime? date;

    try {
      if (dateStr.contains('T')) {
        date = inputFormat1.parse(dateStr);
      } else {
        date = inputFormat2.parse(dateStr);
      }
    } catch (e) {
      print('Error parsing date: $e');
    }

    if (date != null) {
      return outputFormat.format(date);
    } else {
      return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    // if (updated != null && updated!.isNotEmpty) {
    //   print('updateddate: $updated');
    //   try {
    //     DateTime formattedDate1 = DateFormat('dd-MM-yyyy').parse(updated!);
    //      formattedDate = DateFormat('dd-MM-yyyy').format(formattedDate1);
    //     print(formattedDate);  // Output: 2024-09-05 00:00:00.000
    //   } catch (e) {
    //     print('Error parsing date: $e');
    //   }
    // } else {
    //   print('Date string is null or empty');
    // }
    DateFormat inputFormat1 = DateFormat("yyyy-MM-dd'T'HH:mm:ss");
    DateFormat inputFormat2 = DateFormat("yyyy-MM-dd HH:mm:ss");
    DateFormat outputFormat = DateFormat("dd-MM-yyyy", 'en');

    //String? cmlastvisitdate =updated!; // Example date
    String formattedDate =
        formatDate(updated, inputFormat1, inputFormat2, outputFormat);
    // print(cmlastvisitdate);
    print(formattedDate);
    return Scaffold(
      appBar: CustomAppBar(title: tr(LocaleKeys.str_select_plot)),
      body: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.all(10),
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
                  borderRadius: BorderRadius.circular(10.0),
                  color: Colors.black54,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    custombox(
                        label: tr(LocaleKeys.treesAppearance),
                        data: treesAppearance,
                        dataTextColor: CommonStyles.whiteColor,
                        labelTextColor: CommonStyles.whiteColor),
                    custombox(
                        label: tr(LocaleKeys.plamsCount),
                        data: '$plamscount',
                        dataTextColor: CommonStyles.whiteColor,
                        labelTextColor: CommonStyles.whiteColor),
                    custombox(
                        label: tr(LocaleKeys.Frequency_harvest),
                        data: '$frequencyofharvest',
                        dataTextColor: CommonStyles.whiteColor,
                        labelTextColor: CommonStyles.whiteColor),
                    custombox(
                        label: tr(LocaleKeys.last_date),
                        data: formattedDate ?? '',
                        dataTextColor: CommonStyles.whiteColor,
                        labelTextColor: CommonStyles.whiteColor),
                    Text(
                      tr(LocaleKeys.Frequency),
                      style: CommonStyles.txSty_16w_fb,
                    ),
                    const SizedBox(height: 5),
                    Text(
                      tr(
                        LocaleKeys.static_data,
                      ),
                      style:
                          CommonStyles.txF14Fw5Cb.copyWith(color: Colors.white),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 5),
              SizedBox(
                width: MediaQuery.of(context).size.width,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Container(
                      width: MediaQuery.of(context).size.width,
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10.0),
                        color: Colors.black54,
                      ),
                      child: Text(
                        tr(LocaleKeys.pest),
                        style: CommonStyles.txF14Fw5Cb
                            .copyWith(color: Colors.white),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    if (PestDatalist.isNotEmpty)
                      ListView.builder(
                        shrinkWrap:
                            true, // This is crucial to ensure the ListView doesn't require a fixed height
                        physics:
                            const NeverScrollableScrollPhysics(), // Prevents the ListView from scrolling independently
                        itemCount: PestDatalist.length,
                        itemBuilder: (context, index) {
                          final pestData = PestDatalist[index];
                          return Container(
                            color: index.isEven
                                ? Colors.white
                                : const Color(0xFFDFDFDF),
                            padding: const EdgeInsets.all(4),
                            child: Column(
                              children: [
                                plotDetailsBox(
                                    label: tr(LocaleKeys.Pest),
                                    data: pestData.pest,
                                    dataTextColor: const Color(0xFFF1614E)),
                                plotDetailsBox(
                                    label: tr(LocaleKeys.pestChemicals),
                                    data: '${pestData.pestChemicals}'),
                                if (pestData.recommendedChemical != null &&
                                    pestData.recommendedChemical!.isNotEmpty)
                                  plotDetailsBox(
                                      label: tr(LocaleKeys.RecommendedChemical),
                                      data: '${pestData.recommendedChemical}'),
                                if (pestData.dosage != 0.0)
                                  plotDetailsBox(
                                      label: tr(LocaleKeys.dosage_only),
                                      data: '${pestData.dosage}kg'),
                                if (pestData.comments != null &&
                                    pestData.comments!.isNotEmpty)
                                  plotDetailsBox(
                                      label: tr(LocaleKeys.comments),
                                      data: '${pestData.comments}'),
                              ],
                            ),
                          );
                        },
                      )
                    else
                      const SizedBox.shrink(), // Or another placeholder widget
                    const SizedBox(height: 5),
                    Container(
                      width: MediaQuery.of(context).size.width,
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10.0),
                        color: Colors.black54,
                      ),
                      child: Text(
                        tr(LocaleKeys.deases),
                        style: CommonStyles.txF14Fw5Cb
                            .copyWith(color: Colors.white),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    if (DiseaseDatalist.isNotEmpty)
                      ListView.builder(
                        shrinkWrap:
                            true, // This is crucial to ensure the ListView doesn't require a fixed height
                        physics:
                            const NeverScrollableScrollPhysics(), // Prevents the ListView from scrolling independently
                        itemCount: DiseaseDatalist.length,
                        itemBuilder: (context, index) {
                          final pestData = DiseaseDatalist[index];
                          return Container(
                            color: index.isEven
                                ? Colors.white
                                : const Color(0xFFDFDFDF),
                            padding: const EdgeInsets.all(4),
                            child: Column(
                              children: [
                                plotDetailsBox(
                                  label: tr(LocaleKeys.disease),
                                  data: pestData.disease,
                                ),
                                plotDetailsBox(
                                    label: tr(LocaleKeys.pestChemicals),
                                    data: '${pestData.chemical}'),
                                if (pestData.dosage != 0.0)
                                  plotDetailsBox(
                                      label: tr(LocaleKeys.dosage_only),
                                      data: '${pestData.dosage}kg'),
                                if (pestData.recommendedChemical != null &&
                                    pestData.recommendedChemical != 'null')
                                  plotDetailsBox(
                                      label: tr(LocaleKeys.UOMName),
                                      data: '${pestData.recommendedChemical}'),
                                if (pestData.comments != null &&
                                    pestData.comments!.isNotEmpty)
                                  plotDetailsBox(
                                      label: tr(LocaleKeys.comments),
                                      data: '${pestData.comments}'),
                              ],
                            ),
                          );
                        },
                      )
                    else
                      const SizedBox.shrink(),

                    const SizedBox(height: 5),
                    Container(
                      width: MediaQuery.of(context).size.width,
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10.0),
                        color: Colors.black54,
                      ),
                      child: Text(
                        tr(LocaleKeys.nut_repo),
                        style: CommonStyles.txF14Fw5Cb
                            .copyWith(color: Colors.white),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    if (NutrientDatalist.isNotEmpty)
                      ListView.builder(
                        shrinkWrap:
                            true, // This is crucial to ensure the ListView doesn't require a fixed height
                        physics:
                            const NeverScrollableScrollPhysics(), // Prevents the ListView from scrolling independently
                        itemCount: NutrientDatalist.length,
                        itemBuilder: (context, index) {
                          final pestData = NutrientDatalist[index];

                          String formattedDate = DateFormat('dd-MM-yyyy')
                              .format(pestData.registeredDate);

                          return Container(
                            color: index.isEven
                                ? Colors.white
                                : const Color(0xFFDFDFDF),
                            padding: const EdgeInsets.all(4),
                            child: Column(
                              children: [
                                plotDetailsBox(
                                    label:
                                        tr(LocaleKeys.NutrientDeficiencyName),
                                    data: pestData.nutrient),
                                //  plotDetailsBox(label: tr(LocaleKeys.Nameofchemicalapplied), data: '${pestData.chemical}'),
                                if (pestData.recommendedFertilizer != null &&
                                    pestData.recommendedFertilizer != 'null')
                                  plotDetailsBox(
                                      label:
                                          tr(LocaleKeys.recommended_ertilizer),
                                      data:
                                          '${pestData.recommendedFertilizer}'),
                                if (pestData.dosage != 0.0)
                                  plotDetailsBox(
                                      label: tr(LocaleKeys.dosage_only),
                                      data: '${pestData.dosage}kg'),
                                plotDetailsBox(
                                    label: tr(LocaleKeys.registeredDate),
                                    data: formattedDate),
                                if (pestData.comments != null &&
                                    pestData.comments != 'null')
                                  plotDetailsBox(
                                      label: tr(LocaleKeys.comments),
                                      data: '${pestData.comments}'),
                              ],
                            ),
                          );
                        },
                      )
                    else
                      const SizedBox.shrink(),

                    const SizedBox(height: 5),
                    Container(
                      width: MediaQuery.of(context).size.width,
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10.0),
                        color: Colors.black54,
                      ),
                      child: Text(
                        tr(LocaleKeys.irrigation),
                        style: CommonStyles.txF14Fw5Cb
                            .copyWith(color: Colors.white),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    if (plotIrrigationlist.isNotEmpty)
                      ListView.builder(
                        shrinkWrap:
                            true, // This is crucial to ensure the ListView doesn't require a fixed height
                        physics:
                            const NeverScrollableScrollPhysics(), // Prevents the ListView from scrolling independently
                        itemCount: plotIrrigationlist.length,
                        itemBuilder: (context, index) {
                          final pestData = plotIrrigationlist[index];

                          String formattedDate = DateFormat('dd-MM-yyyy')
                              .format(pestData.updatedbyDate);
                          // // String formattedDate = formatDate(formattedDate1, inputFormat1, inputFormat2, outputFormat);
                          // DateTime parsedDate = DateTime.parse(formattedDate1);
                          //
                          // // Format the date
                          // String formattedDate = DateFormat('dd-MM-yyyy').format(parsedDate);
                          // DateFormat inputFormat1 = DateFormat("yyyy-MM-dd'T'HH:mm:ss");
                          // DateFormat inputFormat2 = DateFormat("yyyy-MM-dd HH:mm:ss");
                          // DateFormat outputFormat = DateFormat("dd-MM-yyyy",'en');
                          //
                          // //String? cmlastvisitdate =updated!; // Example date
                          // String formattedDate = formatDate(formattedDate1, inputFormat1, inputFormat2, outputFormat);

                          return Container(
                            color: index.isEven
                                ? Colors.white
                                : const Color(0xFFDFDFDF),
                            padding: const EdgeInsets.all(4),
                            child: Column(
                              children: [
                                plotDetailsBox(
                                    label: tr(LocaleKeys.irrigation_name),
                                    data: pestData.irrigaationType,
                                    dataTextColor: const Color(0xFFF1614E)),
                                plotDetailsBox(
                                    label: tr(LocaleKeys.updated_by),
                                    data: formattedDate),
                                //  plotDetailsBox(label: tr(LocaleKeys.Nameofchemicalapplied), data: '${pestData.chemical}'),
                              ],
                            ),
                          );
                        },
                      )
                    else
                      const SizedBox.shrink(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  //
  // @override
  // Widget build(BuildContext context) {
  //   return Scaffold(
  //     appBar: CustomAppBar(title: tr(LocaleKeys.str_select_plot)),
  //     body:  Container(
  //       padding: EdgeInsets.all(10),
  //       child:  Column(
  //         crossAxisAlignment: CrossAxisAlignment.start,
  //         mainAxisAlignment: MainAxisAlignment.start,
  //         children: [
  //           CropPlotDetails(
  //             plotdata: widget.plotdata,
  //             index: 0,
  //             isIconVisible: false,
  //           ),
  //           const SizedBox(height: 10),
  //           Container(
  //             padding:  EdgeInsets.all(10),
  //             decoration: BoxDecoration(
  //               borderRadius: BorderRadius.circular(10.0),
  //               color: Colors.black54,
  //             ),
  //             child: Column(
  //               mainAxisAlignment: MainAxisAlignment.center,
  //               children: [
  //                 custombox(label: tr(LocaleKeys.treesAppearance), data: '$treesAppearance', dataTextColor: CommonStyles.whiteColor, labelTextColor: CommonStyles.whiteColor),
  //                 custombox(label: tr(LocaleKeys.plamsCount), data: '$plamscount', dataTextColor: CommonStyles.whiteColor, labelTextColor: CommonStyles.whiteColor),
  //                 custombox(label: tr(LocaleKeys.Frequency_harvest), data: '$frequencyofharvest', dataTextColor: CommonStyles.whiteColor, labelTextColor: CommonStyles.whiteColor),
  //                 custombox(
  //                     label: tr(LocaleKeys.last_date), data: '${formatDateString(updated) ?? ''}', dataTextColor: CommonStyles.whiteColor, labelTextColor: CommonStyles.whiteColor),
  //                 Text(
  //                   tr(LocaleKeys.Frequency),
  //                   style: CommonStyles.txSty_16w_fb,
  //                 ),
  //                 const SizedBox(height: 5),
  //                 Text(
  //                   tr(
  //                     LocaleKeys.static_data,
  //                   ),
  //                   style: CommonStyles.txF14Fw5Cb.copyWith(color: Colors.white),
  //                 ),
  //               ],
  //             ),
  //           ),
  //           SizedBox(height: 5),
  //           Container(
  //             width: MediaQuery.of(context).size.width,
  //
  //             child: Column(
  //               crossAxisAlignment: CrossAxisAlignment.start,
  //               mainAxisAlignment: MainAxisAlignment.start,
  //               children: [
  //                 Container(
  //                   width: MediaQuery.of(context).size.width,
  //                   padding: const EdgeInsets.all(10),
  //                   decoration: BoxDecoration(
  //                     borderRadius: BorderRadius.circular(10.0),
  //                     color: Colors.black54,
  //                   ),
  //                   child: Text(
  //                     'Pest Details',
  //                     style: CommonStyles.txF14Fw5Cb.copyWith(color: Colors.white),
  //                     textAlign: TextAlign.center,
  //                   ),
  //                 ),
  //                 Container(
  //                   // width: MediaQuery.of(context).size.width,
  //               //   height: MediaQuery.of(context).size.height/3.5,
  //                   //color: Colors.white,
  //                   child: ListView.builder(
  //                       itemCount: PestDatalist.length,shrinkWrap: true,
  //                       itemBuilder: (context, index) {
  //                         return IntrinsicHeight(
  //                             child: Column(
  //                               children: [
  //                                 plotDetailsBox(label: tr(LocaleKeys.Pest), data: '${PestDatalist[index].pest}', dataTextColor: Color(0xFFF1614E)),
  //                                 plotDetailsBox(label: tr(LocaleKeys.pestChemicals), data: '${PestDatalist[index].pestChemicals}'),
  //                                 if (PestDatalist[index].recommendedChemical != null && PestDatalist[index].recommendedChemical!.isNotEmpty)
  //                                   plotDetailsBox(label: tr(LocaleKeys.RecommendedChemical), data: '${PestDatalist[index].recommendedChemical}'),
  //                                 if (PestDatalist[index].recommendedChemical == null || PestDatalist[index].recommendedChemical!.isEmpty) SizedBox.shrink(),
  //                                 PestDatalist[index].dosage != null && PestDatalist[index].dosage != 0.0
  //                                     ? plotDetailsBox(label: tr(LocaleKeys.dosage_only), data: '${PestDatalist[index].dosage}kg')
  //                                     : SizedBox.shrink(),
  //                                 PestDatalist[index].comments != null && PestDatalist[index].comments != ''
  //                                     ? plotDetailsBox(label: tr(LocaleKeys.comments), data: '${PestDatalist[index].comments}')
  //                                     : SizedBox.shrink(),
  //                               ],
  //                             ));
  //                       }),
  //                 )
  //               ],
  //             ),
  //           )
  //         ],
  //       ),
  //     )
  //
  //   );
  // }

  Widget plotDetailsBox(
      {required String label, required String data, Color? dataTextColor}) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
                flex: 4,
                child: Text(
                  label,
                  style: CommonStyles.txSty_14b_f5,
                )),
            const Expanded(
              flex: 1,
              child: Text(':', style: CommonStyles.txSty_14b_f5),
            ),
            Expanded(
                flex: 4,
                child: Text(
                  data,
                  style: CommonStyles.txSty_14b_f5.copyWith(
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
