import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:path_provider/path_provider.dart';

import '../../constants.dart';
import '../../repositories/test_repository.dart';
import '../../blocs/test/test_bloc.dart';
import '../../blocs/test/test_event.dart';
import '../../blocs/test/test_state.dart';

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

  @override
  void initState() {
    super.initState();
    _initRecorder();
  }

  Future<void> _initRecorder() async {
    var status = await Permission.microphone.request();
    if (status != PermissionStatus.granted) {
      print("❌ Permission micro refusée");
    }
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

  Future<void> _stopAndSend(String word) async {
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
      request.fields['word'] = word;
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
        setState(() {
          _responseData = _formatResponse(responseString);
          _recordedFilePath = _filePath;
        });
      } else {
        setState(() {
          _responseData = null;
        });
      }
    } catch (e) {
      setState(() {
        _responseData = null;
      });
    }
  }

  Map<String, dynamic> _formatResponse(String response) {
    try {
      final json = jsonDecode(response);
      final incorrect = List<int>.from(json['incorrect_indices'] ?? []);
      final totalPhonemes =
          (json['target_phonetic'] ?? '').replaceAll(' ', '').length;
      final correctCount = totalPhonemes - incorrect.length;
      final correctPercent =
          totalPhonemes > 0 ? (correctCount / totalPhonemes * 100).round() : 0;

      return {
        'text': json['target_text'] ?? '',
        'phonetic': json['target_phonetic'] ?? '',
        'incorrect': incorrect,
        'correct_percent': correctPercent,
        'raw': response,
      };
    } catch (e) {
      return {
        'text': '',
        'phonetic': '',
        'incorrect': [],
        'correct_percent': 0,
        'raw': response,
      };
    }
  }

  List<int> getIncorrectLetterIndices(
    String text,
    String phonetic,
    List<int> incorrectPhonemeIndices,
  ) {
    final phonemes = phonetic.replaceAll(' ', '').split('');
    final textRunes = text.runes.toList();
    List<int> incorrectLetterIndices = [];

    int minLength =
        textRunes.length < phonemes.length ? textRunes.length : phonemes.length;

    for (int i = 0; i < minLength; i++) {
      if (incorrectPhonemeIndices.contains(i)) {
        incorrectLetterIndices.add(i);
      }
    }
    return incorrectLetterIndices;
  }

  RichText buildColoredText(
    String text,
    String phonetic,
    List<int> incorrectPhonemeIndices,
  ) {
    final textRunes = text.runes.toList();
    final incorrectLetterIndices = getIncorrectLetterIndices(
      text,
      phonetic,
      incorrectPhonemeIndices,
    );

    List<InlineSpan> spans = [];
    for (int i = 0; i < textRunes.length; i++) {
      final isIncorrect = incorrectLetterIndices.contains(i);
      spans.add(
        TextSpan(
          text: String.fromCharCode(textRunes[i]),
          style: TextStyle(
            color: isIncorrect ? Colors.red : Colors.black,
            fontSize: 32,
            fontWeight: FontWeight.bold,
          ),
        ),
      );
    }

    return RichText(text: TextSpan(children: spans));
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
        appBar: AppBar(
          title: const Text("Test de Prononciation"),
          centerTitle: true,
        ),
        body: SafeArea(
          child: BlocBuilder<TestBloc, TestState>(
            builder: (context, state) {
              if (state is TestLoading) {
                return const Center(child: CircularProgressIndicator());
              } else if (state is TestLoaded) {
                final word = state.currentWord;
                final player = AudioPlayer();

                return SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            word.word,
                            style: const TextStyle(
                              fontSize: 42,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(width: 20),
                          if (word.wordAudio != null &&
                              word.wordAudio!.isNotEmpty)
                            GestureDetector(
                              onTap: () async {
                                await player.play(
                                  UrlSource(baseUrl + word.wordAudio!),
                                );
                              },
                              child: Image.asset(
                                'assets/images/volume.png',
                                width: 80,
                                height: 80,
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 30),
                      if ((word.images ?? []).isNotEmpty)
                        ...word.images!.map(
                          (img) => Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Image.network(baseUrl + img),
                          ),
                        ),
                      const SizedBox(height: 20),
                      GestureDetector(
                        onTapDown: (_) => _startRecording(),
                        onTapUp: (_) => _stopAndSend(word.word),
                        child: Column(
                          children: [
                            Image.asset(
                              'assets/images/mic.png',
                              width: 80,
                              height: 80,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              _isRecording
                                  ? "🎙️ Enregistrement..."
                                  : "Appuie et parle",
                              style: const TextStyle(fontSize: 16),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 30),
                      if (_responseData != null)
                        Column(
                          children: [
                            Text(
                              "✅ ${_responseData!['correct_percent']}% de phonèmes corrects",
                              style: const TextStyle(
                                fontSize: 18,
                                color: Colors.green,
                              ),
                            ),
                            const SizedBox(height: 10),
                            buildColoredText(
                              _responseData!['text'],
                              _responseData!['phonetic'],
                              _responseData!['incorrect'],
                            ),
                            const SizedBox(height: 20),
                            if (_recordedFilePath != null)
                              ElevatedButton.icon(
                                icon: const Icon(Icons.play_arrow),
                                label: const Text(
                                  "Écouter votre prononciation",
                                ),
                                onPressed: () async {
                                  final player = AudioPlayer();
                                  await player.play(
                                    DeviceFileSource(_recordedFilePath!),
                                  );
                                },
                              ),
                          ],
                        ),
                      const SizedBox(height: 30),
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
              } else if (state is TestFinished) {
                return const Center(child: Text("✅ Test terminé !"));
              } else if (state is TestError) {
                return Center(child: Text("❌ Erreur: ${state.message}"));
              } else {
                return const SizedBox();
              }
            },
          ),
        ),
      ),
    );
  }
}
