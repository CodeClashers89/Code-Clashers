import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:convert';
import '../services/auth_service.dart';

class CityStaffDashboard extends StatefulWidget {
  const CityStaffDashboard({super.key});

  @override
  State<CityStaffDashboard> createState() => _CityStaffDashboardState();
}

class _CityStaffDashboardState extends State<CityStaffDashboard> {
  int _selectedIndex = 0;
  
  static final List<Widget> _tabs = [
    const CityTerminalTab(),
    const ManageComplaintsTab(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: _tabs[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) => setState(() => _selectedIndex = index),
        selectedItemColor: const Color(0xFFD68910),
        unselectedItemColor: Colors.grey,
        selectedLabelStyle: GoogleFonts.outfit(fontWeight: FontWeight.w700, fontSize: 11),
        unselectedLabelStyle: GoogleFonts.outfit(fontWeight: FontWeight.w500, fontSize: 11),
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.dashboard_rounded), label: 'TERMINAL'),
          BottomNavigationBarItem(icon: Icon(Icons.assignment_rounded), label: 'COMPLAINTS'),
        ],
      ),
    );
  }
}

class CityTerminalTab extends StatefulWidget {
  const CityTerminalTab({super.key});

  @override
  State<CityTerminalTab> createState() => _CityTerminalTabState();
}

