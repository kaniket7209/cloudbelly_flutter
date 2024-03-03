import 'dart:ui';

import 'package:cloudbelly_app/api_service.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/services.dart';

class MapScreen extends StatefulWidget {
  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  Set<Marker> _markers = {};
  var camerPos = [];
  GoogleMapController? _mapController;

  @override
  void initState() {
    super.initState();
    _initMarkers();
  }

  Future<BitmapDescriptor> _createMarkerImageFromUrl(String imageUrl) async {
    final response = await http.get(Uri.parse(
        'https://images.pexels.com/photos/1162983/pexels-photo-1162983.jpeg?auto=compress&cs=tinysrgb&w=600'));
    final Uint8List bytes = response.bodyBytes;

    // Create a Codec from the image bytes
    final Codec codec = await instantiateImageCodec(bytes, targetWidth: 150);
    final FrameInfo frameInfo = await codec.getNextFrame();

    // Convert the frame to a dart:ui image
    final image = frameInfo.image;

    // Convert the dart:ui image to a PNG
    final ByteData? byteData =
        await image.toByteData(format: ImageByteFormat.png);
    final Uint8List pngBytes = byteData!.buffer.asUint8List();

    // Create the BitmapDescriptor from the PNG bytes
    final BitmapDescriptor bitmapDescriptor =
        BitmapDescriptor.fromBytes(pngBytes);
    return bitmapDescriptor;
  }

  Future<void> _initMarkers() async {
    try {
      var data = await Auth().sendUserTypeRequest();
      print(data);
      Set<Marker> markers = {};

      for (var d in data) {
        if (d['location'] != Null) {
          d['latitude'] = d['location']['latitude'] != ""
              ? d['location']['latitude']
              : Null;
          d['longitude'] = d['location']['longitude'] != ""
              ? d['location']['longitude']
              : Null;
          print("here");
        }
        if (d['latitude'] != Null && d['longitude'] != Null) {
          print("here2");
          print(d);
          camerPos = [
            double.parse(d['latitude']),
            double.parse(d['longitude'])
          ];
          BitmapDescriptor customIcon = await _createMarkerImageFromUrl(d[
              'profile_photo']); // Assuming 'd' contains the S3 URL for the image

          var marker = Marker(
            markerId: MarkerId(d['id'].toString()),
            position: LatLng(
                double.parse(d['latitude']),
                double.parse(d[
                    'longitude'])), // Assuming 'd' contains 'latitude' and 'longitude'
            infoWindow: InfoWindow(title: d['name']),
            icon: customIcon, // Replace with custom icon if needed
          );
          markers.add(marker);
        }
      }

      setState(() {
        _markers = markers;
      });
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: <Widget>[
          GoogleMap(
            onMapCreated: (GoogleMapController controller) {
              _mapController = controller;
            },
            initialCameraPosition: CameraPosition(
              target:
                  LatLng(camerPos[0], camerPos[1]), // Example starting position
              zoom: 12,
            ),
            markers: _markers,
          ),
          Positioned(
            bottom: 50,
            left: 0,
            right: 0,
            child: _buildBottomBar(),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(50),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: TextField(
            decoration: InputDecoration(
              hintText: 'What do you want to eat?',
              border: InputBorder.none,
              suffixIcon: IconButton(
                icon: Icon(Icons.send),
                onPressed: () {
                  // Implement your send request logic
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}
