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

  String? _selectedExamName;
  String _selectedClassId = '';
  String _selectedSubjectId = '';
  DateTime _selectedDate = DateTime.now().add(const Duration(days: 7));
  TimeOfDay _selectedTime = const TimeOfDay(hour: 9, minute: 0);

  // Lists to hold API data
  List<String> _examNames = [];
  List<Class> _classes = [];
  List<Subject> _subjects = [];
  bool _isDataLoaded = false;
  bool _isNewExamName = false;

  // Predefined exam names
  final List<String> _predefinedExamNames = [
  ];

  @override
  void initState() {
    super.initState();

    // Load classes and subjects when form initializes
    context.read<ExamBloc>().loadClassesAndSubjects();

    // Load existing exam names
    context.read<ExamBloc>().add(LoadExams());

    if (widget.exam != null) {
      _populateFormWithExistingData();
    }
  }

  void _populateFormWithExistingData() {
    final exam = widget.exam!;
    _titleController.text = exam.name;
    _totalMarksController.text = exam.maxMarks.toString();
    _selectedClassId = exam.classId;
    _selectedSubjectId = exam.subjectId;
    _selectedDate = exam.date;
    _selectedExamName = exam.name;

    // Extract time from the exam date
    _selectedTime = TimeOfDay.fromDateTime(exam.date);
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
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.exam == null ? 'Create Exam' : 'Edit Exam'),
        elevation: 0,
        backgroundColor: Theme.of(context).colorScheme.surface,
        foregroundColor: Theme.of(context).colorScheme.onSurface,
      ),
      body: BlocConsumer<ExamBloc, ExamState>(
        listener: (context, state) {
          if (kDebugMode) {
            print('Current state: ${state.runtimeType}');
          }

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

            Future.delayed(const Duration(milliseconds: 500), () {
              if (context.mounted) {
                Navigator.pop(context, true);
              }
            });
          } else if (state is ClassesAndSubjectsLoaded) {
            setState(() {
              _classes = state.classes;
              _subjects = state.subjects;
              _isDataLoaded = true;
            });
          } else if (state is ExamNamesLoaded) {
            setState(() {
              _examNames = state.examNames;
            });
          }
        },
        builder: (context, state) {
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
              if (kIsWeb && constraints.maxWidth > 800) {
                return _buildWebLayout();
              } else {
                return _buildMobileLayout();
              }
            },
          );
        },
      ),
    );
  }

  Widget _buildWebLayout() {
    return Row(
      children: [
        Expanded(flex: 1, child: Container()),
        Expanded(
          flex: 2,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: _buildForm(),
          ),
        ),
        Expanded(flex: 1, child: Container()),
      ],
    );
  }

  Widget _buildMobileLayout() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: _buildForm(),
    );
  }

  Widget _buildForm() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildFormHeader(),
              const SizedBox(height: 32),
              _buildExamNameSection(),
              const SizedBox(height: 24),
              _buildBasicInfoSection(),
              const SizedBox(height: 24),
              _buildDateTimeSection(),
              const SizedBox(height: 24),
              _buildClassificationSection(),
              const SizedBox(height: 24),
              _buildExamDetailsSection(),
              const SizedBox(height: 32),
              _buildSubmitButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFormHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              widget.exam == null ? Icons.add_circle : Icons.edit,
              size: 32,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(width: 12),
            Text(
              widget.exam == null ? 'Create New Exam' : 'Edit Exam',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          widget.exam == null
              ? 'Fill in the details below to create a new exam'
              : 'Update the exam information as needed',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }

  Widget _buildExamNameSection() {
    return _buildSection(
      title: 'Exam Information',
      icon: Icons.assignment,
      children: [
        _buildExamNameDropdown(),
        if (_isNewExamName) ...[
          const SizedBox(height: 16),
          _buildTitleField(),
        ],
        const SizedBox(height: 16),
        _buildDescriptionField(),
      ],
    );
  }

  Widget _buildBasicInfoSection() {
    return _buildSection(
      title: 'Basic Information',
      icon: Icons.info,
      children: [
        Row(
          children: [
            Expanded(child: _buildTotalMarksField()),
            const SizedBox(width: 16),
            Expanded(child: _buildDurationField()),
          ],
        ),
      ],
    );
  }

  Widget _buildDateTimeSection() {
    return _buildSection(
      title: 'Schedule',
      icon: Icons.schedule,
      children: [
        Row(
          children: [
            Expanded(flex: 2, child: _buildDateField()),
            const SizedBox(width: 16),
            Expanded(flex: 1, child: _buildTimeField()),
          ],
        ),
      ],
    );
  }

  Widget _buildClassificationSection() {
    return _buildSection(
      title: 'Classification',
      icon: Icons.category,
      children: [
        Row(
          children: [
            Expanded(child: _buildClassField()),
            const SizedBox(width: 16),
            Expanded(child: _buildSubjectField()),
          ],
        ),
      ],
    );
  }

  Widget _buildExamDetailsSection() {
    return _buildSection(
      title: 'Additional Details',
      icon: Icons.settings,
      children: [
        _buildInstructionsField(),
      ],
    );
  }

  Widget _buildSection({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              icon,
              size: 20,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(width: 8),
            Text(
              title,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        ...children,
      ],
    );
  }

  Widget _buildExamNameDropdown() {
    final allExamNames = [..._predefinedExamNames, ..._examNames].toSet().toList();
    allExamNames.add('Create New Exam Name');

    return DropdownButtonFormField<String>(
      decoration: InputDecoration(
        labelText: 'Exam Name *',
        hintText: 'Select or create exam name',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        prefixIcon: const Icon(Icons.quiz),
        filled: true,
        fillColor: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.3),
      ),
      value: _selectedExamName,
      items: allExamNames.map((name) {
        return DropdownMenuItem<String>(
          value: name,
          child: Text(
            name,
            style: TextStyle(
              fontStyle: name == 'Create New Exam Name'
                  ? FontStyle.italic
                  : FontStyle.normal,
              color: name == 'Create New Exam Name'
                  ? Theme.of(context).colorScheme.primary
                  : null,
            ),
          ),
        );
      }).toList(),
      onChanged: (value) {
        setState(() {
          _selectedExamName = value;
          _isNewExamName = value == 'Create New Exam Name';
          if (!_isNewExamName && value != null) {
            _titleController.text = value;
          } else if (_isNewExamName) {
            _titleController.clear();
          }
        });
      },
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please select an exam name';
        }
        if (value == 'Create New Exam Name' && _titleController.text.trim().isEmpty) {
          return 'Please enter a custom exam name';
        }
        return null;
      },
    );
  }

  Widget _buildTitleField() {
    return TextFormField(
      controller: _titleController,
      decoration: InputDecoration(
        labelText: 'Custom Exam Name *',
        hintText: 'Enter custom exam name',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        prefixIcon: const Icon(Icons.create),
        filled: true,
        fillColor: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.3),
      ),
      validator: (value) {
        if (_isNewExamName && (value == null || value.trim().isEmpty)) {
          return 'Please enter a custom exam name';
        }
        return null;
      },
    );
  }

  Widget _buildDescriptionField() {
    return TextFormField(
      controller: _descriptionController,
      decoration: InputDecoration(
        labelText: 'Description',
        hintText: 'Enter exam description or instructions',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        prefixIcon: const Icon(Icons.description),
        filled: true,
        fillColor: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.3),
      ),
      maxLines: 3,
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
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
        decoration: InputDecoration(
          labelText: 'Exam Date *',
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          prefixIcon: const Icon(Icons.calendar_today),
          filled: true,
          fillColor: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.3),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              DateFormat('dd MMM yyyy, EEEE').format(_selectedDate),
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const Icon(Icons.arrow_drop_down),
          ],
        ),
      ),
    );
  }

  Widget _buildTimeField() {
    return InkWell(
      onTap: _pickTime,
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: 'Start Time *',
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          prefixIcon: const Icon(Icons.access_time),
          filled: true,
          fillColor: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.3),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              _selectedTime.format(context),
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const Icon(Icons.arrow_drop_down),
          ],
        ),
      ),
    );
  }

  Widget _buildClassField() {
    return DropdownButtonFormField<String>(
      decoration: InputDecoration(
        labelText: 'Class *',
        hintText: 'Select class',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        prefixIcon: const Icon(Icons.class_),
        filled: true,
        fillColor: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.3),
      ),
      value: _selectedClassId.isNotEmpty ? _selectedClassId : null,
      items: _classes.map((classItem) {
        return DropdownMenuItem<String>(
          value: classItem.id,
          child: Text('${classItem.className} - ${classItem.sectionName}'),
        );
      }).toList(),
      onChanged: (value) {
        setState(() {
          _selectedClassId = value ?? '';
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
      decoration: InputDecoration(
        labelText: 'Subject *',
        hintText: 'Select subject',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        prefixIcon: const Icon(Icons.subject),
        filled: true,
        fillColor: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.3),
      ),
      value: _selectedSubjectId.isNotEmpty ? _selectedSubjectId : null,
      items: _subjects.map((subject) {
        return DropdownMenuItem<String>(
          value: subject.id,
          child: Row(
            children: [
              Text(subject.name),
              if (subject.code != null) ...[
                const SizedBox(width: 8),
                Text(
                  '(${subject.code})',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                    fontSize: 12,
                  ),
                ),
              ],
            ],
          ),
        );
      }).toList(),
      onChanged: (value) {
        setState(() {
          _selectedSubjectId = value ?? '';
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
      decoration: InputDecoration(
        labelText: 'Duration (minutes) *',
        hintText: 'e.g., 90',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        prefixIcon: const Icon(Icons.timer),
        suffixText: 'min',
        filled: true,
        fillColor: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.3),
      ),
      keyboardType: TextInputType.number,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter duration';
        }
        final duration = int.tryParse(value);
        if (duration == null || duration <= 0) {
          return 'Enter a valid duration';
        }
        if (duration > 480) { // 8 hours max
          return 'Duration cannot exceed 480 minutes';
        }
        return null;
      },
    );
  }

  Widget _buildTotalMarksField() {
    return TextFormField(
      controller: _totalMarksController,
      decoration: InputDecoration(
        labelText: 'Total Marks *',
        hintText: 'e.g., 100',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        prefixIcon: const Icon(Icons.score),
        suffixText: 'marks',
        filled: true,
        fillColor: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.3),
      ),
      keyboardType: TextInputType.number,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter total marks';
        }
        final marks = double.tryParse(value);
        if (marks == null || marks <= 0) {
          return 'Enter a valid marks value';
        }
        if (marks > 1000) {
          return 'Marks cannot exceed 1000';
        }
        return null;
      },
    );
  }

  Widget _buildInstructionsField() {
    return TextFormField(
      decoration: InputDecoration(
        labelText: 'Exam Instructions',
        hintText: 'Enter any specific instructions for students',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        prefixIcon: const Icon(Icons.note),
        filled: true,
        fillColor: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.3),
      ),
      maxLines: 3,
    );
  }

  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton.icon(
        onPressed: _isDataLoaded ? _submitForm : null,
        icon: Icon(widget.exam == null ? Icons.add : Icons.save),
        label: Text(
          widget.exam == null ? 'Create Exam' : 'Update Exam',
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: Theme.of(context).colorScheme.primary,
          foregroundColor: Theme.of(context).colorScheme.onPrimary,
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }

  void _pickDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
              primary: Theme.of(context).colorScheme.primary,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = DateTime(
          picked.year,
          picked.month,
          picked.day,
          _selectedTime.hour,
          _selectedTime.minute,
        );
      });
    }
  }

  void _pickTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
              primary: Theme.of(context).colorScheme.primary,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _selectedTime) {
      setState(() {
        _selectedTime = picked;
        _selectedDate = DateTime(
          _selectedDate.year,
          _selectedDate.month,
          _selectedDate.day,
          picked.hour,
          picked.minute,
        );
      });
    }
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      final examName = _isNewExamName
          ? _titleController.text.trim()
          : (_selectedExamName ?? _titleController.text.trim());

      if (kDebugMode) {
        print('Submitting exam with data:');
        print('Name: $examName');
        print('Subject ID: $_selectedSubjectId');
        print('Class ID: $_selectedClassId');
        print('Max Marks: ${_totalMarksController.text}');
        print('Date: $_selectedDate');
        print('Duration: ${_durationController.text}');
        print('Description: ${_descriptionController.text}');
      }

      final exam = Exam(
        id: widget.exam?.id,
        name: examName,
        date: _selectedDate,
        subjectId: _selectedSubjectId,
        classId: _selectedClassId,
        maxMarks: double.parse(_totalMarksController.text),
      );

      if (widget.exam == null) {
        context.read<ExamBloc>().add(CreateExam(exam));
      } else {
        context.read<ExamBloc>().add(UpdateExam(exam));
      }
    }
  }
}