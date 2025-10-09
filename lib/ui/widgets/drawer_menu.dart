import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/category_provider.dart';
import '../../providers/connectivity_provider.dart';
import '../screens/category_screen.dart';
import '../screens/profile_screen.dart';
import '../screens/settings_screen.dart';
import '../screens/ai_sentence_builder_screen.dart';

class DrawerMenu extends StatelessWidget {
  const DrawerMenu({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF1E88E5), Color(0xFF1565C0)],
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const CircleAvatar(
                  radius: 30,
                  backgroundColor: Colors.white24,
                  child: Icon(Icons.person, size: 30, color: Colors.white),
                ),
                const SizedBox(height: 10),
                const Text(
                  'EduNova',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Text(
                  'Voice for Every Student',
                  style: TextStyle(color: Colors.white70, fontSize: 14),
                ),
                const Spacer(),
                Row(
                  children: [
                    const Icon(Icons.wifi, color: Colors.white70, size: 16),
                    const SizedBox(width: 4),
                    Consumer<ConnectivityProvider>(
                      builder: (_, conn, __) => Text(
                        conn.isOnline ? 'Online' : 'Offline',
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // 🔹 Dynamic Category List
          Consumer<CategoryProvider>(
            builder: (context, provider, _) {
              if (provider.isLoading) {
                return const Center(
                  child: Padding(
                    padding: EdgeInsets.all(16.0),
                    child: CircularProgressIndicator(),
                  ),
                );
              }

              if (provider.categories.isEmpty) {
                return const ListTile(
                  leading: Icon(Icons.info_outline),
                  title: Text('No categories available'),
                );
              }

              return Column(
                children: provider.categories.map((category) {
                  return ListTile(
                    leading: Text(category.icon, style: const TextStyle(fontSize: 24)),
                    title: Text(category.name),
                    onTap: () {
                      provider.selectCategory(category);
                      Navigator.pop(context);
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

          const Divider(),

          // 🔹 AI Sentence Builder
          Consumer<ConnectivityProvider>(
            builder: (context, connectivity, _) {
              return ListTile(
                leading: const Icon(Icons.auto_awesome),
                title: const Text('AI Sentence Builder'),
                trailing: Icon(
                  connectivity.isOnline
                      ? Icons.online_prediction
                      : Icons.offline_bolt,
                  color: connectivity.isOnline ? Colors.green : Colors.grey,
                ),
                enabled: connectivity.isOnline,
                onTap: connectivity.isOnline
                    ? () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const AISentenceBuilderScreen(),
                    ),
                  );
                }
                    : null,
              );
            },
          ),

          // 🔹 Profile
          ListTile(
            leading: const Icon(Icons.person),
            title: const Text('Profile'),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ProfileScreen()),
              );
            },
          ),

          // 🔹 Settings
          ListTile(
            leading: const Icon(Icons.settings),
            title: const Text('Settings'),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const SettingsScreen()),
              );
            },
          ),
        ],
      ),
    );
  }
}
