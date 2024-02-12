import '../models/user.dart';

class MockAuthRepository {
  Future<User?> signInWithEmailAndPassword(String email, String password) async {
    // Simulate authentication locally
    if (email == 'student' && password == 'password') {
      // Return a user object if authentication succeeds
      return User(id: '1', email: email, displayName: 'Test User');
    } else {
      // Return null if authentication fails
      return Future.error("Invalid");
    }
  }
}
