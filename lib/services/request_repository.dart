import 'dart:convert';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/waste_request.dart';

class RequestRepository extends ChangeNotifier {
  static final RequestRepository _instance = RequestRepository._internal();
  factory RequestRepository() => _instance;
  RequestRepository._internal();

  static const String _storageKey = 'ecocollect_requests_v1';
  List<WasteRequest> _requests = [];
  bool _isInitialized = false;

  List<WasteRequest> get requests => List.unmodifiable(_requests);
  bool get isInitialized => _isInitialized;

  // Real-time statistics
  int get totalItemsSubmitted => _requests.fold(0, (sum, item) => sum + item.quantity);
  int get pendingPickupsCount => _requests.where((r) => r.status == RequestStatus.pending || r.status == RequestStatus.scheduled).length;
  int get collectedItemsCount => _requests.where((r) => r.status == RequestStatus.collected || r.status == RequestStatus.recycled).fold(0, (sum, item) => sum + item.quantity);
  int get recycledItemsCount => _requests.where((r) => r.status == RequestStatus.recycled).fold(0, (sum, item) => sum + item.quantity);

  // Environmental impact estimations (approximate e-waste metrics)
  double get totalWeightDivertedKg => _requests.where((r) => r.status == RequestStatus.collected || r.status == RequestStatus.recycled).fold(0.0, (sum, r) {
    switch (r.category) {
      case DeviceCategory.mobilePhones:
        return sum + (0.2 * r.quantity);
      case DeviceCategory.laptopsComputers:
        return sum + (2.5 * r.quantity);
      case DeviceCategory.batteries:
        return sum + (0.4 * r.quantity);
      case DeviceCategory.chargersCables:
        return sum + (0.15 * r.quantity);
      case DeviceCategory.televisions:
        return sum + (11.0 * r.quantity);
      case DeviceCategory.keyboardsAccessories:
        return sum + (0.8 * r.quantity);
      case DeviceCategory.otherElectronics:
        return sum + (1.5 * r.quantity);
    }
  });

  double get co2SavedKg => totalWeightDivertedKg * 1.8; // ~1.8kg CO2 saved per kg recycled e-waste

  Future<void> initialize() async {
    if (_isInitialized) return;
    final prefs = await SharedPreferences.getInstance();
    final jsonStr = prefs.getString(_storageKey);

    if (jsonStr != null && jsonStr.isNotEmpty) {
      try {
        final List<dynamic> decoded = jsonDecode(jsonStr);
        _requests = decoded.map((item) => WasteRequest.fromJson(item as Map<String, dynamic>)).toList();
      } catch (e) {
        debugPrint('Error loading saved requests: $e. Re-seeding samples.');
        _requests = _getInitialSampleRequests();
        await _persist();
      }
    } else {
      _requests = _getInitialSampleRequests();
      await _persist();
    }
    _isInitialized = true;
    notifyListeners();
  }

