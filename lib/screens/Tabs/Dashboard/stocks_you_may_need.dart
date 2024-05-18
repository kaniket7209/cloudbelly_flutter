import 'package:cloudbelly_app/api_service.dart';
import 'package:cloudbelly_app/constants/globalVaribales.dart';
import 'package:cloudbelly_app/screens/Tabs/Dashboard/dashboard.dart';
import 'package:cloudbelly_app/screens/Tabs/supplier/components/components.dart';
import 'package:cloudbelly_app/widgets/appwide_button.dart';
import 'package:cloudbelly_app/widgets/appwide_loading_bannner.dart';
import 'package:cloudbelly_app/widgets/space.dart';
import 'package:cloudbelly_app/widgets/touchableOpacity.dart';
import 'package:figma_squircle/figma_squircle.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

class StocksYouMayNeedBottomSheet {
  Future<dynamic> StocksYouMayNeedSheet(BuildContext context) {
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
                        const ItemsView(),
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

class ItemsView extends StatefulWidget {
  const ItemsView({super.key});

  @override
  State<ItemsView> createState() => _ItemsViewState();
}

class _ItemsViewState extends State<ItemsView> {
  @override
  Widget build(BuildContext context) {
    return Container(
      /* decoration: const ShapeDecoration(
              color: Colors.white,
              shape: SmoothRectangleBorder(
                borderRadius: SmoothBorderRadius.only(
                    topLeft:
                    SmoothRadius(cornerRadius: 35, cornerSmoothing: 1),
                    topRight:
                    SmoothRadius(cornerRadius: 35, cornerSmoothing: 1)),
              ),
            ),
            height: MediaQuery.of(context).size.height * 0.6,
            width: double.infinity,*/
      height: MediaQuery.of(context).size.height * 0.90,
      padding: EdgeInsets.only(
          left: 6.w,
          right: 6.w,
          top: 2.h,
          bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Column(
        // mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Space(2.h),
          const BoldTextWidgetHomeScreen(
            txt: 'Stocks you may need',
          ),
          ListView.builder(
            physics: const AlwaysScrollableScrollPhysics(),
            shrinkWrap: true,
            itemBuilder: (context, index) {
              return Column(
                children: [
                  
                  Container(
                    margin: const EdgeInsets.symmetric(
                      vertical: 15,
                    ),
                    child: Row(children: [
                      ImageWidgetInventory(
                          height: 40,
                          radius: 12,
                          url: /*stocksYouMayNeed[index]['image_url'] ??*/
                          'https://drive.google.com/file/d/12-9XoJVr5w0DzuHXkeWdJOq_ZO_JHWMt/view?usp=drive_link'),
                      const Space(
                        14,
                        isHorizontal: true,
                      ),
                      const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Milk",
                            //" stocksYouMayNeed[index]['itemName']",
                            style: TextStyle(
                              color: Color(0xFF0A4C61),
                              fontSize: 14,
                              fontFamily: 'Product Sans',
                              fontWeight: FontWeight.w400,
                              height: 20 / 14.0,
                              // Calculate the line height based on font size
                              letterSpacing: 0.03,
                            ),
                          ),
                          Space(2),
                          Text(
                            "5kg for next 3 days"
                            /*stocksYouMayNeed[index]['runway'] < 0
                                                  ? '${stocksYouMayNeed[index]['volumeLeft']} ${stocksYouMayNeed[index]['unitType']} left and ${"expired 8 days before"}'
                                                  : '${stocksYouMayNeed[index]['volumeLeft']} ${stocksYouMayNeed[index]['unitType']} for next ${stocksYouMayNeed[index]['runway']} days',*/
                            ,
                            style: TextStyle(
                              color: Color(0xFFFA6E00),
                              fontSize: 8,
                              fontFamily: 'Product Sans',
                              fontWeight: FontWeight.w700,
                            ),
                          )
                        ],
                      ),
                      const Spacer(),
                      TouchableOpacity(
                        onTap: () {
                          AppWideLoadingBanner().featurePending(context);
                        },
                        child: Container(
                          width: 71,
                          height: 30,
                          decoration: GlobalVariables().ContainerDecoration(
                              offset: const Offset(0, 8),
                              blurRadius: 20,
                              shadowColor:
                              const Color.fromRGBO(152, 202, 201, 0.8),
                              boxColor:
                              const Color.fromRGBO(84, 166, 193, 1),
                              cornerRadius: 10),
                          child: const Center(
                            child: Text(
                              'Add',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                                fontFamily: 'Product Sans',
                                fontWeight: FontWeight.w700,
                                height: 18.12 / 14.0,
                                // Calculate the line height based on font size
                                letterSpacing: 0.01,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const Space(
                        15.79,
                        isHorizontal: true,
                      ),
                      const Text(
                        "x",
                        style: TextStyle(
                          color: Color(0xFFFA6E00),
                          fontSize: 16,
                          fontFamily: 'Product Sans',
                          fontWeight: FontWeight.w400,
                          height: 20 / 16.0,
                          // Calculate the line height based on font size
                          letterSpacing: 0.03,
                        ),
                      )
                    ]),
                  ),
                ],
              );
            },
            /* separatorBuilder: (context, _) {
                  return Space(30);
                },*/
            itemCount: 1,
          ),

        ],
      ),
    );
  }
}


/*     TouchableOpacity(
                onTap: () {},
                child: Container(
                    height: 37,
                    width: 125,
                    decoration: ShapeDecoration(
                      shadows: const [
                        BoxShadow(
                          offset: Offset(5, 6),
                          color: Color.fromRGBO(72, 138, 136, 0.5),
                          blurRadius: 20,
                        )
                      ],
                      color: const Color.fromRGBO(10, 76, 97, 1),
                      shape: SmoothRectangleBorder(
                        borderRadius: SmoothBorderRadius(
                          cornerRadius: 10,
                          cornerSmoothing: 1,
                        ),
                      ),
                    ),
                    child: Center(
                      child: Text(
                        "Add item",
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontFamily: 'Product Sans',
                          fontWeight: FontWeight.w700,
                          height: 0,
                          letterSpacing: 0.14,
                        ),
                      ),
                    )),
              ),
          const Space(26),
          AppWideButton(
            onTap: () {
            },
            num: 2,
            txt: 'Submit',
            ispop: true,
          ),*/