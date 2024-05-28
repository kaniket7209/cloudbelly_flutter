import 'dart:ui';

import 'package:cloudbelly_app/api_service.dart';
import 'package:cloudbelly_app/constants/enums.dart';
import 'package:cloudbelly_app/prefrence_helper.dart';
import 'package:cloudbelly_app/screens/Tabs/Dashboard/store_setup_sheets.dart';
import 'package:cloudbelly_app/widgets/appwide_button.dart';
import 'package:cloudbelly_app/widgets/appwide_loading_bannner.dart';
import 'package:cloudbelly_app/widgets/appwide_textfield.dart';
import 'package:cloudbelly_app/widgets/space.dart';
import 'package:cloudbelly_app/widgets/toast_notification.dart';
import 'package:cloudbelly_app/widgets/touchableOpacity.dart';
import 'package:figma_squircle/figma_squircle.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

class KycView extends StatefulWidget {
  const KycView({super.key});

  @override
  State<KycView> createState() => _KycViewState();
}

class _KycViewState extends State<KycView> {
  TextEditingController panController = TextEditingController();
  TextEditingController aadharCardController = TextEditingController();
  String fssai_licence_document = '';
  Map<String, dynamic>? userData;

  @override
  void initState() {
    super.initState();
    userData = UserPreferences.getUser();
    if (Provider.of<Auth>(context, listen: false).userData?['pan_number'] != null) {
      panController.text = Provider.of<Auth>(context, listen: false).userData?['pan_number'];
    }

    if (Provider.of<Auth>(context, listen: false).userData?['aadhar_number'] != null) {
      aadharCardController.text = Provider.of<Auth>(context, listen: false).userData?['aadhar_number'];
    }
  }

