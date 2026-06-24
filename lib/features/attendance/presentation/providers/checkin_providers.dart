import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:demo4/features/attendance/domain/entities/checkin_models.dart';
import 'package:demo4/features/attendance/data/repositories/checkin_repository.dart';
import 'package:demo4/features/attendance/data/data_sources/geolocation_service.dart';
import 'package:demo4/core/storage/secure_storage_service.dart';
import 'package:demo4/core/di/service_locator.dart';
import 'package:demo4/core/constants/app_constants.dart';

// ===================== REPOSITORIES & SERVICES =====================

final secureStorageProvider = Provider<SecureStorageService>((ref) {
  return sl<SecureStorageService>();
});

final checkInRepositoryProvider = Provider<CheckInRepository>((ref) {
  return DummyCheckInRepository();
});

final geolocationServiceProvider = Provider<GeolocationService>((ref) {
  return GeolocationService();
});

// ===================== CURRENT LOCATION =====================

final currentLocationProvider =
    FutureProvider.autoDispose<LocationCoordinates>((ref) async {
  final geoService = ref.watch(geolocationServiceProvider);

  // Return location directly (uses dummy data internally)
  return geoService.getCurrentLocation();
});

final locationPermissionProvider = FutureProvider.autoDispose<bool>((ref) async {
  // Return true immediately for dummy/testing purposes
  return true;
});

// ===================== GEOFENCE & SHIFT DATA =====================

final officeGeofenceProvider =
    FutureProvider.autoDispose<Geofence>((ref) async {
  final repository = ref.watch(checkInRepositoryProvider);
  return repository.getOfficeGeofence();
});

final employeeShiftProvider =
    FutureProvider.autoDispose.family<ShiftInfo, String>((ref, employeeId) async {
  final repository = ref.watch(checkInRepositoryProvider);
  return repository.getEmployeeShift(employeeId);
});

// ===================== CHECK-IN VALIDATION =====================

class CheckInValidationController extends Notifier<AsyncValue<CheckInValidation>> {
  @override
  AsyncValue<CheckInValidation> build() {
    return const AsyncValue.data(CheckInValidation(
      isValid: true,
      errorMessage: null,
      isWithinGeofence: false,
      isOnTime: true,
      status: 'pending',
      //location: 'CraftEdge Office, Sector 62, Noida',
    ));
  }

  Future<void> validateCurrentLocation({
    required double userLatitude,
    required double userLongitude,
    required Geofence officeGeofence,
    required ShiftInfo shift,
  }) async {
    state = const AsyncValue.loading();

    try {
      final repository = ref.read(checkInRepositoryProvider);
      
      final timeParts = shift.startTime.split(':');
      final shiftStart = DateTime.now().copyWith(
        hour: int.parse(timeParts[0]),
        minute: int.parse(timeParts[1]),
        second: 0,
        millisecond: 0,
      );

      final validation = await repository.validateCheckIn(
        userLatitude: userLatitude,
        userLongitude: userLongitude,
        officeLatitude: officeGeofence.latitude,
        officeLongitude: officeGeofence.longitude,
        geofenceRadius: officeGeofence.radiusInMeters,
        shiftStartTime: shiftStart,
      );

      state = AsyncValue.data(validation);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }
}

final checkInValidationProvider = NotifierProvider<
    CheckInValidationController,
    AsyncValue<CheckInValidation>>(CheckInValidationController.new);

// ===================== QR CODE TOKENS =====================

final expectedQrTokenProvider = FutureProvider.family<String, bool>((ref, isCheckOut) async {
  final storage = ref.watch(secureStorageProvider);
  final key = isCheckOut ? AppConstants.checkOutQrCodeKey : AppConstants.checkInQrCodeKey;
  
  // Try to read from storage (in case there's an override)
  final storedToken = await storage.read(key);
  
  if (storedToken != null) return storedToken;

  // Fallback to the hardcoded values in AppConstants
  return isCheckOut ? AppConstants.checkOutQrValue : AppConstants.checkInQrValue;
});

// ===================== CHECK-IN EXECUTION =====================

class CheckInController extends Notifier<AsyncValue<CheckInRecord?>> {
  @override
  AsyncValue<CheckInRecord?> build() {
    return const AsyncValue.data(null);
  }

  Future<CheckInRecord?> performCheckIn({
    required String employeeId,
    required double latitude,
    required double longitude,
    required String officeLocation,
    required String shiftType,
  }) async {
    state = const AsyncValue.loading();

    try {
      final repository = ref.read(checkInRepositoryProvider);
      final record = await repository.checkIn(
        employeeId: employeeId,
        latitude: latitude,
        longitude: longitude,
        officeLocation: officeLocation,
        shiftType: shiftType,
      );

      state = AsyncValue.data(record);
      return record;
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
      rethrow;
    }
  }

  void reset() {
    state = const AsyncValue.data(null);
  }
}

final checkInControllerProvider =
    NotifierProvider<CheckInController, AsyncValue<CheckInRecord?>>(
  CheckInController.new,
);

// ===================== TODAY'S CHECK-IN STATUS =====================

final todayCheckInStatusProvider =
    FutureProvider.autoDispose.family<CheckInStatus, String>((ref, employeeId) async {
  final repository = ref.watch(checkInRepositoryProvider);
  return repository.getTodayCheckInStatus(employeeId);
});

// ===================== CHECK-IN HISTORY =====================

final checkInHistoryProvider = FutureProvider.autoDispose.family<
    List<CheckInRecord>,
    ({String employeeId, DateTime startDate, DateTime endDate})>((ref, params) async {
  final repository = ref.watch(checkInRepositoryProvider);
  return repository.getCheckInHistory(
    employeeId: params.employeeId,
    startDate: params.startDate,
    endDate: params.endDate,
  );
});

// ===================== CURRENT TIME PROVIDER =====================

final currentTimeProvider = StreamProvider.autoDispose<DateTime>((ref) async* {
  while (true) {
    yield DateTime.now();
    await Future.delayed(const Duration(seconds: 1));
  }
});

// ===================== HELPER PROVIDERS =====================

final currentDateFormattedProvider =
    Provider.autoDispose<String>((ref) {
  final now = ref.watch(currentTimeProvider);
  
  return now.when(
    data: (time) {
      const weekdays = [
        'Monday',
        'Tuesday',
        'Wednesday',
        'Thursday',
        'Friday',
        'Saturday',
        'Sunday'
      ];
      const months = [
        'January',
        'February',
        'March',
        'April',
        'May',
        'June',
        'July',
        'August',
        'September',
        'October',
        'November',
        'December'
      ];

      final weekday = weekdays[time.weekday - 1];
      final month = months[time.month - 1];
      return '$weekday, ${time.day} $month ${time.year}';
    },
    loading: () => 'Loading...',
    error: (_, __) => 'Error',
  );
});

final currentTimeFormattedProvider =
    Provider.autoDispose<String>((ref) {
  final now = ref.watch(currentTimeProvider);
  
  return now.when(
    data: (time) {
      final hour = time.hour % 12 == 0 ? 12 : time.hour % 12;
      final period = time.hour >= 12 ? 'PM' : 'AM';
      return '${hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')} $period';
    },
    loading: () => '--:-- --',
    error: (_, __) => '--:-- --',
  );
});
