import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../../../core/constants.dart';

class DoctorAvatar extends StatelessWidget {
  final String? imageUrl;
  final double size;
  final double radius;
  final Color backgroundColor;
  final Color iconColor;
  final double iconSize;

  const DoctorAvatar({
    super.key,
    required this.imageUrl,
    required this.size,
    required this.radius,
    this.backgroundColor = const Color(0xFFE9EEF5),
    this.iconColor = Colors.grey,
    double? iconSize,
  }) : iconSize = iconSize ?? size * 0.5;

  @override
  Widget build(BuildContext context) {
    final normalizedUrl = _normalizeImageUrl(imageUrl);

    return ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: Container(
        width: size,
        height: size,
        color: backgroundColor,
        child: normalizedUrl == null
            ? _fallback()
            : CachedNetworkImage(
                imageUrl: normalizedUrl,
                width: size,
                height: size,
                fit: BoxFit.cover,
                fadeInDuration: const Duration(milliseconds: 160),
                placeholder: (_, __) => _fallback(isLoading: true),
                errorWidget: (_, __, ___) => _fallback(),
              ),
      ),
    );
  }

  Widget _fallback({bool isLoading = false}) {
    if (isLoading) {
      return Center(
        child: SizedBox(
          width: size * 0.28,
          height: size * 0.28,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            color: iconColor.withOpacity(0.65),
          ),
        ),
      );
    }

    return Icon(Icons.person, size: iconSize, color: iconColor);
  }

  String? _normalizeImageUrl(String? rawUrl) {
    final url = rawUrl?.trim();
    if (url == null || url.isEmpty) {
      return null;
    }

    if (url.startsWith('http://') || url.startsWith('https://')) {
      return url;
    }
    if (url.startsWith('//')) {
      return 'https:$url';
    }
    if (url.startsWith('/')) {
      return '${AppConstants.baseUrl}$url';
    }
    return url;
  }
}
