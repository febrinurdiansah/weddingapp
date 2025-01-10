import 'dart:convert';
import 'package:WeddingAPP/detailScreen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:custom_rating_bar/custom_rating_bar.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  List<dynamic> vendors = [];
  List<dynamic> filteredVendors = [];
  List<String> selectedCategories = [];
  late TabController _tabController;
  TextEditingController searchController = TextEditingController();
  bool isSearching = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(_onTabChanged);
    loadVendors('sorted_by_recommendations.json');
  }

  Future<void> loadVendors(String fileName) async {
    try {
      String jsonString = await rootBundle.loadString('assets/data/$fileName');
      List<dynamic> jsonResponse = json.decode(jsonString);
      setState(() {
        vendors = jsonResponse;
        filteredVendors = vendors;
      });
    } catch (e) {
      print("Error loading vendors: $e");
    }
  }

  void _resetFilter() {
    setState(() {
      selectedCategories.clear();
      filteredVendors = vendors;
    });
  }

  void _onTabChanged() {
    if (_tabController.indexIsChanging) {
      _resetFilter();
    }
    switch (_tabController.index) {
      case 0:
        loadVendors('sorted_by_recommendations.json');
        break;
      case 1:
        loadVendors('sorted_by_ratings.json');
        break;
      case 2:
        loadVendors('sorted_by_reviews.json');
        break;
      default:
        break;
    }
  }

  final List<Map<String, dynamic>> categories = [
    {"name": "Katering", "icon": Icons.cake},
    {"name": "Venue", "icon": Icons.location_city},
    {"name": "Gift", "icon": Icons.card_giftcard},
    {"name": "Decors", "icon": Icons.brush},
    {"name": "Undangan", "icon": Icons.text_fields},
    {"name": "WO", "icon": Icons.event},
    {"name": "Dresses", "icon": Icons.checkroom},
    {"name": "Ideas", "icon": Icons.lightbulb},
    {"name": "Music", "icon": Icons.music_note},
    {"name": "Photography", "icon": Icons.camera_alt},
  ];

  void filterVendors() {
    setState(() {
      if (selectedCategories.isEmpty && searchController.text.isEmpty) {
        filteredVendors = vendors;
      } else {
        filteredVendors = vendors.where((vendor) {
          List<dynamic> vendorCategories = vendor['vendor_info']['categories'];
          bool matchesCategory = selectedCategories.isEmpty || selectedCategories.any((category) => vendorCategories.contains(category));
          bool matchesSearch = vendor['vendor_info']['name']
              .toLowerCase()
              .contains(searchController.text.toLowerCase());
          return matchesCategory && matchesSearch;
        }).toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromRGBO(234, 217, 201, 1),
      body: DefaultTabController(
        length: 3,
        child: NestedScrollView(
          controller: ScrollController(),
          headerSliverBuilder: (context, innerBoxIsScrolled) {
            return [
              SliverToBoxAdapter(
                child: Container(
                  margin: EdgeInsets.only(top: 25, left: 15, right: 15),
                  padding: EdgeInsets.symmetric(horizontal: 15, vertical: 5),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12)
                  ),
                  child: Row(
                    children: [ 
                      Expanded(
                        flex: 4,
                        child: TextField(
                          maxLines: 1,
                          controller: searchController,
                          onChanged: (text) {
                            filterVendors();
                          },
                          decoration: InputDecoration(
                            hintText: 'Cari Vanue, Katering, dsb',
                            hintStyle: TextStyle(color: Colors.black26),
                            border: InputBorder.none,
                          ),
                          style: TextStyle(color: Colors.black26),
                        ),
                      ),
                      Expanded(
                        flex: 0,
                        child: Container(
                          decoration: BoxDecoration(
                            color: Color.fromRGBO(195, 147, 124, 1),
                            borderRadius: BorderRadius.circular(12)
                          ),
                          child: IconButton(
                            iconSize: 25,
                            icon: Icon(Icons.search, color: Colors.white),
                            onPressed: () {
                              setState(() {
                                if (isSearching) {
                                  searchController.clear();
                                  isSearching = false;
                                  filterVendors();
                                } else {
                                  isSearching = true;
                                }
                              });
                            },
                          ),
                        ),
                      ),
                    ]
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Container(
                  margin: EdgeInsets.only(top: 10, left: 10, right: 10, bottom: 0),
                  padding: EdgeInsets.only(top: 0, left: 10, right: 10, bottom: 20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 6,
                        offset: Offset(0, 3),
                      ),
                    ],
                  ),
                  child: GridView.builder(
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      childAspectRatio: 4,
                      crossAxisSpacing: 6,
                      mainAxisSpacing: 7,
                    ),
                    itemCount: categories.length,
                    shrinkWrap: true,
                    itemBuilder: (context, index) {
                      var category = categories[index];
                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            if (selectedCategories.contains(category['name'])) {
                              selectedCategories.remove(category['name']);
                            } else {
                              selectedCategories.add(category['name']);
                            }
                            filterVendors();
                          });
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            color: selectedCategories.contains(category['name'])
                                ? Color.fromRGBO(195, 147, 124, 1)
                                : Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black12,
                                blurRadius: 6,
                                offset: Offset(0, 3),
                              ),
                            ],
                          ),
                          child: Padding(
                            padding: EdgeInsets.symmetric(horizontal: 10),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Icon(category['icon'], size: 10, color: Colors.black54),
                                SizedBox(width: 5),
                                Text(
                                  category['name'],
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: selectedCategories.contains(category['name'])
                                        ? Colors.white
                                        : Colors.black54,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
              SliverAppBar(
                pinned: true,
                floating: true,
                automaticallyImplyLeading: false,
                backgroundColor: Color.fromRGBO(234, 217, 201, 1),
                expandedHeight: 0,
                toolbarHeight: 0,
                bottom: TabBar(
                  controller: _tabController,
                  isScrollable: true,
                  indicatorColor: Colors.brown,
                  indicatorWeight: 1,
                  labelColor: Colors.black,
                  unselectedLabelColor: Colors.grey,
                  tabAlignment: TabAlignment.start,
                  tabs: [
                    Tab(text: "Rekomendasi"),
                    Tab(text: "Rating Tertinggi"),
                    Tab(text: "Review Terbanyak"),
                  ],
                ),
              ),
            ];
          },
          body: TabBarView(
            controller: _tabController,
            children: [
              _gridData(vendors: filteredVendors),
              _gridData(vendors: filteredVendors),
              _gridData(vendors: filteredVendors),
            ],
          ),
        ),
      ),
    );
  }
}

