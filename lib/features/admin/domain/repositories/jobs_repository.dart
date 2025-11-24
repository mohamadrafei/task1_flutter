import 'dart:io';

import 'package:job_management_system/features/technician/data/model/material_usage_model.dart';

import '../../data/models/create_job_request.dart';
import '../../data/models/job_model.dart';

abstract class JobsRepository {
  Future<JobModel> createJob(CreateJobRequest request);
  Future<void> assignJob({
    required int jobId,
    required String technicianEmail,
  });
  Future<List<JobModel>> getMyJobs(); // <- new
  Future<List<JobModel>> getMyTodayJobs();
 Future<void> updateJobStatus({
    required int jobId,
    required String status,
  }); 
  Future<String> uploadJobPhoto({
    required int jobId,
    required File file,
  });
   Future<void> startWork(int jobId);
  Future<void> completeWork(int jobId); 
   Future<MaterialUsageModel> addMaterial({
    required int jobId,
    required String name,
    required double quantity,
    required String unit,
    required double unitPrice,
  });
  
  Future<List<MaterialUsageModel>> getMaterials(int jobId);
  Future<List<JobModel>> getAdminJobs();   // admin

}
