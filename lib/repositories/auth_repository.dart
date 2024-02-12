
import '../models/user.dart';
import '../services/web_service.dart'; // Import your WebService class

class AuthRepository {
  final WebService webService;

  AuthRepository({required this.webService});

  Future<User?> signInWithEmailAndPassword(String email, String password) async {
    try {
      final data = await webService.postData('signin', {'email': email, 'password': password});
      final user = User.fromJson(data); // Assuming you have a User model and a fromJson method
      return user;
    } catch (error) {
      print("Error signing in: $error");
      throw error;
    }
  }

// Additional authentication methods like signOut, signUp, resetPassword can be added here.
}
