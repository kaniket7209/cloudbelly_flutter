import 'package:cloudbelly_app/api_service.dart';
import 'package:flutter/material.dart';
import 'package:figma_squircle/figma_squircle.dart';
import 'package:provider/provider.dart';

class UserDetailsModal extends StatefulWidget {
  final String title;
  final List<String> userIds;
  final String actionButtonText;
  final VoidCallback onReload; // Callback to trigger reload in the parent widget

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
    _userDetails = Provider.of<Auth>(context, listen: false).getUserInfo(widget.userIds);
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
                    topRight: SmoothRadius(cornerRadius: 20, cornerSmoothing: 1),
                  ),
                ),
              ),
              child: Column(
                children: [
                  SizedBox(height: 10),
                  Container(
                    width: 40,
                    height: 5,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  SizedBox(height: 20),
                  Text(
                    widget.title,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  Expanded(
                    child: ListView.builder(
                      controller: controller,
                      itemCount: users.length,
                      itemBuilder: (context, index) {
                        final user = users[index];
                        final isFollowing = checkFollow(user['_id']);

                        return ListTile(
                          leading: CircleAvatar(
                            backgroundImage: user['profile_photo'] != null
                                ? NetworkImage(user['profile_photo'])
                                : null,
                            child: user['profile_photo'] == null
                                ? Text(user['store_name'].substring(0, 1))
                                : null,
                          ),
                          title: Text(user['store_name']),
                          subtitle: Text(user['user_type']),
                          trailing: ElevatedButton(
                            onPressed: () => _toggleFollowStatus(user['_id']),
                            style: ElevatedButton.styleFrom(
                              shape: SmoothRectangleBorder(
                                borderRadius: SmoothBorderRadius(
                                  cornerRadius: 12,
                                  cornerSmoothing: 1,
                                ),
                              ),
                              backgroundColor: isFollowing ? Colors.red : Colors.blue,
                            ),
                            child: Text(
                              isFollowing ? 'Unfollow' : 'Follow',
                              style: TextStyle(color: Colors.white),
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