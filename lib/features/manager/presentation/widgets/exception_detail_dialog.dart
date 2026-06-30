import 'package:flutter/material.dart';

/// Modal dialog shown when the user taps "Detail" on an attendance
/// exception request card. Matches the "Exception Detail" mock.
class ExceptionDetailDialog extends StatelessWidget {
  final String exceptionReason;
  final String remarks;
  final String locationLabel;
  final String coordinatesLabel;
  final VoidCallback? onApprove;
  final VoidCallback? onReject;

  const ExceptionDetailDialog({
    Key? key,
    required this.exceptionReason,
    required this.remarks,
    required this.locationLabel,
    required this.coordinatesLabel,
    this.onApprove,
    this.onReject,
  }) : super(key: key);

  /// Convenience helper to show the dialog.
  static Future<void> show(
      BuildContext context, {
        required String exceptionReason,
        required String remarks,
        required String locationLabel,
        required String coordinatesLabel,
        VoidCallback? onApprove,
        VoidCallback? onReject,
      }) {
    return showDialog(
      context: context,
      barrierColor: Colors.black54,
      builder: (_) => ExceptionDetailDialog(
        exceptionReason: exceptionReason,
        remarks: remarks,
        locationLabel: locationLabel,
        coordinatesLabel: coordinatesLabel,
        onApprove: onApprove,
        onReject: onReject,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.white,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Close button
            Align(
              alignment: Alignment.centerRight,
              child: InkWell(
                onTap: () => Navigator.of(context).pop(),
                child: const Icon(Icons.close, size: 22, color: Colors.black87),
              ),
            ),
            const SizedBox(height: 4),

            // Icon
            Center(
              child: Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: const Color(0xFFE7E5FF),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.priority_high_rounded,
                  color: Color(0xFF4F3DF5),
                  size: 30,
                ),
              ),
            ),
            const SizedBox(height: 12),

            // Title
            const Center(
              child: Text(
                'Exception Detail',
                style: TextStyle(
                  fontFamily: 'Georgia',
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Exception Reason
            _FieldLabel('Exception Reason'),
            const SizedBox(height: 6),
            _ReadonlyBox(text: exceptionReason),
            const SizedBox(height: 16),

            // Remarks
            _FieldLabel('Remarks'),
            const SizedBox(height: 6),
            _ReadonlyBox(text: remarks, minHeight: 72),
            const SizedBox(height: 16),

            // Location card
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                border: Border.all(color: const Color(0xFFE0E0E0)),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: const BoxDecoration(
                      color: Color(0xFFEDEBFF),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.location_on,
                      color: Color(0xFF4F3DF5),
                      size: 18,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          locationLabel,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          coordinatesLabel,
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.black54,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: const Color(0xFFE3F8EC),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: const [
                                  Icon(Icons.check_circle,
                                      size: 13, color: Color(0xFF1FA45A)),
                                  SizedBox(width: 4),
                                  Text(
                                    'Location captured',
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: Color(0xFF1FA45A),
                                      fontWeight: FontWeight.w600,
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
            ),
            const SizedBox(height: 20),

            // Action buttons
            if (onApprove != null || onReject != null)
              Row(
                children: [
                  Expanded(
                    child: _ActionButton(
                      label: 'Approve',
                      icon: Icons.check,
                      backgroundColor: const Color(0xFFD7F5E4),
                      foregroundColor: const Color(0xFF1FA45A),
                      onTap: () {
                        Navigator.of(context).pop();
                        onApprove?.call();
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _ActionButton(
                      label: 'Reject',
                      icon: Icons.close,
                      backgroundColor: const Color(0xFFFCE0DE),
                      foregroundColor: const Color(0xFFE0473E),
                      onTap: () {
                        Navigator.of(context).pop();
                        onReject?.call();
                      },
                    ),
                  ),
                ],
              )
            else
              SizedBox(
                width: double.infinity,
                child: Material(
                  color: const Color(0xFF4F3DF5),
                  borderRadius: BorderRadius.circular(12),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(12),
                    onTap: () => Navigator.of(context).pop(),
                    child: const Padding(
                      padding: EdgeInsets.symmetric(vertical: 14),
                      child: Center(
                        child: Text(
                          'Back to approval',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            fontSize: 15,
                          ),
                        ),
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
}

class _FieldLabel extends StatelessWidget {
  final String text;
  const _FieldLabel(this.text, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return RichText(
      text: TextSpan(
        style: const TextStyle(
          fontSize: 13,
          color: Colors.black87,
          fontWeight: FontWeight.w500,
        ),
        children: [
          TextSpan(text: text),
          const TextSpan(
            text: ' *',
            style: TextStyle(color: Color(0xFFE0473E)),
          ),
        ],
      ),
    );
  }
}

class _ReadonlyBox extends StatelessWidget {
  final String text;
  final double minHeight;

  const _ReadonlyBox({Key? key, required this.text, this.minHeight = 44})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      constraints: BoxConstraints(minHeight: minHeight),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xFFE0E0E0)),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        text,
        style: const TextStyle(fontSize: 13.5, height: 1.4),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color backgroundColor;
  final Color foregroundColor;
  final VoidCallback onTap;

  const _ActionButton({
    Key? key,
    required this.label,
    required this.icon,
    required this.backgroundColor,
    required this.foregroundColor,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Material(
      color: backgroundColor,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 16, color: foregroundColor),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  color: foregroundColor,
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}