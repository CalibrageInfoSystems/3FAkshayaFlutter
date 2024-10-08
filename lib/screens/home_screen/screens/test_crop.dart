import 'package:akshaya_flutter/common_utils/common_styles.dart';
import 'package:akshaya_flutter/common_utils/custom_appbar.dart';
import 'package:akshaya_flutter/common_utils/custom_box.dart';
import 'package:akshaya_flutter/localization/locale_keys.dart';
import 'package:akshaya_flutter/models/plot_details_model.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

class TestCrop extends StatefulWidget {
  const TestCrop({super.key, required this.plotdata});
  final PlotDetailsModel plotdata;

  @override
  State<TestCrop> createState() => _TestCropState();
}

class _TestCropState extends State<TestCrop> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CommonStyles.screenBgColor,
      appBar: appBar(),
      body: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12).copyWith(top: 12),
          child: Column(
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
                      data: 'treesAppearance',
                    ),
                    custombox(
                      label: tr(LocaleKeys.plamsCount),
                      data: 'plamscount',
                    ),
                    custombox(
                      label: tr(LocaleKeys.Frequency_harvest),
                      data: 'frequencyofharvest',
                    ),
                    custombox(
                      label: tr(LocaleKeys.last_date),
                      data: 'formattedDate',
                    ),
                    const SizedBox(height: 10),
                    Text(
                      tr(LocaleKeys.Frequency),
                      style: CommonStyles.txStyF16CwFF6,
                    ),
                    Text(
                      tr(LocaleKeys.static_data),
                      style: CommonStyles.txStyF14CwFF6,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
            ],
          )),
    );
  }

  CustomAppBar appBar() => CustomAppBar(title: tr(LocaleKeys.crop));
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
    return GestureDetector(onTap: onTap, child: plot(context));
  }

  Widget plot(BuildContext context) {
    final df = NumberFormat("#,##0.00");
    String? dateOfPlanting = plotdata.dateOfPlanting;
    DateTime parsedDate = DateTime.parse(dateOfPlanting!);
    String year = parsedDate.year.toString();
    return Container(
      // color: Colors.green,
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
              child: Text(data, style: CommonStyles.txStyF14CbFF6),
            ),
          ],
        ),
        if (isSpace) const SizedBox(height: 8),
      ],
    );
  }
}
