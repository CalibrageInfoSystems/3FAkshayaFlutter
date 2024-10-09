import 'package:akshaya_flutter/common_utils/common_styles.dart';
import 'package:akshaya_flutter/gen/assets.gen.dart';
import 'package:akshaya_flutter/models/important_contacts_model.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../localization/locale_keys.dart';

class ImportantContactsScreen extends StatelessWidget {
  final ImportantContacts data;
  const ImportantContactsScreen({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Image.asset(Assets.images.icImpContacts.path),
            const SizedBox(height: 10),
            Text(tr(LocaleKeys.important_contacts),
                style: CommonStyles.txStyF16CpFF6.copyWith(fontSize: 18)),
            const SizedBox(height: 20),
            contactForm(
                label: tr(LocaleKeys.officer_name),
                data: data.clusterOfficerName ?? 'N/A'),
            contactFormclick(
                label: tr(LocaleKeys.officer_mobile),
                data: data.clusterOfficerContactNumber ?? 'N/A',
                datatextColor: Colors.green),
            contactForm(
                label: tr(LocaleKeys.manager_name),
                data: data.clusterOfficerManagerName ?? 'N/A'),
            contactFormclick(
                label: tr(LocaleKeys.manager_num),
                data: data.clusterOfficerManagerContactNumber ?? 'N/A',
                datatextColor: Colors.green),
            contactForm(
                label: tr(LocaleKeys.head_name),
                data: data.stateHeadName ?? 'N/A'),
            contactFormclick(
                label: tr(LocaleKeys.customer_care),
                data: '040 23324733',
                datatextColor: Colors.green),
            contactFormWhatsAppclick(
                label: tr(LocaleKeys.whats_number),
                data: '9515103107',
                datatextColor: Colors.green),
          ],
        ),
      ),
    );
  }

  Widget contactForm(
      {required String label, required String? data, Color? datatextColor}) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
                flex: 7, child: Text(label, style: CommonStyles.txStyF14CbFF6)),
            const Text(':  ', style: CommonStyles.txStyF14CbFF6),
            Expanded(
              flex: 4,
              child: Text(
                '$data',
                style: CommonStyles.txStyF14CbFF6.copyWith(
                  color: datatextColor,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
      ],
    );
  }

  Widget contactFormclick(
      {required String label, required String? data, Color? datatextColor}) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
                flex: 7, child: Text(label, style: CommonStyles.txStyF14CbFF6)),
            const Text(
              ':  ',
              style: CommonStyles.txStyF14CbFF6,
            ),
            Expanded(
              flex: 4,
              child: InkWell(
                onTap: () async {
                  final url = 'tel:$data';
                  if (await canLaunch(url)) {
                    await launch(url);
                  } else {
                    throw 'Could not launch $url';
                  }
                },
                child: Text(
                  '$data',
                  style: CommonStyles.txStyF14CbFF6.copyWith(
                    color: const Color(0xFF34A350),
                  ),
                ),
              ),
            ),
            // Expanded(
            //   flex: 4,
            //   child: Text(
            //     '$data',
            //     style: CommonStyles.txSty_14b_fb.copyWith(
            //       color: datatextColor,
            //     ),
            //   ),
            // ),
          ],
        ),
        const SizedBox(height: 12),
      ],
    );
  }

  Widget contactFormWhatsAppclick(
      {required String label, required String? data, Color? datatextColor}) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
                flex: 7, child: Text(label, style: CommonStyles.txStyF14CbFF6)),
            const Text(':  ', style: CommonStyles.txStyF14CbFF6),
            Expanded(
              flex: 4,
              child: InkWell(
                onTap: () async {
                  const phoneNumber = '+91 9515103107';
                  const url =
                      'https://api.whatsapp.com/send?phone=$phoneNumber';
                  if (await canLaunch(url)) {
                    await launch(url);
                  } else {
                    throw 'Could not launch $url';
                  }
                },
                child: Text(
                  '$data',
                  style: CommonStyles.txStyF14CbFF6.copyWith(
                    color: const Color(0xFF34A350), // Use blue or custom color
                    // Optional: underline to indicate clickable
                  ),
                ),
              ),
            ),
            // Expanded(
            //   flex: 4,
            //   child: Text(
            //     '$data',
            //     style: CommonStyles.txSty_14b_fb.copyWith(
            //       color: datatextColor,
            //     ),
            //   ),
            // ),
          ],
        ),
        const SizedBox(height: 12),
      ],
    );
  }
}
