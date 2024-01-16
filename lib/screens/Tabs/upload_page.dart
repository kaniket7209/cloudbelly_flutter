import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';

void main() {
  runApp(MaterialApp(
    home: UploadPage(),
  ));
}

class UploadPage extends StatefulWidget {
  @override
  _UploadPageState createState() => _UploadPageState();
}

class _UploadPageState extends State<UploadPage> {
  String _imagePath = "";
  TextEditingController _latitudeController = TextEditingController();
  TextEditingController _longitudeController = TextEditingController();
  TextEditingController _userIdController = TextEditingController();
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    this.initData();
  }

  initData() async {
  final position = await _getCurrentLocation();
  if (position != null) {
    _latitudeController.text = position.latitude.toString();
    _longitudeController.text = position.longitude.toString();
  } else {
    // Handle the scenario when position is null
    // For example, set default values or show an error message
  }
}


  Future<Position?> _getCurrentLocation() async {
  try {
    // Check if location services are enabled
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      print('Location services are disabled.');
      return null;
    }

    // Check for location permissions
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        print('Location permissions are denied');
        return null;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      // Permissions are denied forever, handle appropriately.
      print('Location permissions are permanently denied, we cannot request permissions.');
      return null;
    }

    // When permissions are granted, get the current position
    return await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.best);
  } catch (e) {
    // Handle any exceptions that occur during location fetching
    print('Error getting location: $e');
    return null;
  }
}

 Future<void> _selectImage() async {
  final picker = ImagePicker();
  final pickedFile = await picker.pickImage(source: ImageSource.gallery);

  if (pickedFile != null) {
    setState(() {
      _imagePath = pickedFile.path;
    });
    // Fetch and update the location after selecting the image
    final position = await _getCurrentLocation();
    if (position != null) {
      setState(() {
        _latitudeController.text = position.latitude.toString();
        _longitudeController.text = position.longitude.toString();
      });
    }
  }
}


  Future<String> _uploadImage(String imagePath) async {
    var request = http.MultipartRequest(
      'POST',
      Uri.parse('https://app.cloudbelly.in/upload'),
    );
    request.headers.addAll({
      'Accept': '*/*',
      'User-Agent': 'Thunder Client (https://www.thunderclient.com)',
    });

    request.files.add(await http.MultipartFile.fromPath(
      'file',
      imagePath,
    ));

    var response = await request.send();

    if (response.statusCode == 200) {
      final data = await response.stream.bytesToString();
      print(data);
      return jsonDecode(data)['file_url'];
    } else {
      throw Exception('Failed to upload image');
    }
  }

  Future<void> _sendMetadata(
      String fileUrl, String latitude, String longitude, String userId) async {
    final Map<String, String> headers = {
      'Accept': '*/*',
      'Content-Type': 'application/json',
    };

    final Map<String, String> body = {
      'file_url': fileUrl,
      'latitude': latitude,
      'longitude': longitude,
      'user_id': userId,
    };

    final response = await http.post(
      Uri.parse('https://app.cloudbelly.in/metadata/feed'),
      headers: headers,
      body: jsonEncode(body),
    );

    if (response.statusCode == 200) {
      // Metadata sent successfully
      // You can handle success here (e.g., show a success message).
    } else {
      throw Exception('Failed to send metadata');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Instagram-like Image Upload'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              GestureDetector(
                onTap: _selectImage,
                child: Container(
                  height: 200,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                  ),
                  child: _imagePath != null
                      ? Image.file(
                          File(_imagePath),
                          fit: BoxFit.cover,
                        )
                      : Center(
                          child: Icon(
                            Icons.add_a_photo,
                            size: 50,
                            color: Colors.grey,
                          ),
                        ),
                ),
              ),
              SizedBox(height: 16),
              TextField(
                controller: _latitudeController,
                decoration: InputDecoration(labelText: 'Latitude'),
              ),
              TextField(
                controller: _longitudeController,
                decoration: InputDecoration(labelText: 'Longitude'),
              ),
              TextField(
                controller: _userIdController,
                decoration: InputDecoration(labelText: 'User ID'),
              ),
              SizedBox(height: 16),
              ElevatedButton(
                onPressed: () async {
                  if (_imagePath != null) {
                    final fileUrl = await _uploadImage(_imagePath);
                    await _sendMetadata(
                      fileUrl,
                      _latitudeController.text,
                      _longitudeController.text,
                      _userIdController.text,
                    );
                  } else {
                    // Handle image not selected
                  }
                },
                child: Text('Upload and Send Metadata'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
