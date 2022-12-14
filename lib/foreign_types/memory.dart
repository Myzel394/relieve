import 'dart:io';

import 'package:gallery_saver/gallery_saver.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:relieve/enums.dart';
import 'package:uuid/uuid.dart';

import 'memory_location.dart';

const uuid = Uuid();

class Memory {
  final String id;
  final DateTime creationDate;
  final File file;
  final String annotation;
  final MemoryLocation? location;
  bool _hasBeenSavedToGallery;

  Memory({
    required this.id,
    required this.creationDate,
    required this.file,
    required this.annotation,
    bool hasBeenSavedToGallery = false,
    this.location,
  }) : _hasBeenSavedToGallery = hasBeenSavedToGallery;

  bool get hasBeenSavedToGallery => _hasBeenSavedToGallery;

  static parse(final Map<String, dynamic> jsonData) => Memory(
        id: jsonData['id'],
        creationDate: DateTime.parse(jsonData['created_at']),
        file: File(jsonData['file_path']),
        annotation: jsonData['annotation'],
        location: MemoryLocation.parse(jsonData['location']),
        hasBeenSavedToGallery: jsonData['has_been_saved_to_gallery'] == 'true',
      );

  static Future<Memory> createFromFile({
    required final File file,
    final String? annotation,
    final MemoryLocation? location,
  }) async {
    final creationDate = DateTime.now();
    final id = uuid.v4();

    final documentDirectory = await getApplicationDocumentsDirectory();
    final filename = '$id${extension(file.path)}';
    final path = '${documentDirectory.path}/$filename';

    await file.copy(path);

    return Memory(
      annotation: annotation ?? '',
      creationDate: creationDate,
      file: File(path),
      id: id,
      location: location,
    );
  }

  String get filename => basename(file.path);

  MemoryType get type =>
      filename.split('.').last == 'jpg' ? MemoryType.photo : MemoryType.video;

  Future<void> saveFileToGallery() async {
    _hasBeenSavedToGallery = true;

    switch (type) {
      case MemoryType.photo:
        await GallerySaver.saveImage(file.path);
        break;
      case MemoryType.video:
        await GallerySaver.saveVideo(file.path);
        break;
    }
  }

  Future<void> delete() async {
    await file.delete();
  }

  Map<String, dynamic> toJSON() => {
        'id': id,
        'created_at': creationDate.toIso8601String(),
        'file_path': file.path,
        'annotation': annotation,
        'location': location?.toJSON(),
        'has_been_saved_to_gallery': _hasBeenSavedToGallery ? 'true' : 'false',
      };
}
