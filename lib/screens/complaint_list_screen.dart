import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/complaint/complaint_bloc.dart';
import '../bloc/complaint/complaint_event.dart';
import '../bloc/complaint/complaint_state.dart';
import '../models/complaint.dart';

class ComplaintListScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    context.read<ComplaintBloc>().add(LoadComplaints());

    return Scaffold(
      appBar: AppBar(title: Text("Complaints")),
      body: BlocBuilder<ComplaintBloc, ComplaintState>(
        builder: (context, state) {
          if (state is ComplaintLoading) {
            return Center(child: CircularProgressIndicator());
          } else if (state is ComplaintLoaded) {
            return ListView.builder(
              itemCount: state.complaints.length,
              itemBuilder: (context, index) {
                final complaint = state.complaints[index];
                return Card(
                  margin: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  child: ListTile(
                    title: Text(complaint.subject,
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Category: ${complaint.category}",
                            style: TextStyle(
                                fontSize: 14, fontWeight: FontWeight.w500)),
                        Text("Status: ${complaint.status}",
                            style: TextStyle(
                                fontSize: 14, color: Colors.grey[700])),
                        if (complaint.isAnonymous)
                          Text("(Anonymous Complaint)",
                              style:
                              TextStyle(fontSize: 12, color: Colors.red)),
                      ],
                    ),
                    onTap: () {
                      _showComplaintDetails(context, complaint);
                    },
                  ),
                );
              },
            );
          } else if (state is ComplaintError) {
            return Center(child: Text(state.message));
          } else {
            return Center(child: Text("No complaints found"));
          }
        },
      ),
    );
  }

  void _showComplaintDetails(BuildContext context, Complaint complaint) {
    TextEditingController _commentController = TextEditingController();
    String _selectedStatus = complaint.status;
    bool _isCommentEnabled = false; // Initially, disable the comment field

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text(complaint.subject),
              content: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Category: ${complaint.category}",
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    SizedBox(height: 8),
                    Text("Status:", style: TextStyle(fontWeight: FontWeight.bold)),
                    DropdownButton<String>(
                      value: _selectedStatus,
                      items: ["Pending", "In Progress", "Resolved"]
                          .map((status) => DropdownMenuItem(
                        value: status,
                        child: Text(status),
                      ))
                          .toList(),
                      onChanged: (newStatus) {
                        if (newStatus != null && newStatus != complaint.status) {
                          setState(() {
                            _selectedStatus = newStatus;
                            _isCommentEnabled = true; // Enable the comment field when status changes
                          });
                        }
                      },
                    ),
                    SizedBox(height: 8),
                    Text("Description:", style: TextStyle(fontWeight: FontWeight.bold)),
                    SizedBox(height: 4),
                    Text(complaint.description),
                    if (complaint.isAnonymous)
                      Text("(Anonymous Complaint)",
                          style: TextStyle(fontSize: 12, color: Colors.red)),
                    SizedBox(height: 16),
                    Text("Comments:", style: TextStyle(fontWeight: FontWeight.bold)),
                    if (complaint.comments.isEmpty)
                      Text("No comments yet")
                    else
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: complaint.comments.map((comment) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text("- ${comment.comment}",
                                    style: TextStyle(fontSize: 14)),
                                Text("By: ${comment.commentedBy} • ${comment.commentedAt}",
                                    style: TextStyle(fontSize: 12, color: Colors.grey)),
                              ],
                            ),
                          );
                        }).toList(),
                      ),
                    SizedBox(height: 16),
                    TextField(
                      controller: _commentController,
                      enabled: _isCommentEnabled, // Comment field is enabled only when status changes
                      decoration: InputDecoration(
                        hintText: "Enter a comment (required for status change)",
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    if (_selectedStatus != complaint.status) {
                      if (_commentController.text.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text("Please enter a comment for status change.")),
                        );
                        return;
                      }
                      context.read<ComplaintBloc>().add(
                        UpdateComplaintStatus(
                            complaint.id, _selectedStatus, _commentController.text),
                      );
                    }
                    Navigator.pop(context);
                  },
                  child: Text("Update Status"),
                ),
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text("Close"),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
