import 'dart:ui';

import 'package:equatable/equatable.dart';

abstract class LanguageState extends Equatable {
  final Locale locale;
  const LanguageState(this.locale);

  @override
  List<Object?> get props => [locale];
}

class LanguageUpdated extends LanguageState {
  const LanguageUpdated(Locale locale) : super(locale);
}