import 'dart:io';
import 'package:bloc/bloc.dart';
import 'package:image_picker/image_picker.dart';
import '../../repositories/configuration_repository.dart';
import '../../models/configuration.dart';
import 'configuration_event.dart';
import 'configuration_state.dart';

class ConfigurationBloc extends Bloc<ConfigurationEvent, ConfigurationState> {
  final ConfigurationRepository repository;
  Configuration? _currentConfig; // Store current config

  ConfigurationBloc(this.repository) : super(ConfigurationInitial()) {
    // Handling LoadConfiguration event
    on<LoadConfiguration>((event, emit) async {
      emit(ConfigurationLoading());
      try {
        final config = await repository.fetchConfiguration();
        _currentConfig = config; // Store the loaded config
        if (config == null) {
          emit(ConfigurationEmpty()); // Show empty form or 'Setup Required'
        } else {
          emit(ConfigurationLoaded(config)); // Load configuration details
        }
      } catch (e) {
        emit(ConfigurationError('Failed to load configuration: $e')); // Show error message
      }
    });

    // Handling UpdateConfiguration event (without logo upload)
    on<UpdateConfiguration>((event, emit) async {
      emit(ConfigurationLoading());
      try {
        final success = await repository.updateConfiguration(event.updatedConfig);
        if (success) {
          _currentConfig = event.updatedConfig; // Update stored config
          emit(ConfigurationUpdated()); // Emit success state
          emit(ConfigurationLoaded(event.updatedConfig)); // Show updated config immediately
        } else {
          emit(ConfigurationError('Failed to update configuration'));
        }
      } catch (e) {
        emit(ConfigurationError('Failed to update configuration: $e')); // Show error message
      }
    });

    // Handling UpdateConfigurationWithLogo event
    on<UpdateConfigurationWithLogo>((event, emit) async {
      emit(ConfigurationLoading());
      try {
        final updatedConfig = await repository.updateConfigurationWithLogo(
          config: event.config,
          userId: event.userId,
          logoFile: event.logoFile,
          logoXFile: event.logoXFile,
        );

        if (updatedConfig != null) {
          _currentConfig = updatedConfig; // Update stored config
          emit(ConfigurationUpdated());
          emit(ConfigurationLoaded(updatedConfig)); // Show updated config immediately
        } else {
          emit(ConfigurationError('Failed to update configuration with logo'));
        }
      } catch (e) {
        emit(ConfigurationError('Failed to update configuration with logo: $e'));
      }
    });

    // Handling UploadLogo event (standalone logo upload)
    on<UploadLogo>((event, emit) async {
      emit(ConfigurationLogoUploading());
      try {
        final logoUrl = await repository.uploadLogo(
          userId: event.userId,
          logoFile: event.logoFile,
          logoXFile: event.logoXFile,
        );

        if (logoUrl != null) {
          emit(ConfigurationLogoUploaded(logoUrl));

          // Automatically update configuration with new logo URL
          if (_currentConfig != null) {
            final updatedConfig = Configuration(
              id: _currentConfig!.id,
              schoolName: _currentConfig!.schoolName,
              logoUrl: logoUrl, // Set the new logo URL
              address: _currentConfig!.address,
              email: _currentConfig!.email,
              phoneNumber1: _currentConfig!.phoneNumber1,
              phoneNumber2: _currentConfig!.phoneNumber2,
              phoneNumber3: _currentConfig!.phoneNumber3,
              phoneNumber4: _currentConfig!.phoneNumber4,
              phoneNumber5: _currentConfig!.phoneNumber5,
              website: _currentConfig!.website,
            );

            // Update configuration in database
            final success = await repository.updateConfiguration(updatedConfig);
            if (success) {
              _currentConfig = updatedConfig;
              emit(ConfigurationLoaded(updatedConfig)); // Refresh the UI with updated config
            }
          }
        } else {
          emit(ConfigurationError('Failed to upload logo'));
        }
      } catch (e) {
        emit(ConfigurationError('Failed to upload logo: $e'));
      }
    });
  }
}