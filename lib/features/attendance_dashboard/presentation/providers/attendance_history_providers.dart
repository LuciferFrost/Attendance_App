import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/attendance_record.dart';

/// Supplies the attendance records shown on the Attendance list/detail
/// screens. Backed by static mock data for now — swap the body of
/// [AttendanceHistoryNotifier.build] for a repository call once a real
/// attendance API/endpoint is available.
class AttendanceHistoryNotifier extends Notifier<List<AttendanceRecord>> {
  @override
  List<AttendanceRecord> build() {
    final now = DateTime.now();
    DateTime onDay(int day) => DateTime(now.year, now.month, day);
    DateTime at(int day, int hour, int minute) =>
        DateTime(now.year, now.month, day, hour, minute);

    return [
      AttendanceRecord(
        id: 'att_06_02',
        employeeId: 'EMP-1042',
        date: onDay(2),
        status: AttendanceStatus.present,
        checkInTime: at(2, 9, 4),
        checkOutTime: at(2, 18, 18),
        totalHoursLabel: '9h 14m',
        fieldDetails: const [
          AttendanceFieldDetail(label: 'Field reason', value: 'Regular day'),
        ],
      ),
      AttendanceRecord(
        id: 'att_06_03',
        employeeId: 'EMP-1042',
        date: onDay(3),
        status: AttendanceStatus.late,
        checkInTime: at(3, 10, 15),
        checkOutTime: at(3, 19, 22),
        totalHoursLabel: '9h 07m',
        fieldDetails: const [
          AttendanceFieldDetail(label: 'Field reason', value: 'Client meeting'),
          AttendanceFieldDetail(
            label: 'Place name',
            value: 'Infosys Technologies Ltd.',
          ),
          AttendanceFieldDetail(
            label: 'Location address',
            value: 'Connaught Place, New Delhi',
          ),
          AttendanceFieldDetail(
            label: 'Purpose/remarks',
            value: 'Q3 product demo and pricing discussion with procurement team',
          ),
        ],
      ),
      AttendanceRecord(
        id: 'att_06_04',
        employeeId: 'EMP-1042',
        date: onDay(4),
        status: AttendanceStatus.absent,
      ),
      AttendanceRecord(
        id: 'att_06_05_a',
        employeeId: 'EMP-1042',
        date: onDay(5),
        status: AttendanceStatus.halfDay,
        regularizationState: RegularizationState.pendingApproval,
        checkInTime: at(5, 10, 45),
        checkOutTime: at(5, 18, 30),
        totalHoursLabel: '4h 30m',
      ),
      AttendanceRecord(
        id: 'att_06_05_b',
        employeeId: 'EMP-1042',
        date: onDay(5),
        status: AttendanceStatus.halfDay,
        checkInTime: at(5, 10, 45),
        checkOutTime: at(5, 18, 30),
        totalHoursLabel: '4h 30m',
      ),
      AttendanceRecord(
        id: 'att_06_06',
        employeeId: 'EMP-1042',
        date: onDay(6),
        status: AttendanceStatus.absent,
        statusNote: 'Unplanned Absence recorded',
      ),
    ];
  }

  /// Records a freshly submitted correction request against [recordId] so
  /// the list screen reflects the "Pending Approval" state immediately.
  void markPendingApproval(String recordId) {
    state = [
      for (final record in state)
        if (record.id == recordId)
          AttendanceRecord(
            id: record.id,
            employeeId: record.employeeId,
            date: record.date,
            status: record.status,
            regularizationState: RegularizationState.pendingApproval,
            statusNote: record.statusNote,
            checkInTime: record.checkInTime,
            checkOutTime: record.checkOutTime,
            totalHoursLabel: record.totalHoursLabel,
            workMode: record.workMode,
            shiftLabel: record.shiftLabel,
            locationLabel: record.locationLabel,
            insideGeofence: record.insideGeofence,
            fieldDetails: record.fieldDetails,
          )
        else
          record,
    ];
  }
}

final attendanceHistoryProvider =
    NotifierProvider<AttendanceHistoryNotifier, List<AttendanceRecord>>(
  AttendanceHistoryNotifier.new,
);
