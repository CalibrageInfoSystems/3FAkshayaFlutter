import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:akshaya_flutter/common_utils/api_config.dart';
import 'package:akshaya_flutter/common_utils/shared_prefs_keys.dart';
import 'package:akshaya_flutter/gen/assets.gen.dart';
import 'package:akshaya_flutter/screens/home_screen/Learning/Model/media_info_model.dart';
import 'package:akshaya_flutter/screens/home_screen/Learning/pdf_view_screen.dart';
import 'package:akshaya_flutter/screens/home_screen/Learning/vidio_player_screen.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
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
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final statecode = prefs.getString(SharedPrefsKeys.statecode);
    final apiUrl = '$baseUrl$encyclopedia${widget.index}/$statecode/true';
    // 'http://182.18.157.215/3FAkshaya/API/api/Encyclopedia/GetEncyclopediaDetails/1/AP/true';

    final jsonResponse = await http.get(Uri.parse(apiUrl));
/*     print('getMediaData: $apiUrl');
    print('getMediaData: ${jsonResponse.body}'); */

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
            /*   // Positioned gradient background
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
                      Color(0xFFDB5D4B),
                      Color(0xFFE39A63),
                      // endColor
                    ],
                  ),
                ),
              ),
            ), */

            Positioned.fill(
                child: Column(
              children: [
                Expanded(
                  child: Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Color(0xFFDB5D4B),
                          Color(0xFFE39A63),
                          // endColor
                        ],
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: Container(
                    color: CommonStyles.screenBgColor,
                    // color: CommonStyles.whiteColor,
                  ),
                ),
              ],
            )),

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
                scrolledUnderElevation: 0,
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
                  dividerColor: Colors.transparent,
                  labelStyle: CommonStyles.txStyF14CbFF6.copyWith(
                    fontWeight: FontWeight.w400,
                  ),
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
                    border: Border(
                        bottom: BorderSide(
                      color: Colors.redAccent,
                      width: 1.4,
                    )),
                    color: CommonStyles.primaryColor,
                  ),
                  tabs: widget.index == 1
                      ? [
                          /* Tab(text: tr(LocaleKeys.str_standard)),
                          Tab(text: tr(LocaleKeys.str_pdf)), 
                          Tab(text: tr(LocaleKeys.str_videos)),*/
                          Tab(
                            child: Text(
                              tr(LocaleKeys.str_standard),
                              textAlign: TextAlign.center,
                              overflow: TextOverflow.visible,
                              style: const TextStyle(
                                height: 1.2,
                              ),
                            ),
                          ),
                          Tab(
                            child: Text(
                              tr(LocaleKeys.str_pdf),
                              textAlign: TextAlign.center,
                              overflow: TextOverflow.visible,
                              style: const TextStyle(
                                height: 1.2,
                              ),
                            ),
                          ),
                          Tab(
                            child: Text(
                              tr(LocaleKeys.str_videos),
                              textAlign: TextAlign.center,
                              overflow: TextOverflow.visible,
                              style: const TextStyle(
                                height: 1.2,
                              ),
                            ),
                          ),
                        ]
                      : [
                          Tab(
                            child: Text(
                              tr(LocaleKeys.str_pdf),
                              textAlign: TextAlign.center,
                              overflow: TextOverflow.visible,
                              style: const TextStyle(
                                height: 1.2,
                              ),
                            ),
                          ),
                          Tab(
                            child: Text(
                              tr(LocaleKeys.str_videos),
                              textAlign: TextAlign.center,
                              overflow: TextOverflow.visible,
                              style: const TextStyle(
                                height: 1.2,
                              ),
                            ),
                          ),
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
            return Text(
              'Error: ${snapshot.error}',
              style: CommonStyles.txStyF16CpFF6,
            );
          } else {
            final data = snapshot.data as List<MediaInfo>;
            final mediaData = filterMediaData(data, 5);

            if (mediaData.isNotEmpty) {
              return MasonryGridView.count(
                crossAxisCount: 2,
                mainAxisSpacing: 8,
                crossAxisSpacing: 8,
                itemCount: mediaData.length,
                itemBuilder: (context, index) {
                  final fileUrl = mediaData[index].fileUrl;
                  final title = mediaData[index].name;
                  final description = mediaData[index].description;
                  return GestureDetector(
                      onTap: () {
                        // "https://www.antennahouse.com/hubfs/xsl-fo-sample/pdf/basic-link-1.pdf",
                        createFileOfPdfUrl(fileUrl!).then((item) => {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      PDFViewScreen(path: item.path),
                                ),
                              )
                            });
                      },
                      child: pdfTemplate(fileUrl, title, description));
                },
              );

              /*  return GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 8.0,
                  mainAxisSpacing: 8.0,
                  // mainAxisExtent: 260,
                  childAspectRatio: 1,
                ),
                itemCount: mediaData.length,
                itemBuilder: (context, index) {
                  final fileUrl = mediaData[index].fileUrl;
                  final title = mediaData[index].name;
                  final description = mediaData[index].description;
                  return GestureDetector(
                      onTap: () {
                        // "https://www.antennahouse.com/hubfs/xsl-fo-sample/pdf/basic-link-1.pdf",
                        createFileOfPdfUrl(fileUrl!).then((item) => {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      PDFViewScreen(path: item.path),
                                ),
                              )
                            });
                      },
                      child: pdfTemplate(fileUrl, title, description));
                },
              ); */
            } else {
              return Center(
                child: Text(
                  tr(LocaleKeys.no_pdfs),
                  style: CommonStyles.txStyF14CpFF6.copyWith(fontSize: 20),
                ),
              );
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
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Center(
            child: CachedNetworkImage(
              imageUrl: Assets.images.icPdf.path,
              placeholder: (context, url) => const CircularProgressIndicator(),
              errorWidget: (context, url, error) => Image.asset(
                width: 100,
                height: 100,
                Assets.images.icPdf.path,
                fit: BoxFit.cover,
              ),
            ),
          ),
          const SizedBox(height: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                '$title',
                // maxLines: 2,
                // overflow: TextOverflow.ellipsis,
                style: CommonStyles.txStyF16CbFF6.copyWith(
                  color: CommonStyles.dataTextColor,
                ),
              ),
              Text(
                '$description',
                // maxLines: 2,
                // overflow: TextOverflow.ellipsis,
                style: CommonStyles.txStyF14CbFF6.copyWith(
                  color: CommonStyles.dataTextColor,
                ),
              ),
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
            return Text(
              'Error: ${snapshot.error}',
              style: CommonStyles.txStyF16CpFF6,
            );
          } else {
            final data = snapshot.data as List<MediaInfo>;
            final mediaData = filterMediaData(data, 4);
            if (mediaData.isNotEmpty) {
              return GridView.builder(
                // padding: const EdgeInsets.all(8),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 1,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                  childAspectRatio: 16 / 11.2,
                  // childAspectRatio: 16 / 9,
                ),
                itemCount: mediaData.length,
                itemBuilder: (context, index) {
                  final mediaInfo = mediaData[index];

                  return Container(
                    // padding: const EdgeInsets.only(bottom: 40),
                    color: CommonStyles.screenBgColor2,
                    child: Stack(
                      children: [
                        YoutubePlayerBuilder(
                          player: YoutubePlayer(
                            bottomActions: [
                              const Spacer(),
                              IconButton(
                                icon: const Icon(
                                  Icons.zoom_out_map_outlined,
                                  size: 22,
                                  color: Colors.white,
                                ),
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => VideoPlayerScreen(
                                        fileUrl: mediaInfo.fileUrl,
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ],
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
                                  useHybridComposition: true),
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
                                      mediaInfo.name ?? '',
                                      style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                        Positioned(
                          bottom: 20,
                          left: 0,
                          right: 0,
                          child: Text(
                            mediaInfo.name ?? '',
                            style: CommonStyles.txStyF20CwFF6.copyWith(
                              color: CommonStyles.dataTextColor,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        Positioned(
                          bottom: 5,
                          left: 0,
                          right: 0,
                          child: Text(
                            mediaInfo.description ?? '',
                            style: CommonStyles.txStyF14CwFF6.copyWith(
                              color: CommonStyles.dataTextColor,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              );
            } else {
              return Center(
                  child: Text(tr(LocaleKeys.no_videos),
                      style:
                          CommonStyles.txStyF14CpFF6.copyWith(fontSize: 20)));
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
  State<Standard> createState() => _StandardState();
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
      _fetchFertilizers(selectedAge!);
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
        '$baseUrl$getRecommendationsByAge$age',
        // 'http://182.18.157.215/3FAkshaya/API/api/GetRecommendationsByAge/$age',
      ));
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
    return Column(
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
                    child: Center(
                      child: Text(
                        age.displayName,
                        textAlign: TextAlign.center,
                        overflow: TextOverflow.ellipsis,
                        style: CommonStyles.txStyF14CwFF6,
                      ),
                    ),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    selectedAge = value!;
                  });
                  _fetchFertilizers(value!);
                },
                dropdownStyleData: DropdownStyleData(
                  decoration: const BoxDecoration(
                    //    borderRadius: BorderRadius.circular(14),
                    borderRadius: BorderRadius.only(
                        bottomRight: Radius.circular(12),
                        bottomLeft: Radius.circular(12)),
                    color: CommonStyles.dropdownListBgColor,
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
                  padding: EdgeInsets.only(left: 20, right: 20),
                ),
              ),
            )),
        const SizedBox(height: 8),
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 12),
          child: Row(
            children: [
              Text(
                '${tr(LocaleKeys.notee)}  ',
                style: CommonStyles.txStyF14CbFF6,
              ),
              Text(
                tr(LocaleKeys.standard_note),
                style: CommonStyles.txStyF14CwFF6,
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Expanded(
          child: ListView.builder(
            itemCount: fertilizers.length,
            itemBuilder: (context, index) {
              final fertilizer = fertilizers[index];
              final isEvenIndex = index % 2 == 0;

              return standardBox(isEvenIndex, fertilizer);
            },
          ),
        ),
      ],
    );
  }

  Container standardBox(bool isEvenIndex, FertilizerRecommendation fertilizer) {
    return Container(
      padding: const EdgeInsets.all(12.0),
      color: isEvenIndex ? Colors.white : CommonStyles.listOddColor,
      margin: const EdgeInsets.symmetric(horizontal: 12).copyWith(bottom: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              SizedBox(
                width: 100, // Equal space for the label
                child: Text(tr(LocaleKeys.fertilizer),
                    style: CommonStyles.txStyF14CbFF6),
              ),
              Expanded(
                child: Text(
                  fertilizer.fertilizer,
                  style: CommonStyles.txStyF14CpFF6,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: 100,
                child: Text(
                  tr(LocaleKeys.quantity),
                  style: CommonStyles.txStyF14CbFF6,
                ),
              ),
              Expanded(
                child: Text('${fertilizer.quantity}',
                    style: CommonStyles.txStyF14CbFF6
                        .copyWith(color: CommonStyles.dataTextColor)),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: 100, // Equal space for the label
                child: Text(tr(LocaleKeys.remarks),
                    style: CommonStyles.txStyF14CbFF6),
              ),
              Expanded(
                child: Text(fertilizer.remarks,
                    style: CommonStyles.txStyF14CbFF6
                        .copyWith(color: CommonStyles.dataTextColor)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<List<AgeRecommendation>> fetchAgeRecommendations() async {
    final response = await http.get(Uri.parse(
      '$baseUrl$getRecommendationAges',
      // 'http://182.18.157.215/3FAkshaya/API/api/GetRecommendationAges',
    ));

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
