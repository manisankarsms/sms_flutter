import 'package:flutter_bloc/flutter_bloc.dart';

import '../../models/fees.dart';
import '../../repositories/fees_repository.dart';

part 'fees_event.dart';
part 'fees_state.dart';

class FeesBloc extends Bloc<FeesEvent, FeesState> {
  final FeesRepository repository;

  FeesBloc(this.repository) : super(FeesInitial()) {
    on<LoadFees>((event, emit) async {
      emit(FeesLoading());
      try {
        final academicYearFees = await repository.fetchFees();
        emit(FeesLoaded(academicYearFees));
      } catch (e) {
        emit(FeesError("Failed to fetch fees"));
      }
    });

    on<AddClassFees>((event, emit) async {
      if (state is FeesLoaded) {
        final currentState = state as FeesLoaded;
        final updatedFees = Map<String, AcademicYearFees>.from(currentState.academicYearFees);

        updatedFees.putIfAbsent(event.academicYear, () => AcademicYearFees(classFees: {}));
        updatedFees[event.academicYear]!.classFees[event.className] = event.classFees;

        emit(FeesLoaded(updatedFees));
      }
    });

    on<UpdateClassFees>((event, emit) async {
      if (state is FeesLoaded) {
        final currentState = state as FeesLoaded;
        final updatedFees = Map<String, AcademicYearFees>.from(currentState.academicYearFees);

        if (updatedFees.containsKey(event.academicYear) &&
            updatedFees[event.academicYear]!.classFees.containsKey(event.className)) {
          updatedFees[event.academicYear]!.classFees[event.className] = event.updatedClassFees;
          emit(FeesLoaded(updatedFees));
        }
      }
    });

    on<DeleteClassFees>((event, emit) async {
      if (state is FeesLoaded) {
        final currentState = state as FeesLoaded;
        final updatedFees = Map<String, AcademicYearFees>.from(currentState.academicYearFees);

        if (updatedFees.containsKey(event.academicYear)) {
          updatedFees[event.academicYear]!.classFees.remove(event.className);
          emit(FeesLoaded(updatedFees));
        }
      }
    });

    on<CopyFeesToNextYear>((event, emit) async {
      if (state is FeesLoaded) {
        final currentState = state as FeesLoaded;
        final updatedFees = Map<String, AcademicYearFees>.from(currentState.academicYearFees);

        if (updatedFees.containsKey(event.currentYear)) {
          updatedFees[event.nextYear] = AcademicYearFees(
            classFees: Map<String, ClassFees>.from(updatedFees[event.currentYear]!.classFees),
          );
          emit(FeesLoaded(updatedFees));
        }
      }
    });
  }
}


