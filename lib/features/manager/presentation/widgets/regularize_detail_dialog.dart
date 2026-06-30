import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';

/// Data shown inside the "Regularize Detail" pop-up.
class RegularizeDetail {
  final String requestType;
  final String actualCheckInTime;
  final String remarks;

  const RegularizeDetail({
    required this.requestType,
    required this.actualCheckInTime,
    required this.remarks,
  });
}

/// Modal pop-up shown from a regularization request card, letting the
/// approver review the request details and Approve / Reject in place.
///
/// Usage:
/// ```dart
/// showRegularizeDetailDialog(
///   context: context,
///   detail: const RegularizeDetail(
///     requestType: 'Missed check-in',
///     actualCheckInTime: '10:08:00 AM',
///     remarks: 'Had to rush to client site for urgent requirement '
///         'discussion before EOD. Left office premises at 6:20 PM.',
///   ),
///   onApprove: () {},
///   onReject: () {},
/// );
/// ```
Future<void> showRegularizeDetailDialog({
  required BuildContext context,
  required RegularizeDetail detail,
  VoidCallback? onApprove,
  VoidCallback? onReject,
}) {
  return showDialog(
    context: context,
    barrierColor: const Color(0x99000000),
    builder: (_) => RegularizeDetailDialog(
      detail: detail,
      onApprove: onApprove,
      onReject: onReject,
    ),
  );
}

class RegularizeDetailDialog extends StatelessWidget {
  final RegularizeDetail detail;
  final VoidCallback? onApprove;
  final VoidCallback? onReject;

  const RegularizeDetailDialog({
    Key? key,
    required this.detail,
    this.onApprove,
    this.onReject,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Icon badge ───────────────────────────────────────────────
            Center(
              child: Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: const Color(0xFFEEF2FF),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.priority_high_rounded,
                  color: AppColors.primary700,
                  size: 28,
                ),
              ),
            ),
            const SizedBox(height: 14),

            // ── Title ────────────────────────────────────────────────────
            Center(
              child: Text(
                'Regularize Detail',
                style: AppTypography.heading2?.copyWith(
                  color: const Color(0xFF111827),
                  fontFamily: 'PlayfairDisplay',
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(height: 20),

            // ── Fields ───────────────────────────────────────────────────
            _buildField(label: 'Request type', value: detail.requestType),
            const SizedBox(height: 14),
            _buildField(
              label: 'Actual check-in time',
              value: detail.actualCheckInTime,
            ),
            const SizedBox(height: 14),
            _buildField(
              label: 'Remarks',
              value: detail.remarks,
              minHeight: 76,
            ),
            const SizedBox(height: 22),

            // ── Actions ──────────────────────────────────────────────────
            Row(
              children: [
                Expanded(
                  child: _actionButton(
                    label: 'Approve',
                    icon: Icons.check_rounded,
                    textColor: const Color(0xFF059669),
                    bgColor: const Color(0xFFD1FAE5),
                    onTap: () {
                      Navigator.of(context).pop();
                      onApprove?.call();
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _actionButton(
                    label: 'Reject',
                    icon: Icons.close_rounded,
                    textColor: const Color(0xFFDC2626),
                    bgColor: const Color(0xFFFEE2E2),
                    onTap: () {
                      Navigator.of(context).pop();
                      onReject?.call();
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ── Sub-widgets ─────────────────────────────────────────────────────────

  Widget _buildField({
    required String label,
    required String value,
    double? minHeight,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLabel(label),
        const SizedBox(height: 6),
        Container(
          width: double.infinity,
          constraints: BoxConstraints(minHeight: minHeight ?? 0),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: const Color(0xFFF9FAFB),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: const Color(0xFFE5E7EB)),
          ),
          child: Text(
            value,
            style: AppTypography.bodySmall?.copyWith(
              color: const Color(0xFF111827),
              fontSize: 13,
              height: 1.4,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLabel(String label) {
    return RichText(
      text: TextSpan(
        style: AppTypography.caption?.copyWith(
          color: const Color(0xFF374151),
          fontWeight: FontWeight.w600,
          fontSize: 13,
        ),
        children: [
          TextSpan(text: label),
          const TextSpan(
            text: ' *',
            style: TextStyle(color: Color(0xFFDC2626)),
          ),
        ],
      ),
    );
  }

  Widget _actionButton({
    required String label,
    required IconData icon,
    required Color textColor,
    required Color bgColor,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 13),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 16, color: textColor),
            const SizedBox(width: 6),
            Text(
              label,
              style: AppTypography.bodyMedium?.copyWith(
                color: textColor,
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
}