import '../repositories/jobs_repository.dart';
import '../../data/models/job_model.dart';

class GetMyJobsUseCase {
  final JobsRepository repository;

  GetMyJobsUseCase(this.repository);

  Future<List<JobModel>> call() {
    return repository.getMyJobs();
  }
}
