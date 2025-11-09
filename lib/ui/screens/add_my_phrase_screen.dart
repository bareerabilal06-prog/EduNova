import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/models/phrase.dart';
import '../../providers/phrase_provider.dart';

class AddMyPhraseScreen extends StatefulWidget {
  const AddMyPhraseScreen({super.key});

  @override
  State<AddMyPhraseScreen> createState() => _AddMyPhraseScreenState();
}

class _AddMyPhraseScreenState extends State<AddMyPhraseScreen> {
  final _formKey = GlobalKey<FormState>();
  final _englishController = TextEditingController();
  final _urduController = TextEditingController();

  @override
  void dispose() {
    _englishController.dispose();
    _urduController.dispose();
    super.dispose();
  }

  // ✅ Validation Patterns
  final RegExp _englishPattern = RegExp(r'^[a-zA-Z0-9 ]+$');
  final RegExp _urduPattern = RegExp(r'^[\u0600-\u06FF0-9 ]*$');

  Future<void> _savePhrase() async {
    if (!_formKey.currentState!.validate()) return;

    final phrase = Phrase(
      id: 0,
      categoryId: 7, // Fixed "My Phrases"
      englishText: _englishController.text.trim(),
      urduText: _urduController.text.trim(),
      emoji: '📝', // Fixed emoji
    );

    await context.read<PhraseProvider>().addPhrase(phrase);

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Phrase added successfully')),
    );

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add My Phrase'),
        backgroundColor: const Color(0xFF1E88E5),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // ✅ English Text Field
                  TextFormField(
                    controller: _englishController,
                    decoration: const InputDecoration(
                      labelText: 'English Text *',
                      border: OutlineInputBorder(),
                      hintText: 'Enter phrase in English',
                    ),
                    maxLength: 100,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'English text is required';
                      }
                      if (!_englishPattern.hasMatch(value.trim())) {
                        return 'Only letters, numbers, and spaces allowed';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // ✅ Urdu Text Field (Optional)
                  TextFormField(
                    controller: _urduController,
                    decoration: const InputDecoration(
                      labelText: 'Urdu Text (optional)',
                      border: OutlineInputBorder(),
                      hintText: 'اردو متن درج کریں (اختیاری)',
                    ),
                    textDirection: TextDirection.rtl,
                    maxLength: 100,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) return null;
                      if (!_urduPattern.hasMatch(value.trim())) {
                        return 'Only Urdu letters, numbers, and spaces allowed';
                      }
                      return null;
                    },
                  ),

                  const SizedBox(height: 32),

                  // ✅ Save Button
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.save, color: Colors.white),
                      label: const Text(
                        'Save Phrase',
                        style: TextStyle(color: Colors.white),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1E88E5),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: _savePhrase,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
