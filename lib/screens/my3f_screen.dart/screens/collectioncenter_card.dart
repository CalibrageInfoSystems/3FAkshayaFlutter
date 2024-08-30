import 'package:akshaya_flutter/common_utils/common_styles.dart';
import 'package:akshaya_flutter/common_utils/constants.dart';
import 'package:akshaya_flutter/gen/assets.gen.dart';
import 'package:akshaya_flutter/models/important_places_model.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../../localization/locale_keys.dart';

class CollectionCenterCard extends StatelessWidget {
  final CollectionCenter data;
  final String imagePath;
  const CollectionCenterCard(
      {super.key, required this.data, required this.imagePath});

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(5.0),
        ),
        margin: const EdgeInsets.only(bottom: 10),
        child: Row(
          children: [
            Expanded(
              flex: 3,
              child: Image.asset(
                imagePath,
                fit: BoxFit.contain,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              flex: 8,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('${data.collectionCenter}',
                      style: CommonStyles.txSty_14b_f5),
                  const Divider(),
                  contentBox(
                    label:  tr(LocaleKeys.village),
                    data: '${data.villageName}',
                  ),
                  contentBox(
                    label: tr(LocaleKeys.mandal),
                    data: '${data.mandalName}',
                  ),
                  contentBox(
                    label:  tr(LocaleKeys.dist),
                    data: '${data.districtName}',
                  ),
                  GestureDetector(
                    onTap: () {
                      Constants.launchMap(
                          latitude: data.latitude, longitude: data.longitude);
                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                         Text( tr(LocaleKeys.view_in_map),
                            style: CommonStyles.txSty_12b_f5),
                        Image.asset(
                          Assets.images.icMapList.path,
                          height: 30,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget contentBox({required String label, required String? data}) {
    return Column(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
                flex: 4, child: Text(label, style: CommonStyles.txSty_12b_f5)),
            const Text(':  '),
            Expanded(
                flex: 6,
                child: Text('$data', style: CommonStyles.txSty_12b_f5)),
          ],
        ),
        const Divider(),
      ],
    );
  }
}
