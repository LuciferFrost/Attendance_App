import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/repositories/timesheet_repository.dart';
import '../../domain/entities/timesheet_models.dart';

// ─── Repository provider ────────────────────────────────────────────────────

final timesheetRepositoryProvider = Provider<TimesheetRepository>(
      (_) => TimesheetRepository.instance,
);

// ─── Current week ───────────────────────────────────────────────────────────

final timesheetWeekProvider = NotifierProvider<TimesheetWeekNotifier, TimesheetWeek>(
  TimesheetWeekNotifier.new,
);

class TimesheetWeekNotifier extends Notifier<TimesheetWeek> {
  @override
  TimesheetWeek build() {
    return ref.watch(timesheetRepositoryProvider).getCurrentWeek();
  }

  void refresh() {
    state = ref.read(timesheetRepositoryProvider).getCurrentWeek();
  }
}

// ─── Selected day ───────────────────────────────────────────────────────────

final selectedTimesheetDayProvider =
NotifierProvider<SelectedDayNotifier, TimesheetDay?>(
  SelectedDayNotifier.new,
);

class SelectedDayNotifier extends Notifier<TimesheetDay?> {
  @override
  TimesheetDay? build() => null;

  void load(DateTime date) {
    state = ref.read(timesheetRepositoryProvider).getDay(date);
  }

  void saveEntry(DateTime date, TimesheetEntry entry) {
    final repo = ref.read(timesheetRepositoryProvider);
    repo.saveEntry(date, entry);
    state = repo.getDay(date);
  }

  void deleteEntry(DateTime date, String entryId) {
    final repo = ref.read(timesheetRepositoryProvider);
    repo.deleteEntry(date, entryId);
    state = repo.getDay(date);
  }

  void submitDay(DateTime date) {
    final repo = ref.read(timesheetRepositoryProvider);
    repo.submitDay(date);
    state = repo.getDay(date);
  }

  void saveDraft(DateTime date) {
    final repo = ref.read(timesheetRepositoryProvider);
    repo.saveDraft(date);
    state = repo.getDay(date);
  }
}