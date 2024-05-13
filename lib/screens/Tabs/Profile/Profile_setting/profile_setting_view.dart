import 'dart:ui';

import 'package:cloudbelly_app/api_service.dart';
import 'package:cloudbelly_app/constants/assets.dart';
import 'package:cloudbelly_app/constants/enums.dart';
import 'package:cloudbelly_app/constants/globalVaribales.dart';
import 'package:cloudbelly_app/prefrence_helper.dart';
import 'package:cloudbelly_app/screens/Login/login_screen.dart';
import 'package:cloudbelly_app/screens/Tabs/Cart/google_map_screen.dart';
import 'package:cloudbelly_app/screens/Tabs/Dashboard/store_setup_sheets.dart';
import 'package:cloudbelly_app/screens/Tabs/Profile/Profile_setting/kyc_view.dart';
import 'package:cloudbelly_app/screens/Tabs/Profile/Profile_setting/payment_details_view.dart';
import 'package:cloudbelly_app/widgets/appwide_loading_bannner.dart';
import 'package:cloudbelly_app/widgets/appwide_textfield.dart';
import 'package:cloudbelly_app/widgets/space.dart';
import 'package:cloudbelly_app/widgets/toast_notification.dart';
import 'package:cloudbelly_app/widgets/touchableOpacity.dart';
import 'package:figma_squircle/figma_squircle.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:url_launcher/url_launcher.dart';

class ProfileSettingView extends StatefulWidget {
  const ProfileSettingView({super.key});

  @override
  State<ProfileSettingView> createState() => _ProfileSettingViewState();
}

class _ProfileSettingViewState extends State<ProfileSettingView> {
  TextEditingController nameController = TextEditingController();
  TextEditingController numberController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController addressController = TextEditingController();
  bool? _switchValue;
  TimeOfDay? tillTime;
  TimeOfDay? fromTime;
  String? fromTiming;
  String? tillTiming;
  Map<String, dynamic> workingHours = {};
  Map<String, dynamic>? userDetails;

  @override
  void initState() {
    super.initState();
    userDetails = UserPreferences.getUser();

    /* if (userData?['user_type'] == UserType.Customer.name) {
      if (userData?['user_name'] != null) {
        nameController.text = userData?['user_name'];
      }
    } else {*/
    if (Provider.of<Auth>(context, listen: false).userData?['store_name'] !=
        null) {
      nameController.text =
          Provider.of<Auth>(context, listen: false).userData?['store_name'];
    }
    if (Provider.of<Auth>(context, listen: false).userData?['email'] != null) {
      emailController.text =
          Provider.of<Auth>(context, listen: false).userData?['email'];
    }
    if (Provider.of<Auth>(context, listen: false).userData?['phone'] != null) {
      numberController.text =
          Provider.of<Auth>(context, listen: false).userData?['phone'];
    }
    if (Provider.of<Auth>(context, listen: false).userData?['working_hours'] !=
        null) {
      if (Provider.of<Auth>(context, listen: false).userData?['working_hours']
              ['start_time'] !=
          null) {
        fromTiming = Provider.of<Auth>(context, listen: false)
            .userData?['working_hours']['start_time'];
        setState(() {});
      }
      if (Provider.of<Auth>(context, listen: false).userData?['working_hours']
              ['end_time'] !=
          null) {
        tillTiming = Provider.of<Auth>(context, listen: false)
            .userData?['working_hours']['end_time'];

        setState(() {});
      }
    }

    if (Provider.of<Auth>(context, listen: false).userData?['address'] !=
        null) {
      addressController.text = Provider.of<Auth>(context, listen: false)
          .userData?['address']['location'];
    }
    if (Provider.of<Auth>(context, listen: false)
            .userData?['store_availability'] !=
        null) {
      _switchValue = Provider.of<Auth>(context, listen: false)
          .userData?['store_availability'];
    }
  }

  Future<void> submitStoreName() async {
    // final prefs = await SharedPreferences.getInstance();
    if (nameController.text != '') {
      AppWideLoadingBanner().loadingBanner(context);

      String msg = await Provider.of<Auth>(context, listen: false)
          .storeName(nameController.text);
      if (msg == 'User information updated successfully.') {
        Provider.of<Auth>(context, listen: false).userData?['store_name'] =
            nameController.text;
        Map<String, dynamic>? userData = {
          'user_id':
              Provider.of<Auth>(context, listen: false).userData?['user_id'],
          'user_name':
              Provider.of<Auth>(context, listen: false).userData?['user_name'],
          'email': Provider.of<Auth>(context, listen: false).userData?['email'],
          'store_name': nameController.text,
          'profile_photo': Provider.of<Auth>(context, listen: false)
                  .userData?['profile_photo'] ??
              '',
          'store_availability': Provider.of<Auth>(context, listen: false)
                  .userData?['store_availability'] ??
              false,
          'pan_number': Provider.of<Auth>(context, listen: false)
                  .userData?['pan_number'] ??
              '',
          'aadhar_number': Provider.of<Auth>(context, listen: false)
                  .userData?['aadhar_number'] ??
              '',
          if (Provider.of<Auth>(context, listen: false).userData?['address'] !=
              null)
            'address': {
              "location": Provider.of<Auth>(context, listen: false)
                  .userData?['address']['location'],
              "latitude": Provider.of<Auth>(context, listen: false)
                  .userData?['address']['latitude'],
              "longitude": Provider.of<Auth>(context, listen: false)
                  .userData?['address']['longitude'],
              "hno": Provider.of<Auth>(context, listen: false)
                  .userData?['address']['hno'],
              "pincode": Provider.of<Auth>(context, listen: false)
                  .userData?['address']['pincode'],
              "landmark": Provider.of<Auth>(context, listen: false)
                  .userData?['address']['landmark'],
              "type": Provider.of<Auth>(context, listen: false)
                  .userData?['address']['type'],
            },
          if (Provider.of<Auth>(context, listen: false).userData?['location'] !=
              null)
            'location': {
              'details': Provider.of<Auth>(context, listen: false)
                      .userData?['location']['details'] ??
                  '',
              'latitude': Provider.of<Auth>(context, listen: false)
                      .userData?['location']['latitude'] ??
                  '',
              'longitude': Provider.of<Auth>(context, listen: false)
                      .userData?['location']['longitude'] ??
                  '',
            },
          if (Provider.of<Auth>(context, listen: false)
                  .userData?['working_hours'] !=
              null)
            'working_hours': {
              'start_time': Provider.of<Auth>(context, listen: false)
                      .userData?['working_hours']['start_time'] ??
                  '',
              'end_time': Provider.of<Auth>(context, listen: false)
                      .userData?['working_hours']['end_time'] ??
                  '',
            },
          'delivery_addresses': Provider.of<Auth>(context, listen: false)
                  .userData?['delivery_addresses'] ??
              [],
          'bank_name': Provider.of<Auth>(context, listen: false)
                  .userData?['bank_name'] ??
              '',
          'pincode':
              Provider.of<Auth>(context, listen: false).userData?['pincode'] ??
                  '',
          'rating':
              Provider.of<Auth>(context, listen: false).userData?['rating'] ??
                  '-',
          'followers': Provider.of<Auth>(context, listen: false)
                  .userData?['followers'] ??
              [],
          'followings': Provider.of<Auth>(context, listen: false)
                  .userData?['followings'] ??
              [],
          'cover_image': Provider.of<Auth>(context, listen: false)
                  .userData?['cover_image'] ??
              '',
          'account_number': Provider.of<Auth>(context, listen: false)
                  .userData?['account_number'] ??
              '',
          'ifsc_code': Provider.of<Auth>(context, listen: false)
                  .userData?['ifsc_code'] ??
              '',
          'phone':
              Provider.of<Auth>(context, listen: false).userData?['phone'] ??
                  '',
          'upi_id':
              Provider.of<Auth>(context, listen: false).userData?['upi_id'] ??
                  '',
          'user_type': Provider.of<Auth>(context, listen: false)
                  .userData?['user_type'] ??
              'Vendor',
        };
        await UserPreferences.setUser(userData);
        userDetails = UserPreferences.getUser();
        print(
            'name: ${Provider.of<Auth>(context, listen: false).userData?['store_name']}');
        TOastNotification().showSuccesToast(
            context,
            Provider.of<Auth>(context, listen: false).userData?['user_type'] ==
                    UserType.Customer.name
                ? "User name update successfully"
                : 'Store name update successfully');
        Navigator.of(context).pop();
        // prefs.setInt('counter', 3);
      } else {
        TOastNotification().showErrorToast(context, msg);
        Navigator.of(context).pop();
      }
      print(msg);
    } else {
      TOastNotification().showErrorToast(context, 'Please fill all fields');
    }
  }

