// lib/core/services/auth_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../constants/api_constants.dart';
// import '../../data/models/auth/auth_response_model.dart';
// import '../../data/models/auth/login_request_model.dart';
// import '../../data/models/auth/register_request_model.dart';
import '../../data/models/auth/cliente_model.dart';

class AuthService {
  static const String _tokenKey = 'auth_token';
  static const String _userKey = 'user_data';
  static const String _tenantKey = 'tenant_id';

  // Headers base para las peticiones
  Map<String, String> _getHeaders({String? token}) {
    final headers = <String, String>{
      'Content-Type': 'application/json',
      'X-Tenant-ID': ApiConstants.tenantId,
    };
    print(ApiConstants.tenantId);
    
    if (token != null) {
      headers['Authorization'] = 'Bearer $token';
    }
    
    return headers;
  }

  // Login
  Future<AuthResponseModel> login(LoginRequestModel request) async {
    try {
      
      final response = await http.post(
        Uri.parse('${ApiConstants.baseUrl}/cliente-auth/login'),
        headers: _getHeaders(),
        body: json.encode(request.toJson()),
      );

      print('Login Response Status: ${response.statusCode}');
      print('Login Response Body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseData = json.decode(response.body);
        final authResponse = AuthResponseModel.fromJson(responseData);
        
        // Guardar token y datos del usuario
        await _saveAuthData(authResponse);
        
        return authResponse;
      } else {
        final errorData = json.decode(response.body);
        throw AuthException(
          errorData['message'] ?? 'Error en el login',
          response.statusCode,
        );
      }
    } catch (e) {
      if (e is AuthException) rethrow;
      print('Login Error: $e');
      throw AuthException('Error de conexión: ${e.toString()}');
    }
  }

  // Register
  Future<AuthResponseModel> register(RegisterRequestModel request) async {
    try {
      final response = await http.post(
        Uri.parse('${ApiConstants.baseUrl}/cliente-auth/register'),
        headers: _getHeaders(),
        body: json.encode(request.toJson()),
      );

      print('Register Response Status: ${response.statusCode}');
      print('Register Response Body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseData = json.decode(response.body);
        final authResponse = AuthResponseModel.fromJson(responseData);
        
        // Guardar token y datos del usuario
        await _saveAuthData(authResponse);
        
        return authResponse;
      } else {
        final errorData = json.decode(response.body);
        throw AuthException(
          errorData['message'] ?? 'Error en el registro',
          response.statusCode,
        );
      }
    } catch (e) {
      if (e is AuthException) rethrow;
      print('Register Error: $e');
      throw AuthException('Error de conexión: ${e.toString()}');
    }
  }

  // Check Auth Status
  Future<ClienteModel> checkAuthStatus() async {
    try {
      final token = await getStoredToken();
      if (token == null) {
        throw AuthException('No hay token de autenticación');
      }

      final response = await http.get(
        Uri.parse('${ApiConstants.baseUrl}/cliente-auth/check-status'),
        headers: _getHeaders(token: token),
      );

      print('Check Status Response: ${response.statusCode}');

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        final authResponse = AuthResponseModel.fromJson(responseData);
        
        // Actualizar datos guardados
        await _saveAuthData(authResponse);
        
        return authResponse.toClienteModel();
      } else {
        // Token inválido, limpiar datos
        await clearAuthData();
        throw AuthException('Sesión expirada', response.statusCode);
      }
    } catch (e) {
      if (e is AuthException) rethrow;
      print('Check Auth Status Error: $e');
      throw AuthException('Error verificando autenticación');
    }
  }

  // Update Profile
  Future<ClienteModel> updateProfile(Map<String, dynamic> data) async {
    try {
      final token = await getStoredToken();
      if (token == null) {
        throw AuthException('No hay token de autenticación');
      }

      final response = await http.patch(
        Uri.parse('${ApiConstants.baseUrl}/cliente-auth/profile'),
        headers: _getHeaders(token: token),
        body: json.encode(data),
      );

      print('Update Profile Response: ${response.statusCode}');

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        final cliente = ClienteModel.fromJson(responseData);
        
        // Actualizar datos guardados localmente
        await _saveUserData(cliente);
        
        return cliente;
      } else {
        final errorData = json.decode(response.body);
        throw AuthException(
          errorData['message'] ?? 'Error actualizando perfil',
          response.statusCode,
        );
      }
    } catch (e) {
      if (e is AuthException) rethrow;
      print('Update Profile Error: $e');
      throw AuthException('Error actualizando perfil');
    }
  }

  // Logout
  Future<void> logout() async {
    try {
      // Opcional: notificar al servidor sobre el logout
      final token = await getStoredToken();
      if (token != null) {
        // Aquí podrías hacer una llamada al backend para invalidar el token
        // No es crítico si falla
      }
    } catch (e) {
      print('Logout server notification failed: $e');
    } finally {
      // Siempre limpiar datos locales
      await clearAuthData();
    }
  }

  // Storage methods
  Future<void> _saveAuthData(AuthResponseModel authResponse) async {
    final prefs = await SharedPreferences.getInstance();
    
    await prefs.setString(_tokenKey, authResponse.token);
    await prefs.setString(_tenantKey, authResponse.tenantId);
    
    final clienteModel = authResponse.toClienteModel();
    await prefs.setString(_userKey, json.encode(clienteModel.toJson()));
  }

  Future<void> _saveUserData(ClienteModel cliente) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userKey, json.encode(cliente.toJson()));
  }

  Future<String?> getStoredToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }

  Future<ClienteModel?> getStoredUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userData = prefs.getString(_userKey);
    
    if (userData != null) {
      try {
        final userJson = json.decode(userData);
        return ClienteModel.fromJson(userJson);
      } catch (e) {
        print('Error parsing stored user data: $e');
        return null;
      }
    }
    
    return null;
  }

  Future<String?> getStoredTenantId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tenantKey);
  }

  Future<bool> isLoggedIn() async {
    final token = await getStoredToken();
    final user = await getStoredUser();
    return token != null && user != null;
  }

  Future<void> clearAuthData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
    await prefs.remove(_userKey);
    await prefs.remove(_tenantKey);
  }
}

// Exception personalizada para autenticación
class AuthException implements Exception {
  final String message;
  final int? statusCode;

  AuthException(this.message, [this.statusCode]);

  @override
  String toString() => message;
}