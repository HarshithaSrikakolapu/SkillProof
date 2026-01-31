import 'package:flutter/material.dart';
import 'package:frontend/features/auth/data/auth_service.dart';
import 'package:frontend/features/auth/data/user_model.dart';

class AuthProvider extends ChangeNotifier {
  User? _user;
  final AuthService _authService = AuthService();
  bool _isLoading = false;

  User? get user => _user;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _user != null;

  Future<void> login(String email, String password) async {
    _isLoading = true;
    notifyListeners();
    try {
      _user = await _authService.login(email, password);
    } catch (e) {
      // Handle error (e.g., show toast)
      print(e);
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> register(String email, String password, String role, String fullName) async {
    _isLoading = true;
    notifyListeners();
    try {
      await _authService.register(email, password, role, fullName);
      // Auto login after register or ask user to login
    } catch (e) {
      print(e);
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> checkAuthStatus() async {
    final token = await _authService.getToken();
    if (token != null) {
      try {
         _user = await _authService.getProfile(); 
         _isLoading = false;
         notifyListeners();
      } catch (e) {
        await logout();
      }
    }
  }

  Future<void> logout() async {
    await _authService.logout();
    _user = null;
    notifyListeners();
  }
}
