import 'package:demo4/features/dashboard/data/datasources/dashboard_remote_data_source.dart';
import 'package:demo4/features/dashboard/data/models/dashboard_summary_model.dart';
import 'package:demo4/features/dashboard/domain/entities/dashboard_summary.dart';
import 'package:demo4/features/dashboard/domain/repositories/dashboard_repository.dart';

class DashboardRepositoryImpl implements DashboardRepository {
  DashboardRepositoryImpl(this._remoteDataSource);

  final DashboardRemoteDataSource _remoteDataSource;

  @override
  Future<DashboardSummary> fetchSummary() async {
    final summary = await _remoteDataSource.fetchSummary();
    return summary.toEntity();
  }
}
