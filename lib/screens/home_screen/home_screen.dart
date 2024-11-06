// ignore_for_file: deprecated_member_use

import 'dart:convert';
import 'dart:io';

import 'package:akshaya_flutter/common_utils/shared_prefs_keys.dart';
import 'package:akshaya_flutter/screens/home_screen/screens/ffb_collection_screen.dart';
import 'package:akshaya_flutter/services/plots_screen.dart';
import 'package:akshaya_flutter/common_utils/api_config.dart';
import 'package:akshaya_flutter/common_utils/common_styles.dart';
import 'package:akshaya_flutter/gen/assets.gen.dart';
import 'package:akshaya_flutter/localization/locale_keys.dart';
import 'package:akshaya_flutter/models/banner_model.dart';
import 'package:akshaya_flutter/models/learning_model.dart';
import 'package:akshaya_flutter/models/service_model.dart';
import 'package:akshaya_flutter/screens/home_screen/screens/loan_request_screen.dart';

import 'package:akshaya_flutter/screens/home_screen/screens/plot_selection_screen.dart';
import 'package:akshaya_flutter/screens/home_screen/screens/quick_pay_screen.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_carousel_widget/flutter_carousel_widget.dart';
import 'package:marquee/marquee.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shimmer/shimmer.dart';

import '../../services/GodownSelectionScreen.dart';
import 'Learning/EncyclopediaActivity.dart';
import 'screens/farmer_passbook.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late Future<List<int>> servicesData;
  late Future<List<String?>> learningsData;
  late Future<List<BannerModel>> bannersAndMarqueeTextData;

  @override
  void initState() {
    super.initState();
    servicesData = getServicesData();
    learningsData = getLearningsData();
    bannersAndMarqueeTextData = getBannersAndMarqueeText();
  }

  Future<List<int>> getServicesData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final statecode = prefs.getString(SharedPrefsKeys.statecode);
    final apiUrl = '$baseUrl$getServices$statecode';

    try {
      final jsonResponse = await http.get(Uri.parse(apiUrl));
      print('getServicesData: $apiUrl');
      print('getServicesData: ${jsonResponse.body}');
      if (jsonResponse.statusCode == 200) {
        final response = jsonDecode(jsonResponse.body);
        List<dynamic> servicesList = response['listResult'];

        List<int> serviceTypeIds = servicesList
            .map((item) => ServiceModel.fromJson(item))
            .map((service) => service.serviceTypeId)
            .where((serviceTypeId) => serviceTypeId != 108)
            .map((id) => id!)
            .toList();
        return serviceTypeIds;
      } else {
        throw Exception('Failed to get learning data');
      }
    } on SocketException {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            tr(LocaleKeys.Internet),
          ),
        ),
      );
      throw Exception(
        tr(LocaleKeys.Internet),
      );
    } catch (error) {
      rethrow;
    }
  }

  Future<List<String?>> getLearningsData() async {
    final apiUrl = '$baseUrl$getlearning';
    try {
      final jsonResponse = await http.get(Uri.parse(apiUrl));
      if (jsonResponse.statusCode == 200) {
        final response = jsonDecode(jsonResponse.body);
        List<dynamic> learningList = response['listResult'];
        print('=========learningList,$learningList');
        // Extract language-specific names based on the current locale
        List<LearningModel> result =
            learningList.map((item) => LearningModel.fromJson(item)).toList();
        print('=========learningList,$result');
        Locale currentLocale =
            EasyLocalization.of(context)?.locale ?? const Locale('en');

        // Map names based on the locale
        return result.map((item) {
          switch (currentLocale.toString()) {
            case 'te_IN': // Telugu
              return item.teluguName ?? item.name;
            case 'hi_IN': // Hindi
              return item.hindiName ?? item.name;
            case 'kn_IN': // Kannada
              return item.kannadaName ?? item.name;
            default: // Default to English
              return item.name; // Updated to return item.name for default case
          }
        }).toList();
      } else {
        throw Exception('Failed to get services data');
      }
    } catch (error) {
      rethrow;
    }
  }

  // Listen to locale changes and rebuild the widget tree
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    //   EasyLocalization.of(context)?.addListener(() {
    setState(() {
      learningsData = getLearningsData();
    });
    // });
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final appBarHeight = AppBar().preferredSize.height;
    final remainingHeight = screenHeight - appBarHeight;

    Size size = MediaQuery.of(context).size;
    return WillPopScope(
      onWillPop: () async {
        SystemNavigator.pop();
        return false;
      },
      child: Scaffold(
        backgroundColor: const Color(0xfff4f3f1),
        body: Column(
          children: [
            menuSection(size, remainingHeight),
            servicesSection(
              size,
              tr(LocaleKeys.req_services),
              remainingHeight: remainingHeight,
            ),
            learningSection(
              size,
              tr(LocaleKeys.learning),
              backgroundColor: Colors.grey.shade300,
              remainingHeight: remainingHeight,
            ),
            SizedBox(
              // height: remainingHeight * 0.03,
              height: remainingHeight * 0.024,
              child: marqueeText(),
            ),
            Expanded(
              child: banners(size),
            ),
          ],
        ),
      ),
    );
  }

  Widget marqueeText() {
    return FutureBuilder(
      future: bannersAndMarqueeTextData,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          final marquee = snapshot.data as List<BannerModel>;
          return Marquee(
            text:
                "${marquee[0].description!}                                        ${marquee[0].description!}                                        ",
            style: CommonStyles.txStyF12CbFF6,
          );
        } else if (snapshot.hasError) {
          return const ShimmerWidn();
        }
        return const ShimmerWidn();
      },
    );
  }

  Widget banners(Size size) {
    return FutureBuilder(
      future: bannersAndMarqueeTextData,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          final banners = snapshot.data as List<BannerModel>;
          return SizedBox(
            // padding: const EdgeInsets.symmetric(
            //     horizontal: 10.0, vertical: 10.0),
            width: MediaQuery.of(context).size.width,
            height: 200,
            child: FlutterCarousel(
              options: CarouselOptions(
                floatingIndicator: true,
                height: 200,
                viewportFraction: 1.0,
                enlargeCenterPage: true,
                autoPlay: true,
                aspectRatio: 16 / 9,
                autoPlayCurve: Curves.fastOutSlowIn,
                enableInfiniteScroll: true,
                slideIndicator: const CircularSlideIndicator(
                  slideIndicatorOptions: SlideIndicatorOptions(
                    itemSpacing: 10,
                    padding: EdgeInsets.only(bottom: 10.0),
                    indicatorBorderColor: Colors.grey,
                    currentIndicatorColor: Colors.white,
                    indicatorRadius: 3,
                  ),
                ),
                autoPlayAnimationDuration: const Duration(milliseconds: 800),
              ),
              items: banners.map((item) {
                return Builder(
                  builder: (BuildContext context) {
                    return SizedBox(
                      width: MediaQuery.of(context).size.width,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(0),
                        child: Image.network(
                          item.imageName!,
                          height: 200,
                          fit: BoxFit.fill,
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) {
                              return child;
                            }
                            return const Center(
                                child: CircularProgressIndicator.adaptive());
                          },
                        ),
                      ),
                    );
                  },
                );
              }).toList(),
            ),
          );
        } else if (snapshot.hasError) {
          /* return Center(
                          child: Text(
                              snapshot.error
                                  .toString()
                                  .replaceFirst('Exception: ', ''),
                              style: CommonStyles.txStyF16CpFF6),
                        ); */
          return const ShimmerWidn();
        }
        return const ShimmerWidn(); // Placeholder when loading
      },
    );
  }

  Container servicesSection(Size size, String title,
      {Color? backgroundColor, required double remainingHeight}) {
    return Container(
      color: backgroundColor,
      child: Column(
        children: [
          const SizedBox(height: 5),
          Text(
            tr(LocaleKeys.req_services),
            style: CommonStyles.txStyF16CbFF6,
          ),
          const SizedBox(height: 10),
          SizedBox(
            height: remainingHeight * 0.26,
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  FutureBuilder(
                    future: servicesData,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const ShimmerWidn();
                      } else if (snapshot.hasError) {
                        /*  return Text(
                          'Error: ${snapshot.error}',
                          style: CommonStyles.txStyF16CpFF6,
                        ); */
                        return Center(
                          child: Text(
                              textAlign: TextAlign.center,
                              snapshot.error
                                  .toString()
                                  .replaceFirst('Exception: ', ''),
                              style: CommonStyles.txStyF16CpFF6),
                        );
                      } else {
                        final serviceTypeIdList = snapshot.data as List<int>;
                        return GridView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 3,
                            mainAxisSpacing: 0,
                            crossAxisSpacing: 0,
                            childAspectRatio: 1.5,
                          ),
                          itemCount: serviceTypeIdList.length + 1,
                          itemBuilder: (context, index) {
                            return serviceGridItem(
                                index,
                                serviceTypeIdList.length + 1,
                                serviceTypeIdList.length == index
                                    ? -1
                                    : serviceTypeIdList[index]);
                          },
                        );
                      }
                    },
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget learningSection(Size size, String title,
      {Color? backgroundColor, required double remainingHeight}) {
    return Container(
      color: backgroundColor,
      child: Column(
        children: [
          const SizedBox(height: 5),
          Text(
            tr(LocaleKeys.learning),
            style: CommonStyles.txStyF16CbFF6,
          ),
          const SizedBox(height: 10),
          SizedBox(
            height: remainingHeight * 0.13,
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  FutureBuilder(
                    future: learningsData,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const ShimmerWidn(
                          height: 70,
                        );
                      } else if (snapshot.hasError) {
                        /* return Center(
                          child: Text(
                              snapshot.error
                                  .toString()
                                  .replaceFirst('Exception: ', ''),
                              style: CommonStyles.txStyF16CpFF6),
                        ); */
                        return const ShimmerWidn(
                          height: 70,
                        );
                      } else {
                        final learningsList = snapshot.data as List<String?>;

                        return GridView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 3,
                            mainAxisSpacing: 0,
                            crossAxisSpacing: 0,
                            childAspectRatio: 1.5,
                          ),
                          itemCount: learningsList.length + 1,
                          itemBuilder: (context, index) {
                            return learningGridItem(
                              index: index,
                              learningsList: learningsList.length + 1,
                              title: learningsList.length == index
                                  ? null
                                  : learningsList[index],
                            );
                          },
                        );
                      }
                    },
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

//MARK: Menu Section
  Container menuSection(Size size, double remainingHeight) {
    return Container(
      height: remainingHeight * 0.155, // 1.3
      decoration: const BoxDecoration(
          gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
            Color(0xffe46f5d),
            Color(0xffe49962),
          ])),
      child: Column(
        children: [
          const SizedBox(height: 5),
          Text(
            tr(LocaleKeys.view),
            style: CommonStyles.txStyF16CwFF6,
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              viewOption(size, Assets.images.ffbCollection.path,
                  tr(LocaleKeys.collection), onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const FfbCollectionScreen(),
                  ),
                );
              }),
              viewOption(
                  size, Assets.images.passbook.path, tr(LocaleKeys.payments),
                  onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const FarmerPassbookScreen(),
                  ),
                );
              }),
              viewOption(size, Assets.images.mainVisit.path,
                  tr(LocaleKeys.recommendationss), onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const PlotSelectionScreen(
                      serviceTypeId: 101,
                    ),
                  ),
                );
              }),
            ],
          ),
        ],
      ),
    );
  }

  Widget viewOption(Size size, String imagePath, String title,
      {void Function()? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Column(children: [
        SizedBox(
          width: size.width / 3,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.asset(
                imagePath,
                width: 35,
                height: 35,
                fit: BoxFit.cover,
              ),
              const SizedBox(height: 5),
              Container(
                width: 120,
                height: 35,
                // color: Colors.grey,
                alignment: Alignment.topCenter,
                child: Text(
                  title,
                  textAlign: TextAlign.center,
                  style: CommonStyles.txStyF14CwFF6.copyWith(height: 1.2),
                ),
              ),
            ],
          ),
        )
      ]),
    );
  }

