import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../services/ai_api_service.dart';

class ActiveJobsScreen extends StatefulWidget {
  const ActiveJobsScreen({super.key});

  @override
  State<ActiveJobsScreen> createState() => _ActiveJobsScreenState();
}

class _ActiveJobsScreenState extends State<ActiveJobsScreen> {
  List<dynamic> jobs = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadJobs();
  }

  Future<void> _loadJobs() async {
    final fetchedJobs = await AiApiService.getActiveJobs();
    if (mounted) {
      setState(() {
        jobs = fetchedJobs ?? [];
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text("Active Job Posts"),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_box_outlined, color: Color(0xFF0052FF)),
            onPressed: () async {
              // Wait for post job result and reload
              await Navigator.pushNamed(context, '/postJob');
              _loadJobs();
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadJobs,
        child: isLoading
            ? const Center(child: CircularProgressIndicator(color: AppTheme.primaryColor))
            : jobs.isEmpty
                ? _buildEmptyState()
                : ListView.builder(
                    padding: const EdgeInsets.all(24),
                    itemCount: jobs.length,
                    itemBuilder: (context, index) {
                      final job = jobs[index];
                      // Format date or default
                      String dateStr = "Posted recently";
                      if (job['created_at'] != null) {
                        try {
                          final parsedDate = DateTime.parse(job['created_at']);
                          final diff = DateTime.now().difference(parsedDate);
                          if (diff.inDays == 0) {
                            dateStr = "Posted today";
                          } else if (diff.inDays == 1) {
                            dateStr = "Posted yesterday";
                          } else {
                            dateStr = "Posted ${diff.inDays} days ago";
                          }
                        } catch (_) {}
                      }
                      
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: _buildJobCard(
                          context,
                          job['title'] ?? "Job Position",
                          dateStr,
                          "${job['job_type'] ?? 'Full-time'} • ${job['location'] ?? ''}",
                          job['salary'] ?? '',
                        ),
                      );
                    },
                  ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        const SizedBox(height: 80),
        Center(
          child: Icon(Icons.work_off_outlined, size: 80, color: Colors.grey.shade400),
        ),
        const SizedBox(height: 24),
        const Text(
          "No Active Job Posts",
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black87),
        ),
        const SizedBox(height: 12),
        const Text(
          "You haven't posted any jobs yet. Tap the '+' icon above to publish your first paid job post.",
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 14, color: Colors.black54),
        ),
      ],
    );
  }

  Widget _buildJobCard(BuildContext context, String title, String subtitle, String details, String salary) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFE3F2FD),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.work_outline_rounded, color: Color(0xFF0052FF)),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.black87),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: const TextStyle(fontSize: 12, color: Colors.black54),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              const Icon(Icons.info_outline, size: 16, color: Colors.grey),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  details,
                  style: const TextStyle(fontSize: 13, color: Colors.black54),
                ),
              ),
              if (salary.isNotEmpty)
                Text(
                  salary,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.green),
                ),
            ],
          ),
          const SizedBox(height: 12),
          Divider(color: Colors.grey.withOpacity(0.1)),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  "Active & Paid",
                  style: TextStyle(color: Colors.green, fontSize: 12, fontWeight: FontWeight.bold),
                ),
              ),
              Row(
                children: [
                  TextButton.icon(
                    onPressed: () {
                      Navigator.pushNamed(context, '/jobDetails', arguments: {
                        'title': title,
                        'subtitle': subtitle,
                        'matches': "Active Job",
                      });
                    },
                    icon: const Icon(Icons.remove_red_eye_outlined, size: 18),
                    label: const Text("View"),
                    style: TextButton.styleFrom(foregroundColor: const Color(0xFF0052FF)),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
