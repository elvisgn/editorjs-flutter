// ignore_for_file: constant_pattern_never_matches_value_type

import 'dart:convert';

import 'package:editorjs_flutter/src/model/EditorJSCSSTag.dart';
import 'package:editorjs_flutter/src/model/EditorJSData.dart';
import 'package:editorjs_flutter/src/model/EditorJSViewStyles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:html/parser.dart';

class EditorJSView extends StatefulWidget {
  final String editorJSData;
  final String? styles;
  final double? h1FontSize;
  final double? h2FontSize;
  final double? h3FontSize;
  final double? h4FontSize;
  final double? h5FontSize;
  final double? h6FontSize;

  const EditorJSView({
    Key? key,
    required this.editorJSData,
    this.styles,
    this.h1FontSize = 32,
    this.h2FontSize = 24,
    this.h3FontSize = 16,
    this.h4FontSize = 14,
    this.h5FontSize = 12,
    this.h6FontSize = 10,
  }) : super(key: key);

  @override
  EditorJSViewState createState() => EditorJSViewState();
}

class EditorJSViewState extends State<EditorJSView> {
  String? data;
  late EditorJSData dataObject;

  double levelFontSize = 16;
  EditorJSViewStyles? styles;
  final List<Widget> items = <Widget>[];
  Map<String, Style>? customStyleMap;

