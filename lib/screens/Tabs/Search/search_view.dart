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
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
  String? area;
  String? address;
  bool isLoading = false;
  bool hasMoreData = true;
  String currentAddress = 'Fetching location...';
  PageController _pageController = PageController();
  bool _locationFetched = false;
  bool darkMode = true;

  Map<String, String> headers = {
    'Content-Type': 'application/json; charset=UTF-8'
  };

  @override
  void initState() {
    super.initState();
    getDarkModeStatus();
    _initializeData();
    currentAddress = Provider.of<Auth>(context, listen: false)
        .userData?['current_location']['area'];
    _searchController.addListener(_onSearchChanged);
  }

  Future<String?> getDarkModeStatus() async {
    final prefs = await SharedPreferences.getInstance();

    setState(() {
      darkMode = prefs.getString('dark_mode') == "true" ? true : false;
    });

    return prefs.getString('dark_mode');
  }

  Future<void> _initializeData() async {
    setState(() {
      isLoading = true;
    });
    if (!_locationFetched) {
      // await _checkLocationPermission();
    }
    _fetchData();
    setState(() {
      isLoading = false;
    });
  }

  Future<void> _getCurrentLocation(context) async {
    setState(() {
      isLoading = true;
    });
    var _currentPosition;
    var address;
    var area;
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
      } else {
        address = 'Address not found';
      }

      await Provider.of<Auth>(context, listen: false).updateCustomerLocation(
          _currentPosition?.latitude, _currentPosition?.longitude, area);
      print("locLogmain.dart $_currentPosition  $area");
    } catch (e) {
      print('Error: $e');
    }
    setState(() {
      isLoading = false;
    });
  }

