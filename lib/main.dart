import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Wedding Vendor App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<dynamic> vendors = [];

  @override
  void initState() {
    super.initState();
    loadVendors();
  }

  Future<void> loadVendors() async {
    try {
      String jsonString =
          await rootBundle.loadString('assets/data/recommendations.json');
      Map<String, dynamic> jsonResponse = json.decode(jsonString);
      setState(() {
        vendors = jsonResponse.values.toList();
      });
    } catch (e) {
      print("Error loading vendors: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Daftar Vendor Pernikahan"),
        backgroundColor: Colors.blueAccent,
      ),
      body: vendors.isEmpty
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: vendors.length,
              itemBuilder: (context, index) {
                var vendor = vendors[index];
                return Card(
                  margin: EdgeInsets.all(10),
                  elevation: 5,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: ListTile(
                    contentPadding: EdgeInsets.all(10),
                    leading: Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        image: DecorationImage(
                          image: NetworkImage(
                              vendor['vendor_info']['featured_image'] ?? ''),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    title: Text(
                      vendor['vendor_info']['name'],
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                    ),
                    subtitle: Text(
                      'Rating: ${vendor['vendor_info']['rating']}',
                      style: TextStyle(fontSize: 14),
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              VendorDetailPage(vendor: vendor),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
    );
  }
}

class VendorDetailPage extends StatelessWidget {
  final dynamic vendor;

  VendorDetailPage({required this.vendor});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(vendor['vendor_info']['name']),
        backgroundColor: Colors.blueAccent,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            // Gambar vendor
            Container(
              width: double.infinity,
              height: 250,
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: NetworkImage(vendor['vendor_info']['featured_image']
                      //?? 'https://via.placeholder.com/150'
                      ),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            // Nama dan Rating Vendor
            Padding(
              padding: EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    vendor['vendor_info']['name'] ?? 'Tidak ada nama',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 10),
                  Text(
                    'Rating: ${vendor['vendor_info']['rating'] ?? 'Tidak ada rating'} (${vendor['vendor_info']['reviews_count'] ?? 0} ulasan)',
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                  SizedBox(height: 20),
                  // Deskripsi Vendor
                  Text(
                    vendor['vendor_info']['description'] ??
                        'Tidak ada keterangan',
                    style: TextStyle(fontSize: 16),
                  ),
                  SizedBox(height: 20),
                  // Informasi Alamat dan Waktu Operasional
                  _buildDetailText(
                      'Alamat: ${vendor['vendor_info']['address'] ?? 'Tidak ada alamat'}'),
                  _buildDetailText(
                      'Jam Kerja: ${vendor['vendor_info']['workday_timing'] ?? 'Tidak ada jam kerja'}'),
                  _buildDetailText(
                      'Tutup: ${vendor['vendor_info']['closed_on'] ?? 'Tidak ada informasi tutup'}'),
                  _buildDetailText(
                      'Telepon: ${vendor['vendor_info']['phone'] ?? 'Tidak ada nomor telepon'}'),
                  _buildDetailText(
                      'Website: ${vendor['vendor_info']['website'] ?? 'Tidak ada website'}'),
                ],
              ),
            ),
            // Daftar Review
            Padding(
              padding: EdgeInsets.all(16.0),
              child: Text(
                'Ulasan:',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            ListView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemCount: vendor['reviews'].length,
              itemBuilder: (context, index) {
                var review = vendor['reviews'][index];
                return Card(
                  margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  elevation: 3,
                  child: ListTile(
                    title: Text(
                      review['reviewer_name'] ?? 'Tidak ada nama reviewer',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(
                      '${review['rating']} bintang: ${review['review_text'] ?? 'Tidak ada ulasan'}',
                      style: TextStyle(fontSize: 14),
                    ),
                    trailing: Text(
                      review['published_at'] ?? 'Tidak ada waktu ulasan',
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  // Helper function to build text for vendor details
  Widget _buildDetailText(String text) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8.0),
      child: Text(
        text,
        style: TextStyle(fontSize: 16, color: Colors.black),
      ),
    );
  }
}
