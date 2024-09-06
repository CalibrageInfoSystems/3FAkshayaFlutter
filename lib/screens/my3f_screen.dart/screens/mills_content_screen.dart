import 'package:akshaya_flutter/gen/assets.gen.dart';
import 'package:akshaya_flutter/models/important_places_model.dart';
import 'package:akshaya_flutter/screens/my3f_screen.dart/screens/collectioncenter_card.dart';
import 'package:flutter/material.dart';

class MillsContentScreen extends StatelessWidget {
  final List<CollectionCenter> mills;
  const MillsContentScreen({super.key, required this.mills});

  @override
  Widget build(BuildContext context) {
    return Container(
      child: ListView.builder(
        itemCount: mills.length,
        itemBuilder: (context, index) {
          return CollectionCenterCard(
            data: mills[index],
            imagePath: Assets.images.icMillList.path,
          );
        },
      ),
    );
  }
}
