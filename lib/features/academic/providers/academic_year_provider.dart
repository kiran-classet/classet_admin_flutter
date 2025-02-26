import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:classet_admin/core/services/api_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';
import 'package:classet_admin/core/navigation/navigation_service.dart';

class AcademicYearState {
  final List<Map<String, dynamic>> academicYears;
  final bool isLoading;
  final String? error;
  final String? selectedAcademicYear;

  AcademicYearState({
    this.academicYears = const [],
    this.isLoading = false,
    this.error,
    this.selectedAcademicYear,
  });

  AcademicYearState copyWith({
    List<Map<String, dynamic>>? academicYears,
    bool? isLoading,
    String? error,
    String? selectedAcademicYear,
  }) {
    return AcademicYearState(
      academicYears: academicYears ?? this.academicYears,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      selectedAcademicYear: selectedAcademicYear ?? this.selectedAcademicYear,
    );
  }
}

class AcademicYearNotifier extends StateNotifier<AcademicYearState> {
  AcademicYearNotifier(this._apiService, this._navigationService)
      : super(AcademicYearState());

  final ApiService _apiService;
  final NavigationService _navigationService;

  Future<void> fetchAcademicYears() async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final response = await _apiService.get('academic-years/');
      final academicYears = List<Map<String, dynamic>>.from(response['data']);
      final prefs = await SharedPreferences.getInstance();
      final selectedAcademicYear =
          prefs.getString('selectedAcademicYear') ?? academicYears.first['_id'];

      state = state.copyWith(
        academicYears: academicYears,
        isLoading: false,
        selectedAcademicYear: selectedAcademicYear,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      _navigationService.navigateTo('/something-went-wrong');
    }
  }

  Future<void> setSelectedAcademicYear(String academicYearId) async {
    state = state.copyWith(selectedAcademicYear: academicYearId);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('selectedAcademicYear', academicYearId);
  }
}

final academicYearProvider =
    StateNotifierProvider<AcademicYearNotifier, AcademicYearState>((ref) {
  final apiService = ApiService();
  final navigationService = NavigationService();
  return AcademicYearNotifier(apiService, navigationService);
});
