import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:url_launcher/url_launcher.dart';
import '../services/admin_api_service.dart';

class AdminDashboardPro extends StatefulWidget {
  const AdminDashboardPro({super.key});

  @override
  State<AdminDashboardPro> createState() => _AdminDashboardProState();
}

class _AdminDashboardProState extends State<AdminDashboardPro> {
  int _selectedIndex = 0;
  bool _isDark = true;
  bool _loading = true;
  String? _error;

  Map<String, dynamic>? _stats;
  List<int> _barData = [0, 0, 0, 0, 0, 0, 0];
  int _jobSeekersPct = 60;
  int _companiesPct = 40;
  List<dynamic> _complaints = [];
  List<dynamic> _notifications = [];

  List<dynamic> _pendingCompanies = [];
  List<dynamic> _pendingPayments = [];
  List<dynamic> _talentActivity = [];

  List<dynamic> _allComplaints = [];
  Map<String, dynamic> _complaintCounts = {};
  String _complaintFilter = 'all';

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    final token = await AdminApiService.getToken();
    if (token == null) {
      if (mounted) Navigator.pushReplacementNamed(context, '/adminLogin');
      return;
    }
    await _loadDashboard();
  }

  Future<void> _loadDashboard() async {
    setState(() { _loading = true; _error = null; });
    try {
      final res = await AdminApiService.getDashboard();
      if (res == null || res['success'] != true) {
        setState(() { _error = 'Failed to load dashboard'; _loading = false; });
        return;
      }
      final data = res['data'] as Map<String, dynamic>;
      final stats = data['stats'] as Map<String, dynamic>? ?? {};
      final charts = data['charts'] as Map<String, dynamic>? ?? {};
      final pie = charts['talents_pie'] as Map<String, dynamic>? ?? {};

      setState(() {
        _stats = stats;
        _barData = List<int>.from(charts['companies_growth'] ?? [0, 0, 0, 0, 0, 0, 0]);
        _jobSeekersPct = pie['job_seekers_pct'] as int? ?? 60;
        _companiesPct = pie['companies_pct'] as int? ?? 40;
        _complaints = data['complaints'] as List<dynamic>? ?? [];
        _notifications = data['notifications'] as List<dynamic>? ?? [];
        _loading = false;
      });
    } catch (e) {
      setState(() { _error = e.toString(); _loading = false; });
    }
  }

  Future<void> _loadVerifications() async {
    setState(() => _loading = true);
    _pendingCompanies = await AdminApiService.getPendingCompanies();
    _pendingPayments = await AdminApiService.getPendingPayments();
    setState(() => _loading = false);
  }

  Future<void> _loadTalents() async {
    setState(() => _loading = true);
    _talentActivity = await AdminApiService.getTalentActivity();
    setState(() => _loading = false);
  }

  Future<void> _loadComplaints() async {
    setState(() => _loading = true);
    final res = await AdminApiService.getComplaints(status: _complaintFilter);
    if (res != null && res['success'] == true) {
      setState(() {
        _allComplaints = res['data'] as List<dynamic>? ?? [];
        _complaintCounts = res['counts'] as Map<String, dynamic>? ?? {};
        _loading = false;
      });
    } else {
      setState(() => _loading = false);
    }
  }

  Future<void> _onNavTap(int index) async {
    setState(() => _selectedIndex = index);
    if (index == 0) await _loadDashboard();
    if (index == 1) await _loadVerifications();
    if (index == 2) await _loadTalents();
    if (index == 3) await _loadComplaints();
  }

  Future<void> _logout() async {
    await AdminApiService.logout();
    if (mounted) Navigator.pushReplacementNamed(context, '/adminLogin');
  }

  @override
  Widget build(BuildContext context) {
    final kPrimary = const Color(0xFF0052FF);
    final kBg = _isDark ? const Color(0xFF0A0F1C) : const Color(0xFFF1F5F9);
    final kCard = _isDark ? const Color(0xFF161B29) : Colors.white;
    final kText = _isDark ? Colors.white : const Color(0xFF0A0F1C);

    return Scaffold(
      backgroundColor: kBg,
      body: Row(
        children: [
          _buildSidebar(kCard, kPrimary, kText),
          Expanded(
            child: Column(
              children: [
                _buildTopBar(kCard, kPrimary, kText),
                Expanded(
                  child: _loading
                      ? const Center(child: CircularProgressIndicator())
                      : _error != null
                          ? Center(child: Text(_error!, style: TextStyle(color: kText)))
                          : _buildBody(kText, kCard, kPrimary),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopBar(Color kCard, Color kPrimary, Color kText) {
    return Container(
      height: 70,
      padding: const EdgeInsets.symmetric(horizontal: 25),
      decoration: BoxDecoration(color: kCard, border: Border(bottom: BorderSide(color: kText.withOpacity(0.1)))),
      child: Row(
        children: [
          Text("Admin Management Panel", style: TextStyle(color: kText.withOpacity(0.5))),
          const Spacer(),
          IconButton(
            onPressed: () => setState(() => _isDark = !_isDark),
            icon: Icon(_isDark ? Icons.light_mode : Icons.dark_mode, color: Colors.grey),
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.notifications_none, color: Colors.grey),
            offset: const Offset(0, 50),
            color: kCard,
            itemBuilder: (_) => _notifications.isEmpty
                ? <PopupMenuEntry<String>>[PopupMenuItem(enabled: false, child: Text('No notifications', style: TextStyle(color: kText)))]
                : _notifications.map<PopupMenuEntry<String>>((n) {
                    IconData icon = Icons.info;
                    if (n['type'] == 'payment') icon = Icons.attach_money;
                    if (n['type'] == 'complaint') icon = Icons.warning_amber;
                    if (n['type'] == 'verification') icon = Icons.business;
                    return PopupMenuItem<String>(
                      value: n['title'],
                      child: Row(
                        children: [
                          Icon(icon, size: 18, color: Colors.blueAccent),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(n['title'] ?? '', style: TextStyle(color: kText, fontSize: 13)),
                                Text(n['time'] ?? '', style: const TextStyle(color: Colors.grey, fontSize: 11)),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
          ),
          const SizedBox(width: 15),
          CircleAvatar(radius: 15, backgroundColor: kPrimary, child: const Icon(Icons.person, size: 18, color: Colors.white)),
        ],
      ),
    );
  }

  Widget _buildSidebar(Color kCard, Color kPrimary, Color kText) {
    return Container(
      width: 250,
      color: kCard,
      child: Column(
        children: [
          const SizedBox(height: 40),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.auto_awesome, color: kPrimary, size: 30),
              const SizedBox(width: 10),
              Text("CAREER AI", style: TextStyle(color: kText, fontWeight: FontWeight.bold, fontSize: 18)),
            ],
          ),
          const SizedBox(height: 40),
          _navItem(0, "Dashboard", Icons.dashboard_rounded, kPrimary, kText),
          _navItem(1, "Verifications", Icons.fact_check_rounded, kPrimary, kText),
          _navItem(2, "Talent Activity", Icons.groups_rounded, kPrimary, kText),
          _navItem(3, "Complaints", Icons.support_agent_rounded, kPrimary, kText),
          const Spacer(),
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.redAccent),
            title: const Text("Logout", style: TextStyle(color: Colors.redAccent)),
            onTap: _logout,
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _navItem(int index, String title, IconData icon, Color kPrimary, Color kText) {
    final isSelected = _selectedIndex == index;
    return ListTile(
      selected: isSelected,
      selectedTileColor: kPrimary.withOpacity(0.1),
      leading: Icon(icon, color: isSelected ? kPrimary : Colors.grey),
      title: Text(title, style: TextStyle(color: isSelected ? kText : Colors.grey)),
      onTap: () => _onNavTap(index),
    );
  }

  Widget _buildBody(Color kText, Color kCard, Color kPrimary) {
    switch (_selectedIndex) {
      case 1:
        return _buildVerificationsPage(kText, kCard, kPrimary);
      case 2:
        return _buildTalentsPage(kText, kCard, kPrimary);
      case 3:
        return _buildComplaintsPage(kText, kCard, kPrimary);
      default:
        return _buildDashboardPage(kText, kCard, kPrimary);
    }
  }

  Widget _buildDashboardPage(Color kText, Color kCard, Color kPrimary) {
    final revenue = _stats?['revenue_formatted'] ?? '\$0';
    final jobs = '${_stats?['active_jobs'] ?? 0}';
    final tickets = '${_stats?['tickets'] ?? 0}';

    return SingleChildScrollView(
      padding: const EdgeInsets.all(25),
      child: Column(
        children: [
          Row(
            children: [
              _statCard("Revenue", revenue, Icons.payments, Colors.green, kCard, kText),
              const SizedBox(width: 20),
              _statCard("Active Jobs", jobs, Icons.work, kPrimary, kCard, kText),
              const SizedBox(width: 20),
              _statCard("Open Tickets", tickets, Icons.warning, Colors.orange, kCard, kText),
            ],
          ),
          const SizedBox(height: 25),
          Row(
            children: [
              Expanded(child: _chartBox("Companies Growth", _buildBarChart(kPrimary), kCard, kText)),
              const SizedBox(width: 20),
              Expanded(child: _chartBox("Talents ($_jobSeekersPct% / $_companiesPct%)", _buildPieChart(kPrimary), kCard, kText)),
            ],
          ),
          const SizedBox(height: 25),
          _buildComplaintsList(kCard, kText, kPrimary),
        ],
      ),
    );
  }

  Widget _buildVerificationsPage(Color kText, Color kCard, Color kPrimary) {
    return Padding(
      padding: const EdgeInsets.all(25),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Company Registration (CR)", style: TextStyle(color: kText, fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 15),
            _buildCompanyTable(kCard, kText),
            const SizedBox(height: 40),
            Text("Job Post Payments (Pending)", style: TextStyle(color: kText, fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 15),
            _buildPaymentTable(kCard, kText),
          ],
        ),
      ),
    );
  }

  Widget _buildCompanyTable(Color kCard, Color kText) {
    if (_pendingCompanies.isEmpty) {
      return _emptyBox('No pending verifications', kCard, kText);
    }
    return Container(
      decoration: BoxDecoration(color: kCard, borderRadius: BorderRadius.circular(15)),
      child: Table(
        children: [
          _tableHeader(["Company", "License", "Status", "Actions"]),
          ..._pendingCompanies.map((c) => _companyRow(c, kText)),
        ],
      ),
    );
  }

  TableRow _companyRow(Map<String, dynamic> c, Color kText) {
    final name = c['company_name'] ?? 'N/A';
    final id = c['id'] as int;
    final url = c['license_url'] as String?;

    return TableRow(
      children: [
        _cell(name, kText),
        TextButton.icon(
          onPressed: url != null ? () => launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication) : null,
          icon: const Icon(Icons.picture_as_pdf, size: 18),
          label: const Text("View PDF"),
        ),
        _cell(c['status'] ?? 'pending', kText),
        Row(
          children: [
            IconButton(
              onPressed: () async {
                final ok = await AdminApiService.approveCompany(id);
                if (ok && mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$name verified ✅')));
                  await _loadVerifications();
                }
              },
              icon: const Icon(Icons.check_circle, color: Colors.green),
            ),
            IconButton(
              onPressed: () async {
                final ok = await AdminApiService.rejectCompany(id);
                if (ok && mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$name rejected ❌')));
                  await _loadVerifications();
                }
              },
              icon: const Icon(Icons.cancel, color: Colors.red),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildPaymentTable(Color kCard, Color kText) {
    if (_pendingPayments.isEmpty) {
      return _emptyBox('No pending payments', kCard, kText);
    }
    return Container(
      decoration: BoxDecoration(color: kCard, borderRadius: BorderRadius.circular(15)),
      child: Table(
        children: [
          _tableHeader(["Job Title", "Amount", "Ref", "Action"]),
          ..._pendingPayments.map((j) => _paymentRow(j, kText)),
        ],
      ),
    );
  }

  TableRow _paymentRow(Map<String, dynamic> j, Color kText) {
    final id = j['id'] as int;
    return TableRow(
      children: [
        _cell(j['title'] ?? '', kText),
        _cell(j['amount'] ?? '\$25', kText),
        _cell(j['payment_session_id'] ?? 'N/A', kText),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: SizedBox(
            width: 90,
            height: 32,
            child: ElevatedButton(
              onPressed: () async {
                final ok = await AdminApiService.confirmPayment(id);
                if (ok && mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Payment confirmed ✅')));
                  await _loadVerifications();
                }
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.blueAccent, padding: EdgeInsets.zero),
              child: const Text("Confirm", style: TextStyle(fontSize: 11, color: Colors.white)),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTalentsPage(Color kText, Color kCard, Color kPrimary) {
    if (_talentActivity.isEmpty) {
      return Center(child: Text('No activity yet', style: TextStyle(color: kText)));
    }
    return ListView(
      padding: const EdgeInsets.all(25),
      children: _talentActivity.map((a) {
        IconData icon = Icons.description;
        if (a['icon'] == 'roadmap') icon = Icons.map;
        if (a['icon'] == 'quiz') icon = Icons.quiz;
        return _talentActivityTile(
          a['name'] ?? 'User',
          a['action'] ?? '',
          a['time'] ?? '',
          icon,
          kCard,
          kText,
          kPrimary,
        );
      }).toList(),
    );
  }

  Widget _emptyBox(String msg, Color kCard, Color kText) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(color: kCard, borderRadius: BorderRadius.circular(15)),
      child: Text(msg, style: TextStyle(color: kText.withOpacity(0.6))),
    );
  }

  TableRow _tableHeader(List<String> cols) => TableRow(
        children: cols
            .map((c) => Padding(
                  padding: const EdgeInsets.all(15),
                  child: Text(c, style: const TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
                ))
            .toList(),
      );

  Widget _cell(String text, Color kText) =>
      Padding(padding: const EdgeInsets.all(15), child: Text(text, style: TextStyle(color: kText)));

  Widget _buildBarChart(Color color) => BarChart(
        BarChartData(
          gridData: FlGridData(show: false),
          titlesData: FlTitlesData(show: false),
          borderData: FlBorderData(show: false),
          barGroups: List.generate(
            _barData.length,
            (i) => BarChartGroupData(
              x: i,
              barRods: [BarChartRodData(toY: (_barData[i] * 5).toDouble().clamp(1, 40), color: color, width: 16)],
            ),
          ),
        ),
      );

  Widget _buildPieChart(Color color) => PieChart(
        PieChartData(
          sections: [
            PieChartSectionData(
              color: color,
              value: _jobSeekersPct.toDouble(),
              title: '$_jobSeekersPct%',
              radius: 40,
              titleStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
            ),
            PieChartSectionData(
              color: Colors.orange,
              value: _companiesPct.toDouble(),
              title: '$_companiesPct%',
              radius: 40,
              titleStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
            ),
          ],
        ),
      );

  Widget _statCard(String title, String val, IconData icon, Color color, Color kCard, Color kText) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(color: kCard, borderRadius: BorderRadius.circular(20)),
        child: Row(
          children: [
            Icon(icon, color: color, size: 30),
            const SizedBox(width: 15),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(val, style: TextStyle(color: kText, fontSize: 20, fontWeight: FontWeight.bold)),
                Text(title, style: const TextStyle(color: Colors.grey, fontSize: 12)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _chartBox(String title, Widget chart, Color kCard, Color kText) {
    return Container(
      height: 300,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: kCard, borderRadius: BorderRadius.circular(20)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: TextStyle(color: kText, fontWeight: FontWeight.bold)),
          const SizedBox(height: 20),
          Expanded(child: chart),
        ],
      ),
    );
  }

  Widget _buildComplaintsPage(Color kText, Color kCard, Color kPrimary) {
    return Padding(
      padding: const EdgeInsets.all(25),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Complaints Management", style: TextStyle(color: kText, fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text(
            "Pending: ${_complaintCounts['pending'] ?? 0} · In progress: ${_complaintCounts['in_progress'] ?? 0} · Resolved: ${_complaintCounts['resolved'] ?? 0}",
            style: TextStyle(color: kText.withOpacity(0.5), fontSize: 13),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            children: [
              _filterChip('all', 'All', kPrimary, kText, kCard),
              _filterChip('pending', 'Pending', kPrimary, kText, kCard),
              _filterChip('in_progress', 'In Progress', kPrimary, kText, kCard),
              _filterChip('resolved', 'Resolved', kPrimary, kText, kCard),
            ],
          ),
          const SizedBox(height: 20),
          Expanded(
            child: _allComplaints.isEmpty
                ? Center(child: Text('No complaints', style: TextStyle(color: kText.withOpacity(0.5))))
                : ListView.builder(
                    itemCount: _allComplaints.length,
                    itemBuilder: (_, i) => _complaintCard(_allComplaints[i], kCard, kText, kPrimary),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _filterChip(String value, String label, Color kPrimary, Color kText, Color kCard) {
    final selected = _complaintFilter == value;
    return FilterChip(
      label: Text(label),
      selected: selected,
      onSelected: (_) async {
        setState(() => _complaintFilter = value);
        await _loadComplaints();
      },
      selectedColor: kPrimary.withOpacity(0.2),
      checkmarkColor: kPrimary,
    );
  }

  Widget _complaintCard(Map<String, dynamic> c, Color kCard, Color kText, Color kPrimary) {
    final status = c['status'] ?? 'pending';
    Color statusColor = Colors.orange;
    if (status == 'resolved') statusColor = Colors.green;
    if (status == 'in_progress') statusColor = Colors.blue;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(color: kCard, borderRadius: BorderRadius.circular(16)),
      child: ListTile(
        onTap: () => _openComplaintDialog(c, kCard, kText, kPrimary),
        title: Text(c['subject'] ?? '', style: TextStyle(color: kText, fontWeight: FontWeight.bold)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text('${c['user_name']} · ${c['user_role']}', style: TextStyle(color: kText.withOpacity(0.6), fontSize: 12)),
            Text(c['created_at'] ?? '', style: const TextStyle(color: Colors.grey, fontSize: 11)),
          ],
        ),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: statusColor.withOpacity(0.15),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(status, style: TextStyle(color: statusColor, fontSize: 11, fontWeight: FontWeight.bold)),
        ),
      ),
    );
  }

  Future<void> _openComplaintDialog(Map<String, dynamic> c, Color kCard, Color kText, Color kPrimary) async {
    final responseCtrl = TextEditingController(text: c['admin_response'] ?? '');
    String status = c['status'] ?? 'pending';

    await showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          backgroundColor: kCard,
          title: Text(c['subject'] ?? 'Complaint', style: TextStyle(color: kText)),
          content: SizedBox(
            width: 450,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('From: ${c['user_name']} (${c['user_email']})', style: TextStyle(color: kText.withOpacity(0.7), fontSize: 13)),
                  const SizedBox(height: 12),
                  Text(c['message'] ?? '', style: TextStyle(color: kText)),
                  const SizedBox(height: 20),
                  Text('Status', style: TextStyle(color: kText, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  DropdownButton<String>(
                    value: status,
                    isExpanded: true,
                    dropdownColor: kCard,
                    style: TextStyle(color: kText, fontSize: 14),
                    iconEnabledColor: kText,
                    items: [
                      DropdownMenuItem(value: 'pending',     child: Text('Pending',     style: TextStyle(color: kText))),
                      DropdownMenuItem(value: 'in_progress', child: Text('In Progress', style: TextStyle(color: kText))),
                      DropdownMenuItem(value: 'resolved',    child: Text('Resolved',    style: TextStyle(color: kText))),
                    ],
                    onChanged: (v) => setDialogState(() => status = v!),
                  ),
                  const SizedBox(height: 16),
                  Text('Admin Response', style: TextStyle(color: kText, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  TextField(
                    controller: responseCtrl,
                    maxLines: 4,
                    style: TextStyle(color: kText),
                    decoration: InputDecoration(
                      hintText: 'Write your reply to the user...',
                      filled: true,
                      fillColor: kText.withOpacity(0.05),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: kPrimary),
              onPressed: () async {
                final ok = await AdminApiService.resolveComplaint(
                  complaintId: c['id'] as int,
                  status: status,
                  adminResponse: responseCtrl.text,
                );
                if (ok && mounted) {
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(status == 'resolved' ? 'Complaint resolved ✅' : 'Complaint updated')),
                  );
                  await _loadComplaints();
                  await _loadDashboard();
                }
              },
              child: const Text('Save', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
    responseCtrl.dispose();
  }

  Widget _buildComplaintsList(Color kCard, Color kText, Color kPrimary) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: kCard, borderRadius: BorderRadius.circular(20)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Recent Complaints", style: TextStyle(color: kText, fontWeight: FontWeight.bold)),
          const Divider(height: 30),
          if (_complaints.isEmpty)
            Text('No complaints', style: TextStyle(color: kText.withOpacity(0.5)))
          else
            ..._complaints.map((c) => ListTile(
                  onTap: () {
                    setState(() => _selectedIndex = 3);
                    _loadComplaints();
                  },
                  title: Text(c['user'] ?? 'User', style: TextStyle(color: kPrimary, fontWeight: FontWeight.bold)),
                  subtitle: Text(c['subject'] ?? '', style: TextStyle(color: kText.withOpacity(0.6))),
                  trailing: Text(c['status'] ?? '', style: const TextStyle(fontSize: 11, color: Colors.orange)),
                )),
        ],
      ),
    );
  }

  Widget _talentActivityTile(String name, String action, String time, IconData icon, Color kCard, Color kText, Color kPrimary) =>
      Container(
        margin: const EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(color: kCard, borderRadius: BorderRadius.circular(15)),
        child: ListTile(
          leading: Icon(icon, color: kPrimary),
          title: Text(name, style: TextStyle(color: kText, fontWeight: FontWeight.bold)),
          subtitle: Text(action, style: const TextStyle(color: Colors.grey)),
          trailing: Text(time, style: TextStyle(color: kText.withOpacity(0.3), fontSize: 12)),
        ),
      );
}
