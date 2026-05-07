import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';

class CatalogImage extends StatelessWidget {
  const CatalogImage({
    super.key,
    required this.source,
    required this.fit,
    required this.errorBuilder,
    this.width,
    this.height,
  });

  final String source;
  final BoxFit fit;
  final double? width;
  final double? height;
  final Widget Function(BuildContext, Object, StackTrace?) errorBuilder;

  @override
  Widget build(BuildContext context) {
    if (source.startsWith('category://')) {
      return _ProductIllustration(
        kind: source.substring('category://'.length),
        width: width,
        height: height,
      );
    }

    if (source.startsWith('assets/')) {
      return Image.asset(
        source,
        width: width,
        height: height,
        fit: fit,
        errorBuilder: errorBuilder,
      );
    }

    return Image.network(
      source,
      width: width,
      height: height,
      fit: fit,
      errorBuilder: errorBuilder,
    );
  }
}

class _ProductIllustration extends StatelessWidget {
  const _ProductIllustration({
    required this.kind,
    required this.width,
    required this.height,
  });

  final String kind;
  final double? width;
  final double? height;

  @override
  Widget build(BuildContext context) {
    final spec = _ProductIllustrationSpec.from(kind);
    return SizedBox(
      width: width,
      height: height,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: spec.background,
          borderRadius: BorderRadius.circular(18),
        ),
        child: Stack(
          fit: StackFit.expand,
          children: [
            Positioned(
              right: -18,
              bottom: -18,
              child: Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  color: spec.accent.withValues(alpha: 0.14),
                  shape: BoxShape.circle,
                ),
              ),
            ),
            Positioned(
              left: -14,
              top: -14,
              child: Container(
                width: 54,
                height: 54,
                decoration: BoxDecoration(
                  color: AppColors.surface.withValues(alpha: 0.34),
                  shape: BoxShape.circle,
                ),
              ),
            ),
            Center(
              child: Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: AppColors.surface.withValues(alpha: 0.9),
                  shape: BoxShape.circle,
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x17000000),
                      blurRadius: 12,
                      offset: Offset(0, 5),
                    ),
                  ],
                ),
                child: Icon(spec.icon, color: spec.accent, size: 32),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProductIllustrationSpec {
  const _ProductIllustrationSpec({
    required this.icon,
    required this.background,
    required this.accent,
  });

  final IconData icon;
  final Color background;
  final Color accent;

  factory _ProductIllustrationSpec.from(String kind) {
    return switch (kind) {
      'produce' => const _ProductIllustrationSpec(
        icon: Icons.local_florist,
        background: Color(0xFFEAF8ED),
        accent: Color(0xFF27884F),
      ),
      'meat' => const _ProductIllustrationSpec(
        icon: Icons.set_meal,
        background: Color(0xFFFFE9E5),
        accent: Color(0xFFB7382B),
      ),
      'seafood' => const _ProductIllustrationSpec(
        icon: Icons.set_meal_outlined,
        background: Color(0xFFEAF6FF),
        accent: Color(0xFF2878B8),
      ),
      'deli' => const _ProductIllustrationSpec(
        icon: Icons.restaurant,
        background: Color(0xFFFFF0DA),
        accent: Color(0xFFD88420),
      ),
      'frozen' => const _ProductIllustrationSpec(
        icon: Icons.ac_unit,
        background: Color(0xFFEAF7F4),
        accent: Color(0xFF2C9A7A),
      ),
      'processed' => const _ProductIllustrationSpec(
        icon: Icons.shopping_bag,
        background: Color(0xFFFFF3D6),
        accent: Color(0xFFE1A21A),
      ),
      'bakery' => const _ProductIllustrationSpec(
        icon: Icons.cake,
        background: Color(0xFFFFEDF4),
        accent: Color(0xFFD94B79),
      ),
      'gift' => const _ProductIllustrationSpec(
        icon: Icons.card_giftcard,
        background: Color(0xFFF2EEFF),
        accent: Color(0xFF7C63C7),
      ),
      _ => const _ProductIllustrationSpec(
        icon: Icons.local_offer,
        background: AppColors.softGreen,
        accent: AppColors.primaryGreen,
      ),
    };
  }
}
