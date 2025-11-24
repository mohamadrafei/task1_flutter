import 'dart:convert';
import 'dart:html' as html;

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:job_management_system/core/network/api_client.dart';
import 'package:job_management_system/features/admin/data/models/dashboard_summary_model.dart';

class AdminRemoteDataSource {
  final ApiClient apiClient;

  AdminRemoteDataSource(this.apiClient);

  Future<DashboardSummaryModel> getDashboardSummary() async {
    final http.Response resp = await apiClient.get('/admin/dashboard-summary');
  print('📊 Dashboard summary raw body: ${resp.body}'); // 👈 ADD THIS

    if (resp.statusCode == 200) {
      final data = jsonDecode(resp.body) as Map<String, dynamic>;
      return DashboardSummaryModel.fromJson(data);
    } else if (resp.statusCode == 401) {
      throw Exception('Session expired. Please login again.');
    } else if (resp.statusCode == 403) {
      throw Exception('Access denied. Admin role required.');
    } else {
      throw Exception(
        'Failed to load dashboard summary: ${resp.statusCode} - ${resp.body}',
      );
    }
  }

  /// Optional: daily report download – we just trigger the request;
  /// for web you can later handle it with a special download flow.
Future<void> downloadDailyReport(DateTime date) async {
  final formatted = DateFormat('yyyy-MM-dd').format(date);

  final http.Response resp =
      await apiClient.get('/admin/daily-report?date=$formatted');

  if (resp.statusCode != 200) {
    throw Exception(
      'Failed to download report: ${resp.statusCode} - ${resp.body}',
    );
  }

  if (!kIsWeb) {
    throw Exception('Daily report download is only implemented for web.');
  }

  final bytes = resp.bodyBytes;
  final blob = html.Blob([bytes], 'text/csv');
  final url = html.Url.createObjectUrlFromBlob(blob);

  final anchor = html.AnchorElement(href: url)
    ..setAttribute('download', 'daily-report-$formatted.csv')
    ..style.display = 'none';

  html.document.body!.append(anchor);
  anchor.click();
  anchor.remove();
  html.Url.revokeObjectUrl(url);
}

}
