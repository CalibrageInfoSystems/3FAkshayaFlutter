import 'package:akshaya_flutter/common_utils/common_styles.dart';
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

  Container servicesSection(Size size, String title) {
    return Container(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(title, style: const TextStyle(fontSize: 20)),
          const SizedBox(height: 10),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              mainAxisSpacing: 0,
              crossAxisSpacing: 0,
            ),
            itemCount: 12,
            itemBuilder: (context, index) {
              return _buildGridItem(index, 12);
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
          const Text('data'),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              viewOption(size,
                  imagePath: 'assets/ffb_collection.png',
                  title: 'FFB Collection'),
              viewOption(size,
                  imagePath: 'assets/ffb_collection.png',
                  title: 'Farmer Passbook'),
              viewOption(size,
                  imagePath: 'assets/main_visit.png',
                  title: 'Crop Maintenance Visits'),
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

  Widget viewOption(Size size,
      {required String imagePath, required String title}) {
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

  Widget _buildGridItem(int index, int gridSize) {
    int totalColumns = 3;
    int totalRows = (gridSize / totalColumns).ceil();
    int currentRow = (index / totalColumns).floor() + 1;

    BorderSide borderSide = const BorderSide(color: Colors.black, width: 1.0);

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
      child: Center(
        child: Text(
          'Item ${index + 1}',
          style: const TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}
