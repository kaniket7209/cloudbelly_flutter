import 'dart:async';
import 'dart:ui';

import 'package:cloudbelly_app/models/user_detail.dart';
import 'package:figma_squircle/figma_squircle.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

import '../../../api_service.dart';
import '../../../models/supplier_bulk_order.dart';
import '../../../services/supplier_services.dart';
import '../../../widgets/custom_icon_button.dart';
import '../../../widgets/space.dart';
import '../../../widgets/toast_notification.dart';
import '../../../widgets/touchableOpacity.dart';
import 'components/components.dart';
import 'dart:ui' as ui;

class BulkOrderSheet extends StatefulWidget {
  final List<SupplierBulkOrder> bulkOrders;
  final bool bidWon;

  const BulkOrderSheet(
      {super.key, required this.bulkOrders, required this.bidWon});

  @override
  State<BulkOrderSheet> createState() => _BulkOrderSheetState();
}

class _BulkOrderSheetState extends State<BulkOrderSheet> {
  List<UserDetail> users = [];

  late bool _bidWon = false;

  late bool _placeBid = false;
  late List<SupplierBulkOrder> _bulkOrders = [];

  late Map<String, dynamic> userAddressDetails = {
    'businessName': '',
    'addressDetails': ''
  };

  late int activeFlag = 0;
  CameraPosition? cameraPosition;
  Position? _currentPosition;
  List<Placemark> placeMarks = [];
  late List<int> checkedBoxes = [1, 2, 3];
  String? area;
  String? address;
  late List<Marker> _markers = [];
  GoogleMapController? _mapController;
  late List<String> userIDs = [];
  TOastNotification toastNotification = TOastNotification();

  // late bool _isLoading = true;
  late Map<int, Map<String, dynamic>> _orderPreparation = {
    1: {'key': 1, 'value': "Start packing before 12pm", 'checked': false},
    2: {'key': 2, 'value': "Check the Quality", 'checked': false},
    3: {'key': 3, 'value': "Ready For Delivery", 'checked': false},
  };

  @override
  void initState() {
    super.initState();
    // Create a deep copy of the list and its items
    _bulkOrders = widget.bulkOrders.map((order) => order.clone()).toList();
    _checkLocationPermission();
    getUsersDetails();
  }

  Future<void> submitSupplierBid() async {
    bool foundValidPrice = false;

    for (int i = 0; i < _bulkOrders.length; i++) {
      if (_bulkOrders[i].price > 0) {
        print('Yes my price is greater than 0 ' +
            _bulkOrders[i].price.toString());

        Map<String, dynamic> bidData = {
          "supplier_id":
              Provider.of<Auth>(context, listen: false).userData!['user_id'],
          "bids": SupplierBulkOrder.toJsonList(_bulkOrders)
        };
        int statusCode = await placeSupplierBid(bidData);

        if (statusCode == 200) {
          setState(() {
            activeFlag = 2;
            startTimer();
          });
        }
        foundValidPrice = true;
        break;
      }
    }

    if (!foundValidPrice) {
      setState(() {
        _placeBid = false;
      });

      // Show error toast if no valid price was found
      toastNotification.showErrorToast(
          context, "No valid price found for any bulk order.");
    }
  }

