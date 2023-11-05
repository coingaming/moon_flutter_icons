import 'package:flutter/material.dart';
import 'package:moon_icons/moon_icons.dart';
import 'package:moon_icons_demo/segment.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Moon Icons Demo",
      theme: ThemeData(),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatelessWidget {
  const MyHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    Map<String, Map<String, IconData>> segments = {};

    for (String key in iconsMap.keys) {
      String segment = key.split('_').first;
      if (!segments.containsKey(segment)) {
        segments[segment] = {};
      }
      segments[segment]![key] = iconsMap[key]!;
    }

    return Scaffold(
      appBar: AppBar(
        title: Text("Moon Icons Demo"),
      ),
      body: CustomScrollView(
        slivers: segments.values.map((e) => Segment(segmentMap: e)).toList(),
      ),
    );
  }
}
