// ✅ lesson_page.dart complet avec BLoC, enregistrement, check pronunciation et lecture de l'enregistrement

import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:audioplayers/audioplayers.dart';

import '../../constants.dart';
import '../../models/word_model.dart';
import '../../repositories/lesson_repository.dart';
import '../../views/result_page.dart';
import '../../blocs/lesson/lesson_bloc.dart';
import '../../blocs/lesson/lesson_event.dart';
import '../../blocs/lesson/lesson_state.dart';

class LessonPage extends StatefulWidget {
  final String domainId;
  final int lessonNumber;
  final String level;

  const LessonPage({
    super.key,
    required this.domainId,
    required this.lessonNumber,
    required this.level,
  });

  @override
  State<LessonPage> createState() => _LessonPageState();
}

class _LessonPageState extends State<LessonPage> {
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
    await Permission.microphone.request();
    await _recorder.openRecorder();
  }

  Future<void> _startRecording() async {
    final dir = await getTemporaryDirectory();
    _filePath = '${dir.path}/lesson_audio.aac';
    await _recorder.startRecorder(
      toFile: _filePath,
      codec: Codec.aacMP4,
      bitRate: 128000,
      sampleRate: 16000,
    );
    setState(() => _isRecording = true);
  }

  Future<void> _stopAndSend(WordModel wordModel) async {
    await Future.delayed(const Duration(milliseconds: 500));
    await _recorder.stopRecorder();
    setState(() => _isRecording = false);

    final file = File(_filePath!);
    if (!await file.exists()) return;

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
    return RichText(
      text: TextSpan(
        children: List.generate(textRunes.length, (i) {
          return TextSpan(
            text: String.fromCharCode(textRunes[i]),
            style: TextStyle(
              color: incorrectIndices.contains(i) ? Colors.red : Colors.black,
              fontSize: 42,
              fontWeight: FontWeight.bold,
            ),
          );
        }),
      ),
    );
  }

  @override
  void dispose() {
    _recorder.closeRecorder();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create:
          (_) => LessonBloc(LessonRepository())..add(
            LoadLessonWords(widget.domainId, widget.lessonNumber, widget.level),
          ),
      child: Scaffold(
        body: SafeArea(
          child: BlocBuilder<LessonBloc, LessonState>(
            builder: (context, state) {
              if (state is LessonLoading)
                return const Center(child: CircularProgressIndicator());
              if (state is LessonLoaded) {
                final word = state.currentWord;
                final isSmall = MediaQuery.of(context).size.width < 600;

                return Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            word.word,
                            style: TextStyle(
                              fontSize: isSmall ? 32 : 42,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      if (_responseData != null)
                        buildColoredText(
                          _responseData!['text'],
                          _responseData!['incorrect'],
                        ),
                      const SizedBox(height: 20),
                      GestureDetector(
                        onTapDown: (_) => _startRecording(),
                        onTapUp: (_) => _stopAndSend(word),
                        child: Column(
                          children: [
                            Image.asset('assets/images/mic.png', width: 80),
                            const SizedBox(height: 8),
                            Text(
                              _isRecording
                                  ? "🎙️ Enregistrement..."
                                  : "Appuie et parle",
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
                            context.read<LessonBloc>().add(NextLessonWord());
                            setState(() {
                              _responseData = null;
                              _recordedFilePath = null;
                            });
                          },
                          child: Text(state.isLast ? "Terminer" : "Suivant"),
                        ),
                    ],
                  ),
                );
              }
              if (state is LessonFinished) {
                return Center(
                  child: ElevatedButton(
                    onPressed: () {
                      context.read<LessonBloc>().add(
                        FinishLessonEvent(
                          wordResults,
                          widget.domainId,
                          widget.lessonNumber,
                        ),
                      );
                    },
                    child: const Text("Valider la leçon"),
                  ),
                );
              }
              if (state is LessonResultState) {
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
              if (state is LessonError) {
                return Center(child: Text("Erreur : ${state.message}"));
              }
              return const SizedBox();
            },
          ),
        ),
      ),
    );
  }
}
