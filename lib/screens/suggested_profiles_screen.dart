import 'package:flutter/material.dart';
import '../services/ai_api_service.dart';
import '../theme/app_theme.dart';

class SuggestedProfilesScreen extends StatefulWidget {
  const SuggestedProfilesScreen({super.key});

  @override
  State<SuggestedProfilesScreen> createState() => _SuggestedProfilesScreenState();
}

class _SuggestedProfilesScreenState extends State<SuggestedProfilesScreen> {
  List<dynamic> _allCandidates   = [];
  List<dynamic> _filtered        = [];
  bool _isLoading                = true;
  bool _isRescoring              = false; // حالة الـ rescoring
  String _searchQuery            = '';

  @override
  void initState() {
    super.initState();
    _loadCandidates();
  }

  Future<void> _loadCandidates() async {
    setState(() => _isLoading = true);
    final data = await AiApiService.getSuggestedCandidates();
    if (mounted) {
      setState(() {
        _allCandidates = data ?? [];
        _filtered      = _allCandidates;
        _isLoading     = false;
      });
    }
  }

  void _onSearch(String query) {
    setState(() {
      _searchQuery = query.toLowerCase();
      _filtered = _allCandidates.where((c) {
        final name = (c['name'] ?? '').toLowerCase();
        final role = (c['role'] ?? '').toLowerCase();
        return name.contains(_searchQuery) || role.contains(_searchQuery);
      }).toList();
    });
  }

  /// يطلب من الـ Backend إعادة حساب النسب ثم يحدث القائمة
  Future<void> _rescoreAndReload() async {
    setState(() => _isRescoring = true);

    final result = await AiApiService.rescoreCandidates();

    if (!mounted) return;

    if (result['success'] == true) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result['message'] ?? 'Scores recalculated ✅'),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
        ),
      );
      // أعد تحميل القائمة بالنسب الجديدة
      await _loadCandidates();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result['message'] ?? 'Rescoring failed'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }

    if (mounted) setState(() => _isRescoring = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text(
          'Suggested Profiles',
          style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black87),
        actions: [
          // ── زر إعادة حساب النسب ──────────────────────────────────────
          _isRescoring
              ? const Padding(
                  padding: EdgeInsets.all(12),
                  child: SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      color: AppTheme.primaryColor,
                    ),
                  ),
                )
              : IconButton(
                  icon: const Icon(Icons.auto_awesome, color: AppTheme.primaryColor),
                  tooltip: 'Recalculate AI Scores',
                  onPressed: _rescoreAndReload,
                ),
          // ── زر Refresh عادي ──────────────────────────────────────────
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: _isRescoring ? null : _loadCandidates,
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: Column(
        children: [
          // ─── Search Bar ───────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 8, 24, 0),
            child: TextField(
              onChanged: _onSearch,
              decoration: InputDecoration(
                hintText: 'Search by name or role...',
                prefixIcon: const Icon(Icons.search, color: AppTheme.primaryColor),
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, color: Colors.grey),
                        onPressed: () {
                          _onSearch('');
                          FocusScope.of(context).unfocus();
                        },
                      )
                    : null,
              ),
            ),
          ),

          const SizedBox(height: 12),

          // ─── Count Label ─────────────────────────────────────────────
          if (!_isLoading)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Row(
                children: [
                  Text(
                    'All AI Matches across your jobs',
                    style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '${_filtered.length} found',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primaryColor,
                      ),
                    ),
                  ),
                ],
              ),
            ),

          const SizedBox(height: 12),

          // ─── Body ────────────────────────────────────────────────────
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator(color: AppTheme.primaryColor))
                : _filtered.isEmpty
                    ? _buildEmptyState()
                    : RefreshIndicator(
                        onRefresh: _loadCandidates,
                        child: ListView.builder(
                          padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                          itemCount: _filtered.length,
                          itemBuilder: (context, index) {
                            return _buildCandidateCard(context, _filtered[index]);
                          },
                        ),
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.people_outline, size: 72, color: Colors.grey.shade300),
          const SizedBox(height: 16),
          Text(
            _searchQuery.isNotEmpty
                ? 'No results for "$_searchQuery"'
                : 'No candidates yet',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey.shade500,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Candidates appear here once they upload their CVs.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 13, color: Colors.grey.shade400),
          ),
        ],
      ),
    );
  }

  Widget _buildCandidateCard(BuildContext context, dynamic candidate) {
    final name       = candidate['name']  ?? 'Candidate';
    final role       = candidate['role']  ?? 'Developer';
    final matchScore = candidate['match'] ?? '85%';
    final matchInt   = int.tryParse(matchScore.replaceAll('%', '')) ?? 0;
    final matchedJobTitle = candidate['matched_job_title']?.toString();

    Color matchColor;
    if (matchInt >= 90) {
      matchColor = Colors.green;
    } else if (matchInt >= 80) {
      matchColor = Colors.orange;
    } else {
      matchColor = Colors.blue;
    }

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
        margin: const EdgeInsets.only(bottom: 14),
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
        child: Row(
          children: [
            // Avatar
            CircleAvatar(
              radius: 28,
              backgroundColor: AppTheme.primaryColor.withOpacity(0.1),
              child: Text(
                name.isNotEmpty ? name[0].toUpperCase() : '?',
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primaryColor,
                ),
              ),
            ),

            const SizedBox(width: 16),

            // Name & Role
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
                  const SizedBox(height: 3),
                  Text(
                    matchedJobTitle != null ? 'For: $matchedJobTitle' : role,
                    style: TextStyle(fontSize: 13, color: Colors.grey.shade500),
                  ),
                ],
              ),
            ),

            // Match Badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: matchColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.auto_awesome, color: matchColor, size: 13),
                  const SizedBox(width: 4),
                  Text(
                    matchScore,
                    style: TextStyle(
                      color: matchColor,
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
