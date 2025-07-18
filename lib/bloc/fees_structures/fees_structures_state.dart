import 'package:equatable/equatable.dart';

import '../../models/AcademicYear.dart';
import '../../models/class.dart';
import '../../models/fees_structures/ClassFeesStructureDto.dart';
import '../../models/fees_structures/FeesStructureDto.dart';
import '../../models/fees_structures/FeesStructureSummaryDto.dart';

abstract class FeesStructureState extends Equatable {
  const FeesStructureState();
  @override
  List<Object?> get props => [];
}

class FeesStructureLoading extends FeesStructureState {}

class FeesStructureLoaded extends FeesStructureState {
  final List<FeesStructureDto>? feesStructures;
  final List<ClassFeesStructureDto>? classFees;
  final List<Class>? classes;
  final List<AcademicYear>? academicYears;
  final FeesStructureSummaryDto? summary;

  const FeesStructureLoaded({
    this.feesStructures,
    this.classFees,
    this.classes,
    this.academicYears,
    this.summary,
  });

  @override
  List<Object?> get props => [feesStructures, classFees, classes, academicYears, summary];

  FeesStructureLoaded copyWith({
    List<FeesStructureDto>? feesStructures,
    List<ClassFeesStructureDto>? classFees,
    List<Class>? classes,
    List<AcademicYear>? academicYears,
    FeesStructureSummaryDto? summary,
  }) {
    return FeesStructureLoaded(
      feesStructures: feesStructures ?? this.feesStructures,
      classFees: classFees ?? this.classFees,
      classes: classes ?? this.classes,
      academicYears: academicYears ?? this.academicYears,
      summary: summary ?? this.summary,
    );
  }
}

class FeesStructureOperationInProgress extends FeesStructureState {
  final List<FeesStructureDto> currentFeesStructures;
  final String operation;
  const FeesStructureOperationInProgress(this.currentFeesStructures, this.operation);
  @override
  List<Object?> get props => [currentFeesStructures, operation];
}

class FeesStructureOperationSuccess extends FeesStructureState {
  final List<FeesStructureDto> feesStructures;
  final String message;
  const FeesStructureOperationSuccess(this.feesStructures, this.message);
  @override
  List<Object?> get props => [feesStructures, message];
}

class FeesStructureOperationFailure extends FeesStructureState {
  final String error;
  final List<FeesStructureDto> currentFeesStructures;
  const FeesStructureOperationFailure(this.error, this.currentFeesStructures);
  @override
  List<Object?> get props => [error, currentFeesStructures];
}