  Future<void> _persist() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = _requests.map((r) => r.toJson()).toList();
    await prefs.setString(_storageKey, jsonEncode(jsonList));
    notifyListeners();
  }

  Future<void> addRequest(WasteRequest request) async {
    _requests.insert(0, request);
    await _persist();
  }

  Future<void> updateRequestStatus(String id, RequestStatus newStatus) async {
    final index = _requests.indexWhere((r) => r.id == id);
    if (index != -1) {
      _requests[index] = _requests[index].copyWith(status: newStatus);
      await _persist();
    }
  }

  Future<void> deleteRequest(String id) async {
    _requests.removeWhere((r) => r.id == id);
    await _persist();
  }

  Future<void> resetToSampleData() async {
    _requests = _getInitialSampleRequests();
    await _persist();
  }

  Future<void> clearAll() async {
    _requests.clear();
    await _persist();
  }

  String generateUniqueRequestId() {
    final year = DateTime.now().year;
    final randomDigits = 1000 + Random().nextInt(9000);
    final id = 'ECO-$year-$randomDigits';
    // Ensure uniqueness
    if (_requests.any((r) => r.id == id)) {
      return generateUniqueRequestId();
    }
    return id;
  }

  List<WasteRequest> _getInitialSampleRequests() {
    final now = DateTime.now();
    return [
      WasteRequest(
        id: 'ECO-${now.year}-1042',
        category: DeviceCategory.mobilePhones,
        deviceName: 'iPhone 11 (64GB Black)',
        quantity: 1,
        condition: DeviceCondition.damaged,
        description: 'Cracked front glass and degraded battery. Still boots into recovery mode. Charger included.',
        customerName: 'Alex Morgan',
        contactNumber: '+1 (555) 234-5678',
        address: '742 Evergreen Terrace, Apt 4B',
        city: 'Springfield',
        pinCode: '97477',
        pickupDate: now.add(const Duration(days: 2)),
        timeSlot: TimeSlot.morning,
        status: RequestStatus.pending,
        isSimulated: true,
        createdAt: now.subtract(const Duration(hours: 4)),
      ),
      WasteRequest(
        id: 'ECO-${now.year}-1028',
        category: DeviceCategory.laptopsComputers,
        deviceName: 'Dell Inspiron 15 (5000 Series)',
        quantity: 1,
        condition: DeviceCondition.notWorking,
        description: 'Motherboard power failure after lightning surge. RAM and SSD already wiped and removed.',
        customerName: 'Priya Sharma',
        contactNumber: '+1 (555) 876-5432',
        address: '128 Silicon Grove Avenue',
        city: 'Metropolis',
        pinCode: '94016',
        pickupDate: now.add(const Duration(days: 1)),
        timeSlot: TimeSlot.afternoon,
        status: RequestStatus.scheduled,
        isSimulated: true,
        createdAt: now.subtract(const Duration(days: 1)),
      ),
      WasteRequest(
        id: 'ECO-${now.year}-0985',
        category: DeviceCategory.televisions,
        deviceName: 'Samsung 43" Smart LED TV',
        quantity: 1,
        condition: DeviceCondition.damaged,
        description: 'Vertical color lines across panel. Remote controller and desktop stand included in original packaging.',
        customerName: 'Carlos Rivera',
        contactNumber: '+1 (555) 345-9876',
        address: '512 Oakwood Boulevard',
        city: 'Riverdale',
        pinCode: '07666',
        pickupDate: now.subtract(const Duration(days: 1)),
        timeSlot: TimeSlot.evening,
        status: RequestStatus.collected,
        isSimulated: true,
        createdAt: now.subtract(const Duration(days: 3)),
      ),
      WasteRequest(
        id: 'ECO-${now.year}-0941',
        category: DeviceCategory.batteries,
        deviceName: 'Laptop Li-Ion Batteries & Power Banks',
        quantity: 4,
        condition: DeviceCondition.notWorking,
        description: 'Old swollen lithium batteries and 2 dead power banks stored in a fireproof safety pouch.',
        customerName: 'Elena Rostova',
        contactNumber: '+1 (555) 654-3210',
        address: '89 North Cascade Way',
        city: 'Portland',
        pinCode: '97201',
        pickupDate: now.subtract(const Duration(days: 5)),
        timeSlot: TimeSlot.morning,
        status: RequestStatus.recycled,
        isSimulated: true,
        createdAt: now.subtract(const Duration(days: 7)),
      ),
      WasteRequest(
        id: 'ECO-${now.year}-0919',
        category: DeviceCategory.chargersCables,
        deviceName: 'Surplus Cables & Adapters (Bundle)',
        quantity: 12,
        condition: DeviceCondition.working,
        description: 'Office cleanup bundle: micro-USB cords, HDMI cables, DisplayPort cables, and power bricks.',
        customerName: 'David Chen',
        contactNumber: '+1 (555) 901-2345',
        address: '300 Tech Park, Suite 102',
        city: 'Austin',
        pinCode: '78701',
        pickupDate: now.subtract(const Duration(days: 8)),
        timeSlot: TimeSlot.afternoon,
        status: RequestStatus.recycled,
        isSimulated: true,
        createdAt: now.subtract(const Duration(days: 10)),
      ),
    ];
  }
}
