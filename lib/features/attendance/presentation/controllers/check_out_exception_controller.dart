import 'package:demo4/features/attendance/data/models/check_out_exception.dart';
import 'package:demo4/features/attendance/data/repositories/check_out_exception_repository.dart';
import 'package:riverpod/riverpod.dart';

class CheckOutExceptionController extends Notifier<AsyncValue<CheckOutExceptionResponse?>> {
  late CheckOutExceptionRepository _repository;

  @override
  AsyncValue<CheckOutExceptionResponse?> build() {
    _repository = CheckOutExceptionRepository();
    return const AsyncValue.data(null);
  }

  /// Submit check-out exception with reason and remarks
  Future<CheckOutExceptionResponse?> submitException({
    required String employeeId,
    required String exceptionReason,
    required String remarks,
    required double latitude,
    required double longitude,
    required String officeLocation,
    required double officeLatitude,
    required double officeLongitude,
    required double distanceInMeters,
    required DateTime attemptedAt,
  }) async {
    state = const AsyncValue.loading();

    try {
      final response = await _repository.submitCheckOutException(
        employeeId: employeeId,
        exceptionReason: exceptionReason,
        remarks: remarks,
        latitude: latitude,
        longitude: longitude,
        officeLocation: officeLocation,
        officeLatitude: officeLatitude,
        officeLongitude: officeLongitude,
        distanceInMeters: distanceInMeters,
        attemptedAt: attemptedAt,
      );

      state = AsyncValue.data(response);
      return response;
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
      rethrow;
    }
  }

  /// Reset the controller state
  void reset() {
    state = const AsyncValue.data(null);
  }
}