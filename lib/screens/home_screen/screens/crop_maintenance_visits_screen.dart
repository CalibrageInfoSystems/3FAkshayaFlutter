import 'dart:convert';
import 'package:akshaya_flutter/models/CropData.dart';
import 'package:akshaya_flutter/screens/home_screen/screens/plot_selection_screen.dart';
import 'package:http/http.dart' as http;
import 'package:akshaya_flutter/common_utils/api_config.dart';
import 'package:akshaya_flutter/common_utils/common_styles.dart';
import 'package:akshaya_flutter/common_utils/custom_appbar.dart';
import 'package:akshaya_flutter/common_utils/custom_box.dart';
import 'package:akshaya_flutter/common_utils/shared_prefs_keys.dart';
import 'package:akshaya_flutter/localization/locale_keys.dart';
import 'package:akshaya_flutter/models/plot_details_model.dart';
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
    // fetchcropmaintencelist();
  }

  Future<void> fetchcropmaintencelist() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? userId = prefs.getString(SharedPrefsKeys.farmerCode);

    String plotcode = widget.plotdata.plotcode!;

    final apiUrl =
        '$baseUrl$getCropMaintenanceHistoryDetailsByPlotCode/APT00123174004/APEGT13119166001';

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
    /*  DateFormat inputFormat1 = DateFormat("yyyy-MM-dd'T'HH:mm:ss");
    DateFormat inputFormat2 = DateFormat("yyyy-MM-dd HH:mm:ss");
    DateFormat outputFormat = DateFormat("dd-MM-yyyy", 'en');

    String formattedDate =
        formatDate(updated, inputFormat1, inputFormat2, outputFormat); */
    return Scaffold(
      backgroundColor: CommonStyles.screenBgColor,
      appBar: CustomAppBar(title: tr(LocaleKeys.crop)),
      body: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12).copyWith(top: 12),
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
                  color: CommonStyles.dropdownListBgColor,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    custombox(
                      label: tr(LocaleKeys.treesAppearance),
                      data: treesAppearance,
                    ),
                    custombox(
                      label: tr(LocaleKeys.plamsCount),
                      data: '$plamscount',
                    ),
                    custombox(
                      label: tr(LocaleKeys.Frequency_harvest),
                      data: '$frequencyofharvest',
                    ),
                    custombox(
                      label: tr(LocaleKeys.last_date),
                      data: formattedDate ?? '',
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
              ),
              const SizedBox(height: 10),
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
            ],
          ),
        ),
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
      padding: const EdgeInsets.symmetric(vertical: 10).copyWith(
        left: 10,
      ),
      margin: const EdgeInsets.symmetric(vertical: 10),
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
                  style: CommonStyles.txStyF14CbFF6,
                )),
            Expanded(
              flex: 6,
              child: Text(
                data,
                style: CommonStyles.txStyF14CbFF6,
              ),
            ),
          ],
        ),
        if (isSpace) const SizedBox(height: 8),
      ],
    );
  }
}
