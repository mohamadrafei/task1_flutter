import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:job_management_system/features/admin/data/datasources/jobs_remote_data_source.dart';
import 'package:job_management_system/features/admin/data/models/create_job_request.dart';
import 'package:job_management_system/features/admin/domain/repositories/jobs_repository.dart';

class CreateJobPage extends StatefulWidget {
  const CreateJobPage({super.key});

  @override
  State<CreateJobPage> createState() => _CreateJobPageState();
}

class _CreateJobPageState extends State<CreateJobPage> {
  final _formKey = GlobalKey<FormState>();

  final _titleCtrl = TextEditingController();
  final _descriptionCtrl = TextEditingController();
  final _addressCtrl = TextEditingController();
  final _priorityCtrl = TextEditingController(text: 'MEDIUM');
  final _latCtrl = TextEditingController();
  final _lngCtrl = TextEditingController();
  final _startCtrl = TextEditingController();
  final _endCtrl = TextEditingController();

  bool _isSubmitting = false;
final sl = GetIt.instance;

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descriptionCtrl.dispose();
    _addressCtrl.dispose();
    _priorityCtrl.dispose();
    _latCtrl.dispose();
    _lngCtrl.dispose();
    _startCtrl.dispose();
    _endCtrl.dispose();
    super.dispose();
  }

Future<void> _submit() async {
  if (!(_formKey.currentState?.validate() ?? false)) return;

  setState(() => _isSubmitting = true);

  try {
    final jobsRepo = sl<JobsRepository>();

    final req = CreateJobRequest(
      title: _titleCtrl.text.trim(),
      description: _descriptionCtrl.text.trim(),
      priority: _priorityCtrl.text.trim().toUpperCase(),
      address: _addressCtrl.text.trim(),
      latitude:
          _latCtrl.text.isEmpty ? null : double.tryParse(_latCtrl.text),
      longitude:
          _lngCtrl.text.isEmpty ? null : double.tryParse(_lngCtrl.text),
      scheduledStart: _startCtrl.text.isEmpty ? null : DateTime.tryParse(_startCtrl.text),
      scheduledEnd: _endCtrl.text.isEmpty ? null : DateTime.tryParse(_endCtrl.text),
    );

    final job = await jobsRepo.createJob(req);

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Job created successfully (ID: ${job.id})')),
    );
    Navigator.of(context).pop();
  } catch (e) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Failed to create job: $e')),
    );
  } finally {
    if (mounted) {
      setState(() => _isSubmitting = false);
    }
  }
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Create Job')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _titleCtrl,
                decoration: const InputDecoration(labelText: 'Title'),
                validator: (v) =>
                    v == null || v.isEmpty ? 'Title is required' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _descriptionCtrl,
                decoration: const InputDecoration(labelText: 'Description'),
                maxLines: 3,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _addressCtrl,
                decoration: const InputDecoration(labelText: 'Address'),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _priorityCtrl,
                decoration:
                    const InputDecoration(labelText: 'Priority (LOW/MEDIUM/HIGH)'),
                validator: (v) {
                  if (v == null || v.isEmpty) return 'Priority is required';
                  final upper = v.toUpperCase();
                  if (!['LOW', 'MEDIUM', 'HIGH'].contains(upper)) {
                    return 'Use LOW, MEDIUM or HIGH';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _latCtrl,
                      decoration:
                          const InputDecoration(labelText: 'Latitude (optional)'),
                      keyboardType:
                          const TextInputType.numberWithOptions(decimal: true),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextFormField(
                      controller: _lngCtrl,
                      decoration:
                          const InputDecoration(labelText: 'Longitude (optional)'),
                      keyboardType:
                          const TextInputType.numberWithOptions(decimal: true),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _startCtrl,
                decoration: const InputDecoration(
                  labelText: 'Scheduled Start (YYYY-MM-DDTHH:MM, optional)',
                  hintText: '2025-11-23T10:00',
                ),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _endCtrl,
                decoration: const InputDecoration(
                  labelText: 'Scheduled End (YYYY-MM-DDTHH:MM, optional)',
                  hintText: '2025-11-23T12:00',
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isSubmitting ? null : _submit,
                  child: _isSubmitting
                      ? const CircularProgressIndicator()
                      : const Text('Create Job'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
