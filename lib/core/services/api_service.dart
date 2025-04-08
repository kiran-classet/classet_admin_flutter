import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  // static const String productionBaseUrl ='https://8bzo5ffosh.execute-api.ap-south-1.amazonaws.com/sasdev/v1/data';

  static const String productionBaseUrl =
      'https://d0xfkv0fi4.execute-api.ap-south-2.amazonaws.com/sasprod/v1/data/';

  // static const String localhostBaseUrl = 'http://192.168.0.114:4000/v1/data/';
  static const String localhostBaseUrl = 'http://192.168.1.13:4000/v1/data/';

  static const String baseUrl =
      productionBaseUrl; // Switch to productionBaseUrl for production.

  // Generic GET request
  Future<dynamic> get(String endpoint) async {
    try {
      final token = await _getIdToken();
      final response = await http.get(
        Uri.parse('$baseUrl/$endpoint'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      return _handleResponse(response);
    } catch (e) {
      return _handleError(e);
    }
  }

  // Generic POST request
  Future<dynamic> post(String endpoint, dynamic body) async {
    try {
      final token = await _getIdToken();
      final response = await http.post(
        Uri.parse('$baseUrl/$endpoint'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: json.encode(body),
      );

      return json.decode(response.body);
    } catch (e) {
      return _handleError(e);
    }
  }

  // Generic PUT request
  Future<dynamic> put(String endpoint, dynamic body) async {
    try {
      final token = await _getIdToken();
      final response = await http.put(
        Uri.parse('$baseUrl/$endpoint'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: json.encode(body),
      );

      return _handleResponse(response);
    } catch (e) {
      return _handleError(e);
    }
  }

  // Generic DELETE request
  Future<dynamic> delete(String endpoint) async {
    try {
      final token = await _getIdToken();
      final response = await http.delete(
        Uri.parse('$baseUrl/$endpoint'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      return _handleResponse(response);
    } catch (e) {
      return _handleError(e);
    }
  }

  // Handle API response
  dynamic _handleResponse(http.Response response) {
    switch (response.statusCode) {
      case 200:
      case 201:
        return json.decode(response.body);
      case 400:
        throw BadRequestException(response.body);
      case 401:
        throw UnauthorizedException(response.body);
      case 403:
        throw ForbiddenException(response.body);
      case 404:
        throw NotFoundException(response.body);
      case 500:
        throw ServerException(response.body);
      default:
        throw Exception('An unexpected error occurred');
    }
  }

  // Handle general errors
  dynamic _handleError(dynamic error) {
    if (error is ApiException) {
      throw error;
    }
    if (error is SocketException) {
      throw Exception(
          'Connection refused. Please check if the server is running and accessible: ${error.toString()}');
    }
    throw Exception('An unexpected error occurred: ${error.toString()}');
  }

  // Get ID token from SharedPreferences
  Future<String?> _getIdToken() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('idToken');
    if (token == null) {
      throw UnauthorizedException('No authentication token found');
    }
    return token;
  }
}

// Custom exceptions
class ApiException implements Exception {
  final String message;
  ApiException(this.message);
}

class BadRequestException extends ApiException {
  BadRequestException(super.message);
}

class UnauthorizedException extends ApiException {
  UnauthorizedException(super.message);
}

class ForbiddenException extends ApiException {
  ForbiddenException(super.message);
}

class NotFoundException extends ApiException {
  NotFoundException(super.message);
}

class ServerException extends ApiException {
  ServerException(super.message);
}
