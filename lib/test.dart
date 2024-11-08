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

  List<NutrientDatum> testData = [
    NutrientDatum(
      plotCode: "APT01323042003",
      isPreviousNutrientDeficiency: "NO",
      isProblemRectified: "NO",
      isCurrentNutrientDeficiency: "NO",
      nutrientId: 221,
      nutrient: "No Nutrient Deficiency",
      chemicalId: null,
      chemical: null,
      applyNutrientFrequencyTypeId: null,
      applyFertilizerFrequency: null,
      isResultSeen: "NO",
      comments: null,
      isActive: "YES",
      updatedDate: DateTime.parse("2024-11-04T15:17:36"),
      registeredDate: DateTime.parse("2024-11-04T15:17:36"),
      dosage: 0.0,
      uomName: null,
      recommendedFertilizer: null,
      cropMaintenanceCode: "CROPT013APT01323042003218-1",
    ),
    NutrientDatum(
      plotCode: "APT01423052004",
      isPreviousNutrientDeficiency: "YES",
      isProblemRectified: "YES",
      isCurrentNutrientDeficiency: "NO",
      nutrientId: 145,
      nutrient: "Nitrogen Deficiency",
      chemicalId: 102,
      chemical: "Urea",
      applyNutrientFrequencyTypeId: 3,
      applyFertilizerFrequency: "Monthly",
      isResultSeen: "YES",
      comments: "Rectified using urea application",
      isActive: "YES",
      updatedDate: DateTime.parse("2024-11-05T10:22:15"),
      registeredDate: DateTime.parse("2024-11-05T10:22:15"),
      dosage: 5.0,
      uomName: "Kg/Ha",
      recommendedFertilizer: "Urea 46%",
      cropMaintenanceCode: "CROPT014APT01423052004145-2",
    ),
    NutrientDatum(
      plotCode: "APT01523062005",
      isPreviousNutrientDeficiency: "NO",
      isProblemRectified: "NO",
      isCurrentNutrientDeficiency: "YES",
      nutrientId: 167,
      nutrient: "Potassium Deficiency",
      chemicalId: 109,
      chemical: "Potash",
      applyNutrientFrequencyTypeId: 2,
      applyFertilizerFrequency: "Bi-weekly",
      isResultSeen: "NO",
      comments: "Signs of deficiency noticed",
      isActive: "YES",
      updatedDate: DateTime.parse("2024-11-06T14:45:00"),
      registeredDate: DateTime.parse("2024-11-06T14:45:00"),
      dosage: 3.0,
      uomName: "Kg/Ha",
      recommendedFertilizer: "Muriate of Potash",
      cropMaintenanceCode: "CROPT015APT01523062005167-3",
    ),
  ];

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
              //MARK: healthPlantation Item
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

              //MARK: pest Item
              FutureBuilder(
                future: futureData,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const SizedBox();
                  } else if (snapshot.hasError) {
                    return const SizedBox();
                  } else {
                    final cropData = snapshot.data as CropMaintanceVisit;

                    if (cropData.pestData != null &&
                        cropData.pestData!.isNotEmpty) {
                      return Column(
                        children: [
                          const SizedBox(height: 10),
                          // pestDataItem(context, pestData),

                          ListView.separated(
                              itemCount: cropData.nutrientData!.length,
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              separatorBuilder: (context, index) =>
                                  const SizedBox(height: 10),
                              itemBuilder: (context, index) {
                                final pestData = cropData.pestData![index];
                                return pestDataItem(context, pestData);
                              })
                        ],
                      );
                    } else {
                      return const SizedBox();
                    }
                  }
                },
              ),

              //MARK: disease Item
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
                      return Column(
                        children: [
                          const SizedBox(height: 10),
                          // diseaseItem(context, diseaseData),

                          ListView.separated(
                              itemCount: cropData.nutrientData!.length,
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              separatorBuilder: (context, index) =>
                                  const SizedBox(height: 10),
                              itemBuilder: (context, index) {
                                final diseaseData =
                                    cropData.diseaseData![index];
                                return diseaseItem(context, diseaseData);
                              })
                        ],
                      );
                    } else {
                      return const SizedBox();
                    }
                  }
                },
              ),
              //MARK: nutrient Item
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
                      return Column(
                        children: [
                          const SizedBox(height: 10),
                          /* ListView.builder(
                              itemCount: cropData.nutrientData!.length,
                              shrinkWrap: true,
                              itemBuilder: (context, index) {
                                final nutrientData =
                                    cropData.nutrientData![index];
                                return nutrientItem(context, nutrientData);
                              }) */

                          ListView.separated(
                              itemCount: cropData.nutrientData!.length,
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              separatorBuilder: (context, index) =>
                                  const SizedBox(height: 10),
                              itemBuilder: (context, index) {
                                final nutrientData =
                                    cropData.nutrientData![index];
                                return nutrientItem(context, nutrientData);
                              })
                        ],
                      );
                    } else {
                      return const SizedBox();
                    }
                  }
                },
              ),

              //MARK: Fertilizer Details Item
              FutureBuilder(
                future: futureData,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const SizedBox();
                  } else if (snapshot.hasError) {
                    return const SizedBox();
                  } else {
                    final cropData = snapshot.data as CropMaintanceVisit;

                    if (cropData.fertilizerRecommendationDetails != null &&
                        cropData.fertilizerRecommendationDetails!.isNotEmpty) {
                      return Column(
                        children: [
                          const SizedBox(height: 10),
                          // fertilizerDataItem(context, fertilizerData),

                          ListView.separated(
                              itemCount: cropData.nutrientData!.length,
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              separatorBuilder: (context, index) =>
                                  const SizedBox(height: 10),
                              itemBuilder: (context, index) {
                                final fertilizerData = cropData
                                    .fertilizerRecommendationDetails![index];
                                return fertilizerDataItem(
                                    context, fertilizerData);
                              })
                        ],
                      );
                    } else {
                      return const SizedBox();
                    }
                  }
                },
              ),

              //MARK: Irrigation Item
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
                      return Column(
                        children: [
                          const SizedBox(height: 10),
                          // plotIrrigationItem(context, plotIrrigation),

                          ListView.separated(
                              itemCount: cropData.nutrientData!.length,
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              separatorBuilder: (context, index) =>
                                  const SizedBox(height: 10),
                              itemBuilder: (context, index) {
                                final plotIrrigation =
                                    cropData.plotIrrigation![index];
                                return plotIrrigationItem(
                                    context, plotIrrigation);
                              })
                        ],
                      );
                    } else {
                      return const SizedBox();
                    }
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget fertilizerDataItem(
      BuildContext context, FertilizerRecommendationDetail fertilizerData) {
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
            tr(LocaleKeys.pest),
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
              if (fertilizerData.recommendedFertilizerName != null)
                CommonWidgets.commonRow(
                  label: tr(LocaleKeys.recommended_ertilizer),
                  data: '${fertilizerData.recommendedFertilizerName}',
                  dataTextColor: CommonStyles.primaryTextColor,
                  isSpace: (fertilizerData.dosage != null &&
                          fertilizerData.uomName != null)
                      ? true
                      : false,
                ),
              if (fertilizerData.dosage != null &&
                  fertilizerData.uomName != null)
                CommonWidgets.commonRow(
                  label: tr(LocaleKeys.dosage_only),
                  data: '${fertilizerData.dosage} ${fertilizerData.uomName}',
                  isSpace: (fertilizerData.comments != null) ? true : false,
                ),
              if (fertilizerData.comments != null)
                CommonWidgets.commonRow(
                  label: tr(LocaleKeys.comments),
                  data: '${fertilizerData.comments}',
                  isSpace: false,
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget pestDataItem(BuildContext context, PestDatum pestData) {
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
            tr(LocaleKeys.pest),
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
              if (pestData.pest != null)
                CommonWidgets.commonRow(
                  label: tr(LocaleKeys.Pest),
                  data: '${pestData.pest}',
                  dataTextColor: CommonStyles.primaryTextColor,
                  isSpace: (pestData.pestChemicals != null) ? true : false,
                ),
              if (pestData.pestChemicals != null)
                CommonWidgets.commonRow(
                  label: tr(LocaleKeys.pestChemicals),
                  data: '${pestData.pestChemicals}',
                  isSpace:
                      (pestData.recommendedChemical != null) ? true : false,
                ),
              if (pestData.recommendedChemical != null)
                CommonWidgets.commonRow(
                  label: tr(LocaleKeys.RecommendedChemical),
                  data: '${pestData.recommendedChemical}',
                  isSpace: (pestData.dosage != null && pestData.uomName != null)
                      ? true
                      : false,
                ),
              if (pestData.dosage != null && pestData.uomName != null)
                CommonWidgets.commonRow(
                  label: tr(LocaleKeys.dosage_only),
                  data: '${pestData.dosage} ${pestData.uomName}',
                  isSpace: (pestData.comments != null) ? true : false,
                ),
              if (pestData.comments != null)
                CommonWidgets.commonRow(
                  label: tr(LocaleKeys.comments),
                  data: '${pestData.comments}',
                  isSpace: false,
                ),
            ],
          ),
        ),
      ],
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
              if (diseaseData.disease != null)
                CommonWidgets.commonRow(
                  label: tr(LocaleKeys.disease),
                  data: '${diseaseData.disease}',
                  dataTextColor: CommonStyles.primaryTextColor,
                  isSpace: (diseaseData.chemical != null) ? true : false,
                ),
              if (diseaseData.chemical != null)
                CommonWidgets.commonRow(
                  label: tr(LocaleKeys.Chemical),
                  data: '${diseaseData.chemical}',
                  isSpace:
                      (diseaseData.recommendedChemical != null) ? true : false,
                ),
              if (diseaseData.recommendedChemical != null)
                CommonWidgets.commonRow(
                  label: tr(LocaleKeys.RecommendedChemical),
                  data: '${diseaseData.recommendedChemical}',
                  isSpace: (diseaseData.dosage != null &&
                          diseaseData.uomName != null)
                      ? true
                      : false,
                ),
              if (diseaseData.dosage != null && diseaseData.uomName != null)
                CommonWidgets.commonRow(
                  label: tr(LocaleKeys.dosage_only),
                  data: '${diseaseData.dosage} ${diseaseData.uomName}',
                  isSpace: (diseaseData.comments != null) ? true : false,
                ),
              if (diseaseData.comments != null)
                CommonWidgets.commonRow(
                  label: tr(LocaleKeys.comments),
                  data: '${diseaseData.comments}',
                  isSpace: false,
                ),
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
                  data: '${nutrient.nutrient}',
                  dataTextColor: CommonStyles.primaryTextColor,
                  isSpace: (nutrient.chemical != null) ? true : false,
                ),
              if (nutrient.chemical != null)
                CommonWidgets.commonRow(
                  label: tr(LocaleKeys.Nameofchemicalapplied),
                  data: '${nutrient.chemical}',
                  isSpace:
                      (nutrient.recommendedFertilizer != null) ? true : false,
                ),
              if (nutrient.recommendedFertilizer != null)
                CommonWidgets.commonRow(
                  label: tr(LocaleKeys.RecommendedChemical),
                  data: '${nutrient.recommendedFertilizer}',
                  isSpace: (nutrient.dosage != null && nutrient.uomName != null)
                      ? true
                      : false,
                ),
              if (nutrient.dosage != null && nutrient.uomName != null)
                CommonWidgets.commonRow(
                  label: tr(LocaleKeys.dosage_only),
                  data: '${nutrient.dosage} ${nutrient.uomName}',
                  isSpace: (nutrient.comments != null) ? true : false,
                ),
              if (nutrient.comments != null)
                CommonWidgets.commonRow(
                  label: tr(LocaleKeys.comments),
                  data: '${nutrient.comments}',
                  isSpace: false,
                ),
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
                  data: '${nutrient.irrigaationType}',
                  dataTextColor: CommonStyles.primaryTextColor,
                  isSpace: (nutrient.updatedBy != null) ? true : false,
                ),
              if (nutrient.updatedBy != null)
                CommonWidgets.commonRow(
                  label: tr(LocaleKeys.updated_by),
                  data: '${nutrient.updatedBy}',
                  isSpace: false,
                ),
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
            data: '${cropData.healthPlantationData?.treesAppearance}',
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
            data:
                '${CommonStyles.formatDate(cropData.healthPlantationData?.updatedDate)}',
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
