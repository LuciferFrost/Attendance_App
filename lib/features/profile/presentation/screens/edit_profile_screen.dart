import 'dart:io';

import 'package:demo4/core/theme/app_colors.dart';
import 'package:demo4/core/theme/app_spacing.dart';
import 'package:demo4/core/theme/app_typography.dart';
import 'package:demo4/features/profile/data/models/user_profile_model.dart';
import 'package:demo4/features/profile/presentation/widgets/profile_image_picker_sheet.dart';
import 'package:demo4/features/profile/presentation/providers/user_profile_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

class EditProfileScreen extends ConsumerStatefulWidget {
  const EditProfileScreen({super.key, required this.profile});

  final UserProfileModel profile;

  @override
  ConsumerState<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  late final TextEditingController _personalEmailCtrl;
  late final TextEditingController _emergencyNameCtrl;
  late final TextEditingController _emergencyNumberCtrl;
  String? _profileImagePath;

  final _formKey = GlobalKey<FormState>();
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _personalEmailCtrl =
        TextEditingController(text: widget.profile.personalEmail ?? '');
    _emergencyNameCtrl =
        TextEditingController(text: widget.profile.emergencyContactName ?? '');
    _emergencyNumberCtrl =
        TextEditingController(text: widget.profile.emergencyContactNumber ?? '');
    _profileImagePath = widget.profile.profileImagePath;
  }

  @override
  void dispose() {
    _personalEmailCtrl.dispose();
    _emergencyNameCtrl.dispose();
    _emergencyNumberCtrl.dispose();
    super.dispose();
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
        setState(() {
          _profileImagePath = pickedFile.path;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to pick image: $e')),
        );
      }
    }
  }

  void _onChangePhoto() {
    ProfileImagePickerSheet.show(
      context,
      onTakePhoto: () => _pickImage(ImageSource.camera),
      onChooseFromGallery: () => _pickImage(ImageSource.gallery),
    );
  }

  Future<void> _onSave() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _saving = true);

    // Simulate network delay — replace with your actual API call
    await Future.delayed(const Duration(milliseconds: 600));

    final updated = widget.profile.copyWith(
      personalEmail: _personalEmailCtrl.text.trim(),
      emergencyContactName: _emergencyNameCtrl.text.trim(),
      emergencyContactNumber: _emergencyNumberCtrl.text.trim(),
      profileImagePath: _profileImagePath,
    );

    if (mounted) {
      ref.read(userProfileProvider.notifier).updateProfile(updated);
      setState(() => _saving = false);
      Navigator.of(context).pop(updated);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: const Color(0xFF11141E),
        elevation: 0,
        leading: const BackButton(color: Colors.white),
        title: Text(
          'Edit profile',
          style: AppTypography.titleMedium.copyWith(color: Colors.white,
          fontFamily: 'PlayfairDisplay',
          fontWeight: FontWeight.w400,
          fontSize: 24,),
        ),
        centerTitle: true,
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ---- Avatar row ----
              Row(
                children: [
                  Stack(
                    children: [
                      CircleAvatar(
                        radius: 32,
                        backgroundColor: AppColors.primary,
                        backgroundImage: _profileImagePath != null
                            ? (_profileImagePath!.startsWith('assets/')
                                ? AssetImage(_profileImagePath!) as ImageProvider
                                : FileImage(File(_profileImagePath!)))
                            : null,
                        child: _profileImagePath == null
                            ? Text(
                          widget.profile.initials,
                          style: AppTypography.headlineSmall.copyWith(
                            color: Colors.white,
                          ),
                        )
                            : null,
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: GestureDetector(
                          onTap: _onChangePhoto,
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: AppColors.surface,
                              shape: BoxShape.circle,
                              border: Border.all(color: AppColors.border),
                            ),
                            child: Icon(
                              Icons.camera_alt_outlined,
                              size: 14,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Profile photo',
                          style: AppTypography.labelLarge.copyWith(
                      fontFamily: 'DMSans',
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                          color: const Color(0xFF111827))),
                      const SizedBox(height: 2),
                      GestureDetector(
                        onTap: _onChangePhoto,
                        child: Text(
                          'Change photo',
                          style: AppTypography.bodySmall.copyWith(
                            color: const Color(0xFF3B5BDB),
                           //decoration: TextDecoration.underline,
                            fontFamily: 'DMSans',
                            fontSize: 14,
                            fontWeight: FontWeight.w400,

                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: AppSpacing.xl),

              // ---- Section label ----
              Text(
                'YOU CAN EDIT THESE',
                style: AppTypography.labelSmall.copyWith(
                  color: AppColors.textSecondary,
                  letterSpacing: 0.8,
                  fontFamily: 'DMSans',
                  fontWeight: FontWeight.w400,
                  fontSize: 12,
                ),
              ),

              const SizedBox(height: AppSpacing.md),

              // ---- Personal email ----
              _FieldLabel('PERSONAL EMAIL'),
              const SizedBox(height: AppSpacing.xs),
              _ProfileTextField(
                controller: _personalEmailCtrl,
                keyboardType: TextInputType.emailAddress,
                validator: (v) {
                  if (v == null || v.isEmpty) return 'Enter personal email';
                  final valid = RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(v);
                  if (!valid) return 'Enter a valid email';
                  return null;
                },
              ),

              const SizedBox(height: AppSpacing.md),

              // ---- Emergency contact name ----
              _FieldLabel('EMERGENCY CONTACT NAME'),
              const SizedBox(height: AppSpacing.xs),
              _ProfileTextField(
                controller: _emergencyNameCtrl,
                validator: (v) =>
                (v == null || v.isEmpty) ? 'Enter contact name' : null,
              ),

              const SizedBox(height: AppSpacing.md),

              // ---- Emergency contact number ----
              _FieldLabel('EMERGENCY CONTACT NUMBER'),
              const SizedBox(height: AppSpacing.xs),
              _ProfileTextField(
                controller: _emergencyNumberCtrl,
                keyboardType: TextInputType.phone,
                validator: (v) =>
                (v == null || v.isEmpty) ? 'Enter contact number' : null,
              ),

              const SizedBox(height: AppSpacing.xxxl),
              const SizedBox(height: AppSpacing.xxxl),
              const SizedBox(height: AppSpacing.xxxl),
              const SizedBox(height: AppSpacing.xxxl),
              const SizedBox(height: AppSpacing.xxxl),
              const SizedBox(height: AppSpacing.xxxl),
              const SizedBox(height: AppSpacing.xxxl),
              const SizedBox(height: AppSpacing.xxxl),
              const SizedBox(height: AppSpacing.xxxl),
              const SizedBox(height: AppSpacing.xxxl),

              // ---- Save button ----
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _saving ? null : _onSave,
                  icon: _saving
                      ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                      : const Icon(Icons.check, size: 18),
                  label: Text(_saving ? 'Saving…' : 'Save profile'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding:
                    const EdgeInsets.symmetric(vertical: AppSpacing.md),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    textStyle: AppTypography.labelLarge,
                  ),
                ),
              ),

              const SizedBox(height: AppSpacing.sm),

              // ---- Cancel ----
              SizedBox(
                width: double.infinity,
                child: TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text(
                    'Cancel',
                    style: AppTypography.labelLarge.copyWith(
                      color: AppColors.primary,
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

// ---------------------------------------------------------------------------
// Small helpers
// ---------------------------------------------------------------------------
class _FieldLabel extends StatelessWidget {
  const _FieldLabel(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: AppTypography.labelSmall.copyWith(
        color: AppColors.textSecondary,
        letterSpacing: 0.6,
        fontFamily: 'DMSans',
        fontSize: 12,
        fontWeight: FontWeight.w400,
      ),
    );
  }
}

class _ProfileTextField extends StatelessWidget {
  const _ProfileTextField({
    required this.controller,
    this.keyboardType,
    this.validator,
  });

  final TextEditingController controller;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      validator: validator,
      style: AppTypography.bodyMedium,
      decoration: InputDecoration(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm + 2,
        ),
        filled: true,
        fillColor: AppColors.surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: AppColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: AppColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: AppColors.primary, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Colors.red),
        ),
      ),
    );
  }
}