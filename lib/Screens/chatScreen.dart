// ignore: file_names
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_gemini/flutter_gemini.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import '../providers/themeProvider.dart';

// ignore: camel_case_types

class SectionItem {
  final int index;
  final String title;
  final Widget widget;

  SectionItem(this.index, this.title, this.widget);
}

class chat_screens extends StatefulWidget {
  const chat_screens({super.key});

  @override
  State<chat_screens> createState() => _chat_screensState();
}

class _chat_screensState extends State<chat_screens> {
  int _selectedItem = 0;

  final _sections = <SectionItem>[
    SectionItem(0, 'text', const SectionTextInput()),
    SectionItem(1, 'textAndImage', const SectionTextAndImageInput()),
    SectionItem(2, 'chat', const SectionChat()),
  ];
bool temp =false;
  @override
  Widget build(BuildContext context) {
    final provider=Provider.of<ThemeProvider>(context);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: temp?Colors.orange:const Color.fromARGB(255, 77, 74, 74),
        title: const Text('AI Project',style: TextStyle(color: Colors.white),),
        centerTitle: true,
        actions: [
          IconButton(onPressed: (){
            setState(() {
              temp=!temp;
              provider.toggleTheme();
            });
          }, icon: Icon(temp?Icons.light_mode:Icons.dark_mode)),
         
          PopupMenuButton<int>(
            initialValue: _selectedItem,
            onSelected: (value) => setState(() => _selectedItem = value),
            itemBuilder: (context) => _sections.map((e) {
              return PopupMenuItem<int>(value: e.index, child: Text(e.title));
            }).toList(),
            child: const Icon(Icons.more_vert_rounded,color: Colors.white,),
          )
        ],
      ),
      body: IndexedStack(
        index: _selectedItem,
        children: _sections.map((e) => e.widget).toList(),
      ),
    );
  }
}

/// -------------------------------------------------------------
class SectionTextInput extends StatefulWidget {
  const SectionTextInput({super.key});

  @override
  State<SectionTextInput> createState() => _SectionTextInputState();
}

class _SectionTextInputState extends State<SectionTextInput> {
  final controller = TextEditingController();
  final gemini = Gemini.instance;
  String? searchedText, result;
  bool _loading = false;

  bool get loading => _loading;

  set loading(bool set) => setState(() => _loading = set);

  @override
  Widget build(BuildContext context) {
    return Column(
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
              child: Text('search: $searchedText')),
        Expanded(
            child: loading
                ? Lottie.asset('assets/animation/animation.json')
                : result != null
                    ? Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Markdown(data: result!),
                      )
                    : const Center(child: Text('Search something!'))),
        Card(
          margin: const EdgeInsets.all(12),
          child: Row(
            children: [
              Expanded(
                  child: TextField(
                controller: controller,
                decoration: const InputDecoration(
                  contentPadding: EdgeInsets.symmetric(horizontal: 12),
                  hintText: 'write something ...',
                  border: InputBorder.none,
                ),
                onTapOutside: (event) =>
                    FocusManager.instance.primaryFocus?.unfocus(),
              )),
              Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: IconButton(
                    onPressed: () {
                      if (controller.text.isNotEmpty) {
                        searchedText = controller.text;
                        controller.clear();
                        loading = true;

                        gemini.text(searchedText!).then((value) {
                          result = value?.content?.parts?.last.text;
                          loading = false;
                        });
                      }
                    },
                    icon: const Icon(Icons.send_rounded)),
              )
            ],
          ),
        )
      ],
    );
  }
}

/// -----------------------------------------------------
class SectionTextAndImageInput extends StatefulWidget {
  const SectionTextAndImageInput({super.key});

  @override
  State<SectionTextAndImageInput> createState() =>
      _SectionTextAndImageInputState();
}

class _SectionTextAndImageInputState extends State<SectionTextAndImageInput> {
  final ImagePicker picker = ImagePicker();
  final controller = TextEditingController();
  final gemini = Gemini.instance;
  String? searchedText, result;
  bool _loading = false;

  Uint8List? selectedImage;

  bool get loading => _loading;

  set loading(bool set) => setState(() => _loading = set);

  @override
  Widget build(BuildContext context) {
    return Column(
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
              child: Text('search: $searchedText')),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Expanded(
                  flex: 2,
                  child: loading
                      ? Lottie.asset('lib/assets/animation.json')
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
                  hintText: 'write something ...',
                  border: InputBorder.none,
                ),
                onTapOutside: (event) =>
                    FocusManager.instance.primaryFocus?.unfocus(),
              )),
              Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: IconButton.filledTonal(
                    color: Colors.orange,
                    onPressed: () async {
                      // Capture a photo.
                      final XFile? photo =
                          await picker.pickImage(source: ImageSource.camera);

                      if (photo != null) {
                        photo.readAsBytes().then((value) => setState(() {
                              selectedImage = value;
                            }));
                      }
                    },
                    icon: const Icon(Icons.camera,color: Colors.orange,)),
              ),
              Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: IconButton(
                    onPressed: () {
                      if (controller.text.isNotEmpty && selectedImage != null) {
                        searchedText = controller.text;
                        controller.clear();
                        loading = true;

                        gemini
                            .textAndImage(
                                text: searchedText!,images: [selectedImage!])
                            .then((value) {
                          result = value?.content?.parts?.last.text;
                          loading = false;
                        });
                      }
                    },
                    icon: const Icon(Icons.send_rounded)),
              ),
            ],
          ),
        )
      ],
    );
  }
}

/// ---------------------------------------------------
class SectionChat extends StatefulWidget {
  const SectionChat({super.key});

  @override
  State<SectionChat> createState() => _SectionChatState();
}

class _SectionChatState extends State<SectionChat> {
  final controller = TextEditingController();
  final gemini = Gemini.instance;
  bool _loading = false;

  bool get loading => _loading;

  set loading(bool set) => setState(() => _loading = set);
  final List<Content> chats = [];

  @override
  Widget build(BuildContext context) {
    return Column(
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
                : const Center(child: Text('Search something!'))),
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
                  hintText: 'write something ...',
                  border: InputBorder.none,
                ),
                onTapOutside: (event) =>
                    FocusManager.instance.primaryFocus?.unfocus(),
              )),
              Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: IconButton(
                    onPressed: () {
                      if (controller.text.isNotEmpty) {
                        final searchedText = controller.text;
                        chats.add(Content(
                            role: 'user', parts: [Parts(text: searchedText)]));
                        controller.clear();
                        loading = true;

                        gemini.chat(chats).then((value) {
                          chats.add(Content(
                              role: 'model',
                              parts: [Parts(text: value?.output)]));
                          loading = false;
                        });
                      }
                    },
                    icon: const Icon(Icons.send_rounded)),
              )
            ],
          ),
        )
      ],
    );
  }

  Widget chatItem(BuildContext context, int index) {
    final Content content = chats[index];

    return Card(
      elevation: 0,
      color:
          content.role == 'model' ? const Color.fromARGB(255, 112, 94, 38) : Colors.transparent,
      child: Padding(
        
        padding: const EdgeInsets.all(10.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(content.role ?? 'role'),
            Markdown(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                data:
                    content.parts?.lastOrNull?.text ?? 'cannot generate data!'),
          ],
        ),
      ),
    );
  }
}