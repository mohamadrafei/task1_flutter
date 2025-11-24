class DashboardSummaryModel {
  final int totalJobs;
  final int jobsToday;
  final int inProgressJobs;
  final int completedToday;
  final int totalTechnicians;
  final double totalMaterialsCostToday; // always non-null in Dart

  DashboardSummaryModel({
    required this.totalJobs,
    required this.jobsToday,
    required this.inProgressJobs,
    required this.completedToday,
    required this.totalTechnicians,
    required this.totalMaterialsCostToday,
  });

  factory DashboardSummaryModel.fromJson(Map<String, dynamic> json) {
    final dynamic rawCost = json['totalMaterialsCostToday'];

    double parsedCost;
    if (rawCost == null) {
      parsedCost = 0.0;
    } else if (rawCost is num) {
      parsedCost = rawCost.toDouble();
    } else if (rawCost is String) {
      parsedCost = double.tryParse(rawCost) ?? 0.0;
    } else {
      parsedCost = 0.0;
    }

    return DashboardSummaryModel(
      totalJobs: json['totalJobs'] as int? ?? 0,
      jobsToday: json['jobsToday'] as int? ?? 0,
      inProgressJobs: json['inProgressJobs'] as int? ?? 0,
      completedToday: json['completedToday'] as int? ?? 0,
      totalTechnicians: json['totalTechnicians'] as int? ?? 0,
      totalMaterialsCostToday: parsedCost,
    );
  }
}
