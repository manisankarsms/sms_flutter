import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../bloc/exam/exam_bloc.dart';
import '../../bloc/exam/exam_event.dart';
import '../../bloc/exam/exam_state.dart';
import '../../models/exams.dart';
import 'exam_form_screen.dart';
import 'exam_detail_screen.dart';

class ExamsListScreen extends StatefulWidget {
  const ExamsListScreen({Key? key}) : super(key: key);

  @override
  _ExamsListScreenState createState() => _ExamsListScreenState();
}

class _ExamsListScreenState extends State<ExamsListScreen> {
  @override
  void initState() {
    super.initState();
    context.read<ExamBloc>().add(LoadExams());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Exams Management'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _showFilterOptions,
          ),
        ],
      ),
      body: BlocConsumer<ExamBloc, ExamState>(
        listener: (context, state) {
          if (state is ExamError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
          } else if (state is ExamOperationSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
          }
        },
        builder: (context, state) {
          if (state is ExamLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is ExamsLoaded) {
            return _buildExamsList(context, state.exams);
          } else if (state is ExamError) {
            return Center(child: Text('Error: ${state.message}'));
          }
          return const Center(child: Text('No exams available'));
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const ExamFormScreen(),
            ),
          );
        },
        child: const Icon(Icons.add),
        tooltip: 'Create new exam',
      ),
    );
  }

  void _showFilterOptions() {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Filter Exams',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              ListTile(
                leading: const Icon(Icons.class_),
                title: const Text('Filter by Class'),
                onTap: () {
                  // Show class selection dialog
                  Navigator.pop(context);
                  _showClassSelectionDialog();
                },
              ),
              ListTile(
                leading: const Icon(Icons.subject),
                title: const Text('Filter by Subject'),
                onTap: () {
                  // Show subject selection dialog
                  Navigator.pop(context);
                  _showSubjectSelectionDialog();
                },
              ),
              ListTile(
                leading: const Icon(Icons.clear_all),
                title: const Text('Clear Filters'),
                onTap: () {
                  Navigator.pop(context);
                  context.read<ExamBloc>().add(LoadExams());
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _showClassSelectionDialog() {
    // In a real app, you would fetch classes from your API
    final dummyClasses = [
      {'id': 'class1', 'name': 'Class 1'},
      {'id': 'class2', 'name': 'Class 2'},
      {'id': 'class3', 'name': 'Class 3'},
    ];

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Select Class'),
          content: SizedBox(
            width: double.maxFinite,
            height: 300,
            child: ListView.builder(
              itemCount: dummyClasses.length,
              itemBuilder: (context, index) {
                final classItem = dummyClasses[index];
                return ListTile(
                  title: Text(classItem['name']!),
                  onTap: () {
                    Navigator.pop(context);
                    context.read<ExamBloc>().add(
                      LoadExamsByClass(classItem['id']!),
                    );
                  },
                );
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
          ],
        );
      },
    );
  }

  void _showSubjectSelectionDialog() {
    // In a real app, you would fetch subjects from your API
    final dummySubjects = [
      {'id': 'subject1', 'name': 'Mathematics'},
      {'id': 'subject2', 'name': 'Science'},
      {'id': 'subject3', 'name': 'English'},
    ];

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Select Subject'),
          content: SizedBox(
            width: double.maxFinite,
            height: 300,
            child: ListView.builder(
              itemCount: dummySubjects.length,
              itemBuilder: (context, index) {
                final subject = dummySubjects[index];
                return ListTile(
                  title: Text(subject['name']!),
                  onTap: () {
                    Navigator.pop(context);
                    context.read<ExamBloc>().add(
                      LoadExamsBySubject(subject['id']!),
                    );
                  },
                );
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildExamsList(BuildContext context, List<Exam> exams) {
    if (exams.isEmpty) {
      return const Center(child: Text('No exams found'));
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16.0),
      itemCount: exams.length,
      separatorBuilder: (context, index) => const Divider(),
      itemBuilder: (context, index) {
        final exam = exams[index];
        return Card(
          elevation: 2,
          child: ListTile(
            title: Text(
              exam.title,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 4),
                Text(
                  'Date: ${_formatDate(exam.examDate)}',
                  style: const TextStyle(fontSize: 12),
                ),
                Text(
                  'Duration: ${exam.duration} minutes',
                  style: const TextStyle(fontSize: 12),
                ),
              ],
            ),
            trailing: _buildStatusChip(exam.status),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ExamDetailScreen(examId: exam.id!),
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildStatusChip(String status) {
    Color chipColor;
    switch (status.toLowerCase()) {
      case 'draft':
        chipColor = Colors.grey;
        break;
      case 'published':
        chipColor = Colors.blue;
        break;
      case 'completed':
        chipColor = Colors.green;
        break;
      default:
        chipColor = Colors.grey;
    }

    return Chip(
      label: Text(
        status,
        style: const TextStyle(color: Colors.white, fontSize: 12),
      ),
      backgroundColor: chipColor,
      padding: EdgeInsets.zero,
      labelPadding: const EdgeInsets.symmetric(horizontal: 8),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}