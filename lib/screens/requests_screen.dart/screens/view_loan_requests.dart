import 'dart:convert';

import 'package:akshaya_flutter/common_utils/api_config.dart';
import 'package:akshaya_flutter/common_utils/common_styles.dart';
import 'package:akshaya_flutter/common_utils/custom_appbar.dart';
import 'package:akshaya_flutter/common_utils/custom_btn.dart';
import 'package:akshaya_flutter/common_utils/shared_prefs_keys.dart';
import 'package:akshaya_flutter/common_utils/shimmer.dart';
import 'package:akshaya_flutter/localization/locale_keys.dart';
import 'package:akshaya_flutter/models/view_loan_request_model.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ViewLoanRequests extends StatefulWidget {
  const ViewLoanRequests({super.key});

  @override
  State<ViewLoanRequests> createState() => _ViewLoanRequestsState();
}

class _ViewLoanRequestsState extends State<ViewLoanRequests> {
  late Future<List<ViewLoanRequest>> futureLoanRequests;

  @override
  void initState() {
    super.initState();
    futureLoanRequests = getLoanRequest();
  }

  Future<List<ViewLoanRequest>> getLoanRequest() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final farmerCode = prefs.getString(SharedPrefsKeys.farmerCode);
    const apiUrl = '$baseUrl$getVisitRequestDetails';
    final requestBody = jsonEncode({
      "farmerCode": farmerCode,
      "fromDate": null,
      "toDate": null,
      "userId": null,
      "stateCode": null
    });
    final jsonResponse = await http.post(
      Uri.parse(apiUrl),
      headers: {
        'Content-Type': 'application/json',
      },
      body: requestBody,
    );

    if (jsonResponse.statusCode == 200) {
      Map<String, dynamic> response = jsonDecode(jsonResponse.body);
      if (response['listResult'] != null) {
        List<dynamic> list = response['listResult'];
        return list.map((item) => ViewLoanRequest.fromJson(item)).toList();
      } else {
        throw Exception('No loan requests found');
      }
    } else {
      throw Exception('Request failed with status: ${jsonResponse.statusCode}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
          title: tr(LocaleKeys.Loan_req), actionIcon: const SizedBox()),
      body: const Center(
        child: Text('View Loan Requests'),
      ),
      /* 
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12).copyWith(top: 10),
        child: FutureBuilder(
          future: futureLoanRequests,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return shimmerLoading();
            } else if (snapshot.hasError) {
              return Text(
                  snapshot.error.toString().replaceFirst('Exception: ', ''));
            } else {
              final visitRequests = snapshot.data as List<ViewLoanRequest>;
              return ListView.builder(
                itemCount: visitRequests.length,
                itemBuilder: (context, index) {
                  final request = visitRequests[index];

                  return visitRequest(
                    index,
                    request,
                    onPressed: () {
                      getVisitRequestMoreDetails(request.requestCode)
                          .then((value) {
                        List<ViewVisitMoreDetailsModel> imageList = value
                            .where((element) => element.fileTypeId == 36)
                            .toList();
                        List<ViewVisitMoreDetailsModel> audioList = value
                            .where((element) => element.fileTypeId == 37)
                            .toList();

                        if (value.isNotEmpty) {
                          CommonStyles.errorDialog(
                            context,
                            errorMessage: 'errorMessage',
                            isHeader: false,
                            bodyBackgroundColor: Colors.white,
                            errorMessageColor: Colors.orange,
                            errorBodyWidget: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                if (audioList.isNotEmpty)
                                  MoreDetails(
                                    imagesList: imageList,
                                    audioFilePath: audioList[0].fileLocation,
                                  )
                              ],
                            ),
                          );
                          /* showDialog(
                            context: context,
                            builder: (context) {
                              return AlertDialog(
                                content: MoreDetails(
                                  imagesList: imageList, // Your images list
                                  audioFilePath:
                                      'https://webaudioapi.com/samples/audio-tag/chrono.mp3', // Your audio URL
                                ),
                              );
                            },
                          ); */
                        }
                      });
                    },
                  );
                },
              );
            }
          },
        ),
      ),
    */
    );
  }

  Widget shimmerLoading() {
    return ShimmerWid(
      child: Container(
        width: double.infinity,
        height: 120.0,
        decoration: BoxDecoration(
          color: Colors.grey.shade300,
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }

  Container visitRequest(int index, ViewLoanRequest visitLoan,
      {void Function()? onPressed}) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
          color: index.isEven ? Colors.transparent : Colors.grey.shade200,
          borderRadius: BorderRadius.circular(10)),
      margin: const EdgeInsets.only(bottom: 10),
      child: Column(
        children: [
          /*  plotDetailBox(
              label: tr(LocaleKeys.requestCodeLabel),
              data: '${visitLoan.requestCode}',
              dataTextColor: CommonStyles.primaryTextColor),
          plotDetailBox(
              label: tr(LocaleKeys.plot_code),
              data: '${visitLoan.plotCode}'),
          plotDetailBox(
              label: tr(LocaleKeys.plot_size),
              data: '${visitLoan.palmArea}'),
          plotDetailBox(
              label: tr(LocaleKeys.village),
              data: '${visitLoan.plotVillage}'),
          plotDetailBox(
              label: tr(LocaleKeys.req_date),
              data: '${visitLoan.reqCreatedDate}'),
          plotDetailBox(
              label: tr(LocaleKeys.status), data: '${visitLoan.statusType}'), */
          const SizedBox(height: 5),
          CustomBtn(
            label: tr(LocaleKeys.complete_details),
            borderColor: Colors.transparent,
            borderRadius: 4,
            onPressed: onPressed,
          ),
        ],
      ),
    );
  }

  Widget plotDetailBox(
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
              ),
            ),
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
        const SizedBox(height: 8),
      ],
    );
  }
}
