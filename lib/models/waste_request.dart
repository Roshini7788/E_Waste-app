import 'package:flutter/material.dart';

enum DeviceCategory {
  mobilePhones('Mobile Phones', Icons.phone_android_rounded, 'Contains gold, copper, and rare earth metals that can be safely reclaimed.'),
  laptopsComputers('Laptops and Computers', Icons.laptop_mac_rounded, 'Recovers aluminum chassis, processor chips, and circuit components.'),
  batteries('Batteries', Icons.battery_charging_full_rounded, 'Prevents dangerous cadmium, mercury, and lithium leaching into soil.'),
  chargersCables('Chargers and Cables', Icons.cable_rounded, 'High-grade copper wiring can be recycled repeatedly with zero quality loss.'),
  televisions('Televisions', Icons.tv_rounded, 'Safely recovers flat panel filters, power supplies, and specialty glass.'),
  keyboardsAccessories('Keyboards and Accessories', Icons.keyboard_rounded, 'Recycles durable ABS plastics, microswitches, and USB connectors.'),
  otherElectronics('Other Electronics', Icons.devices_other_rounded, 'Household electronics with a cord or battery deserve sustainable disposal.');

  final String label;
  final IconData icon;
  final String ecoTip;

  const DeviceCategory(this.label, this.icon, this.ecoTip);

  static DeviceCategory fromString(String val) {
    return DeviceCategory.values.firstWhere(
      (e) => e.name == val || e.label == val,
      orElse: () => DeviceCategory.otherElectronics,
    );
  }
}

enum DeviceCondition {
  working('Working', 'Powers on and functions properly', Icons.check_circle_outline_rounded, Color(0xFF2E7D32)),
  damaged('Damaged', 'Cracked screen or cosmetic / partial faults', Icons.warning_amber_rounded, Color(0xFFED6C02)),
  notWorking('Not Working', 'Non-responsive, dead board, or broken', Icons.cancel_outlined, Color(0xFFD32F2F));

  final String label;
  final String description;
  final IconData icon;
  final Color color;

  const DeviceCondition(this.label, this.description, this.icon, this.color);

  static DeviceCondition fromString(String val) {
    return DeviceCondition.values.firstWhere(
      (e) => e.name == val || e.label == val,
      orElse: () => DeviceCondition.damaged,
    );
  }
}

enum TimeSlot {
  morning('Morning (9:00 AM - 12:00 PM)', 'Morning', Icons.wb_sunny_outlined),
  afternoon('Afternoon (12:00 PM - 4:00 PM)', 'Afternoon', Icons.wb_twilight_rounded),
  evening('Evening (4:00 PM - 8:00 PM)', 'Evening', Icons.nights_stay_outlined);

  final String label;
  final String shortLabel;
  final IconData icon;

  const TimeSlot(this.label, this.shortLabel, this.icon);

  static TimeSlot fromString(String val) {
    return TimeSlot.values.firstWhere(
      (e) => e.name == val || e.shortLabel == val || e.label == val,
      orElse: () => TimeSlot.morning,
    );
  }
}

enum RequestStatus {
  pending('Pending', Icons.hourglass_top_rounded, Color(0xFFF57C00), 0),
  scheduled('Pickup Scheduled', Icons.local_shipping_rounded, Color(0xFF1976D2), 1),
  collected('Collected', Icons.inventory_2_rounded, Color(0xFF00796B), 2),
  recycled('Recycled', Icons.eco_rounded, Color(0xFF2E7D32), 3);

  final String label;
  final IconData icon;
  final Color color;
  final int stepIndex;

  const RequestStatus(this.label, this.icon, this.color, this.stepIndex);

  static RequestStatus fromString(String val) {
    return RequestStatus.values.firstWhere(
      (e) => e.name == val || e.label == val,
      orElse: () => RequestStatus.pending,
    );
  }

  RequestStatus? next() {
    switch (this) {
      case RequestStatus.pending:
        return RequestStatus.scheduled;
      case RequestStatus.scheduled:
        return RequestStatus.collected;
      case RequestStatus.collected:
        return RequestStatus.recycled;
      case RequestStatus.recycled:
        return null;
    }
  }
}

class WasteRequest {
  final String id;
  final DeviceCategory category;
  final String deviceName;
  final int quantity;
  final DeviceCondition condition;
  final String description;
  final String? imageBase64;
  final String customerName;
  final String contactNumber;
  final String address;
  final String city;
  final String pinCode;
  final DateTime pickupDate;
  final TimeSlot timeSlot;
  final RequestStatus status;
  final bool isSimulated;
  final DateTime createdAt;

  const WasteRequest({
    required this.id,
    required this.category,
    required this.deviceName,
    required this.quantity,
    required this.condition,
    required this.description,
    this.imageBase64,
    required this.customerName,
    required this.contactNumber,
    required this.address,
    required this.city,
    required this.pinCode,
    required this.pickupDate,
    required this.timeSlot,
    this.status = RequestStatus.pending,
    this.isSimulated = false,
    required this.createdAt,
  });

  WasteRequest copyWith({
    String? id,
    DeviceCategory? category,
    String? deviceName,
    int? quantity,
    DeviceCondition? condition,
    String? description,
    String? imageBase64,
    String? customerName,
    String? contactNumber,
    String? address,
    String? city,
    String? pinCode,
    DateTime? pickupDate,
    TimeSlot? timeSlot,
    RequestStatus? status,
    bool? isSimulated,
    DateTime? createdAt,
  }) {
    return WasteRequest(
      id: id ?? this.id,
      category: category ?? this.category,
      deviceName: deviceName ?? this.deviceName,
      quantity: quantity ?? this.quantity,
      condition: condition ?? this.condition,
      description: description ?? this.description,
      imageBase64: imageBase64 ?? this.imageBase64,
      customerName: customerName ?? this.customerName,
      contactNumber: contactNumber ?? this.contactNumber,
      address: address ?? this.address,
      city: city ?? this.city,
      pinCode: pinCode ?? this.pinCode,
      pickupDate: pickupDate ?? this.pickupDate,
      timeSlot: timeSlot ?? this.timeSlot,
      status: status ?? this.status,
      isSimulated: isSimulated ?? this.isSimulated,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'category': category.name,
      'deviceName': deviceName,
      'quantity': quantity,
      'condition': condition.name,
      'description': description,
      'imageBase64': imageBase64,
      'customerName': customerName,
      'contactNumber': contactNumber,
      'address': address,
      'city': city,
      'pinCode': pinCode,
      'pickupDate': pickupDate.toIso8601String(),
      'timeSlot': timeSlot.name,
      'status': status.name,
      'isSimulated': isSimulated,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory WasteRequest.fromJson(Map<String, dynamic> json) {
    return WasteRequest(
      id: json['id'] as String,
      category: DeviceCategory.fromString(json['category'] as String),
      deviceName: json['deviceName'] as String,
      quantity: (json['quantity'] as num).toInt(),
      condition: DeviceCondition.fromString(json['condition'] as String),
      description: json['description'] as String? ?? '',
      imageBase64: json['imageBase64'] as String?,
      customerName: json['customerName'] as String,
      contactNumber: json['contactNumber'] as String,
      address: json['address'] as String,
      city: json['city'] as String,
      pinCode: json['pinCode'] as String,
      pickupDate: DateTime.parse(json['pickupDate'] as String),
      timeSlot: TimeSlot.fromString(json['timeSlot'] as String),
      status: RequestStatus.fromString(json['status'] as String),
      isSimulated: json['isSimulated'] as bool? ?? false,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : DateTime.now(),
    );
  }
}
