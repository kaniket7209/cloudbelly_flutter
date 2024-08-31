import 'package:cloudbelly_app/NotificationScree.dart';
import 'package:cloudbelly_app/api_service.dart';
import 'package:flutter/material.dart';
import 'package:figma_squircle/figma_squircle.dart';
import 'package:provider/provider.dart';

class UserDetailsModal extends StatefulWidget {
  final String title;
  final List<String> userIds;
  final String actionButtonText;
  final VoidCallback
      onReload; // Callback to trigger reload in the parent widget

  UserDetailsModal({
    required this.title,
    required this.userIds,
    required this.actionButtonText,
    required this.onReload, // Add this parameter
  });

  @override
  _UserDetailsModalState createState() => _UserDetailsModalState();
}

class _UserDetailsModalState extends State<UserDetailsModal> {
  late Future<List<dynamic>> _userDetails;

  @override
  void initState() {
    super.initState();
    _userDetails =
        Provider.of<Auth>(context, listen: false).getUserInfo(widget.userIds);
  }

  bool checkFollow(String userId) {
    List<dynamic> temp =
        Provider.of<Auth>(context, listen: false).userData?['followings'] ?? [];
    for (var user in temp) {
      if (user['user_id'] == userId) {
        return true;
      }
    }
    return false;
  }

  String timeOfEvent(String userId) {
    List<dynamic> temp =
        Provider.of<Auth>(context, listen: false).userData?['followings'] ?? [];
    for (var user in temp) {
      if (user['user_id'] == userId) {
        return "Followed ${timeAgo(user['followed_at'])}";
      }
    }
    return "";
  }

  void _toggleFollowStatus(String userId) async {
    final userProvider = Provider.of<Auth>(context, listen: false);
    final isFollowing = checkFollow(userId);

    if (isFollowing) {
      await userProvider.unfollow(userId);
    } else {
      await userProvider.follow(userId);
    }

    // Refresh the user details in the modal
    setState(() {
      _userDetails = userProvider.getUserInfo(widget.userIds);
    });

    // Trigger the parent widget's reload callback
    widget.onReload();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<dynamic>>(
      future: _userDetails,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text('Error fetching user data.'));
        }

        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(child: Text('No data found.'));
        }

        final users = snapshot.data!;

        return DraggableScrollableSheet(
          initialChildSize: 0.85,
          minChildSize: 0.3,
          maxChildSize: 0.85,
          builder: (_, controller) {
            return Container(
              decoration: ShapeDecoration(
                color: Colors.white,
                shape: SmoothRectangleBorder(
                  borderRadius: SmoothBorderRadius.only(
                    topLeft: SmoothRadius(cornerRadius: 20, cornerSmoothing: 1),
                    topRight:
                        SmoothRadius(cornerRadius: 20, cornerSmoothing: 1),
                  ),
                ),
              ),
              child: Column(
                children: [
                  SizedBox(height: 10),
                  Container(
                    width: 30,
                    height: 5,
                    decoration: BoxDecoration(
                      color: Color(0xffFA6E00),
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  SizedBox(height: 10),
                  Text(
                    widget.title,
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Color(0xff0A4C61),
                      fontFamily: 'Product Sans',
                    ),
                  ),
                  SizedBox(height: 20),
                  Expanded(
                    child: ListView.builder(
                      controller: controller,
                      itemCount: users.length,
                      itemBuilder: (context, index) {
                        final user = users[index];
                        final isFollowing = checkFollow(user['_id']);

                        return ListTile(
                          leading: Container(
                            width: 50, // Set width for the avatar
                            height: 50, // Set height for the avatar
                            decoration: ShapeDecoration(
                              color: Colors.grey[
                                  200], // Background color if no image is present
                              shape: SmoothRectangleBorder(
                                borderRadius: SmoothBorderRadius(
                                  cornerRadius:
                                      15, // Adjust this value for desired squircle effect
                                  cornerSmoothing: 1,
                                ),
                              ),
                              shadows: [
                                BoxShadow(
                                  color: Color(0xffA5C8C7).withOpacity(0.4),
                                  blurRadius: 10,
                                  offset: Offset(0, 4),
                                ),
                              ],
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(
                                  15), // Ensure the image matches the squircle shape
                              child: user['profile_photo'] != null
                                  ? Image.network(
                                      user['profile_photo'],
                                      fit: BoxFit.cover,
                                    )
                                  : Center(
                                      child: Text(
                                        user['store_name'].substring(0, 1),
                                        style: TextStyle(
                                            fontSize: 24,
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ),
                            ),
                          ),
                          title: Text(
                            user['store_name'],
                            style: TextStyle(
                              fontFamily: 'Product Sans',
                              fontSize: 16,
                              color: user['user_type'] == 'Customer'
                                  ? const Color(0xff2E0536)
                                  : const Color(0xff0A4C61),
                            ),
                          ),
                          subtitle: Text(
                              timeOfEvent(
                                user['_id'],
                              ),
                              style: TextStyle(
                                  fontFamily: 'Product Sans',
                                  fontSize: 12,
                                  color: Color(0xffFA6E00))),
                          trailing: ElevatedButton(
                            onPressed: () => _toggleFollowStatus(user['_id']),
                            style: ElevatedButton.styleFrom(
                              shape: SmoothRectangleBorder(
                                borderRadius: SmoothBorderRadius(
                                  cornerRadius: 12,
                                  cornerSmoothing: 1,
                                ),
                              ),
                              backgroundColor: isFollowing
                                  ? Color(0xffF14343)
                                  : Color(0xff0A4C61),
                            ),
                            child: Container(
                              child: Text(
                                isFollowing ? 'Unfollow' : 'Follow',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontFamily: 'Product Sans',
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
