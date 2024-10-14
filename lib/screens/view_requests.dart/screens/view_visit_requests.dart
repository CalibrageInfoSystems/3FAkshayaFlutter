// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:async';
import 'dart:convert';

import 'package:akshaya_flutter/common_utils/common_widgets.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import 'package:akshaya_flutter/common_utils/api_config.dart';
import 'package:akshaya_flutter/common_utils/common_styles.dart';
import 'package:akshaya_flutter/common_utils/custom_appbar.dart';
import 'package:akshaya_flutter/common_utils/shared_prefs_keys.dart';
import 'package:akshaya_flutter/common_utils/shimmer.dart';
import 'package:akshaya_flutter/gen/assets.gen.dart';
import 'package:akshaya_flutter/localization/locale_keys.dart';
import 'package:akshaya_flutter/models/view_visit_model.dart';
import 'package:akshaya_flutter/models/view_visit_more_details_model.dart';

import 'package:audioplayers/audioplayers.dart';
import 'package:shimmer/shimmer.dart';

class ViewVisitRequests extends StatefulWidget {
  const ViewVisitRequests({super.key});

  @override
  State<ViewVisitRequests> createState() => _ViewVisitRequestsState();
}

class _ViewVisitRequestsState extends State<ViewVisitRequests> {
  late Future<List<ViewVisitModel>> futureVisitRequest;

  double currentPositionDialog = 0;
  double totalDurationDialog = 0;
  bool isPlayingDialog = false;
  AudioPlayer audioPlayerDialog = AudioPlayer();

  @override
  void initState() {
    super.initState();
    futureVisitRequest = getVisitRequest();
  }

  Future<List<ViewVisitModel>> getVisitRequest() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final farmerCode = prefs.getString(SharedPrefsKeys.farmerCode);
    const apiUrl = '$baseUrl$getVisitRequestDetails';
    final requestBody = jsonEncode({
      "farmerCode": farmerCode,
      "fromDate": null,
      "toDate": null,
      "userId": null,
      "stateCode": null
    });
    final jsonResponse = await http.post(
      Uri.parse(apiUrl),
      headers: {
        'Content-Type': 'application/json',
      },
      body: requestBody,
    );

