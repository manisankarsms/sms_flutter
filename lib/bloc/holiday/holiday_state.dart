import 'package:equatable/equatable.dart';
import '../../models/holiday.dart';

enum HolidayStatus { initial, loading, success, failure }

class HolidayState extends Equatable {
  final HolidayStatus status;
  final List<Holiday> holidays;

  HolidayState({this.status = HolidayStatus.initial, this.holidays = const []});

  HolidayState copyWith({HolidayStatus? status, List<Holiday>? holidays}) {
    return HolidayState(
      status: status ?? this.status,
      holidays: holidays ?? this.holidays,
    );
  }

  @override
  List<Object?> get props => [status, holidays];
}