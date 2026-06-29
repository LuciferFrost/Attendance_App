import 'package:flutter_riverpod/flutter_riverpod.dart';

class ManagerTeamStat {
  final int present;
  final int absent;
  final int halfDay;
  final int pending;

  const ManagerTeamStat({
    required this.present,
    required this.absent,
    required this.halfDay,
    required this.pending,
  });
}

class ManagerOverviewState {
  final String date;
  final int teamMemberCount;
  final ManagerTeamStat stats;

  const ManagerOverviewState({
    required this.date,
    required this.teamMemberCount,
    required this.stats,
  });
}

class ManagerOverviewNotifier extends Notifier<ManagerOverviewState> {
  @override
  ManagerOverviewState build() {
    return const ManagerOverviewState(
      date: 'Wednesday, 4 June 2025',
      teamMemberCount: 7,
      stats: ManagerTeamStat(
        present: 4,
        absent: 1,
        halfDay: 1,
        pending: 1,
      ),
    );
  }
}

final managerOverviewProvider =
NotifierProvider<ManagerOverviewNotifier, ManagerOverviewState>(
      () => ManagerOverviewNotifier(),
);