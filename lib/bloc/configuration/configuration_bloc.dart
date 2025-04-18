import 'package:bloc/bloc.dart';
import '../../repositories/configuration_repository.dart';
import 'configuration_event.dart';
import 'configuration_state.dart';

class ConfigurationBloc extends Bloc<ConfigurationEvent, ConfigurationState> {
  final ConfigurationRepository repository;

  ConfigurationBloc(this.repository) : super(ConfigurationInitial()) {
    // Handling LoadConfiguration event
    on<LoadConfiguration>((event, emit) async {
      emit(ConfigurationLoading());
      try {
        final config = await repository.fetchConfiguration();
        if (config == null) {
          emit(ConfigurationEmpty()); // Show empty form or 'Setup Required'
        } else {
          emit(ConfigurationLoaded(config)); // Load configuration details
        }
      } catch (e) {
        emit(ConfigurationError('Failed to load configuration: $e')); // Show error message
      }
    });

    // Handling UpdateConfiguration event
    on<UpdateConfiguration>((event, emit) async {
      emit(ConfigurationLoading());
      try {
        await repository.updateConfiguration(event.updatedConfig);
        emit(ConfigurationUpdated()); // Emit success state
        add(LoadConfiguration()); // Reload the updated config
      } catch (e) {
        emit(ConfigurationError('Failed to update configuration: $e')); // Show error message
      }
    });
  }
}
