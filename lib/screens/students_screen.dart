import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/students/students_bloc.dart';
import '../bloc/students/students_event.dart';
import '../bloc/students/students_state.dart';

class StudentsScreen extends StatelessWidget {
  final String standard;
  final String classId;

  const StudentsScreen({
    Key? key,
    required this.standard,
    required this.classId,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('$standard Students'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              context.read<StudentsBloc>().add(RefreshStudents(classId));
            },
          ),
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showAddStudentDialog(context),
          ),
        ],
      ),
      body: BlocBuilder<StudentsBloc, StudentsState>(
        builder: (context, state) {
          if (state is StudentsInitial) {
            context.read<StudentsBloc>().add(LoadStudents(classId));
            return const Center(child: CircularProgressIndicator());
          }

          if (state is StudentsLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is StudentsError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Error: ${state.message}',
                    style: const TextStyle(color: Colors.red),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      context.read<StudentsBloc>().add(LoadStudents(classId));
                    },
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          if (state is StudentsLoaded) {
            if (state.students.isEmpty) {
              return const Center(
                child: Text(
                  'No students found',
                  style: TextStyle(fontSize: 18, color: Colors.grey),
                ),
              );
            }

            return RefreshIndicator(
              onRefresh: () async {
                context.read<StudentsBloc>().add(RefreshStudents(classId));
              },
              child: ListView.builder(
                itemCount: state.students.length,
                itemBuilder: (context, index) {
                  final student = state.students[index];
                  return Card(
                    margin: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    child: ExpansionTile(
                      title: Text('${student.firstName} ${student.lastName}'),
                      subtitle: Text(student.email),
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildInfoRow('Date of Birth', student.dateOfBirth),
                              _buildInfoRow('Gender', student.gender),
                              _buildInfoRow('Contact', student.contactNumber),
                              _buildInfoRow('Address', student.address),
                              _buildInfoRow('Standard', student.studentStandard),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Expanded(
            child: Text(value),
          ),
        ],
      ),
    );
  }

  void _showAddStudentDialog(BuildContext context) {
    // Implementation for adding new student
    // Similar to your _showAddClassDialog implementation
  }
}