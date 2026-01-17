import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import 'dart:convert';

class CitizenHome extends StatefulWidget {
  const CitizenHome({super.key});

  @override
  State<CitizenHome> createState() => _CitizenHomeState();
}

class _CitizenHomeState extends State<CitizenHome> {
  int _selectedIndex = 0;
  
  final List<Widget> _screens = const [
    DashboardTab(),
    HealthcareTab(),
    AgricultureTab(),
    CityServicesTab(),
  ];

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Citizen Portal'),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications),
            onPressed: () {
              // TODO: Show notifications
            },
          ),
          PopupMenuButton<String>(
            itemBuilder: (context) => <PopupMenuEntry<String>>[
              PopupMenuItem<String>(
                enabled: false,
                child: ListTile(
                  leading: const Icon(Icons.person),
                  title: Text(authService.username ?? 'User'),
                  subtitle: const Text('Citizen'),
                ),
              ),
              const PopupMenuDivider(),
              PopupMenuItem<String>(
                value: 'logout',
                child: const ListTile(
                  leading: Icon(Icons.logout),
                  title: Text('Logout'),
                ),
              ),
            ],
            onSelected: (value) async {
              if (value == 'logout') {
                await authService.logout();
                if (!context.mounted) return;
                Navigator.of(context).pushReplacementNamed('/login');
              }
            },
          ),
        ],
      ),
      body: _screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) => setState(() => _selectedIndex = index),
        type: BottomNavigationBarType.fixed,
        selectedItemColor: const Color(0xFF2563EB),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.local_hospital),
            label: 'Healthcare',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.agriculture),
            label: 'Agriculture',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.location_city),
            label: 'City Services',
          ),
        ],
      ),
    );
  }
}

class DashboardTab extends StatelessWidget {
  const DashboardTab({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Text(
          'Welcome to Seva Setu',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        _buildServiceCard(
          context,
          'Healthcare Services',
          'Book appointments, view medical records',
          Icons.local_hospital,
          Colors.blue,
          () => Navigator.pushNamed(context, '/healthcare'),
        ),
        const SizedBox(height: 12),
        _buildServiceCard(
          context,
          'Agriculture Advisory',
          'Get farming tips and market updates',
          Icons.agriculture,
          Colors.green,
          () => Navigator.pushNamed(context, '/agriculture'),
        ),
        const SizedBox(height: 12),
        _buildServiceCard(
          context,
          'City Services',
          'Report complaints and track status',
          Icons.location_city,
          Colors.orange,
          () => Navigator.pushNamed(context, '/city-services'),
        ),
      ],
    );
  }

  Widget _buildServiceCard(
    BuildContext context,
    String title,
    String subtitle,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return Card(
      elevation: 2,
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: color.withOpacity(0.1),
          child: Icon(icon, color: color),
        ),
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: onTap,
      ),
    );
  }
}

class HealthcareTab extends StatefulWidget {
  const HealthcareTab({super.key});

  @override
  State<HealthcareTab> createState() => _HealthcareTabState();
}

class _HealthcareTabState extends State<HealthcareTab> {
  List<dynamic> _appointments = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadAppointments();
  }

  Future<void> _loadAppointments() async {
    final authService = Provider.of<AuthService>(context, listen: false);
    try {
      final response = await authService.get('/healthcare/appointments/');
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          _appointments = data is List ? data : data['results'] ?? [];
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return RefreshIndicator(
      onRefresh: _loadAppointments,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            'My Appointments',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          if (_appointments.isEmpty)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(32.0),
                child: Text('No appointments found'),
              ),
            )
          else
            ..._appointments.map((apt) => _buildAppointmentCard(apt)).toList(),
        ],
      ),
    );
  }

  Widget _buildAppointmentCard(dynamic appointment) {
    final status = appointment['status'] ?? 'scheduled';
    final statusColor = status == 'completed' ? Colors.green : Colors.blue;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  appointment['doctor_name'] ?? 'Doctor',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    status.toUpperCase(),
                    style: TextStyle(
                      color: statusColor,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.calendar_today, size: 16, color: Colors.grey),
                const SizedBox(width: 8),
                Text(appointment['appointment_date'] ?? ''),
                const SizedBox(width: 16),
                const Icon(Icons.access_time, size: 16, color: Colors.grey),
                const SizedBox(width: 8),
                Text(appointment['appointment_time'] ?? ''),
              ],
            ),
            if (appointment['reason'] != null) ...[
              const SizedBox(height: 8),
              Text(
                appointment['reason'],
                style: const TextStyle(color: Colors.grey),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class AgricultureTab extends StatefulWidget {
  const AgricultureTab({super.key});

  @override
  State<AgricultureTab> createState() => _AgricultureTabState();
}

class _AgricultureTabState extends State<AgricultureTab> {
  List<dynamic> _updates = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUpdates();
  }

  Future<void> _loadUpdates() async {
    final authService = Provider.of<AuthService>(context, listen: false);
    try {
      final response = await authService.get('/agriculture/updates/');
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          _updates = data is List ? data : data['results'] ?? [];
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return RefreshIndicator(
      onRefresh: _loadUpdates,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            'Agricultural Updates',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          if (_updates.isEmpty)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(32.0),
                child: Text('No updates available'),
              ),
            )
          else
            ..._updates.map((update) => _buildUpdateCard(update)).toList(),
        ],
      ),
    );
  }

  Widget _buildUpdateCard(dynamic update) {
    final isUrgent = update['is_urgent'] ?? false;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                if (isUrgent)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.red.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Text(
                      'URGENT',
                      style: TextStyle(
                        color: Colors.red,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    update['update_type'] ?? 'info',
                    style: const TextStyle(
                      color: Colors.blue,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              update['title'] ?? '',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              update['content'] ?? '',
              style: const TextStyle(color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}

class CityServicesTab extends StatefulWidget {
  const CityServicesTab({super.key});

  @override
  State<CityServicesTab> createState() => _CityServicesTabState();
}

class _CityServicesTabState extends State<CityServicesTab> {
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
      final response = await authService.get('/city/complaints/');
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          _complaints = data is List ? data : data['results'] ?? [];
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return RefreshIndicator(
      onRefresh: _loadComplaints,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            'My Complaints',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          if (_complaints.isEmpty)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(32.0),
                child: Text('No complaints found'),
              ),
            )
          else
            ..._complaints.map((complaint) => _buildComplaintCard(complaint)).toList(),
        ],
      ),
    );
  }

  Widget _buildComplaintCard(dynamic complaint) {
    final status = complaint['status'] ?? 'submitted';
    final statusColor = status == 'resolved' ? Colors.green : Colors.orange;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  complaint['complaint_id'] ?? 'N/A',
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    status.toUpperCase(),
                    style: TextStyle(
                      color: statusColor,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              complaint['title'] ?? '',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              complaint['description'] ?? '',
              style: const TextStyle(color: Colors.grey),
            ),
            if (complaint['location'] != null) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.location_on, size: 16, color: Colors.grey),
                  const SizedBox(width: 4),
                  Text(
                    complaint['location'],
                    style: const TextStyle(color: Colors.grey, fontSize: 12),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}
