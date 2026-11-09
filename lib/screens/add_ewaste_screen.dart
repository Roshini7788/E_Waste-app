import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../models/waste_request.dart';
import '../theme/app_theme.dart';
import 'pickup_booking_screen.dart';

class AddEWasteScreen extends StatefulWidget {
  final DeviceCategory? initialCategory;
  final Function(WasteRequest request) onRequestCreated;
  final Function(int tabIndex) onNavigateToTab;

  const AddEWasteScreen({
    super.key,
    this.initialCategory,
    required this.onRequestCreated,
    required this.onNavigateToTab,
  });

  @override
  State<AddEWasteScreen> createState() => _AddEWasteScreenState();
}

class _AddEWasteScreenState extends State<AddEWasteScreen> {
  final _formKey = GlobalKey<FormState>();
  final ImagePicker _picker = ImagePicker();

  late DeviceCategory _category;
  final _deviceNameController = TextEditingController();
  final _descriptionController = TextEditingController();
  int _quantity = 1;
  DeviceCondition _condition = DeviceCondition.damaged;
  String? _imageBase64;
  bool _isPickingImage = false;

  // Step tracking: 1 = Add E-Waste details, 2 = Pickup Booking
  int _currentStep = 1;

  @override
  void initState() {
    super.initState();
    _category = widget.initialCategory ?? DeviceCategory.mobilePhones;
  }

