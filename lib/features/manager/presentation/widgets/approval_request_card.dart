import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';

enum ApprovalCardStatus { pending, approved, rejected }

/// A single request card used across Attendance Exception, Regularization,
/// and Leave Approvals screens.
///
/// [metaLine1] — first icon row (e.g. "Outside geofence — WFH")
/// [metaLine2] — second icon row (e.g. "Working from home — plumber visit")
/// [slaLabel]  — orange timer badge shown top-right when [status] == pending
/// [status]    — drives whether action buttons or a status chip is shown
class ApprovalRequestCard extends StatelessWidget {
  final String employeeName;
  final String empCode;
  final String date;
  final String metaLine1;
  final String metaLine2;
  final String? slaLabel;
  final ApprovalCardStatus status;
  final VoidCallback? onApprove;
  final VoidCallback? onReject;
  final VoidCallback? onDetail;

  // icon for metaLine1 (defaults to location pin for Attendance Exception)
  final IconData line1Icon;
  // icon for metaLine2 (defaults to chat bubble)
  final IconData line2Icon;

  const ApprovalRequestCard({
    Key? key,
    required this.employeeName,
    required this.empCode,
    required this.date,
    required this.metaLine1,
    required this.metaLine2,
    this.slaLabel,
    this.status = ApprovalCardStatus.pending,
    this.onApprove,
    this.onReject,
    this.onDetail,
    this.line1Icon = Icons.location_on_outlined,
    this.line2Icon = Icons.chat_bubble_outline_rounded,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFF3F4F6)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0A000000),
            blurRadius: 6,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Top row: name + SLA badge / status chip ──────────────────────
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                employeeName,
                style: AppTypography.bodyMedium?.copyWith(
                  color: const Color(0xFF111827),
                  fontWeight: FontWeight.w700,
                  fontSize: 15,
                ),
              ),
              if (status == ApprovalCardStatus.pending && slaLabel != null)
                _buildSlaChip(slaLabel!)
              else if (status != ApprovalCardStatus.pending)
                _buildStatusChip(status),
            ],
          ),
          const SizedBox(height: 2),

          // ── Emp code + date ───────────────────────────────────────────────
          Text(
            '$empCode • $date',
            style: AppTypography.caption?.copyWith(
              color: const Color(0xFF9CA3AF),
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 10),

          // ── Meta line 1 ───────────────────────────────────────────────────
          _buildMetaRow(line1Icon, metaLine1),
          const SizedBox(height: 6),

          // ── Meta line 2 ───────────────────────────────────────────────────
          _buildMetaRow(line2Icon, metaLine2),
          const SizedBox(height: 14),

          // ── Action buttons ────────────────────────────────────────────────
          if (status != ApprovalCardStatus.pending)
            _buildDetailOnlyRow()
          else
            _buildActionRow(),
        ],
      ),
    );
  }

  // ── Sub-widgets ───────────────────────────────────────────────────────────

  Widget _buildSlaChip(String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(Icons.access_time_rounded,
            size: 13, color: Color(0xFFD97706)),
        const SizedBox(width: 3),
        Text(
          label,
          style: AppTypography.caption?.copyWith(
            color: const Color(0xFFD97706),
            fontWeight: FontWeight.w600,
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildStatusChip(ApprovalCardStatus s) {
    final isApproved = s == ApprovalCardStatus.approved;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: isApproved
            ? const Color(0xFFD1FAE5)
            : const Color(0xFFFEE2E2),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        isApproved ? 'APPROVED' : 'REJECTED',
        style: AppTypography.caption?.copyWith(
          color: isApproved
              ? const Color(0xFF059669)
              : const Color(0xFFDC2626),
          fontWeight: FontWeight.w600,
          fontSize: 10,
          letterSpacing: 0.4,
        ),
      ),
    );
  }

  Widget _buildMetaRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 14, color: const Color(0xFF9CA3AF)),
        const SizedBox(width: 6),
        Flexible(
          child: Text(
            text,
            style: AppTypography.caption?.copyWith(
              color: const Color(0xFF6B7280),
              fontSize: 12,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildActionRow() {
    return Row(
      children: [
        _actionButton(
          label: 'Approve',
          icon: Icons.check_rounded,
          textColor: const Color(0xFF059669),
          bgColor: const Color(0xFFD1FAE5),
          onTap: onApprove,
        ),
        const SizedBox(width: 8),
        _actionButton(
          label: 'Reject',
          icon: Icons.close_rounded,
          textColor: const Color(0xFFDC2626),
          bgColor: const Color(0xFFFEE2E2),
          onTap: onReject,
        ),
        const SizedBox(width: 8),
        _actionButton(
          label: 'Detail',
          icon: Icons.remove_red_eye_outlined,
          textColor: AppColors.primary700,
          bgColor: const Color(0xFFEEF2FF),
          onTap: onDetail,
        ),
      ],
    );
  }

  Widget _buildDetailOnlyRow() {
    return SizedBox(
      width: double.infinity,
      child: _actionButton(
        label: 'Detail',
        icon: Icons.remove_red_eye_outlined,
        textColor: AppColors.primary700,
        bgColor: const Color(0xFFEEF2FF),
        onTap: onDetail,
        expand: true,
      ),
    );
  }

  Widget _actionButton({
    required String label,
    required IconData icon,
    required Color textColor,
    required Color bgColor,
    VoidCallback? onTap,
    bool expand = false,
  }) {
    final inner = GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 9),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 14, color: textColor),
            const SizedBox(width: 4),
            Text(
              label,
              style: AppTypography.caption?.copyWith(
                color: textColor,
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );

    return expand ? inner : Expanded(child: inner);
  }
}