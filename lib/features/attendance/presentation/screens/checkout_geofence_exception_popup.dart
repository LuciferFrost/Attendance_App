import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';

/// Dialog widget shown when user attempts checkout outside the geofence.
/// Call [showCheckOutGeofenceExceptionDialog] to display this dialog.
class CheckOutGeofenceExceptionDialog extends StatelessWidget {
  final double distanceInMeters;
  final VoidCallback onSubmitException;
  final VoidCallback onRetryLocation;

  const CheckOutGeofenceExceptionDialog({
    super.key,
    required this.distanceInMeters,
    required this.onSubmitException,
    required this.onRetryLocation,
  });

  @override
  Widget build(BuildContext context) {
    final distanceKm = (distanceInMeters / 1000).toStringAsFixed(1);

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
                // Status Icon
                Container(
                  width: 80,
                  height: 80,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Color(0xFFFEE2E2),
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.location_on_rounded,
                      size: 40,
                      color: Color(0xFFEF4444),
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Heading
                const Text(
                  'Outside Office Area',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    fontFamily: 'DMSans',
                    color: Colors.black,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 10),

                // Description
                Text(
                  'You must be within the configured geofence radius to check out normally. '
                      'You are currently $distanceKm km away from the assigned office.',
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w400,
                    fontFamily: 'DMSans',
                    color: Color(0xFF6B7280),
                    height: 1.5,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),

                // Yellow Info Banner
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF9E6),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: const Color(0xFFF5E0A3),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        /*width: 24,
                        height: 24,
                        margin: const EdgeInsets.only(top: 2),
                        decoration: BoxDecoration(
                          color: const Color(0xFF92400E),
                          borderRadius: BorderRadius.circular(6),
                        ),*/
                        child: Image.asset(
                          'assets/images/check_out_popup_notif.png',
                          //color: Colors.white,
                          width:20,
                          height:20,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Submit Check-Out Exception',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                fontFamily: 'DMSans',
                                color: Color(0xFF856404),
                              ),
                            ),
                            const SizedBox(height: 4),
                            const Text(
                              'You can submit a check-out exception with reason and remarks. Your manager will review and approve or reject it.',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w400,
                                fontFamily: 'DMSans',
                                color: Color(0xCC856404),
                                height: 1.4,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Primary Button - Submit Exception
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: onSubmitException,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF3B5BDB),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text(
                      'Submit Check-Out Exception',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        fontFamily: 'DMSans',
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 10),

                // Secondary Button - Retry Location
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: OutlinedButton(
                    onPressed: onRetryLocation,
                    style: OutlinedButton.styleFrom(
                      backgroundColor: const Color(0xFFF3F4F6),
                      foregroundColor: const Color(0xFF374151),
                      side: const BorderSide(
                        color: Color(0xFFE5E7EB),
                        width: 1,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text(
                      'Retry Location',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        fontFamily: 'DMSans',
                        color: Color(0xFF374151),
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
}

/// Helper function to show the check-out geofence exception dialog
Future<void> showCheckOutGeofenceExceptionDialog({
  required BuildContext context,
  required double distanceInMeters,
  required VoidCallback onSubmitException,
  required VoidCallback onRetryLocation,
}) {
  return showDialog(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext dialogContext) {
      return CheckOutGeofenceExceptionDialog(
        distanceInMeters: distanceInMeters,
        onSubmitException: onSubmitException,
        onRetryLocation: onRetryLocation,
      );
    },
  );
}