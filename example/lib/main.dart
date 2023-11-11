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

      // Iterate in steps of 3 for trios
      int maxLightIndex = ((lightKeys.length / 3).ceil() * 3);
      int maxRegularIndex = ((regularKeys.length / 3).ceil() * 3);

      for (int i = 0; i < max(maxLightIndex, maxRegularIndex); i += 3) {
        // Add up to three light icons
        for (int j = i; j < min(i + 3, lightKeys.length); j++) {
          String key = lightKeys[j];
          combinedSegments[segment]![key] = lightSegments[segment]![key]!;
        }
        // Add up to three regular icons
        for (int j = i; j < min(i + 3, regularKeys.length); j++) {
          String key = regularKeys[j];
          combinedSegments[segment]![key] = regularSegments[segment]![key]!;
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
