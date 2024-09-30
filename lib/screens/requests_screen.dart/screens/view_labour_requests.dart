import 'dart:convert';

import 'package:akshaya_flutter/common_utils/api_config.dart';
import 'package:akshaya_flutter/common_utils/common_styles.dart';
import 'package:akshaya_flutter/common_utils/common_widgets.dart';
import 'package:akshaya_flutter/common_utils/custom_appbar.dart';
import 'package:akshaya_flutter/common_utils/custom_btn.dart';
import 'package:akshaya_flutter/common_utils/shared_prefs_keys.dart';
import 'package:akshaya_flutter/localization/locale_keys.dart';
import 'package:akshaya_flutter/models/common_view_request_model.dart';
import 'package:akshaya_flutter/models/view_labour_model.dart';
import 'package:akshaya_flutter/screens/requests_screen.dart/screens/fertilizer_product_details.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class ViewLabourRequests extends StatefulWidget {
  const ViewLabourRequests({super.key});

  @override
  State<ViewLabourRequests> createState() => _ViewLabourRequestsState();
}

class _ViewLabourRequestsState extends State<ViewLabourRequests> {
  late Future<List<ViewLabourModel>> futureRequests;

  @override
  void initState() {
    super.initState();
    futureRequests = getLabourRequests();
  }

  String? formatDate(String? dateString) {
    if (dateString == null || dateString.isEmpty) {
      return null;
    }

    DateTime parsedDate = DateTime.parse(dateString);
    return DateFormat('dd/MM/yyyy').format(parsedDate);
  }

