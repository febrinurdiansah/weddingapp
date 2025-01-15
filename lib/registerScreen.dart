import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'auth_service.dart';
import 'main.dart';

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

  bool _isPasswordHidden = true;
  bool _isConfirmPasswordHidden = true;

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
                color: Color.fromRGBO(195, 147, 124, 1), // Warna lingkaran besar
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
                color: Color.fromRGBO(195, 147, 124, 1), // Warna lingkaran sedang
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
                color: Color.fromRGBO(195, 147, 124, 1), // Warna dot kecil
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
                        Image.asset(
                          "assets/img/logo.png",
                          width: 50,
                          height: 50,
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
                      "Register",
                      style: TextStyle(
                        fontSize: 40,
                        fontFamily: 'RozhaOne',
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    SizedBox(height: 80),
                    // Stack untuk menggabungkan CircleAvatar dan Container
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
                              _inputField("Name", "Your Name", _nametxtCtrl),
                              SizedBox(height: 16),
                              _inputField("Email", "Your email", _emailtxtCtrl),
                              SizedBox(height: 16),
                              _inputField("Phone Number", "Your phone number", _telptxtCtrl),
                              SizedBox(height: 16),
                              _passwordInputField("Password", "Your password, at least 8 character", _passtxtCtrl),
                              SizedBox(height: 16),
                              _passwordInputField("Confirm Password", "Re-type your password", _pass2txtCtrl),
                              Align(
                                alignment: Alignment.centerRight,
                                child: TextButton(
                                  onPressed: () {
                                    Navigator.pop(context);
                                  },
                                  child: Text(
                                    "Punya Akun? Login disini",
                                    style: TextStyle(color: Colors.blue),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        // CircleAvatar di atas bagian atas Container
                        Positioned(
                          top: -40,
                          left: 0,
                          right: 0,
                          child: Center(
                            child: CircleAvatar(
                              radius: 45,
                              backgroundColor: Color(0xFF6E5F5F), // Warna lingkaran foto
                              child: Icon(
                                Icons.camera_alt,
                                color: Colors.white,
                                size: 28,
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
                            final message = await AuthService().registration(
                              email: _emailtxtCtrl.text,
                              password: _passtxtCtrl.text,
                            );

                            if (message!.contains('Success')) {
                              // Ambil token ID Firebase
                              final token = await AuthService().getToken();

                              // Kirim data ke backend
                              final response = await http.post(
                                Uri.parse('https://api-bagas2.vercel.app/user/register'),
                                headers: {
                                  'Authorization': 'Bearer $token',
                                  'Content-Type': 'application/json',
                                },
                                body: jsonEncode({
                                  'name': _nametxtCtrl.text,
                                  'email': _emailtxtCtrl.text,
                                  'phone': _telptxtCtrl.text,
                                }),
                              );

                              print('Response status: ${response.statusCode}');
                              print('Response body: ${response.body}');

                              if (response.statusCode == 201) {
                              // Uraikan JSON respons
                              final responseData = jsonDecode(response.body);

                              print('Message: ${responseData['message']}');
                              print('User data: ${responseData['user']}');
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (context) => NavPage()),
                                );
                              } else {
                                print('Error: ${response.body}');
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    backgroundColor: Colors.red,
                                    content: Text(
                                      "Gagal menyimpan data pengguna: ${response.body}",
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
                                    message,
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
                          print("Register error : $e");
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              backgroundColor: Colors.red,
                              content: Text(
                                "Regristrasi error, tolong ulangi lagi nanti.",
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
                        "Register",
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

  // Fungsi untuk TextField biasa
  Widget _inputField(String label, String hintText, TextEditingController txtController) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          SizedBox(height: 8),
          TextFormField(
            controller: txtController,
            decoration: InputDecoration(
              hintText: hintText,
              contentPadding: EdgeInsets.symmetric(vertical: 12),
            ),
          ),
        ],
      ),
    );
  }

  // Fungsi untuk TextField password
  Widget _passwordInputField(String label, String hintText, TextEditingController txtController) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          SizedBox(height: 8),
          TextFormField(
            controller: txtController,
            obscureText: label == "Password" ? _isPasswordHidden : _isConfirmPasswordHidden,
            decoration: InputDecoration(
              hintText: hintText,
              contentPadding: EdgeInsets.symmetric(vertical: 12),
              suffixIcon: IconButton(
                icon: Icon(
                  label == "Password"
                      ? (_isPasswordHidden ? Icons.visibility_off : Icons.visibility)
                      : (_isConfirmPasswordHidden ? Icons.visibility_off : Icons.visibility),
                  color: Colors.grey,
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
