import 'package:flutter_bloc/flutter_bloc.dart';
import '../../models/holiday.dart';
import '../../repositories/holiday_repository.dart';
import 'holiday_event.dart';
import 'holiday_state.dart';

class HolidayBloc extends Bloc<HolidayEvent, HolidayState> {
  final HolidayRepository repository;

  HolidayBloc({required this.repository}) : super(const HolidayState()) {
    on<LoadHolidays>(_onLoadHolidays);
    on<AddHoliday>(_onAddHoliday);
    on<UpdateHoliday>(_onUpdateHoliday);
    on<DeleteHoliday>(_onDeleteHoliday);

    // Automatically load holidays on initialization
    add(LoadHolidays());
  }

  Future<void> _onLoadHolidays(LoadHolidays event, Emitter<HolidayState> emit) async {
    // Only show loading if we don't have holidays yet
    if (state.holidays.isEmpty) {
      emit(state.copyWith(status: HolidayStatus.loading, clearError: true));
    }

    try {
      final holidays = await repository.fetchHolidays();
      emit(state.copyWith(
        status: HolidayStatus.success,
        holidays: holidays,
        isOperating: false,
        clearError: true,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: state.holidays.isEmpty ? HolidayStatus.failure : HolidayStatus.success,
        isOperating: false,
        errorMessage: 'Failed to load holidays: ${e.toString()}',
      ));
    }
  }

  Future<void> _onAddHoliday(AddHoliday event, Emitter<HolidayState> emit) async {
    emit(state.copyWith(isOperating: true, clearError: true));

    try {
      await repository.addHoliday(event.holiday);

      // Reload fresh data from server
      final holidays = await repository.fetchHolidays();
      emit(state.copyWith(
        status: HolidayStatus.success,
        holidays: holidays,
        isOperating: false,
        clearError: true,
      ));

    } catch (e) {
      // Keep the current holidays list and just show error
      emit(state.copyWith(
        isOperating: false,
        errorMessage: 'Failed to add holiday: ${e.toString()}',
      ));
    }
  }

  Future<void> _onUpdateHoliday(UpdateHoliday event, Emitter<HolidayState> emit) async {
    emit(state.copyWith(isOperating: true, clearError: true));

    try {
      await repository.updateHoliday(event.holiday);

      // Reload fresh data from server
      final holidays = await repository.fetchHolidays();
      emit(state.copyWith(
        status: HolidayStatus.success,
        holidays: holidays,
        isOperating: false,
        clearError: true,
      ));

    } catch (e) {
      // Keep the current holidays list and just show error
      emit(state.copyWith(
        isOperating: false,
        errorMessage: 'Failed to update holiday: ${e.toString()}',
      ));
    }
  }

  Future<void> _onDeleteHoliday(DeleteHoliday event, Emitter<HolidayState> emit) async {
    print('Before delete: status=${state.status}, holidays=${state.holidays.length}, isOperating=${state.isOperating}');
    final previousHolidays = List<Holiday>.from(state.holidays);
    emit(state.copyWith(isOperating: true, clearError: true));
    try {
      await repository.deleteHoliday(event.id);
      final holidays = await repository.fetchHolidays();
      print('After delete: holidays=${holidays.length}');
      emit(state.copyWith(
        status: HolidayStatus.success,
        holidays: holidays,
        isOperating: false,
        clearError: true,
      ));
    } catch (e) {
      print('Delete error: $e');
      emit(state.copyWith(
        status: HolidayStatus.success,
        holidays: previousHolidays,
        isOperating: false,
        errorMessage: 'Failed to delete holiday: ${e.toString()}',
      ));
    }
  }
}