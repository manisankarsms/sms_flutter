
import 'package:flutter/foundation.dart';

import '../models/user.dart';
import '../services/request.dart';
import '../services/web_service.dart'; // Import your WebService class

class AuthRepository {
  final WebService webService;

  AuthRepository({required this.webService});

  Future<String?> signInWithMobileAndPassword(String mobile, String password) async {
    try {
      String request = frameLoginRequest(mobile, password);
      if (kDebugMode) {
        print(request);
      }
      final data = await webService.postData('login', request);

      return data.toString();
    } catch (error) {
      if (kDebugMode) {
        print("Error signing in: $error");
      }
      rethrow;
    }
  }

// Additional authentication methods like signOut, signUp, resetPassword can be added here.
}
