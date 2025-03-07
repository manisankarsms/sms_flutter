import 'dart:ui';

import 'package:bloc/bloc.dart';

import 'language_event.dart';
import 'language_state.dart';

class LanguageBloc extends Bloc<LanguageEvent, LanguageState> {
  LanguageBloc() : super(const LanguageUpdated(Locale('en'))) {
    on<ChangeLanguage>((event, emit) {
      emit(LanguageUpdated(event.locale)); // Emit new locale
    });
  }
}