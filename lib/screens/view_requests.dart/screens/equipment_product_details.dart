import 'dart:convert';

import 'package:akshaya_flutter/common_utils/api_config.dart';
import 'package:akshaya_flutter/common_utils/common_styles.dart';
import 'package:akshaya_flutter/common_utils/custom_appbar.dart';
import 'package:akshaya_flutter/localization/locale_keys.dart';
import 'package:akshaya_flutter/models/fertilizer_view_product_model.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class EquipmentProductDetails extends StatefulWidget {
  final String? requestCode;
  const EquipmentProductDetails({super.key, this.requestCode});

  @override
  State<EquipmentProductDetails> createState() =>
      _EquipmentProductDetailsState();
}

class _EquipmentProductDetailsState extends State<EquipmentProductDetails> {
  late Future<List<FetilizerViewProduct>> futureData;

  @override
  void initState() {
    super.initState();
    futureData = getFetilizerProductDetails();
  }

  Future<List<FetilizerViewProduct>> getFetilizerProductDetails() async {
    final apiUrl = '$baseUrl$getFertilizerProductDetails${widget.requestCode}';

    final jsonResponse = await http.get(Uri.parse(apiUrl));

    if (jsonResponse.statusCode == 200) {
      Map<String, dynamic> response = jsonDecode(jsonResponse.body);
      if (response['listResult'] != null) {
        List<dynamic> list = response['listResult'];
        List<FetilizerViewProduct> products =
            list.map((item) => FetilizerViewProduct.fromJson(item)).toList();
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
    return Scaffold(
      appBar: CustomAppBar(title: tr(LocaleKeys.product_details)),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            RichText(
              text: TextSpan(
                text: 'Request Id ',
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
              child: FutureBuilder(
                future: futureData,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  } else if (snapshot.hasError) {
                    return Text(
                        snapshot.error
                            .toString()
                            .replaceFirst('Exception: ', ''),
                        style: CommonStyles.txStyF16CpFF6);
                  }
                  final products = snapshot.data as List<FetilizerViewProduct>;

                  return ListView.builder(
                    itemCount: products.length,
                    itemBuilder: (context, index) {
                      final product = products[index];
                      return productBox(product);
                    },
                  );
                },
              ),
            ),
            Column(
              children: [
                const SizedBox(height: 10),
                productCostbox(title: tr(LocaleKeys.amount), data: 'data'),
                CommonStyles.horizontalGradien_Divider2(),
                productCostbox(title: tr(LocaleKeys.cgst_amount), data: 'data'),
                CommonStyles.horizontalGradientDivider2(),
                productCostbox(title: tr(LocaleKeys.sgst_amount), data: 'data'),
                CommonStyles.horizontalGradientDivider2(),
                productCostbox(title: tr(LocaleKeys.total_amt), data: 'data'),
                CommonStyles.horizontalGradien_Divider2(),
                /* productCostbox(title: tr(LocaleKeys.transamount), data: 'data'),
                productCostbox(
                    title: tr(LocaleKeys.tcgst_amount), data: 'data'),
                productCostbox(
                    title: tr(LocaleKeys.tsgst_amount), data: 'data'),
                productCostbox(
                    title: tr(LocaleKeys.trnstotal_amt), data: 'data'),
                productCostbox(title: tr(LocaleKeys.subsidy_amt), data: 'data'),
                productCostbox(
                    title: tr(LocaleKeys.amount_payble), data: 'data'),
                const SizedBox(height: 20), */
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
            children: [
              Expanded(
                flex: 4,
                child: Text(tr(LocaleKeys.product),
                    style: CommonStyles.txStyF14CbFF6),
              ),
              //   const SizedBox(width: 10),
              Expanded(
                flex: 6,
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
          /*  productInfo(
            label1: tr(LocaleKeys.transportprice),
            data1: '${product.transPortCost}',
            label2: tr(LocaleKeys.gst),
            data2: '${product.transPortCgstPercentage}',
          ),
          productInfo(
            label1: tr(LocaleKeys.totaltransportcost),
            data1: formatDouble(product.transPortTotalAmount),
            label2: tr(LocaleKeys.total_amt),
            data2: formatDouble(null),
          ), */
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
        // CommonStyles.horizontalGradientDivider(colors: [
        //   const Color(0xFFFF4500),
        //   const Color(0xFFA678EF),
        //   const Color(0xFFFF4500),
        // ]),
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
        CommonStyles.horizontalGradientDivider2(),
        Row(
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
