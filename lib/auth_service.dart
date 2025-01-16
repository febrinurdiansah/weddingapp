import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';

class AuthService {
  final String baseUrl = 'https://api-bagas2.vercel.app/user';
  
  // Tambahkan variabel untuk menyimpan userId
  static String? userId;

  Future<String?> _compressAndConvertImage(File image) async {
    // Compress image
    final result = await FlutterImageCompress.compressWithFile(
      image.absolute.path,
      quality: 70, // Adjust quality as needed (0-100)
      minWidth: 500,
      minHeight: 500,
    );
    
    if (result != null) {
      // Convert to base64
      return base64Encode(result);
    }
    return null;
  }

  // Update fungsi registration
  Future<Map<String, dynamic>> registration({
    required String email,
    required String password,
    required String name,
    required String phone,
    required String country,
    File? profileImage,
  }) async {
    try {
      Map<String, dynamic> body = {
        'email': email,
        'password': password,
        'name': name,
        'phone': phone,
        'country': country,
      };

      if (profileImage != null) {
        final compressedImage = await _compressAndConvertImage(profileImage);
        if (compressedImage != null) {
          body['profileImage'] = compressedImage;
        }
      }

      final response = await http.post(
        Uri.parse('$baseUrl/register'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode(body),
      );

      // Menangani response
      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseData = jsonDecode(response.body);
        return {
          'status': 'Success',
          'message': 'Registration successful',
          'data': responseData
        };
      } else {
        return {
          'status': 'Error',
          'message': 'Registration failed: ${response.body}',
        };
      }
    } catch (e) {
      return {
        'status': 'Error',
        'message': 'An error occurred: $e',
      };
    }
  }

  Future<bool> checkLoginSession() async {
    final prefs = await SharedPreferences.getInstance();
    final isLoggedIn = prefs.getBool('is_logged_in') ?? false;
    final token = prefs.getString('auth_token');
    final userId = prefs.getString('user_id');
    return isLoggedIn && token != null && userId != null;
  }

  Future<Map<String, dynamic>> getUserProfile() async {
    try {
      final token = await getToken();
      final userId = await getUserId();
      
      if (token == null || userId == null) {
        return {
          'status': 'Error',
          'message': 'User not logged in',
        };
      }

      final response = await http.get(
        Uri.parse('$baseUrl/user/$userId'),
        headers: {
          'x-auth-token': token,
        },
      );

      if (response.statusCode == 200) {
        return {
          'status': 'Success',
          'data': jsonDecode(response.body),
        };
      } else {
        return {
          'status': 'Error',
          'message': 'Failed to get user profile',
        };
      }
    } catch (e) {
      return {
        'status': 'Error',
        'message': 'An error occurred: $e',
      };
    }
  }

  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/login'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'email': email,
          'password': password,
        }),
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        final token = responseData['token'];
        final userId = responseData['user']['_id'];
        await saveLoginSession(token, userId);

        return {
          'status': 'Success',
          'token': token,
          'userId': userId,
          'user': responseData['user'],
        };
      } else {
        print('Login failed with status: ${response.statusCode}');
        print('Response body: ${response.body}');
        return {
          'status': 'Error',
          'message': 'Login failed: ${response.body}',
        };
      }
    } catch (e) {
      print('Login error: $e');
      return {
        'status': 'Error',
        'message': 'An error occurred: $e',
      };
    }
  }

  Future<void> saveLoginSession(String token, String userId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('auth_token', token);
      await prefs.setString('user_id', userId);
      await prefs.setBool('is_logged_in', true);
      print('Session saved - Token: $token, UserId: $userId');
    } catch (e) {
      print('Error saving session: $e');
      throw e;
    }
  }

  Future<Map<String, dynamic>?> getCurrentUser() async {
    try {
      final token = await getToken();
      final userId = await getUserId();
      print('Current token: $token');
      print('Current userId: $userId');
      if (token == null || userId == null) {
        print('No token or userId found');
        return null;
      }

      final response = await http.get(
        Uri.parse('$baseUrl/$userId'),
        headers: {
          'Content-Type': 'application/json',
          'x-auth-token': token,
        },
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        print('Get user failed with status: ${response.statusCode}');
        print('Response body: ${response.body}');
        return null;
      }
    } catch (e) {
      print('Error getting current user: $e');
      return null;
    }
  }

  // Di auth_service.dart, tambahkan fungsi untuk update profile
  Future<Map<String, dynamic>> updateProfile({
    required String userId,
    String? name,
    String? phone,
    String? country,
    File? profileImage,
  }) async {
    try {
      final token = await getToken();
      if (token == null) {
        return {
          'status': 'Error',
          'message': 'No token found',
        };
      }

      // Prepare request body
      Map<String, dynamic> body = {};
      if (name != null) body['name'] = name;
      if (phone != null) body['phone'] = phone;
      if (country != null) body['country'] = country;
      if (profileImage != null) {
        final compressedImage = await _compressAndConvertImage(profileImage);
        if (compressedImage != null) {
          body['profileImage'] = compressedImage;
        }
      }

      final response = await http.put(
        Uri.parse('$baseUrl/$userId'),
        headers: {
          'Content-Type': 'application/json',
          'x-auth-token': token,
        },
        body: jsonEncode(body),
      );

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        return {
          'status': 'Success',
          'data': responseData,
        };
      } else {
        return {
          'status': 'Error',
          'message': 'Update failed: ${response.body}',
        };
      }
    } catch (e) {
      print('Error updating profile: $e');
      return {
        'status': 'Error',
        'message': 'An error occurred: $e',
      };
    }
  }


  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }

  Future<String?> getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('user_id');
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
    await prefs.remove('user_id');
    await prefs.remove('vendor_history');
    userId = null;
  }
}