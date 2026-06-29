import 'package:flutter/material.dart';
import '../../../../core/theme/app_typography.dart';

/// Yellow SLA deadline warning banner.
class SlaWarningBanner extends StatelessWidget {
  final String message;

  const SlaWarningBanner({
    Key? key,
    this.message =
        '2 requests approaching SLA deadline. Act within 2 hours to avoid escalation to HR.',
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFBEB),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFFDE68A)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.warning_amber_rounded,
              color: Color(0xFFD97706), size: 18),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: AppTypography.bodySmall?.copyWith(
                color: const Color(0xFF92400E),
                height: 1.4,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
