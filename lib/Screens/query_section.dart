import 'package:flutter/material.dart';
import 'package:green_theme/sections/message.dart';
import 'package:green_theme/sections/new_message.dart';

class querySection extends StatelessWidget {
  const querySection({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Query Section',
          style: TextStyle(fontWeight: FontWeight.w900),
        ),
        centerTitle: true,
      ),
      body: const Padding(
        padding: EdgeInsets.only(left: 7, right: 7),
        child: Column(
          children: [Expanded(child: Messages( section: 'query',)),
           NewMessages(section: 'query',)
           ],
        ),
      ),
    );
  }
}