import 'package:akshaya_flutter/common_utils/common_styles.dart';
import 'package:akshaya_flutter/common_utils/constants.dart';
import 'package:akshaya_flutter/gen/assets.gen.dart';
import 'package:akshaya_flutter/localization/locale_keys.dart';
import 'package:akshaya_flutter/models/important_places_model.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

class NurseriesContentScreen extends StatelessWidget {
  final List<Nursery> nurseries;
  const NurseriesContentScreen({super.key, required this.nurseries});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12).copyWith(top: 12),
      child: ListView.builder(
        itemCount: nurseries.length,
        itemBuilder: (context, index) {
          return NurseriesContentCard(nursery: nurseries[index]);
        },
      ),
    );
  }
}

class NurseriesContentCard extends StatelessWidget {
  final Nursery nursery;
  const NurseriesContentCard({super.key, required this.nursery});

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
                Assets.images.nurseriesIcon.path,
                fit: BoxFit.contain,
                // width: 70,
                height: 90,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              flex: 8,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('${nursery.nurseryName}',
                      style: CommonStyles.txStyF16CbFF6),
                  const Divider(
                    color: CommonStyles.primaryTextColor,
                    thickness: 0.3,
                  ),
                  contentBox(
                    label: tr(LocaleKeys.village),
                    nursery: '${nursery.village}',
                  ),
                  contentBox(
                    label: tr(LocaleKeys.village),
                    nursery: '${nursery.mandal}',
                  ),
                  contentBox(
                    label: tr(LocaleKeys.dist),
                    nursery: '${nursery.district}',
                  ),
                  GestureDetector(
                    onTap: () {
                      Constants.launchMap(
                          latitude: nursery.latitude,
                          longitude: nursery.longitude);
                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text(tr(LocaleKeys.view_in_map),
                            style: CommonStyles.txStyF14CbFF6),
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

  Widget contentBox({required String label, required String? nursery}) {
    return Column(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
                flex: 4, child: Text(label, style: CommonStyles.txStyF14CbFF6)),
            const Text(':  ', style: CommonStyles.txStyF14CbFF6),
            Expanded(
              flex: 6,
              child: Text('$nursery',
                  style: CommonStyles.txStyF14CbFF6,
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
