import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sms/repositories/class_repository.dart';

import '../bloc/classes/classes_bloc.dart';
import '../bloc/classes/classes_event.dart';
import '../bloc/classes/classes_state.dart';
import '../models/class.dart';

class ClassesScreen extends StatelessWidget {
  const ClassesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ClassRepository classRepository = ClassRepository(); // Create an instance of AuthRepository

    return BlocProvider(
      create: (context) => ClassesBloc(classRepository),
      child: ClassesView(),
    );
  }
}

class ClassesView extends StatefulWidget {
  @override
  _ClassesViewState createState() => _ClassesViewState();
}

class _ClassesViewState extends State<ClassesView> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Classes'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search classes...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                filled: true,
                fillColor: Colors.white,
              ),
              onChanged: (query) {
                BlocProvider.of<ClassesBloc>(context).add(SearchClasses(query));
              },
            ),
          ),
        ),
      ),
      body: BlocBuilder<ClassesBloc, ClassesState>(
        builder: (context, state) {
          if (state.status == ClassesStatus.loading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state.filteredClasses.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.class_, size: 100, color: Colors.grey),
                  const SizedBox(height: 20),
                  Text(
                    'No classes found',
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            itemCount: state.filteredClasses.length,
            itemBuilder: (context, index) {
              final cls = state.filteredClasses[index];
              return ClassCard(classData: cls);
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddClassDialog(context),
        child: const Icon(Icons.add),
        tooltip: 'Add New Class',
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
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Class Name',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: subjectsController,
                decoration: const InputDecoration(
                  labelText: 'Subjects (comma-separated)',
                  border: OutlineInputBorder(),
                  hintText: 'e.g. Math, Algebra',
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: instructorController,
                decoration: const InputDecoration(
                  labelText: 'Instructor (Optional)',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                if (nameController.text.isNotEmpty &&
                    subjectsController.text.isNotEmpty) {
                  final newClass = Class(
                    id: DateTime.now().millisecondsSinceEpoch.toString(),
                    name: nameController.text,
                    subjects: subjectsController.text
                        .split(',')
                        .map((s) => s.trim())
                        .toList(),
                    instructor: instructorController.text.isEmpty
                        ? null
                        : instructorController.text,
                  );

                  BlocProvider.of<ClassesBloc>(context).add(AddClass(newClass));
                  Navigator.of(context).pop();
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Please fill in all required fields')),
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
}

class ClassCard extends StatelessWidget {
  final Class classData;

  const ClassCard({required this.classData});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      child: ListTile(
        key: ValueKey(classData.id),
        title: Text(
          classData.name,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Subjects: ${classData.subjects.join(", ")}'),
            if (classData.instructor != null)
              Text('Instructor: ${classData.instructor!}'),
          ],
        ),
        trailing: IconButton(
          icon: const Icon(Icons.delete, color: Colors.red),
          onPressed: () {
            BlocProvider.of<ClassesBloc>(context).add(DeleteClass(classData.id));
          },
        ),
      ),
    );
  }
}
