import 'package:akshaya_flutter/common_utils/common_styles.dart';
import 'package:akshaya_flutter/gen/assets.gen.dart';
import 'package:akshaya_flutter/models/important_places_model.dart';
import 'package:akshaya_flutter/screens/my3f_screen.dart/screens/collectioncenter_card.dart';
import 'package:flutter/material.dart';

class CollectionContentScreen extends StatelessWidget {
  final List<CollectionCenter> data;
  const CollectionContentScreen({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12).copyWith(top: 12),
      child: ListView.builder(
        itemCount: data.length,
        itemBuilder: (context, index) {
          return CollectionCenterCard(
            data: data[index],
            imagePath: Assets.images.icCollectionList.path,
          );
        },
      ),
    );
  }
}
