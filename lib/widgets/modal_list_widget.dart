import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloudbelly_app/NotificationScree.dart';
import 'package:cloudbelly_app/api_service.dart';
import 'package:cloudbelly_app/constants/globalVaribales.dart';
import 'package:cloudbelly_app/screens/Tabs/Profile/profile_view.dart';
import 'package:flutter/material.dart';
import 'package:figma_squircle/figma_squircle.dart';
import 'package:provider/provider.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

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
                          leading: GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ProfileView(
                                    userIdList: [
                                      user['_id']
                                    ], // Adjust this according to your ProfileView constructor
                                  ),
                                ),
                              ).then((value) {
                                // You can clear the userId or perform any other actions here if needed
                              });
                            },
                            child: Container(
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
                                    color: Color(0xff1F6F6D).withOpacity(0.3),
                                    blurRadius: 15,
                                    offset: Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: ClipRRect(
                                borderRadius: SmoothBorderRadius(
                                    cornerRadius:
                                        15, // Adjust this value for desired squircle effect
                                    cornerSmoothing: 1,
                                  ), // Ensure the image matches the squircle shape
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
                          ),
                          title: Text(
                            user['store_name'],
                            style: TextStyle(
                              fontFamily: 'Product Sans',
                              fontWeight: FontWeight.w600,
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
                                  fontSize: 10,
                                  color: Color(0xffFA6E00))),
                          trailing: GestureDetector(
                            onTap: () => _toggleFollowStatus(user['_id']),
                            child: Container(
                              width: 22.w,
                              padding: EdgeInsets.symmetric(vertical: 10),
                              decoration: ShapeDecoration(
                                shadows: [
                                  BoxShadow(
                                    color:  isFollowing
                                    ? Color(0xff0A4C61).withOpacity(0.44)
                                    : Color(0xffE88037).withOpacity(0.5),
                                    blurRadius: 20,
                                    offset: Offset(5, 6),
                                    spreadRadius: 0,
                                  ),
                                ],
                                color: isFollowing
                                    ? Color(0xff0A4C61)
                                    : Color(0xffFA6E00),
                                shape: SmoothRectangleBorder(
                                  borderRadius: SmoothBorderRadius(
                                    cornerRadius: 13,
                                    cornerSmoothing: 1,
                                  ),
                                ),
                              ),
                              child: Text(
                                textAlign: TextAlign.center,
                                // isFollowing ? 'Unfollow' : 'Follow',
                                getButtonText(isFollowing,widget.title),
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
String getButtonText(bool isFollowing, String title) {
  if (title == 'Followings') {
    return 'Remove';
  } else {
    return isFollowing ? 'Unfollow' : 'Follow';
  }
}
}


Future<void> openFullScreen(
  BuildContext context,
  String imageUrl,
) async {
  await showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (BuildContext context) {
      return StatefulBuilder(
        builder: (BuildContext context, StateSetter setState) {
          return Container(
            decoration: const ShapeDecoration(
              shadows: [
                BoxShadow(
                  color: Color(0x7FB1D9D8),
                  blurRadius: 6,
                  offset: Offset(0, 4),
                  spreadRadius: 0,
                ),
              ],
              color: Colors.white,
              shape: SmoothRectangleBorder(
                borderRadius: SmoothBorderRadius.only(
                  topLeft: SmoothRadius(cornerRadius: 40, cornerSmoothing: 1),
                  topRight: SmoothRadius(cornerRadius: 40, cornerSmoothing: 1),
                ),
              ),
            ),
            height: MediaQuery.of(context).size.height * 0.58,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                GestureDetector(
                  onTap: () {
                    Navigator.of(context).pop();
                  },
                  child: Center(
                    child: Container(
                      margin: EdgeInsets.only(top: 10),
                      padding:
                          EdgeInsets.symmetric(vertical: 5, horizontal: 20),
                      width: 30,
                      height: 6,
                      decoration: BoxDecoration(
                        color: const Color(0xFFFA6E00).withOpacity(0.55),
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: Container(
                    margin: const EdgeInsets.fromLTRB(20, 13, 20, 20),
                    width: double.infinity,
                    decoration: ShapeDecoration(
                      shadows: [
                        BoxShadow(
                          color: Color(0xff0F3A47).withOpacity(0.45),
                          blurRadius: 25,
                          offset: Offset(3, 4),
                          spreadRadius: 0,
                        ),
                      ],
                      color: const Color.fromRGBO(239, 255, 254, 1),
                      shape: SmoothRectangleBorder(
                        borderRadius: SmoothBorderRadius(
                          cornerRadius: 30,
                          cornerSmoothing: 1,
                        ),
                      ),
                    ),
                    child: ClipSmoothRect(
                      radius: SmoothBorderRadius(
                        cornerRadius: 30,
                        cornerSmoothing: 1,
                      ),
                      child: CachedNetworkImage(
                        imageUrl: imageUrl,
                        fit: BoxFit.cover,
                        placeholder: (context, url) => GlobalVariables()
                            .imageloadingBuilderForImage(context, null),
                        errorWidget: (context, url, error) => GlobalVariables()
                            .imageErrorBuilderForImage(context, error, null),
                      ),
                    ),
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

Future<void> openLikedBy(BuildContext context, List<dynamic> likedData) async {
  if (likedData.isEmpty) {
    // Handle the case where the list is empty
    print("Liked data is empty");
    return;
  }

  await showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (BuildContext context) {
      return StatefulBuilder(
        builder: (BuildContext context, StateSetter setState) {
          return Container(
            decoration: const ShapeDecoration(
              shadows: [
                BoxShadow(
                  color: Color(0x7FB1D9D8),
                  blurRadius: 6,
                  offset: Offset(0, 4),
                  spreadRadius: 0,
                ),
              ],
              color: Colors.white,
              shape: SmoothRectangleBorder(
                borderRadius: SmoothBorderRadius.only(
                  topLeft: SmoothRadius(cornerRadius: 40, cornerSmoothing: 1),
                  topRight: SmoothRadius(cornerRadius: 40, cornerSmoothing: 1),
                ),
              ),
            ),
            height: MediaQuery.of(context).size.height * 0.58,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 10,),
                GestureDetector(
                  onTap: () {
                    Navigator.of(context).pop();
                  },
                  child: Center(
                    child: Container(
                      margin: EdgeInsets.only(top: 10),
                      padding:
                          EdgeInsets.symmetric(vertical: 5, horizontal: 20),
                      width: 50,
                      height: 6,
                      decoration: BoxDecoration(
                        color: const Color(0xFFFA6E00).withOpacity(0.55),
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 10,),
                Container(
                  alignment: Alignment.center,
                  child: Text(
                    "Liked by",
                    style: TextStyle(
                      fontSize: 24,
                      fontFamily: 'Product Sans',
                      fontWeight: FontWeight.bold,
                      color: Color(0xff0A4C61),
                    ),
                  ),
                ),
                if (likedData.isEmpty)
                  Center(
                    child: Text(
                      'No one has liked this yet.',
                      style: TextStyle(
                        fontSize: 16,
                        fontFamily: 'Product Sans',
                        color: Color(0xff1B7997),
                      ),
                    ),
                  )
                else
                  Expanded(
                    child: ListView.builder(
                      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                      itemCount: likedData.length,
                      itemBuilder: (context, index) {
                        final user = likedData[index];
                        return ListTile(
                          leading: Container(
                            width: 35,
                            height: 35,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              boxShadow: [
                                BoxShadow(
                                  color: Color(0xff1F6F6D).withOpacity(0.4),
                                  blurRadius: 20,
                                  offset: Offset(0, 4),
                                ),
                              ],
                              borderRadius: SmoothBorderRadius(
                                    cornerRadius:
                                        12, // Adjust this value for desired squircle effect
                                    cornerSmoothing: 1,
                                  ),
                            ),
                            clipBehavior: Clip.antiAlias,
                            child: Image.network(
                              user['profile_photo'],
                              fit: BoxFit.cover,
                            ),
                          ),
                          title: Text(
                            user['name'],
                            style: TextStyle(
                              fontSize: 16,
                              fontFamily: 'Product Sans',
                              color: Color(0xff0A4C61),
                              fontWeight: FontWeight.bold,
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



