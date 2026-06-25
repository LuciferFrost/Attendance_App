import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/routing/app_routes.dart';
import '../../domain/entities/attendance_record.dart';
import '../providers/attendance_history_providers.dart';

/// Correction request types an employee can raise against a day's
/// attendance.
enum CorrectionRequestType {
  missedCheckIn,
  missedCheckOut,
  wrongTime,
  fullDayAbsence,
}

extension CorrectionRequestTypeX on CorrectionRequestType {
  String get label {
    switch (this) {
      case CorrectionRequestType.missedCheckIn:
        return 'Missed Check-In';
      case CorrectionRequestType.missedCheckOut:
        return 'Missed Check-Out';
      case CorrectionRequestType.wrongTime:
        return 'Incorrect Check-In/Out Time';
      case CorrectionRequestType.fullDayAbsence:
        return 'Full Day Marked Absent';
    }
  }
}

/// "Correction" screen — lets the employee raise an attendance
/// correction request for a given day, then shows the "Request
/// Submitted" confirmation once it's sent to their manager.
class AttendanceCorrectionScreen extends ConsumerStatefulWidget {
  final AttendanceRecord record;

  /// Whether this screen was pushed directly from the attendance list
  /// (true) or via the Attendance Details screen (false). Used to pop the
  /// correct number of routes back to the list after a successful submit.
  final bool openedFromList;

  const AttendanceCorrectionScreen({
    super.key,
    required this.record,
    this.openedFromList = false,
  });

  @override
  ConsumerState<AttendanceCorrectionScreen> createState() =>
      _AttendanceCorrectionScreenState();
}

