import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/auth_service.dart';
import 'dart:convert';

class CitizenHome extends StatefulWidget {
  const CitizenHome({super.key});

  @override
  State<CitizenHome> createState() => _CitizenHomeState();
}

class _CitizenHomeState extends State<CitizenHome> {
  int _selectedIndex = 0;
  late List<Widget> _screens;

  @override
  void initState() {
    super.initState();
    _screens = [
      DashboardTab(onTabChange: (index) => setState(() => _selectedIndex = index)),
      const HealthcareTab(),
      const AgricultureTab(),
      const CityServicesTab(),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);
    
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Row(
          children: [
            Image.asset('assets/images/logo.png', height: 32),
            const SizedBox(width: 8),
            Text(
              'CITIZEN TERMINAL',
              style: GoogleFonts.outfit(
                fontWeight: FontWeight.w800,
                fontSize: 16,
                letterSpacing: 1.2,
                color: const Color(0xFF0B4F87),
              ),
            ),
          ],
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none_rounded, color: Color(0xFF0B4F87)),
            onPressed: () {},
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.account_circle_outlined, color: Color(0xFF0B4F87)),
            itemBuilder: (context) => <PopupMenuEntry<String>>[
              PopupMenuItem<String>(
                enabled: false,
                child: ListTile(
                  leading: const Icon(Icons.person, color: Color(0xFF0B4F87)),
                  title: Text(
                    authService.username ?? 'User',
                    style: GoogleFonts.outfit(fontWeight: FontWeight.w700),
                  ),
                  subtitle: Text(
                    'Citizen ID Verified',
                    style: GoogleFonts.outfit(fontSize: 12, color: const Color(0xFF1E8449)),
                  ),
                ),
              ),
              const PopupMenuDivider(),
              PopupMenuItem<String>(
                value: 'logout',
                child: ListTile(
                  leading: const Icon(Icons.logout, color: Colors.red),
                  title: Text('Logout', style: GoogleFonts.outfit(color: Colors.red)),
                ),
              ),
            ],
            onSelected: (value) async {
              if (value == 'logout') {
                await authService.logout();
                if (!mounted) return;
                Navigator.of(context).pushReplacementNamed('/login');
              }
            },
          ),
        ],
      ),
      body: _screens[_selectedIndex],
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          border: Border(top: BorderSide(color: Colors.grey.shade100, width: 1)),
        ),
        child: BottomNavigationBar(
          currentIndex: _selectedIndex,
          onTap: (index) => setState(() => _selectedIndex = index),
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.white,
          selectedItemColor: const Color(0xFF0B4F87),
          unselectedItemColor: Colors.grey.shade400,
          selectedLabelStyle: GoogleFonts.outfit(fontWeight: FontWeight.w700, fontSize: 11),
          unselectedLabelStyle: GoogleFonts.outfit(fontWeight: FontWeight.w600, fontSize: 11),
          elevation: 0,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.dashboard_outlined),
              activeIcon: Icon(Icons.dashboard),
              label: 'DASHBOARD',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.monitor_heart_outlined),
              activeIcon: Icon(Icons.monitor_heart),
              label: 'HEALTHCARE',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.agriculture_outlined),
              activeIcon: Icon(Icons.agriculture),
              label: 'AGRI DATA',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.location_city_outlined),
              activeIcon: Icon(Icons.location_city),
              label: 'CIVIC HUB',
            ),
          ],
        ),
      ),
    );
  }
}

