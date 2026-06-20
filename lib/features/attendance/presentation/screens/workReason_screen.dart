import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:demo4/core/theme/app_colors.dart';
import 'package:demo4/core/theme/app_spacing.dart';
import 'package:demo4/core/theme/app_typography.dart';

class WorkReasonScreen extends ConsumerStatefulWidget {
  const WorkReasonScreen({super.key});

  @override
  ConsumerState<WorkReasonScreen> createState() => _WorkReasonScreenState();
}

class _WorkReasonScreenState extends ConsumerState<WorkReasonScreen> {
  String? selectedReason;
  final TextEditingController _remarksController = TextEditingController();
  // Add this near the top of _WorkReasonScreenState
  bool isPreApproved = true; // dummy value

  final List<Map<String, dynamic>> workReasons = [
    {
      'title': 'Work From Home',
      'value': 'work_from_home',
      'icon': Icons.person_rounded,
    },
    {
      'title': 'On-Duty / Field Work',
      'value': 'on_duty_field',
      'icon': Icons.work_rounded,
    },
    {
      'title': 'Client Visit',
      'value': 'client_visit',
      'icon': Icons.business_rounded,
    },
    {
      'title': 'Other (Specify)',
      'value': 'other',
      'icon': Icons.more_horiz_rounded,
    },
  ];

  @override
  void dispose() {
    _remarksController.dispose();
    super.dispose();
  }

  void _showApprovalPendingModal() {
    showDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black.withValues(alpha: 0.5),
      builder: (BuildContext dialogContext) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.symmetric(horizontal: 24),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
            ),
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Bell icon in amber circle
                Container(
                  width: 72,
                  height: 72,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Color(0xFFFEF3C7),
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.notifications_rounded,
                      color: Color(0xFFF59E0B),
                      size: 36,
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Title
                const Text(
                  'Check-in pending',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    fontFamily: 'DMSans',
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 10),

                // Subtitle
                const Text(
                  'You will be logged in once your manager approves this request. Your manager has been notified.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    fontFamily: 'DMSans',
                    color: Color(0xFF6B7280),
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 20),

                // Manager notified card
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFFBEB),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 32,
                        height: 32,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: Color(0xFFF59E0B),
                        ),
                        child: const Center(
                          child: Icon(
                            Icons.notifications_rounded,
                            color: Colors.white,
                            size: 16,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Manager Notified',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                fontFamily: 'DMSans',
                                color: Color(0xFFF59E0B),
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              'Priya Sharma (Manager) has been sent an approval request for your check-in.',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w400,
                                fontFamily: 'DMSans',
                                color: Color(0xFFF59E0B),
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

                // Ok button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(dialogContext).pop();
                      // TODO: navigate away or stay on screen
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF3B5BDB),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(50),
                      ),
                      elevation: 0,
                    ),
                    child: const Text(
                      'Ok, got it',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        fontFamily: 'DMSans',
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  String _getFormattedTime() {
    final now = DateTime.now();
    final hour = now.hour % 12 == 0 ? 12 : now.hour % 12;
    final period = now.hour >= 12 ? 'PM' : 'AM';
    return '${hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')} $period';
  }
  void _handleContinue() {
    if (selectedReason == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Please select a work reason',
            style: AppTypography.bodySmall.copyWith(color: Colors.white),
          ),
          duration: const Duration(seconds: 2),
          backgroundColor: AppColors.error ?? Colors.red,
        ),
      );
      return;
    }

    if (selectedReason == 'other' && _remarksController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Please specify the reason in the remarks',
            style: AppTypography.bodySmall.copyWith(color: Colors.white),
          ),
          duration: const Duration(seconds: 2),
          backgroundColor: AppColors.error ?? Colors.red,
        ),
      );
      return;
    }

    if (!isPreApproved) {
      _showApprovalPendingModal();
      return;
    }

    if (!isPreApproved) {
      _showApprovalPendingModal();
      return;
    }

