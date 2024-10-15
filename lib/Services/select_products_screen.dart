import 'dart:convert';

// import 'package:akshaya_flutter/Services/models/Godowndata.dart';
import 'package:akshaya_flutter/services/models/Godowndata.dart';

import 'package:akshaya_flutter/Services/models/catogery_item_model.dart';
import 'package:akshaya_flutter/Services/models/product_item_model.dart';
import 'package:akshaya_flutter/Services/product_card_screen.dart';
import 'package:akshaya_flutter/common_utils/common_styles.dart';
import 'package:akshaya_flutter/common_utils/custom_appbar.dart';
import 'package:akshaya_flutter/common_utils/custom_btn.dart';
import 'package:akshaya_flutter/gen/assets.gen.dart';
import 'package:akshaya_flutter/localization/locale_keys.dart';
import 'package:animated_read_more_text/animated_read_more_text.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shimmer/shimmer.dart';
import 'package:badges/badges.dart' as badges;
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';

import '../common_utils/api_config.dart';
import '../screens/home_screen/screens/plot_selection_screen.dart';

class SelectProductsScreen extends StatefulWidget {
  final Godowndata godown;

  const SelectProductsScreen({super.key, required this.godown});

  @override
  State<SelectProductsScreen> createState() => _SelectProductsScreenState();
}

class _SelectProductsScreenState extends State<SelectProductsScreen> {
  // tr(LocaleKeys.crop),

  Map<int, int> productQuantities = {};
  int badgeCount = 0;

  String? selectedDropDownValue;
  late Future<List<ProductItem>> productsData;
  late List<ProductItem> copyProductsData = [];
  @override
  void initState() {
    super.initState();
    productsData = getProducts();

    copyProducts();
  }

  Future<void> filterProductsByCatogary(int catogaryId) async {
    productsData = Future.value(
      catogaryId == -1
          ? copyProductsData
          : copyProductsData
              .where((item) => item.categoryId == catogaryId)
              .toList(),
    );
  }

  void copyProducts() async {
    copyProductsData = await productsData;
  }

  List<ProductWithQuantity> fetchCardProducts() {
    final result = copyProductsData
        .where((product) => productQuantities.containsKey(product.id))
        .map((product) => ProductWithQuantity(
              product: product,
              quantity: productQuantities[product.id] ?? 0,
            ))
        .toList();
    print(
        'fetchCardProducts: ${jsonEncode(result.map((p) => p.toJson()).toList())}');
    return result;
  }

  Future<List<CategoryItem>> getDropdownData() async {
    final apiUrl = '$baseUrl$GetCategoriesByParentCategory';
    // const apiUrl = 'http://182.18.157.215/3FAkshaya/API/api/Categories/GetCategoriesByParentCategory/1';

    final jsonResponse = await http.get(Uri.parse(apiUrl));

    if (jsonResponse.statusCode == 200) {
      final response = jsonDecode(jsonResponse.body);
      if (response['listResult'] != null) {
        List<dynamic> listResult = response['listResult'];
        List<CategoryItem> categoryItems =
            listResult.map((item) => CategoryItem.fromJson(item)).toList();
        categoryItems.insert(0, CategoryItem(categoryId: -1, name: 'Select'));
        return categoryItems;
      } else {
        throw Exception('list result is null');
      }
    } else {
      throw Exception('Failed to load data: ${jsonResponse.statusCode}');
    }
  }

