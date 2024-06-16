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
    for (int i = 0; i < items.length; i += 1) {
      String line = items
          .skip(i)
          .take(1)
          .map((item) => '${item['name']} x ${item['quantity']}')
          .join(', ');
      formattedItems.add(line);
    }
    return formattedItems.join('\n');
  }
String oneItem(List<dynamic> items) {
    List<String> formattedItems = [];
    for (int i = 0; i < 1; i += 1) {
      String line = items
          .skip(i)
          .take(1)
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

    Color boxShadowColor;

    if (user_type == 'Vendor') {
      boxShadowColor = const Color(0xff0A4C61);
    } else if (user_type == 'Customer') {
      boxShadowColor = const Color(0xffBC73BC);
    } else if (user_type == 'Supplier') {
      boxShadowColor = Color.fromARGB(0, 115, 188, 150);
    } else {
      boxShadowColor = const Color.fromRGBO(
          77, 191, 74, 0.6); // Default color if user_type is none of the above
    }

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
                            style: TextStyle(
                                color: boxShadowColor,
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
                      decoration: ShapeDecoration(
                        color: Colors.white,
                        shape: SmoothRectangleBorder(
                          borderRadius: SmoothBorderRadius(
                            cornerRadius: 15.0,
                            cornerSmoothing: 1,
                          ),
                        ),
                        shadows: [
                          BoxShadow(
                            color: boxShadowColor.withOpacity(0.2),
                            spreadRadius: 2,
                            blurRadius: 10,
                            offset: Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Padding(
                        padding: EdgeInsets.all(2),
                        child: _buildActionButtons(
                            notification, isAccepted, boxShadowColor),
                      )
                     
                      );
                }),
              )
            ],
          );
  }
