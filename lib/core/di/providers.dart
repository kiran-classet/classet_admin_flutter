import 'package:amazon_cognito_identity_dart_2/cognito.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final authStateProvider = StateProvider<CognitoUserSession?>((ref) {
  return null; // Initially no session (user not logged in)
});