  @override
  void didUpdateWidget(covariant AddEWasteScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialCategory != null && widget.initialCategory != oldWidget.initialCategory) {
      setState(() {
        _category = widget.initialCategory!;
        _currentStep = 1;
      });
    }
  }

  @override
  void dispose() {
    _deviceNameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    setState(() => _isPickingImage = true);
    try {
      final XFile? file = await _picker.pickImage(
        source: source,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 80,
      );

      if (file != null) {
        final bytes = await file.readAsBytes();
        setState(() {
          _imageBase64 = base64Encode(bytes);
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Could not access image picker: $e'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isPickingImage = false);
    }
  }

  void _showImageSourceSheet() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 12),
                  child: Text(
                    'Upload Device Photo',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: AppTheme.primaryGreen,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                ListTile(
                  leading: const CircleAvatar(
                    backgroundColor: AppTheme.lightGreen,
                    child: Icon(Icons.camera_alt_rounded, color: AppTheme.primaryGreen),
                  ),
                  title: const Text('Take a Photograph', style: TextStyle(fontWeight: FontWeight.w600)),
                  subtitle: const Text('Use your device camera to snap the electronic item'),
                  onTap: () {
                    Navigator.of(ctx).pop();
                    _pickImage(ImageSource.camera);
                  },
                ),
                ListTile(
                  leading: const CircleAvatar(
                    backgroundColor: AppTheme.lightGreen,
                    child: Icon(Icons.photo_library_rounded, color: AppTheme.primaryGreen),
                  ),
                  title: const Text('Choose from Gallery / Files', style: TextStyle(fontWeight: FontWeight.w600)),
                  subtitle: const Text('Select an existing photo from your storage'),
                  onTap: () {
                    Navigator.of(ctx).pop();
                    _pickImage(ImageSource.gallery);
                  },
                ),
                if (_imageBase64 != null)
                  ListTile(
                    leading: const CircleAvatar(
                      backgroundColor: Color(0xFFFFEBEE),
                      child: Icon(Icons.delete_outline_rounded, color: Colors.red),
                    ),
                    title: const Text('Remove Photo', style: TextStyle(color: Colors.red, fontWeight: FontWeight.w600)),
                    onTap: () {
                      Navigator.of(ctx).pop();
                      setState(() => _imageBase64 = null);
                    },
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _validateAndContinue() {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _currentStep = 2;
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill all required device details to proceed.'),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

  void _resetForm() {
    setState(() {
      _currentStep = 1;
      _deviceNameController.clear();
      _descriptionController.clear();
      _quantity = 1;
      _condition = DeviceCondition.damaged;
      _imageBase64 = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_currentStep == 2) {
      return PickupBookingScreen(
        category: _category,
        deviceName: _deviceNameController.text.trim(),
        quantity: _quantity,
        condition: _condition,
        description: _descriptionController.text.trim(),
        imageBase64: _imageBase64,
        onBackToDeviceDetails: () => setState(() => _currentStep = 1),
        onRequestCreated: (req) {
          _resetForm();
          widget.onRequestCreated(req);
        },
        onNavigateToTab: widget.onNavigateToTab,
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final isDesktop = constraints.maxWidth >= 900;
        final isTablet = constraints.maxWidth >= 600 && constraints.maxWidth < 900;
        final maxWidth = isDesktop ? 780.0 : double.infinity;

        return Center(
          child: Container(
            constraints: BoxConstraints(maxWidth: maxWidth),
            child: Scaffold(
              appBar: AppBar(
                title: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Step 1 of 2: Device Details',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.accentGreen,
                        letterSpacing: 0.5,
                      ),
                    ),
                    Text(
                      'Add E-Waste for Recycling',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF1B3820),
                      ),
                    ),
                  ],
                ),
              ),
              body: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: EdgeInsets.symmetric(
                  horizontal: isDesktop ? 24 : (isTablet ? 20 : 16),
                  vertical: 16,
                ),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Instructions banner
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: AppTheme.lightGreen.withValues(alpha: 0.7),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: AppTheme.accentGreen.withValues(alpha: 0.2)),
                        ),
                        child: const Row(
                          children: [
                            Icon(Icons.info_outline_rounded, color: AppTheme.primaryGreen, size: 22),
                            SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                'Provide device specs and condition. Photos help our recycling specialists inspect and categorize items prior to pickup.',
                                style: TextStyle(
                                  fontSize: 12.5,
                                  color: Color(0xFF1B3820),
                                  height: 1.3,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),

                      // 1. Device Category Dropdown
                      _buildSectionTitle('1. Device Category *', Icons.category_rounded),
                      const SizedBox(height: 8),
                      DropdownButtonFormField<DeviceCategory>(
                        initialValue: _category,
                        decoration: const InputDecoration(
                          prefixIcon: Icon(Icons.devices_rounded),
                          hintText: 'Select category',
                        ),
                        isExpanded: true,
                        items: DeviceCategory.values.map((cat) {
                          return DropdownMenuItem(
                            value: cat,
                            child: Row(
                              children: [
                                Icon(cat.icon, color: AppTheme.primaryGreen, size: 20),
                                const SizedBox(width: 10),
                                Text(cat.label, style: const TextStyle(fontWeight: FontWeight.w600)),
                              ],
                            ),
                          );
                        }).toList(),
                        onChanged: (cat) {
                          if (cat != null) setState(() => _category = cat);
                        },
                      ),
                      const SizedBox(height: 20),

                      // 2. Device Name Text Field
                      _buildSectionTitle('2. Device Name & Model *', Icons.drive_file_rename_outline_rounded),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _deviceNameController,
                        decoration: InputDecoration(
                          hintText: 'e.g. MacBook Pro 13", Samsung Galaxy S20, Dell Monitor',
                          prefixIcon: const Icon(Icons.devices_other_rounded),
                          suffixIcon: _deviceNameController.text.isNotEmpty
                              ? IconButton(
                                  icon: const Icon(Icons.clear_rounded, size: 18),
                                  onPressed: () => setState(() => _deviceNameController.clear()),
                                )
                              : null,
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Device name / model is required';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),

                      // 3 & 4. Image Upload & Preview
                      _buildSectionTitle('3. Device Photograph (Optional)', Icons.add_a_photo_rounded),
                      const SizedBox(height: 8),
                      _buildImageUploadBox(),
                      const SizedBox(height: 20),

                      // 5. Quantity Input
                      _buildSectionTitle('4. Quantity of Items *', Icons.numbers_rounded),
                      const SizedBox(height: 8),
                      _buildQuantitySelector(),
                      const SizedBox(height: 20),

                      // 6. Device Condition
                      _buildSectionTitle('5. Device Condition *', Icons.health_and_safety_rounded),
                      const SizedBox(height: 8),
                      _buildConditionSelector(),
                      const SizedBox(height: 20),

                      // 7. Additional Description
                      _buildSectionTitle('6. Additional Description', Icons.description_rounded),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _descriptionController,
                        maxLines: 3,
                        decoration: const InputDecoration(
                          hintText: 'Mention visible flaws, battery swelling, included chargers, cords, or storage status...',
                        ),
                      ),
                      const SizedBox(height: 28),

                      // 8. Continue Button
                      SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: ElevatedButton.icon(
                          onPressed: _validateAndContinue,
                          icon: const Icon(Icons.arrow_forward_rounded),
                          label: const Text(
                            'Continue to Pickup Booking',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                          ),
                        ),
                      ),
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildSectionTitle(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 18, color: AppTheme.primaryGreen),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: Color(0xFF1B3820),
          ),
        ),
      ],
    );
  }

  Widget _buildImageUploadBox() {
    if (_imageBase64 != null) {
      return Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppTheme.accentGreen.withValues(alpha: 0.3)),
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.memory(
                base64Decode(_imageBase64!),
                width: 90,
                height: 90,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Device Photo Uploaded',
                    style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: AppTheme.primaryGreen),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Photo is ready and will be saved locally with your request.',
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: [
                      OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          textStyle: const TextStyle(fontSize: 12),
                        ),
                        onPressed: _showImageSourceSheet,
                        icon: const Icon(Icons.change_circle_outlined, size: 16),
                        label: const Text('Change Photo'),
                      ),
                      TextButton.icon(
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.redAccent,
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                          textStyle: const TextStyle(fontSize: 12),
                        ),
                        onPressed: () => setState(() => _imageBase64 = null),
                        icon: const Icon(Icons.delete_outline_rounded, size: 16),
                        label: const Text('Remove'),
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

    return InkWell(
      onTap: _isPickingImage ? null : _showImageSourceSheet,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: Colors.grey.shade300,
            style: BorderStyle.solid,
            width: 1.5,
          ),
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: const BoxDecoration(
                color: AppTheme.lightGreen,
                shape: BoxShape.circle,
              ),
              child: _isPickingImage
                  ? const SizedBox(
                      width: 28,
                      height: 28,
                      child: CircularProgressIndicator(strokeWidth: 2.5, color: AppTheme.primaryGreen),
                    )
                  : const Icon(Icons.add_a_photo_outlined, color: AppTheme.primaryGreen, size: 28),
            ),
            const SizedBox(height: 10),
            const Text(
              'Tap to upload device photograph',
              style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: Color(0xFF1B3820)),
            ),
            const SizedBox(height: 4),
            Text(
              'Take a snap with Camera or select from Gallery',
              style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuantitySelector() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.black.withValues(alpha: 0.12)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Number of units', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
              Text('Select multiple units for bulk recycling', style: TextStyle(fontSize: 11, color: Colors.grey)),
            ],
          ),
          Row(
            children: [
              IconButton.filledTonal(
                icon: const Icon(Icons.remove_rounded),
                onPressed: _quantity > 1
                    ? () => setState(() => _quantity--)
                    : null,
              ),
              Container(
                width: 44,
                alignment: Alignment.center,
                child: Text(
                  '$_quantity',
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
                ),
              ),
              IconButton.filled(
                style: IconButton.styleFrom(backgroundColor: AppTheme.primaryGreen),
                icon: const Icon(Icons.add_rounded, color: Colors.white),
                onPressed: () => setState(() => _quantity++),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildConditionSelector() {
    return Column(
      children: DeviceCondition.values.map((cond) {
        final isSelected = _condition == cond;
        return Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: InkWell(
            borderRadius: BorderRadius.circular(14),
            onTap: () => setState(() => _condition = cond),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isSelected ? cond.color.withValues(alpha: 0.08) : Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: isSelected ? cond.color : Colors.black.withValues(alpha: 0.12),
                  width: isSelected ? 2 : 1,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    isSelected ? Icons.radio_button_checked_rounded : Icons.radio_button_off_rounded,
                    color: isSelected ? cond.color : Colors.grey,
                  ),
                  const SizedBox(width: 12),
                  Icon(cond.icon, color: cond.color, size: 22),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          cond.label,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: isSelected ? cond.color : Colors.black87,
                          ),
                        ),
                        Text(
                          cond.description,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}
