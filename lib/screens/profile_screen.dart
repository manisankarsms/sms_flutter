import 'package:flutter/material.dart';

import '../models/profile.dart';
import '../repositories/mock_profile_repository.dart';

class ProfileScreen extends StatefulWidget {
  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final IProfileRepository profileRepository = MockProfileRepository();

  Profile? _profile;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    String mobileNo = '555-555-5555';
    String userId = '123456';
    Profile profile = await profileRepository.fetchProfile(mobileNo, userId);
    setState(() {
      _profile = profile;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Profile'),
      ),
      body: _profile == null
          ? Center(child: CircularProgressIndicator())
          : LayoutBuilder(
        builder: (context, constraints) {
          if (constraints.maxWidth > 600) {
            return _buildWebLayout(_profile!);
          } else {
            return _buildMobileLayout(_profile!);
          }
        },
      ),
    );
  }

  Widget _buildWebLayout(Profile profile) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(32.0),
      child: Center(
        child: Container(
          width: MediaQuery.of(context).size.width * 0.9,
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: _buildFormFields(profile),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMobileLayout(Profile profile) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16.0),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: _buildFormFields(profile),
        ),
      ),
    );
  }

  List<Widget> _buildFormFields(Profile profile) {
    return [
      Center(child: _buildProfilePicture()),
      SizedBox(height: 16),
      _buildTextInputField('Name', profile.studentName, (value) {
        _profile = profile.copyWith(studentName: value);
      }),
      _buildTextInputField('ID', profile.studentId, (value) {
        _profile = profile.copyWith(studentId: value);
      }),
      _buildTextInputField('Email', profile.email, (value) {
        _profile = profile.copyWith(email: value);
      }),
      _buildTextInputField('Phone', profile.phone, (value) {
        _profile = profile.copyWith(phone: value);
      }),
      _buildTextInputField('Address', profile.address, (value) {
        _profile = profile.copyWith(address: value);
      }),
      _buildTextInputField('Date of Birth', profile.dateOfBirth, (value) {
        _profile = profile.copyWith(dateOfBirth: value);
      }),
      _buildTextInputField('Gender', profile.gender, (value) {
        _profile = profile.copyWith(gender: value);
      }),
      _buildTextInputField('Department', profile.department, (value) {
        _profile = profile.copyWith(department: value);
      }),
      _buildTextInputField('Year of Study', profile.yearOfStudy, (value) {
        _profile = profile.copyWith(yearOfStudy: value);
      }),
      _buildTextInputField('Major', profile.major, (value) {
        _profile = profile.copyWith(major: value);
      }),
      _buildTextInputField('Minor', profile.minor, (value) {
        _profile = profile.copyWith(minor: value);
      }),
      _buildTextInputField('GPA', profile.gpa.toString(), (value) {
        _profile = profile.copyWith(gpa: double.parse(value));
      }),
      _buildTextInputField('Classes', profile.classes.join(', '), (value) {
        _profile = profile.copyWith(classes: value.split(', ').toList());
      }),
      _buildTextInputField('Academic Advisor', profile.academicAdvisor, (value) {
        _profile = profile.copyWith(academicAdvisor: value);
      }),
      _buildTextInputField('Academic Standing', profile.academicStanding, (value) {
        _profile = profile.copyWith(academicStanding: value);
      }),
      _buildTextInputField('Scholarships', profile.scholarships.join(', '), (value) {
        _profile = profile.copyWith(scholarships: value.split(', ').toList());
      }),
      _buildTextInputField('Achievements', profile.achievements.join(', '), (value) {
        _profile = profile.copyWith(achievements: value.split(', ').toList());
      }),
      _buildTextInputField('Activities', profile.activities.join(', '), (value) {
        _profile = profile.copyWith(activities: value.split(', ').toList());
      }),
      _buildTextInputField('Hobbies', profile.hobbies.join(', '), (value) {
        _profile = profile.copyWith(hobbies: value.split(', ').toList());
      }),
      _buildTextInputField('Emergency Contact Name', profile.emergencyContactName, (value) {
        _profile = profile.copyWith(emergencyContactName: value);
      }),
      _buildTextInputField('Emergency Contact Phone', profile.emergencyContactPhone, (value) {
        _profile = profile.copyWith(emergencyContactPhone: value);
      }),
      _buildTextInputField('Emergency Contact Relationship', profile.emergencyContactRelationship, (value) {
        _profile = profile.copyWith(emergencyContactRelationship: value);
      }),
      SizedBox(height: 16),
      Center(
        child: ElevatedButton(
          onPressed: _updateProfile,
          child: Text('Save'),
        ),
      ),
    ];
  }

  Widget _buildTextInputField(String label, String initialValue, ValueChanged<String> onChanged) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        initialValue: initialValue,
        decoration: InputDecoration(labelText: label),
        onChanged: onChanged,
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Please enter $label';
          }
          return null;
        },
      ),
    );
  }

  Widget _buildProfilePicture() {
    return CircleAvatar(
      radius: 60,
      backgroundImage: AssetImage('assets/profile_picture.png'),
      child: Align(
        alignment: Alignment.bottomRight,
        child: CircleAvatar(
          backgroundColor: Colors.white,
          radius: 20,
          child: IconButton(
            icon: Icon(Icons.camera_alt, color: Colors.blue),
            onPressed: () {
              // Implement your logic to upload a new profile picture
            },
          ),
        ),
      ),
    );
  }

  void _updateProfile() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      // Call the repository to save the updated profile
      profileRepository.updateProfile(_profile!);
      // Show a success message or navigate back
    }
  }
}