class _AttendanceCorrectionScreenState
    extends ConsumerState<AttendanceCorrectionScreen> {
  CorrectionRequestType? _requestType;
  late TextEditingController _dateController;
  late TextEditingController _timeController;
  final TextEditingController _reasonController = TextEditingController();
  bool _isSubmitting = false;

  // Mocked for now — swap for the signed-in employee's actual manager.
  static const String _managerName = 'Priya Sharma';

  @override
  void initState() {
    super.initState();
    _dateController = TextEditingController(
      text: DateFormat('EEE, dd MMM').format(widget.record.date),
    );
    _timeController = TextEditingController();
  }

  @override
  void dispose() {
    _dateController.dispose();
    _timeController.dispose();
    _reasonController.dispose();
    super.dispose();
  }

  bool get _needsTimeField =>
      _requestType == CorrectionRequestType.missedCheckIn ||
      _requestType == CorrectionRequestType.missedCheckOut ||
      _requestType == CorrectionRequestType.wrongTime;

  String get _timeFieldLabel {
    switch (_requestType) {
      case CorrectionRequestType.missedCheckIn:
        return 'Actual Check-In Time *';
      case CorrectionRequestType.missedCheckOut:
        return 'Actual Check-Out Time *';
      case CorrectionRequestType.wrongTime:
        return 'Corrected Time *';
      default:
        return 'Time *';
    }
  }

  String get _reasonFieldLabel {
    switch (_requestType) {
      case CorrectionRequestType.missedCheckIn:
        return 'Reason For Missed Check-In *';
      case CorrectionRequestType.missedCheckOut:
        return 'Reason For Missed Check-Out *';
      case CorrectionRequestType.wrongTime:
        return 'Reason For Correction *';
      case CorrectionRequestType.fullDayAbsence:
        return 'Reason For Absence *';
      default:
        return 'Reason *';
    }
  }

  Future<void> _pickTime() async {
    final now = TimeOfDay.now();
    int displayHour = now.hour % 12 == 0 ? 12 : now.hour % 12;
    int selectedMinute = now.minute;
    int selectedSecond = 0;
    bool isAm = now.hour < 12;

    await showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setInnerState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              title: const Text(
                'SELECT TIME',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, letterSpacing: 1.2),
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
                    final hour24 = isAm
                        ? (displayHour == 12 ? 0 : displayHour)
                        : (displayHour == 12 ? 12 : displayHour + 12);
                    final formatted = DateFormat('hh:mm a').format(
                      DateTime(2024, 1, 1, hour24, selectedMinute),
                    );
                    setState(() => _timeController.text = formatted);
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
            color: const Color(0xFF3B5BDB),
            borderRadius: BorderRadius.circular(12),
          ),
          alignment: Alignment.center,
          child: Text(
            value.toString().padLeft(2, '0'),
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
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
          color: selected ? const Color(0xFF3B5BDB) : Colors.transparent,
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

  void _submit() {
    if (_requestType == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a request type'),
          backgroundColor: Color(0xFFEF4444),
        ),
      );
      return;
    }
    if (_needsTimeField && _timeController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please enter the ${_timeFieldLabel.replaceAll(' *', '').toLowerCase()}'),
          backgroundColor: const Color(0xFFEF4444),
        ),
      );
      return;
    }
    if (_reasonController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a reason'),
          backgroundColor: Color(0xFFEF4444),
        ),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    // TODO: wire up to a real correction-request submission provider once
    // the backend endpoint is available.
    Future.delayed(const Duration(milliseconds: 600), () {
      if (!mounted) return;
      setState(() => _isSubmitting = false);
      ref.read(attendanceHistoryProvider.notifier).markPendingApproval(widget.record.id);
      _showSubmittedModal();
    });
  }

  void _showSubmittedModal() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => _SubmittedDialog(
        requestType: _requestType!,
        managerName: _managerName,
        onDone: () {
          Navigator.of(dialogContext).pop();
          // Pop back to the attendance list. When this screen was opened
          // via the Detail screen there are two routes to dismiss; when
          // opened directly from the list (e.g. for an absent day) there
          // is only one.
          context.pop();
          if (!widget.openedFromList) {
            context.pop();
          }
        },
      ),
    );
  }

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
          'Correction',
          style: TextStyle(
            color: AppColors.darkTextPrimary,
            fontFamily: 'LibSerif',
            fontWeight: FontWeight.w400,
            fontSize: 24,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildInfoBanner(),
            const SizedBox(height: 20),
            _buildRequestTypeField(),
            const SizedBox(height: 16),
            _buildLabeledField(
              label: 'Date *',
              child: TextField(
                controller: _dateController,
                readOnly: true,
                style: const TextStyle(
                  fontFamily: 'DMSans',
                  fontSize: 14,
                  color: Colors.black,
                ),
                decoration: _fieldDecoration(),
              ),
            ),
            if (_needsTimeField) ...[
              const SizedBox(height: 16),
              _buildLabeledField(
                label: _timeFieldLabel,
                child: TextField(
                  controller: _timeController,
                  readOnly: true,
                  onTap: _pickTime,
                  style: const TextStyle(
                    fontFamily: 'DMSans',
                    fontSize: 14,
                    color: Colors.black,
                  ),
                  decoration: _fieldDecoration(
                    hintText: 'Select time',
                    suffixIcon: const Icon(
                      Icons.access_time_rounded,
                      size: 18,
                      color: Color(0xFF6B7280),
                    ),
                  ),
                ),
              ),
            ],
            const SizedBox(height: 16),
            _buildLabeledField(
              label: _reasonFieldLabel,
              child: TextField(
                controller: _reasonController,
                minLines: 3,
                maxLines: 5,
                enabled: !_isSubmitting,
                style: const TextStyle(
                  fontFamily: 'DMSans',
                  fontSize: 14,
                  color: Colors.black,
                ),
                decoration: _fieldDecoration(
                  hintText: 'Describe what happened...',
                ),
              ),
            ),
            const SizedBox(height: 250),
            _buildSubmitButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoBanner() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF9E7),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFF5E0A3)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.info_rounded, color: Color(0xFFD2821C), size: 18),
          const SizedBox(width: 10),
          const Expanded(
            child: Text(
              'Use this form if you forgot to check in or check out. '
              'Your manager will review and approve/reject the correction.',
              style: TextStyle(
                fontFamily: 'DMSans',
                fontSize: 14,
                fontWeight: FontWeight.w400,
                color: Color(0xFF334155),
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRequestTypeField() {
    return _buildLabeledField(
      label: 'Request Type *',
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: const Color(0xFFE5E7EB)),
          color: Colors.white,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<CorrectionRequestType>(
            value: _requestType,
            isExpanded: true,
            hint: const Text(
              'Select request type...',
              style: TextStyle(
                fontFamily: 'DMSans',
                fontSize: 14,
                color: Color(0xFF1E293B),
                fontWeight: FontWeight.w400
              ),
            ),
            icon: const Icon(Icons.keyboard_arrow_down_rounded, color: Color(0xFF6B7280)),
            style: const TextStyle(
              fontFamily: 'DMSans',
              fontSize: 14,
              color: Colors.black,
            ),
            onChanged: (value) {
              setState(() {
                _requestType = value;
                _timeController.clear();
              });
            },
            items: CorrectionRequestType.values
                .map((type) => DropdownMenuItem(
                      value: type,
                      child: Text(type.label),
                    ))
                .toList(),
          ),
        ),
      ),
    );
  }

  Widget _buildLabeledField({required String label, required Widget child}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label.toUpperCase(),
          style: const TextStyle(
            fontFamily: 'DMSans',
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: Color(0xFF475569),
            letterSpacing: 0.4,
          ),
        ),
        const SizedBox(height: 8),
        child,
      ],
    );
  }

  InputDecoration _fieldDecoration({String? hintText, Widget? suffixIcon}) {
    return InputDecoration(
      hintText: hintText,
      hintStyle: const TextStyle(
        fontFamily: 'DMSans',
        fontSize: 14,
        color: Color(0xFF1E293B),
        fontWeight: FontWeight.w400,
      ),
      suffixIcon: suffixIcon,
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Color(0xFF3B82F6)),
      ),
    );
  }

  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: _isSubmitting ? null : _submit,
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
          _isSubmitting ? 'Submitting...' : 'Submit Correction Request',
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
}

/// "Request Submitted" confirmation — shown as a modal over the
/// Correction screen, matching the "request submit" Figma frame.
class _SubmittedDialog extends StatelessWidget {
  final CorrectionRequestType requestType;
  final String managerName;
  final VoidCallback onDone;

  const _SubmittedDialog({
    required this.requestType,
    required this.managerName,
    required this.onDone,
  });

  @override
  Widget build(BuildContext context) {
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
          padding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 72,
                height: 72,
                decoration: const BoxDecoration(
                  color: Color(0xFFFFF3E0),
                  shape: BoxShape.circle,
                ),
                child:  Center(
                  child: Image.asset('assets/images/correction_subbed.png', height: 36,width: 36),
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Request Submitted',
                style: TextStyle(
                  fontFamily: 'PlayfairDisplay',
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF11141E),
                ),
              ),
              const SizedBox(height: 14),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFFFFF),
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(color: const Color(0xFFE5E7EB)),
                ),
                child: Text(
                  'Correction Type: ${requestType.label}',
                  style: const TextStyle(
                    fontFamily: 'DMSans',
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF374151),
                  ),
                ),
              ),
              const SizedBox(height: 14),
              const Text(

                'Your attendance correction request has been sent to your '
                'manager for review and approval.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'DMSans',
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                  color: Color(0xFF6B7280),
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: onDone,
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
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      fontFamily: 'DMSans',
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),

            ],
          ),
        ),
      ),
    );
  }
}
