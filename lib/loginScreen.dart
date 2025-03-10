import 'package:WeddingAPP/registerScreen.dart';
import 'package:flutter/material.dart';

import 'auth_service.dart';
import 'main.dart';

class LoginScreen extends StatefulWidget {
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {

  final TextEditingController _emailtxtCtrl = TextEditingController();
    final TextEditingController _passtxtCtrl = TextEditingController();

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
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Selamat Datang di",
                          style: TextStyle(
                            fontSize: 22,
                            color: Colors.black,
                          ),
                        ),
                        Text(
                          "PAWIWAHAN",
                          style: TextStyle(
                            fontSize: 25,
                            fontFamily: "Rufina",
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                      ],
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.push(context, MaterialPageRoute(
                          builder: (context) => RegisterScreen(),
                          )
                        );
                      },
                      child: Text(
                        "Belum punya akun? \nDaftar",
                        style: TextStyle(
                          color: Colors.blue,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 40),
                Center(
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 40),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 10,
                          offset: Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 16),
                          child: Text(
                            "Masuk",
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                        ),
                        SizedBox(height: 16),
                        _inputField("Masukkan email anda", "Email", _emailtxtCtrl),
                        SizedBox(height: 16),
                        _passwordInputField("Masukkan Kata sandi anda", "Kata sandi", _passtxtCtrl),
                        SizedBox(height: 8),
                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton(
                            onPressed: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  backgroundColor: Colors.red,
                                  content: Text(
                                    'Fungsi Lupa Kata sandi belum dibuat',
                                    style: TextStyle(color: Colors.white),
                                  ),
                                ),
                              );
                            },
                            child: Text(
                              "Lupa Kata sandi",
                              style: TextStyle(color: Colors.grey),
                            ),
                          ),
                        ),
                        SizedBox(height: 16),
                        Center(
                          child: ElevatedButton(
                            onPressed: () async {
                              try {
                                final result = await AuthService().login(
                                  email: _emailtxtCtrl.text,
                                  password: _passtxtCtrl.text,
                                );
                                if (result['status'] == 'Success') {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      backgroundColor: Colors.green,
                                      content: Text(
                                        'Berhasil Login',
                                        style: TextStyle(color: Colors.white),
                                      ),
                                    ),
                                  );
                                  Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(builder: (context) => NavPage()),
                                  );
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
                              } catch (e) {
                                print("Login error: $e");
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Color.fromRGBO(195, 147, 124, 1),
                              padding: EdgeInsets.symmetric(
                                horizontal: 60,
                                vertical: 12,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: Text(
                              "Masuk",
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
                SizedBox(height: 40),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(15),
                      child: Image.asset(
                        "assets/img/logo.png",
                        width: 50,
                        height: 50,
                        fit: BoxFit.cover,
                      ),
                    ),
                    SizedBox(width: 8),
                    Text(
                      "PAWIWAHAN",
                      style: TextStyle(
                        fontSize: 18,
                        fontFamily: "Rufina",
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

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
