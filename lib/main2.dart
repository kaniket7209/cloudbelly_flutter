import 'dart:async';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'dart:ui' as ui;

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: MapSample(),
    );
  }
}

class MapSample extends StatefulWidget {
  @override
  State<MapSample> createState() => MapSampleState();
}

class MapSampleState extends State<MapSample> {
  Completer<GoogleMapController> _controller = Completer();
  static final CameraPosition _kGooglePlex = CameraPosition(
    target: LatLng(37.422, -122.084),
    zoom: 14.0,
  );

  late Uint8List markerIcon;
  late bool _isLoading = true;
  final Set<Polyline> _polyline = {};

  @override
  void initState() {
    super.initState();
    _addPolyline();
    setCustomMarker();
  }

  Future<void> setCustomMarker() async {
    try {
      Uint8List iconData =
          await getBytesFromAsset('assets/images/placeholder.png', 100);
      setState(() {
        markerIcon = iconData;
        _isLoading = false;
      });
    } catch (error) {
      print('Error loading custom marker: $error');
    }
  }

  Future<Uint8List> getBytesFromAsset(String path, int width) async {
    ByteData data = await rootBundle.load(path);
    ui.Codec codec = await ui.instantiateImageCodec(
      data.buffer.asUint8List(),
      targetWidth: width,
    );
    ui.FrameInfo fi = await codec.getNextFrame();
    return (await fi.image.toByteData(format: ui.ImageByteFormat.png))!
        .buffer
        .asUint8List();
  }

  void _addPolyline() {
    List<LatLng> polylineCoordinates = [
      LatLng(37.422, -122.084),
      LatLng(37.427, -122.079),
    ];

    setState(() {
      _polyline.add(
        Polyline(
          polylineId: PolylineId('path'),
          points: polylineCoordinates,
          color: Colors.blue,
          width: 5,
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Google Maps Custom Marker'),
        backgroundColor: Colors.green[700],
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : GoogleMap(
              polylines: _polyline,
              mapType: MapType.normal,
              initialCameraPosition: _kGooglePlex,
              markers: {
                Marker(
                  anchor: Offset(0.5, 0.5),
                  markerId: MarkerId('marker1'),
                  position: LatLng(37.422, -122.084),
                  icon: BitmapDescriptor.fromBytes(markerIcon),
                  infoWindow: InfoWindow(
                    title: 'Custom Marker 1',
                    snippet: 'Googleplex',
                  ),
                ),
                Marker(
                  markerId: MarkerId('marker2'),
                  position: LatLng(37.427, -122.079),
                  icon: BitmapDescriptor.fromBytes(markerIcon),
                  infoWindow: InfoWindow(
                    title: 'Custom Marker 2',
                    snippet: 'Some other location',
                  ),
                ),
              },
              onMapCreated: (GoogleMapController controller) {
                _controller.complete(controller);
              },
            ),
    );
  }
}
