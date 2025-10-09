import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/models/category.dart';
import '../../providers/phrase_provider.dart';
import '../../providers/settings_provider.dart';
import '../widgets/phrase_tile.dart';

class CategoryScreen extends StatefulWidget {
  final Category category;

  const CategoryScreen({Key? key, required this.category}) : super(key: key);

  @override
  State<CategoryScreen> createState() => _CategoryScreenState();
}

class _CategoryScreenState extends State<CategoryScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.category.name == 'Favorites') {
        context.read<PhraseProvider>().loadFavorites();
      } else {
        context.read<PhraseProvider>().loadPhrasesByCategory(widget.category.id!);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.category.icon} ${widget.category.name}'),
        backgroundColor: const Color(0xFF1E88E5),
      ),
      body: Consumer2<PhraseProvider, SettingsProvider>(
        builder: (context, phraseProvider, settingsProvider, _) {
          final phrases = widget.category.name == 'Favorites'
              ? phraseProvider.favorites
              : phraseProvider.phrases;

          if (phrases.isEmpty) {
            return const Center(
              child: Text('No phrases available'),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: phrases.length,
            itemBuilder: (context, index) {
              return PhraseTile(
                phrase: phrases[index],
                isUrdu: settingsProvider.preferredLanguage == 'ur',
                onTap: () {
                  phraseProvider.speakPhrase(
                    phrases[index],
                    settingsProvider.preferredLanguage == 'ur',
                  );
                },
                onFavoriteToggle: () {
                  phraseProvider.toggleFavorite(phrases[index]);
                },
              );
            },
          );
        },
      ),
    );
  }
}