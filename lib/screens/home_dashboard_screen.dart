import 'package:flutter/material.dart';
import '../models/waste_request.dart';
import '../services/request_repository.dart';
import '../theme/app_theme.dart';
import '../widgets/device_thumbnail.dart';
import '../widgets/status_badge.dart';

class HomeDashboardScreen extends StatefulWidget {
  final Function(int tabIndex, {DeviceCategory? category}) onNavigate;
  final Function(WasteRequest request) onOpenDetails;

  const HomeDashboardScreen({
    super.key,
    required this.onNavigate,
    required this.onOpenDetails,
  });

  @override
  State<HomeDashboardScreen> createState() => _HomeDashboardScreenState();
}

class _HomeDashboardScreenState extends State<HomeDashboardScreen> {
  final RequestRepository _repo = RequestRepository();
  int _tipIndex = 0;

  static const List<Map<String, String>> _ecoTips = [
    {
      'title': 'Did You Know?',
      'tip': 'Recycling 1 million laptops saves the energy equivalent to the electricity used by over 3,500 homes in a year.',
      'icon': 'bolt',
    },
    {
      'title': 'Precious Resources',
      'tip': 'One metric ton of circuit boards contains 40 to 800 times more gold than one metric ton of mined gold ore.',
      'icon': 'diamond',
    },
    {
      'title': 'Prevent Toxic Leaks',
      'tip': 'E-waste represents only 2% of Americas trash in landfills, but it equals 70% of overall toxic waste.',
      'icon': 'shield',
    },
    {
      'title': 'Before You Hand Over',
      'tip': 'Remember to back up your personal files, remove SIM and memory cards, and perform a factory reset.',
      'icon': 'lock',
    },
  ];

