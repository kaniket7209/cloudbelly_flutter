import 'package:cloudbelly_app/api_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:figma_squircle/figma_squircle.dart';

class UserDetailsModal extends StatefulWidget {
  final String title;
  final List<String> userIds;
  final String actionButtonText;
  final VoidCallback? onActionButtonPressed;

  UserDetailsModal({
    required this.title,
    required this.userIds,
    required this.actionButtonText,
    this.onActionButtonPressed,
  });

  @override
  _UserDetailsModalState createState() => _UserDetailsModalState();
}

class _UserDetailsModalState extends State<UserDetailsModal> {
  List<dynamic> users = [];
  bool isLoading = true;
  bool hasError = false;

  @override
  void initState() {
    super.initState();
    _fetchUserDetails();
  }

  Future<void> _fetchUserDetails() async {
    try {
      final userProvider = Provider.of<Auth>(context, listen: false);
      List<dynamic> fetchedUsers = await userProvider.getUserInfo(widget.userIds);

      setState(() {
        users = fetchedUsers;
        isLoading = false;
      });
    } catch (error) {
      setState(() {
        hasError = true;
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.85, // Start from top
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
                child: isLoading
                    ? Center(child: CircularProgressIndicator())
                    : hasError
                        ? Center(child: Text('Error fetching user data.'))
                        : ListView.builder(
                            controller: controller,
                            itemCount: users.length,
                            itemBuilder: (context, index) {
                              final user = users[index];
                              return ListTile(
                                leading: CircleAvatar(
                                  backgroundImage: user['profile_photo'] != null
                                      ? NetworkImage(user['profile_photo'])
                                      : null,
                                  child: user['profile_photo'] == null
                                      ? Text(user['store_name']?.substring(0, 1) ?? '')
                                      : null,
                                ),
                                title: Text(user['store_name'] ?? ''),
                                subtitle: Text(user['user_name'] ?? ''),
                                trailing: ElevatedButton(
                                  onPressed: widget.onActionButtonPressed,
                                  style: ElevatedButton.styleFrom(
                                    shape: SmoothRectangleBorder(
                                      borderRadius: SmoothBorderRadius(
                                        cornerRadius: 12,
                                        cornerSmoothing: 1,
                                      ),
                                    ),
                                    backgroundColor: Colors.blue,
                                  ),
                                  child: Text(
                                    widget.actionButtonText,
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
  }
}