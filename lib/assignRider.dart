import 'package:cloudbelly_app/api_service.dart';
import 'package:figma_squircle/figma_squircle.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

class DeliveryStatusScreen extends StatefulWidget {
  final ScrollController scrollController;

  DeliveryStatusScreen({required this.scrollController});

  @override
  _DeliveryStatusScreenState createState() => _DeliveryStatusScreenState();
}

class _DeliveryStatusScreenState extends State<DeliveryStatusScreen> {
  @override
  void initState() {
    super.initState();

    // Close modal when scroll reaches the top
    widget.scrollController.addListener(() {
      if (widget.scrollController.position.pixels == 0) {
        Navigator.of(context).pop();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xff0A4C61).withOpacity(0.49),
      body: Consumer<Auth>(
        builder: (context, itemProvider, child) {
          return itemProvider.deliveryStatus.isNotEmpty
              ? Container(
                  child: ListView.builder(
                    controller: widget.scrollController,
                    itemCount: itemProvider.deliveryStatus.length,
                    itemBuilder: (context, index) {
                      final notification = itemProvider.deliveryStatus[index];
                      return DeliveryStatusCard(notification: notification);
                    },
                  ),
                )
              : Center(
                  child: Text(
                    'No delivery status available.',
                    style: TextStyle(color: Colors.white),
                  ),
                );
        },
      ),
    );
  }
}

class DeliveryStatusCard extends StatelessWidget {
  final Map<String, dynamic> notification;

  DeliveryStatusCard({required this.notification});

  @override
  Widget build(BuildContext context) {
    print("notificationnotificationnotif $notification");
    return Container(
      // margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      padding: const EdgeInsets.fromLTRB( 30, 25,30,0),
      decoration: ShapeDecoration(
        color: Color(0xff0A4C61),
        shape: SmoothRectangleBorder(
          borderRadius: SmoothBorderRadius(
            cornerRadius: 30.0,
            cornerSmoothing: 1,
          ),
        ),
        shadows: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            spreadRadius: 2,
            blurRadius: 10,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "ORDER #${notification['order_no']}",
                    style: TextStyle(
                      fontSize: 22,
                      color: Colors.white,
                      fontFamily: 'product Sans Black',
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    "To be delivered, ${notification['items'].length} items, Rs ${notification['total_price']}",
                    style: TextStyle(fontSize: 14, color: Color(0xff8BDFDD)),
                  ),
                ],
              ),
              Spacer(),
              if(notification['delivery_status']  == 'assigning' ||notification['delivery_status']  == 'not_assigned' )
              Container(
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                decoration: ShapeDecoration(
                    color: Color(0xff7CC1BF),
                    shape: SmoothRectangleBorder(
                      borderRadius: SmoothBorderRadius(
                        cornerRadius: 14.0,
                        cornerSmoothing: 1,
                      ),
                    ),
                    shadows: [
                      BoxShadow(
                        color: Color(0xff03303E).withOpacity(0.7),
                        blurRadius: 20,
                        offset: Offset(3, 6),
                      ),
                    ]
                    ),
                child: Text(
                 notification['delivery_status']  == 'assigning' ?'Looking for...':'Not assigned',
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      fontFamily: 'Product Sans'),
                ),
              ),
            ],
          ),
          SizedBox(height: 10),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Image.asset(
                'assets/images/Location_white.png',
                width: 16,
              ),
              SizedBox(
                width: 3.w,
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Deliver to ",
                    style: TextStyle(
                        fontSize: 14,
                        color: Color(0xffFA6E00),
                        fontFamily: 'Product Sans'),
                  ),
                  Text(
                    "${notification['customer_location']['hno']}  ${notification['customer_location']['location']}",
                    style: TextStyle(fontSize: 12, color: Color(0xff8BDFDD)),
                  ),
                ],
              ),
            ],
          ),
          SizedBox(height: 20),
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                GestureDetector(
                  onTap: () {
                    // Handle "Deliver manually" logic
                  },
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 25, vertical: 10),
                    decoration: ShapeDecoration(
                      color: Color(0xffFA6E00),
                      shape: SmoothRectangleBorder(
                        borderRadius: SmoothBorderRadius(
                          cornerRadius: 14.0,
                          cornerSmoothing: 1,
                        ),
                      ),
                      shadows: [
                      BoxShadow(
                        color: Color(0xff03303E).withOpacity(0.7),
                        blurRadius: 20,
                        offset: Offset(3, 6),
                      ),
                    ]
                    ),
                    child: Text(
                      "Deliver manually",
                      style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          fontFamily: 'Product Sans'),
                    ),
                  ),
                ),
                SizedBox(height: 4,),
                GestureDetector(
                  onTap: () {
                    // Handle "Cancel & refund" logic
                  },
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 25, vertical: 10),
                   
                      
                    
                    child: Text(
                      "Cancel & refund",
                      style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                          fontFamily: 'Product Sans'),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
