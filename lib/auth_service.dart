import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;

class AuthService {
  Future<String?> registration({
    required String email,
    required String password,
  }) async {
    try {
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      return 'Success';
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        return 'Password terlalu lemah.';
      } else if (e.code == 'email-already-in-use') {
        return 'Email sudah pernah dibuat.';
      } else {
        return e.message;
      }
    } catch (e) {
      return e.toString();
    }
  }

  Future<String?> getToken() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      return await user?.getIdToken();
    } catch (e) {
      return null;
    }
  }

  final String baseUrl = 'https://api-bagas2.vercel.app/user';

  Future<String?> login({
    required String email,
    required String password,
  }) async {
    try {
      // Firebase Authentication
      UserCredential userCredential =
          await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Get Firebase Token
      String? token = await userCredential.user?.getIdToken();
      if (token == null) return 'Failed to retrieve token.';

      // Backend User Authentication
      final response = await http.post(
        Uri.parse('$baseUrl/auth'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        return 'Success';
      } else {
        print('error: ${response.body}');
        return 'Failed to authenticate with server.';
      }
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        return 'User not found.';
      } else if (e.code == 'wrong-password') {
        return 'Incorrect password.';
      } else {
        return e.message;
      }
    } catch (e) {
      return 'An error occurred. Please try again.';
    }
  }
}