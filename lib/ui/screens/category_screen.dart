import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/models/category.dart';
import '../../providers/phrase_provider.dart';
import '../../providers/settings_provider.dart';
import '../widgets/phrase_tile.dart';
import '../widgets/category_slider.dart';
import 'add_my_phrase_screen.dart';

class CategoryScreen extends StatefulWidget {
  final Category category;

  const CategoryScreen({super.key, required this.category});

  @override
  State<CategoryScreen> createState() => _CategoryScreenState();
}

class _CategoryScreenState extends State<CategoryScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final phraseProvider = context.read<PhraseProvider>();
      if (widget.category.name == 'Favorites') {
        phraseProvider.loadFavorites();
      } else {
        phraseProvider.loadCategoryWithFavorites(widget.category.id);
      }
    });
  }

  static const List<List<Color>> phraseGradients = [
    [Color.fromARGB(128, 30, 136, 229), Color.fromARGB(128, 21, 101, 192)],
    [Color.fromARGB(128, 67, 160, 71), Color.fromARGB(128, 46, 125, 50)],
    [Color.fromARGB(128, 251, 140, 0), Color.fromARGB(128, 245, 124, 0)],
    [Color.fromARGB(128, 229, 57, 53), Color.fromARGB(128, 198, 40, 40)],
    [Color.fromARGB(128, 142, 36, 170), Color.fromARGB(128, 106, 27, 154)],
    [Color.fromARGB(128, 0, 172, 193), Color.fromARGB(128, 0, 131, 143)],
  ];

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsProvider>();

    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.category.icon} ${widget.category.name}'),
        backgroundColor: const Color(0xFF1E88E5),
        actions: [
          IconButton(
            tooltip: settings.preferredLanguage == 'ur'
                ? 'Switch to English'
                : 'Switch to Urdu',
            icon: Text(
              settings.preferredLanguage == 'ur' ? 'EN' : 'ع',
              style: const TextStyle(
                  fontWeight: FontWeight.bold, color: Colors.white),
            ),
            onPressed: () {
              final newLang = settings.preferredLanguage == 'ur' ? 'en' : 'ur';
              context.read<SettingsProvider>().setLanguage(newLang);
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: Consumer2<PhraseProvider, SettingsProvider>(
              builder: (context, phraseProvider, settingsProvider, _) {
                final phrases = widget.category.name == 'Favorites'
                    ? phraseProvider.favorites
                    : phraseProvider.phrases;

                if (phrases.isEmpty) {
                  return const Center(child: Text('No phrases available'));
                }

                return GridView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: phrases.length,
                  physics: const BouncingScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                    maxCrossAxisExtent: 300,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: 280 / 140,
                  ),
                  itemBuilder: (context, index) {
                    final phrase = phrases[index];
                    final gradient =
                    phraseGradients[index % phraseGradients.length];

                    // ✅ Ensure favorite status is always fresh
                    final isFavorite = phraseProvider.isFavorite(phrase.id!);

                    return PhraseTile(
                      phrase: phrase.copyWith(isFavorite: isFavorite),
                      isUrdu: settingsProvider.preferredLanguage == 'ur',
                      gradientColors: gradient,
                      onTap: () {
                        phraseProvider.speakPhrase(
                          phrase,
                          settingsProvider.preferredLanguage == 'ur',
                        );
                      },
                    );
                  },
                );
              },
            ),
          ),
          SafeArea(
            child: CategorySlider(
              currentCategoryId: widget.category.id,
            ),
          ),
        ],
      ),

      floatingActionButton: widget.category.id == 7
          ? Padding(
        padding: const EdgeInsets.only(bottom: 80.0, right: 5.0),
        child: FloatingActionButton.extended(
          backgroundColor: const Color(0xFF1E88E5),
          foregroundColor: Colors.white,
          icon: const Icon(Icons.add),
          label: const Text(
            "Add Phrase",
            style: TextStyle(color: Colors.white),
          ),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const AddMyPhraseScreen(),
              ),
            );
          },
        ),
      )
          : null,
    );
  }
}
