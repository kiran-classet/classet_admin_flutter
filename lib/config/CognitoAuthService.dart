import 'package:classet_admin/config/aws_cognito_config.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:amazon_cognito_identity_dart_2/cognito.dart';

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
      if (session != null) {
        await _storeSession(session); // Store session in Shared Preferences
      }
      return session;
    } catch (e) {
      print('Error during authentication: $e');
      return null;
    }
  }

  Future<void> _storeSession(CognitoUserSession session) async {
    final prefs = await SharedPreferences.getInstance();

    // Get the tokens and ensure they are not null
    final accessToken = session.getAccessToken().getJwtToken();
    final refreshToken = session.getRefreshToken()?.getToken();
    final idToken = session.getIdToken().getJwtToken();

    // Store tokens only if they are not null
    if (accessToken != null) {
      await prefs.setString('accessToken', accessToken);
      print(idToken);
    }
    if (refreshToken != null) {
      await prefs.setString('refreshToken', refreshToken);
    }
    if (idToken != null) {
      await prefs.setString('idToken', idToken);
    }
  }
}
