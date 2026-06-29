import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../providers/manager_overview_provider.dart';

// ---------------------------------------------------------------------------
// Dummy employee data (replace with real provider / API later)
// ---------------------------------------------------------------------------

enum _AttendanceStatus { present, absent, halfDay, pending, hybridOffice, shortLeave, wfh }

class _Employee {
  final String initials;
  final Color avatarColor;
  final String name;
  final String subtitle;
  final String? badge; // e.g. "1h 45m" pending badge
  final _AttendanceStatus status;

  const _Employee({
    required this.initials,
    required this.avatarColor,
    required this.name,
    required this.subtitle,
    this.badge,
    required this.status,
  });
}

const _dummyEmployees = [
  _Employee(
    initials: 'PR',
    avatarColor: Color(0xFF818CF8),
    name: 'Priya Ramesh',
    subtitle: '09:45 AM · IN_OFFICE',
    status: _AttendanceStatus.present,
  ),
  _Employee(
    initials: 'AK',
    avatarColor: Color(0xFFFBBF24),
    name: 'Aditya Kumar',
    subtitle: 'Outside geofence · WFH reason',
    badge: '1h 45m',
    status: _AttendanceStatus.pending,
  ),
  _Employee(
    initials: 'SM',
    avatarColor: Color(0xFF34D399),
    name: 'Sneha Mehta',
    subtitle: '10:15 AM · HYBRID',
    status: _AttendanceStatus.hybridOffice,
  ),
  _Employee(
    initials: 'RJ',
    avatarColor: Color(0xFFF87171),
    name: 'Rahul Joshi',
    subtitle: 'No check-in recorded',
    status: _AttendanceStatus.absent,
  ),
  _Employee(
    initials: 'DV',
    avatarColor: Color(0xFFC084FC),
    name: 'Divya Venkat',
    subtitle: '11:05 AM · Short leave',
    status: _AttendanceStatus.shortLeave,
  ),
  _Employee(
    initials: 'NK',
    avatarColor: Color(0xFFFBBF24),
    name: 'Nikhil Kapoor',
    subtitle: 'Checked in 10:45 AM',
    status: _AttendanceStatus.halfDay,
  ),
  _Employee(
    initials: 'MS',
    avatarColor: Color(0xFF818CF8),
    name: 'Meera Shah',
    subtitle: 'Permanent WFH',
    status: _AttendanceStatus.wfh,
  ),
];

// ---------------------------------------------------------------------------
// Filter tabs
// ---------------------------------------------------------------------------

enum _Filter { all, present, absent, halfDay, pending }

extension _FilterLabel on _Filter {
  String label(List<_Employee> employees) {
    final count = employees.where(matches).length;
    switch (this) {
      case _Filter.all:
        return 'All ($count)';
      case _Filter.present:
        return 'Present ($count)';
      case _Filter.absent:
        return 'Absent ($count)';
      case _Filter.halfDay:
        return 'Half Day ($count)';
      case _Filter.pending:
        return 'Pending ($count)';
    }
  }

  bool matches(_Employee e) {
    switch (this) {
      case _Filter.all:
        return true;
      case _Filter.present:
        return e.status == _AttendanceStatus.present ||
            e.status == _AttendanceStatus.hybridOffice ||
            e.status == _AttendanceStatus.wfh ||
            e.status == _AttendanceStatus.shortLeave;
      case _Filter.absent:
        return e.status == _AttendanceStatus.absent;
      case _Filter.halfDay:
        return e.status == _AttendanceStatus.halfDay;
      case _Filter.pending:
        return e.status == _AttendanceStatus.pending;
    }
  }
}

// ---------------------------------------------------------------------------
// Status chip helpers
// ---------------------------------------------------------------------------

({String label, Color bg, Color fg}) _chipStyle(_AttendanceStatus s) {
  switch (s) {
    case _AttendanceStatus.present:
      return (label: 'PRESENT', bg: const Color(0xFFE6FCF5), fg: const Color(0xFF099268));
    case _AttendanceStatus.absent:
      return (label: 'ABSENT', bg: const Color(0xFFFFF5F5), fg: const Color(0xFFFA5252));
    case _AttendanceStatus.halfDay:
      return (label: 'HALF DAY', bg: const Color(0xFFFFF4E6), fg: const Color(0xFFFD7E14));
    case _AttendanceStatus.pending:
      return (label: 'PENDING', bg: const Color(0xFFFFF9DB), fg: const Color(0xFFF08C00));
    case _AttendanceStatus.hybridOffice:
      return (label: 'HYBRID OFFICE', bg: const Color(0xFFEDF2FF), fg: const Color(0xFF4263EB));
    case _AttendanceStatus.shortLeave:
      return (label: 'SHORT LEAVE', bg: const Color(0xFFF8F0FC), fg: const Color(0xFFAE3EC9));
    case _AttendanceStatus.wfh:
      return (label: 'WFH', bg: const Color(0xFFF3F0FF), fg: const Color(0xFF7950F2));
  }
}

// ---------------------------------------------------------------------------
// Screen
// ---------------------------------------------------------------------------

class TeamAttendanceScreen extends ConsumerStatefulWidget {
  const TeamAttendanceScreen({super.key});

