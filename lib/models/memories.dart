import 'dart:convert';

import 'package:collection/collection.dart';
import 'package:property_change_notifier/property_change_notifier.dart';
import 'package:quid_faciam_hodie/constants/storage_keys.dart';
import 'package:quid_faciam_hodie/foreign_types/memory.dart';
import 'package:quid_faciam_hodie/screens/welcome_screen.dart';

class Memories extends PropertyChangeNotifier<String> {
  late final List<Memory> _memories;

  Memories({
    final List<Memory>? memories,
  }) : _memories = memories ?? [];

  static Future<Memories> restore() async {
    final rawData = await storage.read(key: MEMORIES_KEY);

    if (rawData == null) {
      return Memories();
    }

    final data = jsonDecode(rawData);
    final memories =
        data.map<Memory>((memory) => Memory.parse(memory)).toList();

    return Memories(
      memories: memories,
    ).._sortMemories();
  }

  List<Memory> get memories => _memories;
  Memory? get latest => _memories.firstOrNull;

  Future<void> addMemory(final Memory memory) async {
    _memories.add(memory);
    _sortMemories();
    notifyListeners('memories');
    await save();
  }

  Future<void> removeMemory(final Memory memory) async {
    _memories.remove(memory);
    _sortMemories();
    notifyListeners('memories');
    await save();
  }

  Future<void> removeMemoryByID(final String id) async {
    final memory = _memories.firstWhereOrNull((memory) => memory.id == id);

    if (memory == null) {
      return;
    }

    await removeMemory(memory);
  }

  void _sortMemories() {
    _memories.sort((a, b) => b.creationDate.compareTo(a.creationDate));
  }

  Future<void> save() async {
    final data = toJSON();

    await storage.write(key: MEMORIES_KEY, value: data.toString());
  }

  Map<String, dynamic> toJSON() => {
        'memories': _memories.map((memory) => memory.toJSON()).toList(),
      };
}
