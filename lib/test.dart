import 'dart:convert';
import 'package:akshaya_flutter/common_utils/common_widgets.dart';
import 'package:akshaya_flutter/common_utils/shared_prefs_keys.dart';
import 'package:akshaya_flutter/models/cropmaintenancevisit_model.dart';
import 'package:http/http.dart' as http;
import 'package:akshaya_flutter/common_utils/api_config.dart';
import 'package:akshaya_flutter/common_utils/common_styles.dart';
import 'package:akshaya_flutter/common_utils/custom_appbar.dart';
import 'package:akshaya_flutter/common_utils/custom_box.dart';
import 'package:akshaya_flutter/localization/locale_keys.dart';
import 'package:akshaya_flutter/models/plot_details_model.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TestScreen extends StatefulWidget {
  final PlotDetailsModel plotdata;

  const TestScreen({super.key, required this.plotdata});

  @override
  State<TestScreen> createState() => _TestScreen();
}

class _TestScreen extends State<TestScreen> {
  late Future<CropMaintanceVisit> futureData;

  @override
  void initState() {
    super.initState();
    futureData = getCropMaintenanceHistoryDetails();
    // fetchcropmaintencelist();
  }

  Future<CropMaintanceVisit> getCropMaintenanceHistoryDetails() async {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() {
        CommonStyles.showHorizontalDotsLoadingDialog(context);
      });
    });
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final farmerCode = prefs.getString(SharedPrefsKeys.farmerCode);
    final apiUrl =
        '$baseUrl$getCropMaintenanceHistoryDetailsByPlotCode/${widget.plotdata.plotcode}/$farmerCode';

    print('cropApi: $apiUrl');
    try {
      final jsonResponse = await http.get(Uri.parse(apiUrl));

      WidgetsBinding.instance.addPostFrameCallback((_) {
        setState(() {
          CommonStyles.hideHorizontalDotsLoadingDialog(context);
        });
      });
      if (jsonResponse.statusCode == 200) {
        final response = cropMaintanceVisitFromJson(jsonResponse.body);
        return response;
      } else {
        throw Exception('Failed to fetch data');
      }
    } catch (e) {
      print('catch: $e');
      rethrow;
    }
  }

