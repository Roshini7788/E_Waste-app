import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ecocollect/models/waste_request.dart';
import 'package:ecocollect/services/request_repository.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('WasteRequest Model Tests', () {
    test('toJson and fromJson preserves all fields accurately', () {
      final now = DateTime.now();
      final request = WasteRequest(
        id: 'ECO-2026-9999',
        category: DeviceCategory.laptopsComputers,
        deviceName: 'ThinkPad T480',
        quantity: 2,
        condition: DeviceCondition.damaged,
        description: 'Broken hinges and battery error',
        imageBase64: 'dGVzdA==',
        customerName: 'Alice Green',
        contactNumber: '+1 555 123 4567',
        address: '100 Green St',
        city: 'Metropolis',
        pinCode: '10001',
        pickupDate: now.add(const Duration(days: 3)),
        timeSlot: TimeSlot.afternoon,
        status: RequestStatus.pending,
        isSimulated: false,
        createdAt: now,
      );

      final json = request.toJson();
      final revived = WasteRequest.fromJson(json);

      expect(revived.id, equals('ECO-2026-9999'));
      expect(revived.category, equals(DeviceCategory.laptopsComputers));
      expect(revived.deviceName, equals('ThinkPad T480'));
      expect(revived.quantity, equals(2));
      expect(revived.condition, equals(DeviceCondition.damaged));
      expect(revived.imageBase64, equals('dGVzdA=='));
      expect(revived.customerName, equals('Alice Green'));
      expect(revived.timeSlot, equals(TimeSlot.afternoon));
      expect(revived.status, equals(RequestStatus.pending));
      expect(revived.isSimulated, isFalse);
    });

    test('RequestStatus next() transitions correctly', () {
      expect(RequestStatus.pending.next(), equals(RequestStatus.scheduled));
      expect(RequestStatus.scheduled.next(), equals(RequestStatus.collected));
      expect(RequestStatus.collected.next(), equals(RequestStatus.recycled));
      expect(RequestStatus.recycled.next(), isNull);
    });

    test('DeviceCategory enums have proper labels and icons', () {
      expect(DeviceCategory.values.length, equals(7));
      expect(DeviceCategory.mobilePhones.label, equals('Mobile Phones'));
      expect(DeviceCategory.batteries.label, equals('Batteries'));
      expect(DeviceCategory.televisions.label, equals('Televisions'));
    });
  });

  group('RequestRepository Tests', () {
    setUp(() {
      SharedPreferences.setMockInitialValues({});
    });

    test('Initializes with default simulated samples when storage is empty', () async {
      final repo = RequestRepository();
      await repo.initialize();

      expect(repo.requests.isNotEmpty, isTrue);
      expect(repo.requests.any((r) => r.isSimulated), isTrue);
      expect(repo.totalItemsSubmitted, greaterThan(0));
    });

    test('Generates unique request ID formatted with prefix and year', () {
      final repo = RequestRepository();
      final id = repo.generateUniqueRequestId();
      expect(id.startsWith('ECO-${DateTime.now().year}-'), isTrue);
    });

    test('Adds new request and updates counts correctly', () async {
      final repo = RequestRepository();
      await repo.initialize();

      final initialTotal = repo.totalItemsSubmitted;
      final newReq = WasteRequest(
        id: repo.generateUniqueRequestId(),
        category: DeviceCategory.batteries,
        deviceName: 'Test Battery Pack',
        quantity: 5,
        condition: DeviceCondition.notWorking,
        description: 'Test note',
        customerName: 'Tester',
        contactNumber: '1234567890',
        address: '123 Test Rd',
        city: 'Test City',
        pinCode: '00000',
        pickupDate: DateTime.now(),
        timeSlot: TimeSlot.morning,
        status: RequestStatus.pending,
        createdAt: DateTime.now(),
      );

      await repo.addRequest(newReq);
      expect(repo.totalItemsSubmitted, equals(initialTotal + 5));
      expect(repo.requests.first.deviceName, equals('Test Battery Pack'));

      // Test status progression
      await repo.updateRequestStatus(newReq.id, RequestStatus.scheduled);
      expect(repo.requests.first.status, equals(RequestStatus.scheduled));

      // Test deletion
      await repo.deleteRequest(newReq.id);
      expect(repo.requests.any((r) => r.id == newReq.id), isFalse);
    });
  });
}
