import '../repositories/jobs_repository.dart';

class AssignJobUseCase {
  final JobsRepository repository;

  AssignJobUseCase(this.repository);

  Future<void> call({
    required int jobId,
    required String technicianEmail,
  }) {
    return repository.assignJob(jobId: jobId, technicianEmail: technicianEmail);
  }
}
