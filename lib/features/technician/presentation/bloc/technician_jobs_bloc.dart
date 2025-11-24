import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:job_management_system/features/admin/data/models/job_model.dart';
import 'package:job_management_system/features/admin/domain/usecases/get_my_jobs_usecase.dart';
import 'package:job_management_system/features/technician/domain/usecases/update_job_status_usecase.dart';

part 'technician_jobs_event.dart';
part 'technician_jobs_state.dart';

class TechnicianJobsBloc extends Bloc<TechnicianJobsEvent, TechnicianJobsState> {
  final GetMyJobsUseCase getMyJobsUseCase;
  final UpdateJobStatusUseCase updateJobStatusUseCase;

  TechnicianJobsBloc(
    this.getMyJobsUseCase,
    this.updateJobStatusUseCase,
  ) : super(TechnicianJobsInitial()) {
    on<LoadMyJobs>(_onLoadMyJobs);
    on<UpdateJobStatusRequested>(_onUpdateStatus);
  }

  Future<void> _onLoadMyJobs(
    LoadMyJobs event,
    Emitter<TechnicianJobsState> emit,
  ) async {
    emit(TechnicianJobsLoading());
    try {
      final jobs = await getMyJobsUseCase();
      emit(TechnicianJobsLoaded(jobs));
    } catch (e) {
      emit(TechnicianJobsError(e.toString()));
    }
  }

  Future<void> _onUpdateStatus(
    UpdateJobStatusRequested event,
    Emitter<TechnicianJobsState> emit,
  ) async {
    try {
      // optionally show small loading, but we’ll keep current list
      await updateJobStatusUseCase(
        jobId: event.jobId,
        status: event.newStatus,
      );

      // After success, reload jobs so UI reflects new status
      final jobs = await getMyJobsUseCase();
      emit(TechnicianJobsLoaded(jobs));
    } catch (e) {
      emit(TechnicianJobsError('Failed to update status: $e'));
    }
  }
}
