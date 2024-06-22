// lib/widgets/restaurant_card.dart
import 'package:cloudbelly_app/screens/Tabs/Profile/profile_view.dart';
import 'package:figma_squircle/figma_squircle.dart';
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
            child: Container(
              width: 90,
              height: 90,
              decoration: ShapeDecoration(
                color: Colors.white,
                shape: SmoothRectangleBorder(
                  borderRadius: SmoothBorderRadius(
                    cornerRadius: 17.0,
                    cornerSmoothing: 1,
                  ),
                ),
                shadows: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.2),
                    spreadRadius: 1,
                    blurRadius: 7,
                    offset: Offset(0, 3),
                  ),
                ],
                image: DecorationImage(
                  image: NetworkImage(restaurant.profilePhoto.isNotEmpty
                      ? restaurant.profilePhoto
                      : 'https://via.placeholder.com/150'),
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
          SizedBox(width: 20),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center, // Center vertically
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
                Row(
                  children: [
                    Image.asset(
                      'assets/images/Heart.png', // Ensure this asset file exists
                      width: 20, // Set the width of the image
                      height: 20, // Set the height of the image
                    ),
                    SizedBox(width: 8.0), // Add some space between the image and the text
                    Text(
                      '--  --', // Add the rating text here
                      style: TextStyle(
                        fontSize: 14.0,
                        color: Color(0xff9428A9),
                        fontWeight: FontWeight.bold
                      ),
                    ),
                    Spacer(), // Pushes the text to the right
                    Text(
                      '45-50 mins',
                      style: TextStyle(
                        fontSize: 14.0,
                        color: Color(0xff9428A9),
                        fontWeight: FontWeight.bold
                      ),
                      textAlign: TextAlign.right,
                    ),
                  ],
                ),
                SizedBox(height: 5),
                Text(
                  restaurant.location,
                  style: TextStyle(
                    color: Color(0xff9428A9),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}}
