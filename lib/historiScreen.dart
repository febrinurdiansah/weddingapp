import 'package:custom_rating_bar/custom_rating_bar.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

import 'package:http/http.dart' as http;

class HistoryScreen extends StatefulWidget {
  @override
  _HistoryScreenState createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  List<Map<String, dynamic>> historyItems = [];

  Future<void> loadHistory() async {
    try {
      // Load dari SharedPreferences untuk data lokal
      SharedPreferences prefs = await SharedPreferences.getInstance();
      List<String> localHistory = prefs.getStringList('vendor_history') ?? [];

      // Load dari API untuk data server
      final String? uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid != null) {
        final response = await http.get(
          Uri.parse('https://api-bagas2.vercel.app/user/$uid'),
        );

        if (response.statusCode == 200) {
          final userData = json.decode(response.body);
          final serverHistory = userData['searchHistory'] as List<dynamic>;
          
          // Update state dengan data dari server
          setState(() {
            historyItems = localHistory
                .map((vendorJson) => json.decode(vendorJson) as Map<String, dynamic>)
                .toList();
          });
        }
      }
    } catch (e) {
      print('Error loading history: $e');
    }
  }

  Future<void> clearHistory() async {
    try {
      // Clear local storage
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.remove('vendor_history');

      // Clear server history
      final String? uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid != null) {
        await http.delete(
          Uri.parse('https://api-bagas2.vercel.app/user/$uid/history'),
        );
      }

      setState(() {
        historyItems = [];
      });
    } catch (e) {
      print('Error clearing history: $e');
    }
  }

  @override
  void initState() {
    super.initState();
    loadHistory();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromRGBO(234, 217, 201, 1),
      appBar: AppBar(
        backgroundColor: Color.fromRGBO(195, 147, 124, 1),
        elevation: 0,
        leading: Container(),
        title: Text("History", style: TextStyle(color: Colors.black)),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.delete, color: Colors.black),
            onPressed: clearHistory,
          ),
        ],
      ),
      body: historyItems.isEmpty
      ? Center(child: Text('Tidak ada histori'),)
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
                    child: Image.network(
                      item['vendor_info']['featured_image'] ?? 
                        Image.asset('assets/img/no_img.png',
                          width: 230,
                          height: 180,
                          fit: BoxFit.cover,
                          ),
                      width: 230,
                      height: 180,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => 
                        Image.asset('assets/img/no_img.png',
                            width: 230,
                            height: 180,
                            fit: BoxFit.cover,
                          ),
                    ),
                  ),
                  SizedBox(height: 8),
                  RatingBar.readOnly(
                    filledIcon: Icons.star,
                    emptyIcon: Icons.star_border,
                    halfFilledIcon: Icons.star_half,
                    isHalfAllowed: true,
                    initialRating: item['vendor_info']['rating'].toDouble(),
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
