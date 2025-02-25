import 'package:equatable/equatable.dart';

abstract class HolidayEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class LoadHolidays extends HolidayEvent {}