  Future<void> _submitForm() async {
    // final prefs = await SharedPreferences.getInstance();
    if (panController.text != '' && aadharCardController.text != '') {
      String msg = await Provider.of<Auth>(context, listen: false).storeSetup2(
          panController.text,
          aadharCardController.text,
          fssai_licence_document);

      if (msg == 'User information updated successfully.') {
        Provider.of<Auth>(context, listen: false).userData?['pan_number'] = panController.text;
        Provider.of<Auth>(context, listen: false).userData?['aadhar_number'] = aadharCardController.text;
        Map<String, dynamic>? userData = {
          'user_id': Provider.of<Auth>(context, listen: false).userData?['user_id'],
          'user_name': Provider.of<Auth>(context, listen: false).userData?['user_name'],
          'email': Provider.of<Auth>(context, listen: false).userData?['email'],
          'store_name': Provider.of<Auth>(context, listen: false).userData?['store_name'],
          'profile_photo': Provider.of<Auth>(context, listen: false).userData?['profile_photo']  ?? '',
          'store_availability': Provider.of<Auth>(context, listen: false).userData?['store_availability'] ?? false,
          'pan_number': panController.text ?? '',
          'aadhar_number': aadharCardController.text ?? '',
          if(Provider.of<Auth>(context, listen: false).userData?['address'] != null)
            'address' :{
              "location": Provider.of<Auth>(context, listen: false).userData?['address']['location'],
              "latitude": Provider.of<Auth>(context, listen: false).userData?['address']['latitude'],
              "longitude": Provider.of<Auth>(context, listen: false).userData?['address']['longitude'],
              "hno": Provider.of<Auth>(context, listen: false).userData?['address']['hno'],
              "pincode": Provider.of<Auth>(context, listen: false).userData?['address']['pincode'],
              "landmark": Provider.of<Auth>(context, listen: false).userData?['address']['landmark'],
              "type": Provider.of<Auth>(context, listen: false).userData?['address']['type'],
            },
          if (Provider.of<Auth>(context, listen: false).userData?['location'] != null)
            'location': {
              'details': Provider.of<Auth>(context, listen: false).userData?['location']['details'] ?? '',
              'latitude': Provider.of<Auth>(context, listen: false).userData?['location']['latitude'] ?? '',
              'longitude': Provider.of<Auth>(context, listen: false).userData?['location']['longitude'] ?? '',
            },
          if (Provider.of<Auth>(context, listen: false).userData?['working_hours'] != null)
            'working_hours': {
              'start_time': Provider.of<Auth>(context, listen: false).userData?['working_hours']['start_time'] ?? '',
              'end_time': Provider.of<Auth>(context, listen: false).userData?['working_hours']['end_time'] ?? '',
            },
          'delivery_addresses': Provider.of<Auth>(context, listen: false).userData?['delivery_addresses'] ?? [],
          'bank_name': Provider.of<Auth>(context, listen: false).userData?['bank_name'] ?? '',
          'pincode': Provider.of<Auth>(context, listen: false).userData?['pincode'] ?? '',
          'rating': Provider.of<Auth>(context, listen: false).userData?['rating'] ?? '-',
          'followers': Provider.of<Auth>(context, listen: false).userData?['followers'] ?? [],
          'followings': Provider.of<Auth>(context, listen: false).userData?['followings'] ?? [],
          'cover_image': Provider.of<Auth>(context, listen: false).userData?['cover_image'] ?? '',
          'account_number': Provider.of<Auth>(context, listen: false).userData?['account_number'] ?? '',
          'ifsc_code': Provider.of<Auth>(context, listen: false).userData?['ifsc_code'] ?? '',
          'phone': Provider.of<Auth>(context, listen: false).userData?['phone'] ?? '',
          'upi_id': Provider.of<Auth>(context, listen: false).userData?['upi_id'] ?? '',
          'user_type': Provider.of<Auth>(context, listen: false).userData?['user_type'] ?? 'Vendor',
        };
        await UserPreferences.setUser(userData);
        //  print('pin: ${pan_number}');
        TOastNotification().showSuccesToast(context, 'KYC details updated');
        if (num == 2) Navigator.of(context).pop();
        Navigator.of(context).pop();
        // prefs.setInt('counter', 3);
      }

      print(msg);
    } else {
      TOastNotification().showErrorToast(context, 'Please fill all fields');
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: const Color(0xFFFFFFFF),
        body: Padding(
          padding: EdgeInsets.symmetric(horizontal: 30.0, vertical: 05.h),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  TouchableOpacity(
                    onTap: () {
                      Navigator.of(context).pop();
                    },
                    child: const Padding(
                      padding:
                          EdgeInsets.only(right: 10.0, top: 10, bottom: 10),
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
                  const Space(
                    14,
                    isHorizontal: true,
                  ),
                  const Text(
                    'KYC & Documents',
                    style: TextStyle(
                      color: Color(0xFF0A4C61),
                      fontSize: 26,
                      fontFamily: 'Jost',
                      fontWeight: FontWeight.w600,
                      height: 0.03,
                      letterSpacing: 0.78,
                    ),
                  ),
                ],
              ),
              Space(
                10.h,
              ),
              TextWidgetStoreSetup(label: 'Enter your PAN '),
              Space(1.h),
              AppwideTextField(
                hintText: 'Type your pan card number here',
                controller: panController,
                userType: Provider.of<Auth>(context,
                    listen: false)
                    .userData?['user_type'],
                onChanged: (p0) {
                  // pan_number = p0.toString();
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
                hintText: 'Type your aadhar card number here',
                controller: aadharCardController,
                userType: Provider.of<Auth>(context,
                    listen: false)
                    .userData?['user_type'] ,
                onChanged: (p0) {
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
                  AppWideLoadingBanner().loadingBanner(context);
                  fssai_licence_document =
                      await Provider.of<Auth>(context, listen: false)
                          .pickImageAndUpoad(context);
                  Navigator.pop(context);
                  setState(() {});
                  print("fassai::${fssai_licence_document}");
                },
                child: Container(
                  // rgba(165, 200, 199, 1),
                  padding: EdgeInsets.symmetric(horizontal: 4.w),
                  decoration:  ShapeDecoration(
                    shadows: [
                      BoxShadow(
                        offset: const Offset(0, 4),
                        color: Provider.of<Auth>(context,
                            listen: false)
                            .userData?['user_type'] ==
                            UserType.Vendor.name
                            ? const Color.fromRGBO(
                            165, 200, 199, 0.6)
                            : Provider.of<Auth>(context,
                            listen: false)
                            .userData?['user_type'] ==
                            UserType.Supplier.name
                            ? const Color.fromRGBO(
                            77, 191, 74, 0.3)
                            : const Color.fromRGBO(
                            130, 47, 130, 0.7),
                        blurRadius: 20,
                      )
                    ],
                    color: Colors.white,
                    shape: const SmoothRectangleBorder(
                      borderRadius: SmoothBorderRadius.all(
                          SmoothRadius(cornerRadius: 10, cornerSmoothing: 1)),
                    ),
                  ),
                  height: 6.h,
                  child:  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Upload',
                        style: TextStyle(
                          color: Provider.of<Auth>(context, listen: false)
                              .userData?['user_type'] ==
                              UserType.Vendor.name
                              ?  const Color(0xFF0A4C61) : const Color(0xFF2E0536),
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
                ),
              ),
              if (fssai_licence_document.isNotEmpty) ...[
                Space(3.h),
                Container(
                  height: 100,
                  width: 100,
                  decoration:
                      BoxDecoration(borderRadius: BorderRadius.circular(12)),
                  child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.network(
                        fssai_licence_document,
                        fit: BoxFit.cover,
                      )),
                ),
              ],
              Space(3.h),
              TouchableOpacity(
                onTap: () {
                  context.read<TransitionEffect>().setBlurSigma(5.0);
                  showModalBottomSheet(
                    context: context,
                    builder: (BuildContext context) {
                      return PopScope(
                        canPop: true,
                        onPopInvoked: (_) {
                          context.read<TransitionEffect>().setBlurSigma(0);
                        },
                        child: Container(
                          // height: 35.h,
                          width: double.infinity,
                          padding: EdgeInsets.only(
                              left: 10.w, right: 5.w, top: 1.h, bottom: 2.h),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Center(
                                child: TouchableOpacity(
                                  onTap: () {
                                    return Navigator.of(context).pop();
                                  },
                                  child: Center(
                                    child: Container(
                                      padding: EdgeInsets.symmetric(
                                          vertical: 1.h,),
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
                                  context
                                      .read<TransitionEffect>()
                                      .setBlurSigma(0);
                                  Navigator.pop(context);
                                },
                                num: 2,
                                txt: 'Okay, got it',
                                ispop: true,
                              ),
                            ],
                          ),
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
        bottomNavigationBar: Padding(
          padding: EdgeInsets.symmetric(
              horizontal: 35.0,
              vertical: MediaQuery.of(context).padding.bottom + 30),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AppWideButton(
                  onTap: () {
                    return _submitForm();
                  },
                  num: 2,
                  txt: userData?['pan_number'] != null && userData?['pan_number'] != "" ? "Update KYC & documents" :'Complete KYC & documents'),
            ],
          ),
        ),
      ),
    );
  }
}
