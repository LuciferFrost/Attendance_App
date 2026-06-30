import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/routing/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';

/// Reusable bottom nav bar for all approval sub-screens.
/// [activeIndex] maps to: 0=Home, 1=Attend., 2=Meetings, 3=Approvals, 4=Profile
class ApprovalBottomNavBar extends StatelessWidget {
  final int activeIndex;

  const ApprovalBottomNavBar({
    Key? key,
    this.activeIndex = 3,
  }) : super(key: key);

  static final List<Map<String, dynamic>> _navItems = [
    {'icon': Icons.home_rounded, 'label': 'Home', 'route': AppRoutes.dashboard},
    {'icon': 'assets/images/home_NavAttend.png', 'label': 'Attend.', 'route': AppRoutes.attendance},
    {'icon': 'assets/images/home_NavMeetings.png', 'label': 'Meetings', 'route': AppRoutes.meetings},
    {'icon': 'assets/images/home_NavApproval.png', 'label': 'Approvals', 'route': AppRoutes.approvals},
    {'icon': 'assets/images/home_NavProfile.png', 'label': 'Profile', 'route': AppRoutes.profile},
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(
            color: Color(0xFFE5E7EB),
            width: 1,
          ),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: List.generate(
          _navItems.length,
          (i) => _buildItem(context, i),
        ),
      ),
    );
  }

  Widget _buildItem(BuildContext context, int index) {
    final item = _navItems[index];
    final isActive = index == activeIndex;
    final dynamic icon = item['icon'];
    final String label = item['label'];

    return GestureDetector(
      onTap: () {
        if (!isActive) {
          context.go(item['route']);
        }
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon is IconData)
              Icon(
                icon,
                size: 20,
                color: isActive ? AppColors.primary700 : const Color(0xFF6B7280),
              )
            else
              Image.asset(
                icon,
                width: 20,
                height: 20,
                color: isActive ? AppColors.primary700 : const Color(0xFF6B7280),
              ),
            const SizedBox(height: 4),
            Text(
              label,
              style: AppTypography.caption?.copyWith(
                fontWeight: FontWeight.w500,
                color: isActive ? AppColors.primary700 : const Color(0xFF6B7280),
                fontSize: 10,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
