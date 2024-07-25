// ignore_for_file: must_be_immutable

import 'package:cloudbelly_app/constants/enums.dart';
import 'package:cloudbelly_app/constants/globalVaribales.dart';
import 'package:cloudbelly_app/api_service.dart';
import 'package:cloudbelly_app/widgets/appwide_button.dart';
import 'package:cloudbelly_app/widgets/appwide_textfield.dart';

import 'package:cloudbelly_app/widgets/space.dart';
import 'package:cloudbelly_app/widgets/toast_notification.dart';
import 'package:cloudbelly_app/widgets/touchableOpacity.dart';
import 'package:figma_squircle/figma_squircle.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:provider/provider.dart';

import 'package:responsive_sizer/responsive_sizer.dart';

class SlidingSheet {
  void showAlertDialog(BuildContext context, int num) {
    showGeneralDialog(
        transitionBuilder: (context, a1, a2, widget) {
          final curvedValue = Curves.easeInOutBack.transform(a1.value) - 1.05;
          return ConstrainedBox(
            constraints: const BoxConstraints(
              maxWidth: 400, // Set the maximum width to 800
            ),
            child: Transform(
              transform:
                  Matrix4.translationValues(0.0, -curvedValue * 500, 0.0),
              child: Opacity(
                opacity: a1.value,
                child: AlertDialog(
                    insetPadding: EdgeInsets.zero,
                    contentPadding: EdgeInsets.zero,
                    content: ConstrainedBox(
                      constraints: const BoxConstraints(
                        maxWidth: 420, // Set the maximum width to 800
                      ),
                      child: num == 1
                          ? Sheet1()
                          : num == 2
                              ? const Sheet2()
                              : const Sheet3(),
                    )),
              ),
            ),
          );
        },
        transitionDuration: const Duration(milliseconds: 400),
        barrierDismissible: false,
        barrierLabel: '',
        context: context,
        pageBuilder: (context, animation1, animation2) {
          return Container();
        });
  }
}

class Sheet1 extends StatefulWidget {
  @override
  State<Sheet1> createState() => _Sheet1State();
}

class _Sheet1State extends State<Sheet1> with SingleTickerProviderStateMixin {
  String user_name = '';

  String store_name = '';

  String pincode = '';

  String profile_photo = '';

  String location_details = '';

  String latitude = '';

  String longitude = '';

  String max_order_capacity = '';

  Future<void> _SubmitForm() async {
    // final prefs = await SharedPreferences.getInstance();

    if (user_name != '' &&
        store_name != '' &&
        pincode != '' &&
        location_details != '' &&
        max_order_capacity != '' &&
        profile_photo != 'file size very large') {
      String pinStatus = await Provider.of<Auth>(context, listen: false)
          .postalCodeCheck(pincode);
      print('status: $pinStatus');

      if (pinStatus == 'Success') {
        String msg = await Provider.of<Auth>(context, listen: false)
            .storeSetup1(user_name, pincode, profile_photo, location_details,
                latitude, longitude, store_name, max_order_capacity);

        if (msg == 'User information updated successfully.') {
          Provider.of<Auth>(context, listen: false).userData?['pincode'] =
              pincode;
          Provider.of<Auth>(context, listen: false).logo_url = profile_photo;
          // print(Provider.of<Auth>(context, listen: false).pincode);
          TOastNotification().showSuccesToast(context, 'User Details Updated');
          Navigator.of(context).pop();
          SlidingSheet().showAlertDialog(context, 2);

          // prefs.setInt('counter', 2);
        }
      } else {
        TOastNotification()
            .showErrorToast(context, 'Entered pin-code is not valid');
      }
    } else {
      TOastNotification().showErrorToast(context, 'Please fill all fields');
    }
  }

