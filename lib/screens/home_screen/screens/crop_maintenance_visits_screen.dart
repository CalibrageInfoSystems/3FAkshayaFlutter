import 'package:akshaya_flutter/common_utils/common_styles.dart';
import 'package:akshaya_flutter/common_utils/custom_appbar.dart';
import 'package:akshaya_flutter/common_utils/custom_box.dart';
import 'package:akshaya_flutter/localization/locale_keys.dart';
import 'package:akshaya_flutter/models/plot_details_model.dart';
import 'package:akshaya_flutter/screens/home_screen/screens/plot_selection_screen.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

class CropMaintenanceVisitsScreen extends StatelessWidget {
  final PlotDetailsModel plotdata;
  const CropMaintenanceVisitsScreen({super.key, required this.plotdata});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: tr(LocaleKeys.str_select_plot)),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            CropPlotDetails(
              plotdata: plotdata,
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
                      data: 'data',
                      dataTextColor: CommonStyles.whiteColor,
                      labelTextColor: CommonStyles.whiteColor),
                  custombox(
                      label: tr(LocaleKeys.plamsCount),
                      data: 'data',
                      dataTextColor: CommonStyles.whiteColor,
                      labelTextColor: CommonStyles.whiteColor),
                  custombox(
                      label: tr(LocaleKeys.Frequency_harvest),
                      data: 'data',
                      dataTextColor: CommonStyles.whiteColor,
                      labelTextColor: CommonStyles.whiteColor),
                  custombox(
                      label: tr(LocaleKeys.last_date),
                      data: 'data',
                      dataTextColor: CommonStyles.whiteColor,
                      labelTextColor: CommonStyles.whiteColor),
                  Text(
                    tr(LocaleKeys.Frequency),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    tr(LocaleKeys.static_data),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
