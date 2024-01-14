import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:flutter_gemini/flutter_gemini.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:speech_to_text/speech_to_text.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({Key? key}) : super(key: key);

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final controller = TextEditingController();
  final gemini = Gemini.instance;
  final FlutterTts flutterTts = FlutterTts();
  final SpeechToText _speech = SpeechToText();
  bool _loading = false;
  bool isPlaying = false;
  List<Content> chats = [];

  bool get loading => _loading;

  set loading(bool set) => setState(() => _loading = set);

  Future<void> speakResponse(String response) async {
    await flutterTts.speak(response);
    setState(() {
      isPlaying = true;
    });
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chat Screen'),
      ),
      body: Column(
        children: [
          Expanded(
            child: chats.isNotEmpty
                ? Align(
                    alignment: Alignment.bottomCenter,
                    child: SingleChildScrollView(
                      reverse: true,
                      child: ListView.builder(
                        itemBuilder: chatItem,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: chats.length,
                        reverse: false,
                      ),
                    ),
                  )
                : const Center(child: Text('Start a conversation!')),
          ),
          if (loading) const CircularProgressIndicator(),
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
                        onPressed: () {
                          if (isPlaying) {
                            stopSpeaking();
                          } else {
                            final searchedText = controller.text;
                            chats.add(Content(
                                role: 'user',
                                parts: [Parts(text: searchedText)]));
                            controller.clear();
                            loading = true;

                            gemini.chat(chats).then((value) {
                              final modelResponse = value?.output ?? '';
                              chats.add(Content(
                                  role: 'model', parts: [Parts(text: modelResponse)]));
                              loading = false;
                              if (isPlaying) {
                                speakResponse(modelResponse);
                              }
                            });
                          }
                        },
                        icon: const Icon(Icons.send_rounded),
                      ),
                      IconButton(
                        onPressed: () {
                          isPlaying = !isPlaying;
                          if (isPlaying) {
                            final lastModelResponse = chats.last.parts?.last.text ?? '';
                            speakResponse(lastModelResponse);
                          } else {
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

  Widget chatItem(BuildContext context, int index) {
    final Content content = chats[index];

    return Card(
      elevation: 0,
      color: content.role == 'model'
          ? Colors.white
          : Colors.transparent,
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(content.role ?? 'Role'),
            Markdown(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              data: content.parts?.lastOrNull?.text ?? 'Cannot generate data!',
            ),
          ],
        ),
      ),
    );
  }
}
