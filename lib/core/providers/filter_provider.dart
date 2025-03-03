import 'package:flutter/material.dart';
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
    try {
      return FilterState(
        branch: json['branch'] as String?,
        board: json['board'] as String?,
        grade: json['grade'] as String?,
        section:
            (json['section'] as List?)?.map((e) => e.toString()).toList() ?? [],
      );
    } catch (e) {
      return const FilterState();
    }
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

// FutureProvider to handle async initialization
final filterStateFutureProvider = FutureProvider<FilterState>((ref) async {
  final notifier = ref.watch(filterStateProvider.notifier);
  await notifier._ensureInitialized();
  return ref.watch(filterStateProvider);
});

final filterStateProvider =
    StateNotifierProvider<FilterStateNotifier, FilterState>((ref) {
  return FilterStateNotifier();
});

class FilterStateNotifier extends StateNotifier<FilterState>
    with WidgetsBindingObserver {
  static const String _storageKey = 'filter_state';
  bool _isInitialized = false;

  FilterStateNotifier() : super(const FilterState()) {
    WidgetsBinding.instance.addObserver(this);
    _loadSavedState();
  }

  Future<void> _ensureInitialized() async {
    if (!_isInitialized) {
      await _loadSavedState();
    }
  }

  Future<void> _loadSavedState() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedState = prefs.getString(_storageKey);
      print('Loading saved state: $savedState'); // Debug log
      if (savedState != null) {
        final decodedState = jsonDecode(savedState);
        if (decodedState is Map<String, dynamic>) {
          state = FilterState.fromJson(decodedState);
          print('Loaded state: ${state.toString()}'); // Debug log
        }
      }
    } catch (e) {
      print('Error loading filter state: $e');
    } finally {
      _isInitialized = true;
    }
  }

  Future<void> _saveState() async {
    if (!_isInitialized) return;
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = jsonEncode(state.toJson());
      await prefs.setString(_storageKey, jsonString);
      print('Saved state: $jsonString'); // Debug log
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
      _saveState();
    }
  }

  void updateBoard(String? board) {
    if (board != state.board) {
      state = state.copyWith(
        board: board,
        clearGrade: true,
        clearSection: true,
      );
      _saveState();
    }
  }

  void updateGrade(String? grade) {
    if (grade != state.grade) {
      state = state.copyWith(
        grade: grade,
        clearSection: true,
      );
      _saveState();
    }
  }

  void updateSections(List<String> sections) {
    if (!_listEquals(sections, state.section)) {
      state = state.copyWith(section: sections);
      _saveState();
    }
  }

  void resetFilters() {
    state = const FilterState();
    _saveState();
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
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.detached) {
      _saveState();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _saveState();
    super.dispose();
  }
}
