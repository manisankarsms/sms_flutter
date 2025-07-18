import 'package:equatable/equatable.dart';

import '../../models/fees_structures/BulkCreateFeesStructureRequest.dart';
import '../../models/fees_structures/CreateFeesStructureRequest.dart';
import '../../models/fees_structures/UpdateFeesStructureRequest.dart';

abstract class FeesStructureEvent extends Equatable {
  const FeesStructureEvent();
  @override
  List<Object?> get props => [];
}

class LoadFeesStructures extends FeesStructureEvent {}

class LoadClassesAndAcademicYears extends FeesStructureEvent {}

class LoadFeesStructuresByAcademicYear extends FeesStructureEvent {
  final String academicYearId;
  const LoadFeesStructuresByAcademicYear(this.academicYearId);
  @override
  List<Object?> get props => [academicYearId];
}

class CreateFeesStructure extends FeesStructureEvent {
  final CreateFeesStructureRequest request;
  const CreateFeesStructure(this.request);
  @override
  List<Object?> get props => [request];
}

class CreateBulkFeesStructure extends FeesStructureEvent {
  final BulkCreateFeesStructureRequest request;
  const CreateBulkFeesStructure(this.request);
  @override
  List<Object?> get props => [request];
}

class UpdateFeesStructure extends FeesStructureEvent {
  final String id;
  final UpdateFeesStructureRequest request;
  const UpdateFeesStructure(this.id, this.request);
  @override
  List<Object?> get props => [id, request];
}

class DeleteFeesStructure extends FeesStructureEvent {
  final String id;
  const DeleteFeesStructure(this.id);
  @override
  List<Object?> get props => [id];
}

class LoadFeesStructuresByClass extends FeesStructureEvent {
  final String classId;
  const LoadFeesStructuresByClass(this.classId);
  @override
  List<Object?> get props => [classId];
}