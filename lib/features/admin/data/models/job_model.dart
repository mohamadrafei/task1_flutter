// lib/features/admin/data/models/job_model.dart
class JobModel {
  final int id;
  final String title;
  final String? description;
  final String status;
  final String? priority;
  final String? address;
  final int? assignedTechnicianId;
  final DateTime? scheduledStart;
  final DateTime? scheduledEnd;
  final DateTime? workStartedAt;    // ADD THIS
  final DateTime? workCompletedAt;  // ADD THIS

  JobModel({
    required this.id,
    required this.title,
    this.description,
    required this.status,
    this.priority,
    this.address,
    this.assignedTechnicianId,
    this.scheduledStart,
    this.scheduledEnd,
    this.workStartedAt,        // ADD THIS
    this.workCompletedAt,      // ADD THIS
  });

  factory JobModel.fromJson(Map<String, dynamic> json) {
    return JobModel(
      id: json['id'] as int,
      title: json['title'] as String,
      description: json['description'] as String?,
      status: json['status'] as String,
      priority: json['priority'] as String?,
      address: json['address'] as String?,
      assignedTechnicianId: json['assignedTechnicianId'] as int?,
      scheduledStart: json['scheduledStart'] != null
          ? DateTime.parse(json['scheduledStart'] as String)
          : null,
      scheduledEnd: json['scheduledEnd'] != null
          ? DateTime.parse(json['scheduledEnd'] as String)
          : null,
      workStartedAt: json['workStartedAt'] != null
          ? DateTime.parse(json['workStartedAt'] as String)
          : null,
      workCompletedAt: json['workCompletedAt'] != null
          ? DateTime.parse(json['workCompletedAt'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'status': status,
      'priority': priority,
      'address': address,
      'assignedTechnicianId': assignedTechnicianId,
      'scheduledStart': scheduledStart?.toIso8601String(),
      'scheduledEnd': scheduledEnd?.toIso8601String(),
      'workStartedAt': workStartedAt?.toIso8601String(),
      'workCompletedAt': workCompletedAt?.toIso8601String(),
    };
  }
}