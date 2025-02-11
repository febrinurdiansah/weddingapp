import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:custom_rating_bar/custom_rating_bar.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:map_launcher/map_launcher.dart';
import 'auth_service.dart';
import 'package:appinio_social_share/appinio_social_share.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class VendorDetailScreen extends StatefulWidget {
  final dynamic vendor;

  VendorDetailScreen({Key? key, this.vendor}) : super(key: key);

  @override
  State<VendorDetailScreen> createState() => _VendorDetailScreenState();
}

class _VendorDetailScreenState extends State<VendorDetailScreen> {
  final AuthService _authService = AuthService();
  final AppinioSocialShare _appinioSocialShare = AppinioSocialShare();
  final TextEditingController _reviewController = TextEditingController();
  double _userRating = 0;
  bool isFavorite = false;
  String? _currentUserId;
   // Review state variables
  List<dynamic> reviews = [];
  int currentPage = 1;
  int totalPages = 1;
  bool hasNextPage = false;
  bool isLoadingMore = false;
  double averageRating = 0;
  int totalReviews = 0;
  final ScrollController _scrollController = ScrollController();

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
    _checkIfFavorite();
    _getCurrentUser();
    _loadReviews();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.vendor != null) {
        saveToHistory(widget.vendor);
      }
    });
  }

  Future<void> _checkIfFavorite() async {
    try {
      final token = await _authService.getToken();
      final userId = await _authService.getUserId();

      if (token == null || userId == null) return;

      final response = await http.get(
        Uri.parse('https://api-bagas2.vercel.app/user/$userId/favorites'),
        headers: {'x-auth-token': token},
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        final List<dynamic> favoriteVendors = responseData['favorites'] ?? [];

        setState(() {
          isFavorite = favoriteVendors.contains(widget.vendor['place_id']);
        });
      }
    } catch (e) {
      print('Error checking favorite status: $e');
    }
  }

  // Fungsi untuk menambah/menghapus vendor dari favorit
  Future<void> toggleFavorite() async {
    try {
      final token = await _authService.getToken();
      final userId = await _authService.getUserId();

      if (token == null || userId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Harap login terlebih dahulu')),
        );
        return;
      }

      final apiUrl = isFavorite
          ? 'https://api-bagas2.vercel.app/user/$userId/favorites/${widget.vendor['place_id']}'
          : 'https://api-bagas2.vercel.app/user/$userId/favorites';

      final response = isFavorite
          ? await http.delete(Uri.parse(apiUrl), headers: {'x-auth-token': token})
          : await http.post(
              Uri.parse(apiUrl),
              headers: {
                'Content-Type': 'application/json',
                'x-auth-token': token,
              },
              body: json.encode({'vendorId': widget.vendor['place_id']}),
            );

      if (response.statusCode == 200) {
        setState(() {
          isFavorite = !isFavorite; 
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: isFavorite 
                ? Colors.green
                : Colors.red,
            content: Text(isFavorite
                ? 'Ditambahkan ke Favorit!'
                : 'Dihapus dari Favorit!'),
          ),
        );
      } else {
        throw Exception('Gagal memperbarui favorit');
      }
    } catch (e) {
      print('Error updating favorite: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.red,
          content: Text('Terjadi kesalahan! Coba lagi nanti.')),
      );
    }
  }

  Future<void> _getCurrentUser() async {
    final userId = await _authService.getUserId();
    setState(() {
      _currentUserId = userId;
    });
  }

  Future<void> _loadReviews({bool loadMore = false}) async {
    if (isLoadingMore) return;
    setState(() {
      isLoadingMore = true;
    });

    try {
      final pageToLoad = loadMore ? currentPage + 1 : 1;
      final response = await http.get(
        Uri.parse(
          'https://api-bagas2.vercel.app/review/vendor/${widget.vendor['place_id']}?page=$pageToLoad&limit=10'
        ),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<dynamic> receivedReviews = data['reviews'] ?? [];
        
        setState(() {
          if (loadMore) {
            reviews.addAll(receivedReviews);
          } else {
            reviews = receivedReviews;
          }
          
          totalReviews = data['total_reviews'] ?? 0;
          averageRating = (data['average_rating'] ?? 0).toDouble();
          totalPages = data['pagination']['total_pages'] ?? 1;
          hasNextPage = data['pagination']['has_next'] ?? false;
          currentPage = pageToLoad;
          isLoadingMore = false;
        });
      } else {
        print('Error loading reviews: ${response.statusCode}');
        print('Error response: ${response.body}');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal memuat ulasan')),
        );
      }
    } catch (e) {
      print('Error loading reviews: $e');
      setState(() {
        isLoadingMore = false;
      });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Terjadi kesalahan saat memuat ulasan')),
        );
    }
}

  // Add Review
  Future<void> _addReview() async {
    try {
      final token = await _authService.getToken();
      if (token == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Harap login terlebih dahulu')),
        );
        return;
      }

      final response = await http.post(
        Uri.parse('https://api-bagas2.vercel.app/review/vendor/${widget.vendor['place_id']}'),
        headers: {
          'Content-Type': 'application/json',
          'x-auth-token': token,
        },
        body: json.encode({
          'rating': _userRating,
          'review_text': _reviewController.text,
        }),
      );

      if (response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Ulasan berhasil ditambahkan')),
        );
        _reviewController.clear();
        setState(() {
          _userRating = 0;
        });
        _loadReviews();
      } else {
        final error = json.decode(response.body);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(error['error'] ?? 'Gagal menambahkan ulasan')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Terjadi kesalahan')),
      );
    }
  }

  // Edit Review
  Future<void> _editReview(String reviewId, String currentText, double currentRating) async {
    TextEditingController reviewController = TextEditingController(text: currentText);
    double editedRating = currentRating;

    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Edit Ulasan"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: reviewController,
                decoration: InputDecoration(labelText: "Ulasan Anda"),
              ),
              SizedBox(height: 10),
              Text("Pilih Rating"),
              SizedBox(height: 10),
              RatingBar(
                initialRating: editedRating,
                filledIcon: Icons.star,
                emptyIcon: Icons.star_border,
                onRatingChanged: (rating) {
                  editedRating = rating;
                },
                maxRating: 5,
                filledColor: Colors.yellow,
                size: 24,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("Batal"),
            ),
            TextButton(
              onPressed: () async {
                await _updateReview(reviewId, reviewController.text, editedRating);
                Navigator.pop(context);
              },
              child: Text("Simpan"),
            ),
          ],
        );
      },
    );
  }

  Future<void> _updateReview(String reviewId, String newText, double newRating) async {
    try {
      final token = await _authService.getToken();
      if (token == null) {
        throw Exception("User not logged in");
      }

      final response = await http.put(
        Uri.parse('https://api-bagas2.vercel.app/review/$reviewId'),
        headers: {
          'Content-Type': 'application/json',
          'x-auth-token': token,
        },
        body: jsonEncode({
          "review_text": newText,
          "rating": newRating,
        }),
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Ulasan berhasil diperbarui!"), backgroundColor: Colors.green),
        );

        await _loadReviews();
      } else {
        throw Exception("Gagal memperbarui ulasan: ${response.body}");
      }
    } catch (e) {
      print("Error updating review: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Gagal memperbarui ulasan"), backgroundColor: Colors.red),
      );
    }
  }


  // Delete Review
  Future<void> _deleteReview(String reviewId) async {
    bool confirmDelete = await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Hapus Ulasan"),
          content: Text("Apakah Anda yakin ingin menghapus ulasan ini?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text("Batal"),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: Text("Hapus", style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );

    if (!confirmDelete) return;

    try {
      final token = await _authService.getToken();
      if (token == null) {
        throw Exception("User not logged in");
      }

      final response = await http.delete(
        Uri.parse('https://api-bagas2.vercel.app/review/$reviewId'),
        headers: {
          'x-auth-token': token,
        },
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Ulasan berhasil dihapus!"), backgroundColor: Colors.green),
        );

        await _loadReviews(); // Refresh ulasan
      } else {
        throw Exception("Gagal menghapus ulasan: ${response.body}");
      }
    } catch (e) {
      print("Error deleting review: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Gagal menghapus ulasan"), backgroundColor: Colors.red),
      );
    }
  }


  // Review Form Widget
  Widget _buildReviewForm() {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Tambah Ulasan',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),
            RatingBar(
              initialRating: _userRating,
              filledIcon: Icons.star,
              emptyIcon: Icons.star_border,
              onRatingChanged: (rating) {
                setState(() {
                  _userRating = rating;
                });
              },
              maxRating: 5,
              filledColor: Colors.yellow,
              size: 24,
            ),
            SizedBox(height: 8),
            TextField(
              controller: _reviewController,
              decoration: InputDecoration(
                hintText: 'Tulis ulasan Anda...',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
            SizedBox(height: 8),
            ElevatedButton(
              onPressed: _userRating > 0 && _reviewController.text.isNotEmpty
                  ? _addReview
                  : null,
              child: Text(
                'Kirim Ulasan',
                style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Color.fromRGBO(195, 147, 124, 1),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Review List Item
  Widget _buildReviewItem(dynamic review) {
    final bool isUserReview =
        review['source'] == 'app' &&
        review['user_id'] != null &&
        review['user_id'].toString() == _currentUserId;

    return Card(
      margin: EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      child: ListTile(
        title: Row(
          children: [
            Text(
              review['reviewer_name'].length > 20
                  ? review['reviewer_name'].substring(0, 20) + '...'
                  : review['reviewer_name'],
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(width: 8),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: review['source'] == 'app' ? Colors.brown[200] : Colors.blue[100],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                review['source'] == 'app' ? 'App' : 'Google Maps',
                style: TextStyle(fontSize: 12),
              ),
            ),
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 4),
            Text(review['review_text'] ?? 'Tidak ada kalimat review'),
            SizedBox(height: 4),
            Row(
              children: [
                Row(
                  children: List.generate(
                    5,
                    (index) => Icon(
                      index < (review['rating'] ?? 0) ? Icons.star : Icons.star_border,
                      color: Colors.yellow[700],
                      size: 16,
                    ),
                  ),
                ),
                if (isUserReview) ...[
                  Spacer(),
                  IconButton(
                    icon: Icon(Icons.edit, size: 20),
                    onPressed: () => _editReview(
                      review['id'].toString(),
                      review['review_text'] ?? '',
                      (review['rating'] ?? 0).toDouble(),
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.delete, size: 20, color: Colors.red),
                    onPressed: () => _deleteReview(review['id'].toString()),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
  
  Future<void> _shareVendor() async {
    try {
      // Prepare share content
      final vendorName = widget.vendor['vendor_info']['name'] ?? "Nama Vendor tidak tersedia";
      final vendorAddress = widget.vendor['vendor_info']['address'] ?? "Alamat tidak tersedia";
      final vendorLink = widget.vendor['vendor_info']['maps_link'] ?? "Link maps tidak tersedia";
      final vendorRating = widget.vendor['vendor_info']['rating']?.toString() ?? "0.0";
      
      // Create share message
      final shareMessage = """
      Temukan vendor wedding ini di aplikasi kami!

      $vendorName
      Rating: $vendorRating ⭐
      Lokasi: $vendorAddress
      maps: $vendorLink

      Download aplikasi kami untuk informasi lebih lanjut!
      """;

      // Get installed apps for sharing
      final installedApps = await _appinioSocialShare.getInstalledApps();
      
      // Show bottom sheet with share options
      showModalBottomSheet(
        context: context,
        builder: (BuildContext context) {
          return Container(
            padding: EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Bagikan ke',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    if (installedApps["whatsapp"] ?? false)
                      _buildShareButton(
                        icon: FontAwesomeIcons.whatsapp,
                        label: 'WhatsApp',
                        onTap: () async {
                          Navigator.pop(context);
                          await _appinioSocialShare.android.shareToWhatsapp(shareMessage,null);
                        },
                      ),
                    if (installedApps["telegram"] ?? false)
                      _buildShareButton(
                        icon: FontAwesomeIcons.telegram,
                        label: 'Telegram',
                        onTap: () async {
                          Navigator.pop(context);
                          await _appinioSocialShare.android.shareToTelegram(shareMessage,null);
                        },
                      ),
                    _buildShareButton(
                      icon: FontAwesomeIcons.share,
                      label: 'Lainnya',
                      onTap: () async {
                        Navigator.pop(context);
                        await _appinioSocialShare.android.shareToSystem(
                          "Bagikan Vendor", 
                          shareMessage, 
                          null);
                      },
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      );
    } catch (e) {
      print('Error sharing: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal membagikan konten'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Widget _buildShareButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Color.fromRGBO(195, 147, 124, 1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: Colors.black,
              size: 30,
            ),
          ),
          SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.black,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final vendor = widget.vendor;
    final reviews = this.reviews;

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
            icon: Icon(
              isFavorite ? Icons.favorite : Icons.favorite_border,
              color: isFavorite ? Colors.red : Colors.black,
            ),
            onPressed: toggleFavorite,
          ),
          IconButton(
            icon: Icon(Icons.share, color: Colors.black),
            onPressed: _shareVendor,
          ),
        ],
      ),
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
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
              // Form Review
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Ulasan ($totalReviews)",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 20,
                            ),
                          ),
                          Row(
                            children: [
                              Icon(Icons.star, color: Colors.yellow[700]),
                              Text(
                                " ${averageRating.toStringAsFixed(1)}",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    if (_currentUserId != null) _buildReviewForm(),
                    if (reviews.isEmpty)
                      Center(
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Text(
                            "Belum ada ulasan",
                            style: TextStyle(
                              fontSize: 16,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
        SliverList( // Daftar ulasan yang dinamis
          delegate: SliverChildBuilderDelegate(
            (BuildContext context, int index) {
              if (index < reviews.length) {
                return _buildReviewItem(reviews[index]);
              } else if (hasNextPage) {
                _loadReviews(loadMore: true); 
                return Center(
                  child: CircularProgressIndicator(),
                );
              } else {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(
                      "Belum ada ulasan",
                      style: TextStyle(
                        fontSize: 16,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),
                );
              }
            },
            childCount: reviews.length + (hasNextPage ? 1 : 0), 
          ),
        ),
        ]
      ),
    );
  }
}


// Review Dialog for editing
class ReviewDialog extends StatefulWidget {
  final double initialRating;
  final String initialText;

  ReviewDialog({
    required this.initialRating,
    required this.initialText,
  });

  @override
  _ReviewDialogState createState() => _ReviewDialogState();
}

class _ReviewDialogState extends State<ReviewDialog> {
  late double _rating;
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _rating = widget.initialRating;
    _controller = TextEditingController(text: widget.initialText);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Edit Ulasan'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          RatingBar(
            initialRating: _rating,
            filledIcon: Icons.star,
            emptyIcon: Icons.star_border,
            onRatingChanged: (rating) {
              setState(() {
                _rating = rating;
              });
            },
            maxRating: 5,
            filledColor: Colors.yellow,
            size: 24,
          ),
          SizedBox(height: 8),
          TextField(
            controller: _controller,
            decoration: InputDecoration(
              hintText: 'Tulis ulasan Anda...',
              border: OutlineInputBorder(),
            ),
            maxLines: 3,
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text('Batal'),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context, {
            'rating': _rating,
            'text': _controller.text,
          }),
          child: Text('Simpan'),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}