  Future<BitmapDescriptor> getCustomMarker(String imageUrl) async {
    final ui.PictureRecorder pictureRecorder = ui.PictureRecorder();
    final Canvas canvas = Canvas(pictureRecorder);
    final double radius = 50; // Radius of the circle for the marker

    // Paint for the circle
    final Paint circlePaint = Paint()..color = Colors.white;

    // Paint for the image
    final Paint imagePaint = Paint();

    // Load the image from network
    final ui.Image image = await loadImageFromNetwork(imageUrl);

    // Create a circle path to clip the image
    final Path clipPath = Path()
      ..addOval(
          Rect.fromCircle(center: Offset(radius, radius), radius: radius));

    canvas.clipPath(clipPath);

    // Draw the circle
    canvas.drawCircle(Offset(radius, radius), radius, circlePaint);

    // Calculate the image position to center it inside the circle
    double imgWidth = image.width.toDouble();
    double imgHeight = image.height.toDouble();
    double aspectRatio = imgWidth / imgHeight;

    double targetWidth, targetHeight;
    if (aspectRatio > 1.0) {
      targetHeight = radius * 2;
      targetWidth = targetHeight * aspectRatio;
    } else {
      targetWidth = radius * 2;
      targetHeight = targetWidth / aspectRatio;
    }

    // Draw the image centered in the circle
    canvas.drawImageRect(
      image,
      Rect.fromLTRB(0, 0, imgWidth, imgHeight),
      Rect.fromLTWH(radius - targetWidth / 2, radius - targetHeight / 2,
          targetWidth, targetHeight),
      imagePaint,
    );

    // Convert canvas to image
    final ui.Image img =
        await pictureRecorder.endRecording().toImage(50 * 2, 50 * 2);
    final ByteData? data = await img.toByteData(format: ui.ImageByteFormat.png);

    // Convert image to BitmapDescriptor
    return BitmapDescriptor.fromBytes(data!.buffer.asUint8List());
  }

  Future<ui.Image> loadImageFromNetwork(String imageUrl) async {
    // Fetch the image via HTTP
    final http.Response responseData = await http.get(Uri.parse(imageUrl));
    // Obtain the image data
    final Uint8List bytes = responseData.bodyBytes;

    // Decode the image to the required format
    final ui.Codec codec = await ui.instantiateImageCodec(bytes);
    final ui.FrameInfo frameInfo = await codec.getNextFrame();

    // Return the image
    return frameInfo.image;
  }

  Future<Set<Marker>> setMapMarkers() async {
    Set<Marker> localMarkers = {};

    for (int i = 0; i < users.length; i++) {
      final response = await http.get(Uri.parse(users[i].image));
      if (response.statusCode == 200) {
        final bytes = response.bodyBytes;
        final compressedBytes = await FlutterImageCompress.compressWithList(
          bytes,
          minHeight: 100,
          minWidth: 100,
          quality: 70,
        );

        Marker marker = Marker(
          onTap: () {
            print('Im tapped');
            userAddressDetails['businessName'] = users[i].hNo;
            userAddressDetails['addressDetails'] = users[i].detailedAddress;
            setState(() {});
          },
          icon: await getCustomMarker(users[i].image),
          anchor: Offset(0.5, 0.5),
          markerId: MarkerId(users[i].userID),
          position:
              LatLng(double.parse(users[i].lat), double.parse(users[i].long)),
          infoWindow: InfoWindow(title: users[i].userName),
        );

        localMarkers.add(marker);
      }
    }

    return localMarkers;
  }

  bool _isEnabled(int key) {
    if (key == 1) {
      return true;
    }
    return _orderPreparation[key - 1]!['checked'];
  }

