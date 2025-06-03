import 'package:flutter_bloc/flutter_bloc.dart';
import '../../repositories/rules_repository.dart';
import 'rules_event.dart';
import 'rules_state.dart';

class RulesBloc extends Bloc<RulesEvent, RulesState> {
  final RulesRepository repository;

  RulesBloc({required this.repository}) : super(const RulesState()) {
    on<LoadRulesEvent>(_onLoadRules);
    on<AddRuleEvent>(_onAddRule);
    on<UpdateRuleEvent>(_onUpdateRule);
    on<DeleteRuleEvent>(_onDeleteRule);

    // Automatically load rules on initialization
    add(LoadRulesEvent());
  }

  Future<void> _onLoadRules(LoadRulesEvent event, Emitter<RulesState> emit) async {
    // Only show loading if we don't have rules yet
    if (state.rules.isEmpty) {
      emit(state.copyWith(status: RulesStatus.loading, clearError: true));
    }

    try {
      final rules = await repository.fetchRules();
      emit(state.copyWith(
        status: RulesStatus.success,
        rules: rules,
        isOperating: false,
        clearError: true,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: state.rules.isEmpty ? RulesStatus.failure : RulesStatus.success,
        isOperating: false,
        errorMessage: 'Failed to load rules: ${e.toString()}',
      ));
    }
  }

  Future<void> _onAddRule(AddRuleEvent event, Emitter<RulesState> emit) async {
    emit(state.copyWith(isOperating: true, clearError: true));

    try {
      await repository.addRule(event.rule);

      // Reload fresh data from server
      final rules = await repository.fetchRules();
      emit(state.copyWith(
        status: RulesStatus.success,
        rules: rules,
        isOperating: false,
        clearError: true,
      ));

    } catch (e) {
      // Keep the current rules list and just show error
      emit(state.copyWith(
        isOperating: false,
        errorMessage: 'Failed to add rule: ${e.toString()}',
      ));
    }
  }

  Future<void> _onUpdateRule(UpdateRuleEvent event, Emitter<RulesState> emit) async {
    emit(state.copyWith(isOperating: true, clearError: true));

    try {
      await repository.updateRule(event.index, event.rule);

      // Reload fresh data from server
      final rules = await repository.fetchRules();
      emit(state.copyWith(
        status: RulesStatus.success,
        rules: rules,
        isOperating: false,
        clearError: true,
      ));

    } catch (e) {
      // Keep the current rules list and just show error
      emit(state.copyWith(
        isOperating: false,
        errorMessage: 'Failed to update rule: ${e.toString()}',
      ));
    }
  }

  Future<void> _onDeleteRule(DeleteRuleEvent event, Emitter<RulesState> emit) async {
    print('Before delete: status=${state.status}, rules=${state.rules.length}, isOperating=${state.isOperating}');
    final previousRules = List<String>.from(state.rules);
    emit(state.copyWith(isOperating: true, clearError: true));

    try {
      await repository.deleteRule(event.index);

      // Reload fresh data from server
      final rules = await repository.fetchRules();
      print('After delete: rules=${rules.length}');
      emit(state.copyWith(
        status: RulesStatus.success,
        rules: rules,
        isOperating: false,
        clearError: true,
      ));
    } catch (e) {
      print('Delete error: $e');
      emit(state.copyWith(
        status: RulesStatus.success,
        rules: previousRules,
        isOperating: false,
        errorMessage: 'Failed to delete rule: ${e.toString()}',
      ));
    }
  }
}