import 'dart:async';
import 'dart:convert';
import 'package:cloudbelly_app/api_service.dart';
import 'package:figma_squircle/figma_squircle.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

class AssignDeliveryModal extends StatefulWidget {
  final int taskId;
  final String order_id;
  final String order_From_user_id;
  final String user_id;

  AssignDeliveryModal(this.taskId,this.order_id,this.user_id,this.order_From_user_id);

  @override
  _AssignDeliveryModalState createState() => _AssignDeliveryModalState();
}

class _AssignDeliveryModalState extends State<AssignDeliveryModal> {
  late Timer _timer;
  bool _isCompleted = false;
  String riderName = '';
  String riderContact = '';

  @override
  void initState() {
    super.initState();
    _startStatusCheck();
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  // Function to start the periodic check
  void _startStatusCheck() {
    int retryCount = 0; // Initialize retry counter
    const int maxRetries = 2; // Maximum number of retries (for 30 minute)

    // Periodically check the task status every 30 seconds
    _timer = Timer.periodic(Duration(seconds: 10), (timer) async {
      retryCount++;

      if (retryCount >= maxRetries) {
        _timer.cancel();
        showModalBottomSheet(
          context: context,
          builder: (BuildContext context) {
            return DeliveryPartnerNotAssignedModal(widget.taskId,widget.order_From_user_id,widget.user_id,widget.order_id);
          },
          isScrollControlled: true,
        );
        return; // Exit the function
      }

      var statusResponse = await _checkTaskStatus(widget.taskId);

      // Check the status and update the UI accordingly
      if (statusResponse['status_code'] == 'ALLOTTED' &&
          statusResponse['data']['rider_name'] != null &&
          statusResponse['data']['rider_contact'] != null) {
        setState(() {
          riderName = statusResponse['data']['rider_name'];
          riderContact = statusResponse['data']['rider_contact'];
          _isCompleted = true;
        });
        _timer.cancel(); // Stop the periodic timer if successful

        // Show the Delivery Partner Assigned Modal
        showModalBottomSheet(
          context: context,
          builder: (BuildContext context) {
            return DeliveryPartnerAssignedModal(riderName, riderContact);
          },
          isScrollControlled: true,
        );
      }
    });
  }

  // Simulated API webhook check
  Future<Map<String, dynamic>> _checkTaskStatus(int taskId) async {
    try {
      var res =
          await Provider.of<Auth>(context, listen: false).getTaskStatus(taskId);
      return jsonDecode(res); // Assuming the response is in JSON Map format
    } catch (e) {
      print("Error: $e");
      return {}; // Return an empty map in case of error
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 100.w,
      padding: EdgeInsets.all(16.0),
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
            topLeft: SmoothRadius(cornerRadius: 50, cornerSmoothing: 1),
            topRight: SmoothRadius(cornerRadius: 50, cornerSmoothing: 1),
          ),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(height: 5),
          Text(
            "Assigning delivery partner",
            style: TextStyle(
              fontSize: 36,
              color: Color(0xff0A4C61),
              fontWeight: FontWeight.w800,
              height: 1,
              fontFamily: 'Product Sans Black',
            ),
          ),
          SizedBox(height: 16),
          Container(
            width: 230,
            height: 230,
            child: Lottie.asset(
              'assets/Animation - 1718049075869.json',
              width: 230,
              height: 230,
              fit: BoxFit.fill,
            ),
          ),
          SizedBox(height: 16),

       
        ],
      ),
    );
  }
}

class DeliveryPartnerAssignedModal extends StatelessWidget {
  final String riderName;
  final String riderContact;

  DeliveryPartnerAssignedModal(this.riderName, this.riderContact);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.0),
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
            topLeft: SmoothRadius(cornerRadius: 50, cornerSmoothing: 1),
            topRight: SmoothRadius(cornerRadius: 50, cornerSmoothing: 1),
          ),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(height: 16),
          Text(
            "Delivery partner assigned",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              fontFamily: 'Product Sans',
            ),
          ),
          SizedBox(height: 16),
          Text(
            "Rider Name: $riderName",
            style: TextStyle(
              fontSize: 16,
              color: Colors.black,
              fontFamily: 'Product Sans',
            ),
          ),
          Text(
            "Contact: $riderContact",
            style: TextStyle(
              fontSize: 16,
              color: Colors.black,
              fontFamily: 'Product Sans',
            ),
          ),
          SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context); // Close the modal
            },
            child: Text("OK"),
          ),
        ],
      ),
    );
  }
}

