import 'package:akshaya_flutter/common_utils/common_styles.dart';
import 'package:akshaya_flutter/gen/assets.gen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_carousel_widget/flutter_carousel_widget.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
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

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
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
                    color: Colors.pinkAccent,
                    height: 20,
                  ),
                  servicesSection(size, 'Learnings'),
                ],
              ),
            ),
          ),
          banners(size),
        ],
      ),
    );
  }

  Container banners(Size size) {
    return Container(
      color: Colors.tealAccent,
      width: size.width,
      height: size.height * 0.2,
      child: FlutterCarousel(
        options: CarouselOptions(
          showIndicator: true,
          autoPlay: true,
          floatingIndicator: true,
          autoPlayCurve: Curves.linear,
          slideIndicator: const CircularSlideIndicator(
              slideIndicatorOptions: SlideIndicatorOptions(
            indicatorBorderColor: Colors.grey,
            currentIndicatorColor: CommonStyles.whiteColor,
            indicatorRadius: 2,
          )),
        ),
        items: bannersList.map((item) {
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
                      item,
                      height: 100,
                      fit: BoxFit.cover,
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return const Center(
                            child: CircularProgressIndicator.adaptive());
                      },
                    ),
                  ),
                ),
              );
            },
          );
        }).toList(),
      ),
    );
  }

  Column servicesSection(Size size, String title) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          title,
          style: CommonStyles.txSty_16b_fb,
        ),
        const SizedBox(height: 10),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            mainAxisSpacing: 0,
            crossAxisSpacing: 0,
          ),
          itemCount: gridItems.length,
          itemBuilder: (context, index) {
            return _buildGridItem(index, gridItems.length, gridItems[index]);
          },
        ),
      ],
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
                size,
                imagePath: 'assets/images/ffb_collection.png',
              ),
              viewOption(
                size,
                imagePath: 'assets/images/ffb_collection.png',
              ),
              viewOption(
                size,
                imagePath: 'assets/images/main_visit.png',
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Container(
                width: 120,
                alignment: Alignment.center,
                child: const Text(
                  'FFB Collection',
                  style: CommonStyles.txSty_12W_fb,
                ),
              ),
              Container(
                width: 120,
                alignment: Alignment.center,
                child: const Text(
                  'Farmer Passbook',
                  style: CommonStyles.txSty_12W_fb,
                ),
              ),
              Container(
                width: 120,
                alignment: Alignment.center,
                child: const Text(
                  'Crop Maintenance Visits',
                  style: CommonStyles.txSty_12W_fb,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget viewOption(Size size, {required String imagePath}) {
    return SizedBox(
      width: size.width / 3,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(
            imagePath,
            width: 35,
            height: 35,
            fit: BoxFit.cover,
          ),
          const SizedBox(height: 5),
        ],
      ),
    );
  }

  Widget gridItem(GridItem gridItem) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Image.asset(
          gridItem.imagePath,
          width: 35,
          height: 35,
          fit: BoxFit.cover,
        ),
        const SizedBox(height: 5),
        Text(
          gridItem.title,
          style: CommonStyles.txSty_12W_fb.copyWith(
              color: CommonStyles.blackColor, fontWeight: FontWeight.w600),
        ),
      ],
    );
  }

  Widget _buildGridItem(int index, int gridSize, GridItem item) {
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
      child: gridItem(item),
    );
  }
}

class GridItem {
  final String imagePath;
  final String title;

  GridItem({required this.imagePath, required this.title});
}