class DashboardTab extends StatelessWidget {
  final Function(int) onTabChange;
  const DashboardTab({super.key, required this.onTabChange});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      children: [
        Text(
          'WELCOME BACK',
          style: GoogleFonts.outfit(
            fontSize: 11,
            fontWeight: FontWeight.w800,
            letterSpacing: 2,
            color: const Color(0xFF0B4F87).withValues(alpha: 0.5),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'CITIZEN SERVICES',
          style: GoogleFonts.outfit(
            fontSize: 32,
            fontWeight: FontWeight.w800,
            color: const Color(0xFF0B4F87),
            letterSpacing: 1,
          ),
        ),
        const SizedBox(height: 32),
        const SizedBox(height: 32),
        _buildSectionHeader('UTILITY ACCESS GRID'),
        const SizedBox(height: 16),
        _buildServiceCard(
          context,
          'HEALTHCARE TERMINAL',
          'Deploy appointments & health records',
          Icons.medication_outlined,
          const Color(0xFF0B4F87),
          () => onTabChange(1),
        ),
        _buildServiceCard(
          context,
          'AGRICULTURAL ADVISORY',
          'Access crop yields & market data',
          Icons.eco_outlined,
          const Color(0xFF1E8449),
          () => onTabChange(2),
        ),
        _buildServiceCard(
          context,
          'CITY SERVICE HUB',
          'Coordinate complaints & resolutions',
          Icons.account_balance_outlined,
          const Color(0xFFD68910),
          () => onTabChange(3),
        ),
      ],
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: GoogleFonts.outfit(
        fontSize: 12,
        fontWeight: FontWeight.w800,
        letterSpacing: 1.5,
        color: Colors.grey.shade400,
      ),
    );
  }


  Widget _buildServiceCard(
    BuildContext context,
    String title,
    String subtitle,
    IconData icon,
    Color accentColor,
    VoidCallback onTap,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.grey.shade100, width: 1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(4),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: accentColor.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Icon(icon, color: accentColor, size: 28),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: GoogleFonts.outfit(
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                          color: const Color(0xFF0B4F87),
                          letterSpacing: 1.5,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: GoogleFonts.outfit(
                          fontSize: 13,
                          color: Colors.grey.shade500,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(Icons.chevron_right_rounded, color: Colors.grey.shade300),
              ],
            ),
          ),
        ),
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
  List<dynamic> _doctors = [];
  List<dynamic> _medicalHistory = [];
  bool _isLoading = true;
  bool _isPredicting = false;
  bool _isBooking = false;
  Map<String, dynamic>? _predictionResult;

  // Disease Prediction Controllers
  final _ageController = TextEditingController();
  final _bmiController = TextEditingController();
  String _gender = 'M';
  String _smoking = 'low';
  String _alcohol = 'low';
  String _activity = 'low';
  bool _familyDiabetes = false;
  bool _familyHeart = false;
  bool _familyCancer = false;

  // Appointment Controllers
  String? _selectedDoctorId;
  final _appointmentDateController = TextEditingController();
  final _appointmentTimeController = TextEditingController();
  final _reasonController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    await Future.wait([
      _loadAppointments(),
      _loadDoctors(),
      _loadMedicalHistory(),
    ]);
  }

  Future<void> _loadAppointments() async {
    final authService = Provider.of<AuthService>(context, listen: false);
    try {
      final response = await authService.get('/healthcare/appointments/');
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          _appointments = data is List ? data : data['results'] ?? [];
        });
      }
    } catch (e) { /* error logged */ }
    if (mounted) setState(() => _isLoading = false);
  }

  Future<void> _loadMedicalHistory() async {
    final authService = Provider.of<AuthService>(context, listen: false);
    try {
      final response = await authService.get('/healthcare/medical-records/');
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          _medicalHistory = data is List ? data : data['results'] ?? [];
        });
      }
    } catch (e) { /* error logged */ }
  }

  Future<void> _loadDoctors() async {
    final authService = Provider.of<AuthService>(context, listen: false);
    try {
      final response = await authService.get('/healthcare/doctors/');
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          final rawDoctors = data is List ? data : data['results'] ?? [];
          // Ensure each doctor has at least a fallback name to prevent selection crashes
          _doctors = rawDoctors.map((d) {
            return {
              ...d,
              'display_name': d['full_name'] ?? d['user']?['username'] ?? 'Anonymous Doctor',
            };
          }).toList();
        });
      }
    } catch (e) { /* error logged */ }
  }

  Future<void> _predictDisease() async {
    setState(() => _isPredicting = true);
    final authService = Provider.of<AuthService>(context, listen: false);
    try {
      final response = await authService.post('/healthcare/predict-disease/', {
        'age': int.tryParse(_ageController.text) ?? 30,
        'gender': _gender,
        'bmi': double.tryParse(_bmiController.text) ?? 22.0,
        'smoking': _smoking,
        'alcohol': _alcohol,
        'activity': _activity,
        'family_diabetes': _familyDiabetes ? 1 : 0,
        'family_heart': _familyHeart ? 1 : 0,
        'family_cancer': _familyCancer ? 1 : 0,
      });

      if (response.statusCode == 200) {
        setState(() {
          _predictionResult = json.decode(response.body);
        });
      }
    } catch (e) { /* error logged */ }
    setState(() => _isPredicting = false);
  }

  Future<void> _bookAppointment() async {
    if (_selectedDoctorId == null) return;
    setState(() => _isBooking = true);
    final authService = Provider.of<AuthService>(context, listen: false);
    try {
      final response = await authService.post('/healthcare/appointments/', {
        'doctor': _selectedDoctorId,
        'appointment_date': _appointmentDateController.text,
        'appointment_time': _appointmentTimeController.text,
        'reason': _reasonController.text,
      });

      if (response.statusCode == 201) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Appointment booked successfully!')),
        );
        _loadAppointments();
        _reasonController.clear();
      }
    } catch (e) { /* error logged */ }
    setState(() => _isBooking = false);
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator(color: Color(0xFF0B4F87)));
    }

    return RefreshIndicator(
      onRefresh: _loadData,
      child: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        children: [
          _buildSectionHeader('DISEASE RISK PREDICTION'),
          const SizedBox(height: 16),
          _buildPredictionForm(),
          if (_predictionResult != null) _buildPredictionResults(),
          const SizedBox(height: 40),
          _buildSectionHeader('MY MEDICAL HISTORY'),
          const SizedBox(height: 16),
          if (_medicalHistory.isEmpty)
            _buildEmptyState('No medical records found')
          else
            ..._medicalHistory.map((rec) => _buildMedicalRecordCard(rec)).toList(),
          const SizedBox(height: 40),
          _buildSectionHeader('BOOK APPOINTMENT'),
          const SizedBox(height: 16),
          _buildAppointmentForm(),
          const SizedBox(height: 48),
          _buildSectionHeader('ACTIVE APPOINTMENTS'),
          const SizedBox(height: 16),
          if (_appointments.isEmpty)
            _buildEmptyState('No active appointments found')
          else
            ..._appointments.map((apt) => _buildAppointmentCard(apt)).toList(),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: GoogleFonts.outfit(
        fontSize: 11,
        fontWeight: FontWeight.w800,
        letterSpacing: 2,
        color: const Color(0xFF0B4F87).withValues(alpha: 0.5),
      ),
    );
  }

  Widget _buildEmptyState(String message) {
    return Container(
      padding: const EdgeInsets.all(40),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Column(
        children: [
          Icon(Icons.inbox_outlined, color: Colors.grey.shade300, size: 48),
          const SizedBox(height: 16),
          Text(
            message,
            style: GoogleFonts.outfit(color: Colors.grey.shade400, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }

  Widget _buildPredictionForm() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.grey.shade100),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(child: _buildTextField(_ageController, 'AGE', TextInputType.number)),
              const SizedBox(width: 16),
              Expanded(
                child: _buildDropdown('GENDER', _gender, ['M', 'F'], (val) => setState(() => _gender = val!)),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(child: _buildTextField(_bmiController, 'BMI', const TextInputType.numberWithOptions(decimal: true))),
              const SizedBox(width: 16),
              Expanded(
                child: _buildDropdown('SMOKING', _smoking, ['low', 'moderate', 'high'], (val) => setState(() => _smoking = val!)),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildDropdown('ALCOHOL', _alcohol, ['low', 'moderate', 'high'], (val) => setState(() => _alcohol = val!)),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildDropdown('PHYSICAL ACTIVITY', _activity, ['low', 'moderate', 'high'], (val) => setState(() => _activity = val!)),
              ),
            ],
          ),
          const SizedBox(height: 24),
          _buildLabel('FAMILY HISTORY'),
          const SizedBox(height: 8),
          Wrap(
            spacing: 16,
            children: [
              _buildCheckbox('DIABETES', _familyDiabetes, (val) => setState(() => _familyDiabetes = val!)),
              _buildCheckbox('HEART', _familyHeart, (val) => setState(() => _familyHeart = val!)),
              _buildCheckbox('CANCER', _familyCancer, (val) => setState(() => _familyCancer = val!)),
            ],
          ),
          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: _isPredicting ? null : _predictDisease,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1E8449),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
              ),
              child: _isPredicting
                  ? const CircularProgressIndicator(color: Colors.white)
                  : Text('EXECUTE RISK ANALYSIS', style: GoogleFonts.outfit(fontWeight: FontWeight.w700, letterSpacing: 1, color: Colors.white)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPredictionResults() {
    return Container(
      margin: const EdgeInsets.only(top: 24),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF0B4F87).withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: const Color(0xFF0B4F87).withValues(alpha: 0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'RISK ANALYSIS REPORT',
            style: GoogleFonts.outfit(fontSize: 11, fontWeight: FontWeight.w800, color: const Color(0xFF0B4F87), letterSpacing: 1),
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildRiskIndicator('DIABETES', _predictionResult?['diabetes']),
              _buildRiskIndicator('HEART', _predictionResult?['heart']),
              _buildRiskIndicator('CANCER', _predictionResult?['cancer']),
            ],
          ),
          if (_predictionResult!['advice'] != null && (_predictionResult!['advice'] as List).isNotEmpty) ...[
            const SizedBox(height: 24),
            _buildLabel('LIFESTYLE ADVICE'),
            const SizedBox(height: 8),
            ...(_predictionResult!['advice'] as List).map((a) => Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Text('• $a', style: GoogleFonts.outfit(fontSize: 13, color: Colors.grey.shade700)),
            )),
          ],
        ],
      ),
    );
  }

  Widget _buildRiskIndicator(String label, dynamic value) {
    double risk = 0.0;
    if (value != null) {
      if (value is num) {
        risk = value.toDouble();
      } else if (value is String) {
        risk = double.tryParse(value) ?? 0.0;
      }
    }
    Color color = risk > 50 ? Colors.red : (risk > 20 ? Colors.orange : Colors.green);
    return Column(
      children: [
        Text(
          '${risk.toInt()}%',
          style: GoogleFonts.outfit(fontSize: 24, fontWeight: FontWeight.w800, color: color),
        ),
        Text(
          label,
          style: GoogleFonts.outfit(fontSize: 10, fontWeight: FontWeight.w700, color: Colors.grey.shade500),
        ),
      ],
    );
  }

  Widget _buildAppointmentForm() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.grey.shade100),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildDropdown(
            'SELECT DOCTOR',
            _selectedDoctorId,
            _doctors.map((d) => d['id'].toString()).toList(),
            (val) => setState(() => _selectedDoctorId = val),
            displayNames: _doctors.map((d) => d['display_name'] as String).toList(),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(child: _buildTextField(_appointmentDateController, 'DATE (YYYY-MM-DD)', TextInputType.datetime)),
              const SizedBox(width: 16),
              Expanded(child: _buildTextField(_appointmentTimeController, 'TIME (HH:MM)', TextInputType.datetime)),
            ],
          ),
          const SizedBox(height: 16),
          _buildTextField(_reasonController, 'REASON FOR VISIT', TextInputType.text, maxLines: 2),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: _isBooking ? null : _bookAppointment,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0B4F87),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
              ),
              child: _isBooking
                  ? const CircularProgressIndicator(color: Colors.white)
                  : Text('INITIALIZE APPOINTMENT', style: GoogleFonts.outfit(fontWeight: FontWeight.w700, letterSpacing: 1, color: Colors.white)),
            ),
          ),
        ],
      ),
    );
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
          style: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.w500),
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.grey.shade50,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(4), borderSide: BorderSide(color: Colors.grey.shade100)),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(4), borderSide: BorderSide(color: Colors.grey.shade100)),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
        ),
      ],
    );
  }

  Widget _buildDropdown(String label, String? value, List<String> items, Function(String?) onChanged, {List<String>? displayNames}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLabel(label),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          initialValue: items.contains(value) ? value : null,
          items: items.asMap().entries.map((entry) {
            return DropdownMenuItem(
              value: entry.value,
              child: Text(displayNames != null ? displayNames[entry.key] : entry.value.toUpperCase(), style: GoogleFonts.outfit(fontSize: 13, fontWeight: FontWeight.w600)),
            );
          }).toList(),
          onChanged: onChanged,
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.grey.shade50,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(4), borderSide: BorderSide(color: Colors.grey.shade100)),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(4), borderSide: BorderSide(color: Colors.grey.shade100)),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
        ),
      ],
    );
  }

  Widget _buildCheckbox(String label, bool value, Function(bool?) onChanged) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: 24,
          height: 24,
          child: Checkbox(
            value: value,
            onChanged: onChanged,
            activeColor: const Color(0xFF1E8449),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(2)),
          ),
        ),
        const SizedBox(width: 8),
        Text(label, style: GoogleFonts.outfit(fontSize: 11, fontWeight: FontWeight.w700, color: Colors.grey.shade600)),
      ],
    );
  }

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: GoogleFonts.outfit(fontSize: 10, fontWeight: FontWeight.w800, letterSpacing: 1, color: Colors.grey.shade400),
    );
  }

  Widget _buildMedicalRecordCard(dynamic record) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
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
              Text(
                (record['diagnosis'] ?? 'Clinical Record').toUpperCase(),
                style: GoogleFonts.outfit(fontWeight: FontWeight.w800, fontSize: 13, color: const Color(0xFF0B4F87)),
              ),
              Text(
                record['date_recorded'] ?? '',
                style: GoogleFonts.outfit(fontSize: 11, color: Colors.grey.shade500, fontWeight: FontWeight.w600),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'PHYSICIAN: ${record['doctor_name'] ?? 'Medical Staff'}',
            style: GoogleFonts.outfit(fontSize: 11, fontWeight: FontWeight.w700, color: const Color(0xFF1E8449), letterSpacing: 0.5),
          ),
          const SizedBox(height: 8),
          Text(
            record['notes'] ?? 'No clinical notes provided.',
            style: GoogleFonts.outfit(fontSize: 13, color: Colors.grey.shade600),
          ),
          if (record['prescriptions'] != null && (record['prescriptions'] as List).isNotEmpty) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: Colors.grey.shade50, borderRadius: BorderRadius.circular(4)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('PRESCRIPTION DATA', style: GoogleFonts.outfit(fontSize: 10, fontWeight: FontWeight.w800, color: Colors.grey.shade400)),
                  const SizedBox(height: 8),
                  ...(record['prescriptions'] as List).map((p) => Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Text('• ${p['medication']} (${p['dosage']} - ${p['frequency']})', style: GoogleFonts.outfit(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.black87)),
                  )),
                ],
              ),
            ),
          ],
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
                    color: statusColor.withValues(alpha: 0.1),
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
  List<dynamic> _queries = [];
  List<dynamic> _categories = [];
  bool _isLoading = true;
  bool _isRecommending = false;
  bool _isSubmittingQuery = false;
  Map<String, dynamic>? _recommendationResult;

  // Crop Recommendation Controllers
  String _selectedDistrict = 'Ahmedabad';
  String _selectedSeason = 'Kharif';
  String _selectedSoilType = 'Black';
  String _selectedIrrigation = 'Yes';
  String _selectedRainfall = 'Medium';
  final _landSizeController = TextEditingController();

  // Query Controllers
  String? _selectedCategoryId;
  final _queryTitleController = TextEditingController();
  final _queryDescController = TextEditingController();
  final _queryLocationController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    await Future.wait([
      _loadUpdates(),
      _loadQueries(),
      _loadCategories(),
    ]);
  }

  Future<void> _loadUpdates() async {
    final authService = Provider.of<AuthService>(context, listen: false);
    try {
      final response = await authService.get('/agriculture/updates/');
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          _updates = data is List ? data : data['results'] ?? [];
        });
      }
    } catch (e) { /* error logged */ }
    if (mounted) setState(() => _isLoading = false);
  }

  Future<void> _loadQueries() async {
    final authService = Provider.of<AuthService>(context, listen: false);
    try {
      final response = await authService.get('/agriculture/queries/');
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          _queries = data is List ? data : data['results'] ?? [];
        });
      }
    } catch (e) { /* error logged */ }
  }

  Future<void> _loadCategories() async {
    final authService = Provider.of<AuthService>(context, listen: false);
    try {
      final response = await authService.get('/agriculture/crop-categories/');
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          _categories = data is List ? data : data['results'] ?? [];
        });
      }
    } catch (e) { /* error logged */ }
  }

  Future<void> _recommendCrop() async {
    setState(() => _isRecommending = true);
    final authService = Provider.of<AuthService>(context, listen: false);
    try {
      final response = await authService.post('/agriculture/recommend-crop/', {
        'location': _selectedDistrict,
        'season': _selectedSeason,
        'soil_type': _selectedSoilType,
        'irrigation': _selectedIrrigation,
        'rainfall': _selectedRainfall,
        'land_size': double.tryParse(_landSizeController.text) ?? 1.0,
      });

      if (response.statusCode == 200) {
        setState(() {
          _recommendationResult = json.decode(response.body);
        });
      }
    } catch (e) { /* error logged */ }
    setState(() => _isRecommending = false);
  }

  Future<void> _submitQuery() async {
    setState(() => _isSubmittingQuery = true);
    final authService = Provider.of<AuthService>(context, listen: false);
    final messenger = ScaffoldMessenger.of(context);
    try {
      final response = await authService.post('/agriculture/queries/', {
        'crop_category': _selectedCategoryId,
        'title': _queryTitleController.text,
        'description': _queryDescController.text,
        'location': _queryLocationController.text,
      });
      if (!mounted) return;
      if (response.statusCode == 201) {
        messenger.showSnackBar(
          const SnackBar(content: Text('Query submitted successfully!')),
        );
        _loadQueries();
        _queryTitleController.clear();
        _queryDescController.clear();
        _queryLocationController.clear();
      }
    } catch (e) { /* error logged */ }
    setState(() => _isSubmittingQuery = false);
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator(color: Color(0xFF1E8449)));
    }

    return RefreshIndicator(
      onRefresh: _loadData,
      child: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        children: [
          _buildSectionHeader('CROP RECOMMENDATION ENGINE'),
          const SizedBox(height: 16),
          _buildCropRecommendationForm(),
          const SizedBox(height: 40),
          _buildSectionHeader('SUBMIT ADVISORY QUERY'),
          const SizedBox(height: 16),
          _buildQueryForm(),
          const SizedBox(height: 48),
          _buildSectionHeader('MY ADVISORY QUERIES'),
          const SizedBox(height: 16),
          if (_queries.isEmpty)
            _buildEmptyState('No active queries found')
          else
            ..._queries.map((q) => _buildQueryCard(q)).toList(),
          const SizedBox(height: 40),
          _buildSectionHeader('RECENT UPDATES'),
          const SizedBox(height: 16),
          if (_updates.isEmpty)
            _buildEmptyState('No recent updates')
          else
            ..._updates.map((update) => _buildUpdateCard(update)).toList(),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: GoogleFonts.outfit(
        fontSize: 11,
        fontWeight: FontWeight.w800,
        letterSpacing: 2,
        color: const Color(0xFF1E8449).withValues(alpha: 0.5),
      ),
    );
  }

  Widget _buildEmptyState(String message) {
    return Container(
      padding: const EdgeInsets.all(40),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Column(
        children: [
          Icon(Icons.inbox_outlined, color: Colors.grey.shade300, size: 48),
          const SizedBox(height: 16),
          Text(
            message,
            style: GoogleFonts.outfit(color: Colors.grey.shade400, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }

  Widget _buildCropRecommendationForm() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.grey.shade100),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: _buildDropdown(
                  'DISTRICT',
                  _selectedDistrict,
                  ['Ahmedabad', 'Rajkot', 'Surat', 'Vadodara', 'Pune', 'Nagpur', 'Nashik', 'Aurangabad', 'Ludhiana', 'Amritsar', 'Jalandhar', 'Gurgaon', 'Lucknow', 'Kanpur Nagar', 'Varanasi', 'Patna', 'Gaya', 'Chennai', 'Coimbatore', 'Madurai', 'Guntur', 'Warangal', 'Kolkata', 'Nadia', 'Howrah', 'Jaipur', 'Jodhpur', 'Bikaner'],
                  (val) => setState(() => _selectedDistrict = val!),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildDropdown(
                  'SEASON',
                  _selectedSeason,
                  ['Kharif', 'Rabi'],
                  (val) => setState(() => _selectedSeason = val!),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildDropdown(
                  'SOIL TYPE',
                  _selectedSoilType,
                  ['Black', 'Loamy', 'Clay', 'Sandy', 'Red', 'Alluvial'],
                  (val) => setState(() => _selectedSoilType = val!),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildDropdown(
                  'IRRIGATION',
                  _selectedIrrigation,
                  ['Yes', 'No'],
                  (val) => setState(() => _selectedIrrigation = val!),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildDropdown(
                  'RAINFALL',
                  _selectedRainfall,
                  ['Low', 'Medium', 'High'],
                  (val) => setState(() => _selectedRainfall = val!),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildTextField(_landSizeController, 'LAND SIZE (ACRES)', TextInputType.number),
              ),
            ],
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: _isRecommending ? null : _recommendCrop,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1E8449),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
              ),
              child: _isRecommending
                  ? const CircularProgressIndicator(color: Colors.white)
                  : Text('GENERATE RECOMMENDATION', style: GoogleFonts.outfit(fontWeight: FontWeight.w700, letterSpacing: 1, color: Colors.white)),
            ),
          ),
          if (_recommendationResult != null) ...[
            const SizedBox(height: 24),
            const Divider(),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFF1E8449).withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'RECOMMENDED CROP',
                    style: GoogleFonts.outfit(fontSize: 11, fontWeight: FontWeight.w800, letterSpacing: 2, color: const Color(0xFF1E8449)),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _recommendationResult!['recommended_crop'] ?? 'N/A',
                    style: GoogleFonts.outfit(fontSize: 24, fontWeight: FontWeight.w900, color: const Color(0xFF1E8449)),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'OPTIMAL CONDITIONS',
                    style: GoogleFonts.outfit(fontSize: 10, fontWeight: FontWeight.w800, color: Colors.grey.shade500),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _recommendationResult!['conditions'] ?? 'Standard seasonal conditions',
                    style: GoogleFonts.outfit(fontSize: 13, color: Colors.black87),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildQueryForm() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.grey.shade100),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildDropdown(
            'CROP CATEGORY (OPTIONAL)',
            _selectedCategoryId,
            _categories.map((c) => c['id'].toString()).toList(),
            (val) => setState(() => _selectedCategoryId = val),
            displayNames: _categories.map((c) => c['name'] as String).toList(),
          ),
          const SizedBox(height: 16),
          _buildTextField(_queryTitleController, 'QUERY TITLE', TextInputType.text),
          const SizedBox(height: 16),
          _buildTextField(_queryDescController, 'DESCRIPTION', TextInputType.text, maxLines: 3),
          const SizedBox(height: 16),
          _buildTextField(_queryLocationController, 'VILLAGE / LOCATION', TextInputType.text),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: _isSubmittingQuery ? null : _submitQuery,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0B4F87),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
              ),
              child: _isSubmittingQuery
                  ? const CircularProgressIndicator(color: Colors.white)
                  : Text('SUBMIT ADVISORY REQUEST', style: GoogleFonts.outfit(fontWeight: FontWeight.w700, letterSpacing: 1, color: Colors.white)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQueryCard(dynamic query) {
    final hasResponse = query['expert_response'] != null;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
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
              _buildBadge(query['crop_category_name'] ?? 'General', const Color(0xFF1E8449)),
              _buildBadge(hasResponse ? 'RESPONDED' : 'PENDING', hasResponse ? const Color(0xFF0B4F87) : Colors.grey),
            ],
          ),
          const SizedBox(height: 12),
          Text(query['title'] ?? '', style: GoogleFonts.outfit(fontSize: 15, fontWeight: FontWeight.w700, color: const Color(0xFF0B4F87))),
          const SizedBox(height: 4),
          Text(query['description'] ?? '', style: GoogleFonts.outfit(fontSize: 13, color: Colors.grey.shade600), maxLines: 2, overflow: TextOverflow.ellipsis),
        ],
      ),
    );
  }

  Widget _buildBadge(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(2)),
      child: Text(text.toUpperCase(), style: GoogleFonts.outfit(fontSize: 9, fontWeight: FontWeight.w800, color: color, letterSpacing: 0.5)),
    );
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
          style: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.w500),
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.grey.shade50,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(4), borderSide: BorderSide(color: Colors.grey.shade100)),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(4), borderSide: BorderSide(color: Colors.grey.shade100)),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
        ),
      ],
    );
  }

  Widget _buildDropdown(String label, String? value, List<String> items, Function(String?) onChanged, {List<String>? displayNames}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLabel(label),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          initialValue: items.contains(value) ? value : null,
          items: items.asMap().entries.map((entry) {
            return DropdownMenuItem(
              value: entry.value,
              child: Text(displayNames != null ? displayNames[entry.key] : entry.value.toUpperCase(), style: GoogleFonts.outfit(fontSize: 13, fontWeight: FontWeight.w600)),
            );
          }).toList(),
          onChanged: onChanged,
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.grey.shade50,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(4), borderSide: BorderSide(color: Colors.grey.shade100)),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(4), borderSide: BorderSide(color: Colors.grey.shade100)),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
        ),
      ],
    );
  }

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: GoogleFonts.outfit(fontSize: 10, fontWeight: FontWeight.w800, letterSpacing: 1, color: Colors.grey.shade400),
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
                      color: Colors.red.withValues(alpha: 0.1),
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
                    color: Colors.blue.withValues(alpha: 0.1),
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
  List<dynamic> _categories = [];
  bool _isLoading = true;
  bool _isSubmitting = false;

  // Complaint Controllers
  String? _selectedCityCategoryId;
  final _cityTitleController = TextEditingController();
  final _cityDescController = TextEditingController();
  final _cityLocationController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    await Future.wait([
      _loadComplaints(),
      _loadCategories(),
    ]);
  }

  Future<void> _loadComplaints() async {
    final authService = Provider.of<AuthService>(context, listen: false);
    try {
      final response = await authService.get('/city/complaints/');
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          _complaints = data is List ? data : data['results'] ?? [];
        });
      }
    } catch (e) { /* error logged */ }
    if (mounted) setState(() => _isLoading = false);
  }

  Future<void> _loadCategories() async {
    final authService = Provider.of<AuthService>(context, listen: false);
    try {
      final response = await authService.get('/city/categories/');
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          _categories = data is List ? data : data['results'] ?? [];
        });
      }
    } catch (e) { /* error logged */ }
  }

  Future<void> _submitComplaint() async {
    if (_selectedCityCategoryId == null) return;
    setState(() => _isSubmitting = true);
    final authService = Provider.of<AuthService>(context, listen: false);
    try {
      final response = await authService.post('/city/complaints/', {
        'category': _selectedCityCategoryId,
        'title': _cityTitleController.text,
        'description': _cityDescController.text,
        'location': _cityLocationController.text,
      });

      if (response.statusCode == 201) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Complaint submitted successfully!')),
        );
        _loadComplaints();
        _cityTitleController.clear();
        _cityDescController.clear();
        _cityLocationController.clear();
      }
    } catch (e) { /* error logged */ }
    setState(() => _isSubmitting = false);
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator(color: Color(0xFFD68910)));
    }

    return RefreshIndicator(
      onRefresh: _loadData,
      child: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        children: [
          _buildSectionHeader('REPORT CIVIC GRIEVANCE'),
          const SizedBox(height: 16),
          _buildComplaintForm(),
          const SizedBox(height: 48),
          _buildSectionHeader('MY ACTIVE COMPLAINTS'),
          const SizedBox(height: 16),
          if (_complaints.isEmpty)
            _buildEmptyState('No active complaints found')
          else
            ..._complaints.map((c) => _buildComplaintCard(c)).toList(),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: GoogleFonts.outfit(
        fontSize: 11,
        fontWeight: FontWeight.w800,
        letterSpacing: 2,
        color: const Color(0xFFD68910).withValues(alpha: 0.5),
      ),
    );
  }

  Widget _buildEmptyState(String message) {
    return Container(
      padding: const EdgeInsets.all(40),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Column(
        children: [
          Icon(Icons.inbox_outlined, color: Colors.grey.shade300, size: 48),
          const SizedBox(height: 16),
          Text(
            message,
            style: GoogleFonts.outfit(color: Colors.grey.shade400, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }

  Widget _buildComplaintForm() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.grey.shade100),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildDropdown(
            'SERVICE CATEGORY',
            _selectedCityCategoryId,
            _categories.map((c) => c['id'].toString()).toList(),
            (val) => setState(() => _selectedCityCategoryId = val),
            displayNames: _categories.map((c) => c['name'] as String).toList(),
          ),
          const SizedBox(height: 16),
          _buildTextField(_cityTitleController, 'GRIEVANCE TITLE', TextInputType.text),
          const SizedBox(height: 16),
          _buildTextField(_cityDescController, 'DETAILED DESCRIPTION', TextInputType.text, maxLines: 3),
          const SizedBox(height: 16),
          _buildTextField(_cityLocationController, 'EXACT LOCATION / ADDRESS', TextInputType.text),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: _isSubmitting ? null : _submitComplaint,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFD68910),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
              ),
              child: _isSubmitting
                  ? const CircularProgressIndicator(color: Colors.white)
                  : Text('DEPLOY GRIEVANCE REPORT', style: GoogleFonts.outfit(fontWeight: FontWeight.w700, letterSpacing: 1, color: Colors.white)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildComplaintCard(dynamic complaint) {
    final status = complaint['status']?.toString().toUpperCase() ?? 'PENDING';
    final statusColor = status == 'RESOLVED' ? const Color(0xFF1E8449) : (status == 'IN_PROGRESS' ? const Color(0xFF0B4F87) : Colors.orange);
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
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
              _buildBadge(complaint['category_name'] ?? 'Other', const Color(0xFFD68910)),
              _buildBadge(status, statusColor),
            ],
          ),
          const SizedBox(height: 12),
          Text(complaint['title'] ?? '', style: GoogleFonts.outfit(fontSize: 15, fontWeight: FontWeight.w700, color: const Color(0xFF0B4F87))),
          const SizedBox(height: 4),
          Text(complaint['description'] ?? '', style: GoogleFonts.outfit(fontSize: 13, color: Colors.grey.shade600), maxLines: 2, overflow: TextOverflow.ellipsis),
          const SizedBox(height: 12),
          Row(
            children: [
              const Icon(Icons.location_on_outlined, size: 14, color: Colors.grey),
              const SizedBox(width: 4),
              Text(complaint['location'] ?? '', style: GoogleFonts.outfit(fontSize: 11, color: Colors.grey.shade500, fontWeight: FontWeight.w600)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBadge(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(2)),
      child: Text(text.toUpperCase(), style: GoogleFonts.outfit(fontSize: 9, fontWeight: FontWeight.w800, color: color, letterSpacing: 0.5)),
    );
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
          style: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.w500),
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.grey.shade50,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(4), borderSide: BorderSide(color: Colors.grey.shade100)),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(4), borderSide: BorderSide(color: Colors.grey.shade100)),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
        ),
      ],
    );
  }

  Widget _buildDropdown(String label, String? value, List<String> items, Function(String?) onChanged, {List<String>? displayNames}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLabel(label),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          initialValue: items.contains(value) ? value : null,
          items: items.asMap().entries.map((entry) {
            return DropdownMenuItem(
              value: entry.value,
              child: Text(displayNames != null ? displayNames[entry.key] : entry.value.toUpperCase(), style: GoogleFonts.outfit(fontSize: 13, fontWeight: FontWeight.w600)),
            );
          }).toList(),
          onChanged: onChanged,
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.grey.shade50,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(4), borderSide: BorderSide(color: Colors.grey.shade100)),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(4), borderSide: BorderSide(color: Colors.grey.shade100)),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
        ),
      ],
    );
  }

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: GoogleFonts.outfit(fontSize: 10, fontWeight: FontWeight.w800, letterSpacing: 1, color: Colors.grey.shade400),
    );
  }
}
