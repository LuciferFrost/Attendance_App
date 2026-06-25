import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/leave_request.dart';
import '../providers/leave_providers.dart';

class LeaveApplyScreen extends ConsumerStatefulWidget {
  const LeaveApplyScreen({super.key});

  @override
  ConsumerState<LeaveApplyScreen> createState() => _LeaveApplyScreenState();
}

class _LeaveApplyScreenState extends ConsumerState<LeaveApplyScreen> {
  LeaveType? _selectedType;
  DateTime _leaveDate = DateTime.now().add(const Duration(days: 1));
  TimeOfDay? _leaveTiming;
  final _reasonController = TextEditingController();
  final _remarksController = TextEditingController();
  bool _submitted = false;

  static const _leaveTypes = [
    LeaveType.casual,
    LeaveType.sick,
    LeaveType.earned,
    LeaveType.halfDay,
    LeaveType.shortLeave,
  ];

  @override
  void dispose() {
    _reasonController.dispose();
    _remarksController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _leaveDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: const ColorScheme.light(
            primary: Color(0xFF4F46E5),
            onPrimary: Colors.white,
            onSurface: Color(0xFF11141E),
          ),
        ),
        child: child!,
      ),
    );
    if (picked != null) setState(() => _leaveDate = picked);
  }

  Future<void> _pickTime() async {
    int selectedHour = _leaveTiming?.hour ?? 17;
    int selectedMinute = _leaveTiming?.minute ?? 0;
    int selectedSecond = 0;
    bool isAm = selectedHour < 12;

    // Convert to 12-hour format
    int displayHour = selectedHour % 12 == 0 ? 12 : selectedHour % 12;

    await showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setInnerState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              title: const Text(
                'SELECT TIME',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 1.2,
                ),
              ),
              content: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  _buildSpinner(
                    label: 'HOUR',
                    value: displayHour,
                    min: 1,
                    max: 12,
                    onChanged: (v) => setInnerState(() => displayHour = v),
                  ),
                  const Padding(
                    padding: EdgeInsets.only(top: 24),
                    child: Text(':', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  ),
                  _buildSpinner(
                    label: 'MINUTE',
                    value: selectedMinute,
                    min: 0,
                    max: 59,
                    onChanged: (v) => setInnerState(() => selectedMinute = v),
                  ),
                  const Padding(
                    padding: EdgeInsets.only(top: 24),
                    child: Text(':', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  ),
                  _buildSpinner(
                    label: 'SECOND',
                    value: selectedSecond,
                    min: 0,
                    max: 59,
                    onChanged: (v) => setInnerState(() => selectedSecond = v),
                  ),
                  const SizedBox(width: 8),
                  // AM/PM toggle
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _buildAmPmButton(
                        label: 'AM',
                        selected: isAm,
                        onTap: () => setInnerState(() => isAm = true),
                      ),
                      const SizedBox(height: 4),
                      _buildAmPmButton(
                        label: 'PM',
                        selected: !isAm,
                        onTap: () => setInnerState(() => isAm = false),
                      ),
                    ],
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: () {
                    // Convert back to 24-hour
                    int hour24 = isAm
                        ? (displayHour == 12 ? 0 : displayHour)
                        : (displayHour == 12 ? 12 : displayHour + 12);
                    setState(() => _leaveTiming = TimeOfDay(hour: hour24, minute: selectedMinute));
                    Navigator.pop(ctx);
                  },
                  child: const Text('Done'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildSpinner({
    required String label,
    required int value,
    required int min,
    required int max,
    required ValueChanged<int> onChanged,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(label, style: const TextStyle(fontSize: 11, color: Colors.grey)),
        const SizedBox(height: 4),
        IconButton(
          icon: const Icon(Icons.keyboard_arrow_up),
          onPressed: () => onChanged(value >= max ? min : value + 1),
        ),
        Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            color: AppColors.primary600,
            borderRadius: BorderRadius.circular(12),
          ),
          alignment: Alignment.center,
          child: Text(
            value.toString().padLeft(2, '0'),
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
        IconButton(
          icon: const Icon(Icons.keyboard_arrow_down),
          onPressed: () => onChanged(value <= min ? max : value - 1),
        ),
      ],
    );
  }

  Widget _buildAmPmButton({
    required String label,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 48,
        height: 36,
        decoration: BoxDecoration(
          color: selected ? AppColors.primary600 : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: selected ? Colors.white : Colors.grey,
          ),
        ),
      ),
    );
  }

  bool get _isValid =>
      _selectedType != null &&
      _leaveTiming != null &&
      _reasonController.text.trim().isNotEmpty;

  Future<void> _handleReview() async {
    if (!_isValid) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill in all required fields.'),
          backgroundColor: Color(0xFFEF4444),
        ),
      );
      return;
    }

    final timingStr = _leaveTiming != null
        ? _leaveTiming!.format(context)
        : null;

    await ref.read(leaveSubmissionProvider.notifier).submit(
      type: _selectedType!,
      leaveDate: _leaveDate,
      leaveTiming: timingStr,
      reason: _reasonController.text.trim(),
      remarks: _remarksController.text.trim().isEmpty
          ? null
          : _remarksController.text.trim(),
    );

    if (!mounted) return;

    final submissionState = ref.read(leaveSubmissionProvider);
    if (submissionState.status == LeaveSubmissionStatus.success) {
      _showConfirmationDialog(submissionState.submittedRequest!);
    }
  }

  void _showConfirmationDialog(LeaveRequest request) {
    final dateFmt = DateFormat('d MMM yyyy');
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        backgroundColor: Colors.white,
        insetPadding: const EdgeInsets.symmetric(horizontal: 28),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 32, 24, 28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Clock icon in orange circle
              Container(
                width: 72,
                height: 72,
                decoration: const BoxDecoration(
                  color: Color(0xFFFFF1E6),
                  shape: BoxShape.circle,
                ),
                child: const Center(
                  child: Icon(
                    Icons.schedule_outlined,
                    size: 36,
                    color: Color(0xFFF97316),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              const Text(
                'Request sent for approval',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'PlayfairDisplay',
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF11141E),
                ),
              ),
              const SizedBox(height: 12),

              // Pending badge
              Container(
                padding:
                const EdgeInsets.symmetric(horizontal: 24, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFFEEF2FF),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: const Text(
                  'Pending Manager Approval',
                  style: TextStyle(
                    fontFamily: 'DMSans',
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF3D42C3),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Text(
                'Neha Singh will review your ${request.type.shortLabel} for ${dateFmt.format(request.leaveDate)}. You\'ll get a notification once it\'s decided.',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontFamily: 'DMSans',
                  fontSize: 16,
                  color: Color(0xFF64748B),
                  height: 1.5,
                ),
              ),
              ),
              const SizedBox(height: 60),
              // Fix Dummy Data(Attendance)
              // Clock
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(ctx).pop();
                    // Reset submission state and pop back to dashboard
                    ref.read(leaveSubmissionProvider.notifier).reset();
                    context.pop();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4F46E5),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: const Text(
                    'Ok, got it',
                    style: TextStyle(
                      fontFamily: 'DMSans',
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
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
    final submissionState = ref.watch(leaveSubmissionProvider);
    final isLoading = submissionState.status == LeaveSubmissionStatus.loading;

    final dateFmt = DateFormat('d MMM yyyy, EEEE');
    final timingLabel = _leaveTiming != null
        ? _leaveTiming!.format(context)
        : 'Select time';

    return Scaffold(
      backgroundColor: Colors.white,
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
          'Apply Leave',
          style: TextStyle(
            color: AppColors.darkTextPrimary,
            fontFamily: 'PlayfairDisplay',
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
                padding:
                const EdgeInsets.symmetric(horizontal: 20, vertical: 28),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ── Leave Type ─────────────────────────────────────────
                    _FieldLabel('LEAVE TYPE', required: true),
                    const SizedBox(height: 8),
                    _buildLeaveTypeDropdown(),

                    const SizedBox(height: 20),

                    // ── Leave Date ─────────────────────────────────────────
                    _FieldLabel('LEAVE DATE', required: true),
                    const SizedBox(height: 8),
                    _buildTappableField(
                      value: dateFmt.format(_leaveDate),
                      icon: Icons.calendar_month_outlined,
                      onTap: _pickDate,
                    ),

                    const SizedBox(height: 20),

                    // ── Leave Timing ───────────────────────────────────────
                    _FieldLabel('LEAVE TIMING', required: true),
                    const SizedBox(height: 8),
                    _buildTappableField(
                      value: timingLabel,
                      placeholder: 'Select time',
                      icon: Icons.schedule_outlined,
                      onTap: _pickTime,
                    ),

                    const SizedBox(height: 20),

                    // ── Reason ─────────────────────────────────────────────
                    _FieldLabel('REASON', required: true),
                    const SizedBox(height: 8),
                    _buildTextField(
                      controller: _reasonController,
                      hint: 'Add the reason here....',
                      minLines: 1,
                      maxLines: 3,
                    ),

                    const SizedBox(height: 20),

                    // ── Remarks ────────────────────────────────────────────
                    _FieldLabel('REMARKS', required: true),
                    const SizedBox(height: 8),
                    _buildTextField(
                      controller: _remarksController,
                      hint: 'Add a short note for your manager...',
                      minLines: 4,
                      maxLines: 6,
                    ),

                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),

            // ── Review Request button ──────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
              child: SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: isLoading ? null : _handleReview,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4F46E5),
                    disabledBackgroundColor: const Color(0xFF4F46E5),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: isLoading
                      ? const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor:
                      AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                      : const Text(
                    'Review Request',
                    style: TextStyle(
                      fontFamily: 'DMSans',
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
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

  // ── Private builder helpers ───────────────────────────────────────────────

  Widget _buildLeaveTypeDropdown() {
    return Container(
      height: 52,
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<LeaveType>(
          value: _selectedType,
          hint: const Text(
            'Select leave type',
            style: TextStyle(
              fontFamily: 'DMSans',
              fontSize: 14,
              color: Color(0xFF9CA3AF),
            ),
          ),
          isExpanded: true,
          icon: const Icon(Icons.keyboard_arrow_down_rounded,
              color: Color(0xFF6B7280)),
          style: const TextStyle(
            fontFamily: 'DMSans',
            fontSize: 14,
            color: Color(0xFF11141E),
          ),
          onChanged: (v) => setState(() => _selectedType = v),
          items: _leaveTypes
              .map(
                (t) => DropdownMenuItem(
              value: t,
              child: Text(t.label),
            ),
          )
              .toList(),
        ),
      ),
    );
  }

  Widget _buildTappableField({
    required String value,
    String? placeholder,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    final isEmpty = placeholder != null && value == placeholder;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 52,
        padding: const EdgeInsets.symmetric(horizontal: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: const Color(0xFFE5E7EB)),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                value,
                style: TextStyle(
                  fontFamily: 'DMSans',
                  fontSize: 14,
                  color: isEmpty
                      ? const Color(0xFF9CA3AF)
                      : const Color(0xFF11141E),
                ),
              ),
            ),
            Icon(icon, size: 20, color: const Color(0xFF6B7280)),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required int minLines,
    required int maxLines,
  }) {
    return TextField(
      controller: controller,
      minLines: minLines,
      maxLines: maxLines,
      onChanged: (_) => setState(() {}),
      style: const TextStyle(
        fontFamily: 'DMSans',
        fontSize: 14,
        color: Color(0xFF11141E),
      ),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(
          fontFamily: 'DMSans',
          fontSize: 14,
          color: Color(0xFF9CA3AF),
        ),
        filled: true,
        fillColor: Colors.white,
        contentPadding:
        const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xFF4F46E5)),
        ),
      ),
    );
  }
}

/// Uppercase field label with an optional red asterisk.
class _FieldLabel extends StatelessWidget {
  final String text;
  final bool required;

  const _FieldLabel(this.text, {this.required = false});

  @override
  Widget build(BuildContext context) {
    return RichText(
      text: TextSpan(
        children: [
          TextSpan(
            text: text,
            style: const TextStyle(
              fontFamily: 'DMSans',
              fontSize: 11,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.8,
              color: Color(0xFF6B7280),
            ),
          ),
          if (required)
            const TextSpan(
              text: ' *',
              style: TextStyle(
                fontFamily: 'DMSans',
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: Color(0xFFEF4444),
              ),
            ),
        ],
      ),
    );
  }
}