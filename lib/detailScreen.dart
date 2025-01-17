import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:custom_rating_bar/custom_rating_bar.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:map_launcher/map_launcher.dart';
import 'auth_service.dart';

class VendorDetailScreen extends StatefulWidget {
  final dynamic vendor;

  VendorDetailScreen({Key? key, this.vendor}) : super(key: key);

  @override
  State<VendorDetailScreen> createState() => _VendorDetailScreenState();
}

class _VendorDetailScreenState extends State<VendorDetailScreen> {
  final AuthService _authService = AuthService();
  int _visibleReviewsCount = 10;

  Future<void> saveToHistory(Map<String, dynamic> vendor) async {
    try {
      final token = await _authService.getToken();
      final userId = await _authService.getUserId();

      if (userId != null && token != null) {
        final historyData = {
          'searchItem': vendor['place_id'],
          'vendorName': vendor['vendor_info']['name'] ?? 'Unknown Vendor',
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

        if (response.statusCode != 200) {
          throw Exception('Failed to save history: ${response.body}');
        }
      }
    } catch (e) {
      print('Error saving history: $e');
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.vendor != null) {
        saveToHistory(widget.vendor);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final vendor = widget.vendor;
    final reviews = vendor['reviews'] ?? [];

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
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'Fitur Share belum tersedia',
                    style: TextStyle(color: const Color.fromRGBO(255, 255, 255, 1)),
                  ),
                  duration: Duration(seconds: 2),
                  backgroundColor: Colors.red,
                ),
              );
            },
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
                  vendor['vendor_info']['featured_image'] ?? '',
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
                          backgroundImage: NetworkImage(
                            vendor['vendor_info']['featured_image'] ??
                                'assets/img/no_img.png',
                          ),
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
                        "${vendor['vendor_info']['reviews_count']} Ulasan",
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
                    "Tentang Kami",
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
                    "Buka pada: ${vendor['vendor_info']['workday_timing'] ?? "Tidak ada Jam Kerja"}",
                    style: TextStyle(fontSize: 14, color: Colors.black),
                  ),
                  SizedBox(height: 4),
                  Text(
                    "Tutup pada: ${vendor['vendor_info']['closed_on'] ?? "Tidak ada Tutup/Selalu Buka"}",
                    style: TextStyle(fontSize: 14, color: Colors.black),
                  ),
                ],
              ),
            ),
            SizedBox(height: 20),

            // Map Section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Container(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () async {
                    final coordinates = vendor['vendor_info']['coordinates'];
                    if (coordinates != null && 
                        coordinates['latitude'] != null && 
                        coordinates['longitude'] != null) {
                      final availableMaps = await MapLauncher.installedMaps;
                      if (availableMaps.isNotEmpty) {
                        await availableMaps.first.showMarker(
                          coords: Coords(
                            coordinates['latitude'],
                            coordinates['longitude'],
                          ),
                          title: vendor['vendor_info']['name'],
                          description: vendor['vendor_info']['address'],
                        );
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text("Aplikasi maps tidak terinstall!"),
                          ),
                        );
                      }
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("Koordinat lokasi tidak tersedia!"),
                        ),
                      );
                    }
                  },
                  icon: const Icon(Icons.map,
                    color: Colors.black,
                    ),
                  label: const Text("Buka di Maps",
                  style: TextStyle(
                    color: Colors.black
                  ),
                    ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromRGBO(195, 147, 124, 1),
                  ),
                ),
              ),
            ),
            SizedBox(height: 16),

            // Action Buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton.icon(
                  onPressed: () async {
                    ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            'Fitur Chat belum tersedia',
                            style: TextStyle(color: const Color.fromRGBO(255, 255, 255, 1)),
                          ),
                          duration: Duration(seconds: 2),
                          backgroundColor: Colors.red,
                        ),
                      );
                    // final call = 'tel:${vendor['vendor_info']['phone']}';
                    // if (call.isNotEmpty) {
                    //   final uri = Uri.parse(call);
                    //   if (await canLaunchUrl(uri)) {
                    //     launchUrl(uri);
                    //   }
                    // } else {
                    //   ScaffoldMessenger.of(context).showSnackBar(
                    //     SnackBar(
                    //       content: Text(
                    //         'Nomor tidak tersedia',
                    //         style: TextStyle(color: const Color.fromRGBO(255, 255, 255, 1)),
                    //       ),
                    //       duration: Duration(seconds: 2),
                    //       backgroundColor: Colors.red,
                    //     ),
                    //   );
                    // }
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
                    ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            'Fitur Website belum tersedia',
                            style: TextStyle(color: const Color.fromRGBO(255, 255, 255, 1)),
                          ),
                          duration: Duration(seconds: 2),
                          backgroundColor: Colors.red,
                        ),
                      );
                    // final web = vendor['vendor_info']['website'];
                    // if (web != null && web.isNotEmpty) {
                    //   final uri = Uri.parse(web);
                    //   if (await canLaunchUrl(uri)) {
                    //     launchUrl(uri);
                    //   } else {
                    //     ScaffoldMessenger.of(context).showSnackBar(
                    //       SnackBar(
                    //         content: Text(
                    //           'Tidak dapat membuka website',
                    //           style: TextStyle(color: Colors.white),
                    //         ),
                    //         duration: Duration(seconds: 2),
                    //         backgroundColor: Colors.red,
                    //       ),
                    //     );
                    //   }
                    // } else {
                    //   ScaffoldMessenger.of(context).showSnackBar(
                    //     SnackBar(
                    //       content: Text(
                    //         'Website tidak tersedia',
                    //         style: TextStyle(color: Colors.white),
                    //       ),
                    //       duration: Duration(seconds: 2),
                    //       backgroundColor: Colors.red,
                    //     ),
                    //   );
                    // }
                  },
                  icon: Icon(Icons.language, color: Colors.black),
                  label: Text(
                    "Buka Website",
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
            SizedBox(height: 20),

            // Toggle Reviews
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Ulasan",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                    ),
                  ),
                  const SizedBox(height: 8),
                  ...List.generate(
                    _visibleReviewsCount < reviews.length
                        ? _visibleReviewsCount
                        : reviews.length,
                    (index) {
                      final review = reviews[index];
                      return ListTile(
                        title: Text(review['reviewer_name'] ?? 'Anonymous',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            ),
                          ),
                        subtitle: Text(review['review_text'] ?? 'Tidak ada kalimat review'),
                        trailing: SizedBox(
                          width: 50,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              const Icon(Icons.star, color: Colors.yellow),
                              Text(
                                review['rating'].toString(),
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                  if (_visibleReviewsCount < reviews.length)
                    Center(
                      child: ElevatedButton(
                        onPressed: () {
                          setState(() {
                            _visibleReviewsCount += 10;
                          });
                        },
                        child: const Text("Muat Lebih Banyak Ulasan",
                            style: TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              const Color.fromRGBO(195, 147, 124, 1),
                        ),
                      ),
                    ),
                  if (_visibleReviewsCount >= reviews.length)
                    const Center(
                      child: Text(
                        "Tidak ada ulasan lagi",
                        style: TextStyle(color: Colors.black),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
