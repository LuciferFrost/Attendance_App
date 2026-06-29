import 'package:flutter/material.dart';
import '../../../../core/theme/app_typography.dart';

/// Dark header shared across all approval sub-screens.
class ApprovalScreenHeader extends StatelessWidget {
  final String title;

  const ApprovalScreenHeader({Key? key, required this.title}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: const BoxDecoration(
        color: Color(0xFF11141E),
      ),
      child: Stack(
        alignment: Alignment.centerLeft,
        children: [
          GestureDetector(
            onTap: () => Navigator.of(context).pop(),
            child: const Icon(Icons.arrow_back, color: Colors.white, size: 22),
          ),
          Center(
            child: Text(
              title,
              style: AppTypography.heading2?.copyWith(
                color: Colors.white,
                fontFamily: 'PlayfairDisplay',
                fontSize: 24,
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
