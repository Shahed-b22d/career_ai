import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class CompanyDashboard extends StatelessWidget {
  const CompanyDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA), // Very light gray background
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(context),
              const SizedBox(height: 24),
              _buildAiInsightBanner(context),
              const SizedBox(height: 24),
              _buildStatsRow(context),
              const SizedBox(height: 32),
              _buildTopMatches(context),
              const SizedBox(height: 32),
              _buildActiveJobPostingsHeader(context),
              const SizedBox(height: 16),
              _buildRecentJobRow("Senior Flutter Developer", "Posted 2 days ago", "12 Applicants"),
              const SizedBox(height: 12),
              _buildRecentJobRow("Laravel Backend Dev", "Posted 5 days ago", "34 Applicants"),
              const SizedBox(height: 12),
              _buildRecentJobRow("Product Manager", "Posted 1 week ago", "8 Applicants"),
              const SizedBox(height: 40),
            ],
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
                  "Tech Innovators Inc.",
                  style: TextStyle(
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
              onPressed: () {},
            ),
            GestureDetector(
              onTap: () {
                Navigator.pushNamed(context, '/companyProfile');
              },
              child: const CircleAvatar(
                radius: 20,
                backgroundColor: Color(0xFFE3F2FD),
                child: Icon(Icons.business_rounded, color: AppTheme.primaryColor, size: 20),
              ),
            ),
          ],
        )
      ],
    );
  }

  Widget _buildAiInsightBanner(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF0052FF), Color(0xFF6B00FF)], // Blue to Purple
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0052FF).withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.auto_awesome, color: Colors.white, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  "AI Talent Insight",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  "We found 3 perfect matches for your Senior UI/UX Designer role.",
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 13,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
          const Icon(Icons.arrow_forward_ios_rounded, color: Colors.white, size: 16),
        ],
      ),
    );
  }

  Widget _buildStatsRow(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            _buildStatCard("Active Jobs", "12", Icons.work_outline, Colors.blue),
            const SizedBox(width: 16),
            _buildStatCard("Applicants", "84", Icons.people_outline, Colors.orange),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            _buildStatCard("AI Matches", "15", Icons.auto_awesome, Colors.purple),
            const SizedBox(width: 16),
            _buildStatCard("Stripe Spend", "\$420", Icons.payments_outlined, Colors.green),
          ],
        ),
      ],
    );
  }

  Widget _buildStatCard(String title, String count, IconData icon, Color color) {
    return Expanded(
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
                fontSize: 22,
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
    );
  }

  Widget _buildTopMatches(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              "Top AI Candidates",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            Text(
              "View All",
              style: TextStyle(
                color: AppTheme.primaryColor,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 180,
          // Negative horizontal margin hack to allow scrolling to edges without cutting shadows
          child: ListView(
            clipBehavior: Clip.none,
            scrollDirection: Axis.horizontal,
            children: [
              _buildCandidateCard("Sarah Jenkins", "Senior Flutter Dev", "98%"),
              _buildCandidateCard("Ahmed Ali", "Backend Engineer", "94%"),
              _buildCandidateCard("Emily Chen", "UI/UX Designer", "91%"),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCandidateCard(String name, String role, String match) {
    return Container(
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
            role,
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
          onPressed: () {
            Navigator.pushNamed(context, '/postJob');
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

  Widget _buildRecentJobRow(String title, String subtitle, String badge) {
    return Container(
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
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.black87),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: const TextStyle(fontSize: 11, color: Colors.black54),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.orange.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              badge,
              style: const TextStyle(
                color: Colors.orange,
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
            ),
          )
        ],
      ),
    );
  }
}
