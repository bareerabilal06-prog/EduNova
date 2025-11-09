import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/category_provider.dart';
import '../../providers/settings_provider.dart';
import '../widgets/category_card.dart';
import '../widgets/drawer_menu.dart';
import 'category_screen.dart';
import 'ai_sentence_builder_online_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _query = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CategoryProvider>().loadCategories();
    });

    _searchController.addListener(() {
      setState(() {
        _query = _searchController.text.trim();
      });
    });
  }

  @override
  void dispose() {
    _searchController.removeListener(() {});
    _searchController.dispose();
    super.dispose();
  }

  List _filtered(List categories) {
    if (_query.isEmpty) return categories;
    final q = _query.toLowerCase();
    return categories.where((c) => c.name.toLowerCase().contains(q)).toList();
  }

  final List<List<Color>> categoryGradients = [
    [const Color(0xFFC04848), const Color(0xFF480048)], // Maroon
    [const Color(0xFF25C700), const Color(0xff075e07)], // Green
    [const Color(0xFFE18139), const Color(0xFF8C4804)], // Orange
    [const Color(0xFFED413E), const Color(0xFF800B0B)], // Red
    [const Color(0xFFC53FEA), const Color(0xFF6A1B9A)], // Purple
    [const Color(0xFF047AEF), const Color(0xFF032559)], // Blue
    [const Color(0xFF04D4EF), const Color(0xFF035259)], // Teal
  ];

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsProvider>();

    return Scaffold(
      drawer: const DrawerMenu(),
      appBar: AppBar(
        title: const Text(
          'EduNova',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFF1565C0),
        elevation: 4,
        actions: [
          IconButton(
            tooltip: settings.preferredLanguage == 'ur'
                ? 'Switch to English'
                : 'Switch to Urdu',
            icon: Text(
              settings.preferredLanguage == 'ur' ? 'ع' : 'EN',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            onPressed: () {
              try {
                if (settings.preferredLanguage == 'ur') {
                  context.read<SettingsProvider>().setLanguage('en');
                } else {
                  context.read<SettingsProvider>().setLanguage('ur');
                }
              } catch (_) {}
            },
          ),
        ],
      ),

      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF1565C0),
        child: const Icon(Icons.auto_awesome, color: Colors.white),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AISentenceBuilderOnlineScreen()),
          );
        },
      ),

      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF1E88E5), Color(0xFF1565C0)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Consumer<CategoryProvider>(
            builder: (context, provider, _) {
              if (provider.isLoading) {
                return const Center(
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 3,
                  ),
                );
              }

              final categories = provider.categories;
              if (categories.isEmpty) {
                return const Center(
                  child: Text(
                    'No categories found.',
                    style: TextStyle(fontSize: 18, color: Colors.white),
                  ),
                );
              }

              final filtered = _filtered(categories);

              return Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                    child: TextField(
                      controller: _searchController,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        hintText: 'Search categories or phrases...',
                        hintStyle: const TextStyle(color: Colors.white70),
                        prefixIcon: const Icon(Icons.search, color: Colors.white70),
                        filled: true,
                        fillColor: const Color.fromRGBO(255, 255, 255, 0.12),
                        contentPadding: const EdgeInsets.symmetric(vertical: 12),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                  ),

                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: GridView.builder(
                        physics: const BouncingScrollPhysics(),
                        itemCount: filtered.length,
                        gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                          maxCrossAxisExtent: 220, // ✅ Each card ~220px wide
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 16,
                          childAspectRatio: 1, // ✅ Keep them square-ish
                        ),
                        itemBuilder: (context, index) {
                          final cat = filtered[index];
                          return Hero(
                            tag: 'category_${cat.id}',
                            child: Center(
                              child: CategoryCard(
                                category: cat,
                                gradientColors: categoryGradients[index % categoryGradients.length], // ✅ Cycle colors
                                onTap: () {
                                  provider.selectCategory(cat);
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => CategoryScreen(category: cat),
                                    ),
                                  ).then((_) {
                                    provider.loadCategories(forceRefresh: true);
                                  });
                                },
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
