import 'dart:convert';

import 'package:camera/camera.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:relieve/constants/storage_keys.dart';
import 'package:relieve/enums/record_button_behavior.dart';
import 'package:relieve/utils/string_to_bool.dart';

const secure = FlutterSecureStorage();

class Settings extends ChangeNotifier {
  ResolutionPreset _resolution = ResolutionPreset.max;
  RecordButtonBehavior _recordButtonBehavior =
      RecordButtonBehavior.holdRecording;
  bool _askForMemoryAnnotations = false;
  bool _recordOnStartup = false;
  bool _saveToGallery = true;

  Settings({
    final ResolutionPreset? resolution,
    final RecordButtonBehavior? recordButtonBehavior,
    final bool? askForMemoryAnnotations,
    final bool? recordOnStartup,
    final bool? saveToGallery,
  })  : _resolution = resolution ?? ResolutionPreset.max,
        _askForMemoryAnnotations = askForMemoryAnnotations ?? false,
        _recordOnStartup = recordOnStartup ?? false,
        _saveToGallery = saveToGallery ?? false,
        _recordButtonBehavior =
            recordButtonBehavior ?? RecordButtonBehavior.holdRecording;

  ResolutionPreset get resolution => _resolution;
  RecordButtonBehavior get recordButtonBehavior => _recordButtonBehavior;
  bool get askForMemoryAnnotations => _askForMemoryAnnotations;
  bool get recordOnStartup => _recordOnStartup;
  bool get saveToGallery => _saveToGallery;

  Map<String, dynamic> toJSON() => {
        'resolution': _resolution.toString(),
        'recordButtonBehavior': _recordButtonBehavior.toString(),
        'askForMemoryAnnotations': _askForMemoryAnnotations ? 'true' : 'false',
        'recordOnStartup': _recordOnStartup ? 'true' : 'false',
        'saveToGallery': _saveToGallery ? 'true' : 'false',
      };

  Future<void> save() async {
    final data = toJSON();

    await secure.write(
      key: SETTINGS_KEY,
      value: jsonEncode(data),
    );
  }

  static Future<Settings> restore() async {
    final rawData = await secure.read(key: SETTINGS_KEY);

    if (rawData == null) {
      return Settings();
    }

    final data = jsonDecode(rawData);
    final resolution = ResolutionPreset.values.firstWhereOrNull(
      (preset) => preset.toString() == data['resolution'],
    );
    final recordButtonBehavior = RecordButtonBehavior.values.firstWhereOrNull(
      (preset) => preset.toString() == data['recordButtonBehavior'],
    );
    final askForMemoryAnnotations =
        stringToBool(data['askForMemoryAnnotations']);
    final recordOnStartup = stringToBool(data['recordOnStartup']);

    return Settings(
      resolution: resolution,
      askForMemoryAnnotations: askForMemoryAnnotations,
      recordOnStartup: recordOnStartup,
      recordButtonBehavior: recordButtonBehavior,
    );
  }

  void setResolution(final ResolutionPreset value) {
    _resolution = value;
    notifyListeners();
    save();
  }

  void setRecordButtonBehavior(final RecordButtonBehavior behavior) {
    _recordButtonBehavior = behavior;
    notifyListeners();
    save();
  }

  void setAskForMemoryAnnotations(final bool askForMemoryAnnotations) {
    _askForMemoryAnnotations = askForMemoryAnnotations;
    notifyListeners();
    save();
  }

  void setRecordOnStartup(final bool recordOnStartup) {
    _recordOnStartup = recordOnStartup;
    notifyListeners();
    save();
  }

  void setSaveToGallery(final bool saveToGallery) {
    _saveToGallery = saveToGallery;
    notifyListeners();
    save();
  }
}
