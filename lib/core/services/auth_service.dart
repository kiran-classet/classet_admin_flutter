import 'package:amplify_flutter/amplify_flutter.dart';

class AuthService {
  Future<bool> signIn(String email, String password) async {
    try {
      final result = await Amplify.Auth.signIn(
        username: email,
        password: password,
      );

      if (result.isSignedIn) {
        print('✅ User signed in successfully!');
        return true;
      } else {
        print('❌ Sign-in failed');
        return false;
      }
    } catch (e) {
      print('❌ Error signing in: $e');
      return false;
    }
  }
}
