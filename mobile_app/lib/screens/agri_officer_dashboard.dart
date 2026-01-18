import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:convert';
import '../services/auth_service.dart';

class AgriOfficerDashboard extends StatefulWidget {
  const AgriOfficerDashboard({super.key});

  @override
  State<AgriOfficerDashboard> createState() => _AgriOfficerDashboardState();
}

class _AgriOfficerDashboardState extends State<AgriOfficerDashboard> {
  int _selectedIndex = 0;
  
  static final List<Widget> _tabs = [
    const AgriTerminalTab(),
    const FarmerQueriesTab(),
    const PostUpdateTab(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: _tabs[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) => setState(() => _selectedIndex = index),
        selectedItemColor: const Color(0xFF1E8449),
        unselectedItemColor: Colors.grey,
        selectedLabelStyle: GoogleFonts.outfit(fontWeight: FontWeight.w700, fontSize: 11),
        unselectedLabelStyle: GoogleFonts.outfit(fontWeight: FontWeight.w500, fontSize: 11),
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.dashboard_rounded), label: 'TERMINAL'),
          BottomNavigationBarItem(icon: Icon(Icons.question_answer_rounded), label: 'QUERIES'),
          BottomNavigationBarItem(icon: Icon(Icons.campaign_rounded), label: 'BROADCAST'),
        ],
      ),
    );
  }
}

class AgriTerminalTab extends StatefulWidget {
  const AgriTerminalTab({super.key});

  @override
  State<AgriTerminalTab> createState() => _AgriTerminalTabState();
}