class _CityTerminalTabState extends State<CityTerminalTab> {
  int _pendingCount = 0;
  int _resolvedCount = 0;
  int _inProgressCount = 0;

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  Future<void> _loadStats() async {
    final authService = Provider.of<AuthService>(context, listen: false);
    try {
      final response = await authService.get('/city/stats/');
      if (response.statusCode == 200) {
        if (!mounted) return;
        final data = json.decode(response.body);
        if (mounted) {
          setState(() {
            _pendingCount = data['pending_complaints'] ?? 0;
            _resolvedCount = data['resolved_this_month'] ?? 0;
            _inProgressCount = data['in_progress'] ?? 0;
          });
        }
      }
    } catch (e) {
      // Ignored
    }
  }

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);
    
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text('CITY OPS TERMINAL', style: GoogleFonts.outfit(fontWeight: FontWeight.w900, letterSpacing: 1, fontSize: 18)),
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Color(0xFF0B4F87)),
            onPressed: () async {
              await authService.logout();
              if (!context.mounted) return;
              Navigator.pushReplacementNamed(context, '/login');
            },
          )
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadStats,
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            Text('STAFF: ${authService.username?.toUpperCase()}', 
              style: GoogleFonts.outfit(fontSize: 12, fontWeight: FontWeight.w800, color: const Color(0xFFD68910), letterSpacing: 2)),
            const SizedBox(height: 24),
            
            Row(
              children: [
                Expanded(child: _buildStatCard('PENDING', _pendingCount.toString(), Colors.red)),
                const SizedBox(width: 16),
                Expanded(child: _buildStatCard('IN PROGRESS', _inProgressCount.toString(), const Color(0xFFD68910))),
              ],
            ),
            const SizedBox(height: 16),
            _buildStatCard('RESOLVED (MONTH)', _resolvedCount.toString(), const Color(0xFF1E8449)),
            
            const SizedBox(height: 40),
            Text('CIVIC TOOLS', style: GoogleFonts.outfit(fontSize: 11, fontWeight: FontWeight.w800, color: Colors.grey.shade400, letterSpacing: 2)),
            const SizedBox(height: 16),
            _buildActionCard('COMPLAINT QUEUE', 'Manage urban infrastructure alerts and public grievances submitted by citizens.', Icons.assignment_rounded, const Color(0xFF0B4F87)),
            const SizedBox(height: 16),
            _buildActionCard('STATUS BROADCAST', 'Update citizens on ongoing repairs, public works, and resolution timelines.', Icons.campaign_rounded, const Color(0xFFD68910)),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: color, width: 4)),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 20, offset: const Offset(0, 10))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(value, style: GoogleFonts.outfit(fontSize: 32, fontWeight: FontWeight.w900, color: const Color(0xFF0B4F87))),
          Text(label, style: GoogleFonts.outfit(fontSize: 10, fontWeight: FontWeight.w800, color: Colors.grey.shade500, letterSpacing: 1)),
        ],
      ),
    );
  }

  Widget _buildActionCard(String title, String desc, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.grey.shade100),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(4)),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.w800, color: const Color(0xFF0B4F87))),
                const SizedBox(height: 4),
                Text(desc, style: GoogleFonts.outfit(fontSize: 11, color: Colors.grey.shade600, height: 1.4)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class ManageComplaintsTab extends StatefulWidget {
  const ManageComplaintsTab({super.key});

  @override
  State<ManageComplaintsTab> createState() => _ManageComplaintsTabState();
}

class _ManageComplaintsTabState extends State<ManageComplaintsTab> {
  List<dynamic> _complaints = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadComplaints();
  }

  Future<void> _loadComplaints() async {
    final authService = Provider.of<AuthService>(context, listen: false);
    try {
      final response = await authService.get('/city/complaints/all/');
      if (response.statusCode == 200) {
        setState(() {
          _complaints = json.decode(response.body);
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  void _showUpdateDialog(dynamic complaint) {
    final messageController = TextEditingController();
    final actionController = TextEditingController();
    String status = complaint['status'] ?? 'pending';
    
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => AlertDialog(
          title: Text('UPDATE COMPLAINT', style: GoogleFonts.outfit(fontWeight: FontWeight.w800, fontSize: 14)),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Issue: ${complaint['title']}', style: GoogleFonts.outfit(fontSize: 12, fontWeight: FontWeight.w700)),
                const SizedBox(height: 4),
                Text('Location: ${complaint['location']}', style: GoogleFonts.outfit(fontSize: 11, color: Colors.grey)),
                const SizedBox(height: 20),
                _buildModalLabel('UPDATE STATUS'),
                DropdownButtonFormField<String>(
                  initialValue: status,
                  items: const [
                    DropdownMenuItem(value: 'pending', child: Text('Pending')),
                    DropdownMenuItem(value: 'in_progress', child: Text('In Progress')),
                    DropdownMenuItem(value: 'resolved', child: Text('Resolved')),
                    DropdownMenuItem(value: 'closed', child: Text('Closed')),
                  ],
                  onChanged: (val) => setModalState(() => status = val!),
                  decoration: _modalInputDecoration(),
                ),
                const SizedBox(height: 16),
                _buildModalLabel('OFFICIAL MESSAGE *'),
                TextField(
                  controller: messageController,
                  maxLines: 3,
                  decoration: _modalInputDecoration(),
                ),
                const SizedBox(height: 16),
                _buildModalLabel('ACTION TAKEN'),
                TextField(
                  controller: actionController,
                  maxLines: 2,
                  decoration: _modalInputDecoration(),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('CANCEL')),
            ElevatedButton(
              onPressed: () async {
                if (messageController.text.isEmpty) return;
                final authService = Provider.of<AuthService>(context, listen: false);
                final response = await authService.post('/city/complaints/${complaint['id']}/update_status/', {
                  'status': status,
                  'message': messageController.text,
                  'action_taken': actionController.text,
                });
                if (response.statusCode == 200) {
                  if (!context.mounted) return;
                  Navigator.pop(context);
                  _loadComplaints();
                }
              },
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0B4F87)),
              child: const Text('SUBMIT UPDATE'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildModalLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(text, style: GoogleFonts.outfit(fontSize: 9, fontWeight: FontWeight.w800, color: Colors.grey, letterSpacing: 1)),
    );
  }

  InputDecoration _modalInputDecoration() {
    return InputDecoration(
      filled: true,
      fillColor: Colors.grey.shade50,
      border: const OutlineInputBorder(),
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text('COMPLAINT QUEUE', style: GoogleFonts.outfit(fontWeight: FontWeight.w900, letterSpacing: 1, fontSize: 18)),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: _isLoading 
        ? const Center(child: CircularProgressIndicator(color: Color(0xFFD68910)))
        : RefreshIndicator(
            onRefresh: _loadComplaints,
            child: _complaints.isEmpty 
              ? _buildEmptyState()
              : ListView.builder(
                  padding: const EdgeInsets.all(24),
                  itemCount: _complaints.length,
                  itemBuilder: (context, index) {
                    final c = _complaints[index];
                    return _buildComplaintCard(c);
                  },
                ),
          ),
    );
  }

  Widget _buildComplaintCard(dynamic c) {
    Color statusColor;
    switch (c['status']) {
      case 'resolved': statusColor = const Color(0xFF1E8449); break;
      case 'in_progress': statusColor = const Color(0xFFD68910); break;
      case 'pending': statusColor = Colors.red; break;
      default: statusColor = Colors.grey;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.grey.shade100),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(c['category_name']?.toUpperCase() ?? 'GENERAL', 
                style: GoogleFonts.outfit(fontSize: 10, fontWeight: FontWeight.w800, color: const Color(0xFF0B4F87), letterSpacing: 1)),
              _buildBadge(c['status']?.toUpperCase() ?? 'PENDING', statusColor),
            ],
          ),
          const SizedBox(height: 12),
          Text(c['title'] ?? 'No Title', style: GoogleFonts.outfit(fontSize: 15, fontWeight: FontWeight.w700, color: const Color(0xFF0B4F87))),
          const SizedBox(height: 8),
          Text(c['description'] ?? '', style: GoogleFonts.outfit(fontSize: 12, color: Colors.grey.shade600, height: 1.4)),
          const SizedBox(height: 12),
          Row(
            children: [
              const Icon(Icons.location_on_outlined, size: 14, color: Colors.grey),
              const SizedBox(width: 4),
              Text(c['location'] ?? 'Unknown', style: GoogleFonts.outfit(fontSize: 11, fontWeight: FontWeight.w600, color: Colors.grey)),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('By: ${c['citizen_name']}', style: GoogleFonts.outfit(fontSize: 11, fontWeight: FontWeight.w600, color: Colors.grey)),
              TextButton(
                onPressed: () => _showUpdateDialog(c),
                child: Text('UPDATE STATUS', style: GoogleFonts.outfit(fontSize: 11, fontWeight: FontWeight.w800, color: const Color(0xFFD68910))),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBadge(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(2)),
      child: Text(text, style: GoogleFonts.outfit(fontSize: 9, fontWeight: FontWeight.w800, color: color)),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.assignment_turned_in_outlined, size: 64, color: Colors.grey.shade300),
          const SizedBox(height: 16),
          Text('No complaints in queue', style: GoogleFonts.outfit(color: Colors.grey.shade400, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}
