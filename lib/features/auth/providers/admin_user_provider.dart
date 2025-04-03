import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:classet_admin/core/services/api_service.dart';
import 'package:classet_admin/core/navigation/navigation_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

// State class to hold admin user data
class AdminUserState {
  final Map<String, dynamic>? userDetails;
  final bool isLoading;
  final String? error;

  AdminUserState({
    this.userDetails,
    this.isLoading = false,
    this.error,
  });

  AdminUserState copyWith({
    Map<String, dynamic>? userDetails,
    bool? isLoading,
    String? error,
  }) {
    return AdminUserState(
      userDetails: userDetails ?? this.userDetails,
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

  Future<void> fetchUserDetails(String username) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final response = await _apiService.get('user/details/$username');
      state = state.copyWith(
        userDetails: response,
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

  Future<void> fetchUserDetailsBasedOnAcademicYear(
      String username, String year) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final response =
          await _apiService.get('user/details/$username?reqAcademicYear=$year');
      state = state.copyWith(
        userDetails: response,
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
    await prefs.setString('userDetails', jsonEncode(data));
  }

  Future<void> _loadFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString('userDetails');
    if (data != null) {
      state = state.copyWith(
        userDetails: jsonDecode(data),
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
