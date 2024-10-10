import 'dart:convert';
import 'dart:io';

import 'package:akshaya_flutter/common_utils/api_config.dart';
import 'package:akshaya_flutter/common_utils/common_styles.dart';
import 'package:akshaya_flutter/common_utils/custom_appbar.dart';
import 'package:akshaya_flutter/common_utils/shared_prefs_keys.dart';
import 'package:akshaya_flutter/localization/locale_keys.dart';
import 'package:akshaya_flutter/models/plot_details_model.dart';
import 'package:akshaya_flutter/screens/home_screen/screens/crop_maintenance_visits_screen.dart';
import 'package:akshaya_flutter/screens/home_screen/screens/visit_request_screen.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class PlotSelectionScreen extends StatefulWidget {
  final int serviceTypeId;
  const PlotSelectionScreen({super.key, required this.serviceTypeId});

  @override
  State<PlotSelectionScreen> createState() => _PlotSelectionScreenState();
}

class _PlotSelectionScreenState extends State<PlotSelectionScreen> {
  late Future<List<PlotDetailsModel>> plotsData;

  @override
  void initState() {
    super.initState();
    plotsData = getPlotDetails();
  }

  Future<List<PlotDetailsModel>> getPlotDetails() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? userId = prefs.getString(SharedPrefsKeys.farmerCode);
    //const apiUrl = 'http://182.18.157.215/3FAkshaya/API/api/Farmer/GetActivePlotsByFarmerCode/APWGBDAB00010005';
    final apiUrl = '$baseUrl$getActivePlotsByFarmerCode$userId';

    try {
      final jsonResponse = await http.get(Uri.parse(apiUrl));
      if (jsonResponse.statusCode == 200) {
        final response = jsonDecode(jsonResponse.body);
        if (response['listResult'] != null) {
          List<dynamic> plotList = response['listResult'];
          return plotList
              .map((item) => PlotDetailsModel.fromJson(item))
              .toList();
        }
        throw Exception('list is empty');
      } else {
        throw Exception(
            'Request failed with status: ${jsonResponse.statusCode}');
      }
    } on SocketException {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            tr(LocaleKeys.Internet),
          ),
        ),
      );
      throw Exception(
        tr(LocaleKeys.Internet),
      );
    } catch (e) {
      rethrow;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CommonStyles.whiteColor,
      appBar: CustomAppBar(title: tr(LocaleKeys.str_select_plot)),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: FutureBuilder(
              future: plotsData,
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(
                    child: Text(
                        snapshot.error
                            .toString()
                            .replaceFirst('Exception: ', ''),
                        style: CommonStyles.txStyF16CpFF6),
                  );
                } else if (snapshot.hasData) {
                  final plots = snapshot.data as List<PlotDetailsModel>;
                  return ListView.builder(
                    itemCount: plots.length,
                    itemBuilder: (context, index) {
                      return CropPlotDetails(
                          onTap: () =>
                              navigateAccordingToServiceTypeId(plots[index]),
                          plotdata: plots[index],
                          index: index);
                    },
                  );
                } else {
                  return CommonStyles.rectangularShapeShimmerEffect();
                }
              }),
        ),
      ),
    );
  }

  void navigateAccordingToServiceTypeId(PlotDetailsModel plot) {
    switch (widget.serviceTypeId) {
      case 14:
        setState(() {
          CommonStyles.showHorizontalDotsLoadingDialog(context);
        });
        checkVisitRequest(widget.serviceTypeId, plot);
        break;
      default:
        Navigator.of(context).push(
          MaterialPageRoute(
            // builder: (context) => TestCrop(plotdata: plot),
            builder: (context) => CropMaintenanceVisitsScreen(plotdata: plot),
          ),
        );
        break;
    }
  }

  Future<void> checkVisitRequest(
      int serviceTypeId, PlotDetailsModel plot) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? farmerCode = prefs.getString(SharedPrefsKeys.farmerCode);
    final apiUrl =
        '$baseUrl$raiseCollectionRequest$farmerCode/${plot.plotcode}/$serviceTypeId';
    setState(() {
      CommonStyles.hideHorizontalDotsLoadingDialog(context);
    });
    final jsonResponse = await http.get(Uri.parse(apiUrl));
    if (jsonResponse.statusCode == 200) {
      final Map<String, dynamic> response = jsonDecode(jsonResponse.body);
      if (response['isSuccess']) {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => VisitRequest(plot: plot)),
        );
      } else {
        CommonStyles.errorDialog(
          context,
          errorMessage: tr(LocaleKeys.visit_reqst),
        );
      }
    } else {
      throw Exception('Failed to load data: ${jsonResponse.statusCode}');
    }
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
        color:
            index.isEven ? CommonStyles.whiteColor : CommonStyles.listEvenColor,
        //  ? CommonStyles.listEvenColor
        //     : CommonStyles.listOddColor,
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
            dataTextColor: dataTextColor),
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
              child: Text(
                data,
                style: CommonStyles.txStyF14CbFF6.copyWith(
                  color: dataTextColor,
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
