import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/routing/app_routes.dart';
import '../../domain/entities/attendance_record.dart';

/// "Attendance Details" screen — shows the full breakdown for a single
/// attendance day: status, work mode, shift, check-in/out summary,
/// location, and any field details captured for that day.
class AttendanceDetailScreen extends StatelessWidget {
  final AttendanceRecord record;

  const AttendanceDetailScreen({super.key, required this.record});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FB),
      appBar: AppBar(
        backgroundColor: const Color(0xFF11141E),
        elevation: 0,
        leading: GestureDetector(
          onTap: () => context.pop(),
          child: const Icon(
            Icons.arrow_back_rounded,
            color: AppColors.darkTextPrimary,
            size: 24,
          ),
        ),
        title: const Text(
          'Attendance Details',
          style: TextStyle(
            color: AppColors.darkTextPrimary,
            fontFamily: 'LibSerif',
            fontWeight: FontWeight.w400,
            fontSize: 22,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeaderCard(),
            const SizedBox(height: 16),
            _buildSummaryCard(),
            const SizedBox(height: 16),
            _buildLocationCard(),
            if (record.fieldDetails.isNotEmpty) ...[
              const SizedBox(height: 16),
              _buildFieldDetailsCard(),
            ],
            if (record.canRegularize) ...[
              const SizedBox(height: 24),
              _buildRegularizeButton(context),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderCard() {
    final colors = _statusColors(record.status);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const RadialGradient(
          colors: [Color(0xFFE8ECFD), Color(0xFFFFFFFF)],
            focal: Alignment(1, -1),
            //radius: 0.75,
            stops: [0.0,0.7]
        ),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: colors.background,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.check_circle, size: 14, color: colors.foreground),
                    const SizedBox(width: 6),
                    Text(
                      _statusDisplayLabel(record.status),
                      style: TextStyle(
                        fontFamily: 'DMSans',
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: colors.foreground,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F3F7),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  'EMP-1042',
                  style: const TextStyle(
                    fontFamily: 'DMSans',
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF6B7280),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            'Mon, 03 Jun',
            style: const TextStyle(
              fontFamily: 'PlayfairDisplay',
              fontSize: 26,
              fontWeight: FontWeight.w700,
              color: Color(0xFF11141E),
            ),
          ),
          const SizedBox(height: 16),
          _buildLabelValue('WORK MODE', 'In-office', icon: Icons.business_rounded),
          const SizedBox(height: 12),
          _buildLabelValue('SHIFT TYPE', 'Morning Shift (10:00 AM – 06:30 PM)', icon: Icons.access_time_rounded),
        ],
      ),
    );
  }

  Widget _buildLabelValue(String label, String value, {required IconData icon}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontFamily: 'DMSans',
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: Color(0xFF7B859A),
            letterSpacing: 0.4,
          ),
        ),
        const SizedBox(height: 4),
        Row(
          children: [
            Icon(icon, size: 16, color: const Color(0xFF3B5BDB)),
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                value,
                style: const TextStyle(
                  fontFamily: 'DMSans',
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF2F4AC0),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSummaryCard() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Summary',
                style: const TextStyle(
                  fontFamily: 'DMSans',
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF11141E),
                ),
              ),
            ),
          ),
          _buildSummaryRow(
            'Check-In',
            '09:02 AM',
            showDivider: false,
            monospaceValue: true,
          ),
          _buildSummaryRow(
            'Check-Out',
            '06:14 PM',
            showDivider: true,
            monospaceValue: true,
          ),
          _buildSummaryRow(
            'Total Hours',
            '09h 12m',
            showDivider: false,
            valueColor: const Color(0xFF3B5BDB),
            bold: true,
            monospaceValue: true,
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(
      String label,
      String value, {
        required bool showDivider,
        Color valueColor = const Color(0xFF11141E),
        bool bold = false,
        bool monospaceValue = false,
      }) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontFamily: 'DMSans',
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                  color: Color(0xFF7B859A),
                ),
              ),
              Text(
                value,
                style: TextStyle(
                  fontFamily:  'DMMono',
                  fontSize:  16,
                  fontWeight: FontWeight.w600,
                  color: valueColor,
                ),
              ),
            ],
          ),
        ),
        if (showDivider)
          const Divider(height: 1, thickness: 1, color: Color(0xFFF1F3F7), indent: 16, endIndent: 16),
      ],
    );
  }

  Widget _buildLocationCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: const Color(0xFFECEEF0),
              borderRadius: BorderRadius.circular(999),
            ),
            child: const Center(
              child: Icon(Icons.location_on_rounded, color: Color(0xFF3525CD), size: 20),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Location Information',
                  style: TextStyle(
                    fontFamily: 'DMSans',
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF11141E),
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Sector 62, Noida, Uttar Pradesh',
                  style: TextStyle(
                    fontFamily: 'DMSans',
                    fontSize: 13,
                    fontWeight: FontWeight.w400,
                    color: Color(0xFF6B7280),
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFFDCFCE7),
              borderRadius: BorderRadius.circular(999),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.check_circle,
                  size: 11,
                  color: Color(0xFF15803D),
                ),
                const SizedBox(width: 4),
                const Text(
                  'INSIDE GEOFENCE',
                  style: TextStyle(
                    fontFamily: 'DMSans',
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF15803D),
                    letterSpacing: 0.2,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFieldDetailsCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Field details',
            style: TextStyle(
              fontFamily: 'DMSans',
              fontSize: 15,
              fontWeight: FontWeight.w500,
              color: Color(0xFF11141E),
            ),
          ),
          const SizedBox(height: 14),
          _buildFieldDetailRow(const AttendanceFieldDetail(
            label: 'Field reason',
            value: 'client meeting',
          )),
          const SizedBox(height: 14),
          _buildFieldDetailRow(const AttendanceFieldDetail(
            label: 'Place name',
            value: 'Infosys technologies ltd.',
          )),
          const SizedBox(height: 14),
          _buildFieldDetailRow(const AttendanceFieldDetail(
            label: 'Location address',
            value: 'Connaught Place, New Delhi',
          )),
          const SizedBox(height: 14),
          _buildFieldDetailRow(const AttendanceFieldDetail(
            label: 'Purpose/remarks',
            value: 'Q3 product demo and pricing discussion with procurement team',
          )),
        ],
      ),
    );
  }

  Widget _buildFieldDetailRow(AttendanceFieldDetail detail) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          detail.label,
          style: const TextStyle(
            fontFamily: 'DMSans',
            fontSize: 16,
            fontWeight: FontWeight.w400,
            color: Color(0xFF7B859A),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          detail.value,
          style: const TextStyle(
            fontFamily: 'DMMono',
            fontSize: 16,
            fontWeight: FontWeight.w400,
            color: Color(0xFF191C22),
          ),
        ),
      ],
    );
  }

  Widget _buildRegularizeButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: () => context.push(AppRoutes.attendanceCorrection, extra: record),
        icon: const Icon(Icons.edit_calendar_rounded, size: 18, color: Color(0xFF3B5BDB)),
        label: const Text(
          'Raise a Correction Request',
          style: TextStyle(
            fontFamily: 'DMSans',
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Color(0xFF3B5BDB),
          ),
        ),
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 14),
          side: const BorderSide(color: Color(0xFFC7D2FE)),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      ),
    );
  }

  String _statusDisplayLabel(AttendanceStatus status) {
    switch (status) {
      case AttendanceStatus.present:
        return 'Present';
      case AttendanceStatus.late:
        return 'Late';
      case AttendanceStatus.absent:
        return 'Absent';
      case AttendanceStatus.halfDay:
        return 'Half Day';
    }
  }

  _StatusColors _statusColors(AttendanceStatus status) {
    switch (status) {
      case AttendanceStatus.present:
        return const _StatusColors(Color(0xFFDCFCE7), Color(0xFF15803D));
      case AttendanceStatus.late:
        return const _StatusColors(Color(0xFFFFEDD5), Color(0xFFC2410C));
      case AttendanceStatus.absent:
        return const _StatusColors(Color(0xFFFEE2E2), Color(0xFFB91C1C));
      case AttendanceStatus.halfDay:
        return const _StatusColors(Color(0xFFEDE9FE), Color(0xFF6D28D9));
    }
  }
}

/// Small value holder for a status badge's background/foreground colors.
class _StatusColors {
  final Color background;
  final Color foreground;

  const _StatusColors(this.background, this.foreground);
}