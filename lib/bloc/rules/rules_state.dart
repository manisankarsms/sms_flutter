import 'package:equatable/equatable.dart';

enum RulesStatus { initial, loading, success, failure }

class RulesState extends Equatable {
  final RulesStatus status;
  final List<String> rules;
  final bool isOperating;
  final String? errorMessage;

  const RulesState({
    this.status = RulesStatus.initial,
    this.rules = const [],
    this.isOperating = false,
    this.errorMessage,
  });

  RulesState copyWith({
    RulesStatus? status,
    List<String>? rules,
    bool? isOperating,
    String? errorMessage,
    bool clearError = false,
  }) {
    return RulesState(
      status: status ?? this.status,
      rules: rules ?? this.rules,
      isOperating: isOperating ?? this.isOperating,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }

  @override
  List<Object?> get props => [status, rules, isOperating, errorMessage];
}