import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/settings_provider.dart';
import '../../providers/phrase_provider.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsProvider>();
    final isUrdu = settings.preferredLanguage == 'ur';
    String t(String en, String ur) => isUrdu ? ur : en;

    final isDesktop = defaultTargetPlatform == TargetPlatform.windows ||
        defaultTargetPlatform == TargetPlatform.linux ||
        defaultTargetPlatform == TargetPlatform.macOS;

    return Scaffold(
      appBar: AppBar(
        title: Text(t('Settings', 'ترتیبات'),
            style: TextStyle(fontFamily: isUrdu ? 'NotoNastaliqUrdu' : 'Inter')),
        backgroundColor: const Color(0xFF1E88E5),
      ),
      body: Directionality(
        textDirection: isUrdu ? TextDirection.rtl : TextDirection.ltr,
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            // ---------------- Accessibility ----------------
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16.0),
              child: Text(
                t('Accessibility', 'دستیابی'),
                style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    fontFamily: isUrdu ? 'NotoNastaliqUrdu' : 'Inter'),
                textAlign: isUrdu ? TextAlign.right : TextAlign.left,
              ),
            ),
            Consumer<SettingsProvider>(
              builder: (context, provider, _) => Column(
                children: [
                  SwitchListTile(
                    title: Text(t('Large Text', 'بڑا متن'),
                        style: TextStyle(
                            fontFamily: isUrdu ? 'NotoNastaliqUrdu' : 'Inter')),
                    subtitle: Text(
                      t('Increase text size for better readability',
                          'بہتر مطالعہ کے لیے متن کا سائز بڑھائیں'),
                      style: TextStyle(
                          fontFamily: isUrdu ? 'NotoNastaliqUrdu' : 'Inter'),
                    ),
                    value: provider.isLargeText,
                    onChanged: (_) => provider.toggleLargeText(),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                  ),
                  SwitchListTile(
                    title: Text(t('High Contrast', 'اعلی متضاد'),
                        style: TextStyle(
                            fontFamily: isUrdu ? 'NotoNastaliqUrdu' : 'Inter')),
                    subtitle: Text(
                      t('Use high contrast theme', 'اعلی متضاد تھیم استعمال کریں'),
                      style: TextStyle(
                          fontFamily: isUrdu ? 'NotoNastaliqUrdu' : 'Inter'),
                    ),
                    value: provider.isHighContrast,
                    onChanged: (_) => provider.toggleHighContrast(),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                  ),
                  const Divider(),

                  // ---------------- Voice Settings ----------------
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16.0),
                    child: Text(
                      t('Voice Settings', 'آواز کی ترتیبات'),
                      style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          fontFamily: isUrdu ? 'NotoNastaliqUrdu' : 'Inter'),
                      textAlign: isUrdu ? TextAlign.right : TextAlign.left,
                    ),
                  ),
                  Builder(builder: (context) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SwitchListTile(
                          title: Text(t('Voice Gender', 'آواز کا جنس'),
                              style: TextStyle(
                                  fontFamily:
                                  isUrdu ? 'NotoNastaliqUrdu' : 'Inter')),
                          subtitle: Text(
                            provider.isMaleVoice
                                ? t('Male Voice', 'مردانہ آواز')
                                : t('Female Voice', 'زنانہ آواز'),
                            style: TextStyle(
                                fontFamily:
                                isUrdu ? 'NotoNastaliqUrdu' : 'Inter'),
                          ),
                          value: provider.isMaleVoice,
                          onChanged: isDesktop
                              ? null
                              : (_) {
                            provider.toggleVoiceGender();
                            context
                                .read<PhraseProvider>()
                                .setVoiceGender(provider.isMaleVoice);
                          },
                          contentPadding:
                          const EdgeInsets.symmetric(horizontal: 16),
                        ),
                        if (isDesktop)
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16.0),
                            child: Text(
                              t(
                                  'Male/Female voice selection is not available on desktop.',
                                  'ڈیسک ٹاپ پر مرد/عورت کی آواز کا انتخاب دستیاب نہیں ہے۔'),
                              style: TextStyle(
                                  fontSize: 12,
                                  fontStyle: FontStyle.italic,
                                  color: Colors.grey[600],
                                  fontFamily:
                                  isUrdu ? 'NotoNastaliqUrdu' : 'Inter'),
                            ),
                          ),
                      ],
                    );
                  }),

                  // ---------------- Preferred Language ----------------
                  Container(
                    width: double.infinity,
                    padding:
                    const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          t('Preferred Language', 'پسندیدہ زبان'),
                          style: TextStyle(
                              fontFamily:
                              isUrdu ? 'NotoNastaliqUrdu' : 'Inter',
                              fontWeight: FontWeight.w600),
                          textAlign: isUrdu ? TextAlign.right : TextAlign.left,
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            // English option
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Radio<String>(
                                  value: 'en',
                                  groupValue: provider.preferredLanguage,
                                  onChanged: (value) => provider.setLanguage(value!),
                                ),
                                Text(
                                  'English',
                                  style: TextStyle(
                                    fontFamily: provider.preferredLanguage == 'en'
                                        ? 'Inter'
                                        : 'Inter',
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(width: 16),
                            // Urdu option
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Radio<String>(
                                  value: 'ur',
                                  groupValue: provider.preferredLanguage,
                                  onChanged: (value) => provider.setLanguage(value!),
                                ),
                                Text(
                                  'اردو',
                                  style: TextStyle(
                                    fontFamily: provider.preferredLanguage == 'ur'
                                        ? 'NotoNastaliqUrdu'
                                        : 'NotoNastaliqUrdu',
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const Divider(),

                  // ---------------- About ----------------
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16.0),
                    child: Text(
                      t('About', 'ہمارے بارے میں'),
                      style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          fontFamily: isUrdu ? 'NotoNastaliqUrdu' : 'Inter'),
                      textAlign: isUrdu ? TextAlign.right : TextAlign.left,
                    ),
                  ),
                  ListTile(
                    title: Text(t('Version', 'ورژن'),
                        style: TextStyle(
                            fontFamily: isUrdu ? 'NotoNastaliqUrdu' : 'Inter')),
                    subtitle:
                    const Text('1.0.0', style: TextStyle(fontFamily: 'Inter')),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                  ),
                  ListTile(
                    title: Text(t('EduNova', 'ایجو نوا'),
                        style: TextStyle(
                            fontFamily: isUrdu ? 'NotoNastaliqUrdu' : 'Inter')),
                    subtitle: Text(
                      t('Voice for Every Student, Understanding for Every Teacher',
                          'ہر طالب علم کے لیے آواز، ہر استاد کے لیے سمجھ'),
                      style: TextStyle(
                          fontFamily: isUrdu ? 'NotoNastaliqUrdu' : 'Inter'),
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
