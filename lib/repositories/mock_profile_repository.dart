import '../models/profile.dart';

class MockProfileRepository implements IProfileRepository {
  Profile _mockProfile = Profile(
    // Sample profile data for demonstration
    studentName: 'John Doe',
    studentId: '123456',
    email: 'john.doe@example.com',
    phone: '555-555-5555',
    address: '123 Main St, Anytown, USA',
    dateOfBirth: '2000-01-01',
    gender: 'Male',
    department: 'Computer Science',
    yearOfStudy: 'Senior',
    major: 'Software Engineering',
    minor: 'Mathematics',
    gpa: 3.8,
    classes: ['CS101', 'CS102', 'MATH201'],
    academicAdvisor: 'Dr. Smith',
    academicStanding: 'Good',
    scholarships: ['Scholarship A', 'Scholarship B'],
    achievements: ['Dean\'s List', 'Coding Competition Winner'],
    activities: ['Chess Club', 'Robotics Club'],
    hobbies: ['Reading', 'Swimming'],
    emergencyContactName: 'Jane Doe',
    emergencyContactPhone: '555-555-5556',
    emergencyContactRelationship: 'Mother',
  );

  @override
  Future<Profile> fetchProfile(String mobileNo, String userId) async {
    // Simulate a network delay
    await Future.delayed(Duration(seconds: 1));
    return _mockProfile;
  }

  @override
  Future<void> updateProfile(Profile profile) async {
    // Simulate a network delay
    await Future.delayed(Duration(seconds: 1));
    _mockProfile = profile;
  }
}

abstract class IProfileRepository {
  Future<Profile> fetchProfile(String mobileNo, String userId);
  Future<void> updateProfile(Profile profile);
}