/* 
  Future<void> fetchcropmaintencelist() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final farmerCode = prefs.getString(SharedPrefsKeys.farmerCode);
    final apiUrl =
        '$baseUrl$getCropMaintenanceHistoryDetailsByPlotCode/${widget.plotdata.plotcode}/$farmerCode';

    print('Api URL: $apiUrl');
    try {
      final jsonResponse = await http.get(Uri.parse(apiUrl));
      setState(() {
        CommonStyles.hideHorizontalDotsLoadingDialog(context);
      });
      if (jsonResponse.statusCode == 200) {
        final response = jsonDecode(jsonResponse.body);

        if (response['healthPlantationData'] != null) {
          var healthPlantationData = response['healthPlantationData'];
          var uproomtementdata = response['uprootmentData'];

          var frequency = response['frequencyOfHarvest'];

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
              treesAppearance = treessapprearance;
              print('Trees Appearance: $treesAppearance');
              plamscount = plamscount;
              frequencyofharvest = frequency;
              pestDatalist =
                  pestdatalist.map((item) => PestData.fromJson(item)).toList();
              diseaseDatalist = diseasedatalist
                  .map((item) => DiseaseData.fromJson(item))
                  .toList();
              nutrientDatalist = nutrientdatalist
                  .map((item) => NutrientData.fromJson(item))
                  .toList();
              plotIrrigationlist = plotIrrigationdatalist
                  .map((item) => PlotIrrigation.fromJson(item))
                  .toList();
            });
          }
        } else {
          throw Exception('healthPlantationData is null');
        }
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
 */
  String formatDate(String dateStr, DateFormat inputFormat1,
      DateFormat inputFormat2, DateFormat outputFormat) {
    DateTime? date;
    print(
        'Error parsing date: $dateStr | inputFormat1: $inputFormat1 | inputFormat2: $inputFormat2 | outputFormat: $outputFormat');
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
    return Scaffold(
      backgroundColor: CommonStyles.screenBgColor,
      appBar: CustomAppBar(title: tr(LocaleKeys.crop)),
      body: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.all(12),
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
              FutureBuilder(
                future: futureData,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const SizedBox();
                  } else if (snapshot.hasError) {
                    return healthPlantationError();
                  } else {
                    final cropData = snapshot.data as CropMaintanceVisit;

                    if (cropData.healthPlantationData == null) {
                      return const SizedBox();
                    } else {
                      final healthPlantationData =
                          cropData.healthPlantationData;
                      return healthPlantation(cropData);
                    }
                  }
                },
              ),
              const SizedBox(height: 10),
              FutureBuilder(
                future: futureData,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const SizedBox();
                  } else if (snapshot.hasError) {
                    return const SizedBox();
                    /* return Text(
                      snapshot.error
                          .toString()
                          .replaceFirst('Exception: ', ''),
                      style: CommonStyles.txStyF16CpFF6); */
                  } else {
                    final cropData = snapshot.data as CropMaintanceVisit;

                    if (cropData.diseaseData != null &&
                        cropData.diseaseData!.isNotEmpty) {
                      final diseaseData = cropData.diseaseData![0];
                      return diseaseItem(context, diseaseData);
                    } else {
                      return const SizedBox();
                    }
                  }
                },
              ),
              const SizedBox(height: 10),
              FutureBuilder(
                future: futureData,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const SizedBox();
                  } else if (snapshot.hasError) {
                    return const SizedBox();
                    /* return Text(
                      snapshot.error
                          .toString()
                          .replaceFirst('Exception: ', ''),
                      style: CommonStyles.txStyF16CpFF6); */
                  } else {
                    final cropData = snapshot.data as CropMaintanceVisit;

                    if (cropData.nutrientData != null &&
                        cropData.nutrientData!.isNotEmpty) {
                      final nutrientData = cropData.nutrientData![0];
                      return nutrientItem(context, nutrientData);
                    } else {
                      return const SizedBox();
                    }
                  }
                },
              ),
              const SizedBox(height: 10),
              FutureBuilder(
                future: futureData,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const SizedBox();
                  } else if (snapshot.hasError) {
                    return const SizedBox();
                    /* return Text(
                      snapshot.error
                          .toString()
                          .replaceFirst('Exception: ', ''),
                      style: CommonStyles.txStyF16CpFF6); */
                  } else {
                    final cropData = snapshot.data as CropMaintanceVisit;

                    if (cropData.plotIrrigation != null &&
                        cropData.plotIrrigation!.isNotEmpty) {
                      final plotIrrigation = cropData.plotIrrigation![0];
                      return plotIrrigationItem(context, plotIrrigation);
                    } else {
                      return const SizedBox();
                    }
                  }
                },
              ),

              /* if (pestDatalist.isNotEmpty)
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
                          style: CommonStyles.txStyF14CwFF6,
                          textAlign: TextAlign.center,
                        ),
                      ),
                      if (pestDatalist.isNotEmpty)
                        ListView.builder(
                          shrinkWrap:
                              true, // This is crucial to ensure the ListView doesn't require a fixed height
                          physics:
                              const NeverScrollableScrollPhysics(), // Prevents the ListView from scrolling independently
                          itemCount: pestDatalist.length,
                          itemBuilder: (context, index) {
                            final pestData = pestDatalist[index];
                            return Container(
                              padding: const EdgeInsets.all(4),
                              child: Column(
                                children: [
                                  plotDetailsBox(
                                    label: tr(LocaleKeys.Pest),
                                    data: pestData.pest,
                                  ),
                                  plotDetailsBox(
                                      label: tr(LocaleKeys.pestChemicals),
                                      data: '${pestData.pestChemicals}'),
                                  if (pestData.recommendedChemical != null &&
                                      pestData.recommendedChemical!.isNotEmpty)
                                    plotDetailsBox(
                                        label:
                                            tr(LocaleKeys.RecommendedChemical),
                                        data:
                                            '${pestData.recommendedChemical}'),
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
                        const SizedBox
                            .shrink(), // Or another placeholder widget
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
                      if (diseaseDatalist.isNotEmpty)
                        ListView.builder(
                          shrinkWrap:
                              true, // This is crucial to ensure the ListView doesn't require a fixed height
                          physics:
                              const NeverScrollableScrollPhysics(), // Prevents the ListView from scrolling independently
                          itemCount: diseaseDatalist.length,
                          itemBuilder: (context, index) {
                            final pestData = diseaseDatalist[index];
                            return Container(
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
                                        data:
                                            '${pestData.recommendedChemical}'),
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
                      if (nutrientDatalist.isNotEmpty)
                        ListView.builder(
                          shrinkWrap:
                              true, // This is crucial to ensure the ListView doesn't require a fixed height
                          physics:
                              const NeverScrollableScrollPhysics(), // Prevents the ListView from scrolling independently
                          itemCount: nutrientDatalist.length,
                          itemBuilder: (context, index) {
                            final pestData = nutrientDatalist[index];

                            String formattedDate = DateFormat('dd-MM-yyyy')
                                .format(pestData.registeredDate);

                            return Container(
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
                                        label: tr(
                                            LocaleKeys.recommended_ertilizer),
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

                            return Container(
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
             */
            ],
          ),
        ),
      ),
    );
  }

  Widget diseaseItem(BuildContext context, DiseaseDatum diseaseData) {
    return Column(
      children: [
        Container(
          width: MediaQuery.of(context).size.width,
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10.0),
            color: CommonStyles.labourTemplateColor,
          ),
          child: Text(
            tr(LocaleKeys.deases),
            style: CommonStyles.txStyF16CwFF6,
            textAlign: TextAlign.center,
          ),
        ),
        const SizedBox(height: 5),
        Container(
          width: MediaQuery.of(context).size.width,
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10.0),
            color: Colors.white,
          ),
          child: Column(
            children: [
              CommonWidgets.commonRow(
                label: tr(LocaleKeys.disease),
                data: diseaseData.disease ?? '',
                dataTextColor: CommonStyles.primaryTextColor,
              ),
              CommonWidgets.commonRow(
                  label: tr(LocaleKeys.Chemical),
                  data: diseaseData.chemical ?? '')
            ],
          ),
        ),
      ],
    );
  }

  Widget nutrientItem(BuildContext context, NutrientDatum nutrient) {
    return Column(
      children: [
        Container(
          width: MediaQuery.of(context).size.width,
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10.0),
            color: CommonStyles.labourTemplateColor,
          ),
          child: Text(
            tr(LocaleKeys.nut_repo),
            style: CommonStyles.txStyF16CwFF6,
            textAlign: TextAlign.center,
          ),
        ),
        const SizedBox(height: 5),
        Container(
          width: MediaQuery.of(context).size.width,
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10.0),
            color: Colors.white,
          ),
          child: Column(
            children: [
              if (nutrient.nutrient != null)
                CommonWidgets.commonRow(
                  label: tr(LocaleKeys.NutrientDeficiencyName),
                  data: nutrient.nutrient ?? '',
                  dataTextColor: CommonStyles.primaryTextColor,
                ),
              if (nutrient.chemical != null)
                CommonWidgets.commonRow(
                    label: tr(LocaleKeys.Nameofchemicalapplied),
                    data: nutrient.chemical ?? ''),
              if (nutrient.recommendedFertilizer != null)
                CommonWidgets.commonRow(
                    label: tr(LocaleKeys.RecommendedChemical),
                    data: nutrient.recommendedFertilizer ?? ''),
              if (nutrient.dosage != null && nutrient.uomName != null)
                CommonWidgets.commonRow(
                    label: tr(LocaleKeys.dosage_only),
                    data: '${nutrient.dosage} ${nutrient.uomName}'),
              if (nutrient.comments != null)
                CommonWidgets.commonRow(
                    label: tr(LocaleKeys.comments),
                    data: nutrient.comments ?? ''),
            ],
          ),
        ),
      ],
    );
  }

  Widget plotIrrigationItem(BuildContext context, PlotIrrigation nutrient) {
    return Column(
      children: [
        Container(
          width: MediaQuery.of(context).size.width,
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10.0),
            color: CommonStyles.labourTemplateColor,
          ),
          child: Text(
            tr(LocaleKeys.irrigation),
            style: CommonStyles.txStyF16CwFF6,
            textAlign: TextAlign.center,
          ),
        ),
        const SizedBox(height: 5),
        Container(
          width: MediaQuery.of(context).size.width,
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10.0),
            color: Colors.white,
          ),
          child: Column(
            children: [
              if (nutrient.irrigaationType != null)
                CommonWidgets.commonRow(
                  label: tr(LocaleKeys.irrigation_name),
                  data: nutrient.irrigaationType ?? '',
                  dataTextColor: CommonStyles.primaryTextColor,
                ),
              if (nutrient.updatedBy != null)
                CommonWidgets.commonRow(
                    label: tr(LocaleKeys.updated_by),
                    data: nutrient.updatedBy ?? ''),
              /*  if (nutrient.recommendedFertilizer != null)
                CommonWidgets.commonRow(
                    label: tr(LocaleKeys.RecommendedChemical),
                    data: nutrient.recommendedFertilizer ?? ''),
              if (nutrient.dosage != null)
                CommonWidgets.commonRow(
                    label: tr(LocaleKeys.dosage_only),
                    data: '${nutrient.dosage} ${nutrient.uomName}'),
              if (nutrient.comments != null)
                CommonWidgets.commonRow(
                    label: tr(LocaleKeys.comments), data: nutrient.comments ?? ''), */
            ],
          ),
        ),
      ],
    );
  }

  Widget healthPlantation(CropMaintanceVisit cropData) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10.0),
        color: CommonStyles.labourTemplateColor,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          custombox(
            label: tr(LocaleKeys.treesAppearance),
            data: cropData.healthPlantationData?.treesAppearance,
          ),
          custombox(
            label: tr(LocaleKeys.plamsCount),
            data: '${cropData.uprootmentData?.plamsCount}',
          ),
          custombox(
            label: tr(LocaleKeys.Frequency_harvest),
            data: '${cropData.frequencyOfHarvest!.toInt()} Days',
          ),
          custombox(
            label: tr(LocaleKeys.last_date),
            data: CommonStyles.formatDate(
                cropData.healthPlantationData?.updatedDate),
          ),
          Text(
            tr(LocaleKeys.Frequency),
            style: CommonStyles.txStyF16CwFF6,
          ),
          const SizedBox(height: 5),
          Text(
            tr(LocaleKeys.static_data),
            style: CommonStyles.txStyF14CwFF6,
          ),
        ],
      ),
    );
  }

  Widget healthPlantationError() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10.0),
        color: CommonStyles.labourTemplateColor,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          custombox(
            label: tr(LocaleKeys.treesAppearance),
            data: '',
          ),
          custombox(
            label: tr(LocaleKeys.plamsCount),
            data: '',
          ),
          custombox(
            label: tr(LocaleKeys.Frequency_harvest),
            data: '',
          ),
          custombox(
            label: tr(LocaleKeys.last_date),
            data: '',
          ),
          Text(
            tr(LocaleKeys.Frequency),
            style: CommonStyles.txStyF16CwFF6,
          ),
          const SizedBox(height: 5),
          Text(
            tr(LocaleKeys.static_data),
            style: CommonStyles.txStyF14CwFF6,
          ),
        ],
      ),
    );
  }

  Widget plotDetailsBox(
      {required String label,
      required String data,
      bool isSpace = true,
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
              child: Text(data, style: CommonStyles.txStyF14CbFF6),
            ),
          ],
        ),
        if (isSpace) const SizedBox(height: 8),
      ],
    );
  }
}

