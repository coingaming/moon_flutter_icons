import 'dart:math';

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

  // Helper function to group keys in trios
  List<List<String>> _groupInTrios(List<String> keys) {
    List<List<String>> trios = [];
    for (int i = 0; i < keys.length; i += 3) {
      trios.add(keys.sublist(i, min(i + 3, keys.length)));
    }
    return trios;
  }

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

    Map<String, Map<String, IconData>> combinedSegments = {};

    // Get all unique segment names
    Set<String> allSegments = lightSegments.keys.toSet()..addAll(regularSegments.keys);

    for (String segment in allSegments) {
      combinedSegments[segment] = {};

      // Get the list of keys from light and regular segments for this segment
      List<String> lightKeys = lightSegments[segment]?.keys.toList() ?? [];
      List<String> regularKeys = regularSegments[segment]?.keys.toList() ?? [];

      // Group the keys in trios
      List<List<String>> lightTrios = _groupInTrios(lightKeys);
      List<List<String>> regularTrios = _groupInTrios(regularKeys);

      // Maximum number of trios in either list
      int maxTrios = max(lightTrios.length, regularTrios.length);

      for (int i = 0; i < maxTrios; i++) {
        // Add light trios if available
        if (i < lightTrios.length) {
          for (String key in lightTrios[i]) {
            combinedSegments[segment]![key] = lightSegments[segment]![key]!;
          }
        }
        // Add regular trios if available
        if (i < regularTrios.length) {
          for (String key in regularTrios[i]) {
            combinedSegments[segment]![key] = regularSegments[segment]![key]!;
          }
        }
      }
    }

    segments = combinedSegments;

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
