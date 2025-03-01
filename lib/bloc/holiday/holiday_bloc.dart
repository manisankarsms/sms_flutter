import 'package:flutter_bloc/flutter_bloc.dart';

import '../../repositories/holiday_repository.dart';
import 'holiday_event.dart';
import 'holiday_state.dart';

class HolidayBloc extends Bloc<HolidayEvent, HolidayState> {
  final HolidayRepository repository;

  HolidayBloc({required this.repository}) : super(HolidayState()) {
    on<LoadHolidays>(_onLoadHolidays);
    add(LoadHolidays()); // Automatically load holidays on initialization
  }

  Future<void> _onLoadHolidays(LoadHolidays event, Emitter<HolidayState> emit) async {
    emit(state.copyWith(status: HolidayStatus.loading));

    try {
      final holidays = await repository.fetchHolidays();
      emit(state.copyWith(status: HolidayStatus.success, holidays: holidays));
    } catch (e) {
      emit(state.copyWith(status: HolidayStatus.failure));
    }
  }
}