import 'package:akshaya_flutter/common_utils/common_styles.dart';
import 'package:akshaya_flutter/common_utils/constants.dart';
import 'package:akshaya_flutter/gen/assets.gen.dart';
import 'package:akshaya_flutter/models/important_places_model.dart';
import 'package:flutter/material.dart';

class NurseriesContentScreen extends StatelessWidget {
  final List<Nursery> nurseries;
  const NurseriesContentScreen({super.key, required this.nurseries});

  @override
  Widget build(BuildContext context) {
    return Expanded(
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
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(5.0),
        ),
        margin: const EdgeInsets.only(bottom: 10),
        child: Row(
          children: [
            Expanded(
              flex: 3,
              child: Image.asset(
                Assets.images.nurseriesIcon.path,
                // height: 50,
                fit: BoxFit.contain,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              flex: 8,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('${nursery.nurseryName}',
                      style: CommonStyles.txSty_14b_fb),
                  const Divider(),
                  contentBox(
                    label: 'Village',
                    nursery: '${nursery.village}',
                  ),
                  contentBox(
                    label: 'Mandal',
                    nursery: '${nursery.mandal}',
                  ),
                  contentBox(
                    label: 'District',
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

  Widget contentBox({required String label, required String? nursery}) {
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
                child: Text('$nursery', style: CommonStyles.txSty_12b_f5)),
          ],
        ),
        const Divider(),
      ],
    );
  }
}
