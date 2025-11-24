import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:job_management_system/features/admin/domain/repositories/jobs_repository.dart';
import 'package:job_management_system/features/admin/data/models/job_model.dart';

class JobsListPage extends StatelessWidget {
  const JobsListPage({super.key});

  static final sl = GetIt.instance;

  Future<void> _openAssignDialog(
    BuildContext context,
    int jobId,
  ) async {
    final TextEditingController emailCtrl = TextEditingController();
    final jobsRepo = sl<JobsRepository>();

    await showDialog(
      context: context,
      builder: (dialogCtx) {
        return AlertDialog(
          title: const Text('Assign Technician'),
          content: TextField(
            controller: emailCtrl,
            decoration: const InputDecoration(
              labelText: 'Technician Email',
              hintText: 'tech1@test.com',
            ),
            keyboardType: TextInputType.emailAddress,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogCtx).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                final email = emailCtrl.text.trim();
                if (email.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Please enter a valid email'),
                    ),
                  );
                  return;
                }

                try {
                  await jobsRepo.assignJob(
                    jobId: jobId,
                    technicianEmail: email,
                  );

                  if (context.mounted) {
                    Navigator.of(dialogCtx).pop();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          'Assigned technician $email to job $jobId',
                        ),
                      ),
                    );
                  }
                } catch (e) {
                  if (context.mounted) {
                    Navigator.of(dialogCtx).pop();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Failed to assign job: $e'),
                      ),
                    );
                  }
                }
              },
              child: const Text('Assign'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final jobsRepo = sl<JobsRepository>();

    return Scaffold(
      appBar: AppBar(title: const Text('Jobs List / Assign')),
      body: FutureBuilder<List<JobModel>>(
        // 🔹 Use admin endpoint here, not technician “my jobs”
        future: jobsRepo.getAdminJobs(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Text('Error loading jobs: ${snapshot.error}'),
            );
          }

          final jobs = snapshot.data ?? [];

          if (jobs.isEmpty) {
            return const Center(child: Text('No jobs yet'));
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
                  subtitle: Text('Status: ${job.status}'),
                  trailing: ElevatedButton(
                    onPressed: () => _openAssignDialog(context, job.id),
                    child: const Text('Assign'),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
