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
                        QrView(),
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
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Space(10),
        Center(
          child: QrImageView(
            data: 'This is a simple QR code',
            version: QrVersions.auto,
            size: 200,
            gapless: false,
          ),
        ),
        Space(08),
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
                    border: Border.all(color: Colors.black),
                  ),
                  child: Text(
                    "https://app.cloudbelly.in/profile?profileId=${Provider.of<Auth>(context, listen: false).userData?['user_id']}",
                    style: const TextStyle(
                      color: Colors.black,
                      fontSize: 18,
                      fontFamily: 'Product Sans',
                      fontWeight: FontWeight.w800,
                      height: 0,
                      letterSpacing: 0.35,
                    ),
                  ),
                ),
              ),
              const Space(
                08,
                isHorizontal: true,
              ),
              Container(
                //padding: EdgeInsets.all(10),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.black),
                ),
                child: IconButton(
                  onPressed: () async {
                    final String userId =
                        Provider.of<Auth>(context, listen: false)
                                .userData?['user_id'] ??
                            '';
                    final Uri deepLink = Uri.parse(
                        'https://app.cloudbelly.in/profile?profileId=$userId');

                    Share.share(
                        "$deepLink");
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
        const Space(10),
      ],
    );
  }
}
