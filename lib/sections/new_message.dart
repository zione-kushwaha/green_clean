import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:speech_to_text/speech_to_text.dart';

class NewMessages extends StatefulWidget {
  const NewMessages({Key? key,required this.section});
 final String section;

  @override
  State<NewMessages> createState() => _NewMessagesState();
}

class _NewMessagesState extends State<NewMessages> {
  final controller = TextEditingController();
  final FlutterTts flutterTts = FlutterTts();
  final SpeechToText _speech = SpeechToText();
  bool _loading = false;
  bool isPlaying = false;
  // final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  bool get loading => _loading;
  set loading(bool set) => setState(() => _loading = set);

  Future<void> speakResponse(String response) async {
    await flutterTts.speak(response);
    setState(() {
      isPlaying = true;
    });
  }

  // Function to get the last message from Firestore
  Future<String> getLastMessage() async {
    final querySnapshot = await FirebaseFirestore.instance
        .collection(widget.section)
        .orderBy('createdAt', descending: true)
        .limit(1)
        .get();

    if (querySnapshot.docs.isNotEmpty) {
      return querySnapshot.docs.first['text'] as String;
    }

    return '';
  }

  // Function to play the last message
  Future<void> playLastMessage() async {
    final lastMessage = await getLastMessage();
    if (lastMessage.isNotEmpty) {
      await speakResponse(lastMessage);
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

  void sendMessage() async {
    FocusScope.of(context).unfocus();
    final user = FirebaseAuth.instance.currentUser;
    print(user!.uid);
    FirebaseFirestore.instance.collection(widget.section).add({
      'text': controller.text,
      'createdAt': Timestamp.now(),
      'userId': user.uid,
    });
    FirebaseFirestore.instance.collection(widget.section).add({
      'text': 'Our Admin will reach you soon',
      'createdAt': Timestamp.now(),
      'userId': 'admin',
    });
    controller.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Container(
        margin: const EdgeInsets.only(top: 8),
        padding: const EdgeInsets.all(8),
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
            IconButton(
              onPressed: () async {
                if (isPlaying) {
                  stopSpeaking();
                } else {
                  sendMessage();
                }
              },
              icon: const Icon(Icons.send_rounded),
            ),
            IconButton(
              onPressed: startListening,
              icon: const Icon(Icons.mic),
            ),
            IconButton(
              onPressed: () {
                isPlaying = !isPlaying;
                if (isPlaying) {
                  playLastMessage();
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
    );
  }
}