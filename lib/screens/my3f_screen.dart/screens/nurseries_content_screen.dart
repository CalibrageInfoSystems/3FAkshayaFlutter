import 'package:akshaya_flutter/common_utils/common_styles.dart';
import 'package:akshaya_flutter/common_utils/constants.dart';
import 'package:akshaya_flutter/gen/assets.gen.dart';
import 'package:akshaya_flutter/localization/locale_keys.dart';
import 'package:akshaya_flutter/models/important_places_model.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

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

class NurseriesContentCard extends StatefulWidget {
  final Nursery nursery;
  const NurseriesContentCard({super.key, required this.nursery});

  @override
  State<NurseriesContentCard> createState() => _NurseriesContentCardState();
}

class _NurseriesContentCardState extends State<NurseriesContentCard> {
/*   @override
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
              flex: 2,
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
                      style: CommonStyles.txStyF16CbFF6
                          .copyWith(color: CommonStyles.impPlacesDataColor)),
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

  Widget contentBox({required String label, required String? nursery}) {
    return Column(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
                flex: 4,
                child: Text(label,
                    style: CommonStyles.txStyF14CbFF6
                        .copyWith(color: CommonStyles.impPlacesDataColor))),
            Text(':  ',
                style: CommonStyles.txStyF14CbFF6
                    .copyWith(color: CommonStyles.impPlacesDataColor)),
            Expanded(
              flex: 6,
              child: Text('$nursery',
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
 */
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
                  Text('${widget.nursery.nurseryName}',
                      style: CommonStyles.txStyF16CbFF6
                          .copyWith(color: CommonStyles.impPlacesDataColor)),
                  const Divider(
                    color: CommonStyles.primaryTextColor,
                    thickness: 0.3,
                  ),
                  contentBox(
                    label: tr(LocaleKeys.village),
                    data: '${widget.nursery.village}',
                  ),
                  contentBox(
                    label: tr(LocaleKeys.mandal),
                    data: '${widget.nursery.mandal}',
                  ),
                  contentBox(
                    label: tr(LocaleKeys.dist),
                    data: '${widget.nursery.district}',
                  ),
                  GestureDetector(
                    onTap: () {
                      Constants.launchMap(context,
                          latitude: widget.nursery.latitude,
                          longitude: widget.nursery.longitude);
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

  Future<void> launchMap(
      {required double? latitude, required double? longitude}) async {
    final Uri mapUrl = Uri.parse(
        'https://www.google.com/maps/search/?api=1&query=$latitude,$longitude');

    if (latitude != null || longitude != null) {
      if (!await launchUrl(
        mapUrl,
        mode: LaunchMode.externalApplication,
      )) {
        throw Exception('Could not launch $mapUrl');
      }
    } else {
      print('No latitude or longitude found');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(tr(LocaleKeys.location_notfount)),
        ),
      );
    }
  }
}
