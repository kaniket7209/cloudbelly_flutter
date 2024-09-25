import 'package:figma_squircle/figma_squircle.dart';
import 'package:flutter/material.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

import '../../../models/user_detail.dart';
import '../../../services/supplier_services.dart';
import '../../../widgets/space.dart';
class IndividualOrderBill extends StatefulWidget {
  const IndividualOrderBill({super.key});

  @override
  State<IndividualOrderBill> createState() => _IndividualOrderBillState();
}

class _IndividualOrderBillState extends State<IndividualOrderBill> {

 late UserOrderDeliveryDetail  _userOrderDetails;
 late bool _isLoading=true;

  @override
  void initState() {
    // TODO: implement initState
    getCartInfoForUser();
    super.initState();
  }

  Future<void> getCartInfoForUser() async{
    _userOrderDetails= await getUserCartInfo('bla bla');
    if(_userOrderDetails!=null){
      setState(() {
        _userOrderDetails=_userOrderDetails;
        _isLoading=false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _isLoading?SizedBox(): Text(_userOrderDetails.cartInfoList[0].itemName),
          Space(2.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Image.network(
                    'https://cdn.pixabay.com/photo/2017/02/23/13/05/avatar-2092113_1280.png',
                    height: 40,
                  ),
                  Space(
                    1.h,
                    isHorizontal: true,
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Hotel Gardenia',
                        style: const TextStyle(
                          color: Color(0xFF094B60),
                          fontSize: 20,
                          fontFamily: 'Jost',
                          fontWeight: FontWeight.w600,
                          // height: 0.06,
                          letterSpacing: 0.54,
                        ),
                      ),
                      Text(
                        'Invoice no- ${'CB21989922L04'}',
                        style: const TextStyle(
                          color: Color(0xFF094B60),
                          fontSize: 12,
                          fontFamily: 'Product Sans',
                          fontWeight: FontWeight.w400,
                          // height: 0.06,
                          letterSpacing: 0.54,
                        ),
                      ),
                    ],
                  )
                ],
              ),
              Text(
                '${'23rd March, 2024'}',
                style: const TextStyle(
                  color: Color(0xFF094B60),
                  fontSize: 12,
                  fontFamily: 'Product Sans',
                  fontWeight: FontWeight.w400,
                  // height: 0.06,
                  letterSpacing: 0.54,
                ),
              ),
            ],
          ),
          Space(1.h),
          Divider(),
          DataTable(
            columns: const [
              DataColumn(
                  label: Text(
                    'Items Ordered',
                    style: const TextStyle(
                      color: Color(0xFF094B60),
                      fontSize: 20,
                      fontFamily: 'Jost',
                      fontWeight: FontWeight.w600,
                      // height: 0.06,
                      letterSpacing: 0.54,
                    ),
                  )),
              DataColumn(
                  label: Text(
                    'Volume',
                    style: const TextStyle(
                      color: Color(0xFF094B60),
                      fontSize: 20,
                      fontFamily: 'Jost',
                      fontWeight: FontWeight.w600,
                      // height: 0.06,
                      letterSpacing: 0.54,
                    ),
                  )),
              DataColumn(
                  label: Text(
                    'Price',
                    style: const TextStyle(
                      color: Color(0xFF094B60),
                      fontSize: 20,
                      fontFamily: 'Jost',
                      fontWeight: FontWeight.w600,
                      // height: 0.06,
                      letterSpacing: 0.54,
                    ),
                  )),
            ],
            rows: [
              DataRow(cells: [
                DataCell(Row(
                  children: [
                    Image.network(
                      'https://cdn.pixabay.com/photo/2017/02/23/13/05/avatar-2092113_1280.png',
                      height: 40,
                    ),
                    Space(
                      1.h,
                      isHorizontal: true,
                    ),
                    Text(
                      'Paneer',
                      style: const TextStyle(
                        color: Color(0xFF094B60),
                        fontSize: 14,
                        fontFamily: 'Product Sans',
                        fontWeight: FontWeight.w600,
                        // height: 0.06,
                        letterSpacing: 0.54,
                      ),
                    )
                  ],
                )),
                DataCell(Text(
                  '120kg',
                  style: const TextStyle(
                    color: Color.fromRGBO(250, 110, 0, 1),
                    fontSize: 12,
                    fontFamily: 'Product Sans',
                    fontWeight: FontWeight.w700,
                    // height: 0.06,
                    letterSpacing: 0.54,
                  ),
                )),
                DataCell(Text('Rs 280',
                    style: const TextStyle(
                      color: Color.fromRGBO(10, 76, 97, 1),
                      fontSize: 12,
                      fontFamily: 'Product Sans',
                      fontWeight: FontWeight.w700,
                      // height: 0.06,
                      letterSpacing: 0.54,
                    )))
              ]),
              DataRow(cells: [
                DataCell(Row(
                  children: [
                    Image.network(
                      'https://cdn.pixabay.com/photo/2017/02/23/13/05/avatar-2092113_1280.png',
                      height: 40,
                    ),
                    Space(
                      1.h,
                      isHorizontal: true,
                    ),
                    Text(
                      'Paneer',
                      style: const TextStyle(
                        color: Color(0xFF094B60),
                        fontSize: 14,
                        fontFamily: 'Product Sans',
                        fontWeight: FontWeight.w600,
                        // height: 0.06,
                        letterSpacing: 0.54,
                      ),
                    )
                  ],
                )),
                DataCell(Text(
                  '120kg',
                  style: const TextStyle(
                    color: Color.fromRGBO(250, 110, 0, 1),
                    fontSize: 12,
                    fontFamily: 'Product Sans',
                    fontWeight: FontWeight.w700,
                    // height: 0.06,
                    letterSpacing: 0.54,
                  ),
                )),
                DataCell(Text('Rs 280',
                    style: const TextStyle(
                      color: Color.fromRGBO(10, 76, 97, 1),
                      fontSize: 12,
                      fontFamily: 'Product Sans',
                      fontWeight: FontWeight.w700,
                      // height: 0.06,
                      letterSpacing: 0.54,
                    )))
              ]),
              DataRow(cells: [
                DataCell(Row(
                  children: [
                    Image.network(
                      'https://cdn.pixabay.com/photo/2017/02/23/13/05/avatar-2092113_1280.png',
                      height: 40,
                    ),
                    Space(
                      1.h,
                      isHorizontal: true,
                    ),
                    Text(
                      'Paneer',
                      style: const TextStyle(
                        color: Color(0xFF094B60),
                        fontSize: 14,
                        fontFamily: 'Product Sans',
                        fontWeight: FontWeight.w600,
                        // height: 0.06,
                        letterSpacing: 0.54,
                      ),
                    )
                  ],
                )),
                DataCell(Text(
                  '120kg',
                  style: const TextStyle(
                    color: Color.fromRGBO(250, 110, 0, 1),
                    fontSize: 12,
                    fontFamily: 'Product Sans',
                    fontWeight: FontWeight.w700,
                    // height: 0.06,
                    letterSpacing: 0.54,
                  ),
                )),
                DataCell(Text('Rs 280',
                    style: const TextStyle(
                      color: Color.fromRGBO(10, 76, 97, 1),
                      fontSize: 12,
                      fontFamily: 'Product Sans',
                      fontWeight: FontWeight.w700,
                      // height: 0.06,
                      letterSpacing: 0.54,
                    )))
              ]),
              DataRow(cells: [
                DataCell(Row(
                  children: [
                    Image.network(
                      'https://cdn.pixabay.com/photo/2017/02/23/13/05/avatar-2092113_1280.png',
                      height: 40,
                    ),
                    Space(
                      1.h,
                      isHorizontal: true,
                    ),
                    Text(
                      'Paneer',
                      style: const TextStyle(
                        color: Color(0xFF094B60),
                        fontSize: 14,
                        fontFamily: 'Product Sans',
                        fontWeight: FontWeight.w600,
                        // height: 0.06,
                        letterSpacing: 0.54,
                      ),
                    )
                  ],
                )),
                DataCell(Text(
                  '120kg',
                  style: const TextStyle(
                    color: Color.fromRGBO(250, 110, 0, 1),
                    fontSize: 12,
                    fontFamily: 'Product Sans',
                    fontWeight: FontWeight.w700,
                    // height: 0.06,
                    letterSpacing: 0.54,
                  ),
                )),
                DataCell(Text('Rs 280',
                    style: const TextStyle(
                      color: Color.fromRGBO(10, 76, 97, 1),
                      fontSize: 12,
                      fontFamily: 'Product Sans',
                      fontWeight: FontWeight.w700,
                      // height: 0.06,
                      letterSpacing: 0.54,
                    )))
              ]),
              DataRow(cells: [
                DataCell(Row(
                  children: [
                    Image.network(
                      'https://cdn.pixabay.com/photo/2017/02/23/13/05/avatar-2092113_1280.png',
                      height: 40,
                    ),
                    Space(
                      1.h,
                      isHorizontal: true,
                    ),
                    Text(
                      'Paneer',
                      style: const TextStyle(
                        color: Color(0xFF094B60),
                        fontSize: 14,
                        fontFamily: 'Product Sans',
                        fontWeight: FontWeight.w600,
                        // height: 0.06,
                        letterSpacing: 0.54,
                      ),
                    )
                  ],
                )),
                DataCell(Text(
                  '120kg',
                  style: const TextStyle(
                    color: Color.fromRGBO(250, 110, 0, 1),
                    fontSize: 12,
                    fontFamily: 'Product Sans',
                    fontWeight: FontWeight.w700,
                    // height: 0.06,
                    letterSpacing: 0.54,
                  ),
                )),
                DataCell(Text('Rs 280',
                    style: const TextStyle(
                      color: Color.fromRGBO(10, 76, 97, 1),
                      fontSize: 12,
                      fontFamily: 'Product Sans',
                      fontWeight: FontWeight.w700,
                      // height: 0.06,
                      letterSpacing: 0.54,
                    )))
              ]),
              DataRow(cells: [
                DataCell(Row(
                  children: [
                    Image.network(
                      'https://cdn.pixabay.com/photo/2017/02/23/13/05/avatar-2092113_1280.png',
                      height: 40,
                    ),
                    Space(
                      1.h,
                      isHorizontal: true,
                    ),
                    Text(
                      'Paneer',
                      style: const TextStyle(
                        color: Color(0xFF094B60),
                        fontSize: 14,
                        fontFamily: 'Product Sans',
                        fontWeight: FontWeight.w600,
                        // height: 0.06,
                        letterSpacing: 0.54,
                      ),
                    )
                  ],
                )),
                DataCell(Text(
                  '120kg',
                  style: const TextStyle(
                    color: Color.fromRGBO(250, 110, 0, 1),
                    fontSize: 12,
                    fontFamily: 'Product Sans',
                    fontWeight: FontWeight.w700,
                    // height: 0.06,
                    letterSpacing: 0.54,
                  ),
                )),
                DataCell(Text('Rs 280',
                    style: const TextStyle(
                      color: Color.fromRGBO(10, 76, 97, 1),
                      fontSize: 12,
                      fontFamily: 'Product Sans',
                      fontWeight: FontWeight.w700,
                      // height: 0.06,
                      letterSpacing: 0.54,
                    )))
              ]),
              DataRow(cells: [
                DataCell(Row(
                  children: [
                    Image.network(
                      'https://cdn.pixabay.com/photo/2017/02/23/13/05/avatar-2092113_1280.png',
                      height: 40,
                    ),
                    Space(
                      1.h,
                      isHorizontal: true,
                    ),
                    Text(
                      'Paneer',
                      style: const TextStyle(
                        color: Color(0xFF094B60),
                        fontSize: 14,
                        fontFamily: 'Product Sans',
                        fontWeight: FontWeight.w600,
                        // height: 0.06,
                        letterSpacing: 0.54,
                      ),
                    )
                  ],
                )),
                DataCell(Text(
                  '120kg',
                  style: const TextStyle(
                    color: Color.fromRGBO(250, 110, 0, 1),
                    fontSize: 12,
                    fontFamily: 'Product Sans',
                    fontWeight: FontWeight.w700,
                    // height: 0.06,
                    letterSpacing: 0.54,
                  ),
                )),
                DataCell(Text('Rs 280',
                    style: const TextStyle(
                      color: Color.fromRGBO(10, 76, 97, 1),
                      fontSize: 12,
                      fontFamily: 'Product Sans',
                      fontWeight: FontWeight.w700,
                      // height: 0.06,
                      letterSpacing: 0.54,
                    )))
              ])
            ],
          ),
          Space(2.h),

          //Total Price container
          Center(
              child: Container(
                height: 45,
                margin: EdgeInsets.symmetric(horizontal: 1.h),
                decoration: ShapeDecoration(
                  shadows: [
                    BoxShadow(
                        offset: Offset(5, 6),
                        spreadRadius: 0.1,
                        color: Color.fromRGBO(165, 200, 199, 0.6),
                        blurRadius: 10)
                  ],
                  color: Colors.white,
                  shape: SmoothRectangleBorder(
                    borderRadius: SmoothBorderRadius(
                      cornerRadius: 10,
                      cornerSmoothing: 1,
                    ),
                  ),
                ),
                child: Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 15),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Total Price',
                            style: TextStyle(
                              color: Color.fromRGBO(10, 76, 97, 1),
                              fontSize: 20,
                              fontFamily: 'Product Sans',
                              fontWeight: FontWeight.w600,
                              height: 0,
                              letterSpacing: 0.30,
                            ),
                          ),
                          Text(
                            'Rs 450',
                            style: TextStyle(
                              color: Color.fromRGBO(10, 76, 97, 1),
                              fontSize: 20,
                              fontFamily: 'Product Sans',
                              fontWeight: FontWeight.w600,
                              height: 0,
                              letterSpacing: 0.30,
                            ),
                          ),
                        ],
                      ),
                    )),
              )),
          Space(1.h),
          Text('Add GST+',
              style: const TextStyle(
                color: Color.fromRGBO(10, 76, 97, 1),
                fontSize: 11,
                fontFamily: 'Product Sans',
                fontWeight: FontWeight.w400,
                // height: 0.06,
                letterSpacing: 0.54,
              )),

          Space(2.h),
          //Payment mode section

          Text('Payment mode',
              style: const TextStyle(
                color: Color.fromRGBO(10, 76, 97, 1),
                fontSize: 14,
                fontFamily: 'Product Sans',
                fontWeight: FontWeight.w700,
                // height: 0.06,
                letterSpacing: 0.54,
              )),
          Space(1.h),
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Container(
              padding: EdgeInsets.symmetric(horizontal: 25,vertical: 5),
              decoration: BoxDecoration(
                  border: Border.all(color: Color.fromRGBO(10, 76, 97, 1)),
                  borderRadius: BorderRadius.all(Radius.circular(8))
              ),
              child: Text('Online',style: const TextStyle(
                color: Color.fromRGBO(10, 76, 97, 1),
                fontSize: 14,
                fontFamily: 'Product Sans',
                fontWeight: FontWeight.w400,
                // height: 0.06,
                letterSpacing: 0.54,
              )),
            ),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 25,vertical: 5),
              decoration: BoxDecoration(
                  border: Border.all(color: Color.fromRGBO(10, 76, 97, 1)),
                  borderRadius: BorderRadius.all(Radius.circular(8))
              ),
              child: Text('Cash',style: const TextStyle(
                color: Color.fromRGBO(10, 76, 97, 1),
                fontSize: 14,
                fontFamily: 'Product Sans',
                fontWeight: FontWeight.w400,
                // height: 0.06,
                letterSpacing: 0.54,
              )),
            ),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 25,vertical: 5),
              decoration: BoxDecoration(
                  border: Border.all(color: Color.fromRGBO(10, 76, 97, 1)),
                  borderRadius: BorderRadius.all(Radius.circular(8))
              ),
              child: Text('Pay Later',style: const TextStyle(
                color: Color.fromRGBO(10, 76, 97, 1),
                fontSize: 14,
                fontFamily: 'Product Sans',
                fontWeight: FontWeight.w400,
                // height: 0.06,
                letterSpacing: 0.54,
              )),
            ),
          ],),
          Space(3.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Container(
                  height: 45,
                  margin: EdgeInsets.symmetric(horizontal: 1.h),
                  decoration: ShapeDecoration(
                    shadows: [
                      BoxShadow(
                          offset: Offset(5, 6),
                          spreadRadius: 0.1,
                          color: Color.fromRGBO(232, 128, 55, 0.5),
                          blurRadius: 10)
                    ],
                    color: const Color.fromRGBO(250, 110, 0, 1),
                    shape: SmoothRectangleBorder(
                      borderRadius: SmoothBorderRadius(
                        cornerRadius: 10,
                        cornerSmoothing: 1,
                      ),
                    ),
                  ),
                  child: Center(
                      child: Text(
                        'Share Bill',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontFamily: 'Product Sans',
                          fontWeight: FontWeight.w700,
                          height: 0,
                          letterSpacing: 0.30,
                        ),
                      )),
                ),
              ),
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      // activeFlag = 3;
                    });
                  },
                  child: Container(
                    height: 45,
                    margin: EdgeInsets.symmetric(horizontal: 1.h),
                    decoration: ShapeDecoration(
                      shadows: [
                        BoxShadow(
                            offset: Offset(5, 6),
                            spreadRadius: 0.1,
                            color: Color.fromRGBO(157, 157, 157, 0.5),
                            blurRadius: 10)
                      ],
                      color: const Color.fromRGBO(64, 64, 64, 1),
                      shape: SmoothRectangleBorder(
                        borderRadius: SmoothBorderRadius(
                          cornerRadius: 10,
                          cornerSmoothing: 1,
                        ),
                      ),
                    ),
                    child: Center(
                        child: Text(
                          'Next Delivery',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontFamily: 'Product Sans',
                            fontWeight: FontWeight.w700,
                            height: 0,
                            letterSpacing: 0.30,
                          ),
                        )),
                  ),
                ),
              )
            ],
          ),
        ],
      ),
    );
  }
}
