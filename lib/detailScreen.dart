import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:custom_rating_bar/custom_rating_bar.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'auth_service.dart';

class VendorDetailScreen extends StatelessWidget {
  final dynamic vendor;
  final AuthService _authService = AuthService();

  VendorDetailScreen({super.key, this.vendor});

  Future<void> saveToHistory(Map<String, dynamic> vendor) async {
    try {
      final token = await _authService.getToken();
      final userId = await _authService.getUserId();
      
      print('Saving to history - Token: $token, UserId: $userId'); // Debug log
      
      if (userId != null && token != null) {
        // Prepare the data to be sent
        final historyData = {
          'searchItem': vendor['place_id'],
          'vendorName': vendor['name'] ?? 'Unknown Vendor',
          'timestamp': DateTime.now().toIso8601String(),
        };

        final response = await http.post(
          Uri.parse('https://api-bagas2.vercel.app/user/$userId/history'),
          headers: {
            'Content-Type': 'application/json',
            'x-auth-token': token,
          },
          body: json.encode(historyData),
        );

        print('Save history response: ${response.statusCode}'); // Debug log
        print('Response body: ${response.body}'); // Debug log

        if (response.statusCode != 200) {
          throw Exception('Failed to save history: ${response.body}');
        }
      }
    } catch (e) {
      print('Error saving history: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (vendor != null) {
        saveToHistory(vendor);
      }
    });
    return Scaffold(
      backgroundColor: Color.fromRGBO(234, 217, 201, 1),
      appBar: AppBar(
        backgroundColor: Color.fromRGBO(234, 217, 201, 1),
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.share, color: Colors.black),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Vendor Banner
            Stack(
              children: [
                Image.network(
                  vendor['vendor_info']['featured_image'] ??
                      Image.asset(
                        'assets/img/no_img.png',
                        width: double.infinity,
                        height: 350,
                        fit: BoxFit.cover,
                      ),
                  width: double.infinity,
                  height: 350,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Image.asset(
                    'assets/img/no_img.png',
                    width: double.infinity,
                    height: 350,
                    fit: BoxFit.cover,
                  ),
                ),
                Container(
                  height: 350,
                  color: Colors.black.withOpacity(0.6),
                ),
                Padding(
                  padding: EdgeInsets.only(top: 80),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Center(
                        child: CircleAvatar(
                          radius: 40,
                          backgroundColor: Colors.white,
                          backgroundImage: NetworkImage(vendor['vendor_info']
                                  ['featured_image'] ??
                              AssetImage("assets/img/no_img.png")),
                        ),
                      ),
                      SizedBox(height: 8),
                      RatingBar.readOnly(
                        filledIcon: Icons.star,
                        emptyIcon: Icons.star_border,
                        initialRating:
                            vendor['vendor_info']['rating'].toDouble(),
                        maxRating: 5,
                        filledColor: Colors.yellow,
                        size: 24,
                        alignment: Alignment.center,
                      ),
                      SizedBox(height: 4),
                      Text(
                        "${vendor['vendor_info']['reviews_count']} Reviews",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        vendor['vendor_info']['name'] ?? "Tidak ada Nama",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 4),
                      Text(
                        vendor['vendor_info']['address'] ?? "Tidak ada Alamat",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),
            // About Section
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "About",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    vendor['vendor_info']['description'] ??
                        "Tidak ada Deskripsi",
                    style: TextStyle(fontSize: 14),
                  ),
                  SizedBox(height: 16),
                  Text(
                    "Workday Timing: ${vendor['vendor_info']['workday_timing']}" ??
                        "Tidak ada Jam Kerja",
                    style: TextStyle(fontSize: 14, color: Colors.black),
                  ),
                  SizedBox(height: 4),
                  Text(
                    "Closed On: ${vendor['vendor_info']['closed_on']}" ??
                        "Tidak ada Tutup",
                    style: TextStyle(fontSize: 14, color: Colors.black),
                  ),
                ],
              ),
            ),
            SizedBox(height: 20),
            // Action Buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton.icon(
                  onPressed: () async {
                    final call = 'tel:${vendor['vendor_info']['phone']}';
                    if (call.isNotEmpty) {
                    final uri = Uri.parse(call);
                    if (await canLaunchUrl(uri)) {
                      launchUrl(uri);
                    }
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          'Nomor tidak tersedia',
                          style: TextStyle(color: const Color.fromRGBO(255, 255, 255, 1)),
                        ),
                        duration: Duration(seconds: 2),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                  },
                  icon: Icon(Icons.chat, color: Colors.black),
                  label: Text("Chat Vendor",
                    style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    backgroundColor: Color.fromRGBO(195, 147, 124, 1),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: () async {
                    final web = vendor['vendor_info']['website'];
                    if (web != null && web.isNotEmpty) {
                      final uri = Uri.parse(web);
                      if (await canLaunchUrl(uri)) {
                        launchUrl(uri);
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              'Tidak dapat membuka website',
                              style: TextStyle(color: Colors.white),
                            ),
                            duration: Duration(seconds: 2),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            'Website tidak tersedia',
                            style: TextStyle(color: Colors.white),
                          ),
                          duration: Duration(seconds: 2),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  },
                  icon: Icon(Icons.language, color: Colors.black),
                  label: Text(
                    "Visit Website",
                    style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    backgroundColor: Color.fromRGBO(195, 147, 124, 1),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}
