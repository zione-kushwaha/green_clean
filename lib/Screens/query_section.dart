import 'package:flutter/material.dart';
import 'package:flutter_gemini/flutter_gemini.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:lottie/lottie.dart';
import 'package:speech_to_text/speech_to_text.dart';

class TextInputScreen extends StatefulWidget {
  const TextInputScreen({Key? key}) : super(key: key);

  @override
  _TextInputScreenState createState() => _TextInputScreenState();
}

class _TextInputScreenState extends State<TextInputScreen> {
  final controller = TextEditingController();
  final gemini = Gemini.instance;
  final FlutterTts flutterTts = FlutterTts();
  final SpeechToText _speech = SpeechToText();
  String? searchedText, result;
  bool _loading = false;
  bool isPlaying = false;

  bool get loading => _loading;

  Future<void> speakResponse() async {
    if (result != null) {
      await flutterTts.speak(result!);
      setState(() {
        isPlaying = true;
      });
    }
  }

  Future<void> stopSpeaking() async {
    await flutterTts.stop();
    setState(() {
      isPlaying = false;
    });
  }

  Future<void> startListening() async {
    if (await _speech.initialize()) {
      if (_speech.isListening) {
        await _speech.stop();
      } else {
        await _speech.listen(
          onResult: (result) {
            controller.text = result.recognizedWords;
          },
        );
      }
      setState(() {
        isPlaying = _speech.isListening;
      });
    }
  }

  Future<void> stopListening() async {
    await _speech.stop();
    setState(() {
      isPlaying = false;
    });
  }

  void search() {
    if (controller.text.isNotEmpty) {
      searchedText = controller.text;
      controller.clear();
      loading = true;

      gemini.text(searchedText!).then((value) {
        result = value?.content?.parts?.last.text;
        loading = false;
        if (isPlaying) {
          stopSpeaking();
        } else {
          speakResponse();
        }
      });
    }
  }

  set loading(bool set) => setState(() => _loading = set);

  @override
  void initState() {
    super.initState();
    flutterTts.setLanguage("en-US");
    flutterTts.setPitch(1.0);
    flutterTts.setVolume(1.0);
  }

  @override
  void dispose() {
    super.dispose();
    _speech.cancel();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Query Section'),
      ),
      body: Column(
        children: [
          if (searchedText != null)
            MaterialButton(
              color: Colors.orange,
              onPressed: () {
                setState(() {
                  searchedText = null;
                  result = null;
                });
              },
              child: Text('Search: $searchedText'),
            ),
          Expanded(
            child: loading
                ? Lottie.asset('assets/animation/animation.json')
                : result != null
                    ? Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Markdown(data: result!),
                      )
                    : const Center(child: Text('Search something!')),
          ),
          Card(
            margin: const EdgeInsets.all(12),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: controller,
                    decoration: const InputDecoration(
                      contentPadding: EdgeInsets.symmetric(horizontal: 12),
                      hintText: 'Write something ...',
                      border: InputBorder.none,
                    ),
                    onTapOutside: (event) =>
                        FocusManager.instance.primaryFocus?.unfocus(),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: Row(
                    children: [
                      IconButton(
                        onPressed: startListening,
                        icon: const Icon(Icons.mic),
                      ),
                      IconButton(
                        onPressed: search,
                        icon:const Icon(
                           Icons.send,
                        ),
                      ),
                      IconButton(
                        onPressed: () {
                         isPlaying=!isPlaying;
                         if(isPlaying){
                          speakResponse();
                         }
                         else{
                          stopSpeaking();
                         }
                        },
                        icon: Icon(
                          isPlaying ? Icons.stop : Icons.play_arrow,
                          color: Colors.red,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
