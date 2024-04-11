import 'package:cloudbelly_app/api_service.dart';
import 'package:cloudbelly_app/constants/globalVaribales.dart';
import 'package:cloudbelly_app/models/model.dart';
import 'package:cloudbelly_app/screens/Login/map.dart';
import 'package:cloudbelly_app/screens/Tabs/Cart/provider/view_cart_provider.dart';
import 'package:cloudbelly_app/screens/Tabs/Cart/view_cart.dart';
import 'package:cloudbelly_app/widgets/touchableOpacity.dart';
import 'package:figma_squircle/figma_squircle.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

import '../../../widgets/space.dart';
import 'google_map_screen.dart';

class AddressBottomSheet {
  Future<dynamic> DelievryAddressSheet(
      BuildContext context, List<AddressModel>? deliveryAddressList) {
    return showModalBottomSheet(
      // useSafeArea: true,

      context: context,
      isScrollControlled: true,

      builder: (BuildContext context) {
        bool _isVendor =
            Provider.of<Auth>(context, listen: false).userType == 'Vendor';
        // print(data);
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return SingleChildScrollView(
              child: Container(
                decoration: const ShapeDecoration(
                  color: Colors.white,
                  shape: SmoothRectangleBorder(
                    borderRadius: SmoothBorderRadius.only(
                        topLeft:
                            SmoothRadius(cornerRadius: 35, cornerSmoothing: 1),
                        topRight:
                            SmoothRadius(cornerRadius: 35, cornerSmoothing: 1)),
                  ),
                ),
                //height: MediaQuery.of(context).size.height * 0.4,
                width: double.infinity,
                padding: EdgeInsets.only(
                    top: 2.h, bottom: MediaQuery.of(context).viewInsets.bottom),
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
                      AddressList(
                        deliveryAddressList: deliveryAddressList ?? [],
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}

class AddressList extends StatefulWidget {
  AddressList({super.key, required this.deliveryAddressList});

  List<AddressModel> deliveryAddressList;

  @override
  State<AddressList> createState() => _AddressListState();
}

class _AddressListState extends State<AddressList> {
  int? _currentIndex;



  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Space(3.h),
          if (widget.deliveryAddressList.isNotEmpty) ...[
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 44),
              child: Text(
                "Choose a delivery address",
                style: TextStyle(
                  color: Color(0xFF9428A9),
                  fontSize: 22,
                  fontFamily: 'Jost',
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            const Space(25),

            ListView.separated(
                shrinkWrap: true,
                itemCount: widget.deliveryAddressList.length,
                separatorBuilder: (context, _) {
                  return const Space(30);
                },
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 44.0),
                    child: InkWell(
                      onTap: () {
                        setState(() {
                          _currentIndex = index;
                         // addressModel = widget.deliveryAddressList[index];
                          Provider.of<ViewCartProvider>(context, listen: false).getAddress(widget.deliveryAddressList[index]);
                          Navigator.pop(context);
                        //  Navigator.push(context, MaterialPageRoute(builder: (context) => ViewCart()));
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
                                boxColor: _currentIndex == index
                                    ? const Color(0xFFFA6E00)
                                    : const Color(0xFFD272E5),
                                cornerRadius: 8),
                          ),
                          const Space(
                            15,
                            isHorizontal: true,
                          ),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  widget.deliveryAddressList[index].type ?? "",
                                  style: const TextStyle(
                                    color: Color(0xFF2E0536),
                                    fontSize: 16,
                                    fontFamily: 'Jost',
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const Space(4),
                                Text(
                                  widget.deliveryAddressList[index].location ??
                                      "",
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    color: Color(0xFF494949),
                                    fontSize: 14,
                                    fontFamily: 'Jost',
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                              ],
                            ),
                          )
                        ],
                      ),
                    ),
                  );
                }),

            //  Space(35),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 44.0),
              child: Divider(
                color: Color(0xFF2E0536),
                thickness: 0.5,
                height: 70,
              ),
            ),
          ],
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 44.0),
            child: Row(
              children: [
                Container(
                  height: 40,
                  width: 40,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: const Color(0xFF2E0536),
                      width: 1,
                    ),
                    /* boxShadow: const [
                      BoxShadow(
                        offset: Offset(3, 6),
                        blurRadius: 20,
                        color: Color.fromRGBO(158, 116, 158, 0.5),
                      )
                    ],*/
                  ),
                  /*decoration: GlobalVariables().ContainerDecoration(
                      offset: const Offset(3, 6),
                      blurRadius: 20,
                      shadowColor: const Color.fromRGBO(158, 116, 158, 0.5),
                      boxColor:  Colors.white,
                      cornerRadius: 8),*/
                  child: Center(
                    child: IconButton(
                      icon: const Icon(Icons.add),
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => const GoogleMapScreen(),
                          ),
                        );
                      },
                      color: const Color(0xFF2E0536),
                    ),
                  ),
                ),
                const Space(
                  14,
                  isHorizontal: true,
                ),
                GestureDetector(
                  onTap: () {
                    Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) => const GoogleMapScreen()));
                  },
                  child: const Text(
                    "Add new Address",
                    style: TextStyle(
                      color: Color(0xFF9428A9),
                      fontSize: 18,
                      fontFamily: 'Jost',
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const Space(30),
        ],
      ),
    );
  }
}
