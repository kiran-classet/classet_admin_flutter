import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:classet_admin/core/services/api_service.dart';

class AcademicYearState {
  final List<Map<String, dynamic>> academicYears;
  final bool isLoading;
  final String? error;

  AcademicYearState({
    this.academicYears = const [],
    this.isLoading = false,
    this.error,
  });

  AcademicYearState copyWith({
    List<Map<String, dynamic>>? academicYears,
    bool? isLoading,
    String? error,
  }) {
    return AcademicYearState(
      academicYears: academicYears ?? this.academicYears,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

class AcademicYearNotifier extends StateNotifier<AcademicYearState> {
  AcademicYearNotifier(this._apiService) : super(AcademicYearState());

  final ApiService _apiService;

  Future<void> fetchAcademicYears() async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final response = await _apiService.get('academic-years/');
      state = state.copyWith(
        academicYears: List<Map<String, dynamic>>.from(response['data']),
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }
}

final academicYearProvider =
    StateNotifierProvider<AcademicYearNotifier, AcademicYearState>((ref) {
  final apiService = ApiService();
  return AcademicYearNotifier(apiService);
});
