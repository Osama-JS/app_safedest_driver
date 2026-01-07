import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/notification.dart';

class NotificationDatabase {
  static final NotificationDatabase _instance = NotificationDatabase._internal();
  static Database? _database;

  factory NotificationDatabase() {
    return _instance;
  }

  NotificationDatabase._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'notifications.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDb,
    );
  }

  Future<void> _createDb(Database db, int version) async {
    await db.execute('''
      CREATE TABLE notifications (
        id TEXT PRIMARY KEY,
        user_id INTEGER NOT NULL,
        type TEXT,
        title TEXT,
        body TEXT,
        data TEXT,
        is_read INTEGER DEFAULT 0,
        read_at TEXT,
        created_at TEXT,
        received_at TEXT
      )
    ''');

    // Index for faster queries by user_id
    await db.execute('CREATE INDEX idx_user_id ON notifications(user_id)');
  }

  // Insert a notification
  Future<void> insertNotification(AppNotification notification, int userId) async {
    final db = await database;
    await db.insert(
      'notifications',
      notification.toMap(userId),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // Get notifications for a specific user
  Future<List<AppNotification>> getNotifications(int userId, {int limit = 50, int offset = 0}) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'notifications',
      where: 'user_id = ?',
      whereArgs: [userId],
      orderBy: 'received_at DESC', // Order by receipt time
      limit: limit,
      offset: offset,
    );

    return List.generate(maps.length, (i) {
      return AppNotification.fromMap(maps[i]);
    });
  }

  // Mark notification as read
  Future<void> markAsRead(String id, int userId) async {
    final db = await database;
    await db.update(
      'notifications',
      {
        'is_read': 1,
        'read_at': DateTime.now().toIso8601String(),
      },
      where: 'id = ? AND user_id = ?',
      whereArgs: [id, userId],
    );
  }

  // Mark all notifications as read for a user
  Future<void> markAllAsRead(int userId) async {
    final db = await database;
    await db.update(
      'notifications',
      {
        'is_read': 1,
        'read_at': DateTime.now().toIso8601String(),
      },
      where: 'user_id = ? AND is_read = 0',
      whereArgs: [userId],
    );
  }

  // Get unread count for a user
  Future<int> getUnreadCount(int userId) async {
    final db = await database;
    final result = await db.rawQuery(
      'SELECT COUNT(*) as count FROM notifications WHERE user_id = ? AND is_read = 0',
      [userId],
    );
    return Sqflite.firstIntValue(result) ?? 0;
  }

  // Delete all notifications for a user (e.g. on account deletion, not logout)
  Future<void> deleteNotificationsByUser(int userId) async {
    final db = await database;
    await db.delete(
      'notifications',
      where: 'user_id = ?',
      whereArgs: [userId],
    );
  }

  // Clean up old notifications (optional maintenance)
  Future<void> clearOldNotifications(int userId, {int daysToKeep = 30}) async {
    final db = await database;
    final dateThreshold = DateTime.now().subtract(Duration(days: daysToKeep)).toIso8601String();

    await db.delete(
      'notifications',
      where: 'user_id = ? AND received_at < ?',
      whereArgs: [userId, dateThreshold],
    );
  }
}
