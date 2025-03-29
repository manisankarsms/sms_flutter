import 'package:bloc/bloc.dart';
import '../../repositories/staff_repository.dart';
import 'new_staff_event.dart';
import 'new_staff_state.dart';

class StaffRegistrationBloc extends Bloc<StaffRegistrationEvent, StaffRegistrationState> {
  final StaffRepository repository;

  StaffRegistrationBloc({required this.repository})
      : super(StaffRegistrationInitialState()) {
    on<SubmitStaffRegistrationEvent>(_onSubmitStaffRegistration);
  }

  Future<void> _onSubmitStaffRegistration(
      SubmitStaffRegistrationEvent event,
      Emitter<StaffRegistrationState> emit,
      ) async {
    emit(StaffRegistrationLoadingState());

    try {
      final bool isRegistered = await repository.registerStaff(event.staffData);

      if (isRegistered) {
        emit(StaffRegistrationSuccessState("Staff registered successfully"));
      } else {
        emit(StaffRegistrationErrorState("Staff registration failed. Please try again."));
      }
    } catch (error) {
      emit(StaffRegistrationErrorState("Error: ${error.toString()}"));
    }
  }
}
