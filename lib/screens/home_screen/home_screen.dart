import 'dart:convert';

import 'package:akshaya_flutter/common_utils/Constants.dart';
import 'package:akshaya_flutter/common_utils/api_config.dart';
import 'package:akshaya_flutter/common_utils/common_styles.dart';
import 'package:akshaya_flutter/gen/assets.gen.dart';
import 'package:akshaya_flutter/localization/locale_keys.dart';
import 'package:akshaya_flutter/models/banner_model.dart';
import 'package:akshaya_flutter/models/learning_model.dart';
import 'package:akshaya_flutter/models/service_model.dart';
import 'package:akshaya_flutter/navigation/app_routes.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:marquee/marquee.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

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

  List<String> bannersList = [
    'https://letsenhance.io/static/73136da51c245e80edc6ccfe44888a99/1015f/MainBefore.jpg',
    'https://letsenhance.io/static/73136da51c245e80edc6ccfe44888a99/1015f/MainBefore.jpg',
    'https://letsenhance.io/static/73136da51c245e80edc6ccfe44888a99/1015f/MainBefore.jpg',
  ];

  List<GridItem> gridItems = [
    GridItem(imagePath: Assets.images.fertilizers.path, title: 'Fertilizer'),
    GridItem(imagePath: Assets.images.equipment.path, title: 'Equipment'),
    GridItem(imagePath: Assets.images.fertilizers1.path, title: 'Bio Lab'),
    GridItem(imagePath: Assets.images.labour.path, title: 'Labour'),
    GridItem(imagePath: Assets.images.quickPay.path, title: 'QuickPay'),
    GridItem(imagePath: Assets.images.visit.path, title: 'Visit'),
    GridItem(imagePath: Assets.images.loan.path, title: 'Loan'),
    GridItem(imagePath: Assets.images.passbook.path, title: 'Edible Oil'),
  ];

  Future<List<int>> getServicesData() async {
    final apiUrl = '$baseUrl${getServices}AP';

    try {
      final jsonResponse = await http.get(Uri.parse(apiUrl));
      print('getServicesData jsonResponse: ${jsonResponse.body}');
      if (jsonResponse.statusCode == 200) {
        final response = jsonDecode(jsonResponse.body);
        List<dynamic> servicesList = response['listResult'];

        List<int> serviceTypeIds = servicesList
            .map((item) => ServiceModel.fromJson(item))
            .map((service) => service.serviceTypeId)
            .where((serviceTypeId) => serviceTypeId != 108)
            .map((id) => id!)
            .toList();
        print('serviceTypeIds: $serviceTypeIds');
        return serviceTypeIds;
      } else {
        throw Exception('Failed to get learning data');
      }
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
        SharedPreferences prefs = await SharedPreferences.getInstance();
        String language =
            prefs.getString(SharedPrefsKeys.language) ?? 'english';
        List<LearningModel> result =
            learningList.map((item) => LearningModel.fromJson(item)).toList();
        return getlearningString(language, result);
        /*  return learningList
            .map((item) => LearningModel.fromJson(item))
            .toList(); */
      } else {
        throw Exception('Failed to get services data');
      }
    } catch (error) {
      rethrow;
    }
  }

  Future<bool> showExitDialog(BuildContext context) async {
    return await showDialog<bool>(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('Exit App'),
              content: const Text('Are you sure you want to exit the app?'),
              actions: <Widget>[
                TextButton(
                  child: const Text('No'),
                  onPressed: () {
                    Navigator.of(context).pop(false); // Return false
                  },
                ),
                TextButton(
                  child: const Text('Yes'),
                  onPressed: () {
                    Navigator.of(context).pop(true); // Return true
                  },
                ),
              ],
            );
          },
        ) ??
        false;
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return WillPopScope(
      onWillPop: () async {
        bool shouldClose = await showExitDialog(context);
        if (shouldClose) {
          SystemNavigator.pop(); // Close the app
        }
        return false; // Prevent the default back button behavior
      },
      child: Scaffold(
        backgroundColor: const Color(0xfff4f3f1),
        body: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    menuSection(size),
                    servicesSection(size, 'Services'),
                    Container(
                      color: Colors.transparent,
                      height: 20,
                    ),
                    learningSection(size, 'Learnings',
                        backgroundColor: Colors.grey.shade300),
                  ],
                ),
              ),
            ),
            marqueeText(),
            banners(size),
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
          return SizedBox(
            // color: Colors.green,
            height: 25,
            child: Marquee(
                text: marquee[0].description!,
                style: CommonStyles.txSty_12b_f5),
          );
        } else if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        }
        return const CircularProgressIndicator.adaptive();
      },
    );
  }

  Widget banners(Size size) {
    return FutureBuilder(
      future: bannersAndMarqueeTextData,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          final banners = snapshot.data as List<BannerModel>;

          return CarouselSlider(
            options: CarouselOptions(
              height: size.height * 0.2,
              viewportFraction: 1.0, // Occupy full width
              autoPlay: true, // Enable auto-play
            ),
            items: banners.map((url) {
              return Builder(
                builder: (BuildContext context) {
                  return Container(
                    width:
                        MediaQuery.of(context).size.width, // Occupy full width
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        image: NetworkImage(url.imageName!),
                        fit: BoxFit
                            .fill, // Ensure the image covers the entire area
                      ),
                    ),
                  );
                },
              );
            }).toList(),
          );
        } else if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        }
        return const CircularProgressIndicator.adaptive();
      },
    );
  }

