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
          color: CommonStyles.whiteColor,
          borderRadius: BorderRadius.circular(5.0),
        ),
        margin: const EdgeInsets.only(bottom: 5),
        child: Row(
          children: [
            Expanded(
              flex: 3,
              child: Image.asset(
                imagePath,
                fit: BoxFit.contain,
                width: 50,
                height: 70,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              flex: 8,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('${data.collectionCenter}',
                      style: CommonStyles.txStyF16CbFF6
                          .copyWith(color: CommonStyles.impPlacesDataColor)),
                  const Divider(
                    color: CommonStyles.primaryTextColor,
                    thickness: 0.3,
                  ),
                  contentBox(
                    label: tr(LocaleKeys.village),
                    data: '${data.villageName}',
                  ),
                  contentBox(
                    label: tr(LocaleKeys.mandal),
                    data: '${data.mandalName}',
                  ),
                  contentBox(
                    label: tr(LocaleKeys.dist),
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
                        Text(tr(LocaleKeys.view_in_map),
                            style: CommonStyles.txStyF14CbFF6.copyWith(
                                color: CommonStyles.impPlacesDataColor)),
                        const SizedBox(width: 5),
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
                flex: 3,
                child: Text(label,
                    style: CommonStyles.txStyF14CbFF6
                        .copyWith(color: CommonStyles.impPlacesDataColor))),
            Text(':  ',
                style: CommonStyles.txStyF14CbFF6
                    .copyWith(color: CommonStyles.impPlacesDataColor)),
            Expanded(
              flex: 7,
              child: Text('$data',
                  style: CommonStyles.txStyF14CbFF6
                      .copyWith(color: CommonStyles.impPlacesDataColor),
                  maxLines: 4,
                  overflow: TextOverflow.ellipsis),
            ),
          ],
        ),
        const Divider(
          color: CommonStyles.primaryTextColor,
          thickness: 0.3,
        ),
      ],
    );
  }
}
