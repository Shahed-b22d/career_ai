import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class AdminDashboardPro extends StatefulWidget {
  const AdminDashboardPro({super.key});

  @override
  State<AdminDashboardPro> createState() => _AdminDashboardProState();
}

class _AdminDashboardProState extends State<AdminDashboardPro> {
  int _selectedIndex = 0;
  bool _isLoggedIn = true; 
  bool _isDark = true;

  @override
  Widget build(BuildContext context) {
    final Color kPrimary = const Color(0xFF0052FF);
    final Color kBg = _isDark ? const Color(0xFF0A0F1C) : const Color(0xFFF1F5F9);
    final Color kCard = _isDark ? const Color(0xFF161B29) : Colors.white;
    final Color kText = _isDark ? Colors.white : const Color(0xFF0A0F1C);

    if (!_isLoggedIn) return _buildLoginPage(kBg, kCard, kPrimary, kText);

    return Scaffold(
      backgroundColor: kBg,
      body: Row(
        children: [
          _buildSidebar(kCard, kPrimary, kText),
          Expanded(
            child: Column(
              children: [
                _buildTopBar(kCard, kPrimary, kText),
                Expanded(child: _buildBody(kText, kCard, kPrimary)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // --- التوب بار مع قائمة الإشعارات المنسدلة ---
  Widget _buildTopBar(Color kCard, Color kPrimary, Color kText) {
    return Container(
      height: 70,
      padding: const EdgeInsets.symmetric(horizontal: 25),
      decoration: BoxDecoration(color: kCard, border: Border(bottom: BorderSide(color: kText.withOpacity(0.1)))),
      child: Row(
        children: [
          Text("Admin Management Panel", style: TextStyle(color: kText.withOpacity(0.5))),
          const Spacer(),
          
          // زر تفعيل الوضع المظلم
          IconButton(
            onPressed: () => setState(() => _isDark = !_isDark),
            icon: Icon(_isDark ? Icons.light_mode : Icons.dark_mode, color: Colors.grey),
          ),

          const SizedBox(width: 10),

          // قائمة الإشعارات المنسدلة (Dropdown)
          PopupMenuButton<String>(
            icon: const Icon(Icons.notifications_none, color: Colors.grey),
            offset: const Offset(0, 50),
            color: kCard,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            onSelected: (value) {
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Selected: $value")));
            },
            itemBuilder: (BuildContext context) {
              return [
                _buildNotificationItem("New Company: TechNova", "2 min ago", Icons.business, kText),
                _buildNotificationItem("Payment Received: \$50", "15 min ago", Icons.attach_money, kText),
                _buildNotificationItem("New Complaint #14", "1 hour ago", Icons.warning_amber, kText),
              ];
            },
          ),

          const SizedBox(width: 15),
          CircleAvatar(radius: 15, backgroundColor: kPrimary, child: const Icon(Icons.person, size: 18, color: Colors.white)),
        ],
      ),
    );
  }

  PopupMenuItem<String> _buildNotificationItem(String title, String time, IconData icon, Color kText) {
    return PopupMenuItem(
      value: title,
      child: Row(
        children: [
          Icon(icon, size: 18, color: Colors.blueAccent),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: TextStyle(color: kText, fontSize: 13, fontWeight: FontWeight.w500)),
              Text(time, style: const TextStyle(color: Colors.grey, fontSize: 11)),
            ],
          ),
        ],
      ),
    );
  }

  // --- القائمة الجانبية ---
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
          const Spacer(),
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.redAccent),
            title: const Text("Logout", style: TextStyle(color: Colors.redAccent)),
            onTap: () => setState(() => _isLoggedIn = false),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _navItem(int index, String title, IconData icon, Color kPrimary, Color kText) {
    bool isSelected = _selectedIndex == index;
    return ListTile(
      selected: isSelected,
      selectedTileColor: kPrimary.withOpacity(0.1),
      leading: Icon(icon, color: isSelected ? kPrimary : Colors.grey),
      title: Text(title, style: TextStyle(color: isSelected ? kText : Colors.grey)),
      onTap: () => setState(() => _selectedIndex = index),
    );
  }

  Widget _buildBody(Color kText, Color kCard, Color kPrimary) {
    switch (_selectedIndex) {
      case 0: return _buildDashboardPage(kText, kCard, kPrimary);
      case 1: return _buildVerificationsPage(kText, kCard, kPrimary);
      case 2: return _buildTalentsPage(kText, kCard, kPrimary);
      default: return _buildDashboardPage(kText, kCard, kPrimary);
    }
  }

  // --- الصفحة الأولى: المخططات ---
  Widget _buildDashboardPage(Color kText, Color kCard, Color kPrimary) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(25),
      child: Column(
        children: [
          Row(
            children: [
              _statCard("Revenue", "\$12,450", Icons.payments, Colors.green, kCard, kText),
              const SizedBox(width: 20),
              _statCard("Active Jobs", "450", Icons.work, kPrimary, kCard, kText),
              const SizedBox(width: 20),
              _statCard("Tickets", "14", Icons.warning, Colors.orange, kCard, kText),
            ],
          ),
          const SizedBox(height: 25),
          Row(
            children: [
              Expanded(child: _chartBox("Companies Growth (Bar Chart)", _buildBarChart(kPrimary), kCard, kText)),
              const SizedBox(width: 20),
              Expanded(child: _chartBox("Talents Stats (Pie Chart)", _buildPieChart(kPrimary), kCard, kText)),
            ],
          ),
          const SizedBox(height: 25),
          _buildComplaintsList(kCard, kText, kPrimary),
        ],
      ),
    );
  }

  // --- الصفحة الثانية: الجداول والأزرار ---
  Widget _buildVerificationsPage(Color kText, Color kCard, Color kPrimary) {
    return Padding(
      padding: const EdgeInsets.all(25),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Company Registration (CR)", style: TextStyle(color: kText, fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 15),
            _buildVerificationTable(kCard, kText),
            const SizedBox(height: 40),
            Text("Job Post Payments", style: TextStyle(color: kText, fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 15),
            _buildPaymentTable(kCard, kText),
          ],
        ),
      ),
    );
  }

