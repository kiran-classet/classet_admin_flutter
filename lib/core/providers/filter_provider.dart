import 'package:classet_admin/core/utils/filter_data_parser.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class FilterState {
  final String? branch;
  final String? board;
  final String? grade;
  final List<String> section;

  const FilterState({
    this.branch,
    this.board,
    this.grade,
    this.section = const [],
  });

  Map<String, dynamic> toJson() {
    return {
      'branch': branch,
      'board': board,
      'grade': grade,
      'section': section,
    };
  }

  factory FilterState.fromJson(Map<String, dynamic> json) {
    return FilterState(
      branch: json['branch'] as String?,
      board: json['board'] as String?,
      grade: json['grade'] as String?,
      section:
          (json['section'] as List?)?.map((e) => e.toString()).toList() ?? [],
    );
  }

  FilterState copyWith({
    String? branch,
    String? board,
    String? grade,
    List<String>? section,
    bool clearBoard = false,
    bool clearGrade = false,
    bool clearSection = false,
  }) {
    return FilterState(
      branch: branch ?? this.branch,
      board: clearBoard ? null : (board ?? this.board),
      grade: clearGrade ? null : (grade ?? this.grade),
      section: clearSection ? [] : (section ?? this.section),
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is FilterState &&
        other.branch == branch &&
        other.board == board &&
        other.grade == grade &&
        _listEquals(other.section, section);
  }

  bool _listEquals<T>(List<T>? a, List<T>? b) {
    if (a == null) return b == null;
    if (b == null || a.length != b.length) return false;
    for (int i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }

  @override
  int get hashCode =>
      branch.hashCode ^ board.hashCode ^ grade.hashCode ^ section.hashCode;

  @override
  String toString() {
    return 'FilterState(branch: $branch, board: $board, grade: $grade, section: $section)';
  }
}

final filterStateProvider =
    StateNotifierProvider<FilterStateNotifier, FilterState>((ref) {
  return FilterStateNotifier();
});

final tempFilterStateProvider =
    StateNotifierProvider<FilterStateNotifier, FilterState>((ref) {
  return FilterStateNotifier(); // Separate instance for temporary state
});

class FilterStateNotifier extends StateNotifier<FilterState> {
  static const String _storageKey = 'filter_state';
  bool _isInitialized = false;

  FilterStateNotifier() : super(const FilterState()) {
    _loadSavedState();
  }
  void clearAllFilters() {
    print('Before clearing filters: $state');
    state = const FilterState(); // Reset to initial empty state
    print('After clearing filters: $state');
    _saveState(); // Persist the cleared state to SharedPreferences
  }

  Future<void> _loadSavedState() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedState = prefs.getString(_storageKey);
      if (savedState != null) {
        final decodedState = jsonDecode(savedState);
        if (decodedState is Map<String, dynamic>) {
          state = FilterState.fromJson(decodedState);
        }
      } else {
        // Set default values for the first time
        final userDetails = await _getUserDetails(); // Fetch user details
        if (userDetails != null) {
          final branches =
              FilterDataParser.getBranchesFromUserDetails(userDetails);
          if (branches.isNotEmpty) {
            final firstBranch = branches.first['branchId'];
            final boards =
                FilterDataParser.getBoardsFromBranch(userDetails, firstBranch);
            final firstBoard =
                boards.isNotEmpty ? boards.first['boardId'] : null;
            final classes = firstBoard != null
                ? FilterDataParser.getClassesFromBoard(
                    userDetails, firstBranch, firstBoard)
                : [];
            final firstClass =
                classes.isNotEmpty ? classes.first['classId'] : null;
            final sections = firstClass != null
                ? FilterDataParser.getSectionsFromClass(
                    userDetails, firstBranch, firstBoard!, firstClass)
                : [];
            final firstSection =
                sections.isNotEmpty ? [sections.first['sectionId']] : [];

            state = FilterState(
              branch: firstBranch,
              board: firstBoard,
              grade: firstClass,
              section: firstSection.cast<String>(),
            );
          }
        }
      }
    } catch (e) {
      print('Error loading filter state: $e');
    } finally {
      _isInitialized = true;
    }
  }

// Add a helper method to fetch user details
  Future<Map<String, dynamic>?> _getUserDetails() async {
    // Replace this with the actual logic to fetch user details
    // For example, you might fetch it from a provider or API
    return null;
  }

  Future<void> _saveState() async {
    if (!_isInitialized) return; // Don't save until initial load is complete
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_storageKey, jsonEncode(state.toJson()));
    } catch (e) {
      print('Error saving filter state: $e');
    }
  }

  void updateBranch(String? branch) {
    if (branch != state.branch) {
      state = state.copyWith(
        branch: branch,
        clearBoard: true,
        clearGrade: true,
        clearSection: true,
      );
    }
  }

  void updateBoard(String? board) {
    if (board != state.board) {
      state = state.copyWith(
        board: board,
        clearGrade: true,
        clearSection: true,
      );
    }
  }

  void updateGrade(String? grade) {
    if (grade != state.grade) {
      state = state.copyWith(
        grade: grade,
        clearSection: true,
      );
    }
  }

  void updateSections(List<String> sections,
      {bool isSingleSectionsSelection = false}) {
    if (isSingleSectionsSelection) {
      state = state.copyWith(
          section: sections.isNotEmpty
              ? [sections.last]
              : []); // Add only the last section
    } else if (!_listEquals(sections, state.section)) {
      state = state.copyWith(section: sections); // Update sections
    }
  }

  void saveState() async {
    if (!_isInitialized) return; // Don't save until initial load is complete
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_storageKey, jsonEncode(state.toJson()));
    } catch (e) {
      print('Error saving filter state: $e');
    }
  }

  void resetFilters() {
    state = const FilterState(); // Reset to initial empty state
  }

  void loadFromMainState(FilterState mainState) {
    state = mainState; // Load main state into temporary state
  }

  void applyTempState(WidgetRef ref) {
    ref.read(filterStateProvider.notifier).state =
        state; // Apply temp state to main state
  }

  void resetTempFilters() {
    state = const FilterState(); // Reset temporary state
  }

  bool _listEquals<T>(List<T>? a, List<T>? b) {
    if (a == null) return b == null;
    if (b == null || a.length != b.length) return false;
    for (int i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }

  @override
  void dispose() {
    _saveState(); // Save state when disposing
    super.dispose();
  }
}
