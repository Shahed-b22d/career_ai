import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../theme/app_theme.dart';

const primary = Color(0xFF0052FF);
const bg = Color(0xFFF8F9FA);
const sidebarColor = Color(0xFF0A0F1C); // Very dark, professional sidebar

class AdminDashboardPro extends StatefulWidget {
  const AdminDashboardPro({super.key});

  @override
  State<AdminDashboardPro> createState() => _AdminDashboardProState();
}

class _AdminDashboardProState extends State<AdminDashboardPro> with SingleTickerProviderStateMixin {
  int selected = 0;

  // 🔥 AI SYSTEM DATA (Dummy data for UI)
  List talentPool = [
    {"name": "Ahmad Ali", "cv_status": "Analyzed", "score": 92, "roadmap": "Active"},
    {"name": "Sara Jenkins", "cv_status": "Analyzed", "score": 88, "roadmap": "Active"},
    {"name": "Lina Othman", "cv_status": "Pending AI", "score": 0, "roadmap": "None"},
    {"name": "Omar K.", "cv_status": "Analyzed", "score": 75, "roadmap": "Completed"},
  ];

  List enterprises = [
    {"name": "TechFlow Inc.", "jobs": 4, "matches_delivered": 120, "status": "Active"},
    {"name": "Innovate AI", "jobs": 1, "matches_delivered": 15, "status": "Active"},
    {"name": "Global Corp", "jobs": 0, "matches_delivered": 0, "status": "Pending Review"},
  ];

  List aiOperations = [
    {"type": "CV Parsing (Gemini)", "user": "Lina Othman", "status": "Processing", "time": "2 sec ago"},
    {"type": "Quiz Generation", "user": "Ahmad Ali", "status": "Success", "time": "5 mins ago"},
    {"type": "Roadmap Creation", "user": "Sara Jenkins", "status": "Success", "time": "1 hour ago"},
    {"type": "Job Matching Batch", "user": "System", "status": "Success", "time": "3 hours ago"},
  ];

  // 🔥 ANIMATION
  late AnimationController c;
  late Animation<double> fade;

  @override
  void initState() {
    super.initState();
    c = AnimationController(vsync: this, duration: const Duration(milliseconds: 600));
    fade = Tween(begin: 0.0, end: 1.0).animate(c);
    c.forward();
  }

