import 'dart:ui';

import 'package:cloudbelly_app/api_service.dart';
import 'package:cloudbelly_app/constants/assets.dart';
import 'package:cloudbelly_app/constants/globalVaribales.dart';
import 'package:cloudbelly_app/screens/Tabs/Cart/add_address.dart';
import 'package:cloudbelly_app/screens/Tabs/Dashboard/dashboard.dart';
import 'package:cloudbelly_app/widgets/appwide_loading_bannner.dart';
import 'package:cloudbelly_app/widgets/space.dart';
import 'package:cloudbelly_app/widgets/toast_notification.dart';
import 'package:cloudbelly_app/widgets/touchableOpacity.dart';
import 'package:figma_squircle/figma_squircle.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/widgets.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';

class GoogleMapScreen extends StatefulWidget {
  final String type;

  const GoogleMapScreen({super.key, required this.type});

  @override
  State<GoogleMapScreen> createState() => _GoogleMapScreenState();
}

class _GoogleMapScreenState extends State<GoogleMapScreen> {
  CameraPosition? cameraPosition;
  Position? _currentPosition;
  List<Placemark> placeMarks = [];
  String? area;
  String? address;
  Set<Marker> _markers = {};
  GoogleMapController? _mapController;

  @override
  void initState() {
    super.initState();
    _checkLocationPermission();
  }

  Future<void> _checkLocationPermission() async {
    PermissionStatus permission = await Permission.locationWhenInUse.status;
    if (permission == PermissionStatus.granted) {
      _getCurrentLocation();
    } else {
      await Permission.locationWhenInUse.request();
    }
  }