//MARK: Services
  void navigateToSelectedServiceScreen(int serviceTypeId) {
    switch (serviceTypeId) {
      case 12:
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) =>
                  const GodownSelectionScreen(keyName: 'Fertilizer')),
        );
        break;
      case 10: // Pole Request
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) =>
                  const GodownSelectionScreen(keyName: 'Pole')),
        );
        break;
      case 107: // Bio Lab Request
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) =>
                  const GodownSelectionScreen(keyName: 'BioLab')),
        );
        break;
      case 116: // Edibleoils Request
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) =>
                  const GodownSelectionScreen(keyName: 'edibleoils')),
        );
        break;
      case 13: // Quick Pay Request
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const QuickPayScreen()),
        );

      case 14: // Visit Request
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => const PlotSelectionScreen(
                    serviceTypeId: 14,
                  )),
        );
        break;
      case 28: // Loan Request
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => const LoanRequestScreen(
                    clusterId: 28,
                  )),
        );
        break;
      case 11: // Labour Request
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const PlotSelection()),
        );
        break;

      default:
        break;
    }
  }

  Widget gridServiceItem(int serviceTypeId) {
    return serviceTypeId < 0
        ? const SizedBox()
        : Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Image.asset(
                getServiceImagePath(serviceTypeId),
                width: 35,
                height: 35,
                fit: BoxFit.cover,
              ),
              const SizedBox(height: 5),
              Text(
                getServiceName(serviceTypeId),
                textAlign: TextAlign.center,
                style: CommonStyles.txStyF14CbFF6,
              ),
            ],
          );
  }

  Widget gridLearningItem(int index, String? title) {
    return title == null
        ? const SizedBox()
        : GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => EncyclopediaActivity(
                    appBarTitle: title,
                    index: (index + 1),
                  ),
                ),
              );
            },
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Image.asset(
                  getLearningImagePath(index),
                  width: 35,
                  height: 35,
                  fit: BoxFit.cover,
                ),
                const SizedBox(height: 5),
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: CommonStyles.txStyF14CbFF6.copyWith(height: 1),
                ),
              ],
            ),
          );
  }

  Widget serviceGridItem(int index, int gridSize, int? serviceTypeId) {
    int totalColumns = 3;
    int totalRows = (gridSize / totalColumns).ceil();
    int currentRow = (index / totalColumns).floor() + 1;

    BorderSide borderSide = const BorderSide(color: Colors.grey, width: 0.5);

    return GestureDetector(
      onTap: () => navigateToSelectedServiceScreen(serviceTypeId),
      child: Container(
        decoration: BoxDecoration(
          border: Border(
            top: (index < totalColumns) ? BorderSide.none : borderSide,
            left: (index % totalColumns == 0) ? BorderSide.none : borderSide,
            right: (index % totalColumns == totalColumns - 1)
                ? BorderSide.none
                : borderSide,
            bottom: (currentRow == totalRows) ? BorderSide.none : borderSide,
          ),
        ),
        child: gridServiceItem(serviceTypeId!),
      ),
    );
  }

  Widget learningGridItem(
      {required int index,
      required int learningsList,
      required String? title}) {
    int totalColumns = 3;
    int totalRows = (learningsList / totalColumns).ceil();
    int currentRow = (index / totalColumns).floor() + 1;

    BorderSide borderSide = const BorderSide(color: Colors.grey, width: 0.5);

    return Container(
      decoration: BoxDecoration(
        border: Border(
          top: (index < totalColumns) ? BorderSide.none : borderSide,
          left: (index % totalColumns == 0) ? BorderSide.none : borderSide,
          right: (index % totalColumns == totalColumns - 1)
              ? BorderSide.none
              : borderSide,
          bottom: (currentRow == totalRows) ? BorderSide.none : borderSide,
        ),
      ),
      child: gridLearningItem(index, title),
    );
  }

  String getServiceImagePath(int serviceTypeId) {
    // 12 10 107 11 13 14 28 108 116
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
      case 000: // 108 Transport Request
        return Assets.images.fertilizers.path;
      case 116: // Edible Oils Request
        return Assets.images.ediableoils.path;

      default:
        return Assets.images.ediableoils.path;
    }
  }

  String getServiceName(int serviceTypeId) {
    // 12 10 107 11 13 14 28 108 116
    switch (serviceTypeId) {
      case 10: // Pole Request
        return tr(LocaleKeys.pole);
      case 11: // Labour Request
        return tr(LocaleKeys.labour_lable);
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
        return tr(LocaleKeys.my3F);
    }
  }

  String getLearningImagePath(int index) {
    // 12 10 107 11 13 14 28 108 116
    switch (index) {
      case 0: // Fertilizers
        return Assets.images.fertilizers.path;
      case 1: // Harvesting
        return Assets.images.harvesting.path;
      case 2: // Pests and Diseases
        return Assets.images.pest.path;
      case 3: // Oil Palm Management
        return Assets.images.oilpalm.path;
      case 4: // General
        return Assets.images.general.path;
      case 5: // Loan Request
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

//MARK: Marqee API

  Future<List<BannerModel>> getBannersAndMarqueeText() async {
    final apiUrl = '$baseUrl$getbanners/AP';
    try {
      final jsonResponse = await http.get(Uri.parse(apiUrl));
      if (jsonResponse.statusCode == 200) {
        List<dynamic> response = json.decode(jsonResponse.body)['listResult'];
        return response.map((item) => BannerModel.fromJson(item)).toList();
      } else {
        throw Exception(
            'Request failed with status: ${jsonResponse.statusCode}');
      }
    } catch (e) {
      rethrow;
    }
  }
}

class ShimmerWidn extends StatelessWidget {
  const ShimmerWidn({super.key, this.height = 70});
  final double? height;
  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Container(
        width: double.infinity,
        height: height,
        color: Colors.white,
      ),
    );
  }
}

class GridItem {
  final String imagePath;
  final String title;

  GridItem({required this.imagePath, required this.title});
}
