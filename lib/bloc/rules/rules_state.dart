abstract class RulesState {}

class RulesLoading extends RulesState {}

class RulesLoaded extends RulesState {
  final List<String> rules;
  RulesLoaded(this.rules);
}

class RulesError extends RulesState {
  final String message;
  RulesError(this.message);
}