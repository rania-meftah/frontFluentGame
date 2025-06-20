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
  String? _serverResponse;

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
    await _recorder.stopRecorder();
    setState(() => _isRecording = false);

    final file = File(_filePath!);

    // 🔄 Attente de la création du fichier (max 1 sec)
    int tries = 0;
    while (!await file.exists() && tries < 10) {
      await Future.delayed(const Duration(milliseconds: 100));
      tries++;
    }

    if (!await file.exists()) {
      print("❌ Le fichier audio n’a pas été trouvé.");
      return;
    }

    final bytes = await file.readAsBytes();
    if (bytes.isEmpty) {
      print("❌ Fichier audio vide !");
      return;
    }

    // 🧪 Lecture locale pour debug
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
        print("✅ Envoi réussi !");
        print("📄 Réponse : $responseString");
        setState(() {
          _serverResponse = _formatResponse(responseString);
        });
      } else {
        print("❌ Erreur ${streamedResponse.statusCode}");
        print("📄 Détail : $responseString");
        setState(() {
          _serverResponse = "Erreur: ${streamedResponse.statusCode}";
        });
      }
    } catch (e) {
      print("🚨 Exception HTTP : $e");
      setState(() {
        _serverResponse = "Exception: $e";
      });
    }
  }

  String _formatResponse(String response) {
    try {
      final json = jsonDecode(response);
      final recognized = json['recognized'] ?? json['audio_phonetic'] ?? "";
      final target = json['target_phonetic'] ?? "";
      final score = (json['similarity'] ?? 0.0) * 100;

      return "🔊 Cible : $target\n🎙️ Reçu : $recognized\n🎯 Similarité : ${score.toStringAsFixed(1)}%";
    } catch (e) {
      return response;
    }
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
                            child: Image.network(
                              baseUrl + img,
                              errorBuilder:
                                  (_, __, ___) => const SizedBox.shrink(),
                            ),
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
                      if (_serverResponse != null)
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade200,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            _serverResponse!,
                            style: const TextStyle(fontSize: 16),
                          ),
                        ),
                      const SizedBox(height: 30),
                      ElevatedButton(
                        onPressed: () {
                          context.read<TestBloc>().add(NextWord());
                          setState(() {
                            _serverResponse = null;
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
