import 'dart:async';
import 'dart:ui';
import 'package:cloudbelly_app/screens/Tabs/supplier/individual_order_bill.dart';
import 'package:location/location.dart' as loc;
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
import 'package:location/location.dart';
import 'package:permission_handler/permission_handler.dart' as perm;
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

class OrderDeliveryMap extends StatefulWidget {
  final List<SupplierBulkOrder> bulkOrders;
  final bool bidWon;

  const OrderDeliveryMap(
      {super.key, required this.bulkOrders, required this.bidWon});

  @override
  State<OrderDeliveryMap> createState() => OrderDeliveryMapState();
}

class OrderDeliveryMapState extends State<OrderDeliveryMap> {
  List<UserDetail> users = [];

  late bool _bidWon = false;

  late bool _placeBid = false;
  late List<SupplierBulkOrder> _bulkOrders = [];

  late Map<String, dynamic> userAddressDetails = {
    'businessName': '',
    'addressDetails': ''
  };
  late LatLng _currentLocation;
  late bool _isMapLoading = false;
  late bool _isDataLoading = true;
  late int activeFlag = 0;
  late bool _reduceMapHeight = false;
  CameraPosition? cameraPosition;
  Position? _currentPosition;
  late Set<Marker> _mapMarkers = {};
  loc.Location _location = loc.Location();
  List<Placemark> placeMarks = [];
  late List<int> checkedBoxes = [1, 2, 3];
  String? area;
  String? address;
  late Set<Marker> _initialMarkers = {};
  GoogleMapController? _mapController;
  late List<String> userIDs = [];
  TOastNotification toastNotification = TOastNotification();
  late UserOrderDeliveryDetail _userOrderDetails;

  late Map<int, Map<String, dynamic>> _orderPreparation = {
    1: {'key': 1, 'value': "Start packing before 12pm", 'checked': false},
    2: {'key': 2, 'value': "Check the Quality", 'checked': false},
    3: {'key': 3, 'value': "Ready For Delivery", 'checked': false},
  };

  final _controllers = List.generate(4, (index) => TextEditingController());
  final _focusNodes = List.generate(4, (index) => FocusNode());

  Widget _buildBody() {
    switch (activeFlag) {
      case 0:
        return _deliveryRoute();
      case 1:
        return IndividualOrderBill();
      default:
        return _deliveryRoute(); // Default case if the flag is out of expected range
    }
  }

  Future<void> getCartInfoForUser(String userId) async {
    setState(() {
      _isDataLoading = true;
    });
    _userOrderDetails = await getUserCartInfo(userId);
    if (_userOrderDetails != null) {
      setState(() {
        _userOrderDetails = _userOrderDetails;
        _isDataLoading = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();

    // Create a deep copy of the list and its items
    _bulkOrders = widget.bulkOrders.map((order) => order.clone()).toList();
    getCartInfoForUser(_bulkOrders[0].userIDs[0]);
    // print('Hello user ids'+ _bulkOrders[0].userIDs.toString());
    _checkLocationPermission();
    // _getCurrentLocation();
    getUsersDetails();
  }

  void _onChanged(String value, int index) {
    if (value.length == 1 && index < 3) {
      FocusScope.of(context).requestFocus(_focusNodes[index + 1]);
    }
    if (value.isEmpty && index > 0) {
      FocusScope.of(context).requestFocus(_focusNodes[index - 1]);
    }

    // Update container size based on OTP input
    if (_controllers.any((controller) => controller.text.isNotEmpty)) {
      setState(() {
        print('Yes');
        _reduceMapHeight = true; // Reduced size
      });
    } else {
      print('No');
      setState(() {
        _reduceMapHeight = false; // Original size
      });
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
    late Set<Marker> localMarkers = {};
    print('Inside set map markers');
    _isMapLoading = true;
    setState(() {});

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
            getCartInfoForUser(users[i].userID);
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

    setState(() {
      _isMapLoading = false;
    });
    return localMarkers;
  }

  bool _isEnabled(int key) {
    if (key == 1) {
      return true;
    }
    return _orderPreparation[key - 1]!['checked'];
  }

  Widget orderOtpSection() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: List.generate(4, (index) {
        return Container(
            width: 50,
            margin: EdgeInsets.symmetric(horizontal: 5),
            child: TextField(
              controller: _controllers[index],
              focusNode: _focusNodes[index],
              keyboardType: TextInputType.number,
              textAlign: TextAlign.center,
              maxLength: 1,
              decoration: InputDecoration(
                counterText: '',
                filled: true, // This property enables filling the text box
                fillColor: Color.fromRGBO(
                    198, 239, 161, 1), // Change this to the desired color
              ),
              onChanged: (value) => _onChanged(value, index),
            ));
      }),
    );
  }

  Future<void> getUsersDetails() async {
    for (int i = 0; i < _bulkOrders.length; i++) {
      userIDs += _bulkOrders[i].userIDs;
    }
    users = await getUsersDetailsByUserIDs(userIDs);

    if (users != null) {
      userAddressDetails['businessName'] = users[0].hNo;
      userAddressDetails['addressDetails'] = users[0].detailedAddress;

      _mapMarkers = await setMapMarkers();
      if (_mapMarkers.isNotEmpty) {
        _isMapLoading = false;
      }
    }
  }

  Future<void> _checkLocationPermission() async {
    perm.PermissionStatus permission =
        await perm.Permission.locationWhenInUse.status;
    if (permission != perm.PermissionStatus.granted) {
      await perm.Permission.locationWhenInUse.request();
    }
  }

  Future<void> _getCurrentLocation() async {
    setState(() {
      _isMapLoading = true;
    });

    try {
      loc.LocationData _locationData = await _location.getLocation();
      if (_locationData.latitude != null) {
        setState(() {
          _currentLocation =
              LatLng(_locationData.latitude!, _locationData.longitude!);
          _initialMarkers.add(
            Marker(
              markerId: MarkerId('currentLocation'),
              position: _currentLocation,
              infoWindow: InfoWindow(title: 'Current Location'),
            ),
          );
          _isMapLoading = false;
        });
      }
    } catch (e) {}
  }

  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.dispose();
    }
    for (var focusNode in _focusNodes) {
      focusNode.dispose();
    }
    super.dispose();
  }

