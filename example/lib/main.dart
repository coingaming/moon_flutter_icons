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
    Map<String, Map<String, IconData>> lightSegments = {};
    Map<String, Map<String, IconData>> regularSegments = {};

    for (String key in iconsMap.keys) {
      // Extract the segment and type (like light or regular)
      List<String> parts = key.split('_');
      String segment = parts.first;
      String type = parts.last;

      if (type == "light") {
        if (!lightSegments.containsKey(segment)) {
          lightSegments[segment] = {};
        }
        lightSegments[segment]![key] = iconsMap[key]!;
      } else if (type == "regular") {
        if (!regularSegments.containsKey(segment)) {
          regularSegments[segment] = {};
        }
        regularSegments[segment]![key] = iconsMap[key]!;
      }
    }

    // Merging the "light" and "regular" segments in the desired order
    for (String segment in lightSegments.keys) {
      segments[segment] = lightSegments[segment]!;
    }
    for (String segment in regularSegments.keys) {
      if (!segments.containsKey(segment)) {
        segments[segment] = regularSegments[segment]!;
      } else {
        segments[segment]!.addAll(regularSegments[segment]!);
      }
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
