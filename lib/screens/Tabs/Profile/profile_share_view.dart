import 'package:cloudbelly_app/api_service.dart';
import 'package:cloudbelly_app/widgets/space.dart';
import 'package:cloudbelly_app/widgets/touchableOpacity.dart';
import 'package:figma_squircle/figma_squircle.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:share_plus/share_plus.dart';
import 'package:uni_links/uni_links.dart';
import 'package:url_launcher/url_launcher.dart';

//  for QR code sharing (profile)
class ProfileShareBottomSheet {
  Future<dynamic> AddAddressSheet(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return PopScope(
          canPop: true,
          onPopInvoked: (_) {
            context.read<TransitionEffect>().setBlurSigma(0);
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
                        const QrView(),
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

class QrView extends StatefulWidget {
  const QrView({super.key});

  @override
  State<QrView> createState() => _QrViewState();
}

class _QrViewState extends State<QrView> {
  @override
  Widget build(BuildContext context) {
    final String userId =
        Provider.of<Auth>(context, listen: false).userData?['user_id'] ?? '';
    print(
        "prof ${Provider.of<Auth>(context, listen: false).userData?['profile_photo']}");
    final String profileUrl =
        "https://app.cloudbelly.in/profile?profileId=$userId";
    final String profilePhoto =
        Provider.of<Auth>(context, listen: false).userData?['profile_photo'] ??
            '';

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox(height: 10),
        Center(
          child: Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(40),
              // border: Border.all(color: Colors.black),
              image: DecorationImage(
                image: NetworkImage(profilePhoto),
                fit: BoxFit.cover,
              ),
            ),
          ),
        ),
        SizedBox(height: 10),
        Center(
          child: Text(
            Provider.of<Auth>(context, listen: false).userData?['store_name'] ??
                '',
            style: const TextStyle(
              color: Colors.black,
              fontSize: 18,
              fontFamily: 'Product Sans',
              fontWeight: FontWeight.w800,
              height: 1.2,
              letterSpacing: 0.35,
            ),
          ),
        ),
        SizedBox(height: 10),
        // Center(
        //   child: Text(
        //     Provider.of<Auth>(context, listen: false).userData?['phone'] ?? '',
        //     style: const TextStyle(
        //       color: Colors.black,
        //       fontSize: 18,
        //       fontFamily: 'Product Sans',
        //       fontWeight: FontWeight.w800,
        //       height: 1.2,
        //       letterSpacing: 0.35,
        //     ),
        //   ),
        // ),
        GestureDetector(
          onTap: () async {
            final phoneNumber =
                Provider.of<Auth>(context, listen: false).userData?['phone'] ??
                    '';
            final url = 'tel:$phoneNumber';
            if (await canLaunch(url)) {
              await launch(url);
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Could not launch phone call')),
              );
            }
          },
          child: CircleAvatar(
            radius: 10,
            backgroundColor: const Color(0xFFFA6E00),
            child: Image.asset(
              'assets/images/Phone.png',
              width: 30,
              height: 30,
              fit: BoxFit.fill,
            ),
          ),
        ),
        SizedBox(height: 10),
        Center(
          child: QrImageView(
            data: profileUrl,
            version: QrVersions.auto,
            size: 200,
            gapless: false,
            foregroundColor: const Color.fromARGB(255, 56, 12, 64),
          ),
        ),
        SizedBox(height: 8),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(
                child: Container(
                  padding: EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    // color: const Color.fromARGB(255, 244, 114, 54),
                    border: Border.all(color: Colors.black),
                  ),
                  child: Text(
                    profileUrl,
                    style: const TextStyle(
                      color: Colors.black,
                      fontSize: 18,
                      fontFamily: 'Product Sans',
                      fontWeight: FontWeight.w800,
                      height: 1.2,
                      letterSpacing: 0.35,
                    ),
                  ),
                ),
              ),
              SizedBox(width: 8),
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.black),
                ),
                child: IconButton(
                  onPressed: () async {
                    Share.share(profileUrl);
                  },
                  icon: const Icon(
                    Icons.share,
                    color: Colors.black,
                  ),
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 10),
      ],
    );
  }
}
