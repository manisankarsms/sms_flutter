import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';
import 'dart:ui';
import '../bloc/complaint/complaint_bloc.dart';
import '../bloc/complaint/complaint_event.dart';
import '../bloc/complaint/complaint_state.dart';
import '../models/complaint.dart';
import '../models/user.dart';
import '../widgets/screen_header.dart';
import '../widgets/text_form_field.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class ComplaintScreen extends StatefulWidget {
  final User user;
  ComplaintScreen({Key? key, required this.user}) : super(key: key);

  @override
  _ComplaintScreenState createState() => _ComplaintScreenState();
}

class _ComplaintScreenState extends State<ComplaintScreen> with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _subjectController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _otherController = TextEditingController();

  String _selectedCategory = 'Staff';
  bool _isAnonymous = false;
  bool _isSubmitting = false;
  String _selectedStatusFilter = 'All';
  late TabController _tabController;

  final List<String> _categories = ['Staff', 'Transport', 'Management', 'Other'];
  final List<String> _statusFilters = ['All', 'Open', 'In Progress', 'Resolved', 'Closed'];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    context.read<ComplaintBloc>().add(LoadUserComplaints(widget.user.id));
  }

  @override
  void dispose() {
    _subjectController.dispose();
    _descriptionController.dispose();
    _otherController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  void _submitComplaint() {
    if (_formKey.currentState!.validate()) {
      final category = _selectedCategory == 'Other' ? _otherController.text.trim() : _selectedCategory;
      final complaint = Complaint(
        author: widget.user.id,
        id: Uuid().v4(),
        title: _subjectController.text.trim(),
        content: _descriptionController.text.trim(),
        category: category,
        status: 'Open',
        createdAt: DateTime.now().toString(),
        isAnonymous: _isAnonymous,
        comments: [],
      );
      context.read<ComplaintBloc>().add(AddUserComplaint(complaint, widget.user.id));
    }
  }

  void _resetForm() {
    _subjectController.clear();
    _descriptionController.clear();
    _otherController.clear();
    setState(() {
      _selectedCategory = 'Staff';
      _isAnonymous = false;
    });
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'open': return const Color(0xFFF59E0B);
      case 'in progress': return const Color(0xFF3B82F6);
      case 'resolved': return const Color(0xFF10B981);
      case 'closed': return const Color(0xFFEF4444);
      default: return const Color(0xFF6B7280);
    }
  }

  Widget _buildModernCard({required Widget child, EdgeInsets? padding}) {
    return Container(
      padding: padding ?? const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: child,
    );
  }

  Widget _buildGradientCard({required Widget child}) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF667EEA).withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.white.withOpacity(0.2)),
            ),
            child: child,
          ),
        ),
      ),
    );
  }

  Widget _buildComplaintForm() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildModernCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Complaint Details',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1F2937),
                    ),
                  ),
                  const SizedBox(height: 16),
                  CustomTextFormField(
                    controller: _subjectController,
                    label: 'Subject',
                    validator: (value) => value?.trim().isEmpty == true ? 'Please enter subject' : null,
                  ),
                  const SizedBox(height: 16),
                  CustomTextFormField(
                    controller: _descriptionController,
                    label: 'Description',
                    validator: (value) => value?.trim().isEmpty == true ? 'Please enter description' : null,
                    maxLines: 5,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            _buildModernCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Category',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1F2937),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 8.0,
                    runSpacing: 8.0,
                    children: _categories.map((category) {
                      final isSelected = _selectedCategory == category;
                      return GestureDetector(
                        onTap: _isSubmitting ? null : () {
                          setState(() {
                            _selectedCategory = category;
                            if (category != 'Other') _otherController.clear();
                          });
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                          decoration: BoxDecoration(
                            color: isSelected ? const Color(0xFF667EEA) : Colors.grey[100],
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: isSelected ? const Color(0xFF667EEA) : Colors.grey[300]!,
                            ),
                          ),
                          child: Text(
                            category,
                            style: TextStyle(
                              color: isSelected ? Colors.white : const Color(0xFF6B7280),
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  if (_selectedCategory == 'Other') ...[
                    const SizedBox(height: 16),
                    CustomTextFormField(
                      controller: _otherController,
                      label: 'Specify Other',
                      validator: (value) => value?.trim().isEmpty == true ? 'Please specify category' : null,
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 16),
            _buildModernCard(
              child: CheckboxListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text(
                  'Submit as Anonymous',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1F2937),
                  ),
                ),
                value: _isAnonymous,
                onChanged: _isSubmitting ? null : (value) => setState(() => _isAnonymous = value ?? false),
                controlAffinity: ListTileControlAffinity.leading,
                activeColor: const Color(0xFF667EEA),
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: _isSubmitting ? null : _submitComplaint,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF667EEA),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 0,
                ),
                child: _isSubmitting
                    ? const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                    ),
                    SizedBox(width: 12),
                    Text('Submitting...', style: TextStyle(fontSize: 16)),
                  ],
                )
                    : const Text('Submit Complaint', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildComplaintCard(Complaint complaint) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _showComplaintDetails(complaint),
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        complaint.title,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1F2937),
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: _getStatusColor(complaint.status),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        complaint.status,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  complaint.content,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                    height: 1.5,
                  ),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    _buildInfoChip(Icons.category_rounded, complaint.category, const Color(0xFF8B5CF6)),
                    const SizedBox(width: 12),
                    _buildInfoChip(Icons.schedule_rounded, _formatDate(complaint.createdAt), const Color(0xFF6B7280)),
                    if (complaint.comments.isNotEmpty) ...[
                      const SizedBox(width: 12),
                      _buildInfoChip(Icons.comment_rounded, '${complaint.comments.length}', const Color(0xFF3B82F6)),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoChip(IconData icon, String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(
              fontSize: 12,
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildComplaintsList() {
    return BlocBuilder<ComplaintBloc, ComplaintState>(
      builder: (context, state) {
        if (state is ComplaintLoading) {
          return const Center(child: CircularProgressIndicator(color: Color(0xFF667EEA)));
        } else if (state is ComplaintError) {
          return _buildErrorState(state.message);
        } else if (state is ComplaintLoaded) {
          final userComplaints = state.complaints;
          final filteredComplaints = _filterComplaints(userComplaints);

          if (userComplaints.isEmpty) {
            return _buildEmptyState();
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildFilterSection(),
                const SizedBox(height: 24),
                filteredComplaints.isEmpty
                    ? _buildNoFilterResults()
                    : Column(
                  children: filteredComplaints.map(_buildComplaintCard).toList(),
                ),
              ],
            ),
          );
        }
        return const Center(child: Text('Something went wrong'));
      },
    );
  }

  Widget _buildFilterSection() {
    return _buildModernCard(
      child: Row(
        children: [
          const Text(
            'Filter by status:',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1F2937),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(12),
              ),
              child: DropdownButton<String>(
                value: _selectedStatusFilter,
                isExpanded: true,
                underline: const SizedBox(),
                items: _statusFilters.map((status) {
                  return DropdownMenuItem(
                    value: status,
                    child: Text(status),
                  );
                }).toList(),
                onChanged: (newStatus) {
                  if (newStatus != null) {
                    setState(() => _selectedStatusFilter = newStatus);
                  }
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(24),
              ),
              child: Icon(Icons.inbox_rounded, size: 64, color: Colors.grey[400]),
            ),
            const SizedBox(height: 24),
            const Text(
              'No complaints yet',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1F2937),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'You haven\'t submitted any complaints yet.',
              style: TextStyle(color: Colors.grey[600]),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => _tabController.animateTo(0),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF667EEA),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
              child: const Text('Submit New Complaint'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.red[50],
                borderRadius: BorderRadius.circular(24),
              ),
              child: Icon(Icons.error_outline_rounded, size: 64, color: Colors.red[400]),
            ),
            const SizedBox(height: 24),
            const Text(
              'Something went wrong',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1F2937),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              style: TextStyle(color: Colors.grey[600]),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => context.read<ComplaintBloc>().add(LoadUserComplaints(widget.user.id)),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF667EEA),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
              child: const Text('Try Again'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNoFilterResults() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(24),
              ),
              child: Icon(Icons.filter_list_off_rounded, size: 64, color: Colors.grey[400]),
            ),
            const SizedBox(height: 24),
            const Text(
              'No complaints found',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1F2937),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'No complaints match the selected filter.',
              style: TextStyle(color: Colors.grey[600]),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  void _showComplaintDetails(Complaint complaint) {
    final commentController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(complaint.title),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildDetailRow('Category', complaint.category),
              const SizedBox(height: 12),
              _buildDetailRow('Status', complaint.status),
              const SizedBox(height: 12),
              _buildDetailRow('Description', complaint.content),
              if (complaint.isAnonymous) ...[
                const SizedBox(height: 12),
                const Text('(Anonymous Complaint)', style: TextStyle(color: Colors.red, fontStyle: FontStyle.italic)),
              ],
              const SizedBox(height: 16),
              const Text('Comments:', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              ...complaint.comments.map((comment) => _buildCommentTile(comment)).toList(),
              const SizedBox(height: 16),
              TextField(
                controller: commentController,
                maxLines: 3,
                decoration: const InputDecoration(
                  hintText: 'Add a comment...',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              if (commentController.text.trim().isNotEmpty) {
                context.read<ComplaintBloc>().add(
                  AddCommentToComplaint(
                    complaint.id,
                    commentController.text.trim(),
                    widget.user.id,
                  ),
                );
              }
              Navigator.pop(context);
            },
            child: const Text('Add Comment'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('$label: ', style: const TextStyle(fontWeight: FontWeight.bold)),
        Expanded(child: Text(value)),
      ],
    );
  }

  Widget _buildCommentTile(dynamic comment) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(comment.comment),
          const SizedBox(height: 4),
          Text(
            'By: ${comment.commentedBy} • ${comment.commentedAt}',
            style: TextStyle(fontSize: 12, color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  List<Complaint> _filterComplaints(List<Complaint> complaints) {
    return _selectedStatusFilter == 'All'
        ? complaints
        : complaints.where((complaint) => complaint.status == _selectedStatusFilter).toList();
  }

  String _formatDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      return '${date.day}/${date.month}/${date.year}';
    } catch (e) {
      return dateString;
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<ComplaintBloc, ComplaintState>(
      listener: (context, state) {
        if (state is ComplaintLoading) {
          setState(() => _isSubmitting = true);
        } else if (state is ComplaintLoaded) {
          setState(() => _isSubmitting = false);
          if (_subjectController.text.isNotEmpty) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: const Text('Complaint submitted successfully!'),
                backgroundColor: Colors.green,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                action: SnackBarAction(
                  label: 'View',
                  textColor: Colors.white,
                  onPressed: () => _tabController.animateTo(1),
                ),
              ),
            );
            _resetForm();
            _tabController.animateTo(1);
          }
        } else if (state is ComplaintError) {
          setState(() => _isSubmitting = false);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: Colors.red,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          );
        }
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFF8FAFC),
        appBar: AppBar(
          backgroundColor: const Color(0xFFF8FAFC),
          title: Text(AppLocalizations.of(context)?.complaint_title ?? "Complaints"),
          bottom: TabBar(
            controller: _tabController,
            indicatorColor: const Color(0xFF667EEA),
            labelColor: const Color(0xFF667EEA),
            unselectedLabelColor: Colors.grey,
            tabs: const [
              Tab(text: 'New'),
              Tab(text: 'My Complaints'),
            ],
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh_rounded),
              onPressed: () => context.read<ComplaintBloc>().add(LoadUserComplaints(widget.user.id)),
            ),
          ],
        ),
        body: TabBarView(
          controller: _tabController,
          children: [
            _buildComplaintForm(),
            _buildComplaintsList(),
          ],
        ),
      ),
    );
  }
}