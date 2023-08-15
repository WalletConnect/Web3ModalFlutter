import 'package:flutter/material.dart';
import 'package:sign/utils/constants.dart';
import 'package:sign/utils/string_constants.dart';

class EventWidget extends StatelessWidget {
  const EventWidget({
    super.key,
    required this.title,
    required this.content,
  });

  final String title;
  final String content;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        title,
        style: StyleConstants.titleText,
      ),
      content: Text(content),
      actions: [
        TextButton(
          child: const Text(
            StringConstants.ok,
          ),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ],
    );
  }
}
