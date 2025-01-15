import 'package:WeddingAPP/loginScreen.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:io';

class ProfileScreen extends StatefulWidget {
  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String name = "Loading...";
  String email = "Loading...";
  DateTime dateOfBirth = DateTime.now();
  String country = "Loading...";
  File? profileImage;

Future<Map<String, dynamic>> fetchUserProfile() async {
  final user = FirebaseAuth.instance.currentUser;
  if (user == null) {
    throw Exception("User not logged in");
  }

  final response = await http.get(
    Uri.parse('https://api-bagas2.vercel.app/user/${user.uid}'),
  );

  if (response.statusCode == 200) {
    return json.decode(response.body);
  } else {
    throw Exception("Failed to load user profile");
  }
}

@override
void initState() {
  super.initState();
  _loadUserData();
}

void _loadUserData() async {
  try {
    final userData = await fetchUserProfile();
    setState(() {
      name = userData['name'];
      email = userData['email'];
      dateOfBirth = DateTime.parse(userData['dateOfBirth']);
      country = userData['country'];
      profileImage = userData['profileImage'] != null ? File(userData['profileImage']) : null;
    });
  } catch (e) {
    print("Error loading user data: $e");
  }
}

  void _updateProfile(Map<String, dynamic> updatedData) {
    setState(() {
      name = updatedData["name"] ?? name;
      dateOfBirth = updatedData["dateOfBirth"] ?? dateOfBirth;
      country = updatedData["country"] ?? country;
      profileImage = updatedData["profileImage"] ?? profileImage;
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
        actions: [
          IconButton(
            icon: Icon(Icons.edit, color: Colors.black),
            onPressed: () async {
              final updatedData = await Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => EditProfileScreen(name: name, email: email, dateOfBirth: dateOfBirth, country: country, profileImage: profileImage)),
              );
              if (updatedData != null) {
                _updateProfile(updatedData);
              }
            },
          )
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              CircleAvatar(
                radius: 60,
                backgroundImage: profileImage != null
                    ? FileImage(profileImage!)
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
                  title: Text("Date of Birth", style: TextStyle(fontWeight: FontWeight.bold)),
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
                  title: Text("Country/Region", style: TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text(country),
                ),
              ),
              SizedBox(height: 20),
              Center(
                child: ElevatedButton(
                  onPressed: ()  => Navigator.push(context, MaterialPageRoute(
                    builder: (context) => LoginScreen(),
                    )
                  ),
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
  final File? profileImage;

  EditProfileScreen({
    required this.name,
    required this.email,
    required this.dateOfBirth,
    required this.country,
    this.profileImage,
  });

  @override
  _EditProfileScreenState createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  late TextEditingController nameController;
  late TextEditingController dateController;
  DateTime? selectedDateOfBirth;
  String? selectedCountry;
  File? profileImage;

  Future<void> updateUserProfile(Map<String, dynamic> updatedData) async {
  final user = FirebaseAuth.instance.currentUser;
  if (user == null) {
    throw Exception("User not logged in");
  }

  final response = await http.put(
    Uri.parse('https://api-bagas2.vercel.app/user/${user.uid}'),
    headers: {'Content-Type': 'application/json'},
    body: json.encode(updatedData),
  );

  if (response.statusCode != 200) {
    throw Exception("Failed to update user profile");
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
      setState(() {
        profileImage = File(pickedFile.path);
      });
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
                    backgroundImage: profileImage != null
                        ? FileImage(profileImage!)
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
                  labelText: "Name",
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
                      labelText: "Date of Birth",
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ),
              ),
              SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: selectedCountry,
                decoration: InputDecoration(
                  labelText: "Country/Region",
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
                  final updatedData = {
                    "name": nameController.text,
                    "dateOfBirth": DateFormat('dd/MM/yyyy').parse(dateController.text).toIso8601String(),
                    "country": selectedCountry,
                    "profileImage": profileImage?.path,
                  };

                  try {
                    await updateUserProfile(updatedData);
                    Navigator.pop(context, updatedData);
                  } catch (e) {
                    print("Error updating user profile: $e");
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.brown,
                  padding: EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: Text("Save changes",
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
