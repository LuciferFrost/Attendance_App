import '../../domain/entities/checkin_models.dart';

/// Abstract repository for check-in operations
/// Defines the contract for check-in data operations
abstract class CheckInRepository {
  /// Perform a check-in for the current user at current location
  Future<CheckInRecord> checkIn({
    required String employeeId,
    required double latitude,
    required double longitude,
    required String officeLocation,
    required String shiftType,
  });

  /// Validate if check-in is possible from current location
  Future<CheckInValidation> validateCheckIn({
    required double userLatitude,
    required double userLongitude,
    required double officeLatitude,
    required double officeLongitude,
    required double geofenceRadius,
    required DateTime shiftStartTime,
  });

  /// Get today's check-in status
  Future<CheckInStatus> getTodayCheckInStatus(String employeeId);

  /// Get check-in history for a date range
  Future<List<CheckInRecord>> getCheckInHistory({
    required String employeeId,
    required DateTime startDate,
    required DateTime endDate,
  });

  /// Get current geofence for the office
  Future<Geofence> getOfficeGeofence();

  /// Get employee's shift information
  Future<ShiftInfo> getEmployeeShift(String employeeId);

  /// Returns today's HolidayInfo if today is a holiday/non-working day,
  /// or null if it is a normal working day.
  Future<HolidayInfo?> getTodayHolidayInfo();
}

/// Dummy implementation of CheckInRepository using mock data
/// To be replaced with real API implementation
class DummyCheckInRepository implements CheckInRepository {
  // Simulate network delay
  static const Duration _simulatedDelay = Duration(milliseconds: 1200);

  // Mock office geofence
  static final _officeGeofence = Geofence(
    id: 'office_sector_62',
    name: 'CraftEdge Office, Sector 62, Noida',
    latitude: 28.6142,
    longitude: 77.3640,
    radiusInMeters: 500,
  );

  // Mock shift info
  static final _defaultShift = ShiftInfo(
    id: 'shift_general_001',
    name: 'General Shift',
    startTime: '09:00',
    endTime: '18:00',
    type: 'general',
  );

  // In-memory storage of check-in records (for demo)
  final Map<String, List<CheckInRecord>> _checkInHistory = {};

  @override
  Future<CheckInRecord> checkIn({
    required String employeeId,
    required double latitude,
    required double longitude,
    required String officeLocation,
    required String shiftType,
  }) async {
    await Future.delayed(_simulatedDelay);

    // WFH and WFF employees are not bound by the office geofence —
    // their check-in always succeeds from wherever they are.
    // WFO still gates on geofence proximity.
    final isLocationMode =
        shiftType == 'WFH' || shiftType == 'WFF';
    final isWithinBounds =
        isLocationMode || _officeGeofence.isWithinBounds(latitude, longitude);
    final status = isWithinBounds ? 'success' : 'warning';

    final record = CheckInRecord(
      id: 'checkin_${DateTime.now().millisecondsSinceEpoch}',
      employeeId: employeeId,
      checkInTime: DateTime.now(),
      latitude: latitude,
      longitude: longitude,
      officeLocation: officeLocation,
      shiftType: shiftType,
      status: status,
      createdAt: DateTime.now(),
    );

    // Store in mock history
    if (!_checkInHistory.containsKey(employeeId)) {
      _checkInHistory[employeeId] = [];
    }
    _checkInHistory[employeeId]!.add(record);

    return record;
  }

  @override
  Future<CheckInValidation> validateCheckIn({
    required double userLatitude,
    required double userLongitude,
    required double officeLatitude,
    required double officeLongitude,
    required double geofenceRadius,
    required DateTime shiftStartTime,
  }) async {
    await Future.delayed(_simulatedDelay);

    final isWithinGeofence =
    _officeGeofence.isWithinBounds(userLatitude, userLongitude);

    final now = DateTime.now();
    final isOnTime = now.isBefore(shiftStartTime);

    return CheckInValidation(
      isValid: isWithinGeofence,
      errorMessage: isWithinGeofence
          ? null
          : 'You are outside the office geofence. Current location is ${(isWithinGeofence ? 'within' : 'outside')} the allowed area.',
      isWithinGeofence: isWithinGeofence,
      isOnTime: isOnTime,
      status: isOnTime ? 'on_time' : 'late',
    );
  }

  @override
  Future<CheckInStatus> getTodayCheckInStatus(String employeeId) async {
    await Future.delayed(_simulatedDelay);

    final todayRecords = _checkInHistory[employeeId]
        ?.where((record) {
      final today = DateTime.now();
      final recordDate = record.checkInTime;
      return recordDate.year == today.year &&
          recordDate.month == today.month &&
          recordDate.day == today.day;
    })
        .toList() ??
        [];

    return CheckInStatus(
      hasCheckedIn: todayRecords.isNotEmpty,
      currentTime: DateTime.now(),
      currentDate: DateTime.now(),
      currentLatitude: 28.6315,
      currentLongitude: 77.2167,
      officeLocation: _officeGeofence.name,
      shiftTimings: '${_defaultShift.startTime} - ${_defaultShift.endTime}',
      gpsPermissionGranted: true,
      locationFetched: true,
      errorMessage: null,
    );
  }

  @override
  Future<List<CheckInRecord>> getCheckInHistory({
    required String employeeId,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    await Future.delayed(_simulatedDelay);

    return (_checkInHistory[employeeId] ?? [])
        .where((record) {
      return record.checkInTime.isAfter(startDate) &&
          record.checkInTime.isBefore(endDate);
    })
        .toList();
  }

  @override
  Future<Geofence> getOfficeGeofence() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return _officeGeofence;
  }

  @override
  Future<ShiftInfo> getEmployeeShift(String employeeId) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return _defaultShift;
  }

  // Dummy holiday data — today is always treated as a holiday for demo purposes.
  // To simulate a normal working day, return null instead.
  static final _dummyHoliday = HolidayInfo(
    id: 'holiday_001',
    name: 'Holiday / Non-working day',
    date: DateTime.now(),
    managerName: 'Priya Sharma (Manager)',
  );

  @override
  Future<HolidayInfo?> getTodayHolidayInfo() async {
    await Future.delayed(const Duration(milliseconds: 300));
    // Return _dummyHoliday to simulate a holiday.
    // Return null to simulate a normal working day.
    return null;
  }
}