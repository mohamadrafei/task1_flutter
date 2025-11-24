part of 'technician_jobs_bloc.dart';

abstract class TechnicianJobsState extends Equatable {
  const TechnicianJobsState();

  @override
  List<Object?> get props => [];
}

class TechnicianJobsInitial extends TechnicianJobsState {}

class TechnicianJobsLoading extends TechnicianJobsState {}

class TechnicianJobsLoaded extends TechnicianJobsState {
  final List<JobModel> jobs;

  const TechnicianJobsLoaded(this.jobs);

  @override
  List<Object?> get props => [jobs];
}

class TechnicianJobsError extends TechnicianJobsState {
  final String message;

  const TechnicianJobsError(this.message);

  @override
  List<Object?> get props => [message];
}
