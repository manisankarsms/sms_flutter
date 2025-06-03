import 'package:equatable/equatable.dart';

abstract class RulesEvent extends Equatable {
  const RulesEvent();

  @override
  List<Object?> get props => [];
}

class LoadRulesEvent extends RulesEvent {}

class AddRuleEvent extends RulesEvent {
  final String rule;

  const AddRuleEvent(this.rule);

  @override
  List<Object?> get props => [rule];
}

class UpdateRuleEvent extends RulesEvent {
  final int index;
  final String rule;

  const UpdateRuleEvent(this.index, this.rule);

  @override
  List<Object?> get props => [index, rule];
}

class DeleteRuleEvent extends RulesEvent {
  final int index;

  const DeleteRuleEvent(this.index);

  @override
  List<Object?> get props => [index];
}
