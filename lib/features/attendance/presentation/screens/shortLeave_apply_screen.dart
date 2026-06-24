import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_colors.dart';

/// Screen for applying for early exit / short leave when an employee
/// has not met the minimum required hours for the day at check-out.
class ShortLeaveApplyScreen extends StatefulWidget {
  final String checkInTime;
  final String checkOutTime;
  final Duration totalHours;
  final Duration shortfall;

  const ShortLeaveApplyScreen({
    super.key,
    required this.checkInTime,
    required this.checkOutTime,
    required this.totalHours,
    required this.shortfall,
  });

  @override
  State<ShortLeaveApplyScreen> createState() => _ShortLeaveApplyScreenState();
}

class _ShortLeaveApplyScreenState extends State<ShortLeaveApplyScreen> {
  final TextEditingController _reasonController = TextEditingController();
  final TextEditingController _remarksController = TextEditingController();
  bool _isSubmitting = false;

  @override
  void dispose() {
    _reasonController.dispose();
    _remarksController.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    if (_reasonController.text.trim().isEmpty) {

      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      // TODO: wire up to a short-leave/early-exit submission provider
      // e.g. ref.read(shortLeaveControllerProvider.notifier).submit(
      //   reason: _reasonController.text.trim(),
      //   remarks: _remarksController.text.trim(),
      // );
      await Future.delayed(const Duration(seconds: 1));

      if (!mounted) return;

      /*ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Submitted for manager approval'),
          backgroundColor: AppColors.success,
          duration: Duration(seconds: 2),
        ),
      );*/

      context.pushReplacementNamed(
        'short-leave-pending',
        extra: {
          'checkInTime': widget.checkInTime,
          'checkOutTime': widget.checkOutTime,
          'totalHours': widget.totalHours,
          'shortfall': widget.shortfall,
          'managerName': 'Jai Prakash', // Mocked for now
          'requestSentTime': DateFormat('h:mm a').format(DateTime.now()),
        },
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Submission failed: ${e.toString()}'),
            backgroundColor: AppColors.error,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
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
          'Check out',
          style: TextStyle(
            color: AppColors.darkTextPrimary,
            fontFamily: 'LibSerif',
            fontWeight: FontWeight.w400,
            fontSize: 24,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Icon badge
              Center(
                child: Container(
                  width: 88,
                  height: 88,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Color(0xFFFCE8D8),
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.meeting_room_outlined,
                      size: 40,
                      color: Color(0xFFD2521C),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Title
              const Text(
                'Apply Early Exit / Short Leave',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 19,
                  fontWeight: FontWeight.w700,
                  fontFamily: 'PlayfairDisplay',
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 8),

              // Subtitle
              const Text(
                'Request manager approval for missing\n hours',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                  fontFamily: 'Inter',
                  color: Color(0xFF6B7280),
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 32),

              // Reason for leave label
              const Text(
                'Reason for leave',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  fontFamily: 'DMSans',
                  color: const Color(0xFF3A4255),
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _reasonController,
                style: const TextStyle(
                  fontSize: 14,
                  fontFamily: 'DMSans',
                  color: Colors.black,
                ),
                decoration: InputDecoration(
                  hintText: 'Add the reason for leave.....',
                  hintStyle: const TextStyle(
                    fontSize: 14,
                    fontFamily: 'DMSans',
                    color: Color(0xFF6B7280),
                    fontWeight: FontWeight.w400,
                  ),
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 14,
                  ),
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
                    borderSide: const BorderSide(color: Color(0xFF3B5BDB)),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Additional remarks label
              const Text(
                'Additional Remarks (optional)',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  fontFamily: 'DMSans',
                  color: const Color(0xFF3A4255),
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _remarksController,
                minLines: 4,
                maxLines: 6,
                style: const TextStyle(
                  fontSize: 14,
                  fontFamily: 'DMSans',
                  color: Colors.black,
                ),
                decoration: InputDecoration(
                  hintText: 'Add any notes for your manager...',
                  hintStyle: const TextStyle(
                    fontSize: 14,
                    fontFamily: 'DMSans',
                    color: Color(0xFF9CA3AF),
                    fontWeight: FontWeight.w400,
                  ),
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: const EdgeInsets.all(14),
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
                    borderSide: const BorderSide(color: Color(0xFF3B5BDB)),
                  ),
                ),
              ),
              const SizedBox(height: 32),

              // Submit button
              SizedBox(
                height: 50,
                child: ElevatedButton(
                  onPressed: _isSubmitting ? null : _handleSubmit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF3B5BDB),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: _isSubmitting
                      ? const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        Colors.white,
                      ),
                    ),
                  )
                      : const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.check_rounded,
                          color: Colors.white, size: 18),
                      SizedBox(width: 8),
                      Text(
                        'Submit for approval',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          fontFamily: 'DMSans',
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 14),

              // Cancel
              Center(
                child: TextButton(
                  onPressed: _isSubmitting ? null : () => context.pop(),
                  child: const Text(
                    'Cancel',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      fontFamily: 'DMSans',
                      color: Color(0xFF3B5BDB),
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