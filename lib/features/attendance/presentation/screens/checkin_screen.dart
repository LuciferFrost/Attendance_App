import 'dart:math' as math;

import 'package:demo4/features/dashboard/presentation/providers/dashboard_providers.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../data/data_sources/dummy_geolocation.dart';
import '../providers/checkin_providers.dart';
import 'qr_scanner_screen.dart';
import 'checkout_geofence_exception_popup.dart';
import 'checkout_hours_shortfall_popup.dart';
import 'holiday_warning_screen.dart';
import 'package:demo4/features/attendance/domain/entities/checkin_models.dart';
import 'package:demo4/features/attendance/data/data_sources/geolocation_service.dart';

// ─── Work mode constants ──────────────────────────────────────────────────────
// These match the values returned by the employee profile from the database.
class WorkMode {
  static const String wfo = 'WFO'; // Work from Office
  static const String wfh = 'WFH'; // Work from Home
  static const String wff = 'WFF'; // Work from Field
}

// ─── Location verification state (WFH / WFF only) ───────────────────────────
enum _LocationState {
  /// Fetching GPS — pulsing map animation shown.
  fetching,
  /// GPS obtained — brief pause before proceeding to check-in.
  verified,
  /// GPS fetch failed — failure dialog is shown.
  failed,
}

class CheckInScreen extends ConsumerStatefulWidget {
  final bool isCheckOut;
  final Duration qrSuccessDelay;

  /// The employee's pre-set work mode from the database.
  /// Use [WorkMode] constants: [WorkMode.wfo], [WorkMode.wfh], [WorkMode.wff].
  /// Defaults to WFO to preserve existing behaviour.
  final String workMode;

  const CheckInScreen({
    super.key,
    this.isCheckOut = false,
    this.qrSuccessDelay = const Duration(seconds: 1),
    this.workMode = WorkMode.wfo,
  });

  @override
  ConsumerState<CheckInScreen> createState() => _CheckInScreenState();
}

class _CheckInScreenState extends ConsumerState<CheckInScreen> {
  late String _employeeId;
  bool _isCheckingIn = false;
  String? _errorMessage;
  bool _qrVerified = false;
  bool _qrWrongType = false;
  // ── WFF field-detail form state ─────────────────────────────────────────────
  final _wffFieldReasonController    = TextEditingController();
  final _wffPlaceNameController      = TextEditingController();
  final _wffLocationAddressController = TextEditingController();
  final _wffRemarksController        = TextEditingController();
  bool _wffFormSubmitted = false;

  // ── WFH / WFF location flow state ──────────────────────────────────────────
  _LocationState _locationState = _LocationState.fetching;
  LocationCoordinates? _resolvedLocation;

  // Geofence radius in meters (e.g., 500m)
  static const double GEOFENCE_RADIUS = 500.0;

  // Returns true when the current work mode uses location-only check-in.
  bool get _isLocationMode =>
      widget.workMode == WorkMode.wfh || widget.workMode == WorkMode.wff;

