import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:akshaya_flutter/common_utils/api_config.dart';
import 'package:akshaya_flutter/gen/assets.gen.dart';
import 'package:akshaya_flutter/screens/home_screen/Learning/Model/media_info_model.dart';
import 'package:akshaya_flutter/screens/home_screen/Learning/pdf_view_screen.dart';
import 'package:akshaya_flutter/screens/home_screen/home_screen.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import '../../../common_utils/common_styles.dart';
import '../../../localization/locale_keys.dart';
import '../../main_screen.dart';
import 'Model/AgeRecommendation.dart';
import 'Model/FertilizerRecommendation.dart';
import 'package:path_provider/path_provider.dart';

class EncyclopediaActivity extends StatefulWidget {
  final String appBarTitle;
  final int index;

  const EncyclopediaActivity(
      {super.key, required this.appBarTitle, required this.index});

  @override
  State<EncyclopediaActivity> createState() => _EncyclopediaActivityState();
}

class _EncyclopediaActivityState extends State<EncyclopediaActivity> {
  Future<List<MediaInfo>> getMediaData() async {
    final apiUrl = '$baseUrl$encyclopedia${widget.index}/AP/true';
    // 'http://182.18.157.215/3FAkshaya/API/api/Encyclopedia/GetEncyclopediaDetails/1/AP/true';

    final jsonResponse = await http.get(Uri.parse(apiUrl));
    // print('getMediaData: ${jsonResponse.body}');

    if (jsonResponse.statusCode == 200) {
      final Map<String, dynamic> response = json.decode(jsonResponse.body);
      if (response['listResult'] != null) {
        List<dynamic> result = response['listResult'];
        return result.map((item) => MediaInfo.fromJson(item)).toList();
      }
      throw Exception('No media data found');
    } else {
      throw Exception('Failed to load media data');
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: widget.index == 1 ? 3 : 2,
      child: Scaffold(
        body: Stack(
          children: [
            // Positioned gradient background
            Positioned(
              top: -90,
              bottom: 450, // Adjust as needed
              left: -60,
              right: -60,
              child: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter, // 90 degrees
                    end: Alignment.bottomCenter,
                    colors: [
                      //Color(0xffDB5D4B),.
                      Color(0xFFDB5D4B),
                      Color(0xFFE39A63), // startColor
                      // endColor
                    ],
                  ),
                ),
              ),
            ),

            // Main content with AppBar and TabBar
            Scaffold(
              backgroundColor: Colors
                  .transparent, // To make the scaffold background transparent
              appBar: AppBar(
                backgroundColor: Colors
                    .transparent, // Transparent background for gradient to show through
                leading: GestureDetector(
                  onTap: () {
                    Navigator.pop(context);
                  },
                  child: Image.asset(Assets.images.icLeft.path),
                ),
                elevation: 0,
                title: Text(
                  widget.appBarTitle,
                  style: CommonStyles.txSty_14black_f5.copyWith(
                    color: CommonStyles.whiteColor,
                  ),
                ),
                actions: [
                  IconButton(
                    icon: const Icon(
                      Icons.home,
                      color: Colors.white,
                    ),
                    onPressed: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const MainScreen(),
                        ),
                      );
                    },
                  ),
                ],
                bottom: TabBar(
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
                  tabs: widget.index == 1
                      ? [
                          Tab(text: tr(LocaleKeys.str_standard)),
                          Tab(text: tr(LocaleKeys.str_pdf)),
                          Tab(text: tr(LocaleKeys.str_videos)),
                        ]
                      : [
                          Tab(text: tr(LocaleKeys.str_pdf)),
                          Tab(text: tr(LocaleKeys.str_videos)),
                        ],
                ),
              ),

