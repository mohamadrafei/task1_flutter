import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:job_management_system/features/admin/data/datasources/AdminRemoteDataSource.dart';
import 'package:job_management_system/features/admin/data/models/dashboard_summary_model.dart';

import 'create_job_page.dart';
import 'jobs_list_page.dart';

class AdminDashboardPage extends StatefulWidget {
  const AdminDashboardPage({super.key});

  @override
  State<AdminDashboardPage> createState() => _AdminDashboardPageState();
}

class _AdminDashboardPageState extends State<AdminDashboardPage> {
  final sl = GetIt.instance;

  late final AdminRemoteDataSource _adminRemoteDataSource;
  late Future<DashboardSummaryModel> _summaryFuture;

  @override
  void initState() {
    super.initState();
    _adminRemoteDataSource = sl<AdminRemoteDataSource>();
    _summaryFuture = _adminRemoteDataSource.getDashboardSummary();
  }

  Future<void> _refresh() async {
    setState(() {
      _summaryFuture = _adminRemoteDataSource.getDashboardSummary();
    });
  }

  Future<void> _pickDateAndDownloadReport() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: now.subtract(const Duration(days: 365)),
      lastDate: now,
    );

    if (picked != null) {
      try {
        await _adminRemoteDataSource.downloadDailyReport(picked);
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Daily report requested for ${picked.toLocal()}'),
          ),
        );
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to download report: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _refresh,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isWide = constraints.maxWidth > 800;

            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // LEFT: main dashboard content
                Expanded(
                  flex: 3,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Text(
                        'Welcome, Admin',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Stats cards
                      FutureBuilder<DashboardSummaryModel>(
                        future: _summaryFuture,
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const Center(
                              child: Padding(
                                padding: EdgeInsets.all(24.0),
                                child: CircularProgressIndicator(),
                              ),
                            );
                          }

                          if (snapshot.hasError) {
                            return Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Failed to load dashboard: ${snapshot.error}',
                                    style: const TextStyle(color: Colors.red),
                                  ),
                                  const SizedBox(height: 8),
                                  ElevatedButton.icon(
                                    onPressed: _refresh,
                                    icon: const Icon(Icons.refresh),
                                    label: const Text('Retry'),
                                  ),
                                ],
                              ),
                            );
                          }

                          final summary = snapshot.data!;
                         final cards = [
  _DashboardCard(
    title: 'Total Jobs',
    value: summary.totalJobs.toString(),
    icon: Icons.work_outline,
  ),
  _DashboardCard(
    title: 'Jobs Today',
    value: summary.jobsToday.toString(),
    icon: Icons.today_outlined,
  ),
 
  _DashboardCard(
    title: 'Completed Today',
    value: summary.completedToday.toString(),
    icon: Icons.check_circle_outline,
  ),
  _DashboardCard(
    title: 'Materials Cost Today',
    // format with 2 decimals
    value: summary.totalMaterialsCostToday.toStringAsFixed(2),
    icon: Icons.attach_money,
  ),
  _DashboardCard(
    title: 'Technicians',
    value: summary.totalTechnicians.toString(),
    icon: Icons.engineering,
  ),
];


                          if (isWide) {
                            return Wrap(
                              spacing: 16,
                              runSpacing: 16,
                              children: cards
                                  .map(
                                    (c) => SizedBox(
                                      width: (constraints.maxWidth - 64) / 3,
                                      child: c,
                                    ),
                                  )
                                  .toList(),
                            );
                          } else {
                            return Column(
                              children: cards
                                  .map(
                                    (c) => Padding(
                                      padding:
                                          const EdgeInsets.only(bottom: 12),
                                      child: c,
                                    ),
                                  )
                                  .toList(),
                            );
                          }
                        },
                      ),

                      const SizedBox(height: 24),

                      // Daily report section
                      Card(
                        elevation: 2,
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Daily Reports',
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    SizedBox(height: 4),
                                    Text(
                                      'Generate CSV reports for a specific day',
                                      style: TextStyle(color: Colors.grey),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 16),
                              ElevatedButton.icon(
                                icon: const Icon(Icons.download),
                                label: const Text('Download Report'),
                                onPressed: _pickDateAndDownloadReport,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(width: 24),

                // RIGHT: actions (navigation panel)
                if (isWide)
                  Expanded(
                    flex: 1,
                    child: _AdminActionsPanel(),
                  )
                else
                  // On small screens, put actions below instead of side
                  Expanded(
                    flex: 1,
                    child: Align(
                      alignment: Alignment.topCenter,
                      child: _AdminActionsPanel(),
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }
}

/// Small panel with navigation buttons (Create Job, Jobs List, etc.)
class _AdminActionsPanel extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Actions',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              icon: const Icon(Icons.add_task),
              label: const Text('Create Job'),
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => const CreateJobPage(),
                  ),
                );
              },
            ),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              icon: const Icon(Icons.assignment_ind),
              label: const Text('Jobs List / Assign Technician'),
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => const JobsListPage(),
                  ),
                );
              },
            ),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              icon: const Icon(Icons.analytics),
              label: const Text('More Analytics (Later)'),
              onPressed: () {
                // TODO: navigate to future analytics page
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _DashboardCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;

  const _DashboardCard({
    required this.title,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Icon(icon, size: 32),
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(title),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
