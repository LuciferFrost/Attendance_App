import 'package:demo4/features/attendance/data/models/check_out_exception.dart';

class CheckOutExceptionRepository {
  /// Submit a check-out exception
  /// In a real app, this would call an API endpoint
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
    await Future.delayed(const Duration(seconds: 2));

    // Dummy response with hardcoded manager
    return CheckOutExceptionResponse(
      id: 'exception_${DateTime.now().millisecondsSinceEpoch}',
      employeeId: employeeId,
      employeeName: 'Current User', // In real app, get from dashboard
      managerId: 'MGR_001',
      managerName: 'Arvind Joshi', // Hardcoded dummy manager
      exceptionReason: exceptionReason,
      remarks: remarks,
      status: 'pending',
      submittedAt: DateTime.now(),
      attendanceStatus: 'Check-Out Pending Approval',
      latitude: latitude,
      longitude: longitude,
    );
  }

  /// Get manager details for the current employee
  /// In a real app, this would be fetched from the API based on employee hierarchy
  Future<({String id, String name, String avatar})> getManagerDetails() async {
    await Future.delayed(const Duration(milliseconds: 300));

    return (
    id: 'MGR_001',
    name: 'Arvind Joshi',
    avatar: 'AJ', // Initials for avatar
    );
  }
}