  Future<void> _getCurrentLocation() async {
    AppWideLoadingBanner().loadingBanner(context);
    try {
      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);
      _currentPosition = position;
      _mapController?.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(
            target: LatLng(
              _currentPosition?.latitude ?? 22.88689073443092,
              _currentPosition?.longitude ?? 79.5086424934095,
            ),
            zoom: 15,
            bearing: 45,
            tilt: 30,
            //  zoom: 19,
          ),
        ),
      );
      var marker = Marker(
        markerId: MarkerId("1"),
        position: LatLng(
            _currentPosition?.latitude ?? 22.88689073443092,
            _currentPosition?.longitude ??
                79.5086424934095), // Assuming 'd' contains 'latitude' and 'longitude'
      );
      _markers.add(marker);
      List<Placemark> placemarks = await placemarkFromCoordinates(
          _currentPosition?.latitude ?? 22.88689073443092,
          _currentPosition?.longitude ?? 79.5086424934095);
      if (placemarks.isNotEmpty) {
        Placemark placemark = placemarks.first;

        address =
            '${placemark.street}, ${placemark.subLocality},${placemark.subAdministrativeArea}, ${placemark.locality}, ${placemark.administrativeArea},${placemark.country}, ${placemark.postalCode}';
        area = '${placemark.administrativeArea}';

        print("address $area,$address");
      } else {
        address = 'Address not found';
      }
      print(
          "postiton:: ${_currentPosition?.latitude} ${_currentPosition?.longitude}");
    } catch (e) {
      print('Error: $e');
    }
    Navigator.pop(context);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    clipBehavior: Clip.hardEdge,
                    height: MediaQuery.of(context).size.height * .65,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                            blurRadius: 20,
                            offset: const Offset(0, 5),
                            color: Colors.black.withOpacity(0.2)),
                      ],
                      borderRadius: const BorderRadius.only(
                        bottomLeft: Radius.circular(74),
                        bottomRight: Radius.circular(74),
                      ),
                    ),
                    child: GoogleMap(
                      zoomControlsEnabled: false,
                      myLocationEnabled: false,
                      markers: _markers,
                      onMapCreated: (GoogleMapController controller) {
                        setState(() {
                          _mapController = controller;
                        });
                      },
                      initialCameraPosition: CameraPosition(
                        target: LatLng(
                          _currentPosition?.latitude ?? 22.88689073443092,
                          _currentPosition?.longitude ?? 79.5086424934095,
                        ),
                        zoom: 15,
                        bearing: 45,
                        tilt: 30,
                        //  zoom: 19,
                      ),
                    ),
                  ),
                  Positioned(
                    left: 10,
                    top: 10,
                    child: InkWell(
                      onTap: () {
                        Navigator.of(context).pop();
                      },
                      child: Container(
                        height: 40,
                        width: 40,
                        decoration: GlobalVariables().ContainerDecoration(
                            offset: const Offset(3, 6),
                            blurRadius: 20,
                            shadowColor:
                                const Color.fromRGBO(158, 116, 158, 0.5),
                            boxColor: const Color(0xFFFA6E00),
                            cornerRadius: 8),
                        child: const Text(
                          '<<',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontFamily: 'Kavoon',
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.66,
                          ),
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 19,
                    //left: 50,
                    //right: 50,
                    child: InkWell(
                      onTap: () {
                        _checkLocationPermission();
                      },
                      child: Container(
                        height: 45,
                        //margin: EdgeInsets.symmetric(horizontal: 50),
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        decoration: GlobalVariables().ContainerDecoration(
                            offset: const Offset(3, 6),
                            blurRadius: 20,
                            shadowColor: const Color(0xFF3D3D3D78),
                            boxColor: Colors.white,
                            cornerRadius: 15),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Image.asset(
                              Assets.place_marker,
                              height: 23,
                              width: 23,
                              fit: BoxFit.cover,
                            ),
                            const Space(
                              10,
                              isHorizontal: true,
                            ),
                            const Text(
                              "LOCATE ME",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Color(0xFF2E0536),
                                fontSize: 16,
                                fontFamily: 'Jost',
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const Space(29),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 27.0),
                child: Text(
                  'SELECT DELIVERY LOCATION',
                  style: TextStyle(
                      fontSize: 18,
                      color: Color(0xFF494949),
                      fontFamily: 'Product Sans',
                      fontWeight: FontWeight.w400),
                ),
              ),
              const Space(9),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 27.0),
                child: Row(
                  children: [
                    Image.asset(
                      Assets.location,
                      height: 20,
                      width: 20,
                      fit: BoxFit.cover,
                    ),
                    const Space(
                      4,
                      isHorizontal: true,
                    ),
                    Text(
                      area ?? "",
                      style: const TextStyle(
                          fontSize: 16,
                          color: Color(0xFF2E0536),
                          fontFamily: 'Jost',
                          fontWeight: FontWeight.w600),
                    ),
                    const Spacer(),
                    Container(
                      height: 40,
                      //width: 40,
                      padding: const EdgeInsets.symmetric(horizontal: 15),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: const Color(0xFF2E0536),
                          width: 1,
                        ),
                        boxShadow: const [
                          BoxShadow(
                            offset: Offset(0, 6),
                            blurRadius: 20,
                            color: Color.fromRGBO(158, 116, 158, 0.5),
                          )
                        ],
                      ),
                      /*decoration: GlobalVariables().ContainerDecoration(
                        offset: const Offset(3, 6),
                        blurRadius: 20,
                        shadowColor: const Color.fromRGBO(158, 116, 158, 0.5),
                        boxColor:  Colors.white,
                        cornerRadius: 8),*/
                      child: const Center(
                        child: Text(
                          'Change',
                          style: TextStyle(
                              fontSize: 14,
                              color: Color(0xFF9428A9),
                              fontFamily: 'Jost',
                              fontWeight: FontWeight.w600),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const Space(10),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 27.0),
                child: Text(
                  address ?? '',
                  //'23rd Main Rd, Hosapalaya, Bangalore, Karnatak 560102, India (Colive Gardenia)',
                  style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF494949),
                      fontFamily: 'Product Sans',
                      fontWeight: FontWeight.w400),
                ),
              ),
              const Space(25),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 51.0),
                child: SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: TouchableOpacity(
                    onTap: () {
                      if (_currentPosition?.latitude != null ||
                          _currentPosition?.longitude != null) {
                        context.read<TransitionEffect>().setBlurSigma(5.0);
                        AddAddressBottomSheet().AddAddressSheet(
                            context,
                            _currentPosition?.latitude ?? 0.0,
                            _currentPosition?.longitude ?? 0.0,
                            address ?? " ",
                            widget.type);
                      } else {
                        TOastNotification().showErrorToast(
                            context, "Please get the location");
                      }
                    },
                    child: ButtonWidgetHomeScreen(
                      txt: 'Confirm Location',
                      isActive: true,
                    ),
                  ),
                ),
              ),
              GestureDetector(
                onTap: () {
                  // Handle tap on the area around the BackdropFilter
                  print('Tapped outside of the modal bottom sheet');
                  // You can add any logic here, such as dismissing the modal bottom sheet
                  // For example:
                  // Navigator.of(context).pop();
                },
                child: BackdropFilter(
                  filter: ImageFilter.blur(
                    sigmaX: context.watch<TransitionEffect>().blurSigma,
                    sigmaY: context.watch<TransitionEffect>().blurSigma,
                  ),
                  child: Container(
                    color: Colors.transparent, // Transparent color
                  ),
                ),
              )
              /*  Padding(
                padding: const EdgeInsets.symmetric(horizontal: 27.0),
                child: TouchableOpacity(
                  onTap: () {},
                  child: Container(
                    height: 48,
                    padding: const EdgeInsets.symmetric(horizontal: 18),
                    decoration: ShapeDecoration(
                      color: const Color(0xFFFA6E00),
                      shape: SmoothRectangleBorder(
                          borderRadius: SmoothBorderRadius(
                            cornerRadius: 12,
                            cornerSmoothing: 1,
                          )),
                    ),
                    child: const Center(
                      child: Text(
                        'Confirm Location',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontFamily: 'Product Sans',
                          fontWeight: FontWeight.w700,
                          height: 0,
                          letterSpacing: 0.14,
                        ),
                      ),
                    ),
                  ),
                ),
              ),*/
            ],
          ),
        ),
      ),
    );
  }
}