// Pre-approved — navigate to success screen
    context.pushReplacementNamed(
      'check-in-success',
      extra: {
        'attendanceStatus': 'Present',
        'geofenceStatus': 'Outside Geofence',
        'checkInTime': _getFormattedTime(),
        'workMode': selectedReason ?? '',
        'location': 'CraftEdge Office, Sector 62, Noida',
        'shiftType': 'Day Shift',
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: _buildAppBar(context),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: AppSpacing.md),
              _buildTitle(),
              SizedBox(height: AppSpacing.sm),
              _buildSubtitle(),
              SizedBox(height: AppSpacing.xl),
              _buildReasonOptions(),
              SizedBox(height: AppSpacing.xl),
              _buildRemarksSection(),
              SizedBox(height: AppSpacing.xl),
              _buildContinueButton(),
              SizedBox(height: AppSpacing.lg),
            ],
          ),
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: AppColors.darkSurface,
      elevation: 0,
      leading: GestureDetector(
        onTap: () => context.pop(),
        child: Center(
          child: Icon(
            Icons.arrow_back_rounded,
            color: Colors.white,
            size: 24,
          ),
        ),
      ),
      title: Text(
        'Check in',
        style: AppTypography.heading2.copyWith(
          color: Colors.white,
          fontFamily: 'LibSerif',
          fontWeight: FontWeight.w400,
          fontSize: 24,
        ),
      ),
      centerTitle: true,
      actions: [
        SizedBox(width: AppSpacing.lg),
      ],
    );
  }

  Widget _buildTitle() {
    return Text(
      'Select Work Reason',
      style: AppTypography.heading2.copyWith(
        color: AppColors.neutral900,
        fontWeight: FontWeight.w700,
        fontFamily: 'DMSans',
        fontSize: 18,
      ),
    );
  }

  Widget _buildSubtitle() {
    return Text(
      'Why are you outside office today?',
      style: AppTypography.bodyMedium.copyWith(
        color: AppColors.neutral600,
      ),
    );
  }

  Widget _buildReasonOptions() {
    return Column(
      children: List.generate(
        workReasons.length,
            (index) {
          final reason = workReasons[index];
          final isSelected = selectedReason == reason['value'];

          return Column(
            children: [
              _buildReasonCard(
                title: reason['title'],
                value: reason['value'],
                icon: reason['icon'],
                isSelected: isSelected,
                onTap: () {
                  setState(() {
                    selectedReason = reason['value'];
                  });
                },
              ),
              if (index < workReasons.length - 1) SizedBox(height: AppSpacing.md),
            ],
          );
        },
      ),
    );
  }

  Widget _buildReasonCard({
    required String title,
    required String value,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFF3B82F6).withValues(alpha: 0.08)
              : const Color(0xFFFFFFFF),//Option bg
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? const Color(0xFF3B82F6) //Border Color
                : const Color(0xFFE5E7EB),
            width: 1,
          ),
          boxShadow: [
            if (isSelected)
              BoxShadow(
                color: const Color(0xFF3B82F6).withValues(alpha: 0.1),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            if (!isSelected)
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.03),
                blurRadius: 4,
                offset: const Offset(0, 1),
              ),
          ],
        ),
        child: Row(
          children: [
            // Icon
            Icon(
              icon,
              color: isSelected
                  ? const Color(0xFF3B82F6) //Icon Blue
                  : const Color(0xFF6B7280),
              size: 24,
            ),
            SizedBox(width: AppSpacing.md),
            // Title
            Expanded(
              child: Text(
                title,
                style: AppTypography.bodyMedium.copyWith(
                  fontWeight: FontWeight.w500,
                  fontFamily: 'DMSans',
                  fontSize: 16,
                  color: isSelected
                      ? const Color(0xFF3B82F6) //Text Blue
                      : AppColors.neutral900,
                ),
              ),
            ),
            // Radio Button
            Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected
                      ? const Color(0xFF3B82F6) //Button Blue
                      : const Color(0xFFC8CDD9),//#F1F3F7
                  width: isSelected ? 6: 2,
                ),
              ),
              /*child: isSelected
                  ? Center(
                child: Container(
                  width: 12,
                  height: 12,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Color(0xFF3B82F6),
                  ),
                ),
              )
                  : null,*/
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRemarksSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Additional Remarks (optional)',
          style: AppTypography.label.copyWith(
            color: AppColors.neutral900,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.3,
          ),
        ),
        SizedBox(height: AppSpacing.md),
        TextField(
          controller: _remarksController,
          maxLines: 4,
          style: AppTypography.bodyMedium.copyWith(
            color: AppColors.neutral900,
          ),
          decoration: InputDecoration(
            filled: true,
            fillColor: const Color(0xFFFFFFFF),
            hintText: 'Add any notes for your manager...',
            hintStyle: AppTypography.bodyMedium.copyWith(
              color: const Color(0xFF9CA3AF),
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: Color(0xFFC8CDD9),
                width: 1,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: Color(0xFFC8CDD9),
                width: 1,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: Color(0xFFC8CDD9),
                width: 2,
              ),
            ),
            contentPadding: EdgeInsets.all(AppSpacing.md),
          ),
        ),
      ],
    );
  }

  Widget _buildContinueButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _handleContinue,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF3B82F6),
          padding: EdgeInsets.symmetric(vertical: AppSpacing.md),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          elevation: 0,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.check_rounded,
              color: Colors.white,
              size: 20,
            ),
            SizedBox(width: AppSpacing.sm),
            Text(
              'Continue with Selected Reason',
              style: AppTypography.label.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}