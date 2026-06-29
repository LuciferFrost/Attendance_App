import 'dart:math';

/// Represents a single check-in record for an employee
class CheckInRecord {
  final String id;
  final String employeeId;
  final DateTime checkInTime;
  final double latitude;
  final double longitude;
  final String officeLocation;
  final String shiftType;
  final String status; // 'success', 'late', 'early', etc.
  final String? notes;
  final DateTime? createdAt;

  const CheckInRecord({
    required this.id,
    required this.employeeId,
    required this.checkInTime,
    required this.latitude,
    required this.longitude,
    required this.officeLocation,
    required this.shiftType,
    required this.status,
    this.notes,
    this.createdAt,
  });

  factory CheckInRecord.fromJson(Map<String, dynamic> json) {
    return CheckInRecord(
      id: json['id'] as String,
      employeeId: json['employeeId'] as String,
      checkInTime: DateTime.parse(json['checkInTime'] as String),
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      officeLocation: json['officeLocation'] as String,
      shiftType: json['shiftType'] as String,
      status: json['status'] as String,
      notes: json['notes'] as String?,
      createdAt: json['createdAt'] == null
          ? null
          : DateTime.parse(json['createdAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'employeeId': employeeId,
      'checkInTime': checkInTime.toIso8601String(),
      'latitude': latitude,
      'longitude': longitude,
      'officeLocation': officeLocation,
      'shiftType': shiftType,
      'status': status,
      'notes': notes,
      'createdAt': createdAt?.toIso8601String(),
    };
  }
}

/// Current check-in status and context
class CheckInStatus {
  final bool hasCheckedIn;
  final DateTime currentTime;
  final DateTime currentDate;
  final double? currentLatitude;
  final double? currentLongitude;
  final String? officeLocation;
  final String shiftTimings;
  final bool gpsPermissionGranted;
  final bool locationFetched;
  final String? errorMessage;

  const CheckInStatus({
    required this.hasCheckedIn,
    required this.currentTime,
    required this.currentDate,
    this.currentLatitude,
    this.currentLongitude,
    this.officeLocation,
    required this.shiftTimings,
    required this.gpsPermissionGranted,
    required this.locationFetched,
    this.errorMessage,
  });

  factory CheckInStatus.fromJson(Map<String, dynamic> json) {
    return CheckInStatus(
      hasCheckedIn: json['hasCheckedIn'] as bool,
      currentTime: DateTime.parse(json['currentTime'] as String),
      currentDate: DateTime.parse(json['currentDate'] as String),
      currentLatitude: (json['currentLatitude'] as num?)?.toDouble(),
      currentLongitude: (json['currentLongitude'] as num?)?.toDouble(),
      officeLocation: json['officeLocation'] as String?,
      shiftTimings: json['shiftTimings'] as String,
      gpsPermissionGranted: json['gpsPermissionGranted'] as bool,
      locationFetched: json['locationFetched'] as bool,
      errorMessage: json['errorMessage'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'hasCheckedIn': hasCheckedIn,
      'currentTime': currentTime.toIso8601String(),
      'currentDate': currentDate.toIso8601String(),
      'currentLatitude': currentLatitude,
      'currentLongitude': currentLongitude,
      'officeLocation': officeLocation,
      'shiftTimings': shiftTimings,
      'gpsPermissionGranted': gpsPermissionGranted,
      'locationFetched': locationFetched,
      'errorMessage': errorMessage,
    };
  }
}

/// Location coordinates and related data
class LocationData {
  final double latitude;
  final double longitude;
  final String? address;
  final DateTime fetchedAt;
  final double? accuracy;

  const LocationData({
    required this.latitude,
    required this.longitude,
    this.address,
    required this.fetchedAt,
    this.accuracy,
  });

  factory LocationData.fromJson(Map<String, dynamic> json) {
    return LocationData(
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      address: json['address'] as String?,
      fetchedAt: DateTime.parse(json['fetchedAt'] as String),
      accuracy: (json['accuracy'] as num?)?.toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'latitude': latitude,
      'longitude': longitude,
      'address': address,
      'fetchedAt': fetchedAt.toIso8601String(),
      'accuracy': accuracy,
    };
  }
}

/// Geofence definition for office location
class Geofence {
  final String id;
  final String name;
  final double latitude;
  final double longitude;
  final double radiusInMeters;

  const Geofence({
    required this.id,
    required this.name,
    required this.latitude,
    required this.longitude,
    required this.radiusInMeters,
  });

  factory Geofence.fromJson(Map<String, dynamic> json) {
    return Geofence(
      id: json['id'] as String,
      name: json['name'] as String,
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      radiusInMeters: (json['radiusInMeters'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'latitude': latitude,
      'longitude': longitude,
      'radiusInMeters': radiusInMeters,
    };
  }

  bool isWithinBounds(double lat, double lng) {
    const double earthRadiusKm = 6371;
    
    final double dLat = _toRadians(lat - latitude);
    final double dLng = _toRadians(lng - longitude);
    
    final double a = sin(dLat / 2) * sin(dLat / 2) +
        cos(_toRadians(latitude)) * cos(_toRadians(lat)) *
        sin(dLng / 2) * sin(dLng / 2);
        
    final double c = 2 * atan2(sqrt(a), sqrt(1 - a));
    final double distance = earthRadiusKm * c * 1000;
    
    return distance <= radiusInMeters;
  }

  double _toRadians(double degree) => degree * pi / 180;
}

/// Employee shift information
class ShiftInfo {
  final String id;
  final String name;
  final String startTime; // HH:mm format
  final String endTime; // HH:mm format
  final String type; // 'general', 'flexible', 'night', etc.

  const ShiftInfo({
    required this.id,
    required this.name,
    required this.startTime,
    required this.endTime,
    required this.type,
  });

  factory ShiftInfo.fromJson(Map<String, dynamic> json) {
    return ShiftInfo(
      id: json['id'] as String,
      name: json['name'] as String,
      startTime: json['startTime'] as String,
      endTime: json['endTime'] as String,
      type: json['type'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'startTime': startTime,
      'endTime': endTime,
      'type': type,
    };
  }
}

/// Check-in validation result
class CheckInValidation {
  final bool isValid;
  final String? errorMessage;
  final bool isWithinGeofence;
  final bool isOnTime;
  final String? status; // 'on_time', 'late', 'early', etc.

  const CheckInValidation({
    required this.isValid,
    this.errorMessage,
    required this.isWithinGeofence,
    required this.isOnTime,
    this.status,
  });

  factory CheckInValidation.fromJson(Map<String, dynamic> json) {
    return CheckInValidation(
      isValid: json['isValid'] as bool,
      errorMessage: json['errorMessage'] as String?,
      isWithinGeofence: json['isWithinGeofence'] as bool,
      isOnTime: json['isOnTime'] as bool,
      status: json['status'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'isValid': isValid,
      'errorMessage': errorMessage,
      'isWithinGeofence': isWithinGeofence,
      'isOnTime': isOnTime,
      'status': status,
    };
  }
}

// Dummy/Mock implementation for development
class MockCheckInData {
  static const String officeLocation = "CraftEdge Office, Sector 62, Noida";
  static const double officeLatitude = 28.6142;
  static const double officeLongitude = 77.3640;
  static const String shiftTimings = "General (09:00 AM - 06:00 PM)";
  static const double geofenceRadius = 500; // meters

  static Geofence getOfficeGeofence() => const Geofence(
    id: 'office_sector_62',
    name: officeLocation,
    latitude: officeLatitude,
    longitude: officeLongitude,
    radiusInMeters: geofenceRadius,
  );

  static CheckInRecord createDummyRecord({
    String? employeeId,
    DateTime? checkInTime,
  }) {
    return CheckInRecord(
      id: 'checkin_${DateTime.now().millisecondsSinceEpoch}',
      employeeId: employeeId ?? 'emp_001',
      checkInTime: checkInTime ?? DateTime.now(),
      latitude: officeLatitude,
      longitude: officeLongitude,
      officeLocation: officeLocation,
      shiftType: 'general',
      status: 'success',
      createdAt: DateTime.now(),
    );
  }

  static CheckInStatus getDefaultStatus() => CheckInStatus(
    hasCheckedIn: false,
    currentTime: DateTime.now(),
    currentDate: DateTime.now(),
    currentLatitude: officeLatitude,
    currentLongitude: officeLongitude,
    officeLocation: officeLocation,
    shiftTimings: shiftTimings,
    gpsPermissionGranted: false,
    locationFetched: false,
    errorMessage: null,
  );
}

/// Holiday / non-working day information
class HolidayInfo {
  final String id;
  final String name;
  final DateTime date;
  final String managerName;

  const HolidayInfo({
    required this.id,
    required this.name,
    required this.date,
    required this.managerName,
  });

  factory HolidayInfo.fromJson(Map<String, dynamic> json) {
    return HolidayInfo(
      id: json['id'] as String,
      name: json['name'] as String,
      date: DateTime.parse(json['date'] as String),
      managerName: json['managerName'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'date': date.toIso8601String(),
      'managerName': managerName,
    };
  }
}
