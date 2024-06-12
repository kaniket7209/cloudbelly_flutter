import 'package:cloudbelly_app/api_service.dart';
import 'package:cloudbelly_app/constants/assets.dart';
import 'package:cloudbelly_app/widgets/space.dart';
import 'package:cloudbelly_app/widgets/toast_notification.dart';
import 'package:figma_squircle/figma_squircle.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:toastification/toastification.dart';
import 'package:url_launcher/url_launcher.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({Key? key}) : super(key: key);

  @override
  _NotificationScreenState createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  bool showAllSocialNotifications = false;
  bool showAllAcceptedOrderNotifications = false;
  bool showAllIncomingOrderNotifications = false;
  bool showAllCompletedOrderNotifications = false;
  bool showAllPaymentNotifications = false;

  @override
  void initState() {
    super.initState();
    _fetchNotifications();
  }

  Future<void> _fetchNotifications() async {
    try {
      await Provider.of<Auth>(context, listen: false).getNotificationList();
    } catch (error) {
      print('Failed to fetch notifications: $error');
    }
  }

  String formatItems(List<dynamic> items) {
    List<String> formattedItems = [];
    for (int i = 0; i < items.length; i += 2) {
      String line = items
          .skip(i)
          .take(2)
          .map((item) => '${item['name']} x ${item['quantity']}')
          .join(', ');
      formattedItems.add(line);
    }
    return formattedItems.join('\n');
  }

  String timeAgo(String d) {
    final DateFormat formatter =
        DateFormat('EEE, dd MMM yyyy HH:mm:ss \'GMT\'');
    var date = formatter.parseUtc(d);
    final Duration difference = DateTime.now().difference(date);

    if (difference.inSeconds < 20) {
      return 'just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes} minute${difference.inMinutes == 1 ? '' : 's'} ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours} hour${difference.inHours == 1 ? '' : 's'} ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} day${difference.inDays == 1 ? '' : 's'} ago';
    } else if (difference.inDays < 30) {
      final int weeks = (difference.inDays / 7).floor();
      return '$weeks week${weeks == 1 ? '' : 's'} ago';
    } else if (difference.inDays < 365) {
      final int months = (difference.inDays / 30).floor();
      return '$months month${months == 1 ? '' : 's'} ago';
    } else {
      final int years = (difference.inDays / 365).floor();
      return '$years year${years == 1 ? '' : 's'} ago';
    }
  }

  Widget buildNotificationList(String title,
      List<Map<String, dynamic>> notifications, bool showAll, bool isAccepted) {
    final List<Map<String, dynamic>> displayedNotifications = showAll
        ? notifications.take(0).toList()
        : notifications; // Changed to 2 for testing

    // Debug print statements
    print(
        "Title: $title, Notifications Length: ${notifications.length}, ShowAll: $showAll");

    return notifications.isEmpty
        ? Container()
        : Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                          color: Color(0xff0A4C61),
                          fontSize: 18,
                          fontWeight: FontWeight.bold),
                    ),
                    if (notifications.length > 0) // Changed to 2 for testing
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            print("Toggling showAll for $title");
                            if (title == 'Socials') {
                              showAllSocialNotifications =
                                  !showAllSocialNotifications;
                            } else if (title == 'Accepted Orders') {
                              showAllAcceptedOrderNotifications =
                                  !showAllAcceptedOrderNotifications;
                            } else if (title == 'Incoming Orders') {
                              showAllIncomingOrderNotifications =
                                  !showAllIncomingOrderNotifications;
                            } else if (title == 'Completed Orders') {
                              showAllCompletedOrderNotifications =
                                  !showAllCompletedOrderNotifications;
                            } else if (title == 'Payment Verification') {
                              showAllPaymentNotifications =
                                  !showAllPaymentNotifications;
                            }
                          });
                        },
                        child: Row(
                          mainAxisSize: MainAxisSize
                              .min, // Ensures the row takes up the minimum space needed
                          children: [
                            Text(
                              showAll ? 'See all' : 'See less',
                              style: TextStyle(
                                  color: Color(0xff0A4C61),
                                  fontWeight: FontWeight.bold,
                                  fontFamily: 'Product Sans'),
                            ),
                            SizedBox(
                                width:
                                    5), // Add some space between the text and the icon if needed
                            Image.asset(
                              'assets/icons/next_arrow.png',
                              width: 10,
                            ),
                          ],
                        ),
                      )
                  ],
                ),
              ),
              ListView.builder(
                physics: const NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                itemCount: displayedNotifications.length,
                itemBuilder: (context, index) {
                  final notification = displayedNotifications[index];
                  return Container(
                    margin: const EdgeInsets.symmetric(
                        vertical: 8.0, horizontal: 16.0),
                    padding: const EdgeInsets.all(16.0),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(15.0),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.2),
                          spreadRadius: 1,
                          blurRadius: 7,
                          offset: Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        CircleAvatar(
                          backgroundImage:
                              NetworkImage(notification['seller_logo']),
                          radius: 20,
                        ),
                        SizedBox(width: 16.0),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "${notification['store_name']}  |  Order no - ${notification['order_no']} ",
                                style: const TextStyle(
                                    fontSize: 14.0,
                                    fontFamily: 'Product Sans',
                                    color: Color(0xff0A4C61),
                                    fontWeight: FontWeight.bold),
                              ),
                              SizedBox(height: 1.0),
                              Text(
                                formatItems(notification['items']),
                                style: TextStyle(
                                    fontSize: 14.0,
                                    color: Color(0xff0A4C61),
                                    fontWeight: FontWeight.bold),
                              ),
                              Row(
                                children: [
                                  Text(
                                    timeAgo(notification['created_date']),
                                    style: const TextStyle(
                                        fontSize: 10.0,
                                        color: Color(0xFFFA6E00)),
                                  ),
                                  SizedBox(width: 20),
                                  GestureDetector(
                                    onTap: () async {
                                      if (notification['location'] != null &&
                                          notification['location']
                                                  ['latitude'] !=
                                              null) {
                                        final String googleMapsUrl =
                                            'https://www.google.com/maps/search/?api=1&query=${notification['location']['latitude']},${notification['location']['longitude']}';
                                        if (await canLaunchUrl(
                                            Uri.parse(googleMapsUrl))) {
                                          await launchUrl(
                                              Uri.parse(googleMapsUrl));
                                        } else {
                                          throw 'Could not open the map.';
                                        }
                                      }
                                    },
                                    child: Image.asset(
                                        'assets/images/Navigation.png',width: 30,height: 30,fit: BoxFit.fill,),
                                  ),
                                  GestureDetector(
                                  
                                    onTap: () async {
                                      final phoneNumber = notification['customer_phone'];
                                      final url = 'tel:$phoneNumber';
                                      if (await canLaunch(url)) {
                                        await launch(url);
                                      } else {
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          const SnackBar(
                                              content: Text(
                                                  'Could not launch phone call')),
                                        );
                                      }
                                    },
                                    child: CircleAvatar(
                                      radius: 10,
                                      backgroundColor: const Color(0xFFFA6E00),
                                      child: Image.asset(
                                          'assets/images/Phone.png',width: 30,height: 30,fit: BoxFit.fill,),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        notification['status'] == 'Submitted'
                            ? Column(
                                children: [
                                  Center(
                                    child: Text(
                                        "RS ${notification['total_price']}",
                                        style: const TextStyle(
                                            color: Color(0xff0A4C61),
                                            fontSize: 14,
                                            fontWeight: FontWeight.bold)),
                                  ),
                                  SizedBox(height: 10),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceAround,
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      GestureDetector(
                                        onTap: () async {
                                          try {
                                            await Provider.of<Auth>(context,
                                                    listen: false)
                                                .rejectOrder(
                                                    notification['_id'],
                                                    notification['user_id'],
                                                    notification[
                                                        'order_from_user_id']);
                                          } catch (e) {
                                            print("${e.toString()}");
                                          }
                                        },
                                        child: Container(
                                          width: 30,
                                          decoration: ShapeDecoration(
                                            color: const Color(0xFFFD4F4F),
                                            shape: SmoothRectangleBorder(
                                              borderRadius: SmoothBorderRadius(
                                                cornerRadius: 10,
                                                cornerSmoothing: 1,
                                              ),
                                            ),
                                          ),
                                          child: Image.asset(
                                              'assets/images/Multiply.png'),
                                        ),
                                      ),
                                      SizedBox(width: 10),
                                      GestureDetector(
                                        onTap: () async {
                                          try {
                                            await Provider.of<Auth>(context,
                                                    listen: false)
                                                .acceptOrder(
                                                    notification['_id'],
                                                    notification['user_id'],
                                                    notification[
                                                        'order_from_user_id']);
                                          } catch (e) {
                                            print("${e.toString()}");
                                          }
                                        },
                                        child: Container(
                                          width: 30,
                                          decoration: ShapeDecoration(
                                            color: const Color(0xFF1ACD0A),
                                            shape: SmoothRectangleBorder(
                                              borderRadius: SmoothBorderRadius(
                                                cornerRadius: 10,
                                                cornerSmoothing: 1,
                                              ),
                                            ),
                                          ),
                                          child: Image.asset(
                                              'assets/images/Done.png'),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              )
                            : notification['status'] == 'Accepted'
                                ? Column(
                                    children: [
                                      Center(
                                        child: Text(
                                          "Rs ${notification['amount']}",
                                          style: const TextStyle(
                                              fontSize: 15.0,
                                              fontFamily: 'Product Sans',
                                              color: Color(0xff0A4C61),
                                              fontWeight: FontWeight.bold),
                                        ),
                                      ),
                                      Space(10),
                                      GestureDetector(
                                        onTap: () async {
                                          try {
                                            await Provider.of<Auth>(context,
                                                    listen: false)
                                                .markOrderAsDelivered(
                                                    notification['_id'],
                                                    notification['user_id'],
                                                    notification[
                                                        'order_from_user_id']);
                                          } catch (e) {
                                            print("${e.toString()}");
                                          }
                                        },
                                        child: Container(
                                          child: Icon(
                                              Icons.local_shipping_rounded,
                                              color: Color(0xff0A4C61)),
                                        ),
                                      ),
                                    ],
                                  )
                                : Container(
                                    padding: EdgeInsets.fromLTRB(12, 6, 12, 6),
                                    decoration: BoxDecoration(
                                        color: Color(0xff0A4C61),
                                        borderRadius: BorderRadius.circular(8)),
                                    child: Text("Delivered",
                                        style: TextStyle(
                                            color: Colors.white, fontSize: 10)),
                                  ),
                      ],
                    ),
                  );
                },
              ),
            ],
          );
  }

  Widget buildSocialNotificationList(
      String title, List notifications, bool showAll) {
    final List displayedNotifications =
        showAll
         ? notifications
         : notifications.take(3).toList();
    return notifications.isEmpty
        ? Container()
        : Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                          fontSize: 18,
                          color: Color(0xff0A4C61),
                          fontWeight: FontWeight.bold),
                    ),
                    if (notifications.length > 3)
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            print("Toggling showAll for $title");
                            if (title == 'Socials') {
                              showAllSocialNotifications =
                                  !showAllSocialNotifications;
                            } else if (title == 'Accepted Orders') {
                              showAllAcceptedOrderNotifications =
                                  !showAllAcceptedOrderNotifications;
                            } else if (title == 'Incoming Orders') {
                              showAllIncomingOrderNotifications =
                                  !showAllIncomingOrderNotifications;
                            } else if (title == 'Completed Orders') {
                              showAllCompletedOrderNotifications =
                                  !showAllCompletedOrderNotifications;
                            } else if (title == 'Payment Verification') {
                              showAllPaymentNotifications =
                                  !showAllPaymentNotifications;
                            }
                          });
                        },
                        child: Row(
                          mainAxisSize: MainAxisSize
                              .min, // Ensures the row takes up the minimum space needed
                          children: [
                            Text(
                              showAll ? 'See less' : 'See all',
                              style: TextStyle(
                                  color: Color(0xff0A4C61),
                                  fontWeight: FontWeight.bold,
                                  fontFamily: 'Product Sans'),
                            ),
                            SizedBox(
                                width:
                                    5), // Add some space between the text and the icon if needed
                            Image.asset(
                              'assets/icons/next_arrow.png',
                              width: 10,
                            ),
                          ],
                        ),
                      )
                  ],
                ),
              ),
              ListView.builder(
                physics: NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                itemCount: displayedNotifications.length,
                itemBuilder: (context, index) {
                  final notification = displayedNotifications[index];
                  print("nott $notification");
                  return Container(
                    margin: const EdgeInsets.symmetric(
                        vertical: 8.0, horizontal: 16.0),
                    padding: const EdgeInsets.all(16.0),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(15.0),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.white.withOpacity(0.2),
                          spreadRadius: 1,
                          blurRadius: 7,
                          offset: Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        CircleAvatar(
                          backgroundImage:
                              notification['msg']['from_profile_photo'] != ''
                                  ? NetworkImage(notification['msg']
                                      ['from_profile_photo']) as ImageProvider
                                  : AssetImage(Assets.appIcon),
                          radius: 20,
                        ),
                        SizedBox(width: 16.0),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                notification['notification']['title'],
                                style: const TextStyle(
                                    fontSize: 12.0,
                                    fontWeight: FontWeight.bold),
                              ),
                              Text(
                                timeAgo(notification['timestamp']),
                                style: TextStyle(
                                    fontSize: 10.0, color: Colors.grey),
                              ),
                              Text(
                                notification['notification']['body'],
                                style: TextStyle(
                                    fontSize: 10.0, color: Colors.grey),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ],
          );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Consumer<Auth>(
        builder: (context, itemProvider, child) {
          print("itemProvider.userData ${itemProvider.userData}");
          return itemProvider.orderDetails.isNotEmpty
              ? ListView(
                  children: [
                    SizedBox(height: 20),
                    const Center(
                      child: Text(
                        "Notification & Orders",
                        style: TextStyle(
                            color: Color(0xff0A4C61),
                            fontFamily: 'Jost',
                            fontWeight: FontWeight.w600,
                            fontSize: 22),
                      ),
                    ),
                    const SizedBox(height: 12),
                    buildSocialNotificationList(
                        'Socials',
                        itemProvider.notificationDetails,
                        showAllSocialNotifications),
                    if ((itemProvider.userData?['user_type'] ?? '') == 'Vendor')
                      buildNotificationList(
                          'Accepted Orders',
                          itemProvider.acceptedOrders,
                          showAllAcceptedOrderNotifications,
                          false),
                    if ((itemProvider.userData?['user_type'] ?? '') == 'Vendor')
                      buildNotificationList(
                          'Incoming Orders',
                          itemProvider.incomingOrders,
                          showAllIncomingOrderNotifications,
                          false),
                    if ((itemProvider.userData?['user_type'] ?? '') == 'Vendor')
                      buildNotificationList(
                          'Completed Orders',
                          itemProvider.completedOrders,
                          showAllCompletedOrderNotifications,
                          false),
                    buildSocialNotificationList(
                        'Payment Verification',
                        itemProvider.paymentDetails,
                        showAllPaymentNotifications),
                  ],
                )
              : Center(child: Text('No notifications available'));
        },
      ),
    );
  }
}
