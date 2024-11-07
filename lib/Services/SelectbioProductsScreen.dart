import 'dart:convert';

import 'package:akshaya_flutter/Services/bioProductCardScreen.dart';
import 'package:akshaya_flutter/Services/models/product_item_model.dart';
// import 'package:akshaya_flutter/Services/models/Godowndata.dart';
import 'package:akshaya_flutter/services/models/Godowndata.dart';

import 'package:akshaya_flutter/common_utils/common_styles.dart';
import 'package:akshaya_flutter/common_utils/custom_appbar.dart';
import 'package:akshaya_flutter/common_utils/custom_btn.dart';
import 'package:akshaya_flutter/gen/assets.gen.dart';
import 'package:akshaya_flutter/localization/locale_keys.dart';
import 'package:akshaya_flutter/Services/custom_product_card.dart';
import 'package:animated_read_more_text/animated_read_more_text.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shimmer/shimmer.dart';
import 'package:badges/badges.dart' as badges;
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';

import '../common_utils/api_config.dart';

class SelectbioProductsScreen extends StatefulWidget {
  final Godowndata godown;

  const SelectbioProductsScreen({super.key, required this.godown});

  @override
  State<SelectbioProductsScreen> createState() =>
      _SelectbioProductsScreenState();
}

class _SelectbioProductsScreenState extends State<SelectbioProductsScreen> {
  // tr(LocaleKeys.crop),

  Map<int, int> productQuantities = {};
  int badgeCount = 0;

  String? selectedDropDownValue;
  late Future<List<ProductItem>> productsData;
  late List<ProductItem> copyProductsData = [];
  List<int> orderedProductIds = [];
  // List<ProductWithQuantity>? copyProductsData;
  @override
  void initState() {
    super.initState();
    productsData = getProducts();

    copyProducts();
  }

  Future<void> filterProductsByCatogary(int catogaryId) async {
    // print('filterProductsByCatogary: $catogaryId');

    /*   productsData = Future.value(
      copyProductsData.where((item) => if (catogaryId != -1) {
          return item.categoryId == catogaryId;
        }).toList(),
    ); */

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
    final result = orderedProductIds
        .where((id) => productQuantities.containsKey(id))
        .map((id) {
      final product = copyProductsData.firstWhere((p) => p.id == id);
      return ProductWithQuantity(
        product: product,
        quantity: productQuantities[id] ?? 0,
      );
    }).toList();
    print(
        'fetchCardProducts: ${jsonEncode(result.map((p) => p.toJson()).toList())}');
    return result;
  }

  Future<List<ProductItem>> getProducts() async {
    try {
      final apiUrl = '$baseUrl$Getproductdata/11/${widget.godown.code}';
      print('getProducts: $apiUrl');

      final jsonResponse = await http.get(Uri.parse(apiUrl));
      print('getProducts: ${jsonResponse.body}');

      if (jsonResponse.statusCode == 200) {
        final response = jsonDecode(jsonResponse.body);
        if (response['listResult'] != null) {
          List<dynamic> listResult = response['listResult'];
          return listResult.map((item) => ProductItem.fromJson(item)).toList();
        } else {
          return [];
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
      appBar: CustomAppBar(
        title: tr(LocaleKeys.select_product),
      ),
      body: FutureBuilder(
        future: productsData,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return shimmerLoading();
          }
          if (snapshot.hasError) {
            return Center(
              child: Text(
                  textAlign: TextAlign.center,
                  snapshot.error.toString().replaceFirst('Exception: ', ''),
                  style: CommonStyles.txStyF16CpFF6),
            );
          } else {
            final products = snapshot.data as List<ProductItem>;
            if (products.isNotEmpty) {
              return Column(
                children: [
                  headerSection(),
                  const SizedBox(height: 10),
                  Expanded(
                    child: productsGridView(products),
                  ),
                ],
              );
            } else {
              return Center(
                child: Text(
                  tr(LocaleKeys.no_products),
                  // style: CommonStyles.txStyF16CpFF6,
                  style: CommonStyles.txStyF16CpFF6.copyWith(
                    fontSize: 20,
                  ),
                ),
              );
            }
          }
        },
      ),

/*       Padding(
        padding: const EdgeInsets.fromLTRB(12, 12, 12, 0),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.fromLTRB(12, 12, 12, 0),
              child: FutureBuilder(
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
                      return Column(
                        children: [
                          headerSection(),
                          const SizedBox(height: 10),
                          Expanded(
                            child: productsGridView(products),
                          ),
                        ],
                      );
                    } else {
                      return const Center(
                        child: Text(
                          'No products found',
                          style: CommonStyles.txStyF16CpFF6,
                        ),
                      );
                    }
                  }
                },
              ),
            ),
          ],
        ),
      ), */
    );
  }

