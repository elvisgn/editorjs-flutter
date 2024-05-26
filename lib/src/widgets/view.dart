// ignore_for_file: constant_pattern_never_matches_value_type

import 'dart:convert';

import 'package:editorjs_flutter/src/model/EditorJSBlockTypes.dart';
import 'package:editorjs_flutter/src/model/EditorJSCSSTag.dart';
import 'package:editorjs_flutter/src/model/EditorJSData.dart';
import 'package:editorjs_flutter/src/model/EditorJSViewStyles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';

class EditorJSView extends StatefulWidget {
  final String editorJSData;
  final String? styles;

  const EditorJSView({Key? key, required this.editorJSData, this.styles})
      : super(key: key);

  @override
  EditorJSViewState createState() => EditorJSViewState();
}

class EditorJSViewState extends State<EditorJSView> {
  String? data;
  late EditorJSData dataObject;
  late EditorJSViewStyles styles;
  final List<Widget> items = <Widget>[];
  late Map<String, Style> customStyleMap;

  @override
  void initState() {
    super.initState();

    setState(
      () {
        dataObject = EditorJSData.fromJson(jsonDecode(widget.editorJSData));
        if (widget.styles != null) {
          styles = EditorJSViewStyles.fromJson(jsonDecode(widget.styles!));
          customStyleMap = generateStylemap(styles.cssTags!);
        }

        dataObject.blocks?.forEach(
          (block) {
            double levelFontSize = 16;

            switch (block.data!.level) {
              case 1:
                levelFontSize = 32;
                break;
              case 2:
                levelFontSize = 24;
                break;
              case 3:
                levelFontSize = 16;
                break;
              case 4:
                levelFontSize = 12;
                break;
              case 5:
                levelFontSize = 10;
                break;
              case 6:
                levelFontSize = 8;
                break;
            }

            switch (block.type) {
              case EditorJSBlockTypes.header:
                items.add(Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        block.data!.text!,
                        style: TextStyle(
                            fontSize: levelFontSize,
                            fontWeight: (block.data!.level! <= 3)
                                ? FontWeight.bold
                                : FontWeight.normal),
                      )
                    ]));
                break;
              case EditorJSBlockTypes.paragraph:
                items.add(Html(
                  data: block.data!.text,
                  style: customStyleMap,
                ));
                break;
              case EditorJSBlockTypes.list:
                String bullet = "\u2022 ";
                String? style = block.data!.style;
                int counter = 1;

                block.data!.items!.forEach(
                  (element) {
                    if (style == 'ordered') {
                      bullet = counter.toString();
                      items.add(
                        Row(children: [
                          Expanded(
                            child: Container(
                                child: Html(
                              data: bullet + element,
                              style: customStyleMap,
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
                                  style: customStyleMap),
                            ))
                          ],
                        ),
                      );
                    }
                  },
                );
                break;
              case EditorJSBlockTypes.quote:
                items.add(Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Text('***', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold), textAlign: TextAlign.center,)
                      Expanded(child: Divider(color: Colors.grey))
                    ]));
                break;
              case EditorJSBlockTypes.image:
                items.add(Image.network(block.data!.file!.url!));
                break;
            }
            items.add(const SizedBox(height: 10));
          },
        );
      },
    );
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
                color:
                    (element.color != null) ? getColor(element.color!) : null,
                padding: (element.padding != null)
                    ? HtmlPaddings.all(element.padding!)
                    : null));
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
