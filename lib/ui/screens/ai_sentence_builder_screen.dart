import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/models/phrase.dart';
import '../../providers/ai_provider.dart';
import '../../providers/phrase_provider.dart';
import '../../providers/settings_provider.dart';

class AISentenceBuilderScreen extends StatelessWidget {
  const AISentenceBuilderScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AI Sentence Builder'),
        backgroundColor: const Color(0xFF1E88E5),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () {
              context.read<AIProvider>().clearSentence();
            },
          ),
        ],
      ),
      body: Consumer<AIProvider>(
        builder: (context, aiProvider, _) {
          return Column(
            children: [
              // Built sentence display
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                color: Colors.blue.shade50,
                child: Column(
                  children: [
                    Text(
                      aiProvider.builtSentence.isEmpty
                          ? 'Tap words below to build a sentence'
                          : aiProvider.builtSentence,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    if (aiProvider.builtSentence.isNotEmpty)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.backspace),
                            onPressed: () => aiProvider.removeLastWord(),
                          ),
                          IconButton(
                            icon: const Icon(Icons.volume_up),
                            onPressed: () {
                              // Speak the built sentence
                              context.read<PhraseProvider>().speakPhrase(
                                Phrase(
                                  categoryId: 0,
                                  englishText: aiProvider.builtSentence,
                                  urduText: aiProvider.builtSentence,
                                  emoji: '🗣️',
                                ),
                                false,
                              );
                            },
                          ),
                        ],
                      ),
                  ],
                ),
              ),
              const Divider(),
              // Word suggestions
              Expanded(
                child: aiProvider.builtSentence.isEmpty
                    ? _buildStarterWords(context, aiProvider)
                    : _buildSuggestions(context, aiProvider),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildStarterWords(BuildContext context, AIProvider provider) {
    final starterWords = provider.getStarterWords();
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 2,
      ),
      itemCount: starterWords.length,
      itemBuilder: (context, index) {
        return _buildWordChip(context, starterWords[index], provider);
      },
    );
  }

  Widget _buildSuggestions(BuildContext context, AIProvider provider) {
    if (provider.currentSuggestions.isEmpty) {
      return const Center(
        child: Text('No more suggestions. Clear to start over.'),
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 2,
      ),
      itemCount: provider.currentSuggestions.length,
      itemBuilder: (context, index) {
        return _buildWordChip(
          context,
          provider.currentSuggestions[index],
          provider,
        );
      },
    );
  }

  Widget _buildWordChip(BuildContext context, String word, AIProvider provider) {
    return Card(
      elevation: 2,
      child: InkWell(
        onTap: () => provider.addWord(word),
        child: Center(
          child: Text(
            word,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}