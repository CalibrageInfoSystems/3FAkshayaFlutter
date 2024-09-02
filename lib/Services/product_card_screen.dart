import 'dart:convert';

import 'package:akshaya_flutter/Services/models/catogery_item_model.dart';
import 'package:akshaya_flutter/Services/select_products_screen.dart';
import 'package:akshaya_flutter/common_utils/common_styles.dart';
import 'package:akshaya_flutter/common_utils/custom_appbar.dart';
import 'package:akshaya_flutter/common_utils/custom_btn.dart';
import 'package:akshaya_flutter/localization/locale_keys.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class ProductCardScreen extends StatefulWidget {
  final List<ProductWithQuantity> products;
  const ProductCardScreen({super.key, required this.products});

  @override
  State<ProductCardScreen> createState() => _ProductCardScreenState();
}

class _ProductCardScreenState extends State<ProductCardScreen> {
  int? selectedDropDownValue = -1;

  @override
  void initState() {
    super.initState();
  }

  Future<List<dynamic>> getDropdownData() async {
    const apiUrl =
        'http://182.18.157.215/3FAkshaya/API/api/Farmer/GetPaymentsTypeByFarmerCode/APWGBDAB00010005';

    final jsonResponse = await http.get(Uri.parse(apiUrl));

    if (jsonResponse.statusCode == 200) {
      final response = jsonDecode(jsonResponse.body);
      if (response['listResult'] != null) {
        return response['listResult'] as List<dynamic>;
      } else {
        throw Exception('listResult is empty');
      }
    } else {
      throw Exception('Failed to load data');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: tr(LocaleKeys.product_req),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                children: [
                  Text('Payment Details', style: CommonStyles.txSty_14b_f5),
                  SizedBox(width: 5),
                  Text(
                    '*',
                    style: TextStyle(color: Colors.red),
                  ),
                ],
              ),
              const SizedBox(height: 5),
              dropdownWidget(),
              const SizedBox(height: 10),
              const Text('Product Details', style: CommonStyles.txSty_14b_f5),
              const SizedBox(height: 5),
              Column(
                children: [
                  ListView.builder(
                      itemCount: widget.products.length,
                      physics: const NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      itemBuilder: (context, index) {
                        return widget.products[index].quantity == 0
                            ? const SizedBox()
                            : productBox(widget.products[index]);
                      }),
                  const SizedBox(height: 20),
                  CommonStyles.horizontalGradientDivider(colors: [
                    const Color(0xFFFF4500),
                    const Color(0xFFA678EF),
                    const Color(0xFFFF4500),
                  ]),
                  noteBox(),
                  productCostbox(title: 'Amount (Rs)', data: 'data'),
                  productCostbox(title: 'Amount (Rs)', data: 'data'),
                  productCostbox(title: 'Amount (Rs)', data: 'data'),
                  productCostbox(title: 'Amount (Rs)', data: 'data'),
                  productCostbox(title: 'Amount (Rs)', data: 'data'),
                  productCostbox(title: 'Amount (Rs)', data: 'data'),
                  productCostbox(title: 'Amount (Rs)', data: 'data'),
                  CommonStyles.horizontalGradientDivider(colors: [
                    const Color(0xFFFF4500),
                    const Color(0xFFA678EF),
                    const Color(0xFFFF4500),
                  ]),
                  CustomBtn(
                    label: 'Submit',
                    borderColor: CommonStyles.primaryTextColor,
                    borderRadius: 12,
                    onPressed: () {},
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget productCostbox({
    required String title,
    required String data,
  }) {
    return Column(
      children: [
        CommonStyles.horizontalGradientDivider(colors: [
          const Color(0xFFFF4500),
          const Color(0xFFA678EF),
          const Color(0xFFFF4500),
        ]),
        Row(
          children: [
            Expanded(
                flex: 6,
                child: Text(
                  title,
                  style: CommonStyles.txSty_14p_f5,
                )),
            const Expanded(
                flex: 1,
                child: Text(
                  ':',
                  style: CommonStyles.txSty_14p_f5,
                )),
            Expanded(
                flex: 5,
                child: Text(
                  data,
                  style: CommonStyles.txSty_14p_f5,
                )),
          ],
        ),
      ],
    );
  }

  Container noteBox() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: const Color.fromARGB(255, 231, 224, 148),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Note',
            style: CommonStyles.text18orangeeader,
          ),
          Text(
            'If the products has not been picked with in 5 days of requested date, Your order will be cancelled.',
            style: CommonStyles.txSty_14b_f5,
          ),
        ],
      ),
    );
  }

  Container dropdownWidget() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey),
      ),
      clipBehavior: Clip.antiAlias,
      child: FutureBuilder(
        future: getDropdownData(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            final paymentmodes = snapshot.data as List<dynamic>;
            return filterDropDown(paymentmodes);
          } else if (snapshot.hasError) {
            return Text('${tr(LocaleKeys.error)}: ${snapshot.error}');
          }
          return Container(
            padding: const EdgeInsets.all(10),
            child: const Center(child: Text('loading...')),
          );
        },
      ),
    );
  }

  Widget filterDropDown(List<dynamic> paymentmodes) {
    return DropdownButtonHideUnderline(
      child: ButtonTheme(
        alignedDropdown: true,
        child: DropdownButton2<int>(
          isExpanded: true,
          items: [
            const DropdownMenuItem<int>(
              value: -1,
              child: Text(
                'Select payment mode',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
                textAlign: TextAlign.center,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            ...paymentmodes.asMap().entries.map((entry) {
              final index = entry.key;
              final item = entry.value;
              return DropdownMenuItem<int>(
                value: index,
                child: Text(
                  item['desc'],
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                  textAlign: TextAlign.center,
                  overflow: TextOverflow.ellipsis,
                ),
              );
            }),
          ].toList(),
          value: selectedDropDownValue,
          onChanged: (value) {
            setState(() {
              selectedDropDownValue = value!;
              if (selectedDropDownValue != -1) {
                final paymentmodeId =
                    paymentmodes[selectedDropDownValue!]['typeCdId'];

                final paymentmodeName =
                    paymentmodes[selectedDropDownValue!]['desc'];

                print('setState: $paymentmodeId');
                print('setState: $paymentmodeName');
              }
            });
          },
          buttonStyleData: const ButtonStyleData(
            height: 45,
            width: double.infinity,
            padding: EdgeInsets.only(left: 14, right: 14),
          ),
          iconStyleData: const IconStyleData(
            icon: Icon(
              Icons.arrow_drop_down_sharp,
            ),
            iconSize: 24,
            iconEnabledColor: Color(0xFF11528f),
            iconDisabledColor: Color(0xFF11528f),
          ),
          dropdownStyleData: DropdownStyleData(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              color: Colors.grey,
            ),
            offset: const Offset(0, 0),
            scrollbarTheme: ScrollbarThemeData(
              radius: const Radius.circular(40),
              thickness: WidgetStateProperty.all<double>(6),
              thumbVisibility: WidgetStateProperty.all<bool>(true),
            ),
          ),
          menuItemStyleData: const MenuItemStyleData(
            height: 40,
            padding: EdgeInsets.only(left: 20, right: 20),
          ),
        ),
      ),
    );
  }

  Widget productBox(ProductWithQuantity productinfo) {
    final product = productinfo.product;
    final quantity = productinfo.quantity;
    final productQuantity = product.actualPriceInclGst! * quantity;
    final totalTrasport = product.transPortActualPriceInclGst! * quantity;
    final totalAmount = productQuantity + product.transPortActualPriceInclGst!;
    return Container(
      padding: const EdgeInsets.all(10),
      margin: const EdgeInsets.only(bottom: 10),
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
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey.shade400),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Expanded(
                child: Text('Product', style: CommonStyles.txSty_14b_f5),
              ),
              SizedBox(width: 10),
              Expanded(
                child: Text('Urea', style: CommonStyles.txSty_14p_f5),
              ),
            ],
          ),
          productInfo(
            label1: 'Item Cost(Rs)',
            data1: '${product.actualPriceInclGst}',
            label2: 'GST(%)',
            data2: '${product.gstPercentage}',
          ),
          productInfo(
            label1: 'Quantity',
            data1: '$quantity',
            label2: 'Amount(Rs)',
            data2: '$productQuantity',
          ),
          productInfo(
            label1: 'Trasport Cost(Rs)',
            data1: '${product.transPortActualPriceInclGst}',
            label2: 'GST(%)',
            data2: '${product.transportGstPercentage}',
          ),
          productInfo(
            label1: 'Total Transport\nAmount (Rs)',
            data1: '$totalTrasport',
            label2: 'Total Amount',
            data2: '$totalAmount',
          ),
        ],
      ),
    );
  }

  Column productInfo(
      {required String label1,
      required String data1,
      required String label2,
      required String data2}) {
    return Column(
      children: [
        CommonStyles.horizontalGradientDivider(),
        Row(
          children: [
            Expanded(
                child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(label1, style: CommonStyles.txSty_14b_f5),
                Text(data1, style: CommonStyles.txSty_14b_f5)
              ],
            )),
            const SizedBox(width: 10),
            Expanded(
                child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(label2, style: CommonStyles.txSty_14b_f5),
                Text(data2, style: CommonStyles.txSty_14b_f5)
              ],
            )),
          ],
        ),
      ],
    );
  }

