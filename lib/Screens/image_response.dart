import 'dart:io';
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lottie/lottie.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:flutter_tts/flutter_tts.dart';

class TextAndImageInputScreen extends StatefulWidget {
  const TextAndImageInputScreen({Key? key}) : super(key: key);

  @override
  _TextAndImageInputScreenState createState() => _TextAndImageInputScreenState();
}

class _TextAndImageInputScreenState extends State<TextAndImageInputScreen> {
  final ImagePicker picker = ImagePicker();
  final controller = TextEditingController();
  final FlutterTts flutterTts = FlutterTts();
  final SpeechToText _speech = SpeechToText();
  String? searchedText, result;
  bool _loading = false;
  bool isPlaying = false;
   String searchedData='';
 

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
    // Perform asynchronous operation
    Uint8List imageBytes = await photo.readAsBytes();

    // Update the state inside setState
    setState(() {
      selectedImage = imageBytes;
    });
  }
}

Future<void> _sendImage() async {
  if (selectedImage != null) {
    try {
      // Set loading state to true
      setState(() {
        _loading = true;
      });

      // Upload image to Firebase Storage
      final user = FirebaseAuth.instance.currentUser;
      final ref = FirebaseStorage.instance.ref().child('user_image').child('${user!.uid}.jpg');

      // Upload the file
      await ref.putData(selectedImage!).then((taskSnapshot) async {
        // Retrieve the download URL after the file is uploaded
        final url = await ref.getDownloadURL();

        // Store user data in Firestore with the download URL
        await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
          'message': controller.text, // Assuming user has a display name
          'email': user.email,
          'url': url,
        });

        // Set loading state to false
        setState(() {
          _loading = false;
        });
      });
    } on FirebaseException catch (e) {
      // Handle FirebaseException
      String errorMessage = 'Error occurred while uploading image';

      if (e.code == 'permission-denied') {
        errorMessage = 'Permission denied. Please check your Firebase Storage rules.';
      } else {
        errorMessage = 'Unexpected error: ${e.message}';
      }

      // Show error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorMessage),
          duration: const Duration(seconds: 2),
        ),
      );

      // Set loading state to false
      setState(() {
        _loading = false;
      });
    } catch (e) {
      // Handle other exceptions
      // Show error message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('An error occurred. Please try again.'),
        ),
      );

      // Set loading state to false
      setState(() {
        _loading = false;
      });
    }
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
  void initState() {
    super.initState();
    // Fetch data from Firestore when the widget is initialized
    _fetchData();
  }
   Future<void> _fetchData() async {
  // Retrieve image and response data from Firestore
  final user = FirebaseAuth.instance.currentUser;
  final querySnapshot = await FirebaseFirestore.instance
      .collection('users') // Assuming you are storing user data in the 'users' collection
      .doc(user!.uid)
      .get();

  if (querySnapshot.exists) {
    final data = querySnapshot.data() as Map<String, dynamic>;
    setState(() {
      selectedImage = null; 
      result = data['url']; 
      searchedData=data['message'];
    });
  }
}



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Image Response Screen'),
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
                            ? Image.network(result!,height: 300,width: 300,) // Display image from URL
                            : const Center(
                                child: Text('Search something!'),
                              ),),
                          
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
          if(searchedData!='')
              Text(searchedData),
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
                  onPressed: ()async {
                    if (controller.text.isNotEmpty && selectedImage != null) {
                      searchedText = controller.text;
                      loading = true;
                    await  _sendImage();
                      controller.clear();
                      
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