  Widget _buildTalentsPage(Color kText, Color kCard, Color kPrimary) {
    return ListView(
      padding: const EdgeInsets.all(25),
      children: [
        _talentActivityTile("Ahmad M.", "Uploaded CV", "Now", Icons.description, kCard, kText, kPrimary),
        _talentActivityTile("Sara K.", "Roadmap Done", "1h ago", Icons.map, kCard, kText, kPrimary),
      ],
    );
  }

  Widget _buildVerificationTable(Color kCard, Color kText) {
    return Container(
      decoration: BoxDecoration(color: kCard, borderRadius: BorderRadius.circular(15)),
      child: Table(
        children: [
          _tableHeader(["Company", "License", "Status", "Actions"]),
          _companyRow("TechNova", "Pending", kText),
          _companyRow("Future Soft", "Pending", kText),
        ],
      ),
    );
  }

  Widget _buildPaymentTable(Color kCard, Color kText) {
    return Container(
      decoration: BoxDecoration(color: kCard, borderRadius: BorderRadius.circular(15)),
      child: Table(
        children: [
          _tableHeader(["Job Title", "Amount", "Ref", "Action"]),
          _paymentRow("Flutter Dev", "\$50", "REF-9920", kText),
        ],
      ),
    );
  }

  TableRow _tableHeader(List<String> cols) => TableRow(
    children: cols.map((c) => Padding(padding: const EdgeInsets.all(15), child: Text(c, style: const TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)))).toList()
  );

  TableRow _companyRow(String name, String status, Color kText) => TableRow(
    children: [
      _cell(name, kText),
      TextButton.icon(
        onPressed: () => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Opening PDF for $name..."))), 
        icon: const Icon(Icons.picture_as_pdf, size: 18), 
        label: const Text("View PDF")
      ),
      _cell(status, kText),
      Row(
        children: [
          IconButton(
            onPressed: () => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("$name Verified ✅"))), 
            icon: const Icon(Icons.check_circle, color: Colors.green)
          ),
          IconButton(
            onPressed: () => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("$name Rejected ❌"))), 
            icon: const Icon(Icons.cancel, color: Colors.red)
          ),
        ],
      ),
    ]
  );

  TableRow _paymentRow(String title, String amount, String ref, Color kText) => TableRow(
    children: [
      _cell(title, kText), _cell(amount, kText), _cell(ref, kText),
     Padding(
  padding: const EdgeInsets.all(8.0),
  child: Align(
    alignment: Alignment.centerLeft,
    child: SizedBox(
      width: 90,
      height: 32,
      child: ElevatedButton(
        onPressed: () {},
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.blueAccent,
          padding: EdgeInsets.zero,
          minimumSize: Size.zero,
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        child: const Text(
          "Confirm",
          style: TextStyle(
            fontSize: 11,
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    ),
  ),
),
    ]
  );

  Widget _cell(String text, Color kText) => Padding(padding: const EdgeInsets.all(15), child: Text(text, style: TextStyle(color: kText)));

  Widget _buildBarChart(Color color) => BarChart(BarChartData(
    gridData: FlGridData(show: false),
    titlesData: FlTitlesData(show: false),
    borderData: FlBorderData(show: false),
    barGroups: List.generate(7, (i) => BarChartGroupData(x: i, barRods: [BarChartRodData(toY: (i + 2) * 5, color: color, width: 16)]))
  ));

  Widget _buildPieChart(Color color) => PieChart(PieChartData(sections: [
    PieChartSectionData(color: color, value: 60, title: '60%', radius: 40, titleStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
    PieChartSectionData(color: Colors.orange, value: 40, title: '40%', radius: 40, titleStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
  ]));

  Widget _statCard(String title, String val, IconData icon, Color color, Color kCard, Color kText) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(color: kCard, borderRadius: BorderRadius.circular(20)),
        child: Row(children: [
          Icon(icon, color: color, size: 30),
          const SizedBox(width: 15),
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(val, style: TextStyle(color: kText, fontSize: 20, fontWeight: FontWeight.bold)),
            Text(title, style: const TextStyle(color: Colors.grey, fontSize: 12)),
          ])
        ]),
      ),
    );
  }

  Widget _chartBox(String title, Widget chart, Color kCard, Color kText) {
    return Container(
      height: 300,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: kCard, borderRadius: BorderRadius.circular(20)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(title, style: TextStyle(color: kText, fontWeight: FontWeight.bold)),
        const SizedBox(height: 20),
        Expanded(child: chart),
      ]),
    );
  }

  Widget _buildComplaintsList(Color kCard, Color kText, Color kPrimary) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: kCard, borderRadius: BorderRadius.circular(20)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text("Recent Complaints", style: TextStyle(color: kText, fontWeight: FontWeight.bold)),
        const Divider(height: 30),
        _complaintItem("User #12", "Roadmap bug", kPrimary, kText),
      ]),
    );
  }

  Widget _complaintItem(String user, String msg, Color kPrimary, Color kText) => ListTile(
    title: Text(user, style: TextStyle(color: kPrimary, fontWeight: FontWeight.bold)),
    subtitle: Text(msg, style: TextStyle(color: kText.withOpacity(0.6))),
  );

  Widget _talentActivityTile(String name, String action, String time, IconData icon, Color kCard, Color kText, Color kPrimary) => Container(
    margin: const EdgeInsets.only(bottom: 10),
    decoration: BoxDecoration(color: kCard, borderRadius: BorderRadius.circular(15)),
    child: ListTile(
      leading: Icon(icon, color: kPrimary),
      title: Text(name, style: TextStyle(color: kText, fontWeight: FontWeight.bold)),
      subtitle: Text(action, style: const TextStyle(color: Colors.grey)),
      trailing: Text(time, style: TextStyle(color: kText.withOpacity(0.3))),
    ),
  );

  Widget _buildLoginPage(Color kBg, Color kCard, Color kPrimary, Color kText) {
    return Scaffold(
      backgroundColor: kBg,
      body: Center(
        child: Container(
          width: 350,
          padding: const EdgeInsets.all(40),
          decoration: BoxDecoration(color: kCard, borderRadius: BorderRadius.circular(20)),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.auto_awesome, color: kPrimary, size: 50),
              const SizedBox(height: 30),
              ElevatedButton(onPressed: () => setState(() => _isLoggedIn = true), child: const Text("Login")),
            ],
          ),
        ),
      ),
    );
  }
}