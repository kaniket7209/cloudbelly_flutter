import 'package:flutter/material.dart';

class SearchView extends StatefulWidget {
  const SearchView({super.key});

  @override
  State<SearchView> createState() => _SearchViewState();
}

class _SearchViewState extends State<SearchView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text(
          'Feature Coming Soon',
          style: TextStyle(
            color: Color(0xFF094B60),
            fontSize: 20,
            fontFamily: 'Jost',
            fontWeight: FontWeight.w600,
            // height: 0.05,
            letterSpacing: 0.60,
          ),
        ),
      ),
    );
  }
}
