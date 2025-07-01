// ... Imports initiaux
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:my_flutter_app/models/word_model.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:path_provider/path_provider.dart';

import '../../constants.dart';
import '../../repositories/test_repository.dart';
import '../../blocs/test/test_bloc.dart';
import '../../blocs/test/test_event.dart';
import '../../blocs/test/test_state.dart';
import 'result_page.dart';

class TestQuestionPage extends StatefulWidget {
  const TestQuestionPage({super.key});

  @override
  State<TestQuestionPage> createState() => _TestQuestionPageState();
}

class _TestQuestionPageState extends State<TestQuestionPage> {
  final FlutterSoundRecorder _recorder = FlutterSoundRecorder();
  bool _isRecording = false;
  String? _filePath;
  String? _recordedFilePath;
  Map<String, dynamic>? _responseData;
  List<Map<String, dynamic>> wordResults = [];

  @override
  void initState() {
    super.initState();
    _initRecorder();
  }

  Future<void> _initRecorder() async {
    var status = await Permission.microphone.request();
    if (status != PermissionStatus.granted) return;
    await _recorder.openRecorder();
  }

  Future<void> _startRecording() async {
    final dir = await getTemporaryDirectory();
    _filePath = '${dir.path}/audio.aac';
    await _recorder.startRecorder(
      toFile: _filePath,
      codec: Codec.aacMP4,
      bitRate: 128000,
      sampleRate: 16000,
    );
    setState(() => _isRecording = true);
  }

