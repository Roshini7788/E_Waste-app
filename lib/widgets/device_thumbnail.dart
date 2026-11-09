import 'dart:convert';
import 'package:flutter/material.dart';
import '../models/waste_request.dart';
import '../theme/app_theme.dart';

class DeviceThumbnail extends StatelessWidget {
  final String? imageBase64;
  final DeviceCategory category;
  final double size;
  final double borderRadius;
  final BoxFit fit;

  const DeviceThumbnail({
    super.key,
    required this.imageBase64,
    required this.category,
    this.size = 56,
    this.borderRadius = 12,
    this.fit = BoxFit.cover,
  });

  @override
  Widget build(BuildContext context) {
    if (imageBase64 != null && imageBase64!.isNotEmpty) {
      try {
        final bytes = base64Decode(imageBase64!);
        return ClipRRect(
          borderRadius: BorderRadius.circular(borderRadius),
          child: Image.memory(
            bytes,
            width: size,
            height: size,
            fit: fit,
            errorBuilder: (context, error, stackTrace) => _buildFallback(),
          ),
        );
      } catch (_) {
        return _buildFallback();
      }
    }
    return _buildFallback();
  }

  Widget _buildFallback() {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: AppTheme.lightGreen,
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(color: AppTheme.accentGreen.withValues(alpha: 0.15)),
      ),
      child: Center(
        child: Icon(
          category.icon,
          color: AppTheme.primaryGreen,
          size: size * 0.48,
        ),
      ),
    );
  }
}
