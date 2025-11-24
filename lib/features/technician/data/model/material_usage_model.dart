// lib/features/admin/data/models/material_usage_model.dart
class MaterialUsageModel {
  final int id;
  final int jobId;
  final int technicianId;
  final String name;
  final double quantity;
  final String unit;
  final double unitPrice;
  final DateTime createdAt;

  MaterialUsageModel({
    required this.id,
    required this.jobId,
    required this.technicianId,
    required this.name,
    required this.quantity,
    required this.unit,
    required this.unitPrice,
    required this.createdAt,
  });

  factory MaterialUsageModel.fromJson(Map<String, dynamic> json) {
    return MaterialUsageModel(
      id: json['id'] as int,
      jobId: json['jobId'] as int,
      technicianId: json['technicianId'] as int,
      name: json['name'] as String,
      quantity: (json['quantity'] as num).toDouble(),
      unit: json['unit'] as String,
      unitPrice: (json['unitPrice'] as num).toDouble(),
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  double get totalPrice => quantity * unitPrice;
}