import 'package:equatable/equatable.dart';

import '../../models/holiday.dart';

abstract class HolidayEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class LoadHolidays extends HolidayEvent {}

class AddHoliday extends HolidayEvent {
  final Holiday holiday;

  AddHoliday(this.holiday);

  @override
  List<Object?> get props => [holiday];
}

class UpdateHoliday extends HolidayEvent {
  final Holiday holiday;

  UpdateHoliday(this.holiday);

  @override
  List<Object?> get props => [holiday];
}

class DeleteHoliday extends HolidayEvent {
  final int id;

  DeleteHoliday(this.id);

  @override
  List<Object?> get props => [id];
}