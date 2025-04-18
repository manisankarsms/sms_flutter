import '../../models/configuration.dart';

abstract class ConfigurationEvent {}

class LoadConfiguration extends ConfigurationEvent {}

class UpdateConfiguration extends ConfigurationEvent {
  final Configuration updatedConfig;
  UpdateConfiguration(this.updatedConfig);
}
