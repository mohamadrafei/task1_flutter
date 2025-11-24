import 'dart:io';

import 'package:job_management_system/features/technician/data/model/material_usage_model.dart';

import '../../domain/repositories/jobs_repository.dart';
import '../datasources/jobs_remote_data_source.dart';
import '../models/create_job_request.dart';
import '../models/job_model.dart';

class JobsRepositoryImpl implements JobsRepository {
  final JobsRemoteDataSource remoteDataSource;

  JobsRepositoryImpl({required this.remoteDataSource});

  @override
  Future<JobModel> createJob(CreateJobRequest request) {
    return remoteDataSource.createJob(request);
  }
  @override
  Future<List<JobModel>> getMyTodayJobs() {
    return remoteDataSource.getMyTodayJobs();
  }

  @override
  Future<void> assignJob({
    required int jobId,
    required String technicianEmail,
  }) {
    return remoteDataSource.assignJob(
      jobId: jobId,
      technicianEmail: technicianEmail,
    );
  }
   @override
Future<List<JobModel>> getMyJobs() {
  return remoteDataSource.getMyJobs();
}
@override
  Future<void> updateJobStatus({
    required int jobId,
    required String status,
  }) {
    return remoteDataSource.updateJobStatus(
      jobId: jobId,
      status: status,
    );
  }
    @override
  Future<String> uploadJobPhoto({
    required int jobId,
    required File file,
  }) {
    return remoteDataSource.uploadJobPhoto(
      jobId: jobId,
      file: file,
    );
  }
  @override
  Future<void> completeWork(int jobId) {
    return remoteDataSource.completeWork(jobId);
  }
   @override
  Future<void> startWork(int jobId){
    return remoteDataSource.startWork(jobId);
  }
  @override
  Future<MaterialUsageModel> addMaterial({
    required int jobId,
    required String name,
    required double quantity,
    required String unit,
    required double unitPrice,
  }) {
    return remoteDataSource.addMaterial(
      jobId: jobId,
      name: name,
      quantity: quantity,
      unit: unit,
      unitPrice: unitPrice,
    );
  }
  @override
  Future<List<JobModel>> getAdminJobs() => remoteDataSource.getAdminJobs();

  @override
  Future<List<MaterialUsageModel>> getMaterials(int jobId) {
    return remoteDataSource.getMaterials(jobId);
  }
}
