import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pluto_grid/pluto_grid.dart';
import 'package:sms/screens/print_preview_screen.dart';
import '../bloc/complete_marks/complete_marks_bloc.dart';
import '../bloc/complete_marks/complete_marks_event.dart';
import '../bloc/complete_marks/complete_marks_state.dart';
import '../models/complete_marks_model.dart';
import '../utils/ExportUtil.dart';

class CompleteStudentsMarksScreen extends StatefulWidget {
  final String classId;
  final String standard;

  const CompleteStudentsMarksScreen({
    Key? key,
    required this.classId,
    required this.standard,
  }) : super(key: key);

  @override
  _CompleteStudentsMarksScreenState createState() => _CompleteStudentsMarksScreenState();
}

class _CompleteStudentsMarksScreenState extends State<CompleteStudentsMarksScreen> {
  late PlutoGridStateManager _stateManager;
  List<String> examNames = [];
  String? selectedExamName;
  CompleteMarksData? currentMarksData;
  List<StudentCompleteMarks> topScorers = [];

  @override
  void initState() {
    super.initState();
    // Load available exams
    context.read<CompleteMarksBloc>().add(LoadExamNames(widget.classId));
  }

  void _loadCompleteMarks() {
    if (selectedExamName != null) {
      context.read<CompleteMarksBloc>().add(LoadCompleteMarks(
        widget.classId,
        selectedExamName!,
      ));
    }
  }

