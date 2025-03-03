import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

// Provider to store and retrieve filter preferences
final filterPersistenceProvider = Provider<FilterPersistence>((ref) {
  return FilterPersistence();
});

// Provider for the actual filter state
final filterProvider =
    StateNotifierProvider<FilterNotifier, Map<String, dynamic>>((ref) {
  return FilterNotifier(ref);
});

class FilterPersistence {
  static const String _filterKey = 'app_filters';

  Future<void> saveFilters(Map<String, dynamic> filters) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_filterKey, jsonEncode(filters));
  }

  Future<Map<String, dynamic>> loadFilters() async {
    final prefs = await SharedPreferences.getInstance();
    final filterString = prefs.getString(_filterKey);
    if (filterString == null) {
      return {
        'branch': null,
        'board': null,
        'grade': null,
        'section': <String>[],
      };
    }

    try {
      final Map<String, dynamic> decodedFilters = jsonDecode(filterString);
      // Ensure section is always a List<String>
      if (decodedFilters['section'] != null) {
        decodedFilters['section'] =
            List<String>.from(decodedFilters['section']);
      } else {
        decodedFilters['section'] = <String>[];
      }
      return decodedFilters;
    } catch (e) {
      return {
        'branch': null,
        'board': null,
        'grade': null,
        'section': <String>[],
      };
    }
  }
}

class FilterNotifier extends StateNotifier<Map<String, dynamic>> {
  final Ref _ref;

  FilterNotifier(this._ref)
      : super({
          'branch': null,
          'board': null,
          'grade': null,
          'section': <String>[],
        }) {
    _loadSavedFilters();
  }

  Future<void> _loadSavedFilters() async {
    final savedFilters =
        await _ref.read(filterPersistenceProvider).loadFilters();
    state = savedFilters;
  }

  Future<void> updateFilters(Map<String, dynamic> newFilters) async {
    state = newFilters;
    await _ref.read(filterPersistenceProvider).saveFilters(newFilters);
  }

  Future<void> resetFilters() async {
    final emptyFilters = {
      'branch': null,
      'board': null,
      'grade': null,
      'section': <String>[],
    };
    state = emptyFilters;
    await _ref.read(filterPersistenceProvider).saveFilters(emptyFilters);
  }
}
