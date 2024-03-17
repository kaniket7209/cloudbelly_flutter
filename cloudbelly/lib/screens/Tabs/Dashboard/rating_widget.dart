import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class RatingIcons extends StatelessWidget {
  final double rating;
  final double iconSize;

  RatingIcons({required this.rating, this.iconSize = 15});

  @override
  Widget build(BuildContext context) {
    List<Widget> icons = [];
    int filledStars = rating.floor();
    double remainder = rating - filledStars;

    for (int i = 0; i < filledStars; i++) {
      icons.add(Icon(Icons.favorite, size: iconSize, color: Color(0xFFFA6E00)));
    }

    if (remainder > 0) {
      icons.add(Icon(
        Icons.favorite,
        size: iconSize,
        color: Color(0xFFFA6E00).withOpacity(0.5),
      ));
      filledStars++; // Increment to include the half star
    }

    for (int i = filledStars; i < 5; i++) {
      icons.add(Icon(Icons.favorite_border,
          size: iconSize, color: Color(0xFFFA6E00)));
    }

    return Row(children: icons);
  }
}
