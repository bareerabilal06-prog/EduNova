import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/models/category.dart';
import '../../providers/settings_provider.dart';

class CategoryCard extends StatelessWidget {
  final Category category;
  final VoidCallback? onTap;
  final List<Color>? gradientColors; // ✅ new optional gradient field

  const CategoryCard({
    super.key,
    required this.category,
    this.onTap,
    this.gradientColors,
  });

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsProvider>();
    final bool isUrdu = settings.preferredLanguage == 'ur';

    final colors = gradientColors ??
        const [Color(0xFF1E88E5), Color(0xFF1565C0)]; // default blue gradient

    return SizedBox(
      width: 180,
      height: 180,
      child: Card(
        elevation: 6,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: InkWell(
          onTap: onTap ?? () {},
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: colors,
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: const Color(0x76ADE3FF),
                width: 1.0,
                style: BorderStyle.solid,
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.fromLTRB(6, 2, 6, 6),
                  decoration: const BoxDecoration(
                    color: Colors.black26,
                    shape: BoxShape.circle,
                  ),
                  child: Text(
                    category.icon,
                    style: const TextStyle(fontSize: 32),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  isUrdu ? category.urduName : category.name,
                  textAlign: TextAlign.center,
                  textDirection:
                  isUrdu ? TextDirection.rtl : TextDirection.ltr,
                  overflow: TextOverflow.fade,
                  softWrap: true,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: isUrdu ? 14 : 16,
                    fontWeight: FontWeight.bold,
                    fontFamily: isUrdu ? 'NotoNastaliqUrdu' : 'Inter',
                    height: isUrdu ? 1.8 : 1.6,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
