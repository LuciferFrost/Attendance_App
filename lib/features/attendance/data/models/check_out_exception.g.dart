// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'check_out_exception.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_CheckOutException _$CheckOutExceptionFromJson(Map<String, dynamic> json) =>
    _CheckOutException(
      employeeId: json['employeeId'] as String,
      exceptionReason: json['exceptionReason'] as String,
      remarks: json['remarks'] as String,
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      officeLocation: json['officeLocation'] as String,
      officeLatitude: (json['officeLatitude'] as num).toDouble(),
      officeLongitude: (json['officeLongitude'] as num).toDouble(),
      distanceInMeters: (json['distanceInMeters'] as num).toDouble(),
      attemptedAt: DateTime.parse(json['attemptedAt'] as String),
    );

Map<String, dynamic> _$CheckOutExceptionToJson(_CheckOutException instance) =>
    <String, dynamic>{
      'employeeId': instance.employeeId,
      'exceptionReason': instance.exceptionReason,
      'remarks': instance.remarks,
      'latitude': instance.latitude,
      'longitude': instance.longitude,
      'officeLocation': instance.officeLocation,
      'officeLatitude': instance.officeLatitude,
      'officeLongitude': instance.officeLongitude,
      'distanceInMeters': instance.distanceInMeters,
      'attemptedAt': instance.attemptedAt.toIso8601String(),
    };

_CheckOutExceptionResponse _$CheckOutExceptionResponseFromJson(
  Map<String, dynamic> json,
) => _CheckOutExceptionResponse(
  id: json['id'] as String,
  employeeId: json['employeeId'] as String,
  employeeName: json['employeeName'] as String,
  managerId: json['managerId'] as String,
  managerName: json['managerName'] as String,
  exceptionReason: json['exceptionReason'] as String,
  remarks: json['remarks'] as String,
  status: json['status'] as String,
  submittedAt: DateTime.parse(json['submittedAt'] as String),
  attendanceStatus: json['attendanceStatus'] as String,
  latitude: (json['latitude'] as num).toDouble(),
  longitude: (json['longitude'] as num).toDouble(),
);

Map<String, dynamic> _$CheckOutExceptionResponseToJson(
  _CheckOutExceptionResponse instance,
) => <String, dynamic>{
  'id': instance.id,
  'employeeId': instance.employeeId,
  'employeeName': instance.employeeName,
  'managerId': instance.managerId,
  'managerName': instance.managerName,
  'exceptionReason': instance.exceptionReason,
  'remarks': instance.remarks,
  'status': instance.status,
  'submittedAt': instance.submittedAt.toIso8601String(),
  'attendanceStatus': instance.attendanceStatus,
  'latitude': instance.latitude,
  'longitude': instance.longitude,
};
