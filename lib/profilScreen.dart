import 'package:WeddingAPP/favoritesScreen.dart';
import 'package:WeddingAPP/loginScreen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'dart:io';

import 'auth_service.dart';

class ProfileScreen extends StatefulWidget {
  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String name = "Loading...";
  String email = "Loading...";
  DateTime dateOfBirth = DateTime.now();
  String country = "Indonesia";
  String? profileImage;
  final AuthService _authService = AuthService();
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _checkAuthAndLoadProfile();
  }

  Future<void> _checkAuthAndLoadProfile() async {
    try {
      // Periksa status login
      final isLoggedIn = await _authService.checkLoginSession();
      if (!isLoggedIn) {
        // Redirect ke login jika tidak login
        if (mounted) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => LoginScreen()),
          );
        }
        return;
      }

      // Load profile jika sudah login
      await _loadUserProfile();
    } catch (e) {
      print('Error in _checkAuthAndLoadProfile: $e');
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  Future<void> _loadUserProfile() async {
    try {
      final userData = await _authService.getCurrentUser();
      
      if (userData != null && mounted) {
        setState(() {
          name = userData['name'] ?? "No Name";
          email = userData['email'] ?? "No Email";
          dateOfBirth = DateTime.parse(userData['dateOfBirth'] ?? DateTime.now().toIso8601String());
          country = userData['country'] ?? 'Indonesia';
          if (userData['profileImage'] != null) {
            profileImage = userData['profileImage'];
          }
          isLoading = false;
        });
      } else {
        throw Exception("Failed to load user data");
      }
    } catch (e) {
      print('Error loading profile: $e');
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  void _updateProfile(Map<String, dynamic> updatedData) {
    setState(() {
      name = updatedData["name"] ?? name;
      if (updatedData["dateOfBirth"] != null) {
        if (updatedData["dateOfBirth"] is String) {
          dateOfBirth = DateTime.parse(updatedData["dateOfBirth"]);
        } 
        else if (updatedData["dateOfBirth"] is DateTime) {
          dateOfBirth = updatedData["dateOfBirth"];
        }
      }
      country = updatedData["country"] ?? country;
      if (updatedData["profileImage"] != null) {
        profileImage = updatedData["profileImage"] is File 
            ? updatedData["profileImage"] 
            : File(updatedData["profileImage"]);
      }
    });
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color.fromRGBO(234, 217, 201, 1),
        elevation: 0,
        title: Text("Profile", style: TextStyle(color: Colors.black, fontSize: 20, fontWeight: FontWeight.bold)),
        centerTitle: true,
        leading: Container(),
        actions: [
          IconButton(
            icon: Icon(Icons.edit, color: Colors.black),
            onPressed: () async {
              final updatedData = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => EditProfileScreen(
                    name: name,
                    email: email,
                    dateOfBirth: dateOfBirth,
                    country: country,
                    profileImage: profileImage,
                  ),
                ),
              );

              if (updatedData != null) {
                setState(() {
                  name = updatedData["name"];
                  dateOfBirth = updatedData["dateOfBirth"];
                  country = updatedData["country"];
                });
              } else {
                await _loadUserProfile();
              }
              if (updatedData != null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text("Profil berhasil diperbarui!"),
                    backgroundColor: Colors.green,
                  ),
                );
              }
            }
          )
        ],
      ),
      body: isLoading
      ? Center(child: CircularProgressIndicator(),)
      : SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              CircleAvatar(
                radius: 60,
                backgroundImage: profileImage != null && profileImage!.isNotEmpty
                        ? MemoryImage(base64Decode(profileImage!))
                        : AssetImage('assets/img/no_img.png') as ImageProvider,
              ),
              SizedBox(height: 20),
              Text(
                name,
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 10),
              Text(
                email,
                style: TextStyle(fontSize: 16, color: Colors.grey[600]),
              ),
              SizedBox(height: 30),
              Container(
                padding: EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 6,
                      offset: Offset(0, 2),
                    )
                  ],
                ),
                child: ListTile(
                  title: Text("Tanggal lahir", style: TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text(DateFormat('dd/MM/yyyy').format(dateOfBirth)),
                ),
              ),
              SizedBox(height: 10),
              Container(
                padding: EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 6,
                      offset: Offset(0, 2),
                    )
                  ],
                ),
                child: ListTile(
                  title: Text("Negara/Wilayah", style: TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text(country),
                ),
              ),
              SizedBox(height: 10),
              GestureDetector(
                onTap: () => Navigator.push(context, MaterialPageRoute(
                  builder: (context) => FavoritesScreen(),
                  )
                ),
                child: Container(
                  padding: EdgeInsets.symmetric(vertical: 10),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 6,
                        offset: Offset(0, 2),
                      )
                    ],
                  ),
                  child: ListTile(
                    title: Text("Vendor Favorit", style: TextStyle(fontWeight: FontWeight.bold)),
                    // subtitle: Text(country),
                  ),
                ),
              ),
              SizedBox(height: 20),
              Center(
                child: ElevatedButton(
                  onPressed: () async {
                    await _authService.logout();
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => LoginScreen()),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    padding: EdgeInsets.symmetric(
                      horizontal: 60,
                      vertical: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(
                    "Log Out",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class EditProfileScreen extends StatefulWidget {
  final String name;
  final String email;
  final DateTime dateOfBirth;
  final String country;
  final String? profileImage;

  EditProfileScreen({
    required this.name,
    required this.email,
    required this.dateOfBirth,
    required this.country,
    required this.profileImage,
  });

  @override
  _EditProfileScreenState createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  late TextEditingController nameController;
  late TextEditingController dateController;
  DateTime? selectedDateOfBirth;
  String? selectedCountry;
  String? profileImage;
  final AuthService _authService = AuthService();

  Future<void> updateUserProfile(Map<String, dynamic> updatedData) async {
    try {
      final token = await _authService.getToken();
      final userId = await _authService.getUserId();

      if (token == null || userId == null) {
        print("Token or User ID not found. Token: $token, User ID: $userId");
        throw Exception("User not logged in");
      }

      final Map<String, dynamic> bodyData = {
        if (updatedData['name'] != null) 'name': updatedData['name'],
        if (updatedData['dateOfBirth'] != null) 'dateOfBirth': updatedData['dateOfBirth'],
        if (updatedData['country'] != null) 'country': updatedData['country'],
        if (profileImage != null) 'profileImage': profileImage,
      };

      final response = await http.put(
        Uri.parse('https://api-bagas2.vercel.app/user/$userId'),
        headers: {
          'Content-Type': 'application/json',
          'x-auth-token': token,
        },
        body: json.encode(bodyData),
      );

      if (response.statusCode != 200) {
        throw Exception("Failed to update profile: ${response.body}");
      }

      // Tampilkan snackbar sukses
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Profil berhasil diperbarui!"),
          backgroundColor: Colors.green,
        ),
      );

      // Kembali ke halaman profile dengan data yang diperbarui
      Navigator.pop(context, {
        "name": updatedData["name"],
        "dateOfBirth": DateTime.parse(updatedData["dateOfBirth"]),
        "country": updatedData["country"],
        "profileImage": profileImage,
      });

    } catch (e) {
      print('Error updating profile: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal memperbarui profil: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController(text: widget.name);
    dateController = TextEditingController(
      text: DateFormat('dd/MM/yyyy').format(widget.dateOfBirth),
    );
    selectedCountry = widget.country;
    profileImage = widget.profileImage;
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: widget.dateOfBirth,
      firstDate: DateTime(1950),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        dateController.text = DateFormat('dd/MM/yyyy').format(picked);
      });
    }
  }

  Future<void> _pickImage() async {
  final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
  if (pickedFile != null) {
    File file = File(pickedFile.path);
    String? compressedBase64 = await compressImage(file);
    if (compressedBase64 != null) {
      setState(() {
        profileImage = compressedBase64;
      });
    }
  }
}

  Future<String?> compressImage(File file) async {
  try {
    final filePath = file.absolute.path;
    final lastIndex = filePath.lastIndexOf(RegExp(r'.jp'));
    if (lastIndex != -1) {
      final splitName = filePath.substring(0, lastIndex);
      final outPath = "${splitName}_compressed.jpg";
      
      final compressedImage = await FlutterImageCompress.compressWithFile(
          filePath,
          quality: 70, // Adjust quality as needed (0-100)
          format: CompressFormat.jpeg,
        );
        
        if (compressedImage != null) {
        return base64Encode(compressedImage);
      } else {
        return null;
      }
    } else {
      print("Invalid file name for compression");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Format gambar tidak mendukung, gunakan file berformat jpg'),
          backgroundColor: Colors.red,
        ),
      );
      return null;
    }
  } catch (e) {
    print('Error compressing image: $e');
    return null;
  }
}

  @override
  void dispose() {
    nameController.dispose();
    dateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromRGBO(234, 217, 201, 1),
      appBar: AppBar(
        backgroundColor: Color.fromRGBO(234, 217, 201, 1),
        elevation: 0,
        title: Text("Edit Profile", style: TextStyle(color: Colors.black, fontSize: 20, fontWeight: FontWeight.bold)),
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Stack(
                children: [
                  CircleAvatar(
                    radius: 60,
                    backgroundImage: profileImage != null && profileImage!.isNotEmpty
                        ? MemoryImage(base64Decode(profileImage!))
                        : AssetImage('assets/img/no_img.png') as ImageProvider,
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: GestureDetector(
                      onTap: _pickImage,
                      child: CircleAvatar(
                        backgroundColor: Colors.brown,
                        radius: 18,
                        child: Icon(Icons.camera_alt, color: Colors.white, size: 18),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 20),
              TextField(
                controller: nameController,
                decoration: InputDecoration(
                  labelText: "Nama",
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              SizedBox(height: 16),
              SizedBox(height: 16),
              GestureDetector(
                onTap: () => _selectDate(context),
                child: AbsorbPointer(
                  child: TextField(
                    controller: dateController,
                    decoration: InputDecoration(
                      labelText: "Tanggal lahir",
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ),
              ),
              SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: selectedCountry,
                decoration: InputDecoration(
                  labelText: "Negara/Wilayah",
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
                items: ["Indonesia", "USA", "Singapura", "Japan", "Germany", "France", "Australia"].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                onChanged: (value) {
                  setState(() {
                    selectedCountry = value;
                  });
                },
              ),
              SizedBox(height: 30),
              ElevatedButton(
                onPressed: () async {
                  try {
                    final DateTime parsedDate = DateFormat('dd/MM/yyyy').parse(dateController.text);
                    final updatedData = {
                      "name": nameController.text,
                      "dateOfBirth": parsedDate.toIso8601String(),
                      "country": selectedCountry,
                    };
                    await updateUserProfile(updatedData);

                  } catch (e) {
                    print("Error parsing date: $e");
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        backgroundColor: Colors.red,
                        content: Text('Failed to parse date: $e',
                          style: TextStyle(
                            color: Colors.white
                            ),
                          )
                      ),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.brown,
                  padding: EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: Text("Simpan",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