  Future<List<ProductItem>> getProducts() async {
    // const apiUrl = 'http://182.18.157.215/3FAkshaya/API/api/Products/GetProductsByGodown/1/AgrGAPYG';
    try {
      final apiUrl = '$baseUrl$Getproductdata/1/${widget.godown.code}';
      print('getProducts: $apiUrl');
      final jsonResponse = await http.get(Uri.parse(apiUrl));
      print('getProducts: ${jsonResponse.body}');

      if (jsonResponse.statusCode == 200) {
        final response = jsonDecode(jsonResponse.body);
        if (response['listResult'] != null) {
          List<dynamic> listResult = response['listResult'];
          return listResult.map((item) => ProductItem.fromJson(item)).toList();
        } else {
          return []; // Return empty list if listResult is null
        }
      } else {
        throw Exception('Failed to load data: ${jsonResponse.statusCode}');
      }
    } catch (e) {
      throw Exception('Error occurred while fetching products: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CommonStyles.screenBgColor2,
      appBar: appBar(context),
      body: Column(
        children: [
          headerSection(),
          Expanded(child: filterAndProductSection()),
        ],
      ),
    );
  }

  CustomAppBar appBar(BuildContext context) {
    return CustomAppBar(
      title: tr(LocaleKeys.select_product),
      actionIcon: Row(
        children: [
          GestureDetector(
            onTap: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => const PlotSelectionScreen(
                    serviceTypeId: 100,
                  ),
                ),
              );
            },
            child: Container(
              width: 120,
              margin: const EdgeInsets.fromLTRB(5, 5, 0, 5),
              padding: const EdgeInsets.symmetric(
                horizontal: 5,
              ),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.white),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Center(
                child: Text(
                  tr(LocaleKeys.recommendationss),
                  textAlign: TextAlign.center,
                  style: CommonStyles.txStyF12CwFF6,
                ),
              ),
            ),
          ),
          const SizedBox(width: 10)
        ],
      ),
    );
  }

  Widget filterAndProductSection() {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            tr(LocaleKeys.Categorytype),
            style: CommonStyles.txStyF16CbFF6.copyWith(
              color: CommonStyles.blackColorShade,
            ),
          ),
          const SizedBox(height: 10),
          Container(
            width: double.infinity,
            // padding: const EdgeInsets.symmetric(horizontal: 10),
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
                  return Text('${tr(LocaleKeys.error)}: ${snapshot.error}',
                      style: CommonStyles.txStyF16CpFF6);
                }
                return Container(
                  padding: const EdgeInsets.all(10),
                  child: const Center(child: Text('loading...')),
                );
              },
            ),
          ),
          const SizedBox(height: 10),
          FutureBuilder(
            future: productsData,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return shimmerLoading();
              }
              if (snapshot.hasError) {
                return Text('${tr(LocaleKeys.error)}: ${snapshot.error}',
                    style: CommonStyles.txStyF16CpFF6);
              } else {
                final products = snapshot.data as List<ProductItem>;
                if (products.isNotEmpty) {
                  return Expanded(
                    child: GridView.builder(
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              crossAxisSpacing: 5.0,
                              mainAxisSpacing: 5.0,
                              mainAxisExtent: 250,
                              childAspectRatio: 8 / 2),
                      itemCount: products.length,
                      itemBuilder: (context, index) {
                        final product = products[index];
                        final quantity = productQuantities[product.id] ?? 0;
                        return ProductCard(
                          product: product,
                          quantity: quantity,
                          onQuantityChanged: (newQuantity) {
                            setState(() {
                              productQuantities[product.id!] = newQuantity;
                              updateBadgeCount();
                            });
                          },
                        );
                      },
                    ),
                  );
                } else {
                  return const Expanded(
                    child: Center(
                      child: Text(
                        'No products found',
                        style: CommonStyles.txStyF16CpFF6,
                      ),
                    ),
                  );
                }
              }
            },
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
        buttonStyleData: const ButtonStyleData(
          // height: 45,
          width: double.infinity,
          padding: EdgeInsets.only(left: 14, right: 14),
        ),
        iconStyleData: const IconStyleData(
          icon: Icon(
            Icons.arrow_drop_down_sharp,
            color: CommonStyles.blackColorShade,
            // color: CommonStyles.blackColorShade,
          ),
        ),
        isExpanded: true,
        hint: const Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(
                child: Text(
                  'Select',
                  style: CommonStyles.txStyF14CbFF6,
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
                      style: CommonStyles.txStyF14CbFF6,
                      textAlign: TextAlign.center,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ))
            .toList(),
        value: selectedDropDownValue,
        style: CommonStyles.txStyF14CwFF6,
        onChanged: (String? value) {
          setState(() {
            selectedDropDownValue = value;
          });
          filterProductsByCatogary(
            categories.where((item) => item.name == value).first.categoryId ??
                0,
          );
        },
        dropdownStyleData: DropdownStyleData(
          decoration: const BoxDecoration(
            color: CommonStyles.screenBgColor,
            borderRadius: BorderRadius.only(
                bottomRight: Radius.circular(12),
                bottomLeft: Radius.circular(12)),
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
          // padding: EdgeInsets.only(left: 20, right: 20),
        ),
      ),
    );
  }

  Container headerSection() {
    return Container(
      color: const Color(0xffc6c6c6),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              badges.Badge(
                badgeContent: Text(
                  '$badgeCount',
                  style: CommonStyles.txStyF12CwFF6,
                ),
                badgeAnimation: const badges.BadgeAnimation.fade(
                  animationDuration: Duration(seconds: 1),
                  colorChangeAnimationDuration: Duration(seconds: 1),
                  loopAnimation: false,
                  curve: Curves.fastOutSlowIn,
                  colorChangeAnimationCurve: Curves.easeInCubic,
                ),
                child: Image.asset(
                  Assets.images.cart.path,
                  width: 30,
                  height: 30,
                ),
              ),
              const SizedBox(width: 10),
              Text(
                calculateTotalAmount() == 0
                    ? ' ₹0'
                    : ' ₹${calculateTotalAmount().toStringAsFixed(2)}',
                style: CommonStyles.text16white,
              ),
            ],
          ),
          CustomBtn(
            label: tr(LocaleKeys.next),
            borderColor: CommonStyles.primaryTextColor,
            borderRadius: 16,
            btnTextStyle: CommonStyles.txStyF12CpFF6.copyWith(fontSize: 14),
            padding: const EdgeInsets.symmetric(
              horizontal: 25,
            ),
            onPressed: () {
              // if (fetchCardProducts().isNotEmpty) {
              if (calculateTotalAmount() != 0) {
                print(
                    'xxx: calculateTotalAmount().length: ${calculateTotalAmount()}');
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ProductCardScreen(
                      products: fetchCardProducts(),
                      godown: widget.godown,
                    ),
                  ),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Please add at least one product.'),
                  ),
                );
              }
            },
          ),
        ],
      ),
    );
  }

  void updateBadgeCount() {
    badgeCount =
        productQuantities.values.fold(0, (sum, quantity) => sum + quantity);
    print('productQuantities: $productQuantities');
  }

  double calculateTotalAmount() {
    return fetchCardProducts()
        .map((productWithQuantity) => productWithQuantity.totalPrice)
        .fold(0.0, (previousValue, element) => previousValue + element);
  }
}