/* 
  Widget filterDropDown(List<dynamic> paymentmodes) {
    return DropdownButtonHideUnderline(
      child: ButtonTheme(
        alignedDropdown: true,
        child: DropdownButton2<int>(
          isExpanded: true,
          items: [
            const DropdownMenuItem<int>(
              value: -1,
              child: Text(
                ' Select Purpose of Visit',
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 14,
                  fontFamily: 'Outfit',
                ),
              ),
            ),
            ...paymentmodes.asMap().entries.map((entry) {
              final index = entry.key;
              final item = entry.value;
              return DropdownMenuItem<int>(
                value: index,
                child: Text(
                  item['desc'],
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    color: Colors.black,
                    fontFamily: 'Outfit',
                  ),
                ),
              );
            }),
          ].toList(),
          value: selectedDropDownValue,
          onChanged: (value) {},
          buttonStyleData: const ButtonStyleData(
            height: 45,
            width: double.infinity,
            padding: EdgeInsets.only(left: 14, right: 14),
          ),
          iconStyleData: const IconStyleData(
            icon: Icon(
              Icons.arrow_drop_down_sharp,
            ),
            iconSize: 24,
            iconEnabledColor: Color(0xFF11528f),
            iconDisabledColor: Color(0xFF11528f),
          ),
          dropdownStyleData: DropdownStyleData(
            maxHeight: MediaQuery.of(context).size.height / 4,
            width: MediaQuery.of(context).size.width / 1.1,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: Colors.grey.shade50,
            ),
            scrollbarTheme: ScrollbarThemeData(
              radius: const Radius.circular(40),
              thickness: WidgetStateProperty.all<double>(6),
              thumbVisibility: WidgetStateProperty.all<bool>(true),
            ),
          ),
          menuItemStyleData: const MenuItemStyleData(
            height: 40,
            padding: EdgeInsets.only(left: 14, right: 14),
          ),
        ),
      ),
    );
  } */
}