  Future<void> _stopAndSend(WordModel wordModel) async {
    await Future.delayed(const Duration(seconds: 1));
    await _recorder.stopRecorder();
    setState(() => _isRecording = false);

    final file = File(_filePath!);
    if (!await file.exists()) return;

    final bytes = await file.readAsBytes();
    if (bytes.length < 1000) return;

    final player = AudioPlayer();
    await player.play(DeviceFileSource(_filePath!));

    try {
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrl/api/check-pronunciation'),
      );
      request.fields['word'] = wordModel.word;
      request.files.add(
        await http.MultipartFile.fromPath(
          'audio',
          _filePath!,
          contentType: MediaType('audio', 'aac'),
        ),
      );

      var streamedResponse = await request.send();
      final responseString = await streamedResponse.stream.bytesToString();

      if (streamedResponse.statusCode == 200) {
        final formatted = _formatResponse(responseString);

        wordResults.add({
          'word': wordModel.id,
          'accuracy': formatted['correct_percent'],
        });

        setState(() {
          _responseData = formatted;
          _recordedFilePath = _filePath;
        });
      } else {
        setState(() => _responseData = null);
      }
    } catch (_) {
      setState(() => _responseData = null);
    }
  }

  Map<String, dynamic> _formatResponse(String response) {
    try {
      final json = jsonDecode(response);
      final incorrect = List<int>.from(json['incorrect_indices'] ?? []);
      final totalLetters = (json['target_text'] ?? '').length;
      final correctCount = totalLetters - incorrect.length;
      final correctPercent =
          totalLetters > 0 ? (correctCount / totalLetters * 100).round() : 0;

      return {
        'text': json['target_text'] ?? '',
        'phonetic': json['target_phonetic'] ?? '',
        'incorrect': incorrect,
        'correct_percent': correctPercent,
        'raw': response,
      };
    } catch (_) {
      return {
        'text': '',
        'phonetic': '',
        'incorrect': [],
        'correct_percent': 0,
        'raw': response,
      };
    }
  }

  RichText buildColoredText(String text, List<int> incorrectIndices) {
    final textRunes = text.runes.toList();
    List<InlineSpan> spans = [];

    for (int i = 0; i < textRunes.length; i++) {
      final isIncorrect = incorrectIndices.contains(i);
      spans.add(
        TextSpan(
          text: String.fromCharCode(textRunes[i]),
          style: TextStyle(
            color: isIncorrect ? Colors.red : Colors.black,
            fontSize: 42,
            fontWeight: FontWeight.bold,
          ),
        ),
      );
    }

    return RichText(text: TextSpan(children: spans));
  }

  Future<List<String>> _filterValidImages(List<String> imagePaths) async {
    List<String> validImages = [];
    for (String img in imagePaths) {
      final url = baseUrl + img;
      try {
        final res = await http.head(Uri.parse(url));
        if (res.statusCode == 200) validImages.add(img);
      } catch (_) {}
    }
    return validImages;
  }

  @override
  void dispose() {
    _recorder.closeRecorder();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => TestBloc(TestRepository())..add(LoadTestWords()),
      child: Scaffold(
        body: SafeArea(
          child: BlocBuilder<TestBloc, TestState>(
            builder: (context, state) {
              if (state is TestLoading)
                return const Center(child: CircularProgressIndicator());

              if (state is TestLoaded) {
                final word = state.currentWord;
                final player = AudioPlayer();

                return LayoutBuilder(
                  builder: (context, constraints) {
                    final isSmall = constraints.maxWidth < 600;

                    return SingleChildScrollView(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Column(
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    _responseData == null ? word.word : '',
                                    style: TextStyle(
                                      fontSize: isSmall ? 32 : 42,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  if (word.wordAudio?.isNotEmpty == true)
                                    GestureDetector(
                                      onTap:
                                          () async => await player.play(
                                            UrlSource(
                                              baseUrl + word.wordAudio!,
                                            ),
                                          ),
                                      child: Padding(
                                        padding: const EdgeInsets.only(
                                          left: 10,
                                        ),
                                        child: Image.asset(
                                          'assets/images/volume.png',
                                          width: isSmall ? 60 : 80,
                                          height: isSmall ? 60 : 80,
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                              if (_responseData == null)
                                const SizedBox(height: 10)
                              else
                                buildColoredText(
                                  _responseData!['text'],
                                  _responseData!['incorrect'],
                                ),
                              if (_responseData != null)
                                Padding(
                                  padding: const EdgeInsets.only(top: 10),
                                  child: Text(
                                    "✅ ${_responseData!['correct_percent']}% de lettres correctes",
                                    style: const TextStyle(
                                      fontSize: 18,
                                      color: Colors.green,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(height: 20),
                          FutureBuilder<List<String>>(
                            future: _filterValidImages(word.images ?? []),
                            builder: (context, snapshot) {
                              if (snapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return const CircularProgressIndicator();
                              }
                              final validImages = snapshot.data ?? [];
                              return Column(
                                children:
                                    validImages
                                        .map(
                                          (img) => Padding(
                                            padding: const EdgeInsets.symmetric(
                                              vertical: 8,
                                            ),
                                            child: Image.network(
                                              Uri.encodeFull(baseUrl + img),
                                              height: isSmall ? 250 : 350,
                                              fit: BoxFit.contain,
                                            ),
                                          ),
                                        )
                                        .toList(),
                              );
                            },
                          ),
                          const SizedBox(height: 20),
                          GestureDetector(
                            onTapDown: (_) => _startRecording(),
                            onTapUp: (_) => _stopAndSend(word),
                            child: Column(
                              children: [
                                Image.asset(
                                  'assets/images/mic.png',
                                  width: isSmall ? 80 : 100,
                                  height: isSmall ? 80 : 100,
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  _isRecording
                                      ? "🎙️ Enregistrement..."
                                      : "Appuie et parle",
                                  style: TextStyle(fontSize: isSmall ? 14 : 16),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 20),
                          if (_recordedFilePath != null)
                            GestureDetector(
                              onTap: () async {
                                final player = AudioPlayer();
                                await player.play(
                                  DeviceFileSource(_recordedFilePath!),
                                );
                              },
                              child: Image.asset(
                                'assets/images/play_pronunciation.png',
                                width: 60,
                                height: 60,
                              ),
                            ),
                          const SizedBox(height: 30),
                          if (_responseData != null)
                            ElevatedButton(
                              onPressed: () {
                                context.read<TestBloc>().add(NextWord());
                                setState(() {
                                  _responseData = null;
                                  _recordedFilePath = null;
                                });
                              },
                              child: Text(
                                state.isLast ? "Terminer" : "Suivant",
                                style: const TextStyle(fontSize: 18),
                              ),
                            ),
                        ],
                      ),
                    );
                  },
                );
              }

              if (state is TestFinished) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          "Test Terminé",
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 30),
                        Image.asset("assets/images/test.png", height: 200),
                        const SizedBox(height: 40),
                        ElevatedButton(
                          onPressed: () {
                            context.read<TestBloc>().add(
                              FinishTest(wordResults, "français"),
                            );
                          },
                          child: const Text(
                            "Continuer",
                            style: TextStyle(fontSize: 18),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }

              if (state is TestResultState) {
                Future.microtask(() {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder:
                          (_) => ResultPage(
                            score: state.score,
                            feedback: state.feedback,
                          ),
                    ),
                  );
                });
                return const Center(child: CircularProgressIndicator());
              }

              if (state is TestError) {
                return Center(child: Text("❌ Erreur : ${state.message}"));
              }

              return const SizedBox();
            },
          ),
        ),
      ),
    );
  }
}
