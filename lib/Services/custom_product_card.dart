import 'dart:async';

import 'package:akshaya_flutter/common_utils/common_styles.dart';
import 'package:shimmer/shimmer.dart';
import 'package:akshaya_flutter/gen/assets.gen.dart';
import 'package:akshaya_flutter/localization/locale_keys.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:akshaya_flutter/Services/models/product_item_model.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';

class CustomProductCard extends StatefulWidget {
  final ProductItem product;
  final int quantity;
  final Function(int) onQuantityChanged;

  const CustomProductCard({
    super.key,
    required this.product,
    required this.quantity,
    required this.onQuantityChanged,
  });

  @override
  State<CustomProductCard> createState() => _CustomProductCardState();
}

class _CustomProductCardState extends State<CustomProductCard> {
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
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
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
                  Assets.images.noproductImage.path,
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
                  ),
                ],
              ),
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
                crossAxisAlignment: CrossAxisAlignment.start,
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
                  const SizedBox(
                    width: 25,
                    height: 25,
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Center(
                child: GestureDetector(
                  onTap: () => showZoomedAttachment('${product.imageUrl}'),
                  child:
                      /* CachedNetworkImage(
                    imageUrl: '${product.imageUrl}',
                    placeholder: (context, url) =>
                        const CircularProgressIndicator(),
                    errorWidget: (context, url, error) => Image.asset(
                      Assets.images.icLogo.path,
                      fit: BoxFit.contain,
                    ),
                  ), */
                      CachedNetworkImage(
                    width: 150,
                    height: 150,
                    imageUrl: '${product.imageUrl}',
                    placeholder: (context, url) => Shimmer.fromColors(
                      baseColor: Colors.grey.shade300,
                      highlightColor: Colors.grey.shade100,
                      child: Container(
                        width: 150,
                        height: 150,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade300,
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                      ),
                    ),
                    errorWidget: (context, url, error) => Image.asset(
                      Assets.images.noproductImage.path,
                      fit: BoxFit.cover,
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
                      product.description!.trim(),
                      style: CommonStyles.txStyF14CbFF6,
                    ),
                  ],
                ),
              CommonStyles.horizontalGradientDivider(),
              infoRow(
                  label1: tr(LocaleKeys.price),
                  data1: product.priceInclGst,
                  discountPrice: product.actualPriceInclGst,
                  label2: tr(LocaleKeys.gst),
                  data2: product.gstPercentage,
                  isSingle: product.gstPercentage != null
                  /* isSingle: (product.gstPercentage != null ||
                        product.gstPercentage != 0)
                    ? false
                    : true, */
                  ),
              CommonStyles.horizontalGradientDivider(),
              if (product.size != null && widget.product.uomType != null)
                /*   infoRow2(
                    label1: tr(LocaleKeys.product_size),
                    data1: '${product.size} ${product.uomType}',
                    label2: 'label2',
                    data2: '${product.description}',
                    isSingle: true), */
                infoRow2(
                  label1: tr(LocaleKeys.product_size),
                  data1: '${product.size} ${product.uomType}',
                  isNull: (product.size != null || product.uomType != null),
                ),
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
    required double? data1,
    double? discountPrice,
    required String label2,
    required double? data2,
    bool isSingle = false,
  }) {
    print('Condition: ${data2 != null} && ${data2 != 0}');
    return Column(
      children: [
        const SizedBox(height: 10),
        Row(
          children: [
            if (data1 != null)
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
                      child: (discountPrice == null || data1 == discountPrice)
                          ? Text(
                              '₹${data1.toStringAsFixed(2)}',
                              style: CommonStyles.txStyF14CbFF6,
                            )
                          : Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '₹${data1.toStringAsFixed(2)}',
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
                            ),
                    ),
                  ],
                ),
              ),
            if (data1 != null) const SizedBox(width: 10),
            (data2 != null && data2 != 0)
                ? Expanded(
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
                  )
                : const Expanded(
                    child: SizedBox(),
                  )
          ],
        ),
      ],
    );
  }

  Widget infoRow2({
    required String label1,
    required String? data1,
    bool isNull = true,
  }) {
    return Column(
      children: [
        const SizedBox(height: 10),
        if (isNull)
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
                        '$data1',
                        style: CommonStyles.txStyF14CbFF6,
                      ),
                    ),
                  ],
                ),
              ),
              const Expanded(
                child: SizedBox(),
              )
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
                  child: FutureBuilder(
                    future: _loadImage(imageString),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.done) {
                        if (snapshot.hasError) {
                          return Center(
                            child: Image.asset(
                              Assets.images.noproductImage
                                  .path, // Path to your error image
                              fit: BoxFit.cover,
                            ),
                          );
                        }
                        return PhotoViewGallery.builder(
                          itemCount: 1,
                          builder: (context, index) {
                            return PhotoViewGalleryPageOptions(
                              imageProvider: NetworkImage(imageString),
                              minScale: PhotoViewComputedScale.covered,
                              maxScale: PhotoViewComputedScale.covered,
                            );
                          },
                          scrollDirection: Axis.vertical,
                          backgroundDecoration: const BoxDecoration(
                            color: Colors.white,
                          ),
                        );
                      } else {
                        return Center(
                          child: Image.asset(
                            Assets.images.noproductImage.path,
                            fit: BoxFit.cover,
                          ),
                        );
                      }
                    },
                  ),

/* 				  PhotoViewGallery.builder(
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
                  ), */
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

  Future<void> _loadImage(String url) async {
    final completer = Completer<void>();
    final img = Image.network(url);

    img.image.resolve(const ImageConfiguration()).addListener(
          ImageStreamListener(
            (info, _) => completer.complete(),
            onError: (error, stackTrace) => completer.completeError(error),
          ),
        );
    await completer.future;
  }
}
