// text_and_image_input_screen.dart
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_gemini/flutter_gemini.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lottie/lottie.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:flutter_tts/flutter_tts.dart';

class TextAndImageInputScreen extends StatefulWidget {
  const TextAndImageInputScreen({Key? key}) : super(key: key);

  @override
  _TextAndImageInputScreenState createState() =>
      _TextAndImageInputScreenState();
}

class _TextAndImageInputScreenState extends State<TextAndImageInputScreen> {
  final ImagePicker picker = ImagePicker();
  final controller = TextEditingController();
  final gemini = Gemini.instance;
  final FlutterTts flutterTts = FlutterTts();
  final SpeechToText _speech = SpeechToText();
  String? searchedText, result;
  bool _loading = false;
  bool isPlaying = false;

  Uint8List? selectedImage;

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

  Future<void> _getImage(ImageSource source) async {
    final XFile? photo = await picker.pickImage(source: source);

    if (photo != null) {
      photo.readAsBytes().then((value) => setState(() {
            selectedImage = value;
          }));
    }
  }

  Future<void> _showImageSourceOptions() async {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            ListTile(
              leading: const Icon(Icons.camera),
              title: const Text('Take a Photo'),
              onTap: () {
                Navigator.pop(context);
                _getImage(ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo),
              title: const Text('Choose from Gallery'),
              onTap: () {
                Navigator.pop(context);
                _getImage(ImageSource.gallery);
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Text and Image Input Screen'),
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
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Expanded(
                    flex: 2,
                    child: loading
                        ? Lottie.asset('assets/animation/animation.json')
                        : result != null
                            ? Markdown(
                                data: result!,
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 12),
                              )
                            : const Center(
                                child: Text('Search something!'),
                              ),
                  ),
                  if (selectedImage != null)
                    Expanded(
                      flex: 1,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(32),
                        child: Image.memory(
                          selectedImage!,
                          fit: BoxFit.cover,
                        ),
                      ),
                    )
                ],
              ),
            ),
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
                IconButton.filledTonal(
                  color: Colors.orange,
                  onPressed: _showImageSourceOptions, // Show options modal
                  icon: const Icon(Icons.add_a_photo, color: Colors.orange),
                ),
                IconButton(
                  onPressed: () {
                    if (controller.text.isNotEmpty && selectedImage != null) {
                      searchedText = controller.text;
                      controller.clear();
                      loading = true;
                
                      gemini
                          .textAndImage(
                              text: searchedText!, images: [selectedImage!])
                          .then((value) {
                        result = value?.content?.parts?.last.text;
                        loading = false;
                        if (isPlaying) {
                          speakResponse(result!);
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
                      speakResponse(result!);
                    } else {
                      stopSpeaking();
                    }
                  },
                  icon: Icon(
                    isPlaying ? Icons.stop : Icons.play_arrow,
                    color: Colors.red,
                  ),
                ),
                IconButton(
                  onPressed: () {
                    isPlaying = !isPlaying;
                    if (isPlaying) {
                      startListening();
                    } else {
                      stopListening();
                    }
                  },
                  icon: Icon(
                    isPlaying ? Icons.stop : Icons.mic,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
