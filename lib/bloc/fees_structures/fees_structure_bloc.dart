import 'package:bloc/bloc.dart';
import 'package:flutter/foundation.dart';

import '../../models/AcademicYear.dart';
import '../../models/class.dart';
import '../../models/fees_structures/FeesStructureDto.dart';
import '../../repositories/fees_structure_repository.dart';
import 'fees_structures_event.dart';
import 'fees_structures_state.dart';

class FeesStructureBloc extends Bloc<FeesStructureEvent, FeesStructureState> {
  final FeesStructureRepository feesStructureRepository;
  List<FeesStructureDto> _feesStructures = [];
  List<Class> _classes = [];
  List<AcademicYear> _academicYears = [];

  FeesStructureBloc({required this.feesStructureRepository}) : super(FeesStructureLoading()) {
    if (kDebugMode) {
      print("[FeesStructureBloc] Initialized.");
    }

    on<LoadFeesStructures>(_onLoadFeesStructures);
    on<LoadClassesAndAcademicYears>(_onLoadClassesAndAcademicYears);
    on<LoadFeesStructuresByAcademicYear>(_onLoadFeesStructuresByAcademicYear);
    on<CreateFeesStructure>(_onCreateFeesStructure);
    on<CreateBulkFeesStructure>(_onCreateBulkFeesStructure);
    on<UpdateFeesStructure>(_onUpdateFeesStructure);
    on<DeleteFeesStructure>(_onDeleteFeesStructure);
    on<LoadFeesStructuresByClass>(_onLoadFeesStructuresByClass);
  }

  Future<void> _onLoadFeesStructures(LoadFeesStructures event, Emitter<FeesStructureState> emit) async {
    try {
      if (kDebugMode) {
        print("[FeesStructureBloc] Processing LoadFeesStructures event");
      }
      emit(FeesStructureLoading());

      // Load fee structures for active academic year
      final activeAcademicYear = await feesStructureRepository.getActiveAcademicYear();
      if (activeAcademicYear != null) {
        final classFees = await feesStructureRepository.getClassFeesStructures(activeAcademicYear.id);
        final summary = await feesStructureRepository.getFeesStructureSummary(activeAcademicYear.id);

        if (kDebugMode) {
          print("[FeesStructureBloc] Loaded ${classFees.length} class fee structures");
        }

        emit(FeesStructureLoaded(
          classFees: classFees,
          summary: summary,
          classes: _classes,
          academicYears: _academicYears,
        ));
      } else {
        emit(FeesStructureLoaded(
          classFees: [],
          classes: _classes,
          academicYears: _academicYears,
        ));
      }
    } catch (e, stacktrace) {
      if (kDebugMode) {
        print("[FeesStructureBloc] Error loading fee structures: $e");
        print("[FeesStructureBloc] Stacktrace: $stacktrace");
      }
      emit(FeesStructureOperationFailure('Failed to load fee structures: ${e.toString()}', _feesStructures));
    }
  }

  Future<void> _onLoadClassesAndAcademicYears(LoadClassesAndAcademicYears event, Emitter<FeesStructureState> emit) async {
    try {
      if (kDebugMode) {
        print("[FeesStructureBloc] Processing LoadClassesAndAcademicYears event");
      }

      final classes = await feesStructureRepository.getClasses();
      final academicYears = await feesStructureRepository.getAcademicYears();

      _classes = classes;
      _academicYears = academicYears;

      if (kDebugMode) {
        print("[FeesStructureBloc] Loaded ${classes.length} classes and ${academicYears.length} academic years");
      }

      // If current state is FeesStructureLoaded, update it
      if (state is FeesStructureLoaded) {
        final currentState = state as FeesStructureLoaded;
        emit(currentState.copyWith(
          classes: classes,
          academicYears: academicYears,
        ));
      } else {
        emit(FeesStructureLoaded(
          classes: classes,
          academicYears: academicYears,
        ));
      }
    } catch (e) {
      if (kDebugMode) {
        print("[FeesStructureBloc] Error loading classes and academic years: $e");
      }
      emit(FeesStructureOperationFailure('Failed to load classes and academic years: ${e.toString()}', _feesStructures));
    }
  }

