import 'dart:io';

import 'package:demo4/core/theme/app_colors.dart';
import 'package:demo4/core/theme/app_spacing.dart';
import 'package:demo4/core/theme/app_typography.dart';
import 'package:demo4/core/widgets/app_shell.dart';
import 'package:demo4/features/profile/data/models/user_profile_model.dart';
import 'package:demo4/features/profile/presentation/screens/edit_profile_screen.dart';
import 'package:demo4/features/profile/presentation/widgets/profile_image_picker_sheet.dart';
import 'package:demo4/features/profile/presentation/providers/user_profile_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  void _onEditPressed(UserProfileModel profile) {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (_) => EditProfileScreen(profile: profile),
    ));
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(
        source: source,
        maxWidth: 1000,
        maxHeight: 1000,
        imageQuality: 85,
      );

      if (pickedFile != null) {
        final profile = ref.read(userProfileProvider);
        ref
            .read(userProfileProvider.notifier)
            .updateProfile(profile.copyWith(profileImagePath: pickedFile.path));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to pick image: $e')),
        );
      }
    }
  }

  void _onCameraPressed() {
    ProfileImagePickerSheet.show(
      context,
      onTakePhoto: () => _pickImage(ImageSource.camera),
      onChooseFromGallery: () => _pickImage(ImageSource.gallery),
    );
  }

  void _onLogoutPressed() {
    // TODO: call your auth logout logic
  }

  @override
  Widget build(BuildContext context) {
    final profile = ref.watch(userProfileProvider);

    return AppShell(
      title: 'Profile',
      padding: EdgeInsets.zero,
      showAppBar: false,
      child: Column(
        children: [
          _ProfileHeader(
            profile: profile,
            onEdit: () => _onEditPressed(profile),
            onCamera: _onCameraPressed,
            onLogout: _onLogoutPressed,
          ),
          const SizedBox(height: AppSpacing.xl),
          _InfoSection(
            icon: Icons.person_outline,
            iconSize: 14,
            title: 'Identity',
            rows: [
              _InfoRow('Employee Code', profile.employeeCode),
              _InfoRow('Employee Name', profile.name),
              if (profile.dateOfBirth != null)
                _InfoRow('Date of Birth', profile.dateOfBirth!),
              _InfoRow(
                'Employee Status',
                profile.employeeStatus,
                valueWidget: _StatusBadge(profile.employeeStatus),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xl),
          _InfoSection(
            icon: Icons.phone_outlined,
            iconSize: 14,
            title: 'Contact',
            rows: [
              if (profile.workEmail != null)
                _InfoRow('Work Email', profile.workEmail!),
              if (profile.personalEmail != null)
                _InfoRow('Personal Email', profile.personalEmail!),
              if (profile.contactNumber != null)
                _InfoRow('Contact Number', profile.contactNumber!),
              if (profile.whatsappNumber != null)
                _InfoRow('WhatsApp Number', profile.whatsappNumber!),
              if (profile.address != null)
                _InfoRow('Address', profile.address!),
              if (profile.emergencyContactName != null)
                _InfoRow(
                  'Emergency Contact',
                  '${profile.emergencyContactName}\n${profile.emergencyContactNumber ?? ''}',
                ),
            ],
          ),
          const SizedBox(height: AppSpacing.xl),
          _InfoSection(
            icon: Icons.work_outline,
            title: 'Job & Reporting',
            iconSize: 15,
            rows: [
              _InfoRow('Department', profile.department),
              _InfoRow('Designation', profile.designation),
              _InfoRow('Role', profile.role),
              if (profile.reportingManager != null)
                _InfoRow('Reporting Manager', profile.reportingManager!),
              if (profile.workType != null)
                _InfoRow('Work Type', profile.workType!),
              if (profile.officeLocation != null)
                _InfoRow('Office Location', profile.officeLocation!),
              if (profile.shiftPolicy != null)
                _InfoRow('Shift Policy', profile.shiftPolicy!),
              if (profile.joiningDate != null)
                _InfoRow('Joining Date', profile.joiningDate!),
            ],
          ),
          const SizedBox(height: AppSpacing.xl),
          _LogoutButton2(
            onTap: _onLogoutPressed,
            icon: Icons.logout_rounded,
          ),
          const SizedBox(height: AppSpacing.xl * 2),
        ],
        ),
    );
  }
}

// ---------------------------------------------------------------------------
// Header widget
// ---------------------------------------------------------------------------
class _ProfileHeader extends StatelessWidget {
  const _ProfileHeader({
    required this.profile,
    required this.onEdit,
    required this.onCamera,
    required this.onLogout,
  });

  final UserProfileModel profile;
  final VoidCallback onEdit;
  final VoidCallback onCamera;
  final VoidCallback onLogout;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(
        20.0,
        MediaQuery.of(context).padding.top + 20.0,
        20.0,
        24.0,
      ),
      decoration: const BoxDecoration(

        color: const Color(0xFF11141E),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(32),
          bottomRight: Radius.circular(32),
        ),
      ),
      child: Column(
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ),
              const Text(
                'Profile',
                style: TextStyle(
                  color: Colors.white,
                  fontFamily: 'PlayfairDisplay',
                  fontSize: 24,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          Stack(
            children: [
              CircleAvatar(
                radius: 48,
                backgroundColor: Colors.white,
                child: CircleAvatar(
                  radius: 44,
                  backgroundColor: AppColors.primary,
                  backgroundImage: profile.profileImagePath != null
                      ? (profile.profileImagePath!.startsWith('assets/')
                          ? AssetImage(profile.profileImagePath!) as ImageProvider
                          : FileImage(File(profile.profileImagePath!)))
                      : null,
                  child: profile.profileImagePath == null
                      ? Text(
                          profile.initials,
                          style: AppTypography.headlineMedium.copyWith(
                            color: Colors.white,
                          ),
                        )
                      : null,
                ),
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: GestureDetector(
                  onTap: onCamera,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFFFFF),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: const Color(0xFF2D3133),
                        width: 2,
                      ),
                    ),
                    child: const Icon(
                      Icons.camera_alt_outlined,
                      size: 15,
                      color: const Color(0xFF3525CD),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            profile.name,
            style: AppTypography.headlineSmall.copyWith(color: Colors.white,
            fontFamily: 'DMSans',
            fontSize: 16,
            fontWeight: FontWeight.w400,),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            '${profile.designation} • ${profile.department}',
            style: AppTypography.bodyMedium.copyWith(
              color: Colors.white,
              fontFamily: 'DMSans',
              fontSize: 16,
              fontWeight: FontWeight.w400,
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _HeaderButton(
                icon: Icons.edit_outlined,
                label: 'Edit',
                onTap: onEdit,
              ),
              const SizedBox(width: AppSpacing.md),
              _HeaderButton(
                icon: Icons.logout,
                label: 'Logout',
                onTap: onLogout,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _HeaderButton extends StatelessWidget {
  const _HeaderButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: onTap,
      icon: Icon(icon, size: 16),
      label: Text(label),
      style: OutlinedButton.styleFrom(
        backgroundColor: const Color(0xFF1F2937),
        foregroundColor: Colors.white,

        side: const BorderSide(color: const Color(0xFF1F2937)),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.sm,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(999),
        ),
        textStyle: AppTypography.labelMedium.copyWith(
          color: Colors.white,
          fontFamily: 'DMSans',
          fontSize: 14,
          fontWeight: FontWeight.w400,
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Info section card
// ---------------------------------------------------------------------------
class _InfoSection extends StatelessWidget {
  const _InfoSection({
    required this.icon,
    required this.title,
    required this.rows,
    required this.iconSize,
  });

  final IconData icon;
  final String title;
  final double iconSize;
  final List<_InfoRow> rows;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.md,
              AppSpacing.md,
              AppSpacing.md,
              AppSpacing.sm,
            ),
            child: Row(
              children: [
                Icon(icon, size: iconSize, color: const Color(0xFF464555)),
                const SizedBox(width: AppSpacing.sm),
                Text(title, style: AppTypography.labelLarge.copyWith(color: Colors.black,
                  fontFamily: 'DMSans',
                  fontSize: 16,
                  fontWeight: FontWeight.w600,)
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          ...rows.map((row) => _buildRow(row)).toList(),
        ],
      ),
    );
  }

  Widget _buildRow(_InfoRow row) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.sm + 2,
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 4,
                child: Text(
                  row.label,
                  style: AppTypography.bodySmall.copyWith(
                    color: const Color(0xFF464555),
                    fontFamily: 'DMSans',
                    fontSize: 14,
                    fontWeight: FontWeight.w400,

                  ),
                ),
              ),
              Expanded(
                flex: 5,
                child: row.valueWidget ??
                    Text(
                      row.value,
                      style: AppTypography.bodySmall.copyWith(
                        color: const Color(0xFF191C1E),
                        fontFamily: 'DMSans',
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                      textAlign: TextAlign.right,
                    ),
              ),
            ],
          ),
        ),
        const Divider(height: 1, indent: AppSpacing.md),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Logout Button
// ---------------------------------------------------------------------------
class _LogoutButton2 extends StatelessWidget {
  const _LogoutButton2({
    required this.onTap,
    this.label = 'Log Out',
    this.icon,
    this.height = 54,
    this.width = double.infinity,
    this.backgroundColor = const Color(0xFFFEE2E2),
    this.foregroundColor = const Color(0xFFDC2626),
    this.fontSize = 16,
    this.borderRadius = 12,
    this.fontWeight = FontWeight.w600,
  });

  final VoidCallback onTap;
  final String label;
  final IconData? icon;
  final double height;
  final double width;
  final Color backgroundColor;
  final Color foregroundColor;
  final double fontSize;
  final double borderRadius;
  final FontWeight fontWeight;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      margin: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      child: TextButton(
        onPressed: onTap,
        style: TextButton.styleFrom(
          backgroundColor: backgroundColor,
          foregroundColor: foregroundColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadius),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (icon != null) ...[
              Icon(icon, size: fontSize + 4),
              const SizedBox(width: 8),
            ],
            Text(
              label,
              style: TextStyle(
                fontSize: fontSize,
                fontWeight: fontWeight,
                fontFamily: 'DMSans',
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoRow {
  const _InfoRow(this.label, this.value, {this.valueWidget});
  final String label;
  final String value;
  final Widget? valueWidget;
}

// ---------------------------------------------------------------------------
// Status badge
// ---------------------------------------------------------------------------
class _StatusBadge extends StatelessWidget {
  const _StatusBadge(this.status);
  final String status;

  @override
  Widget build(BuildContext context) {
    final isActive = status.toLowerCase() == 'active';
    return Align(
      alignment: Alignment.centerRight,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
        decoration: BoxDecoration(
          color: isActive
              ? const Color(0x1A006C49)
              : const Color(0x33EF4444),//#EF444433
          //
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 6,
              height: 6,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isActive ? const Color(0xFF006C49) : const Color(0xFFEF4444),
              ),
            ),
            const SizedBox(width: 4),
            Text(
              status,
              style: AppTypography.labelSmall.copyWith(
                color: isActive ? const Color(0xFF006C49) : const Color(0xFFEF4444),
              ),
            ),
          ],
        ),
      ),
    );
  }
}