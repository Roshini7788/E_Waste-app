import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/waste_request.dart';
import '../services/request_repository.dart';
import '../theme/app_theme.dart';
import '../widgets/device_thumbnail.dart';
import '../widgets/status_badge.dart';

class MyRequestsScreen extends StatefulWidget {
  final Function(WasteRequest request) onOpenDetails;
  final Function(int tabIndex) onNavigateToTab;

  const MyRequestsScreen({
    super.key,
    required this.onOpenDetails,
    required this.onNavigateToTab,
  });

  @override
  State<MyRequestsScreen> createState() => _MyRequestsScreenState();
}

class _MyRequestsScreenState extends State<MyRequestsScreen> {
  final RequestRepository _repo = RequestRepository();
  final TextEditingController _searchController = TextEditingController();
  RequestStatus? _statusFilter;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _repo.addListener(_onRepoChanged);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _repo.removeListener(_onRepoChanged);
    super.dispose();
  }

  void _onRepoChanged() {
    if (mounted) setState(() {});
  }

  List<WasteRequest> _getFilteredRequests() {
    return _repo.requests.where((r) {
      if (_statusFilter != null && r.status != _statusFilter) {
        return false;
      }
      if (_searchQuery.isNotEmpty) {
        final query = _searchQuery.toLowerCase();
        final matchName = r.deviceName.toLowerCase().contains(query);
        final matchId = r.id.toLowerCase().contains(query);
        final matchCat = r.category.label.toLowerCase().contains(query);
        final matchCity = r.city.toLowerCase().contains(query);
        if (!matchName && !matchId && !matchCat && !matchCity) return false;
      }
      return true;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _getFilteredRequests();

    return LayoutBuilder(
      builder: (context, constraints) {
        final isDesktop = constraints.maxWidth >= 900;
        final isTablet = constraints.maxWidth >= 600 && constraints.maxWidth < 900;
        final horizontalPadding = isDesktop ? 36.0 : (isTablet ? 24.0 : 16.0);

        return Scaffold(
          appBar: AppBar(
            title: const Text('My Collection Requests'),
            actions: [
              IconButton(
                tooltip: 'Add New Request',
                icon: const Icon(Icons.add_circle_outline_rounded),
                onPressed: () => widget.onNavigateToTab(1),
              ),
              const SizedBox(width: 8),
            ],
          ),
          body: CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              SliverPadding(
                padding: EdgeInsets.symmetric(horizontal: horizontalPadding, vertical: 12),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    // Search Bar
                    TextField(
                      controller: _searchController,
                      decoration: InputDecoration(
                        hintText: 'Search by device name, request ID, category, or city...',
                        prefixIcon: const Icon(Icons.search_rounded),
                        suffixIcon: _searchQuery.isNotEmpty
                            ? IconButton(
                                icon: const Icon(Icons.clear_rounded, size: 18),
                                onPressed: () {
                                  _searchController.clear();
                                  setState(() => _searchQuery = '');
                                },
                              )
                            : null,
                      ),
                      onChanged: (val) {
                        setState(() => _searchQuery = val.trim());
                      },
                    ),
                    const SizedBox(height: 14),

                    // Filter Status Chips
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          _buildFilterChip('All (${_repo.requests.length})', null),
                          ...RequestStatus.values.map((status) {
                            final count = _repo.requests.where((r) => r.status == status).length;
                            return _buildFilterChip('${status.label} ($count)', status);
                          }),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Simulated Data Banner Alert
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      decoration: BoxDecoration(
                        color: Colors.blueGrey.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.blueGrey.withValues(alpha: 0.2)),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.info_outline_rounded, size: 18, color: Colors.blueGrey.shade700),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              'Sample demonstration requests are labeled "Demo Data". Tap any request to view its complete progress timeline.',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.blueGrey.shade800,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                  ]),
                ),
              ),

              // Request Cards List
              if (filtered.isEmpty)
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.all(32),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.filter_list_off_rounded, size: 54, color: Colors.grey.shade400),
                          const SizedBox(height: 14),
                          const Text(
                            'No collection requests match your filters',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Try resetting filters or search query',
                            style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton.icon(
                            onPressed: () {
                              _searchController.clear();
                              setState(() {
                                _searchQuery = '';
                                _statusFilter = null;
                              });
                            },
                            icon: const Icon(Icons.refresh_rounded, size: 18),
                            label: const Text('Reset Filters'),
                          ),
                        ],
                      ),
                    ),
                  ),
                )
              else
                SliverPadding(
                  padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final req = filtered[index];
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: _buildRequestCard(req),
                        );
                      },
                      childCount: filtered.length,
                    ),
                  ),
                ),
              const SliverToBoxAdapter(
                child: SizedBox(height: 40),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildFilterChip(String label, RequestStatus? status) {
    final isSelected = _statusFilter == status;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (selected) {
          setState(() {
            _statusFilter = selected ? status : null;
          });
        },
        backgroundColor: Colors.white,
        selectedColor: AppTheme.primaryGreen.withValues(alpha: 0.15),
        labelStyle: TextStyle(
          color: isSelected ? AppTheme.primaryGreen : Colors.black87,
          fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
          fontSize: 12.5,
        ),
        side: BorderSide(
          color: isSelected ? AppTheme.primaryGreen : Colors.grey.shade300,
        ),
      ),
    );
  }

  Widget _buildRequestCard(WasteRequest req) {
    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => widget.onOpenDetails(req),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header row: ID, category chip, status badge
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: AppTheme.lightGreen,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      req.id,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                        color: AppTheme.primaryGreen,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    req.category.label,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey.shade700,
                    ),
                  ),
                  const Spacer(),
                  StatusBadge(status: req.status, isSimulated: req.isSimulated),
                ],
              ),
              const Divider(height: 18),

              // Content row: Device photo & specs
              Row(
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
                        Text(
                          req.deviceName,
                          style: const TextStyle(
                            fontSize: 16,
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
                              '${req.quantity} item${req.quantity > 1 ? 's' : ''}',
                              style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
                            ),
                            const Text(' • ', style: TextStyle(color: Colors.grey)),
                            Text(
                              req.condition.label,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: req.condition.color,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Bottom row: Pickup date & View details prompt
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: const Color(0xFFF7FBF8),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  children: [
                    Icon(Icons.calendar_month_outlined, size: 14, color: Colors.grey.shade600),
                    const SizedBox(width: 6),
                    Text(
                      'Pickup: ${DateFormat('EEE, MMM d, yyyy').format(req.pickupDate)} (${req.timeSlot.shortLabel})',
                      style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
                    ),
                    const Spacer(),
                    const Text(
                      'View Details',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.primaryGreen,
                      ),
                    ),
                    const SizedBox(width: 4),
                    const Icon(Icons.arrow_forward_ios_rounded, size: 11, color: AppTheme.primaryGreen),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