class ProductCard extends StatefulWidget {
  final ProductItem product;
  final int quantity;
  final Function(int) onQuantityChanged;

  const ProductCard({
    super.key,
    required this.product,
    required this.quantity,
    required this.onQuantityChanged,
  });

  @override
  State<ProductCard> createState() => _ProductCardState();
}

class _ProductCardState extends State<ProductCard> {
  late int productQuantity;

  @override
  void initState() {
    super.initState();
    productQuantity = widget.quantity;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 5),
      decoration: BoxDecoration(
        color: CommonStyles.whiteColor,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /*  Expanded(
                child: Text(
                  '${widget.product.name}',
                  style: CommonStyles.txStyF14CpFF6,
                ),
              ), */
              Expanded(
                child: AnimatedReadMoreText(
                  '${widget.product.name}',
                  textStyle: CommonStyles.txStyF14CpFF6,
                  maxLines: 2,
                  readMoreText: '..',
                  readLessText: '.',
                  buttonTextStyle: CommonStyles.txSty_14p_f5,
                ),
              ),
              GestureDetector(
                onTap: openProductInfoDialog,
                child: Image.asset(
                  Assets.images.infoIcon.path,
                  width: 25,
                  height: 25,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Text(
                    '₹${widget.product.priceInclGst}',
                    style: CommonStyles.txStyF14CbFF6,
                  ),
                  const SizedBox(width: 15),
                  if (widget.product.priceInclGst !=
                      widget.product.actualPriceInclGst)
                    Text(
                      '₹${widget.product.actualPriceInclGst}',
                      style: CommonStyles.txStyF14CbFF6.copyWith(
                        decoration: TextDecoration.lineThrough,
                        decorationColor: CommonStyles.RedColor,
                        color: CommonStyles.formFieldErrorBorderColor,
                      ),
                    ),
                ],
              ),
              widget.product.size != null && widget.product.uomType != null
                  ? Text(
                      '${widget.product.size} ${widget.product.uomType}',
                      style: CommonStyles.txStyF14CpFF6,
                    )
                  : const SizedBox(),
            ],
          ),
          const SizedBox(height: 5),
          Expanded(
            child: Center(
              child: CachedNetworkImage(
                width: 100,
                height: 100,
                imageUrl: '${widget.product.imageUrl}',
                placeholder: (context, url) =>
                    // const CircularProgressIndicator(),
                    Shimmer.fromColors(
                        baseColor: Colors.grey.shade300,
                        highlightColor: Colors.grey.shade100,
                        child: Container(
                            width: 100,
                            height: 100,
                            decoration: BoxDecoration(
                              color: Colors.grey.shade300,
                              borderRadius: BorderRadius.circular(10.0),
                            ))),
                errorWidget: (context, url, error) => Image.asset(
                  Assets.images.icLogo.path,
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
          const SizedBox(height: 3),
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              const Text(
                'Qty:',
                style: CommonStyles.txSty_14b_f5,
              ),
              const SizedBox(width: 5),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GestureDetector(
                    onTap: removeProduct,
                    child: Container(
                      padding: const EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.grey),
                      ),
                      child: const Icon(Icons.remove,
                          size: 20, color: CommonStyles.primaryTextColor),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    '$productQuantity',
                    style: CommonStyles.txStyF14CbFF6
                        .copyWith(color: CommonStyles.blackColorShade),
                  ),
                  const SizedBox(width: 10),
                  GestureDetector(
                    onTap: addProduct,
                    child: Container(
                      padding: const EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.grey),
                      ),
                      child: const Icon(Icons.add,
                          size: 20, color: CommonStyles.statusGreenText),
                    ),
                  )

                  /*  IconButton(
                    iconSize: 16,
                    style: iconBtnStyle(
                      foregroundColor: CommonStyles.primaryTextColor,
                    ),
                    icon: const Icon(Icons.remove, color: CommonStyles.primaryTextColor),
                    onPressed: removeProduct,
                  ), */
                  // const SizedBox(width: 12),
                  ,

                  // const SizedBox(width: 12),
                  /*  IconButton(
                    iconSize: 16,
                    style: iconBtnStyle(
                      foregroundColor: CommonStyles.statusGreenText,
                    ),
                    icon: const Icon(Icons.add),
                    onPressed: addProduct,
                  ), */
                ],
              ),
              // const SizedBox(),
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
        padding: const EdgeInsets.all(1.0),
        side: const BorderSide(color: Colors.grey));
  }

  void removeProduct() {
    if (productQuantity > 0) {
      setState(() {
        productQuantity--;
        widget.onQuantityChanged(productQuantity);
      });
    }
  }

  void addProduct() {
    setState(() {
      productQuantity++;
      widget.onQuantityChanged(productQuantity);
    });
  }

  void openProductInfoDialog() {
    CommonStyles.customDialog(context, infoDialogContent(widget.product));
  }

  Widget infoDialogContent(ProductItem product) {
    final size = MediaQuery.of(context).size;
    return Container(
      width: size.width * 0.8,
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: CommonStyles.primaryTextColor, width: 2),
      ),
      child: Stack(children: [
        Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    tr(LocaleKeys.name),
                    style: CommonStyles.txStyF14CbFF6,
                  ),
                  const Text(
                    '     : ',
                    style: CommonStyles.txStyF14CbFF6,
                  ),
                  Expanded(
                    child: Text(
                      '${product.name}',
                      style: CommonStyles.txStyF14CpFF6,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Center(
                child: GestureDetector(
                  onTap: () => showZoomedAttachment('${product.imageUrl}'),
                  child: CachedNetworkImage(
                    imageUrl: '${product.imageUrl}',
                    placeholder: (context, url) =>
                        const CircularProgressIndicator(),
                    errorWidget: (context, url, error) => Image.asset(
                      Assets.images.icLogo.path,
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              if (product.description != null &&
                  product.description!.isNotEmpty)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      tr(LocaleKeys.description),
                      style: CommonStyles.txStyF14CbFF6,
                    ),
                    Text(
                      '${product.description}',
                      style: CommonStyles.txStyF14CbFF6,
                    ),
                  ],
                ),
              CommonStyles.horizontalGradientDivider(),
              infoRow(
                label1: tr(LocaleKeys.price),
                data1: '${product.priceInclGst}',
                discountPrice: product.actualPriceInclGst,
                label2: tr(LocaleKeys.gst),
                data2: '${product.gstPercentage}',
                isSingle: product.gstPercentage != null ? false : true,
              ),
              CommonStyles.horizontalGradientDivider(),
              if (product.size != null && widget.product.uomType != null)
                infoRow2(
                    label1: tr(LocaleKeys.product_size),
                    data1: '${product.size} ${product.uomType}',
                    label2: 'label2',
                    data2: '${product.description}',
                    isSingle: true),
            ],
          ),
        ),
        Positioned(
          top: 5,
          right: 5,
          child: GestureDetector(
            onTap: () {
              Navigator.of(context).pop();
            },
            child: Container(
              margin: const EdgeInsets.only(
                top: 5,
                right: 5,
              ),
              decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: CommonStyles.primaryTextColor,
                  )),
              child: const Icon(
                Icons.close,
                color: CommonStyles.primaryTextColor,
                size: 24,
              ),
            ),
          ),
        ),
      ]),
    );
  }
