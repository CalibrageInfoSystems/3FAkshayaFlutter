import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:akshaya_flutter/common_utils/api_config.dart';
import 'package:akshaya_flutter/common_utils/common_styles.dart';
import 'package:akshaya_flutter/common_utils/custom_appbar.dart';
import 'package:akshaya_flutter/common_utils/custom_btn.dart';
import 'package:akshaya_flutter/gen/assets.gen.dart';
import 'package:akshaya_flutter/localization/locale_keys.dart';
import 'package:akshaya_flutter/models/plot_details_model.dart';
import 'package:akshaya_flutter/models/type_issue.dart';
import 'package:akshaya_flutter/screens/home_screen/screens/plot_selection_screen.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:just_audio/just_audio.dart';
import 'package:record/record.dart';
import 'package:http/http.dart' as http;

class VisitRequest extends StatefulWidget {
  final PlotDetailsModel plot;
  const VisitRequest({super.key, required this.plot});

  @override
  State<VisitRequest> createState() => _VisitRequestState();
}

class _VisitRequestState extends State<VisitRequest> {
  String? selectedTypeOfIssue;
  final List<Uint8List> _images = [];
  bool isImageList = false;

  TextEditingController commentsController = TextEditingController();
  final AudioPlayer _audioPlayer = AudioPlayer();
  final AudioRecorder _recorder = AudioRecorder();
  bool _isRecording = false;
  bool isAudioRecorded = false;
  String? audioFilePath;
  double _currentPosition = 0;
  double _totalDuration = 0;
  int _recordedSeconds = 0;
  Timer? _timer;
  int? selectedTypeOfIssueId;

  late Future<List<TypeIssue>> dropDownTypeIssues;

  @override
  void initState() {
    super.initState();
    dropDownTypeIssues = getTypeOfIssues();
  }

  Future<List<TypeIssue>> getTypeOfIssues() async {
    const apiUrl = '$baseUrl$typeOfIssues/10';

    final jsonResponse = await http.get(Uri.parse(apiUrl));
    // print('xxx: ${jsonResponse.body}');
    if (jsonResponse.statusCode == 200) {
      Map<String, dynamic> response = jsonDecode(jsonResponse.body);
      if (response['listResult'] != null) {
        List<dynamic> list = response['listResult'];
        List<TypeIssue> typeIssues =
            list.map((item) => TypeIssue.fromJson(item)).toList();
        return typeIssues;
      } else {
        throw Exception('list result is null');
      }
    } else {
      throw Exception('Request failed with status: ${jsonResponse.statusCode}');
    }
  }

  void validateFields() {
    FocusScope.of(context).unfocus();
    if (selectedTypeOfIssueId == null) {
      CommonStyles.errorDialog(
        context,
        errorMessage: 'Please select type of issue',
      );
    } else if (selectedTypeOfIssueId == 35 && commentsController.text.isEmpty) {
      CommonStyles.errorDialog(
        context,
        errorMessage: 'Please enter comments',
      );
    } else if (_images.isEmpty && audioFilePath == null) {
      setState(() {
        isImageList = true;
      });
      CommonStyles.errorDialog(
        context,
        errorMessage: tr(LocaleKeys.select_image),
      );
    } else {
      setState(() {
        isImageList = false;
      });

      submitVisitRequest(
        plot: widget.plot,
        reason: selectedTypeOfIssue,
        comments: commentsController.text,
      );
    }
  }

