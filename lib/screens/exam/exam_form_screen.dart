// lib/screens/exams/exam_form_screen.dart

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../bloc/exam/exam_bloc.dart';
import '../../bloc/exam/exam_event.dart';
import '../../bloc/exam/exam_state.dart';
import '../../models/exams.dart';
import '../../models/class.dart';
import '../../models/subject.dart';

class ExamFormScreen extends StatefulWidget {
  final Exam? exam;

  const ExamFormScreen({Key? key, this.exam}) : super(key: key);

  @override
  _ExamFormScreenState createState() => _ExamFormScreenState();
}

class _ExamFormScreenState extends State<ExamFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _durationController = TextEditingController();
  final _totalMarksController = TextEditingController();

  String _selectedClassId = '';
  String _selectedSubjectId = '';
  DateTime _selectedDate = DateTime.now().add(const Duration(days: 7));

  // Lists to hold API data
  List<Class> _classes = [];
  List<Subject> _subjects = [];
  bool _isDataLoaded = false;

  @override
  void initState() {
    super.initState();

    // Load classes and subjects when form initializes
    context.read<ExamBloc>().loadClassesAndSubjects();

    if (widget.exam != null) {
      _titleController.text = widget.exam!.name;
      _totalMarksController.text = widget.exam!.maxMarks.toString();
      _selectedClassId = widget.exam!.classId;
      _selectedSubjectId = widget.exam!.subjectId;
      _selectedDate = widget.exam!.date;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _durationController.dispose();
    _totalMarksController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 16,
        bottom: MediaQuery.of(context).viewInsets.bottom + 16,
      ),
      child: BlocConsumer<ExamBloc, ExamState>(
        listener: (context, state) {
          print('Current state: ${state.runtimeType}'); // Add logging

          if (state is ExamError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          } else if (state is ExamOperationSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.green,
              ),
            );

            // Add a small delay to ensure snackbar is shown
            Future.delayed(const Duration(milliseconds: 500), () {
              if (context.mounted) {
                Navigator.pop(context, true); // Return true to indicate success
              }
            });

          } else if (state is ClassesAndSubjectsLoaded) {
            setState(() {
              _classes = state.classes;
              _subjects = state.subjects;
              _isDataLoaded = true;
            });
          }
        },
        builder: (context, state) {
          // Your existing builder code
          if (state is ExamLoading && !_isDataLoaded) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Loading form data...'),
                ],
              ),
            );
          }

          return LayoutBuilder(
            builder: (context, constraints) {
              // Your existing layout builder code
              if (kIsWeb && constraints.maxWidth > 800) {
                return Row(
                  children: [
                    Expanded(
                      flex: 1,
                      child: Container(),
                    ),
                    Expanded(
                      flex: 2,
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.all(24.0),
                        child: _buildForm(),
                      ),
                    ),
                  ],
                );
              } else {
                return SingleChildScrollView(
                  padding: const EdgeInsets.all(16.0),
                  child: _buildForm(),
                );
              }
            },
          );
        },
      ),
    );
  }

  Widget _buildForm() {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildTitleField(),
          const SizedBox(height: 16),
          _buildDescriptionField(),
          const SizedBox(height: 16),
          _buildDateField(),
          const SizedBox(height: 16),
          _buildClassField(),
          const SizedBox(height: 16),
          _buildSubjectField(),
          const SizedBox(height: 16),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: _buildDurationField()),
              const SizedBox(width: 16),
              Expanded(child: _buildTotalMarksField()),
            ],
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _isDataLoaded ? _submitForm : null,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                child: Text(
                  widget.exam == null ? 'Create Exam' : 'Update Exam',
                  style: const TextStyle(fontSize: 16),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTitleField() {
    return TextFormField(
      controller: _titleController,
      decoration: const InputDecoration(
        labelText: 'Exam Title',
        border: OutlineInputBorder(),
        prefixIcon: Icon(Icons.title),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter an exam title';
        }
        return null;
      },
    );
  }

  Widget _buildDescriptionField() {
    return TextFormField(
      controller: _descriptionController,
      decoration: const InputDecoration(
        labelText: 'Description',
        border: OutlineInputBorder(),
        prefixIcon: Icon(Icons.description),
      ),
      maxLines: 3,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter a description';
        }
        return null;
      },
    );
  }

  Widget _buildDateField() {
    return InkWell(
      onTap: _pickDate,
      child: InputDecorator(
        decoration: const InputDecoration(
          labelText: 'Exam Date',
          border: OutlineInputBorder(),
          prefixIcon: Icon(Icons.calendar_today),
        ),
        child: Text(
          DateFormat('dd/MM/yyyy').format(_selectedDate),
        ),
      ),
    );
  }

  Widget _buildClassField() {
    return DropdownButtonFormField<String>(
      decoration: const InputDecoration(
        labelText: 'Class',
        border: OutlineInputBorder(),
        prefixIcon: Icon(Icons.class_),
      ),
      value: _selectedClassId.isNotEmpty ? _selectedClassId : null,
      items: _classes.map((classItem) {
        return DropdownMenuItem<String>(
          value: classItem.id,
          child: Text('${classItem.className}-${classItem.sectionName}'),
        );
      }).toList(),
      onChanged: (value) {
        setState(() {
          _selectedClassId = value!;
        });
      },
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please select a class';
        }
        return null;
      },
    );
  }

  Widget _buildSubjectField() {
    return DropdownButtonFormField<String>(
      decoration: const InputDecoration(
        labelText: 'Subject',
        border: OutlineInputBorder(),
        prefixIcon: Icon(Icons.subject),
      ),
      value: _selectedSubjectId.isNotEmpty ? _selectedSubjectId : null,
      items: _subjects.map((subject) {
        return DropdownMenuItem<String>(
          value: subject.id,
          child: Text(subject.name),
        );
      }).toList(),
      onChanged: (value) {
        setState(() {
          _selectedSubjectId = value!;
        });
      },
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please select a subject';
        }
        return null;
      },
    );
  }

  Widget _buildDurationField() {
    return TextFormField(
      controller: _durationController,
      decoration: const InputDecoration(
        labelText: 'Duration (minutes)',
        border: OutlineInputBorder(),
        prefixIcon: Icon(Icons.timer),
      ),
      keyboardType: TextInputType.number,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter duration';
        }
        if (int.tryParse(value) == null || int.parse(value) <= 0) {
          return 'Enter a valid duration';
        }
        return null;
      },
    );
  }

  Widget _buildTotalMarksField() {
    return TextFormField(
      controller: _totalMarksController,
      decoration: const InputDecoration(
        labelText: 'Total Marks',
        border: OutlineInputBorder(),
        prefixIcon: Icon(Icons.score),
      ),
      keyboardType: TextInputType.number,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter total marks';
        }
        if (double.tryParse(value) == null || double.parse(value) <= 0) {
          return 'Enter a valid marks value';
        }
        return null;
      },
    );
  }

  void _pickDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      // Format date as YYYY-MM-DD for API
      final formattedDate = DateFormat('yyyy-MM-dd').format(_selectedDate);

      if (kDebugMode) {
        print('Submitting exam with data:');
        print('Name: ${_titleController.text}');
        print('Subject ID: $_selectedSubjectId');
        print('Class ID: $_selectedClassId');
        print('Max Marks: ${_totalMarksController.text}');
        print('Date: $formattedDate');
        print('Duration: ${_durationController.text}');
        print('Description: ${_descriptionController.text}');
      }

      // Create Exam object - you might need to update your Exam model
      final exam = Exam(
        id: widget.exam?.id,
        name: _titleController.text,
        date: _selectedDate, // Keep as DateTime for internal use
        subjectId: _selectedSubjectId,
        classId: _selectedClassId,
        maxMarks: double.parse(_totalMarksController.text),
        // Add these fields to your Exam model if they don't exist
        // description: _descriptionController.text,
        // duration: int.parse(_durationController.text),
      );

      if (widget.exam == null) {
        context.read<ExamBloc>().add(CreateExam(exam));
      } else {
        context.read<ExamBloc>().add(UpdateExam(exam));
      }
    }
  }
}