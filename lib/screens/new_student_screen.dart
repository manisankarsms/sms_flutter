import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sms/repositories/student_repository.dart';

import '../bloc/new_student/new_student_bloc.dart';
import '../bloc/new_student/new_student_event.dart';
import '../bloc/new_student/new_student_state.dart';
import '../models/student.dart';
import '../services/web_service.dart';

class NewStudentScreen extends StatelessWidget {
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _dobController = TextEditingController();
  final _genderController = TextEditingController();
  final _contactController = TextEditingController();
  final _emailController = TextEditingController();
  final _addressController = TextEditingController();
  final _standardController = TextEditingController();


  @override
  Widget build(BuildContext context) {
    final WebService webService = WebService(baseUrl: 'http://localhost:8080'); // Create an instance of WebService

    final StudentRepository stuRepository = StudentRepository(webService: webService); // Create an instance of AuthRepository

    return BlocProvider(
      create: (context) => StudentBloc(studentRepository: stuRepository),
      child: Scaffold(
        appBar: AppBar(
          title: Text("New Student"),
        ),
        body: BlocConsumer<StudentBloc, StudentState>(
          listener: (context, state) {
            if (state is StudentSaved) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text("Student saved successfully!")),
              );
              Navigator.pop(context);
            } else if (state is StudentError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(state.message)),
              );
            }
          },
          builder: (context, state) {
            if (state is StudentSaving) {
              return Center(child: CircularProgressIndicator());
            }

            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: ListView(
                  children: [
                    _buildTextField("First Name", _firstNameController),
                    _buildTextField("Last Name", _lastNameController),
                    _buildTextField("Date of Birth", _dobController),
                    _buildTextField("Gender", _genderController),
                    _buildTextField("Contact Number", _contactController),
                    _buildTextField("Email", _emailController),
                    _buildTextField("Address", _addressController),
                    _buildTextField("Standard", _standardController),
                    SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          final student = Student(
                            firstName: _firstNameController.text,
                            lastName: _lastNameController.text,
                            dateOfBirth: _dobController.text,
                            gender: _genderController.text,
                            contactNumber: _contactController.text,
                            email: _emailController.text,
                            address: _addressController.text,
                            studentStandard: _standardController.text,
                          );
                          context
                              .read<StudentBloc>()
                              .add(SaveStudentEvent(student));
                        }
                      },
                      child: Text("Save Student"),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(labelText: label),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return "Please enter $label";
        }
        return null;
      },
    );
  }
}
