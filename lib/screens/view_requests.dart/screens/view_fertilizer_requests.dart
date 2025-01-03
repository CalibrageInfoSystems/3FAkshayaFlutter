import 'dart:convert';

import 'package:akshaya_flutter/common_utils/api_config.dart';
import 'package:akshaya_flutter/common_utils/common_styles.dart';
import 'package:akshaya_flutter/common_utils/common_widgets.dart';
import 'package:akshaya_flutter/common_utils/custom_appbar.dart';
import 'package:akshaya_flutter/common_utils/shared_prefs_keys.dart';
import 'package:akshaya_flutter/localization/locale_keys.dart';
import 'package:akshaya_flutter/models/common_view_request_model.dart';
import 'package:akshaya_flutter/screens/view_requests.dart/screens/fertilizer_product_details.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class ViewFertilizerRequests extends StatefulWidget {
  const ViewFertilizerRequests({super.key});

  @override
  State<ViewFertilizerRequests> createState() => _ViewFertilizerRequestsState();
}

class _ViewFertilizerRequestsState extends State<ViewFertilizerRequests> {
  late Future<List<CommonViewRequestModel>> futureRequests;

  @override
  void initState() {
    super.initState();
    futureRequests = getFertilizerRequests();
  }

  String? formatDate(String? dateString) {
    if (dateString == null || dateString.isEmpty) {
      return null;
    }

    DateTime parsedDate = DateTime.parse(dateString);
    return DateFormat('dd/MM/yyyy').format(parsedDate);
  }

  Future<List<CommonViewRequestModel>> getFertilizerRequests() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      CommonStyles.showHorizontalDotsLoadingDialog(context);
    });
    final farmerCode = prefs.getString(SharedPrefsKeys.farmerCode);
    final statecode = prefs.getString(SharedPrefsKeys.statecode);

    const apiUrl = '$baseUrl$getFertilizerDetails';

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
            .map((item) => CommonViewRequestModel.fromJson(item))
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
        title: tr(LocaleKeys.fert_req),
        actionIcon: const SizedBox(),
      ),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: FutureBuilder(
          future: futureRequests,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const SizedBox();
            } else if (snapshot.hasError) {
              return Center(
                child: Text(
                    textAlign: TextAlign.center,
                    snapshot.error.toString().replaceFirst('Exception: ', ''),
                    style: CommonStyles.txStyF16CpFF6),
              );
            } else if (!snapshot.hasData) {
              return const Text('No data');
            }

            final requests = snapshot.data as List<CommonViewRequestModel>;
            if (requests.isEmpty) {
              return Center(
                child: Text(
                  tr(LocaleKeys.no_req_found),
                  style: CommonStyles.txSty_16p_fb,
                ),
              );
            } else {
              return CommonWidgets.customSlideAnimation(
                itemCount: requests.length,
                isSeparatorBuilder: true,
                childBuilder: (index) {
                  final request = requests[index];

                  return this.request(
                    index,
                    request,
                    onTap: () {
                      // Ensuring null safety for nullable fields
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => FertilizerProductDetails(
                            requestCode: request.requestCode ?? 'N/A',
                            payableAmount:
                                request.paubleAmount.toString() ?? '0.0',
                            subsidyAmount:
                                request.subsidyAmount.toString() ?? '0.0',
                          ),
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

  Widget request(int index, CommonViewRequestModel request,
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
          if (request.goDownName != null)
            CommonWidgets.commonRow(
              label: tr(LocaleKeys.Godown_name),
              data: '${request.goDownName}',
            ),
          if (request.reqCreatedDate != null)
            CommonWidgets.commonRow(
              label: tr(LocaleKeys.req_date),
              data: '${formatDate(request.reqCreatedDate)}',
            ),
          if (request.status != null)
            CommonWidgets.commonRow(
              label: tr(LocaleKeys.status),
              data: '${request.status}',
            ),
          if (request.paubleAmount != null)
            CommonWidgets.commonRow(
              label: tr(LocaleKeys.amount_payble),
              data: request.paubleAmount!.toStringAsFixed(2),
            ),
          if (request.subsidyAmount != null)
            CommonWidgets.commonRow(
              label: tr(LocaleKeys.subcd_amt),
              data: request.subsidyAmount!.toStringAsFixed(2),
            ),
          if (request.paymentMode != null)
            CommonWidgets.commonRow(
              label: tr(LocaleKeys.payment_mode),
              data: '${request.paymentMode}',
            ),
          if (request.isImmediatePayment != null)
            CommonWidgets.commonRow(
              label: tr(LocaleKeys.imdpayment),
              data: '${request.isImmediatePayment}',
            ),
          if (request.paymentMode == 'Against FFB')
            CommonWidgets.commonRow(
              label: tr(LocaleKeys.pinn),
              data: '${request.pin}',
            ),
        ],
      ),
    );
  }
}
