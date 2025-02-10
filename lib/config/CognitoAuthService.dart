import 'package:amazon_cognito_identity_dart_2/cognito.dart';
import 'package:classet_admin/config/aws_cognito_config.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class CognitoAuthService {
  final userPool =
      CognitoUserPool(CognitoConfig.userPoolId, CognitoConfig.clientId);

  Future<CognitoUserSession?> login(String username, String password) async {
    final cognitoUser = CognitoUser(username, userPool);
    final authDetails = AuthenticationDetails(
      username: username,
      password: password,
    );

    try {
      final session = await cognitoUser.authenticateUser(authDetails);
      return session;
    } catch (e) {
      print('Error during authentication: $e');
      return null;
    }
  }

  Future<void> logout(String username) async {
    final cognitoUser = CognitoUser(username, userPool);
    await cognitoUser.signOut();
  }

  Future<CognitoUserSession?> getSession(String username) async {
    final cognitoUser = CognitoUser(username, userPool);
    return await cognitoUser.getSession();
  }
}

final cognitoAuthServiceProvider = Provider<CognitoAuthService>((ref) {
  return CognitoAuthService();
});
