import 'dart:io';

import 'package:gallery_saver/gallery_saver.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:quid_faciam_hodie/enums.dart';
import 'package:uuid/uuid.dart';

import 'memory_location.dart';

const uuid = Uuid();

class Memory {
  final String id;
  final DateTime creationDate;
  final String filePath;
  final String annotation;
  final MemoryLocation? location;

  const Memory({
    required this.id,
    required this.creationDate,
    required this.filePath,
    required this.annotation,
    this.location,
  });

  static parse(final Map<String, dynamic> jsonData) => Memory(
        id: jsonData['id'],
        creationDate: DateTime.parse(jsonData['created_at']),
        filePath: jsonData['file_path'],
        annotation: jsonData['annotation'],
        location: MemoryLocation.parse(jsonData['location']),
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

    return Memory(
      annotation: annotation ?? '',
      creationDate: creationDate,
      filePath: path,
      id: id,
      location: location,
    );
  }

  String get filename => basename(filePath);

  MemoryType get type =>
      filename.split('.').last == 'jpg' ? MemoryType.photo : MemoryType.video;

  Future<File> downloadToFile() => throw Exception('not implemented');

  Future<void> saveFileToGallery() async {
    final file = await downloadToFile();

    switch (type) {
      case MemoryType.photo:
        await GallerySaver.saveImage(file.path);
        break;
      case MemoryType.video:
        await GallerySaver.saveVideo(file.path);
        break;
    }
  }

  Map<String, dynamic> toJSON() => {
        'id': id,
        'created_at': creationDate.toIso8601String(),
        'file_path': filePath,
        'annotation': annotation,
        'location': location?.toJSON(),
      };
}
