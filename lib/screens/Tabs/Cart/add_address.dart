import 'package:cloudbelly_app/api_service.dart';
import 'package:cloudbelly_app/constants/enums.dart';
import 'package:cloudbelly_app/constants/globalVaribales.dart';
import 'package:cloudbelly_app/models/model.dart';
import 'package:cloudbelly_app/prefrence_helper.dart';
import 'package:cloudbelly_app/screens/Tabs/Dashboard/dashboard.dart';
import 'package:cloudbelly_app/screens/Tabs/Dashboard/store_setup_sheets.dart';
import 'package:cloudbelly_app/screens/Tabs/Profile/Profile_setting/profile_setting_view.dart';
import 'package:cloudbelly_app/widgets/appwide_loading_bannner.dart';
import 'package:cloudbelly_app/widgets/appwide_textfield.dart';
import 'package:cloudbelly_app/widgets/space.dart';
import 'package:cloudbelly_app/widgets/toast_notification.dart';
import 'package:cloudbelly_app/widgets/touchableOpacity.dart';
import 'package:figma_squircle/figma_squircle.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:cloudbelly_app/screens/Tabs/Cart/view_cart.dart';

class AddAddressBottomSheet {
  Future<dynamic> AddAddressSheet(BuildContext context, final double latitude,
      final double longitude, final String location, final String type) {
    return showModalBottomSheet(
      // useSafeArea: true,

      context: context,
      isScrollControlled: true,

      builder: (BuildContext context) {
        bool _isVendor =
            Provider.of<Auth>(context, listen: false).userData?['user_type'] ==
                'Vendor';
        // print(data);
        return PopScope(
          canPop: true,
          onPopInvoked: (_) {
            //context.read<TransitionEffect>().set(0);
          },
          child: StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
              return SingleChildScrollView(
                child: Container(
                  decoration: const ShapeDecoration(
                    color: Colors.white,
                    shape: SmoothRectangleBorder(
                      borderRadius: SmoothBorderRadius.only(
                          topLeft: SmoothRadius(
                              cornerRadius: 35, cornerSmoothing: 1),
                          topRight: SmoothRadius(
                              cornerRadius: 35, cornerSmoothing: 1)),
                    ),
                  ),
                  //height: MediaQuery.of(context).size.height * 0.4,
                  width: double.infinity,
                  padding: EdgeInsets.only(
                      top: 2.h,
                      bottom: MediaQuery.of(context).viewInsets.bottom),
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
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
                              height: 5,
                              decoration: ShapeDecoration(
                                color: const Color(0xFFFA6E00),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(6)),
                              ),
                            ),
                          ),
                        ),
                        AddAddressView(
                          latitude: latitude,
                          longitude: longitude,
                          location: location,
                          type: type,
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}

class AddAddressView extends StatefulWidget {
  const AddAddressView({
    super.key,
    required this.latitude,
    required this.longitude,
    required this.location,
    required this.type,
  });

  final double latitude;
  final double longitude;
  final String location;
  final String type;

  @override
  State<AddAddressView> createState() => _AddAddressViewState();
}

class _AddAddressViewState extends State<AddAddressView> {
  List<String> typeList = ["Office", "Home", "Others"];
  int? _currentIndex;
  String type = "";
  final _formKey = GlobalKey<FormState>();
  TextEditingController locationController = TextEditingController();
  TextEditingController flatNoController = TextEditingController();
  TextEditingController pinCodeController = TextEditingController();
  TextEditingController landMarkController = TextEditingController();
  Map<String, dynamic> address = {};

  @override
  void initState() {
    super.initState();
    if (widget.type == "profile") {
      if (Provider.of<Auth>(context, listen: false).userData?['address'] !=
          null) {
        print("address:: ${Provider.of<Auth>(context, listen: false).userData?['address']}");
        locationController.text =
            Provider.of<Auth>(context, listen: false).userData?['address']['location'] ??
                '';
        flatNoController.text = Provider.of<Auth>(context, listen: false).userData?['address']['hno'] ?? '';
        pinCodeController.text = Provider.of<Auth>(context, listen: false).userData?['address']['pincode'] ?? '';
        landMarkController.text = Provider.of<Auth>(context, listen: false).userData?['address']['landmark'] ?? '';
        type = Provider.of<Auth>(context, listen: false).userData?['address']['type'] ?? '';

      }
    }
  }

  void addAddress(BuildContext context) async {
    if (locationController.text.isNotEmpty ||
        flatNoController.text.isNotEmpty ||
        pinCodeController.text.isNotEmpty ||
        landMarkController.text.isNotEmpty) {
      if (type == "") {
        TOastNotification().showErrorToast(context, "Please Select Type");
      } else {
        AppWideLoadingBanner().loadingBanner(context);
        address = {
          "location": locationController.text.trim(),
          "latitude": widget.latitude.toString(),
          "longitude": widget.longitude.toString(),
          "hno": flatNoController.text.trim(),
          "pincode": pinCodeController.text.trim(),
          "landmark": landMarkController.text.trim(),
          "type": type,
        };
        if (widget.type == "cart") {
          String response =
              await Provider.of<Auth>(context, listen: false).addAddress(
            address,
            /* AddressModel(
            location: locationController.text.trim(),
            latitude: widget.latitude.toString(),
            longitude: widget.longitude.toString(),
            hno: flatNoController.text.trim(),
            pincode: pinCodeController.text.trim(),
            landmark: landMarkController.text.trim(),
            type: type,
          ),*/
          );
          Navigator.pop(context);
          if (response == "Delivery details updated successfully") {
            Navigator.pop(context);
            //context.read<TransitionEffect>().set(0);
            Navigator.pushReplacement(
                context, MaterialPageRoute(builder: (context) => ViewCart()));
          } else {
            TOastNotification().showErrorToast(context, response);
          }
        } else {
          String msg = await Provider.of<Auth>(context, listen: false)
              .addressUpdate(address);
          if (msg == 'User information updated successfully.') {
            Provider.of<Auth>(context, listen: false).userData?['address'] ==
                address;
            Map<String, dynamic>? userData = {
              'user_id': Provider.of<Auth>(context, listen: false)
                  .userData?['user_id'],
              'user_name': Provider.of<Auth>(context, listen: false)
                  .userData?['user_name'],
              'email':
                  Provider.of<Auth>(context, listen: false).userData?['email'],
              'store_name': Provider.of<Auth>(context, listen: false)
                  .userData?['store_name'],
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
              if (Provider.of<Auth>(context, listen: false)
                      .userData?['address'] !=
                  null)
                'address': {
                  "location": locationController.text,
                  "latitude": widget.latitude,
                  "longitude": widget.longitude,
                  "hno": flatNoController.text,
                  "pincode": pinCodeController.text,
                  "landmark": landMarkController.text,
                  "type": type,
                },
              if (Provider.of<Auth>(context, listen: false)
                      .userData?['location'] !=
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
              'pincode': pinCodeController.text,
              'rating': Provider.of<Auth>(context, listen: false)
                      .userData?['rating'] ??
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
              'phone': Provider.of<Auth>(context, listen: false)
                      .userData?['phone'] ??
                  '',
              'upi_id': Provider.of<Auth>(context, listen: false)
                      .userData?['upi_id'] ??
                  '',
              'user_type': Provider.of<Auth>(context, listen: false)
                      .userData?['user_type'] ??
                  'Vendor',
            };
            await UserPreferences.setUser(userData);
            //  print('pin: ${pan_number}');
            TOastNotification()
                .showSuccesToast(context, 'Address update successfully');
            Navigator.of(context).pop();
            context.read<TransitionEffect>().setBlurSigma(0);
            Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                    builder: (context) => const ProfileSettingView()));
            // prefs.setInt('counter', 3);
          } else {
            TOastNotification().showErrorToast(context, msg);
            Navigator.of(context).pop();
          }
        }
      }
    } else {
      TOastNotification().showErrorToast(context, "Please Fill All details");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 36.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Space(3.h),
            Text(
              "Enter delivery address",
              style: TextStyle(
                color: Provider.of<Auth>(context, listen: false)
                    .userData?['user_type'] ==
                    UserType.Vendor.name
                    ?   const Color(0xFF0A4C61) :  Provider.of<Auth>(context, listen: false)
                    .userData?['user_type'] ==
                    UserType.Supplier.name
                    ? const Color(0xFF4DBF4A):const Color(0xFF9428A9),
                fontSize: 22,
                fontFamily: 'Jost',
                fontWeight: FontWeight.w700,
              ),
            ),
            const Space(28),
            TextWidgetStoreSetup(
              label: 'Your location',
              color: const Color(0xFF494949),
            ),
            Space(1.h),
            AppwideTextField(
              hintText: 'Type your location here',
              userType: Provider.of<Auth>(context, listen: false)
                  .userData?['user_type'],
              controller: locationController,
              onChanged: (p0) {
                // user_name = p0.toString();
                // print(user_name);
              },
            ),
            Space(
              3.h,
            ),
            TextWidgetStoreSetup(
              label: 'House/flat/block no.',
              color: const Color(0xFF494949),
            ),
            Space(1.h),
            AppwideTextField(
              hintText: 'Type your House/flat/block no. here',
              userType: Provider.of<Auth>(context, listen: false)
                  .userData?['user_type'],
              controller: flatNoController,
              onChanged: (p0) {
                // user_name = p0.toString();
                // print(user_name);
              },
            ),
            Space(
              3.h,
            ),
            TextWidgetStoreSetup(
              label: 'Pin code',
              color: const Color(0xFF494949),
            ),
            Space(1.h),
            AppwideTextField(
              controller: pinCodeController,
              hintText: 'Type your Pin code here',
              userType: Provider.of<Auth>(context, listen: false)
                  .userData?['user_type'],
              onChanged: (p0) {
                // user_name = p0.toString();
                // print(user_name);
              },
            ),
            Space(
              3.h,
            ),
            TextWidgetStoreSetup(
              label: 'Landmark',
              color: const Color(0xFF494949),
            ),
            Space(1.h),
            AppwideTextField(
              controller: landMarkController,
              hintText: 'Type your Landmark here',
              userType: Provider.of<Auth>(context, listen: false)
                  .userData?['user_type'],
              onChanged: (p0) {
                // user_name = p0.toString();
                // print(user_name);
              },
            ),
            Space(
              3.h,
            ),
            const Text(
              "Save as ",
              style: TextStyle(
                color: Color(0xFF9428A9),
                fontSize: 18,
                fontFamily: 'Jost',
                fontWeight: FontWeight.w500,
              ),
            ),
            const Space(20),
            SizedBox(
              height: 40,
              child: ListView.separated(
                  itemCount: typeList.length,
                  shrinkWrap: true,
                  scrollDirection: Axis.horizontal,
                  separatorBuilder: (context, _) {
                    return const Space(
                      12,
                      isHorizontal: true,
                    );
                  },
                  itemBuilder: (context, index) {
                    return InkWell(
                      onTap: () {
                        setState(() {
                          _currentIndex = index;
                          type = typeList[index];
                        });
                      },
                      child: Row(
                        children: [
                          Container(
                            height: 40,
                            width: 40,
                            decoration: GlobalVariables().ContainerDecoration(
                                offset: const Offset(3, 6),
                                blurRadius: 20,
                                shadowColor:
                                    const Color.fromRGBO(158, 116, 158, 0.5),
                                boxColor: type == typeList[index]
                                    ? const Color(0xFFFA6E00)
                                    : const Color(0xFFD272E5),
                                cornerRadius: 8),
                          ),
                          const Space(
                            10,
                            isHorizontal: true,
                          ),
                          Text(
                            typeList[index],
                            style: const TextStyle(
                              color: Color(0xFF2E0536),
                              fontSize: 16,
                              fontFamily: 'Jost',
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
            ),
            const Space(43),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15.0),
              child: SizedBox(
                width: double.infinity,
                height: 48,
                child: TouchableOpacity(
                  onTap: () {
                    addAddress(context);
                  },
                  child: ButtonWidgetHomeScreen(
                    txt: 'Save Address',
                    isActive: true,
                  ),
                ),
              ),
            ),
            const Space(20),
          ],
        ),
      ),
    );
  }
}
