import 'package:cloudbelly_app/api_service.dart';
import 'package:cloudbelly_app/constants/assets.dart';
import 'package:cloudbelly_app/widgets/toast_notification.dart';
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
  bool showAllOrderNotifications = false;
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
    return items.map((item) => '${item['name']} x ${item['quantity']}').join(', ');
  }

  String timeAgo(String d) {
    final DateFormat formatter = DateFormat('EEE, dd MMM yyyy HH:mm:ss \'GMT\'');
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

  Widget buildNotificationList(String title, List<Map<String, dynamic>> notifications, bool showAll, bool isAccepted) {
    final List<Map<String, dynamic>> displayedNotifications = showAll
        ? notifications
        : notifications.take(4).toList();

    return notifications.isEmpty
        ? Container()
        : Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    if (notifications.length > 4)
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            if (title == 'Socials') {
                              showAllSocialNotifications = !showAllSocialNotifications;
                            } else {
                              showAllOrderNotifications = !showAllOrderNotifications;
                            }
                          });
                        },
                        child: Text(
                          showAll ? 'See less' : 'See all',
                          style: TextStyle(color: Theme.of(context).primaryColor),
                        ),
                      ),
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
                    margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
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
                          backgroundImage: NetworkImage(notification['seller_logo']),
                          radius: 20,
                        ),
                        SizedBox(width: 16.0),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "${notification['store_name']} ordered for RS ${notification['total_price']}",
                                style: TextStyle(fontSize: 14.0, fontWeight: FontWeight.bold),
                              ),
                              Text(
                                formatItems(notification['items']),
                                style: TextStyle(fontSize: 12.0, color: Colors.grey),
                              ),
                              Row(
                                children: [
                                  Text(
                                    timeAgo(notification['created_date']),
                                    style: const TextStyle(fontSize: 10.0, color: Color(0xFFFA6E00)),
                                  ),
                                  SizedBox(width: 20),
                                  GestureDetector(
                                    onTap: () async {
                                      print(notification);
                                      if (notification != null && notification['location'] != null && notification['location']['latitude'] != null) {
                                        final String googleMapsUrl = 'https://www.google.com/maps/search/?api=1&query=${notification['location']['latitude']},${notification['location']['longitude']}';
                                        if (await canLaunchUrl(Uri.parse(googleMapsUrl))) {
                                          await launchUrl(Uri.parse(googleMapsUrl));
                                        } else {
                                          throw 'Could not open the map.';
                                        }
                                      }
                                    },
                                    child: Icon(Icons.directions, size: 16),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        notification['status'] != 'delivered'
                            ? Row(
                                children: [
                                  Container(
                                    decoration: BoxDecoration(borderRadius: BorderRadius.circular(8), color: Colors.red),
                                    child: Icon(Icons.close, color: Colors.white),
                                  ),
                                  SizedBox(width: 10),
                                  GestureDetector(
                                    onTap: () async {
                                      try {
                                        await Provider.of<Auth>(context, listen: false).acceptOrder(
                                            notification['_id'], notification['user_id'], notification['order_from_user_id']);
                                      } catch (e) {
                                        TOastNotification().showErrorToast(context, e.toString());
                                      }
                                    },
                                    child: Container(
                                      decoration: BoxDecoration(borderRadius: BorderRadius.circular(8), color: Colors.green),
                                      child: Icon(Icons.check, color: Colors.white),
                                    ),
                                  ),
                                ],
                              )
                            : Container(
                                padding: EdgeInsets.fromLTRB(12, 6, 12, 6),
                                decoration: BoxDecoration(color: Color(0xff0A4C61), borderRadius: BorderRadius.circular(8)),
                                child: Text("Delivered", style: TextStyle(color: Colors.white, fontSize: 10)),
                              ),
                      ],
                    ),
                  );
                },
              ),
            ],
          );
  }

  Widget buildSocialNotificationList(String title, List notifications, bool showAll) {
    final List displayedNotifications = showAll ? notifications : notifications.take(4).toList();
    return notifications.isEmpty
        ? Container()
        : Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      title,
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    if (notifications.length > 4)
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            showAllSocialNotifications = !showAllSocialNotifications;
                          });
                        },
                        child: Text(
                          showAll ? 'See less' : 'See all',
                          style: TextStyle(color: Theme.of(context).primaryColor),
                        ),
                      ),
                  ],
                ),
              ),
              ListView.builder(
                physics: NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                itemCount: displayedNotifications.length,
                itemBuilder: (context, index) {
                  final notification = displayedNotifications[index];
                  return Container(
                    margin: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                    padding: EdgeInsets.all(16.0),
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
                          backgroundImage: AssetImage(Assets.appIcon),
                          radius: 20,
                        ),
                        SizedBox(width: 16.0),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                notification['notification']['title'],
                                style: TextStyle(fontSize: 12.0, fontWeight: FontWeight.bold),
                              ),
                              Text(
                                timeAgo(notification['timestamp']),
                                style: TextStyle(fontSize: 10.0, color: Colors.grey),
                              ),
                              Text(
                                notification['notification']['body'],
                                style: TextStyle(fontSize: 10.0, color: Colors.grey),
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
      body: Consumer<Auth>(
        builder: (context, itemProvider, child) {
          return itemProvider.orderDetails.isNotEmpty
              ? ListView(
                  children: [
                    SizedBox(height: 20),
                    Center(
                      child: Text(
                        "Notification & Orders",
                        style: TextStyle(color: Color(0xff0A4C61), fontFamily: 'Jost', fontWeight: FontWeight.w600, fontSize: 22),
                      ),
                    ),
                    SizedBox(height: 12),
                    buildSocialNotificationList('Socials', itemProvider.notificationDetails, showAllSocialNotifications),
                    if ((itemProvider.userData?['user_type'] ?? '') == 'Vendor')
                      buildNotificationList('Accepted Orders', itemProvider.acceptedOrders, showAllOrderNotifications, false),
                    if ((itemProvider.userData?['user_type'] ?? '') == 'Vendor')
                      buildNotificationList('Incoming Orders', itemProvider.incomingOrders, showAllOrderNotifications, true),
                    if ((itemProvider.userData?['user_type'] ?? '') == 'Vendor')
                      buildNotificationList('Completed Orders', itemProvider.completedOrders, showAllOrderNotifications, false),
                  ],
                )
              : Center(child: Text('No notifications available'));
        },
      ),
    );
  }
}
