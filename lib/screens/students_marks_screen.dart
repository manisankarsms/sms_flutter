
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pluto_grid/pluto_grid.dart';
import 'package:sms/screens/print_preview_screen.dart';
import '../bloc/students/students_bloc.dart';
import '../bloc/students/students_event.dart';
import '../bloc/students/students_state.dart';
import '../models/student.dart';
import '../models/exams.dart';
import 'package:intl/intl.dart';
import '../models/student_marks.dart';
import '../utils/ExportUtil.dart';

class StudentsMarksScreen extends StatefulWidget {
  final String standard;
  final String classId;
  final String subjectId;
  final String subjectName;

  const StudentsMarksScreen({
    Key? key,
    required this.standard,
    required this.classId,
    required this.subjectId,
    required this.subjectName,
  }) : super(key: key);

  @override
  _StudentsMarksScreenState createState() => _StudentsMarksScreenState();
}

class _StudentsMarksScreenState extends State<StudentsMarksScreen> {
  late PlutoGridStateManager _stateManager;
  Map<String, double> studentMarksMap = {};
  bool isLoading = true;
  String errorMessage = '';
  List<Exam> exams = [];
  String? selectedExamId;

  @override
  void initState() {
    super.initState();
    // First load the available exams
    context.read<StudentsBloc>().add(LoadExams(widget.classId));
  }

  void _loadMarks() {
    if (selectedExamId != null) {
      context.read<StudentsBloc>().add(LoadStudentMarks(
        widget.classId,
        selectedExamId!,
        widget.subjectId,
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('${widget.standard} - ${widget.subjectName}'),
            const Text(
              'Exam Marks',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w400),
            ),
          ],
        ),
        actions: [
          IconButton(
              icon: const Icon(Icons.print),
              onPressed: () => _printStudentMarks(context)),
          IconButton(
              icon: const Icon(Icons.download),
              onPressed: () => _showExportOptions(context)),
        ],
      ),
      body: BlocBuilder<StudentsBloc, StudentsState>(
        builder: (context, state) {
          // Handle exams loaded state
          if (state is ExamsLoaded) {
            exams = state.exams;
            // Only set selected exam if not already set and exams available
            if (selectedExamId == null && exams.isNotEmpty) {
              selectedExamId = exams[0].id;
              // Now load marks for the selected exam
              Future.microtask(() => _loadMarks());
            }

            // Return loading indicator until marks are loaded
            return Column(
              children: [
                _buildExamDropdown(),
                const Expanded(
                  child: Center(child: CircularProgressIndicator()),
                ),
              ],
            );
          }

          if (state is StudentsLoading) {
            return Column(
              children: [
                _buildExamDropdown(),
                const Expanded(
                  child: Center(child: CircularProgressIndicator()),
                ),
              ],
            );
          }

          if (state is StudentsError) {
            return Column(
              children: [
                _buildExamDropdown(),
                Expanded(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('Error: ${state.message}',
                            style: const TextStyle(color: Colors.red)),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: _loadMarks,
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            );
          }

          if (state is MarksLoaded) {
            // Initialize marks map from API response
            if (studentMarksMap.isEmpty || selectedExamId != state.examId) {
              selectedExamId = state.examId;
              studentMarksMap.clear();
              for (var mark in state.marks) {
                studentMarksMap[mark.studentId] = mark.marksScored.toDouble();
              }
            }

            return Column(
              children: [
                _buildExamDropdown(),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      ElevatedButton(
                        onPressed: _submitMarks,
                        child: const Text('Save Marks'),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: PlutoGrid(
                    columns: _buildMarksGridColumns(),
                    rows: _buildMarksGridRows(state.marks),
                    configuration: const PlutoGridConfiguration(
                      style: PlutoGridStyleConfig(
                        gridBorderColor: Colors.grey,
                        gridBackgroundColor: Colors.white,
                        rowColor: Colors.white,
                        gridBorderRadius:
                        BorderRadius.all(Radius.circular(8.0)),
                      ),
                      columnSize: PlutoGridColumnSizeConfig(
                        autoSizeMode: PlutoAutoSizeMode.scale,
                        resizeMode: PlutoResizeMode.pushAndPull,
                      ),
                      scrollbar: PlutoGridScrollbarConfig(
                        isAlwaysShown: true,
                      ),
                    ),
                    onLoaded: (PlutoGridOnLoadedEvent event) {
                      _stateManager = event.stateManager;
                      event.stateManager.setShowColumnFilter(true);
                      event.stateManager.setPageSize(10);
                    },
                    createFooter: (stateManager) =>
                        PlutoPagination(stateManager),
                    mode: PlutoGridMode.normal,
                  ),
                )
              ],
            );
          }

          if (state is NoStudentsFound) {
            return Column(
              children: [
                _buildExamDropdown(),
                const Expanded(
                  child: Center(
                    child: Text('No students found',
                        style: TextStyle(fontSize: 18, color: Colors.grey)),
                  ),
                ),
              ],
            );
          }

          // Initial state
          return const Center(child: CircularProgressIndicator());
        },
      ),
    );
  }

