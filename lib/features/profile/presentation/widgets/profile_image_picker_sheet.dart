import 'package:demo4/core/theme/app_colors.dart';
import 'package:demo4/core/theme/app_spacing.dart';
import 'package:demo4/core/theme/app_typography.dart';
import 'package:flutter/material.dart';

class ProfileImagePickerSheet extends StatelessWidget {
  const ProfileImagePickerSheet({
    super.key,
    required this.onTakePhoto,
    required this.onChooseFromGallery,
  });

  final VoidCallback onTakePhoto;
  final VoidCallback onChooseFromGallery;

  /// Convenience static method — call this instead of showModalBottomSheet
  static void show(
      BuildContext context, {
        required VoidCallback onTakePhoto,
        required VoidCallback onChooseFromGallery,
      }) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => ProfileImagePickerSheet(
        onTakePhoto: () {
          Navigator.of(context).pop();
          onTakePhoto();
        },
        onChooseFromGallery: () {
          Navigator.of(context).pop();
          onChooseFromGallery();
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.lg,
          AppSpacing.lg,
          AppSpacing.lg,
          AppSpacing.xl,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // ---- Header row ----
            Row(
              children: [
                Text('    Edit Profile', style: AppTypography.titleMedium.copyWith(
                  color: const Color(0xFF111827),
                  fontFamily: 'DMSans',
                  fontWeight: FontWeight.w700,
                  fontSize: 20,
                )),
                const Spacer(),
                GestureDetector(
                  onTap: () => Navigator.of(context).pop(),
                  child: const Icon(Icons.close),
                ),
              ],
            ),

            const SizedBox(height: AppSpacing.lg),

            // ---- Take Photo ----
            _PickerOption(
              icon: Icons.camera_alt_outlined,
              iconBgColor: AppColors.primary.withOpacity(0.12),
              iconColor: AppColors.primary,
              title: 'Take Photo',
              subtitle: 'Use your camera',
              onTap: onTakePhoto,
            ),

            const SizedBox(height: AppSpacing.md),

            // ---- Choose from Gallery ----
            _PickerOption(
              icon: Icons.photo_library_outlined,
              iconBgColor: Colors.purple.withOpacity(0.12),
              iconColor: Colors.purple,
              title: 'Choose from Gallery',
              subtitle: 'JPG or PNG, max 5MB',
              onTap: onChooseFromGallery,
            ),
          ],
        ),
      ),
    );
  }
}

class _PickerOption extends StatelessWidget {
  const _PickerOption({
    required this.icon,
    required this.iconBgColor,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final Color iconBgColor;
  final Color iconColor;
  final String title;
  final String subtitle;
  final VoidCallback onTap;


  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.only(top: 10,right:24,left:24,bottom:0),
        child: Container(
      padding: const EdgeInsets.symmetric(
      horizontal: AppSpacing.md,
        vertical: AppSpacing.md,
      ),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFF3F4F6)), // or Colors.grey.shade200
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: iconBgColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: iconColor, size: 22),
          ),
          const SizedBox(width: AppSpacing.md),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: AppTypography.labelLarge.copyWith(
                fontFamily: 'DMSans',
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF111827)
              )),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: AppTypography.bodySmall.copyWith(
                  color: AppColors.textSecondary,
                  fontFamily: 'DMSans',
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
          ),
        ],
      ),
    ),
      ),
    );
  }
}