import 'package:editorjs_flutter/src/model/EditorJSBlockFile.dart';

class EditorJSBlockData {
  final String? text;
  final int? level;
  final String? style;
  final List<dynamic>? items;
  final EditorJSBlockFile? file;
  final String? caption;
  final String? alignment;
  final bool? withBorder;
  final bool? stretched;
  final bool? withBackground;

  EditorJSBlockData(
      {this.text,
      this.level,
      this.style,
      this.items,
      this.file,
      this.caption,
      this.alignment,
      this.withBorder,
      this.stretched,
      this.withBackground});

  factory EditorJSBlockData.fromJson(Map<String, dynamic> parsedJson) {
    var list = parsedJson['items'] as List?;
    final List<dynamic> itemsList = <dynamic>[];

    if (list != null) {
      list.forEach((element) {
        itemsList.add(element);
      });
    }

    return EditorJSBlockData(
        text: parsedJson['text'],
        level: parsedJson['level'],
        style: parsedJson['style'],
        items: itemsList,
        file: (parsedJson['file'] != null)
            ? EditorJSBlockFile.fromJson(parsedJson['file'])
            : null,
        caption: parsedJson['caption'],
        alignment: parsedJson['alignment'],
        withBorder: parsedJson['withBorder'],
        withBackground: parsedJson['withBackground']);
  }
}
