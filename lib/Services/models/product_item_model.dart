import 'dart:convert';

ProductItem productItemFromJson(String str) =>
    ProductItem.fromJson(json.decode(str));

String productItemToJson(ProductItem data) => json.encode(data.toJson());

class ProductItem {
  final int? id;
  final String? name;
  final String? description;
  final int? categoryId;
  final double? actualPrice;
  final double? actualPriceInclGst;
  final double? size;
  final int? uoMTypeId;
  final String? uomType;
  final double? discountedPrice;
  final double? discountedPriceInclGst;
  final String? imageUrl;
  final double? price;
  final double? priceInclGst;
  final double? transPortActualPriceInclGst;
  final double? gstPercentage;
  final double? cgst;
  final double? sgst;
  final double? transportGstPercentage;
  final double? transCgst;
  final double? transSgst;
  final String? code;
  final double? availableQuantity;

  ProductItem({
    this.id,
    this.name,
    this.description,
    this.categoryId,
    this.actualPrice,
    this.actualPriceInclGst,
    this.size,
    this.uoMTypeId,
    this.uomType,
    this.discountedPrice,
    this.discountedPriceInclGst,
    this.imageUrl,
    this.price,
    this.priceInclGst,
    this.transPortActualPriceInclGst,
    this.gstPercentage,
    this.cgst,
    this.sgst,
    this.transportGstPercentage,
    this.transCgst,
    this.transSgst,
    this.code,
    this.availableQuantity,
  });

  factory ProductItem.fromJson(Map<String, dynamic> json) => ProductItem(
        id: json["id"],
        name: json["name"],
        description: json["description"],
        categoryId: json["categoryId"],
        actualPrice: json["actualPrice"]?.toDouble(),
        actualPriceInclGst: json["actualPriceInclGST"]?.toDouble(),
        size: json["size"]?.toDouble(),
        uoMTypeId: json["uoMTypeId"],
        uomType: json["uomType"],
        discountedPrice: json["discountedPrice"]?.toDouble(),
        discountedPriceInclGst: json["discountedPriceInclGST"]?.toDouble(),
        imageUrl: json["imageUrl"],
        price: json["price"]?.toDouble(),
        priceInclGst: json["priceInclGST"]?.toDouble(),
        transPortActualPriceInclGst:
            json["transPortActualPriceInclGST"]?.toDouble(),
        gstPercentage: json["gstPercentage"]?.toDouble(),
        cgst: json["cgst"]?.toDouble(),
        sgst: json["sgst"]?.toDouble(),
        transportGstPercentage: json["transportGSTPercentage"]?.toDouble(),
        transCgst: json["transCGST"]?.toDouble(),
        transSgst: json["transSGST"]?.toDouble(),
        code: json["code"],
        availableQuantity: json["availableQuantity"]?.toDouble(),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "description": description,
        "categoryId": categoryId,
        "actualPrice": actualPrice,
        "actualPriceInclGST": actualPriceInclGst,
        "size": size,
        "uoMTypeId": uoMTypeId,
        "uomType": uomType,
        "discountedPrice": discountedPrice,
        "discountedPriceInclGST": discountedPriceInclGst,
        "imageUrl": imageUrl,
        "price": price,
        "priceInclGST": priceInclGst,
        "transPortActualPriceInclGST": transPortActualPriceInclGst,
        "gstPercentage": gstPercentage,
        "cgst": cgst,
        "sgst": sgst,
        "transportGSTPercentage": transportGstPercentage,
        "transCGST": transCgst,
        "transSGST": transSgst,
        "code": code,
        "availableQuantity": availableQuantity,
      };
}