  Widget productsGridView(List<ProductItem> products) {
    return Padding(
      padding: const EdgeInsets.all(10),
      // padding: const EdgeInsets.symmetric(horizontal: 12),
      child: GridView.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 10.0,
            mainAxisSpacing: 10.0,
            mainAxisExtent: 250,
            childAspectRatio: 8 / 2),
        itemCount: products.length,
        itemBuilder: (context, index) {
          final product = products[index];
          final quantity = productQuantities[product.id] ?? 0;
          return CustomProductCard(
            product: product,
            quantity: quantity,
            onQuantityChanged: (newQuantity) {
              setState(() {
                if (newQuantity > 0) {
                  productQuantities[product.id!] = newQuantity;
                  // Add to ordered list if not already present
                  if (!orderedProductIds.contains(product.id)) {
                    orderedProductIds.add(product.id!);
                  }
                } else {
                  // Remove from both lists if quantity is zero
                  productQuantities.remove(product.id);
                  orderedProductIds.remove(product.id);
                }
                updateBadgeCount();
              });
            },
          );
        },
      ),
    );
  }

  Padding shimmerLoading() {
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: GridView.builder(
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
              GestureDetector(
                onTap: checkingCartProducts,
                child: badges.Badge(
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
              ),
              const SizedBox(width: 10), // Spacing between cart icon and text

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
            btnTextColor: CommonStyles.primaryTextColor,
            borderColor: CommonStyles.primaryTextColor,
            borderRadius: 16,
            onPressed: checkingCartProducts,
          ),
        ],
      ),
    );
  }

  void checkingCartProducts() {
    if (calculateTotalAmount() != 0) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => BioProductCardScreen(
            products: fetchCardProducts(),
            godown: widget.godown,
          ),
        ),
      );
    } else {
      /*  ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Please add at least one product.'),
                  ),
                ); */
      CommonStyles.showCustomDialog(
          context, tr(LocaleKeys.select_product_toast));
    }
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
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    /*  AnimatedReadMoreText(
                      '${widget.product.name}',
                      textStyle: CommonStyles.txStyF14CpFF6,
                      maxLines: 2,
                      readMoreText: '..',
                      readLessText: '.',
                      buttonTextStyle: CommonStyles.txSty_14p_f5,
                    ), */
                    Expanded(
                      child: Text(
                        '${widget.product.name}',
                        textAlign: TextAlign.center,
                        overflow: TextOverflow.ellipsis,
                        style: CommonStyles.txStyF14CpFF6,
                      ),
                    )
                  ],
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
                    '₹${widget.product.priceInclGst!.toStringAsFixed(2)}',
                    style: CommonStyles.txStyF14CbFF6.copyWith(
                      fontSize: 13,
                    ),
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
                      style: CommonStyles.txStyF14CpFF6.copyWith(
                        fontSize: 13,
                      ),
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
                style: CommonStyles.txStyF14CbFF6,
              ),
              const SizedBox(width: 5),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GestureDetector(
                    onTap: removeProduct,
                    child: Container(
                      padding: const EdgeInsets.all(3),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.grey),
                      ),
                      child: const Icon(Icons.remove,
                          size: 20, color: CommonStyles.primaryTextColor),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    '$productQuantity',
                    style: CommonStyles.txStyF14CbFF6
                        .copyWith(color: CommonStyles.blackColorShade),
                  ),
                  const SizedBox(width: 12),
                  GestureDetector(
                    onTap: addProduct,
                    child: Container(
                      padding: const EdgeInsets.all(3),
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
              CommonStyles.horizontalDivider(),
              infoRow(
                label1: tr(LocaleKeys.price),
                data1: '${product.priceInclGst}',
                discountPrice: product.actualPriceInclGst,
                label2: tr(LocaleKeys.gst),
                data2: '${product.gstPercentage}',
                isSingle: product.gstPercentage != null ? false : true,
              ),
              CommonStyles.horizontalDivider(),
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

/* 
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
                  const SizedBox(width: 10),
                  if (widget.product.actualPriceInclGst !=
                      widget.product.priceInclGst)
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
                    const CircularProgressIndicator(),
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
/*               infoRow(
                label1: tr(LocaleKeys.price),
                data1: '${product.priceInclGst}',
                label2: tr(LocaleKeys.gst),
                data2: '${product.gstPercentage}',
                isSingle: product.gstPercentage != null ? false : true,
              ),
              CommonStyles.horizontalGradientDivider(),
              if (product.size != null)
                infoRow(
                    label1: tr(LocaleKeys.product_size),
                    // data1: product.size?.toString(),
                    data1: '${product.size} ${product.uomType}',
                    label2: 'label2',
                    data2: '${product.description}',
                    isSingle: true), */
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
                      child: discountPrice == null
                          ? Text(
                              data1,
                              style: CommonStyles.txStyF14CbFF6,
                            )
                          : Column(
                              children: [
                                Text(
                                  data1,
                                  style: CommonStyles.txStyF14CbFF6,
                                ),
                                Text(
                                  discountPrice,
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
 */
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
