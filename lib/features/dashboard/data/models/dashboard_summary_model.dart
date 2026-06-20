import 'package:demo4/features/dashboard/domain/entities/dashboard_summary.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'dashboard_summary_model.freezed.dart';
part 'dashboard_summary_model.g.dart';

@freezed
abstract class DashboardSummaryModel with _$DashboardSummaryModel {
  const factory DashboardSummaryModel({
    required int totalEmployees,
    required int onLeave,
    required int newHires,
    required int openRoles,
    required List<String> recentActivity,
  }) = _DashboardSummaryModel;

  factory DashboardSummaryModel.fromJson(Map<String, dynamic> json) =>
      _$DashboardSummaryModelFromJson(json);
}

extension DashboardSummaryModelMapper on DashboardSummaryModel {
  DashboardSummary toEntity() {
    return DashboardSummary(
      totalEmployees: totalEmployees,
      onLeave: onLeave,
      newHires: newHires,
      openRoles: openRoles,
      recentActivity: recentActivity,
    );
  }
}
