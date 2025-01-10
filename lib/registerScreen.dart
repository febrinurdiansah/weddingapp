import 'package:flutter/material.dart';

class RegisterScreen extends StatelessWidget {
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
                              _inputField("Name", "Your Name"),
                              SizedBox(height: 16),
                              _inputField("Email", "Your email"),
                              SizedBox(height: 16),
                              _inputField("Phone Number", "Your phone number"),
                              SizedBox(height: 16),
                              _inputField("Password", "Your password, at least 8 character", obscureText: true),
                              SizedBox(height: 16),
                              _inputField("Confirm Password", "Re-type your password", obscureText: true),
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
                      onPressed: () {
                        // Tambahkan aksi registrasi
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

  Widget _inputField(String label, String hintText, {bool obscureText = false}) {
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
            obscureText: obscureText,
            decoration: InputDecoration(
              hintText: hintText,
              contentPadding: EdgeInsets.symmetric( vertical: 12),
              suffixIcon: obscureText
                  ? Icon(Icons.visibility, color: Colors.grey)
                  : null,
            ),
          ),
        ],
      ),
    );
  }
}
