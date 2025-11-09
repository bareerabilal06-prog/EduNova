import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/category_provider.dart';
import '../../providers/connectivity_provider.dart';
import '../../providers/settings_provider.dart';
import '../screens/category_screen.dart';
import '../screens/profile_screen.dart';
import '../screens/settings_screen.dart';
import '../screens/ai_sentence_builder_offline_screen.dart';
import '../screens/ai_sentence_builder_online_screen.dart';

class DrawerMenu extends StatelessWidget {
  const DrawerMenu({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsProvider>();
    final isUrdu = settings.preferredLanguage == 'ur';
    String t(String en, String ur) => isUrdu ? ur : en;

    return Drawer(
      backgroundColor: const Color(0xFF1E88E5), // dark blue background
      child: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: isUrdu ? CrossAxisAlignment.end : CrossAxisAlignment.start,
            children: [
              // Header
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF1E88E5), Color(0xFF1565C0)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  border: Border(
                    bottom: BorderSide(
                      color: Colors.white24, // semi-transparent white
                      width: 1, // thickness of the border
                    ),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: isUrdu ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                  children: [
                    const _HoverAvatar(),
                    const SizedBox(height: 12),
                    const Text(
                      'EduNova',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Inter',
                      ),
                    ),
                    Text(
                      t('Voice for Every Student', 'ہر طالب علم کی آواز'),
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 13,
                        fontFamily: isUrdu ? 'NotoNastaliqUrdu' : 'Inter',
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: isUrdu ? MainAxisAlignment.end : MainAxisAlignment.start,
                      children: [
                        const Icon(Icons.wifi, color: Colors.white70, size: 16),
                        const SizedBox(width: 4),
                        Consumer<ConnectivityProvider>(
                          builder: (_, conn, __) => Text(
                            conn.isOnline ? t('Online', 'آن لائن') : t('Offline', 'آف لائن'),
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 12,
                              fontFamily: isUrdu ? 'NotoNastaliqUrdu' : 'Inter',
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 1),
              //const Divider(color: Colors.white24),

              // Categories
              Consumer<CategoryProvider>(
                builder: (context, provider, _) {
                  if (provider.isLoading) {
                    return const Padding(
                      padding: EdgeInsets.all(16),
                      child: Center(child: CircularProgressIndicator(color: Colors.white)),
                    );
                  }

                  return Column(
                    children: provider.categories.map((category) {
                      final name = isUrdu ? category.urduName : category.name;
                      final categoryIcon = Text(
                        category.icon,
                        style: const TextStyle(fontSize: 24, color: Colors.white),
                      );

                      return _SidebarItem(
                        icon: categoryIcon,
                        label: name,
                        isUrdu: isUrdu,
                        onTap: () {
                          provider.selectCategory(category);
                          Navigator.pop(context); // close drawer first
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => CategoryScreen(category: category),
                            ),
                          );
                        },
                      );
                    }).toList(),
                  );
                },
              ),

              const SizedBox(height: 4),
              const Divider(color: Colors.white24),

              // AI Tools
              _SidebarItem(
                icon: const Icon(Icons.offline_bolt, color: Colors.white),
                label: t('AI Sentence Builder (Offline)', 'اے آئی جملہ ساز (آف لائن)'),
                isUrdu: isUrdu,
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const AISentenceBuilderOfflineScreen(),
                    ),
                  );
                },
              ),
              Consumer<ConnectivityProvider>(
                builder: (context, connectivity, _) {
                  return _SidebarItem(
                    icon: Icon(
                      connectivity.isOnline
                          ? Icons.online_prediction
                          : Icons.cloud_off,
                      color: connectivity.isOnline ? Colors.green : Colors.grey,
                    ),
                    label: t('AI Sentence Builder (Online)', 'اے آئی جملہ ساز (آن لائن)'),
                    isUrdu: isUrdu,
                    enabled: connectivity.isOnline,
                    onTap: connectivity.isOnline
                        ? () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const AISentenceBuilderOnlineScreen(),
                        ),
                      );
                    }
                        : null,
                  );
                },
              ),

              const SizedBox(height: 1),
              const Divider(color: Colors.white24),

              // Profile & Settings
              _SidebarItem(
                icon: const Icon(Icons.person, color: Colors.white),
                label: t('Profile', 'پروفائل'),
                isUrdu: isUrdu,
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const ProfileScreen()),
                  );
                },
              ),
              _SidebarItem(
                icon: const Icon(Icons.settings, color: Colors.white),
                label: t('Settings', 'ترتیبات'),
                isUrdu: isUrdu,
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const SettingsScreen()),
                  );
                },
              ),

              const SizedBox(height: 1),
              const Divider(color: Colors.white24),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}

// -----------------------------
// Sidebar Item with hover animation
// -----------------------------
class _SidebarItem extends StatefulWidget {
  final Widget icon;
  final String label;
  final bool isUrdu;
  final VoidCallback? onTap;
  final bool enabled;

  const _SidebarItem({
    required this.icon,
    required this.label,
    required this.isUrdu,
    this.onTap,
    this.enabled = true,
  });

  @override
  State<_SidebarItem> createState() => _SidebarItemState();
}

class _SidebarItemState extends State<_SidebarItem> {
  bool _hovering = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovering = true),
      onExit: (_) => setState(() => _hovering = false),
      cursor: widget.enabled ? SystemMouseCursors.click : SystemMouseCursors.basic,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        decoration: BoxDecoration(
          color: _hovering ? Colors.white24 : Colors.transparent, // hover color
          borderRadius: BorderRadius.circular(8),
        ),
        margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: ListTile(
          enabled: widget.enabled,
          leading: widget.isUrdu ? null : widget.icon,
          trailing: widget.isUrdu ? widget.icon : null,
          title: AnimatedDefaultTextStyle(
            duration: const Duration(milliseconds: 200),
            style: TextStyle(
              color: widget.enabled ? Colors.white : Colors.white38,
              fontFamily: widget.isUrdu ? 'NotoNastaliqUrdu' : 'Inter',
              fontWeight: FontWeight.w600,
            ),
            child: Text(
              widget.label,
              textAlign: widget.isUrdu ? TextAlign.right : TextAlign.left,
            ),
          ),
          onTap: widget.enabled ? widget.onTap : null,
        ),
      ),
    );
  }
}

// -----------------------------
// Hover Avatar for Header
// -----------------------------
class _HoverAvatar extends StatefulWidget {
  const _HoverAvatar({super.key});

  @override
  State<_HoverAvatar> createState() => _HoverAvatarState();
}

class _HoverAvatarState extends State<_HoverAvatar> {
  bool _hovering = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovering = true),
      onExit: (_) => setState(() => _hovering = false),
      child: AnimatedScale(
        duration: const Duration(milliseconds: 200),
        scale: _hovering ? 1.05 : 1.0,
        child: const CircleAvatar(
          radius: 36,
          backgroundColor: Colors.white24,
          child: Icon(Icons.person, size: 36, color: Colors.white),
        ),
      ),
    );
  }
}