  @override
  void initState() {
    super.initState();
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

  void _cycleTip() {
    setState(() {
      _tipIndex = (_tipIndex + 1) % _ecoTips.length;
    });
  }

  @override
  Widget build(BuildContext context) {
    final recentRequests = _repo.requests.take(3).toList();

    return LayoutBuilder(
      builder: (context, constraints) {
        final isDesktop = constraints.maxWidth >= 900;
        final isTablet = constraints.maxWidth >= 600 && constraints.maxWidth < 900;
        final horizontalPadding = isDesktop ? 36.0 : (isTablet ? 24.0 : 16.0);

        return Scaffold(
          body: CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              // Header / App Bar
              SliverAppBar(
                floating: true,
                pinned: true,
                backgroundColor: const Color(0xFFF7FBF8).withValues(alpha: 0.95),
                title: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryGreen.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.recycling_rounded,
                        color: AppTheme.primaryGreen,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'EcoCollect',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                            color: AppTheme.primaryGreen,
                            letterSpacing: -0.5,
                          ),
                        ),
                        Text(
                          'E-Waste Collection Platform',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                actions: [
                  IconButton(
                    tooltip: 'Notification / Platform Status',
                    icon: Badge(
                      label: Text('${_repo.requests.length}'),
                      backgroundColor: AppTheme.accentGreen,
                      child: const Icon(Icons.notifications_none_rounded),
                    ),
                    onPressed: () => widget.onNavigate(2),
                  ),
                  const SizedBox(width: 8),
                ],
              ),

              // Content Body
              SliverPadding(
                padding: EdgeInsets.symmetric(horizontal: horizontalPadding, vertical: 12),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    // Hero Banner
                    _buildHeroBanner(context, isDesktop),
                    const SizedBox(height: 24),

                    // Statistics Cards
                    _buildStatisticsSection(isDesktop, isTablet),
                    const SizedBox(height: 28),

                    // What Can You Recycle Section
                    _buildCategorySection(isDesktop, isTablet),
                    const SizedBox(height: 28),

                    // Awareness Tip Card
                    _buildAwarenessTipCard(),
                    const SizedBox(height: 28),

                    // Recent Requests Section
                    _buildRecentRequestsSection(recentRequests),
                    const SizedBox(height: 40),
                  ]),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHeroBanner(BuildContext context, bool isDesktop) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFF1B5E20),
            Color(0xFF2E7D32),
            Color(0xFF388E3C),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryGreen.withValues(alpha: 0.25),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            right: -20,
            bottom: -30,
            child: Icon(
              Icons.energy_savings_leaf_rounded,
              size: 220,
              color: Colors.white.withValues(alpha: 0.08),
            ),
          ),
          Padding(
            padding: EdgeInsets.all(isDesktop ? 32 : 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.18),
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.eco_rounded, color: Colors.lightGreenAccent, size: 16),
                      SizedBox(width: 6),
                      Text(
                        'Responsible Electronics Disposal',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
                const Text(
                  'Give Your Old Electronics\na New Purpose!',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 26,
                    height: 1.25,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  'Dispose of laptops, phones, cables & appliances safely. We schedule free doorstep pickup and ensure zero landfill waste.',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.88),
                    fontSize: 14,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 20),
                Wrap(
                  spacing: 12,
                  runSpacing: 10,
                  children: [
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: AppTheme.primaryGreen,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                      onPressed: () => widget.onNavigate(1),
                      icon: const Icon(Icons.calendar_month_rounded, size: 18),
                      label: const Text(
                        'Schedule a Pickup',
                        style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
                      ),
                    ),
                    OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.white,
                        side: const BorderSide(color: Colors.white70, width: 1.5),
                        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                      onPressed: () => widget.onNavigate(2),
                      icon: const Icon(Icons.track_changes_rounded, size: 18),
                      label: const Text(
                        'Track My Pickups',
                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatisticsSection(bool isDesktop, bool isTablet) {
    final stats = [
      _StatItem(
        title: 'Total Items Submitted',
        value: '${_repo.totalItemsSubmitted}',
        subtitle: 'Diverted from waste stream',
        icon: Icons.inventory_rounded,
        color: const Color(0xFF1B5E20),
      ),
      _StatItem(
        title: 'Pending Pickups',
        value: '${_repo.pendingPickupsCount}',
        subtitle: 'Scheduled or queued',
        icon: Icons.access_time_filled_rounded,
        color: const Color(0xFFF57C00),
      ),
      _StatItem(
        title: 'Collected Items',
        value: '${_repo.collectedItemsCount}',
        subtitle: 'Processed & recycled',
        icon: Icons.check_circle_rounded,
        color: const Color(0xFF00796B),
      ),
    ];

    if (isDesktop || isTablet) {
      return Row(
        children: stats
            .map((stat) => Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 6),
                    child: _buildStatCard(stat),
                  ),
                ))
            .toList(),
      );
    }

    return Column(
      children: stats.map((stat) => Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: _buildStatCard(stat),
      )).toList(),
    );
  }

  Widget _buildStatCard(_StatItem stat) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: stat.color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(stat.icon, color: stat.color, size: 28),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    stat.value,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                      color: stat.color,
                      letterSpacing: -0.5,
                    ),
                  ),
                  Text(
                    stat.title,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF1E2D22),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    stat.subtitle,
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.grey.shade600,
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

  Widget _buildCategorySection(bool isDesktop, bool isTablet) {
    final categories = DeviceCategory.values;
    final int crossAxisCount = isDesktop ? 4 : (isTablet ? 3 : 2);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'What Can You Recycle?',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF1B3820),
                    letterSpacing: -0.3,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  'Tap any category to start a collection request',
                  style: TextStyle(fontSize: 13, color: Colors.black54),
                ),
              ],
            ),
            TextButton.icon(
              onPressed: () => widget.onNavigate(1),
              icon: const Icon(Icons.arrow_forward_rounded, size: 16),
              label: const Text('Add Request'),
            ),
          ],
        ),
        const SizedBox(height: 14),
        GridView.builder(
          physics: const NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          itemCount: categories.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: isDesktop ? 1.4 : 1.25,
          ),
          itemBuilder: (context, index) {
            final cat = categories[index];
            return _buildCategoryCard(cat);
          },
        ),
      ],
    );
  }

  Widget _buildCategoryCard(DeviceCategory cat) {
    return Card(
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: AppTheme.accentGreen.withValues(alpha: 0.12)),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {
          widget.onNavigate(1, category: cat);
        },
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppTheme.lightGreen,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(cat.icon, color: AppTheme.primaryGreen, size: 24),
                  ),
                  Icon(
                    Icons.add_circle_outline_rounded,
                    color: Colors.grey.shade400,
                    size: 20,
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    cat.label,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF1E2D22),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    cat.ecoTip,
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.grey.shade600,
                      height: 1.2,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAwarenessTipCard() {
    final tip = _ecoTips[_tipIndex];
    return Card(
      color: const Color(0xFFF1F8F3),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: BorderSide(color: AppTheme.accentGreen.withValues(alpha: 0.2)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: const BoxDecoration(
                color: AppTheme.accentGreen,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.lightbulb_rounded,
                color: Colors.white,
                size: 22,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Recycling Awareness • ${tip['title']}',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.primaryGreen,
                        ),
                      ),
                      InkWell(
                        onTap: _cycleTip,
                        borderRadius: BorderRadius.circular(12),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          child: Row(
                            children: [
                              Text(
                                'Next Tip (${_tipIndex + 1}/${_ecoTips.length})',
                                style: const TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: AppTheme.accentGreen,
                                ),
                              ),
                              const SizedBox(width: 4),
                              const Icon(Icons.arrow_forward_ios_rounded, size: 10, color: AppTheme.accentGreen),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    tip['tip']!,
                    style: const TextStyle(
                      fontSize: 13,
                      height: 1.35,
                      color: Color(0xFF2E3D31),
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

  Widget _buildRecentRequestsSection(List<WasteRequest> recentRequests) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Recent Collection Requests',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: Color(0xFF1B3820),
                letterSpacing: -0.3,
              ),
            ),
            TextButton(
              onPressed: () => widget.onNavigate(2),
              child: const Text('View All'),
            ),
          ],
        ),
        const SizedBox(height: 10),
        if (recentRequests.isEmpty)
          Card(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Center(
                child: Column(
                  children: [
                    Icon(Icons.inbox_rounded, size: 48, color: Colors.grey.shade400),
                    const SizedBox(height: 8),
                    const Text(
                      'No requests yet',
                      style: TextStyle(fontWeight: FontWeight.w600, color: Colors.grey),
                    ),
                    const SizedBox(height: 12),
                    ElevatedButton(
                      onPressed: () => widget.onNavigate(1),
                      child: const Text('Create First Pickup Request'),
                    ),
                  ],
                ),
              ),
            ),
          )
        else
          Column(
            children: recentRequests.map((req) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Card(
                  child: InkWell(
                    borderRadius: BorderRadius.circular(16),
                    onTap: () => widget.onOpenDetails(req),
                    child: Padding(
                      padding: const EdgeInsets.all(14),
                      child: Row(
                        children: [
                          DeviceThumbnail(
                            imageBase64: req.imageBase64,
                            category: req.category,
                            size: 56,
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Text(
                                      req.id,
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.grey.shade700,
                                      ),
                                    ),
                                    const Spacer(),
                                    StatusBadge(status: req.status, isSimulated: req.isSimulated, compact: true),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  req.deviceName,
                                  style: const TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w700,
                                    color: Color(0xFF1E2D22),
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    Text(
                                      '${req.quantity} item${req.quantity > 1 ? 's' : ''} • ${req.condition.label}',
                                      style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                                    ),
                                    const Spacer(),
                                    Icon(Icons.calendar_today_outlined, size: 12, color: Colors.grey.shade500),
                                    const SizedBox(width: 4),
                                    Text(
                                      '${req.pickupDate.day}/${req.pickupDate.month}/${req.pickupDate.year}',
                                      style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          Icon(Icons.chevron_right_rounded, color: Colors.grey.shade400),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
      ],
    );
  }
}

class _StatItem {
  final String title;
  final String value;
  final String subtitle;
  final IconData icon;
  final Color color;

  _StatItem({
    required this.title,
    required this.value,
    required this.subtitle,
    required this.icon,
    required this.color,
  });
}