  @override
  void dispose() {
    c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bg,
      body: Row(
        children: [
          _buildSidebar(),
          Expanded(
            child: FadeTransition(
              opacity: fade,
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return Align(
                    alignment: Alignment.topCenter,
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        maxWidth: 1200,
                        maxHeight: constraints.maxHeight,
                      ),
                      child: SizedBox(
                        width: double.infinity,
                        height: constraints.maxHeight,
                        child: Padding(
                          padding: const EdgeInsets.all(32),
                          child: _buildPageContent(),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          )
        ],
      ),
    );
  }

  // ================= SIDEBAR =================
  Widget _buildSidebar() {
    return Container(
      width: 250,
      color: sidebarColor,
      child: Column(
        children: [
          const SizedBox(height: 40),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: primary.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.admin_panel_settings, color: primary, size: 28),
              ),
              const SizedBox(width: 12),
              const Text("AI Admin", style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 40),
          _buildSidebarItem(Icons.dashboard_rounded, "System Overview", 0),
          _buildSidebarItem(Icons.people_alt_rounded, "Talent Pool", 1),
          _buildSidebarItem(Icons.business_rounded, "Enterprises", 2),
          _buildSidebarItem(Icons.memory_rounded, "AI Operations", 3),
          const Spacer(),
          const Divider(color: Colors.white24),
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.white54),
            title: const Text("Logout", style: TextStyle(color: Colors.white54)),
            onTap: () => Navigator.pushReplacementNamed(context, '/login'),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildSidebarItem(IconData icon, String text, int index) {
    bool isActive = selected == index;

    return GestureDetector(
      onTap: () {
        setState(() => selected = index);
        c.reset();
        c.forward();
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
        decoration: BoxDecoration(
          color: isActive ? primary : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          boxShadow: isActive
              ? [BoxShadow(color: primary.withOpacity(0.3), blurRadius: 10, offset: const Offset(0, 4))]
              : [],
        ),
        child: Row(
          children: [
            Icon(icon, color: isActive ? Colors.white : Colors.white54, size: 20),
            const SizedBox(width: 16),
            Text(
              text,
              style: TextStyle(
                color: isActive ? Colors.white : Colors.white54,
                fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                fontSize: 15,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ================= ROUTER =================
  Widget _buildPageContent() {
    switch (selected) {
      case 1:
        return _buildTalentPoolPage();
      case 2:
        return _buildEnterprisesPage();
      case 3:
        return _buildAiOperationsPage();
      default:
        return _buildDashboardOverview();
    }
  }

  // ================= DASHBOARD OVERVIEW =================
  Widget _buildDashboardOverview() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("System Overview", style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.black87)),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(color: Colors.green.withOpacity(0.1), borderRadius: BorderRadius.circular(20)),
                child: const Row(
                  children: [
                    Icon(Icons.check_circle, color: Colors.green, size: 16),
                    SizedBox(width: 8),
                    Text("System Healthy", style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 32),
          Row(
            children: [
              _buildKpiCard("CVs Parsed", "1,240", Icons.document_scanner, Colors.blue),
              const SizedBox(width: 20),
              _buildKpiCard("Active Jobs", "85", Icons.work, Colors.orange),
              const SizedBox(width: 20),
              _buildKpiCard("Successful Matches", "8,920", Icons.handshake, Colors.green),
              const SizedBox(width: 20),
              _buildKpiCard("API Calls (Today)", "4.2k", Icons.api, Colors.purple),
            ],
          ),
          const SizedBox(height: 32),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(flex: 2, child: _buildChartBox("AI Match Rate vs Direct Apply", _buildLineChart())),
              const SizedBox(width: 24),
              Expanded(child: _buildChartBox("Talent Skill Distribution", _buildPieChart())),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildKpiCard(String title, String value, IconData icon, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 15, offset: const Offset(0, 5))],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: color.withOpacity(0.1), shape: BoxShape.circle),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(height: 20),
            Text(value, style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.black87)),
            const SizedBox(height: 4),
            Text(title, style: const TextStyle(color: Colors.black54, fontSize: 13, fontWeight: FontWeight.w500)),
          ],
        ),
      ),
    );
  }

  Widget _buildChartBox(String title, Widget chartContent) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 15, offset: const Offset(0, 5))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87)),
          const SizedBox(height: 32),
          SizedBox(height: 220, child: chartContent),
        ],
      ),
    );
  }

  Widget _buildLineChart() {
    return LineChart(
      LineChartData(
        gridData: FlGridData(show: true, drawVerticalLine: false, horizontalInterval: 2, getDrawingHorizontalLine: (value) => FlLine(color: Colors.grey.withOpacity(0.1), strokeWidth: 1)),
        titlesData: FlTitlesData(
          rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 22, interval: 1, getTitlesWidget: (v, m) => Text('W${v.toInt()+1}', style: const TextStyle(color: Colors.black54, fontSize: 10)))),
          leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        borderData: FlBorderData(show: false),
        lineBarsData: [
          LineChartBarData(
            spots: const [FlSpot(0, 3), FlSpot(1, 4), FlSpot(2, 5), FlSpot(3, 8), FlSpot(4, 7), FlSpot(5, 10)],
            isCurved: true,
            color: Colors.green,
            barWidth: 4,
            isStrokeCapRound: true,
            dotData: FlDotData(show: false),
            belowBarData: BarAreaData(show: true, color: Colors.green.withOpacity(0.1)),
          ),
          LineChartBarData(
            spots: const [FlSpot(0, 2), FlSpot(1, 2.5), FlSpot(2, 2.2), FlSpot(3, 3), FlSpot(4, 2.8), FlSpot(5, 3.5)],
            isCurved: true,
            color: Colors.grey.withOpacity(0.5),
            barWidth: 3,
            isStrokeCapRound: true,
            dotData: FlDotData(show: false),
          ),
        ],
      ),
    );
  }

  Widget _buildPieChart() {
    return PieChart(
      PieChartData(
        sectionsSpace: 2,
        centerSpaceRadius: 50,
        sections: [
          PieChartSectionData(value: 40, color: Colors.blue, title: 'Frontend', radius: 40, titleStyle: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.white)),
          PieChartSectionData(value: 30, color: Colors.purple, title: 'Backend', radius: 40, titleStyle: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.white)),
          PieChartSectionData(value: 15, color: Colors.orange, title: 'UI/UX', radius: 40, titleStyle: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.white)),
          PieChartSectionData(value: 15, color: Colors.green, title: 'Data', radius: 40, titleStyle: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.white)),
        ],
      ),
    );
  }

  // ================= TALENT POOL =================
  Widget _buildTalentPoolPage() {
    return _buildDataTableContainer(
      "Talent Pool",
      "Manage job seekers and their AI evaluation status",
      DataTable(
        headingTextStyle: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black54),
        columns: const [
          DataColumn(label: Text("Candidate Name")),
          DataColumn(label: Text("CV AI Status")),
          DataColumn(label: Text("AI Score")),
          DataColumn(label: Text("Roadmap")),
          DataColumn(label: Text("Action")),
        ],
        rows: talentPool.map((u) {
          bool isAnalyzed = u["cv_status"] == "Analyzed";
          return DataRow(cells: [
            DataCell(Text(u["name"], style: const TextStyle(fontWeight: FontWeight.bold))),
            DataCell(
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(color: isAnalyzed ? Colors.green.withOpacity(0.1) : Colors.orange.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
                child: Text(u["cv_status"], style: TextStyle(color: isAnalyzed ? Colors.green : Colors.orange, fontSize: 12)),
              ),
            ),
            DataCell(Text(u["score"].toString(), style: TextStyle(fontWeight: FontWeight.bold, color: u["score"] > 80 ? Colors.green : Colors.black87))),
            DataCell(Text(u["roadmap"])),
            DataCell(IconButton(
              icon: const Icon(Icons.delete_outline, color: Colors.red),
              onPressed: () {
                setState(() => talentPool.remove(u));
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Candidate removed")));
              },
            )),
          ]);
        }).toList(),
      ),
    );
  }

  // ================= ENTERPRISES =================
  Widget _buildEnterprisesPage() {
    return _buildDataTableContainer(
      "Enterprises & Companies",
      "Monitor company job postings and AI matching delivery",
      DataTable(
        headingTextStyle: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black54),
        columns: const [
          DataColumn(label: Text("Company Name")),
          DataColumn(label: Text("Active Jobs")),
          DataColumn(label: Text("Matches Delivered")),
          DataColumn(label: Text("Status")),
          DataColumn(label: Text("Action")),
        ],
        rows: enterprises.map((c) {
          bool isActive = c["status"] == "Active";
          return DataRow(cells: [
            DataCell(Text(c["name"], style: const TextStyle(fontWeight: FontWeight.bold))),
            DataCell(Text(c["jobs"].toString())),
            DataCell(Text(c["matches_delivered"].toString(), style: const TextStyle(color: primary, fontWeight: FontWeight.bold))),
            DataCell(
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(color: isActive ? Colors.green.withOpacity(0.1) : Colors.orange.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
                child: Text(c["status"], style: TextStyle(color: isActive ? Colors.green : Colors.orange, fontSize: 12)),
              ),
            ),
            DataCell(Row(
              children: [
                if (!isActive)
                  IconButton(
                    icon: const Icon(Icons.check_circle_outline, color: Colors.green),
                    onPressed: () => setState(() => c["status"] = "Active"),
                  ),
                IconButton(
                  icon: const Icon(Icons.block, color: Colors.red),
                  onPressed: () {
                    setState(() => enterprises.remove(c));
                  },
                ),
              ],
            )),
          ]);
        }).toList(),
      ),
    );
  }

  // ================= AI OPERATIONS =================
  Widget _buildAiOperationsPage() {
    return _buildDataTableContainer(
      "AI Operations Log",
      "Live feed of Gemini API usage, parsing, and matching tasks",
      DataTable(
        headingTextStyle: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black54),
        columns: const [
          DataColumn(label: Text("Task Type")),
          DataColumn(label: Text("Target User/Entity")),
          DataColumn(label: Text("Status")),
          DataColumn(label: Text("Time")),
        ],
        rows: aiOperations.map((op) {
          bool isSuccess = op["status"] == "Success";
          return DataRow(cells: [
            DataCell(Row(
              children: [
                Icon(Icons.memory, size: 16, color: Colors.purple.withOpacity(0.6)),
                const SizedBox(width: 8),
                Text(op["type"], style: const TextStyle(fontWeight: FontWeight.bold)),
              ],
            )),
            DataCell(Text(op["user"])),
            DataCell(
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(color: isSuccess ? Colors.green.withOpacity(0.1) : Colors.blue.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
                child: Text(op["status"], style: TextStyle(color: isSuccess ? Colors.green : Colors.blue, fontSize: 12)),
              ),
            ),
            DataCell(Text(op["time"], style: const TextStyle(color: Colors.black54))),
          ]);
        }).toList(),
      ),
    );
  }

  // ================= HELPER =================
  Widget _buildDataTableContainer(String title, String subtitle, Widget dataTable) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.black87)),
        const SizedBox(height: 4),
        Text(subtitle, style: const TextStyle(fontSize: 14, color: Colors.black54)),
        const SizedBox(height: 32),
        Expanded(
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 15, offset: const Offset(0, 5))],
            ),
            child: SingleChildScrollView(
              child: Theme(
                data: Theme.of(context).copyWith(dividerColor: Colors.grey.withOpacity(0.1)),
                child: dataTable,
              ),
            ),
          ),
        ),
      ],
    );
  }
}