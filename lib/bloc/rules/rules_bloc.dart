import 'package:bloc/bloc.dart';
import 'package:sms/bloc/rules/rules_event.dart';
import 'package:sms/bloc/rules/rules_state.dart';

import '../../repositories/rules_repository.dart';

class RulesBloc extends Bloc<RulesEvent, RulesState> {
  final RulesRepository rulesRepository;

  RulesBloc(this.rulesRepository) : super(RulesLoading()) {
    on<LoadRulesEvent>((event, emit) async {
      try {
        final rules = await rulesRepository.getRules();
        emit(RulesLoaded(rules));
      } catch (e) {
        emit(RulesError("Failed to load rules"));
      }
    });
  }
}