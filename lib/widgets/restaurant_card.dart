// lib/widgets/restaurant_card.dart
import 'package:cloudbelly_app/screens/Tabs/Profile/profile_view.dart';
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
      margin: const EdgeInsets.symmetric(vertical: 0.0, horizontal: 20.0),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Row(
          children: [
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ProfileView(
                      userIdList: [
                        restaurant.id
                      ], // Adjust this according to your ProfileView constructor
                    ),
                  ),
                ).then((value) {
                  // You can clear the userId or perform any other actions here if needed
                });
              },
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10.0),
                child: Image.network(
                  restaurant.profilePhoto.isNotEmpty
                      ? restaurant.profilePhoto
                      : 'https://via.placeholder.com/150',
                  height: 80,
                  width: 80,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Image.asset(
                      'assets/placeholder.png',
                      height: 80,
                      width: 80,
                      fit: BoxFit.cover,
                    );
                  },
                ),
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
                      color: Color(0xff2E0536),
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