Future<void> _fetchData() async {
  if (!hasMoreData) return; // Stop if there's no more data to fetch

  setState(() {
    isLoading = true;
  });

  final currentLocation = Provider.of<Auth>(context, listen: false)
      .userData?['current_location'];

  if (currentLocation == null) {
    await _getCurrentLocation(context); // Ensure location is fetched first
  }

  String function = isDishesSelected ? 'products' : 'vendors';

  var response = await http.post(
    Uri.parse('https://app.cloudbelly.in/search/$function'),
    headers: headers,
    body: jsonEncode({
      'page': page,
      'limit': limit,
      'latitude': currentLocation?['latitude'],
      'longitude': currentLocation?['longitude'],
      'query': _searchController.text,
    }),
  );

  if (response.statusCode == 200) {
    List<dynamic> data = json.decode(response.body);
    
    setState(() {
      if (isDishesSelected) {
        print("datadata  $data");
        dishItems.addAll(data.map((item) => Dish.fromJson(item)).toList());
      } else {
        if(page ==1 ) {
          restaurantItems.clear();
        }
        restaurantItems.addAll(data.map((item) => Restaurant.fromJson(item)).toList());
      }

      if (data.length < limit) {
        hasMoreData = false; // End of data
      } else {
        page++; // Increment page if more data exists
      }
    });
  } else {
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
    hasMoreData = true;
   
   

    // Clear the appropriate list based on the selected tab
    if (isDishesSelected) {
      dishItems.clear();
      
    } else {
      restaurantItems.clear();
    }
  });

  // Change the page in the PageView
  _pageController.jumpToPage(dishesSelected ? 0 : 1);

  // Fetch data for the newly selected tab
  _fetchData();
}


  @override
  void dispose() {
    getDarkModeStatus();
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: darkMode
          ? Color(0xff313030)
          : Colors.white, // Full background color
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 20.0), // Custom padding for the "AppBar"
            decoration: BoxDecoration(
              color: darkMode ? Color(0xff1D1D1D) : Color(0xff7B358D),
              boxShadow: [
                BoxShadow(
                  color: darkMode
                      ? Color(0xff151415).withOpacity(0.69)
                      : Color(0xff7B358D).withOpacity(0.3),
                  blurRadius: 20,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  height: 3.h,
                ),
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

                        await Provider.of<Auth>(context, listen: false)
                            .updateCustomerLocation(
                                latitude, longitude, currentAddress);

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
                      Icon(Icons.location_pin, color: Colors.white),
                      SizedBox(width: 10),
                      Expanded(
                        child: Row(
                          children: [
                            Text(
                              currentAddress,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                            Icon(
                              Icons.keyboard_arrow_down,
                              color: Color(0xFFFA6E00),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 10),
                Container(
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
                    cursorColor: Color(0xff7B358D),
                    style: const TextStyle(
                      fontSize: 14,
                    ),
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Search for restaurants or dishes',
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(
                        vertical: 14,
                        horizontal: 20,
                      ),
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
          // Segment for Tabs and PageView
          Container(
            decoration: BoxDecoration(
              color: darkMode ? Color(0xff1D1D1D) : Color(0xff7B358D),
              boxShadow: [
                BoxShadow(
                  color: darkMode
                      ? Color(0xff151415).withOpacity(0.69)
                      : Color(0xff7B358D).withOpacity(0.3),
                  blurRadius: 20,
                  offset: Offset(0, 4),
                ),
              ],
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(30),
                bottomRight: Radius.circular(30),
              ),
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
                            letterSpacing: 1),
                      ),
                      if (isDishesSelected)
                        Align(
                          alignment: Alignment.center,
                          child: Container(
                            margin: const EdgeInsets.only(top: 6.0),
                            decoration: BoxDecoration(
                              color: Color(0xffFA6E00),
                              borderRadius: BorderRadius.circular(2.0),
                            ),
                            height: 4.0,
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
                            letterSpacing: 1),
                      ),
                      if (!isDishesSelected)
                        Align(
                          alignment: Alignment.center,
                          child: Container(
                            margin: const EdgeInsets.only(top: 6.0),
                            decoration: BoxDecoration(
                              color: Color(0xffFA6E00),
                              borderRadius: BorderRadius.circular(2.0),
                            ),
                            height: 4.0,
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
                    ],
                  ),
                ),
              ],
            ),
          ),
          // Content Body
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
            : Container(
                child: ListView.builder(
                  itemCount: dishItems.length + (hasMoreData ? 1 : 0),
                  itemBuilder: (context, index) {
                    if (index == dishItems.length) {
                      return Center(child: CircularProgressIndicator());
                    }
                    return DishCard(dish: dishItems[index],darkMode:darkMode);
                  },
                ),
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
                  return RestaurantCard(restaurant: restaurantItems[index],darkMode:darkMode);
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
    {"description": "Bangalore, Karnataka", "location": "12.9716, 77.5946"},
    {"description": "Sikkim, India", "location": "27.5330, 88.5122"}
  ];

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: Icon(Icons.clear),
        onPressed: () {
          Navigator.of(context).pop();
        },
      )
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return const SizedBox(
      width: 0,
    ); // Ensure this line is present
  }

  @override
  ThemeData appBarTheme(BuildContext context) {
    return Theme.of(context).copyWith(
      appBarTheme:  AppBarTheme(
        color: Color(0xff1D1D1D), // Your app bar color1D1D1D
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.white),
        toolbarTextStyle: TextStyle(
          color: Colors.white,
          fontSize: 18,
        ),
        titleTextStyle: TextStyle(
          color: Colors.white,
          fontSize: 18,
        ),
      ),
      inputDecorationTheme: const InputDecorationTheme(
        hintStyle: TextStyle(
          color: Colors.white, // Adjust as needed
          fontSize: 18,
        ),
      ),
      textTheme: const TextTheme(
        titleLarge: TextStyle(
          color: Colors.white, // Adjust as needed
          fontSize: 18,
        ),
      ),
    );
  }

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

    return Container(
      color: Color(0xff313030),
      child: ListView.builder(
        itemCount: suggestions.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(suggestions[index]['description']!,style: TextStyle(color: Colors.white),),
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
      ),
    );
  }

  void _getCurrentLocation(BuildContext context) async {
    var _currentPosition;
    var area;

    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    _currentPosition = position;
    List<Placemark> placemarks =
        await placemarkFromCoordinates(position.latitude, position.longitude);
    if (placemarks.isNotEmpty) {
      Placemark placemark = placemarks.first;
      area = '${placemark.administrativeArea}';
      close(context, {
        'description': '$area',
        'location': '${position.latitude},${position.longitude}',
      });
    } else {
      close(context, {'description': 'Location not found', 'location': ''});
    }

    await Provider.of<Auth>(context, listen: false).updateCustomerLocation(
        _currentPosition?.latitude, _currentPosition?.longitude, area);
    print("locLogsearchView.dart $_currentPosition  $area");
  }
}
