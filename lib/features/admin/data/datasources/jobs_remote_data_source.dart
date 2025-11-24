// lib/features/admin/data/datasources/jobs_remote_data_source.dart
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:job_management_system/core/network/api_client.dart';
import 'package:job_management_system/features/technician/data/model/material_usage_model.dart';

import '../models/create_job_request.dart';
import '../models/job_model.dart';

class JobsRemoteDataSource {
  final ApiClient apiClient;

  JobsRemoteDataSource(this.apiClient);

  Future<JobModel> createJob(CreateJobRequest request) async {
    final resp = await apiClient.post(
      '/jobs', // full URL = http://localhost:8080/api/jobs
      body: jsonEncode(request.toJson()),
    );

    if (resp.statusCode == 200) {
      return JobModel.fromJson(jsonDecode(resp.body) as Map<String, dynamic>);
    } else {
      throw Exception(
          'Create job failed: ${resp.statusCode} - ${resp.body}');
    }
  }
   Future<List<JobModel>> getAdminJobs() async {
    final http.Response resp = await apiClient.get('/jobs/all');

    if (resp.statusCode == 200) {
      final List<dynamic> jsonList = jsonDecode(resp.body) as List<dynamic>;
      return jsonList
          .map((e) => JobModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } else {
      throw Exception(
        'Get admin jobs failed: ${resp.statusCode} - ${resp.body}',
      );
    }
  }

  Future<void> assignJob({
    required int jobId,
    required String technicianEmail,
  }) async {
    final resp = await apiClient.put(
      '/jobs/$jobId/assign?technicianEmail=$technicianEmail',
    );

    if (resp.statusCode != 200 && resp.statusCode != 204) {
      throw Exception(
        'Failed to assign job: ${resp.statusCode} - ${resp.body}',
      );
    }
  }
  Future<List<JobModel>> getMyTodayJobs() async {
    final http.Response resp = await apiClient.get('/jobs/my-today');

    if (resp.statusCode == 200) {
      final List<dynamic> list = jsonDecode(resp.body) as List<dynamic>;
      return list
          .map((j) => JobModel.fromJson(j as Map<String, dynamic>))
          .toList();
    } else {
      throw Exception(
        'Failed to load today jobs: ${resp.statusCode} - ${resp.body}',
      );
    }
  }
   Future<List<JobModel>> getMyJobs() async {
    final http.Response resp = await apiClient.get('/jobs/my-jobs');

    if (resp.statusCode == 200) {
      final List<dynamic> jsonList = jsonDecode(resp.body) as List<dynamic>;
      return jsonList
          .map((e) => JobModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } else {
      throw Exception('Get jobs failed: ${resp.statusCode} - ${resp.body}');
    }
  }
   Future<void> updateJobStatus({
    required int jobId,
    required String status, // e.g. "IN_PROGRESS"
  }) async {
    final resp = await apiClient.put(
      '/jobs/$jobId/status',
      body: jsonEncode({
        'status': status,
      }),
    );

    if (resp.statusCode != 200 && resp.statusCode != 204) {
      throw Exception(
        'Update status failed: ${resp.statusCode} - ${resp.body}',
      );
    }
  }
    Future<String> uploadJobPhoto({
    required int jobId,
    required File file,
  }) async {
    final multipartFile = await http.MultipartFile.fromPath(
      'file',        // 👈 must match @RequestParam("file")
      file.path,
    );

    final streamedResponse = await apiClient.uploadMultipart(
      path: '/jobs/$jobId/upload-photo',
      files: [multipartFile],
    );

    final resp = await http.Response.fromStream(streamedResponse);

    if (resp.statusCode == 200) {
      // backend returns String (e.g. URL or filename)
      return resp.body;
    } else {
      throw Exception(
        'Upload photo failed: ${resp.statusCode} - ${resp.body}',
      );
    }
  }
  /// Starts work on a job
  Future<void> startWork(int jobId) async {
    try {
      print('🚀 Starting work on job $jobId...');
      
      final resp = await apiClient.put('/jobs/$jobId/start-work');

      print('📡 Response: ${resp.statusCode}');
      if (resp.body.isNotEmpty) {
        print('📦 Body: ${resp.body}');
      }

      if (resp.statusCode == 200 || resp.statusCode == 204) {
        print('✅ Work started successfully');
        return;
      } else if (resp.statusCode == 401) {
        throw Exception('Session expired. Please login again.');
      } else if (resp.statusCode == 403) {
        throw Exception(
          'Access denied. This job is not assigned to you, or you don\'t have technician role.',
        );
      } else if (resp.statusCode == 404) {
        throw Exception('Job not found.');
      } else if (resp.statusCode == 400) {
        // Try to parse error message
        try {
          final errorData = jsonDecode(resp.body);
          final message = errorData['message'] ?? errorData['error'];
          throw Exception(message ?? 'Job cannot be started. Check job status.');
        } catch (_) {
          throw Exception('Job is not in correct status to start work (must be ASSIGNED).');
        }
      } else {
        throw Exception('Start work failed: ${resp.statusCode} - ${resp.body}');
      }
    } catch (e) {
      print('❌ Start work error: $e');
      rethrow;
    }
  }

  /// Completes work on a job
  Future<void> completeWork(int jobId) async {
    try {
      print('✅ Completing work on job $jobId...');
      
      final resp = await apiClient.put('/jobs/$jobId/complete-work');

      print('📡 Response: ${resp.statusCode}');
      if (resp.body.isNotEmpty) {
        print('📦 Body: ${resp.body}');
      }

      if (resp.statusCode == 200 || resp.statusCode == 204) {
        print('✅ Work completed successfully');
        return;
      } else if (resp.statusCode == 401) {
        throw Exception('Session expired. Please login again.');
      } else if (resp.statusCode == 403) {
        throw Exception('Access denied. This job is not assigned to you.');
      } else if (resp.statusCode == 404) {
        throw Exception('Job not found.');
      } else if (resp.statusCode == 400) {
        // Try to parse error message
        try {
          final errorData = jsonDecode(resp.body);
          final message = errorData['message'] ?? errorData['error'];
          throw Exception(message ?? 'Job cannot be completed. Check job status.');
        } catch (_) {
          throw Exception('Job must be IN_PROGRESS to complete (start work first).');
        }
      } else {
        throw Exception('Complete work failed: ${resp.statusCode} - ${resp.body}');
      }
    } catch (e) {
      print('❌ Complete work error: $e');
      rethrow;
    }
  }
  // Add to jobs_remote_data_source.dart

/// Adds material usage to a job
Future<MaterialUsageModel> addMaterial({
  required int jobId,
  required String name,
  required double quantity,
  required String unit,
  required double unitPrice,
}) async {
  try {
    print('📦 Adding material to job $jobId...');
    
    final resp = await apiClient.post(
      '/jobs/$jobId/materials',
      body: jsonEncode({
        'name': name,
        'quantity': quantity,
        'unit': unit,
        'unitPrice': unitPrice,
      }),
    );

    print('📡 Response: ${resp.statusCode}');

    if (resp.statusCode == 200 || resp.statusCode == 201) {
      print('✅ Material added successfully');
      return MaterialUsageModel.fromJson(
        jsonDecode(resp.body) as Map<String, dynamic>,
      );
    } else if (resp.statusCode == 401) {
      throw Exception('Session expired. Please login again.');
    } else if (resp.statusCode == 403) {
      throw Exception('Access denied. Only assigned technician can add materials.');
    } else {
      throw Exception('Failed to add material: ${resp.statusCode} - ${resp.body}');
    }
  } catch (e) {
    print('❌ Add material error: $e');
    rethrow;
  }
}

/// Gets materials for a job
Future<List<MaterialUsageModel>> getMaterials(int jobId) async {
  try {
    print('📋 Fetching materials for job $jobId...');
    
    final resp = await apiClient.get('/jobs/$jobId/materials');

    print('📡 Response: ${resp.statusCode}');

    if (resp.statusCode == 200) {
      final List<dynamic> jsonList = jsonDecode(resp.body) as List<dynamic>;
      print('✅ Found ${jsonList.length} materials');
      
      return jsonList
          .map((e) => MaterialUsageModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } else if (resp.statusCode == 401) {
      throw Exception('Session expired. Please login again.');
    } else {
      throw Exception('Failed to load materials: ${resp.statusCode} - ${resp.body}');
    }
  } catch (e) {
    print('❌ Get materials error: $e');
    rethrow;
  }
}
}