  List<Map<String, dynamic>>? convertImagesToBase64(List<Uint8List> images) {
    if (images.isEmpty) {
      return null;
    }

    List<Map<String, dynamic>> base64Images = images.map((image) {
      return {
        "createdDate": DateFormat('yyyy-MM-dd').format(DateTime.now()),
        "fileExtension": ".jpg",
        "fileName": base64Encode(image),
        "fileTypeId": 36,
        "id": 1,
        "isActive": true
      };
    }).toList();

    return base64Images;
  }

/*   List<String>? convertImagesToBase64(List<Uint8List> images) {
    if (images.isEmpty) {
      return null;
    }

    List<String> base64Images = images.map((image) {
      
      return base64Encode(image);
    }).toList();

    return base64Images;
  } */

//  String base64Audio = await convertAudioToBase64(_filePath!);
  Future<String> convertAudioToBase64(String filePath) async {
    File audioFile = File(filePath);
    List<int> audioBytes = await audioFile.readAsBytes();
    String base64Audio = base64Encode(audioBytes);

    return base64Audio;
  }

  Future<void> submitVisitRequest({
    required PlotDetailsModel plot,
    String? reason,
    String? comments,
  }) async {
    // List<String>? base64Images = convertImagesToBase64(_images);
    // String? base64Audio = await convertAudioToBase64(audioFilePath);
    String currentDate = DateFormat('yyyy-MM-dd').format(DateTime.now());

    const apiUrl = '$baseUrl$visitRequest';

    final requestBody = jsonEncode({
      "reason": reason,
      "requestHeader": {
        "clusterId": plot.clusterId,
        "comments": comments,
        "createdDate": currentDate,
        "farmerCode": plot.farmerCode,
        "farmerName": plot.farmerName,
        "id": null,
        "isFarmerRequest": true,
        "issueTypeId": selectedTypeOfIssueId,
        "palmArea": plot.palmArea,
        "plotCode": plot.plotcode,
        "plotVillage": plot.villageName,
        "reqCreatedDate": currentDate,
        "requestTypeId": 14,
        "stateCode": plot.stateCode,
        "stateName": plot.stateName,
        "statusTypeId": plot.statusTypeId,
        "updatedDate": currentDate,
        "yearofPlanting": plot.dateOfPlanting,
      },
      "visitRepo": [
        if (_images.isNotEmpty)
          ..._images.map((image) {
            return {
              "createdDate": currentDate,
              "fileExtension": ".jpg",
              "fileName": base64Encode(image),
              "fileTypeId": 36,
              "id": 1,
              "isActive": true
            };
          }),
        if (audioFilePath != null)
          {
            "createdDate": currentDate,
            "fileExtension": ".mp3",
            "fileName": await convertAudioToBase64(audioFilePath!),
            "fileTypeId": 37,
            "id": 1,
            "isActive": true
          }
      ],
    });

    final jsonResponse = await http.post(
      Uri.parse(apiUrl),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: requestBody,
    );

    print('xxx: $apiUrl');
    print('xxx: $requestBody');
    print('xxx: ${jsonResponse.body}');

    if (jsonResponse.statusCode == 200) {
      Map<String, dynamic> response = jsonDecode(jsonResponse.body);
      if (response['isSuccess']) {
        showSuccessDialog();
      } else {
        throw Exception('list result is null');
      }
    }
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    _recorder.dispose();
    _timer?.cancel();
    commentsController.dispose();
    super.dispose();
  }

