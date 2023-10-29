import 'package:demux_app/app/pages/chat/utils/copy_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_highlighter/themes/atom-one-light.dart';
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

  SelectableHighlightView(
    String input, {
    this.language,
    this.theme = const {},
    this.padding,
    this.textStyle,
    int tabSize = 8, // TODO: https://github.com/flutter/flutter/issues/50087
    required this.textScaleFactor,
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
    // if (spans.length > 1) spans.removeLast();
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
      color: theme[_rootKey]?.backgroundColor ?? _defaultBackgroundColor,
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

class CodeBlockElementBuilder extends MarkdownElementBuilder {
  double textScaleFactor;

  CodeBlockElementBuilder({required this.textScaleFactor});

  @override
  Widget? visitElementAfter(md.Element element, TextStyle? preferredStyle) {
    var language = '';
    print("element.tag = ${element.tag}");
    print("element.attributes = ${element.attributes}");

    if (element.attributes['class'] != null) {
      String lg = element.attributes['class'] as String;
      language = lg.substring(9);
    }

    return Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Container(
            color: Colors.blueGrey,
            child: ListTile(
              title: Text(language),
              trailing: Icon(Icons.copy),
              dense: true,
              tileColor: Colors.green,
            ),
          ),
          Scrollbar(
              trackVisibility: true,
              thickness: 8, //width of scrollbar
              radius: Radius.circular(20), //corner radius of scrollbar
              scrollbarOrientation: ScrollbarOrientation.bottom,
              child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: SelectableHighlightView(
                    element.textContent,
                    language: language,
                    theme: atomOneLightTheme,
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                    textScaleFactor: textScaleFactor,
                    textStyle: GoogleFonts.jetBrainsMono(
                      backgroundColor: Colors.transparent,
                    ),
                  )))
        ]));
  }
}

class InlineCodeElementBuilder extends MarkdownElementBuilder {
  double textScaleFactor;

  InlineCodeElementBuilder({required this.textScaleFactor});

  Widget getSelectableHighlightView(md.Element element,
      {String language = ''}) {
    return SelectableHighlightView(
      element.textContent,
      language: language,
      theme: atomOneLightTheme,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      textScaleFactor: textScaleFactor,
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
    if (element.attributes['class'] != null) {
      String lg = element.attributes['class'] as String;
      language = lg.substring(9);
      var scrollController = ScrollController();
      return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
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
        Scrollbar(
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
              )),
        ),
      ]);
    }
    return getSelectableHighlightView(
      element,
      language: language,
    );
  }
}