    if (jsonResponse.statusCode == 200) {
      Map<String, dynamic> response = jsonDecode(jsonResponse.body);
      if (response['listResult'] != null) {
        List<dynamic> list = response['listResult'];
        return list.map((item) => ViewVisitModel.fromJson(item)).toList();
      } else {
        throw Exception('No visit request found');
      }
    } else {
      throw Exception('Request failed with status: ${jsonResponse.statusCode}');
    }
  }

  Future<List<ViewVisitMoreDetailsModel>> getVisitRequestMoreDetails(
      String? requestId) async {
    final apiUrl = '$baseUrl$getVisitRequestCompleteDetails$requestId';

    final jsonResponse = await http.get(Uri.parse(apiUrl));
    print('getVisitRequestMoreDetails: $apiUrl');
    print('getVisitRequestMoreDetails: ${jsonResponse.body}');

    if (jsonResponse.statusCode == 200) {
      Map<String, dynamic> response = jsonDecode(jsonResponse.body);
      if (response['listResult'] != null) {
        List<dynamic> list = response['listResult'];
        return list
            .map((item) => ViewVisitMoreDetailsModel.fromJson(item))
            .toList();
      } else {
        throw Exception('No visit request found');
      }
    } else {
      throw Exception('Request failed with status: ${jsonResponse.statusCode}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
          title: tr(LocaleKeys.req_visit), actionIcon: const SizedBox()),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12).copyWith(top: 10),
        child: FutureBuilder(
          future: futureVisitRequest,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return shimmerLoading();
            } else if (snapshot.hasError) {
              return Text(
                  snapshot.error.toString().replaceFirst('Exception: ', ''),
                  style: CommonStyles.txStyF16CpFF6);
            } else {
              final visitRequests = snapshot.data as List<ViewVisitModel>;
              if (visitRequests.isEmpty) {
                return Center(
                  child: Text(
                    tr(LocaleKeys.no_req_found),
                    style: CommonStyles.txStyF16CpFF6,
                  ),
                );
              } else {
                return ListView.builder(
                  itemCount: visitRequests.length,
                  itemBuilder: (context, index) {
                    final request = visitRequests[index];

                    return visitRequest(
                      index,
                      request,
                      onPressed: () {
                        getVisitRequestMoreDetails(request.requestCode)
                            .then((value) {
                          // Images
                          List<ViewVisitMoreDetailsModel> imageList = value
                              .where((element) => element.fileTypeId == 36)
                              .toList();

                          // Audo
                          List<ViewVisitMoreDetailsModel> audioList = value
                              .where((element) => element.fileTypeId == 37)
                              .toList();

                          if (value.isNotEmpty) {
                            CommonStyles.errorDialog(
                              context,
                              errorMessage: 'errorMessage',
                              isHeader: false,
                              bodyBackgroundColor: Colors.white,
                              errorMessageColor: Colors.orange,
                              errorBodyWidget: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  MoreDetails(
                                    imagesList: imageList,
                                    audioFilePath: audioList,
                                  )
                                ],
                              ),
                            );
                          }
                        });
                      },
                    );
                  },
                );
              }
            }
          },
        ),
      ),
    );
  }

  Widget request(int index, ViewVisitModel request, {void Function()? onTap}) {
    final df = NumberFormat("#,##0.00");
    return CommonWidgets.viewTemplate(
      bgColor: index.isEven ? Colors.white : Colors.grey.shade200,
      onTap: onTap,
      child: Column(
        children: [
          if (request.requestCode != null)
            CommonWidgets.commonRow(
                label: tr(LocaleKeys.requestCodeLabel),
                data: '${request.requestCode}',
                dataTextColor: CommonStyles.primaryTextColor),
          if (request.plotCode != null)
            CommonWidgets.commonRow(
              label: tr(LocaleKeys.plot_code),
              data: '${request.plotCode}',
            ),
          if (request.palmArea != null)
            CommonWidgets.commonRow(
              label: tr(LocaleKeys.plot_size),
              data:
                  '${df.format(request.palmArea)} Ha (${df.format(request.palmArea! * 2.5)} Acre)',
            ),
          if (request.plotVillage != null)
            CommonWidgets.commonRow(
              label: tr(LocaleKeys.village),
              data: '${request.plotVillage}',
            ),
          if (request.reqCreatedDate != null)
            CommonWidgets.commonRow(
                label: tr(LocaleKeys.req_date),
                data: '${CommonStyles.formatDate(request.reqCreatedDate)}'),
          if (request.statusType != null)
            CommonWidgets.commonRow(
              label: tr(LocaleKeys.status),
              data: '${request.statusType}',
            ),
        ],
      ),
    );
  }

  Widget shimmerLoading() {
    return ShimmerWid(
      child: Container(
        width: double.infinity,
        height: 120.0,
        decoration: BoxDecoration(
          color: Colors.grey.shade300,
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }

  Container visitRequest(int index, ViewVisitModel visitRequest,
      {void Function()? onPressed}) {
    final df = NumberFormat("#,##0.00");
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
          color: index.isEven ? Colors.transparent : Colors.grey.shade200,
          borderRadius: BorderRadius.circular(5)),
      margin: const EdgeInsets.only(bottom: 10),
      child: Column(
        children: [
          plotDetailBox(
              label: tr(LocaleKeys.requestCodeLabel),
              data: '${visitRequest.requestCode}',
              dataTextColor: CommonStyles.primaryTextColor),
          plotDetailBox(
              label: tr(LocaleKeys.plot_code),
              data: '${visitRequest.plotCode}'),
          plotDetailBox(
            label: tr(LocaleKeys.plot_size),
            data:
                '${df.format(visitRequest.palmArea)} Ha (${df.format(visitRequest.palmArea! * 2.5)} Acre)',
          ),
          plotDetailBox(
              label: tr(LocaleKeys.village),
              data: '${visitRequest.plotVillage}'),
          plotDetailBox(
              label: tr(LocaleKeys.req_date),
              data: '${CommonStyles.formatDate(visitRequest.reqCreatedDate)}'),
          plotDetailBox(
              label: tr(LocaleKeys.status), data: '${visitRequest.statusType}'),
          const SizedBox(height: 5),
          GestureDetector(
            onTap: onPressed,
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 10),
              alignment: Alignment.center,
              decoration: const BoxDecoration(
                // borderRadius: BorderRadius.circular(10),
                color: CommonStyles.listOddColor,
              ),
              child: Text(
                'Click Here to See Complete Details',
                style: CommonStyles.txStyF16CbFF6.copyWith(
                    color: CommonStyles.viewMoreBtnTextColor, fontSize: 18),
                /*  style: TextStyle(
                    fontWeight: FontWeight.w600), */
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget plotDetailBox(
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
              ),
            ),
            Expanded(
                flex: 6,
                child: Text(
                  data,
                  style: CommonStyles.txF14Fw5Cb.copyWith(
                    color: dataTextColor,
                  ),
                )),
          ],
        ),
        const SizedBox(height: 8),
      ],
    );
  }
}

class MoreDetails extends StatefulWidget {
  final List<ViewVisitMoreDetailsModel> imagesList;
  final List<ViewVisitMoreDetailsModel> audioFilePath;

  const MoreDetails({
    super.key,
    required this.imagesList,
    required this.audioFilePath,
  });

  @override
  State<MoreDetails> createState() => _MoreDetailsState();
}