class _gridData extends StatelessWidget {
  const _gridData({
    super.key,
    required this.vendors,
  });

  final List vendors;

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 8.0,
        mainAxisSpacing: 8.0,
        childAspectRatio: 0.8,
      ),
      itemCount: vendors.length,
      padding: const EdgeInsets.all(8.0),
      shrinkWrap: true,
      itemBuilder: (context, index) {
        var vendor = vendors[index];
        int rating = vendor['vendor_info']['rating'].toInt();
        return vendors.isEmpty
            ? Center(child: CircularProgressIndicator())
            : GestureDetector(
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => VendorDetailScreen(vendor: vendor),
                ),
              ),
              child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 6,
                        offset: Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ClipRRect(
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(12),
                          topRight: Radius.circular(12),
                        ),
                        child: Image.network(
                          vendor['vendor_info']['featured_image'] 
                          ?? Image.asset('assets/img/no_img.png',
                            height: 140,
                            width: double.infinity,
                            fit: BoxFit.cover,
                            ),
                          height: 140,
                          width: double.infinity,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => 
                            Image.asset('assets/img/no_img.png',
                            height: 140,
                            width: double.infinity,
                            fit: BoxFit.cover,
                            ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            RatingBar.readOnly(
                              filledIcon: Icons.star,
                              emptyIcon: Icons.star_border,
                              halfFilledIcon: Icons.star_half,
                              isHalfAllowed: true,
                              initialRating: rating.toDouble(),
                              maxRating: 5,
                              filledColor: Colors.yellow,
                              halfFilledColor: Colors.yellow,
                              size: 18,
                            ),
                            const SizedBox(height: 6),
                            Text(
                              vendor['vendor_info']['name'] ?? "Tidak ada nama",
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                const Icon(
                                  Icons.location_on,
                                  size: 15,
                                  color: Colors.black54,
                                ),
                                const SizedBox(width: 5),
                                Expanded(
                                  child: Text(
                                    vendor['vendor_info']['address'] ??
                                        "Lokasi tidak ditemukan",
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: Colors.black54,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
            );
      },
    );
  }
}
