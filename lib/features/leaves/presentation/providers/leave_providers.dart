import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/repositories/dummy_leave_repository.dart';
import '../../domain/entities/leave_balance.dart';
import '../../domain/entities/leave_request.dart';

// ---------------------------------------------------------------------------
// Repository provider
// ---------------------------------------------------------------------------

final leaveRepositoryProvider = Provider<DummyLeaveRepository>(
      (_) => DummyLeaveRepository(),
);

// ---------------------------------------------------------------------------
// Leave balance
// ---------------------------------------------------------------------------

final leaveBalanceProvider = Provider<LeaveBalance>((ref) {
  return ref.read(leaveRepositoryProvider).getLeaveBalance();
});

// ---------------------------------------------------------------------------
// Leave history notifier
// ---------------------------------------------------------------------------

/// Holds the list of leave requests and exposes a method to append a newly
/// submitted request so the list screen reflects it immediately.
class LeaveHistoryNotifier extends Notifier<List<LeaveRequest>> {
  @override
  List<LeaveRequest> build() {
    return ref.read(leaveRepositoryProvider).getLeaveHistory();
  }

  /// Prepends a freshly submitted [request] to the history list.
  void addRequest(LeaveRequest request) {
    state = [request, ...state];
  }
}

final leaveHistoryProvider =
NotifierProvider<LeaveHistoryNotifier, List<LeaveRequest>>(
  LeaveHistoryNotifier.new,
);

// ---------------------------------------------------------------------------
// Leave submission state
// ---------------------------------------------------------------------------

enum LeaveSubmissionStatus { idle, loading, success, error }

class LeaveSubmissionState {
  final LeaveSubmissionStatus status;
  final LeaveRequest? submittedRequest;
  final String? errorMessage;

  const LeaveSubmissionState({
    this.status = LeaveSubmissionStatus.idle,
    this.submittedRequest,
    this.errorMessage,
  });

  LeaveSubmissionState copyWith({
    LeaveSubmissionStatus? status,
    LeaveRequest? submittedRequest,
    String? errorMessage,
  }) {
    return LeaveSubmissionState(
      status: status ?? this.status,
      submittedRequest: submittedRequest ?? this.submittedRequest,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

class LeaveSubmissionNotifier extends Notifier<LeaveSubmissionState> {
  @override
  LeaveSubmissionState build() => const LeaveSubmissionState();

  Future<void> submit({
    required LeaveType type,
    required DateTime leaveDate,
    String? leaveTiming,
    required String reason,
    String? remarks,
  }) async {
    state = state.copyWith(status: LeaveSubmissionStatus.loading);

    try {
      final request = await ref.read(leaveRepositoryProvider).submitLeave(
        type: type,
        leaveDate: leaveDate,
        leaveTiming: leaveTiming,
        reason: reason,
        remarks: remarks,
      );

      // Add to history immediately
      ref.read(leaveHistoryProvider.notifier).addRequest(request);

      state = state.copyWith(
        status: LeaveSubmissionStatus.success,
        submittedRequest: request,
      );
    } catch (e) {
      state = state.copyWith(
        status: LeaveSubmissionStatus.error,
        errorMessage: e.toString(),
      );
    }
  }

  void reset() {
    state = const LeaveSubmissionState();
  }
}

final leaveSubmissionProvider =
NotifierProvider<LeaveSubmissionNotifier, LeaveSubmissionState>(
  LeaveSubmissionNotifier.new,
);