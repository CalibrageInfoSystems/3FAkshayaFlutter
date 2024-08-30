import 'dart:convert';

import 'package:akshaya_flutter/Services/models/catogery_item_model.dart';
import 'package:akshaya_flutter/Services/models/product_item_model.dart';
import 'package:akshaya_flutter/common_utils/common_styles.dart';
import 'package:akshaya_flutter/common_utils/custom_appbar.dart';
import 'package:akshaya_flutter/common_utils/custom_btn.dart';
import 'package:akshaya_flutter/localization/locale_keys.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shimmer/shimmer.dart';

class SelectProductsScreen extends StatefulWidget {
  const SelectProductsScreen({super.key});

  @override
  State<SelectProductsScreen> createState() => _SelectProductsScreenState();
}

class _SelectProductsScreenState extends State<SelectProductsScreen> {
  // tr(LocaleKeys.crop),

  final List<String> dropdownItems = [
    tr(LocaleKeys.home),
    tr(LocaleKeys.home),
    tr(LocaleKeys.home),
  ];
  String? selectedDropDownValue;
  late Future<List<ProductItem>> productsData;

  @override
  void initState() {
    super.initState();
    productsData = getProducts();
  }

  Future<List<CategoryItem>> getDropdownData() async {
    const apiUrl =
        'http://182.18.157.215/3FAkshaya/API/api/Categories/GetCategoriesByParentCategory/1';

    final jsonResponse = await http.get(Uri.parse(apiUrl));

    if (jsonResponse.statusCode == 200) {
      final response = jsonDecode(jsonResponse.body);
      if (response['listResult'] != null) {
        List<dynamic> listResult = response['listResult'];
        return listResult.map((item) => CategoryItem.fromJson(item)).toList();
      } else {
        throw Exception('list result is null');
      }
    } else {
      throw Exception('Failed to load data: ${jsonResponse.statusCode}');
    }
  }

