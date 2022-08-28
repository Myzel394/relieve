import 'package:location/location.dart';

class MemoryLocation {
  final double latitude;
  final double longitude;
  final double speed;
  final double accuracy;
  final double altitude;
  final double heading;

  const MemoryLocation({
    required this.latitude,
    required this.longitude,
    required this.speed,
    required this.accuracy,
    required this.altitude,
    required this.heading,
  });

  static MemoryLocation? parse(final Map<String, dynamic> jsonData) {
    try {
      return MemoryLocation(
        latitude: (jsonData['latitude'] as num).toDouble(),
        longitude: (jsonData['longitude'] as num).toDouble(),
        speed: (jsonData['speed'] as num).toDouble(),
        accuracy: (jsonData['accuracy'] as num).toDouble(),
        altitude: (jsonData['altitude'] as num).toDouble(),
        heading: (jsonData['heading'] as num).toDouble(),
      );
    } catch (error) {
      return null;
    }
  }

  static MemoryLocation fromLocationData(final LocationData locationData) =>
      MemoryLocation(
        latitude: locationData.latitude!,
        longitude: locationData.longitude!,
        speed: locationData.speed!,
        accuracy: locationData.accuracy!,
        altitude: locationData.altitude!,
        heading: locationData.heading!,
      );

  Map<String, dynamic> toJSON() => {
        'latitude': latitude,
        'longitude': longitude,
        'speed': speed,
        'accuracy': accuracy,
        'altitude': altitude,
        'heading': heading,
      };
}
