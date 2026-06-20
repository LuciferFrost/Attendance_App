// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'dashboard_summary_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_DashboardSummaryModel _$DashboardSummaryModelFromJson(
  Map<String, dynamic> json,
) => _DashboardSummaryModel(
  totalEmployees: (json['totalEmployees'] as num).toInt(),
  onLeave: (json['onLeave'] as num).toInt(),
  newHires: (json['newHires'] as num).toInt(),
  openRoles: (json['openRoles'] as num).toInt(),
  recentActivity: (json['recentActivity'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
);

Map<String, dynamic> _$DashboardSummaryModelToJson(
  _DashboardSummaryModel instance,
) => <String, dynamic>{
  'totalEmployees': instance.totalEmployees,
  'onLeave': instance.onLeave,
  'newHires': instance.newHires,
  'openRoles': instance.openRoles,
  'recentActivity': instance.recentActivity,
};
