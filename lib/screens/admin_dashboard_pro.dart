import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

const primary = Color(0xFF2563EB);
const bg = Color(0xFFF1F5F9);

class AdminDashboardPro extends StatefulWidget {
  @override
  State<AdminDashboardPro> createState() => _AdminDashboardProState();
}

class _AdminDashboardProState extends State<AdminDashboardPro>
    with SingleTickerProviderStateMixin {

  int selected = 0;

  // 🔥 DATA
  List users = ["Ahmad", "Sara", "Lina", "Omar"];

  List companies = [
    {"name": "Google", "status": "Approved", "revenue": 5000},
    {"name": "Tesla", "status": "Pending", "revenue": 2000},
    {"name": "Amazon", "status": "Approved", "revenue": 3000},
  ];

  List complaints = [
    {"title": "Fake Job", "status": "Pending"},
    {"title": "Spam", "status": "In Review"},
    {"title": "Delay", "status": "Resolved"},
  ];

  // 🔥 ANIMATION
  late AnimationController c;
  late Animation<double> fade;

  @override
  void initState() {
    super.initState();
    c = AnimationController(vsync: this, duration: Duration(milliseconds: 600));
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
          sidebar(),
          Expanded(
            child: FadeTransition(
              opacity: fade,
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: page(),
              ),
            ),
          )
        ],
      ),
    );
  }

  // ================= SIDEBAR =================
  Widget sidebar() {
    return Container(
      width: 230,
      color: const Color(0xFF0F172A),
      child: Column(
        children: [
          const SizedBox(height: 40),
          const Text("ADMIN",
              style: TextStyle(color: Colors.white, fontSize: 20)),
          const SizedBox(height: 30),

          item(Icons.dashboard, "Dashboard", 0),
          item(Icons.people, "Users", 1),
          item(Icons.business, "Companies", 2),
          item(Icons.report, "Complaints", 3),
        ],
      ),
    );
  }

  Widget item(IconData icon, String text, int i) {
    bool active = selected == i;

    return GestureDetector(
      onTap: () => setState(() => selected = i),
      child: Container(
        margin: const EdgeInsets.all(8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: active ? Colors.white.withOpacity(0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: [
            Icon(icon, color: Colors.white),
            const SizedBox(width: 10),
            Text(text, style: const TextStyle(color: Colors.white)),
          ],
        ),
      ),
    );
  }

  // ================= ROUTER =================
  Widget page() {
    switch (selected) {
      case 1:
        return usersPage();
      case 2:
        return companiesPage();
      case 3:
        return complaintsPage();
      default:
        return dashboard();
    }
  }

  // ================= DASHBOARD =================
  Widget dashboard() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          const Text("Dashboard",
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),

          const SizedBox(height: 20),

          Row(
            children: [
              kpi("Users", users.length.toString()),
              kpi("Companies", companies.length.toString()),
              kpi("Revenue", "\$10000"),
              kpi("Complaints", complaints.length.toString()),
            ],
          ),

          const SizedBox(height: 25),

          Row(
            children: [
              Expanded(child: chart()),
              const SizedBox(width: 20),
              Expanded(child: pie()),
            ],
          ),
        ],
      ),
    );
  }

  // ================= KPI =================
  Widget kpi(String t, String v) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.only(right: 12),
        padding: const EdgeInsets.all(20),
        decoration: box(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(v,
                style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: primary)),
            const SizedBox(height: 5),
            Text(t, style: const TextStyle(color: Colors.grey)),
          ],
        ),
      ),
    );
  }

  // ================= CHART =================
  Widget chart() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: box(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          const Text("User Growth"),

          const SizedBox(height: 20),

          SizedBox(
            height: 180,
            child: LineChart(
              LineChartData(
                borderData: FlBorderData(show: false),
                titlesData: FlTitlesData(show: false),
                lineBarsData: [
                  LineChartBarData(
                    isCurved: true,
                    color: primary,
                    spots: const [
                      FlSpot(0, 2),
                      FlSpot(1, 3),
                      FlSpot(2, 5),
                      FlSpot(3, 4),
                      FlSpot(4, 6),
                    ],
                  )
                ],
              ),
            ),
          ),

          const SizedBox(height: 10),

          const Text("Jan - May growth data",
              style: TextStyle(color: Colors.grey))
        ],
      ),
    );
  }

  // ================= PIE =================
  Widget pie() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: box(),
      child: Column(
        children: [
          const Text("Company Status"),

          const SizedBox(height: 20),

          SizedBox(
            height: 150,
            child: PieChart(
              PieChartData(sections: [
                PieChartSectionData(value: 70, color: primary),
                PieChartSectionData(value: 30, color: Colors.orange),
              ]),
            ),
          ),

          const SizedBox(height: 10),

          const Text("Approved vs Pending",
              style: TextStyle(color: Colors.grey))
        ],
      ),
    );
  }

  // ================= USERS =================
  Widget usersPage() {
    return DataTable(
      columns: const [
        DataColumn(label: Text("User")),
        DataColumn(label: Text("Delete")),
      ],
      rows: users.map((u) {
        return DataRow(cells: [
          DataCell(Text(u)),
          DataCell(IconButton(
            icon: const Icon(Icons.delete, color: Colors.red),
            onPressed: () => confirm(() {
              setState(() => users.remove(u));
            }),
          ))
        ]);
      }).toList(),
    );
  }

  // ================= COMPANIES =================
  Widget companiesPage() {
    return DataTable(
      columns: const [
        DataColumn(label: Text("Company")),
        DataColumn(label: Text("Status")),
        DataColumn(label: Text("Action")),
      ],
      rows: companies.map((c) {
        return DataRow(cells: [
          DataCell(Text(c["name"])),

          DataCell(Text(c["status"])),

          DataCell(Row(
            children: [
              IconButton(
                icon: const Icon(Icons.check, color: Colors.green),
                onPressed: () {
                  setState(() => c["status"] = "Approved");
                },
              ),
              IconButton(
                icon: const Icon(Icons.delete, color: Colors.red),
                onPressed: () => confirm(() {
                  setState(() => companies.remove(c));
                }),
              ),
            ],
          )),
        ]);
      }).toList(),
    );
  }

  // ================= COMPLAINTS =================
  Widget complaintsPage() {
    return DataTable(
      columns: const [
        DataColumn(label: Text("Complaint")),
        DataColumn(label: Text("Status")),
        DataColumn(label: Text("Action")),
      ],
      rows: complaints.map((c) {
        return DataRow(cells: [
          DataCell(Text(c["title"])),

          DataCell(Text(c["status"])),

          DataCell(Row(
            children: [
              IconButton(
                icon: const Icon(Icons.hourglass_empty, color: Colors.orange),
                onPressed: () {
                  setState(() => c["status"] = "In Review");
                },
              ),
              IconButton(
                icon: const Icon(Icons.check, color: Colors.green),
                onPressed: () {
                  setState(() => c["status"] = "Resolved");
                },
              ),
              IconButton(
                icon: const Icon(Icons.delete, color: Colors.red),
                onPressed: () => confirm(() {
                  setState(() => complaints.remove(c));
                }),
              ),
            ],
          )),
        ]);
      }).toList(),
    );
  }

  // ================= CONFIRM =================
  void confirm(VoidCallback f) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Confirm"),
        content: const Text("Are you sure?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              f();
            },
            child: const Text("Delete"),
          )
        ],
      ),
    );
  }

  // ================= STYLE =================
  BoxDecoration box() {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      boxShadow: [
        BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10)
      ],
    );
  }
}