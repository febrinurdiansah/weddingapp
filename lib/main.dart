import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:google_nav_bar/google_nav_bar.dart';

import 'detailScreen.dart';
import 'historiScreen.dart';
import 'homeScreen.dart';
import 'loginScreen.dart';
import 'profilScreen.dart';
import 'registerScreen.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'Wedding Vendor App',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primarySwatch: Colors.blue,
          visualDensity: VisualDensity.adaptivePlatformDensity,
        ),
        home: HomeScreen());
  }
}

class NavPage extends StatefulWidget {
  static List<Widget> _widgetOptions = <Widget>[
    HomeScreen(),
    HistoryScreen(),
    ProfileScreen(),
  ];

  @override
  State<NavPage> createState() => _HomeState();
}

class _HomeState extends State<NavPage> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Center(
          child: NavPage._widgetOptions.elementAt(_selectedIndex),
        ),
        bottomNavigationBar: Container(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 15, vertical: 2),
            child: SafeArea(
              child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 15.0, vertical: 8),
                  child: GNav(
                      rippleColor: Color.fromRGBO(218, 137, 100, 1),
                      hoverColor: Color.fromRGBO(211, 121, 79, 1),
                      gap: 8,
                      activeColor: Color.fromRGBO(196, 86, 35, 1),
                      iconSize: 24,
                      padding:
                          EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      duration: Duration(milliseconds: 400),
                      tabActiveBorder: Border.all(
                          color: Color.fromRGBO(165, 90, 57, 1), width: 1),
                      color: Color.fromRGBO(210, 177, 162, 1),
                      tabs: [
                        GButton(
                          icon: Icons.home,
                          text: 'Home',
                        ),
                        GButton(
                          icon: Icons.article_rounded,
                          text: 'Histori',
                        ),
                        GButton(
                          icon: Icons.person,
                          text: 'Profil',
                        ),
                      ],
                      selectedIndex: _selectedIndex,
                      onTabChange: (index) {
                        setState(() {
                          _selectedIndex = index;
                        });
                      })),
            ),
          ),
        ));
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
