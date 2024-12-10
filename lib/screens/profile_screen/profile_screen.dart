import 'dart:convert';

import 'package:akshaya_flutter/common_utils/api_config.dart';
import 'package:akshaya_flutter/common_utils/common_styles.dart';
import 'package:akshaya_flutter/common_utils/common_widgets.dart';
import 'package:akshaya_flutter/common_utils/shared_prefs_keys.dart';
import 'package:akshaya_flutter/gen/assets.gen.dart';
import 'package:akshaya_flutter/localization/locale_keys.dart';
import 'package:akshaya_flutter/models/farmer_model.dart';
import 'package:akshaya_flutter/models/plot_details_model.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late Future<FarmerModel> farmerData;
  late Future<List<PlotDetailsModel>> plotsData;
  String? userId;
  String? stateCode;
  int? districtId;
  String? districtName;
  @override
  void initState() {
    super.initState();
    _loadUserData();
    farmerData = getFarmerInfoFromSharedPrefs();
    plotsData = getPlotDetails();
  }

  Future<List<PlotDetailsModel>> getPlotDetails() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      userId = prefs.getString(SharedPrefsKeys.farmerCode);
      print('FarmerCode -==$userId');
    });
    //const apiUrl = 'http://182.18.157.215/3FAkshaya/API/api/Farmer/GetActivePlotsByFarmerCode/APWGBDAB00010005';
    final apiUrl = '$baseUrl$getActivePlotsByFarmerCode$userId';

    print('profile: $apiUrl');
    try {
      final jsonResponse = await http.get(Uri.parse(apiUrl));
      if (jsonResponse.statusCode == 200) {
        final response = jsonDecode(jsonResponse.body);
        List<dynamic> plotList = response['listResult'];
        return plotList.map((item) => PlotDetailsModel.fromJson(item)).toList();
      } else {
        throw Exception(
            'Request failed with status: ${jsonResponse.statusCode}');
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<FarmerModel> getFarmerInfoFromSharedPrefs() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final result = prefs.getString(SharedPrefsKeys.farmerData);
    if (result == null) {
      throw Exception('No farmer data found in shared preferences');
    }
    Map<String, dynamic> response = json.decode(result);
    Map<String, dynamic> farmerResult = response['result']['farmerDetails'][0];
    return FarmerModel.fromJson(farmerResult);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    EasyLocalization.of(context)?.locale;
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: CommonStyles.screenBgColor,
        appBar: tabBar(),
        body: tabView(),
      ),
    );
  }

  AppBar tabBar() {
    return AppBar(
      automaticallyImplyLeading: false,
      backgroundColor: CommonStyles.tabBarColor,
      elevation: 0,
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1),
        child: TabBar(
          labelStyle: CommonStyles.txStyF14CbFF6.copyWith(
            fontWeight: FontWeight.w400,
          ),
          // indicatorPadding: const EdgeInsets.only(bottom: 3),
          indicatorColor: CommonStyles.primaryTextColor,
          indicatorWeight: 2.0,
          indicatorSize: TabBarIndicatorSize.tab,
          labelColor: CommonStyles.primaryTextColor,
          unselectedLabelColor: CommonStyles.whiteColor,
          dividerColor: Colors.transparent,
          indicator: const BoxDecoration(
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(10),
              topRight: Radius.circular(10),
            ),
            border: Border(
                bottom: BorderSide(
              color: Colors.redAccent,
              width: 1.4,
            )),
            color: CommonStyles.primaryColor,
          ),
          tabs: [
            Tab(text: tr(LocaleKeys.farmer_profile)),
            Tab(text: tr(LocaleKeys.plot_details)),
          ],
        ),
      ),
    );
  }

  Widget tabView() {
    return Padding(
      // padding: const EdgeInsets.symmetric(horizontal: 12).copyWith(top: 12),
      padding: const EdgeInsets.all(12),
      child: TabBarView(
        children: [
          FutureBuilder(
              future: farmerData,
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(
                    child: Text(
                        textAlign: TextAlign.center,
                        snapshot.error
                            .toString()
                            .replaceFirst('Exception: ', ''),
                        style: CommonStyles.txStyF16CpFF6),
                  );
                } else if (snapshot.hasData) {
                  final farmer = snapshot.data as FarmerModel;
                  return FarmerProfile(farmerData: farmer);
                }
                return const CircularProgressIndicator.adaptive();
              }),
          // const Center(child: Text('Plot Details')),
          FutureBuilder(
              future: plotsData,
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(
                    child: Text(
                        textAlign: TextAlign.center,
                        snapshot.error
                            .toString()
                            .replaceFirst('Exception: ', ''),
                        style: CommonStyles.txStyF16CpFF6),
                  );
                } else if (snapshot.hasData) {
                  final plots = snapshot.data as List<PlotDetailsModel>;
                  return ListView.builder(
                    itemCount: plots.length,
                    itemBuilder: (context, index) {
                      return PlotDetails(plotdata: plots[index], index: index);
                    },
                  );
                } else {
                  return const Center(
                      child: CircularProgressIndicator.adaptive());
                }
              }),
        ],
      ),
    );
  }

  Future<void> _loadUserData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      userId = prefs.getString('user_id');
      stateCode = prefs.getString('statecode');
      districtId = prefs.getInt('districtId');
      districtName = prefs.getString('districtName');
    });
  }
}

