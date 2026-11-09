import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/waste_request.dart';
import '../services/request_repository.dart';
import '../theme/app_theme.dart';
import '../widgets/progress_timeline.dart';
import '../widgets/status_badge.dart';

class RequestDetailsScreen extends StatefulWidget {
  final WasteRequest request;
  final VoidCallback? onBack;

  const RequestDetailsScreen({
    super.key,
    required this.request,
    this.onBack,
  });

  @override
  State<RequestDetailsScreen> createState() => _RequestDetailsScreenState();
}

class _RequestDetailsScreenState extends State<RequestDetailsScreen> {
  final RequestRepository _repo = RequestRepository();
  late WasteRequest _currentRequest;

  @override
  void initState() {
    super.initState();
    _currentRequest = widget.request;
    _repo.addListener(_syncWithRepo);
  }

  @override
  void dispose() {
    _repo.removeListener(_syncWithRepo);
    super.dispose();
  }

  void _syncWithRepo() {
    final updated = _repo.requests.firstWhere(
      (r) => r.id == _currentRequest.id,
      orElse: () => _currentRequest,
    );
    if (mounted && updated != _currentRequest) {
      setState(() => _currentRequest = updated);
    }
  }

  void _advanceStatus() async {
    final nextStatus = _currentRequest.status.next();
    if (nextStatus != null) {
      await _repo.updateRequestStatus(_currentRequest.id, nextStatus);
      setState(() {
        _currentRequest = _currentRequest.copyWith(status: nextStatus);
      });
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Status advanced to "${nextStatus.label}"'),
          backgroundColor: nextStatus.color,
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  void _confirmCancel() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Cancel Request?'),
        content: Text('Are you sure you want to cancel pickup request ${_currentRequest.id}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Keep Request'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
            onPressed: () async {
              Navigator.of(ctx).pop();
              await _repo.deleteRequest(_currentRequest.id);
              if (mounted) {
                if (widget.onBack != null) {
                  widget.onBack!();
                } else {
                  Navigator.of(context).pop();
                }
              }
            },
            child: const Text('Yes, Cancel Request'),
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
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_rounded),
              onPressed: () {
                if (widget.onBack != null) {
                  widget.onBack!();
                } else {
                  Navigator.of(context).pop();
                }
              },
            ),
            title: Text('Request ${_currentRequest.id}'),
            actions: [
              if (_currentRequest.isSimulated)
                const Padding(
                  padding: EdgeInsets.only(right: 16),
                  child: Center(
                    child: StatusBadge(
                      status: RequestStatus.pending,
                      isSimulated: true,
                      compact: true,
                    ),
                  ),
                ),
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
                    // Top Overview Card
                    _buildOverviewCard(),
                    const SizedBox(height: 20),

                    // Progress Timeline Card
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  'Collection Progress',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w800,
                                    color: Color(0xFF1B3820),
                                  ),
                                ),
                                StatusBadge(status: _currentRequest.status),
                              ],
                            ),
                            const SizedBox(height: 20),
                            ProgressTimeline(currentStatus: _currentRequest.status),
                            const SizedBox(height: 20),
                            _buildSimulationControlBar(),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Two columns on desktop / tablet, single column on phone
                    if (isDesktop || isTablet)
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(child: _buildDeviceDetailsCard()),
                          const SizedBox(width: 16),
                          Expanded(child: _buildPickupDetailsCard()),
                        ],
                      )
                    else ...[
                      _buildDeviceDetailsCard(),
                      const SizedBox(height: 16),
                      _buildPickupDetailsCard(),
                    ],
                    const SizedBox(height: 24),

                    // Bottom Action Bar
                    _buildBottomActions(),
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

  Widget _buildOverviewCard() {
    return Card(
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Device Photograph
            _buildDevicePhotoWidget(88),
            const SizedBox(width: 18),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: AppTheme.lightGreen,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(_currentRequest.category.icon, size: 14, color: AppTheme.primaryGreen),
                            const SizedBox(width: 4),
                            Text(
                              _currentRequest.category.label,
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: AppTheme.primaryGreen,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Spacer(),
                      Text(
                        'Created ${DateFormat('MMM d, yyyy').format(_currentRequest.createdAt)}',
                        style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _currentRequest.deviceName,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF1B3820),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Wrap(
                    spacing: 12,
                    children: [
                      _buildMetaChip(Icons.numbers_rounded, '${_currentRequest.quantity} unit${_currentRequest.quantity > 1 ? 's' : ''}'),
                      _buildMetaChip(_currentRequest.condition.icon, _currentRequest.condition.label, color: _currentRequest.condition.color),
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

  Widget _buildDevicePhotoWidget(double size) {
    if (_currentRequest.imageBase64 != null && _currentRequest.imageBase64!.isNotEmpty) {
      try {
        final bytes = base64Decode(_currentRequest.imageBase64!);
        return ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Image.memory(
            bytes,
            width: size,
            height: size,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) => _buildFallbackPhoto(size),
          ),
        );
      } catch (_) {
        return _buildFallbackPhoto(size);
      }
    }
    return _buildFallbackPhoto(size);
  }

  Widget _buildFallbackPhoto(double size) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: AppTheme.lightGreen,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.accentGreen.withValues(alpha: 0.2)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(_currentRequest.category.icon, size: size * 0.4, color: AppTheme.primaryGreen),
          const SizedBox(height: 2),
          Text(
            'Photo N/A',
            style: TextStyle(fontSize: 9, fontWeight: FontWeight.w600, color: Colors.grey.shade600),
          ),
        ],
      ),
    );
  }

  Widget _buildMetaChip(IconData icon, String text, {Color? color}) {
    final chipColor = color ?? Colors.grey.shade700;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: chipColor),
        const SizedBox(width: 4),
        Text(
          text,
          style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: chipColor),
        ),
      ],
    );
  }

  Widget _buildSimulationControlBar() {
    final nextStatus = _currentRequest.status.next();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F6F2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.accentGreen.withValues(alpha: 0.15)),
      ),
      child: Row(
        children: [
          const Icon(Icons.touch_app_rounded, size: 18, color: AppTheme.accentGreen),
          const SizedBox(width: 8),
          const Expanded(
            child: Text(
              'Demo Simulator: Test lifecycle steps',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF1B3820)),
            ),
          ),
          if (nextStatus != null)
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: nextStatus.color,
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              onPressed: _advanceStatus,
              icon: const Icon(Icons.play_arrow_rounded, size: 16),
              label: Text(
                'Advance to ${nextStatus.label}',
                style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700),
              ),
            )
          else
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.green.shade100,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text(
                'Fully Recycled ✓',
                style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppTheme.primaryGreen),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildDeviceDetailsCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.devices_rounded, size: 18, color: AppTheme.primaryGreen),
                SizedBox(width: 8),
                Text(
                  'Device Specifications',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: Color(0xFF1B3820)),
                ),
              ],
            ),
            const Divider(height: 20),
            _buildDetailRow('Category', _currentRequest.category.label),
            _buildDetailRow('Device Name', _currentRequest.deviceName),
            _buildDetailRow('Quantity', '${_currentRequest.quantity} unit(s)'),
            _buildDetailRow('Condition', _currentRequest.condition.label, valueColor: _currentRequest.condition.color),
            const SizedBox(height: 8),
            const Text('Additional Description / Notes:', style: TextStyle(fontSize: 12, color: Colors.grey)),
            const SizedBox(height: 4),
            Text(
              _currentRequest.description.isNotEmpty
                  ? _currentRequest.description
                  : 'No additional notes provided by user.',
              style: const TextStyle(fontSize: 13, height: 1.35),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPickupDetailsCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.local_shipping_rounded, size: 18, color: AppTheme.primaryGreen),
                SizedBox(width: 8),
                Text(
                  'Pickup & Schedule',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: Color(0xFF1B3820)),
                ),
              ],
            ),
            const Divider(height: 20),
            _buildDetailRow('Customer Name', _currentRequest.customerName),
            _buildDetailRow('Contact Phone', _currentRequest.contactNumber),
            _buildDetailRow('Street Address', _currentRequest.address),
            _buildDetailRow('City & PIN Code', '${_currentRequest.city}, ${_currentRequest.pinCode}'),
            _buildDetailRow(
              'Scheduled Date',
              DateFormat('EEE, MMM d, yyyy').format(_currentRequest.pickupDate),
              valueColor: AppTheme.primaryGreen,
            ),
            _buildDetailRow('Time Window', _currentRequest.timeSlot.label),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, {Color? valueColor}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: valueColor ?? Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomActions() {
    return Row(
      children: [
        if (_currentRequest.status == RequestStatus.pending) ...[
          OutlinedButton.icon(
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.redAccent,
              side: const BorderSide(color: Colors.redAccent),
            ),
            onPressed: _confirmCancel,
            icon: const Icon(Icons.cancel_outlined, size: 18),
            label: const Text('Cancel Request'),
          ),
          const SizedBox(width: 12),
        ],
        Expanded(
          child: ElevatedButton.icon(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Collection summary for ${_currentRequest.id} printed/saved.'),
                  duration: const Duration(seconds: 2),
                ),
              );
            },
            icon: const Icon(Icons.share_outlined, size: 18),
            label: const Text('Share / Save Summary'),
          ),
        ),
      ],
    );
  }
}