  Future<List<ProductItem>> getProducts() async {
    const apiUrl =
        'http://182.18.157.215/3FAkshaya/API/api/Products/GetProductsByGodown/1/AgrGAPYG';

    final jsonResponse = await http.get(Uri.parse(apiUrl));

    if (jsonResponse.statusCode == 200) {
      final response = jsonDecode(jsonResponse.body);
      if (response['listResult'] != null) {
        List<dynamic> listResult = response['listResult'];
        return listResult.map((item) => ProductItem.fromJson(item)).toList();
      } else {
        throw Exception('list result is null');
      }
    } else {
      throw Exception('Failed to load data: ${jsonResponse.statusCode}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: CustomAppBar(
          title: tr(LocaleKeys.select_product),
          actionIcon: Container(
            padding: const EdgeInsets.all(5),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.white),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              tr(LocaleKeys.crop),
              textAlign: TextAlign.center,
              style: CommonStyles.txSty_12W_fb,
            ),
          ),
        ),
        body: Column(
          children: [
            headerSection(),
            Expanded(child: filterAndProductSection()),
          ],
        ));
  }

  Widget filterAndProductSection() {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            tr(LocaleKeys.Categorytype),
            style: CommonStyles.txSty_14b_f5,
          ),
          const SizedBox(height: 10),
          Container(
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
                  final categories = snapshot.data as List<CategoryItem>;
                  return filterDropDown(categories);
                } else if (snapshot.hasError) {
                  return Text('${tr(LocaleKeys.error)}: ${snapshot.error}');
                }
                return Container(
                  padding: const EdgeInsets.all(10),
                  child: const Center(child: Text('loading...')),
                );
              },
            ),
          ),
          const SizedBox(height: 10),
          Expanded(
            child: FutureBuilder(
              future: productsData,
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  final products = snapshot.data as List<ProductItem>;
                  return GridView.builder(
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 10.0,
                            mainAxisSpacing: 10.0,
                            mainAxisExtent: 250,
                            childAspectRatio: 8 / 2),
                    itemCount: 12,
                    itemBuilder: (context, index) {
                      final product = products[index];
                      return ProductCard(product: product);
                    },
                  );
                } else if (snapshot.hasError) {
                  return Text('${tr(LocaleKeys.error)}: ${snapshot.error}');
                }
                return shimmerLoading();
              },
            ),
          ),
        ],
      ),
    );
  }

  GridView shimmerLoading() {
    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 10.0,
          mainAxisSpacing: 10.0,
          mainAxisExtent: 250,
          childAspectRatio: 8 / 2),
      itemCount: 12,
      itemBuilder: (context, index) {
        return Shimmer.fromColors(
          baseColor: Colors.grey.shade300,
          highlightColor: Colors.grey.shade100,
          child: Container(
            width: 220,
            height: 300,
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 5),
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      },
    );
  }

  Widget filterDropDown(List<CategoryItem> categories) {
    return DropdownButtonHideUnderline(
      child: DropdownButton2<String>(
        iconStyleData: const IconStyleData(
          icon: Icon(
            Icons.arrow_drop_down_rounded,
            color: Colors.black,
          ),
        ),
        isExpanded: true,
        hint: const Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(
                child: Text(
                  'Select Item',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                  textAlign: TextAlign.center,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
        items: categories
            .map((CategoryItem category) => DropdownMenuItem<String>(
                  value: category.name,
                  child: Center(
                    child: Text(
                      '${category.name}',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                      textAlign: TextAlign.center,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ))
            .toList(),
        value: selectedDropDownValue,
        onChanged: (String? value) {
          setState(() {
            selectedDropDownValue = value;
          });
        },
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
    );
  }

  Container headerSection() {
    return Container(
      color: Colors.grey.shade300,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: const Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Icon(Icons.shop),
          CustomBtn(
            label: 'Next',
            borderColor: CommonStyles.primaryTextColor,
            backgroundColor: Colors.white,
            borderRadius: 16,
          ),
        ],
      ),
    );
  }
}

class ProductCard extends StatelessWidget {
  final ProductItem product;
  const ProductCard({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    return Container(
      /* width: 220,
      height: 300, */
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 5),
      decoration: BoxDecoration(
        color: Colors.grey.shade300,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const SizedBox(),
              Text(
                '${product.name}',
                style: CommonStyles.txSty_14p_f5,
              ),
              const Icon(
                Icons.info,
                color: CommonStyles.primaryTextColor,
              ),
            ],
          ),
          const SizedBox(height: 5),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${product.priceInclGst}',
                style: CommonStyles.txSty_14b_f5,
              ),
              Text(
                '${product.size} ${product.uomType}',
                style: CommonStyles.txSty_14p_f5,
              ),
            ],
          ),
          const SizedBox(height: 5),
          Expanded(
              child: Center(
                  child: Image.network(
            '${product.imageUrl}',
            fit: BoxFit.cover,
          ))),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Qty: ',
                style: CommonStyles.txSty_14b_f5,
              ),
              Row(
                children: [
                  IconButton(
                    style: iconBtnStyle(
                      foregroundColor: CommonStyles.primaryTextColor,
                    ),
                    icon: const Icon(Icons.remove),
                    onPressed: () {},
                  ),
                  const SizedBox(width: 5),
                  const Text(
                    '0',
                    style: CommonStyles.texthintstyle,
                  ),
                  const SizedBox(width: 5),
                  IconButton(
                    style: iconBtnStyle(
                      foregroundColor: CommonStyles.statusGreenText,
                    ),
                    icon: const Icon(Icons.add),
                    onPressed: () {},
                  ),
                ],
              ),
              const SizedBox(),
            ],
          )
        ],
      ),
    );
  }

  ButtonStyle iconBtnStyle({required Color? foregroundColor}) {
    return IconButton.styleFrom(
        foregroundColor: foregroundColor,
        shape: const CircleBorder(),
        padding: const EdgeInsets.all(4.0),
        side: const BorderSide(color: Colors.grey));
  }
}
