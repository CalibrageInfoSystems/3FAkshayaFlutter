import 'package:akshaya_flutter/common_utils/common_styles.dart';
import 'package:akshaya_flutter/common_utils/constants.dart';
import 'package:akshaya_flutter/gen/assets.gen.dart';
import 'package:akshaya_flutter/models/important_places_model.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../../localization/locale_keys.dart';

class GoDownsScreen extends StatelessWidget {
  final List<Godown> godowns;
  const GoDownsScreen({super.key, required this.godowns});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 0),
      // color: Colors.grey,
      child: ListView.builder(
        itemCount: godowns.length,
        itemBuilder: (context, index) {
          return GoDownsCard(godown: godowns[index]);
        },
      ),
    );
  }
}

class GoDownsCard extends StatelessWidget {
  final Godown godown;
  const GoDownsCard({super.key, required this.godown});

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
            Image.asset(
              Assets.images.icGodown.path,
              fit: BoxFit.contain,
              width: 80,
              height: 60,
            ),
            const SizedBox(width: 10),
            Expanded(
              // flex: 9,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('${godown.godown}',
                      style: CommonStyles.txStyF16CbFF6
                          .copyWith(color: CommonStyles.impPlacesDataColor)),
                  const Divider(
                    color: CommonStyles.primaryTextColor,
                    thickness: 0.3,
                  ),
                  contentBox(
                      label: tr(LocaleKeys.location),
                      data: '${godown.location}'),
                  contentBox(
                      label: tr(LocaleKeys.address), data: '${godown.address}'),
                  GestureDetector(
                    onTap: () {
                      Constants.launchMap(context,
                          latitude: godown.latitude,
                          longitude: godown.longitude);
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
