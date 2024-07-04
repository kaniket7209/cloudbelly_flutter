import 'package:cloudbelly_app/api_service.dart';
import 'package:cloudbelly_app/screens/Tabs/Dashboard/social_status.dart';
import 'package:cloudbelly_app/screens/Tabs/Dashboard/store_setup_sheets.dart';
import 'package:cloudbelly_app/widgets/appwide_loading_bannner.dart';
import 'package:cloudbelly_app/widgets/space.dart';
import 'package:cloudbelly_app/widgets/toast_notification.dart';
import 'package:cloudbelly_app/widgets/touchableOpacity.dart';
import 'package:figma_squircle/figma_squircle.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

class EditProfileWidget extends StatelessWidget {
  const EditProfileWidget({
    super.key,
    required TextEditingController controller,
  }) : _controller = controller;

  final TextEditingController _controller;

  @override
  Widget build(BuildContext context) {
     String userType =
        Provider.of<Auth>(context, listen: false).userData?['user_type'];
    Color boxShadowColor;
print("userType $userType");
    if (userType == 'Vendor') {
      boxShadowColor = const Color(0xff0A4C61);
    } else if (userType == 'Customer') {
      boxShadowColor = const Color(0xff2E0536);
    } else if (userType == 'Supplier') {
      boxShadowColor = Color.fromARGB(0, 115, 188, 150);
    } else {
      boxShadowColor = const Color.fromRGBO(77, 191, 74, 0.6);
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
               Text(
                'Edit Profile',
                style: TextStyle(
                  color: boxShadowColor,
                  fontSize: 26,
                  fontFamily: 'Jost',
                  fontWeight: FontWeight.w600,
                  height: 0.03,
                  letterSpacing: 0.78,
                ),
              ),
              Space(3.h),
              if (userType == 'Customer')
              TextWidgetStoreSetup(label: 'Edit Name '),

              if (userType != 'Customer')
              TextWidgetStoreSetup(label: 'Edit Store Name',color:boxShadowColor),
              Space(1.h),
              Container(
                // rgba(165, 200, 199, 1),
                decoration:  ShapeDecoration(
                  shadows: [
                    BoxShadow(
                      offset: Offset(0, 2),
                      color: boxShadowColor.withOpacity(0.2),
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
                  child: Row(
                    children: [
                      SizedBox(
                        width: 70.w,
                        child: TextField(
                          onSubmitted: (newvalue) async {
                            AppWideLoadingBanner().loadingBanner(context);
                            final code =
                                await Provider.of<Auth>(context, listen: false)
                                    .updateStoreName(_controller.text);
                            Navigator.of(context).pop();
                            if (code == '200') {
                              TOastNotification().showSuccesToast(
                                  context, 'Store name updated');
                              Provider.of<Auth>(context, listen: false)
                                  .userData?['store_name'] = _controller.text;
                            } else {
                              TOastNotification()
                                  .showErrorToast(context, 'Error!');
                            }
                          },
                          controller: _controller,
                          decoration: InputDecoration(
                            fillColor: Colors.white,
                            contentPadding: EdgeInsets.only(left: 14),
                            hintStyle: TextStyle(
                                fontSize: 12,
                                color: boxShadowColor,
                                fontFamily: 'Product Sans',
                                fontWeight: FontWeight.w400),
                            border: InputBorder.none,
                            // suffixIcon:
                          ),
                          // onChanged: onChanged,
                        ),
                      ),
                      Space(
                        3.w,
                        isHorizontal: true,
                      ),
                      TouchableOpacity(
                        onTap: () async {
                          if (_controller.text != '') {
                            AppWideLoadingBanner().loadingBanner(context);
                            final body =
                                await Provider.of<Auth>(context, listen: false)
                                    .updateStoreName(_controller.text);
                            Navigator.of(context).pop();
                            print(body);
                            if (body['code'] == 200) {
                              TOastNotification().showSuccesToast(
                                  context, 'Store name updated');
                              Provider.of<Auth>(context, listen: false)
                                  .userData?['store_name'] = _controller.text;
                            } else {
                              TOastNotification()
                                  .showErrorToast(context, body['message']);
                            }
                          }
                        },
                        child: Icon(
                          Icons.done,
                          color: Color(0xFFFA6E00),
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        Space(3.h),
        AddCoverImageOrLogoSheetContent(isProfile: true, isLogo: true),
        Space(3.h),
        TouchableOpacity(
          onTap: () async {
            await Provider.of<Auth>(context, listen: false)
                .updateProfilePhoto('');
            Provider.of<Auth>(context, listen: false).logo_url = '';

            TOastNotification().showSuccesToast(context, 'Logo removed');
          },
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: 0.5.h, horizontal: 2.w),
            child: Row(
              children: [
                Icon(
                  Icons.delete,
                  color: Colors.red,
                ),
                Text(
                  userType == 'Customer'?'Remove profile photo':'Remove Logo',
                  style: TextStyle(
                    color: boxShadowColor,
                    fontSize: 17,
                    fontFamily: 'Jost',
                    fontWeight: FontWeight.w600,
                    height: 0.03,
                    letterSpacing: 0.78,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
