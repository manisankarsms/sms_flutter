import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sms/models/staff_subject_assignment.dart';
import 'package:sms/screens/students_screen.dart';

import '../bloc/classes/classes_bloc.dart';
import '../bloc/class_details/class_details_bloc.dart';
import '../bloc/class_details/class_details_event.dart';
import '../bloc/class_details/class_details_state.dart';
import '../bloc/students/students_bloc.dart';
import '../models/class.dart';
import '../models/subject.dart';
import '../models/user.dart';
import '../repositories/class_repository.dart';
import '../repositories/class_details_repository.dart';
import '../repositories/students_repository.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class ClassDetailsScreen extends StatelessWidget {
  final Class classData;
  final User user;

  const ClassDetailsScreen({Key? key, required this.classData, required this.user}) : super(key: key);

  bool get isAdmin => ['Admin', 'ADMIN', 'PRINCIPAL'].contains(user.role);

  @override
  Widget build(BuildContext context) {
    // Load all data
    final bloc = context.read<ClassDetailsBloc>();
    bloc.add(LoadClassTeachers(classData.id));
    bloc.add(LoadClassSubjects(classData.id));
    bloc.add(LoadStaffSubjects(classData.id));

    return Scaffold(
      appBar: AppBar(
        title: Text('${classData.className} Details'),
        elevation: 0,
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          bloc.add(LoadClassTeachers(classData.id));
          bloc.add(LoadClassSubjects(classData.id));
          bloc.add(LoadStaffSubjects(classData.id));
        },
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              _buildClassInfo(),
              const SizedBox(height: 16),
              _buildClassTeacher(context),
              const SizedBox(height: 16),
              _buildSubjects(context),
              const SizedBox(height: 16),
              _buildSubjectTeachers(context),
              const SizedBox(height: 80), // Space for FAB
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _navigateToStudents(context),
        icon: const Icon(Icons.people),
        label: const Text('View Students'),
      ),
    );
  }

  Widget _buildClassInfo() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Class Information', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            _infoRow('Class', classData.className),
            _infoRow('Academic Year', classData.academicYearName ?? 'N/A'),
          ],
        ),
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Text('$label: ', style: TextStyle(fontWeight: FontWeight.w500)),
          Text(value),
        ],
      ),
    );
  }

  Widget _buildClassTeacher(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Class Teacher', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                if (isAdmin)
                  IconButton(
                    icon: const Icon(Icons.person_add),
                    onPressed: () => _showTeacherDialog(context),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            BlocBuilder<ClassDetailsBloc, ClassDetailsState>(
              buildWhen: (p, c) => c is ClassTeacherLoaded || c is TeacherAssignmentSuccess,
              builder: (context, state) {
                if (state is ClassTeacherLoaded) {
                  return state.teacher != null
                      ? _teacherTile(context, state.teacher!)
                      : _emptyState(Icons.person_outline, 'No class teacher assigned');
                }
                return const CircularProgressIndicator();
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSubjects(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Subjects', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                if (isAdmin)
                  ElevatedButton.icon(
                    icon: const Icon(Icons.add, size: 16),
                    label: const Text('Add'),
                    onPressed: () => _showSubjectsDialog(context),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            BlocBuilder<ClassDetailsBloc, ClassDetailsState>(
              buildWhen: (p, c) => c is ClassSubjectsLoaded || c is SubjectAssignmentSuccess,
              builder: (context, state) {
                if (state is ClassSubjectsLoaded) {
                  return state.subjects.isEmpty
                      ? _emptyState(Icons.book_outlined, 'No subjects assigned')
                      : Column(
                    children: state.subjects.map((s) => _subjectTile(context, s)).toList(),
                  );
                }
                return const CircularProgressIndicator();
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSubjectTeachers(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Subject Teachers', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            BlocBuilder<ClassDetailsBloc, ClassDetailsState>(
              buildWhen: (p, c) => c is StaffSubjectsLoaded || c is SubjectStaffAssignmentSuccess,
              builder: (context, state) {
                if (state is StaffSubjectsLoaded) {
                  return state.subjects.isEmpty
                      ? _emptyState(Icons.assignment_outlined, 'Add subjects first to assign teachers')
                      : Column(
                    children: state.subjects.map((s) => _subjectTeacherTile(context, s)).toList(),
                  );
                }
                return const CircularProgressIndicator();
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _teacherTile(BuildContext context, User teacher) {
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: Colors.green.shade100,
        child: Icon(Icons.person, color: Colors.green.shade700),
      ),
      title: Text('${teacher.firstName} ${teacher.lastName}'),
      subtitle: Text(teacher.email ?? ''),
      trailing: isAdmin ? IconButton(
        icon: Icon(Icons.remove_circle, color: Colors.red),
        onPressed: () => _confirmRemove(
          context,
          'Remove class teacher?',
              () => context.read<ClassDetailsBloc>().add(RemoveTeacherFromClass(classData.id, teacher.id)),
        ),
      ) : null,
    );
  }

  Widget _subjectTile(BuildContext context, Subject subject) {
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: Colors.blue.shade100,
        child: Icon(Icons.book, color: Colors.blue.shade700),
      ),
      title: Text(subject.name),
      subtitle: subject.code != null ? Text('Code: ${subject.code}') : null,
      trailing: isAdmin ? IconButton(
        icon: Icon(Icons.remove_circle, color: Colors.red),
        onPressed: () => _confirmRemove(
          context,
          'Remove subject from class?',
              () => context.read<ClassDetailsBloc>().add(RemoveSubjectFromClass(subject.classSubjectId, classData.id)),
        ),
      ) : null,
    );
  }

  Widget _subjectTeacherTile(BuildContext context, StaffSubjectAssignment assignment) {
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: Colors.purple.shade100,
        child: Icon(Icons.assignment_ind, color: Colors.purple.shade700),
      ),
      title: Text(assignment.subjectName),
      subtitle: Text(
        assignment.staffName ?? 'No teacher assigned',
        style: TextStyle(
          color: assignment.staffName != null ? Colors.green : Colors.orange,
        ),
      ),
      trailing: isAdmin ? PopupMenuButton<String>(
        onSelected: (value) {
          if (value == 'assign') {
            _showAssignTeacherDialog(context, assignment);
          } else if (value == 'remove') {
            _confirmRemove(
              context,
              'Remove teacher from subject?',
                  () => context.read<ClassDetailsBloc>().add(RemoveStaffFromSubject(assignment.id, classData.id)),
            );
          }
        },
        itemBuilder: (context) => [
          PopupMenuItem(
            value: 'assign',
            child: Row(
              children: [
                Icon(Icons.person_add, size: 16),
                const SizedBox(width: 8),
                Text(assignment.staffName != null ? 'Change Teacher' : 'Assign Teacher'),
              ],
            ),
          ),
          if (assignment.staffName != null)
            PopupMenuItem(
              value: 'remove',
              child: Row(
                children: [
                  Icon(Icons.person_remove, size: 16, color: Colors.red),
                  const SizedBox(width: 8),
                  Text('Remove Teacher'),
                ],
              ),
            ),
        ],
      ) : null,
    );
  }

  Widget _emptyState(IconData icon, String message) {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          Icon(icon, size: 48, color: Colors.grey[400]),
          const SizedBox(height: 8),
          Text(message, style: TextStyle(color: Colors.grey[600])),
        ],
      ),
    );
  }

  void _showTeacherDialog(BuildContext context) {
    context.read<ClassDetailsBloc>().add(LoadStaffList());
    _showDialog(
      context,
      'Assign Class Teacher',
      BlocBuilder<ClassDetailsBloc, ClassDetailsState>(
        builder: (context, state) {
          if (state is StaffListLoaded) {
            return _staffList(context, state.staffList, (staff) {
              context.read<ClassDetailsBloc>().add(AssignTeacherToClass(classData.id, staff.id));
              Navigator.pop(context);
            });
          }
          return const CircularProgressIndicator();
        },
      ),
    );
  }

  void _showSubjectsDialog(BuildContext context) {
    context.read<ClassDetailsBloc>().add(LoadAvailableSubjects());
    _showDialog(
      context,
      'Add Subjects',
      _BulkSubjectDialog(classId: classData.id),
    );
  }

  void _showAssignTeacherDialog(BuildContext context, StaffSubjectAssignment assignment) {
    context.read<ClassDetailsBloc>().add(LoadStaffList());
    _showDialog(
      context,
      'Assign Teacher to ${assignment.subjectName}',
      BlocBuilder<ClassDetailsBloc, ClassDetailsState>(
        builder: (context, state) {
          if (state is StaffListLoaded) {
            return _staffList(context, state.staffList, (staff) {
              context.read<ClassDetailsBloc>().add(
                  AssignStaffToSubject(classData.id, staff.id, assignment.classSubjectId)
              );
              Navigator.pop(context);
            });
          }
          return const CircularProgressIndicator();
        },
      ),
    );
  }

  Widget _staffList(BuildContext context, List<User> staff, Function(User) onTap) {
    return SizedBox(
      height: 300,
      width: double.maxFinite,
      child: ListView.builder(
        itemCount: staff.length,
        itemBuilder: (context, index) {
          final person = staff[index];
          return ListTile(
            title: Text('${person.firstName} ${person.lastName}'),
            subtitle: Text(person.email ?? ''),
            trailing: IconButton(
              icon: const Icon(Icons.add),
              onPressed: () => onTap(person),
            ),
          );
        },
      ),
    );
  }

  void _showDialog(BuildContext context, String title, Widget content) {
    showDialog(
      context: context,
      builder: (dialogContext) => BlocProvider.value(
        value: context.read<ClassDetailsBloc>(),
        child: AlertDialog(
          title: Text(title),
          content: content,
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancel'),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmRemove(BuildContext context, String message, VoidCallback onConfirm) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm'),
        content: Text(message),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              onConfirm();
              Navigator.pop(context);
            },
            child: const Text('Remove', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _navigateToStudents(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => BlocProvider(
          create: (context) => StudentsBloc(repository: context.read<StudentsRepository>()),
          child: StudentsScreen(
            standard: classData.className,
            classId: classData.id,
            userRole: user.role,
          ),
        ),
      ),
    );
  }
}

class _BulkSubjectDialog extends StatefulWidget {
  final String classId;
  const _BulkSubjectDialog({required this.classId});

  @override
  State<_BulkSubjectDialog> createState() => _BulkSubjectDialogState();
}

class _BulkSubjectDialogState extends State<_BulkSubjectDialog> {
  final Set<String> selected = {};

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (selected.isNotEmpty)
          Container(
            padding: const EdgeInsets.all(8),
            margin: const EdgeInsets.only(bottom: 8),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text('${selected.length} selected', style: TextStyle(color: Colors.blue.shade700)),
          ),
        SizedBox(
          height: 300,
          width: double.maxFinite,
          child: BlocBuilder<ClassDetailsBloc, ClassDetailsState>(
            builder: (context, state) {
              if (state is AvailableSubjectsLoaded) {
                return ListView.builder(
                  itemCount: state.availableSubjects.length,
                  itemBuilder: (context, index) {
                    final subject = state.availableSubjects[index];
                    return CheckboxListTile(
                      value: selected.contains(subject.id),
                      onChanged: (value) {
                        setState(() {
                          value! ? selected.add(subject.id) : selected.remove(subject.id);
                        });
                      },
                      title: Text(subject.name),
                      subtitle: subject.code != null ? Text(subject.code!) : null,
                    );
                  },
                );
              }
              return const CircularProgressIndicator();
            },
          ),
        ),
        const SizedBox(height: 16),
        ElevatedButton(
          onPressed: selected.isEmpty ? null : () {
            context.read<ClassDetailsBloc>().add(BulkAssignSubjectsToClass(widget.classId, selected.toList()));
            Navigator.pop(context);
          },
          child: Text('Add ${selected.length} Subject(s)'),
        ),
      ],
    );
  }
}