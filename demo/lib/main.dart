import 'package:editorjs_flutter/editorjs_flutter.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'createnote.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'EditorJS Example',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: MyHomePage(title: 'EditorJS Flutter Example'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({required this.title, super.key});

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  EditorJSView? editorJSView;

  @override
  void initState() {
    super.initState();
    fetchTestData();
  }

  void fetchTestData() async {
    String data = await http
        .get(Uri.parse(
            'https://d3574m8g5kpmf1.cloudfront.net/10k5XhzIpmMnM4pYC3XhKGWEiPq2/520076df-a9a4-4a8a-ae73-910956b024b6.json'))
        .then((response) {
      return response.body;
    });
    editorJSView = EditorJSView(editorJSData: data);
    setState(() {});
  }

  void _showEditor() {
    Navigator.of(context).push(MaterialPageRoute(
        builder: (BuildContext context) => CreateNoteLayout()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: ListView(
        shrinkWrap: true,
        padding: EdgeInsets.all(8),
        children: [
          (editorJSView != null)
              ? editorJSView!
              : Center(child: Text("Please wait..."))
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showEditor,
        tooltip: 'Create content',
        child: Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