class CropPlotDetails extends StatelessWidget {
  final PlotDetailsModel plotdata;
  final int index;
  final void Function()? onTap;
  final bool isIconVisible;
  final Color? dataTextColor;

  const CropPlotDetails(
      {super.key,
      required this.plotdata,
      required this.index,
      this.onTap,
      this.isIconVisible = true,
      this.dataTextColor = CommonStyles.primaryTextColor});

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
      // padding: const EdgeInsets.symmetric(vertical: 10).copyWith(
      //   left: 10,
      // ),
      // margin: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: Colors.transparent,
      ),
      child: Row(
        children: [
          Expanded(child: plotCard(df, year)),
          if (isIconVisible) const Icon(Icons.arrow_forward_ios_rounded),
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
        ),
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
          isSpace: false,
        ),
      ],
    );
  }

  Widget plotDetailsBox({
    required String label,
    required String data,
    bool isSpace = true,
  }) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
                flex: 5,
                child: Text(
                  label,
                  style: CommonStyles.txStyF14CbFF6.copyWith(
                    fontSize: 14.3,
                  ),
                )),
            Expanded(
              flex: 6,
              child: Text(
                data,
                style: CommonStyles.txStyF14CbFF6.copyWith(
                  fontSize: 14.3,
                ),
              ),
            ),
          ],
        ),
        if (isSpace) const SizedBox(height: 8),
      ],
    );
  }
}
