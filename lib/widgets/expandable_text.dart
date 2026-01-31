import 'package:flutter/material.dart';

class ExpandableText extends StatefulWidget {
  final String fullText;
  final int maxLines;

  const ExpandableText({
    super.key,
    required this.fullText,
    this.maxLines = 3,
  });

  @override
  State<ExpandableText> createState() => _ExpandableTextState();
}

class _ExpandableTextState extends State<ExpandableText> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.fullText,
          maxLines: _expanded ? null : widget.maxLines,
          overflow: _expanded ? TextOverflow.visible : TextOverflow.ellipsis,
        ),
        TextButton(
          onPressed: () {
            setState(() {
              _expanded = !_expanded;
            });
          },
          child: Text(_expanded ? 'สรุปย่อ' : 'ดูเพิ่มเติม'),
        ),
      ],
    );
  }
}