  @override
  ConsumerState<TeamAttendanceScreen> createState() => _TeamAttendanceScreenState();
}

class _TeamAttendanceScreenState extends ConsumerState<TeamAttendanceScreen> {
  _Filter _activeFilter = _Filter.all;
  String _searchQuery = '';

  List<_Employee> get _filteredEmployees {
    return _dummyEmployees.where((e) {
      final matchesFilter = _activeFilter.matches(e);
      final matchesSearch = _searchQuery.isEmpty ||
          e.name.toLowerCase().contains(_searchQuery.toLowerCase());
      return matchesFilter && matchesSearch;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final overview = ref.watch(managerOverviewProvider);

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context),
            _buildFilterTabs(),
            _buildSearchBar(),
            _buildDateRow(overview),
            Expanded(
              child: _buildEmployeeList(),
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
      decoration: const BoxDecoration(
        color: const Color(0xFF11141E),
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
              'Team Attendance',
              style: AppTypography.heading2?.copyWith(
                color: Colors.white,
                fontFamily: 'PlayfairDisplay',
                fontWeight: FontWeight.w400,
                fontSize: 24,
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
      height: 48,
      color: Colors.white,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        children: _Filter.values.map((f) {
          final isActive = f == _activeFilter;
          return GestureDetector(
            onTap: () => setState(() => _activeFilter = f),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.symmetric(horizontal: 14),
              decoration: BoxDecoration(
                color: isActive ? AppColors.primary700 : Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isActive ? AppColors.primary700 : const Color(0xFFE5E7EB),
                ),
              ),
              child: Center(
                child: Text(
                  f.label(_dummyEmployees),
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

  // ── Search bar ────────────────────────────────────────────────────────────

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
      child: TextField(
        onChanged: (v) => setState(() => _searchQuery = v),
        style: AppTypography.bodyMedium?.copyWith(color: const Color(0xFF111827)),
        decoration: InputDecoration(
          hintText: 'Search employee...',
          hintStyle: AppTypography.bodyMedium?.copyWith(color: const Color(0xFF9CA3AF)),
          prefixIcon: const Icon(Icons.search, color: Color(0xFF9CA3AF), size: 20),
          filled: true,
          fillColor: const Color(0xFFF9FAFB),
          contentPadding: const EdgeInsets.symmetric(vertical: 0),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: AppColors.primary700, width: 1.5),
          ),
        ),
      ),
    );
  }

  // ── Date row ──────────────────────────────────────────────────────────────

  Widget _buildDateRow(ManagerOverviewState overview) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            overview.date,
            style: AppTypography.bodyMedium?.copyWith(
              color: const Color(0xFF111827),
              fontWeight: FontWeight.w600,
            ),
          ),
          Icon(Icons.calendar_month_outlined, color: AppColors.primary700, size: 22),
        ],
      ),
    );
  }

  // ── Employee list ─────────────────────────────────────────────────────────

  Widget _buildEmployeeList() {
    final employees = _filteredEmployees;

    if (employees.isEmpty) {
      return Center(
        child: Text(
          'No employees found',
          style: AppTypography.bodyMedium?.copyWith(color: const Color(0xFF9CA3AF)),
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      itemCount: employees.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (_, i) => _buildEmployeeCard(employees[i]),
    );
  }

  Widget _buildEmployeeCard(_Employee e) {
    final chip = _chipStyle(e.status);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFF3F4F6)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0A000000),
            blurRadius: 6,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Avatar
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: e.avatarColor.withOpacity(0.18),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                e.initials,
                style: TextStyle(
                  color: e.avatarColor,
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  fontFamily: 'DMSans',
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),

          // Name + subtitle + optional badge
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  e.name,
                  style: AppTypography.bodyMedium?.copyWith(
                    color: const Color(0xFF111827),
                    fontWeight: FontWeight.w600,
                    fontFamily: 'DMSans',
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 3),
                Row(
                  children: [
                    if (e.status != _AttendanceStatus.pending &&
                        e.status != _AttendanceStatus.absent &&
                        e.status != _AttendanceStatus.wfh)
                      const Padding(
                        padding: EdgeInsets.only(right: 4),
                        child: Icon(Icons.access_time_rounded,
                            size: 12, color: Color(0xFF9CA3AF)),
                      ),
                    Flexible(
                      child: Text(
                        e.subtitle,
                        style: AppTypography.caption?.copyWith(
                          color: const Color(0xFF9CA3AF),
                          fontSize: 11,
                          fontFamily: 'DMSans',
                          fontWeight: FontWeight.w400,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                if (e.badge != null) ...[
                  const SizedBox(height: 5),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFEF3C7),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.circle, size: 6, color: Color(0xFFF59E0B)),
                        const SizedBox(width: 4),
                        Text(
                          e.badge!,
                          style: AppTypography.caption?.copyWith(
                            color: const Color(0xFFF08C00),
                            fontSize: 10,
                            fontWeight: FontWeight.w400,
                            fontFamily: 'Inter'
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),

          // Status chip
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: chip.bg,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              chip.label,
              style: AppTypography.caption?.copyWith(
                color: chip.fg,
                fontSize: 10.4,
                fontWeight: FontWeight.w600,
                fontFamily: 'DMSans',
                letterSpacing: 0.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}