import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../providers/my_requests_provider.dart';

// ---------------------------------------------------------------------------
// Screen
// ---------------------------------------------------------------------------

class MyRequestsScreen extends ConsumerStatefulWidget {
  const MyRequestsScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<MyRequestsScreen> createState() => _MyRequestsScreenState();
}

class _MyRequestsScreenState extends ConsumerState<MyRequestsScreen> {
  String _selectedFilter = 'All';

  static const _filters = ['All', 'Pending', 'Approved', 'Rejected'];

  @override
  Widget build(BuildContext context) {
    final requestsState = ref.watch(myRequestsProvider);
    final filteredRequests = requestsState.byFilter(_selectedFilter);

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context),
            _buildFilterTabs(),
            Expanded(
              child: requestsState.isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : requestsState.error != null
                  ? _buildErrorState(requestsState.error!)
                  : filteredRequests.isEmpty
                  ? _buildEmptyState()
                  : RefreshIndicator(
                onRefresh: () =>
                    ref.read(myRequestsProvider.notifier).refresh(),
                child: ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                  itemCount: filteredRequests.length,
                  itemBuilder: (context, index) =>
                      _buildRequestCard(filteredRequests[index]),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Header ────────────────────────────────────────────────────────────────

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: const BoxDecoration(color: Color(0xFF11141E)),
      child: Stack(
        alignment: Alignment.centerLeft,
        children: [
          GestureDetector(
            onTap: () => Navigator.of(context).pop(),
            child: const Icon(Icons.arrow_back, color: Colors.white, size: 22),
          ),
          Center(
            child: Text(
              'My Request',
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

  // ── Filter tabs ───────────────────────────────────────────────────────────

  Widget _buildFilterTabs() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: _filters.map((f) {
            final isSelected = f == _selectedFilter;
            return Padding(
              padding: const EdgeInsets.only(right: 10),
              child: GestureDetector(
                onTap: () => setState(() => _selectedFilter = f),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 9),
                  decoration: BoxDecoration(
                    color: isSelected ? AppColors.primary700 : Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                      color: isSelected
                          ? AppColors.primary700
                          : const Color(0xFFE2E8F0),
                    ),
                  ),
                  child: Text(
                    f,
                    style: AppTypography.bodySmall?.copyWith(
                      color: isSelected ? Colors.white : const Color(0xFF64748B),
                      fontWeight: FontWeight.w600,
                      fontFamily: 'DMSans',
                      fontSize: 13,
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  // ── Empty state ───────────────────────────────────────────────────────────

  Widget _buildErrorState(String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline_rounded, color: Color(0xFFDC2626), size: 40),
            const SizedBox(height: 12),
            Text(
              'Couldn\'t load your requests',
              style: AppTypography.bodyMedium?.copyWith(
                color: const Color(0xFF1E293B),
                fontFamily: 'DMSans',
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              message,
              textAlign: TextAlign.center,
              style: AppTypography.bodySmall?.copyWith(
                color: const Color(0xFF94A3B8),
                fontFamily: 'DMSans',
              ),
            ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: () => ref.read(myRequestsProvider.notifier).refresh(),
              child: const Text('Try again'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.inbox_outlined, color: Color(0xFFD1D5DB), size: 48),
            const SizedBox(height: 12),
            Text(
              'No $_selectedFilter requests',
              style: AppTypography.bodyMedium?.copyWith(
                color: const Color(0xFF94A3B8),
                fontFamily: 'DMSans',
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Request card ──────────────────────────────────────────────────────────

  Widget _buildRequestCard(MyRequestItem r) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFF1F5F9)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x08000000),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Tags row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                decoration: BoxDecoration(
                  color: r.typeTagBg,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  r.typeTag,
                  style: AppTypography.caption?.copyWith(
                    color: r.typeTagColor,
                    fontWeight: FontWeight.w600,
                    fontFamily: 'DMSans',
                    fontSize: 12,
                  ),
                ),
              ),
              _buildStatusBadge(r.status),
            ],
          ),
          const SizedBox(height: 14),
          // Title
          Text(
            r.title,
            style: AppTypography.bodyMedium?.copyWith(
              color: const Color(0xFF1E293B),
              fontWeight: FontWeight.w700,
              fontFamily: 'DMSans',
              fontSize: 15,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            r.dateLine,
            style: AppTypography.bodySmall?.copyWith(
              color: const Color(0xFF94A3B8),
              fontFamily: 'DMSans',
              fontWeight: FontWeight.w500,
              fontSize: 12,
              letterSpacing: 0.3,
            ),
          ),
          const SizedBox(height: 12),
          const Divider(height: 1, color: Color(0xFFF1F5F9)),
          const SizedBox(height: 12),
          // Detail rows
          _buildDetailRow(r.detailIcon, r.detailLine),
          const SizedBox(height: 8),
          _buildDetailRow(Icons.person_outline_rounded, r.approverLine),
          const SizedBox(height: 8),
          _buildDetailRow(Icons.calendar_today_outlined, r.submittedLine),
          const SizedBox(height: 16),
          // Detail button
          SizedBox(
            width: double.infinity,
            child: Material(
              color: const Color(0xFFEEF2FF),
              borderRadius: BorderRadius.circular(10),
              child: InkWell(
                borderRadius: BorderRadius.circular(10),
                onTap: () {
                  // TODO: navigate to full request detail screen
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.visibility_outlined,
                          color: Color(0xFF4338CA), size: 16),
                      const SizedBox(width: 6),
                      Text(
                        'Detail',
                        style: AppTypography.bodySmall?.copyWith(
                          color: const Color(0xFF4338CA),
                          fontWeight: FontWeight.w600,
                          fontFamily: 'DMSans',
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 15, color: const Color(0xFF94A3B8)),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: AppTypography.bodySmall?.copyWith(
              color: const Color(0xFF64748B),
              fontFamily: 'DMSans',
              fontWeight: FontWeight.w400,
              fontSize: 13,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStatusBadge(RequestStatus status) {
    late final String label;
    late final Color color;
    late final Color bg;
    late final IconData icon;

    switch (status) {
      case RequestStatus.pending:
        label = 'Pending';
        color = const Color(0xFFB45309);
        bg = const Color(0xFFFEF3C7);
        icon = Icons.access_time_rounded;
        break;
      case RequestStatus.approved:
        label = 'Approved';
        color = const Color(0xFF059669);
        bg = const Color(0xFFD1FAE5);
        icon = Icons.check_circle_outline_rounded;
        break;
      case RequestStatus.rejected:
        label = 'Rejected';
        color = const Color(0xFFDC2626);
        bg = const Color(0xFFFEE2E2);
        icon = Icons.cancel_outlined;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: AppTypography.caption?.copyWith(
              color: color,
              fontWeight: FontWeight.w600,
              fontFamily: 'DMSans',
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }
}