  Future<void> _onLoadFeesStructuresByAcademicYear(LoadFeesStructuresByAcademicYear event, Emitter<FeesStructureState> emit) async {
    try {
      emit(FeesStructureLoading());

      final classFees = await feesStructureRepository.getClassFeesStructures(event.academicYearId);
      final summary = await feesStructureRepository.getFeesStructureSummary(event.academicYearId);

      emit(FeesStructureLoaded(
        classFees: classFees,
        summary: summary,
        classes: _classes,
        academicYears: _academicYears,
      ));
    } catch (e) {
      emit(FeesStructureOperationFailure('Failed to load fee structures: ${e.toString()}', _feesStructures));
    }
  }

  Future<void> _onCreateFeesStructure(CreateFeesStructure event, Emitter<FeesStructureState> emit) async {
    try {
      emit(FeesStructureOperationInProgress(List.from(_feesStructures), "Creating fee structure..."));

      await feesStructureRepository.createFeesStructure(event.request);

      emit(FeesStructureOperationSuccess(List.from(_feesStructures), "Fee structure created successfully!"));
    } catch (e) {
      emit(FeesStructureOperationFailure('Failed to create fee structure: ${e.toString()}', List.from(_feesStructures)));
    }
  }

  Future<void> _onCreateBulkFeesStructure(CreateBulkFeesStructure event, Emitter<FeesStructureState> emit) async {
    try {
      emit(FeesStructureOperationInProgress(List.from(_feesStructures), "Creating fee structures..."));

      await feesStructureRepository.createBulkFeesStructures(event.request);

      emit(FeesStructureOperationSuccess(List.from(_feesStructures), "Fee structures created successfully!"));
    } catch (e) {
      emit(FeesStructureOperationFailure('Failed to create fee structures: ${e.toString()}', List.from(_feesStructures)));
    }
  }

  Future<void> _onUpdateFeesStructure(UpdateFeesStructure event, Emitter<FeesStructureState> emit) async {
    try {
      emit(FeesStructureOperationInProgress(List.from(_feesStructures), "Updating fee structure..."));

      await feesStructureRepository.updateFeesStructure(event.id, event.request);

      emit(FeesStructureOperationSuccess(List.from(_feesStructures), "Fee structure updated successfully!"));
    } catch (e) {
      emit(FeesStructureOperationFailure('Failed to update fee structure: ${e.toString()}', List.from(_feesStructures)));
    }
  }

  Future<void> _onDeleteFeesStructure(DeleteFeesStructure event, Emitter<FeesStructureState> emit) async {
    try {
      emit(FeesStructureOperationInProgress(List.from(_feesStructures), "Deleting fee structure..."));

      await feesStructureRepository.deleteFeesStructure(event.id);

      emit(FeesStructureOperationSuccess(List.from(_feesStructures), "Fee structure deleted successfully!"));
    } catch (e) {
      emit(FeesStructureOperationFailure('Failed to delete fee structure: ${e.toString()}', List.from(_feesStructures)));
    }
  }

  Future<void> _onLoadFeesStructuresByClass(LoadFeesStructuresByClass event, Emitter<FeesStructureState> emit) async {
    try {
      emit(FeesStructureLoading());

      final feesStructures = await feesStructureRepository.getFeesStructuresByClass(event.classId);
      _feesStructures = feesStructures;

      emit(FeesStructureLoaded(
        feesStructures: feesStructures,
        classes: _classes,
        academicYears: _academicYears,
      ));
    } catch (e) {
      emit(FeesStructureOperationFailure('Failed to load fee structures: ${e.toString()}', _feesStructures));
    }
  }
}