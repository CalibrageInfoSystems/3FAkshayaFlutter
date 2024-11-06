import 'dart:convert';

import 'package:akshaya_flutter/common_utils/common_widgets.dart';
import 'package:decimal/decimal.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../../common_utils/api_config.dart';
import '../../../common_utils/common_styles.dart';
import '../../../common_utils/custom_appbar.dart';
import '../../../localization/locale_keys.dart';
import '../../../models/fertilizer_view_product_model.dart';
import 'package:http/http.dart' as http;

class ProductDetails extends StatefulWidget {
  final String? requestCode;
  const ProductDetails({super.key, required this.requestCode});

  @override
  State<ProductDetails> createState() => _FertilizerProductDetailsState();
}

class _FertilizerProductDetailsState extends State<ProductDetails> {
  late Future<List<FetilizerViewProduct>> futureData;
  // Initialize totals
  double totalBasePrice = 0.0;
  double totalAmount = 0.0;
  double totalGst = 0.0;
  double totalSGst = 0.0;
  double totalCGst = 0.0;
  double totalBaseTransportAmount = 0.0;
  double totalTransportAmount = 0.0;
  double totalTransportGST = 0.0;
  double totalTransportSGST = 0.0;
  double totalTransportCGST = 0.0;
  double paybleamount = 0.0;
  double subsidyAmount = 0.0;
  @override
  void initState() {
    super.initState();
    futureData = getFetilizerProductDetails();
  }

