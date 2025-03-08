import 'package:bloc/bloc.dart';

import '../../repositories/complaint_repository.dart';
import 'complaint_event.dart';
import 'complaint_state.dart';

class ComplaintBloc extends Bloc<ComplaintEvent, ComplaintState> {
  final ComplaintRepository complaintRepository;

  ComplaintBloc(this.complaintRepository) : super(ComplaintInitial()) {
    on<LoadComplaints>((event, emit) async {
      emit(ComplaintLoading());
      try {
        final complaints = await complaintRepository.fetchComplaints();
        emit(ComplaintLoaded(complaints));
      } catch (e) {
        emit(ComplaintError("Failed to load complaints"));
      }
    });

    on<AddComplaint>((event, emit) async {
      await complaintRepository.addComplaint(event.complaint);
      add(LoadComplaints());
    });

    // Handle status update with comment in Bloc
    on<UpdateComplaintStatus>((event, emit) async {
      try {
        await complaintRepository.updateComplaintStatus(event.id, event.status, event.comment);
        add(LoadComplaints()); // Refresh complaints after update
      } catch (e) {
        emit(ComplaintError("Failed to update status: ${e.toString()}"));
      }
    });
  }
}