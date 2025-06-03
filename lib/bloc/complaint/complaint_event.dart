import 'package:flutter_bloc/flutter_bloc.dart';

import '../../models/complaint.dart';

// Events
abstract class ComplaintEvent {}

// Load all complaints (for admin)
class LoadComplaints extends ComplaintEvent {}

// Load complaints for a specific user
class LoadUserComplaints extends ComplaintEvent {
  final String userId;
  LoadUserComplaints(this.userId);
}

// Add complaint (general)
class AddComplaint extends ComplaintEvent {
  final Complaint complaint;
  AddComplaint(this.complaint);
}

// Add complaint for a specific user and reload their complaints
class AddUserComplaint extends ComplaintEvent {
  final Complaint complaint;
  final String userId;
  AddUserComplaint(this.complaint, this.userId);
}

// Update complaint status - IMPROVED VERSION
class UpdateComplaintStatus extends ComplaintEvent {
  final String id;
  final String status;
  final String comment;
  final String? userId; // Optional: if provided, reload user's complaints only

  UpdateComplaintStatus(this.id, this.status, this.comment, {this.userId});
}

// NEW: Separate event for adding comments from user view
class AddCommentToComplaint extends ComplaintEvent {
  final String complaintId;
  final String comment;
  final String userId; // The user viewing their complaints

  AddCommentToComplaint(this.complaintId, this.comment, this.userId);
}