  List<StudentCompleteMarks> _calculateTopScorers() {
    if (currentMarksData == null) return [];

    List<StudentCompleteMarks> sortedStudents = List.from(currentMarksData!.students);
    sortedStudents.sort((a, b) => b.overallPercentage.compareTo(a.overallPercentage));
    return sortedStudents.take(3).toList();
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
            Text('${widget.standard} - Complete Marks'),
            const Text(
              'Exam Results',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w400),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.print),
            tooltip: 'Print Results',
            onPressed: () => _printCompleteMarks(context),
          ),
          IconButton(
            icon: const Icon(Icons.download),
            tooltip: 'Export Results',
            onPressed: () => _showExportOptions(context),
          ),
        ],
      ),
      body: BlocBuilder<CompleteMarksBloc, CompleteMarksState>(
        builder: (context, state) {
          if (state is ExamNamesLoaded) {
            examNames = state.examNames;
            if (selectedExamName == null && examNames.isNotEmpty) {
              selectedExamName = examNames[0];
              Future.microtask(() => _loadCompleteMarks());
            }
            return _buildMainContent(
              content: const Center(child: CircularProgressIndicator()),
            );
          }

          if (state is CompleteMarksLoading) {
            return _buildMainContent(
              content: const Center(child: CircularProgressIndicator()),
            );
          }

          if (state is CompleteMarksError) {
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
                      onPressed: _loadCompleteMarks,
                      icon: const Icon(Icons.refresh),
                      label: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            );
          }

          if (state is CompleteMarksLoaded) {
            currentMarksData = state.marksData;
            topScorers = _calculateTopScorers();

            return _buildMainContent(
              content: _buildCompleteMarksTable(state.marksData),
            );
          }

          if (state is NoMarksFound) {
            return _buildMainContent(
              content: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.assignment_outlined, size: 48, color: Colors.grey.shade400),
                    const SizedBox(height: 16),
                    const Text(
                      'No marks found for this exam',
                      style: TextStyle(fontSize: 18, color: Colors.grey),
                    ),
                  ],
                ),
              ),
            );
          }

          return const Center(child: CircularProgressIndicator());
        },
      ),
    );
  }

  Widget _buildMainContent({required Widget content}) {
    return Column(
      children: [
        _buildExamSelectionBar(),
        if (currentMarksData != null) _buildExamInfoBar(),
        Expanded(
          child: LayoutBuilder(
            builder: (context, constraints) {
              if (constraints.maxWidth >= 600) {
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (topScorers.isNotEmpty)
                      SizedBox(
                        width: 250,
                        child: _buildTopScorersSection(topScorers, isVertical: true),
                      ),
                    Expanded(child: content),
                  ],
                );
              } else {
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
            value: selectedExamName,
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
            items: examNames.map((examName) {
              return DropdownMenuItem<String>(
                value: examName,
                child: Text(examName, overflow: TextOverflow.ellipsis),
              );
            }).toList(),
            onChanged: (value) {
              if (value != null && value != selectedExamName) {
                setState(() {
                  selectedExamName = value;
                  currentMarksData = null;
                  topScorers = [];
                });
                _loadCompleteMarks();
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildExamInfoBar() {
    if (currentMarksData == null) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        border: Border(
          bottom: BorderSide(color: Colors.grey.shade200),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${currentMarksData!.className} - ${currentMarksData!.sectionName}',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(
                  'Academic Year: ${currentMarksData!.academicYear}',
                  style: TextStyle(color: Colors.grey.shade700, fontSize: 12),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                'Exam Date: ${_formatDate(currentMarksData!.examDate)}',
                style: const TextStyle(fontWeight: FontWeight.w500),
              ),
              Text(
                'Total Students: ${currentMarksData!.students.length}',
                style: TextStyle(color: Colors.grey.shade700, fontSize: 12),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTopScorersSection(List<StudentCompleteMarks> topScorers, {required bool isVertical}) {
    if (topScorers.isEmpty) return const SizedBox.shrink();

    final headerRow = Row(
      children: [
        Icon(Icons.emoji_events, color: Colors.amber.shade700),
        const SizedBox(width: 8),
        const Text(
          'Top Scorers',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ],
    );

    final scorersWidget = isVertical
        ? Column(
      children: topScorers.asMap().entries.map((entry) {
        final index = entry.key;
        final student = entry.value;
        final colors = [
          Colors.amber.shade800,
          Colors.blueGrey.shade400,
          Colors.brown.shade400,
        ];

        return Card(
          elevation: 0,
          color: Colors.grey.shade50,
          margin: const EdgeInsets.symmetric(vertical: 4),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.star, color: colors[index], size: 16),
                    const SizedBox(width: 4),
                    Text(
                      '${index + 1}${_getOrdinal(index + 1)}',
                      style: TextStyle(
                        fontSize: 12,
                        color: colors[index],
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  student.studentName,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  '${student.overallPercentage.toStringAsFixed(1)}%',
                  style: TextStyle(
                    color: Colors.grey.shade700,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    )
        : Row(
      children: topScorers.asMap().entries.map((entry) {
        final index = entry.key;
        final student = entry.value;
        final colors = [
          Colors.amber.shade800,
          Colors.blueGrey.shade400,
          Colors.brown.shade400,
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
                      Icon(Icons.star, color: colors[index], size: 16),
                      const SizedBox(width: 4),
                      Text(
                        '${index + 1}${_getOrdinal(index + 1)}',
                        style: TextStyle(
                          fontSize: 12,
                          color: colors[index],
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    student.studentName,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${student.overallPercentage.toStringAsFixed(1)}%',
                    style: TextStyle(
                      color: Colors.grey.shade700,
                      fontSize: 11,
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

  Widget _buildCompleteMarksTable(CompleteMarksData marksData) {
    if (MediaQuery.of(context).size.width < 600) {
      return _buildMobileMarksView(marksData);
    } else {
      return _buildDesktopMarksView(marksData);
    }
  }

  Widget _buildMobileMarksView(CompleteMarksData marksData) {
    return ListView.builder(
      padding: const EdgeInsets.all(8),
      itemCount: marksData.students.length,
      itemBuilder: (context, index) {
        final student = marksData.students[index];
        return Card(
          margin: const EdgeInsets.symmetric(vertical: 4),
          child: ExpansionTile(
            title: Text(
              student.studentName,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Total: ${student.totalMarksObtained}/${student.totalMaxMarks}'),
                Text('Percentage: ${student.overallPercentage.toStringAsFixed(1)}%'),
              ],
            ),
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Subject-wise Marks:',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    ...marksData.subjects.asMap().entries.map((entry) {
                      final subjectIndex = entry.key;
                      final subject = entry.value;
                      final marks = student.subjectMarks[subjectIndex];

                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(subject.subjectName),
                            Text('${marks.marksObtained}/${subject.maxMarks}'),
                          ],
                        ),
                      );
                    }).toList(),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDesktopMarksView(CompleteMarksData marksData) {
    return Card(
      margin: const EdgeInsets.all(8),
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      child: PlutoGrid(
        columns: _buildCompleteMarksGridColumns(marksData.subjects),
        rows: _buildCompleteMarksGridRows(marksData),
        configuration: PlutoGridConfiguration(
          style: PlutoGridStyleConfig(
            gridBorderColor: Colors.grey.shade200,
            gridBackgroundColor: Colors.white,
            rowColor: Colors.white,
            activatedColor: Colors.blue.shade50,
            gridBorderRadius: const BorderRadius.all(Radius.circular(8.0)),
            columnTextStyle: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 12,
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
        createFooter: (stateManager) => PlutoPagination(stateManager),
        mode: PlutoGridMode.readOnly,
      ),
    );
  }

  List<PlutoColumn> _buildCompleteMarksGridColumns(List<SubjectInfo> subjects) {
    List<PlutoColumn> columns = [
      PlutoColumn(
        title: 'Student Name',
        field: 'name',
        type: PlutoColumnType.text(),
        enableFilterMenuItem: true,
        textAlign: PlutoColumnTextAlign.start,
        enableEditingMode: false,
        width: 150,
      ),
    ];

    // Add subject columns
    for (int i = 0; i < subjects.length; i++) {
      columns.add(
        PlutoColumn(
          title: '${subjects[i].subjectName}\n(${subjects[i].maxMarks})',
          field: 'subject_$i',
          type: PlutoColumnType.text(),
          textAlign: PlutoColumnTextAlign.center,
          enableEditingMode: false,
          width: 100,
        ),
      );
    }

    // Add total and percentage columns
    columns.addAll([
      PlutoColumn(
        title: 'Total',
        field: 'total',
        type: PlutoColumnType.text(),
        textAlign: PlutoColumnTextAlign.center,
        enableEditingMode: false,
        width: 80,
      ),
      PlutoColumn(
        title: 'Percentage',
        field: 'percentage',
        type: PlutoColumnType.text(),
        textAlign: PlutoColumnTextAlign.center,
        enableEditingMode: false,
        width: 80,
      ),
    ]);

    return columns;
  }

  List<PlutoRow> _buildCompleteMarksGridRows(CompleteMarksData marksData) {
    return marksData.students.map((student) {
      Map<String, PlutoCell> cells = {
        'name': PlutoCell(value: student.studentName),
      };

      // Add subject marks
      for (int i = 0; i < student.subjectMarks.length; i++) {
        cells['subject_$i'] = PlutoCell(value: student.subjectMarks[i].marksObtained.toString());
      }

      // Add total and percentage
      cells['total'] = PlutoCell(value: '${student.totalMarksObtained}/${student.totalMaxMarks}');
      cells['percentage'] = PlutoCell(value: '${student.overallPercentage.toStringAsFixed(1)}%');

      return PlutoRow(cells: cells);
    }).toList();
  }

  String _getOrdinal(int number) {
    if (number == 1) return 'st';
    if (number == 2) return 'nd';
    if (number == 3) return 'rd';
    return 'th';
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  void _printCompleteMarks(BuildContext context) {
    if (currentMarksData == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please wait for marks to load"),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    final headers = ['Student Name', ...currentMarksData!.subjects.map((s) => s.subjectName), 'Total', 'Percentage'];
    final data = currentMarksData!.students.map((student) {
      return [
        student.studentName,
        ...student.subjectMarks.map((mark) => mark.marksObtained.toString()),
        '${student.totalMarksObtained}/${student.totalMaxMarks}',
        '${student.overallPercentage.toStringAsFixed(1)}%',
      ];
    }).toList();

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PrintPreviewScreen(
          title: "${currentMarksData!.examName} - ${currentMarksData!.className}${currentMarksData!.sectionName}",
          headers: headers,
          data: data,
        ),
      ),
    );
  }

  void _showExportOptions(BuildContext context) {
    if (currentMarksData == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please wait for marks to load"),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    final headers = ['Student Name', ...currentMarksData!.subjects.map((s) => s.subjectName), 'Total', 'Percentage'];
    final data = currentMarksData!.students.map((student) {
      return [
        student.studentName,
        ...student.subjectMarks.map((mark) => mark.marksObtained.toString()),
        '${student.totalMarksObtained}/${student.totalMaxMarks}',
        '${student.overallPercentage.toStringAsFixed(1)}%',
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
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
              ListTile(
                leading: Icon(Icons.file_download, color: Colors.blue.shade700),
                title: const Text("Export as CSV"),
                onTap: () {
                  final fileName = 'complete_marks_${currentMarksData!.examName.replaceAll(' ', '_')}_${currentMarksData!.className}${currentMarksData!.sectionName}';
                  ExportUtil.exportToCSV(fileName: fileName, headers: headers, data: data);
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
                  final fileName = 'complete_marks_${currentMarksData!.examName.replaceAll(' ', '_')}_${currentMarksData!.className}${currentMarksData!.sectionName}';
                  ExportUtil.exportToExcel(fileName: fileName, headers: headers, data: data);
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
  }
}