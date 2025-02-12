import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'auth_service.dart';

class RegisterScreen extends StatefulWidget {
  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController _nametxtCtrl = TextEditingController();
  final TextEditingController _emailtxtCtrl = TextEditingController();
  final TextEditingController _passtxtCtrl = TextEditingController();
  final TextEditingController _pass2txtCtrl = TextEditingController();
  final TextEditingController _telptxtCtrl = TextEditingController();
  final TextEditingController _birthDateTxtCtrl = TextEditingController();

  String? _selectedCountry;
  File? _profileImage;
  bool _isPasswordHidden = true;
  bool _isConfirmPasswordHidden = true;

  final List<String> _countries = [
    "Indonesia",
    "USA",
    "Singapura",
    "Japan",
    "Germany",
    "France",
    "Australia",
  ];

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _profileImage = File(pickedFile.path);
      });
    }
  }

  void _togglePasswordVisibility() {
    setState(() {
      _isPasswordHidden = !_isPasswordHidden;
    });
  }

  void _toggleConfirmPasswordVisibility() {
    setState(() {
      _isConfirmPasswordHidden = !_isConfirmPasswordHidden;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromRGBO(234, 217, 201, 1),
      body: Stack(
        children: [
          // Background Lingkaran dan Dot
          Positioned(
            top: -80,
            right: -50,
            child: Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                color: Color.fromRGBO(195, 147, 124, 1),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Positioned(
            top: 200,
            left: 50,
            child: Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: Color.fromRGBO(195, 147, 124, 1),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Positioned(
            top: 180,
            left: 10,
            child: Container(
              width: 15,
              height: 15,
              decoration: BoxDecoration(
                color: Color.fromRGBO(195, 147, 124, 1),
                shape: BoxShape.circle,
              ),
            ),
          ),
          // Konten Utama
          SafeArea(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Logo dan Judul
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(15),
                          child: Image.asset(
                            "assets/img/logo.png",
                            width: 50,
                            height: 50,
                          ),
                        ),
                        SizedBox(width: 8),
                        Text(
                          "PAWIWAHAN",
                          style: TextStyle(
                            fontSize: 24,
                            fontFamily: "Rufina",
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 50),
                    Text(
                      "Daftar",
                      style: TextStyle(
                        fontSize: 40,
                        fontFamily: 'RozhaOne',
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    SizedBox(height: 80),
                    // Stack untuk CircleAvatar dan Container
                    Stack(
                      clipBehavior: Clip.none,
                      children: [
                        Container(
                          padding: EdgeInsets.only(
                            top: 60,
                            left: 16,
                            right: 16,
                            bottom: 30,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 6,
                                offset: Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _inputField("Nama", "Nama Anda", _nametxtCtrl),
                              SizedBox(height: 16),
                              _inputField("Email", "Email Anda", _emailtxtCtrl),
                              SizedBox(height: 16),
                              _inputField("Nomor telepon", "Nomor telepon Anda", _telptxtCtrl),
                              SizedBox(height: 16),
                              _countryDropdown(),
                              SizedBox(height: 16),
                              Padding(
                                padding: EdgeInsets.symmetric(horizontal: 16),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    Text(
                                      "Pilih tanggal lahir",
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black,
                                      ),
                                    ),
                                    SizedBox(height: 8),
                                    GestureDetector(
                                      onTap: () async {
                                        DateTime? pickedDate = await showDatePicker(
                                          context: context,
                                          initialDate: DateTime.now(),
                                          firstDate: DateTime(1900),
                                          lastDate: DateTime.now(),
                                        );
                                        if (pickedDate != null) {
                                          _birthDateTxtCtrl.text = DateFormat('yyyy-MM-dd').format(pickedDate);
                                        }
                                      },
                                      child: AbsorbPointer(
                                        child: TextFormField(
                                          controller: _birthDateTxtCtrl,
                                          decoration: InputDecoration(
                                            labelText: "Tanggal lahir",
                                            hintText: "Pilih tanggal lahir Anda",
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(height: 16),
                              _passwordInputField("Kata sandi", "Kata sandi Anda, minimal 6 karakter", _passtxtCtrl),
                              SizedBox(height: 16),
                              _passwordInputField("Konfirmasi Kata Sandi", "Ketik ulang kata sandi Anda", _pass2txtCtrl),
                              SizedBox(height: 13),
                              Align(
                                alignment: Alignment.centerRight,
                                child: TextButton(
                                  onPressed: () {
                                    Navigator.pop(context);
                                  },
                                  child: Text(
                                    "Sudah punya akun? Login di sini",
                                    style: TextStyle(color: Colors.blue),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Positioned(
                          top: -40,
                          left: 0,
                          right: 0,
                          child: Center(
                            child: GestureDetector(
                              onTap: _pickImage,
                              child: CircleAvatar(
                                radius: 45,
                                backgroundColor: Color(0xFF6E5F5F),
                                backgroundImage: _profileImage != null
                                    ? FileImage(_profileImage!)
                                    : null,
                                child: _profileImage == null
                                    ? Icon(
                                        Icons.camera_alt,
                                        color: Colors.white,
                                        size: 28,
                                      )
                                    : null,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 30),
                    ElevatedButton(
                      onPressed: () async {
                        try {
                          if (_passtxtCtrl.text == _pass2txtCtrl.text) {
                            // Pastikan country tidak null
                            if (_selectedCountry == null) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Silakan pilih negara')),
                              );
                              return;
                            }

                            final result = await AuthService().registration(
                              email: _emailtxtCtrl.text,
                              password: _passtxtCtrl.text,
                              name: _nametxtCtrl.text,
                              phone: _telptxtCtrl.text,
                              country: _selectedCountry!,
                              dateOfBirth: DateTime.parse(_birthDateTxtCtrl.text),
                              profileImage: _profileImage,
                            );

                            if (result['status'] == 'Success') {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  backgroundColor: Colors.green,
                                  content: Text(
                                    'Akun berhasil dibuat',
                                    style: TextStyle(color: Colors.white),
                                  ),
                                ),
                              );
                              Navigator.pop(context);
                              // Navigator.pushReplacement(
                              //   context,
                              //   MaterialPageRoute(builder: (context) => LoginScreen()),
                              // );
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  backgroundColor: Colors.red,
                                  content: Text(
                                    result['message'],
                                    style: TextStyle(color: Colors.white),
                                  ),
                                ),
                              );
                            }
                          } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  backgroundColor: Colors.red,
                                  content: Text(
                                    "Passwords tidak sama, tolong ulangi lagi.",
                                    style: TextStyle(color: Colors.white),
                                  ),
                                ),
                              );
                            }
                          } catch (e) {
                            print("Register error: $e");
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                backgroundColor: Colors.red,
                                content: Text(
                                  "Daftar error, tolong ulangi lagi nanti.",
                                  style: TextStyle(color: Colors.white),
                                ),
                              ),
                            );
                          }
                        },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color.fromRGBO(195, 147, 124, 1),
                        padding: EdgeInsets.symmetric(horizontal: 40, vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Text(
                        "Daftar",
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _inputField(String label, String hintText, TextEditingController txtController) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black)),
          SizedBox(height: 8),
          TextFormField(controller: txtController, decoration: InputDecoration(hintText: hintText)),
        ],
      ),
    );
  }

  Widget _countryDropdown() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Negara/Wilayah",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          SizedBox(height: 8),
          DropdownButtonFormField<String>(
            value: _selectedCountry,
            items: _countries.map((country) {
              return DropdownMenuItem(
                value: country,
                child: Text(country),
              );
            }).toList(),
            onChanged: (value) {
              setState(() {
                _selectedCountry = value;
              });
            },
            decoration: InputDecoration(
              contentPadding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _passwordInputField(String label, String hintText, TextEditingController txtController) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black)),
          SizedBox(height: 8),
          TextFormField(
            controller: txtController,
            obscureText: label == "Password" ? _isPasswordHidden : _isConfirmPasswordHidden,
            decoration: InputDecoration(
              hintText: hintText,
              suffixIcon: IconButton(
                icon: Icon(
                  label == "Password" ? (_isPasswordHidden ? Icons.visibility_off : Icons.visibility) : (_isConfirmPasswordHidden ? Icons.visibility_off : Icons.visibility),
                ),
                onPressed: label == "Password" ? _togglePasswordVisibility : _toggleConfirmPasswordVisibility,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
