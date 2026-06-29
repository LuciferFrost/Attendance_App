import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_typography.dart';

class EarlyCheckInScreen extends StatefulWidget {
  /// The scheduled shift start time string, e.g. "9:00 AM"
  final String shiftStartTime;

  const EarlyCheckInScreen({
    Key? key,
    required this.shiftStartTime,
  }) : super(key: key);

  @override
  State<EarlyCheckInScreen> createState() => _EarlyCheckInScreenState();
}

class _EarlyCheckInScreenState extends State<EarlyCheckInScreen> {
  final TextEditingController _reasonController = TextEditingController();
  final TextEditingController _remarksController = TextEditingController();
  bool _isSubmitting = false;

  @override
  void dispose() {
    _reasonController.dispose();
    _remarksController.dispose();
    super.dispose();
  }

  void _handleCheckInAnyway() {
    if (_reasonController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please provide a reason for early check-in.'),
          backgroundColor: Color(0xFFEF4444),
        ),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    // Pop back with result so HomeScreen can proceed with check-in flow,
    // passing along the reason & remarks.
    context.pop({
      'proceed': true,
      'reason': _reasonController.text.trim(),
      'remarks': _remarksController.text.trim(),
    });
  }

  void _handleCancel() => context.pop({'proceed': false});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color(0xFF11141E),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: _handleCancel,
        ),
        centerTitle: true,
        title: Text(
          'Early Check-In',
          style: AppTypography.heading2?.copyWith(
            color: Colors.white,
            fontFamily: 'PlayfairDisplay',
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Icon ──────────────────────────────────────────────────────
              Center(
                child: Container(
                  width: 80,
                  height: 80,
                  decoration: const BoxDecoration(
                    color: Color(0xFFFEF0E6),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.sensor_door_outlined,
                    color: Color(0xFFB45309),
                    size: 36,
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // ── Title ─────────────────────────────────────────────────────
              Center(
                child: Text(
                  'Early Check-In Detected',
                  textAlign: TextAlign.center,
                  style: AppTypography.heading2?.copyWith(
                    fontFamily: 'PlayfairDisplay',
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF111827),
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // ── Subtitle ──────────────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Center(
                  child: Text(
                    'You are attempting to check in before your scheduled '
                        'shift start time of ${widget.shiftStartTime}. '
                        'Manager approval is required to proceed with early check-in.',
                    textAlign: TextAlign.center,
                    style: AppTypography.bodyMedium?.copyWith(
                      color: const Color(0xFF6B7280),
                      height: 1.55,
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 36),

              // ── Reason field ──────────────────────────────────────────────
              Text(
                'Reason for early check-in',
                style: AppTypography.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF111827),
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _reasonController,
                maxLines: 1,
                decoration: InputDecoration(
                  hintText: 'Add the reason.....',
                  hintStyle: AppTypography.bodyMedium?.copyWith(
                    color: const Color(0xFF9CA3AF),
                    fontSize: 14,
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: Color(0xFFD1D5DB)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(
                      color: Color(0xFF3B5BDB),
                      width: 1.5,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // ── Remarks field ─────────────────────────────────────────────
              Text(
                'Remarks (optional)',
                style: AppTypography.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF111827),
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _remarksController,
                maxLines: 6,
                decoration: InputDecoration(
                  hintText: 'Add any notes for your manager...',
                  hintStyle: AppTypography.bodyMedium?.copyWith(
                    color: const Color(0xFF9CA3AF),
                    fontSize: 14,
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: Color(0xFFD1D5DB)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(
                      color: Color(0xFF3B5BDB),
                      width: 1.5,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 32),

              // ── Check in anyway button ────────────────────────────────────
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isSubmitting ? null : _handleCheckInAnyway,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF3B5BDB),
                    foregroundColor: Colors.white,
                    disabledBackgroundColor: const Color(0xFF3B5BDB).withOpacity(0.6),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: _isSubmitting
                      ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                      : Text(
                    'Check in anyway',
                    style: AppTypography.bodyMedium?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // ── Cancel ────────────────────────────────────────────────────
              Center(
                child: TextButton(
                  onPressed: _handleCancel,
                  child: Text(
                    'Cancel',
                    style: AppTypography.bodyMedium?.copyWith(
                      color: const Color(0xFF3B5BDB),
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}