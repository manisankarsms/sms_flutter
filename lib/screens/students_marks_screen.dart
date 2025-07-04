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
  Map<String, TextEditingController> _markControllers = {};
  bool isLoading = true;
  String errorMessage = '';
  List<Exam> exams = [];
  String? selectedExamId;
  Exam? selectedExam;
  List<StudentMark> currentMarks = [];
  List<StudentMark> topScorers = [];

  @override
  void initState() {
    super.initState();
    // First load the available exams
    context.read<StudentsBloc>().add(LoadExams(widget.classId, widget.subjectId));
  }

  @override
  void dispose() {
    // Clean up all text controllers
    for (var controller in _markControllers.values) {
      controller.dispose();
    }
    super.dispose();
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

  // Calculate top scorers without setState
  List<StudentMark> _calculateTopScorers() {
    // Create a list of students with their marks
    List<StudentMark> studentsWithMarks = [];

    for (var mark in currentMarks) {
      double score = studentMarksMap[mark.studentId] ?? 0;
      studentsWithMarks.add(
          StudentMark(
            studentId: mark.studentId,
            studentName: mark.studentName,
            marksScored: score,
          )
      );
    }

    // Sort by marks in descending order
    studentsWithMarks.sort((a, b) => b.marksScored.compareTo(a.marksScored));

    // Take top 3 (or less if fewer students)
    return studentsWithMarks.take(3).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        elevation: 0,
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
            tooltip: 'Print Marks',
            onPressed: () => _printStudentMarks(context),
          ),
          IconButton(
            icon: const Icon(Icons.download),
            tooltip: 'Export Marks',
            onPressed: () => _showExportOptions(context),
          ),
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
              selectedExam = exams[0];
              // Now load marks for the selected exam
              Future.microtask(() => _loadMarks());
            }

            // Return loading indicator until marks are loaded
            return _buildMainContent(
              content: const Center(child: CircularProgressIndicator()),
            );
          }

          if (state is StudentsLoading) {
            return _buildMainContent(
              content: const Center(child: CircularProgressIndicator()),
            );
          }

          if (state is StudentsError) {
            return _buildMainContent(
              content: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.error_outline, size: 48, color: Colors.red.shade300),
                    const SizedBox(height: 16),
                    Text(
                      'Error: ${state.message}',
                      style: TextStyle(color: Colors.red.shade700),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: _loadMarks,
                      icon: const Icon(Icons.refresh),
                      label: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            );
          }

          if (state is MarksSaving) {
            return _buildMainContent(
              content: const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 16),
                    Text('Saving marks...'),
                  ],
                ),
              ),
            );
          }

          if (state is MarksSaved) {
            // Show success message and reload marks
            WidgetsBinding.instance.addPostFrameCallback((_) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Row(
                    children: [
                      Icon(Icons.check_circle, color: Colors.white),
                      SizedBox(width: 12),
                      Text("Marks saved successfully!"),
                    ],
                  ),
                  backgroundColor: Colors.green,
                  behavior: SnackBarBehavior.floating,
                  duration: Duration(seconds: 2),
                ),
              );

              // Reload the marks to get the updated data
              _loadMarks();
            });

            return _buildMainContent(
              content: const Center(child: CircularProgressIndicator()),
            );
          }


          if (state is MarksLoaded) {
            // Always update the current marks list
            currentMarks = state.marks;

            // Initialize or update marks map from API response
            if (selectedExamId != state.examId) {
              selectedExamId = state.examId;
              selectedExam = exams.firstWhere(
                    (exam) => exam.id == selectedExamId,
                orElse: () => Exam(
                    id: '',
                    name: 'Unknown Exam',
                    date: DateTime(1),
                    subjectId: '',
                    classId: '',
                    maxMarks: 0
                ),
              );

              // Clear existing data
              studentMarksMap.clear();
              for (var controller in _markControllers.values) {
                controller.dispose();
              }
              _markControllers.clear();
            }

            // Always update the marks map and controllers with the latest data
            for (var mark in state.marks) {
              // If we don't have this mark yet, initialize it
              if (!studentMarksMap.containsKey(mark.studentId)) {
                studentMarksMap[mark.studentId] = mark.marksScored.toDouble();

                // Create or update the controller
                if (_markControllers.containsKey(mark.studentId)) {
                  _markControllers[mark.studentId]!.text = mark.marksScored.toString();
                } else {
                  _markControllers[mark.studentId] = TextEditingController(
                      text: mark.marksScored.toString()
                  );
                }
              }
            }

            // Calculate top scorers without setState
            topScorers = _calculateTopScorers();

            return _buildMainContent(
              content: _buildMarksTable(state.marks),
              showSaveButton: true,
            );
          }

          if (state is NoStudentsFound) {
            return _buildMainContent(
              content: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.person_off, size: 48, color: Colors.grey.shade400),
                    const SizedBox(height: 16),
                    const Text(
                      'No students found',
                      style: TextStyle(fontSize: 18, color: Colors.grey),
                    ),
                  ],
                ),
              ),
            );
          }

          // Initial state
          return const Center(child: CircularProgressIndicator());
        },
      ),
    );
  }

  String _getOrdinal(int number) {
    if (number == 1) return 'st';
    if (number == 2) return 'nd';
    if (number == 3) return 'rd';
    return 'th';
  }

  // Modified _buildMainContent function to handle desktop layout
  Widget _buildMainContent({required Widget content, bool showSaveButton = false}) {
    return Column(
      children: [
        _buildExamSelectionBar(),
        if (showSaveButton) _buildSaveBar(),
        Expanded(
          child: LayoutBuilder(
            builder: (context, constraints) {
              // For desktop view (wider screens), use horizontal layout
              if (constraints.maxWidth >= 600) {
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Side panel with top scorers (if available)
                    if (topScorers.isNotEmpty)
                      SizedBox(
                        width: 250, // Fixed width for the sidebar
                        child: _buildTopScorersSection(topScorers, isVertical: true),
                      ),
                    // Main content (marks table)
                    Expanded(child: content),
                  ],
                );
              } else {
                // For mobile view, keep the original vertical layout
                return Column(
                  children: [
                    if (topScorers.isNotEmpty) _buildTopScorersSection(topScorers, isVertical: false),
                    Expanded(child: content),
                  ],
                );
              }
            },
          ),
        ),
      ],
    );
  }

