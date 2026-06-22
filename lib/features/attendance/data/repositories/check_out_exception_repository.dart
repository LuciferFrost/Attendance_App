import '../models/check_out_exception.dart';

class CheckOutExceptionRepository {
  /// Submit check-out exception with dummy simulation
  Future<CheckOutExceptionResponse> submitCheckOutException({
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
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 1500));

    // Return dummy response
    return CheckOutExceptionResponse(
      id: 'exc_${DateTime.now().millisecondsSinceEpoch}',
      employeeId: employeeId,
      employeeName: 'Current User', // In a real app, this would come from Auth/DB
      managerId: 'mgr_001',
      managerName: 'Harsh Singh',
      exceptionReason: exceptionReason,
      remarks: remarks,
      status: 'pending',
      submittedAt: DateTime.now(),
      attendanceStatus: 'Check-Out Pending Approval',
      latitude: latitude,
      longitude: longitude,
    );
  }
}
