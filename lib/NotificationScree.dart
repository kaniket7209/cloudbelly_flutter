import 'package:cloudbelly_app/api_service.dart';
import 'package:cloudbelly_app/constants/assets.dart';
import 'package:cloudbelly_app/widgets/space.dart';
import 'package:cloudbelly_app/widgets/toast_notification.dart';
import 'package:figma_squircle/figma_squircle.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
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
  bool showAllPaymentNotifications = false;
  int _selectedTabIndex = 0;
  final PageController _pageController = PageController();
  final ScrollController _scrollController = ScrollController();
  RefreshController _refreshController =
      RefreshController(initialRefresh: false);

  @override
  void initState() {
    super.initState();
    _fetchNotifications();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onTabTapped(int index) {
    setState(() {
      _selectedTabIndex = index;
      _pageController.animateToPage(
        index,
        duration: Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
      _scrollToSelectedTab();
    });
  }

  void _scrollToSelectedTab() {
    _scrollController.animateTo(
      _selectedTabIndex * 65.0,
      duration: Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  Future<void> _fetchNotifications() async {
    try {
      await Provider.of<Auth>(context, listen: false).getNotificationList();
    } catch (error) {
      print('Failed to fetch notifications: $error');
    }
  }

  Future<void> _onRefresh() async {
    try {
      await _fetchNotifications();
      _refreshController.refreshCompleted();
    } catch (error) {
      _refreshController.refreshFailed();
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

  Widget buildNotificationList(
      String title,
      List<Map<String, dynamic>> notifications,
      bool showAll,
      bool isAccepted,
      String user_type) {
    final List<Map<String, dynamic>> displayedNotifications =
        showAll ? notifications : notifications.take(10).toList();

    return notifications.isEmpty
        ? Container()
        : Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                        color: Colors.transparent,
                        fontSize: 18,
                        fontWeight: FontWeight.bold),
                  ),
                  if (notifications.length > 10)
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          if (title == 'Socials') {
                            showAllSocialNotifications =
                                !showAllSocialNotifications;
                          } else if (title == 'Accepted Orders') {
                            showAllAcceptedOrderNotifications =
                                !showAllAcceptedOrderNotifications;
                          } else if (title == 'Incoming Orders') {
                            showAllIncomingOrderNotifications =
                                !showAllIncomingOrderNotifications;
                          }
                        });
                      },
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            showAll ? 'See less' : 'See all',
                            style: const TextStyle(
                                color: Color(0xff0A4C61),
                                fontWeight: FontWeight.bold,
                                fontFamily: 'Product Sans'),
                          ),
                          SizedBox(width: 5),
                          Image.asset(
                            'assets/icons/next_arrow.png',
                            width: 10,
                          ),
                        ],
                      ),
                    )
                ],
              ),
              Column(
                children: List.generate(displayedNotifications.length, (index) {
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
                              NetworkImage(notification['buyer_logo']),
                          radius: 20,
                        ),
                        SizedBox(width: 16.0),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "${notification['buyer_store_name']}  |  Order no - ${notification['order_no']}  ( ${notification['payment_mode']} )",
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
                                      'assets/images/Navigation.png',
                                      width: 30,
                                      height: 30,
                                      fit: BoxFit.fill,
                                    ),
                                  ),
                                  GestureDetector(
                                    onTap: () async {
                                      final phoneNumber =
                                          notification['customer_phone'];
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
                                        'assets/images/Phone.png',
                                        width: 30,
                                        height: 30,
                                        fit: BoxFit.fill,
                                      ),
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
                                    decoration: ShapeDecoration(
                                      color: Color(0x000000).withOpacity(0.69),
                                      shape: SmoothRectangleBorder(
                                          borderRadius: SmoothBorderRadius(
                                        cornerRadius: 8,
                                        cornerSmoothing: 1,
                                      )),
                                    ),
                                    child: Text("Delivered",
                                        style: TextStyle(
                                            color: Colors.white, fontSize: 10)),
                                  ),
                      ],
                    ),
                  );
                }),
              )
            ],
          );
  }

  Widget buildSocialNotificationList(
      String title, List notifications, bool showAll, String user_type) {
    final List displayedNotifications =
        showAll ? notifications : notifications.take(10).toList();
    return notifications.isEmpty
        ? Container()
        : Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 1.0, horizontal: 16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                          color: Colors.transparent,
                          fontSize: 18,
                          fontWeight: FontWeight.bold),
                    ),
                    if (notifications.length > 10)
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            if (title == 'Socials') {
                              showAllSocialNotifications =
                                  !showAllSocialNotifications;
                            }
                          });
                        },
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              showAll ? 'See less' : 'See all',
                              style: TextStyle(
                                  color: Color(0xff0A4C61),
                                  fontWeight: FontWeight.bold,
                                  fontFamily: 'Product Sans'),
                            ),
                            SizedBox(width: 5),
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
              Column(
                children: List.generate(displayedNotifications.length, (index) {
                  final notification = displayedNotifications[index];
                  return Container(
                    margin: const EdgeInsets.symmetric(
                        vertical: 1.0, horizontal: 16.0),
                    padding: const EdgeInsets.all(16.0),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(15.0),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 35,
                          height: 35,
                          decoration: BoxDecoration(
                            boxShadow: [
                              BoxShadow(
                                color:
                                    Color(0x591F6F6D), // Color with 35% opacity
                                blurRadius: 10, // Blur amount
                                offset: Offset(0, 4), // X and Y offset
                              ),
                            ],
                            borderRadius: BorderRadius.circular(8),
                            image: DecorationImage(
                              image: NetworkImage(
                                  notification['msg']['from_profile_photo']),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        SizedBox(width: 16.0),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                notification['notification']['body'],
                                style: TextStyle(
                                  color: user_type == 'Customer'
                                      ? Color.fromARGB(255, 110, 20, 128)
                                      : Color(0xff0A4C61),
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12.0,
                                ),
                              ),
                              Text(
                                timeAgo(notification['timestamp']),
                                style: TextStyle(
                                    fontSize: 10.0, color: Color(0xfffFA6E00)),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                }),
              )
            ],
          );
  }

  @override
  Widget build(BuildContext context) {
    String? userType =
        Provider.of<Auth>(context, listen: false).userData?['user_type'];
    Color boxShadowColor;

    if (userType == 'Vendor') {
      boxShadowColor = const Color(0xff0A4C61);
    } else if (userType == 'Customer') {
      boxShadowColor = const Color(0xffBC73BC);
    } else if (userType == 'Supplier') {
      boxShadowColor = Color.fromARGB(0, 115, 188, 150);
    } else {
      boxShadowColor = const Color.fromRGBO(
          77, 191, 74, 0.6); // Default color if user_type is none of the above
    }

    return Scaffold(
      backgroundColor: Colors.white,
      body: Consumer<Auth>(
        builder: (context, itemProvider, child) {
          bool hasNotifications = itemProvider.notificationDetails.isNotEmpty ||
              itemProvider.acceptedOrders.isNotEmpty ||
              itemProvider.incomingOrders.isNotEmpty ||
              itemProvider.paymentDetails.isNotEmpty;

          return hasNotifications
              ? SmartRefresher(
                  onRefresh: _onRefresh,
                  controller: _refreshController,
                  enablePullDown: true,
                  enablePullUp: false,
                  child: Column(
                    children: [
                      SizedBox(height: 60),
                      Center(
                        child: Text(
                          "Notification & Orders",
                          style: TextStyle(
                            color: boxShadowColor,
                            fontFamily: 'Jost',
                            fontWeight: FontWeight.w600,
                            letterSpacing: 1,
                            fontSize: 22,
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        controller: _scrollController,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildTabItem('Socials', 0, boxShadowColor),
                              SizedBox(width: 30),
                              _buildTabItem(
                                  'Incoming Orders', 1, boxShadowColor),
                              SizedBox(width: 30),
                              _buildTabItem(
                                  'Ongoing Orders', 2, boxShadowColor),
                            ],
                          ),
                        ),
                      ),
                      Expanded(
                        child: PageView(
                          controller: _pageController,
                          onPageChanged: (index) {
                            setState(() {
                              _selectedTabIndex = index;
                              _scrollToSelectedTab();
                            });
                          },
                          children: [
                            _buildPageContent(
                              buildSocialNotificationList(
                                'Socials',
                                itemProvider.notificationDetails,
                                showAllSocialNotifications,
                                itemProvider.userData?['user_type'] ?? '',
                              ),
                            ),
                            _buildPageContent(
                              buildNotificationList(
                                'Incoming Orders',
                                itemProvider.incomingOrders,
                                showAllIncomingOrderNotifications,
                                false,
                                itemProvider.userData?['user_type'] ?? '',
                              ),
                            ),
                            _buildPageContent(
                              buildNotificationList(
                                'Ongoing Orders',
                                itemProvider.acceptedOrders +
                                    itemProvider.completedOrders,
                                showAllAcceptedOrderNotifications,
                                true,
                                itemProvider.userData?['user_type'] ?? '',
                              ),
                            ),
                          ],
                        ),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => PaymentScreen(),
                            ),
                          );
                        },
                        child: Text('Payment Verification'),
                      ),
                    ],
                  ),
                )
              : const Center(child: Text('No notifications available.'));
        },
      ),
    );
  }

  Widget _buildPageContent(Widget content) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(1.0),
        child: content,
      ),
    );
  }

  Widget _buildTabItem(String title, int index, Color boxShadowColor) {
    return GestureDetector(
      onTap: () => _onTabTapped(index),
      child: Column(
        children: [
          Text(
            title,
            style: TextStyle(
              color: _selectedTabIndex == index
                  ? boxShadowColor
                  : boxShadowColor, // change to grey to make inactive tab text  grey color
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          if (_selectedTabIndex == index)
            Align(
              alignment: Alignment.center,
              child: Container(
                margin: const EdgeInsets.only(top: 4.0),
                decoration: BoxDecoration(
                  color: Color(0xffFA6E00),
                  borderRadius: BorderRadius.circular(2.0),
                ),
                height: 4.0,
                child: IntrinsicWidth(
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.transparent,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class PaymentScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Payment Verification'),
      ),
      body: Consumer<Auth>(
        builder: (context, itemProvider, child) {
          return itemProvider.paymentVerifications.isNotEmpty
              ? ListView.builder(
                  itemCount: itemProvider.paymentVerifications.length,
                  itemBuilder: (context, index) {
                    final notification =
                        itemProvider.paymentVerifications[index];
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
                            backgroundImage: NetworkImage(
                                notification['transaction_image'] ?? ''),
                            radius: 20,
                          ),
                          SizedBox(width: 16.0),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "${notification['buyer_store_name'] ?? 'Unknown Store'} | Order no - ${notification['order_no'] ?? 0}",
                                  style: const TextStyle(
                                      fontSize: 14.0,
                                      fontFamily: 'Product Sans',
                                      color: Color(0xff0A4C61),
                                      fontWeight: FontWeight.bold),
                                ),
                                SizedBox(height: 1.0),
                                Text(
                                  "Amount: ${notification['amount'] ?? 0}",
                                  style: TextStyle(
                                      fontSize: 14.0,
                                      color: Color(0xff0A4C61),
                                      fontWeight: FontWeight.bold),
                                ),
                                Row(
                                  children: [
                                    Text(
                                      timeAgo(
                                          (notification['timestamp'] ?? '')),
                                      // "timeAgo ${(notification['timestamp'] ?? '')}",
                                      style: const TextStyle(
                                          fontSize: 10.0,
                                          color: Color(0xFFFA6E00)),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                )
              : Center(child: Text('No payment history available.'));
        },
      ),
    );
  }
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
