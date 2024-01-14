import 'package:cloudbelly_app/screens/Login/login_screen.dart';
import 'package:cloudbelly_app/widgets/appwide_textfield.dart';
import 'package:cloudbelly_app/widgets/space.dart';
import 'package:cloudbelly_app/widgets/touchableOpacity.dart';
import 'package:figma_squircle/figma_squircle.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

class SlidingSheet {
  void showAlertDialog(BuildContext context, int num) {
    showGeneralDialog(
        transitionBuilder: (context, a1, a2, widget) {
          final curvedValue = Curves.easeInOutBack.transform(a1.value) - 1.05;
          return Transform(
            transform: Matrix4.translationValues(0.0, -curvedValue * 500, 0.0),
            child: Opacity(
              opacity: a1.value,
              child: AlertDialog(
                insetPadding: EdgeInsets.zero,
                contentPadding: EdgeInsets.zero,
                content: num == 1
                    ? const Sheet1()
                    : num == 2
                        ? const Sheet2()
                        : const Sheet3(),
              ),
            ),
          );
        },
        transitionDuration: Duration(milliseconds: 400),
        barrierDismissible: false,
        barrierLabel: '',
        context: context,
        pageBuilder: (context, animation1, animation2) {
          return Container();
        });
  }
}

class Sheet1 extends StatelessWidget {
  const Sheet1({
    super.key,
  });

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
                      hintText: 'Type name here',
                      onChanged: (p0) {
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
                      hintText: 'Type store name here',
                      onChanged: (p0) {
                        // user_name = p0.toString();
                        // print(user_name);
                      },
                    ),
                    Space(
                      3.h,
                    ),
                    TextWidgetStoreSetup(label: 'Where is your store located?'),
                    Space(1.h),
                    AppwideTextField(
                      hintText: 'Choose your location',
                      onChanged: (p0) {
                        // user_name = p0.toString();
                        // print(user_name);
                      },
                    ),
                    Space(
                      3.h,
                    ),
                    TextWidgetStoreSetup(label: 'Please enter pin code'),
                    Space(1.h),
                    AppwideTextField(
                      hintText: 'Enter your pin code',
                      onChanged: (p0) {
                        // user_name = p0.toString();
                        // print(user_name);
                      },
                    ),
                    Space(
                      3.h,
                    ),
                    TextWidgetStoreSetup(label: 'Upload your business’s logo'),
                    Space(1.h),
                    GestureDetector(
                        onTap: () async {
                          final picker = ImagePicker();
                          final pickedImage = await picker.pickImage(
                            source: ImageSource.gallery,
                          );
                          if (pickedImage != null) {
                            String imagePath = pickedImage.path;
                            debugPrint('imaged added');
                            debugPrint(imagePath);
                          }
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
                                'Upload from gallery',
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
                    Space(5.h),
                    SheetButtonStoreSetup(
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
  TextWidgetStoreSetup({
    super.key,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: TextStyle(
        color: Color(0xFF0A4C61),
        fontSize: 14,
        fontFamily: 'Product Sans',
        fontWeight: FontWeight.w700,
        height: 0,
        letterSpacing: 0.14,
      ),
    );
  }
}

class Sheet2 extends StatelessWidget {
  const Sheet2({
    super.key,
  });

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
                            const Icon(
                              Icons.arrow_back_ios_new,
                              color: Color(0xFFFA6E00),
                            ),
                            Space(3.w, isHorizontal: true),
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
                      hintText: 'Type your pan card number here',
                      onChanged: (p0) {
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
                      onChanged: (p0) {
                        // user_name = p0.toString();
                        // print(user_name);
                      },
                    ),
                    Space(
                      3.h,
                    ),
                    TextWidgetStoreSetup(label: 'Max order capacity'),
                    Space(1.h),
                    AppwideTextField(
                      hintText: 'Type here',
                      onChanged: (p0) {
                        // user_name = p0.toString();
                        // print(user_name);
                      },
                    ),
                    Space(
                      3.h,
                    ),
                    TextWidgetStoreSetup(label: 'Minimum time guarantee '),
                    Space(1.h),
                    AppwideTextField(
                      hintText: 'type in hours/week',
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
                          final picker = ImagePicker();
                          final pickedImage = await picker.pickImage(
                            source: ImageSource.gallery,
                          );
                          if (pickedImage != null) {
                            String imagePath = pickedImage.path;
                            debugPrint('imaged added');
                            debugPrint(imagePath);
                          }
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
                                  SheetButtonStoreSetup(
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
                    Space(2.h),
                    SheetButtonStoreSetup(
                        num: 2, txt: 'Continue to payment details'),
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

class Sheet3 extends StatelessWidget {
  const Sheet3({
    super.key,
  });

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
                        Text(
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
                    AppwideTextField(
                      hintText: 'Choose from the list',
                      onChanged: (p0) {
                        // user_name = p0.toString();
                        // print(user_name);
                      },
                    ),
                    Space(
                      3.h,
                    ),
                    TextWidgetStoreSetup(label: 'Enter your account number'),
                    Space(1.h),
                    AppwideTextField(
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
                      hintText: 'Type your UPI ID here',
                      onChanged: (p0) {
                        // user_name = p0.toString();
                        // print(user_name);
                      },
                    ),
                    Space(5.h),
                    SheetButtonStoreSetup(num: 3, txt: 'Go to main screen'),
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

// ignore: must_be_immutable
class SheetButtonStoreSetup extends StatelessWidget {
  int num;
  String txt;
  bool ispop;
  SheetButtonStoreSetup({
    super.key,
    required this.num,
    required this.txt,
    this.ispop = false,
  });

  @override
  Widget build(BuildContext context) {
    return TouchableOpacity(
      onTap: () {
        if (ispop) Navigator.of(context).pop();
        Navigator.of(context).pop();
        if (num < 3) SlidingSheet().showAlertDialog(context, num + 1);
      },
      child: Center(
        child: Container(
          height: 6.h,
          width: 100.w,
          // width: ,
          padding: EdgeInsets.symmetric(horizontal: 3.w),
          decoration: const ShapeDecoration(
            shadows: [
              BoxShadow(
                offset: Offset(0, 4),
                color: Color.fromRGBO(0, 0, 0, 0.25),
                blurRadius: 4,
              )
            ],
            color: Color.fromRGBO(250, 110, 0, 0.7),
            shape: SmoothRectangleBorder(
              borderRadius: SmoothBorderRadius.all(
                  SmoothRadius(cornerRadius: 10, cornerSmoothing: 1)),
            ),
          ),
          child: Center(
              child: Row(
            children: [
              Container(
                height: 4.h,
                width: 35,
                decoration: const ShapeDecoration(
                  color: Colors.white,
                  shape: SmoothRectangleBorder(
                    borderRadius: SmoothBorderRadius.all(
                        SmoothRadius(cornerRadius: 10, cornerSmoothing: 1)),
                  ),
                ),
              ),
              Space(isHorizontal: true, num == 2 ? 10.w : 15.w),
              Text(
                txt,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontFamily: 'Product Sans',
                  fontWeight: FontWeight.w700,
                  height: 0,
                  letterSpacing: 0.16,
                ),
              ),
            ],
          )),
        ),
      ),
    );
  }
}