/* 
  Widget banners(Size size) {
    return FutureBuilder(
      future: bannersAndMarqueeTextData,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          final banners = snapshot.data as List<BannerModel>;

          return FlutterCarousel(
            options: CarouselOptions(
              height: size.height * 0.2,
              showIndicator: true,
              autoPlay: true,
              viewportFraction: 1,
              floatingIndicator: true,
              autoPlayCurve: Curves.linear,
              slideIndicator: const CircularSlideIndicator(
                slideIndicatorOptions: SlideIndicatorOptions(
                  indicatorBorderColor: Colors.grey,
                  currentIndicatorColor: CommonStyles.whiteColor,
                  indicatorRadius: 2,
                ),
              ),
            ),
            items: banners.map((item) {
              return Builder(
                builder: (BuildContext context) {
                  return SizedBox(
                    width: MediaQuery.of(context).size.width,
                    child: Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      elevation: 4,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Image.network(
                          item.imageName!,
                          width: MediaQuery.of(context)
                              .size
                              .width, // Set image width
                          fit: BoxFit.cover,
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            return const Center(
                              child: CircularProgressIndicator.adaptive(),
                            );
                          },
                        ),
                      ),
                    ),
                  );
                },
              );
            }).toList(),
          );
        } else if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        }
        return const CircularProgressIndicator.adaptive();
      },
    );
  }
 */
  Container servicesSection(Size size, String title, {Color? backgroundColor}) {
    return Container(
      color: backgroundColor,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            title,
            style: CommonStyles.txSty_16b_fb,
          ),
          const SizedBox(height: 10),
          FutureBuilder(
            future: servicesData,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const CircularProgressIndicator.adaptive();
              } else if (snapshot.hasError) {
                return Text('Error: ${snapshot.error}');
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
                    itemCount: serviceTypeIdList.length,
                    itemBuilder: (context, index) {
                      return serviceGridItem(index, serviceTypeIdList.length,
                          serviceTypeIdList[index]);
                    });
              }
            },
          ),
        ],
      ),
    );
  }

  Container learningSection(Size size, String title, {Color? backgroundColor}) {
    return Container(
      color: backgroundColor,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            title,
            style: CommonStyles.txSty_16b_fb,
          ),
          const SizedBox(height: 10),
          FutureBuilder(
            future: learningsData,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const CircularProgressIndicator.adaptive();
              } else if (snapshot.hasError) {
                return Text('Error: ${snapshot.error}');
              } else {
                final learningsList = snapshot.data as List<String?>;

                return GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    mainAxisSpacing: 0,
                    crossAxisSpacing: 0,
                    childAspectRatio: 1.5,
                  ),
                  itemCount: learningsList.length,
                  itemBuilder: (context, index) {
                    //MARK: Work
                    return learningGridItem(
                        index: index,
                        learningsList: learningsList.length,
                        title: learningsList[index]!);
                    // return learningGridItem(index, learningsList.length, learningsList[index]);
                  },
                );
              }
            },
          ),
        ],
      ),
    );
  }

  Container menuSection(Size size) {
    return Container(
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
          Text(
            'Views',
            style: CommonStyles.txSty_16b_fb
                .copyWith(color: CommonStyles.whiteColor),
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              viewOption(
                  size, Assets.images.ffbCollection.path, 'FFB Collection',
                  onTap: () {
                context.push(
                    context.namedLocation(Routes.ffbCollectionScreen.name));
              }),
              viewOption(size, Assets.images.passbook.path, 'Farmer Passbook',
                  onTap: () {
                context.push(
                    context.namedLocation(Routes.farmerPassbookScreen.name));
              }),
              viewOption(
                  size, Assets.images.mainVisit.path, 'Crop Maintenance Visits',
                  onTap: () {
                context.push(context
                    .namedLocation(Routes.cropMaintenanceVisitsScreen.name));
              }),
            ],
          ),
          const SizedBox(height: 20),
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
              Container(
                width: 120,
                height: 30,
                alignment: Alignment.center,
                child: Text(
                  title,
                  textAlign: TextAlign.center,
                  style: CommonStyles.txSty_12W_fb,
                ),
              ),
            ],
          ),
        )
      ]),
    );
  }

  Widget gridServiceItem(int serviceTypeId) {
    return Column(
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
          style: CommonStyles.txSty_12W_fb.copyWith(
              color: CommonStyles.blackColor, fontWeight: FontWeight.w600),
        ),
      ],
    );
  }

  Widget gridLearningItem(int index, String title) {
    return Column(
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
          style: CommonStyles.txSty_12W_fb.copyWith(
              color: CommonStyles.blackColor, fontWeight: FontWeight.w600),
        ),
      ],
    );
  }

  Widget serviceGridItem(int index, int gridSize, int serviceTypeId) {
    int totalColumns = 3;
    int totalRows = (gridSize / totalColumns).ceil();
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
      child: gridServiceItem(serviceTypeId),
    );
  }

  Widget learningGridItem(
      {required int index, required int learningsList, required String title}) {
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
        return Assets.images.mainVisit.path;
    }
  }

  String getServiceName(int serviceTypeId) {
    // 12 10 107 11 13 14 28 108 116
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
        return Assets.images.mainVisit.path;
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

  String getLearningName(int serviceTypeId) {
    // 12 10 107 11 13 14 28 108 116
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
        return Assets.images.mainVisit.path;
    }
  }

  List<String?> getlearningString(String language, List<LearningModel> result) {
    switch (language) {
      case 'english':
        return result.map((item) => item.name).toList();
      case 'telugu':
        return result.map((item) => item.teluguName).toList();
      case 'kannada':
        return result.map((item) => item.kannadaName).toList();

      default:
        return result.map((item) => item.updatedBy).toList();
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

class GridItem {
  final String imagePath;
  final String title;

  GridItem({required this.imagePath, required this.title});
}
