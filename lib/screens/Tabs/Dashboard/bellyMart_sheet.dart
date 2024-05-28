import 'package:cloudbelly_app/api_service.dart';
import 'package:cloudbelly_app/constants/globalVaribales.dart';
import 'package:cloudbelly_app/screens/Tabs/Dashboard/dashboard.dart';
import 'package:cloudbelly_app/screens/Tabs/Dashboard/stocks_you_may_need.dart';
import 'package:cloudbelly_app/widgets/appwide_button.dart';
import 'package:cloudbelly_app/widgets/appwide_loading_bannner.dart';
import 'package:cloudbelly_app/widgets/space.dart';
import 'package:cloudbelly_app/widgets/touchableOpacity.dart';
import 'package:figma_squircle/figma_squircle.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

import '../supplier/components/components.dart';

class BellyMartBottomSheet {
  Future<dynamic> BellyMartSheet(BuildContext context,List<dynamic> stocksYouMayNeed) {
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
                        BellyMartView(stocksYouMayNeed: stocksYouMayNeed,),
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

class BellyMartView extends StatefulWidget {
  List<dynamic>? stocksYouMayNeed;
  BellyMartView({super.key,this.stocksYouMayNeed});

  @override
  State<BellyMartView> createState() => _BellyMartViewState();
}

class _BellyMartViewState extends State<BellyMartView> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 45),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Space(29),
          const Text.rich(
            TextSpan(
              children: [
                TextSpan(
                  text: 'Welcome to ',
                  style: TextStyle(
                    color: Color(0xFF0A4C61),
                    fontSize: 20,
                    fontFamily: 'Product Sans',
                    fontWeight: FontWeight.w700,
                    height: 0,
                    letterSpacing: 0.14,
                  ),
                ),
                TextSpan(
                  text: ' \nBellyMart',
                  style: TextStyle(
                    color: Color(0xFF0A4C61),
                    fontSize: 40,
                    fontFamily: 'Product Sans',
                    fontWeight: FontWeight.w700,
                    height: 0,
                    letterSpacing: 0.14,
                  ),
                ),
              ],
            ),
          ),
          const Space(19),
          const Text(
            "Get all your kitchen’s inventory directly from farmers,all fresh and cheaper from the market!",
            textAlign: TextAlign.left,
            style: TextStyle(
              color: Color(0xFF0A4C61),
              fontSize: 12,
              fontFamily: 'Product Sans',
              fontWeight: FontWeight.w700,
              height: 15.53 / 12.0, // Calculate the line height based on font size
              letterSpacing: 0.01,
            ),
          ),
          const Space(37),
          const Text(
            "How does it work?",
            textAlign: TextAlign.left,
            style: TextStyle(
              color: Color(0xFF0A4C61),
              fontSize: 16,
              fontFamily: 'Product Sans',
              fontWeight: FontWeight.w700,
              height: 20.7 / 16.0, // Calculate the line height based on font size
              letterSpacing: 0.01,
              /*height: 0,
              letterSpacing: 0.14,*/
            ),
          ),
          const Space(14),
          const Text(
            "We are creating a community of kitchens and collecting & adding up the orders, so that combined volume can be leveraged for bigger discount from market.",
            textAlign: TextAlign.left,
            style: TextStyle(
              color: Color(0xFF0A4C61),
              fontSize: 12,
              fontFamily: 'Product Sans',
              fontWeight: FontWeight.w700,
              height: 15.53 / 12.0, // Calculate the line height based on font size
              letterSpacing: 0.01,
            ),
          ),
          const Space(48),
          Container(
              height: 24,
              width: 70,
              decoration: ShapeDecoration(
                shadows: const [
                  BoxShadow(
                    offset: Offset(5, 6),
                    color: Color.fromRGBO(77, 131, 147, 0.43),
                    blurRadius: 18,
                  )
                ],
                color: const Color.fromRGBO(84, 166, 193, 1),
                shape: SmoothRectangleBorder(
                  borderRadius: SmoothBorderRadius(
                    cornerRadius: 7,
                    cornerSmoothing: 1,
                  ),
                ),
              ),
              child: const Center(
                child: Text(
                  "Step 1",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontFamily: 'Product Sans',
                    fontWeight: FontWeight.w700,
                    height: 15.53 / 12.0, // Calculate the line height based on font size
                    letterSpacing: 0.01,
                  ),
                ),
              )),
          const Space(18),
          const Text(
            "Just make a list of items you need for next cycle. Mention name & volume",
            style: TextStyle(
              color: Color(0xFF0A4C61),
              fontSize: 14,
              fontFamily: 'Product Sans',
              fontWeight: FontWeight.w400,
              height: 18.12 / 14.0, // Calculate the line height based on font size
              letterSpacing: 0.01,
            ),
          ),
          const Space(29),
          Container(
              height: 24,
              width: 70,
              decoration: ShapeDecoration(
                shadows: const [
                  BoxShadow(
                    offset: Offset(5, 6),
                    color: Color.fromRGBO(77, 131, 147, 0.43),
                    blurRadius: 18,
                  )
                ],
                color: const Color.fromRGBO(84, 166, 193, 1),
                shape: SmoothRectangleBorder(
                  borderRadius: SmoothBorderRadius(
                    cornerRadius: 7,
                    cornerSmoothing: 1,
                  ),
                ),
              ),
              child: const Center(
                child: Text(
                  "Step 1",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontFamily: 'Product Sans',
                    fontWeight: FontWeight.w700,
                    height: 15.53 / 12.0, // Calculate the line height based on font size
                    letterSpacing: 0.01,
                  ),
                ),
              )),
          const Space(18),
          const Text(
            "We will add the volume of zonal kitchens and pass it to the native suppliers for placing bids.",
            style: TextStyle(
              color: Color(0xFF0A4C61),
              fontSize: 14,
              fontFamily: 'Product Sans',
              fontWeight: FontWeight.w400,
              height: 18.12 / 14.0, // Calculate the line height based on font size
              letterSpacing: 0.01,
            ),
          ),
          const Space(32),
          Container(
              height: 24,
              width: 70,
              decoration: ShapeDecoration(
                shadows: const [
                  BoxShadow(
                    offset: Offset(5, 6),
                    color: Color.fromRGBO(77, 131, 147, 0.43),
                    blurRadius: 18,
                  )
                ],
                color: const Color.fromRGBO(84, 166, 193, 1),
                shape: SmoothRectangleBorder(
                  borderRadius: SmoothBorderRadius(
                    cornerRadius: 7,
                    cornerSmoothing: 1,
                  ),
                ),
              ),
              child: const Center(
                child: Text(
                  "Step 1",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontFamily: 'Product Sans',
                    fontWeight: FontWeight.w700,
                    height: 15.53 / 12.0, // Calculate the line height based on font size
                    letterSpacing: 0.01,
                  ),
                ),
              )),
          const Space(18),
          const Text(
            "Sit back & relax, you will be notified with your order status and lowest price.",
            style: TextStyle(
              color: Color(0xFF0A4C61),
              fontSize: 14,
              fontFamily: 'Product Sans',
              fontWeight: FontWeight.w400,
              height: 18.12 / 14.0, // Calculate the line height based on font size
              letterSpacing: 0.01,
            ),
          ),
          const Space(35),
          AppWideButton(
            onTap: () {
              StocksYouMayNeedBottomSheet().StocksYouMayNeedSheet(context,widget.stocksYouMayNeed ?? []);
            },
            num: 2,
            txt: 'Ready to buy at the lowest price?',
            ispop: true,
          ),
          const Space(20),
        ],
      ),
    );
  }
}
