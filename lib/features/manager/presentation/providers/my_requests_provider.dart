import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// ---------------------------------------------------------------------------
// Data model
// ---------------------------------------------------------------------------

enum RequestStatus { pending, approved, rejected }

class MyRequestItem {
  final String id;
  final String typeTag;
  final Color typeTagColor;
  final Color typeTagBg;
  final RequestStatus status;
  final String title;
  final String dateLine;
  final IconData detailIcon;
  final String detailLine;
  final String approverLine;
  final String submittedLine;

  const MyRequestItem({
    required this.id,
    required this.typeTag,
    required this.typeTagColor,
    required this.typeTagBg,
    required this.status,
    required this.title,
    required this.dateLine,
    required this.detailIcon,
    required this.detailLine,
    required this.approverLine,
    required this.submittedLine,
  });

  MyRequestItem copyWith({RequestStatus? status}) {
    return MyRequestItem(
      id: id,
      typeTag: typeTag,
      typeTagColor: typeTagColor,
      typeTagBg: typeTagBg,
      status: status ?? this.status,
      title: title,
      dateLine: dateLine,
      detailIcon: detailIcon,
      detailLine: detailLine,
      approverLine: approverLine,
      submittedLine: submittedLine,
    );
  }
}

class MyRequestsState {
  final List<MyRequestItem> requests;
  final bool isLoading;
  final String? error;

  const MyRequestsState({
    this.requests = const [],
    this.isLoading = false,
    this.error,
  });

  MyRequestsState copyWith({
    List<MyRequestItem>? requests,
    bool? isLoading,
    String? error,
  }) {
    return MyRequestsState(
      requests: requests ?? this.requests,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }

  List<MyRequestItem> get pending =>
      requests.where((r) => r.status == RequestStatus.pending).toList();

  List<MyRequestItem> get approved =>
      requests.where((r) => r.status == RequestStatus.approved).toList();

  List<MyRequestItem> get rejected =>
      requests.where((r) => r.status == RequestStatus.rejected).toList();

  List<MyRequestItem> byFilter(String filter) {
    switch (filter) {
      case 'Pending':
        return pending;
      case 'Approved':
        return approved;
      case 'Rejected':
        return rejected;
      default:
        return requests;
    }
  }
}

// ---------------------------------------------------------------------------
// Notifier
// ---------------------------------------------------------------------------

class MyRequestsNotifier extends Notifier<MyRequestsState> {
  @override
  MyRequestsState build() {
    // Seed with sample data matching the design. Replace with a repository
    // call (e.g. `ref.read(requestsRepositoryProvider).fetchMyRequests()`)
    // once the backend endpoint is available.
    return MyRequestsState(
      requests: [
        const MyRequestItem(
          id: 'req_001',
          typeTag: 'Exception',
          typeTagColor: Color(0xFFB45309),
          typeTagBg: Color(0xFFFEF3C7),
          status: RequestStatus.pending,
          title: 'Out-of-Geofence • Client Site Visit',
          dateLine: 'Fri, 6 Jun 2025',
          detailIcon: Icons.apartment_outlined,
          detailLine: 'On-Duty • Client site (BKC, Mumbai)',
          approverLine: 'Sent to: Suresh Nair (Sr. Manager)',
          submittedLine: 'Submitted: 6 Jun • 9:05 AM',
        ),
        const MyRequestItem(
          id: 'req_002',
          typeTag: 'Short leave',
          typeTagColor: Color(0xFF4338CA),
          typeTagBg: Color(0xFFEEF2FF),
          status: RequestStatus.pending,
          title: 'Afternoon short leave',
          dateLine: 'Mon, 9 Jun 2025 • Afternoon',
          detailIcon: Icons.logout_rounded,
          detailLine: 'Early exit • Leave by 3:00 PM',
          approverLine: 'Sent to: Suresh Nair (Sr. Manager)',
          submittedLine: 'Submitted: 7 Jun • 5:30 PM',
        ),
      ],
    );
  }

  /// Re-fetches requests. Wire this to your repository/API once available.
  Future<void> refresh() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      // final requests = await ref.read(requestsRepositoryProvider).fetchMyRequests();
      // state = state.copyWith(requests: requests, isLoading: false);
      state = state.copyWith(isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  /// Optimistically updates a request's status, e.g. after the user cancels
  /// a pending request or a push notification reports a decision.
  void updateStatus(String id, RequestStatus status) {
    state = state.copyWith(
      requests: [
        for (final r in state.requests)
          if (r.id == id) r.copyWith(status: status) else r,
      ],
    );
  }
}

final myRequestsProvider =
NotifierProvider<MyRequestsNotifier, MyRequestsState>(
      () => MyRequestsNotifier(),
);