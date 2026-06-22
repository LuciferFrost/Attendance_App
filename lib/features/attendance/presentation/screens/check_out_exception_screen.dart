import 'package:demo4/core/theme/app_colors.dart';
import 'package:demo4/core/theme/app_spacing.dart';
import 'package:demo4/core/theme/app_typography.dart';
import 'package:demo4/features/attendance/data/models/check_out_exception.dart';
import 'package:demo4/features/attendance/presentation/providers/check_out_exception_providers.dart';
import 'package:demo4/features/dashboard/presentation/providers/dashboard_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class CheckOutExceptionScreen extends ConsumerStatefulWidget {
  final double latitude;
  final double longitude;
  final double distanceInMeters;
  final String officeLocation;
  final double officeLatitude;
  final double officeLongitude;
  final DateTime attemptedAt;

  const CheckOutExceptionScreen({
    super.key,
    required this.latitude,
    required this.longitude,
    required this.distanceInMeters,
    required this.officeLocation,
    required this.officeLatitude,
    required this.officeLongitude,
    required this.attemptedAt,
  });

  @override
  ConsumerState<CheckOutExceptionScreen> createState() =>
      _CheckOutExceptionScreenState();
}

class _CheckOutExceptionScreenState
    extends ConsumerState<CheckOutExceptionScreen> {
  late TextEditingController _reasonController;
  late TextEditingController _remarksController;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _reasonController = TextEditingController();
    _remarksController = TextEditingController();
  }

  @override
  void dispose() {
    _reasonController.dispose();
    _remarksController.dispose();
    super.dispose();
  }

  /// Format time to 12-hour format (e.g., "6:29 PM")
  String _formatTime(DateTime dateTime) {
    final hour = dateTime.hour % 12 == 0 ? 12 : dateTime.hour % 12;
    final period = dateTime.hour >= 12 ? 'PM' : 'AM';
    return '${hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')} $period';
  }

  /// Format distance in meters to km string (e.g., "820 m")
  String _formatDistance(double meters) {
    if (meters >= 1000) {
      return '${(meters / 1000).toStringAsFixed(1)} km';
    }
    return '${meters.toStringAsFixed(0).replaceAllMapped(RegExp(r'\B(?=(\d{3})+(?!\d))'), (m) => ',')} m';
  }

  /// Submit the exception
  Future<void> _submitException() async {
    if (_reasonController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter an exception reason'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    if (_remarksController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter remarks'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final employeeId = ref.read(dashboardStateProvider).employeeCode;
      final controller =
      ref.read(checkOutExceptionControllerProvider.notifier);

      final response = await controller.submitException(
        employeeId: employeeId,
        exceptionReason: _reasonController.text.trim(),
        remarks: _remarksController.text.trim(),
        latitude: widget.latitude,
        longitude: widget.longitude,
        officeLocation: widget.officeLocation,
        officeLatitude: widget.officeLatitude,
        officeLongitude: widget.officeLongitude,
        distanceInMeters: widget.distanceInMeters,
        attemptedAt: widget.attemptedAt,
      );

      if (mounted && response != null) {
        setState(() => _isSubmitting = false);
        _showSuccessModal(response);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSubmitting = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  /// Show success modal after exception submission
  void _showSuccessModal(CheckOutExceptionResponse response) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return _buildExceptionSubmittedModal(dialogContext, response);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
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
        title: Text(
          'Check out',
          style: AppTypography.heading2.copyWith(
            color: AppColors.darkTextPrimary,
            fontFamily: 'LibSerif',
            fontWeight: FontWeight.w400,
            fontSize: 24,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.pageHorizontal,
            vertical: AppSpacing.pageVertical,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildGeofenceFailureAlert(),
              const SizedBox(height: AppSpacing.lg),
              _buildExceptionReasonField(),
              const SizedBox(height: AppSpacing.lg),
              _buildRemarksField(),
              const SizedBox(height: AppSpacing.lg),
              _buildLocationCard(),
              const SizedBox(height: AppSpacing.lg),
              _buildManagerCard(),
              const SizedBox(height: AppSpacing.xxxl),
              _buildSubmitButton(),
              const SizedBox(height: AppSpacing.md),
              _buildCancelButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGeofenceFailureAlert() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFE3F2FD),
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        border: Border.all(
          color: const Color(0xFF90CAF9),
        ),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.info_rounded,
            color: Color(0xFF1976D2),
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Outside Geofence at Check-Out',
                  style: TextStyle(
                    color: Color(0xFF1976D2),
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    fontFamily: 'DMSans',
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'GEOFENCE RESULT',
                            style: TextStyle(
                              color: Color(0xFF1976D2).withOpacity(0.7),
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                              fontFamily: 'DMSans',
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Failed • ${_formatDistance(widget.distanceInMeters)} away',
                            style: const TextStyle(
                              color: Color(0xFF1976D2),
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              fontFamily: 'DMSans',
                            ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            'ATTEMPTED AT',
                            style: TextStyle(
                              color: Color(0xFF1976D2).withOpacity(0.7),
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                              fontFamily: 'DMSans',
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            _formatTime(widget.attemptedAt),
                            style: const TextStyle(
                              color: Color(0xFF1976D2),
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              fontFamily: 'DMSans',
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExceptionReasonField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Exception Reason *',
          style: AppTypography.label.copyWith(
            color: AppColors.neutral900,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        TextField(
          controller: _reasonController,
          maxLines: 1,
          enabled: !_isSubmitting,
          decoration: InputDecoration(
            hintText: 'Left office site for urgent client escalation',
            hintStyle: const TextStyle(
              color: Color(0xFFAAAAAA),
              fontSize: 14,
              fontFamily: 'DMSans',
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 12,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
              borderSide: const BorderSide(
                color: Color(0xFFE5E7EB),
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
              borderSide: const BorderSide(
                color: Color(0xFF3B82F6),
              ),
            ),
            filled: true,
            fillColor: Colors.white,
          ),
          style: const TextStyle(
            color: Colors.black,
            fontSize: 14,
            fontFamily: 'DMSans',
          ),
        ),
      ],
    );
  }

  Widget _buildRemarksField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Remarks *',
          style: AppTypography.label.copyWith(
            color: AppColors.neutral900,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        TextField(
          controller: _remarksController,
          maxLines: 4,
          minLines: 3,
          enabled: !_isSubmitting,
          decoration: InputDecoration(
            hintText:
            'Had to rush to client site for urgent requirement discussion before EOD. Left office premises at 6:20 PM',
            hintStyle: const TextStyle(
              color: Color(0xFFAAAAAA),
              fontSize: 14,
              fontFamily: 'DMSans',
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 12,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
              borderSide: const BorderSide(
                color: Color(0xFFE5E7EB),
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
              borderSide: const BorderSide(
                color: Color(0xFF3B82F6),
              ),
            ),
            filled: true,
            fillColor: Colors.white,
          ),
          style: const TextStyle(
            color: Colors.black,
            fontSize: 14,
            fontFamily: 'DMSans',
          ),
        ),
      ],
    );
  }

  Widget _buildLocationCard() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        border: Border.all(
          color: const Color(0xFFE5E7EB),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: const Color(0xFFE3F2FD),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Center(
              child: Icon(
                Icons.location_on_rounded,
                color: Color(0xFF3B82F6),
                size: 20,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.officeLocation,
                  style: const TextStyle(
                    color: Colors.black,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    fontFamily: 'DMSans',
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${widget.officeLatitude.toStringAsFixed(4)}°N, ${widget.officeLongitude.toStringAsFixed(4)}°E',
                  style: const TextStyle(
                    color: Color(0xFF6B7280),
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                    fontFamily: 'DMSans',
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Color(0xFF10B981),
                      ),
                    ),
                    const SizedBox(width: 6),
                    const Text(
                      'Location captured',
                      style: TextStyle(
                        color: Color(0xFF10B981),
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        fontFamily: 'DMSans',
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildManagerCard() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        border: Border.all(
          color: const Color(0xFFE5E7EB),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: const Color(0xFF5B6FDB),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Center(
              child: Text(
                'AJ',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  fontFamily: 'DMSans',
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Arvind Joshi',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    fontFamily: 'DMSans',
                  ),
                ),
                const SizedBox(height: 2),
                const Text(
                  'Will review this exception',
                  style: TextStyle(
                    color: Color(0xFF6B7280),
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                    fontFamily: 'DMSans',
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFFDCFCE7),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Text(
              'Will Notify',
              style: TextStyle(
                color: Color(0xFF059669),
                fontSize: 11,
                fontWeight: FontWeight.w600,
                fontFamily: 'DMSans',
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: _isSubmitting ? null : _submitException,
        icon: _isSubmitting
            ? const SizedBox(
          width: 18,
          height: 18,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
          ),
        )
            : const Icon(Icons.send_rounded, size: 18),
        label: Text(
          _isSubmitting ? 'Submitting...' : 'Submit Exception',
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            fontFamily: 'DMSans',
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF3B5BDB),
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 14),
          disabledBackgroundColor: const Color(0xFFB0B5BC),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          elevation: 0,
        ),
      ),
    );
  }

  Widget _buildCancelButton() {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton(
        onPressed: _isSubmitting ? null : () => context.pop(),
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 14),
          side: const BorderSide(
            color: Color(0xFFE5E7EB),
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        child: const Text(
          'Cancel',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            fontFamily: 'DMSans',
            color: Color(0xFF374151),
          ),
        ),
      ),
    );
  }

  Widget _buildExceptionSubmittedModal(BuildContext dialogContext, CheckOutExceptionResponse response) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: const Color(0xFFFEF3C7),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Center(
                  child: Icon(
                    Icons.notifications_active_rounded,
                    size: 40,
                    color: Color(0xFFD97706),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'Exception Submitted',
                style: AppTypography.heading2.copyWith(
                  color: Colors.black,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'Check-out exception submitted. Attendance status: ${response.attendanceStatus}. Your manager will review.',
                textAlign: TextAlign.center,
                style: AppTypography.bodySmall.copyWith(
                  color: const Color(0xFF6B7280),
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                decoration: BoxDecoration(
                  color: const Color(0xFFFEF3C7),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: const Color(0xFFDEBE54),
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.info_rounded,
                      color: Color(0xFFD97706),
                      size: 18,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Manager Notified',
                            style: TextStyle(
                              color: Color(0xFFD97706),
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              fontFamily: 'DMSans',
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'An approval request for your check-out has been sent to ${response.managerName} (Manager).',
                            style: const TextStyle(
                              color: Color(0xFFB45309),
                              fontSize: 12,
                              fontWeight: FontWeight.w400,
                              fontFamily: 'DMSans',
                              height: 1.4,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(dialogContext).pop(); // Close modal
                    context.go('/dashboard'); // Navigate to dashboard
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF3B5BDB),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    'Ok, got it',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      fontFamily: 'DMSans',
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () => Navigator.of(dialogContext).pop(),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    side: const BorderSide(
                      color: Color(0xFFE5E7EB),
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text(
                    'Continue with Selected Reason',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      fontFamily: 'DMSans',
                      color: Color(0xFF374151),
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