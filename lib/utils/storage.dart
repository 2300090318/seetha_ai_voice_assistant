import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class Storage {
  static Database? _db;

  static Future<void> init() async {
    final dbPath = await getDatabasesPath();
    _db = await openDatabase(
      join(dbPath, 'seetha.db'),
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE conversations (
            id          INTEGER PRIMARY KEY AUTOINCREMENT,
            user_msg    TEXT NOT NULL,
            seetha_msg  TEXT NOT NULL,
            tool_used   TEXT,
            timestamp   TEXT NOT NULL
          )
        ''');
        await db.execute('''
          CREATE TABLE edit_history (
            id          INTEGER PRIMARY KEY AUTOINCREMENT,
            file_path   TEXT NOT NULL,
            edit_type   TEXT NOT NULL,
            operation   TEXT NOT NULL,
            timestamp   TEXT NOT NULL
          )
        ''');
      },
    );
  }

  static Database get db {
    if (_db == null) throw Exception('Database not initialized');
    return _db!;
  }

  // ─── Conversations ──────────────────────────────────────────────────────────
  static Future<int> insertConversation({
    required String userMsg,
    required String seethaMsg,
    String? toolUsed,
  }) async {
    return await db.insert('conversations', {
      'user_msg': userMsg,
      'seetha_msg': seethaMsg,
      'tool_used': toolUsed,
      'timestamp': DateTime.now().toIso8601String(),
    });
  }

  static Future<List<Map<String, dynamic>>> getAllConversations() async {
    return await db.query('conversations', orderBy: 'id DESC');
  }

  static Future<void> deleteConversation(int id) async {
    await db.delete('conversations', where: 'id = ?', whereArgs: [id]);
  }

  static Future<void> clearAllConversations() async {
    await db.delete('conversations');
  }

  // ─── Edit History ───────────────────────────────────────────────────────────
  static Future<void> insertEditHistory({
    required String filePath,
    required String editType,
    required String operation,
  }) async {
    await db.insert('edit_history', {
      'file_path': filePath,
      'edit_type': editType,
      'operation': operation,
      'timestamp': DateTime.now().toIso8601String(),
    });
  }

  static Future<void> clearEditHistory() async {
    await db.delete('edit_history');
  }
}
