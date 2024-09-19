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
import 'EquipProductCardScreen.dart';
import 'models/Godowndata.dart';

class SelectEquipProductsScreen extends StatefulWidget {
  final Godowndata godown;

  const SelectEquipProductsScreen({super.key, required this.godown});

  @override
  State<SelectEquipProductsScreen> createState() =>
      _SelectEquipProductsScreenState();
}

class _SelectEquipProductsScreenState extends State<SelectEquipProductsScreen> {
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
      final apiUrl = '$baseUrl$Getproductdata/2/${widget.godown.code}';
      print('products url $apiUrl');

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
        body: Column(
          children: [
            headerSection(),
            Expanded(child: filterAndProductSection()),
          ],
        ));
  }

  Widget filterAndProductSection() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10).copyWith(top: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // const SizedBox(height: 10),
          Expanded(
            child: FutureBuilder(
              future: productsData,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return shimmerLoading();
                }
                if (snapshot.hasError) {
                  return Text('${tr(LocaleKeys.error)}: ${snapshot.error}');
                } else {
                  final products = snapshot.data as List<ProductItem>;
                  if (products.isNotEmpty) {
                    return GridView.builder(
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
                    );
                  } else {
                    return const Center(
                      child: Text(
                        'No products found',
                        style: CommonStyles.txSty_14b_f6,
                      ),
                    );
                  }
                }
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
            btnTextStyle: CommonStyles.txStyF12CpFF6.copyWith(fontSize: 14),
            padding: const EdgeInsets.symmetric(
              horizontal: 25,
            ),
            onPressed: () {
              if (fetchCardProducts().isNotEmpty) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => EquipProductCardScreen(
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
      child: Column(children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const SizedBox(),
            Expanded(
              child: Text(
                widget.product.name!,
                style: CommonStyles.txStyF14CpFF6,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
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
            Text(
              '₹${widget.product.priceInclGst}',
              style: CommonStyles.txStyF14CbFF6,
            ),
            // Conditionally show product size and uomType if product.size is not null
            if (widget.product.size != null)
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
              imageUrl: widget.product.imageUrl!,
              placeholder: (context, url) => const CircularProgressIndicator(),
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
            const SizedBox(),
          ],
        ),
      ]),
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
      padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: CommonStyles.primaryTextColor, width: 2),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  // Wraps the Row to handle the text overflow
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Name',
                        style: CommonStyles.txStyF14CbFF6,
                      ),
                      const Text(
                        '     : ',
                        style: CommonStyles.txStyF14CbFF6,
                      ),
                      Expanded(
                        // Wraps the Text widget to handle long product names
                        child: Text(
                          '${product.name}',
                          textAlign: TextAlign.start,
                          overflow: TextOverflow.visible,
                          maxLines: 2,
                          style: CommonStyles.txStyF14CpFF6,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(
                    Icons.close,
                    color: CommonStyles.primaryTextColor,
                  ),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
                /*  Align(
                  alignment: Alignment.topRight,
                  child: IconButton(
                    padding: const EdgeInsets.all(0),
                    icon: const Icon(
            Icons.close,
            color: CommonStyles.primaryTextColor,
            size: 24,
                    ),
                    onPressed: () {
            Navigator.of(context).pop();
                    },
                  ),
                ), */
              ],
            ),
          ),

/* 
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Text(
                    'Name',
                    style: CommonStyles.txStyF14CbFF6,
                  ),
                  const Text(
                    '     : ',
                    style: CommonStyles.txStyF14CbFF6,
                  ),
                  Text(
                    '${product.name}',
                    textAlign: TextAlign.center,
                    overflow: TextOverflow.visible,
                    maxLines: 2,
                    style: CommonStyles.txStyF14CpFF6,
                  ),
                ],
              ),
              Align(
                alignment: Alignment.topRight,
                child: IconButton(
                  padding: const EdgeInsets.all(0),
                  icon: const Icon(
                    Icons.close,
                    color: CommonStyles.primaryTextColor,
                    size: 24,
                  ),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ),
            ],
          ),
     */
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
          const Text(
            'Description:',
            style: CommonStyles.txStyF14CbFF6,
          ),
          Text(
            '${product.description}',
            style: CommonStyles.txStyF14CbFF6,
          ),
          CommonStyles.horizontalGradientDivider(),
          infoRow(
            label1: 'Price (Rs)',
            data1: '${product.actualPriceInclGst}',
            label2: 'GST (%)',
            data2: '${product.gstPercentage}',
          ),
          const SizedBox(height: 10),
          CommonStyles.horizontalGradientDivider(),
          infoRow(
              label1: 'Size',
              data1: product.size?.toString(),
              label2: 'label2',
              data2: '${product.description}',
              isSingle: true),
        ],
      ),
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
        Row(
          children: [
            data1 != null
                ? Expanded(
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
                    ),
                  )
                : const SizedBox(),
            const SizedBox(width: 10),
            isSingle
                ? const Expanded(
                    child: SizedBox(),
                  )
                : Expanded(
                    child: data2 != null
                        ? Row(
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
                                  data2,
                                  style: CommonStyles.txStyF14CbFF6,
                                ),
                              ),
                            ],
                          )
                        : const SizedBox(),
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

// class ProductWithQuantity {
//   final ProductItem product;
//   final int quantity;
//
//   ProductWithQuantity({required this.product, required this.quantity});
// }
