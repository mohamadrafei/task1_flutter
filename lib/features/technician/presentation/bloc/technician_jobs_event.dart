part of 'technician_jobs_bloc.dart';

abstract class TechnicianJobsEvent extends Equatable {
  const TechnicianJobsEvent();

  @override
  List<Object?> get props => [];
}

class LoadMyJobs extends TechnicianJobsEvent {}

class UpdateJobStatusRequested extends TechnicianJobsEvent {
  final int jobId;
  final String newStatus; // "IN_PROGRESS", "COMPLETED", etc.

  const UpdateJobStatusRequested({
    required this.jobId,
    required this.newStatus,
  });

  @override
  List<Object?> get props => [jobId, newStatus];
}
