import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/waste_request.dart';
import '../services/request_repository.dart';
import '../theme/app_theme.dart';

class ProfileScreen extends StatefulWidget {
  final Function(int tabIndex) onNavigateToTab;

  const ProfileScreen({
    super.key,
    required this.onNavigateToTab,
  });

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final RequestRepository _repo = RequestRepository();

  String _userName = 'Alex Morgan';
  String _userEmail = 'alex.morgan@ecocollect.demo';
  String _userPhone = '+1 (555) 234-5678';
  String _userCity = 'Springfield';

  @override
  void initState() {
    super.initState();
    _loadProfilePrefs();
    _repo.addListener(_onRepoChanged);
  }

  @override
  void dispose() {
    _repo.removeListener(_onRepoChanged);
    super.dispose();
  }

  void _onRepoChanged() {
    if (mounted) setState(() {});
  }

  Future<void> _loadProfilePrefs() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _userName = prefs.getString('ecocollect_user_name') ?? 'Alex Morgan';
      _userEmail = prefs.getString('ecocollect_user_email') ?? 'alex.morgan@ecocollect.demo';
      _userPhone = prefs.getString('ecocollect_user_phone') ?? '+1 (555) 234-5678';
      _userCity = prefs.getString('ecocollect_user_city') ?? 'Springfield';
    });
  }

  Future<void> _saveProfilePrefs(String name, String email, String phone, String city) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('ecocollect_user_name', name);
    await prefs.setString('ecocollect_user_email', email);
    await prefs.setString('ecocollect_user_phone', phone);
    await prefs.setString('ecocollect_user_city', city);
    setState(() {
      _userName = name;
      _userEmail = email;
      _userPhone = phone;
      _userCity = city;
    });
  }

  void _showEditProfileDialog() {
    final nameCtrl = TextEditingController(text: _userName);
    final emailCtrl = TextEditingController(text: _userEmail);
    final phoneCtrl = TextEditingController(text: _userPhone);
    final cityCtrl = TextEditingController(text: _userCity);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Edit Demo Profile'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameCtrl,
                decoration: const InputDecoration(labelText: 'Full Name'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: emailCtrl,
                decoration: const InputDecoration(labelText: 'Email Address'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: phoneCtrl,
                decoration: const InputDecoration(labelText: 'Contact Phone'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: cityCtrl,
                decoration: const InputDecoration(labelText: 'City'),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              _saveProfilePrefs(
                nameCtrl.text.trim(),
                emailCtrl.text.trim(),
                phoneCtrl.text.trim(),
                cityCtrl.text.trim(),
              );
            },
            child: const Text('Save Changes'),
          ),
        ],
      ),
    );
  }

  void _confirmResetData() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Reset to Sample Data?'),
        content: const Text(
          'This will restore the original demonstration collection requests and clear any custom entries.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.of(ctx).pop();
              await _repo.resetToSampleData();
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Reset to default demonstration requests.')),
                );
              }
            },
            child: const Text('Reset Data'),
          ),
        ],
      ),
    );
  }

  void _confirmClearAllData() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Clear All Local Data?'),
        content: const Text(
          'This will remove all saved e-waste collection requests from local storage.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
            onPressed: () async {
              Navigator.of(ctx).pop();
              await _repo.clearAll();
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('All requests cleared.')),
                );
              }
            },
            child: const Text('Clear All'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isDesktop = constraints.maxWidth >= 900;
        final isTablet = constraints.maxWidth >= 600 && constraints.maxWidth < 900;
        final maxWidth = isDesktop ? 860.0 : double.infinity;

        return Scaffold(
          appBar: AppBar(
            title: const Text('User Profile & Impact'),
            actions: [
              IconButton(
                tooltip: 'Edit Profile Info',
                icon: const Icon(Icons.edit_outlined),
                onPressed: _showEditProfileDialog,
              ),
              const SizedBox(width: 8),
            ],
          ),
          body: Center(
            child: Container(
              constraints: BoxConstraints(maxWidth: maxWidth),
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: EdgeInsets.symmetric(
                  horizontal: isDesktop ? 32 : (isTablet ? 24 : 16),
                  vertical: 16,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Profile Header Card
                    _buildProfileHeaderCard(),
                    const SizedBox(height: 20),

                    // Metrics & Impact Cards
                    _buildMetricsSection(isDesktop, isTablet),
                    const SizedBox(height: 20),

                    // Environmental Impact Banner
                    _buildEnvironmentalImpactCard(),
                    const SizedBox(height: 20),

                    // About EcoCollect Section
                    _buildAboutEcoCollectCard(),
                    const SizedBox(height: 20),

                    // Demo / Storage Management Utilities
                    _buildDemoControlsCard(),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildProfileHeaderCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppTheme.primaryGreen, AppTheme.secondaryTeal],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Center(
                child: Text(
                  _userName.isNotEmpty ? _userName.split(' ').map((n) => n.isNotEmpty ? n[0] : '').take(2).join() : 'EC',
                  style: const TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 18),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        _userName,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF1B3820),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppTheme.lightGreen,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Text(
                          'Demo User',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: AppTheme.primaryGreen,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.email_outlined, size: 14, color: Colors.grey.shade600),
                      const SizedBox(width: 6),
                      Text(_userEmail, style: TextStyle(fontSize: 13, color: Colors.grey.shade700)),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.location_on_outlined, size: 14, color: Colors.grey.shade600),
                      const SizedBox(width: 6),
                      Text('$_userCity • $_userPhone', style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricsSection(bool isDesktop, bool isTablet) {
    final completedCollections = _repo.requests.where((r) => r.status == RequestStatus.collected || r.status == RequestStatus.recycled).length;

    final cards = [
      _buildStatTile(
        title: 'Total Items Submitted',
        value: '${_repo.totalItemsSubmitted}',
        unit: 'electronic devices',
        icon: Icons.inventory_2_rounded,
        color: AppTheme.primaryGreen,
      ),
      _buildStatTile(
        title: 'Completed Collections',
        value: '$completedCollections',
        unit: 'pickups fulfilled',
        icon: Icons.task_alt_rounded,
        color: AppTheme.secondaryTeal,
      ),
    ];

    if (isDesktop || isTablet) {
      return Row(
        children: cards.map((c) => Expanded(child: Padding(padding: const EdgeInsets.symmetric(horizontal: 6), child: c))).toList(),
      );
    }

    return Column(
      children: cards.map((c) => Padding(padding: const EdgeInsets.only(bottom: 12), child: c)).toList(),
    );
  }

  Widget _buildStatTile({
    required String title,
    required String value,
    required String unit,
    required IconData icon,
    required Color color,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(icon, color: color, size: 28),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    value,
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.w800,
                      color: color,
                      letterSpacing: -0.5,
                    ),
                  ),
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF1E2D22),
                    ),
                  ),
                  Text(
                    unit,
                    style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEnvironmentalImpactCard() {
    return Card(
      color: const Color(0xFFF1F8F3),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: BorderSide(color: AppTheme.accentGreen.withValues(alpha: 0.2)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.eco_rounded, color: AppTheme.primaryGreen, size: 22),
                SizedBox(width: 8),
                Text(
                  'Your Environmental Footprint Saved',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: AppTheme.primaryGreen,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: _buildImpactMetric(
                    '${_repo.totalWeightDivertedKg.toStringAsFixed(1)} kg',
                    'E-Waste Diverted',
                    Icons.scale_rounded,
                  ),
                ),
                Expanded(
                  child: _buildImpactMetric(
                    '${_repo.co2SavedKg.toStringAsFixed(1)} kg',
                    'CO2 Emissions Prevented',
                    Icons.cloud_done_outlined,
                  ),
                ),
                Expanded(
                  child: _buildImpactMetric(
                    (_repo.co2SavedKg / 21).toStringAsFixed(1),
                    'Trees Equivalent / Year',
                    Icons.park_rounded,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImpactMetric(String value, String label, IconData icon) {
    return Column(
      children: [
        Icon(icon, size: 24, color: AppTheme.accentGreen),
        const SizedBox(height: 6),
        Text(
          value,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: Color(0xFF1B3820),
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 11, color: Colors.grey.shade700),
        ),
      ],
    );
  }

  Widget _buildAboutEcoCollectCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.info_outline_rounded, size: 20, color: AppTheme.primaryGreen),
                SizedBox(width: 8),
                Text(
                  'About EcoCollect',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF1B3820),
                  ),
                ),
              ],
            ),
            const Divider(height: 20),
            const Text(
              'EcoCollect is an eco-friendly platform built to bridge consumers with certified electronic recycling facilities. We divert retired gadgets, household electronics, cables, and batteries away from harmful landfills.',
              style: TextStyle(fontSize: 13, height: 1.45, color: Color(0xFF2E3D31)),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.amber.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.amber.withValues(alpha: 0.3)),
              ),
              child: const Row(
                children: [
                  Icon(Icons.shield_outlined, color: Colors.amber, size: 20),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Functional Prototype Note: This application is a frontend demonstration prototype. Requests are stored locally on your device via shared_preferences. No real collection vehicles are dispatched.',
                      style: TextStyle(fontSize: 11.5, color: Color(0xFF5D4037)),
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

  Widget _buildDemoControlsCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.tune_rounded, size: 20, color: AppTheme.primaryGreen),
                SizedBox(width: 8),
                Text(
                  'Testing & Data Utilities',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF1B3820),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Manage locally stored requests for evaluation purposes:',
              style: TextStyle(fontSize: 12.5, color: Colors.grey.shade600),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 12,
              runSpacing: 10,
              children: [
                OutlinedButton.icon(
                  onPressed: _confirmResetData,
                  icon: const Icon(Icons.restore_rounded, size: 18),
                  label: const Text('Reset to Sample Demo Data'),
                ),
                OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.redAccent,
                    side: const BorderSide(color: Colors.redAccent),
                  ),
                  onPressed: _confirmClearAllData,
                  icon: const Icon(Icons.delete_sweep_rounded, size: 18),
                  label: const Text('Clear All Local Data'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
