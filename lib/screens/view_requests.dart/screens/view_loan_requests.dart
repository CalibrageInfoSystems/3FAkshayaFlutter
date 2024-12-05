/* import 'dart:convert';

import 'package:akshaya_flutter/common_utils/api_config.dart';
import 'package:akshaya_flutter/common_utils/common_styles.dart';
import 'package:akshaya_flutter/common_utils/common_widgets.dart';
import 'package:akshaya_flutter/common_utils/custom_appbar.dart';
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
    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() {
        CommonStyles.showHorizontalDotsLoadingDialog(context);
      });
    });
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final farmerCode = prefs.getString(SharedPrefsKeys.farmerCode);
    const apiUrl = '$baseUrl$getLoanRequestDetails';
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
    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() {
        CommonStyles.hideHorizontalDotsLoadingDialog(context);
      });
    });
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
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12).copyWith(top: 10),
        child: FutureBuilder(
          future: futureLoanRequests,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return shimmerLoading();
            } else if (snapshot.hasError) {
              return Text(
                  snapshot.error.toString().replaceFirst('Exception: ', ''),
                  style: CommonStyles.txStyF16CpFF6);
            } else {
              final visitRequests = snapshot.data as List<ViewLoanRequest>;
              if (visitRequests.isEmpty) {
                return Center(
                  child: Text(
                    tr(LocaleKeys.no_req_found),
                    style: CommonStyles.txStyF16CpFF6,
                  ),
                );
              } else {
                return CommonWidgets.customSlideAnimation(
                  itemCount: visitRequests.length,
                  isSeparatorBuilder: true,
                  childBuilder: (index) {
                    final request = visitRequests[index];
                    return visitRequest(
                      index,
                      request,
                      viewMoreDetails: () {
                        CommonStyles.errorDialog(
                          context,
                          errorHeaderColor: Colors.transparent,
                          bodyBackgroundColor: Colors.transparent,
                          isHeader: false,
                          errorMessage: '',
                          errorBodyWidget: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              (request.comments == null ||
                                      request.comments!.isEmpty)
                                  ? Text(tr(LocaleKeys.nocomments),
                                      style: CommonStyles.txStyF16CpFF6)
                                  : Text(tr(LocaleKeys.comments),
                                      style: CommonStyles.txStyF16CpFF6),
                              const SizedBox(height: 10),
                              (request.comments == null ||
                                      request.comments!.isEmpty)
                                  ? const SizedBox()
                                  : Row(
                                      children: [
                                        Text('${request.comments}',
                                            style: CommonStyles.txStyF14CbFF6),
                                      ],
                                    ),
                            ],
                          ),
                        );
                      },
                    );
                  },
                );
                /*  return ListView.separated(
                  itemCount: visitRequests.length,
                  separatorBuilder: (context, index) {
                    return const SizedBox(height: 10);
                  },
                  itemBuilder: (context, index) {
                    final request = visitRequests[index];
                    return visitRequest(
                      index,
                      request,
                      viewMoreDetails: () {
                        CommonStyles.errorDialog(
                          context,
                          errorHeaderColor: Colors.transparent,
                          bodyBackgroundColor: Colors.transparent,
                          isHeader: false,
                          errorMessage: '',
                          errorBodyWidget: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              (request.comments == null ||
                                      request.comments!.isEmpty)
                                  ? Text(tr(LocaleKeys.nocomments),
                                      style: CommonStyles.txStyF16CpFF6)
                                  : Text(tr(LocaleKeys.comments),
                                      style: CommonStyles.txStyF16CpFF6),
                              const SizedBox(height: 10),
                              (request.comments == null ||
                                      request.comments!.isEmpty)
                                  ? const SizedBox()
                                  : Row(
                                      children: [
                                        Text('${request.comments}',
                                            style: CommonStyles.txStyF14CbFF6),
                                      ],
                                    ),
                            ],
                          ),
                        );
                      },
                    );
                  },
                ); */
              }
            }
          },
        ),
      ),
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

  Widget visitRequest(int index, ViewLoanRequest request,
      {void Function()? viewMoreDetails}) {
    return CommonWidgets.viewTemplate(
      bgColor: index.isEven ? Colors.white : Colors.grey.shade200,
      onTap: viewMoreDetails,
      child: Column(
        children: [
          if (request.requestCode != null)
            CommonWidgets.commonRow(
                label: tr(LocaleKeys.requestCodeLabel),
                data: '${request.requestCode}',
                dataTextColor: CommonStyles.primaryTextColor),
          if (request.reqCreatedDate != null)
            CommonWidgets.commonRow(
              label: tr(LocaleKeys.req_date),
              data: '${CommonStyles.formatDate(request.reqCreatedDate)}',
            ),
          if (request.totalCost != null)
            CommonWidgets.commonRow(
              label: tr(LocaleKeys.total_amt),
              data: request.totalCost!.toStringAsFixed(2),
            ),
        ],
      ),
    );
  }

  String? formatDate(String? dateString) {
    if (dateString == null || dateString.isEmpty) {
      return null;
    }

    DateTime parsedDate = DateTime.parse(dateString);
    return DateFormat('dd-MM-yyyy').format(parsedDate);
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
 */
import 'dart:convert';

import 'package:akshaya_flutter/common_utils/api_config.dart';
import 'package:akshaya_flutter/common_utils/common_styles.dart';
import 'package:akshaya_flutter/common_utils/common_widgets.dart';
import 'package:akshaya_flutter/common_utils/custom_appbar.dart';
import 'package:akshaya_flutter/common_utils/shared_prefs_keys.dart';
import 'package:akshaya_flutter/localization/locale_keys.dart';
import 'package:akshaya_flutter/models/view_loan_request_model.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

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
    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() {
        CommonStyles.showHorizontalDotsLoadingDialog(context);
      });
    });
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final farmerCode = prefs.getString(SharedPrefsKeys.farmerCode);
    const apiUrl = '$baseUrl$getLoanRequestDetails';
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
    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() {
        CommonStyles.hideHorizontalDotsLoadingDialog(context);
      });
    });
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
      backgroundColor: Colors.white,
      appBar: CustomAppBar(
        title: tr(LocaleKeys.Loan_req),
        actionIcon: const SizedBox(),
      ),
      body: Padding(
        padding: const EdgeInsets.all(12),
        // padding: const EdgeInsets.symmetric(horizontal: 8).copyWith(top: 12),
        child: FutureBuilder(
          future: futureLoanRequests,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const SizedBox();
            } else if (snapshot.hasError) {
              return CommonStyles.snapshotError(snapshot.error);
            }
            final requests = snapshot.data as List<ViewLoanRequest>;
            if (requests.isEmpty) {
              return Center(
                child: Text(
                  tr(LocaleKeys.no_req_found),
                  style: CommonStyles.txStyF16CpFF6,
                ),
              );
            } else {
              return CommonWidgets.customSlideAnimation(
                itemCount: requests.length,
                isSeparatorBuilder: true,
                childBuilder: (index) {
                  final request = requests[index];

                  return visitRequest(
                    index,
                    request,
                    onTap: () {
                      CommonStyles.errorDialog(
                        context,
                        btnTextColor: CommonStyles.primaryTextColor,
                        errorHeaderColor: Colors.transparent,
                        bodyBackgroundColor: Colors.transparent,
                        isHeader: false,
                        errorMessage: '',
                        errorBodyWidget: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            (request.comments == null ||
                                    request.comments!.isEmpty)
                                ? Text(tr(LocaleKeys.nocomments),
                                    style: CommonStyles.txStyF16CpFF6)
                                : Text(tr(LocaleKeys.comments),
                                    style: CommonStyles.txStyF16CpFF6),
                            const SizedBox(height: 10),
                            (request.comments == null ||
                                    request.comments!.isEmpty)
                                ? const SizedBox()
                                : 
                                // Row(
                                //     children: [
                                //       Text('${request.comments}',
                                //           style: CommonStyles.txStyF14CbFF6),
                                //     ],
                                //   ),
                                Text(
                            '${request.comments}',
                            textAlign: TextAlign.center,
                            // maxLines: 4,
                            // overflow: TextOverflow.ellipsis,
                            style: CommonStyles.txStyF14CbFF6,
                          ),
                          ],
                        ),
                      );
                    },
                  );
                },
              );
            }
          },
        ),
      ),
    );
  }

  Widget visitRequest(int index, ViewLoanRequest request,
      {void Function()? onTap}) {
    return CommonWidgets.viewTemplate(
      bgColor: index.isEven ? Colors.white : Colors.grey.shade200,
      onTap: onTap,
      child: Column(
        children: [
          if (request.requestCode != null)
            CommonWidgets.commonRow(
                label: tr(LocaleKeys.requestCodeLabel),
                data: '${request.requestCode}',
                dataTextColor: CommonStyles.primaryTextColor),
          if (request.reqCreatedDate != null)
            CommonWidgets.commonRow(
              label: tr(LocaleKeys.req_date),
              data: '${CommonStyles.formatDate(request.reqCreatedDate)}',
            ),
          if (request.totalCost != null)
            CommonWidgets.commonRow(
              label: tr(LocaleKeys.total_amt),
              data: request.totalCost!.toStringAsFixed(2),
            ),
        ],
      ),
    );
  }
}
