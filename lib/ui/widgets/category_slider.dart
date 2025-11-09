import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/category_provider.dart';
import '../screens/category_screen.dart';

class CategorySlider extends StatefulWidget {
  final int currentCategoryId;

  const CategorySlider({super.key, required this.currentCategoryId});

  @override
  State<CategorySlider> createState() => _CategorySliderState();
}

class _CategorySliderState extends State<CategorySlider> {
  final ScrollController _scrollController = ScrollController();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<CategoryProvider>();
      final categories = provider.categories;
      final index = categories.indexWhere((c) => c.id == widget.currentCategoryId);

      if (index != -1 && _scrollController.hasClients) {
        const double chipWidth = 140; // slightly wider for better balance
        final double screenWidth = MediaQuery.of(context).size.width;
        final double targetOffset =
            (index * chipWidth) - (screenWidth / 2) + (chipWidth / 2);

        _scrollController.animateTo(
          targetOffset.clamp(
            _scrollController.position.minScrollExtent,
            _scrollController.position.maxScrollExtent,
          ),
          duration: const Duration(milliseconds: 600),
          curve: Curves.easeOutCubic,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<CategoryProvider>(
      builder: (context, provider, _) {
        final categories = provider.categories;

        if (categories.isEmpty) return const SizedBox.shrink();

        return ClipRRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(
              height: 80,
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.white.withAlpha(217), // translucent background
                border: const Border(
                  top: BorderSide(color: Colors.black12, width: 0.8),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withAlpha(25),
                    blurRadius: 6,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: SingleChildScrollView(
                controller: _scrollController,
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                child: Row(
                  children: categories.map((category) {
                    final bool isSelected =
                        category.id == widget.currentCategoryId;

                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: ChoiceChip(
                        labelPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        avatar: Text(
                          category.icon,
                          style: const TextStyle(fontSize: 24), // bigger icon
                        ),
                        label: Text(
                          category.name,
                          style: TextStyle(
                            fontSize: 15,
                            color: isSelected ? Colors.white : Colors.black87,
                            fontWeight:
                            isSelected ? FontWeight.bold : FontWeight.w500,
                          ),
                        ),
                        selected: isSelected,
                        backgroundColor: Colors.white.withAlpha(102),
                        selectedColor: const Color(0xFF1E88E5),
                        checkmarkColor: Colors.transparent, // ❌ hides the tick
                        elevation: isSelected ? 3 : 0,
                        pressElevation: 1,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(32),
                        ),
                        onSelected: (_) {
                          if (!isSelected) {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (_) =>
                                    CategoryScreen(category: category),
                              ),
                            );
                          }
                        },
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }
}
