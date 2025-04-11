import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../bloc/exam/exam_bloc.dart';
import '../../bloc/exam/exam_event.dart';
import '../../bloc/exam/exam_state.dart';
import '../../models/exams.dart';
import 'exam_form_screen.dart';

class ExamDetailScreen extends StatefulWidget {
  final String examId;

  const ExamDetailScreen({Key? key, required this.examId}) : super(key: key);

  @override
  _ExamDetailScreenState createState() => _ExamDetailScreenState();
}

class _ExamDetailScreenState extends State<ExamDetailScreen> {
  @override
  void initState() {
    super.initState();
    context.read<ExamBloc>().add(LoadExam(widget.examId));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Exam Details'),
        actions: [
          BlocBuilder<ExamBloc, ExamState>(
            builder: (context, state) {
              if (state is ExamLoaded) {
                return PopupMenuButton<String>(
                  onSelected: (value) {
                    switch (value) {
                      case 'edit':
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => ExamFormScreen(exam: state.exam),
                          ),
                        );
                        break;
                      case 'publish':
                        _confirmPublish(state.exam);
                        break;
                      case 'delete':
                        _confirmDelete(state.exam);
                        break;
                    }
                  },
                  itemBuilder: (BuildContext context) => [
                    const PopupMenuItem<String>(
                      value: 'edit',
                      child: ListTile(
                        leading: Icon(Icons.edit),
                        title: Text('Edit'),
                      ),
                    ),
                    if (state.exam.status.toLowerCase() == 'draft')
                      const PopupMenuItem<String>(
                        value: 'publish',
                        child: ListTile(
                          leading: Icon(Icons.publish),
                          title: Text('Publish'),
                        ),
                      ),
                    const PopupMenuItem<String>(
                      value: 'delete',
                      child: ListTile(
                        leading: Icon(Icons.delete, color: Colors.red),
                        title: Text('Delete', style: TextStyle(color: Colors.red)),
                      ),
                    ),
                  ],
                );
              }
              return Container();
            },
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
            if (state.message.contains('deleted')) {
              Navigator.pop(context);
            }
          }
        },
        builder: (context, state) {
          if (state is ExamLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is ExamLoaded) {
            return _buildExamDetails(state.exam);
          } else if (state is ExamError) {
            return Center(child: Text('Error: ${state.message}'));
          }
          return const Center(child: Text('No exam details available'));
        },
      ),
    );
  }

  Widget _buildExamDetails(Exam exam) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(exam),
          const SizedBox(height: 24),
          _buildInfoCard('General Information', [
            _buildInfoRow('Title', exam.title),
            _buildInfoRow('Description', exam.description),
            _buildInfoRow('Status', exam.status.toUpperCase(), isChip: true, chipColor: _getStatusColor(exam.status)),
          ]),
          const SizedBox(height: 16),
          _buildInfoCard('Exam Details', [
            _buildInfoRow('Date', _formatDate(exam.examDate)),
            _buildInfoRow('Duration', '${exam.duration} minutes'),
            _buildInfoRow('Total Marks', exam.totalMarks.toString()),
          ]),
          const SizedBox(height: 16),
          _buildInfoCard('Class & Subject', [
            _buildInfoRow('Class ID', exam.classId),
            _buildInfoRow('Subject ID', exam.subjectId),
          ]),
          if (exam.createdAt != null) ...[
            const SizedBox(height: 16),
            _buildInfoCard('Administrative', [
              if (exam.createdBy != null) _buildInfoRow('Created By', exam.createdBy!),
              _buildInfoRow('Created At', _formatDateTime(exam.createdAt!)),
            ]),
          ],
          const SizedBox(height: 24),
          // Here you could add sections for questions, results, etc.
        ],
      ),
    );
  }

  Widget _buildHeader(Exam exam) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            color: Theme.of(context).primaryColor.withOpacity(0.2),
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Icon(Icons.assignment, size: 32),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                exam.title,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                exam.description,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildInfoCard(String title, List<Widget> children) {
    return Card(
      elevation: 1,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).primaryColor,
              ),
            ),
            const Divider(),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, {bool isChip = false, Color? chipColor}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.grey[700],
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: isChip
                ? Chip(
              label: Text(
                value,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                ),
              ),
              backgroundColor: chipColor,
              padding: EdgeInsets.zero,
              labelPadding: const EdgeInsets.symmetric(horizontal: 8),
            )
                : Text(
              value,
              style: const TextStyle(
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(Exam exam) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Exam'),
        content: Text('Are you sure you want to delete "${exam.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              context.read<ExamBloc>().add(DeleteExam(exam.id!));
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _confirmPublish(Exam exam) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Publish Exam'),
        content: Text('Are you sure you want to publish "${exam.title}"? Once published, only minor edits will be allowed.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              context.read<ExamBloc>().add(PublishExam(exam.id!));
            },
            child: const Text('Publish'),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.day}/${dateTime.month}/${dateTime.year} ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'draft':
        return Colors.grey;
      case 'published':
        return Colors.blue;
      case 'completed':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }
}