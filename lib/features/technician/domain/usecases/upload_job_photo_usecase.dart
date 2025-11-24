import 'dart:io';
import 'package:job_management_system/features/admin/domain/repositories/jobs_repository.dart';

class UploadJobPhotoUseCase {
  final JobsRepository repository;

  UploadJobPhotoUseCase(this.repository);

  Future<String> call({
    required int jobId,
    required File file,
  }) {
    return repository.uploadJobPhoto(jobId: jobId, file: file);
  }
}
