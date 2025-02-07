import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:classet_admin/core/services/auth_service.dart';

final authServiceProvider = Provider<AuthService>((ref) => AuthService());