  Future<void> submitUserImage(dynamic userImage) async {
    // final prefs = await SharedPreferences.getInstance();
    AppWideLoadingBanner().loadingBanner(context);

    String msg =
        await Provider.of<Auth>(context, listen: false).userImage(userImage);
    if (msg == 'User information updated successfully.') {
      Navigator.of(context).pop();
      Provider.of<Auth>(context, listen: false).userData?['profile_photo'] =
          userImage;
      Map<String, dynamic>? userData = {
        'user_id':
            Provider.of<Auth>(context, listen: false).userData?['user_id'],
        'user_name':
            Provider.of<Auth>(context, listen: false).userData?['user_name'],
        'email': Provider.of<Auth>(context, listen: false).userData?['email'],
        'store_name':
            Provider.of<Auth>(context, listen: false).userData?['store_name'],
        'profile_photo': userImage ?? '',
        'store_availability': Provider.of<Auth>(context, listen: false)
                .userData?['store_availability'] ??
            false,
        'pan_number':
            Provider.of<Auth>(context, listen: false).userData?['pan_number'] ??
                '',
        'aadhar_number': Provider.of<Auth>(context, listen: false)
                .userData?['aadhar_number'] ??
            '',
        if (Provider.of<Auth>(context, listen: false).userData?['address'] !=
            null)
          'address': {
            "location": Provider.of<Auth>(context, listen: false)
                .userData?['address']['location'],
            "latitude": Provider.of<Auth>(context, listen: false)
                .userData?['address']['latitude'],
            "longitude": Provider.of<Auth>(context, listen: false)
                .userData?['address']['longitude'],
            "hno": Provider.of<Auth>(context, listen: false)
                .userData?['address']['hno'],
            "pincode": Provider.of<Auth>(context, listen: false)
                .userData?['address']['pincode'],
            "landmark": Provider.of<Auth>(context, listen: false)
                .userData?['address']['landmark'],
            "type": Provider.of<Auth>(context, listen: false)
                .userData?['address']['type'],
          },
        if (Provider.of<Auth>(context, listen: false).userData?['location'] !=
            null)
          'location': {
            'details': Provider.of<Auth>(context, listen: false)
                    .userData?['location']['details'] ??
                '',
            'latitude': Provider.of<Auth>(context, listen: false)
                    .userData?['location']['latitude'] ??
                '',
            'longitude': Provider.of<Auth>(context, listen: false)
                    .userData?['location']['longitude'] ??
                '',
          },
        if (Provider.of<Auth>(context, listen: false)
                .userData?['working_hours'] !=
            null)
          'working_hours': {
            'start_time': Provider.of<Auth>(context, listen: false)
                    .userData?['working_hours']['start_time'] ??
                '',
            'end_time': Provider.of<Auth>(context, listen: false)
                    .userData?['working_hours']['end_time'] ??
                '',
          },
        'delivery_addresses': Provider.of<Auth>(context, listen: false)
                .userData?['delivery_addresses'] ??
            [],
        'bank_name':
            Provider.of<Auth>(context, listen: false).userData?['bank_name'] ??
                '',
        'pincode':
            Provider.of<Auth>(context, listen: false).userData?['pincode'] ??
                '',
        'rating':
            Provider.of<Auth>(context, listen: false).userData?['rating'] ??
                '-',
        'followers':
            Provider.of<Auth>(context, listen: false).userData?['followers'] ??
                [],
        'followings':
            Provider.of<Auth>(context, listen: false).userData?['followings'] ??
                [],
        'cover_image': Provider.of<Auth>(context, listen: false)
                .userData?['cover_image'] ??
            '',
        'account_number': Provider.of<Auth>(context, listen: false)
                .userData?['account_number'] ??
            '',
        'ifsc_code':
            Provider.of<Auth>(context, listen: false).userData?['ifsc_code'] ??
                '',
        'phone':
            Provider.of<Auth>(context, listen: false).userData?['phone'] ?? '',
        'upi_id':
            Provider.of<Auth>(context, listen: false).userData?['upi_id'] ?? '',
        'user_type':
            Provider.of<Auth>(context, listen: false).userData?['user_type'] ??
                'Vendor',
      };
      await UserPreferences.setUser(userData);
      userDetails = UserPreferences.getUser();
      print(
          'profile_photo: ${Provider.of<Auth>(context, listen: false).userData?['profile_photo']}');
      TOastNotification()
          .showSuccesToast(context, 'Profile Image update successfully');
      // prefs.setInt('counter', 3);
    } else {
      TOastNotification().showErrorToast(context, msg);
      Navigator.of(context).pop();
    }
    Navigator.of(context).pop();
    print(msg);
  }

  Future<void> submitEmail() async {
    // final prefs = await SharedPreferences.getInstance();
    if (emailController.text != '') {
      AppWideLoadingBanner().loadingBanner(context);

      String msg = await Provider.of<Auth>(context, listen: false)
          .email(emailController.text);
      if (msg == 'User information updated successfully.') {
        Provider.of<Auth>(context, listen: false).userData?['email'] =
            emailController.text;
        Map<String, dynamic>? userData = {
          'user_id':
              Provider.of<Auth>(context, listen: false).userData?['user_id'],
          'user_name':
              Provider.of<Auth>(context, listen: false).userData?['user_name'],
          'email': emailController.text,
          'store_name':
              Provider.of<Auth>(context, listen: false).userData?['store_name'],
          'profile_photo': Provider.of<Auth>(context, listen: false)
                  .userData?['profile_photo'] ??
              '',
          'store_availability': Provider.of<Auth>(context, listen: false)
                  .userData?['store_availability'] ??
              false,
          'pan_number': Provider.of<Auth>(context, listen: false)
                  .userData?['pan_number'] ??
              '',
          'aadhar_number': Provider.of<Auth>(context, listen: false)
                  .userData?['aadhar_number'] ??
              '',
          if (Provider.of<Auth>(context, listen: false).userData?['address'] !=
              null)
            'address': {
              "location": Provider.of<Auth>(context, listen: false)
                  .userData?['address']['location'],
              "latitude": Provider.of<Auth>(context, listen: false)
                  .userData?['address']['latitude'],
              "longitude": Provider.of<Auth>(context, listen: false)
                  .userData?['address']['longitude'],
              "hno": Provider.of<Auth>(context, listen: false)
                  .userData?['address']['hno'],
              "pincode": Provider.of<Auth>(context, listen: false)
                  .userData?['address']['pincode'],
              "landmark": Provider.of<Auth>(context, listen: false)
                  .userData?['address']['landmark'],
              "type": Provider.of<Auth>(context, listen: false)
                  .userData?['address']['type'],
            },
          if (Provider.of<Auth>(context, listen: false).userData?['location'] !=
              null)
            'location': {
              'details': Provider.of<Auth>(context, listen: false)
                      .userData?['location']['details'] ??
                  '',
              'latitude': Provider.of<Auth>(context, listen: false)
                      .userData?['location']['latitude'] ??
                  '',
              'longitude': Provider.of<Auth>(context, listen: false)
                      .userData?['location']['longitude'] ??
                  '',
            },
          if (Provider.of<Auth>(context, listen: false)
                  .userData?['working_hours'] !=
              null)
            'working_hours': {
              'start_time': Provider.of<Auth>(context, listen: false)
                      .userData?['working_hours']['start_time'] ??
                  '',
              'end_time': Provider.of<Auth>(context, listen: false)
                      .userData?['working_hours']['end_time'] ??
                  '',
            },
          'delivery_addresses': Provider.of<Auth>(context, listen: false)
                  .userData?['delivery_addresses'] ??
              [],
          'bank_name': Provider.of<Auth>(context, listen: false)
                  .userData?['bank_name'] ??
              '',
          'pincode':
              Provider.of<Auth>(context, listen: false).userData?['pincode'] ??
                  '',
          'rating':
              Provider.of<Auth>(context, listen: false).userData?['rating'] ??
                  '-',
          'followers': Provider.of<Auth>(context, listen: false)
                  .userData?['followers'] ??
              [],
          'followings': Provider.of<Auth>(context, listen: false)
                  .userData?['followings'] ??
              [],
          'cover_image': Provider.of<Auth>(context, listen: false)
                  .userData?['cover_image'] ??
              '',
          'account_number': Provider.of<Auth>(context, listen: false)
                  .userData?['account_number'] ??
              '',
          'ifsc_code': Provider.of<Auth>(context, listen: false)
                  .userData?['ifsc_code'] ??
              '',
          'phone':
              Provider.of<Auth>(context, listen: false).userData?['phone'] ??
                  '',
          'upi_id':
              Provider.of<Auth>(context, listen: false).userData?['upi_id'] ??
                  '',
          'user_type': Provider.of<Auth>(context, listen: false)
                  .userData?['user_type'] ??
              'Vendor',
        };
        await UserPreferences.setUser(userData);
        userDetails = UserPreferences.getUser();

        //  print('pin: ${pan_number}');
        TOastNotification()
            .showSuccesToast(context, 'Email update successfully');
        Navigator.of(context).pop();
        // prefs.setInt('counter', 3);
      } else {
        TOastNotification().showErrorToast(context, msg);
        Navigator.of(context).pop();
      }
      print(msg);
    } else {
      TOastNotification().showErrorToast(context, 'Please fill email fields');
    }
  }

