import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../providers/checkin_providers.dart';

class HolidayWarningScreen extends ConsumerStatefulWidget {
  const HolidayWarningScreen({super.key});

  @override
  ConsumerState<HolidayWarningScreen> createState() =>
      _HolidayWarningScreenState();
}

class _HolidayWarningScreenState extends ConsumerState<HolidayWarningScreen> {
  final TextEditingController _reasonController = TextEditingController();
  bool _isSubmitting = false;

  @override
  void dispose() {
    _reasonController.dispose();
    super.dispose();
  }

  Future<void> _handleCheckInAnyway() async {
    if (_reasonController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please provide a reason for working today.'),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    // Simulate submitting the request
    await Future.delayed(const Duration(milliseconds: 800));

    if (!mounted) return;

    setState(() => _isSubmitting = false);

    // Show the "Check-in pending" popup
    await _showCheckInPendingDialog();
  }

  Future<void> _showCheckInPendingDialog() async {
    final holidayAsync = ref.read(holidayInfoProvider);
    final managerName = holidayAsync.maybeWhen(
      data: (info) => info?.managerName ?? 'Your Manager',
      orElse: () => 'Your Manager',
    );

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        child: Padding(
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
                  color: Color(0xFFFFF8E1),
                ),
                child: const Center(
                  child: Icon(
                    Icons.notifications_rounded,
                    size: 36,
                    color: Color(0xFFF59E0B),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Check-in pending',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  fontFamily: 'PlayfairDisplay',
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                'You will be logged in once your manager approves this request. Your manager has been notified.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  fontFamily: 'DMSans',
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF6B7280),
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 16),
              // Manager notified box
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF8E1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
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
                              size: 18,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        const Text(
                          'Manager Notified',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            fontFamily: 'DMSans',
                            color: Color(0xFFB88230),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '$managerName has been sent an approval request for your check-in.',
                      style: const TextStyle(
                        fontSize: 14,
                        fontFamily: 'DMSans',
                        fontWeight: FontWeight.w500,
                        color: Color(0xFFB88230),
                        height: 1.4,
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
                    Navigator.of(ctx).pop();
                    context.go('/dashboard');
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF3B5BDB),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    'Ok, got it',
                    style: TextStyle(
                      fontSize: 16,
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
      ),
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
          'Check in',
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
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.pageHorizontal,
          vertical: AppSpacing.pageVertical,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHolidayBanner(),
            const SizedBox(height: 20),
            _buildIfYouProceedCard(),
            const SizedBox(height: 20),
            _buildReasonField(),
            const SizedBox(height: 32),
            _buildCheckInAnywayButton(),
            const SizedBox(height: 12),
            _buildBackToHomeButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildHolidayBanner() {
    final holidayAsync = ref.watch(holidayInfoProvider);

    final holidayName = holidayAsync.maybeWhen(
      data: (info) => info?.name ?? 'Holiday / Non-working day',
      orElse: () => 'Holiday / Non-working day',
    );

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFBEB),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFFDE68A)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.warning_amber_rounded,
            color: Color(0xFFD97706),
            size: 24,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  holidayName,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    fontFamily: 'PlayfairDisplay',
                    color: Color(0xFFE6A23C),
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Working today requires manager approval. Your entry will be sent for review.',
                  style: TextStyle(
                    fontSize: 14,
                    fontFamily: 'DMSans',
                    fontWeight: FontWeight.w400,
                    color: Color(0xFFE6A23C),
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIfYouProceedCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'If you proceed:',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              fontFamily: 'PlayfairDisplay',
              color: const Color(0xFF0F172A),
            ),
          ),
          const SizedBox(height: 14),
          _buildProceedItem(
            icon: Icons.check_rounded,
            iconColor: const Color(0xFF22C55E),
            text: 'Attendance will be logged',
          ),
          const SizedBox(height: 10),
          _buildProceedItem(
            icon: Icons.check_rounded,
            iconColor: const Color(0xFF22C55E),
            text: 'Manager will be notified',
          ),
          const SizedBox(height: 10),
          _buildProceedItem(
            icon: Icons.access_time_rounded,
            iconColor: const Color(0xFFF59E0B),
            text: 'Timesheet required only if approved',
          ),
          const SizedBox(height: 10),
          _buildProceedItem(
            icon: Icons.close_rounded,
            iconColor: const Color(0xFFEF4444),
            text: "If rejected, attendance won't count as work",
          ),
        ],
      ),
    );
  }

  Widget _buildProceedItem({
    required IconData icon,
    required Color iconColor,
    required String text,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: iconColor),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              fontSize: 16,
              fontFamily: 'DMSans',
              fontWeight: FontWeight.w500,
              color: Color(0xFF475569),
              height: 1.4,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildReasonField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Reason for working today *',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            fontFamily: 'DMSans',
            color: Color(0xFF334155),
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _reasonController,
          maxLines: 4,
          style: const TextStyle(
            fontSize: 14,
            fontFamily: 'DMSans',
            color: Colors.black,
          ),
          decoration: InputDecoration(
            hintText: "Explain why you're working on a holiday...",
            hintStyle: const TextStyle(
              fontSize: 14,
              fontFamily: 'DMSans',
              color: Color(0xFF9CA3AF),
            ),
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.all(14),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Color(0xFFD1D5DB)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Color(0xFFD1D5DB)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Color(0xFF3B5BDB), width: 1.5),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCheckInAnywayButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _isSubmitting ? null : _handleCheckInAnyway,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF3B5BDB),
          disabledBackgroundColor: const Color(0xFF3B5BDB).withOpacity(0.6),
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 0,
        ),
        child: _isSubmitting
            ? const SizedBox(
          width: 20,
          height: 20,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
          ),
        )
            : const Text(
          'Check in anyway',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            fontFamily: 'DMSans',
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  Widget _buildBackToHomeButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () => context.go('/dashboard'),
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFF3F4F6),
          foregroundColor: const Color(0xFF374151),
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 0,
        ),
        child: const Text(
          'Back to Home',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            fontFamily: 'DMSans',
            color: Color(0xFF374151),
          ),
        ),
      ),
    );
  }
}