  @override
  void initState() {
    super.initState();
    _employeeId = ref.read(dashboardStateProvider).employeeCode;

    // WFH starts location flow automatically; WFF waits for the user to
    // fill in field details and tap "Confirm check-in" first.

    if (widget.workMode == WorkMode.wfh ||
        (widget.workMode == WorkMode.wff && widget.isCheckOut)) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _startLocationFlow());
    }
  }

  @override
  void dispose() {
    _wffFieldReasonController.dispose();
    _wffPlaceNameController.dispose();
    _wffLocationAddressController.dispose();
    _wffRemarksController.dispose();
    super.dispose();
  }

  /// Calculate distance between two coordinates using Haversine formula
  double _calculateDistance(
      double lat1,
      double lon1,
      double lat2,
      double lon2,
      ) {
    const R = 6371000; // Earth's radius in meters
    final dLat = (lat2 - lat1) * math.pi / 180;
    final dLon = (lon2 - lon1) * math.pi / 180;
    final a = math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(lat1 * math.pi / 180) *
            math.cos(lat2 * math.pi / 180) *
            math.sin(dLon / 2) *
            math.sin(dLon / 2);
    final c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
    return R * c;
  }

  /// Parses a time string like "09:00 AM" into a DateTime anchored to today
  DateTime _parseShiftTime(String timeStr) {
    final parts = timeStr.trim().split(' ');
    final hm = parts[0].split(':');
    int hour = int.parse(hm[0]);
    final minute = int.parse(hm[1]);
    final period = parts.length > 1 ? parts[1].toUpperCase() : 'AM';

    if (period == 'PM' && hour != 12) hour += 12;
    if (period == 'AM' && hour == 12) hour = 0;

    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day, hour, minute);
  }

  /// Required shift duration, derived from shiftStartTime/shiftEndTime
  Duration _getRequiredShiftDuration(
      String shiftStartTime,
      String shiftEndTime,
      ) {
    final start = _parseShiftTime(shiftStartTime);
    var end = _parseShiftTime(shiftEndTime);
    if (end.isBefore(start)) {
      end = end.add(const Duration(days: 1)); // overnight shift safety
    }
    return end.difference(start);
  }

  /// Show loading dialog while checking approvals
  /*Future<void> _showCheckingApprovalsDialog() async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return _buildCheckingApprovalsDialog();
      },
    );

    // Simulate verification delay
    await Future.delayed(const Duration(seconds: 2));

    // Close the dialog
    if (mounted) {
      Navigator.of(context, rootNavigator: true).pop();
    }
  }*/

  /// Show modal for outside geofence case
  Future<bool?> _showOutsideGeofenceModal(
      String locationName,
      double latitude,
      double longitude,
      double distanceInMeters,
      ) async {
    return await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return _buildOutsideGeofenceModal(
          locationName: locationName,
          latitude: latitude,
          longitude: longitude,
          distanceInMeters: distanceInMeters,
        );
      },
    );
  }

  /// Show modal for insufficient hours case (check-out only)
  Future<void> _showHoursShortfallModal({
    required Duration durationSoFar,
    required Duration requiredDuration,
  }) async {
    final dashboardState = ref.read(dashboardStateProvider);
    final shortfall = requiredDuration - durationSoFar;
    final now = DateTime.now();
    final formattedCheckOutTime = DateFormat('h:mm a').format(now);

    await showHoursShortfallDialog(
      context: context,
      durationSoFar: durationSoFar,
      requiredDuration: requiredDuration,
      onApplyShortLeave: () {
        Navigator.of(context).pop();
        context.pushNamed(
          'short-leave-apply',
          extra: {
            'checkInTime': dashboardState.shiftStartTime,
            'checkOutTime': formattedCheckOutTime,
            'totalHours': durationSoFar,
            'shortfall': shortfall.isNegative ? Duration.zero : shortfall,
          },
        );
      },
      onBackToHome: () {
        Navigator.of(context).pop();
        context.go('/dashboard');
      },
    );
  }

  /// Handle check-in process
  Future<void> _handleCheckIn({
    required double latitude,
    required double longitude,
    required String officeLocation,
    required String shiftType,
    required double officeLatitude,
    required double officeLongitude,
    required double geofenceRadius,
  }) async {
    setState(() {
      _isCheckingIn = true;
      _errorMessage = null;
    });

    try {
      // For check-out, hours-shortfall takes priority over geofence.
      if (widget.isCheckOut) {
        final dashboardState = ref.read(dashboardStateProvider);
        final requiredDuration = _getRequiredShiftDuration(
          dashboardState.shiftStartTime,
          dashboardState.shiftEndTime,
        );
        final durationSoFar = Duration(
          milliseconds:
          (dashboardState.hoursWorked * Duration.millisecondsPerHour)
              .round(),
        );

        if (durationSoFar < requiredDuration) {
          setState(() {
            _isCheckingIn = false;
          });

          if (!mounted) return;

          await _showHoursShortfallModal(
            durationSoFar: durationSoFar,
            requiredDuration: requiredDuration,
          );
          return;
        }
      }

      // Calculate distance from current location to office
      final distance = _calculateDistance(
        latitude,
        longitude,
        officeLatitude,
        officeLongitude,
      );

      final isWithinGeofence = distance <= geofenceRadius;

      if (isWithinGeofence) {
        // User is within geofence - proceed with normal check-in
        //await _showCheckingApprovalsDialog();

        if (!mounted) return;

        final checkInController = ref.read(checkInControllerProvider.notifier);
        final record = await checkInController.performCheckIn(
          employeeId: _employeeId,
          latitude: latitude,
          longitude: longitude,
          officeLocation: officeLocation,
          shiftType: shiftType,
        );

        if (mounted && record != null) {
          setState(() {
            _isCheckingIn = false;
          });

          // Navigate to success screen
          final hour = record.checkInTime.hour % 12 == 0
              ? 12
              : record.checkInTime.hour % 12;
          final period = record.checkInTime.hour >= 12 ? 'PM' : 'AM';
          final formattedTime =
              '${hour.toString().padLeft(2, '0')}:${record.checkInTime.minute.toString().padLeft(2, '0')} $period';

          if (mounted) {
            context.pushReplacementNamed(
              widget.isCheckOut ? 'check-out-success' : 'check-in-success',
              extra: {
                'attendanceStatus':
                record.status == 'success' ? 'Present' : record.status,
                'geofenceStatus': 'Within Geofence',
                'checkInTime': formattedTime,
                'workMode': 'Office',
                'location': record.officeLocation,
                'shiftType': record.shiftType,
                'isCheckOut': widget.isCheckOut,
                'isWithinGeofence': true,
              },
            );
          }
        }
      } else {
        // User is outside geofence
        setState(() {
          _isCheckingIn = false;
        });

        if (!mounted) return;

        // For check-out, navigate to check-out exception screen
        if (widget.isCheckOut) {
          await showCheckOutGeofenceExceptionDialog(
            context: context,
            distanceInMeters: distance,
            onSubmitException: () {
              Navigator.of(context).pop();
              context.pushNamed(
                'check-out-exception',
                extra: {
                  'latitude': latitude,
                  'longitude': longitude,
                  'distanceInMeters': distance,
                  'officeLocation': officeLocation,
                  'officeLatitude': officeLatitude,
                  'officeLongitude': officeLongitude,
                  'attemptedAt': DateTime.now(),
                },
              );
            },
            onRetryLocation: () {
              Navigator.of(context).pop();
              // User can retry
            },
          );
        } else {
          // For check-in, keep existing logic
          final locationName = await _getLocationName(latitude, longitude);

          final hasPermission = await _showOutsideGeofenceModal(
            locationName,
            latitude,
            longitude,
            distance,
          );

          if (!mounted) return;

          if (hasPermission == true) {
            //await _showCheckingApprovalsDialog();

            if (mounted) {
              context.go('/work-reason');
            }
          }
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Check-in failed: ${e.toString()}';
          _isCheckingIn = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_errorMessage!),
            backgroundColor: AppColors.error,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  /// Get location name from coordinates
  Future<String> _getLocationName(double latitude, double longitude) async {
    final userFarLat = DummyGeolocation.userFarFromOffice['latitude'] as double;
    final userFarLng = DummyGeolocation.userFarFromOffice['longitude'] as double;

    if ((latitude - userFarLat).abs() < 0.0001 &&
        (longitude - userFarLng).abs() < 0.0001) {
      return DummyGeolocation.farLocationName;
    }

    return 'Current Location';
  }

  /// Proceed with check-in after QR verification.
  /// Checks for holidays first; if today is a holiday, routes to the
  /// HolidayWarningScreen instead of continuing with the normal flow.
  Future<void> _proceedWithCheckInAfterQRVerification() async {
    // ── 1. Holiday check (highest priority) ──────────────────────────────────
    final holidayAsync = ref.read(holidayInfoProvider);

    final HolidayInfo? holidayInfo = await holidayAsync.when(
      data: (info) async => info,
      loading: () async {
        // Wait for the future to resolve if still loading
        return await ref.read(holidayInfoProvider.future);
      },
      error: (_, __) async => null,
    );

    if (!mounted) return;

    if (holidayInfo != null) {
      context.pushNamed('holiday-warning');
      return;
    }
    // ── 2. Normal geofence / check-in flow ───────────────────────────────────
    final locationAsync = ref.read(currentLocationProvider);
    final geofenceAsync = ref.read(officeGeofenceProvider);

    locationAsync.when(
      data: (location) {
        geofenceAsync.when(
          data: (geofence) {
            _handleCheckIn(
              latitude: location.latitude,
              longitude: location.longitude,
              officeLocation: geofence.name,
              shiftType: 'Day Shift',
              officeLatitude: geofence.latitude,
              officeLongitude: geofence.longitude,
              geofenceRadius: geofence.radiusInMeters,
            );
          },
          loading: () => ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Loading office data...')),
          ),
          error: (_, __) => ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Could not fetch office data')),
          ),
        );
      },
      loading: () => ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Fetching your location...')),
      ),
      error: (_, __) => ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not fetch your location')),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

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
          widget.isCheckOut ? 'Check out' : 'Check in',
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
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.pageHorizontal,
            vertical: AppSpacing.pageVertical,
          ),
          child: _isLocationMode
              ? _buildLocationModeBody()   // WFH / WFF
              : _buildWfoBody(isDark),     // WFO (original)
        ),
      ),
    );
  }

  // ─── WFO body (original layout, unchanged) ─────────────────────────────────

  Widget _buildWfoBody(bool isDark) {
    return Column(
      children: [
        _buildWFONotifier(),
        const SizedBox(height: AppSpacing.lg),
        _buildLocationVisualizationBox(isDark),
        const SizedBox(height: AppSpacing.lg),
        _buildLocationBox(),
        const SizedBox(height: AppSpacing.xxxl),
        _buildQRCodeBox(),
        const SizedBox(height: AppSpacing.sm),
        _buildNotif(),
      ],
    );
  }

  // ─── WFH / WFF body ────────────────────────────────────────────────────────

  Widget _buildLocationModeBody() {

    if (widget.workMode == WorkMode.wff && !_wffFormSubmitted && !widget.isCheckOut)  {
      return _buildWFFFieldDetailsBody();
    }
    return Column(
      children: [
        _buildWorkModeNotifier(),
        const SizedBox(height: AppSpacing.lg),
        _buildWFHMapCard(),
        const SizedBox(height: AppSpacing.lg),
        _buildWFHLocationCapture(),
        const SizedBox(height: AppSpacing.md),
        _buildNotif(),
      ],
    );
  }

  // ─── WFF field details form ─────────────────────────────────────────────────

  Widget _buildWFFFieldDetailsBody() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildWorkModeNotifier(),
        const SizedBox(height: AppSpacing.lg),
        _buildWFHMapCard(),
        const SizedBox(height: AppSpacing.lg),
        _buildWFHLocationCapture(),
        const SizedBox(height: AppSpacing.lg),

        // ── Field Details section ────────────────────────────────────────────
        const Text(
          'Field Details',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            fontFamily: 'DMSans',
            color: Colors.black,
          ),
        ),
        const SizedBox(height: AppSpacing.md),

        _buildWFFTextField(
          label: 'Field Reason',
          controller: _wffFieldReasonController,
          hint: 'e.g. Client Meeting',
        ),
        const SizedBox(height: AppSpacing.md),

        _buildWFFTextField(
          label: 'Place Name',
          controller: _wffPlaceNameController,
          hint: 'e.g. Infosys Technologies Ltd.',
        ),
        const SizedBox(height: AppSpacing.md),

        _buildWFFTextField(
          label: 'Location Address',
          controller: _wffLocationAddressController,
          hint: 'e.g. Connaught Place, New Delhi',
        ),
        const SizedBox(height: AppSpacing.md),

        _buildWFFTextField(
          label: 'Purpose / Remarks',
          controller: _wffRemarksController,
          hint: 'e.g. Q3 product demo and pricing discussion…',
          maxLines: 3,
        ),
        const SizedBox(height: AppSpacing.sm),

        _buildNotif(),
        const SizedBox(height: AppSpacing.lg),

        // ── Confirm button ───────────────────────────────────────────────────
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: _isCheckingIn ? null : _onWFFConfirm,
            icon: _isCheckingIn
                ? const SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor:
                AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            )
                : const Icon(Icons.check_rounded, size: 20, color: Colors.white),
            label: Text(
    // AFTER:
              _isCheckingIn
                  ? 'Confirming…'
                  : widget.isCheckOut ? 'Confirm check-out' : 'Confirm check-in',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                fontFamily: 'DMSans',
                color: Colors.white,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF3B5BDB),
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
              ),
              elevation: 0,
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
      ],
    );
  }

  Widget _buildWFFTextField({
    required String label,
    required TextEditingController controller,
    String? hint,
    int maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RichText(
          text: TextSpan(
            text: label,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              fontFamily: 'DMSans',
              color: Colors.black,
            ),
            children: const [
              TextSpan(
                text: ' *',
                style: TextStyle(color: Color(0xFFEF4444)),
              ),
            ],
          ),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          maxLines: maxLines,
          style: const TextStyle(
            fontSize: 14,
            fontFamily: 'DMSans',
            color: Colors.black,
          ),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(
              color: Color(0xFF9CA3AF),
              fontSize: 14,
              fontFamily: 'DMSans',
            ),
            contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius:
              BorderRadius.circular(AppSpacing.radiusMd),
              borderSide: const BorderSide(color: Color(0xFFD1D5DB)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius:
              BorderRadius.circular(AppSpacing.radiusMd),
              borderSide: const BorderSide(color: Color(0xFFD1D5DB)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius:
              BorderRadius.circular(AppSpacing.radiusMd),
              borderSide: const BorderSide(
                  color: Color(0xFF3B5BDB), width: 1.5),
            ),
          ),
        ),
      ],
    );
  }

  /// Called when the user taps "Confirm check-in" on the WFF form.
  /// Validates fields, then hands off to the location flow.
  void _onWFFConfirm() {
    final reason  = _wffFieldReasonController.text.trim();
    final place   = _wffPlaceNameController.text.trim();
    final address = _wffLocationAddressController.text.trim();

    if (reason.isEmpty || place.isEmpty || address.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill in all required fields.'),
          backgroundColor: Color(0xFFEF4444),
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    // Mark form done so the body switches to the GPS-flow view,
    // then kick off location fetch.
    setState(() => _wffFormSubmitted = true);
    _startLocationFlow();
  }

  /// Top banner — text varies by work mode.
  Widget _buildWorkModeNotifier() {
    final String message;
    if (widget.workMode == WorkMode.wfh) {
      message = widget.isCheckOut
          ? 'Work from Home. Your GPS location will be captured for Check-out.'
          : 'Work from Home. Your GPS location will be captured automatically.';
    } else {
      // WFF
      message = widget.isCheckOut
          ? 'Work from Field. Your GPS location will be captured for Check-out.'
          : 'Work from Field. Your GPS location will be captured automatically.';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0x383B5BDB),
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        border: Border.all(color: const Color(0xFFC7C4D8)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Image.asset(
            'assets/images/checkin_WFOnotif.png',
            width: 20,
            height: 20,
            errorBuilder: (_, __, ___) => const Icon(
              Icons.info_outline_rounded,
              color: Color(0xFF1A40C2),
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(
                color: Color(0xFF1A40C2),
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Dark map card with static rings — shown during location fetch.
  Widget _buildWFHMapCard() {
    final ringColor = _locationState == _LocationState.failed
        ? const Color(0xFFEF4444)
        : const Color(0xFF3B82F6);

    // Location label shown at bottom of card.
    final locationLabel = (_locationState == _LocationState.verified &&
        _resolvedLocation != null)
        ? _resolvedLocationLabel(_resolvedLocation!)
        : (widget.workMode == WorkMode.wff
        ? 'Detecting field location…'
        : 'Dwarka, New Delhi - 110030');

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.darkSurfaceSecondary,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        border: Border.all(color: AppColors.darkBorder),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      clipBehavior: Clip.hardEdge,
      child: Column(
        children: [
          SizedBox(
            height: 150,
            child: Stack(
              alignment: Alignment.center,
              clipBehavior: Clip.none,
              children: [
                // Static rings
                _buildLocationRings(ringColor),
                // Bottom location label.
                Positioned(
                  bottom: 15,
                  child: Container(
                    padding: EdgeInsets.zero,
                    decoration: BoxDecoration(
                      color: const Color(0xCC111827),
                      borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Image.asset(
                          'assets/images/checkin_locationTag.png',
                          width: 24,
                          height: 24,
                          errorBuilder: (_, __, ___) => const Icon(
                            Icons.location_on,
                            color: Colors.blue,
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        Text(
                          locationLabel,
                          style: AppTypography.label.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w400,
                            fontFamily: 'LiberationSans',
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLocationRings(Color color) {
    return Stack(
      alignment: Alignment.center,
      children: [
        Container(
          width: 128,
          height: 128,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: color.withOpacity(0.3), width: 2),
          ),
        ),
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: color.withOpacity(0.5), width: 2),
          ),
        ),
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: color,
          ),
        ),
      ],
    );
  }

  /// Location capture info card shown below the map card.
  Widget _buildWFHLocationCapture() {
    final isFetching = _locationState == _LocationState.fetching;
    final coordsText = isFetching
        ? 'Fetching location…'
        : _formatCoordinates(_resolvedLocation);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        border: Border.all(color: const Color(0xB2C7C4D8)),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 36,
            height: 36,
            child: isFetching
                ? const Padding(
              padding: EdgeInsets.all(6),
              child: CircularProgressIndicator(
                strokeWidth: 2.5,
                valueColor: AlwaysStoppedAnimation<Color>(
                  Color(0xFF3B82F6),
                ),
              ),
            )
                : const Icon(
              Icons.location_on_rounded,
              color: Color(0xFF3B82F6),
              size: 28,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isFetching ? 'Capture location' : 'Location captured',
                  style: const TextStyle(
                    color: Colors.black,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    fontFamily: 'DMSans',
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  coordsText,
                  style: const TextStyle(
                    color: Color(0xFF6B7280),
                    fontSize: 12,
                    fontFamily: 'DMSans',
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ─── WFH / WFF location flow logic ─────────────────────────────────────────

  Future<void> _startLocationFlow() async {
    setState(() {
      _locationState = _LocationState.fetching;
      _resolvedLocation = null;
    });

    // Buffer so the pulsing animation is visible before result arrives.
    await Future.delayed(const Duration(milliseconds: 1800));
    if (!mounted) return;

    try {
      final location = await ref.read(currentLocationProvider.future);
      if (!mounted) return;
      _resolvedLocation = location;
      setState(() => _locationState = _LocationState.verified);

      // Brief verified pause, then proceed to check-in.
      await Future.delayed(const Duration(milliseconds: 600));
      if (!mounted) return;
      await _proceedAfterLocationVerified(location);
    } catch (_) {
      if (!mounted) return;
      setState(() => _locationState = _LocationState.failed);
      _showLocationFailedDialog();
    }
  }

  Future<void> _proceedAfterLocationVerified(
      LocationCoordinates location) async {
    // ── 1. Holiday check ────────────────────────────────────────────────────
    final HolidayInfo? holidayInfo = await ref
        .read(holidayInfoProvider.future)
        .catchError((_) => null as HolidayInfo?);
    if (!mounted) return;

    if (holidayInfo != null) {
      context.pushNamed('holiday-warning');
      return;
    }

    // ── 2. Perform check-in ─────────────────────────────────────────────────
    try {
      final checkInController = ref.read(checkInControllerProvider.notifier);
      final record = await checkInController.performCheckIn(
        employeeId: _employeeId,
        latitude: location.latitude,
        longitude: location.longitude,
        officeLocation: _resolvedLocationLabel(location),
        shiftType: widget.workMode,
      );

      if (!mounted || record == null) return;

      final h = record.checkInTime.hour % 12 == 0
          ? 12
          : record.checkInTime.hour % 12;
      final period = record.checkInTime.hour >= 12 ? 'PM' : 'AM';
      final formattedTime =
          '${h.toString().padLeft(2, '0')}:'
          '${record.checkInTime.minute.toString().padLeft(2, '0')}:'
          '${record.checkInTime.second.toString().padLeft(2, '0')} $period';

      final shiftStart = DateTime(
        record.checkInTime.year,
        record.checkInTime.month,
        record.checkInTime.day,
        9,
        0,
      );
      final attendanceStatus =
      record.checkInTime.isBefore(shiftStart) ? 'Present' : 'Late';

      final workModeLabel = widget.workMode == WorkMode.wff
          ? 'Work from Field'
          : 'Work from Home';

      context.pushReplacementNamed(
        widget.isCheckOut ? 'check-out-success' : 'check-in-success',
        extra: {
          'attendanceStatus': attendanceStatus,
          'geofenceStatus': record.officeLocation,
          'checkInTime': formattedTime,
          'workMode': workModeLabel,
          'location': record.officeLocation,
          'shiftType': record.shiftType,
          'isCheckOut': widget.isCheckOut,
          'isWfh': true,
          'isWithinGeofence': true,
        },
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Check-in failed: ${e.toString()}'),
          backgroundColor: AppColors.error,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  void _showLocationFailedDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black54,
      builder: (ctx) => _LocationFailedDialog(
        onTryAgain: () {
          Navigator.of(ctx).pop();
          _startLocationFlow();
        },
      ),
    );
  }

  /// Converts coordinates to a human-readable label.
  /// In production this would call a reverse-geocoding service.
  String _resolvedLocationLabel(LocationCoordinates loc) {
    return widget.workMode == WorkMode.wff
        ? 'Field Location – ${loc.latitude.toStringAsFixed(4)}°N'
        : 'Dwarka, New Delhi – 110030';
  }

  String _formatCoordinates(LocationCoordinates? loc) {
    if (loc == null) return '—';
    final lat =
        '${loc.latitude.abs().toStringAsFixed(4)}°${loc.latitude >= 0 ? 'N' : 'S'}';
    final lon =
        '${loc.longitude.abs().toStringAsFixed(4)}°${loc.longitude >= 0 ? 'E' : 'W'}';
    return '$lat, $lon';
  }

  Widget _buildWFONotifier() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0x383B5BDB),
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        border: Border.all(
          color: const Color(0xFFC7C4D8),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Image.asset(
            'assets/images/checkin_WFOnotif.png',
            width: 20,
            height: 20,
            errorBuilder: (context, error, stackTrace) => const Icon(
              Icons.info_outline_rounded,
              color: Color(0xFF1A40C2),
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              widget.isCheckOut
                  ? 'Work from Office. Geofence and QR scan required for Check-out.'
                  : 'Work from Office. Geofence and QR scan required.',
              style: const TextStyle(
                color: Color(0xFF1A40C2),
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Location visualization with geofence circles
  Widget _buildLocationVisualizationBox(bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 120, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.darkSurfaceSecondary,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        border: Border.all(
          color: AppColors.darkBorder,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          SizedBox(
            height: 150,
            child: Stack(
              alignment: Alignment.center,
              clipBehavior: Clip.none,
              children: [
                _buildLocationRings(const Color(0xFF2563EB)),

                // Location Status
                Positioned(
                  bottom: 15,
                  child: Container(
                    padding: EdgeInsets.zero,
                    decoration: BoxDecoration(
                      color: const Color(0xCC111827),
                      borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Image.asset(
                          'assets/images/checkin_locationTag.png',
                          width: 24,
                          height: 24,
                          errorBuilder: (context, error, stackTrace) =>
                          const Icon(Icons.location_on,
                              color: Colors.blue, size: 24),
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        Text(
                          'CraftEdge Office, Sector 62, Noida',
                          style: AppTypography.label.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w400,
                            fontFamily: 'LiberationSans',
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLocationBox() {
    final locationAsync = ref.watch(currentLocationProvider);
    final geofenceAsync = ref.watch(officeGeofenceProvider);

    final bool inGeofence = locationAsync.maybeWhen(
      data: (loc) => geofenceAsync.maybeWhen(
        data: (geo) =>
        _calculateDistance(
          loc.latitude,
          loc.longitude,
          geo.latitude,
          geo.longitude,
        ) <=
            geo.radiusInMeters,
        orElse: () => true,
      ),
      orElse: () => true,
    );

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        border: Border.all(
          color: const Color(0xB2C7C4D8),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Image.asset(
            'assets/images/checkin_WFOnotif.png',
            width: 20,
            height: 20,
            errorBuilder: (context, error, stackTrace) => const Icon(
              Icons.info_outline_rounded,
              color: Color(0xFF1A40C2),
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'CraftEdge Office, Sector 62, Noida',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    fontFamily: 'LiberationSans',
                  ),
                ),
                const SizedBox(height: 0),
                Text(
                  locationAsync.when(
                    data: (loc) => loc.toFormattedString(),
                    loading: () => 'Fetching location...',
                    error: (_, __) => 'Location unavailable',
                  ),
                  style: const TextStyle(
                    color: Color(0xFF666666),
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    fontFamily: 'DMSans',
                  ),
                ),
                const SizedBox(height: 2),
                Container(
                  padding:
                  const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: inGeofence
                        ? const Color(0xFFE8F5E9)
                        : const Color(0xFFFFEBEE),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Image.asset(
                        'assets/images/checkin_locationTag.png',
                        width: 10,
                        height: 10,
                        color: inGeofence
                            ? const Color(0xFF2E7D32)
                            : const Color(0xFFC62828),
                        errorBuilder: (context, error, stackTrace) => Icon(
                          Icons.location_on_rounded,
                          size: 14,
                          color: inGeofence
                              ? const Color(0xFF2E7D32)
                              : const Color(0xFFC62828),
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        inGeofence ? 'Within Geofence' : 'Outside Geofence',
                        style: TextStyle(
                          color: inGeofence
                              ? const Color(0xFF2E7D32)
                              : const Color(0xFFC62828),
                          fontSize: 12,
                          fontWeight: FontWeight.w400,
                          fontFamily: 'LiberationSans',
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQRCodeBox() {
    return DottedBorder(
      options: const RoundedRectDottedBorderOptions(
        color: Color(0xB2C7C4D8),
        strokeWidth: 2,
        dashPattern: [6, 4],
        radius: Radius.circular(12),
        padding: EdgeInsets.all(30),
      ),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
        decoration: BoxDecoration(
          color: const Color(0xFFFFFFFF),
          borderRadius: BorderRadius.circular(12),
        ),
        child: _qrVerified
            ? _buildQRVerifiedContent()
            : _qrWrongType
            ? _buildQRWrongTypeContent()
            : _buildQRDefaultContent(),
      ),
    );
  }

  Widget _buildQRVerifiedContent() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 80,
          height: 80,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            color: Color(0xFFE8F5E9),
          ),
          child: const Center(
            child: Icon(Icons.check_rounded, size: 40, color: Color(0xFF4CAF50)),
          ),
        ),
        const SizedBox(height: 16),
        const Text(
          'QR Code Verified',
          style: TextStyle(
            color: Colors.black,
            fontSize: 16,
            fontWeight: FontWeight.w600,
            fontFamily: 'LiberationSans',
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'CraftEdge Office, Sector 62, Noida',
          style: TextStyle(
            color: Color(0xFF666666),
            fontSize: 12,
            fontFamily: 'DMSans',
          ),
        ),
        const SizedBox(height: 24),
        /*SizedBox(
          width: 160,
          child: ElevatedButton(
            onPressed: _proceedWithCheckInAfterQRVerification,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF3B5BDB),
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              elevation: 0,
            ),
            child: const Text(
              'Proceed',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                fontFamily: 'DMSans',
                color: Colors.white,
              ),
            ),
          ),
        ),*/
      ],
    );
  }

  Widget _buildQRWrongTypeContent() {
    return Column(
      children: [
        Image.asset(
          'assets/images/checkin_QRCode.png',
          width: 40,
          height: 40,
          color: const Color(0xFFEF4444),
          errorBuilder: (_, __, ___) => const Icon(
            Icons.qr_code_2_rounded,
            size: 40,
            color: Color(0xFFEF4444),
          ),
        ),
        const SizedBox(height: 16),
        const Text(
          'Wrong QR Type',
          style: TextStyle(
            color: Colors.black,
            fontSize: 16,
            fontWeight: FontWeight.w700,
            fontFamily: 'DMSans',
          ),
        ),
        const SizedBox(height: 10),
        RichText(
          textAlign: TextAlign.center,
          text: TextSpan(
            style: const TextStyle(
              fontSize: 13,
              fontFamily: 'DMSans',
              color: Color(0xFF6B7280),
              height: 1.5,
            ),
            children: [
              TextSpan(text: 'You scanned the '),
              TextSpan(
                text: widget.isCheckOut ? 'Check-In QR' : 'Check-Out QR',
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF111827),
                ),
              ),
              TextSpan(text: ' but this is a ${widget.isCheckOut ? 'check-out' : 'check-in'} action. Please scan the '),
              TextSpan(
                text: widget.isCheckOut ? 'Check-Out QR' : 'Check-In QR',
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF111827),
                ),
              ),
              TextSpan(text: ' located at the ${widget.isCheckOut ? 'exit' : 'reception'} desk.'),
            ],
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          width: 160,
          child: ElevatedButton.icon(
            onPressed: () async {
              // Reset the states
              setState(() {
                _qrWrongType = false;
                _qrVerified = false;
              });

              // Get the expected QR token from secure storage via provider
              final expectedTokenAsync = await ref.read(
                expectedQrTokenProvider(widget.isCheckOut).future,
              );

              if (!mounted) return;

              final result = await Navigator.of(context).push<Map<String, dynamic>>(
                MaterialPageRoute(
                  builder: (context) => QRScannerScreen(
                    expectedQRToken: expectedTokenAsync,
                    isCheckOut: widget.isCheckOut,
                  ),
                ),
              );

              if (result != null && mounted) {
                if (result['verified'] == true) {
                  // QR verified - show verified content
                  setState(() => _qrVerified = true);
                  await Future.delayed(widget.qrSuccessDelay);
                  if (mounted) {
                    _proceedWithCheckInAfterQRVerification();
                  }
                } else if (result['wrongType'] == true) {
                  // Wrong QR type - show error again
                  setState(() => _qrWrongType = true);
                }
              }
            },
            icon: Image.asset(
              'assets/images/checkin_camera.png',
              width: 18,
              height: 18,
              color: const Color(0xFFEF4444),
              errorBuilder: (_, __, ___) => const Icon(
                Icons.camera_alt_rounded,
                size: 18,
                color: Color(0xFFEF4444),
              ),
            ),
            label: const Text(
              'Scan again',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                fontFamily: 'DMSans',
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFEE2E2),
              foregroundColor: const Color(0xFFEF4444),
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 6),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(9999),
              ),
              elevation: 0,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildQRDefaultContent() {
    return Column(
      children: [
        Image.asset(
          'assets/images/checkin_QRCode.png',
          width: 40,
          height: 40,
          color: const Color(0xFF464555),
          errorBuilder: (_, __, ___) => const Icon(
            Icons.qr_code_2_rounded,
            size: 40,
            color: Color(0xFF464555),
          ),
        ),
        const SizedBox(height: 16),
        RichText(
          textAlign: TextAlign.center,
          text: TextSpan(
            style: const TextStyle(
              fontSize: 16,
              fontFamily: 'DMSans',
              color: Color(0xFF464555),
            ),
            children: [
              const TextSpan(text: 'Scan the office '),
              TextSpan(
                text: widget.isCheckOut ? 'Check-Out QR ' : 'Check-In QR ',
                style: const TextStyle(
                  color: Color(0xFF3525CD),
                  fontWeight: FontWeight.w600,
                ),
              ),
              const TextSpan(text: 'code displayed at the entrance'),
            ],
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          width: 160,
          child: ElevatedButton.icon(
            onPressed: () async {
              // Get the expected QR token from secure storage via provider
              final expectedTokenAsync = await ref.read(
                expectedQrTokenProvider(widget.isCheckOut).future,
              );

              if (!mounted) return;

              final result = await Navigator.of(context).push<Map<String, dynamic>>(
                MaterialPageRoute(
                  builder: (context) => QRScannerScreen(
                    expectedQRToken: expectedTokenAsync,
                    isCheckOut: widget.isCheckOut,
                  ),
                ),
              );

              if (result != null && mounted) {
                if (result['verified'] == true) {
                  // QR verified - show verified content
                  setState(() => _qrVerified = true);
                  await Future.delayed(widget.qrSuccessDelay);
                  if (mounted) {
                    _proceedWithCheckInAfterQRVerification();
                  }
                } else if (result['wrongType'] == true) {
                  // Wrong QR type - show error
                  setState(() => _qrWrongType = true);
                }
              }
            },
            icon: Image.asset(
              'assets/images/checkin_camera.png',
              width: 20,
              height: 18,
              color: const Color(0xFF191C1E),
              errorBuilder: (_, __, ___) =>
              const Icon(Icons.camera_alt_rounded, size: 18),
            ),
            label: const Text(
              'Open Scanner',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                fontFamily: 'DMSans',
                letterSpacing: 0.3,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFF5F5F5),
              foregroundColor: Colors.black,
              padding:
              const EdgeInsets.symmetric(vertical: 12, horizontal: 6),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(9999),
              ),
              elevation: 0,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildNotif() {
    return Row(
      children: const [
        Icon(
          Icons.info_outline,
          size: 18,
          color: Color(0xFF6B7280),
        ),
        SizedBox(width: 8),
        Text(
          'Timestamp and GPS captured automatically',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            fontFamily: 'Inter',
            color: Color(0xFF6B7280),
            letterSpacing: 0.2,
          ),
        ),
      ],
    );
  }

  Widget _buildChecklistItem({
    required String label,
    required bool isCompleted,
    required bool isLoading,
    required bool showDivider,
  }) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.md,
          ),
          child: Row(
            children: [
              if (isLoading)
                const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      Color(0xFF3B82F6),
                    ),
                  ),
                )
              else if (isCompleted)
                Container(
                  width: 20,
                  height: 20,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.success,
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.check_rounded,
                      size: 12,
                      color: Colors.white,
                    ),
                  ),
                )
              else
                Container(
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: const Color(0xFFD1D5DB),
                      width: 2,
                    ),
                  ),
                ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Text(
                  label,
                  style: AppTypography.bodyMedium.copyWith(
                    color: isCompleted || isLoading
                        ? AppColors.neutral900
                        : const Color(0xFFB0B5BC),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
        if (showDivider)
          const Divider(
            height: 1,
            thickness: 1,
            indent: AppSpacing.lg + 20 + AppSpacing.md,
            endIndent: AppSpacing.lg,
            color: Color(0xFFE5E7EB),
          ),
      ],
    );
  }

  Widget _buildCheckingApprovalsDialog() {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
        ),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(
                  width: 80,
                  height: 80,
                  child: CircularProgressIndicator(
                    strokeWidth: 6,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      Color(0xFF3B82F6),
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                Text(
                  'Checking Approvals',
                  style: AppTypography.heading2.copyWith(
                    color: AppColors.neutral900,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  'Verifying if you have an existing approved request for work from another location...',
                  textAlign: TextAlign.center,
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.neutral600,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF9FAFB),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: const Color(0xFFE5E7EB),
                      width: 1,
                    ),
                  ),
                  child: Column(
                    children: [
                      _buildChecklistItem(
                        label: 'Checking approval...',
                        isCompleted: false,
                        isLoading: true,
                        showDivider: true,
                      ),
                      _buildChecklistItem(
                        label: 'Employee Type: In-Office',
                        isCompleted: true,
                        isLoading: false,
                        showDivider: true,
                      ),
                      _buildChecklistItem(
                        label: 'Reason Submitted: Client Visit',
                        isCompleted: true,
                        isLoading: false,
                        showDivider: true,
                      ),
                      _buildChecklistItem(
                        label: 'Looking for manager pre-approval...',
                        isCompleted: false,
                        isLoading: true,
                        showDivider: false,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildOutsideGeofenceModal({
    required String locationName,
    required double latitude,
    required double longitude,
    required double distanceInMeters,
  }) {
    final distanceKm = (distanceInMeters / 1000).toStringAsFixed(1);

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
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
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
              const Text(
                'Geofence Failed',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  fontFamily: 'DMSans',
                  color: Colors.black,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 10),
              Text(
                'Check-in requires you to be within the office premises. '
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
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context, true),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF3B5BDB),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    elevation: 0,
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.check_rounded, color: Colors.white, size: 18),
                      SizedBox(width: 8),
                      Text(
                        'Yes, I have permission',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          fontFamily: 'DMSans',
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                child: TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  style: TextButton.styleFrom(
                    backgroundColor: const Color(0xFFF3F4F6),
                    padding: const EdgeInsets.symmetric(vertical: 14),
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
    );
  }
}

// ─── Location-failed dialog ───────────────────────────────────────────────────

class _LocationFailedDialog extends StatelessWidget {
  final VoidCallback onTryAgain;

  const _LocationFailedDialog({required this.onTryAgain});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 32, 24, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Icon
            Container(
              width: 72,
              height: 72,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Color(0xFFFEE2E2),
              ),
              child: const Center(
                child: Icon(
                  Icons.location_off_rounded,
                  size: 36,
                  color: Color(0xFFEF4444),
                ),
              ),
            ),
            const SizedBox(height: 20),
            // Title
            const Text(
              'Location Verification Failed',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                fontFamily: 'DMSans',
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 8),
            // Subtitle
            const Text(
              "We couldn't verify your current location.",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Color(0xFF6B7280),
                fontFamily: 'DMSans',
                height: 1.5,
              ),
            ),
            const SizedBox(height: 20),
            // Checklist box
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF5F5),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFFECACA)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: const [
                      Icon(Icons.warning_amber_rounded,
                          color: Color(0xFFEF4444), size: 18),
                      SizedBox(width: 6),
                      Text(
                        'Please ensure',
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          color: Color(0xFFEF4444),
                          fontSize: 14,
                          fontFamily: 'DMSans',
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  _BulletPoint('GPS accuracy is set to High.'),
                  const SizedBox(height: 6),
                  _BulletPoint(
                      'You are in an area with a strong GPS signal.'),
                  const SizedBox(height: 6),
                  _BulletPoint(
                      'The app has permission to access your location.'),
                  const SizedBox(height: 10),
                  const Text(
                    'Try again after checking your settings.',
                    style: TextStyle(
                      color: Color(0xFFEF4444),
                      fontSize: 13,
                      fontFamily: 'DMSans',
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            // Try Again button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: onTryAgain,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF3B5BDB),
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  elevation: 0,
                ),
                child: const Text(
                  'Try Again',
                  style: TextStyle(
                    fontSize: 15,
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
    );
  }
}

class _BulletPoint extends StatelessWidget {
  final String text;
  const _BulletPoint(this.text);

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('•  ',
            style: TextStyle(color: Color(0xFFEF4444), fontSize: 14)),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              color: Color(0xFFEF4444),
              fontSize: 13,
              fontFamily: 'DMSans',
              height: 1.4,
            ),
          ),
        ),
      ],
    );
  }
}

// ─── Map grid background painter (WFH / WFF map card) ────────────────────────

class _MapGridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF1E2433)
      ..strokeWidth = 1;
    const step = 28.0;
    for (double x = 0; x < size.width; x += step) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (double y = 0; y < size.height; y += step) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}