import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:amplify_auth_cognito/amplify_auth_cognito.dart';
import 'package:classet_admin/config/aws_cognito_config.dart'; // Import your Cognito config

class AmplifyService {
  static Future<void> configureAmplify() async {
    try {
      final authPlugin = AmplifyAuthCognito();

      await Amplify.addPlugin(authPlugin);

      await Amplify.configure('''
      {
        "auth": {
          "plugins": {
            "awsCognitoAuthPlugin": {
              "UserAgent": "aws-amplify-flutter/1.3.0",
              "Version": "1.3.0",
              "CognitoUserPool": {
                "Default": {
                  "PoolId": "${awsCognitoConfig['UserPoolId']}",
                  "AppClientId": "${awsCognitoConfig['ClientId']}",
                  "Region": "${awsCognitoConfig['Region']}"
                }
              }
            }
          }
        }
      }
      ''');

      print('✅ Amplify configured successfully!');
    } catch (e) {
      print('❌ Error configuring Amplify: $e');
    }
  }
}
