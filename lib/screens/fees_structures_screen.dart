import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../bloc/fees_structures/fees_structure_bloc.dart';
import '../bloc/fees_structures/fees_structures_event.dart';
import '../bloc/fees_structures/fees_structures_state.dart';
import '../models/AcademicYear.dart';
import '../models/class.dart';
import '../models/fees_structures/BulkCreateFeesStructureRequest.dart';
import '../models/fees_structures/ClassFeesStructureDto.dart';
import '../models/fees_structures/FeesStructureDto.dart';
import '../models/fees_structures/FeesStructureItem.dart';
class FeesStructureScreen extends StatefulWidget {
  const FeesStructureScreen({super.key});

  @override
  State<FeesStructureScreen> createState() => _FeesStructureScreenState();
}

class _FeesStructureScreenState extends State<FeesStructureScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _amountController = TextEditingController();

  Class? _selectedClass;
  AcademicYear? _selectedAcademicYear;
  bool _isMandatory = true;
  bool _showCreateForm = false;

  List<FeesStructureItem> _tempFeeItems = [];

  @override
  void initState() {
    super.initState();
    context.read<FeesStructureBloc>().add(LoadFeesStructures());
    // Also load classes and academic years
    context.read<FeesStructureBloc>().add(LoadClassesAndAcademicYears());
  }

  void _addFeeItem() {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _tempFeeItems.add(FeesStructureItem(
          name: _nameController.text.trim(),
          amount: _amountController.text.trim(),
          isMandatory: _isMandatory,
        ));
        _nameController.clear();
        _amountController.clear();
        _isMandatory = true;
      });
    }
  }

  void _removeFeeItem(int index) {
    setState(() {
      _tempFeeItems.removeAt(index);
    });
  }

  void _saveFeeStructure() {
    if (_selectedClass == null || _selectedAcademicYear == null) {
      _showSnackBar('Please select class and academic year', isError: true);
      return;
    }

    if (_tempFeeItems.isEmpty) {
      _showSnackBar('Please add at least one fee item', isError: true);
      return;
    }

    final request = BulkCreateFeesStructureRequest(
      classId: _selectedClass!.id,
      academicYearId: _selectedAcademicYear!.id,
      feeStructures: _tempFeeItems,
    );

    context.read<FeesStructureBloc>().add(CreateBulkFeesStructure(request));
  }

  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
      ),
    );
  }

  void _resetForm() {
    setState(() {
      _selectedClass = null;
      _selectedAcademicYear = null;
      _tempFeeItems.clear();
      _showCreateForm = false;
    });
    _nameController.clear();
    _amountController.clear();
  }

  Widget _buildCreateForm() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.add, color: Theme.of(context).primaryColor),
                const SizedBox(width: 8),
                Text(
                  'Create Fee Structure',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                IconButton(
                  onPressed: () => setState(() => _showCreateForm = false),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            const Divider(),

            // Class and Academic Year Selection
            BlocBuilder<FeesStructureBloc, FeesStructureState>(
              builder: (context, state) {
                if (state is FeesStructureLoaded) {
                  return Row(
                    children: [
                      Expanded(
                        child: DropdownButtonFormField<Class>(
                          value: _selectedClass,
                          decoration: const InputDecoration(
                            labelText: 'Select Class',
                            border: OutlineInputBorder(),
                          ),
                          items: state.classes?.map((classModel) {
                            return DropdownMenuItem<Class>(
                              value: classModel,
                              child: Text('${classModel?.className} - ${classModel.sectionName}'),
                            );
                          }).toList() ?? [],
                          onChanged: (value) {
                            setState(() => _selectedClass = value);
                          },
                          validator: (value) => value == null ? 'Please select a class' : null,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: DropdownButtonFormField<AcademicYear>(
                          value: _selectedAcademicYear,
                          decoration: const InputDecoration(
                            labelText: 'Academic Year',
                            border: OutlineInputBorder(),
                          ),
                          items: state.academicYears?.map((year) {
                            return DropdownMenuItem<AcademicYear>(
                              value: year,
                              child: Text(year.year),
                            );
                          }).toList() ?? [],
                          onChanged: (value) {
                            setState(() => _selectedAcademicYear = value);
                          },
                          validator: (value) => value == null ? 'Please select academic year' : null,
                        ),
                      ),
                    ],
                  );
                }
                return const Center(child: CircularProgressIndicator());
              },
            ),

            const SizedBox(height: 16),

            // Fee Items Form
            Form(
              key: _formKey,
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        flex: 2,
                        child: TextFormField(
                          controller: _nameController,
                          decoration: const InputDecoration(
                            labelText: 'Fee Name',
                            border: OutlineInputBorder(),
                            hintText: 'e.g., Tuition Fee',
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Please enter fee name';
                            }
                            return null;
                          },
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: TextFormField(
                          controller: _amountController,
                          decoration: const InputDecoration(
                            labelText: 'Amount (₹)',
                            border: OutlineInputBorder(),
                            prefixText: '₹ ',
                          ),
                          keyboardType: TextInputType.number,
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Please enter amount';
                            }
                            if (double.tryParse(value) == null) {
                              return 'Invalid amount';
                            }
                            return null;
                          },
                        ),
                      ),
                      const SizedBox(width: 16),
                      Column(
                        children: [
                          Text('Mandatory', style: Theme.of(context).textTheme.bodySmall),
                          Switch(
                            value: _isMandatory,
                            onChanged: (value) => setState(() => _isMandatory = value),
                          ),
                        ],
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton.icon(
                        onPressed: _addFeeItem,
                        icon: const Icon(Icons.add),
                        label: const Text('Add'),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Added Fee Items List
            if (_tempFeeItems.isNotEmpty) ...[
              Text(
                'Fee Items Added',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  children: _tempFeeItems.asMap().entries.map((entry) {
                    final index = entry.key;
                    final item = entry.value;
                    return ListTile(
                      title: Text(item.name),
                      subtitle: Text('₹${item.amount}'),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Chip(
                            label: Text(
                              item.isMandatory ? 'Mandatory' : 'Optional',
                              style: const TextStyle(fontSize: 12),
                            ),
                            backgroundColor: item.isMandatory
                                ? Colors.green.shade100
                                : Colors.orange.shade100,
                          ),
                          const SizedBox(width: 8),
                          IconButton(
                            icon: const Icon(Icons.remove_circle, color: Colors.red),
                            onPressed: () => _removeFeeItem(index),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 16),

              // Action Buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: _resetForm,
                    child: const Text('Reset'),
                  ),
                  const SizedBox(width: 16),
                  ElevatedButton.icon(
                    onPressed: _saveFeeStructure,
                    icon: const Icon(Icons.save),
                    label: const Text('Save Fee Structure'),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildFeesStructureList(List<ClassFeesStructureDto> classFees) {
    if (classFees.isEmpty) {
      return _buildEmptyState();
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: classFees.length,
      itemBuilder: (context, index) {
        final classData = classFees[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 16),
          elevation: 2,
          child: ExpansionTile(
            leading: CircleAvatar(
              backgroundColor: Theme.of(context).primaryColor,
              child: Text(
                classData.className[0],
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
            title: Text(
              '${classData.className} - ${classData.sectionName}',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Academic Year: ${classData.academicYearName}'),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text('Total: ₹${classData.totalFees}'),
                    const SizedBox(width: 16),
                    Text('Items: ${classData.feeStructures.length}'),
                  ],
                ),
              ],
            ),
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    // Summary Cards
                    Row(
                      children: [
                        Expanded(
                          child: _buildSummaryCard(
                            'Mandatory Fees',
                            '₹${classData.totalMandatoryFees}',
                            Colors.green,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _buildSummaryCard(
                            'Optional Fees',
                            '₹${classData.totalOptionalFees}',
                            Colors.orange,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Fee Items Table
                    Table(
                      border: TableBorder.all(color: Colors.grey.shade300),
                      columnWidths: const {
                        0: FlexColumnWidth(3),
                        1: FlexColumnWidth(2),
                        2: FlexColumnWidth(1),
                        3: FlexColumnWidth(1),
                      },
                      children: [
                        // Header
                        TableRow(
                          decoration: BoxDecoration(color: Colors.grey.shade100),
                          children: const [
                            Padding(
                              padding: EdgeInsets.all(8.0),
                              child: Text('Fee Name', style: TextStyle(fontWeight: FontWeight.bold)),
                            ),
                            Padding(
                              padding: EdgeInsets.all(8.0),
                              child: Text('Amount', style: TextStyle(fontWeight: FontWeight.bold)),
                            ),
                            Padding(
                              padding: EdgeInsets.all(8.0),
                              child: Text('Type', style: TextStyle(fontWeight: FontWeight.bold)),
                            ),
                            Padding(
                              padding: EdgeInsets.all(8.0),
                              child: Text('Actions', style: TextStyle(fontWeight: FontWeight.bold)),
                            ),
                          ],
                        ),
                        // Data rows
                        ...classData.feeStructures.map((fee) {
                          return TableRow(
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(fee.name),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text('₹${fee.amount}'),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Chip(
                                  label: Text(
                                    fee.isMandatory ? 'M' : 'O',
                                    style: const TextStyle(fontSize: 10),
                                  ),
                                  backgroundColor: fee.isMandatory
                                      ? Colors.green.shade100
                                      : Colors.orange.shade100,
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(
                                      icon: const Icon(Icons.edit, size: 16),
                                      onPressed: () => _editFeeStructure(fee),
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.delete, size: 16, color: Colors.red),
                                      onPressed: () => _deleteFeeStructure(fee.id!),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          );
                        }).toList(),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSummaryCard(String title, String amount, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        border: Border.all(color: color.withOpacity(0.3)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            amount,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.receipt_long,
              size: 80,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              "No Fee Structures Yet",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "Create your first fee structure to get started!",
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[500],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => setState(() => _showCreateForm = true),
              icon: const Icon(Icons.add),
              label: const Text("Create Fee Structure"),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _editFeeStructure(FeesStructureDto fee) {
    // TODO: Implement edit functionality
    _showSnackBar('Edit functionality will be implemented soon');
  }

  void _deleteFeeStructure(String feeId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Fee Structure'),
        content: const Text('Are you sure you want to delete this fee structure?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            onPressed: () {
              context.read<FeesStructureBloc>().add(DeleteFeesStructure(feeId));
              Navigator.pop(context);
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Fee Structure Management'),
        actions: [
          if (!_showCreateForm)
            IconButton(
              icon: const Icon(Icons.add),
              onPressed: () => setState(() => _showCreateForm = true),
            ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => context.read<FeesStructureBloc>().add(LoadFeesStructures()),
          ),
        ],
      ),
      body: BlocConsumer<FeesStructureBloc, FeesStructureState>(
        listener: (context, state) {
          if (state is FeesStructureOperationSuccess) {
            _showSnackBar(state.message);
            _resetForm();
            context.read<FeesStructureBloc>().add(LoadFeesStructures());
          } else if (state is FeesStructureOperationFailure) {
            _showSnackBar(state.error, isError: true);
          }
        },
        builder: (context, state) {
          if (state is FeesStructureLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is FeesStructureLoaded) {
            return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (_showCreateForm) ...[
                    _buildCreateForm(),
                    const SizedBox(height: 24),
                  ],

                  if (state.classFees != null && state.classFees!.isNotEmpty) ...[
                    Row(
                      children: [
                        Text(
                          'Existing Fee Structures',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Spacer(),
                        if (!_showCreateForm)
                          ElevatedButton.icon(
                            onPressed: () => setState(() => _showCreateForm = true),
                            icon: const Icon(Icons.add),
                            label: const Text('Create New'),
                          ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _buildFeesStructureList(state.classFees!),
                  ] else if (!_showCreateForm) ...[
                    _buildEmptyState(),
                  ],
                ],
              ),
            );
          } else if (state is FeesStructureOperationFailure) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 80,
                    color: Colors.red[300],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    "Error Loading Fee Structures",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.red[700],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32),
                    child: Text(
                      state.error,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: () => context.read<FeesStructureBloc>().add(LoadFeesStructures()),
                    icon: const Icon(Icons.refresh),
                    label: const Text("Retry"),
                  ),
                ],
              ),
            );
          } else {
            return const Center(child: CircularProgressIndicator());
          }
        },
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _amountController.dispose();
    super.dispose();
  }
}