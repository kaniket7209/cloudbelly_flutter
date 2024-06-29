import 'package:cloudbelly_app/api_service.dart';
import 'package:cloudbelly_app/models/dish.dart';
import 'package:cloudbelly_app/models/restaurant.dart';
import 'package:cloudbelly_app/widgets/appwide_loading_bannner.dart';
import 'package:cloudbelly_app/widgets/dish_card.dart';
import 'package:cloudbelly_app/widgets/restaurant_card.dart';
import 'package:figma_squircle/figma_squircle.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';

class SearchView extends StatefulWidget {
  @override
  _SearchViewState createState() => _SearchViewState();
}

class _SearchViewState extends State<SearchView> {
  final TextEditingController _searchController = TextEditingController();
  List<Dish> dishItems = [];
  List<Restaurant> restaurantItems = [];
  bool isDishesSelected = true;
  int page = 1;
  int limit = 10;
  Position? _currentPosition;
  String? area;
  String? address;
  bool isLoading = false;
  bool hasMoreData = true;
  String currentAddress = 'Fetching location...';
  PageController _pageController = PageController();

  Map<String, String> headers = {
    'Content-Type': 'application/json; charset=UTF-8'
  };

  @override
  void initState() {
    super.initState();
    _initializeData();

    // _checkLocationPermission();
    // _fetchData();
    _searchController.addListener(_onSearchChanged);
  }

