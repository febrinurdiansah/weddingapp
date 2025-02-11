import 'package:custom_rating_bar/custom_rating_bar.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'auth_service.dart';
import 'detailScreen.dart';

class FavoritesScreen extends StatefulWidget {
  @override
  _FavoritesScreenState createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  List<Map<String, dynamic>> favoriteItems = [];
  final AuthService _authService = AuthService();
  bool isLoading = true;
  List<dynamic> vendorData = [];

  @override
  void initState() {
    super.initState();
    loadVendorData();
  }

  Future<void> loadVendorData() async {
    try {
      final String jsonString = await DefaultAssetBundle.of(context)
          .loadString('assets/data/sorted_by_recommendations.json');
      setState(() {
        vendorData = json.decode(jsonString);
      });
      await loadFavorites();
    } catch (e) {
      print('Error loading vendor data: $e');
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading vendor data: ${e.toString()}')),
      );
    }
  }

  Map<String, dynamic>? findVendorById(String placeId) {
    try {
      print('Searching for placeId: $placeId');
      final vendor = vendorData.firstWhere(
        (vendor) => vendor['place_id'].toString() == placeId.toString(),
        orElse: () => null,
      );
      if (vendor != null) {
        print('Vendor found: ${vendor['vendor_info']}');
        return vendor['vendor_info']; 
      }
      return null;
    } catch (e) {
      print('Error finding vendor with ID $placeId: $e');
      return null;
    }
  }

  Future<void> loadFavorites() async {
    if (!mounted) return;

    try {
      setState(() {
        isLoading = true;
      });

      final token = await _authService.getToken();
      final userId = await _authService.getUserId();

      print('Loading favorites - Token: $token, UserId: $userId');

      if (userId == null || token == null) {
        throw Exception('User ID or token is null');
      }

      final response = await http.get(
        Uri.parse('https://api-bagas2.vercel.app/user/$userId/favorites'),
        headers: {
          'Content-Type': 'application/json',
          'x-auth-token': token,
        },
      );

      print('Favorites response status: ${response.statusCode}');
      print('Favorites response body: ${response.body}');

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        final List<dynamic> favoritesList = List.from(responseData['favorites']);
        
        print('Favorite Vendor IDs: $favoritesList'); 

        List<Map<String, dynamic>> detailedFavorites = [];

        for (String placeId in favoritesList) {
          final vendorDetails = findVendorById(placeId);
          print('Found vendor details for $placeId: ${vendorDetails != null}');

          if (vendorDetails != null) {
            detailedFavorites.add({
              'place_id': placeId,
              'vendor_info': {
                'name': vendorDetails['name'] ?? "Tidak ada nama Vendor",
                'address': vendorDetails['address'] ?? "Tidak ada alamat",
                'featured_image': vendorDetails['featured_image'] ?? "",
                'rating': double.tryParse(vendorDetails['rating']?.toString() ?? '0') ?? 0.0,
                'reviews_count': int.tryParse(vendorDetails['reviews_count']?.toString() ?? '0') ?? 0,
                'description': vendorDetails['description'],
                'workday_timing': vendorDetails['workday_timing'],
                'closed_on': vendorDetails['closed_on'],
                'phone': vendorDetails['phone'],
                'website': vendorDetails['website'],
              },
            });
          }
        }
        if (mounted) {
          setState(() {
            favoriteItems = detailedFavorites;
            isLoading = false;
          });
        }
      } else {
        throw Exception('Failed to load favorites: ${response.statusCode}');
      }
    } catch (e) {
      print('Error loading favorites: $e');
      if (mounted) {
        setState(() {
          isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load favorites: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> removeFromFavorites(String placeId) async {
    try {
      final token = await _authService.getToken();
      final userId = await _authService.getUserId();

      if (userId == null || token == null) {
        throw Exception('User ID or token is null');
      }

      final response = await http.delete(
        Uri.parse('https://api-bagas2.vercel.app/user/$userId/favorites/$placeId'),
        headers: {
          'x-auth-token': token,
        },
      );

      if (response.statusCode == 200) {
        setState(() {
          favoriteItems.removeWhere((item) => item['place_id'] == placeId);
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Colors.green,
            content: Text('Vendor berhasil dihapus dari favorit')),
        );
      } else {
        throw Exception('Failed to remove from favorites');
      }
    } catch (e) {
      print('Error removing favorite: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.red,
          content: Text('Gagal hapus vendor favorit')),
      );
    }
  }

  Widget _buildImage(String? imageUrl) {
    return imageUrl != null && imageUrl.isNotEmpty
        ? Image.network(
            imageUrl,
            width: 230,
            height: 180,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) => Image.asset(
              'assets/img/no_img.png',
              width: 230,
              height: 180,
              fit: BoxFit.cover,
            ),
          )
        : Image.asset(
            'assets/img/no_img.png',
            width: 230,
            height: 180,
            fit: BoxFit.cover,
          );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromRGBO(234, 217, 201, 1),
      appBar: AppBar(
        backgroundColor: Color.fromRGBO(195, 147, 124, 1),
        elevation: 0,
        title: Text("Favorites", style: TextStyle(color: Colors.black)),
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : favoriteItems.isEmpty
              ? Center(child: Text('Tidak ada favorit'))
              : ListView.builder(
                  padding: const EdgeInsets.all(20),
                  itemCount: favoriteItems.length,
                  itemBuilder: (context, index) {
                    final item = favoriteItems[index];
                    return Dismissible(
                      key: Key(item['place_id']),
                      direction: DismissDirection.endToStart,
                      background: Container(
                        color: Colors.red,
                        alignment: Alignment.centerRight,
                        padding: EdgeInsets.symmetric(horizontal: 20),
                        child: Icon(Icons.delete, color: Colors.white),
                      ),
                      confirmDismiss: (direction) async {
                        return await showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: Text("Hapus Favorit"),
                            content: Text("Apakah Anda yakin ingin menghapus vendor ini dari favorit?"),
                            actions: [
                              TextButton(onPressed: () => Navigator.of(context).pop(false), child: Text("Batal")),
                              TextButton(onPressed: () => Navigator.of(context).pop(true), child: Text("Hapus")),
                            ],
                          ),
                        );
                      },
                      onDismissed: (direction) => removeFromFavorites(item['place_id']),
                      child: GestureDetector(
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => VendorDetailScreen(vendor: item),
                          ),
                        ),
                        child: Card(
                          margin: const EdgeInsets.only(bottom: 16.0),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(13),
                            child: Column(
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: _buildImage(item['vendor_info']['featured_image']),
                                        ),
                                SizedBox(height: 8),
                                RatingBar.readOnly(
                                  filledIcon: Icons.star,
                                  emptyIcon: Icons.star_border,
                                  halfFilledIcon: Icons.star_half,
                                  isHalfAllowed: true,
                                  initialRating: item['vendor_info']['rating'] ?? 0.0,
                                  maxRating: 5,
                                  filledColor: Colors.yellow,
                                  halfFilledColor: Colors.yellow,
                                  size: 24,
                                  alignment: Alignment.center,
                                ),
                                SizedBox(height: 8),
                                Text(
                                  item['vendor_info']['name'] ?? "Tidak ada nama Vendor",
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                SizedBox(height: 5),
                                Text(
                                  item['vendor_info']['address'] ?? "Tidak ada alamat",
                                  style: TextStyle(fontSize: 16, color: Colors.grey),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          ),
                        ),
                      )
                    );
                  },
                ),
    );
  }
}
