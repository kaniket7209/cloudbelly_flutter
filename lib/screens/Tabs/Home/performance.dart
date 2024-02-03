import 'package:flutter/material.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

class Performance extends StatefulWidget {
  const Performance({super.key});

  @override
  State<Performance> createState() => _PerformanceState();
}

class _PerformanceState extends State<Performance> {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 10.h,
      width: double.infinity,
      child: Center(
        child: Text('Feature Pending'),
      ),
    );
  }
}