  Future<List<ViewLabourModel>> getLabourRequests() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      CommonStyles.showHorizontalDotsLoadingDialog(context);
    });
    final farmerCode = prefs.getString(SharedPrefsKeys.farmerCode);
    final statecode = prefs.getString(SharedPrefsKeys.statecode);

    const apiUrl = '$baseUrl$getLabourProductDetails';

    final requestBody = {
      "farmerCode": farmerCode,
      "fromDate": null,
      "toDate": null,
      "userId": null,
      "stateCode": statecode
    };

    final jsonResponse = await http.post(Uri.parse(apiUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(requestBody));

    print('getFertilizerRequests: $apiUrl');
    print('getFertilizerRequests: ${jsonEncode(requestBody)}');
    print('getFertilizerRequests: ${jsonResponse.body}');
    setState(() {
      CommonStyles.hideHorizontalDotsLoadingDialog(context);
    });
    if (jsonResponse.statusCode == 200) {
      final response = jsonDecode(jsonResponse.body);
      if (response['listResult'] != null) {
        List<dynamic> listResult = response['listResult'];
        return listResult
            .map((item) => ViewLabourModel.fromJson(item))
            .toList();
      } else {
        throw Exception('listResult is empty');
      }
    } else {
      throw Exception('Failed to load data: ${jsonResponse.statusCode}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: CustomAppBar(
        title: tr(LocaleKeys.lab_req),
      ), // actionIcon: const SizedBox()
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12).copyWith(top: 12),
        child: FutureBuilder(
          future: futureRequests,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const SizedBox();
            } else if (snapshot.hasError) {
              return Text('Error: ${snapshot.error}',
                  style: CommonStyles.txStyF16CpFF6);
            } else if (!snapshot.hasData) {
              return const Text('No data');
            }

            final requests = snapshot.data as List<ViewLabourModel>;

            return ListView.separated(
              itemCount: requests.length,
              itemBuilder: (context, index) {
                return request(
                  index,
                  requests[index],
                  onTap: () => viewCompleteDetails(requests[index]),
                );
              },
              separatorBuilder: (context, index) {
                return const SizedBox(height: 10);
              },
            );
          },
        ),
      ),
    );
  }

  Widget request(int index, ViewLabourModel request, {void Function()? onTap}) {
    return CommonWidgets.viewTemplate(
      bgColor: index.isEven ? Colors.white : Colors.grey.shade200,
      onTap: onTap,
      child: Column(
        children: [
          CommonWidgets.commonRow(
              label: tr(LocaleKeys.requestCodeLabel),
              data: '${request.requestCode}',
              dataTextColor: CommonStyles.primaryTextColor),
          CommonWidgets.commonRow(
            label: tr(LocaleKeys.plot_code),
            data: '${request.plotCode}',
          ),
          CommonWidgets.commonRow(
            label: tr(LocaleKeys.plot_size),
            data: '${request.palmArea}',
          ),
          CommonWidgets.commonRow(
            label: tr(LocaleKeys.village),
            data: '${request.plotVillage}',
          ),
          CommonWidgets.commonRow(
            label: tr(LocaleKeys.startDate),
            data: '${CommonStyles.formatDate2(request.startDate)}',
          ),
          CommonWidgets.commonRow(
            label: tr(LocaleKeys.serviceType),
            data: '${request.serviceTypes}',
          ),
          CommonWidgets.commonRow(
            label: tr(LocaleKeys.status),
            data: '${request.statusType}',
          ),
        ],
      ),
    );
  }

  Widget commonRow({
    required String label,
    required String data,
    Color? labelTextColor,
    bool isColon = false,
  }) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              flex: 6,
              child: Text(
                label,
                style: CommonStyles.txStyF14CwFF6.copyWith(
                  color: labelTextColor,
                ),
              ),
            ),
            const Expanded(
                flex: 1, child: Text(':', style: CommonStyles.txStyF14CwFF6)),
            Expanded(
              flex: 7,
              child: Text(data, style: CommonStyles.txStyF14CwFF6),
            ),
          ],
        ),
        const SizedBox(height: 10),
      ],
    );
  }

  void viewCompleteDetails(ViewLabourModel request) {
    CommonStyles.customDialog(
        context,
        Container(
          width: MediaQuery.of(context).size.width * 0.9,
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.black,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: CommonStyles.primaryTextColor),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('${request.requestCode}', style: CommonStyles.txStyF16CpFF6),
              const SizedBox(height: 10),
              commonRow(
                label: tr(LocaleKeys.plot_code),
                data: '${request.plotCode}',
              ),
              commonRow(
                label: tr(LocaleKeys.plot_size),
                data: '${request.palmArea}',
              ),
              commonRow(
                label: tr(LocaleKeys.village),
                data: '${request.plotVillage}',
              ),
              commonRow(
                label: tr(LocaleKeys.labour_leader),
                data: '${request.leader}',
              ),
              commonRow(
                label: tr(LocaleKeys.startDate),
                data: '${request.startDate}',
              ),
              commonRow(
                label: tr(LocaleKeys.serviceType),
                data: '${request.serviceTypes}',
              ),
              commonRow(
                label: tr(LocaleKeys.job_done),
                data: '${request.updatedDate}',
              ),
              commonRow(
                label: tr(LocaleKeys.Package),
                data: '${request.assignedDate}',
              ),
              commonRow(
                label: tr(LocaleKeys.status),
                data: '${request.statusType}',
              ),
              commonRow(
                label: tr(LocaleKeys.assign_date),
                data: '${request.createdDate}',
              ),
              Text(tr(LocaleKeys.total_amt), style: CommonStyles.txStyF16CpFF6),
              const SizedBox(height: 5),
              Container(
                height: 1.0,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Color(0xFFFF4500),
                      Color(0xFFA678EF),
                      Color(0xFFFF4500),
                    ],
                    end: Alignment.topRight,
                  ),
                ),
              ),
              const SizedBox(height: 5),
              commonRow(
                label: tr(LocaleKeys.total_amt),
                data: '${request.totalCost}',
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CustomBtn(
                      label: tr(LocaleKeys.ok),
                      padding: const EdgeInsets.symmetric(horizontal: 30),
                      borderRadius: 20,
                      onPressed: () => Navigator.pop(context)),
                ],
              ),
            ],
          ),
        ));
  }
}