  Future<void> submitContactNumber() async {
    print("contactNUmber:: ${numberController.text}");

    // final prefs = await SharedPreferences.getInstance();
    if (numberController.text != '') {
      AppWideLoadingBanner().loadingBanner(context);

      String msg = await Provider.of<Auth>(context, listen: false)
          .contactNumber(numberController.text);
      if (msg == 'User information updated successfully.') {
        Provider.of<Auth>(context, listen: false).userData?['phone'] =
            numberController.text;
        Map<String, dynamic>? userData = {
          'user_id':
              Provider.of<Auth>(context, listen: false).userData?['user_id'],
          'user_name':
              Provider.of<Auth>(context, listen: false).userData?['user_name'],
          'email': Provider.of<Auth>(context, listen: false).userData?['email'],
          'store_name':
              Provider.of<Auth>(context, listen: false).userData?['store_name'],
          'profile_photo': Provider.of<Auth>(context, listen: false)
                  .userData?['profile_photo'] ??
              '',
          'store_availability': Provider.of<Auth>(context, listen: false)
                  .userData?['store_availability'] ??
              false,
          'pan_number': Provider.of<Auth>(context, listen: false)
                  .userData?['pan_number'] ??
              '',
          'aadhar_number': Provider.of<Auth>(context, listen: false)
                  .userData?['aadhar_number'] ??
              '',
          if (Provider.of<Auth>(context, listen: false).userData?['address'] !=
              null)
            'address': {
              "location": Provider.of<Auth>(context, listen: false)
                  .userData?['address']['location'],
              "latitude": Provider.of<Auth>(context, listen: false)
                  .userData?['address']['latitude'],
              "longitude": Provider.of<Auth>(context, listen: false)
                  .userData?['address']['longitude'],
              "hno": Provider.of<Auth>(context, listen: false)
                  .userData?['address']['hno'],
              "pincode": Provider.of<Auth>(context, listen: false)
                  .userData?['address']['pincode'],
              "landmark": Provider.of<Auth>(context, listen: false)
                  .userData?['address']['landmark'],
              "type": Provider.of<Auth>(context, listen: false)
                  .userData?['address']['type'],
            },
          if (Provider.of<Auth>(context, listen: false).userData?['location'] !=
              null)
            'location': {
              'details': Provider.of<Auth>(context, listen: false)
                      .userData?['location']['details'] ??
                  '',
              'latitude': Provider.of<Auth>(context, listen: false)
                      .userData?['location']['latitude'] ??
                  '',
              'longitude': Provider.of<Auth>(context, listen: false)
                      .userData?['location']['longitude'] ??
                  '',
            },
          if (Provider.of<Auth>(context, listen: false)
                  .userData?['working_hours'] !=
              null)
            'working_hours': {
              'start_time': Provider.of<Auth>(context, listen: false)
                      .userData?['working_hours']['start_time'] ??
                  '',
              'end_time': Provider.of<Auth>(context, listen: false)
                      .userData?['working_hours']['end_time'] ??
                  '',
            },
          'delivery_addresses': Provider.of<Auth>(context, listen: false)
                  .userData?['delivery_addresses'] ??
              [],
          'bank_name': Provider.of<Auth>(context, listen: false)
                  .userData?['bank_name'] ??
              '',
          'pincode':
              Provider.of<Auth>(context, listen: false).userData?['pincode'] ??
                  '',
          'rating':
              Provider.of<Auth>(context, listen: false).userData?['rating'] ??
                  '-',
          'followers': Provider.of<Auth>(context, listen: false)
                  .userData?['followers'] ??
              [],
          'followings': Provider.of<Auth>(context, listen: false)
                  .userData?['followings'] ??
              [],
          'cover_image': Provider.of<Auth>(context, listen: false)
                  .userData?['cover_image'] ??
              '',
          'account_number': Provider.of<Auth>(context, listen: false)
                  .userData?['account_number'] ??
              '',
          'ifsc_code': Provider.of<Auth>(context, listen: false)
                  .userData?['ifsc_code'] ??
              '',
          'phone': numberController.text ?? '',
          'upi_id':
              Provider.of<Auth>(context, listen: false).userData?['upi_id'] ??
                  '',
          'user_type': Provider.of<Auth>(context, listen: false)
                  .userData?['user_type'] ??
              'Vendor',
        };
        await UserPreferences.setUser(userData);
        userDetails = UserPreferences.getUser();
        print(
            "contactNUmber:: ${Provider.of<Auth>(context, listen: false).userData?['phone']}");
        //  print('pin: ${pan_number}');
        TOastNotification()
            .showSuccesToast(context, 'Contact Number update successfully');
        Navigator.of(context).pop();
        // prefs.setInt('counter', 3);
      } else {
        TOastNotification().showErrorToast(context, msg);
        Navigator.of(context).pop();
      }
      print(msg);
    } else {
      TOastNotification().showErrorToast(context, 'Please fill all fields');
    }
  }

