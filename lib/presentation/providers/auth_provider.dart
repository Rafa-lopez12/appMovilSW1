import 'package:flutter/foundation.dart';
import '../../core/services/auth_service.dart';
import '../../data/models/auth/cliente_model.dart';
// import '../../data/models/auth/login_request_model.dart';
// import '../../data/models/auth/register_request_model.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();

  // State variables
  ClienteModel? _currentUser;
  bool _isLoading = false;
  bool _isAuthenticated = false;
  String? _errorMessage;
  String? _token;

  // Getters
  ClienteModel? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _isAuthenticated;
  String? get errorMessage => _errorMessage;
  String? get token => _token;
  String? get userFullName => _currentUser?.fullName;
  String? get userEmail => _currentUser?.email;
  String? get userId => _currentUser?.id;
  String? get tenantId => _currentUser?.tenantId;

  // Initialize auth state
  Future<void> initializeAuth() async {
    _setLoading(true);
    
    try {
      // Verificar si hay datos guardados localmente
      final isLoggedIn = await _authService.isLoggedIn();
      
      if (isLoggedIn) {
        // Intentar verificar el estado con el servidor
        try {
          _currentUser = await _authService.checkAuthStatus();
          _token = await _authService.getStoredToken();
          _isAuthenticated = true;
        } catch (e) {
          // Si falla la verificación, usar datos locales
          _currentUser = await _authService.getStoredUser();
          _token = await _authService.getStoredToken();
          _isAuthenticated = _currentUser != null && _token != null;
          
          if (!_isAuthenticated) {
            await _authService.clearAuthData();
          }
        }
      }
    } catch (e) {
      debugPrint('Error initializing auth: $e');
      await _authService.clearAuthData();
      _isAuthenticated = false;
    } finally {
      _setLoading(false);
    }
  }

  // Login method
  Future<void> login({
    required String email,
    required String password,
    bool rememberMe = false,
  }) async {
    _setLoading(true);
    _clearError();
    try {
      final request = LoginRequestModel(
        email: email.trim(),
        password: password,
      );
      final response = await _authService.login(request);
      _currentUser = response.toClienteModel();
      _token = response.token;
      _isAuthenticated = true;

      debugPrint('Login successful for user: ${_currentUser?.email}');
      notifyListeners();
    } catch (e) {
      _handleError(e);
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  // Register method
  Future<void> register({
    required String firstName,
    required String lastName,
    required String email,
    required String password,
    String? phone,
    String? address,
    DateTime? birthDate,
    bool acceptNewsletter = false,
  }) async {
    _setLoading(true);
    _clearError();

    try {
      final request = RegisterRequestModel(
        email: email.trim(),
        password: password,
        firstName: firstName.trim(),
        lastName: lastName.trim(),
        telefono: phone?.trim(),
        direccion: address?.trim(),
      );

      final response = await _authService.register(request);
      
      _currentUser = response.toClienteModel();
      _token = response.token;
      _isAuthenticated = true;

      debugPrint('Registration successful for user: ${_currentUser?.email}');
      notifyListeners();
    } catch (e) {
      _handleError(e);
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  // Logout method
  Future<void> logout() async {
    _setLoading(true);

    try {
      await _authService.logout();
      await _clearAuthData();
      debugPrint('Logout successful');
    } catch (e) {
      debugPrint('Error during logout: $e');
      // Limpiar datos locales aunque haya error
      await _clearAuthData();
    } finally {
      _setLoading(false);
    }
  }

  // Update user profile
  Future<void> updateProfile({
    String? firstName,
    String? lastName,
    String? phone,
    String? address,
  }) async {
    if (_currentUser == null) return;

    _setLoading(true);
    _clearError();

    try {
      final updateData = <String, dynamic>{};
      
      if (firstName != null) updateData['firstName'] = firstName.trim();
      if (lastName != null) updateData['lastName'] = lastName.trim();
      if (phone != null) updateData['telefono'] = phone.trim();
      if (address != null) updateData['direccion'] = address.trim();

      _currentUser = await _authService.updateProfile(updateData);
      
      debugPrint('Profile updated successfully');
      notifyListeners();
    } catch (e) {
      _handleError(e);
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  // Refresh user data
  Future<void> refreshUserData() async {
    if (!_isAuthenticated) return;

    try {
      _currentUser = await _authService.checkAuthStatus();
      notifyListeners();
    } catch (e) {
      debugPrint('Failed to refresh user data: $e');
      // Si falla la verificación, podría ser que el token expiró
      if (e.toString().contains('Sesión expirada') || 
          e.toString().contains('401')) {
        await logout();
      }
    }
  }

  // Check if user has specific permission (placeholder)
  bool hasPermission(String permission) {
    return _isAuthenticated && _currentUser?.isActive == true;
  }

  // Verify if email is verified
  bool get isEmailVerified {
    return _currentUser?.isActive ?? false;
  }

  // Get user initials
  String get userInitials {
    if (_currentUser == null) return 'U';
    
    final firstName = _currentUser!.firstName;
    final lastName = _currentUser!.lastName;
    
    if (firstName.isEmpty && lastName.isEmpty) return 'U';
    
    return '${firstName.isNotEmpty ? firstName[0].toUpperCase() : ''}'
           '${lastName.isNotEmpty ? lastName[0].toUpperCase() : ''}';
  }

  // Check if user is new (registered recently)
  bool get isNewUser {
    // Esta lógica se puede implementar basándose en la fecha de registro
    // Por ahora retorna false
    return false;
  }

  // Auto-login attempt
  Future<bool> tryAutoLogin() async {
    try {
      final isLoggedIn = await _authService.isLoggedIn();
      if (isLoggedIn) {
        await initializeAuth();
        return _isAuthenticated;
      }
      return false;
    } catch (e) {
      debugPrint('Auto-login failed: $e');
      return false;
    }
  }

  // Change password (placeholder - requiere endpoint en backend)
  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    _setLoading(true);
    _clearError();

    try {
      // TODO: Implementar endpoint en backend para cambiar contraseña
      await Future.delayed(const Duration(seconds: 1));
      
      // Por ahora solo simular
      throw UnimplementedError('Cambio de contraseña no implementado en el backend');
    } catch (e) {
      _handleError(e);
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  // Private methods
  Future<void> _clearAuthData() async {
    _currentUser = null;
    _token = null;
    _isAuthenticated = false;
    _errorMessage = null;
    notifyListeners();
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _handleError(dynamic error) {
    _errorMessage = error.toString();
    debugPrint('Auth Error: $_errorMessage');
    notifyListeners();
  }

  void _clearError() {
    _errorMessage = null;
  }

  // Session management (placeholder para futuras funcionalidades)
  void startSessionTimer() {
    // TODO: Implementar timer de sesión
  }

  void resetSessionTimer() {
    // TODO: Reset timer de sesión
  }

  // Get authorization header for API calls
  Map<String, String>? getAuthHeaders() {
    if (_token == null) return null;
    
    return {
      'Authorization': 'Bearer $_token',
      'Content-Type': 'application/json',
    };
  }
}