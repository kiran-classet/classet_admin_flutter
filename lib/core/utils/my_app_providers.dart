import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MyAppProviders {
  MyAppProviders._();

  static final List<ProviderBase> _allProviders = [];

  static void addProvider(ProviderBase provider) {
    _allProviders.add(provider);
  }

  static Future<void> invalidateAllProviders(WidgetRef ref) async {
    for (var provider in _allProviders) {
      ref.invalidate(provider);
    }
    _allProviders.clear();
  }
}

class CustomProviderObserver extends ProviderObserver {
  @override
  void didAddProvider(
      ProviderBase provider, Object? value, ProviderContainer container) {
    MyAppProviders.addProvider(provider);
    super.didAddProvider(provider, value, container);
  }
}