  bool _isImageUploading = false;
  Position? _currentPosition;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    this.initData();
  }

  initData() async {
    final hasPermission = await _handleLocationPermission();

    if (hasPermission)
      await Geolocator.getCurrentPosition(
              desiredAccuracy: LocationAccuracy.high)
          .then((Position position) {
        print(position);
        setState(() => _currentPosition = position);
      }).catchError((e) {
        debugPrint(e);
      });

    if (_currentPosition != null) {
      latitude = _currentPosition!.latitude.toString();
      longitude = _currentPosition!.longitude.toString();
    } else {}
  }

  Future<bool> _handleLocationPermission() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text(
              'Location services are disabled. Please enable the services')));
      return false;
    }
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Location permissions are denied')));
        return false;
      }
    }
    if (permission == LocationPermission.deniedForever) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text(
              'Location permissions are permanently denied, we cannot request permissions.')));
      return false;
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 90.w,
      decoration: const ShapeDecoration(
        shadows: [
          BoxShadow(
              color: Color.fromRGBO(165, 200, 199, 0.4),
              blurRadius: 10,
              spreadRadius: 4)
        ],
        color: Colors.white,
        shape: SmoothRectangleBorder(
          borderRadius: SmoothBorderRadius.all(
              SmoothRadius(cornerRadius: 25, cornerSmoothing: 1)),
        ),
      ),
      child: SingleChildScrollView(
        child: Center(
          child: Column(
            children: [
              Space(1.5.h),
              TouchableOpacity(
                onTap: () {
                  Navigator.popUntil(
                      context, ModalRoute.withName('/tabs-screen'));
                },
                child: Container(
                  padding: EdgeInsets.symmetric(vertical: 1.h, horizontal: 3.w),
                  width: 55,
                  height: 9,
                  decoration: ShapeDecoration(
                    color: const Color(0xFFFA6E00),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(6)),
                  ),
                ),
              ),
              Space(2.5.h),
              Container(
                margin:
                    const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Store Setup',
                          style: TextStyle(
                            color: Color(0xFF094B60),
                            fontSize: 26,
                            fontFamily: 'Jost',
                            fontWeight: FontWeight.w600,
                            height: 0.03,
                            letterSpacing: 0.78,
                          ),
                        ),
                        Text(
                          '1/3',
                          style: TextStyle(
                            color: Color(0xFFFA6E00),
                            fontSize: 12,
                            fontFamily: 'Jost',
                            fontWeight: FontWeight.w600,
                            height: 0.14,
                            letterSpacing: 0.36,
                          ),
                        )
                      ],
                    ),
                    Space(
                      4.h,
                    ),
                    TextWidgetStoreSetup(label: 'Enter business owner’s name'),
                    Space(1.h),
                    AppwideTextField(
                      userType: Provider.of<Auth>(context, listen: false)
                          .userData?['user_type'],
                      hintText: 'Type name here',
                      onChanged: (p0) {
                        user_name = p0.toString();
                        // user_name = p0.toString();
                        // print(user_name);
                      },
                    ),
                    Space(
                      3.h,
                    ),
                    TextWidgetStoreSetup(label: 'Enter store name'),
                    Space(1.h),
                    AppwideTextField(
                      userType: Provider.of<Auth>(context, listen: false)
                          .userData?['user_type'],
                      hintText: 'Type store name here',
                      onChanged: (p0) {
                        store_name = p0.toString();
                      },
                    ),
                    Space(
                      3.h,
                    ),
                    TextWidgetStoreSetup(label: 'Where is your store located?'),
                    Space(1.h),
                    AppwideTextField(
                      userType: Provider.of<Auth>(context, listen: false)
                          .userData?['user_type'],
                      hintText: 'Enter your location',
                      onChanged: (p0) async {
                        location_details = p0.toString();
                      },
                    ),
                    Space(
                      3.h,
                    ),
                    TextWidgetStoreSetup(label: 'Please enter pin code'),
                    Space(1.h),
                    AppwideTextField(
                      userType: Provider.of<Auth>(context, listen: false)
                          .userData?['user_type'],
                      hintText: 'Enter your pin code',
                      onChanged: (p0) {
                        pincode = p0.toString();
                        // user_name = p0.toString();
                        // print(user_name);
                      },
                    ),
                    Space(
                      3.h,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        TextWidgetStoreSetup(
                            label: 'Upload your business’s logo'),
                        if (_isImageUploading)
                          const SizedBox(
                              height: 10,
                              width: 10,
                              child: CircularProgressIndicator(
                                color: Colors.orange,
                              ))
                      ],
                    ),
                    Space(1.h),
                    GestureDetector(
                        onTap: () async {
                          setState(() {
                            _isImageUploading = true;
                          });
                          profile_photo =
                              await Provider.of<Auth>(context, listen: false)
                                  .pickImageAndUpoad(context);
                          if (profile_photo == 'file size very large') {
                            TOastNotification().showErrorToast(
                                context, 'file size very large');
                          }
                          print(profile_photo);
                          setState(() {
                            _isImageUploading = false;
                          });
                        },
                        child: Container(
                          // rgba(165, 200, 199, 1),
                          padding: EdgeInsets.symmetric(horizontal: 4.w),
                          decoration: const ShapeDecoration(
                            shadows: [
                              BoxShadow(
                                offset: Offset(0, 4),
                                color: Color.fromRGBO(165, 200, 199, 0.6),
                                blurRadius: 20,
                              )
                            ],
                            color: Colors.white,
                            shape: SmoothRectangleBorder(
                              borderRadius: SmoothBorderRadius.all(SmoothRadius(
                                  cornerRadius: 10, cornerSmoothing: 1)),
                            ),
                          ),
                          height: 6.h,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                profile_photo == '' ||
                                        profile_photo == 'file size very large'
                                    ? 'Upload from gallery'
                                    : 'Image Uploaded !',
                                style: const TextStyle(
                                  color: Color(0xFF0A4C61),
                                  fontSize: 12,
                                  fontFamily: 'Product Sans',
                                  fontWeight: FontWeight.w400,
                                  height: 0,
                                  letterSpacing: 0.12,
                                ),
                              ),
                              const Icon(
                                Icons.add,
                                color: Color.fromRGBO(250, 110, 0, 0.7),
                              )
                            ],
                          ),
                        )),
                    Space(
                      3.h,
                    ),
                    TextWidgetStoreSetup(label: 'Max order capacity'),
                    Space(1.h),
                    AppwideTextField(
                      userType: Provider.of<Auth>(context, listen: false)
                          .userData?['user_type'],
                      hintText: 'Type here',
                      onChanged: (p0) {
                        max_order_capacity = p0.toString();
                        // user_name = p0.toString();
                        // print(user_name);
                      },
                    ),
                    Space(5.h),
                    AppWideButton(
                      onTap: () {
                        // print('999999');
                        return _SubmitForm();
                      },
                      num: 1,
                      txt: 'Continue to KYC',
                    )
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class TextWidgetStoreSetup extends StatelessWidget {
  String label;
  Color? color;

  TextWidgetStoreSetup({
    super.key,
    required this.label,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
     Color boxShadowColor;
    String userType =
        Provider.of<Auth>(context, listen: false).userData?['user_type'];
    if (userType == 'Vendor') {
      boxShadowColor = const Color(0xff0A4C61);
    } else if (userType == 'Customer') {
      boxShadowColor = const Color(0xff2E0536);
    } else if (userType == 'Supplier') {
      boxShadowColor = Color.fromARGB(0, 115, 188, 150);
    } else {
      boxShadowColor = const Color.fromRGBO(77, 191, 74, 0.6);
    }
    return Text(
      label,
      style: Provider.of<Auth>(context, listen: false)
          .userData?['user_type'] ==
          UserType.Vendor.name
          ? TextStyle(
        color: color ?? const Color(0xFF0A4C61),
        fontSize: 16,
        fontFamily: 'PT Sans Black',
        fontWeight: FontWeight.w800,
       // letterSpacing: 1,
      ) : TextStyle(
        color: color ?? const Color(0xFF494949),
        fontSize: 16,
        fontFamily: 'PT Sans',
        fontWeight: FontWeight.w700,
        height: 0,
        letterSpacing: 0.14,
      ),
    );
  }
}

class Sheet2 extends StatefulWidget {
  const Sheet2({
    super.key,
  });

  @override
  State<Sheet2> createState() => _Sheet2State();
}

class _Sheet2State extends State<Sheet2> with SingleTickerProviderStateMixin {
  String pan_number = '';

  String aadhar_number = '';

  String fssai_licence_document = '';

  Future<void> _SubmitForm({int num = 1}) async {
    // final prefs = await SharedPreferences.getInstance();
    if (pan_number != '' && aadhar_number != '') {
      String msg = await Provider.of<Auth>(context, listen: false)
          .storeSetup2(pan_number, aadhar_number, fssai_licence_document);

      if (msg == 'User information updated successfully.') {
        Provider.of<Auth>(context, listen: false).userData?['pan_number'] ==
            pan_number;
        print('pin: ${pan_number}');
        TOastNotification().showSuccesToast(context, 'KYC details updated');
        if (num == 2) Navigator.of(context).pop();
        Navigator.of(context).pop();
        SlidingSheet().showAlertDialog(context, 3);
        // prefs.setInt('counter', 3);
      }

      print(msg);
    } else {
      TOastNotification().showErrorToast(context, 'Please fill all fields');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 80.h,
      width: 90.w,
      decoration: const ShapeDecoration(
        shadows: [
          BoxShadow(
              color: Color.fromRGBO(165, 200, 199, 0.4),
              blurRadius: 10,
              spreadRadius: 4)
        ],
        color: Colors.white,
        shape: SmoothRectangleBorder(
          borderRadius: SmoothBorderRadius.all(
              SmoothRadius(cornerRadius: 35, cornerSmoothing: 1)),
        ),
      ),
      child: SingleChildScrollView(
        child: Center(
          child: Column(
            children: [
              Space(1.5.h),
              TouchableOpacity(
                onTap: () {
                  return Navigator.popUntil(
                      context, ModalRoute.withName('/tabs-screen'));
                },
                child: Container(
                  padding: EdgeInsets.symmetric(vertical: 1.h, horizontal: 3.w),
                  width: 55,
                  height: 9,
                  decoration: ShapeDecoration(
                    color: const Color(0xFFFA6E00),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(6)),
                  ),
                ),
              ),
              Space(2.5.h),
              Container(
                margin:
                    const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            TouchableOpacity(
                              onTap: () {
                                Navigator.of(context).pop();
                                SlidingSheet().showAlertDialog(context, 1);
                              },
                              child: const Padding(
                                padding: EdgeInsets.only(
                                    right: 10.0, top: 10, bottom: 10),
                                child: Text(
                                  '<<',
                                  style: TextStyle(
                                    color: Color(0xFFFA6E00),
                                    fontSize: 22,
                                    fontFamily: 'Kavoon',
                                    fontWeight: FontWeight.w400,
                                    height: 0.04,
                                    letterSpacing: 0.66,
                                  ),
                                ),
                              ),
                            ),
                            // Space(2.w, isHorizontal: true),
                            const Text(
                              'KYC',
                              style: TextStyle(
                                color: Color(0xFF094B60),
                                fontSize: 26,
                                fontFamily: 'Jost',
                                fontWeight: FontWeight.w600,
                                height: 0.03,
                                letterSpacing: 0.78,
                              ),
                            ),
                          ],
                        ),
                        const Text(
                          '2/3',
                          style: TextStyle(
                            color: Color(0xFFFA6E00),
                            fontSize: 12,
                            fontFamily: 'Jost',
                            fontWeight: FontWeight.w600,
                            height: 0.14,
                            letterSpacing: 0.36,
                          ),
                        )
                      ],
                    ),
                    Space(
                      4.h,
                    ),
                    TextWidgetStoreSetup(label: 'Enter your PAN '),
                    Space(1.h),
                    AppwideTextField(
                      userType: Provider.of<Auth>(context, listen: false)
                          .userData?['user_type'],
                      hintText: 'Type your pan card number here',
                      onChanged: (p0) {
                        pan_number = p0.toString();
                        // user_name = p0.toString();
                        // print(user_name);
                      },
                    ),
                    Space(
                      3.h,
                    ),
                    TextWidgetStoreSetup(label: 'Aadhar card'),
                    Space(1.h),
                    AppwideTextField(
                      userType: Provider.of<Auth>(context, listen: false)
                          .userData?['user_type'],
                      hintText: 'Type your aadhar card number here',
                      onChanged: (p0) {
                        aadhar_number = p0.toString();
                        // user_name = p0.toString();
                        // print(user_name);
                      },
                    ),
                    Space(
                      3.h,
                    ),
                    TextWidgetStoreSetup(label: 'Upload your FSSAI licence'),
                    Space(1.h),
                    GestureDetector(
                        onTap: () async {
                          fssai_licence_document =
                              await Provider.of<Auth>(context, listen: false)
                                  .pickImageAndUpoad(context);
                        },
                        child: Container(
                          // rgba(165, 200, 199, 1),
                          padding: EdgeInsets.symmetric(horizontal: 4.w),
                          decoration: const ShapeDecoration(
                            shadows: [
                              BoxShadow(
                                offset: Offset(0, 4),
                                color: Color.fromRGBO(165, 200, 199, 0.6),
                                blurRadius: 20,
                              )
                            ],
                            color: Colors.white,
                            shape: SmoothRectangleBorder(
                              borderRadius: SmoothBorderRadius.all(SmoothRadius(
                                  cornerRadius: 10, cornerSmoothing: 1)),
                            ),
                          ),
                          height: 6.h,
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Upload',
                                style: TextStyle(
                                  color: Color(0xFF0A4C61),
                                  fontSize: 12,
                                  fontFamily: 'Product Sans',
                                  fontWeight: FontWeight.w400,
                                  height: 0,
                                  letterSpacing: 0.12,
                                ),
                              ),
                              Icon(
                                Icons.add,
                                color: Color.fromRGBO(250, 110, 0, 0.7),
                              )
                            ],
                          ),
                        )),
                    Space(3.h),
                    TouchableOpacity(
                      onTap: () {
                        showModalBottomSheet(
                          context: context,
                          builder: (BuildContext context) {
                            return Container(
                              height: 35.h,
                              width: double.infinity,
                              padding: EdgeInsets.only(
                                  left: 10.w,
                                  right: 5.w,
                                  top: 1.h,
                                  bottom: 2.h),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
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
                                  const Center(
                                    child: Text(
                                      'Don’t have FSSAI yet?',
                                      style: TextStyle(
                                        color: Color(0xFF0A4C61),
                                        fontSize: 24,
                                        fontFamily: 'Jost',
                                        fontWeight: FontWeight.w600,
                                        height: 0,
                                      ),
                                    ),
                                  ),
                                  Space(3.h),
                                  const Text(
                                    'You can apply for FSSAI on the last step as well',
                                    style: TextStyle(
                                      color: Color(0xFF094B60),
                                      fontSize: 16,
                                      fontFamily: 'Product Sans',
                                      fontWeight: FontWeight.w400,
                                    ),
                                  ),
                                  Space(3.h),
                                  const Text(
                                    'You can also apply directly on the ',
                                    style: TextStyle(
                                      color: Color(0xFF094B60),
                                      fontSize: 16,
                                      fontFamily: 'Product Sans',
                                      fontWeight: FontWeight.w400,
                                      height: 0.09,
                                    ),
                                  ),
                                  Space(1.5.h),
                                  const Text('Government portal.',
                                      style: TextStyle(
                                        color: Color(0xFF2D33C5),
                                        fontSize: 16,
                                        fontFamily: 'Product Sans',
                                        fontWeight: FontWeight.w400,
                                      )),
                                  Container(
                                    height: 1,
                                    width: 130,
                                    color: const Color(0xFF2D33C5),
                                  ),
                                  Space(4.h),
                                  AppWideButton(
                                    onTap: () {
                                      return _SubmitForm(num: 2);
                                    },
                                    num: 2,
                                    txt: 'Continue to payment details',
                                    ispop: true,
                                  ),
                                ],
                              ),
                            );
                          },
                        );
                      },
                      child: Center(
                        child: Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: Column(
                            children: [
                              const Text(
                                'Don’t have FSSAI licence?',
                                style: TextStyle(
                                  color: Color(0xFFE77E37),
                                  fontSize: 12,
                                  fontFamily: 'Product Sans',
                                  fontWeight: FontWeight.w400,
                                  letterSpacing: 0.12,
                                ),
                              ),
                              Container(
                                height: 2,
                                width: 140,
                                color: const Color(0xFFE77E37),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    Space(18.h),
                    AppWideButton(
                        onTap: () {
                          return _SubmitForm();
                        },
                        num: 2,
                        txt: 'Continue to payment details'),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class Sheet3 extends StatefulWidget {
  const Sheet3({
    super.key,
  });

  @override
  State<Sheet3> createState() => _Sheet3State();
}

class _Sheet3State extends State<Sheet3> with SingleTickerProviderStateMixin {
  // String bankList = [];
  bool _isSelected = false;
  String bank_name = '';
  String account_number = '';
  String re_account_number = '';
  String ifsc_code = '';
  String upi_id = '';
  String preferred_payment_method = 'both';

  Future<void> _SubmitForm() async {
    // final prefs = await SharedPreferences.getInstance();
    if (bank_name != '' &&
        account_number != '' &&
        re_account_number != '' &&
        ifsc_code != '' &&
        upi_id != '') {
      if (account_number == re_account_number) {
        String msg = await Provider.of<Auth>(context, listen: false)
            .storeSetup3(bank_name, account_number, ifsc_code, upi_id,preferred_payment_method);

        if (msg == 'User information updated successfully.') {
          Provider.of<Auth>(context, listen: false).userData?['bank_name'] =
              bank_name;
          TOastNotification()
              .showSuccesToast(context, 'Payment details updated');
          Navigator.of(context).pop();
          // prefs.setInt('counter', 4);
        }

        print(msg);
      } else {
        TOastNotification()
            .showErrorToast(context, 'Fill Account number properly');
      }
    } else {
      TOastNotification().showErrorToast(context, 'Please fill all fields');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 90.w,
      decoration: const ShapeDecoration(
        shadows: [
          BoxShadow(
              color: Color.fromRGBO(165, 200, 199, 0.4),
              blurRadius: 10,
              spreadRadius: 4)
        ],
        color: Colors.white,
        shape: SmoothRectangleBorder(
          borderRadius: SmoothBorderRadius.all(
              SmoothRadius(cornerRadius: 25, cornerSmoothing: 1)),
        ),
      ),
      child: SingleChildScrollView(
        child: Center(
          child: Column(
            children: [
              Space(1.5.h),
              TouchableOpacity(
                onTap: () {
                  Navigator.popUntil(
                      context, ModalRoute.withName('/tabs-screen'));
                },
                child: Container(
                  padding: EdgeInsets.symmetric(vertical: 1.h, horizontal: 3.w),
                  width: 55,
                  height: 9,
                  decoration: ShapeDecoration(
                    color: const Color(0xFFFA6E00),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(6)),
                  ),
                ),
              ),
              Space(2.5.h),
              Container(
                margin:
                    const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        TouchableOpacity(
                          onTap: () {
                            Navigator.of(context).pop();
                            SlidingSheet().showAlertDialog(context, 2);
                          },
                          child: const Padding(
                            padding: EdgeInsets.only(
                                right: 10.0, top: 10, bottom: 10),
                            child: Text(
                              '<<',
                              style: TextStyle(
                                color: Color(0xFFFA6E00),
                                fontSize: 22,
                                fontFamily: 'Kavoon',
                                fontWeight: FontWeight.w400,
                                height: 0.04,
                                letterSpacing: 0.66,
                              ),
                            ),
                          ),
                        ),
                        const Text(
                          'Payment Details',
                          style: TextStyle(
                            color: Color(0xFF094B60),
                            fontSize: 26,
                            fontFamily: 'Jost',
                            fontWeight: FontWeight.w600,
                            height: 0.03,
                            letterSpacing: 0.78,
                          ),
                        ),
                        const Spacer(),
                        const Text(
                          '3/3',
                          style: TextStyle(
                            color: Color(0xFFFA6E00),
                            fontSize: 12,
                            fontFamily: 'Jost',
                            fontWeight: FontWeight.w600,
                            height: 0.14,
                            letterSpacing: 0.36,
                          ),
                        )
                      ],
                    ),
                    Space(
                      4.h,
                    ),
                    TextWidgetStoreSetup(label: 'Select your bank'),
                    Space(1.h),
                    Container(
                      // rgba(165, 200, 199, 1),
                      decoration: const ShapeDecoration(
                        shadows: [
                          BoxShadow(
                            offset: Offset(0, 4),
                            color: Color.fromRGBO(165, 200, 199, 0.6),
                            blurRadius: 20,
                          )
                        ],
                        color: Colors.white,
                        shape: SmoothRectangleBorder(
                          borderRadius: SmoothBorderRadius.all(SmoothRadius(
                              cornerRadius: 10, cornerSmoothing: 1)),
                        ),
                      ),
                      height: 6.h,
                      child: Center(
                        child: DropdownButton<String>(
                          hint: Text(
                            !_isSelected ? 'Choose from the list' : bank_name,
                            style: const TextStyle(
                                fontSize: 14,
                                color: Color(0xFF0A4C61),
                                fontFamily: 'Product Sans',
                                fontWeight: FontWeight.w400),
                          ),
                          //value: selectedOption,

                          onChanged: (value) {
                            setState(() {
                              bank_name = value.toString();
                              _isSelected = true;
                            });
                          },
                          underline:
                              Container(), // This line removes the bottom line
                          items: GlobalVariables()
                              .bankNames
                              .map<DropdownMenuItem<String>>((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(
                                value,
                                style: const TextStyle(
                                    fontSize: 12,
                                    color: Color(0xFF0A4C61),
                                    fontFamily: 'Product Sans',
                                    fontWeight: FontWeight.w400),
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ),
                    Space(
                      3.h,
                    ),
                    TextWidgetStoreSetup(label: 'Enter your account number'),
                    Space(1.h),
                    AppwideTextField(
                      userType: Provider.of<Auth>(context, listen: false)
                          .userData?['user_type'],
                      hintText: 'Type your account number here',
                      onChanged: (p0) {
                        account_number = p0.toString();
                        // user_name = p0.toString();
                        // print(user_name);
                      },
                    ),
                    Space(
                      3.h,
                    ),
                    TextWidgetStoreSetup(label: 'Re-enter you account number '),
                    Space(1.h),
                    AppwideTextField(
                      userType: Provider.of<Auth>(context, listen: false)
                          .userData?['user_type'],
                      hintText: 'Type here account number here',
                      onChanged: (p0) {
                        re_account_number = p0.toString();
                        // user_name = p0.toString();
                        // print(user_name);
                      },
                    ),
                    Space(
                      3.h,
                    ),
                    TextWidgetStoreSetup(label: 'Enter IFSC code'),
                    Space(1.h),
                    AppwideTextField(
                      userType: Provider.of<Auth>(context, listen: false)
                          .userData?['user_type'],
                      hintText: 'Enter your IFSC code here',
                      onChanged: (p0) {
                        ifsc_code = p0.toString();
                        // user_name = p0.toString();
                        // print(user_name);
                      },
                    ),
                    Space(
                      3.h,
                    ),
                    TextWidgetStoreSetup(label: 'Enter your UPI ID'),
                    Space(1.h),
                    AppwideTextField(
                      userType: Provider.of<Auth>(context, listen: false)
                          .userData?['user_type'],
                      hintText: 'Type your UPI ID here',
                      onChanged: (p0) {
                        upi_id = p0.toString();
                        // user_name = p0.toString();
                        // print(user_name);
                      },
                    ),
                    Space(5.h),
                    AppWideButton(
                        onTap: () {
                          return _SubmitForm();
                        },
                        num: 3,
                        txt: 'Go to main screen'),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
