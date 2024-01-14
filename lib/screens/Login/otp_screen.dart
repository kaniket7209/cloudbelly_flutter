import 'package:cloudbelly_app/widgets/appwide_banner.dart';

import 'package:cloudbelly_app/screens/Tabs/tabs.dart';
import 'package:flutter/material.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

class OtpScreen extends StatefulWidget {
  const OtpScreen({super.key});
  static const routeName = '/otp-screen';

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  List<FocusNode> _focusNodes = [];
  List<TextEditingController> _controllers = [];

  String number = '';

  // bool _didchanged = true;
  @override
  void didChangeDependencies() {
    // if (_didchanged) {
    //   setState(() {
    //     final args =
    //         ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    //     number = args['number'] as String;
    //   });
    //   _didchanged = false;
    // }

    // TODO: implement didChangeDependencies
    super.didChangeDependencies();
  }

  @override
  void initState() {
    _otpLength = 4;
    for (int i = 0; i < _otpLength; i++) {
      _focusNodes.add(FocusNode());
      _controllers.add(TextEditingController());
    }
    super.initState();
  }

  int _otpLength = 4;

  void _onTextChanged(int index) {
    if (index < _otpLength - 1) {
      _focusNodes[index].unfocus();
      _focusNodes[index + 1].requestFocus();
    } else {
      _focusNodes[index].unfocus();

      Navigator.of(context).pushNamed(Tabs.routeName);
    }
  }

  void _showDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          // title: Text('Dialog Title'),
          content: Container(
            height: 160,
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    const Text(
                      'Get your OTP on',
                      style:
                          TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
                    ),
                    IconButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        icon: const Icon(Icons.close))
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Icon(
                          Icons.call,
                          size: 30,
                        ),
                        Text(
                          'Call',
                          style: TextStyle(fontSize: 22),
                        ),
                      ],
                    ),
                    Container(
                      width: 1,
                      height: 80,
                      color: Colors.grey,
                    ),
                    const Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Icon(
                          Icons.call_merge,
                          size: 30,
                        ),
                        Text(
                          'Whatsapp',
                          style: TextStyle(fontSize: 20),
                        ),
                      ],
                    ),
                  ],
                )
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromRGBO(247, 247, 247, 1),
      body: Column(children: [
        AppwideBanner(),
        Container(
          margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
          child: Text(
            // 'Please enter the 4-digit code sent to you at +91-${number.substring(0, 6)}XXXX',/
            'Please enter the 4-digit code sent to you at +91-123456XXXX',
            style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w500),
          ),
        ),
        SizedBox(
          height: 3.h,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
            _otpLength,
            (index) => Container(
              width: 5.h,
              height: 11.w,
              margin: EdgeInsets.symmetric(horizontal: 2.5.w),
              decoration: BoxDecoration(boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  spreadRadius: 1,
                  blurRadius: 5,
                ),
              ], color: Colors.white, borderRadius: BorderRadius.circular(10)),
              child: Center(
                child: TextField(
                  focusNode: _focusNodes[index],
                  controller: _controllers[index],
                  textAlign: TextAlign.center,
                  keyboardType: TextInputType.number,
                  maxLength: 1,
                  onChanged: (value) {
                    _onTextChanged(index);
                  },
                  decoration: InputDecoration(
                    counterText: '',
                    border: InputBorder.none,
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(4),
                      borderSide: const BorderSide(
                        color: Colors.blue,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
        SizedBox(height: 4.h),
        Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('Didn’t get the code?'),
              const SizedBox(
                width: 5,
              ),
              GestureDetector(
                onTap: () {
                  // print('object');
                  _showDialog(context);
                },
                child: const Text(
                  'See other options',
                  style: TextStyle(color: Colors.blue),
                ),
              )
            ],
          ),
        )
      ]),
    );
  }
}
