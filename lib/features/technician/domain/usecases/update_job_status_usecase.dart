import 'package:job_management_system/features/admin/domain/repositories/jobs_repository.dart';

class UpdateJobStatusUseCase {
  final JobsRepository repository;

  UpdateJobStatusUseCase(this.repository);

  Future<void> call({
    required int jobId,
    required String status,
  }) {
    return repository.updateJobStatus(
      jobId: jobId,
      status: status,
    );
  }
}
