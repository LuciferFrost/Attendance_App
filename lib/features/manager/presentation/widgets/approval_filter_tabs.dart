import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';

enum ApprovalFilter { all, pending, approved, rejected }

extension ApprovalFilterLabel on ApprovalFilter {
  String get label {
    switch (this) {
      case ApprovalFilter.all:       return 'All';
      case ApprovalFilter.pending:   return 'Pending';
      case ApprovalFilter.approved:  return 'Approved';
      case ApprovalFilter.rejected:  return 'Rejected';
    }
  }
}

/// Horizontally scrollable filter tab row shared across approval sub-screens.
class ApprovalFilterTabs extends StatelessWidget {
  final ApprovalFilter activeFilter;
  final ValueChanged<ApprovalFilter> onFilterChanged;

  const ApprovalFilterTabs({
    Key? key,
    required this.activeFilter,
    required this.onFilterChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 48,
      color: Colors.white,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        children: ApprovalFilter.values.map((f) {
          final isActive = f == activeFilter;
          return GestureDetector(
            onTap: () => onFilterChanged(f),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: isActive ? AppColors.primary700 : Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isActive ? AppColors.primary700 : const Color(0xFFE5E7EB),
                ),
              ),
              child: Center(
                child: Text(
                  f.label,
                  style: AppTypography.caption?.copyWith(
                    color: isActive ? Colors.white : const Color(0xFF6B7280),
                    fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
                    fontSize: 12,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
