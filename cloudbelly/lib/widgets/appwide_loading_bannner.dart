import 'package:flutter/material.dart';
import 'package:loading_indicator/loading_indicator.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

class AppWideLoadingBanner {
  Future<void> loadingBanner(BuildContext context) async {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                height: 10.h,
                // width: 50.w,
                child: LoadingIndicator(
                    indicatorType: Indicator.ballSpinFadeLoader,

                    /// Required, The loading type of the widget
                    colors: const [
                      Colors.red,
                      Colors.orange,
                      Colors.yellow,
                      Colors.green,
                      Colors.blue,
                      Colors.indigo,
                      Colors.purple,
                    ],

                    /// Optional, The color collections
                    strokeWidth: 2,

                    /// Optional, The stroke of the line, only applicable to widget which contains line
                    backgroundColor: Colors.transparent,

                    /// Optional, Background of the widget
                    pathBackgroundColor: Colors.black

                    /// Optional, the stroke backgroundColor
                    ),
              ),
              SizedBox(height: 20),
              Text('Loading...'),
            ],
          ),
        );
      },
    );
  }

  Widget LoadingCircle(BuildContext context) {
    return SizedBox(
      height: 4.h,
      child: Center(
        child: LoadingIndicator(
            indicatorType: Indicator.ballSpinFadeLoader,
            colors: const [
              Colors.red,
              Colors.orange,
              Colors.yellow,
              Colors.green,
              Colors.blue,
              Colors.indigo,
              Colors.purple
            ],
            strokeWidth: 2,
            backgroundColor: Colors.transparent,
            pathBackgroundColor: Colors.black),
      ),
    );
  }

  Future<void> featurePending(BuildContext context) async {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Pending Feature"),
          content: Text("This feature is currently pending implementation."),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Close'),
            ),
          ],
        );
      },
    );
  }
}
