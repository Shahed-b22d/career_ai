import 'package:flutter/material.dart';

import '../services/ai_api_service.dart';
import '../services/local_storage_service.dart';
import '../theme/app_theme.dart';
import 'complaint_screen.dart';

class CompanyDashboard extends StatefulWidget {
  const CompanyDashboard({super.key});

  @override
  State<CompanyDashboard> createState() => _CompanyDashboardState();
}

class _CompanyDashboardState extends State<CompanyDashboard> {
  String companyName = "Tech Innovators Inc.";
  String activeJobsCount = "0";
  String suggestedCandidatesCount = "84";
  String stripeSpend = "\$0";
  List<dynamic> topCandidates = [];
  List<dynamic> recentJobs = [];
  bool isLoading = true;
  String? avatarUrl;

  @override
  void initState() {
    super.initState();
    _loadDashboardData();
  }

  Future<void> _loadDashboardData() async {
    // Quick load company profile name from local storage first for instant feedback
    final profile = await LocalStorageService.getUserProfile();
    if (mounted) {
      setState(() {
        companyName = profile['name'] ?? "Company Partner";
        avatarUrl = profile['avatar'];
      });
    }

    // Fetch live backend metrics
    final data = await AiApiService.getCompanyDashboardData();
    if (data != null && data['success'] == true) {
      final payload = data['data'];
      if (mounted) {
        setState(() {
          companyName = payload['company_name'] ?? companyName;
          activeJobsCount = (payload['active_jobs_count'] ?? 0).toString();
          
          final spend = payload['stripe_spend']?.toString() ?? "0";
          stripeSpend = spend.contains('\$') ? spend : "\$$spend";

          suggestedCandidatesCount = (payload['suggested_candidates_count'] ?? 84).toString();
          topCandidates = payload['top_candidates'] ?? [];
          recentJobs = payload['recent_jobs'] ?? [];
          isLoading = false;
        });
      }
    } else {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: SafeArea(
        child: isLoading
            ? const Center(child: CircularProgressIndicator(color: AppTheme.primaryColor))
            : RefreshIndicator(
                onRefresh: _loadDashboardData,
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildHeader(context),
                      const SizedBox(height: 24),
                      _buildStatsRow(context),
                      const SizedBox(height: 32),
                      _buildTopMatches(context),
                      const SizedBox(height: 32),
                      _buildActiveJobPostingsHeader(context),
                      const SizedBox(height: 16),
                      if (recentJobs.isEmpty)
                        _buildEmptyJobsState()
                      else
                        ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: recentJobs.length,
                          itemBuilder: (context, index) {
                            final job = recentJobs[index];
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
                              padding: const EdgeInsets.only(bottom: 12),
                              child: _buildRecentJobRow(
                                context,
                                jobId: job['id'] is int ? job['id'] : int.tryParse(job['id']?.toString() ?? ''),
                                title: job['title'] ?? 'Job Posting',
                                subtitle: dateStr,
                                isPaid: job['is_paid'] == true || job['is_paid'] == 1 || job['is_paid'] == "1",
                                description: job['description'] ?? '',
                                location: job['location'] ?? '',
                                salary: job['salary']?.toString() ?? '',
                                jobType: job['job_type'] ?? '',
                              ),
                            );
                          },
                        ),
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Company Dashboard",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                const Text(
                  "Welcome back, ",
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.black54,
                  ),
                ),
                Text(
                  companyName,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primaryColor,
                  ),
                ),
              ],
            ),
          ],
        ),
        Row(
          children: [
            IconButton(
              icon: const Icon(Icons.notifications_outlined, color: Colors.black87),
              onPressed: () {
                Navigator.pushNamed(context, '/notifications');
              },
            ),
            PopupMenuButton<String>(
              offset: const Offset(0, 50),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: "edit",
                  child: Row(
                    children: [
                      Icon(Icons.edit, color: Colors.blue),
                      SizedBox(width: 10),
                      Text("Edit Profile"),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: "complaints",
                  child: Row(
                    children: [
                      Icon(Icons.report_problem, color: Colors.orange),
                      SizedBox(width: 10),
                      Text("Complaints / شكاوي"),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: "logout",
                  child: Row(
                    children: [
                      Icon(Icons.logout, color: Colors.red),
                      SizedBox(width: 10),
                      Text("Logout"),
                    ],
                  ),
                ),
              ],
              onSelected: (value) async {
                if (value == "logout") {
                  await AiApiService.logout();
                  if (mounted) Navigator.pushReplacementNamed(context, '/login');
                } else if (value == "complaints") {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const ComplaintScreen()),
                  );
                } else if (value == "edit") {
                  Navigator.pushNamed(context, '/companyProfile').then((_) => _loadDashboardData());
                }
              },
              child: CircleAvatar(
                radius: 20,
                backgroundColor: const Color(0xFFE3F2FD),
                child: ClipOval(
                  child: avatarUrl != null
                      ? Image.network(
                          "http://127.0.0.1:8000/storage/$avatarUrl",
                          width: 40,
                          height: 40,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => 
                              const Icon(Icons.business_rounded, color: AppTheme.primaryColor, size: 20),
                        )
                      : const Icon(Icons.business_rounded, color: AppTheme.primaryColor, size: 20),
                ),
              ),
            ),
          ],
        )
      ],
    );
  }

  Widget _buildStatsRow(BuildContext context) {
    return Row(
      children: [
        _buildStatCard(context, "Active Jobs", activeJobsCount, Icons.work_outline, Colors.blue, '/activeJobs'),
        const SizedBox(width: 16),
        _buildStatCard(context, "Suggested Profiles", suggestedCandidatesCount, Icons.people_outline, Colors.orange, '/suggestedProfiles'),
        const SizedBox(width: 16),
        _buildStatCard(context, "Stripe Spend", stripeSpend, Icons.payments_outlined, Colors.green, '/billing'),
      ],
    );
  }

  Widget _buildStatCard(BuildContext context, String title, String count, IconData icon, Color color, String route) {
    return Expanded(
      child: GestureDetector(
        onTap: () async {
          await Navigator.pushNamed(context, route);
          _loadDashboardData();
        },
        child: Container(
          padding: const EdgeInsets.all(16),
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
              Icon(icon, color: color, size: 28),
              const SizedBox(height: 12),
              Text(
                count,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 11,
                  color: Colors.black54,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTopMatches(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Top AI Candidates",
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 16),
        topCandidates.isEmpty
            ? Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Center(
                  child: Text(
                    "No candidates found yet.",
                    style: TextStyle(color: Colors.black54),
                  ),
                ),
              )
            : SizedBox(
                height: 180,
                child: ListView.builder(
                  clipBehavior: Clip.none,
                  scrollDirection: Axis.horizontal,
                  itemCount: topCandidates.length,
                  itemBuilder: (context, index) {
                    final candidate = topCandidates[index];
                    return _buildCandidateCard(context, Map<String, dynamic>.from(candidate));
                  },
                ),
              ),
      ],
    );
  }

  Widget _buildCandidateCard(BuildContext context, Map<String, dynamic> candidate) {
    final name = candidate['name'] ?? 'Candidate';
    final role = candidate['role'] ?? 'Job Seeker';
    final match = candidate['match']?.toString() ?? '85%';
    final matchedJobTitle = candidate['matched_job_title']?.toString();

    return GestureDetector(
      onTap: () {
        final Map<String, dynamic> candidateData = Map<String, dynamic>.from(candidate);
        if (candidateData['matched_job_id'] != null) {
          candidateData['job_id'] = candidateData['matched_job_id'];
        }
        Navigator.pushNamed(
          context,
          '/candidateProfile',
          arguments: candidateData,
        );
      },
      child: Container(
        width: 140,
        margin: const EdgeInsets.only(right: 16, bottom: 8),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const CircleAvatar(
              radius: 24,
              backgroundColor: Color(0xFFE3F2FD),
              child: Icon(Icons.person, color: Colors.blue),
            ),
            const SizedBox(height: 12),
            Text(
              name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.black87),
            ),
            const SizedBox(height: 4),
            Text(
              matchedJobTitle != null ? 'For: $matchedJobTitle' : role,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 11, color: Colors.black54),
            ),
            const Spacer(),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.auto_awesome, color: Colors.green, size: 12),
                  const SizedBox(width: 4),
                  Text(
                    match,
                    style: const TextStyle(
                      color: Colors.green,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildActiveJobPostingsHeader(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          "Recent Job Postings",
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        ElevatedButton.icon(
          onPressed: () async {
            await Navigator.pushNamed(context, '/postJob');
            _loadDashboardData();
          },
          icon: const Icon(Icons.add_rounded, size: 16),
          label: const Text("Post New"),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF0052FF),
            foregroundColor: Colors.white,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyJobsState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: const Center(
        child: Text(
          "No recent job postings.",
          style: TextStyle(color: Colors.black54),
        ),
      ),
    );
  }

  Widget _buildRecentJobRow(
    BuildContext context, {
    required int? jobId,
    required String title,
    required String subtitle,
    required bool isPaid,
    String description = '',
    String location = '',
    String salary = '',
    String jobType = '',
  }) {
    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(
          context,
          '/jobDetails',
          arguments: {
            'job_id':     jobId,
            'title':      title,
            'subtitle':   subtitle,
            'description': description,
            'location':   location,
            'salary':     salary,
            'job_type':   jobType,
            'is_paid':    isPaid,
          },
        );
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.02),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isPaid ? const Color(0xFFE8F5E9) : const Color(0xFFFFEBEE),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                Icons.work_outline_rounded,
                color: isPaid ? Colors.green : Colors.red,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.black87),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Text(
                        subtitle,
                        style: const TextStyle(fontSize: 11, color: Colors.black54),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: isPaid ? Colors.green.withOpacity(0.1) : Colors.red.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          isPaid ? "Paid" : "Pending",
                          style: TextStyle(
                            color: isPaid ? Colors.green : Colors.red,
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded, color: Colors.black38, size: 20),
          ],
        ),
      ),
    );
  }
}
