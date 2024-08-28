import 'package:cloudbelly_app/api_service.dart';
import 'package:cloudbelly_app/constants/enums.dart';
import 'package:cloudbelly_app/constants/globalVaribales.dart';
import 'package:cloudbelly_app/prefrence_helper.dart';
import 'package:cloudbelly_app/screens/Tabs/Dashboard/store_setup_sheets.dart';
import 'package:cloudbelly_app/screens/Tabs/Profile/Profile_setting/kyc_view.dart';
import 'package:cloudbelly_app/widgets/appwide_button.dart';
import 'package:cloudbelly_app/widgets/appwide_loading_bannner.dart';
import 'package:cloudbelly_app/widgets/appwide_textfield.dart';
import 'package:cloudbelly_app/widgets/space.dart';
import 'package:cloudbelly_app/widgets/toast_notification.dart';
import 'package:cloudbelly_app/widgets/touchableOpacity.dart';
import 'package:figma_squircle/figma_squircle.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

class PaymentDetailsView extends StatefulWidget {
  const PaymentDetailsView({super.key});

  @override
  State<PaymentDetailsView> createState() => _PaymentDetailsViewState();
}

class _PaymentDetailsViewState extends State<PaymentDetailsView> {
  bool _isSelected = false;
  String bank_name = '';
  String preferred_payment_method = 'Both Online and COD';
  TextEditingController accountNumberController = TextEditingController();
  TextEditingController reEnterAccountNumber = TextEditingController();
  TextEditingController ifscCode = TextEditingController();
  TextEditingController upiController = TextEditingController();
  Map<String, dynamic>? userData;

  @override
  void initState() {
    super.initState();
    userData = UserPreferences.getUser();
    print("userData :: $userData");
    if (Provider.of<Auth>(context, listen: false).userData?['bank_name'] !=
        null) {
      bank_name =
          Provider.of<Auth>(context, listen: false).userData?['bank_name'];
    }
    if (Provider.of<Auth>(context, listen: false)
            .userData?['preferred_payment_method'] !=
        null) {
      preferred_payment_method = Provider.of<Auth>(context, listen: false)
          .userData?['preferred_payment_method'];
    }

    if (Provider.of<Auth>(context, listen: false).userData?['account_number'] !=
        null) {
      accountNumberController.text =
          Provider.of<Auth>(context, listen: false).userData?['account_number'];
      reEnterAccountNumber.text =
          Provider.of<Auth>(context, listen: false).userData?['account_number'];
    }

    if (Provider.of<Auth>(context, listen: false).userData?['ifsc_code'] !=
        null) {
      ifscCode.text =
          Provider.of<Auth>(context, listen: false).userData?['ifsc_code'];
    }

    if (Provider.of<Auth>(context, listen: false).userData?['upi_id'] != null) {
      upiController.text =
          Provider.of<Auth>(context, listen: false).userData?['upi_id'];
    }
  }

