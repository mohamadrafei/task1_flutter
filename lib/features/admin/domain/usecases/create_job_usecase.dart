import '../../data/models/create_job_request.dart';
import '../../data/models/job_model.dart';
import '../repositories/jobs_repository.dart';

class CreateJobUseCase {
  final JobsRepository repository;

  CreateJobUseCase(this.repository);

  Future<JobModel> call(CreateJobRequest request) {
    return repository.createJob(request);
  }
}
