import '../models/complaint.dart';

class ComplaintRepository {
  final List<Complaint> _complaints = [];

  Future<List<Complaint>> fetchComplaints() async {
    await Future.delayed(Duration(milliseconds: 500));
    return _complaints;
  }

  Future<void> addComplaint(Complaint complaint) async {
    await Future.delayed(Duration(milliseconds: 500));
    _complaints.add(complaint);
  }

  Future<void> updateComplaintStatus(String id, String status) async {
    await Future.delayed(Duration(milliseconds: 500));
    int index = _complaints.indexWhere((c) => c.id == id);
    if (index != -1) {
      _complaints[index] = _complaints[index].copyWith(status: status);
    }
  }
}