bool showFullItems = false;
  Widget _buildActionButtons(Map<String, dynamic> notification, bool isAccepted,
      Color boxShadowColor) {
    void handleStatusChange(String newStatus) async {
      try {
        await Provider.of<Auth>(context, listen: false).statusChange(
          notification['_id'],
          notification['user_id'],
          notification['order_from_user_id'],
          newStatus,
        );
        setState(() {}); // Trigger UI update
      } catch (e) {
        print("${e.toString()}");
      }
    }

    if (notification['status'] == 'Submitted') {
      return Row(
        // mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Buyer logo
        
          Container(
            width: 35,
            height: 35,
            decoration: ShapeDecoration(
              shape: SmoothRectangleBorder(
                borderRadius: SmoothBorderRadius(
                  cornerRadius: 8,
                  cornerSmoothing: 1,
                ),
              ),
              image: DecorationImage(
                image: NetworkImage(notification['buyer_logo']),
                fit: BoxFit.cover,
              ),
            ),
          ),
          SizedBox(width: 10.0),
          // Order details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  formatItems(notification['items']),
                  style: TextStyle(
                    fontSize: 14.0,
                    color: boxShadowColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  timeAgo(notification['created_date']),
                  style: TextStyle(
                    fontSize: 10.0,
                    color: Color(0xffFA6E00),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          // Map icon
          GestureDetector(
            onTap: () async {
              if (notification['location'] != null &&
                  notification['location']['latitude'] != null) {
                final String googleMapsUrl =
                    'https://www.google.com/maps/search/?api=1&query=${notification['location']['latitude']},${notification['location']['longitude']}';
                if (await canLaunch(googleMapsUrl)) {
                  await launch(googleMapsUrl);
                } else {
                  throw 'Could not open the map.';
                }
              }
            },
            
            child: Container(
              width: 30,
              height: 30,
              padding: EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                    color: boxShadowColor.withOpacity(0.2), // Color with 35% opacity
                    blurRadius: 10, // Blur amount
                    offset: Offset(0, 4), // X and Y offset
                  ),
                ],
              ),
              child: Image.asset(
                'assets/images/Location.png',
              ),
            ),
          ),
          SizedBox(width: 10.0),
          // Reject button
          GestureDetector(
            onTap: () async {
              try {
                await Provider.of<Auth>(context, listen: false).rejectOrder(
                    notification['_id'],
                    notification['user_id'],
                    notification['order_from_user_id']);
              } catch (e) {
                print("${e.toString()}");
              }
            },
            child: Container(
              width: 30,
              height: 30,
              decoration: BoxDecoration(
                color: const Color(0xFFFD4F4F),
                borderRadius: BorderRadius.circular(8),

                boxShadow: [
                  BoxShadow(
                    color: boxShadowColor.withOpacity(0.2), // Color with 35% opacity
                    blurRadius: 10, // Blur amount
                    offset: Offset(0, 4), // X and Y offset
                  ),
                ],
              ),
              child: Icon(Icons.close, color: Colors.white, size: 20),
            ),
          ),
          SizedBox(width: 10),
          // Accept button
          GestureDetector(
            onTap: () async {
              try {
                await Provider.of<Auth>(context, listen: false).acceptOrder(
                    notification['_id'],
                    notification['user_id'],
                    notification['order_from_user_id']);
              } catch (e) {
                print("${e.toString()}");
              }
            },
            child: Container(
              width: 30,
              height: 30,
              decoration: BoxDecoration(
                color: boxShadowColor,
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                    color: boxShadowColor.withOpacity(0.2), // Color with 35% opacity
                    blurRadius: 10, // Blur amount
                    offset: Offset(0, 4), // X and Y offset
                  ),
                ],
              ),
              child: Icon(Icons.check, color: Colors.white, size: 20),
            ),
          ),
       


        ],
      );
    } 
    else if (notification['status'] == 'Accepted') {
      return Row(
        children: [
          // Buyer logo
          Container(
            width: 35,
            height: 35,
            decoration: ShapeDecoration(
              shape: SmoothRectangleBorder(
                borderRadius: SmoothBorderRadius(
                  cornerRadius: 8,
                  cornerSmoothing: 1,
                ),
              ),
              image: DecorationImage(
                image: NetworkImage(notification['buyer_logo']),
                fit: BoxFit.cover,
              ),
            ),
          ),
          SizedBox(width: 10.0),
          // Order details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                    showFullItems
                        ? formatItems(notification['items'])
                        : oneItem(notification['items']),
                    style: TextStyle(
                      fontSize: 14.0,
                      color: boxShadowColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        showFullItems = !showFullItems;
                      });
                    },
                    child: Icon(
                      showFullItems
                          ? Icons.keyboard_arrow_up
                          : Icons.keyboard_arrow_down,
                      color: boxShadowColor,
                    ),
                  ),
                Text(
                  timeAgo(notification['created_date']),
                  style: TextStyle(
                    fontSize: 10.0,
                    color: Color(0xffFA6E00),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: 40),
          // Complete button
          GestureDetector(
            onTap: () => handleStatusChange('Prepared'),
            child: Container(
              padding: EdgeInsets.all(10),
              decoration: ShapeDecoration(
                color: boxShadowColor,
                shape: SmoothRectangleBorder(
                  borderRadius: SmoothBorderRadius(
                    cornerRadius: 10,
                    cornerSmoothing: 1,
                  ),
                ),
              ),
              child: Text(
                'Complete',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ),
        ],
      );
   
    } 
    else if (notification['status'] == 'Prepared') {
      return Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  formatItems(notification['items']),
                  style: TextStyle(
                    fontSize: 14.0,
                    color: boxShadowColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  timeAgo(notification['created_date']),
                  style: TextStyle(
                    fontSize: 10.0,
                    color: Color(0xffFA6E00),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          // Packed button
          GestureDetector(
            onTap: () => handleStatusChange('Packed'),
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Color(0xFF0A4C61),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                "Packed",
                style: TextStyle(color: Colors.white, fontSize: 10),
              ),
            ),
          ),
        ],
      );
    } else if (notification['status'] == 'Packed') {
      return Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  formatItems(notification['items']),
                  style: TextStyle(
                    fontSize: 14.0,
                    color: boxShadowColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  timeAgo(notification['created_date']),
                  style: TextStyle(
                    fontSize: 10.0,
                    color: Color(0xffFA6E00),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          // Out for delivery button
          GestureDetector(
            onTap: () => handleStatusChange('Out for delivery'),
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Color(0xFF0A4C61),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                "Out for delivery",
                style: TextStyle(color: Colors.white, fontSize: 10),
              ),
            ),
          ),
        ],
      );
    } else if (notification['status'] == 'Out for delivery') {
      return Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  formatItems(notification['items']),
                  style: TextStyle(
                    fontSize: 14.0,
                    color: boxShadowColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  timeAgo(notification['created_date']),
                  style: TextStyle(
                    fontSize: 10.0,
                    color: Color(0xffFA6E00),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          // Delivered button
          GestureDetector(
            onTap: () => handleStatusChange('Delivered'),
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Color(0xFF0A4C61),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                "Delivered",
                style: TextStyle(color: Colors.white, fontSize: 10),
              ),
            ),
          ),
        ],
      );
    } else if (notification['status'] == 'Delivered') {
      return Container(
        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: Color(0xFF0A4C61),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          "Completed",
          style: TextStyle(color: Colors.white, fontSize: 10),
        ),
      );
    } else {
      return Container();
    }
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
                            boxShadow: const [
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
                                // itemProvider.acceptedOrders +
                                //     itemProvider.completedOrders,
                                itemProvider.ongoingOrders,
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
