import 'package:bloc/bloc.dart';

import '../../repositories/complaint_repository.dart';
import 'complaint_event.dart';
import 'complaint_state.dart';

class ComplaintBloc extends Bloc<ComplaintEvent, ComplaintState> {
  final ComplaintRepository complaintRepository;

  ComplaintBloc(this.complaintRepository) : super(ComplaintInitial()) {
    // Load all complaints (for admin use)
    on<LoadComplaints>((event, emit) async {
      emit(ComplaintLoading());
      try {
        final complaints = await complaintRepository.fetchComplaints();
        emit(ComplaintLoaded(complaints));
      } catch (e) {
        emit(ComplaintError("Failed to load complaints"));
      }
    });

    // Load complaints for a specific user
    on<LoadUserComplaints>((event, emit) async {
      emit(ComplaintLoading());
      try {
        final complaints = await complaintRepository.fetchComplaintsByUserId(event.userId);
        emit(ComplaintLoaded(complaints));
      } catch (e) {
        emit(ComplaintError("Failed to load your complaints: ${e.toString()}"));
      }
    });

    // Add complaint and reload user's complaints
    on<AddUserComplaint>((event, emit) async {
      emit(ComplaintLoading());
      try {
        await complaintRepository.addComplaint(event.complaint);
        // After successfully adding, reload user's complaints to show updated list
        final complaints = await complaintRepository.fetchComplaintsByUserId(event.userId);
        emit(ComplaintLoaded(complaints));
      } catch (e) {
        emit(ComplaintError("Failed to submit complaint: ${e.toString()}"));
      }
    });

    // Original AddComplaint for backward compatibility
    on<AddComplaint>((event, emit) async {
      emit(ComplaintLoading());
      try {
        await complaintRepository.addComplaint(event.complaint);
        // After successfully adding, reload all complaints
        final complaints = await complaintRepository.fetchComplaints();
        emit(ComplaintLoaded(complaints));
      } catch (e) {
        emit(ComplaintError("Failed to submit complaint: ${e.toString()}"));
      }
    });

    // Handle status update with comment - IMPROVED VERSION
    on<UpdateComplaintStatus>((event, emit) async {
      try {
        await complaintRepository.updateComplaintStatus(event.id, event.status, event.comment);

        // If userId is provided, reload user's complaints; otherwise reload all
        final complaints = await complaintRepository.fetchComplaints();
        emit(ComplaintLoaded(complaints));
      } catch (e) {
        emit(ComplaintError("Failed to update status: ${e.toString()}"));
      }
    });

    // Handle adding comments from user view - NEW EVENT
    on<AddCommentToComplaint>((event, emit) async {
      try {
        // Get the current complaint to preserve its status
        final currentComplaints = await complaintRepository.fetchComplaintsByUserId(event.userId);
        final complaint = currentComplaints.firstWhere((c) => c.id == event.complaintId);

        await complaintRepository.addCommentToComplaint(
            complaintId: event.complaintId,
            comment: event.comment,
            commentedBy: "User"
        );

        // Reload user's complaints
        final complaints = await complaintRepository.fetchComplaintsByUserId(event.userId);
        emit(ComplaintLoaded(complaints));
      } catch (e) {
        emit(ComplaintError("Failed to add comment: ${e.toString()}"));
      }
    });
  }
}