  Future<void> submitStoreWorkingHours() async {
    // final prefs = await SharedPreferences.getInstance();
    if (fromTime != null && tillTime != null) {
      workingHours = {
        "start_time": "${fromTime?.hour}:${fromTime?.minute}",
        "end_time": "${tillTime?.hour}:${tillTime?.minute}"
      };
      AppWideLoadingBanner().loadingBanner(context);

      String msg = await Provider.of<Auth>(context, listen: false)
          .workingHours(workingHours);
      if (msg == 'User information updated successfully.') {
        Provider.of<Auth>(context, listen: false).userData?['working_hours'] =
            workingHours;
        Map<String, dynamic>? userData = {
          'user_id':
              Provider.of<Auth>(context, listen: false).userData?['user_id'],
          'user_name':
              Provider.of<Auth>(context, listen: false).userData?['user_name'],
          'email': Provider.of<Auth>(context, listen: false).userData?['email'],
          'store_name':
              Provider.of<Auth>(context, listen: false).userData?['store_name'],
          'profile_photo': Provider.of<Auth>(context, listen: false)
                  .userData?['profile_photo'] ??
              '' ??
              '',
          'store_availability': Provider.of<Auth>(context, listen: false)
                  .userData?['store_availability'] ??
              false,
          'pan_number': Provider.of<Auth>(context, listen: false)
                  .userData?['pan_number'] ??
              '',
          'aadhar_number': Provider.of<Auth>(context, listen: false)
                  .userData?['aadhar_number'] ??
              '',
          if (Provider.of<Auth>(context, listen: false).userData?['address'] !=
              null)
            'address': {
              "location": Provider.of<Auth>(context, listen: false)
                  .userData?['address']['location'],
              "latitude": Provider.of<Auth>(context, listen: false)
                  .userData?['address']['latitude'],
              "longitude": Provider.of<Auth>(context, listen: false)
                  .userData?['address']['longitude'],
              "hno": Provider.of<Auth>(context, listen: false)
                  .userData?['address']['hno'],
              "pincode": Provider.of<Auth>(context, listen: false)
                  .userData?['address']['pincode'],
              "landmark": Provider.of<Auth>(context, listen: false)
                  .userData?['address']['landmark'],
              "type": Provider.of<Auth>(context, listen: false)
                  .userData?['address']['type'],
            },
          if (Provider.of<Auth>(context, listen: false).userData?['location'] !=
              null)
            'location': {
              'details': Provider.of<Auth>(context, listen: false)
                      .userData?['location']['details'] ??
                  '',
              'latitude': Provider.of<Auth>(context, listen: false)
                      .userData?['location']['latitude'] ??
                  '',
              'longitude': Provider.of<Auth>(context, listen: false)
                      .userData?['location']['longitude'] ??
                  '',
            },
          if (Provider.of<Auth>(context, listen: false)
                  .userData?['working_hours'] !=
              null)
            'working_hours': {
              'start_time': "${fromTime?.hour}:${fromTime?.minute}" ?? '',
              'end_time': "${tillTime?.hour}:${tillTime?.minute}" ?? '',
            },
          'delivery_addresses': Provider.of<Auth>(context, listen: false)
                  .userData?['delivery_addresses'] ??
              [],
          'bank_name': Provider.of<Auth>(context, listen: false)
                  .userData?['bank_name'] ??
              '',
          'pincode':
              Provider.of<Auth>(context, listen: false).userData?['pincode'] ??
                  '',
          'rating':
              Provider.of<Auth>(context, listen: false).userData?['rating'] ??
                  '-',
          'followers': Provider.of<Auth>(context, listen: false)
                  .userData?['followers'] ??
              [],
          'followings': Provider.of<Auth>(context, listen: false)
                  .userData?['followings'] ??
              [],
          'cover_image': Provider.of<Auth>(context, listen: false)
                  .userData?['cover_image'] ??
              '',
          'account_number': Provider.of<Auth>(context, listen: false)
                  .userData?['account_number'] ??
              '',
          'ifsc_code': Provider.of<Auth>(context, listen: false)
                  .userData?['ifsc_code'] ??
              '',
          'phone':
              Provider.of<Auth>(context, listen: false).userData?['phone'] ??
                  '',
          'upi_id':
              Provider.of<Auth>(context, listen: false).userData?['upi_id'] ??
                  '',
          'user_type': Provider.of<Auth>(context, listen: false)
                  .userData?['user_type'] ??
              'Vendor',
        };
        await UserPreferences.setUser(userData);
        userDetails = UserPreferences.getUser();

        //  print('pin: ${pan_number}');
        TOastNotification()
            .showSuccesToast(context, 'working hours update successfully');
        Navigator.of(context).pop();
        // prefs.setInt('counter', 3);
      } else {
        TOastNotification().showErrorToast(context, msg);
        Navigator.of(context).pop();
      }
      print(msg);
    } else {
      TOastNotification().showErrorToast(context, 'Please select Both Time');
    }
  }

  Future<void> submitStoreAvailability() async {
    // final prefs = await SharedPreferences.getInstance();

    AppWideLoadingBanner().loadingBanner(context);

    String msg = await Provider.of<Auth>(context, listen: false)
        .storeAvailability(_switchValue);
    if (msg == 'User information updated successfully.') {
      Provider.of<Auth>(context, listen: false)
          .userData?['store_availability'] = _switchValue;
      Map<String, dynamic>? userData = {
        'user_id':
            Provider.of<Auth>(context, listen: false).userData?['user_id'],
        'user_name':
            Provider.of<Auth>(context, listen: false).userData?['user_name'],
        'email': Provider.of<Auth>(context, listen: false).userData?['email'],
        'store_name':
            Provider.of<Auth>(context, listen: false).userData?['store_name'],
        'profile_photo': Provider.of<Auth>(context, listen: false)
                .userData?['profile_photo'] ??
            '' ??
            '',
        'store_availability': _switchValue ?? false,
        'pan_number':
            Provider.of<Auth>(context, listen: false).userData?['pan_number'] ??
                '',
        'aadhar_number': Provider.of<Auth>(context, listen: false)
                .userData?['aadhar_number'] ??
            '',
        if (Provider.of<Auth>(context, listen: false).userData?['address'] !=
            null)
          'address': {
            "location": Provider.of<Auth>(context, listen: false)
                .userData?['address']['location'],
            "latitude": Provider.of<Auth>(context, listen: false)
                .userData?['address']['latitude'],
            "longitude": Provider.of<Auth>(context, listen: false)
                .userData?['address']['longitude'],
            "hno": Provider.of<Auth>(context, listen: false)
                .userData?['address']['hno'],
            "pincode": Provider.of<Auth>(context, listen: false)
                .userData?['address']['pincode'],
            "landmark": Provider.of<Auth>(context, listen: false)
                .userData?['address']['landmark'],
            "type": Provider.of<Auth>(context, listen: false)
                .userData?['address']['type'],
          },
        if (Provider.of<Auth>(context, listen: false).userData?['location'] !=
            null)
          'location': {
            'details': Provider.of<Auth>(context, listen: false)
                    .userData?['location']['details'] ??
                '',
            'latitude': Provider.of<Auth>(context, listen: false)
                    .userData?['location']['latitude'] ??
                '',
            'longitude': Provider.of<Auth>(context, listen: false)
                    .userData?['location']['longitude'] ??
                '',
          },
        if (Provider.of<Auth>(context, listen: false)
                .userData?['working_hours'] !=
            null)
          'working_hours': {
            'start_time': Provider.of<Auth>(context, listen: false)
                    .userData?['working_hours']['start_time'] ??
                '' ??
                '',
            'end_time': Provider.of<Auth>(context, listen: false)
                    .userData?['working_hours']['end_time'] ??
                '',
          },
        'delivery_addresses': Provider.of<Auth>(context, listen: false)
                .userData?['delivery_addresses'] ??
            [],
        'bank_name':
            Provider.of<Auth>(context, listen: false).userData?['bank_name'] ??
                '',
        'pincode':
            Provider.of<Auth>(context, listen: false).userData?['pincode'] ??
                '',
        'rating':
            Provider.of<Auth>(context, listen: false).userData?['rating'] ??
                '-',
        'followers':
            Provider.of<Auth>(context, listen: false).userData?['followers'] ??
                [],
        'followings':
            Provider.of<Auth>(context, listen: false).userData?['followings'] ??
                [],
        'cover_image': Provider.of<Auth>(context, listen: false)
                .userData?['cover_image'] ??
            '',
        'account_number': Provider.of<Auth>(context, listen: false)
                .userData?['account_number'] ??
            '',
        'ifsc_code':
            Provider.of<Auth>(context, listen: false).userData?['ifsc_code'] ??
                '',
        'phone':
            Provider.of<Auth>(context, listen: false).userData?['phone'] ?? '',
        'upi_id':
            Provider.of<Auth>(context, listen: false).userData?['upi_id'] ?? '',
        'user_type':
            Provider.of<Auth>(context, listen: false).userData?['user_type'] ??
                'Vendor',
      };
      await UserPreferences.setUser(userData);
      userDetails = UserPreferences.getUser();

      //  print('pin: ${pan_number}');
      TOastNotification()
          .showSuccesToast(context, 'StoreAvailability update successfully');
      Navigator.of(context).pop();
      // prefs.setInt('counter', 3);
    } else {
      TOastNotification().showErrorToast(context, msg);
      Navigator.of(context).pop();
    }
    print(msg);
  }

  Future<void> logout() async {
    AppWideLoadingBanner().loadingBanner(context);

    await Provider.of<Auth>(context, listen: false).logout();
    Navigator.of(context).pop();
    Navigator.of(context).pushReplacementNamed(LoginScreen.routeName);
  }

