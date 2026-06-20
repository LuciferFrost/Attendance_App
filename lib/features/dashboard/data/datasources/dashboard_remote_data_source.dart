import 'package:demo4/core/network/api_client.dart';
import 'package:demo4/features/dashboard/data/models/dashboard_summary_model.dart';

class DashboardRemoteDataSource {
  DashboardRemoteDataSource(this._client);

  final ApiClient _client;

  Future<DashboardSummaryModel> fetchSummary() async {
    if (_client.dio.options.baseUrl.contains('local')) {
      await Future<void>.delayed(const Duration(milliseconds: 500));
      return const DashboardSummaryModel(
        totalEmployees: 1247,
        onLeave: 28,
        newHires: 12,
        openRoles: 34,
        recentActivity: [
          'Leave approved for Priya Mehta',
          'Payroll processed for May 2026',
          '3 new hires onboarded',
        ],
      );
    }

    final response = await _client.dio.get<Map<String, dynamic>>(
      '/dashboard/summary',
    );
    return DashboardSummaryModel.fromJson(response.data!);
  }
}
