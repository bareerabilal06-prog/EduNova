import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/settings_provider.dart';
import '../../providers/phrase_provider.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        backgroundColor: const Color(0xFF1E88E5),
      ),
      body: Consumer<SettingsProvider>(
        builder: (context, provider, _) {
          return ListView(
            children: [
              const Padding(
                padding: EdgeInsets.all(16.0),
                child: Text(
                  'Accessibility',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ),
              SwitchListTile(
                title: const Text('Large Text'),
                subtitle: const Text('Increase text size for better readability'),
                value: provider.isLargeText,
                onChanged: (_) => provider.toggleLargeText(),
              ),
              SwitchListTile(
                title: const Text('High Contrast'),
                subtitle: const Text('Use high contrast theme'),
                value: provider.isHighContrast,
                onChanged: (_) => provider.toggleHighContrast(),
              ),
              const Divider(),
              const Padding(
                padding: EdgeInsets.all(16.0),
                child: Text(
                  'Voice Settings',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ),
              SwitchListTile(
                title: const Text('Voice Gender'),
                subtitle: Text(provider.isMaleVoice ? 'Male Voice' : 'Female Voice'),
                value: provider.isMaleVoice,
                onChanged: (_) {
                  provider.toggleVoiceGender();
                  context.read<PhraseProvider>().setVoiceGender(provider.isMaleVoice);
                },
              ),
              ListTile(
                title: const Text('Preferred Language'),
                subtitle: Text(provider.preferredLanguage == 'en' ? 'English' : 'Urdu'),
                trailing: DropdownButton<String>(
                  value: provider.preferredLanguage,
                  items: const [
                    DropdownMenuItem(value: 'en', child: Text('English')),
                    DropdownMenuItem(value: 'ur', child: Text('Urdu')),
                  ],
                  onChanged: (value) {
                    if (value != null) {
                      provider.setLanguage(value);
                    }
                  },
                ),
              ),
              const Divider(),
              const Padding(
                padding: EdgeInsets.all(16.0),
                child: Text(
                  'About',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ),
              const ListTile(
                title: Text('Version'),
                subtitle: Text('1.0.0'),
              ),
              const ListTile(
                title: Text('EduNova'),
                subtitle: Text('Voice for Every Student, Understanding for Every Teacher'),
              ),
            ],
          );
        },
      ),
    );
  }
}