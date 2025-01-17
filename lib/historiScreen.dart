import 'package:custom_rating_bar/custom_rating_bar.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'auth_service.dart';

class HistoryScreen extends StatefulWidget {
  @override
  _HistoryScreenState createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  List<Map<String, dynamic>> historyItems = [];
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
      await loadHistory();
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
      return vendor['vendor_info']; // Akses vendor_info langsung
    }
    return null;
  } catch (e) {
    print('Error finding vendor with ID $placeId: $e');
    return null;
  }
}


  Future<void> loadHistory() async {
    if (!mounted) return;

    try {
      setState(() {
        isLoading = true;
      });

      final token = await _authService.getToken();
      final userId = await _authService.getUserId();
      
      print('Loading history - Token: $token, UserId: $userId');

      if (userId == null || token == null) {
        throw Exception('User ID or token is null');
      }

      final response = await http.get(
        Uri.parse('https://api-bagas2.vercel.app/user/$userId/history'),
        headers: {
          'Content-Type': 'application/json',
          'x-auth-token': token,
        },
      );

      print('History response status: ${response.statusCode}');
      print('History response body: ${response.body}');

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        final List<dynamic> searchHistory = List.from(responseData['searchHistory']);
        
        print('Search History IDs: $searchHistory'); // Debug log
        
        List<Map<String, dynamic>> detailedHistory = [];
        
        for (String placeId in searchHistory) {
          final vendorDetails = findVendorById(placeId);
          print('Found vendor details for $placeId: ${vendorDetails != null}'); // Debug log

          if (vendorDetails != null) {
            detailedHistory.add({
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
            historyItems = detailedHistory;
            isLoading = false;
          });
        }
      } else {
        throw Exception('Failed to load history: ${response.statusCode}');
      }
    } catch (e) {
      print('Error loading history: $e');
      if (mounted) {
        setState(() {
          isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load history: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
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

  Future<void> clearHistory() async {
    try {
      // Clear local storage
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.remove('vendor_history');

      // Clear server history
      final token = await _authService.getToken();
      final userId = await _authService.getUserId();
      
      if (userId != null && token != null) {
        final response = await http.delete(
          Uri.parse('https://api-bagas2.vercel.app/user/$userId/history'),
          headers: {
            'x-auth-token': token,
          },
        );

        if (response.statusCode != 200) {
          throw Exception('Failed to clear server history');
        }
      }

      setState(() {
        historyItems = [];
      });
    } catch (e) {
      print('Error clearing history: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to clear history')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromRGBO(234, 217, 201, 1),
      appBar: AppBar(
        backgroundColor: Color.fromRGBO(195, 147, 124, 1),
        elevation: 0,
        leading: Container(),
        title: Text("Histori", style: TextStyle(color: Colors.black)),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.delete, color: Colors.black),
            onPressed: clearHistory,
          ),
        ],
      ),
      body: isLoading
      ? Center(child: CircularProgressIndicator())
      : historyItems.isEmpty
        ? Center(child: Text('Tidak ada histori'))
        : ListView.builder(
          padding: const EdgeInsets.all(20),
          itemCount: historyItems.length,
          itemBuilder: (context, index) {
            final item = historyItems[index];
            return Card(
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
            );
          },
        ),
    );
  }
}
