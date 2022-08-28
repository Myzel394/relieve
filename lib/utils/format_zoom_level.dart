String formatZoomLevel(double zoomLevel) {
  if (zoomLevel.floor() == zoomLevel) {
    // Zoom level is a whole number
    return '${zoomLevel.floor()}x';
  } else {
    return '${zoomLevel.toStringAsFixed(1)}x';
  }
}
