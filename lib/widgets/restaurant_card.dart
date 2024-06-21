// lib/widgets/restaurant_card.dart
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/restaurant.dart';

class RestaurantCard extends StatelessWidget {
  final Restaurant restaurant;

  RestaurantCard({required this.restaurant});

  void _launchURL(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Padding(
        
        padding: const EdgeInsets.all(20.0),
        child: Row(
          
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(10.0),
              child: Image.network(
                restaurant.profilePhoto.isNotEmpty
                    ? restaurant.profilePhoto
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
                    restaurant.storeName,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  SizedBox(height: 5),
                  Text(
                    'Orders: ${restaurant.orderCounter}',
                    style: TextStyle(
                      color: Colors.grey,
                    ),
                  ),
                  Text(
                    restaurant.location,
                    style: TextStyle(
                      color: Colors.grey,
                    ),
                  ),
                  GestureDetector(
                    onTap: () => _launchURL('tel:${restaurant.phone}'),
                    child: Text(
                      restaurant.phone,
                      style: TextStyle(
                        color: Colors.blue,
                        decoration: TextDecoration.underline,
                      ),
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