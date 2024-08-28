import 'package:akshaya_flutter/common_utils/common_styles.dart';
import 'package:akshaya_flutter/gen/assets.gen.dart';
import 'package:akshaya_flutter/models/important_contacts_model.dart';
import 'package:flutter/material.dart';

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
            const SizedBox(height: 20),
            Image.asset(Assets.images.icImpContacts.path),
            const SizedBox(height: 10),
            const Text('Important Contacts', style: CommonStyles.txSty_16p_fb),
            const SizedBox(height: 20),
            contactForm(
                label: 'Cluster Officer Name', data: data.clusterOfficerName),
            contactForm(
                label: 'Cluster Officer Contact Number',
                data: data.clusterOfficerContactNumber,
                datatextColor: Colors.green),
            contactForm(
                label: 'Cluster Manager Name',
                data: data.clusterOfficerManagerName),
            contactForm(
                label: 'Cluster Manager Contact Number',
                data: data.clusterOfficerManagerContactNumber,
                datatextColor: Colors.green),
            contactForm(label: 'State Head Name', data: data.stateHeadName),
            contactForm(
                label: 'Customer Care Number',
                data: 'xxxxxx',
                datatextColor: Colors.green),
            contactForm(
                label: 'WhatsApp Number',
                data: 'xxxxxx',
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
                flex: 7, child: Text(label, style: CommonStyles.txSty_14b_fb)),
            const Text(':  '),
            Expanded(
              flex: 4,
              child: Text(
                '$data',
                style: CommonStyles.txSty_14b_fb.copyWith(
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
}
