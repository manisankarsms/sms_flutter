import 'package:equatable/equatable.dart';
import '../../models/holiday.dart';

enum HolidayStatus { initial, loading, success, failure }

class HolidayState extends Equatable {
  final HolidayStatus status;
  final List<Holiday> holidays;
  final bool isOperating;
  final String? errorMessage; // Add error message field

  const HolidayState({
    this.status = HolidayStatus.initial,
    this.holidays = const [],
    this.isOperating = false,
    this.errorMessage,
  });

  HolidayState copyWith({
    HolidayStatus? status,
    List<Holiday>? holidays,
    bool? isOperating,
    String? errorMessage,
    bool clearError = false, // Flag to clear error
  }) {
    return HolidayState(
      status: status ?? this.status,
      holidays: holidays ?? this.holidays,
      isOperating: isOperating ?? this.isOperating,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }

  @override
  List<Object?> get props => [status, holidays, isOperating, errorMessage];
}