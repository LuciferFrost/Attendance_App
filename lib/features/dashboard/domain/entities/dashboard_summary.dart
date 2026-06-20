class DashboardSummary {
  const DashboardSummary({
    required this.totalEmployees,
    required this.onLeave,
    required this.newHires,
    required this.openRoles,
    required this.recentActivity,
  });

  final int totalEmployees;
  final int onLeave;
  final int newHires;
  final int openRoles;
  final List<String> recentActivity;
}
