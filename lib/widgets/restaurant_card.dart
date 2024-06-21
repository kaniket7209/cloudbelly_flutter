// lib/widgets/restaurant_card.dart
import 'package:flutter/material.dart';
import '../models/restaurant.dart';

class RestaurantCard extends StatelessWidget {
  final Restaurant restaurant;

  RestaurantCard({required this.restaurant});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8.0),
              child: Image.network(
                restaurant.images.isNotEmpty 
                  ? restaurant.images.first 
                  : 'https://via.placeholder.com/150',
                height: 80,
                width: 80,
                fit: BoxFit.cover,
              ),
            ),
            SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    restaurant.name,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  SizedBox(height: 5),
                  Row(
                    children: [
                      Icon(Icons.favorite, color: Colors.red, size: 16),
                      SizedBox(width: 5),
                      Text('4.6 (100+)'),
                      SizedBox(width: 10),
                      Text('45-50 mins'),
                    ],
                  ),
                  SizedBox(height: 5),
                  Text(
                    restaurant.category,
                    style: TextStyle(
                      color: Colors.grey,
                    ),
                  ),
                  Text(
                    restaurant.storeName,
                    style: TextStyle(
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}