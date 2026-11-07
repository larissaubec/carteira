import 'package:flutter/material.dart';

/// Circular avatar. Shows the network image when [imageUrl] is present and
/// loads; otherwise the initials of [name].
class AppAvatar extends StatelessWidget {
  const AppAvatar({
    required this.name,
    super.key,
    this.imageUrl,
    this.size = 40,
  });

  final String name;
  final String? imageUrl;
  final double size;

  /// "Ana Ribeiro" -> "AR", "ana" -> "A", "" -> "?".
  static String initialsOf(String name) {
    final parts = name
        .trim()
        .split(RegExp(r'\s+'))
        .where((p) => p.isNotEmpty)
        .toList();
    if (parts.isEmpty) return '?';
    if (parts.length == 1) return parts.first[0].toUpperCase();
    return (parts.first[0] + parts.last[0]).toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final url = imageUrl;
    final fallback = Text(
      initialsOf(name),
      style: TextStyle(
        fontSize: size * 0.38,
        fontWeight: FontWeight.w600,
        color: scheme.onPrimaryContainer,
      ),
    );

    return Semantics(
      image: true,
      label: 'Avatar de $name',
      child: SizedBox.square(
        dimension: size,
        child: ClipOval(
          child: ColoredBox(
            color: scheme.primaryContainer,
            child: url == null || url.isEmpty
                ? Center(child: fallback)
                : Image.network(
                    url,
                    fit: BoxFit.cover,
                    errorBuilder: (_, _, _) => Center(child: fallback),
                  ),
          ),
        ),
      ),
    );
  }
}
