// lib/widgets/dish_card.dart
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloudbelly_app/constants/globalVaribales.dart';
import 'package:cloudbelly_app/screens/Tabs/Profile/profile_view.dart';
import 'package:figma_squircle/figma_squircle.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import '../models/dish.dart';

class DishCard extends StatelessWidget {
  final Dish dish;

  DishCard({required this.dish});

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
                        dish.user_id
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
                      color: Color(0xff9E749E).withOpacity(0.5),
                      spreadRadius: 1,
                      blurRadius: 10,
                      offset: Offset(3, 6),
                    ),
                  ],
                ),
                child: ClipSmoothRect(
                  radius: SmoothBorderRadius(
                    cornerRadius: 22,
                    cornerSmoothing: 1,
                  ),
                  child: dish.images.isNotEmpty
                      ? CachedNetworkImage(
                          imageUrl: dish.images.first,
                          fit: BoxFit.cover,
                          placeholder: (context, url) => GlobalVariables()
                              .imageloadingBuilderForImage(context, null),
                          errorWidget: (context, url, error) =>
                              GlobalVariables().imageErrorBuilderForImage(
                                  context, error, null),
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
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ProfileView(
                            userIdList: [
                              dish.user_id
                            ], // Adjust this according to your ProfileView constructor
                          ),
                        ),
                      ).then((value) {
                        // You can clear the userId or perform any other actions here if needed
                      });
                    },
                    child: Row(
                      children: [
                        Container(
                          width: MediaQuery.of(context).size.width * 0.3,
                          child: Text(
                            dish.name,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontFamily: 'Product Sans',
                              fontSize: 16,
                              color: Color(0xff2E0536),
                            ),
                          ),
                        ),
                        // SizedBox(width: 2),
                        Container(
                          width: 16,
                          height: 16,
                          decoration: ShapeDecoration(
                            color: Colors.white,
                            shape: SmoothRectangleBorder(
                              borderRadius: SmoothBorderRadius(
                                cornerRadius: 7.0,
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
                            // side: BorderSide(
                            //   color: Colors.black,
                            //   width: 2.0,
                            // ),
                          ),
                          child: Center(
                            child: Container(
                              width: 9,
                              height: 9,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: dish.type == 'Veg'
                                    ? Color(0xff6EFD6B)
                                    : Color(0xffE23131),
                              ),
                            ),
                          ),
                        ),
                        Spacer(),
                        Text(
                          'Rs ${double.parse(dish.price).toStringAsFixed(0)}',
                          style: TextStyle(
                              fontSize: 14.0,
                              fontFamily: 'Product Sans',
                              color: Color(0xff9428A9),
                              fontWeight: FontWeight.bold),
                          textAlign: TextAlign.right,
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 5),
                  Row(
                    children: [
                      Text(
                        dish.store_name,
                        style: TextStyle(
                          color: Color(0xff9428A9),
                          fontFamily: 'Product Sans',
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                      SizedBox(
                        width: 10,
                      ),
                      Text(
                        '${double.parse(dish.distance_km).toStringAsFixed(2)} km',
                        style: TextStyle(
                          color: Color(0xffFA6E00),
                          fontFamily: 'Product Sans',
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 5),
                  Text(
                    dish.description,
                    style: TextStyle(
                      color: Color(0xff9428A9),
                      fontFamily: 'Product Sans',
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
  }
}
