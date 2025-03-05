import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import '../../utils/theme.dart';

part 'theme_event.dart';
part 'theme_state.dart';

class ThemeBloc extends Bloc<ThemeEvent, ThemeState> {
  ThemeBloc() : super(ThemeState(AppThemes.lightTheme)) {
    on<ChangeThemeEvent>((event, emit) {
      emit(ThemeState(event.themeData));
    });
  }
}