              body: TabBarView(
                children: widget.index == 1
                    ? [
                        const Standard(),
                        PdfTabView(pdfData: getMediaData()),
                        VideoTabView(vidioData: getMediaData()),
                      ]
                    : [
                        PdfTabView(pdfData: getMediaData()),
                        VideoTabView(vidioData: getMediaData()),
                      ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class PdfTabView extends StatefulWidget {
  final Future<List<MediaInfo>> pdfData;
  const PdfTabView({super.key, required this.pdfData});

  @override
  State<PdfTabView> createState() => _PdfTabViewState();
}

class _PdfTabViewState extends State<PdfTabView> {
  List<MediaInfo> filterMediaData(List<MediaInfo> mediaData, int mediaTypeId) {
    return mediaData.where((media) => media.fileTypeId == mediaTypeId).toList();
  }

  String pdfPath = "";

  @override
  void initState() {
    super.initState();

    /*  createFileOfPdfUrl().then((f) {
      setState(() {
        pdfPath = f.path;
      });
    }); */
  }

  Future<File> createFileOfPdfUrl(String pdfpath) async {
    Completer<File> completer = Completer();
    print("Start download file from internet!");
    try {
      final url = pdfpath;
      final filename = url.substring(url.lastIndexOf("/") + 1);
      var request = await HttpClient().getUrl(Uri.parse(url));
      var response = await request.close();
      var bytes = await consolidateHttpClientResponseBytes(response);
      var dir = await getApplicationDocumentsDirectory();
      print("Download files");
      print("${dir.path}/$filename");
      File file = File("${dir.path}/$filename");

      await file.writeAsBytes(bytes, flush: true);
      completer.complete(file);
    } catch (e) {
      throw Exception('Error parsing asset file!');
    }

    return completer.future;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: FutureBuilder(
        future: widget.pdfData,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Text('Error: ${snapshot.error}');
          } else {
            final data = snapshot.data as List<MediaInfo>;
            final mediaData = filterMediaData(data, 5);

            if (mediaData.isNotEmpty) {
              return GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 10.0,
                  mainAxisSpacing: 10.0,
                  mainAxisExtent: 260,
                  childAspectRatio: 8 / 6,
                ),
                itemCount: mediaData.length,
                itemBuilder: (context, index) {
                  final imagePath = mediaData[index].fileUrl;
                  final title = mediaData[index].name;
                  final description = mediaData[index].description;
                  /* return MediaView(
                    imagePath: imagePath,
                    title: title,
                    description: description); */

                  return GestureDetector(
                      onTap: () {
                        createFileOfPdfUrl(imagePath!
                                // "https://www.antennahouse.com/hubfs/xsl-fo-sample/pdf/basic-link-1.pdf",
                                )
                            .then((item) => {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          PDFViewScreen(path: item.path),
                                    ),
                                  )
                                });
                      },
                      child: pdfTemplate(imagePath, title, description));
                },
              );
            } else {
              return Center(child: Text(tr(LocaleKeys.no_pdfs)));
            }
          }
        },
      ),
    );
  }

  Widget pdfTemplate(String? imagePath, String? title, String? description) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: CommonStyles.whiteColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Expanded(
              child: Center(
            child: CachedNetworkImage(
              imageUrl: '$imagePath',
              placeholder: (context, url) => const CircularProgressIndicator(),
              errorWidget: (context, url, error) => Image.asset(
                Assets.images.icLogo.path,
                fit: BoxFit.cover,
              ),
            ),
          )),
          const SizedBox(height: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('$title'),
              Text('$description'),
            ],
          ),
        ],
      ),
    );
  }
}

class VideoTabView extends StatefulWidget {
  final Future<List<MediaInfo>> vidioData;
  const VideoTabView({super.key, required this.vidioData});

  @override
  State<VideoTabView> createState() => _VideoTabViewState();
}

class _VideoTabViewState extends State<VideoTabView> {
  late YoutubePlayerController _controller;
  late PlayerState playerState;
  late YoutubeMetaData videoMetaData;
  double volume = 100;
  bool muted = false;
  bool isPlayerReady = false;

  @override
  void initState() {
    super.initState();
    _controller = YoutubePlayerController(
      initialVideoId: '',
      flags: const YoutubePlayerFlags(
        mute: false,
        autoPlay: true,
        disableDragSeek: false,
        loop: false,
        isLive: false,
        forceHD: false,
        enableCaption: true,
      ),
    )..addListener(listener);
    videoMetaData = const YoutubeMetaData();
    playerState = PlayerState.unknown;
  }

  void listener() {
    if (isPlayerReady && mounted && !_controller.value.isFullScreen) {
      setState(() {
        playerState = _controller.value.playerState;
        videoMetaData = _controller.metadata;
      });
    }
  }

  @override
  void deactivate() {
    _controller.pause();
    super.deactivate();
  }

