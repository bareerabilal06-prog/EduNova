import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/ai_provider_offline.dart';
import '../../providers/phrase_provider.dart';
import '../../providers/settings_provider.dart';
import '../../core/models/phrase.dart';

class AISentenceBuilderOfflineScreen extends StatefulWidget {
  const AISentenceBuilderOfflineScreen({super.key});

  @override
  State<AISentenceBuilderOfflineScreen> createState() =>
      _AISentenceBuilderOfflineScreenState();
}

class _AISentenceBuilderOfflineScreenState
    extends State<AISentenceBuilderOfflineScreen> {
  @override
  void initState() {
    super.initState();
    context.read<AIProviderOffline>().initSuggestions();
  }

  void _showError(String message) {
    if (!mounted) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsProvider>();

    context.read<PhraseProvider>().setVoiceGender(settings.isMaleVoice);

    return Scaffold(
      appBar: AppBar(
        title: const Text('AI Sentence Builder (Offline)'),
        backgroundColor: Colors.blueGrey,
        actions: [
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () =>
                context.read<AIProviderOffline>().clearSentence(),
          ),
        ],
      ),
      body: Consumer<AIProviderOffline>(
        builder: (context, aiProvider, _) {
          final isRTL = Directionality.of(context) == TextDirection.rtl;

          return Column(
            children: [
              Container(
                width: double.infinity,
                padding:
                const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
                color: Colors.blue.shade50,
                child: Column(
                  children: [
                    Text(
                      aiProvider.builtSentence.isEmpty
                          ? 'Tap words below to build a sentence'
                          : aiProvider.builtSentence,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                      textDirection:
                      isRTL ? TextDirection.rtl : TextDirection.ltr,
                    ),
                    if (aiProvider.builtSentence.isNotEmpty)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.backspace),
                            onPressed: () => aiProvider.removeLastWord(
                              onError: _showError,
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.volume_up),
                            onPressed: () async {
                              bool isUrdu =
                                  settings.preferredLanguage == 'ur';

                              bool success =
                              await context.read<PhraseProvider>().speakPhrase(
                                Phrase(
                                  categoryId: 0,
                                  englishText: aiProvider.builtSentence,
                                  urduText: aiProvider.builtSentence,
                                  emoji: '🗣️',
                                ),
                                isUrdu,
                              );

                              if (!success) {
                                _showError(
                                  'Urdu TTS voice is not installed on this system.',
                                );
                              }
                            },
                          ),
                        ],
                      ),
                  ],
                ),
              ),
              const Divider(height: 1),
              Expanded(
                child: aiProvider.isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : aiProvider.currentSuggestions.isEmpty
                    ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        'No suggestions. Clear to start over.',
                        style: TextStyle(fontSize: 16),
                      ),
                      const SizedBox(height: 12),
                      ElevatedButton(
                        onPressed: aiProvider.clearSentence,
                        child: const Text('Clear Sentence'),
                      ),
                    ],
                  ),
                )
                    : GridView.builder(
                  padding: const EdgeInsets.all(16),
                  gridDelegate:
                  const SliverGridDelegateWithMaxCrossAxisExtent(
                    maxCrossAxisExtent: 280, // fixed card width
                    mainAxisExtent: 60, // fixed card height
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                  ),
                  itemCount: aiProvider.currentSuggestions.length,
                  itemBuilder: (context, index) {
                    final word =
                    aiProvider.currentSuggestions[index];
                    return Card(
                      elevation: 2,
                      child: InkWell(
                        onTap: () => aiProvider.addWord(
                          word,
                          onError: _showError,
                        ),
                        child: Center(
                          child: Text(
                            word,
                            textAlign: TextAlign.center,
                            textDirection: isRTL
                                ? TextDirection.rtl
                                : TextDirection.ltr,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