  Future<List<FetilizerViewProduct>> getFetilizerProductDetails() async {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() {
        CommonStyles.showHorizontalDotsLoadingDialog(context);
      });
    });
    final apiUrl = '$baseUrl$getFertilizerProductDetails${widget.requestCode}';
    final jsonResponse = await http.get(Uri.parse(apiUrl));

    print('api: $apiUrl');
    print('api: ${jsonResponse.body}');

    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() {
        CommonStyles.hideHorizontalDotsLoadingDialog(context);
      });
    });
    if (jsonResponse.statusCode == 200) {
      Map<String, dynamic> response = jsonDecode(jsonResponse.body);

      if (response['listResult'] != null) {
        List<dynamic> list = response['listResult'];
        List<FetilizerViewProduct> products =
            list.map((item) => FetilizerViewProduct.fromJson(item)).toList();

        // Sum basePrice and totalAmount
        for (var product in products) {
          totalBasePrice += product.basePrice ?? 0.0;
          totalAmount += product.totalAmount ?? 0.0;
          totalBaseTransportAmount += product.transportBasePrice ?? 0.0;
          totalTransportAmount += product.transPortAmount ?? 0.0;
        }

        // Calculate GST and ensure two decimal points
        /* double gstAmount =
            double.parse((totalAmount - totalBasePrice).toStringAsFixed(2)); */

        double gstAmount = (totalAmount - totalBasePrice);
        totalSGst = gstAmount / 2;
        double transgstAmount =
            double.parse((totalAmount - totalBasePrice).toStringAsFixed(2));
        totalTransportSGST = transgstAmount / 2;
        // Ensure the values have two decimal places
        totalBasePrice = double.parse(totalBasePrice.toStringAsFixed(2));
        totalAmount = double.parse(totalAmount.toStringAsFixed(2));
        totalBaseTransportAmount =
            double.parse(totalBaseTransportAmount.toStringAsFixed(2));
        totalTransportAmount =
            double.parse(totalTransportAmount.toStringAsFixed(2));
        totalTransportGST = double.parse(totalTransportGST.toStringAsFixed(2));

        // Bind values to your UI elements
        setState(() {
          // Assuming you store these values in variables
          totalBasePrice = totalBasePrice;
          totalAmount = totalAmount;
          totalSGst = totalSGst;
          totalBaseTransportAmount = totalBaseTransportAmount;
          totalTransportAmount = totalTransportAmount;
          totalTransportGST = totalTransportGST;
          totalTransportSGST = totalTransportSGST;
        });

        return products;
      } else {
        throw Exception('list result is null');
      }
    } else {
      throw Exception('Request failed with status: ${jsonResponse.statusCode}');
    }
  }

  @override
  Widget build(BuildContext context) {
    // final size = MediaQuery.of(context).size;
    // 'Payable Amount: $payableAmount'
    return Scaffold(
      appBar: CustomAppBar(title: tr(LocaleKeys.product_details)),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12).copyWith(top: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            RichText(
              text: TextSpan(
                text: '${tr(LocaleKeys.requestCodeLabel)} :  ',
                style: CommonStyles.txStyF14CbFF6,
                children: [
                  TextSpan(
                      text: '${widget.requestCode}',
                      style: CommonStyles.txStyF14CpFF6)
                ],
              ),
            ),
            const SizedBox(height: 5),
            Expanded(
              child: SizedBox(
                // height: size.height * 0.35,
                child: FutureBuilder(
                  future: futureData,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const SizedBox();
                    } else if (snapshot.hasError) {
                      return Center(
                        child: Text(
                            textAlign: TextAlign.center,
                            snapshot.error
                                .toString()
                                .replaceFirst('Exception: ', ''),
                            style: CommonStyles.txStyF16CpFF6),
                      );
                    }
                    final products =
                        snapshot.data as List<FetilizerViewProduct>;
                    return CommonWidgets.customSlideAnimation(
                      itemCount: products.length,
                      childBuilder: (index) {
                        final product = products[index];
                        return productBox(product);
                      },
                    );
                    /* return ListView.builder(
                      itemCount: products.length,
                      itemBuilder: (context, index) {
                        final product = products[index];
                        return productBox(product);
                      },
                    ); */
                  },
                ),
              ),
            ),
            Column(
              children: [
                productCostbox(
                    title: tr(LocaleKeys.amount),
                    data: Decimal.parse(totalBasePrice.toString())
                        .toStringAsFixed(2)),
                productCostbox(
                    title: tr(LocaleKeys.cgst_amount),
                    data:
                        Decimal.parse(totalSGst.toString()).toStringAsFixed(2)),
                // data: totalSGst.toStringAsFixed(2)),
                productCostbox(
                    title: tr(LocaleKeys.sgst_amount),
                    data:
                        Decimal.parse(totalSGst.toString()).toStringAsFixed(2)),
                productCostbox(
                    title: tr(LocaleKeys.total_amt),
                    data: Decimal.parse(totalAmount.toString())
                        .toStringAsFixed(2)),
                CommonStyles.horizontalDivider(),

                // productCostbox(title: tr(LocaleKeys.transamount), data:totalBaseTransportAmount.toStringAsFixed(2)),
                // productCostbox(
                //     title: tr(LocaleKeys.tcgst_amount), data:totalTransportSGST.toStringAsFixed(2)),
                // productCostbox(
                //     title: tr(LocaleKeys.tsgst_amount), data:totalTransportSGST.toStringAsFixed(2)),
                // productCostbox(
                //     title: tr(LocaleKeys.trnstotal_amt), data: totalTransportAmount.toStringAsFixed(2)),
                // productCostbox(title: tr(LocaleKeys.subsidy_amt), data:  subsidyAmount.toStringAsFixed(2)),
                // productCostbox(
                //     title: tr(LocaleKeys.amount_payble), data: paybleamount.toStringAsFixed(2)),
                const SizedBox(height: 20),
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget productBox(FetilizerViewProduct product) {
    return Container(
      padding: const EdgeInsets.all(5),
      margin: const EdgeInsets.only(bottom: 5),
      decoration: BoxDecoration(
        // color: Colors.white,
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFFCCCCCC),
            Color(0xFFFFFFFF),
            Color(0xFFCCCCCC),
          ],
        ),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: Colors.grey.shade400),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 3,
                child: Text(tr(LocaleKeys.product),
                    style: CommonStyles.txStyF14CbFF6),
              ),
              const SizedBox(width: 10),
              Expanded(
                flex: 7,
                child:
                    Text('${product.name}', style: CommonStyles.txStyF14CpFF6),
              ),
            ],
          ),
          productInfo(
            label1: tr(LocaleKeys.each_product),
            data1: formatDouble(product.bagCost),
            label2: tr(LocaleKeys.gst),
            data2: '${product.gstPercentage}',
          ),
          productInfo(
            label1: tr(LocaleKeys.quantity),
            data1: '${product.quantity}',
            label2: tr(LocaleKeys.amount),
            data2: formatDouble(product.amount),
          ),
          // productInfo(
          //   label1: tr(LocaleKeys.transportprice),
          //   data1: '${product.transPortCost}',
          //   label2: tr(LocaleKeys.gst),
          //   data2: '${product.transPortCgstPercentage}',
          // ),
          // productInfo(
          //   label1: tr(LocaleKeys.totaltransportcost),
          //   data1: formatDouble(product.transPortTotalAmount),
          //   label2: tr(LocaleKeys.total_amt),
          //   data2: formatDouble(null),
          // ),
        ],
      ),
    );
  }

  String formatDouble(double? value) {
    if (value == null) return '0.00';
    return value.toStringAsFixed(2);
  }

  Widget productCostbox({
    required String title,
    required String data,
  }) {
    return Column(
      children: [
        CommonStyles.horizontalDivider(colors: [
          const Color(0xFFFF4500),
          const Color(0xFFA678EF),
          const Color(0xFFFF4500),
        ]),
        const SizedBox(height: 2),
        Row(
          children: [
            Expanded(
                flex: 6,
                child: Text(
                  title,
                  style: CommonStyles.txStyF14CpFF6,
                )),
            const Expanded(
                flex: 1,
                child: Text(
                  ':',
                  style: CommonStyles.txStyF14CpFF6,
                )),
            Expanded(
                flex: 5,
                child: Text(
                  data,
                  style: CommonStyles.txStyF14CpFF6,
                )),
          ],
        ),
        const SizedBox(height: 2),
      ],
    );
  }

  Column productInfo({
    required String label1,
    required String data1,
    required String label2,
    required String data2,
  }) {
    return Column(
      children: [
        CommonStyles.horizontalDivider(),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Flexible(
                    flex: 4,
                    child: Text(label1, style: CommonStyles.txStyF14CbFF6),
                  ),
                  const SizedBox(width: 3),
                  Expanded(
                    flex: 2,
                    child: Text(data1, style: CommonStyles.txStyF14CbFF6),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 5),
            Expanded(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Flexible(
                    flex: 4,
                    child: Text(label2, style: CommonStyles.txStyF14CbFF6),
                  ),
                  const SizedBox(width: 3),
                  Expanded(
                    flex: 2,
                    child: Text(data2, style: CommonStyles.txStyF14CbFF6),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }
}
