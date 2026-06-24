import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';

/// Screen shown after a short leave / early exit request has been submitted
/// and is awaiting manager approval.
class ShortLeavePendingScreen extends StatelessWidget {
  /// The time the check-in was recorded (e.g. "10:04 AM")
  final String checkInTime;

  /// The time the check-out was attempted (e.g. "5:15 PM")
  final String checkOutTime;

  /// Total hours worked as a Duration
  final Duration totalHours;

  /// The shortfall duration (required - worked)
  final Duration shortfall;

  /// Manager's name to display
  final String managerName;

  /// Time the request was sent (e.g. "4:46 PM")
  final String requestSentTime;

  const ShortLeavePendingScreen({
    super.key,
    required this.checkInTime,
    required this.checkOutTime,
    required this.totalHours,
    required this.shortfall,
    required this.managerName,
    required this.requestSentTime,
  });

  static String _formatDuration(Duration d) {
    final h = d.inHours;
    final m = d.inMinutes.remainder(60);
    return '${h}h ${m.toString().padLeft(2, '0')}m';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color(0xFF11141E),
        elevation: 0,
        leading: GestureDetector(
          onTap: () => context.go('/dashboard'),
          child: const Icon(
            Icons.arrow_back_rounded,
            color: Colors.white,
            size: 24,
          ),
        ),
        title: const Text(
          'Check out',
          style: TextStyle(
            color: Colors.white,
            fontFamily: 'LibSerif',
            fontWeight: FontWeight.w400,
            fontSize: 24,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 32,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Clock icon badge
                    Container(
                      width: 96,
                      height: 96,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Color(0xFFFCF0DF),
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.access_time_rounded,
                          size: 44,
                          color: Color(0xFFD2821C),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Title
                    const Text(
                      'Pending Review',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.w700,
                        fontFamily: 'PlayfairDisplay',
                        color: Color(0xFF111827),
                      ),
                    ),
                    const SizedBox(height: 10),

                    // Subtitle
                    const Text(
                      'You have an exception pending manager\napproval. Your attendance will be finalized\nafter approval.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w400,
                        fontFamily: 'DMSans',
                        color: Color(0xFF6B7280),
                        height: 1.55,
                      ),
                    ),
                    const SizedBox(height: 28),

                    // Approval status card
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 14,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFF8EE),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: const Color(0xFFFDE9C1),
                          width: 1,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Header row
                          Row(
                            children: const [
                              Icon(
                                Icons.access_time_rounded,
                                size: 18,
                                color: Color(0xFFD2821C),
                              ),
                              SizedBox(width: 8),
                              Text(
                                'Pending Manager Approval',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  fontFamily: 'DMSans',
                                  color: Color(0xFFD2821C),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Leave type: short leave (Shortfall)',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              fontFamily: 'DMSans',
                              color: Color(0xFF92400E),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Manager: $managerName · Request sent $requestSentTime',
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w400,
                              fontFamily: 'DMSans',
                              color: Color(0xFFB45309),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Time summary card
                    Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: const Color(0xFFE5E7EB),
                          width: 1,
                        ),
                      ),
                      child: Column(
                        children: [
                          _buildSummaryRow(
                            label: 'Check in',
                            value: checkInTime,
                            valueColor: const Color(0xFF111827),
                            showDivider: true,
                          ),
                          _buildSummaryRow(
                            label: 'check out',
                            value: checkOutTime,
                            valueColor: const Color(0xFF111827),
                            showDivider: true,
                          ),
                          _buildSummaryRow(
                            label: 'Total hours',
                            value: _formatDuration(totalHours),
                            valueColor: const Color(0xFF16A34A),
                            showDivider: true,
                          ),
                          _buildSummaryRow(
                            label: 'Shortfall',
                            value: '-${_formatDuration(shortfall)}',
                            valueColor: const Color(0xFFEF4444),
                            showDivider: false,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // OK, Go Home button pinned to bottom
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
              child: SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton.icon(
                  onPressed: () => context.go('/dashboard'),
                  icon: const Icon(
                    Icons.home_rounded,
                    color: Colors.white,
                    size: 20,
                  ),
                  label: const Text(
                    'OK, Go Home',
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w600,
                      fontFamily: 'DMSans',
                      color: Colors.white,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF3B5BDB),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryRow({
    required String label,
    required String value,
    required Color valueColor,
    required bool showDivider,
  }) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  fontFamily: 'DMSans',
                  color: Color(0xFF9CA3AF),
                ),
              ),
              Text(
                value,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  fontFamily: 'DMSans',
                  color: valueColor,
                ),
              ),
            ],
          ),
        ),
        if (showDivider)
          const Divider(height: 1, thickness: 1, color: Color(0xFFF3F4F6)),
      ],
    );
  }
}