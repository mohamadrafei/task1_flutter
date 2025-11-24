import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';

import 'package:job_management_system/features/admin/data/models/job_model.dart';
import 'package:job_management_system/features/admin/domain/usecases/get_my_jobs_usecase.dart';
import 'package:job_management_system/features/admin/domain/usecases/get_my_today_jobs_usecase.dart';
import 'package:job_management_system/features/technician/domain/usecases/update_job_status_usecase.dart';
import 'package:job_management_system/features/technician/presentation/bloc/pages/job_details_page.dart';
import 'package:job_management_system/features/technician/presentation/bloc/technician_jobs_bloc.dart';
class TechnicianHomePage extends StatefulWidget {
  const TechnicianHomePage({super.key});

  @override
  State<TechnicianHomePage> createState() => _TechnicianHomePageState();
}

class _TechnicianHomePageState extends State<TechnicianHomePage> {
  final sl = GetIt.instance;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          TechnicianJobsBloc(sl<GetMyJobsUseCase>(),    sl<UpdateJobStatusUseCase>(),
)..add(LoadMyJobs()),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('My Assigned Jobs'),
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: () {
                context.read<TechnicianJobsBloc>().add(LoadMyJobs());
              },
            ),
          ],
        ),
        body: BlocBuilder<TechnicianJobsBloc, TechnicianJobsState>(
          builder: (context, state) {
            if (state is TechnicianJobsLoading) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is TechnicianJobsError) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline, size: 48, color: Colors.red),
                    const SizedBox(height: 16),
                    Text('Error: ${state.message}'),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        context.read<TechnicianJobsBloc>().add(LoadMyJobs());
                      },
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              );
            } else if (state is TechnicianJobsLoaded) {
              final jobs = state.jobs;

              if (jobs.isEmpty) {
                return const Center(
                  child: Text('No jobs assigned yet.'),
                );
              }

              return ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: jobs.length,
                separatorBuilder: (_, __) => const SizedBox(height: 8),
                itemBuilder: (context, index) {
                  final job = jobs[index];
                  return Card(
  child: ListTile(
    title: Text(job.title),
    subtitle: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Status: ${job.status}'),
        if (job.address != null) Text('Address: ${job.address}'),
        if (job.description != null) Text('Description: ${job.description}'),
      ],
    ),
    trailing: PopupMenuButton<String>(
      onSelected: (value) {
        // value is e.g. "IN_PROGRESS"
        context.read<TechnicianJobsBloc>().add(
              UpdateJobStatusRequested(
                jobId: job.id,
                newStatus: value,
              ),
            );
      },
      itemBuilder: (context) => const [
        PopupMenuItem(
          value: 'IN_PROGRESS',
          child: Text('Mark In Progress'),
        ),
        PopupMenuItem(
          value: 'COMPLETED',
          child: Text('Mark Completed'),
        ),
        PopupMenuItem(
          value: 'CANCELLED',
          child: Text('Mark Cancelled'),
        ),
      ],
      child: const Icon(Icons.more_vert),
       
    ),onTap: () {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => JobDetailsPage(
             jobId: job.id,
        title: job.title,
        status: job.status,
        address: job.address,
        description: job.description,
            
            ),
        ),
      );
    },
  ),
  
);

                  
                },
              );
            }

            return const Center(child: CircularProgressIndicator());
          },
        ),
      ),
    );
  }
}
