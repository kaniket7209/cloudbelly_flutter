// map.dart

// import 'package:cloudbelly_app/api_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class MapScreen extends StatefulWidget {
  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  List markers = [];
  List marker2s = [];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    this.initData();
    // print("gaurav");
  }

  // Future<List<String>> fetchImageUrls() async {
  //   final bucket = getBuc(
  //     region: 'ap-south-1', // Example: 'us-west-2'
  //     bucketId: 'image-uploads',
  //     accessKey: 'AKIAZQ3DPQ3CHIW33DWM',
  //     secretKey: 'HGxt4Zrsi0MGfk8uAV+FvESKH8Bx/orqrzOXVAIC',
  //   );

  //   // Now you can use 'bucket' to interact with your S3 bucket

  //   final images = await bucket.listContents();
  //   return images.map((file) => file.url).toList();
  // }

  initData() async {
    // var data = await sendUserTypeRequest();
    // // print(data);
    // for (var d in data) {
    //   // var dat = jsonDecode(d);
    //   // print(d);
    //   markers.add(d);
    // }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Search'),
      ),
      body: Column(
        children: [
          // Map Widget
          Flexible(
            child: FlutterMap(
              options: MapOptions(
                center: LatLng(12.9499136, 77.6732672), // San Francisco, CA
                zoom: 12.0,
              ),
              children: [
                TileLayer(
                  urlTemplate:
                      'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
                  subdomains: ['a', 'b', 'c'],
                ),
                MarkerLayer(
                  markers: (markers
                      .map(
                        (e) => Marker(
                          point: LatLng(12.9499136, 77.6732672),
                          width: 80,
                          height: 80,
                          child: e['profile_photo'] != null
                              ? Image.network(e['profile_photo'])
                              : Text("no imge"),
                        ),
                      )
                      .toList()),
                ),
              ],
            ),
          ),
          // Search Bar
          Container(
            padding: EdgeInsets.all(10.0),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Enter your search query',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
              ),
              // Implement your search functionality here
              onChanged: (query) {
                // Handle search query changes
              },
            ),
          ),
        ],
      ),
    );
  }
}
