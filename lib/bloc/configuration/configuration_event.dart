import 'dart:io';

import 'package:image_picker/image_picker.dart';

import '../../models/configuration.dart';

abstract class ConfigurationEvent {}

class LoadConfiguration extends ConfigurationEvent {}

class UpdateConfiguration extends ConfigurationEvent {
  final Configuration updatedConfig;
  UpdateConfiguration(this.updatedConfig);
}

class UpdateConfigurationWithLogo extends ConfigurationEvent {
  final Configuration config;
  final String userId;
  final File? logoFile;
  final XFile? logoXFile;

  UpdateConfigurationWithLogo({
    required this.config,
    required this.userId,
    this.logoFile,
    this.logoXFile,
  });
}

class UploadLogo extends ConfigurationEvent {
  final String userId;
  final File? logoFile;
  final XFile? logoXFile;

  UploadLogo({
    required this.userId,
    this.logoFile,
    this.logoXFile,
  });
}