// Modified top scorers section to support both horizontal and vertical layouts
  Widget _buildTopScorersSection(List<StudentMark> topScorers, {required bool isVertical}) {
    if (topScorers.isEmpty) {
      return const SizedBox.shrink();
    }

    final headerRow = Row(
      children: [
        Icon(Icons.emoji_events, color: Colors.amber.shade700),
        const SizedBox(width: 8),
        const Text(
          'Top Scorers',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );

    final scorersWidget = isVertical
    // Vertical layout for desktop sidebar
        ? Column(
      children: topScorers.asMap().entries.map((entry) {
        final index = entry.key;
        final student = entry.value;
        final colors = [
          Colors.amber.shade800, // Gold
          Colors.blueGrey.shade400, // Silver
          Colors.brown.shade400, // Bronze
        ];

        return Card(
          elevation: 0,
          color: Colors.grey.shade50,
          margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 0),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.star, color: colors[index]),
                    const SizedBox(width: 4),
                    Text(
                      '${index + 1}${_getOrdinal(index + 1)} place',
                      style: TextStyle(
                        fontSize: 12,
                        color: colors[index],
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  student.studentName,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  'Score: ${student.marksScored}',
                  style: TextStyle(
                    color: Colors.grey.shade700,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    )
    // Horizontal layout for mobile view (original layout)
        : Row(
      children: topScorers.asMap().entries.map((entry) {
        final index = entry.key;
        final student = entry.value;
        final colors = [
          Colors.amber.shade800, // Gold
          Colors.blueGrey.shade400, // Silver
          Colors.brown.shade400, // Bronze
        ];

        return Expanded(
          child: Card(
            elevation: 0,
            color: Colors.grey.shade50,
            margin: const EdgeInsets.symmetric(horizontal: 4),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.star, color: colors[index]),
                      const SizedBox(width: 4),
                      Text(
                        '${index + 1}${_getOrdinal(index + 1)} place',
                        style: TextStyle(
                          fontSize: 12,
                          color: colors[index],
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    student.studentName,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Score: ${student.marksScored}',
                    style: TextStyle(
                      color: Colors.grey.shade700,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );

    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 3,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          headerRow,
          const SizedBox(height: 12),
          scorersWidget,
        ],
      ),
    );
  }

// Update the _buildMarksTable function to remove redundant LayoutBuilder
  Widget _buildMarksTable(List<StudentMark> marks) {
    // For narrow screens, use a ListView instead of PlutoGrid
    if (MediaQuery.of(context).size.width < 600) {
      return _buildMobileMarksView(marks);
    } else {
      return _buildDesktopMarksView(marks);
    }
  }

  Widget _buildExamSelectionBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 3,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Select Exam:',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          DropdownButtonFormField<String>(
            value: selectedExamId,
            isExpanded: true,
            decoration: InputDecoration(
              isDense: true,
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              filled: true,
              fillColor: Colors.grey.shade50,
            ),
            items: exams.map((exam) {
              return DropdownMenuItem<String>(
                value: exam.id,
                child: Text(exam.name, overflow: TextOverflow.ellipsis),
              );
            }).toList(),
            onChanged: (value) {
              if (value != null && value != selectedExamId) {
                setState(() {
                  selectedExamId = value;
                  selectedExam = exams.firstWhere((exam) => exam.id == value);
                  studentMarksMap.clear();
                  // Dispose old controllers
                  for (var controller in _markControllers.values) {
                    controller.dispose();
                  }
                  _markControllers.clear();
                  topScorers = [];
                  currentMarks = [];
                });
                _loadMarks();
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSaveBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      color: Colors.white,
      child: Row(
        children: [
          if (selectedExam != null && selectedExam!.maxMarks != null)
            Expanded(
              child: Text(
                'Total Marks: ${selectedExam!.maxMarks}',
                style: const TextStyle(fontWeight: FontWeight.bold),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ElevatedButton.icon(
            onPressed: _submitMarks,
            icon: const Icon(Icons.save),
            label: const Text('Save Marks'),
            style: ElevatedButton.styleFrom(
              foregroundColor: Colors.white,
              backgroundColor: Colors.green.shade600,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ],
      ),
    );
  }


  Widget _buildMobileMarksView(List<StudentMark> marks) {
    return ListView.builder(
      padding: const EdgeInsets.all(8),
      itemCount: marks.length,
      itemBuilder: (context, index) {
        final mark = marks[index];
        final studentId = mark.studentId;

        // Ensure there's a controller for this student
        if (!_markControllers.containsKey(studentId)) {
          _markControllers[studentId] = TextEditingController(
              text: (studentMarksMap[studentId] ?? 0).toString()
          );
        }

        return Card(
          margin: const EdgeInsets.symmetric(vertical: 4),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        mark.studentName,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'ID: ${mark.studentId}',
                        style: TextStyle(
                          color: Colors.grey.shade700,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                SizedBox(
                  width: 80,
                  child: TextField(
                    controller: _markControllers[studentId],
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    textAlign: TextAlign.center,
                    decoration: InputDecoration(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      labelText: 'Marks',
                      isDense: true,
                    ),
                    onChanged: (value) {
                      _updateStudentMark(studentId, double.tryParse(value) ?? 0);
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildDesktopMarksView(List<StudentMark> marks) {
    return Card(
      margin: const EdgeInsets.all(8),
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      child: PlutoGrid(
        columns: _buildMarksGridColumns(),
        rows: _buildMarksGridRows(marks),
        configuration: PlutoGridConfiguration(
          style: PlutoGridStyleConfig(
            gridBorderColor: Colors.grey.shade200,
            gridBackgroundColor: Colors.white,
            rowColor: Colors.white,
            activatedColor: Colors.blue.shade50,
            gridBorderRadius: const BorderRadius.all(Radius.circular(8.0)),
            columnTextStyle: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
            rowHeight: 48,
          ),
          columnSize: const PlutoGridColumnSizeConfig(
            autoSizeMode: PlutoAutoSizeMode.scale,
            resizeMode: PlutoResizeMode.pushAndPull,
          ),
          scrollbar: const PlutoGridScrollbarConfig(
            isAlwaysShown: true,
            scrollbarThickness: 6,
            scrollbarRadius: Radius.circular(3),
          ),
        ),
        onLoaded: (PlutoGridOnLoadedEvent event) {
          _stateManager = event.stateManager;
          _stateManager.setShowColumnFilter(true);
          _stateManager.setPageSize(12);
        },
        onChanged: (PlutoGridOnChangedEvent event) {
          // This is the key fix - sync PlutoGrid changes back to your data
          if (event.column.field == 'marks') {
            final studentId = event.row.cells['id']?.value;
            final newValue = event.value;
            if (studentId != null && newValue != null) {
              final marks = double.tryParse(newValue.toString()) ?? 0;
              _updateStudentMark(studentId, marks);

              // Also update the controller to keep it in sync
              if (_markControllers.containsKey(studentId)) {
                _markControllers[studentId]!.text = marks.toString();
              }
            }
          }
        },
        createFooter: (stateManager) => PlutoPagination(stateManager),
        mode: PlutoGridMode.normal,
      ),
    );
  }

  List<PlutoColumn> _buildMarksGridColumns() {
    return [
      PlutoColumn(
        title: 'Roll No.',
        field: 'id',
        width: 100,
        type: PlutoColumnType.text(),
        enableFilterMenuItem: true,
        textAlign: PlutoColumnTextAlign.start,
        enableEditingMode: false,
      ),
      PlutoColumn(
        title: 'Student Name',
        field: 'name',
        type: PlutoColumnType.text(),
        enableFilterMenuItem: true,
        textAlign: PlutoColumnTextAlign.start,
        enableEditingMode: false,
      ),
      PlutoColumn(
        title: 'Marks',
        field: 'marks',
        type: PlutoColumnType.number(),
        enableEditingMode: true, // <-- Make sure this is true
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
      // Recalculate top scorers when marks change
      topScorers = _calculateTopScorers();
    });
  }

  void _submitMarks() {
    if (selectedExamId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please select an exam first"),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    // Update marks from controllers to ensure the latest values (for mobile)
    _markControllers.forEach((studentId, controller) {
      final value = double.tryParse(controller.text) ?? 0;
      studentMarksMap[studentId] = value;
    });

    if (MediaQuery.of(context).size.width >= 600 && _stateManager != null) {
      for (var row in _stateManager.rows) {
        final studentId = row.cells['id']?.value;
        final marksValue = row.cells['marks']?.value;
        if (studentId != null && marksValue != null) {
          final marks = double.tryParse(marksValue.toString()) ?? 0;
          studentMarksMap[studentId] = marks;
        }
      }
    }

    // Recalculate top scorers with the final marks
    setState(() {
      topScorers = _calculateTopScorers();
    });

    // Debug: Print the marks being sent
    print('Submitting marks: $studentMarksMap');

    // Construct payload in the new format
    final marksData = studentMarksMap.entries.map((entry) {
      return {
        "studentId": entry.key,
        "marksScored": entry.value,
      };
    }).toList();

    final requestBody = {
      "examId": selectedExamId,
      "marks": marksData
    };

    // Debug: Print the request body
    print('Request body: $requestBody');

    // Make the API call to save the marks
    context.read<StudentsBloc>().add(SaveStudentMarks(requestBody));
  }

  void _printStudentMarks(BuildContext context) {
    final bloc = context.read<StudentsBloc>();
    if (bloc.state is MarksLoaded) {
      final marks = (bloc.state as MarksLoaded).marks;
      final selectedExam = exams.firstWhere(
            (exam) => exam.id == selectedExamId,
        orElse: () => Exam(
            id: '',
            name: 'Unknown Exam',
            date: DateTime(1),
            subjectId: '',
            classId: '',
            maxMarks: 0
        ),
      );

      // Update marks from controllers
      _markControllers.forEach((studentId, controller) {
        final value = double.tryParse(controller.text) ?? 0;
        studentMarksMap[studentId] = value;
      });

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
            title: "${widget.subjectName} - ${selectedExam.name}",
            headers: headers,
            data: data,
          ),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please wait for marks to load"),
          behavior: SnackBarBehavior.floating,
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
        orElse: () => Exam(
            id: '',
            name: 'Unknown Exam',
            date: DateTime(1),
            subjectId: '',
            classId: '',
            maxMarks: 0
        ),
      );

      // Update marks from controllers
      _markControllers.forEach((studentId, controller) {
        final value = double.tryParse(controller.text) ?? 0;
        studentMarksMap[studentId] = value;
      });

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
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
        ),
        builder: (context) {
          return Container(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Padding(
                  padding: EdgeInsets.only(bottom: 12),
                  child: Text(
                    "Export Options",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                ListTile(
                  leading: Icon(Icons.file_download, color: Colors.blue.shade700),
                  title: const Text("Export as CSV"),
                  onTap: () {
                    final fileName = 'marks_${widget.subjectName}_${selectedExam.name.replaceAll(' ', '_')}';
                    ExportUtil.exportToCSV(
                        fileName: fileName,
                        headers: headers,
                        data: data);
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("CSV exported successfully!"),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  },
                ),
                ListTile(
                  leading: Icon(Icons.insert_drive_file, color: Colors.green.shade700),
                  title: const Text("Export as Excel"),
                  onTap: () {
                    final fileName = 'marks_${widget.subjectName}_${selectedExam.name.replaceAll(' ', '_')}';
                    ExportUtil.exportToExcel(
                        fileName: fileName,
                        headers: headers,
                        data: data);
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("Excel exported successfully!"),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  },
                ),
              ],
            ),
          );
        },
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please wait for marks to load"),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }
}