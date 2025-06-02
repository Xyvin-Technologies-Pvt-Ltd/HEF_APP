import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:hef/src/data/services/launch_url.dart';
import 'package:url_launcher/url_launcher.dart';

class ExpandableText extends StatefulWidget {
  final String text;
  const ExpandableText({super.key, required this.text});

  @override
  State<ExpandableText> createState() => _ExpandableTextState();
}

class _ExpandableTextState extends State<ExpandableText> {
  bool _isExpanded = false;

  List<InlineSpan> _buildTextSpans(String text) {
    final List<InlineSpan> spans = [];
  final RegExp urlRegExp = RegExp(
  r'(https?:\/\/[^\s\)]+)',
  caseSensitive: false,
);

    final matches = urlRegExp.allMatches(text);
    int start = 0;

    for (final match in matches) {
      if (match.start > start) {
        spans.add(TextSpan(
          text: text.substring(start, match.start),
        ));
      }

      final url = match.group(0)!;
      spans.add(TextSpan(
        text: url,
        style: const TextStyle(
          color: Colors.blue,
          decoration: TextDecoration.underline,
        ),
        recognizer: TapGestureRecognizer()
          ..onTap = () async {
            launchURL(url, launchMode: LaunchMode.externalApplication);
          },
      ));

      start = match.end;
    }

    if (start < text.length) {
      spans.add(TextSpan(text: text.substring(start)));
    }

    return spans;
  }

  @override
  Widget build(BuildContext context) {
    final defaultTextStyle = const TextStyle(fontSize: 14, color: Colors.black);
    final fullSpans = _buildTextSpans(widget.text);

    final TextPainter textPainter = TextPainter(
      text: TextSpan(children: fullSpans, style: defaultTextStyle),
      maxLines: 2,
      textDirection: TextDirection.ltr,
    )..layout(maxWidth: MediaQuery.of(context).size.width - 32);

    final isOverflowing = textPainter.didExceedMaxLines;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RichText(
          text: TextSpan(
            style: defaultTextStyle,
            children: _isExpanded
                ? fullSpans
                : _buildTextSpans(
                    widget.text.length > 100
                        ? widget.text.substring(0, 100) +
                            (isOverflowing ? '...' : '')
                        : widget.text,
                  ),
          ),
          maxLines: _isExpanded ? null : 2,
          overflow: _isExpanded ? TextOverflow.visible : TextOverflow.ellipsis,
        ),
        if (isOverflowing)
          GestureDetector(
            onTap: () => setState(() => _isExpanded = !_isExpanded),
            child: Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                _isExpanded ? 'Read less' : 'Read more',
                style: const TextStyle(color: Colors.blue),
              ),
            ),
          ),
      ],
    );
  }
}