  Widget googleMap() {
    return GoogleMap(
      myLocationButtonEnabled: true,
      zoomControlsEnabled: true,
      myLocationEnabled: true,
      scrollGesturesEnabled: true,
      markers: _isMapLoading ? _initialMarkers : _mapMarkers,
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
          children: [_buildBody()],
        ),
      ),
    );
  }

  Widget _deliveryRoute() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
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
                    child: _isMapLoading ? SizedBox() : googleMap()),
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
              _isDataLoading ? '' : _userOrderDetails.businessName,
              style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  fontFamily: 'Jost',
                  color: Color.fromRGBO(10, 76, 97, 1)),
            ),
          ],
        ),
        Space(0.5.h),
        Text(_isDataLoading ? '' : _userOrderDetails.businessName,
            style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w400,
                fontFamily: 'Product Sans',
                color: Color.fromRGBO(10, 76, 97, 1))),
        Space(2.h),
        widget.bidWon
            ? SizedBox(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Enter OTP",
                        style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                            fontFamily: 'Jost',
                            color: Color.fromRGBO(10, 76, 97, 1))),
                    Space(1.h),
                    orderOtpSection(),
                    Row(
                      children: [
                        Space(
                          1.h,
                          isHorizontal: true,
                        ),
                        Text("Verified",
                            style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                fontFamily: 'Jost',
                                color: Color.fromRGBO(250, 110, 0, 1))),
                        Space(0.5.h),
                        Transform.scale(
                          scale: 0.8, // Adjust the scale to change the size
                          child: Checkbox(
                            fillColor:
                                MaterialStateProperty.resolveWith((states) {
                              if (states.contains(MaterialState.selected)) {
                                return Color.fromRGBO(
                                    250, 110, 0, 1); // Active color
                              }
                              return Colors.grey
                                  .withOpacity(0.3); // Inactive color
                            }),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(6)),
                            side: BorderSide.none,
                            value: true,
                            onChanged: (var val) {},
                          ),
                        )
                      ],
                    ),
                    Space(1.h),
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
                              'Delivered',
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
                                activeFlag = 1;
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
                                'Generate Bill',
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
                    Space(2.h),
                  ],
                ),
              )
            : Container(
                padding: EdgeInsets.only(left: 20, top: 20),
                width: double.infinity,
                decoration: BoxDecoration(
                    color: Color.fromRGBO(243, 246, 240, 1),
                    borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(35),
                        topRight: Radius.circular(35))),
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
                          for (int index = 0;
                              index < _userOrderDetails.cartInfoList.length;
                              index++)
                            Row(
                              children: [
                                CartOrderItem(
                                  cartDetails:
                                      _userOrderDetails.cartInfoList[index],
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
              ),
      ],
    );
  }
}
