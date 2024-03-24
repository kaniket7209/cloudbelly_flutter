import 'package:flutter/material.dart';
import 'dart:ui'; // Import this to use ImageFilter

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: HomePage(),
    );
  }
}

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Modal Bottom Sheet Example'),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            showModalBottomSheet(
              context: context,
              isScrollControlled: true,
              builder: (BuildContext context) {
                return MyBottomSheetContent();
              },
            );
          },
          child: Text('Open Modal Bottom Sheet'),
        ),
      ),
    );
  }
}

class MyBottomSheetContent extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return NotificationListener<ScrollNotification>(
      onNotification: (scrollNotification) {
        if (scrollNotification is ScrollUpdateNotification) {}
        return true;
      },
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Main Content
          Container(
            color: Colors.blue, // Example background color
          ),
          // Blur Background
          BackdropFilter(
            filter: ImageFilter.blur(
              sigmaX: MyBottomSheetContent.blurSigma,
              sigmaY: MyBottomSheetContent.blurSigma,
            ),
            child: Container(
              color: Colors.transparent, // Transparent color
            ),
          ),
          // Bottom Sheet Content
          SingleChildScrollView(
            child: Container(
              height: MediaQuery.of(context).size.height * 0.6,
              color: Colors.white,
              padding: EdgeInsets.symmetric(vertical: 20.0, horizontal: 20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: List.generate(
                  4,
                  (index) => ListTile(
                    title: Text('Item $index'),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Static variable to hold blur sigma value
  static double blurSigma = 0.0;
}