class FarmerProfile extends StatelessWidget {
  final FarmerModel farmerData;
  const FarmerProfile({super.key, required this.farmerData});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: 120,
            child: Row(
              children: [
                Expanded(
                  child: Center(
                    child: farmerData.farmerPictureLocation != null
                        ? Image.network(
                            farmerData.farmerPictureLocation!,
                            fit: BoxFit.contain,
                            height: 90,
                            errorBuilder: (context, error, stackTrace) {
                              // Show icUser image if there's an error loading the farmer image
                              return Image.asset(
                                Assets.images.icUser.path,
                                fit: BoxFit.contain,
                                height: 90,
                              );
                            },
                          )
                        : Image.asset(
                            Assets.images.icUser
                                .path, // Placeholder image if farmerImage is null
                            fit: BoxFit.contain,
                            height: 90,
                          ),
                  ),
                ),
                Expanded(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          color: CommonStyles.whiteColor,
                          padding: const EdgeInsets.all(4.0),
                          child: QrImageView(
                            data: '${farmerData.code}',
                            version: QrVersions.auto,
                            size: 90,
                          ),
                        ),
                        const Text(
                          'QR Code',
                          style: CommonStyles.txStyF14CbFF6,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          if (farmerData.code != null)
            CommonWidgets.commonRowWithColon(
                label: tr(LocaleKeys.farmar_code),
                data: '${farmerData.code}',
                dataTextColor: CommonStyles.primaryTextColor),
          if (farmerData.firstName != null)
            CommonWidgets.commonRowWithColon(
              label: tr(LocaleKeys.farmer_name),
              data:
                  '${farmerData.firstName} ${farmerData.middleName ?? ''} ${farmerData.lastName}',
            ),
          if (farmerData.guardianName != null)
            CommonWidgets.commonRowWithColon(
              label: tr(LocaleKeys.fa_hu_name),
              data: '${farmerData.guardianName}',
            ),
          if (farmerData.contactNumber != null)
            CommonWidgets.commonRowWithColon(
                label: tr(LocaleKeys.mobile),
                data: '${farmerData.contactNumber}',
                dataTextColor: Colors.green),
          if (farmerData.mobileNumber != null)
            CommonWidgets.commonRowWithColon(
              label: tr(LocaleKeys.alter_mobile),
              data: '${farmerData.mobileNumber}',
            ),
          const SizedBox(height: 20),
          Text(tr(LocaleKeys.res_address),
              style: CommonStyles.txStyF14CbFF6
                  .copyWith(color: CommonStyles.primaryTextColor)),
          const Divider(
            color: CommonStyles.primaryTextColor,
            thickness: 0.3,
          ),
          if (farmerData.address != null)
            CommonWidgets.commonRowWithColon(
              label: tr(LocaleKeys.address),
              data: '${farmerData.addressLine1} - ${farmerData.addressLine2}',
            ),
          if (farmerData.landmark != null)
            CommonWidgets.commonRowWithColon(
              label: tr(LocaleKeys.landmark),
              data: '${farmerData.landmark}',
            ),
          if (farmerData.villageName != null)
            CommonWidgets.commonRowWithColon(
              label: tr(LocaleKeys.village),
              data: '${farmerData.villageName}',
            ),
          if (farmerData.mandalName != null)
            CommonWidgets.commonRowWithColon(
              label: tr(LocaleKeys.mandal),
              data: '${farmerData.mandalName}',
            ),
          if (farmerData.districtName != null)
            CommonWidgets.commonRowWithColon(
              label: tr(LocaleKeys.dist),
              data: '${farmerData.districtName}',
            ),
          if (farmerData.stateName != null)
            CommonWidgets.commonRowWithColon(
              label: tr(LocaleKeys.state),
              data: '${farmerData.stateName}',
            ),
          if (farmerData.pinCode != null)
            CommonWidgets.commonRowWithColon(
              label: tr(LocaleKeys.pin),
              data: '${farmerData.pinCode}',
              isSpace: false,
            ),
          const Divider(
            color: CommonStyles.primaryTextColor,
            thickness: 0.3,
          ),
        ],
      ),
    );
  }

  farmerdialInfoBox(
      {required String label,
      required String data,
      required MaterialColor textColor}) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
                flex: 5,
                child: Text(
                  label,
                  style: CommonStyles.txSty_14b_f5,
                )),
            Expanded(
              flex: 6,
              child: InkWell(
                onTap: () async {
                  final url = 'tel:+91$data';
                  if (await canLaunch(url)) {
                    await launch(url);
                  } else {
                    throw 'Could not launch $url';
                  }
                },
                child: Text(
                  ':   $data',
                  style: CommonStyles.txSty_14b_f5.copyWith(
                    color: const Color(0xFF34A350), // Use blue or custom color
                    // Optional: underline to indicate clickable
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 5),
      ],
    );
  }
}