class _MoreDetailsState extends State<MoreDetails> {
  final AudioPlayer _audioPlayer = AudioPlayer();
  bool isPlaying = false;
  double currentPosition = 0;
  double totalDuration = 0;
  StreamSubscription<Duration>? _durationSubscription;
  StreamSubscription<Duration>? _positionSubscription;
  StreamSubscription<void>? _completeSubscription;

  @override
  void initState() {
    super.initState();
    if (widget.audioFilePath.isNotEmpty) {
      _initAudio();
    }
    print(
        'camp: ${widget.imagesList.length} | ${widget.audioFilePath.length} ');
  }
/* 
  Future<void> _initAudio() async {
    await _audioPlayer.setSourceUrl(widget.audioFilePath[0].fileLocation!);
    _durationSubscription = _audioPlayer.onDurationChanged.listen((duration) {
      if (mounted) {
        setState(() {
          totalDuration = duration.inSeconds.toDouble();
        });
      }
    });

    _positionSubscription = _audioPlayer.onPositionChanged.listen((position) {
      if (mounted) {
        setState(() {
          currentPosition = position.inSeconds.toDouble();
        });
      }
    });

    _completeSubscription = _audioPlayer.onPlayerComplete.listen((event) {
      if (mounted) {
        setState(() {
          isPlaying = false;
          currentPosition = 0;
        });
      }
    });
  }
 */

  Future<void> _initAudio() async {
    try {
      await _audioPlayer
          .setSource(UrlSource(widget.audioFilePath[0].fileLocation!));
      _durationSubscription = _audioPlayer.onDurationChanged.listen((duration) {
        if (mounted) {
          setState(() {
            totalDuration = duration.inSeconds.toDouble();
          });
        }
      });

      _positionSubscription = _audioPlayer.onPositionChanged.listen((position) {
        if (mounted) {
          setState(() {
            currentPosition = position.inSeconds.toDouble();
          });
        }
      });

      _completeSubscription = _audioPlayer.onPlayerComplete.listen((event) {
        if (mounted) {
          setState(() {
            isPlaying = false;
            currentPosition = 0;
          });
        }
      });
    } catch (e) {
      print('Error initializing audio: $e');
    }
  }

  /* Future<void> playOrPause() async {
    if (isPlaying) {
      await _audioPlayer.pause();
    } else {
      await _audioPlayer.play(UrlSource(widget.audioFilePath[0].fileLocation!));
    }
    if (mounted) {
      setState(() {
        isPlaying = !isPlaying;
      });
    }
  } */
  Future<void> playOrPause() async {
    try {
      if (isPlaying) {
        await _audioPlayer.pause();
      } else {
        await _audioPlayer
            .play(UrlSource(widget.audioFilePath[0].fileLocation!));
      }
      if (mounted) {
        setState(() {
          isPlaying = !isPlaying;
        });
      }
    } catch (e) {
      print('Error playing audio: $e');
    }
  }

  @override
  void dispose() {
    _durationSubscription?.cancel();
    _positionSubscription?.cancel();
    _completeSubscription?.cancel();
    _audioPlayer.dispose();
    super.dispose();
  }

  String formatTime(int seconds) {
    final minutes = (seconds / 60).floor();
    final remainingSeconds = seconds % 60;
    return '$minutes:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          if (widget.imagesList.isNotEmpty)
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: widget.imagesList.map((image) {
                return Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: CachedNetworkImage(
                    imageUrl: image.fileLocation!,
                    width: 100,
                    height: 100,
                    placeholder: (context, url) => Shimmer.fromColors(
                      baseColor: Colors.grey[300]!,
                      highlightColor: Colors.grey[100]!,
                      child: Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(5),
                          color: Colors.white,
                        ),
                      ),
                    ),
                    errorWidget: (context, url, error) => Image.asset(
                      Assets.images.icLogo.path,
                      fit: BoxFit.cover,
                    ),
                  ),
                );
              }).toList(),
            ),
          const SizedBox(height: 10),
          if (widget.audioFilePath.isNotEmpty)
            Row(
              children: [
                IconButton(
                  icon: Icon(
                    isPlaying
                        ? Icons.pause_circle_filled
                        : Icons.play_circle_filled,
                  ),
                  onPressed: playOrPause,
                ),
                if (totalDuration > 0)
                  Expanded(
                    child: Slider(
                      value: currentPosition,
                      min: 0,
                      max: totalDuration,
                      activeColor: CommonStyles.primaryTextColor,
                      onChanged: (value) {
                        setState(() {
                          currentPosition = value;
                        });
                        _audioPlayer.seek(Duration(seconds: value.toInt()));
                      },
                    ),
                  ),
                Text(formatTime(currentPosition.toInt())),
              ],
            ),
        ],
      ),
    );
  }
}
