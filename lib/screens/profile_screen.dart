import 'package:flutter/material.dart';

class ProfileScreen extends StatefulWidget {
  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();

  String studentName = "John Doe";
  String studentId = "123456";
  String email = "johndoe@example.com";
  String phone = "123-456-7890";
  String address = "123 Main St, City, State";
  String dateOfBirth = "01/01/2000";
  String gender = "Male";
  String department = "Computer Science";
  String yearOfStudy = "Sophomore";
  String major = "Software Engineering";
  String minor = "Mathematics";
  String gpa = "3.8";
  List<String> classes = ["CS101", "MATH201", "PHYS101"];
  String academicAdvisor = "Dr. Smith";
  String academicStanding = "Good";
  List<String> scholarships = ["Dean's Scholarship", "Merit Scholarship"];
  List<String> achievements = ["First Place in Hackathon", "Published Research Paper"];
  List<String> activities = ["Coding Club", "Basketball Team"];
  List<String> hobbies = ["Reading", "Gaming", "Traveling"];
  String emergencyContactName = "Jane Doe";
  String emergencyContactPhone = "987-654-3210";
  String emergencyContactRelationship = "Mother";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Profile'),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          if (constraints.maxWidth > 600) {
            // Web layout
            return _buildWebLayout();
          } else {
            // Mobile layout
            return _buildMobileLayout();
          }
        },
      ),
    );
  }

  Widget _buildWebLayout() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(32.0),
      child: Center(
        child: Container(
          width: MediaQuery.of(context).size.width * 0.9, // Adjusts the width to 90% of the screen width
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(child: _buildProfilePicture()),
                SizedBox(height: 16),
                GridView.count(
                  shrinkWrap: true,
                  crossAxisCount: 4,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 0, // Remove space between rows
                  padding: EdgeInsets.zero, // Remove padding around GridView
                  children: [
                    _buildTextInputField('Name', studentName, (value) {
                      studentName = value;
                    }),
                    _buildTextInputField('ID', studentId, (value) {
                      studentId = value;
                    }),
                    _buildTextInputField('Email', email, (value) {
                      email = value;
                    }),
                    _buildTextInputField('Phone', phone, (value) {
                      phone = value;
                    }),
                    _buildTextInputField('Address', address, (value) {
                      address = value;
                    }),
                    _buildTextInputField('Date of Birth', dateOfBirth, (value) {
                      dateOfBirth = value;
                    }),
                    _buildTextInputField('Gender', gender, (value) {
                      gender = value;
                    }),
                    _buildTextInputField('Department', department, (value) {
                      department = value;
                    }),
                    _buildTextInputField('Year of Study', yearOfStudy, (value) {
                      yearOfStudy = value;
                    }),
                    _buildTextInputField('Major', major, (value) {
                      major = value;
                    }),
                    _buildTextInputField('Minor', minor, (value) {
                      minor = value;
                    }),
                    _buildTextInputField('GPA', gpa, (value) {
                      gpa = value;
                    }),
                    _buildTextInputField('Classes Enrolled', classes.join(', '), (value) {
                      classes = value.split(',').map((s) => s.trim()).toList();
                    }),
                    _buildTextInputField('Academic Advisor', academicAdvisor, (value) {
                      academicAdvisor = value;
                    }),
                    _buildTextInputField('Academic Standing', academicStanding, (value) {
                      academicStanding = value;
                    }),
                    _buildTextInputField('Scholarships', scholarships.join(', '), (value) {
                      scholarships = value.split(',').map((s) => s.trim()).toList();
                    }),
                    _buildTextInputField('Achievements', achievements.join(', '), (value) {
                      achievements = value.split(',').map((s) => s.trim()).toList();
                    }),
                    _buildTextInputField('Extracurricular Activities', activities.join(', '), (value) {
                      activities = value.split(',').map((s) => s.trim()).toList();
                    }),
                    _buildTextInputField('Hobbies and Interests', hobbies.join(', '), (value) {
                      hobbies = value.split(',').map((s) => s.trim()).toList();
                    }),
                    _buildTextInputField('Emergency Contact Name', emergencyContactName, (value) {
                      emergencyContactName = value;
                    }),
                    _buildTextInputField('Emergency Contact Phone', emergencyContactPhone, (value) {
                      emergencyContactPhone = value;
                    }),
                    _buildTextInputField('Emergency Contact Relationship', emergencyContactRelationship, (value) {
                      emergencyContactRelationship = value;
                    }),
                  ],
                ),
                SizedBox(height: 16),
                Center(
                  child: ElevatedButton(
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        _formKey.currentState!.save();
                        // Logic to save profile changes
                      }
                    },
                    child: Text('Save Profile'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMobileLayout() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16.0),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(child: _buildProfilePicture()),
            SizedBox(height: 16),
            _buildTextInputField('Name', studentName, (value) {
              studentName = value;
            }),
            _buildTextInputField('ID', studentId, (value) {
              studentId = value;
            }),
            _buildTextInputField('Email', email, (value) {
              email = value;
            }),
            _buildTextInputField('Phone', phone, (value) {
              phone = value;
            }),
            _buildTextInputField('Address', address, (value) {
              address = value;
            }),
            _buildTextInputField('Date of Birth', dateOfBirth, (value) {
              dateOfBirth = value;
            }),
            _buildTextInputField('Gender', gender, (value) {
              gender = value;
            }),
            _buildTextInputField('Department', department, (value) {
              department = value;
            }),
            _buildTextInputField('Year of Study', yearOfStudy, (value) {
              yearOfStudy = value;
            }),
            _buildTextInputField('Major', major, (value) {
              major = value;
            }),
            _buildTextInputField('Minor', minor, (value) {
              minor = value;
            }),
            _buildTextInputField('GPA', gpa, (value) {
              gpa = value;
            }),
            _buildTextInputField('Classes Enrolled', classes.join(', '), (value) {
              classes = value.split(',').map((s) => s.trim()).toList();
            }),
            _buildTextInputField('Academic Advisor', academicAdvisor, (value) {
              academicAdvisor = value;
            }),
            _buildTextInputField('Academic Standing', academicStanding, (value) {
              academicStanding = value;
            }),
            _buildTextInputField('Scholarships', scholarships.join(', '), (value) {
              scholarships = value.split(',').map((s) => s.trim()).toList();
            }),
            _buildTextInputField('Achievements', achievements.join(', '), (value) {
              achievements = value.split(',').map((s) => s.trim()).toList();
            }),
            _buildTextInputField('Extracurricular Activities', activities.join(', '), (value) {
              activities = value.split(',').map((s) => s.trim()).toList();
            }),
            _buildTextInputField('Hobbies and Interests', hobbies.join(', '), (value) {
              hobbies = value.split(',').map((s) => s.trim()).toList();
            }),
            _buildTextInputField('Emergency Contact Name', emergencyContactName, (value) {
              emergencyContactName = value;
            }),
            _buildTextInputField('Emergency Contact Phone', emergencyContactPhone, (value) {
              emergencyContactPhone = value;
            }),
            _buildTextInputField('Emergency Contact Relationship', emergencyContactRelationship, (value) {
              emergencyContactRelationship = value;
            }),
            SizedBox(height: 16),
            Center(
              child: ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    _formKey.currentState!.save();
                    // Logic to save profile changes
                  }
                },
                child: Text('Save Profile'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfilePicture() {
    return Column(
      children: [
        CircleAvatar(
          radius: 50,
          backgroundImage: AssetImage('assets/images/students.png'), // Ensure this path matches the path in your pubspec.yaml
        ),
        SizedBox(height: 16),
        ElevatedButton(
          onPressed: () {
            // Logic to upload profile picture
          },
          child: Text('Upload Profile Picture'),
        ),
      ],
    );
  }

  /*Widget _buildTextInputField(String label, String initialValue, Function(String) onSaved) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        initialValue: initialValue,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(),
        ),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Please enter $label';
          }
          return null;
        },
        onSaved: (value) => onSaved(value!),
      ),
    );
  }*/
  Widget _buildTextInputField(String label, String initialValue, Function(String) onSaved, {EdgeInsetsGeometry padding = const EdgeInsets.symmetric(vertical: 8.0)}) {
    return Padding(
      padding: padding,
      child: TextFormField(
        initialValue: initialValue,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(color: Colors.grey[700], fontSize: 16),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8.0),
            borderSide: BorderSide(color: Colors.grey[400]!),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8.0),
            borderSide: BorderSide(color: Colors.blue, width: 2.0),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8.0),
            borderSide: BorderSide(color: Colors.red, width: 2.0),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8.0),
            borderSide: BorderSide(color: Colors.red, width: 2.0),
          ),
          contentPadding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 14.0),
          errorStyle: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
        ),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Please enter $label';
          }
          return null;
        },
        onSaved: (value) => onSaved(value!),
      ),
    );
  }

}