  Future<void> _submitForm() async {
    // final prefs = await SharedPreferences.getInstance();
    if ((upiController.text != '' ||
        (bank_name != '' &&
            accountNumberController.text != '' &&
            reEnterAccountNumber.text != '' &&
            ifscCode.text != ''))) {
      if (accountNumberController.text == reEnterAccountNumber.text ||
          upiController.text != '') {
        AppWideLoadingBanner().loadingBanner(context);

        String msg;
        if (upiController.text != '') {
          msg = await Provider.of<Auth>(context, listen: false).storeSetup3(
              '', '', '', upiController.text, preferred_payment_method);
        } else {
          msg = await Provider.of<Auth>(context, listen: false).storeSetup3(
              bank_name,
              accountNumberController.text,
              ifscCode.text,
              '',
              preferred_payment_method);
        }

        if (msg == 'User information updated successfully.') {
          if (upiController.text != '') {
            Provider.of<Auth>(context, listen: false).userData?['upi_id'] =
                upiController.text;
          } else {
            Provider.of<Auth>(context, listen: false).userData?['bank_name'] =
                bank_name;
            Provider.of<Auth>(context, listen: false)
                .userData?['account_number'] = accountNumberController.text;
            Provider.of<Auth>(context, listen: false).userData?['ifsc_code'] =
                ifscCode.text;
          }

          Map<String, dynamic>? userData = {
            'user_id':
                Provider.of<Auth>(context, listen: false).userData?['user_id'],
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
            'bank_name': bank_name ?? '',
            'pincode': Provider.of<Auth>(context, listen: false)
                    .userData?['pincode'] ??
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
            'account_number': accountNumberController.text ?? '',
            'ifsc_code': ifscCode.text ?? '',
            'phone':
                Provider.of<Auth>(context, listen: false).userData?['phone'] ??
                    '',
            'upi_id': upiController.text ?? '',
            'user_type': Provider.of<Auth>(context, listen: false)
                    .userData?['user_type'] ??
                'Vendor',
          };

          await UserPreferences.setUser(userData);
          TOastNotification()
              .showSuccesToast(context, 'Payment details updated');
          Navigator.of(context).pop();
          // prefs.setInt('counter', 4);
        }
        Navigator.of(context).pop();
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
    return SafeArea(
      child: Scaffold(
        body: SingleChildScrollView(
          child: Padding(
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
                      'Payment Setting',
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
                Space(4.h),
                const Text(
                  'Choose any one option. ',
                  style: TextStyle(
                    color: Color(0xFF0A4C61),
                    fontSize: 14,
                    fontFamily: 'Product Sans',
                    fontWeight: FontWeight.bold,
                    height: 0.03,
                    letterSpacing: 0.78,
                  ),
                ),
                Space(2.h),
                const Text(
                  'UPI ID is mandatory  ',
                  style: TextStyle(
                    color: Color(0xFF0A4C61),
                    fontSize: 14,
                    fontFamily: 'Product Sans',
                    fontWeight: FontWeight.bold,
                    height: 0.03,
                    letterSpacing: 0.78,
                  ),
                ),
                Space(
                  4.h,
                ),

                TextWidgetStoreSetup(label: 'Enter your UPI ID'),
                Space(1.h),
                AppwideTextField(
                  controller: upiController,
                  hintText: 'Type your UPI ID here',
                  userType: Provider.of<Auth>(context, listen: false)
                      .userData?['user_type'],
                  onChanged: (p0) {
                    // user_name = p0.toString();
                    // print(user_name);
                  },
                ),

                Space(3.h),
                Container(
                    width: MediaQuery.of(context).size.width - 50,
                    child: TextWidgetStoreSetup(
                        label:
                            'Select preffered payment method for your customers.')),
                Space(1.h),
                Container(
                  padding: const EdgeInsets.only(left: 14),
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
                                : const Color.fromRGBO(130, 47, 130, 0.7),
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
                  child: Center(
                    child: DropdownButton<String>(
                      isExpanded: true,
                      alignment: Alignment.centerLeft,
                      hint: Text(
                        preferred_payment_method.isEmpty
                            ? 'Choose from the list'
                            : preferred_payment_method,
                        textAlign: TextAlign.left,
                        style: TextStyle(
                          fontSize: 14,
                          color: Provider.of<Auth>(context, listen: false)
                                      .userData?['user_type'] ==
                                  UserType.Vendor.name
                              ? const Color(0xFF0A4C61)
                              : const Color(0xFF2E0536),
                          fontFamily: 'Product Sans',
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      onChanged: (value) {
                        setState(() {
                          preferred_payment_method = value.toString();
                          _isSelected = true;
                        });
                      },
                      underline: Container(),
                      items: ['Both Online and COD', 'COD Only', 'Online Only']
                          .map<DropdownMenuItem<String>>((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(
                            value,
                            style: const TextStyle(
                              fontSize: 12,
                              color: Color(0xFF0A4C61),
                              fontFamily: 'Product Sans',
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ),
                Space(
                  3.h,
                ),
                Container(
                    width: MediaQuery.of(context).size.width - 50,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Note:- ',
                          style: TextStyle(
                              fontFamily: 'Product Sans', color: Colors.red,fontSize: 14,fontWeight: FontWeight.bold),
                        ),
                        Text(
                          'If you want delivery from Cloudbelly, choose Online only. We ${"don't"} accept COD for delivery from our end.\n\nIf you can deliver by youself then choose any of your choice',
                          style: TextStyle(
                              fontFamily: 'Product Sans', color: Colors.red,fontSize: 14),
                        ),
                      ],
                    )),
                // TextWidgetStoreSetup(label: 'Select your bank'),
                // Space(1.h),
                // Container(
                //   padding: const EdgeInsets.only(left: 14),
                //   // rgba(165, 200, 199, 1),
                //   decoration:  ShapeDecoration(
                //     shadows: [
                //       BoxShadow(
                //         offset: const Offset(0, 4),
                //         color: Provider.of<Auth>(context,
                //             listen: false)
                //             .userData?['user_type'] ==
                //             UserType.Vendor.name
                //             ? const Color.fromRGBO(
                //             165, 200, 199, 0.6)
                //             : Provider.of<Auth>(context,
                //             listen: false)
                //             .userData?['user_type'] ==
                //             UserType.Supplier.name
                //             ? const Color.fromRGBO(
                //             77, 191, 74, 0.3)
                //             : const Color.fromRGBO(
                //             130, 47, 130, 0.7),
                //         blurRadius: 20,
                //       )
                //     ],
                //     color: Colors.white,
                //     shape: const SmoothRectangleBorder(
                //       borderRadius: SmoothBorderRadius.all(
                //           SmoothRadius(cornerRadius: 10, cornerSmoothing: 1)),
                //     ),
                //   ),
                //   height: 6.h,
                //   child: Center(
                //     child: DropdownButton<String>(
                //       isExpanded: true,
                //       alignment: Alignment.centerLeft,
                //       hint: Text(
                //         bank_name.isEmpty ? 'Choose from the list' : bank_name,
                //         textAlign: TextAlign.left,
                //         style: TextStyle(
                //             fontSize: 14,
                //             color:  Provider.of<Auth>(context, listen: false)
                //                 .userData?['user_type'] ==
                //                 UserType.Vendor.name
                //                 ?  const Color(0xFF0A4C61) : const Color(0xFF2E0536),
                //             fontFamily: 'Product Sans',
                //             fontWeight: FontWeight.w400),
                //       ),
                //       //value: selectedOption,
                //       onChanged: (value) {
                //         setState(() {
                //           bank_name = value.toString();
                //           _isSelected = true;
                //         });
                //       },
                //       underline: Container(),
                //       // This line removes the bottom line
                //       items: GlobalVariables()
                //           .bankNames
                //           .map<DropdownMenuItem<String>>((String value) {
                //         return DropdownMenuItem<String>(
                //           value: value,
                //           child: Text(
                //             value,
                //             style: const TextStyle(
                //                 fontSize: 12,
                //                 color: Color(0xFF0A4C61),
                //                 fontFamily: 'Product Sans',
                //                 fontWeight: FontWeight.w400),
                //           ),
                //         );
                //       }).toList(),
                //     ),
                //   ),
                // ),
                // Space(
                //   3.h,
                // ),
                // TextWidgetStoreSetup(label: 'Enter your account number'),
                // Space(1.h),
                // AppwideTextField(
                //   controller: accountNumberController,
                //   hintText: 'Type your account number here',
                //   userType: Provider.of<Auth>(context,
                //       listen: false)
                //       .userData?['user_type'] ,
                //   onChanged: (p0) {
                //     // user_name = p0.toString();
                //     // print(user_name);
                //   },
                // ),
                // Space(
                //   3.h,
                // ),
                // TextWidgetStoreSetup(label: 'Re-enter you account number '),
                // Space(1.h),
                // AppwideTextField(
                //   controller: reEnterAccountNumber,
                //   hintText: 'Type here account number here',

                //   userType: Provider.of<Auth>(context,
                //       listen: false)
                //       .userData?['user_type'] ,
                //   onChanged: (p0) {
                //     // user_name = p0.toString();
                //     // print(user_name);
                //   },
                // ),
                // Space(
                //   3.h,
                // ),
                // TextWidgetStoreSetup(label: 'Enter IFSC code'),
                // Space(1.h),
                // AppwideTextField(
                //   controller: ifscCode,
                //   hintText: 'Enter your IFSC code here',
                //   userType: Provider.of<Auth>(context,
                //       listen: false)
                //       .userData?['user_type'] ,
                //   onChanged: (p0) {
                //     // user_name = p0.toString();
                //     // print(user_name);
                //   },
                // ),
                // Space(
                //   3.h,
                // ),

                // TextWidgetStoreSetup(label: 'Enter your UPI ID'),
                // Space(1.h),
                // AppwideTextField(
                //   controller: upiController,
                //   hintText: 'Type your UPI ID here',
                //   userType: Provider.of<Auth>(context,
                //       listen: false)
                //       .userData?['user_type'] ,
                //   onChanged: (p0) {
                //     // user_name = p0.toString();
                //     // print(user_name);
                //   },
                // ),
              ],
            ),
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
                  txt: 'Complete payment setup'),
              const Space(17),
              InkWell(
                onTap: () {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (context) => const KycView()));
                },
                child: const Text(
                  'Proceed to KYC & documents',
                  style: TextStyle(
                    color: Color(0xFF0A4C61),
                    fontSize: 12,
                    fontFamily: 'Product Sans',
                    fontWeight: FontWeight.w700,
                    height: 0,
                    letterSpacing: 0.14,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