  Future<void> _startRecording() async {
    final bool isPermissionGranted = await _recorder.hasPermission();
    if (!isPermissionGranted) {
      return;
    }

    final directory = await getApplicationDocumentsDirectory();
    String fileName = 'recording_${DateTime.now().millisecondsSinceEpoch}.m4a';
    audioFilePath = '${directory.path}/$fileName';

    const config = RecordConfig(
      encoder: AudioEncoder.aacLc,
      sampleRate: 44100,
      bitRate: 128000,
    );

    await _recorder.start(config, path: audioFilePath!);
    setState(() {
      _isRecording = true;
      isAudioRecorded = false;
      _recordedSeconds = 0;
    });

    _startTimer();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _recordedSeconds++;
      });
    });
  }

  Future<void> _stopRecording() async {
    await _recorder.stop().whenComplete(() {
      setState(() {
        _isRecording = false;
        isAudioRecorded = true;
      });
    });
    _timer?.cancel();
  }

  String _formatTime(int seconds) {
    final int minutes = seconds ~/ 60;
    final int remainingSeconds = seconds % 60;
    return '$minutes:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  Future<void> _playRecording() async {
    if (audioFilePath != null) {
      await _audioPlayer.setFilePath(audioFilePath!);
      _totalDuration = _audioPlayer.duration?.inSeconds.toDouble() ?? 0;
      _audioPlayer.play();

      _audioPlayer.positionStream.listen((position) {
        setState(() {
          _currentPosition = position.inSeconds.toDouble();
        });
      });
    }
  }

  String getSemanticsValue() {
    if (_totalDuration == 0) {
      return 'Loading';
    }
    return '${(_currentPosition / _totalDuration * 100).toStringAsFixed(0)}% completed';
  }

  void _deleteImage(int index) {
    setState(() {
      _images.removeAt(index);
    });
  }

  Future<void> mobileImagePicker(BuildContext context) async {
    final ImagePicker picker = ImagePicker();
    try {
      final List<XFile> pickedFiles = await picker.pickMultiImage();

      final List<Uint8List> newImages = await Future.wait(
          pickedFiles.map((file) async => await file.readAsBytes()));

      setState(() {
        if (_images.length + newImages.length <= 3) {
          _images.addAll(newImages);
        } else {
          final int remainingSpace = 3 - _images.length;
          _images.addAll(newImages.sublist(0, remainingSpace));
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'You can only select up to 3 images.',
                style: TextStyle(
                  color: Colors.grey,
                ),
              ),
            ),
          );
        }
      });
    } catch (e) {
      print('Error picking images: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: 'Visit Request'),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            CropPlotDetails(
              plotdata: widget.plot,
              index: 0,
              isIconVisible: false,
            ),
            // PlotItem(index: 0, plot: widget.plot),
            const SizedBox(height: 10),
            mainSection(),
          ],
        ),
      ),
    );
  }

  void showSuccessDialog() {
    CommonStyles.errorDialog(
      context,
      errorMessage: 'errorMessage',
      errorIcon: SvgPicture.asset(Assets.images.progressComplete.path),
      bodyBackgroundColor: Colors.white,
      errorLabel: 'errorLabel',
      errorMessageColor: Colors.orange,
      onPressed: () {
        /* Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => const HomeScreen(),
          ),
        ); */
      },
      errorBodyWidget: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(tr(LocaleKeys.visit_success),
                style: CommonStyles.txSty_14p_f5),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Expanded(
                  flex: 6,
                  child: Text(tr(LocaleKeys.issue_type),
                      style: CommonStyles.txSty_14b_f5),
                ),
                const Expanded(
                    flex: 1,
                    child: Text(':', style: CommonStyles.txSty_14b_f5)),
                Expanded(
                  flex: 5,
                  child: Text('$selectedTypeOfIssue',
                      style: CommonStyles.texthintstyle),
                ),
              ],
            ),
            const SizedBox(
              height: 5,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Expanded(
                  flex: 6,
                  child: Text(tr(LocaleKeys.issue_type),
                      style: CommonStyles.txSty_14b_f5),
                ),
                const Expanded(
                    flex: 1,
                    child: Text(':', style: CommonStyles.txSty_14b_f5)),
                Expanded(
                  flex: 5,
                  child: Text(commentsController.text,
                      style: CommonStyles.texthintstyle),
                ),
              ],
            ),
            const SizedBox(
              height: 10,
            ),
            //MARK: GridView
            if (_images.isNotEmpty)
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  mainAxisSpacing: 10,
                  crossAxisSpacing: 10,
                  childAspectRatio: 1.5,
                ),
                itemCount: _images.length,
                itemBuilder: (context, index) {
                  Uint8List image = _images[index];
                  return Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      image: DecorationImage(
                        image: MemoryImage(image),
                        fit: BoxFit.cover,
                      ),
                    ),
                  );
                },
              ),
            const SizedBox(
              height: 10,
            ),
            if (_images.isNotEmpty) const SizedBox(),
          ],
        ),
      ),
    );
  }

  Widget mainSection() {
    return Expanded(
      child: Container(
        decoration: BoxDecoration(
          color: CommonStyles.blackColorShade,
          borderRadius: BorderRadius.circular(10),
        ),
        padding: const EdgeInsets.all(12),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              RichText(
                text: TextSpan(
                  text: tr(LocaleKeys.issue_type),
                  style: CommonStyles.txSty_16w_fb,
                  children: const <TextSpan>[
                    TextSpan(
                      text: ' *',
                      style: TextStyle(color: Colors.red),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 5),
              FutureBuilder(
                future: dropDownTypeIssues,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator.adaptive(),
                    );
                  } else if (snapshot.hasError) {
                    return Center(
                      child: Text(
                        snapshot.error
                            .toString()
                            .replaceFirst('Exception: ', ''),
                      ),
                    );
                  } else {
                    // Casting the response to a list of TypeIssue
                    List<TypeIssue> dropdownItems =
                        snapshot.data as List<TypeIssue>;

                    return Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: Colors.white),
                      ),
                      width: double.infinity,
                      child: DropdownButtonHideUnderline(
                        child: ButtonTheme(
                          alignedDropdown: true,
                          child: DropdownButton<int>(
                            value: selectedTypeOfIssueId,
                            dropdownColor: CommonStyles.blackColorShade,
                            hint: const Text(
                              'Select Type of issue',
                              style: CommonStyles.txSty_14w_fb,
                            ),
                            items: dropdownItems.map((item) {
                              return DropdownMenuItem<int>(
                                value: item.typeCdId,
                                child: Text(
                                  '${item.desc}',
                                  style: CommonStyles.txSty_14w_fb,
                                ),
                              );
                            }).toList(),
                            onChanged: (int? typeIssueId) {
                              setState(() {
                                selectedTypeOfIssueId = typeIssueId;
                                TypeIssue item = dropdownItems
                                    .where(
                                        (item) => item.typeCdId == typeIssueId)
                                    .first;
                                selectedTypeOfIssue = item.desc;
                              });
                            },
                          ),
                        ),
                      ),
                    );
                  }
                },
              ),
              const SizedBox(height: 10),
              RichText(
                text: TextSpan(
                  text: tr(LocaleKeys.comments),
                  style: CommonStyles.txSty_16w_fb,
                  children: <TextSpan>[
                    if (selectedTypeOfIssueId == 35)
                      const TextSpan(
                        text: ' *',
                        style: TextStyle(color: Colors.red),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 5),
              TextField(
                controller: commentsController,
                style: CommonStyles.txSty_14w_fb,
                decoration: InputDecoration(
                  contentPadding: const EdgeInsets.only(left: 10),
                  border: outlineInputBorder(),
                  enabledBorder: outlineInputBorder(),
                  focusedBorder: outlineInputBorder(),
                ),
              ),
              const SizedBox(height: 10),
              /* const Text('Upload Image *', 
                          style: CommonStyles.txSty_16w_fb,), */
              RichText(
                text: TextSpan(
                  text: tr(LocaleKeys.image),
                  style: CommonStyles.txSty_16w_fb,
                  children: const <TextSpan>[
                    TextSpan(
                      text: ' *',
                      style: TextStyle(color: Colors.red),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 5),
              GestureDetector(
                onTap: () {
                  mobileImagePicker(context);
                },
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    borderRadius: const BorderRadius.all(Radius.circular(10)),
                    border: Border.all(color: Colors.white),
                  ),
                  child: const Icon(
                    Icons.image,
                    size: 40,
                    color: Colors.black54,
                  ),
                ),
              ),
              const SizedBox(height: 5),
              _images.isEmpty
                  ? (isImageList
                      ? const Text(
                          'No images selected.',
                          style: TextStyle(
                            color: Colors.grey,
                          ),
                        )
                      : const SizedBox())
                  //MARK: Images
                  : Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _images.map((image) {
                        final int index = _images.indexOf(image);
                        return Stack(
                          children: [
                            Container(
                              width: 100,
                              height: 100,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8),
                                image: DecorationImage(
                                  image: MemoryImage(image),
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                            Positioned(
                              top: 0,
                              right: 0,
                              child: GestureDetector(
                                onTap: () => _deleteImage(index),
                                child: Container(
                                  width: 24,
                                  height: 24,
                                  decoration: const BoxDecoration(
                                    color: Colors.red,
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.close,
                                    color: Colors.grey,
                                    size: 16,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        );
                      }).toList(),
                    ),
              const SizedBox(height: 10),
              if (isAudioRecorded)
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.play_arrow_rounded),
                      onPressed: !_isRecording ? _playRecording : null,
                    ),
                    if (_totalDuration > 0)
                      Expanded(
                        child: Row(
                          children: [
                            Expanded(
                              child: SeekBar(
                                progressColor: Colors.red,
                                backgroundColor: Colors.white,
                                value: _currentPosition,
                                min: 0,
                                max: _totalDuration,
                                onValueChanged: (value) {
                                  setState(() {
                                    _currentPosition = value.value;
                                  });
                                  _audioPlayer.seek(
                                    Duration(seconds: value.value.toInt()),
                                  );
                                },
                              ),
                            ),
                            Text(
                              _formatTime(_currentPosition.toInt()),
                              style: const TextStyle(color: Colors.black),
                            ),
                          ],
                        ),
                      ),
                    const SizedBox(width: 10),
                  ],
                ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    icon: Icon(
                      _isRecording ? Icons.pause : Icons.mic,
                      size: 100,
                      color: _isRecording ? Colors.red : Colors.blue,
                    ),
                    onPressed: _isRecording ? _stopRecording : _startRecording,
                  ),
                ],
              ),
              if (_isRecording)
                Text(
                  'Recording... ${_formatTime(_recordedSeconds)}',
                  style: const TextStyle(color: Colors.red),
                ),
              const SizedBox(height: 30),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CustomBtn(
                    label: tr(LocaleKeys.submit_req),
                    onPressed: validateFields,
                  ),
                ],
              ),

              /* ElevatedButton(
                onPressed: () {
                  if (_images.isEmpty) {
                    isImageList = true;
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          tr(LocaleKeys.select_product_toast),
                          style: const TextStyle(
                            color: Colors.grey,
                          ),
                        ),
                      ),
                    );
                  } else {
                    isImageList = false;
                  }
                  setState(() {});
                },
                child: Text(
                  tr(LocaleKeys.submit_req),
                ),
              ), */
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  OutlineInputBorder outlineInputBorder() {
    return const OutlineInputBorder(
      borderRadius: BorderRadius.all(Radius.circular(10)),
      borderSide: BorderSide(
        color: Colors.white,
      ),
    );
  }
}

class SeekBar extends StatelessWidget {
  const SeekBar({
    super.key,
    required this.value,
    required this.min,
    required this.max,
    required this.progressColor,
    required this.backgroundColor,
    this.onValueChanged,
    this.semanticsValue,
  });

  final double value;
  final double min;
  final double max;
  final Color progressColor;
  final Color backgroundColor;
  final void Function(SliderValue)? onValueChanged;
  final String? semanticsValue;

  @override
  Widget build(BuildContext context) {
    return Slider(
      value: value,
      min: min,
      max: max,
      activeColor: progressColor,
      inactiveColor: backgroundColor,
      onChanged: (value) {
        if (onValueChanged != null) {
          onValueChanged!(SliderValue(value));
        }
      },
      semanticFormatterCallback: (value) => semanticsValue ?? value.toString(),
    );
  }
}

class SliderValue {
  SliderValue(this.value);

  final double value;
}
