import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';
import '../bloc/complaint/complaint_bloc.dart';
import '../bloc/complaint/complaint_event.dart';
import '../bloc/complaint/complaint_state.dart';
import '../models/complaint.dart';
import '../models/user.dart';
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
  String _selectedStatusFilter = 'All'; // Add status filter

  late TabController _tabController;
  final List<String> _categories = ['Staff', 'Transport', 'Management', 'Other'];
  final List<String> _statusFilters = ['All', 'Open', 'In Progress', 'Resolved', 'Closed']; // Add filter options

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    // Load user's complaints when screen opens
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

  void _showSuccessSnackBar() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          AppLocalizations.of(context)?.complaint_submitted ?? 'Complaint submitted successfully!',
        ),
        backgroundColor: Colors.green,
        action: SnackBarAction(
          label: 'View',
          textColor: Colors.white,
          onPressed: () {
            _tabController.animateTo(1); // Switch to complaints list tab
          },
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'open':
        return Colors.orange;
      case 'in progress':
        return Colors.blue;
      case 'resolved':
        return Colors.green;
      case 'closed':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  void _showComplaintDetails(BuildContext context, Complaint complaint) {
    TextEditingController _commentController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(complaint.title),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("${AppLocalizations.of(context)?.category ?? "Category"}: ${complaint.category}",
                    style: TextStyle(fontWeight: FontWeight.bold)),
                SizedBox(height: 8),
                // Display status as read-only
                Text("${AppLocalizations.of(context)?.status ?? "Status"}: ",
                    style: TextStyle(fontWeight: FontWeight.bold)),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: _getStatusColor(complaint.status),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    complaint.status,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                SizedBox(height: 8),
                Text(AppLocalizations.of(context)?.complaint_description ?? "Description:",
                    style: TextStyle(fontWeight: FontWeight.bold)),
                SizedBox(height: 4),
                Text(complaint.content),
                if (complaint.isAnonymous)
                  Text(AppLocalizations.of(context)?.complaint_anonymous ?? "(Anonymous Complaint)",
                      style: TextStyle(fontSize: 12, color: Colors.red)),
                SizedBox(height: 16),
                Text(AppLocalizations.of(context)?.comments ?? "Comments:",
                    style: TextStyle(fontWeight: FontWeight.bold)),
                if (complaint.comments.isEmpty)
                  Text(AppLocalizations.of(context)?.no_comments_yet ?? "No comments yet")
                else
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: complaint.comments.map((comment) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Container(
                          padding: EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.grey[100],
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(comment.comment,
                                  style: TextStyle(fontSize: 14)),
                              SizedBox(height: 4),
                              Text("${AppLocalizations.of(context)?.by ?? "By"}: ${comment.commentedBy} • ${comment.commentedAt}",
                                  style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                SizedBox(height: 16),
                TextField(
                  controller: _commentController,
                  maxLines: 3,
                  decoration: InputDecoration(
                    hintText: AppLocalizations.of(context)?.enter_a_comment ?? "Add a comment (optional)",
                    border: OutlineInputBorder(),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                // Only add comment if there's text
                if (_commentController.text.trim().isNotEmpty) {
                  // Use the new AddCommentToComplaint event for user view
                  context.read<ComplaintBloc>().add(
                    AddCommentToComplaint(
                      complaint.id,
                      _commentController.text.trim(),
                      widget.user.id, // Pass the current user ID
                    ),
                  );
                }
                Navigator.pop(context);
              },
              child: Text("Add Comment"),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(AppLocalizations.of(context)?.close ?? "Close"),
            ),
          ],
        );
      },
    );
  }

  // Filter complaints based on selected status
  List<Complaint> _filterComplaints(List<Complaint> complaints) {
    if (_selectedStatusFilter == 'All') {
      return complaints;
    }
    return complaints.where((complaint) => complaint.status == _selectedStatusFilter).toList();
  }

  Widget _buildComplaintCard(Complaint complaint) {
    return Card(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 2,
      child: InkWell(
        onTap: () => _showComplaintDetails(context, complaint),
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      complaint.title,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  SizedBox(width: 8),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: _getStatusColor(complaint.status),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      complaint.status,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 8),
              Text(
                complaint.content,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
              SizedBox(height: 12),
              Column(
                children: [
                  Row(
                    children: [
                      Icon(Icons.category, size: 16, color: Colors.grey[600]),
                      SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          complaint.category,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      SizedBox(width: 8),
                      Icon(Icons.access_time, size: 16, color: Colors.grey[600]),
                      SizedBox(width: 4),
                      Text(
                        _formatDate(complaint.createdAt),
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                  if (complaint.isAnonymous || complaint.comments.isNotEmpty) ...[
                    SizedBox(height: 8),
                    Row(
                      children: [
                        if (complaint.isAnonymous) ...[
                          Icon(Icons.visibility_off, size: 16, color: Colors.grey[600]),
                          SizedBox(width: 4),
                          Text(
                            'Anonymous',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ],
                        if (complaint.isAnonymous && complaint.comments.isNotEmpty)
                          SizedBox(width: 16),
                        if (complaint.comments.isNotEmpty) ...[
                          Icon(Icons.comment, size: 16, color: Colors.blue),
                          SizedBox(width: 4),
                          Text(
                            '${complaint.comments.length} comment${complaint.comments.length > 1 ? 's' : ''}',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.blue,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      return '${date.day}/${date.month}/${date.year}';
    } catch (e) {
      return dateString;
    }
  }

  Widget _buildComplaintForm() {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CustomTextFormField(
                controller: _subjectController,
                label: AppLocalizations.of(context)?.complaint_subject ?? "Subject",
                validator: (value) => value?.trim().isEmpty == true
                    ? AppLocalizations.of(context)?.complaint_subject_hint ?? "Please enter subject"
                    : null,
              ),
              SizedBox(height: 16),
              CustomTextFormField(
                controller: _descriptionController,
                label: AppLocalizations.of(context)?.complaint_description ?? "Description",
                validator: (value) => value?.trim().isEmpty == true
                    ? AppLocalizations.of(context)?.complaint_description_hint ?? "Please enter description"
                    : null,
                maxLines: 5,
              ),
              SizedBox(height: 16),
              Text(
                AppLocalizations.of(context)?.complaint_about ?? "Complaint About",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Wrap(
                spacing: 8.0,
                children: _categories.map((category) {
                  return ChoiceChip(
                    label: Text(category),
                    selected: _selectedCategory == category,
                    onSelected: _isSubmitting ? null : (selected) {
                      setState(() {
                        _selectedCategory = category;
                        if (category != 'Other') _otherController.clear();
                      });
                    },
                  );
                }).toList(),
              ),
              if (_selectedCategory == 'Other') ...[
                SizedBox(height: 16),
                CustomTextFormField(
                  controller: _otherController,
                  label: AppLocalizations.of(context)?.complaint_other_specify ?? "Specify Other",
                  validator: (value) => value?.trim().isEmpty == true
                      ? "Please specify the complaint category"
                      : null,
                ),
              ],
              SizedBox(height: 16),
              CheckboxListTile(
                title: Text(AppLocalizations.of(context)?.complaint_anonymous ?? "Submit as Anonymous"),
                value: _isAnonymous,
                onChanged: _isSubmitting ? null : (value) {
                  setState(() {
                    _isAnonymous = value ?? false;
                  });
                },
                controlAffinity: ListTileControlAffinity.leading,
              ),
              SizedBox(height: 24),
              Center(
                child: SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: _isSubmitting ? null : () {
                      if (_formKey.currentState!.validate()) {
                        _submitComplaint();
                      }
                    },
                    child: _isSubmitting
                        ? const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        ),
                        SizedBox(width: 12),
                        Text('Submitting...'),
                      ],
                    )
                        : Text(AppLocalizations.of(context)?.submit ?? "Submit"),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildComplaintsList() {
    return BlocBuilder<ComplaintBloc, ComplaintState>(
      builder: (context, state) {
        if (state is ComplaintLoading) {
          return Center(child: CircularProgressIndicator());
        } else if (state is ComplaintError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline, size: 64, color: Colors.red),
                SizedBox(height: 16),
                Text(
                  'Error loading complaints',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 8),
                Text(
                  state.message,
                  style: TextStyle(color: Colors.grey[600]),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    context.read<ComplaintBloc>().add(LoadUserComplaints(widget.user.id));
                  },
                  child: Text('Retry'),
                ),
              ],
            ),
          );
        } else if (state is ComplaintLoaded) {
          final userComplaints = state.complaints;
          final filteredComplaints = _filterComplaints(userComplaints);

          if (userComplaints.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.inbox, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text(
                    'No complaints found',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'You haven\'t submitted any complaints yet.',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                  SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      _tabController.animateTo(0); // Switch to form tab
                    },
                    child: Text('Submit New Complaint'),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () async {
              context.read<ComplaintBloc>().add(LoadUserComplaints(widget.user.id));
            },
            child: Column(
              children: [
                Container(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              'Total: ${userComplaints.length} complaint${userComplaints.length > 1 ? 's' : ''}',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 8),
                      _buildStatusSummary(userComplaints),
                      SizedBox(height: 8),
                      // Status filter dropdown
                      Row(
                        children: [
                          Text('Filter by status: ', style: TextStyle(fontWeight: FontWeight.bold)),
                          Expanded(
                            child: DropdownButton<String>(
                              value: _selectedStatusFilter,
                              isExpanded: true,
                              items: _statusFilters.map((status) {
                                return DropdownMenuItem(
                                  value: status,
                                  child: Text(status),
                                );
                              }).toList(),
                              onChanged: (newStatus) {
                                if (newStatus != null) {
                                  setState(() {
                                    _selectedStatusFilter = newStatus;
                                  });
                                }
                              },
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: filteredComplaints.isEmpty
                      ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.filter_list_off, size: 64, color: Colors.grey),
                        SizedBox(height: 16),
                        Text(
                          'No complaints found',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'No complaints match the selected filter.',
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                      ],
                    ),
                  )
                      : ListView.builder(
                    itemCount: filteredComplaints.length,
                    itemBuilder: (context, index) {
                      return _buildComplaintCard(filteredComplaints[index]);
                    },
                  ),
                ),
              ],
            ),
          );
        }

        return Center(child: Text('Something went wrong'));
      },
    );
  }

  Widget _buildStatusSummary(List<Complaint> complaints) {
    final statusCounts = <String, int>{};
    for (final complaint in complaints) {
      statusCounts[complaint.status] = (statusCounts[complaint.status] ?? 0) + 1;
    }

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      alignment: WrapAlignment.center,
      children: statusCounts.entries.map((entry) {
        final isSelected = _selectedStatusFilter == entry.key;
        return GestureDetector(
          onTap: () {
            setState(() {
              _selectedStatusFilter = isSelected ? 'All' : entry.key;
            });
          },
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: isSelected
                  ? _getStatusColor(entry.key)
                  : _getStatusColor(entry.key).withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: _getStatusColor(entry.key),
                width: 1,
              ),
            ),
            child: Text(
              '${entry.key}: ${entry.value}',
              style: TextStyle(
                fontSize: 12,
                color: isSelected ? Colors.white : _getStatusColor(entry.key),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<ComplaintBloc, ComplaintState>(
      listener: (context, state) {
        if (state is ComplaintLoading) {
          setState(() => _isSubmitting = true);
        } else if (state is ComplaintLoaded) {
          setState(() => _isSubmitting = false);
          // Only show success message for new complaint submission, not for comment additions
          if (_subjectController.text.isNotEmpty) {
            _showSuccessSnackBar();
            _resetForm();
            // Navigate to My Complaints tab after successful submission
            _tabController.animateTo(1);
          }
        } else if (state is ComplaintError) {
          setState(() => _isSubmitting = false);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: Colors.red,
            ),
          );
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(AppLocalizations.of(context)?.complaint_title ?? "Complaints"),
          bottom: TabBar(
            controller: _tabController,
            tabs: [
              Tab(
                icon: Icon(Icons.add),
                text: 'New Complaint',
              ),
              Tab(
                icon: Icon(Icons.list),
                text: 'My Complaints',
              ),
            ],
          ),
          actions: [
            IconButton(
              icon: Icon(Icons.refresh),
              onPressed: () {
                context.read<ComplaintBloc>().add(LoadUserComplaints(widget.user.id));
              },
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