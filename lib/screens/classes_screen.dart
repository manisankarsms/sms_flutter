import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sms/screens/students_screen.dart';

import '../bloc/classes/classes_bloc.dart';
import '../bloc/classes/classes_event.dart';
import '../bloc/classes/classes_state.dart';
import '../bloc/students/students_bloc.dart';
import '../bloc/students/students_event.dart';
import '../models/class.dart';
import '../models/user.dart';
import '../repositories/students_repository.dart';

class ClassesScreen extends StatefulWidget {

  final User user;
  const ClassesScreen({Key? key, required this.user}) : super(key: key);

  @override
  _ClassesScreenState createState() => _ClassesScreenState();
}

class _ClassesScreenState extends State<ClassesScreen> {
  final TextEditingController _searchController = TextEditingController();
  final GlobalKey<NavigatorState> _navigatorKey = GlobalKey<NavigatorState>();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Navigator(
      key: _navigatorKey,
      onGenerateRoute: (settings) => MaterialPageRoute(
        builder: (context) => Scaffold(
          body: BlocBuilder<ClassesBloc, ClassesState>(
            builder: (context, state) {
              if (state.status == ClassesStatus.loading) {
                return const Center(child: CircularProgressIndicator());
              }

              if (state.filteredClasses.isEmpty) {
                return const Center(
                  child: Text(
                    'No classes found',
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                );
              }

              return ListView.builder(
                padding: const EdgeInsets.all(10),
                itemCount: state.filteredClasses.length,
                itemBuilder: (context, index) {
                  final cls = state.filteredClasses[index];
                  return ClassCard(classData: cls, user: widget.user);
                },
              );
            },
          ),
        ),
      ),
    );
  }

  void _showAddClassDialog(BuildContext context) {
    final nameController = TextEditingController();
    final subjectsController = TextEditingController();
    final instructorController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Add New Class'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildTextField(nameController, 'Class Name', 'Enter class name'),
              const SizedBox(height: 10),
              _buildTextField(subjectsController, 'Subjects', 'Math, Science'),
              const SizedBox(height: 10),
              _buildTextField(instructorController, 'Instructor (Optional)', ''),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                if (nameController.text.isNotEmpty && subjectsController.text.isNotEmpty) {
                  final newClass = Class(
                    id: DateTime.now().millisecondsSinceEpoch.toString(),
                    name: nameController.text,
                    staff: instructorController.text.isEmpty ? null : instructorController.text,
                  );

                  context.read<ClassesBloc>().add(AddClass(newClass));
                  Navigator.of(context).pop();
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Please fill in required fields')),
                  );
                }
              },
              child: const Text('Add'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, String hint) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        border: OutlineInputBorder(),
      ),
    );
  }
}

class ClassCard extends StatelessWidget {
  final Class classData;
  final User user;

  const ClassCard({super.key, required this.classData, required this.user});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 5),
      child: ListTile(
        onTap: () => _navigateToStudents(context),
        title: Text(
          classData.name,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: classData.staff != null
            ? Text('Instructor: ${classData.staff!}')
            : null,
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.people, color: Colors.blue),
              onPressed: () => _navigateToStudents(context),
              tooltip: 'View Students',
            ),
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: () {
                context.read<ClassesBloc>().add(DeleteClass(classData.id));
              },
            ),
          ],
        ),
      ),
    );
  }

  void _navigateToStudents(BuildContext context) {
    Navigator.of(context, rootNavigator: false).push(
      MaterialPageRoute(
        builder: (context) => BlocProvider(
          create: (context) => StudentsBloc(
            repository: context.read<StudentsRepository>(),
          ),
          child: StudentsScreen(
            standard: classData.name,
            classId: classData.id,
            userRole: user.userType,
          ),
        ),
      ),
    );
  }
}