class PlotDetails extends StatelessWidget {
  final PlotDetailsModel plotdata;
  final int index;

  const PlotDetails({super.key, required this.plotdata, required this.index});

  @override
  Widget build(BuildContext context) {
    return plot();
  }

  Container plot() {
    final df = NumberFormat("#,##0.00");
    String? dateOfPlanting = plotdata.dateOfPlanting;
    DateTime parsedDate = DateTime.parse(dateOfPlanting!);
    String year = parsedDate.year.toString();
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: index % 2 == 0 ? Colors.transparent : Colors.grey.shade200),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CommonWidgets.commonRowWithColon(
            label: tr(LocaleKeys.code),
            data: '${plotdata.plotcode}',
            dataTextColor: CommonStyles.primaryTextColor,
          ),
          CommonWidgets.commonRowWithColon(
              label: tr(LocaleKeys.plaod_hect),
              dataTextColor: CommonStyles.dataTextColor,
              data:
                  '${df.format(plotdata.palmArea)} Ha (${df.format(plotdata.palmArea! * 2.5)} Acre)'),
          CommonWidgets.commonRowWithColon(
            label: tr(LocaleKeys.sur_num),
            dataTextColor: CommonStyles.dataTextColor,
            data: '${plotdata.surveyNumber}',
          ),
          CommonWidgets.commonRowWithColon(
            label: tr(LocaleKeys.address),
            dataTextColor: CommonStyles.dataTextColor,
            data: '${plotdata.villageName}',
          ),
          CommonWidgets.commonRowWithColon(
            label: tr(LocaleKeys.land_mark),
            dataTextColor: CommonStyles.dataTextColor,
            data: '${plotdata.landMark}',
          ),
          CommonWidgets.commonRowWithColon(
            label: tr(LocaleKeys.village),
            dataTextColor: CommonStyles.dataTextColor,
            data: '${plotdata.villageName}',
          ),
          CommonWidgets.commonRowWithColon(
            label: tr(LocaleKeys.mandal),
            dataTextColor: CommonStyles.dataTextColor,
            data: '${plotdata.mandalName}',
          ),
          CommonWidgets.commonRowWithColon(
            label: tr(LocaleKeys.dist),
            dataTextColor: CommonStyles.dataTextColor,
            data: '${plotdata.districtName}',
          ),
          CommonWidgets.commonRowWithColon(
            label: tr(LocaleKeys.yop),
            dataTextColor: CommonStyles.dataTextColor,
            data: year,
          ),
          CommonWidgets.commonRowWithColon(
            label: tr(LocaleKeys.cluster_officer),
            dataTextColor: CommonStyles.dataTextColor,
            data: '${plotdata.clusterName}',
          ),
        ],
      ),
    );
  }

  Widget plotDetailsBox(
      {required String label, required String data, Color? dataTextColor}) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
                flex: 5,
                child: Text(
                  label,
                  style: CommonStyles.txStyF14CbFF6,
                )),
            Expanded(
                flex: 6,
                child: Text(
                  ':   $data',
                  style: CommonStyles.txStyF14CbFF6.copyWith(
                    color: dataTextColor,
                  ),
                )),
          ],
        ),
        const SizedBox(height: 5),
      ],
    );
  }
}
