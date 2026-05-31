import 'package:flutter/material.dart';
import '../services/ai_api_service.dart';
import '../theme/app_theme.dart';

class JobDetailsScreen extends StatefulWidget {
  const JobDetailsScreen({super.key});

  @override
  State<JobDetailsScreen> createState() => _JobDetailsScreenState();
}

class _JobDetailsScreenState extends State<JobDetailsScreen> {
  bool _isLoading = false;
  List<dynamic> _candidates = [];
  String? _errorMessage;

  // بيانات الوظيفة من الـ arguments
  int? _jobId;
  String _title = '';
  String _subtitle = '';
  String _badge = '0 AI Matches';
  String _description = '';
  String _location = '';
  String _salary = '';
  String _jobType = '';
  bool _isPaid = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _init());
  }

  void _init() {
    final args =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;

    if (args != null) {
      _jobId       = args['job_id'] as int?;
      _title       = args['title']?.toString()       ?? '';
      _subtitle    = args['subtitle']?.toString()    ?? '';
      _badge       = args['matches']?.toString()     ?? '0 AI Matches';
      _description = args['description']?.toString() ?? '';
      _location    = args['location']?.toString()    ?? '';
      _salary      = args['salary']?.toString()      ?? '';
      _jobType     = args['job_type']?.toString()    ?? '';
      _isPaid      = args['is_paid'] as bool?        ?? false;
    }

    if (_jobId != null) {
      _loadCandidates();
    }
  }

  Future<void> _loadCandidates() async {
    if (_jobId == null) return;

    setState(() {
      _isLoading    = true;
      _errorMessage = null;
    });

    final result = await AiApiService.getJobCandidates(_jobId!);

    if (!mounted) return;

    setState(() {
      _isLoading = false;
      if (result != null) {
        _candidates = result['data'] as List<dynamic>? ?? [];

        // تحديث بيانات الوظيفة من الـ backend إذا كانت أكثر تفصيلاً
        _title       = result['job_title']?.toString()        ?? _title;
        _description = result['job_description']?.toString()  ?? _description;
        _location    = result['job_location']?.toString()     ?? _location;
        _salary      = result['job_salary']?.toString()       ?? _salary;
        _jobType     = result['job_type']?.toString()         ?? _jobType;
        _isPaid      = result['is_paid'] as bool?             ?? _isPaid;

        final count = _candidates.length;
        _badge = '$count AI Matches';
      } else {
        _errorMessage = 'Could not load candidates. Please try again.';
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text(
          'Job Details',
          style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black87),
        actions: [
          if (_jobId != null)
            IconButton(
              icon: const Icon(Icons.refresh_rounded),
              onPressed: _loadCandidates,
              tooltip: 'Refresh',
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Job Header ──────────────────────────────────────────────
            _buildJobHeader(),
            const SizedBox(height: 24),

            // ── Description ─────────────────────────────────────────────
            if (_description.isNotEmpty) ...[
              const Text(
                'Job Description',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                _description,
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.black87,
                  height: 1.6,
                ),
              ),
              const SizedBox(height: 32),
            ],

            // ── AI Matched Candidates ────────────────────────────────────
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'AI Matched Candidates',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.orange.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    _badge,
                    style: const TextStyle(
                      color: Colors.orange,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // ── Error ────────────────────────────────────────────────────
            if (_errorMessage != null)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border:
                      Border.all(color: Colors.orange.withOpacity(0.3)),
                ),
                child: Text(
                  _errorMessage!,
                  style: const TextStyle(color: Colors.orange, fontSize: 13),
                ),
              ),

            // ── Loading ──────────────────────────────────────────────────
            if (_isLoading)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(32),
                  child: CircularProgressIndicator(
                      color: AppTheme.primaryColor),
                ),
              )

            // ── No job_id passed ─────────────────────────────────────────
            else if (_jobId == null)
              _buildNoJobIdState()

            // ── Empty ────────────────────────────────────────────────────
            else if (_candidates.isEmpty)
              _buildEmptyState()

            // ── Candidates List ──────────────────────────────────────────
            else
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _candidates.length,
                itemBuilder: (context, index) {
                  return _buildCandidateCard(
                      context, _candidates[index]);
                },
              ),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildJobHeader() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFE3F2FD),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(
              Icons.work_outline_rounded,
              color: Color(0xFF0052FF),
              size: 32,
            ),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _title.isNotEmpty ? _title : 'Job Posting',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 4),
                if (_location.isNotEmpty || _jobType.isNotEmpty)
                  Text(
                    [_location, _jobType]
                        .where((s) => s.isNotEmpty)
                        .join(' • '),
                    style: const TextStyle(
                        fontSize: 13, color: Colors.black54),
                  ),
                if (_salary.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    _salary,
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppTheme.primaryColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
                const SizedBox(height: 10),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: _isPaid
                            ? Colors.green
                            : Colors.orange,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        _isPaid ? 'Active' : 'Pending Payment',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    if (_subtitle.isNotEmpty) ...[
                      const SizedBox(width: 8),
                      Text(
                        _subtitle,
                        style: const TextStyle(
                            fontSize: 11, color: Colors.black45),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCandidateCard(
      BuildContext context, dynamic candidate) {
    final name       = candidate['name']?.toString()  ?? 'Candidate';
    final role       = candidate['role']?.toString()  ?? 'Job Seeker';
    final matchStr   = candidate['match']?.toString() ?? '0%';
    final matchInt   = int.tryParse(
            matchStr.replaceAll('%', '')) ??
        0;
    final justification =
        candidate['justification']?.toString() ?? '';

    Color matchColor;
    if (matchInt >= 80) {
      matchColor = Colors.green;
    } else if (matchInt >= 60) {
      matchColor = Colors.orange;
    } else {
      matchColor = Colors.red;
    }

    return GestureDetector(
      onTap: () {
        final Map<String, dynamic> candidateData = Map<String, dynamic>.from(candidate);
        candidateData['job_id'] = _jobId;
        Navigator.pushNamed(
          context,
          '/candidateProfile',
          // نمرر كل بيانات المرشح بما فيها النسبة الصحيحة لهذه الوظيفة
          arguments: candidateData,
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.withOpacity(0.1)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.02),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 22,
                  backgroundColor:
                      AppTheme.primaryColor.withOpacity(0.1),
                  child: Text(
                    name.isNotEmpty
                        ? name[0].toUpperCase()
                        : '?',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.primaryColor,
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        role,
                        style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade500),
                      ),
                    ],
                  ),
                ),
                // نسبة التوافق
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: matchColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.auto_awesome,
                          color: matchColor, size: 13),
                      const SizedBox(width: 4),
                      Text(
                        matchStr,
                        style: TextStyle(
                          color: matchColor,
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                const Icon(Icons.arrow_forward_ios,
                    size: 13, color: Colors.grey),
              ],
            ),
            // مبرر الـ AI
            if (justification.isNotEmpty &&
                justification != 'Calculated locally') ...[
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                      color: Colors.grey.shade200),
                ),
                child: Row(
                  children: [
                    Icon(Icons.psychology_outlined,
                        size: 14,
                        color: Colors.grey.shade500),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        justification,
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.grey.shade600,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          Icon(Icons.people_outline,
              size: 56, color: Colors.grey.shade300),
          const SizedBox(height: 12),
          Text(
            'No matched candidates yet',
            style: TextStyle(
                fontSize: 15, color: Colors.grey.shade500),
          ),
          const SizedBox(height: 6),
          Text(
            'Candidates will appear here once they upload their CVs.',
            textAlign: TextAlign.center,
            style: TextStyle(
                fontSize: 12, color: Colors.grey.shade400),
          ),
        ],
      ),
    );
  }

  Widget _buildNoJobIdState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          Icon(Icons.info_outline,
              size: 56, color: Colors.grey.shade300),
          const SizedBox(height: 12),
          Text(
            'No job ID provided',
            style: TextStyle(
                fontSize: 15, color: Colors.grey.shade500),
          ),
        ],
      ),
    );
  }
}
