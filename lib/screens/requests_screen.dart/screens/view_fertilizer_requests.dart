import 'dart:convert';

import 'package:akshaya_flutter/common_utils/api_config.dart';
import 'package:akshaya_flutter/common_utils/common_styles.dart';
import 'package:akshaya_flutter/common_utils/common_widgets.dart';
import 'package:akshaya_flutter/common_utils/custom_appbar.dart';
import 'package:akshaya_flutter/common_utils/shared_prefs_keys.dart';
import 'package:akshaya_flutter/localization/locale_keys.dart';
import 'package:akshaya_flutter/models/common_view_request_model.dart';
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
          title: tr(LocaleKeys.fert_req), actionIcon: const SizedBox()),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12).copyWith(top: 12),
        child: FutureBuilder(
          future: futureRequests,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            } else if (snapshot.hasError) {
              return Text('Error: ${snapshot.error}');
            } else if (!snapshot.hasData) {
              return const Text('No data');
            }

            final requests = snapshot.data as List<CommonViewRequestModel>;

            return ListView.separated(
              itemCount: requests.length,
              itemBuilder: (context, index) {
                return request(index, requests[index]);
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

  Widget request(int index, CommonViewRequestModel request) {
    return CommonWidgets.viewTemplate(
      bgColor: index.isEven ? Colors.white : Colors.grey.shade200,
      child: Column(
        children: [
          CommonWidgets.commonRow(
              label: tr(LocaleKeys.requestCodeLabel),
              data: '${request.requestCode}',
              dataTextColor: CommonStyles.appBarColor),
          CommonWidgets.commonRow(
            label: tr(LocaleKeys.Godown_name),
            data: '${request.goDownName}',
          ),
          CommonWidgets.commonRow(
            label: tr(LocaleKeys.req_date),
            data: '${formatDate(request.reqCreatedDate)}',
          ),
          CommonWidgets.commonRow(
            label: tr(LocaleKeys.status),
            data: '${request.status}',
          ),
          CommonWidgets.commonRow(
            label: tr(LocaleKeys.amount_payble),
            data: '${request.transportPayableAmount}', // check this field
          ),
          CommonWidgets.commonRow(
            label: tr(LocaleKeys.subcd_amt),
            data: '${request.subsidyAmount}',
          ),
          CommonWidgets.commonRow(
            label: tr(LocaleKeys.payment_mode),
            data: '${request.paymentMode}',
          ),
          CommonWidgets.commonRow(
            label: tr(LocaleKeys.imdpayment),
            data: '${request.isImmediatePayment}',
          ),
          CommonWidgets.commonRow(
            label: tr(LocaleKeys.pinn),
            data: '${request.pin}',
          ),
        ],
      ),
    );
  }
}
