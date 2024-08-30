import 'dart:convert';

import 'package:akshaya_flutter/common_utils/api_config.dart';
import 'package:akshaya_flutter/common_utils/common_styles.dart';
import 'package:akshaya_flutter/common_utils/custom_appbar.dart';
import 'package:akshaya_flutter/common_utils/shared_prefs_keys.dart';
import 'package:akshaya_flutter/localization/locale_keys.dart';
import 'package:akshaya_flutter/models/plot_details_model.dart';
import 'package:akshaya_flutter/screens/home_screen/screens/crop_maintenance_visits_screen.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class PlotSelectionScreen extends StatefulWidget {
  const PlotSelectionScreen({super.key});

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
      // print('apiUrl: $apiUrl');
      // print('jsonResponse: ${jsonResponse.body}');
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
    } catch (e) {
      rethrow;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: tr(LocaleKeys.str_select_plot)),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: FutureBuilder(
              future: plotsData,
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Text('${tr(LocaleKeys.error)}: ${snapshot.error}');
                } else if (snapshot.hasData) {
                  final plots = snapshot.data as List<PlotDetailsModel>;
                  return ListView.builder(
                    itemCount: plots.length,
                    itemBuilder: (context, index) {
                      return CropPlotDetails(
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) =>
                                    CropMaintenanceVisitsScreen(
                                        plotdata: plots[index]),
                              ),
                            );
                          },
                          plotdata: plots[index],
                          index: index);
                    },
                  );
                } else {
                  return const Center(
                      child: CircularProgressIndicator.adaptive());
                }
              }),
        ),
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
      padding: const EdgeInsets.all(8),
      margin: const EdgeInsets.symmetric(vertical: 10),
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
      ],
    );
  }

  Widget plotDetailsBox(
      {required String label, required String data, Color? dataTextColor}) {
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
