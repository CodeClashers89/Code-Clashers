import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class AuthService extends ChangeNotifier {
  // IMPORTANT: For physical device testing, use your computer's local IP address
  // Your WiFi IP: 120.120.122.113
  // Make sure your Android device is connected to the same WiFi network
  final String baseUrl = 'http://120.120.122.113:8000/api';
  
  String? _accessToken;
  String? _refreshToken;
  String? _userRole;
  String? _username;
  bool _isAuthenticated = false;

  bool get isAuthenticated => _isAuthenticated;
  String? get userRole => _userRole;
  String? get username => _username;
  String? get accessToken => _accessToken;

  AuthService() {
    _loadTokens();
  }

  Future<void> _loadTokens() async {
    final prefs = await SharedPreferences.getInstance();
    _accessToken = prefs.getString('access_token');
    _refreshToken = prefs.getString('refresh_token');
    _userRole = prefs.getString('user_role');
    _username = prefs.getString('username');
    _isAuthenticated = _accessToken != null;
    notifyListeners();
  }

  Future<Map<String, dynamic>> login(String username, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/accounts/login/'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'username': username,
          'password': password,
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        
        _accessToken = data['access'];
        _refreshToken = data['refresh'];
        _userRole = data['user']['role'];
        _username = data['user']['username'];
        _isAuthenticated = true;

        // Store tokens
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('access_token', _accessToken!);
        await prefs.setString('refresh_token', _refreshToken!);
        await prefs.setString('user_role', _userRole!);
        await prefs.setString('username', _username!);

        notifyListeners();
        return {'success': true, 'role': _userRole};
      } else {
        final error = json.decode(response.body);
        return {'success': false, 'error': error['detail'] ?? 'Login failed'};
      }
    } catch (e) {
      return {'success': false, 'error': 'Network error: $e'};
    }
  }

  Future<Map<String, dynamic>> register(Map<String, dynamic> userData) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/accounts/register/'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(userData),
      );

      if (response.statusCode == 201) {
        final data = json.decode(response.body);
        return {
          'success': true,
          'requires_approval': data['requires_approval'] ?? false,
        };
      } else {
        final error = json.decode(response.body);
        return {'success': false, 'error': error.toString()};
      }
    } catch (e) {
      return {'success': false, 'error': 'Network error: $e'};
    }
  }

  Future<void> logout() async {
    _accessToken = null;
    _refreshToken = null;
    _userRole = null;
    _username = null;
    _isAuthenticated = false;

    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    notifyListeners();
  }

  Future<Map<String, String>> getHeaders() async {
    return {
      'Content-Type': 'application/json',
      if (_accessToken != null) 'Authorization': 'Bearer $_accessToken',
    };
  }

  Future<http.Response> get(String endpoint) async {
    final headers = await getHeaders();
    return await http.get(
      Uri.parse('$baseUrl$endpoint'),
      headers: headers,
    );
  }

  Future<http.Response> post(String endpoint, Map<String, dynamic> data) async {
    final headers = await getHeaders();
    return await http.post(
      Uri.parse('$baseUrl$endpoint'),
      headers: headers,
      body: json.encode(data),
    );
  }
}
