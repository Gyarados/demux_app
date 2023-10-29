import 'package:demux_app/app/pages/chat/utils/copy_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_highlighter/themes/atom-one-dark.dart';
import 'package:flutter_markdown_selectionarea/flutter_markdown.dart';
import 'package:markdown/markdown.dart' as md;
import 'package:google_fonts/google_fonts.dart';
import 'package:highlight/highlight.dart' show highlight, Node;

class SelectableHighlightView extends StatelessWidget {
  /// The original code to be highlighted
  final String source;

  /// Highlight language
  ///
  /// It is recommended to give it a value for performance
  ///
  /// [All available languages](https://github.com/predatorx7/highlight/tree/master/highlight/lib/languages)
  final String? language;

  /// Highlight theme
  ///
  /// [All available themes](https://github.com/predatorx7/highlight/blob/master/flutter_highlighter/lib/themes)
  final Map<String, TextStyle> theme;

  /// Padding
  final EdgeInsetsGeometry? padding;

  /// Text styles
  ///
  /// Specify text styles such as font family and font size
  final TextStyle? textStyle;
  final double textScaleFactor;
  final bool isCodeBlock;

  SelectableHighlightView(
    String input, {
    this.language,
    this.theme = const {},
    this.padding,
    this.textStyle,
    int tabSize = 8, // TODO: https://github.com/flutter/flutter/issues/50087
    required this.textScaleFactor,
    required this.isCodeBlock,
  }) : source = input.replaceAll('\t', ' ' * tabSize);

  List<TextSpan> _convert(List<Node> nodes) {
    List<TextSpan> spans = [];
    var currentSpans = spans;
    List<List<TextSpan>> stack = [];

    _traverse(Node node) {
      if (node.value != null) {
        currentSpans.add(node.className == null
            ? TextSpan(text: node.value)
            : TextSpan(text: node.value, style: theme[node.className!]));
      } else if (node.children != null) {
        List<TextSpan> tmp = [];
        currentSpans
            .add(TextSpan(children: tmp, style: theme[node.className!]));
        stack.add(currentSpans);
        currentSpans = tmp;

        node.children!.forEach((n) {
          _traverse(n);
          if (n == node.children!.last) {
            currentSpans = stack.isEmpty ? spans : stack.removeLast();
          }
        });
      }
    }

    for (var node in nodes) {
      _traverse(node);
    }
    return spans;
  }

  static const _rootKey = 'root';
  static const _defaultFontColor = Color(0xff000000);
  static const _defaultBackgroundColor = Color(0xffffffff);

  // TODO: dart:io is not available at web platform currently
  // See: https://github.com/flutter/flutter/issues/39998
  // So we just use monospace here for now
  static const _defaultFontFamily = 'monospace';

  @override
  Widget build(BuildContext context) {
    var _textStyle = TextStyle(
      fontFamily: _defaultFontFamily,
      color: theme[_rootKey]?.color ?? _defaultFontColor,
    );
    if (textStyle != null) {
      _textStyle = _textStyle.merge(textStyle);
    }

    return Container(
      decoration: BoxDecoration(
          color: theme[_rootKey]?.backgroundColor ?? _defaultBackgroundColor,
          borderRadius: isCodeBlock
              ? BorderRadius.vertical(bottom: Radius.circular(10))
              : BorderRadius.circular(10)),
      padding: padding,
      child: Text.rich(
        softWrap: false,
        textScaler: TextScaler.linear(textScaleFactor),
        TextSpan(
            style: _textStyle,
            children:
                _convert(highlight.parse(source, language: language).nodes!)),
      ),
    );
  }
}

class CodeElementBuilder extends MarkdownElementBuilder {
  double textScaleFactor;

  Map<String, TextStyle> syntaxTheme = atomOneDarkTheme;

  CodeElementBuilder({required this.textScaleFactor});

  Widget getSelectableHighlightView(md.Element element,
      {String language = '', bool isCodeBlock = false}) {
    return SelectableHighlightView(
      element.textContent,
      language: language,
      theme: syntaxTheme,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      textScaleFactor: textScaleFactor,
      isCodeBlock: isCodeBlock,
      textStyle: GoogleFonts.jetBrainsMono(
        backgroundColor: Colors.transparent,
      ),
    );
  }

  @override
  Widget? visitElementAfterWithContext(
    BuildContext context,
    md.Element element,
    TextStyle? preferredStyle,
    TextStyle? parentStyle,
  ) {
    var language = '';

    bool isCodeBlock = element.attributes['class'] != null;

    if (isCodeBlock) {
      String lg = element.attributes['class'] as String;
      language = lg.substring(9);
      var scrollController = ScrollController();
      return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        Container(
          decoration: BoxDecoration(
              color: Colors.blueGrey.shade100,
              borderRadius: BorderRadius.vertical(top: Radius.circular(8))),
          child: ListTile(
            title: Text(language),
            trailing: IconButton(
              icon: Icon(Icons.copy),
              onPressed: () async {
                await copyMessage(context, element.textContent);
              },
            ),
            dense: true,
            textColor: Colors.black,
            iconColor: Colors.black,
          ),
        ),
        Container(
            decoration: BoxDecoration(
                color: syntaxTheme['root']?.backgroundColor,
                borderRadius:
                    BorderRadius.vertical(bottom: Radius.circular(10))),
            child: Scrollbar(
              controller: scrollController,
              interactive: true,
              thumbVisibility: true,
              trackVisibility: true,
              thickness: 8,
              radius: Radius.circular(20),
              scrollbarOrientation: ScrollbarOrientation.bottom,
              child: SingleChildScrollView(
                  controller: scrollController,
                  physics: ScrollPhysics(),
                  scrollDirection: Axis.horizontal,
                  child: getSelectableHighlightView(
                    element,
                    language: language,
                    isCodeBlock: isCodeBlock,
                  )),
            )),
      ]);
    } else {
      return Container(
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(10)),
          child: getSelectableHighlightView(
            element,
            language: language,
            isCodeBlock: isCodeBlock,
          ));
    }
  }
}
