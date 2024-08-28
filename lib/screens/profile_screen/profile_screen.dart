import 'dart:convert';

import 'package:akshaya_flutter/common_utils/api_config.dart';
import 'package:akshaya_flutter/common_utils/common_styles.dart';
import 'package:akshaya_flutter/common_utils/constants.dart';
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
      userId = prefs.getString('user_id');
      print('FarmerCode -==$userId');
    });
    //const apiUrl = 'http://182.18.157.215/3FAkshaya/API/api/Farmer/GetActivePlotsByFarmerCode/APWGBDAB00010005';
     final apiUrl = '$baseUrl${getActivePlotsByFarmerCode}$userId';

    try {
      final jsonResponse = await http.get(Uri.parse(apiUrl));
      print('apiUrl: $apiUrl');
      print('jsonResponse: ${jsonResponse.body}');
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
    if (result != null) {}
    Map<String, dynamic> response = json.decode(result!);
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
        // backgroundColor: const Color(0xffe46f5d),
        appBar: tabBar(),
        body: tabView(),
      ),
    );
  }

  AppBar tabBar() {
    return AppBar(
      automaticallyImplyLeading: false,
      backgroundColor: const Color(0xffe46f5d),
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1),
        child: TabBar(
          indicatorColor: CommonStyles.primaryTextColor,
          indicatorWeight: 2.0,
          indicatorSize: TabBarIndicatorSize.tab,
          labelColor: CommonStyles.primaryTextColor,
          unselectedLabelColor: CommonStyles.whiteColor,
          indicator: const BoxDecoration(
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(10),
              topRight: Radius.circular(10),
            ),
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
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: TabBarView(
        children: [
          FutureBuilder(
              future: farmerData,
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Text('Error: ${snapshot.error}');
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
                  return Text('Error: ${snapshot.error}');
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
      print('FarmerCode -==$userId');
      print('stateCode -==$stateCode');
      print('districtId -==$districtId');
      print('districtName -==$districtName');
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
                    child: Image.asset(
                      Assets.images.icUser.path,
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
                Expanded(
                    child: Center(
                  child: QrImageView(
                    data: '${farmerData.code}',
                    version: QrVersions.auto,
                    // size: 200.0,
                  ),
                )),
              ],
            ),
          ),
          const SizedBox(height: 10),
          farmerInfoBox(
              label: tr(LocaleKeys.farmar_code),
              data: '${farmerData.code}',
              textColor: CommonStyles.primaryTextColor),
          farmerInfoBox(
            label: tr(LocaleKeys.farmer_name),
            data: '${farmerData.firstName} ${farmerData.middleName ?? ''} ${farmerData.lastName}',
          ),
          farmerInfoBox(
            label: tr(LocaleKeys.fa_hu_name),
            data: '${farmerData.guardianName}',
          ),
          farmerdialInfoBox(
              label: tr(LocaleKeys.mobile),
              data: '${farmerData.contactNumber}',
              textColor: Colors.green),
          const SizedBox(height: 20),
          Text(tr(LocaleKeys.res_address),
              style: CommonStyles.txSty_14b_f5
                  .copyWith(color: CommonStyles.primaryTextColor)),
          const Divider(color: CommonStyles.primaryTextColor, thickness: 0.3),
          const SizedBox(height: 5),
          farmerInfoBox(
            label: tr(LocaleKeys.address),
            data: '${farmerData.address}',
          ),
          farmerInfoBox(
            label: tr(LocaleKeys.res_address),
            data: '${farmerData.landmark}',
          ),
          farmerInfoBox(
            label: tr(LocaleKeys.village),
            data: '${farmerData.villageName}',
          ),
          farmerInfoBox(
            label: tr(LocaleKeys.mandal),
            data: '${farmerData.mandalName}',
          ),
          farmerInfoBox(
            label: tr(LocaleKeys.dist),
            data: '${farmerData.districtName}',
          ),
          farmerInfoBox(
            label: tr(LocaleKeys.state),
            data: '${farmerData.stateName}',
          ),
          farmerInfoBox(
            label: tr(LocaleKeys.pin),
            data: '${farmerData.pinCode}',
          ),
        ],
      ),
    );
  }

  Widget farmerInfoBox(
      {required String label, required String data, Color? textColor}) {
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
                child: Text(
                  ':   $data',
                  style: CommonStyles.txSty_14b_f5.copyWith(
                    color: textColor,
                  ),
                )),
          ],
        ),
        const SizedBox(height: 5),
      ],
    );
  }

  farmerdialInfoBox({required String label, required String data, required MaterialColor textColor}) {
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
    color:Color(0xFF34A350), // Use blue or custom color
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
    return Column(
      children: [
        const SizedBox(height: 10),
        plot(),
        const SizedBox(height: 10),
      ],
    );
  }

  Container plot() {
    final df = NumberFormat("#,##0.00");
    String? dateOfPlanting = plotdata.dateOfPlanting;
    DateTime parsedDate = DateTime.parse(dateOfPlanting!);
    String year = parsedDate.year.toString();// Example number format
    print('year=======$year');
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
          // border:
          //     Border.all(color: CommonStyles.primaryTextColor, width: 0.3),
          borderRadius: BorderRadius.circular(10),
          color: index % 2 == 0 ? Colors.transparent : Colors.grey.shade200),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          plotDetailsBox(
              label: tr(LocaleKeys.code),
              data: '${plotdata.plotcode}',
              dataTextColor: CommonStyles.primaryTextColor),
          plotDetailsBox(
            label: tr(LocaleKeys.plaod_hect),
            data: '${df.format(plotdata.palmArea)} Ha (${df.format(plotdata.palmArea! * 2.5)} Acre)',
          ),
          plotDetailsBox(
            label: tr(LocaleKeys.sur_num),
            data: '${plotdata.surveyNumber}',
          ),
          plotDetailsBox(
            label: tr(LocaleKeys.address),
            data: '${plotdata.clusterName}',
          ),
          plotDetailsBox(
            label: tr(LocaleKeys.land_mark),
            data: '${plotdata.landMark}',
          ),
          plotDetailsBox(
            label: tr(LocaleKeys.village),
            data: '${plotdata.villageName}',
          ),
          plotDetailsBox(
            label: tr(LocaleKeys.mandal),
            data: '${plotdata.mandalName}',
          ),
          plotDetailsBox(
            label: tr(LocaleKeys.dist),
            data: '${plotdata.districtName}',
          ),
          plotDetailsBox(
            label: tr(LocaleKeys.yop),
            data: '${year}',
          ),
          plotDetailsBox(
            label: tr(LocaleKeys.address),
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
                  style: CommonStyles.txSty_14b_f5,
                )),
            Expanded(
                flex: 6,
                child: Text(
                  ':   $data',
                  style: CommonStyles.txSty_14b_f5.copyWith(
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
