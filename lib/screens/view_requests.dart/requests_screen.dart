import 'dart:convert';

import 'package:akshaya_flutter/screens/view_requests.dart/screens/view_biolab_requests.dart';
import 'package:akshaya_flutter/screens/view_requests.dart/screens/view_edibleoil_requests.dart';
import 'package:akshaya_flutter/screens/view_requests.dart/screens/view_equipment_requests.dart';
import 'package:akshaya_flutter/screens/view_requests.dart/screens/view_fertilizer_requests.dart';
import 'package:akshaya_flutter/screens/view_requests.dart/screens/view_labour_requests.dart';
import 'package:akshaya_flutter/screens/view_requests.dart/screens/view_loan_requests.dart';
import 'package:akshaya_flutter/screens/view_requests.dart/screens/view_quickpay_requests.dart';
import 'package:akshaya_flutter/screens/view_requests.dart/screens/view_visit_requests.dart';
import 'package:easy_localization/easy_localization.dart';

import 'package:flutter/material.dart';

import 'package:http/http.dart' as http;

import '../../common_utils/api_config.dart';
import '../../common_utils/common_styles.dart';
import '../../common_utils/shimmer.dart';
import '../../gen/assets.gen.dart';
import '../../localization/locale_keys.dart';
import '../../models/service_model.dart';

class RequestsScreen extends StatefulWidget {
  const RequestsScreen({super.key});

  @override
  State<RequestsScreen> createState() => _RequestsScreenState();
}

class _RequestsScreenState extends State<RequestsScreen> {
  late Future<List<int>> servicesData;

  @override
  void initState() {
    super.initState();
    servicesData = getServicesData();
  }

  Future<List<int>> getServicesData() async {
    final apiUrl = '$baseUrl${getServices}AP';

    try {
      final jsonResponse = await http.get(Uri.parse(apiUrl));
      if (jsonResponse.statusCode == 200) {
        final response = jsonDecode(jsonResponse.body);
        List<dynamic> servicesList = response['listResult'];

        List<int>? serviceTypeIds = servicesList
            .map((item) => ServiceModel.fromJson(item))
            .map((service) => service.serviceTypeId)
            .where((serviceTypeId) => serviceTypeId != 108)
            .map((id) => id!)
            .toList();
        return serviceTypeIds;
      } else {
        throw Exception('Failed to get learning data');
      }
    } catch (error) {
      rethrow;
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    EasyLocalization.of(context)?.locale;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CommonStyles.screenBgColor,
      body: FutureBuilder(
        future: servicesData,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return ShimmerWid(
              child: Container(
                width: double.infinity,
                height: 65.0,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            );
          } else if (snapshot.hasError) {
            return Text('Error: ${snapshot.error}',
                style: CommonStyles.txStyF16CpFF6);
          } else {
            final serviceTypeIdList = snapshot.data as List<int>;
            return ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: serviceTypeIdList.length,
              itemBuilder: (context, index) {
                return serviceListItem(serviceTypeIdList[index]);
              },
            );
          }
        },
      ),
    );
  }

  Widget serviceListItem(int serviceTypeId) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10),
      margin: const EdgeInsets.only(bottom: 2),
      decoration: const BoxDecoration(
          // border: Border.all(color: Colors.green, width: 0.8),
          color: CommonStyles.whiteColor
          //borderRadius: BorderRadius.circular(8),
          ),
      child: ListTile(
        // minTileHeight: 50,
        // trailing: const IconButton(
        //     onPressed: null, icon: Icon(Icons.arrow_right_rounded)),
        leading: Image.asset(
          getServiceImagePath(serviceTypeId),
          width: 35,
          height: 35,
          //    fit: BoxFit.cover,
        ),
        title: Text(
          getServiceName(serviceTypeId),
          style: CommonStyles.txSty_14b_f5.copyWith(
              color: CommonStyles.blackColor, fontWeight: FontWeight.w600),
        ),
        onTap: () {
          switch (serviceTypeId) {
            case 12: // Fertilizer Request
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const ViewFertilizerRequests()),
              );
              break;
            case 10: // Pole Request
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const ViewEquipmentRequests()),
              );
              break;
            case 11: // Labour Request
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const ViewLabourRequests()),
              );
              break;
            case 13: // Quick Pay Request
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const ViewQuickpayRequests()),
              );
            case 14: // Visit Request
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const ViewVisitRequests(),
                ),
              );
              break;
            case 28: // Loan Request
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const ViewLoanRequests()),
              );
              break;
            case 107: // Bio Lab Request
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const ViewBioLabRequests()),
              );
              break;
            case 116: // Edible Oils Request
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const ViewEdibleoilRequests()),
              );
              break;

            default:
              break;
          }
          // Add your onTap functionality here
        },
      ),
    );
  }

  String getServiceImagePath(int serviceTypeId) {
    // Adjust your image paths here
    switch (serviceTypeId) {
      case 10: // Pole Request
        return Assets.images.equipment.path;
      case 11: // Labour Request
        return Assets.images.labour.path;
      case 12: // Fertilizer Request
        return Assets.images.fertilizers.path;
      case 13: // QuickPay Request
        return Assets.images.quickPay.path;
      case 14: // Visit Request
        return Assets.images.visit.path;
      case 28: // Loan Request
        return Assets.images.loan.path;
      case 107: // Bio Lab Request
        return Assets.images.fertilizers.path;
      case 108: // Transport Request
        return Assets.images.fertilizers.path;
      case 116: // Edible Oils Request
        return Assets.images.ediableoils.path;
      default:
        return Assets.images.mainVisit.path;
    }
  }

  String getServiceName(int serviceTypeId) {
    // Adjust your service names here
    switch (serviceTypeId) {
      case 10: // Pole Request
        return tr(LocaleKeys.pole);
      case 11: // Labour Request
        return tr(LocaleKeys.select_labour_type);
      case 12: // Fertilizer Request
        return tr(LocaleKeys.fertilizer);
      case 13: // QuickPay Request
        return tr(LocaleKeys.quick);
      case 14: // Visit Request
        return tr(LocaleKeys.visit);
      case 28: // Loan Request
        return tr(LocaleKeys.loan);
      case 107: // Bio Lab Request
        return tr(LocaleKeys.labproducts);
      case 108: // Transport Request
        return tr(LocaleKeys.App_version);
      case 116: // Edible Oils Request
        return tr(LocaleKeys.edibleoils);
      default:
        return 'Unknown Service';
    }
  }
}