  List<MediaInfo> filterMediaData(List<MediaInfo> mediaData, int mediaTypeId) {
    return mediaData
        .where((media) => media.fileTypeId == mediaTypeId)
        .map((media) {
      return media.copyWith(
        fileUrl: YoutubePlayer.convertUrlToId(media.fileUrl ?? ''),
      );
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: FutureBuilder(
        future: widget.vidioData,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Text('Error: ${snapshot.error}');
          } else {
            final data = snapshot.data as List<MediaInfo>;
            print('yyy: ${data.length}');
            final mediaData = filterMediaData(data, 4);
            if (mediaData.isNotEmpty) {
              return GridView.builder(
                padding: const EdgeInsets.all(8),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 1,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                  childAspectRatio: 16 / 9,
                ),
                itemCount: mediaData.length,
                itemBuilder: (context, index) {
                  final mediaInfo = mediaData[index];

                  return YoutubePlayerBuilder(
                    player: YoutubePlayer(
                      controller: YoutubePlayerController(
                        initialVideoId: mediaInfo.fileUrl!,
                        flags: const YoutubePlayerFlags(
                          mute: false,
                          autoPlay: false,
                          disableDragSeek: false,
                          loop: false,
                          isLive: false,
                          forceHD: false,
                          enableCaption: true,
                        ),
                      ),
                      showVideoProgressIndicator: true,
                      progressIndicatorColor: Colors.blueAccent,
                    ),
                    builder: (context, player) {
                      return Card(
                        child: Column(
                          children: [
                            Expanded(child: player),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                '${mediaInfo.name}',
                                style: const TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.bold),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  );
                },
              );
            } else {
              return Center(child: Text(tr(LocaleKeys.no_videos)));
            }
          }
        },
      ),
    );
  }

  Padding videoTemplate(String? imagePath, String? title, String? description) {
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: CommonStyles.whiteColor,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Expanded(
                child: Center(
              child: CachedNetworkImage(
                imageUrl: '$imagePath',
                placeholder: (context, url) =>
                    const CircularProgressIndicator(),
                errorWidget: (context, url, error) => Image.asset(
                  Assets.images.icLogo.path,
                  fit: BoxFit.cover,
                ),
              ),
            )),
            const SizedBox(height: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('$title'),
                Text('$description'),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class Standard extends StatefulWidget {
  const Standard({super.key});

  @override
  _StandardState createState() => _StandardState();
}

class _StandardState extends State<Standard> {
  String? selectedAge;
  List<AgeRecommendation> ages = [];
  List<FertilizerRecommendation> fertilizers = [];

  @override
  void initState() {
    super.initState();
    _fetchAges();
    if (ages.isNotEmpty) {
      selectedAge = ages.first.displayName;
      _fetchFertilizers(
          selectedAge!); // Fetch fertilizers for the default selected age
    }
  }

  Future<void> _fetchAges() async {
    try {
      final fetchedAges = await fetchAgeRecommendations();
      setState(() {
        ages = fetchedAges;
        if (ages.isNotEmpty) {
          selectedAge = ages.first.displayName; // Set the first item by default
          _fetchFertilizers(
              selectedAge!); // Fetch data for the default selection
        }
      });
    } catch (e) {
      print('Error fetching ages: $e');
    }
  }

  Future<void> _fetchFertilizers(String age) async {
    try {
      final response = await http.get(Uri.parse(
          'http://182.18.157.215/3FAkshaya/API/api/GetRecommendationsByAge/$age'));
      if (response.statusCode == 200) {
        final List<dynamic> jsonData = json.decode(response.body);

        // Map JSON data to Dart model
        final fetchedFertilizers = jsonData
            .map((item) => FertilizerRecommendation.fromJson(item))
            .toList();

        setState(() {
          fertilizers = fetchedFertilizers;
        });
      } else {
        throw Exception('Failed to load fertilizers');
      }
    } catch (e) {
      print('Error fetching fertilizers: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
              alignment: Alignment.topCenter,
              margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.white),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton2<String>(
                  iconStyleData: const IconStyleData(
                    icon: Icon(
                      Icons.keyboard_arrow_down_rounded,
                      color: Colors.white,
                    ),
                  ),
                  isExpanded: true,
                  value: selectedAge,
                  items: ages.map((age) {
                    return DropdownMenuItem<String>(
                      value: age.displayName,
                      child: Text(age.displayName,
                          style: CommonStyles.txSty_12W_fb),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      selectedAge = value!;
                    });
                    _fetchFertilizers(value!);
                  },
                  dropdownStyleData: DropdownStyleData(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(14),
                      color: Colors.black87,
                    ),
                    offset: const Offset(0, 0),
                    scrollbarTheme: ScrollbarThemeData(
                      radius: const Radius.circular(40),
                      thickness: WidgetStateProperty.all<double>(6),
                      thumbVisibility: WidgetStateProperty.all<bool>(true),
                    ),
                  ),
                  menuItemStyleData: const MenuItemStyleData(
                    height: 40,
                    padding: EdgeInsets.symmetric(horizontal: 20),
                  ),
                ),
              )),
          const SizedBox(height: 8), // Spacing between dropdown and note
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 12),
            child: RichText(
              text: const TextSpan(
                text: 'Note: ',
                style: CommonStyles.text18orangeeader,
                children: [
                  TextSpan(
                    text: 'Quantity in gm/plant/year',
                    style: CommonStyles.text14white,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: ListView.builder(
              itemCount: fertilizers.length,
              itemBuilder: (context, index) {
                final fertilizer = fertilizers[index];
                final isEvenIndex = index % 2 == 0;

                return Container(
                  margin: const EdgeInsets.symmetric(
                      horizontal: 12), // Adding margin
                  child: Card(
                    color: isEvenIndex
                        ? Colors.white
                        : Colors.grey.shade300, // Alternate colors
                    child: Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const SizedBox(
                                width: 100, // Equal space for the label
                                child: Text('Fertilizer',
                                    style: CommonStyles.txSty_14b_f6),
                              ),
                              Expanded(
                                child: Text(
                                  fertilizer.fertilizer,
                                  style: CommonStyles.text18orangeeader,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              const SizedBox(
                                width: 100, // Equal space for the label
                                child: Text(
                                  'Quantity',
                                  style: CommonStyles.txSty_14b_f6,
                                ),
                              ),
                              Expanded(
                                child: Text('${fertilizer.quantity}',
                                    style: CommonStyles.txSty_14b_f5),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              const SizedBox(
                                width: 100, // Equal space for the label
                                child: Text('Remarks',
                                    style: CommonStyles.txSty_14b_f6),
                              ),
                              Expanded(
                                child: Text(fertilizer.remarks,
                                    style: CommonStyles.txSty_14b_f5),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Future<List<AgeRecommendation>> fetchAgeRecommendations() async {
    final response = await http.get(Uri.parse(
        'http://182.18.157.215/3FAkshaya/API/api/GetRecommendationAges'));

    if (response.statusCode == 200) {
      List<dynamic> jsonData = json.decode(response.body)['listResult'];
      return jsonData.map((data) => AgeRecommendation.fromJson(data)).toList();
    } else {
      throw Exception('Failed to load age recommendations');
    }
  }

  Future<List<FertilizerRecommendation>> fetchFertilizerRecommendations(
      String age) async {
    final response = await http.get(Uri.parse(
        'http://182.18.157.215/3FAkshaya/API/api/GetRecommendationsByAge/Year 2'));

    if (response.statusCode == 200) {
      List<dynamic> jsonData = json.decode(response.body)['listResult'];
      return jsonData
          .map((data) => FertilizerRecommendation.fromJson(data))
          .toList();
    } else {
      throw Exception('Failed to load fertilizer recommendations');
    }
  }
}

class MediaView extends StatelessWidget {
  final String? imagePath;
  final String? title;
  final String? description;
  const MediaView(
      {super.key,
      required this.title,
      required this.description,
      this.imagePath});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: CommonStyles.whiteColor,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Expanded(
                child: Center(
              child: CachedNetworkImage(
                imageUrl: '$imagePath',
                placeholder: (context, url) =>
                    const CircularProgressIndicator(),
                errorWidget: (context, url, error) => Image.asset(
                  Assets.images.icLogo.path,
                  fit: BoxFit.cover,
                ),
              ),
            )),
            const SizedBox(height: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('$title'),
                Text('$description'),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class Videos extends StatelessWidget {
  const Videos({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text('Content for Tab 3'),
    );
  }
}
