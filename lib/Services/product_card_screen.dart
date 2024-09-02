import 'package:akshaya_flutter/Services/models/product_item_model.dart';
import 'package:flutter/material.dart';

class ProductCardScreen extends StatelessWidget {
  final List<ProductItem> products;
  const ProductCardScreen({super.key, required this.products});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text(products.length.toString()),
      ),
    );
  }
}
