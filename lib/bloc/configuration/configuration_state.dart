import '../../models/configuration.dart';

abstract class ConfigurationState {}

class ConfigurationInitial extends ConfigurationState {}

class ConfigurationLoading extends ConfigurationState {}

/// When configuration is found and loaded
class ConfigurationLoaded extends ConfigurationState {
  final Configuration config;
  ConfigurationLoaded(this.config);
}

/// When configuration was not found / not set yet
class ConfigurationEmpty extends ConfigurationState {}

/// When an error occurred (e.g. network, server)
class ConfigurationError extends ConfigurationState {
  final String message;
  ConfigurationError(this.message);
}

/// When the config was successfully saved/updated
class ConfigurationUpdated extends ConfigurationState {}
