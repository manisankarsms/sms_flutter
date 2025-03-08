import 'package:flutter_bloc/flutter_bloc.dart';

import '../../models/complaint.dart';

// Events
abstract class ComplaintEvent {}

class LoadComplaints extends ComplaintEvent {}

class AddComplaint extends ComplaintEvent {
  final Complaint complaint;
  AddComplaint(this.complaint);
}

class UpdateComplaintStatus extends ComplaintEvent {
  final String id;
  final String status;
  final String comment; // New comment field

  UpdateComplaintStatus(this.id, this.status, this.comment);
}
