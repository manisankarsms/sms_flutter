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

class ModernFeesStructureScreen extends StatefulWidget {
  const ModernFeesStructureScreen({super.key});

  @override
  State<ModernFeesStructureScreen> createState() => _ModernFeesStructureScreenState();
}

class _ModernFeesStructureScreenState extends State<ModernFeesStructureScreen> with TickerProviderStateMixin {
  late TabController _tabController;
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
    _tabController = TabController(length: 2, vsync: this);
    context.read<FeesStructureBloc>().add(LoadFeesStructures());
    context.read<FeesStructureBloc>().add(LoadClassesAndAcademicYears());
  }

  @override
  void dispose() {
    _tabController.dispose();
    _nameController.dispose();
    _amountController.dispose();
    super.dispose();
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
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
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
          return Column(
            children: [
              _buildHeader(),
              _buildTabBar(),
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildOverviewTab(state),
                    _buildCreateTab(state),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_back),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.receipt_long,
              color: Theme.of(context).primaryColor,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Fee Structures',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Manage fee structures for different classes',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () => context.read<FeesStructureBloc>().add(LoadFeesStructures()),
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      color: Colors.white,
      child: TabBar(
        controller: _tabController,
        indicatorColor: Theme.of(context).primaryColor,
        labelColor: Theme.of(context).primaryColor,
        unselectedLabelColor: Colors.grey[600],
        tabs: const [
          Tab(text: 'Overview'),
          Tab(text: 'Create New'),
        ],
      ),
    );
  }

  Widget _buildOverviewTab(FeesStructureState state) {
    if (state is FeesStructureLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state is FeesStructureLoaded) {
      if (state.classFees == null || state.classFees!.isEmpty) {
        return _buildEmptyState();
      }

      return SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildSummaryCards(state),
            const SizedBox(height: 24),
            _buildFeesStructureList(state.classFees!),
          ],
        ),
      );
    }

    return _buildEmptyState();
  }

  Widget _buildSummaryCards(FeesStructureLoaded state) {
    final totalClasses = state.classFees?.length ?? 0;
    final totalStructures = state.classFees?.fold<int>(0, (sum, classData) => sum + classData.feeStructures.length) ?? 0;

    return Row(
      children: [
        Expanded(
          child: _buildSummaryCard(
            title: 'Total Classes',
            value: '$totalClasses',
            icon: Icons.class_,
            color: Colors.blue,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildSummaryCard(
            title: 'Fee Structures',
            value: '$totalStructures',
            icon: Icons.receipt,
            color: Colors.green,
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCreateTab(FeesStructureState state) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildCreateForm(state),
          if (_tempFeeItems.isNotEmpty) ...[
            const SizedBox(height: 24),
            _buildFeeItemsList(),
          ],
        ],
      ),
    );
  }

  Widget _buildCreateForm(FeesStructureState state) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Create Fee Structure',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 24),

          // Class and Academic Year Selection
          if (state is FeesStructureLoaded) ...[
            Row(
              children: [
                Expanded(
                  child: _buildDropdownField<Class>(
                    label: 'Select Class',
                    value: _selectedClass,
                    items: state.classes ?? [],
                    itemBuilder: (classModel) => '${classModel?.className} - ${classModel.sectionName}',
                    onChanged: (value) => setState(() => _selectedClass = value),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildDropdownField<AcademicYear>(
                    label: 'Academic Year',
                    value: _selectedAcademicYear,
                    items: state.academicYears ?? [],
                    itemBuilder: (year) => year.year,
                    onChanged: (value) => setState(() => _selectedAcademicYear = value),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
          ],

          // Fee Item Form
          Text(
            'Add Fee Items',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),

          Form(
            key: _formKey,
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: _buildTextField(
                        controller: _nameController,
                        label: 'Fee Name',
                        hint: 'e.g., Tuition Fee',
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
                      child: _buildTextField(
                        controller: _amountController,
                        label: 'Amount',
                        hint: '0.00',
                        prefixText: '₹ ',
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
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.grey[50],
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey[300]!),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              _isMandatory ? Icons.star : Icons.star_border,
                              color: _isMandatory ? Colors.amber : Colors.grey,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              _isMandatory ? 'Mandatory Fee' : 'Optional Fee',
                              style: const TextStyle(fontWeight: FontWeight.w500),
                            ),
                            const Spacer(),
                            Switch(
                              value: _isMandatory,
                              onChanged: (value) => setState(() => _isMandatory = value),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    ElevatedButton.icon(
                      onPressed: _addFeeItem,
                      icon: const Icon(Icons.add),
                      label: const Text('Add Item'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          if (_tempFeeItems.isNotEmpty) ...[
            const SizedBox(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                OutlinedButton(
                  onPressed: _resetForm,
                  child: const Text('Reset'),
                ),
                const SizedBox(width: 16),
                ElevatedButton.icon(
                  onPressed: _saveFeeStructure,
                  icon: const Icon(Icons.save),
                  label: const Text('Save Structure'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildDropdownField<T>({
    required String label,
    required T? value,
    required List<T> items,
    required String Function(T) itemBuilder,
    required void Function(T?) onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontWeight: FontWeight.w500,
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey[300]!),
          ),
          child: DropdownButtonFormField<T>(
            value: value,
            decoration: InputDecoration(
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              hintText: 'Select $label',
            ),
            items: items.map((item) {
              return DropdownMenuItem<T>(
                value: item,
                child: Text(itemBuilder(item)),
              );
            }).toList(),
            onChanged: onChanged,
          ),
        ),
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    String? hint,
    String? prefixText,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontWeight: FontWeight.w500,
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          validator: validator,
          decoration: InputDecoration(
            hintText: hint,
            prefixText: prefixText,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Theme.of(context).primaryColor, width: 2),
            ),
            filled: true,
            fillColor: Colors.grey[50],
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
        ),
      ],
    );
  }

  Widget _buildFeeItemsList() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'Fee Items (${_tempFeeItems.length})',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              Text(
                'Total: ₹${_tempFeeItems.fold<double>(0, (sum, item) => sum + double.parse(item.amount)).toStringAsFixed(2)}',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).primaryColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...List.generate(_tempFeeItems.length, (index) {
            final item = _tempFeeItems[index];
            return Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey[200]!),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: item.isMandatory ? Colors.green.withOpacity(0.1) : Colors.orange.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      item.isMandatory ? Icons.star : Icons.star_border,
                      color: item.isMandatory ? Colors.green : Colors.orange,
                      size: 16,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.name,
                          style: const TextStyle(
                            fontWeight: FontWeight.w500,
                            fontSize: 14,
                          ),
                        ),
                        Text(
                          item.isMandatory ? 'Mandatory' : 'Optional',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    '₹${item.amount}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    onPressed: () => _removeFeeItem(index),
                    icon: const Icon(Icons.remove_circle, color: Colors.red),
                    iconSize: 20,
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildFeesStructureList(List<ClassFeesStructureDto> classFees) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Fee Structures by Class',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        ...classFees.map((classData) => _buildClassFeesCard(classData)),
      ],
    );
  }

  Widget _buildClassFeesCard(ClassFeesStructureDto classData) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ExpansionTile(
        tilePadding: const EdgeInsets.all(20),
        childrenPadding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
        leading: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Theme.of(context).primaryColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            classData.className[0],
            style: TextStyle(
              color: Theme.of(context).primaryColor,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ),
        title: Text(
          '${classData.className} - ${classData.sectionName}',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text('${classData.academicYearName}'),
            const SizedBox(height: 8),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '₹${classData.totalFees}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                      fontSize: 12,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  '${classData.feeStructures.length} items',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ],
        ),
        children: [
          _buildFeeStructureDetails(classData),
        ],
      ),
    );
  }

  Widget _buildFeeStructureDetails(ClassFeesStructureDto classData) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildDetailCard(
                'Mandatory Fees',
                '₹${classData.totalMandatoryFees}',
                Colors.green,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildDetailCard(
                'Optional Fees',
                '₹${classData.totalOptionalFees}',
                Colors.orange,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Container(
          decoration: BoxDecoration(
            color: Colors.grey[50],
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(12),
                    topRight: Radius.circular(12),
                  ),
                ),
                child: const Row(
                  children: [
                    Expanded(flex: 3, child: Text('Fee Name', style: TextStyle(fontWeight: FontWeight.bold))),
                    Expanded(flex: 2, child: Text('Amount', style: TextStyle(fontWeight: FontWeight.bold))),
                    Expanded(flex: 1, child: Text('Type', style: TextStyle(fontWeight: FontWeight.bold))),
                    SizedBox(width: 80, child: Text('Actions', style: TextStyle(fontWeight: FontWeight.bold))),
                  ],
                ),
              ),
              ...classData.feeStructures.map((fee) => Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border: Border(bottom: BorderSide(color: Colors.grey[200]!)),
                ),
                child: Row(
                  children: [
                    Expanded(flex: 3, child: Text(fee.name)),
                    Expanded(flex: 2, child: Text('₹${fee.amount}')),
                    Expanded(
                      flex: 1,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: fee.isMandatory ? Colors.green.withOpacity(0.1) : Colors.orange.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          fee.isMandatory ? 'M' : 'O',
                          style: TextStyle(
                            fontSize: 10,
                            color: fee.isMandatory ? Colors.green : Colors.orange,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      width: 80,
                      child: Row(
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
                ),
              )),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDetailCard(String title, String amount, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        border: Border.all(color: color.withOpacity(0.3)),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Text(
            title,
            style: const TextStyle(
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
              color: color,
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
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.receipt_long,
                size: 64,
                color: Colors.grey[400],
              ),
            ),
            const SizedBox(height: 24),
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
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: () => _tabController.animateTo(1),
              icon: const Icon(Icons.add),
              label: const Text("Create Fee Structure"),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
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
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Delete Fee Structure'),
        content: const Text('Are you sure you want to delete this fee structure?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
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
}