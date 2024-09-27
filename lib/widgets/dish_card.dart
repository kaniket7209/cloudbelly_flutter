// lib/widgets/dish_card.dart
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloudbelly_app/constants/globalVaribales.dart';
import 'package:cloudbelly_app/screens/Tabs/Profile/profile_view.dart';
import 'package:cloudbelly_app/widgets/modal_list_widget.dart';
import 'package:figma_squircle/figma_squircle.dart';
import 'package:flutter/material.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import '../models/dish.dart';

class DishCard extends StatelessWidget {
  final Dish dish;
  final bool darkMode;

  DishCard({required this.dish, required this.darkMode});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 0.0, horizontal: 10.0),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            GestureDetector(
              onTap: () {
                openFullScreen(context, dish.images.first);
              },
              child: Container(
                height: 155,
                width: 130,
                 decoration: ShapeDecoration(
                  color:darkMode?Color(0xff000000).withOpacity(0.47): Colors.white,
                  shape: SmoothRectangleBorder(
                    borderRadius: SmoothBorderRadius(
                      cornerRadius: 22.0,
                      cornerSmoothing: 1,
                    ),
                  ),
                  shadows: [
                    BoxShadow(
                      color: darkMode
                          ? Color(0xff000000).withOpacity(0.47)
                          : const Color.fromRGBO(130, 47, 130, 1)
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
                      : Container(
                          decoration: const BoxDecoration(
                            shape: BoxShape.rectangle,
                            gradient: LinearGradient(
                              colors: [
                                Color.fromRGBO(39, 39, 39, 1),
                                Color.fromRGBO(74, 74, 74, 1),
                              ],
                              begin: Alignment.bottomCenter,
                              end: Alignment.topCenter,
                            ),
                          ),
                          padding: EdgeInsets.symmetric(horizontal: 2.w),
                          alignment: Alignment.center,
                          // color:darkMode? Color(0xfff313030):Colors.white,
                          child: Center(
                            child: Text(
                              textAlign: TextAlign.center,
                              dish.name.toUpperCase(),
                              style: TextStyle(
                                  fontSize: 20,
                                  color: 
                                      Colors.white.withOpacity(0.7),
                                  fontFamily: 'Ubuntu',
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
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
                  SizedBox(
                    height: 1.h,
                  ),
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
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: MediaQuery.of(context).size.width * 0.3,
                          child: Text(
                            dish.name,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontFamily: 'Product Sans',
                              fontSize: 17,
                              color:
                                  darkMode ? Colors.white : Color(0xff2E0536),
                            ),
                          ),
                        ),
                        // SizedBox(width: 2),
                        Column(
                          children: [
                            SizedBox(
                              height: 0.5.h,
                            ),
                            Container(
                              width: 16,
                              height: 16,

                              // decoration:ShapeDecoration(
                              //   color: Colors.white,
                              //   shape: SmoothRectangleBorder(
                              //     borderRadius: SmoothBorderRadius(
                              //       cornerRadius: 7.0,
                              //       cornerSmoothing: 1,
                              //     ),
                              //   ),
                              //   shadows: [
                              //     BoxShadow(
                              //       color: Colors.grey.withOpacity(0.2),
                              //       spreadRadius: 1,
                              //       blurRadius: 7,
                              //       offset: Offset(0, 3),
                              //     ),
                              //   ],
                              //   // side: BorderSide(
                              //   //   color: Colors.black,
                              //   //   width: 2.0,
                              //   // ),
                              // ),
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
                          ],
                        ),
                        Spacer(),
                        Text(
                          'Rs ${double.parse(dish.price).toStringAsFixed(0)}',
                          style: TextStyle(
                              fontSize: 18.0,
                              fontFamily: 'Ubuntu',
                              color: darkMode
                                  ? Color(0xffFA6E00)
                                  : Color(0xff9428A9),
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
                          color:
                              darkMode ? Color(0xffB1F0EF) : Color(0xff9428A9),
                          fontFamily: 'Product Sans',
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      Spacer(),
                      Text(
                        '${double.parse(dish.distance_km).toStringAsFixed(2)} km',
                        style: TextStyle(
                          color:
                              darkMode ? Color(0xff54A6C1) : Color(0xffFA6E00),
                          fontFamily: 'Product Sans',
                          // fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 5),
                  Text(
                    dish.description,
                    style: TextStyle(
                      color: darkMode ? Color(0xffB1F0EF) : Color(0xff9428A9),
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