/* 
  Widget infoRow({
    required String label1,
    required String? data1,
    String? discountPrice,
    required String label2,
    required String? data2,
    bool isSingle = false,
  }) {
    return Column(
      children: [
        const SizedBox(height: 10),
        if (data1 != null)
          Row(
            children: [
              Expanded(
                  child: Row(
                children: [
                  Expanded(
                    flex: 5,
                    child: discountPrice == null
                        ? Text(
                            label1,
                            style: CommonStyles.txStyF14CbFF6,
                          )
                        : Column(
                            children: [
                              Text(
                                label1,
                                style: CommonStyles.txStyF14CbFF6,
                              ),
                              Text(
                                discountPrice,
                                style: CommonStyles.txStyF14CbFF6.copyWith(
                                  decoration: TextDecoration.lineThrough,
                                  decorationColor: CommonStyles.RedColor,
                                  color: CommonStyles.formFieldErrorBorderColor,
                                ),
                              ),
                            ],
                          ),
                  ),
                  const Expanded(
                    flex: 1,
                    child: Text(
                      ':',
                      style: CommonStyles.txStyF14CbFF6,
                    ),
                  ),
                  Expanded(
                    flex: 5,
                    child: Text(
                      data1,
                      style: CommonStyles.txStyF14CbFF6,
                    ),
                  ),
                ],
              )),
              const SizedBox(width: 10),
              isSingle
                  ? const Expanded(
                      child: SizedBox(),
                    )
                  : Expanded(
                      child: Row(
                        children: [
                          Expanded(
                            flex: 5,
                            child: Text(
                              label2,
                              style: CommonStyles.txStyF14CbFF6,
                            ),
                          ),
                          const Expanded(
                            flex: 1,
                            child: Text(
                              ':',
                              style: CommonStyles.txStyF14CbFF6,
                            ),
                          ),
                          Expanded(
                            flex: 5,
                            child: Text(
                              '$data2',
                              style: CommonStyles.txStyF14CbFF6,
                            ),
                          ),
                        ],
                      ),
                    ),
            ],
          ),
      ],
    );
  }
 */

  Widget infoRow({
    required String label1,
    required String? data1,
    double? discountPrice,
    required String label2,
    required String? data2,
    bool isSingle = false,
  }) {
    return Column(
      children: [
        const SizedBox(height: 10),
        if (data1 != null)
          Row(
            children: [
              Expanded(
                  child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 5,
                    child: Text(
                      label1,
                      style: CommonStyles.txStyF14CbFF6,
                    ),
                  ),
                  const Expanded(
                    flex: 1,
                    child: Text(
                      ':',
                      style: CommonStyles.txStyF14CbFF6,
                    ),
                  ),
                  Expanded(
                      flex: 5,
                      child: (discountPrice == null ||
                              data1 == discountPrice.toString())
                          ? Text(
                              data1,
                              style: CommonStyles.txStyF14CbFF6,
                            )
                          : Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  data1,
                                  style: CommonStyles.txStyF14CbFF6,
                                ),
                                Text(
                                  '$discountPrice',
                                  style: CommonStyles.txStyF14CbFF6.copyWith(
                                    decoration: TextDecoration.lineThrough,
                                    decorationColor: CommonStyles.RedColor,
                                    color:
                                        CommonStyles.formFieldErrorBorderColor,
                                  ),
                                ),
                              ],
                            )),
                ],
              )),
              const SizedBox(width: 10),
              isSingle
                  ? const Expanded(
                      child: SizedBox(),
                    )
                  : Expanded(
                      child: Row(
                        children: [
                          Expanded(
                            flex: 5,
                            child: Text(
                              label2,
                              style: CommonStyles.txStyF14CbFF6,
                            ),
                          ),
                          const Expanded(
                            flex: 1,
                            child: Text(
                              ':',
                              style: CommonStyles.txStyF14CbFF6,
                            ),
                          ),
                          Expanded(
                            flex: 5,
                            child: Text(
                              '$data2',
                              style: CommonStyles.txStyF14CbFF6,
                            ),
                          ),
                        ],
                      ),
                    ),
            ],
          ),
      ],
    );
  }

  Widget infoRow2({
    required String label1,
    required String? data1,
    String? discountPrice,
    required String label2,
    required String? data2,
    bool isSingle = false,
  }) {
    return Column(
      children: [
        const SizedBox(height: 10),
        if (data1 != null)
          Row(
            children: [
              Expanded(
                  child: Row(
                children: [
                  Expanded(
                    flex: 5,
                    child: discountPrice == null
                        ? Text(
                            label1,
                            style: CommonStyles.txStyF14CbFF6,
                          )
                        : Column(
                            children: [
                              Text(
                                label1,
                                style: CommonStyles.txStyF14CbFF6,
                              ),
                              Text(
                                discountPrice,
                                style: CommonStyles.txStyF14CbFF6.copyWith(
                                  decoration: TextDecoration.lineThrough,
                                  decorationColor: CommonStyles.RedColor,
                                  color: CommonStyles.formFieldErrorBorderColor,
                                ),
                              ),
                            ],
                          ),
                  ),
                  const Expanded(
                    flex: 1,
                    child: Text(
                      ':',
                      style: CommonStyles.txStyF14CbFF6,
                    ),
                  ),
                  Expanded(
                    flex: 5,
                    child: Text(
                      data1,
                      style: CommonStyles.txStyF14CbFF6,
                    ),
                  ),
                ],
              )),
              const SizedBox(width: 10),
              isSingle
                  ? const Expanded(
                      child: SizedBox(),
                    )
                  : Expanded(
                      child: Row(
                        children: [
                          Expanded(
                            flex: 5,
                            child: Text(
                              label2,
                              style: CommonStyles.txStyF14CbFF6,
                            ),
                          ),
                          const Expanded(
                            flex: 1,
                            child: Text(
                              ':',
                              style: CommonStyles.txStyF14CbFF6,
                            ),
                          ),
                          Expanded(
                            flex: 5,
                            child: Text(
                              '$data2',
                              style: CommonStyles.txStyF14CbFF6,
                            ),
                          ),
                        ],
                      ),
                    ),
            ],
          ),
      ],
    );
  }

  void showZoomedAttachment(String imageString) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          child: Container(
            padding: const EdgeInsets.all(5),
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10), color: Colors.white),
            width: double.infinity,
            height: 500,
            child: Stack(
              children: [
                Center(
                  child: PhotoViewGallery.builder(
                    itemCount: 1,
                    builder: (context, index) {
                      return PhotoViewGalleryPageOptions(
                        imageProvider: NetworkImage(imageString),
                        minScale: PhotoViewComputedScale.covered,
                        maxScale: PhotoViewComputedScale.covered,
                      );
                    },
                    scrollDirection: Axis.vertical,
                    scrollPhysics: const PageScrollPhysics(),
                    allowImplicitScrolling: true,
                    backgroundDecoration: const BoxDecoration(
                      color: Colors.white,
                    ),
                  ),
                ),
                Positioned(
                  top: 0,
                  right: 0,
                  child: GestureDetector(
                    onTap: () => Navigator.of(context).pop(),
                    child: Container(
                      padding: const EdgeInsets.all(5),
                      decoration: BoxDecoration(
                          color: Colors.red.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(20)),
                      child: const Icon(
                        Icons.close,
                        color: Colors.red,
                        size: 16,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class ProductWithQuantity {
  final ProductItem product;
  final int quantity;

  ProductWithQuantity({
    required this.product,
    required this.quantity,
  });

  double get totalPrice => product.priceInclGst! * quantity;

  // Convert Product to JSON
  Map<String, dynamic> toJson() {
    return {
      'product': product,
      'quantity': quantity,
    };
  }
}
