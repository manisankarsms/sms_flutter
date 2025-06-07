import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sms/screens/students_screen.dart';
import 'package:fl_chart/fl_chart.dart';

import '../bloc/classes/classes_bloc.dart';
import '../bloc/classes/classes_event.dart';
import '../bloc/classes/classes_state.dart';
import '../bloc/students/students_bloc.dart';
import '../models/class.dart';
import '../models/user.dart';
import '../models/subject.dart';
import '../repositories/students_repository.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class ClassDetailsScreen extends StatelessWidget {
  final Class classData;
  final User user;

  const ClassDetailsScreen({Key? key, required this.classData, required this.user}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${classData.className} ${AppLocalizations.of(context)?.details ?? 'Details'}'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Class information section
              Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300, width: 1),
                  borderRadius: BorderRadius.circular(10),
                ),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Instructor row
                    Row(
                      children: [
                        Text(
                          '${AppLocalizations.of(context)?.instructor ?? 'Instructor'}: ',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          classData.staff ?? (AppLocalizations.of(context)?.not_assigned ?? 'Not assigned'),
                          style: const TextStyle(fontSize: 16),
                        ),
                        const Spacer(),
                        IconButton(
                          icon: const Icon(Icons.edit, size: 20),
                          onPressed: () => _showEditClassDialog(context),
                          constraints: const BoxConstraints(),
                          padding: EdgeInsets.zero,
                          tooltip: AppLocalizations.of(context)?.edit ?? 'Edit',
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Subjects row
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${AppLocalizations.of(context)?.subjects ?? 'Subjects'}: ',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            classData.subjectNames != null && classData.subjectNames!.isNotEmpty
                                ? classData.subjectNames!.join(', ')
                                : (AppLocalizations.of(context)?.not_assigned ?? 'Not assigned'),
                            style: const TextStyle(fontSize: 16),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              // Two-column layout for Analytics and Top Performers
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Left column - Analytics
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          AppLocalizations.of(context)?.analytics ?? 'Analytics',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        _buildPieChart(context),
                      ],
                    ),
                  ),

                  const SizedBox(width: 20),

                  // Right column - Top performers
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          AppLocalizations.of(context)?.top_performers ?? 'Top Performers',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        _buildTopPerformersList(context),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _navigateToStudents(context),
        icon: const Icon(Icons.people),
        label: Text(AppLocalizations.of(context)?.view_students ?? 'View Students'),
      ),
    );
  }

  Widget _buildPieChart(BuildContext context) {
    return Container(
      height: 240,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300, width: 1),
        borderRadius: BorderRadius.circular(10),
      ),
      padding: const EdgeInsets.all(16),
      child: PieChart(
        PieChartData(
          sections: [
            PieChartSectionData(
              color: Colors.blue.shade300,
              value: 35,
              title: 'Boys',
              titleStyle: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
              radius: 60,
            ),
            PieChartSectionData(
              color: Colors.blue.shade200,
              value: 40,
              title: 'Girls',
              titleStyle: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
              radius: 60,
            ),
            PieChartSectionData(
              color: Colors.blue.shade100,
              value: 25,
              title: 'Others',
              titleStyle: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
              radius: 60,
            ),
          ],
          sectionsSpace: 0,
          centerSpaceRadius: 40,
          startDegreeOffset: 180,
        ),
      ),
    );
  }

  Widget _buildTopPerformersList(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300, width: 1),
        borderRadius: BorderRadius.circular(10),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildPerformerItem(context, rank: 1, name: 'Manisankar'),
          const Divider(height: 24),
          _buildPerformerItem(context, rank: 2, name: 'M2'),
          const Divider(height: 24),
          _buildPerformerItem(context, rank: 3, name: 'M3'),
        ],
      ),
    );
  }

  Widget _buildPerformerItem(BuildContext context, {required int rank, required String name}) {
    return Row(
      children: [
        Text(
          '$rank.',
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            name,
            style: const TextStyle(
              fontSize: 16,
            ),
          ),
        ),
      ],
    );
  }

  void _showEditClassDialog(BuildContext context) {
    // Controllers for simple text fields
    final nameController = TextEditingController(text: classData.className);

    // Selected values for dropdowns
    String? selectedInstructorId = classData.staffId;
    List<String> selectedSubjectIds = List.from(classData.subjectIds ?? []);

    // Get the ClassesBloc instance before opening the dialog
    final classesBloc = context.read<ClassesBloc>();

    // Fetch staff and subjects data
    classesBloc.add(const FetchStaffAndSubjects());

    showDialog(
      context: context,
      builder: (dialogContext) {
        // Provide the ClassesBloc to the dialog's widget tree
        return BlocProvider.value(
          value: classesBloc, // Reuse the existing bloc
          child: StatefulBuilder(
            builder: (context, setState) {
              return BlocBuilder<ClassesBloc, ClassesState>(
                builder: (context, state) {
                  // Handle different states
                  if (state is StaffAndSubjectsLoading) {
                    return AlertDialog(
                      title: Text(AppLocalizations.of(context)?.edit_class ?? 'Edit Class'),
                      content: Container(
                        height: 100,
                        alignment: Alignment.center,
                        child: const CircularProgressIndicator(),
                      ),
                    );
                  } else if (state is StaffAndSubjectsLoaded) {
                    // Data is loaded, build the form
                    return AlertDialog(
                      title: Text(AppLocalizations.of(context)?.edit_class ?? 'Edit Class'),
                      content: SingleChildScrollView(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Class Name field
                            TextField(
                              controller: nameController,
                              decoration: InputDecoration(
                                labelText: AppLocalizations.of(context)?.class_name ?? 'Class Name',
                                border: const OutlineInputBorder(),
                              ),
                            ),
                            const SizedBox(height: 16),

                            // Instructor Dropdown
                            Text(
                              AppLocalizations.of(context)?.instructor ?? 'Instructor',
                              style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                            ),
                            const SizedBox(height: 8),
                            Container(
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: DropdownButtonHideUnderline(
                                child: DropdownButton<String>(
                                  value: selectedInstructorId,
                                  isExpanded: true,
                                  hint: Text(AppLocalizations.of(context)?.select_instructor ?? 'Select Instructor'),
                                  padding: const EdgeInsets.symmetric(horizontal: 12),
                                  items: [
                                    // Add a "None" option
                                    const DropdownMenuItem<String>(
                                      value: null,
                                      child: Text('None'),
                                    ),
                                    // Add staff members from API
                                    ...state.staff.map((staff) {
                                      return DropdownMenuItem<String>(
                                        value: staff.id,
                                        child: Text('${staff.firstName} ${staff.lastName}'),
                                      );
                                    }).toList(),
                                  ],
                                  onChanged: (String? newValue) {
                                    setState(() {
                                      selectedInstructorId = newValue;
                                    });
                                  },
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),

                            // Subjects Multiselect
                            Text(
                              AppLocalizations.of(context)?.subjects ?? 'Subjects',
                              style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                            ),
                            const SizedBox(height: 8),
                            Container(
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              constraints: const BoxConstraints(
                                maxHeight: 200,
                              ),
                              child: SingleChildScrollView(
                                child: Column(
                                  children: state.subjects.map((subject) {
                                    final isSelected = selectedSubjectIds.contains(subject.id);

                                    return CheckboxListTile(
                                      title: Text(subject.name),
                                      subtitle: Text(subject.code),
                                      value: isSelected,
                                      onChanged: (bool? value) {
                                        setState(() {
                                          if (value == true) {
                                            selectedSubjectIds.add(subject.id);
                                          } else {
                                            selectedSubjectIds.remove(subject.id);
                                          }
                                        });
                                      },
                                      dense: true,
                                      controlAffinity: ListTileControlAffinity.leading,
                                    );
                                  }).toList(),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.of(dialogContext).pop(),
                          child: Text(AppLocalizations.of(context)?.cancel ?? 'Cancel'),
                        ),
                        ElevatedButton(
                          onPressed: () {
                            if (nameController.text.isNotEmpty) {
                              // Get staff name from staff ID
                              String? staffName;
                              if (selectedInstructorId != null) {
                                final selectedStaff = state.staff.firstWhere(
                                      (staff) => staff.id == selectedInstructorId,
                                  orElse: () => User(
                                    id: '',
                                    email: '',
                                    mobileNumber: '',
                                    role: '',
                                    firstName: '',
                                    lastName: '', permissions: [],
                                  ),
                                );
                                staffName = selectedStaff.id.isNotEmpty
                                    ? '${selectedStaff.firstName} ${selectedStaff.lastName}'
                                    : null;
                              }

                              // Get subject names from subject IDs
                              List<String> subjectNames = selectedSubjectIds.map((id) {
                                final subject = state.subjects.firstWhere(
                                      (subject) => subject.id == id,
                                  orElse: () => Subject(id: '', name: '', code: ''),
                                );
                                return subject.name;
                              }).where((name) => name.isNotEmpty).toList();

                              final updatedClass = Class(
                                id: classData.id,
                                className: nameController.text,
                                sectionName: nameController.text,
                                academicYearId: classData.academicYearId,
                                academicYearName: classData.academicYearName,
                              );

                              // Update class in the bloc using the context from BlocProvider.value
                              context.read<ClassesBloc>().add(UpdateClass(updatedClass));

                              // Close dialog and pass back the updated class
                              Navigator.of(dialogContext).pop(updatedClass);
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text(AppLocalizations.of(context)?.class_name_required ?? 'Class name is required')),
                              );
                            }
                          },
                          child: Text(AppLocalizations.of(context)?.save ?? 'Save'),
                        ),
                      ],
                    );
                  } else if (state is ClassesError) {
                    // Show error message
                    return AlertDialog(
                      title: const Text('Error'),
                      content: Text(state.errorMessage),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.of(dialogContext).pop(),
                          child: Text(AppLocalizations.of(context)?.close ?? 'Close'),
                        ),
                      ],
                    );
                  } else {
                    // Fallback dialog (initial state or other states)
                    return AlertDialog(
                      title: Text(AppLocalizations.of(context)?.edit_class ?? 'Edit Class'),
                      content: const Text('Loading data...'),
                    );
                  }
                },
              );
            },
          ),
        );
      },
    ).then((updatedClassResult) {
      // After dialog closes, if we have an updated class, use it to update the UI
      if (updatedClassResult != null && updatedClassResult is Class) {
        // Since ClassDetailsScreen is a StatelessWidget, we need to refresh the screen
        // by replacing the current route with a new one that has the updated data
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => ClassDetailsScreen(
              classData: updatedClassResult,
              user: user,
            ),
          ),
        );
      }
    });
  }

  void _navigateToStudents(BuildContext context) {
    Navigator.of(context, rootNavigator: false).push(
      MaterialPageRoute(
        builder: (context) => BlocProvider(
          create: (context) => StudentsBloc(
            repository: context.read<StudentsRepository>(),
          ),
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