class _AgriTerminalTabState extends State<AgriTerminalTab> {
  int _pendingCount = 0;
  int _advisoriesCount = 0;
  int _updatesCount = 0;

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  Future<void> _loadStats() async {
    final authService = Provider.of<AuthService>(context, listen: false);
    try {
      final response = await authService.get('/agriculture/stats/');
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (mounted) {
          setState(() {
            _pendingCount = data['pending_queries'] ?? 0;
            _advisoriesCount = data['advisories_given'] ?? 0;
            _updatesCount = data['updates_posted'] ?? 0;
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
        title: Text('AGRI TERMINAL', style: GoogleFonts.outfit(fontWeight: FontWeight.w900, letterSpacing: 1, fontSize: 18)),
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
            Text('OFFICER: ${authService.username?.toUpperCase()}', 
              style: GoogleFonts.outfit(fontSize: 12, fontWeight: FontWeight.w800, color: const Color(0xFF1E8449), letterSpacing: 2)),
            const SizedBox(height: 24),
            
            Row(
              children: [
                Expanded(child: _buildStatCard('PENDING', _pendingCount.toString(), Colors.orange)),
                const SizedBox(width: 16),
                Expanded(child: _buildStatCard('ADVISORIES', _advisoriesCount.toString(), const Color(0xFF1E8449))),
              ],
            ),
            const SizedBox(height: 16),
            _buildStatCard('UPDATES POSTED', _updatesCount.toString(), const Color(0xFF0B4F87)),
            
            const SizedBox(height: 40),
            Text('DEPARTMENTAL TOOLS', style: GoogleFonts.outfit(fontSize: 11, fontWeight: FontWeight.w800, color: Colors.grey.shade400, letterSpacing: 2)),
            const SizedBox(height: 16),
            _buildActionCard('FARMER HELPLINE', 'Review and respond to pending agricultural queries from local districts.', Icons.question_answer_rounded, const Color(0xFF1E8449)),
            const SizedBox(height: 16),
            _buildActionCard('MARKET BROADCAST', 'Post real-time market prices and weather alerts for community farmers.', Icons.campaign_rounded, const Color(0xFF0B4F87)),
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

class FarmerQueriesTab extends StatefulWidget {
  const FarmerQueriesTab({super.key});

  @override
  State<FarmerQueriesTab> createState() => _FarmerQueriesTabState();
}

class _FarmerQueriesTabState extends State<FarmerQueriesTab> {
  List<dynamic> _queries = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadQueries();
  }

  Future<void> _loadQueries() async {
    final authService = Provider.of<AuthService>(context, listen: false);
    try {
      final response = await authService.get('/agriculture/queries/');
      if (response.statusCode == 200) {
        setState(() {
          _queries = json.decode(response.body);
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  void _showResponseDialog(dynamic query) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('RESPOND TO QUERY', style: GoogleFonts.outfit(fontWeight: FontWeight.w800, fontSize: 14)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Farmer: ${query['farmer_name']}', style: GoogleFonts.outfit(fontSize: 12, fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            Text(query['description'], style: GoogleFonts.outfit(fontSize: 12, color: Colors.grey.shade600)),
            const SizedBox(height: 20),
            TextField(
              controller: controller,
              maxLines: 4,
              decoration: InputDecoration(
                hintText: 'Enter your expert advice...',
                hintStyle: GoogleFonts.outfit(fontSize: 12),
                border: const OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('CANCEL')),
          ElevatedButton(
            onPressed: () async {
              final authService = Provider.of<AuthService>(context, listen: false);
              final response = await authService.post('/agriculture/queries/${query['id']}/respond/', {
                'expert_response': controller.text,
              });
              if (response.statusCode == 200) {
                if (!context.mounted) return;
                Navigator.pop(context);
                _loadQueries();
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF1E8449)),
            child: const Text('SEND ADVICE'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text('FARMER QUERIES', style: GoogleFonts.outfit(fontWeight: FontWeight.w900, letterSpacing: 1, fontSize: 18)),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: _isLoading 
        ? const Center(child: CircularProgressIndicator(color: Color(0xFF1E8449)))
        : RefreshIndicator(
            onRefresh: _loadQueries,
            child: _queries.isEmpty 
              ? _buildEmptyState()
              : ListView.builder(
                  padding: const EdgeInsets.all(24),
                  itemCount: _queries.length,
                  itemBuilder: (context, index) {
                    final q = _queries[index];
                    return _buildQueryCard(q);
                  },
                ),
          ),
    );
  }

  Widget _buildQueryCard(dynamic q) {
    final isResponded = q['expert_response'] != null;
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
              Text(q['crop_category_name']?.toUpperCase() ?? 'GENERAL', 
                style: GoogleFonts.outfit(fontSize: 10, fontWeight: FontWeight.w800, color: const Color(0xFF1E8449), letterSpacing: 1)),
              _buildBadge(isResponded ? 'RESPONDED' : 'PENDING', isResponded ? const Color(0xFF0B4F87) : Colors.orange),
            ],
          ),
          const SizedBox(height: 12),
          Text(q['title'] ?? 'No Title', style: GoogleFonts.outfit(fontSize: 15, fontWeight: FontWeight.w700, color: const Color(0xFF0B4F87))),
          const SizedBox(height: 8),
          Text(q['description'] ?? '', style: GoogleFonts.outfit(fontSize: 12, color: Colors.grey.shade600, height: 1.4)),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('By: ${q['farmer_name']}', style: GoogleFonts.outfit(fontSize: 11, fontWeight: FontWeight.w600, color: Colors.grey)),
              if (!isResponded)
                TextButton(
                  onPressed: () => _showResponseDialog(q),
                  child: Text('PROVIDE ADVICE', style: GoogleFonts.outfit(fontSize: 11, fontWeight: FontWeight.w800, color: const Color(0xFF1E8449))),
                ),
            ],
          ),
          if (isResponded) ...[
            const Divider(height: 24),
            Text('MY ADVICE:', style: GoogleFonts.outfit(fontSize: 9, fontWeight: FontWeight.w800, color: Colors.grey, letterSpacing: 1)),
            const SizedBox(height: 8),
            Text(q['expert_response'], style: GoogleFonts.outfit(fontSize: 12, fontStyle: FontStyle.italic, color: const Color(0xFF0B4F87))),
          ],
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
          Icon(Icons.inbox_outlined, size: 64, color: Colors.grey.shade300),
          const SizedBox(height: 16),
          Text('No pending queries found', style: GoogleFonts.outfit(color: Colors.grey.shade400, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}

class PostUpdateTab extends StatefulWidget {
  const PostUpdateTab({super.key});

  @override
  State<PostUpdateTab> createState() => _PostUpdateTabState();
}

class _PostUpdateTabState extends State<PostUpdateTab> {
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  final _districtController = TextEditingController();
  String _updateType = 'weather';
  bool _isPosting = false;

  Future<void> _postUpdate() async {
    setState(() => _isPosting = true);
    final authService = Provider.of<AuthService>(context, listen: false);
    try {
      final response = await authService.post('/agriculture/updates/', {
        'update_type': _updateType,
        'title': _titleController.text,
        'content': _contentController.text,
        'district': _districtController.text,
      });
      if (response.statusCode == 201) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Update Broadcasted Successfully')));
        _titleController.clear();
        _contentController.clear();
        _districtController.clear();
      }
    } catch (e) { /* error logged */ }
    setState(() => _isPosting = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text('MARKET BROADCAST', style: GoogleFonts.outfit(fontWeight: FontWeight.w900, letterSpacing: 1, fontSize: 18)),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('POST NEW UPDATE', style: GoogleFonts.outfit(fontSize: 11, fontWeight: FontWeight.w800, color: Colors.grey.shade400, letterSpacing: 2)),
            const SizedBox(height: 24),
            
            _buildLabel('UPDATE CATEGORY'),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              initialValue: _updateType,
              items: const [
                DropdownMenuItem(value: 'weather', child: Text('Weather Alert')),
                DropdownMenuItem(value: 'market', child: Text('Market Price')),
                DropdownMenuItem(value: 'scheme', child: Text('Government Scheme')),
                DropdownMenuItem(value: 'pest', child: Text('Pest Alert')),
                DropdownMenuItem(value: 'advisory', child: Text('General Advisory')),
              ],
              onChanged: (val) => setState(() => _updateType = val!),
              decoration: _inputDecoration(),
            ),
            
            const SizedBox(height: 20),
            _buildTextField(_titleController, 'BROADCAST TITLE', TextInputType.text),
            const SizedBox(height: 20),
            _buildTextField(_contentController, 'DETAILED CONTENT', TextInputType.text, maxLines: 4),
            const SizedBox(height: 20),
            _buildTextField(_districtController, 'TARGET DISTRICT (OPTIONAL)', TextInputType.text),
            
            const SizedBox(height: 40),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: _isPosting ? null : _postUpdate,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0B4F87),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                ),
                child: _isPosting
                    ? const CircularProgressIndicator(color: Colors.white)
                    : Text('POST TO DEPARTMENT', style: GoogleFonts.outfit(fontWeight: FontWeight.w700, letterSpacing: 1, color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Text(text, style: GoogleFonts.outfit(fontSize: 10, fontWeight: FontWeight.w800, color: const Color(0xFF0B4F87).withValues(alpha: 0.5)));
  }

  Widget _buildTextField(TextEditingController controller, String label, TextInputType type, {int maxLines = 1}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLabel(label),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: type,
          maxLines: maxLines,
          style: GoogleFonts.outfit(fontSize: 13, fontWeight: FontWeight.w600),
          decoration: _inputDecoration(),
        ),
      ],
    );
  }

  InputDecoration _inputDecoration() {
    return InputDecoration(
      filled: true,
      fillColor: Colors.grey.shade50,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(4), borderSide: BorderSide(color: Colors.grey.shade100)),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(4), borderSide: BorderSide(color: Colors.grey.shade100)),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    );
  }
}
