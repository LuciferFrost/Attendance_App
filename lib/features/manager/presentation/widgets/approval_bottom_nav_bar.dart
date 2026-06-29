import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';

/// Reusable bottom nav bar for all approval sub-screens.
/// [activeIndex] maps to: 0=Home, 1=Attend., 2=Meetings, 3=Approvals, 4=Profile
class ApprovalBottomNavBar extends StatelessWidget {
  final int activeIndex;
  final int approvalsBadgeCount;

  const ApprovalBottomNavBar({
    Key? key,
    this.activeIndex = 3,
    this.approvalsBadgeCount = 3,
  }) : super(key: key);

  static const _labels = ['Home', 'Attend.', 'Meetings', 'Approvals', 'Profile'];
  static const _icons = [
    Icons.home_rounded,
    Icons.login_rounded,
    Icons.people_outline_rounded,
    Icons.check_box_outlined,
    Icons.person_outline_rounded,
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Color(0xFFE5E7EB))),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: List.generate(_labels.length, (i) => _buildItem(context, i)),
      ),
    );
  }

  Widget _buildItem(BuildContext context, int index) {
    final isActive = index == activeIndex;
    final showBadge = index == 3 && approvalsBadgeCount > 0;

    return GestureDetector(
      onTap: () {
        if (!isActive) Navigator.of(context).pop();
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                Icon(
                  _icons[index],
                  size: 22,
                  color: isActive ? AppColors.primary700 : const Color(0xFF9CA3AF),
                ),
                if (showBadge)
                  Positioned(
                    top: -6,
                    right: -8,
                    child: Container(
                      width: 16,
                      height: 16,
                      decoration: const BoxDecoration(
                        color: Color(0xFFEF4444),
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          '$approvalsBadgeCount',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 9,
                            fontWeight: FontWeight.w700,
                            fontFamily: 'DMSans',
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              _labels[index],
              style: AppTypography.caption?.copyWith(
                fontSize: 10,
                color: isActive ? AppColors.primary700 : const Color(0xFF9CA3AF),
                fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
              ),
            ),
            if (isActive)
              Container(
                margin: const EdgeInsets.only(top: 4),
                width: 20,
                height: 3,
                decoration: BoxDecoration(
                  color: AppColors.primary700,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
          ],
        ),
      ),
    );
  }
}