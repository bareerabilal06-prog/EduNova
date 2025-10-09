import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/category.dart';
import '../models/phrase.dart';
import '../models/profile.dart';

class DatabaseService {
  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'edunova.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    // Create profile table
    await db.execute('''
      CREATE TABLE profile (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        gender TEXT NOT NULL,
        age INTEGER NOT NULL,
        email TEXT
      )
    ''');

    // Create categories table
    await db.execute('''
      CREATE TABLE categories (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        icon TEXT NOT NULL
      )
    ''');

    // Create phrases table
    await db.execute('''
      CREATE TABLE phrases (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        category_id INTEGER NOT NULL,
        english_text TEXT NOT NULL,
        urdu_text TEXT NOT NULL,
        emoji TEXT NOT NULL,
        is_favorite INTEGER DEFAULT 0,
        FOREIGN KEY (category_id) REFERENCES categories (id)
      )
    ''');

    await _seedData(db);
  }

  Future<void> _seedData(Database db) async {
    // Seed Categories
    const categories = [
      {'name': 'Questions', 'icon': '❓'},
      {'name': 'Answers', 'icon': '✅'},
      {'name': 'Emotions', 'icon': '😊'},
      {'name': 'Needs', 'icon': '🧩'},
      {'name': 'Actions', 'icon': '⚡'},
      {'name': 'Favorites', 'icon': '⭐'},
    ];

    for (var cat in categories) {
      await db.insert('categories', cat);
    }

    // Seed Phrases
    const phrases = [
      {
        'category_id': 1,
        'english_text': 'Can I go to the bathroom?',
        'urdu_text': 'کیا میں باتھ روم جا سکتا ہوں؟',
        'emoji': '🚻',
      },
      {
        'category_id': 1,
        'english_text': 'May I ask a question?',
        'urdu_text': 'کیا میں سوال پوچھ سکتا ہوں؟',
        'emoji': '🙋',
      },
      {
        'category_id': 2,
        'english_text': 'Yes, I understand',
        'urdu_text': 'جی ہاں، میں سمجھ گیا',
        'emoji': '👍',
      },
      {
        'category_id': 3,
        'english_text': 'I am happy',
        'urdu_text': 'میں خوش ہوں',
        'emoji': '😊',
      },
      {
        'category_id': 4,
        'english_text': 'I need help',
        'urdu_text': 'مجھے مدد چاہیے',
        'emoji': '🆘',
      },
    ];

    for (var phrase in phrases) {
      await db.insert('phrases', phrase);
    }
  }

  // ---------------- Profile CRUD ----------------

  Future<int> insertProfile(Profile profile) async {
    final db = await database;

    // Ensure only one profile record exists (overwrite existing)
    await db.delete('profile');
    return await db.insert('profile', profile.toMap());
  }

  Future<Profile?> getProfile() async {
    final db = await database;
    final result = await db.query('profile', limit: 1);
    if (result.isEmpty) return null;
    return Profile.fromMap(result.first);
  }

  Future<int> updateProfile(Profile profile) async {
    final db = await database;
    if (profile.id == null) {
      // If somehow profile has no ID, just replace existing
      await db.delete('profile');
      return await db.insert('profile', profile.toMap());
    }
    return await db.update(
      'profile',
      profile.toMap(),
      where: 'id = ?',
      whereArgs: [profile.id],
    );
  }

  // ---------------- Category CRUD ----------------

  Future<List<Category>> getCategories() async {
    final db = await database;
    final maps = await db.query('categories');
    return maps.map((e) => Category.fromMap(e)).toList();
  }

  // ---------------- Phrase CRUD ----------------

  Future<List<Phrase>> getPhrasesByCategory(int categoryId) async {
    final db = await database;
    final maps = await db.query(
      'phrases',
      where: 'category_id = ?',
      whereArgs: [categoryId],
    );
    return maps.map((e) => Phrase.fromMap(e)).toList();
  }

  Future<List<Phrase>> getFavoritePhrases() async {
    final db = await database;
    final maps = await db.query(
      'phrases',
      where: 'is_favorite = ?',
      whereArgs: [1],
    );
    return maps.map((e) => Phrase.fromMap(e)).toList();
  }

  Future<int> toggleFavorite(int phraseId, bool isFavorite) async {
    final db = await database;
    return await db.update(
      'phrases',
      {'is_favorite': isFavorite ? 1 : 0},
      where: 'id = ?',
      whereArgs: [phraseId],
    );
  }

  // ---------------- Utility ----------------

  Future<void> clearAllData() async {
    final db = await database;
    await db.delete('profile');
    await db.delete('phrases');
    await db.delete('categories');
    await _seedData(db);
  }
}
