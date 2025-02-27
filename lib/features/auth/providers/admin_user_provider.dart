import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:classet_admin/core/services/api_service.dart';
import 'package:amazon_cognito_identity_dart_2/cognito.dart';
import 'package:flutter/material.dart';
import 'package:classet_admin/core/navigation/navigation_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

// State class to hold admin user data
class AdminUserState {
  final Map<String, dynamic>? userRolesPermissions;
  final bool isLoading;
  final String? error;

  AdminUserState({
    this.userRolesPermissions,
    this.isLoading = false,
    this.error,
  });

  AdminUserState copyWith({
    Map<String, dynamic>? userRolesPermissions,
    bool? isLoading,
    String? error,
  }) {
    return AdminUserState(
      userRolesPermissions: userRolesPermissions ?? this.userRolesPermissions,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }
}

// Notifier class to manage admin user state
class AdminUserNotifier extends StateNotifier<AdminUserState> {
  AdminUserNotifier(this._apiService, this._navigationService)
      : super(AdminUserState()) {
    _loadFromPrefs();
  }

  final ApiService _apiService;
  final NavigationService _navigationService;

  Future<void> fetchUserRolesPermissions(String username) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final response = await _apiService
          .get('authorize/getAdminUserRolesPermissions/$username');
      state = state.copyWith(
        userRolesPermissions: response,
        isLoading: false,
      );
      _saveToPrefs(response);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      _navigationService.navigateTo('/something-went-wrong');
    }
  }

  Future<void> _saveToPrefs(Map<String, dynamic> data) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('userRolesPermissions', jsonEncode(data));
  }

  Future<void> _loadFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString('userRolesPermissions');
    if (data != null) {
      state = state.copyWith(
        userRolesPermissions: jsonDecode(data),
      );
    }
  }
}

// Provider definition
final adminUserProvider =
    StateNotifierProvider<AdminUserNotifier, AdminUserState>((ref) {
  final apiService = ApiService();
  final navigationService = NavigationService();
  return AdminUserNotifier(apiService, navigationService);
});
