import 'package:job_management_system/features/admin/data/models/job_model.dart';
import 'package:job_management_system/features/admin/domain/repositories/jobs_repository.dart';

class GetMyTodayJobsUseCase {
  final JobsRepository jobsRepository;

  GetMyTodayJobsUseCase(this.jobsRepository);

  Future<List<JobModel>> call() {
    return jobsRepository.getMyTodayJobs();
  }
}
