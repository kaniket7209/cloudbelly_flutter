import 'package:cloudbelly_app/models/dish.dart';
import 'package:cloudbelly_app/models/restaurant.dart';
import 'package:cloudbelly_app/widgets/dish_card.dart';
import 'package:cloudbelly_app/widgets/restaurant_card.dart';
import 'package:figma_squircle/figma_squircle.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

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
  bool isLoading = false;
  bool hasMoreData = true;
  PageController _pageController = PageController();

  @override
  void initState() {
    super.initState();
    _fetchData();
    _searchController.addListener(_onSearchChanged);
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

  Future<void> _fetchData() async {
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
        'query': _searchController.text,
      }),
    );

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
        title: Container(
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
                color: Color(0xff7B358D).withOpacity(0.2),
                spreadRadius: 2,
                blurRadius: 10,
                offset: Offset(0, 3),
              ),
            ],
          ),
          child: TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Search for restaurants or dishes',
              border: InputBorder.none,
              contentPadding:
                  EdgeInsets.symmetric(vertical: 15, horizontal: 20),
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
                      SizedBox(height: 20),
                      Text(
                        'Dishes',
                        style: TextStyle(
                          color:Colors.white,
                          fontSize: 16,
                          fontFamily: 'Product Sans',
                           fontWeight: FontWeight.bold
                              // isDishesSelected ? Colors.orange : Colors.white,
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
                      // SizedBox(height: 10),
                    ],
                  ),
                ),
                GestureDetector(
                  onTap: () => _changeTab(false),
                  child: Column(
                    children: [
                      SizedBox(height: 20),
                      Text(
                        'Restaurants',
                        style: TextStyle(
                          color:Colors.white,
                          fontSize: 16,
                           fontFamily: 'Product Sans',
                          fontWeight: FontWeight.bold
                              // isDishesSelected ? Colors.white : Colors.orange,
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
                      // SizedBox(height: 10),
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
        child: ListView.builder(
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
        child: ListView.builder(
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
