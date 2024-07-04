// lib/widgets/restaurant_card.dart
import 'package:cloudbelly_app/constants/globalVaribales.dart';
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
                height: 90,
                width: 90,
                decoration: ShapeDecoration(
                  color: Colors.white,
                  shape: SmoothRectangleBorder(
                    borderRadius: SmoothBorderRadius(
                      cornerRadius: 22.0,
                      cornerSmoothing: 1,
                    ),
                  ),
                  shadows: [
                    BoxShadow(
                      color: const Color.fromRGBO(130, 47, 130, 1)
                          .withOpacity(0.3),
                      spreadRadius: 1,
                      blurRadius: 25,
                      offset: Offset(3, 6),
                    ),
                  ],
                ),
                child: ClipSmoothRect(
                  radius: SmoothBorderRadius(
                    cornerRadius: 22,
                    cornerSmoothing: 1,
                  ),
                  child: restaurant.profilePhoto.isNotEmpty
                      ? Image.network(
                          restaurant.profilePhoto.isNotEmpty
                              ? restaurant.profilePhoto
                              : 'https://via.placeholder.com/150', // Fallback image URL
                          fit: BoxFit.cover,
                          loadingBuilder:
                              GlobalVariables().loadingBuilderForImage,
                          errorBuilder: GlobalVariables().ErrorBuilderForImage,
                        )
                      : Image.network('https://via.placeholder.com/150'),
                ),
              ),
            ),
            SizedBox(width: 20),
            Expanded(
              flex: 1,
              child: Column(
                mainAxisAlignment:
                    MainAxisAlignment.center, // Center vertically
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
                      SizedBox(
                          width:
                              8.0), // Add some space between the image and the text
                      Text(
                        '--  --', // Add the rating text here
                        style: TextStyle(
                            fontSize: 14.0,
                            color: Color(0xff9428A9),
                            fontWeight: FontWeight.bold),
                      ),
                      SizedBox(width: 3.0),

                      Spacer(), // Pushes the text to the right
                      Text(
                        '45-50 mins',
                        style: TextStyle(
                            fontSize: 14.0,
                            color: Color(0xff9428A9),
                            fontWeight: FontWeight.bold),
                        textAlign: TextAlign.right,
                      ),
                    ],
                  ),
                  SizedBox(height: 5),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Flexible(
                        child: Text(
                          restaurant.location,
                          style: TextStyle(
                            color: Color(0xff9428A9),
                            fontSize: 12,
                          ),
                          overflow: TextOverflow
                              .ellipsis, // This will add ellipsis (...) if text overflows
                        ),
                      ),
                      // SizedBox(width: 8),
                      // Spacer(), // Add some spacing between the location and distance
                      Text(
                        '${double.parse(restaurant.distance_km).toStringAsFixed(2)} km',
                        style: TextStyle(
                          fontSize: 14.0,
                          color: Color(0xffFA6E00),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
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
