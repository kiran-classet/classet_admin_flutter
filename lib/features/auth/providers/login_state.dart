import 'package:flutter_riverpod/flutter_riverpod.dart';

class LoginState {
  final bool isLoading;
  final String? errorMessage;
  final String? idToken; // Add ID token field
  final String? refreshToken; // Add refresh token field
  final String? accessToken; // Add access token field

  LoginState({
    this.isLoading = false,
    this.errorMessage,
    this.idToken,
    this.refreshToken,
    this.accessToken,
  });
}

class LoginNotifier extends StateNotifier<LoginState> {
  LoginNotifier() : super(LoginState());

  void setLoading(bool loading) {
    state = LoginState(
      isLoading: loading,
      errorMessage: state.errorMessage,
      idToken: state.idToken,
      refreshToken: state.refreshToken,
      accessToken: state.accessToken,
    );
  }

  void setError(String message) {
    state = LoginState(
      isLoading: false,
      errorMessage: message,
      idToken: state.idToken,
      refreshToken: state.refreshToken,
      accessToken: state.accessToken,
    );
  }

  void clearError() {
    state = LoginState(
      isLoading: false,
      errorMessage: null,
      idToken: state.idToken,
      refreshToken: state.refreshToken,
      accessToken: state.accessToken,
    );
  }

  void setSessionData(String idToken, String refreshToken, String accessToken) {
    state = LoginState(
      isLoading: false,
      errorMessage: null,
      idToken: idToken,
      refreshToken: refreshToken,
      accessToken: accessToken,
    );
  }
}

final loginProvider = StateNotifierProvider<LoginNotifier, LoginState>((ref) {
  return LoginNotifier();
});
