import 'dart:async';
import 'dart:math';

import 'package:property_change_notifier/property_change_notifier.dart';
import 'package:relieve/extensions/date.dart';
import 'package:relieve/foreign_types/memory.dart';

class TimelineModel extends PropertyChangeNotifier<String> {
  final Map<DateTime, List<Memory>> _timeline;

  TimelineModel({
    required final List<Memory> memories,
    final int initialndex = 0,
  })  : _timeline = mapFromMemoriesList(memories),
        _currentIndex = initialndex;

  int _currentIndex = 0;
  int _memoryIndex = 0;
  bool _paused = false;
  bool _showOverlay = true;
  Timer? _overlayRemoverTimer;

  Map<DateTime, List<Memory>> get values => _timeline;
  int get length => _timeline.length;
  int get currentIndex => _currentIndex;
  int get memoryIndex => _memoryIndex;
  bool get paused => _paused;
  bool get showOverlay => _showOverlay;

  DateTime dateAtIndex(final int index) => _timeline.keys.elementAt(index);

  List<Memory> atIndex(final int index) => _timeline.values.elementAt(index);

  List<Memory> get _currentMemories => atIndex(currentIndex);
  bool get _isAtLastMemory => _memoryIndex == _currentMemories.length - 1;
  Memory get currentMemory => _currentMemories.elementAt(_memoryIndex);

  void _removeEmptyDates() {
    _timeline.removeWhere((key, memories) => memories.isEmpty);
  }

  void restoreOverlay() => setShowOverlay(true);
  void hideOverlay() => setShowOverlay(false);

  static Map<DateTime, List<Memory>> mapFromMemoriesList(
    final List<Memory> memories,
  ) {
    final map = <DateTime, List<Memory>>{};

    for (final memory in memories) {
      final key = memory.creationDate.asNormalizedDate();

      if (map.containsKey(key)) {
        map[key]!.add(memory);
      } else {
        map[key] = [memory];
      }
    }

    return map;
  }

  void setCurrentIndex(final int index) {
    _currentIndex = min(_timeline.length - 1, max(0, index));
    notifyListeners('currentIndex');
  }

  void setMemoryIndex(final int index) {
    _memoryIndex = min(
      _timeline.values.elementAt(_currentIndex).length - 1,
      max(0, index),
    );
    resume();
    notifyListeners('memoryIndex');
  }

  void setPaused(final bool paused) {
    _paused = paused;

    _overlayRemoverTimer?.cancel();

    if (paused) {
      _overlayRemoverTimer = Timer(
        const Duration(milliseconds: 600),
        hideOverlay,
      );
    } else {
      restoreOverlay();
    }

    notifyListeners('paused');
  }

  void setShowOverlay(final bool showOverlay) {
    _showOverlay = showOverlay;
    notifyListeners('showOverlay');
  }

  void pause() => setPaused(true);
  void resume() => setPaused(false);

  void nextTimeline() {
    if (currentIndex == length - 1) {
      return;
    }
    setCurrentIndex(currentIndex + 1);
    setMemoryIndex(0);
  }

  void previousTimeline() {
    if (currentIndex == 0) {
      return;
    }

    setCurrentIndex(currentIndex - 1);
    setMemoryIndex(_currentMemories.length - 1);
  }

  void nextMemory() {
    if (_isAtLastMemory) {
      nextTimeline();
    } else {
      setMemoryIndex(memoryIndex + 1);
    }
  }

  void previousMemory() {
    if (memoryIndex == 0) {
      previousTimeline();
    } else {
      setMemoryIndex(memoryIndex - 1);
    }
  }

  void refresh(final List<Memory> memories) {
    _timeline.clear();
    _timeline.addAll(mapFromMemoriesList(memories));
    _removeEmptyDates();
  }
}