  Widget _buildExamDropdown() {
    return Container(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: [
          const Text(
            'Select Exam: ',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: DropdownButtonFormField<String>(
              value: selectedExamId,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              ),
              items: exams.map((exam) {
                return DropdownMenuItem<String>(
                  value: exam.id,
                  child: Text(exam.title),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null && value != selectedExamId) {
                  setState(() {
                    selectedExamId = value;
                    studentMarksMap.clear();
                  });
                  _loadMarks();
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  // Marks Grid Columns
  List<PlutoColumn> _buildMarksGridColumns() {
    return [
      PlutoColumn(
        title: 'Student ID',
        field: 'id',
        type: PlutoColumnType.text(),
        enableRowChecked: true,
      ),
      PlutoColumn(title: 'Name', field: 'name', type: PlutoColumnType.text()),
      PlutoColumn(
        title: 'Marks',
        field: 'marks',
        type: PlutoColumnType.number(),
        renderer: (rendererContext) {
          return TextFormField(
            initialValue: rendererContext.cell.value?.toString() ?? '0',
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              border: InputBorder.none,
              contentPadding: EdgeInsets.all(8),
            ),
            onChanged: (value) {
              final studentId = rendererContext.row.cells['id']!.value as String;
              _updateStudentMark(studentId, double.tryParse(value) ?? 0);
              rendererContext.cell.value = double.tryParse(value) ?? 0;
            },
          );
        },
      ),
    ];
  }

  List<PlutoRow> _buildMarksGridRows(List<StudentMark> marks) {
    return marks.map((mark) {
      return PlutoRow(cells: {
        'id': PlutoCell(value: mark.studentId),
        'name': PlutoCell(value: mark.studentName),
        'marks': PlutoCell(value: studentMarksMap[mark.studentId] ?? 0),
      });
    }).toList();
  }

  void _updateStudentMark(String studentId, double mark) {
    setState(() {
      studentMarksMap[studentId] = mark;
    });
  }

  // Submitting Marks Data
  void _submitMarks() {
    if (selectedExamId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please select an exam first")),
      );
      return;
    }

    // Construct payload
    final marksData = studentMarksMap.entries.map((entry) {
      return {
        "studentId": entry.key,
        "marksScored": entry.value,
      };
    }).toList();

    final requestBody = {
      "classId": widget.classId,
      "examId": selectedExamId,
      "subjectId": widget.subjectId,
      "marks": marksData
    };

    // Here you would make the API call to save the marks
    context.read<StudentsBloc>().add(SaveStudentMarks(requestBody));

    // Show temporary success message
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Marks submitted successfully!")),
    );
  }

  void _printStudentMarks(BuildContext context) {
    final bloc = context.read<StudentsBloc>();
    if (bloc.state is MarksLoaded) {
      final marks = (bloc.state as MarksLoaded).marks;
      final selectedExam = exams.firstWhere(
            (exam) => exam.id == selectedExamId,
        orElse: () => Exam(id: '', title: 'Unknown Exam', description: '', createdBy: '', createdAt: null, examDate: null, subjectId: '', classId: '', duration: null, totalMarks: null),
      );

      final headers = ['ID', 'Name', 'Marks'];
      final data = marks.map((mark) {
        return [
          mark.studentId,
          mark.studentName,
          (studentMarksMap[mark.studentId] ?? 0).toString(),
        ];
      }).toList();

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => PrintPreviewScreen(
            title: "${widget.subjectName} - ${selectedExam.title}",
            headers: headers,
            data: data,
          ),
        ),
      );
    }
  }

  void _showExportOptions(BuildContext context) {
    final bloc = context.read<StudentsBloc>();
    if (bloc.state is MarksLoaded) {
      final marks = (bloc.state as MarksLoaded).marks;
      final selectedExam = exams.firstWhere(
            (exam) => exam.id == selectedExamId,
        orElse: () => Exam(id: '', title: 'Unknown Exam', description: '', createdBy: '', createdAt: null, examDate: null, subjectId: '', classId: '', duration: null, totalMarks: null),
      );

      final headers = ['ID', 'Name', 'Marks'];
      final data = marks.map((mark) {
        return [
          mark.studentId,
          mark.studentName,
          (studentMarksMap[mark.studentId] ?? 0).toString(),
        ];
      }).toList();

      showModalBottomSheet(
        context: context,
        builder: (context) {
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.file_download),
                title: const Text("Export as CSV"),
                onTap: () {
                  final fileName = 'marks_${widget.subjectName}_${selectedExam.title.replaceAll(' ', '_')}';
                  ExportUtil.exportToCSV(
                      fileName: fileName,
                      headers: headers,
                      data: data);
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                      content: Text("CSV exported successfully!")));
                },
              ),
              ListTile(
                leading: const Icon(Icons.insert_drive_file),
                title: const Text("Export as Excel"),
                onTap: () {
                  final fileName = 'marks_${widget.subjectName}_${selectedExam.title.replaceAll(' ', '_')}';
                  ExportUtil.exportToExcel(
                      fileName: fileName,
                      headers: headers,
                      data: data);
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                      content: Text("Excel exported successfully!")));
                },
              ),
            ],
          );
        },
      );
    }
  }
}