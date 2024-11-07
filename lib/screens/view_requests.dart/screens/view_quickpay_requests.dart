import 'dart:convert';

import 'package:akshaya_flutter/common_utils/api_config.dart';
import 'package:akshaya_flutter/common_utils/common_styles.dart';
import 'package:akshaya_flutter/common_utils/common_widgets.dart';
import 'package:akshaya_flutter/common_utils/custom_appbar.dart';
import 'package:akshaya_flutter/common_utils/custom_btn.dart';
import 'package:akshaya_flutter/common_utils/shared_prefs_keys.dart';
import 'package:akshaya_flutter/localization/locale_keys.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import 'package:webview_flutter/webview_flutter.dart';

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
        actionIcon: const SizedBox(),
        title: tr(LocaleKeys.quick_req),
      ), // actionIcon: const SizedBox()
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

            final requests = snapshot.data as List<QuickpayRequest>;
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
                  return request(
                    index,
                    requests[index],
                    onTap: () {
                      fetchQuickPayDocument(requests[index].requestCode);
                    },
                  );
                },
              );
              /*  return ListView.separated(
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
              ); */
            }
          },
        ),
      ),
    );
  }

  Widget request(int index, QuickpayRequest request, {void Function()? onTap}) {
    return CommonWidgets.viewTemplate(
      bgColor: index.isEven ? Colors.white : Colors.grey.shade200,
      onTap: onTap,
      child: Column(
        children: [
          CommonWidgets.commonRow(
              label: tr(LocaleKeys.requestCodeLabel),
              data: request.requestCode,
              dataTextColor: CommonStyles.primaryTextColor), // appBarColor
          if (request.reqCreatedDate != null)
            CommonWidgets.commonRow(
              label: tr(LocaleKeys.req_date),
              data: '${formatDate(request.reqCreatedDate)}',
            ),
          CommonWidgets.commonRow(
            label: tr(LocaleKeys.status),
            data: request.statusType,
          ),
          CommonWidgets.commonRow(
            label: tr(LocaleKeys.total_amt),
            data: request.totalCost.toStringAsFixed(2),
          ),
        ],
      ),
    );
  }

  Future<void> fetchQuickPayDocument(String requestId) async {
    final url = '$baseUrl$getQuickpayDocument$requestId';
    // 'http://182.18.157.215/3FAkshaya/API/api/QuickPayRequest/GetQuickpayDocument/$requestId';

    print('fetchQuickPayDocument: $url');
    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final Map<String, dynamic> result = json.decode(response.body);

        if (result['isSuccess']) {
          // Show the pop-up with the URL
          showPdfDialog(context, result['result']);
          //   _showPopup(result['result']);
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

  void showPdfDialog(BuildContext context, String pdfUrl) {
    /* showDialog(
      context: context,
      builder: (BuildContext context) {
        return PdfViewerPopup(pdfUrl: pdfUrl);
      },
    ); */
    print('showPdfDialog: $pdfUrl');
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(2.0),
        ),
        child: Container(
          height: MediaQuery.of(context).size.height * 0.7,
          color: CommonStyles.screenBgColor,
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                color: CommonStyles.RedColor,
                width: double.infinity,
                child: Center(
                  child: Text(
                    tr(LocaleKeys.quick_pdf),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                    ),
                  ),
                ),
              ),
              Expanded(
                child: FutureBuilder(
                  future: _loadPdf(pdfUrl),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    } else if (snapshot.hasError) {
                      return const Center(
                        child: Text(
                          'Failed to load PDF Please try again later.',
                          style: CommonStyles.txStyF16CpFF6,
                          textAlign: TextAlign.center,
                        ),
                      );
                    } else {
                      // Display PDF if loaded successfully
                      return SfPdfViewer.network(pdfUrl);
                    }
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CustomBtn(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      btnTextColor: CommonStyles.primaryTextColor,
                      label: tr(LocaleKeys.ok),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
/* 
    showDialog(
        context: context,
        builder: (context) => Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(2.0),
              ),
              child: Container(
                height: MediaQuery.of(context).size.height * 0.7,
                color: const Color(
                    0x8D000000),
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      color: CommonStyles.RedColor,
                      width: double.infinity,
                      child: Center(
                        child: Text(
                          tr(LocaleKeys.quick_pdf),
                          style: const TextStyle(
                              color: Colors.white, fontSize: 18),
                        ),
                      ),
                    ),
                    Expanded(
                      child: SfPdfViewer.network(pdfUrl),
                    ),

                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CustomBtn(
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                              btnTextColor: CommonStyles.primaryTextColor,
                              label: tr(LocaleKeys.ok)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            )
        );
   */
  }

  Future<void> _loadPdf(String pdfUrl) async {
    // Make a request to check if the PDF exists
    final response = await http.head(Uri.parse(pdfUrl));
    if (response.statusCode == 404) {
      throw Exception('PDF not found');
    }
  }
}

class PdfViewerPopup extends StatefulWidget {
  final String pdfUrl;

  const PdfViewerPopup({super.key, required this.pdfUrl});

  @override
  _PdfViewerPopupState createState() => _PdfViewerPopupState();
}

class _PdfViewerPopupState extends State<PdfViewerPopup> {
  bool isLoading = true;
  late final WebViewController _controller;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageFinished: (String url) {
            setState(() {
              isLoading = false;
            });
          },
        ),
      )
      ..loadRequest(Uri.parse(
          "https://docs.google.com/gview?embedded=true&url=${widget.pdfUrl}"));
  }

  @override
  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(2.0),
      ),
      child: Container(
        height: MediaQuery.of(context).size.height * 0.7,
        color: const Color(0x8D000000), // Background color with transparency
        child: Column(
          children: <Widget>[
            // Header
            Container(
              padding: const EdgeInsets.all(8),
              color: CommonStyles.RedColor,
              width: double.infinity,
              child: Center(
                child: Text(
                  tr(LocaleKeys.quick_pdf),
                  style: const TextStyle(color: Colors.white, fontSize: 18),
                ),
              ),
            ),
            Expanded(
              child: Stack(
                children: [
                  WebViewWidget(controller: _controller),
                  if (isLoading)
                    const Center(child: CircularProgressIndicator()),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 10.0),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20.0), // Rounded corners
                  gradient: const LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Color(0xFFCCCCCC), // Start color (light gray)
                      Color(0xFFFFFFFF), // Center color (white)
                      Color(0xFFCCCCCC), // End color (light gray)
                    ],
                  ),
                  border: Border.all(
                    color: const Color(0xFFe86100), // Orange border color
                    width: 2.0,
                  ),
                ),
                child: SizedBox(
                  height: 30.0, // Set the desired height
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 35.0),
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20.0),
                      ),
                    ),
                    child: Text(
                      tr(LocaleKeys.ok),
                      style: CommonStyles.txSty_16p_f5,
                    ),
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

// void showSuccessquikDialog(BuildContext context, String summary) {
  //   showDialog(
  //     context: context,
  //     builder: (BuildContext context) {
  //       return SuccessDialog2(title: summary);
  //     },
  //   );
  // }
}
