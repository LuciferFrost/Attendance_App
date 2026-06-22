import 'package:freezed_annotation/freezed_annotation.dart';

part 'check_out_exception.freezed.dart';
part 'check_out_exception.g.dart';

@freezed
abstract class CheckOutException with _$CheckOutException {
  const factory CheckOutException({
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
  }) = _CheckOutException;

  factory CheckOutException.fromJson(Map<String, dynamic> json) =>
      _$CheckOutExceptionFromJson(json);
}

@freezed
abstract class CheckOutExceptionResponse with _$CheckOutExceptionResponse {
  const factory CheckOutExceptionResponse({
    required String id,
    required String employeeId,
    required String employeeName,
    required String managerId,
    required String managerName,
    required String exceptionReason,
    required String remarks,
    required String status, // pending, approved, rejected
    required DateTime submittedAt,
    required String attendanceStatus, // Check-Out Pending Approval
    required double latitude,
    required double longitude,
  }) = _CheckOutExceptionResponse;

  factory CheckOutExceptionResponse.fromJson(Map<String, dynamic> json) =>
      _$CheckOutExceptionResponseFromJson(json);
}