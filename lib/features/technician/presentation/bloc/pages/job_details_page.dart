// lib/features/technician/presentation/pages/job_details_page.dart
import 'dart:io';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

import 'package:job_management_system/features/admin/domain/repositories/jobs_repository.dart';
import 'package:job_management_system/features/technician/data/model/material_usage_model.dart';

class JobDetailsPage extends StatefulWidget {
  final int jobId;
  final String title;
  final String status;
  final String? address;
  final String? description;
  final DateTime? workStartedAt;
  final DateTime? workCompletedAt;

  const JobDetailsPage({
    super.key,
    required this.jobId,
    required this.title,
    required this.status,
    this.address,
    this.description,
    this.workStartedAt,
    this.workCompletedAt,
  });

  @override
  State<JobDetailsPage> createState() => _JobDetailsPageState();
}

class _JobDetailsPageState extends State<JobDetailsPage> {
  final sl = GetIt.instance;
  late JobsRepository jobsRepository;

  String _currentStatus = '';
  bool _isBusy = false;
  DateTime? _workStartTime;
  DateTime? _workEndTime;
  Timer? _timer;
  Duration _elapsedTime = Duration.zero;

  // Materials
  List<MaterialUsageModel> _materials = [];
  bool _isLoadingMaterials = false;

  @override
  void initState() {
    super.initState();
    jobsRepository = sl<JobsRepository>();
    _currentStatus = widget.status;
    _workStartTime = widget.workStartedAt;
    _workEndTime = widget.workCompletedAt;

    // Start timer if work is in progress
    if (_currentStatus == 'IN_PROGRESS' && _workStartTime != null) {
      _startTimer();
    }

    // Load materials
    _loadMaterials();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  // ==================== MATERIALS ====================

  Future<void> _loadMaterials() async {
    setState(() => _isLoadingMaterials = true);
    try {
      final materials = await jobsRepository.getMaterials(widget.jobId);
      if (mounted) {
        setState(() {
          _materials = materials;
          _isLoadingMaterials = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoadingMaterials = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load materials: $e')),
        );
      }
    }
  }

  Future<void> _showAddMaterialDialog() async {
    final nameController = TextEditingController();
    final quantityController = TextEditingController();
    final unitController = TextEditingController(text: 'pcs');
    final priceController = TextEditingController();

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Material'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Material Name *',
                  hintText: 'e.g., Copper Wire',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: quantityController,
                decoration: const InputDecoration(
                  labelText: 'Quantity *',
                  hintText: 'e.g., 10',
                  border: OutlineInputBorder(),
                ),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: unitController,
                decoration: const InputDecoration(
                  labelText: 'Unit *',
                  hintText: 'e.g., meters, pcs, kg',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: priceController,
                decoration: const InputDecoration(
                  labelText: 'Unit Price *',
                  hintText: 'e.g., 25.50',
                  prefixText: '\$ ',
                  border: OutlineInputBorder(),
                ),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (nameController.text.trim().isEmpty ||
                  quantityController.text.trim().isEmpty ||
                  unitController.text.trim().isEmpty ||
                  priceController.text.trim().isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Please fill all fields')),
                );
                return;
              }

              try {
                double.parse(quantityController.text.trim());
                double.parse(priceController.text.trim());
                Navigator.pop(context, true);
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Please enter valid numbers')),
                );
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );

    if (result == true && mounted) {
      setState(() => _isBusy = true);
      try {
        final material = await jobsRepository.addMaterial(
          jobId: widget.jobId,
          name: nameController.text.trim(),
          quantity: double.parse(quantityController.text.trim()),
          unit: unitController.text.trim(),
          unitPrice: double.parse(priceController.text.trim()),
        );

        if (mounted) {
          setState(() {
            _materials.add(material);
            _isBusy = false;
          });

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Material added successfully'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          setState(() => _isBusy = false);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to add material: $e')),
          );
        }
      }
    }
  }

  // ==================== TIME TRACKING ====================

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_workStartTime != null) {
        setState(() {
          _elapsedTime = DateTime.now().difference(_workStartTime!);
        });
      }
    });
  }

  void _stopTimer() {
    _timer?.cancel();
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final hours = twoDigits(duration.inHours);
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$hours:$minutes:$seconds';
  }

  String _formatDateTime(DateTime? dateTime) {
    if (dateTime == null) return 'Not set';
    return DateFormat('MMM dd, yyyy HH:mm:ss').format(dateTime);
  }

  // ==================== JOB ACTIONS ====================

  Future<void> _changeStatus(String newStatus) async {
    setState(() => _isBusy = true);
    try {
      await jobsRepository.updateJobStatus(
        jobId: widget.jobId,
        status: newStatus,
      );

      if (!mounted) return;
      setState(() => _currentStatus = newStatus);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Status updated to $newStatus')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update status: $e')),
      );
    } finally {
      if (mounted) setState(() => _isBusy = false);
    }
  }

  Future<void> _startWork() async {
    setState(() => _isBusy = true);
    try {
      await jobsRepository.startWork(widget.jobId);
      if (!mounted) return;

      final now = DateTime.now();
      setState(() {
        _currentStatus = 'IN_PROGRESS';
        _workStartTime = now;
        _workEndTime = null;
        _elapsedTime = Duration.zero;
      });

      _startTimer();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Work started at ${_formatDateTime(now)}'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to start work: $e')),
      );
    } finally {
      if (mounted) setState(() => _isBusy = false);
    }
  }

  Future<void> _completeWork() async {
    setState(() => _isBusy = true);
    try {
      await jobsRepository.completeWork(widget.jobId);
      if (!mounted) return;

      final now = DateTime.now();
      _stopTimer();

      setState(() {
        _currentStatus = 'COMPLETED';
        _workEndTime = now;
      });

      final totalDuration = _workStartTime != null
          ? now.difference(_workStartTime!)
          : Duration.zero;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Work completed!\nTotal time: ${_formatDuration(totalDuration)}',
          ),
          backgroundColor: Colors.blue,
          duration: const Duration(seconds: 4),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to complete work: $e')),
      );
    } finally {
      if (mounted) setState(() => _isBusy = false);
    }
  }

  Future<void> _uploadPhoto() async {
    try {
      final ImageSource? source = await showDialog<ImageSource>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Choose Image Source'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text('Camera'),
                onTap: () => Navigator.pop(context, ImageSource.camera),
              ),
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Gallery'),
                onTap: () => Navigator.pop(context, ImageSource.gallery),
              ),
            ],
          ),
        ),
      );

      if (source == null) return;

      final picker = ImagePicker();
      final XFile? pickedFile = await picker.pickImage(
        source: source,
        imageQuality: 85,
      );

      if (pickedFile == null) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No image selected')),
        );
        return;
      }

      final File imageFile = File(pickedFile.path);

      setState(() => _isBusy = true);

      try {
        final String photoUrl = await jobsRepository.uploadJobPhoto(
          jobId: widget.jobId,
          file: imageFile,
        );

        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Photo uploaded successfully!\nURL: $photoUrl'),
            duration: const Duration(seconds: 3),
          ),
        );
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to upload photo: $e')),
        );
      } finally {
        if (mounted) setState(() => _isBusy = false);
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  // ==================== BUILD UI ====================

  @override
  Widget build(BuildContext context) {
    final jobId = widget.jobId;

    return Scaffold(
      appBar: AppBar(
        title: Text('Job #$jobId'),
        elevation: 2,
      ),
      body: AbsorbPointer(
        absorbing: _isBusy,
        child: Stack(
          children: [
            SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // BASIC INFO CARD
                  Card(
                    elevation: 2,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.title,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const Divider(height: 24),
                          _buildInfoRow('Job ID', jobId.toString()),
                          const SizedBox(height: 8),
                          _buildInfoRow('Status', _currentStatus),
                          if (widget.address != null) ...[
                            const SizedBox(height: 8),
                            _buildInfoRow('Address', widget.address!),
                          ],
                          if (widget.description != null) ...[
                            const SizedBox(height: 8),
                            _buildInfoRow('Description', widget.description!),
                          ],
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // TIME TRACKING SECTION
                  _buildTimeTrackingSection(),

                  const SizedBox(height: 24),

                  // STATUS UPDATE SECTION
                  const Text(
                    'Update Status',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _buildStatusChip('IN_PROGRESS', 'In Progress', Colors.orange),
                      _buildStatusChip('COMPLETED', 'Completed', Colors.green),
                      _buildStatusChip('CANCELLED', 'Cancelled', Colors.red),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // PHOTO UPLOAD SECTION
                  const Text(
                    'Job Photos',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  ElevatedButton.icon(
                    onPressed: _isBusy ? null : _uploadPhoto,
                    icon: const Icon(Icons.camera_alt),
                    label: const Text('Upload Photo'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // MATERIALS SECTION
                  _buildMaterialsSection(),
                ],
              ),
            ),

            // Loading Overlay
            if (_isBusy)
              Container(
                color: Colors.black26,
                child: const Center(
                  child: Card(
                    child: Padding(
                      padding: EdgeInsets.all(24),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          CircularProgressIndicator(),
                          SizedBox(height: 16),
                          Text('Processing...'),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  // ==================== WIDGET BUILDERS ====================

  Widget _buildTimeTrackingSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Time Tracking',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),

        // Time Display Card
        Card(
          elevation: 1,
          color: _getStatusColor(_currentStatus).withOpacity(0.1),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // Current Timer (if in progress)
                if (_currentStatus == 'IN_PROGRESS' && _workStartTime != null)
                  Column(
                    children: [
                      const Icon(Icons.timer, size: 40, color: Colors.blue),
                      const SizedBox(height: 8),
                      Text(
                        _formatDuration(_elapsedTime),
                        style: const TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue,
                          fontFeatures: [FontFeature.tabularFigures()],
                        ),
                      ),
                      const Text(
                        'Work in Progress',
                        style: TextStyle(color: Colors.grey),
                      ),
                      const Divider(height: 24),
                    ],
                  ),

                // Start Time
                if (_workStartTime != null)
                  _buildTimeRow(
                    icon: Icons.play_arrow,
                    label: 'Started',
                    time: _formatDateTime(_workStartTime),
                    color: Colors.green,
                  ),

                // End Time
                if (_workEndTime != null) ...[
                  const SizedBox(height: 8),
                  _buildTimeRow(
                    icon: Icons.check_circle,
                    label: 'Completed',
                    time: _formatDateTime(_workEndTime),
                    color: Colors.blue,
                  ),
                  const Divider(height: 24),

                  // Total Duration
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.timelapse, color: Colors.orange),
                      const SizedBox(width: 8),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Total Duration',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                            ),
                          ),
                          Text(
                            _formatDuration(
                                _workEndTime!.difference(_workStartTime!)),
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.orange,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],

                // No time tracking yet
                if (_workStartTime == null)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 8),
                    child: Text(
                      'Time tracking will start when work begins',
                      style: TextStyle(color: Colors.grey),
                      textAlign: TextAlign.center,
                    ),
                  ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 16),

        // Action Buttons
        if (_currentStatus == 'ASSIGNED')
          ElevatedButton.icon(
            onPressed: _isBusy ? null : _startWork,
            icon: const Icon(Icons.play_arrow),
            label: const Text('Start Work'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 14),
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
              minimumSize: const Size(double.infinity, 50),
            ),
          )
        else if (_currentStatus == 'IN_PROGRESS')
          ElevatedButton.icon(
            onPressed: _isBusy ? null : _completeWork,
            icon: const Icon(Icons.check_circle),
            label: const Text('Complete Work'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 14),
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
              minimumSize: const Size(double.infinity, 50),
            ),
          )
        else if (_currentStatus == 'COMPLETED')
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.green.shade50,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.green, width: 2),
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.check_circle, color: Colors.green),
                SizedBox(width: 8),
                Text(
                  'Job Completed',
                  style: TextStyle(
                    color: Colors.green,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildMaterialsSection() {
    final totalCost = _materials.fold<double>(
      0,
      (sum, material) => sum + material.totalPrice,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Materials Used',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            if (_materials.isNotEmpty)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.green.shade100,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  'Total: \$${totalCost.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 12),

        if (_isLoadingMaterials)
          const Center(
            child: Padding(
              padding: EdgeInsets.all(24),
              child: CircularProgressIndicator(),
            ),
          )
        else if (_materials.isEmpty)
          Card(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  Icon(Icons.inventory_2_outlined,
                      size: 48, color: Colors.grey.shade400),
                  const SizedBox(height: 12),
                  const Text(
                    'No materials added yet',
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            ),
          )
        else
          ..._materials.map((material) => Card(
                margin: const EdgeInsets.only(bottom: 8),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Colors.blue.shade100,
                    child: const Icon(Icons.construction, color: Colors.blue),
                  ),
                  title: Text(
                    material.name,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(
                    '${material.quantity} ${material.unit} × \$${material.unitPrice.toStringAsFixed(2)}',
                  ),
                  trailing: Text(
                    '\$${material.totalPrice.toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Colors.green,
                    ),
                  ),
                ),
              )),

        const SizedBox(height: 12),

        // Add Material Button
        ElevatedButton.icon(
          onPressed: _isBusy ? null : _showAddMaterialDialog,
          icon: const Icon(Icons.add),
          label: const Text('Add Material'),
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 14),
          ),
        ),
      ],
    );
  }

  Widget _buildTimeRow({
    required IconData icon,
    required String label,
    required String time,
    required Color color,
  }) {
    return Row(
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade700,
                ),
              ),
              Text(
                time,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 100,
          child: Text(
            '$label:',
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              color: Colors.grey,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(fontSize: 15),
          ),
        ),
      ],
    );
  }

  Widget _buildStatusChip(String statusValue, String label, Color color) {
    final isCurrentStatus = _currentStatus == statusValue;

    return FilterChip(
      label: Text(label),
      selected: isCurrentStatus,
      onSelected: _isBusy
          ? null
          : (selected) {
              if (!isCurrentStatus) {
                _changeStatus(statusValue);
              }
            },
      backgroundColor: Colors.grey.shade200,
      selectedColor: color.withOpacity(0.3),
      checkmarkColor: color,
      labelStyle: TextStyle(
        color: isCurrentStatus ? color : Colors.black87,
        fontWeight: isCurrentStatus ? FontWeight.bold : FontWeight.normal,
      ),
    );
    
  }
    Color _getStatusColor(String status) {
    switch (status.toUpperCase()) {
      case 'NEW':
        return Colors.grey;
      case 'ASSIGNED':
        return Colors.orange;
      case 'IN_PROGRESS':
        return Colors.blue;
      case 'COMPLETED':
        return Colors.green;
      case 'CANCELLED':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}