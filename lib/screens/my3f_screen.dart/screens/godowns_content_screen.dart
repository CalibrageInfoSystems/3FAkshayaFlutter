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
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(5.0),
        ),
        margin: const EdgeInsets.only(bottom: 10),
        child:
        Row(
          children: [
            Expanded(
              flex: 3,
              child: Image.asset(
                Assets.images.icGodown.path,
                fit: BoxFit.contain,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              flex: 8,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('${godown.godown}', style: CommonStyles.txSty_14b_f5),
                  const Divider(),
                  contentBox(label: tr(LocaleKeys.location), data: '${godown.location}'),
                  contentBox(label: tr(LocaleKeys.address), data: '${godown.address}'),
                  GestureDetector(
                    onTap: () {
                      Constants.launchMap(
                          latitude: godown.latitude,
                          longitude: godown.longitude);
                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        const Text('View in Map',
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
              child: Text('$data',
                  style: CommonStyles.txSty_12b_f5,
                  maxLines: 4,
                  overflow: TextOverflow.ellipsis),
            ),
          ],
        ),
        const Divider(),
      ],
    );
  }
}