class DeliveryPartnerNotAssignedModal extends StatelessWidget {
  final int taskId; 
  // Add taskId as a parameter
    final String order_id;
  final String order_from_user_id;
  final String user_id;

  DeliveryPartnerNotAssignedModal(this.taskId, this.order_id, this.order_from_user_id, this.user_id); // Constructor

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(25.0),
          topRight: Radius.circular(25.0),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(height: 16),
          Text(
            "Delivery partner not assigned",
            style: TextStyle(
              fontSize: 36,
              color: Color(0xff0A4C61),
              fontWeight: FontWeight.w800,
              height: 1,
              fontFamily: 'Product Sans Black',
            ),
          ),
          SizedBox(height: 16),
          Text(
            "We are sorry for the inconvenience, but no riders are available at this moment. You can opt for delivering it manually by booking a bike taxi from your end.",
            style: TextStyle(
              fontSize: 14,
              color: Color(0xff0A4C61),
              fontFamily: 'Product Sans',
            ),
          ),
          SizedBox(height: 30),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              GestureDetector(
                onTap: () {
                  // Handle manual delivery
                 Navigator.of(context).popUntil((route) => route.isFirst); // Close the modal
                },
                child: Container(
                    padding:
                        EdgeInsets.symmetric(horizontal: 5.w, vertical: 1.1.h),
                    decoration: ShapeDecoration(
                      shadows: [
                        BoxShadow(
                          offset: const Offset(3, 6),
                          color: Color(0xffFA6E00).withOpacity(0.45),
                          blurRadius: 30,
                        ),
                      ],
                      color: Color(0xffFA6E00),
                      shape: SmoothRectangleBorder(
                        borderRadius: SmoothBorderRadius(
                          cornerRadius: 13,
                          cornerSmoothing: 1,
                        ),
                      ),
                    ),
                    child: Text(
                      "Deliver manually",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontFamily: 'Product Sans',
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.14,
                      ),
                    )),
              ),
              GestureDetector(
                onTap: () async {
                  // Call the cancel task function
                  print("6802954  $taskId");
                  var response = await cancelTask(context,taskId,order_id,user_id,order_from_user_id);
                    Navigator.of(context).popUntil((route) => route.isFirst);
                  // if (response['status'] == true && response['status_code'] == 'CANCELLED') {
                  //   // Close all modals after successful cancellation
                  //   Navigator.of(context).popUntil((route) => route.isFirst);
                  // } else {
                  //   print("Failed to cancel the task: ${response['message']}");
                  // }
                },
                child: Container(
                    padding:
                        EdgeInsets.symmetric(horizontal: 5.w, vertical: 1.1.h),
                    decoration: ShapeDecoration(
                      shadows: [
                        BoxShadow(
                          offset: const Offset(3, 6),
                          color: Color(0xff0A4C61).withOpacity(0.5),
                          blurRadius: 30,
                        ),
                      ],
                      color: Color(0xff0A4C61),
                      shape: SmoothRectangleBorder(
                        borderRadius: SmoothBorderRadius(
                          cornerRadius: 13,
                          cornerSmoothing: 1,
                        ),
                      ),
                    ),
                    child: Text(
                      "Cancel & refund",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontFamily: 'Product Sans',
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.14,
                      ),
                    )),
              ),
            ],
          ),
          SizedBox(height: 20),
        ],
      ),
    );
  }

  // Function to cancel the delivery task
  Future<Map<String, dynamic>> cancelTask(BuildContext context,int taskId,order_from_user_id,order_id,user_id) async {
    try {
      print("order_from_user_id,user_id,order_id  $order_from_user_id $user_id  $order_id");
      var res = await Provider.of<Auth>(context, listen: false).cancelDeliveryTask(taskId,order_from_user_id,user_id,order_id);
      
      // Check response
      return jsonDecode(res); // Assuming the response is in JSON format
    } catch (e) {
      print("Error canceling task: $e");
      return {'status': false, 'message': 'Error canceling task'};
    }
  }
}
