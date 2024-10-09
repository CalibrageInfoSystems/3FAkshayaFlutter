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

import '../../../Services/models/QuickpayRequest.dart';

class ViewQuickpayRequests extends StatefulWidget {
  const ViewQuickpayRequests({super.key});

  @override
  State<ViewQuickpayRequests> createState() => _ViewQuickpayRequestsState();
}

class _ViewQuickpayRequestsState extends State<ViewQuickpayRequests> {
  late Future<List<QuickpayRequest>> futureRequests;

  @override
  void initState() {
    super.initState();
    futureRequests = getQuickpayRequests();
  }

  String? formatDate(String? dateString) {
    if (dateString == null || dateString.isEmpty) {
      return null;
    }

    DateTime parsedDate = DateTime.parse(dateString);
    return DateFormat('dd/MM/yyyy').format(parsedDate);
  }

  Future<List<QuickpayRequest>> getQuickpayRequests() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      CommonStyles.showHorizontalDotsLoadingDialog(context);
    });
    final farmerCode = prefs.getString(SharedPrefsKeys.farmerCode);
    final statecode = prefs.getString(SharedPrefsKeys.statecode);

    const apiUrl = '$baseUrl$getQuickpayProductDetails';

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
            .map((item) => QuickpayRequest.fromJson(item))
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
        title: tr(LocaleKeys.quick_req),
      ), // actionIcon: const SizedBox()
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12).copyWith(top: 12),
        child: FutureBuilder(
          future: futureRequests,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const SizedBox();
            } else if (snapshot.hasError) {
              return Text(
                  snapshot.error.toString().replaceFirst('Exception: ', ''),
                  style: CommonStyles.txStyF16CpFF6);
            } else if (!snapshot.hasData) {
              return const Text('No data');
            }

            final requests = snapshot.data as List<QuickpayRequest>;
            if (requests.isEmpty) {
              return Center(
                child: Text(
                  tr(LocaleKeys.no_req_found),
                  style: CommonStyles.txSty_16p_fb,
                ),
              );
            }
            else {
              return ListView.separated(
                itemCount: requests.length,
                itemBuilder: (context, index) {
                  return request(
                    index,
                    requests[index],
                    onTap: () {
                      fetchQuickPayDocument(requests[index].requestCode);
                    },
                  );
                },
                separatorBuilder: (context, index) {
                  return const SizedBox(height: 10);
                },
              );
            }
          },
        ),
      ),
    );
  }

  Widget request(int index, QuickpayRequest request,
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
                dataTextColor: CommonStyles.appBarColor),
          if (request.reqCreatedDate != null)
            CommonWidgets.commonRow(
              label: tr(LocaleKeys.req_date),
              data: '${formatDate(request.reqCreatedDate)}',
            ),
          if (request.statusType != null)
            CommonWidgets.commonRow(
              label: tr(LocaleKeys.status),
              data: '${request.statusType}',
            ),
          if (request.totalCost != null)
            CommonWidgets.commonRow(
              label: tr(LocaleKeys.total_amt),
              data: '${request.totalCost}',
            ),
        ],
      ),
    );
  }

  Future<void> fetchQuickPayDocument(String requestId) async {
    final url = 'http://182.18.157.215/3FAkshaya/API/api/QuickPayRequest/GetQuickpayDocument/$requestId';

    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final Map<String, dynamic> result = json.decode(response.body);

        if (result['isSuccess']) {
          // Show the pop-up with the URL
          _showPopup(result['result']);
        } else {
          // Handle error message
          print(result['endUserMessage']);
        }
      } else {
        // Handle error response
        print('Error: ${response.statusCode}');
      }
    } catch (e) {
      // Handle exceptions
      print('Exception: $e');
    }
  }

  void _showPopup(String url) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('QuickPay Document'),
          content: Text('Document URL: $url'),
          actions: [
            TextButton(
              child: Text('Close'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Open Document'),
              onPressed: () {
                // Implement opening the URL in the browser
                // You may want to use url_launcher package for this
                // final uri = Uri.parse(url);
                // launch(uri.toString());
                Navigator.of(context).pop(); // Close the dialog after opening
              },
            ),
          ],
        );
      },
    );
  }
}
