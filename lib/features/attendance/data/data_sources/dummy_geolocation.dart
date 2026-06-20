/// Dummy Geolocation Data for testing and development
/// Contains predefined latitude and longitude values for various office locations
/// and simulated user positions.
class DummyGeolocation {
  DummyGeolocation._();

  // ==================== OFFICE LOCATIONS ====================

  /// Main Headquarters - Noida Sector 62
  static const Map<String, dynamic> mainOffice = {
    'name': 'CraftEdge HQ, Noida',
    'address': 'Plot No. 15, Sector 62, Noida, Uttar Pradesh 201301',
    'latitude': 28.6142,
    'longitude': 77.3640,
    'radius': 200.0, // meters
  };

  /// Regional Office - Gurgaon
  static const Map<String, dynamic> gurgaonOffice = {
    'name': 'CraftEdge Regional, Gurgaon',
    'address': 'DLF Cyber City, Phase 3, Gurgaon, Haryana 122002',
    'latitude': 28.4950,
    'longitude': 77.0890,
    'radius': 150.0,
  };

  /// Satellite Office - Bangalore
  static const Map<String, dynamic> bangaloreOffice = {
    'name': 'CraftEdge Tech Hub, Bangalore',
    'address': 'Outer Ring Rd, Marathahalli, Bangalore, Karnataka 560103',
    'latitude': 12.9279,
    'longitude': 77.6833,
    'radius': 300.0,
  };

  // ==================== SIMULATED USER POSITIONS ====================

  /// User is exactly at the office center
  static const Map<String, double> userAtOffice = {
    'latitude': 28.6142,
    'longitude': 77.3640,
  };

  /// User is within the geofence (Near Main Office)
  /// Distance: ~30 meters from office
  static const Map<String, double> userNearOffice = {
    'latitude': 28.6145,
    'longitude': 77.3642,
  };

  /// User is far from the office (Outside Geofence)
  /// Distance: ~18 km from office (Connaught Place, Delhi)
  static const Map<String, double> userFarFromOffice = {
    'latitude': 28.6315,
    'longitude': 77.2167,
  };

  /// Approximate location name for userFarFromOffice
  static const String farLocationName = 'Connaught Place, New Delhi';

  // ==================== HELPER METHODS ====================

  /// Get formatted coordinate string
  static String formatCoordinates(double lat, double lng) {
    final latDir = lat >= 0 ? "N" : "S";
    final lngDir = lng >= 0 ? "E" : "W";
    return "${lat.abs().toStringAsFixed(4)}° $latDir, ${lng.abs().toStringAsFixed(4)}° $lngDir";
  }

  /// Get all available office locations
  static List<Map<String, dynamic>> getAllOffices() {
    return [mainOffice, gurgaonOffice, bangaloreOffice];
  }

  /// Get office by name
  static Map<String, dynamic>? getOfficeByName(String name) {
    return getAllOffices().firstWhere(
          (office) => office['name'] == name,
      orElse: () => mainOffice,
    );
  }
}