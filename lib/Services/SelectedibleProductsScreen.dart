import 'dart:convert';

import 'package:akshaya_flutter/Services/models/product_item_model.dart';
import 'package:akshaya_flutter/common_utils/common_styles.dart';
import 'package:akshaya_flutter/common_utils/custom_appbar.dart';
import 'package:akshaya_flutter/common_utils/custom_btn.dart';
import 'package:akshaya_flutter/gen/assets.gen.dart';
import 'package:akshaya_flutter/localization/locale_keys.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shimmer/shimmer.dart';
import 'package:badges/badges.dart' as badges;
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';

import '../common_utils/api_config.dart';
import 'package:akshaya_flutter/Services/EdibleProductCardScreen.dart';
import 'package:akshaya_flutter/services/models/Godowndata.dart';

class SelectedibleProductsScreen extends StatefulWidget {
  final Godowndata godown;

  const SelectedibleProductsScreen({super.key, required this.godown});

  @override
  State<SelectedibleProductsScreen> createState() =>
      _SelectEdibleProductsScreenState();
}

class _SelectEdibleProductsScreenState
    extends State<SelectedibleProductsScreen> {
  // tr(LocaleKeys.crop),

  Map<int, int> productQuantities = {};
  int badgeCount = 0;

  String? selectedDropDownValue;
  late Future<List<ProductItem>> productsData;
  late List<ProductItem> copyProductsData = [];
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
    return copyProductsData
        .where((product) => productQuantities.containsKey(product.id))
        .map((product) => ProductWithQuantity(
              product: product,
              quantity: productQuantities[product.id] ?? 0,
            ))
        .toList();
  }

  Future<List<ProductItem>> getProducts() async {
    try {
      final apiUrl = '$baseUrl$Getproductdata/12/${widget.godown.code}';

      final jsonResponse = await http.get(Uri.parse(apiUrl));
      if (jsonResponse.statusCode == 200) {
        final response = jsonDecode(jsonResponse.body);
        if (response['listResult'] != null) {
          List<dynamic> listResult = response['listResult'];
          return listResult.map((item) => ProductItem.fromJson(item)).toList();
        } else {
          return []; // Return an empty list if listResult is null
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
        body: filterAndProductSection());
  }

  Widget filterAndProductSection() {
    return FutureBuilder(
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
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(12, 12, 12, 0),
                    child: GridView.builder(
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              crossAxisSpacing: 10.0,
                              mainAxisSpacing: 10.0,
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
                  ),
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
                  style: CommonStyles.txSty_12W_fb,
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
              const SizedBox(width: 10), // Spacing between cart icon and text
              Text(
                ' ₹${calculateTotalAmount().toStringAsFixed(2)}',
                style: CommonStyles.text16white,
              ),
            ],
          ),
          CustomBtn(
            label: tr(LocaleKeys.next),
            borderColor: CommonStyles.primaryTextColor,
            borderRadius: 16,
            onPressed: () {
              if (fetchCardProducts().isNotEmpty) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => EdibleProductCardScreen(
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
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const SizedBox(),
              Text(
                '${widget.product.name}',
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: CommonStyles.txStyF14CpFF6,
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
              Text(
                '₹${widget.product.discountedPriceInclGst != 0 ? widget.product.discountedPriceInclGst!.toStringAsFixed(2) : '0.0'}',
                style: CommonStyles.txStyF14CbFF6,
              ),
              Text(
                '₹${widget.product.actualPriceInclGst != 0 ? widget.product.actualPriceInclGst!.toStringAsFixed(2) : '0.0'}',
                style: CommonStyles.txStyF14CbFF6.copyWith(
                    decoration: TextDecoration.lineThrough,
                    decorationColor: Colors.redAccent,
                    color: Colors.redAccent),
              ),
              Text(
                '${widget.product.size} ${widget.product.uomType}',
                style: CommonStyles.txStyF14CpFF6,
              ),
            ],
          ),
          /*  Row(
          Should I need to include original estination and completed hours?
          
          I asked vamsi he said No of Hrs Spent Per Day is enough.
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '₹${widget.product.priceInclGst}',
                style: CommonStyles.txStyF14CbFF6,
              ),
              Text(
                '${widget.product.size} ${widget.product.uomType}',
                style: CommonStyles.txStyF14CpFF6,
              ),
            ],
          ), */
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
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.grey),
                      ),
                      child: const Icon(Icons.remove,
                          color: CommonStyles.primaryTextColor),
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
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.grey),
                      ),
                      child: const Icon(Icons.add,
                          color: CommonStyles.statusGreenText),
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
      width: size.width * 0.75,
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
                      fit: BoxFit.cover,
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
              infoRow(
                label1: tr(LocaleKeys.price),
                data1: '${product.actualPriceInclGst}',
                label2: tr(LocaleKeys.gst),
                data2: '${product.gstPercentage}',
              ),
              CommonStyles.horizontalGradientDivider(),
              infoRow(
                  label1: tr(LocaleKeys.product_size),
                  data1: product.size?.toString(),
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

  Widget infoRow({
    required String label1,
    required String? data1,
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
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const SizedBox(),
              Text(
                '${widget.product.name}',
                style: CommonStyles.txStyF14CpFF6,
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
              Text(
                '₹${widget.product.discountedPriceInclGst != 0 ? widget.product.discountedPriceInclGst!.toStringAsFixed(2) : '0.0'}',
                style: CommonStyles.txStyF14CbFF6,
              ),
              Text(
                '₹${widget.product.actualPriceInclGst != 0 ? widget.product.actualPriceInclGst!.toStringAsFixed(2) : '0.0'}',
                style: CommonStyles.txStyF14CbFF6.copyWith(
                    decoration: TextDecoration.lineThrough,
                    decorationColor: Colors.redAccent,
                    color: Colors.redAccent),
              ),
              Text(
                '${widget.product.size} ${widget.product.uomType}',
                style: CommonStyles.txStyF14CpFF6,
              ),
            ],
          ),
          const SizedBox(height: 5),
          Expanded(
            child: Center(
              child: CachedNetworkImage(
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
                children: [
                  IconButton(
                    iconSize: 16,
                    style: iconBtnStyle(
                      foregroundColor: CommonStyles.primaryTextColor,
                    ),
                    icon: const Icon(Icons.remove),
                    onPressed: removeProduct,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    '$productQuantity',
                    style: CommonStyles.txStyF14CbFF6
                        .copyWith(color: CommonStyles.blackColorShade),
                  ),
                  const SizedBox(width: 12),
                  IconButton(
                    iconSize: 16,
                    style: iconBtnStyle(
                      foregroundColor: CommonStyles.statusGreenText,
                    ),
                    icon: const Icon(Icons.add),
                    onPressed: addProduct,
                  ),
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
      width: size.width * 0.75,
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
                      fit: BoxFit.cover,
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
              infoRow(
                label1: tr(LocaleKeys.price),
                data1: '${product.discountedPriceInclGst}',
                label2: tr(LocaleKeys.gst),
                data2: '${product.gstPercentage}',
              ),
              CommonStyles.horizontalGradientDivider(),
              infoRow(
                  label1: tr(LocaleKeys.product_size),
                  data1: product.size?.toString(),
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

  Widget infoRow({
    required String label1,
    required String? data1,
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
}
 */