  Widget orderPreparationCheckbox(String title, String count) {
    return Center(
        child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Text('${count}/3',
                style: TextStyle(
                  color: Color.fromRGBO(232, 128, 55, 1),
                  fontSize: 14,
                  fontFamily: 'Product Sans',
                  fontWeight: FontWeight.w700,
                  // height: 0.14,
                  letterSpacing: 0.36,
                )),
            Space(
              2.h,
              isHorizontal: true,
            ),
            Text(
              title,
              style: TextStyle(
                color: Color(0xFF094B60),
                fontSize: 14,
                fontFamily: 'Product Sans',
                fontWeight: FontWeight.w400,
                // height: 0.14,
                letterSpacing: 0.36,
              ),
            ),
          ],
        ),
        Transform.scale(
          scale: 1.5, // Adjust the scale to change the size
          child: Checkbox(
            fillColor: MaterialStateProperty.resolveWith((states) {
              if (states.contains(MaterialState.selected)) {
                return Color.fromRGBO(250, 110, 0, 1); // Active color
              }
              return Colors.grey.withOpacity(0.3); // Inactive color
            }),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
            side: BorderSide.none,
            value: _orderPreparation[int.parse(count)]!['checked'],
            onChanged: _isEnabled(int.parse(count))
                ? (bool? val) {
                    _orderPreparation[int.parse(count)]!['checked'] = val;
                    setState(() {});
                  }
                : null,
          ),
        )
      ],
    ));
  }

  Future<void> getUsersDetails() async {
    for (int i = 0; i < _bulkOrders.length; i++) {
      userIDs += _bulkOrders[i].userIDs;
    }
    users = await getUsersDetailsByUserIDs(userIDs);

    if (users != null) {
      userAddressDetails['businessName'] = users[0].hNo;
      userAddressDetails['addressDetails'] = users[0].detailedAddress;
    }
  }

  Future<void> _checkLocationPermission() async {
    PermissionStatus permission = await Permission.locationWhenInUse.status;
    if (permission != PermissionStatus.granted) {
      await Permission.locationWhenInUse.request();
    }
  }

  final ScrollController _controller = ScrollController();

  Widget _buildBody() {
    switch (activeFlag) {
      case 0:
        return widget.bidWon
            ? _bidWonCheckListSection()
            : _bulkOrderItemSheet();
      case 1:
        return _deliveryRoute();
      case 2:
        return _bidSuccessful();
      default:
        return _bulkOrderItemSheet(); // Default case if the flag is out of expected range
    }
  }

  Widget _bidWonCheckListSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Space(1.h),
          GestureDetector(
            onTap: () {
              print('Im tapped');
              setState(() {
                activeFlag = 1;
              });
            },
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              mainAxisSize: MainAxisSize.max,
              // crossAxisAlignment: CrossAxisAlignment,// Set mainAxisSize to min
              children: [
                const Text(
                  'Delivery route',
                  style: TextStyle(
                    color: Color(0xFF094B60),
                    fontSize: 12,
                    fontFamily: 'Product Sans',
                    fontWeight: FontWeight.w700,
                    // height: 0.14,
                    letterSpacing: 0.36,
                  ),
                ),
                Space(isHorizontal: true, 2.w),
                Icon(
                  Icons.double_arrow_outlined,
                  size: 16,
                  color: Color(0xFFFA6E00),
                ),
              ],
            ),
          ),
          Space(1.h),
          Text(
            'Congratulations! You have won the bid #cb-01-24-07-sil',
            style: const TextStyle(
              color: Color(0xFF094B60),
              fontSize: 25,
              fontFamily: 'Jost',
              fontWeight: FontWeight.w500,
              // height: 0.06,
              letterSpacing: 0.54,
            ),
          ),
          Space(1.h),
          Text(
            'Let\'s get prepared',
            style: const TextStyle(
              color: Color(0xFF094B60),
              fontSize: 14,
              fontFamily: 'Jost',
              fontWeight: FontWeight.w500,
              // height: 0.06,
              letterSpacing: 0.54,
            ),
          ),
          orderPreparationCheckbox('Start packing before 12am', '1'),
          Space(1.h),
          orderPreparationCheckbox('Check the quality', '2'),
          Space(1.h),
          orderPreparationCheckbox('Out for delivery', '3'),
          Space(2.h),
          Container(
            height: 45,
            margin: EdgeInsets.symmetric(horizontal: 1.h),
            decoration: ShapeDecoration(
              shadows: [
                BoxShadow(
                    offset: Offset(5, 6),
                    spreadRadius: 0.1,
                    color: _orderPreparation.values
                            .every((item) => item['checked'] == true)
                        ? Color.fromRGBO(232, 128, 55, 0.5)
                        : Colors.black12,
                    blurRadius: 10)
              ],
              color: _orderPreparation.values
                      .every((item) => item['checked'] == true)
                  ? Color.fromRGBO(250, 110, 0, 1)
                  : Colors.grey,
              shape: SmoothRectangleBorder(
                borderRadius: SmoothBorderRadius(
                  cornerRadius: 10,
                  cornerSmoothing: 1,
                ),
              ),
            ),
            child: Center(
                child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Proceed to deliver',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontFamily: 'Product Sans',
                    fontWeight: FontWeight.w700,
                    height: 0,
                    letterSpacing: 0.30,
                  ),
                ),
              ],
            )),
          ),
          Space(2.h)

          // Center(
          //     child: GestureDetector(
          //   onTap: () {
          //     setState(() {
          //       _placeBid = true;
          //       submitSupplierBid();
          //     });
          //   },
          //   child: Container(
          //     height: 45,
          //     margin: EdgeInsets.symmetric(horizontal: 1.h),
          //     decoration: ShapeDecoration(
          //       shadows: [
          //         BoxShadow(
          //             offset: Offset(5, 6),
          //             spreadRadius: 0.1,
          //             color: Color.fromRGBO(232, 128, 55, 0.5),
          //             blurRadius: 10)
          //       ],
          //       color: const Color.fromRGBO(250, 110, 0, 1),
          //       shape: SmoothRectangleBorder(
          //         borderRadius: SmoothBorderRadius(
          //           cornerRadius: 10,
          //           cornerSmoothing: 1,
          //         ),
          //       ),
          //     ),
          //     child: Center(
          //         child: Row(
          //       mainAxisAlignment: MainAxisAlignment.center,
          //       children: [
          //         Text(
          //           'Submit your bid',
          //           style: TextStyle(
          //             color: Colors.white,
          //             fontSize: 16,
          //             fontFamily: 'Product Sans',
          //             fontWeight: FontWeight.w700,
          //             height: 0,
          //             letterSpacing: 0.30,
          //           ),
          //         ),
          //         _placeBid
          //             ? Space(
          //                 2.h,
          //                 isHorizontal: true,
          //               )
          //             : SizedBox(),
          //         _placeBid
          //             ? SizedBox(
          //                 height: 20,
          //                 width: 20,
          //                 child: CircularProgressIndicator(
          //                   color: Colors.grey,
          //                 ))
          //             : SizedBox()
          //       ],
          //     )),
          //   ),
          // )),,
        ],
      ),
    );
    ;
  }

  Duration duration = Duration(hours: 3, minutes: 45, seconds: 4);
  Timer? timer;

  void startTimer() {
    timer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (duration.inSeconds == 0) {
        timer.cancel();
      } else {
        setState(() {
          duration -= Duration(seconds: 1);
        });
      }
    });
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  Widget googleMap(snapshot) {
    return GoogleMap(
      myLocationButtonEnabled: true,
      zoomControlsEnabled: true,
      myLocationEnabled: true,
      scrollGesturesEnabled: true,
      markers: snapshot.data ?? {},
      onMapCreated: (GoogleMapController controller) {
        _mapController = controller;
      },
      initialCameraPosition: CameraPosition(
        target: LatLng(
          double.parse(users.isNotEmpty ? users[0].lat : '0'),
          double.parse(users.isNotEmpty ? users[0].long : '0'),
        ),
        zoom: 12,
        bearing: 10,
        tilt: 30,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      // margin: EdgeInsets.symmetric(horizontal: 2.h),
      padding: EdgeInsets.only(
        top: 2.h,
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      decoration: const ShapeDecoration(
        color: Colors.white,
        shape: SmoothRectangleBorder(
          borderRadius: SmoothBorderRadius.only(
            topLeft: SmoothRadius(
              cornerRadius: 35,
              cornerSmoothing: 1,
            ),
            topRight: SmoothRadius(
              cornerRadius: 35,
              cornerSmoothing: 1,
            ),
          ),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TouchableOpacity(
              onTap: () {
                context.read<TransitionEffect>().setBlurSigma(0);
                return Navigator.of(context).pop();
              },
              child: Center(
                child: Container(
                  padding: EdgeInsets.symmetric(
                    vertical: 1.h,
                    horizontal: 3.w,
                  ),
                  width: 65,
                  height: 6,
                  decoration: ShapeDecoration(
                    color: const Color(0xFFFA6E00),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                ),
              ),
            ),
            _buildBody()
          ],
        ),
      ),
    );
  }

  Widget _bulkOrderItemSheet() {
    return Column(
      children: [
        Space(1.h),
        GestureDetector(
          onTap: () {
            print('Im tapped');
            setState(() {
              activeFlag = 1;
            });
          },
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            mainAxisSize: MainAxisSize.max,
            // crossAxisAlignment: CrossAxisAlignment,// Set mainAxisSize to min
            children: [
              const Text(
                'Delivery route',
                style: TextStyle(
                  color: Color(0xFF094B60),
                  fontSize: 12,
                  fontFamily: 'Product Sans',
                  fontWeight: FontWeight.w700,
                  // height: 0.14,
                  letterSpacing: 0.36,
                ),
              ),
              Space(isHorizontal: true, 2.w),
              Icon(
                Icons.double_arrow_outlined,
                size: 16,
                color: Color(0xFFFA6E00),
              ),
            ],
          ),
        ),
        Space(1.h),
        Row(
          children: [
            Space(
              1.h,
              isHorizontal: true,
            ),
            Text(
              'New Bulk Order',
              style: const TextStyle(
                color: Color(0xFF094B60),
                fontSize: 25,
                fontFamily: 'Jost',
                fontWeight: FontWeight.w500,
                // height: 0.06,
                letterSpacing: 0.54,
              ),
            ),
          ],
        ),
        Container(
          height: 30.h,
          child: Scrollbar(
            interactive: true,
            thumbVisibility: true,
            // Set to true to always show scrollbar
            controller: _controller,
            // Pass the controller
            child: ListView.builder(
              controller: _controller,
              // Pass the controller to the ListView as well
              itemCount: _bulkOrders.length,
              itemBuilder: (context, index) {
                return Column(
                  children: [
                    index == 0 ? Space(2.h) : SizedBox(),
                    BulkOrderSectionItem(
                      itemDetails: _bulkOrders[index],
                    ),
                    index == 0 ? Space(2.h) : SizedBox(),
                    index > 0 ? Space(2.h) : SizedBox(),
                  ],
                );
              },
            ),
          ),
        ),
        Space(2.h),
        Center(
            child: GestureDetector(
          onTap: () {
            setState(() {
              _placeBid = true;
              submitSupplierBid();
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
                child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Submit your bid',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontFamily: 'Product Sans',
                    fontWeight: FontWeight.w700,
                    height: 0,
                    letterSpacing: 0.30,
                  ),
                ),
                _placeBid
                    ? Space(
                        2.h,
                        isHorizontal: true,
                      )
                    : SizedBox(),
                _placeBid
                    ? SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          color: Colors.grey,
                        ))
                    : SizedBox()
              ],
            )),
          ),
        )),
        Space(1.h)
      ],
    );
  }

  Widget _deliveryRoute() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Space(2.h),
        Stack(children: [
          Container(
            clipBehavior: Clip.hardEdge,
            height: MediaQuery.of(context).size.height / 2,
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  blurRadius: 20,
                  offset: const Offset(0, 5),
                  color: Colors.black.withOpacity(0.2),
                ),
              ],
              borderRadius: const BorderRadius.all(Radius.circular(20)),
            ),
            child: SizedBox(
              width: MediaQuery.of(context).size.width,
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: SizedBox(
                  height: MediaQuery.of(context).size.height / 3,
                  width: MediaQuery.of(context).size.width - 10,
                  child: FutureBuilder<Set<Marker>>(
                    future: setMapMarkers(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return googleMap(snapshot);
                      } else if (snapshot.hasError) {
                        // return Center(child: Text('Error loading markers'));
                        // Log the error to your console or debug log
                        debugPrint('Error loading markers: ${snapshot.error}');
                        print('Error loading markers: ${snapshot.error}');

                        // Optionally, assert in development mode to catch unexpected errors
                        assert(
                            false, 'Error loading markers: ${snapshot.error}');
                        return Center(
                          child: Text(''),
                        );
                      } else {
                        return googleMap(snapshot);
                      }
                    },
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            right: 2.h,
            top: 2.h,
            child: CustomIconButton(
              // color: Colors.white,
              // boxColor: Color.fromRGBO(250, 110, 0, 1),
              text: 'back',
              ic: Icons.arrow_back_ios_new_outlined,
              onTap: () {
                setState(() {
                  activeFlag = 0;
                });
              },
            ),
          )
        ]),
        Space(2.h),
        Text(
          'DELIVERY LOCATION',
          style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w400,
              fontFamily: 'Product Sans',
              color: Color.fromRGBO(10, 76, 97, 1)),
        ),
        Space(2.h),
        Row(
          children: [
            Icon(
              Icons.location_on,
              color: Color.fromRGBO(250, 110, 0, 1),
              size: 28,
            ),
            Space(
              1.h,
              isHorizontal: true,
            ),
            Text(
              userAddressDetails['businessName'],
              style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  fontFamily: 'Jost',
                  color: Color.fromRGBO(10, 76, 97, 1)),
            ),
          ],
        ),
        Space(0.5.h),
        Text(userAddressDetails['addressDetails'],
            style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w400,
                fontFamily: 'Product Sans',
                color: Color.fromRGBO(10, 76, 97, 1))),
        Space(2.h),
        Container(
          padding: EdgeInsets.only(left: 20, top: 20),
          width: double.infinity,
          decoration: BoxDecoration(
              color: Color.fromRGBO(243, 246, 240, 1),
              borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(35), topRight: Radius.circular(35))),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Items needed',
                style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    fontFamily: 'Jost',
                    color: Color.fromRGBO(10, 76, 97, 1)),
              ),
              Space(2.h),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    for (int index = 0; index < _bulkOrders.length; index++)
                      Row(
                        children: [
                          BulkOrderItem(
                            itemDetails: _bulkOrders[index],
                          ),
                          Space(
                            3.h,
                            isHorizontal: true,
                          ),
                        ],
                      ),
                  ],
                ),
              ),
              Space(2.h)
            ],
          ),
        )
      ],
    );
  }

  Widget _bidSuccessful() {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final hours = twoDigits(duration.inHours);
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 4.h, vertical: 4.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Your bid has been placed successfully',
            style: const TextStyle(
              color: Color(0xFF094B60),
              fontSize: 25,
              fontFamily: 'PT Sans',
              fontWeight: FontWeight.w700,
              // height: 0.06,
              letterSpacing: 0.54,
            ),
          ),
          Space(1.h),
          const Text(
            'We will notify you if you win the orders in',
            style: TextStyle(
              color: Color(0xFF094B60),
              fontSize: 12,
              fontFamily: 'PT Sans',
              fontWeight: FontWeight.w400,
              // height: 0.06,
              letterSpacing: 0.54,
            ),
          ),
          Space(3.h),
          const Center(
            child: Text(
              'Countdown :',
              style: TextStyle(
                color: Color.fromRGBO(250, 110, 0, 1),
                fontSize: 12,
                fontFamily: 'PT Sans',
                fontWeight: FontWeight.w700,
                // height: 0.06,
                letterSpacing: 0.54,
              ),
            ),
          ),
          Space(1.h),
          Center(
            child: IntrinsicWidth(
              child: Container(
                padding: EdgeInsets.symmetric(vertical: 1.h, horizontal: 1.h),
                decoration: ShapeDecoration(
                  color: Colors.white,
                  shadows: [
                    BoxShadow(
                        offset: Offset(0, 8),
                        spreadRadius: 0,
                        color: Color.fromRGBO(162, 210, 167, 0.38),
                        blurRadius: 20)
                  ],
                  // color: const Color.fromRGBO(250, 110, 0, 1),
                  shape: SmoothRectangleBorder(
                    borderRadius: SmoothBorderRadius(
                      cornerRadius: 10,
                      cornerSmoothing: 1,
                    ),
                  ),
                ),
                child: Center(
                    child: Text(
                  '$hours:$minutes:$seconds',
                  style: TextStyle(
                    color: Color.fromRGBO(10, 76, 97, 1),
                    fontSize: 12,
                    fontFamily: 'Product Sans',
                    fontWeight: FontWeight.w400,
                    height: 0,
                    letterSpacing: 0.30,
                  ),
                )),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