  Future<void> deleteAccount(String url) async {
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url));
    } else {
      throw 'Could not launch $url';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFFFFF),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 30.0, vertical: 10.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Provider.of<Auth>(context, listen: false)
                                      .userData?['profile_photo'] ==
                                  '' ||
                              Provider.of<Auth>(context, listen: false)
                                      .userData?['profile_photo'] ==
                                  null
                          ? Container(
                              height: 70,
                              width: 70,
                              decoration: ShapeDecoration(
                                shadows: [
                                  BoxShadow(
                                    offset: const Offset(0, 4),
                                    color: Provider.of<Auth>(context,
                                                    listen: false)
                                                .userData?['user_type'] ==
                                            UserType.Vendor.name
                                        ? const Color.fromRGBO(
                                            31, 111, 109, 0.4)
                                        : Provider.of<Auth>(context,
                                                        listen: false)
                                                    .userData?['user_type'] ==
                                                UserType.Supplier.name
                                            ? const Color.fromRGBO(
                                                198, 239, 161, 0.6)
                                            : const Color.fromRGBO(
                                                130, 47, 130, 0.4),
                                    blurRadius: 20,
                                  ),
                                ],
                                color: const Color.fromRGBO(31, 111, 109, 0.6),
                                shape: SmoothRectangleBorder(
                                    borderRadius: SmoothBorderRadius(
                                  cornerRadius: 20,
                                  cornerSmoothing: 1,
                                )),
                              ),
                              child: Center(
                                child: Text(
                                  Provider.of<Auth>(context, listen: true)
                                      .userData!['store_name'][0]
                                      .toUpperCase(),
                                  style: const TextStyle(fontSize: 20),
                                ),
                              ))
                          : Container(
                              height: 70,
                              width: 70,
                              decoration: ShapeDecoration(
                                shadows: [
                                  BoxShadow(
                                    offset: const Offset(0, 4),
                                    color: Provider.of<Auth>(context,
                                                    listen: false)
                                                .userData?['user_type'] ==
                                            UserType.Vendor.name
                                        ? const Color.fromRGBO(
                                            31, 111, 109, 0.6)
                                        : Provider.of<Auth>(context,
                                                        listen: false)
                                                    .userData?['user_type'] ==
                                                UserType.Supplier.name
                                            ? const Color.fromRGBO(
                                                77, 191, 74, 0.5)
                                            : const Color.fromRGBO(
                                                130, 47, 130, 0.4),
                                    blurRadius: 20,
                                  )
                                ],
                                shape: const SmoothRectangleBorder(),
                              ),
                              child: ClipSmoothRect(
                                radius: SmoothBorderRadius(
                                  cornerRadius: 20,
                                  cornerSmoothing: 1,
                                ),
                                child: Image.network(
                                  Provider.of<Auth>(context, listen: false)
                                      .userData?['profile_photo'],
                                  fit: BoxFit.cover,
                                  loadingBuilder:
                                      GlobalVariables().loadingBuilderForImage,
                                  errorBuilder:
                                      GlobalVariables().ErrorBuilderForImage,
                                ),
                              ),
                            ),
                      const Space(
                        13,
                        isHorizontal: true,
                      ),
                      InkWell(
                        onTap: () {
                          context.read<TransitionEffect>().setBlurSigma(5.0);
                          showModalBottomSheet(
                            context: context,
                            builder: (BuildContext context) {
                              return PopScope(
                                canPop: true,
                                onPopInvoked: (_) {
                                  context
                                      .read<TransitionEffect>()
                                      .setBlurSigma(0);
                                },
                                child: Container(
                                  // height: 35.h,
                                  width: double.infinity,
                                  padding: EdgeInsets.only(
                                      left: 10.w,
                                      right: 5.w,
                                      top: 1.h,
                                      bottom: 2.h),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      TouchableOpacity(
                                        onTap: () {
                                          return Navigator.of(context).pop();
                                        },
                                        child: Center(
                                          child: Container(
                                            padding: EdgeInsets.symmetric(
                                                vertical: 1.h, horizontal: 3.w),
                                            width: 55,
                                            height: 9,
                                            decoration: ShapeDecoration(
                                              color: const Color(0xFFFA6E00),
                                              shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(6)),
                                            ),
                                          ),
                                        ),
                                      ),
                                      Space(3.h),
                                      Row(
                                        children: [
                                          Container(
                                            height: 25,
                                            width: 25,
                                            decoration: const ShapeDecoration(
                                              shadows: [
                                                BoxShadow(
                                                  offset: Offset(0, 4),
                                                  color: Color.fromRGBO(
                                                      165, 200, 199, 0.6),
                                                  blurRadius: 20,
                                                )
                                              ],
                                              color: Color(0xFFA5C8C799),
                                              shape: SmoothRectangleBorder(
                                                borderRadius:
                                                    SmoothBorderRadius.all(
                                                        SmoothRadius(
                                                            cornerRadius: 10,
                                                            cornerSmoothing:
                                                                1)),
                                              ),
                                            ),
                                          ),
                                          const Space(
                                            16,
                                            isHorizontal: true,
                                          ),
                                          InkWell(
                                            onTap: () async {
                                              var profileImage = await Provider
                                                      .of<Auth>(context,
                                                          listen: false)
                                                  .pickImageAndUpoad(context);
                                              submitUserImage(profileImage);
                                            },
                                            child: const Text(
                                              "Add logo",
                                              style: TextStyle(
                                                  fontSize: 14,
                                                  color: Color(0xFF0A4C61),
                                                  fontFamily: 'Product Sans',
                                                  fontWeight: FontWeight.w700),
                                            ),
                                          ),
                                        ],
                                      ),
                                      Space(1.h),
                                      Row(
                                        children: [
                                          Container(
                                            height: 25,
                                            width: 25,
                                            decoration: const ShapeDecoration(
                                              shadows: [
                                                BoxShadow(
                                                  offset: Offset(0, 4),
                                                  color: Color.fromRGBO(
                                                      165, 200, 199, 0.6),
                                                  blurRadius: 20,
                                                )
                                              ],
                                              color: Color(0xFFA5C8C799),
                                              shape: SmoothRectangleBorder(
                                                borderRadius:
                                                    SmoothBorderRadius.all(
                                                        SmoothRadius(
                                                            cornerRadius: 10,
                                                            cornerSmoothing:
                                                                1)),
                                              ),
                                            ),
                                          ),
                                          const Space(
                                            16,
                                            isHorizontal: true,
                                          ),
                                          const Text(
                                            "Add cover photo",
                                            style: TextStyle(
                                                fontSize: 14,
                                                color: Color(0xFF0A4C61),
                                                fontFamily: 'Product Sans',
                                                fontWeight: FontWeight.w700),
                                          ),
                                        ],
                                      ),
                                      Space(1.h),
                                      Row(
                                        children: [
                                          Container(
                                            height: 25,
                                            width: 25,
                                            decoration: const ShapeDecoration(
                                              shadows: [
                                                BoxShadow(
                                                  offset: Offset(0, 4),
                                                  color: Color.fromRGBO(
                                                      165, 200, 199, 0.6),
                                                  blurRadius: 20,
                                                )
                                              ],
                                              color: Color(0xFFA5C8C799),
                                              shape: SmoothRectangleBorder(
                                                borderRadius:
                                                    SmoothBorderRadius.all(
                                                        SmoothRadius(
                                                            cornerRadius: 10,
                                                            cornerSmoothing:
                                                                1)),
                                              ),
                                            ),
                                          ),
                                          const Space(
                                            16,
                                            isHorizontal: true,
                                          ),
                                          InkWell(
                                            onTap: () {
                                              Provider.of<Auth>(context,
                                                          listen: false)
                                                      .userData?[
                                                  'profile_photo'] = "";
                                              submitUserImage("");
                                              setState(() {});
                                            },
                                            child: const Text(
                                              "Remove logo",
                                              style: TextStyle(
                                                  fontSize: 14,
                                                  color: Color(0xFF0A4C61),
                                                  fontFamily: 'Product Sans',
                                                  fontWeight: FontWeight.w700),
                                            ),
                                          ),
                                        ],
                                      ),
                                      Space(1.h),
                                      Row(
                                        children: [
                                          Container(
                                            height: 25,
                                            width: 25,
                                            decoration: const ShapeDecoration(
                                              shadows: [
                                                BoxShadow(
                                                  offset: Offset(0, 4),
                                                  color: Color.fromRGBO(
                                                      165, 200, 199, 0.6),
                                                  blurRadius: 20,
                                                )
                                              ],
                                              color: Color(0xFFA5C8C799),
                                              shape: SmoothRectangleBorder(
                                                borderRadius:
                                                    SmoothBorderRadius.all(
                                                        SmoothRadius(
                                                            cornerRadius: 10,
                                                            cornerSmoothing:
                                                                1)),
                                              ),
                                            ),
                                          ),
                                          const Space(
                                            16,
                                            isHorizontal: true,
                                          ),
                                          const Text(
                                            "Remove cover image",
                                            style: TextStyle(
                                                fontSize: 14,
                                                color: Color(0xFF0A4C61),
                                                fontFamily: 'Product Sans',
                                                fontWeight: FontWeight.w700),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          );
                        },
                        child: SizedBox(
                          height: 20,
                          width: 20,
                          child: Align(
                            alignment: Alignment.bottomLeft,
                            child: Image.asset(
                              Assets.editIcon,
                              height: 15,
                              width: 15,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  const Center(
                    child: Text(
                      'Setting',
                      style: TextStyle(
                        color: Color(0xFF0A4C61),
                        fontSize: 30,
                        fontFamily: 'Jost',
                        fontWeight: FontWeight.w600,
                        height: 0.03,
                        letterSpacing: 3,
                      ),
                    ),
                  ),
                ],
              ),
              const Space(
                23,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: TextWidgetStoreSetup(
                    label: userDetails?['user_type'] == UserType.Customer.name
                        ? 'Enter user name'
                        : 'Enter brand name'),
              ),
              Space(1.h),
              Container(
                height: 45,
                // rgba(165, 200, 199, 1),
                decoration: ShapeDecoration(
                  shadows: [
                    BoxShadow(
                      offset: const Offset(0, 4),
                      color: Provider.of<Auth>(context, listen: false)
                                  .userData?['user_type'] ==
                              UserType.Vendor.name
                          ? const Color.fromRGBO(165, 200, 199, 0.4)
                          : Provider.of<Auth>(context, listen: false)
                                      .userData?['user_type'] ==
                                  UserType.Supplier.name
                              ? const Color.fromRGBO(77, 191, 74, 0.3)
                              : const Color.fromRGBO(188, 115, 188, 0.2),
                      blurRadius: 20,
                    )
                  ],
                  color: Colors.white,
                  shape: const SmoothRectangleBorder(
                    borderRadius: SmoothBorderRadius.all(
                        SmoothRadius(cornerRadius: 10, cornerSmoothing: 1)),
                  ),
                ),
                //  height: 6.h,
                child: TextField(
                  onChanged: (value) {
                    nameController.text = value;
                    setState(() {});
                  },
                  style: Provider.of<Auth>(context, listen: false)
                              .userData?['user_type'] ==
                          UserType.Vendor.name
                      ? const TextStyle(
                          fontSize: 12,
                          fontFamily: 'Product Sans',
                          fontWeight: FontWeight.w400,
                          color: Color(0xFF0A4C61),
                        )
                      : const TextStyle(
                          fontSize: 14,
                          fontFamily: 'PT Sans',
                          fontWeight: FontWeight.w400,
                          color: Color(0xFF2E0536)),
                  controller: nameController,
                  decoration: InputDecoration(
                    fillColor: Colors.white,
                    suffixIcon: nameController.text.isEmpty
                        ? Padding(
                            padding: const EdgeInsets.all(15.0),
                            child: Image.asset(
                              Assets.editIcon,
                              height: 15,
                              width: 15,
                            ),
                          )
                        : IconButton(
                            onPressed: () {
                              submitStoreName();
                            },
                            icon: const Icon(Icons.done),
                            color: const Color(0xFFFA6E00),
                          ),
                    hintText: "Enter your brand name here",
                    contentPadding: const EdgeInsets.only(left: 14, top: 10),
                    hintStyle: TextStyle(
                        fontSize: 12,
                        color: Provider.of<Auth>(context, listen: false)
                                    .userData?['user_type'] ==
                                UserType.Vendor.name
                            ? const Color(0xFF0A4C61)
                            : const Color(0xFF494949),
                        fontFamily: 'Product Sans',
                        fontWeight: FontWeight.w400),
                    border: InputBorder.none,
                    // suffixIcon:
                  ),
                ),
              ),
              Space(
                3.h,
              ),
              if (userDetails?['user_type'] == UserType.Customer.name) ...[
                TextWidgetStoreSetup(label: 'Enter email'),
                Space(1.h),
                Container(
                  // rgba(165, 200, 199, 1),
                  decoration: ShapeDecoration(
                    shadows: [
                      BoxShadow(
                        offset: const Offset(0, 4),
                        color: Provider.of<Auth>(context, listen: false)
                                    .userData?['user_type'] ==
                                UserType.Vendor.name
                            ? const Color.fromRGBO(165, 200, 199, 0.6)
                            : Provider.of<Auth>(context, listen: false)
                                        .userData?['user_type'] ==
                                    UserType.Supplier.name
                                ? const Color.fromRGBO(77, 191, 74, 0.3)
                                : const Color.fromRGBO(188, 115, 188, 0.2),
                        blurRadius: 20,
                      )
                    ],
                    color: Colors.white,
                    shape: const SmoothRectangleBorder(
                      borderRadius: SmoothBorderRadius.all(
                          SmoothRadius(cornerRadius: 10, cornerSmoothing: 1)),
                    ),
                  ),
                  //  height: 6.h,
                  child: TextField(
                    onChanged: (value) {
                      emailController.text = value;
                      setState(() {});
                    },
                    style: Provider.of<Auth>(context, listen: false)
                                .userData?['user_type'] ==
                            UserType.Vendor.name
                        ? const TextStyle(
                            color: Color(0xFF0A4C61),
                          )
                        : const TextStyle(
                            fontSize: 14,
                            fontFamily: 'PT Sans',
                            fontWeight: FontWeight.w400,
                            color: Color(0xFF2E0536)),
                    controller: emailController,
                    decoration: InputDecoration(
                      fillColor: Colors.white,
                      suffixIcon: emailController.text.isEmpty
                          ? Padding(
                              padding: const EdgeInsets.all(15.0),
                              child: Image.asset(
                                Assets.editIcon,
                                height: 15,
                                width: 15,
                              ),
                            )
                          : IconButton(
                              onPressed: () {
                                submitEmail();
                              },
                              icon: const Icon(Icons.done),
                              color: const Color(0xFFFA6E00),
                            ),
                      hintText: "Enter your email here",
                      contentPadding: const EdgeInsets.only(left: 14, top: 10),
                      hintStyle: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF0A4C61),
                          fontFamily: 'Product Sans',
                          fontWeight: FontWeight.w400),
                      border: InputBorder.none,
                      // suffixIcon:
                    ),
                    /*decoration: const InputDecoration(
                          fillColor: Colors.white,
                          hintText: "Enter your  brand name here",
                          contentPadding: EdgeInsets.only(left: 14),
                          hintStyle: TextStyle(
                              fontSize: 12,
                              color: Color(0xFF0A4C61),
                              fontFamily: 'Product Sans',
                              fontWeight: FontWeight.w400),
                          border: InputBorder.none,
                          // suffixIcon:
                        ),*/
                    // onChanged: onChanged,
                  ),
                ),
                Space(
                  3.h,
                ),
              ],
              TextWidgetStoreSetup(label: 'Contact number'),
              Space(1.h),
              Container(
                // rgba(165, 200, 199, 1),
                decoration: ShapeDecoration(
                  shadows: [
                    BoxShadow(
                      offset: const Offset(0, 4),
                      color: Provider.of<Auth>(context, listen: false)
                                  .userData?['user_type'] ==
                              UserType.Vendor.name
                          ? const Color.fromRGBO(165, 200, 199, 0.6)
                          : Provider.of<Auth>(context, listen: false)
                                      .userData?['user_type'] ==
                                  UserType.Supplier.name
                              ? const Color.fromRGBO(77, 191, 74, 0.3)
                              : const Color.fromRGBO(188, 115, 188, 0.2),
                      blurRadius: 20,
                    ),
                  ],
                  color: Colors.white,
                  shape: const SmoothRectangleBorder(
                    borderRadius: SmoothBorderRadius.all(
                        SmoothRadius(cornerRadius: 10, cornerSmoothing: 1)),
                  ),
                ),
                // height: 6.h,
                child: TextField(
                  onChanged: (value) {
                    numberController.text = value;
                    setState(() {});
                  },
                  style: Provider.of<Auth>(context, listen: false)
                              .userData?['user_type'] ==
                          UserType.Vendor.name
                      ? const TextStyle(
                          color: Color(0xFF0A4C61),
                        )
                      : const TextStyle(
                          fontSize: 14,
                          fontFamily: 'PT Sans',
                          fontWeight: FontWeight.w400,
                          color: Color(0xFF2E0536)),
                  keyboardType: TextInputType.number,
                  inputFormatters: <TextInputFormatter>[
                    FilteringTextInputFormatter.digitsOnly
                  ],
                  controller: numberController,
                  decoration: InputDecoration(
                    fillColor: Colors.white,
                    suffixIcon: numberController.text.isEmpty
                        ? Padding(
                            padding: const EdgeInsets.all(15.0),
                            child: Image.asset(
                              Assets.editIcon,
                              height: 15,
                              width: 15,
                            ),
                          )
                        : IconButton(
                            onPressed: () {
                              submitContactNumber();
                            },
                            icon: const Icon(Icons.done),
                            color: const Color(0xFFFA6E00),
                          ),
                    hintText: "Enter your contact here",
                    contentPadding: const EdgeInsets.only(left: 14, top: 10),
                    hintStyle: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF0A4C61),
                        fontFamily: 'Product Sans',
                        fontWeight: FontWeight.w400),
                    border: InputBorder.none,
                    // suffixIcon:
                  ),
                  // onChanged: onChanged,
                ),
              ),
              Space(
                3.h,
              ),
              TextWidgetStoreSetup(label: 'Business address'),
              Space(1.h),
              Container(
                // rgba(165, 200, 199, 1),
                decoration: ShapeDecoration(
                  shadows: [
                    BoxShadow(
                      offset: const Offset(0, 4),
                      color: Provider.of<Auth>(context, listen: false)
                                  .userData?['user_type'] ==
                              UserType.Vendor.name
                          ? const Color.fromRGBO(165, 200, 199, 0.6)
                          : Provider.of<Auth>(context, listen: false)
                                      .userData?['user_type'] ==
                                  UserType.Supplier.name
                              ? const Color.fromRGBO(77, 191, 74, 0.3)
                              : const Color.fromRGBO(188, 115, 188, 0.2),
                      blurRadius: 20,
                    )
                  ],
                  color: Colors.white,
                  shape: const SmoothRectangleBorder(
                    borderRadius: SmoothBorderRadius.all(
                        SmoothRadius(cornerRadius: 10, cornerSmoothing: 1)),
                  ),
                ),
                child: TextField(
                  readOnly: true,
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const GoogleMapScreen(
                                  type: "profile",
                                )));
                  },
                  onChanged: (value) {
                    addressController.text = value;
                    setState(() {});
                  },
                  onSubmitted: (newvalue) async {},
                  controller: addressController,
                  style: Provider.of<Auth>(context, listen: false)
                              .userData?['user_type'] ==
                          UserType.Vendor.name
                      ? const TextStyle(
                          color: Color(0xFF0A4C61),
                        )
                      : const TextStyle(
                          fontSize: 14,
                          fontFamily: 'PT Sans',
                          fontWeight: FontWeight.w400,
                          color: Color(0xFF2E0536)),
                  decoration: InputDecoration(
                    fillColor: Colors.white,
                    suffixIcon: addressController.text.isEmpty
                        ? Padding(
                            padding: const EdgeInsets.all(15.0),
                            child: Image.asset(
                              Assets.editIcon,
                              height: 15,
                              width: 15,
                            ),
                          )
                        : IconButton(
                            onPressed: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          const GoogleMapScreen(
                                              type: "profile")));
                            },
                            icon: const Icon(Icons.done),
                            color: const Color(0xFFFA6E00),
                          ),
                    hintText: "Enter your contact here",
                    contentPadding: const EdgeInsets.only(left: 14, top: 10),
                    hintStyle: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF0A4C61),
                        fontFamily: 'Product Sans',
                        fontWeight: FontWeight.w400),
                    border: InputBorder.none,
                    // suffixIcon:
                  ),
                  /*    decoration: const InputDecoration(
                    fillColor: Colors.white,
                    hintText: "Choose from map",
                    contentPadding: EdgeInsets.only(left: 14),

                    hintStyle: TextStyle(
                        fontSize: 12,
                        color: Color(0xFF0A4C61),
                        fontFamily: 'Product Sans',
                        fontWeight: FontWeight.w400),
                    border: InputBorder.none,
                    // suffixIcon:
                  ),*/
                  // onChanged: onChanged,
                ),
              ),
              if (Provider.of<Auth>(context, listen: false)
                      .userData?['user_type'] !=
                  UserType.Customer.name) ...[
                Space(
                  3.h,
                ),
                TextWidgetStoreSetup(label: 'Choose your working hours'),
                Space(1.h),
                Row(
                  children: [
                    Expanded(
                      child: InkWell(
                        onTap: () async {
                          final TimeOfDay? pickedTime = await showTimePicker(
                            context: context,
                            initialTime: TimeOfDay.now(),
                          );

                          if (pickedTime != null && pickedTime != fromTime) {
                            setState(() {
                              fromTime = pickedTime;
                              print("fromTime:: ${fromTime}");
                            });
                          }
                        },
                        child: Container(
                          decoration: ShapeDecoration(
                            shadows: [
                              BoxShadow(
                                offset: const Offset(0, 4),
                                color: Provider.of<Auth>(context, listen: false)
                                            .userData?['user_type'] ==
                                        UserType.Vendor.name
                                    ? const Color.fromRGBO(165, 200, 199, 0.6)
                                    : Provider.of<Auth>(context, listen: false)
                                                .userData?['user_type'] ==
                                            UserType.Supplier.name
                                        ? const Color.fromRGBO(77, 191, 74, 0.3)
                                        : const Color.fromRGBO(
                                            130, 47, 130, 0.2),
                                blurRadius: 20,
                              )
                            ],
                            color: Colors.white,
                            shape: const SmoothRectangleBorder(
                              borderRadius: SmoothBorderRadius.all(SmoothRadius(
                                  cornerRadius: 10, cornerSmoothing: 1)),
                            ),
                          ),
                          height: 45,
                          // width: 40.w,
                          child: Center(
                            child: Text(
                              fromTime != null
                                  ? "${fromTime?.hour}:${fromTime?.minute}"
                                  : fromTiming ?? "From",
                              style: TextStyle(
                                  fontSize: 12,
                                  color:
                                      Provider.of<Auth>(context, listen: false)
                                                  .userData?['user_type'] ==
                                              UserType.Vendor.name
                                          ? const Color(0xFF0A4C61)
                                          : const Color(0xFF2E0536),
                                  fontFamily: 'Product Sans',
                                  fontWeight: FontWeight.w400),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const Space(
                      21,
                      isHorizontal: true,
                    ),
                    const Text(
                      "-",
                      style: TextStyle(
                          fontSize: 18,
                          color: Color(0xFFFA6E00),
                          fontFamily: 'Kavoon',
                          fontWeight: FontWeight.w400),
                    ),
                    const Space(
                      21,
                      isHorizontal: true,
                    ),
                    Expanded(
                      child: InkWell(
                        onTap: () async {
                          final TimeOfDay? pickedTime = await showTimePicker(
                            context: context,
                            initialTime: TimeOfDay.now(),
                          );

                          if (pickedTime != null && pickedTime != tillTime) {
                            setState(() {
                              tillTime = pickedTime;
                            });
                            submitStoreWorkingHours();
                          }
                        },
                        child: Container(
                          height: 45,
                          decoration: ShapeDecoration(
                            shadows: [
                              BoxShadow(
                                offset: const Offset(0, 4),
                                color: Provider.of<Auth>(context, listen: false)
                                            .userData?['user_type'] ==
                                        UserType.Vendor.name
                                    ? const Color.fromRGBO(165, 200, 199, 0.6)
                                    : Provider.of<Auth>(context, listen: false)
                                                .userData?['user_type'] ==
                                            UserType.Supplier.name
                                        ? const Color.fromRGBO(77, 191, 74, 0.3)
                                        : const Color.fromRGBO(
                                            130, 47, 130, 0.7),
                                blurRadius: 20,
                              )
                            ],
                            color: Colors.white,
                            shape: const SmoothRectangleBorder(
                              borderRadius: SmoothBorderRadius.all(SmoothRadius(
                                  cornerRadius: 10, cornerSmoothing: 1)),
                            ),
                          ),
                          //width: 40.w,
                          child: Center(
                            child: Text(
                              tillTime != null
                                  ? "${tillTime?.hour}:${tillTime?.minute}"
                                  : tillTiming ?? "Till",
                              style: TextStyle(
                                  fontSize: 12,
                                  color:
                                      Provider.of<Auth>(context, listen: false)
                                                  .userData?['user_type'] ==
                                              UserType.Vendor.name
                                          ? const Color(0xFF0A4C61)
                                          : const Color(0xFF2E0536),
                                  fontFamily: 'Product Sans',
                                  fontWeight: FontWeight.w400),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const Space(
                  42,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextWidgetStoreSetup(label: 'Store availability'),
                    Container(
                      height: 01, // Adjust the scale factor to adjust the height
                      child: CupertinoSwitch(
                        thumbColor: _switchValue == true
                            ? const Color(0xFF4DAB4B)
                            : const Color(0xFFF82E52),
                        activeColor: _switchValue == true
                            ? const Color(0xFFBFFC9A)
                            : const Color(0xFFF82E52).withOpacity(0.5),
                        trackColor: const Color(0xFFF82E52).withOpacity(0.5),
                        value: _switchValue ?? false,
                        onChanged: (value) {
                          setState(() {
                            _switchValue = value;
                          });
                          submitStoreAvailability();
                        },
                      ),
                    ),
                  ],
                ),
                Space(
                  3.h,
                ),
                InkWell(
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const PaymentDetailsView()));
                  },
                  child: Row(
                    children: [
                      Container(
                        height: 25,
                        width: 25,
                        decoration: ShapeDecoration(
                          shadows: const [
                            BoxShadow(
                              offset: Offset(0, 4),
                              color: Color.fromRGBO(165, 200, 199, 0.6),
                              blurRadius: 20,
                            )
                          ],
                          color: Provider.of<Auth>(context, listen: false)
                                          .userData?['pan_number'] !=
                                      null &&
                                  Provider.of<Auth>(context, listen: false)
                                          .userData?['pan_number'] !=
                                      ""
                              ? const Color(0xFFFA6E00)
                              : const Color(0xFFA5C8C799),
                          shape: const SmoothRectangleBorder(
                            borderRadius: SmoothBorderRadius.all(SmoothRadius(
                                cornerRadius: 10, cornerSmoothing: 1)),
                          ),
                        ),
                        child: const Icon(
                          Icons.check,
                          color: Colors.white,
                          size: 15,
                        ),
                      ),
                      const Space(
                        16,
                        isHorizontal: true,
                      ),
                      Text(
                        "Payment setup",
                        style: TextStyle(
                            fontSize: 14,
                            color: Provider.of<Auth>(context, listen: false)
                                        .userData?['user_type'] ==
                                    UserType.Vendor.name
                                ? const Color(0xFF0A4C61)
                                : const Color(0xFF2E0536),
                            fontFamily: 'Product Sans',
                            fontWeight: FontWeight.w700),
                      ),
                      const Space(
                        9,
                        isHorizontal: true,
                      ),
                      if (Provider.of<Auth>(context, listen: false)
                                  .userData?['pan_number'] ==
                              null &&
                          Provider.of<Auth>(context, listen: false)
                                  .userData?['pan_number'] ==
                              "") ...[
                        Container(
                          height: 8,
                          width: 8,
                          decoration: const BoxDecoration(
                            color: Color(0xFFF82E52),
                            shape: BoxShape.circle,
                          ),
                        ),
                      ],
                      const Spacer(),
                      Image.asset(
                        Assets.nextIcon,
                        height: 20,
                        width: 8,
                      )
                    ],
                  ),
                ),
                Space(
                  3.h,
                ),
                InkWell(
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const KycView()));
                  },
                  child: Row(
                    children: [
                      Container(
                        height: 25,
                        width: 25,
                        decoration: ShapeDecoration(
                          shadows: const [
                            BoxShadow(
                              offset: Offset(0, 4),
                              color: Color.fromRGBO(165, 200, 199, 0.6),
                              blurRadius: 20,
                            )
                          ],
                          color: Provider.of<Auth>(context, listen: false)
                                          .userData?['bank_name'] !=
                                      null &&
                                  Provider.of<Auth>(context, listen: false)
                                          .userData?['bank_name'] !=
                                      ""
                              ? const Color(0xFFFA6E00)
                              : const Color(0xFFA5C8C799),
                          shape: const SmoothRectangleBorder(
                            borderRadius: SmoothBorderRadius.all(SmoothRadius(
                                cornerRadius: 10, cornerSmoothing: 1)),
                          ),
                        ),
                        child: const Icon(
                          Icons.check,
                          color: Colors.white,
                          size: 15,
                        ),
                      ),
                      const Space(
                        16,
                        isHorizontal: true,
                      ),
                      Text(
                        "KYC & documents",
                        style: TextStyle(
                            fontSize: 14,
                            color: Provider.of<Auth>(context, listen: false)
                                        .userData?['user_type'] ==
                                    UserType.Vendor.name
                                ? const Color(0xFF0A4C61)
                                : const Color(0xFF2E0536),
                            fontFamily: 'Product Sans',
                            fontWeight: FontWeight.w700),
                      ),
                      const Space(
                        9,
                        isHorizontal: true,
                      ),
                      if (Provider.of<Auth>(context, listen: false)
                                  .userData?['bank_name'] ==
                              null &&
                          Provider.of<Auth>(context, listen: false)
                                  .userData?['bank_name'] ==
                              "")
                        Container(
                          height: 8,
                          width: 8,
                          decoration: const BoxDecoration(
                            color: Color(0xFFF82E52),
                            shape: BoxShape.circle,
                          ),
                        ),
                      const Spacer(),
                      Image.asset(
                        Assets.nextIcon,
                        height: 20,
                        width: 8,
                      )
                    ],
                  ),
                ),
              ],
              const Space(24),
              const Text(
                "Please note your store will be live for receiving orders only after your trade & FSSAI license is verified, which will notify once approved.",
                style: TextStyle(
                    fontSize: 9,
                    color: Color(0xFF0A4C61),
                    fontFamily: 'Product Sans',
                    fontWeight: FontWeight.w400),
              ),
              GestureDetector(
                onTap: () {
                  // Handle tap on the area around the BackdropFilter
                  print('Tapped outside of the modal bottom sheet');
                  // You can add any logic here, such as dismissing the modal bottom sheet
                  // For example:
                  // Navigator.of(context).pop();
                },
                child: BackdropFilter(
                  filter: ImageFilter.blur(
                    sigmaX: context.watch<TransitionEffect>().blurSigma,
                    sigmaY: context.watch<TransitionEffect>().blurSigma,
                  ),
                  child: Container(
                    color: Colors.transparent, // Transparent color
                  ),
                ),
              )
            ],
          ),
        ),
      ),
      bottomNavigationBar: Padding(
        padding:
            EdgeInsets.only(bottom: MediaQuery.of(context).padding.bottom + 18),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Center(
              child: TouchableOpacity(
                onTap: () {
                  logout();
                  // widget.updateDataList(newItem);
                },
                child: Container(
                    padding:
                        EdgeInsets.symmetric(horizontal: 6.w, vertical: 1.h),
                    // margin: EdgeInsets.only(bottom: 2.h),

                    decoration: GlobalVariables().ContainerDecoration(
                      offset: const Offset(0, 4),
                      blurRadius: 15,
                      boxColor: const Color.fromRGBO(248, 46, 82, 1),
                      cornerRadius: 10,
                      shadowColor: const Color.fromRGBO(232, 128, 55, 0.5),
                    ),
                    child: const Text(
                      'Log Out',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontFamily: 'Product Sans',
                        fontWeight: FontWeight.w700,
                        // height: 0,
                        letterSpacing: 0.14,
                      ),
                    )),
              ),
            ),
            const Space(18),
            InkWell(
              onTap: () {
                deleteAccount("https://app.cloudbelly.in/delete-my-profile");
              },
              child: const Text(
                "Delete Account",
                style: TextStyle(
                    fontSize: 12,
                    color: Color(0xFF0A4C61),
                    fontFamily: 'Product Sans',
                    fontWeight: FontWeight.w700),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
