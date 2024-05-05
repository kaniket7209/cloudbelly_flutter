import 'package:cloudbelly_app/api_service.dart';
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
    if (userData?['bank_name'] != null) {
      bank_name = userData?['bank_name'];
    }

    if (userData?['account_number'] != null) {
      accountNumberController.text = userData?['account_number'];
      reEnterAccountNumber.text = userData?['account_number'];
    }

    if (userData?['ifsc_code'] != null) {
      ifscCode.text = userData?['ifsc_code'];
    }

    if (userData?['upi_id'] != null) {
      upiController.text = userData?['upi_id'];
    }
  }

  Future<void> _submitForm() async {
    // final prefs = await SharedPreferences.getInstance();
    if (bank_name != '' &&
        accountNumberController.text != '' &&
        reEnterAccountNumber.text != '' &&
        ifscCode.text != '' &&
        upiController.text != '') {
      if (accountNumberController.text == reEnterAccountNumber.text) {
        AppWideLoadingBanner().loadingBanner(context);
        String msg = await Provider.of<Auth>(context, listen: false)
            .storeSetup3(bank_name, accountNumberController.text, ifscCode.text,
                upiController.text);

        if (msg == 'User information updated successfully.') {
          Provider.of<Auth>(context, listen: false).userData?['bank_name'] =
              bank_name;
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
                    Space(
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
                Space(
                  10.h,
                ),
                TextWidgetStoreSetup(label: 'Select your bank'),
                Space(1.h),
                Container(
                  padding: EdgeInsets.only(left: 14),
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
                        bank_name.isEmpty ? 'Choose from the list' : bank_name,
                        textAlign: TextAlign.left,
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
                      underline: Container(),
                      // This line removes the bottom line
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
                  controller: accountNumberController,
                  hintText: 'Type your account number here',
                  onChanged: (p0) {
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
                  controller: reEnterAccountNumber,
                  hintText: 'Type here account number here',
                  onChanged: (p0) {
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
                  controller: ifscCode,
                  hintText: 'Enter your IFSC code here',
                  onChanged: (p0) {
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
                  controller: upiController,
                  hintText: 'Type your UPI ID here',
                  onChanged: (p0) {
                    // user_name = p0.toString();
                    // print(user_name);
                  },
                ),
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
              Space(17),
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
