import 'package:flutter_bloc/flutter_bloc.dart';

import '../../models/class.dart';
import '../../models/user.dart';
import '../../repositories/class_repository.dart';
import 'staff_classes_event.dart';
import 'staff_classes_state.dart';

class StaffClassesBloc extends Bloc<StaffClassesEvent, StaffClassesState> {
  final ClassRepository repository;
  final User user;

  StaffClassesBloc({required this.repository, required this.user})
      : super(const StaffClassesState()) {
    on<LoadStaffClasses>(_onLoadStaffClasses);
    add(LoadStaffClasses(staffId: user.id));
  }

  Future<void> _onLoadStaffClasses(
      LoadStaffClasses event,
      Emitter<StaffClassesState> emit,
      ) async {
    emit(state.copyWith(status: StaffClassesStatus.loading));
    /*try {
      final response = await repository.fetchClasses(user.id);

      // Handle myClass as a list
      final myClassList = (response['myClass'] as List?)?.map((json) => Class.fromJson(json)).toList() ?? [];

      final teachingClasses = (response['teachingClasses'] as List)
          .map((json) => Class.fromJson(json))
          .toList();

      emit(state.copyWith(
        status: StaffClassesStatus.success,
        myClasses: myClassList,
        teachingClasses: teachingClasses,
      ));
    } catch (e) {
      print("Error loading staff classes: $e");
      emit(state.copyWith(status: StaffClassesStatus.failure));
    }*/
  }
}
