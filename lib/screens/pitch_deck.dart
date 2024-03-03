import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class PitchDeck extends StatefulWidget {
  static const routeName = '/pitch-deck-screen';
  const PitchDeck({super.key});

  @override
  State<PitchDeck> createState() => _PitchDeckState();
}

class _PitchDeckState extends State<PitchDeck> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(child: Text('pitch')),
    );
  }
}
