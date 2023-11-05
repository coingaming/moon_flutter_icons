import 'package:flutter/material.dart';
import 'package:moon_icons/moon_icons.dart';

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
    return Scaffold(
      appBar: AppBar(
        title: Text("Moon Icons Demo"),
      ),
      body: CustomScrollView(
        slivers: [
          SliverGrid.builder(
            itemCount: iconsMap.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 8,
              mainAxisExtent: 104,
            ),
            itemBuilder: (BuildContext context, int index) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  if (iconsMap.keys.toList()[index].contains("16"))
                    Icon(iconsMap.values.toList()[index], size: 16)
                  else if (iconsMap.keys.toList()[index].contains("24"))
                    Icon(iconsMap.values.toList()[index], size: 24)
                  else
                    Icon(iconsMap.values.toList()[index], size: 32),
                  const SizedBox(height: 20),
                  Text(
                    iconsMap.keys.toList()[index],
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

class TextDivider extends StatelessWidget {
  final String text;
  final double paddingTop;
  final double paddingBottom;

  const TextDivider({
    super.key,
    required this.text,
    this.paddingTop = 40,
    this.paddingBottom = 32,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(top: paddingTop, bottom: paddingBottom),
      child: Row(
        children: [
          const Expanded(
            child: Divider(),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Text(
              text,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Colors.grey[600],
              ),
            ),
          ),
          const Expanded(
            child: Divider(),
          ),
        ],
      ),
    );
  }
}
