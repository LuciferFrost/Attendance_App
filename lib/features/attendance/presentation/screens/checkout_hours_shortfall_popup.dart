import 'package:flutter/material.dart';

/// Dialog widget shown when user attempts checkout without having met
/// the minimum required working hours for the day.
/// Call [showHoursShortfallDialog] to display this dialog.
class HoursShortfallDialog extends StatelessWidget {
  final Duration durationSoFar;
  final Duration requiredDuration;
  final VoidCallback onApplyShortLeave;
  final VoidCallback onBackToHome;

  const HoursShortfallDialog({
    super.key,
    required this.durationSoFar,
    required this.requiredDuration,
    required this.onApplyShortLeave,
    required this.onBackToHome,
  });

  static String _formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    return '${hours}h ${minutes.toString().padLeft(2, '0')}m';
  }

  @override
  Widget build(BuildContext context) {
    final shortfall = requiredDuration - durationSoFar;
    final formattedSoFar = _formatDuration(durationSoFar);
    final formattedRequired = _formatDuration(requiredDuration);
    final formattedShortfall = _formatDuration(
      shortfall.isNegative ? Duration.zero : shortfall,
    );

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      insetPadding: const EdgeInsets.symmetric(horizontal: 20),
      child: SingleChildScrollView(
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
                // Heading
                const Text(
                  'Hours Shortfall',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    fontFamily: 'PlayfairDisplay',
                    color: const Color(0xFF111827),
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 10),

                // Description
                const Text(
                  'You have not met the minimum required hours for today. '
                      'You will need to make up this time.',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                    fontFamily: 'DMSans',
                    color: Color(0xFF6B7280),
                    height: 1.5,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),

                // Stats card
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF9E6),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: const Color(0xFFFEF3C7),
                      width: 1,
                    ),
                  ),
                  child: Column(
                    children: [
                      _buildStatRow(
                        label: 'Duration so far',
                        value: formattedSoFar,
                        valueColor: const Color(0xFF846E3A),
                        showDivider: true,
                      ),
                      _buildStatRow(
                        label: 'Required',
                        value: formattedRequired,
                        valueColor: const Color(0xFF846E3A),

                        showDivider: true,
                      ),
                      _buildStatRow(
                        label: 'Shortfall',
                        value: '-$formattedShortfall',
                        valueColor: const Color(0xFFEF4444),
                        showDivider: false,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Primary Button - Apply short leave
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: onApplyShortLeave,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF3B5BDB),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text(
                      'Apply short leave',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        fontFamily: 'DMSans',
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 10),

                // Secondary Button - Back to home
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: TextButton(
                    onPressed: onBackToHome,
                    style: TextButton.styleFrom(
                      foregroundColor: const Color(0xFF3B5BDB),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text(
                      'Back to home',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
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
      ),
    );
  }

  Widget _buildStatRow({
    required String label,
    required String value,
    required Color valueColor,
    required bool showDivider,
  }) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  fontFamily: 'DMSans',
                  color: Color(0xFF856404),
                ),
              ),
              Text(
                value,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  fontFamily: 'DMSans',
                  color: valueColor,
                ),
              ),
            ],
          ),
        ),
        if (showDivider)
          Divider(
            height: 1,
            thickness: 1,
            color: const Color(0xFFF5E0A3).withOpacity(0.6),
          ),
      ],
    );
  }
}

/// Helper function to show the hours shortfall dialog
Future<void> showHoursShortfallDialog({
  required BuildContext context,
  required Duration durationSoFar,
  required Duration requiredDuration,
  required VoidCallback onApplyShortLeave,
  required VoidCallback onBackToHome,
}) {
  return showDialog(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext dialogContext) {
      return HoursShortfallDialog(
        durationSoFar: durationSoFar,
        requiredDuration: requiredDuration,
        onApplyShortLeave: onApplyShortLeave,
        onBackToHome: onBackToHome,
      );
    },
  );
}