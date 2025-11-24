class CreateJobRequest {
  final String title;
  final String description;
  final String priority; // "LOW" / "MEDIUM" / "HIGH" / "URGENT"
  final String address;
  final double? latitude;
  final double? longitude;
  final DateTime? scheduledStart;
  final DateTime? scheduledEnd;

  CreateJobRequest({
    required this.title,
    required this.description,
    required this.priority,
    required this.address,
    this.latitude,
    this.longitude,
    this.scheduledStart,
    this.scheduledEnd,
  });

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'description': description,
      'priority': priority,
      'address': address,
      'latitude': latitude,
      'longitude': longitude,
      'scheduledStart': scheduledStart?.toIso8601String(),
      'scheduledEnd': scheduledEnd?.toIso8601String(),
    };
  }
}