  @override
  void initState() {
    levelFontSize = widget.h3FontSize!;
    super.initState();

    setState(
      () {
        dataObject = EditorJSData.fromJson(jsonDecode(widget.editorJSData));
        if (widget.styles != null) {
          styles = EditorJSViewStyles.fromJson(jsonDecode(widget.styles!));
          if (styles!.cssTags != null)
            customStyleMap = generateStylemap(styles!.cssTags!);
        }

        dataObject.blocks?.forEach(
          (block) {
            switch (block.data?.level) {
              case 1:
                levelFontSize = widget.h1FontSize!;
                break;
              case 2:
                levelFontSize = widget.h2FontSize!;
                break;
              case 3:
                levelFontSize = widget.h3FontSize!;
                break;
              case 4:
                levelFontSize = widget.h4FontSize!;
                break;
              case 5:
                levelFontSize = widget.h5FontSize!;
                break;
              case 6:
                levelFontSize = widget.h6FontSize!;
                break;
            }

            switch (block.type) {
              case "header":
                items.add(Container(
                  padding: EdgeInsets.all(4),
                  width: double.infinity,
                  child: Text(
                    block.data!.text!,
                    textAlign: TextAlign.start,
                    style: TextStyle(
                        fontSize: levelFontSize,
                        fontWeight: (block.data!.level! <= 3)
                            ? FontWeight.bold
                            : FontWeight.normal),
                  ),
                ));
                break;
              case "paragraph":
                items.add(customText(
                  block.data!.text!,
                  customStyleMap ?? {},
                ));
                break;
              case "list":
                String bullet = "\u2022 ";
                String? style = block.data?.style;
                int counter = 1;

                block.data?.items?.forEach(
                  (element) {
                    if (style == 'ordered') {
                      bullet = counter.toString();
                      items.add(
                        Row(children: [
                          Expanded(
                            child: Container(
                                child: customText(
                              bullet + element,
                              customStyleMap ?? {},
                            )),
                          )
                        ]),
                      );
                      counter++;
                    } else {
                      items.add(
                        Row(
                          children: <Widget>[
                            Expanded(
                                child: Container(
                              child: Html(
                                  data: bullet + element,
                                  style: customStyleMap ?? {}),
                            ))
                          ],
                        ),
                      );
                    }
                  },
                );
                break;
              case "checklist":
                block.data?.items?.forEach(
                  (element) {
                    // print('Checklist: $element');
                    items.add(
                      Row(children: [
                        Checkbox.adaptive(
                            value: element['checked'] ?? false,
                            onChanged: null),
                        const SizedBox(width: 4),
                        Expanded(
                            child: Container(
                          child: Html(
                              data: element['text'],
                              style: customStyleMap ?? {}),
                        )),
                      ]),
                    );
                  },
                );
                break;
              case "quote":
                items.add(Container(
                  margin: EdgeInsets.all(8),
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    border: Border(
                      left: BorderSide(
                        color: Colors.grey,
                        width: 4,
                      ),
                    ),
                  ),
                  child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Column(
                          mainAxisAlignment: block.data?.alignment == 'center'
                              ? MainAxisAlignment.center
                              : block.data?.alignment == 'right'
                                  ? MainAxisAlignment.end
                                  : MainAxisAlignment.start,
                          children: [
                            Text(block.data!.text!,
                                style: TextStyle(fontSize: levelFontSize)),
                            const SizedBox(height: 8),
                            Text(block.data!.caption!,
                                style: TextStyle(fontSize: levelFontSize))
                          ],
                        ),
                      ]),
                ));
                break;
              case "image":
                items.add(Image.network(block.data!.file!.url!));
                break;
              default:
                break;
            }
            items.add(const SizedBox(height: 10));
          },
        );
      },
    );
  }

  Widget customText(String input, Map<String, Style> style) {
    return _handleFormattingTags(input, style);
    // final reg = RegExp("(?=<a)|(?<=/a>)");
    // var result = input.split(reg);

    // return RichText(
    //     text: TextSpan(
    //         text: '',
    //         style: DefaultTextStyle.of(context).style,
    //         children: <TextSpan>[
    //       ...result.map((e) => e.startsWith('<a')
    //           ? TextSpan(
    //               text: _stripHtmlTags(e),
    //               style: new TextStyle(color: Colors.blue),
    //               recognizer: new TapGestureRecognizer()
    //                 ..onTap = () {
    //                   launchUrl(Uri.parse(
    //                       'https://docs.flutter.io/flutter/services/UrlLauncher-class.html'));
    //                 },
    //             )
    //           // : _handleFormattingTags(e, style))
    //           : TextSpan(text: e, style: TextStyle(fontSize: 16)))
    //     ]));
  }

  _handleFormattingTags(String input, Map<String, Style> style) {
    return Html(
        data: input,
        style: {}
          ..addAll({
            "a": Style(
              color: Colors.blue,
              fontSize: FontSize.large,
              textDecoration: TextDecoration.underline,
            ), // on text highlighting works, link does not
            "b": Style(
              fontWeight: FontWeight.bold,
              fontSize: FontSize.large,
            ),
            "i": Style(
              fontStyle: FontStyle.italic,
              fontSize: FontSize.large,
            ),
            "u": Style(
              textDecoration: TextDecoration.underline,
              fontSize: FontSize.large,
            ),
            "mark": Style(
              backgroundColor: Colors.yellowAccent,
              fontSize: FontSize.large,
            ),
          })
          ..addAll(style));
  }

  String _stripHtmlTags(String htmlString) {
    print('HTMLString: $htmlString');
    final document = parse(htmlString);
    final String parsedString =
        parse(document.body?.text).documentElement!.text;

    print('Parsed HTMLString: $parsedString');
    return parsedString;
  }

  Map<String, Style> generateStylemap(List<EditorJSCSSTag> styles) {
    Map<String, Style> map = <String, Style>{};

    styles.forEach(
      (element) {
        map.putIfAbsent(
          element.tag.toString(),
          () => Style(
              backgroundColor: (element.backgroundColor != null)
                  ? getColor(element.backgroundColor!)
                  : null,
              color: (element.color != null) ? getColor(element.color!) : null,
              padding: (element.padding != null)
                  ? HtmlPaddings.all(element.padding!)
                  : null),
        );
      },
    );

    return map;
  }

  Color getColor(String hexColor) {
    final hexCode = hexColor.replaceAll('#', '');
    return Color(int.parse('$hexCode', radix: 16));
  }

  @override
  Widget build(BuildContext context) {
    return Column(children: items);
  }
}
