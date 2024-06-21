// lib/screens/search_view.dart
import 'package:cloudbelly_app/models/restaurant.dart';
import 'package:cloudbelly_app/widgets/restaurant_card.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';


class SearchView extends StatefulWidget {
  @override
  _SearchViewState createState() => _SearchViewState();
}

class _SearchViewState extends State<SearchView> {
  final TextEditingController _searchController = TextEditingController();
  List<Restaurant> _restaurants = [];
  bool isDishesSelected = true;
  int page = 1;
  int limit = 10;

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  void _fetchData() async {
    String function = isDishesSelected ? 'products' : 'vendors';
    var response = await http.post(
      Uri.parse('https://app.cloudbelly.in/search/$function'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, dynamic>{
        'page': page,
        'limit': limit,
      }),
    );

    if (response.statusCode == 200) {
      print("resp ${json.decode(response.body)}");
      List<dynamic> data = json.decode(response.body);
      setState(() {
        _restaurants = data.map((item) => Restaurant.fromJson(item)).toList();
      });
    } else {
      // Handle error
      print("Failed to load data");
    }
  }

  void _searchRestaurants(String query) {
    setState(() {
      _restaurants = _restaurants
          .where((restaurant) =>
              restaurant.name.toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.purple,
        title: TextField(
          controller: _searchController,
          decoration: InputDecoration(
            hintText: 'Search for restaurants or dishes',
            suffixIcon: IconButton(
              icon: Icon(Icons.search),
              onPressed: () => _searchRestaurants(_searchController.text),
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          Container(
            color: Colors.purple,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                GestureDetector(
                  onTap: () {
                    setState(() {
                      isDishesSelected = true;
                    });
                    _fetchData();
                  },
                  child: Column(
                    children: [
                      Text(
                        'Dishes',
                        style: TextStyle(
                          color: isDishesSelected
                              ? Colors.orange
                              : Colors.white,
                        ),
                      ),
                      if (isDishesSelected)
                        Container(
                          height: 2,
                          width: 60,
                          color: Colors.orange,
                        )
                    ],
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    setState(() {
                      isDishesSelected = false;
                    });
                    _fetchData();
                  },
                  child: Column(
                    children: [
                      Text(
                        'Restaurants',
                        style: TextStyle(
                          color: isDishesSelected
                              ? Colors.white
                              : Colors.orange,
                        ),
                      ),
                      if (!isDishesSelected)
                        Container(
                          height: 2,
                          width: 60,
                          color: Colors.orange,
                        )
                    ],
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _restaurants.length,
              itemBuilder: (context, index) {
                return RestaurantCard(restaurant: _restaurants[index]);
              },
            ),
          ),
        ],
      ),
    );
  }
}