  Future<void> _initializeData() async {
    await _checkLocationPermission();
    _fetchData();
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

      List<Placemark> placemarks = await placemarkFromCoordinates(
          _currentPosition?.latitude ?? 22.88689073443092,
          _currentPosition?.longitude ?? 79.5086424934095);
      if (placemarks.isNotEmpty) {
        Placemark placemark = placemarks.first;

        address =
            '${placemark.street}, ${placemark.subLocality},${placemark.subAdministrativeArea}, ${placemark.locality}, ${placemark.administrativeArea},${placemark.country}, ${placemark.postalCode}';
        area = '${placemark.administrativeArea}';

        setState(() {
          currentAddress = area!;
        });
      } else {
        address = 'Address not found';
      }

      await Provider.of<Auth>(context, listen: false).updateCustomerLocation(
          _currentPosition?.latitude, _currentPosition?.longitude);
    } catch (e) {
      print('Error: $e');
    }
    Navigator.pop(context);
    setState(() {});
  }

  Future<void> _fetchData() async {
    if (_currentPosition == null) {
      await _getCurrentLocation();
    }

    if (_currentPosition == null) {
      // Handle the case where location could not be fetched
      return;
    }

    if (isLoading || !hasMoreData) return;

    setState(() {
      isLoading = true;
    });

    String function = isDishesSelected ? 'products' : 'vendors';
    var response = await http.post(
      Uri.parse('https://app.cloudbelly.in/search/$function'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, dynamic>{
        'page': page,
        'limit': limit,
        'latitude': _currentPosition!.latitude,
        'longitude': _currentPosition!.longitude,
        'query': _searchController.text,
      }),
    );
    print("apicall ${json.encode({
          'page': page,
          'limit': limit,
          'latitude': _currentPosition!.latitude,
          'longitude': _currentPosition!.longitude,
          'query': _searchController.text,
        })}");
    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(response.body);
      setState(() {
        if (isDishesSelected) {
          dishItems.addAll(data.map((item) => Dish.fromJson(item)).toList());
        } else {
          restaurantItems
              .addAll(data.map((item) => Restaurant.fromJson(item)).toList());
        }
        if (data.length < limit) {
          hasMoreData = false;
        } else {
          page++;
        }
      });
    } else {
      // Handle error
      print("Failed to load data");
    }

    setState(() {
      isLoading = false;
    });
  }

  void _onSearchChanged() {
    setState(() {
      page = 1;
      if (isDishesSelected) {
        dishItems.clear();
      } else {
        restaurantItems.clear();
      }
      hasMoreData = true;
    });
    _fetchData();
  }

  void _searchItems(String query) {
    setState(() {
      page = 1;
      if (isDishesSelected) {
        dishItems.clear();
      } else {
        restaurantItems.clear();
      }
      hasMoreData = true;
      _fetchData();
    });
  }

  void _changeTab(bool dishesSelected) {
    setState(() {
      isDishesSelected = dishesSelected;
      page = 1;
      if (dishesSelected) {
        dishItems.clear();
      } else {
        restaurantItems.clear();
      }
      hasMoreData = true;
    });
    _pageController.jumpToPage(dishesSelected ? 0 : 1);
    _fetchData();
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xff7B358D),
        toolbarHeight: 120.0, // Set a specific height for the AppBar
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            GestureDetector(
              onTap: () async {
                var selectedLocation = await showSearch(
                  context: context,
                  delegate: LocationSearchDelegate(),
                );
                if (selectedLocation != null) {
                  setState(() {
                    currentAddress = selectedLocation['description']!;
                  });

                  var location = selectedLocation['location']?.split(',');
                  if (location != null && location.length == 2) {
                    double latitude = double.parse(location[0]);
                    double longitude = double.parse(location[1]);

                    _currentPosition = Position(
                      latitude: latitude,
                      longitude: longitude,
                      timestamp: DateTime.now(),
                      accuracy: 0,
                      altitude: 0,
                      heading: 0,
                      speed: 0,
                      speedAccuracy: 0,
                      altitudeAccuracy: 0,
                      headingAccuracy: 0, // Added this parameter
                    );

                    await Provider.of<Auth>(context, listen: false)
                        .updateCustomerLocation(
                      latitude,
                      longitude,
                    );

                    // Fetch data based on new location
                    // _fetchData();
                    setState(() {
                      page = 1;
                      dishItems.clear();
                      restaurantItems.clear();
                      hasMoreData = true;
                    });
                    await _fetchData();
                  }
                }
              },
              child: Row(
                children: [
                  Container(
                    child: Icon(Icons.location_pin, color: Colors.white),
                  ),
                  SizedBox(
                    width: 10,
                  ),
                  Row(
                    children: [
                      Container(
                        child: Text(
                          currentAddress,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Container(
                        child: Icon(
                          Icons.keyboard_arrow_down,
                          color: Color(0xFFFA6E00),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(height: 10),
            Container(
              // height: 48.0, // Ensure height is consistent with the TextField
              decoration: ShapeDecoration(
                color: Colors.white,
                shape: SmoothRectangleBorder(
                  borderRadius: SmoothBorderRadius(
                    cornerRadius: 15.0,
                    cornerSmoothing: 1,
                  ),
                ),
                shadows: [
                  BoxShadow(
                    color: Color(0xff4F205B).withOpacity(0.4),
                    spreadRadius: 0,
                    blurRadius: 20,
                    offset: Offset(0, 8),
                  ),
                ],
              ),
              child: TextField(
                style: const TextStyle(
                  fontSize: 14,
                ),
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Search for restaurants or dishes',
                  border: InputBorder.none,
                  contentPadding:
                      EdgeInsets.symmetric(vertical: 14, horizontal: 20),
                  suffixIcon: IconButton(
                    icon: Icon(Icons.search),
                    onPressed: () => _searchItems(_searchController.text),
                  ),
                ),
                textInputAction: TextInputAction.search,
                onSubmitted: (value) {
                  _searchItems(value);
                },
              ),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Container(
            decoration: BoxDecoration(
              color: Color(0xff7B358D),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(30),
                bottomRight: Radius.circular(30),
              ),
              boxShadow: [
                BoxShadow(
                  color: Color(0xff7B358D).withOpacity(0.3),
                  blurRadius: 6,
                  offset: Offset(0, 6),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                GestureDetector(
                  onTap: () => _changeTab(true),
                  child: Column(
                    children: [
                      SizedBox(height: 5),
                      Text(
                        'Dishes',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontFamily: 'Product Sans',
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (isDishesSelected)
                        Align(
                          alignment: Alignment.center,
                          child: Container(
                            margin: const EdgeInsets.only(top: 6.0, right: 0),
                            decoration: BoxDecoration(
                              color: Color(0xffFA6E00),
                              borderRadius: BorderRadius.circular(2.0),
                            ),
                            height: 4.0,
                            child: IntrinsicWidth(
                              child: Text(
                                'Dishes',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.transparent,
                                ),
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                GestureDetector(
                  onTap: () => _changeTab(false),
                  child: Column(
                    children: [
                      SizedBox(height: 5),
                      Text(
                        'Restaurants',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontFamily: 'Product Sans',
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (!isDishesSelected)
                        Align(
                          alignment: Alignment.center,
                          child: Container(
                            margin: const EdgeInsets.only(top: 6.0, right: 0),
                            decoration: BoxDecoration(
                              color: Color(0xffFA6E00),
                              borderRadius: BorderRadius.circular(2.0),
                            ),
                            height: 4.0,
                            child: IntrinsicWidth(
                              child: Text(
                                'Restaurants',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.transparent,
                                ),
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 10),
          Expanded(
            child: PageView(
              controller: _pageController,
              onPageChanged: (index) {
                setState(() {
                  isDishesSelected = index == 0;
                });
                _changeTab(index == 0);
              },
              children: [
                _buildDishList(),
                _buildRestaurantList(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDishList() {
    return NotificationListener<ScrollNotification>(
      onNotification: (ScrollNotification scrollInfo) {
        if (scrollInfo.metrics.pixels == scrollInfo.metrics.maxScrollExtent &&
            !isLoading) {
          _fetchData();
        }
        return false;
      },
      child: RefreshIndicator(
        onRefresh: () async {
          setState(() {
            page = 1;
            dishItems.clear();
            hasMoreData = true;
          });
          await _fetchData();
        },
        child: dishItems.isEmpty && !isLoading
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      'No dishes in   ',
                      style: TextStyle(
                        color: Color(0xff9E749E).withOpacity(0.4),
                        fontWeight: FontWeight.bold,
                        fontSize: 35,
                        fontFamily: 'Product Sans',
                      ),
                    ),
                    Text(
                      'this region  ',
                      style: TextStyle(
                        color: Color(0xff9E749E).withOpacity(0.4),
                        fontWeight: FontWeight.bold,
                        fontSize: 35,
                        fontFamily: 'Product Sans',
                      ),
                    ),
                  ],
                ),
              )
            : ListView.builder(
                itemCount: dishItems.length + (hasMoreData ? 1 : 0),
                itemBuilder: (context, index) {
                  if (index == dishItems.length) {
                    return Center(child: CircularProgressIndicator());
                  }
                  return DishCard(dish: dishItems[index]);
                },
              ),
      ),
    );
  }

  Widget _buildRestaurantList() {
    return NotificationListener<ScrollNotification>(
      onNotification: (ScrollNotification scrollInfo) {
        if (scrollInfo.metrics.pixels == scrollInfo.metrics.maxScrollExtent &&
            !isLoading) {
          _fetchData();
        }
        return false;
      },
      child: RefreshIndicator(
        onRefresh: () async {
          setState(() {
            page = 1;
            restaurantItems.clear();
            hasMoreData = true;
          });
          await _fetchData();
        },
        child: restaurantItems.isEmpty && !isLoading
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      'No restaurants in   ',
                      style: TextStyle(
                        color: Color(0xff9E749E).withOpacity(0.4),
                        fontWeight: FontWeight.bold,
                        fontSize: 35,
                        fontFamily: 'Product Sans',
                      ),
                    ),
                    Text(
                      'this region  ',
                      style: TextStyle(
                        color: Color(0xff9E749E).withOpacity(0.4),
                        fontWeight: FontWeight.bold,
                        fontSize: 35,
                        fontFamily: 'Product Sans',
                      ),
                    ),
                  ],
                ),
              )
            : ListView.builder(
                itemCount: restaurantItems.length + (hasMoreData ? 1 : 0),
                itemBuilder: (context, index) {
                  if (index == restaurantItems.length) {
                    return Center(child: CircularProgressIndicator());
                  }
                  return RestaurantCard(restaurant: restaurantItems[index]);
                },
              ),
      ),
    );
  }
}

class LocationSearchDelegate extends SearchDelegate<Map<String, String>> {
  final List<Map<String, String>> locations = [
    {'description': 'Current Location', 'location': ''},
    {'description': 'Jamshedpur, Jharkhand', 'location': '22.8046, 86.2029'},
    {'description': 'Siliguri, West Bengal', 'location': '26.7271, 88.3953'},
    {'description': 'Kolkata, West Bengal', 'location': '22.5726, 88.3639'},
    {'description': 'Mumbai, Maharashtra', 'location': '19.0760, 72.8777'},
  ];

  @override
  List<Widget> buildActions(BuildContext context) {
    return [IconButton(icon: Icon(Icons.clear),  onPressed: () {
                                    Navigator.of(context).pop();
                                  },)];
  }

  // @override
  // Widget buildLeading(BuildContext context) {
  //   return IconButton(
  //     icon: Icon(Icons.arrow_back),
  //     onPressed: () => close(context, {}),
  //   );
  // }

  @override
  Widget buildResults(BuildContext context) {
    final results = locations
        .where((loc) =>
            loc['description']!.toLowerCase().contains(query.toLowerCase()))
        .toList();

    return ListView.builder(
      itemCount: results.length,
      itemBuilder: (context, index) {
        return ListTile(
          title: Text(results[index]['description']!),
          onTap: () {
            if (results[index]['description'] == 'Current Location') {
              // Handle current location selection
              _getCurrentLocation(context);
            } else {
               Navigator.of(context).pop();
              // close(context, results[index]);
            }
          },
        );
      },
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    final suggestions = locations
        .where((loc) =>
            loc['description']!.toLowerCase().contains(query.toLowerCase()))
        .toList();

    return ListView.builder(
      itemCount: suggestions.length,
      itemBuilder: (context, index) {
        return ListTile(
          title: Text(suggestions[index]['description']!),
          onTap: () {
            if (suggestions[index]['description'] == 'Current Location') {
              // Handle current location selection
              _getCurrentLocation(context);
            } else {
              close(context, suggestions[index]);
            }
          },
        );
      },
    );
  }

  void _getCurrentLocation(BuildContext context) async {
    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    List<Placemark> placemarks =
        await placemarkFromCoordinates(position.latitude, position.longitude);
    if (placemarks.isNotEmpty) {
      Placemark placemark = placemarks.first;
      close(context, {
        'description': 'Current Location',
        'location': '${position.latitude},${position.longitude}',
      });
    } else {
      close(context, {'description': 'Location not found', 'location': ''});
    }
  }
  
  @override
  Widget buildLeading(BuildContext context) {
    return const SizedBox(); // Return an empty widget
  }
}
