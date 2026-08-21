import 'package:uuid/uuid.dart';

const _uuid = Uuid();

class HeatmapEntry {
  final String id;
  final String userId;
  final DateTime activityDate;
  final int tasksCompleted;
  final int focusMins;
  final int streakCount;
  final DateTime createdAt;

  HeatmapEntry({
    String? id,
    required this.userId,
    required this.activityDate,
    this.tasksCompleted = 0,
    this.focusMins = 0,
    this.streakCount = 0,
    DateTime? createdAt,
  })  : id = id ?? _uuid.v4(),
        createdAt = createdAt ?? DateTime.now();

  factory HeatmapEntry.fromJson(Map<String, dynamic> json) {
    return HeatmapEntry(
      id: json['id'],
      userId: json['user_id'],
      activityDate: DateTime.parse(json['activity_date']),
      tasksCompleted: json['tasks_completed'] ?? 0,
      focusMins: json['focus_mins'] ?? 0,
      streakCount: json['streak_count'] ?? 0,
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'user_id': userId,
        'activity_date': activityDate.toIso8601String().split('T')[0],
        'tasks_completed': tasksCompleted,
        'focus_mins': focusMins,
        'streak_count': streakCount,
        'created_at': createdAt.toIso8601String(),
      };
}

class Leaderboard {
  final String id;
  final String examCategory;
  final String boardType;
  final int? weekNumber;
  final int? year;
  final bool isActive;
  final DateTime createdAt;

  Leaderboard({
    String? id,
    required this.examCategory,
    required this.boardType,
    this.weekNumber,
    this.year,
    this.isActive = true,
    DateTime? createdAt,
  })  : id = id ?? _uuid.v4(),
        createdAt = createdAt ?? DateTime.now();

  factory Leaderboard.fromJson(Map<String, dynamic> json) {
    return Leaderboard(
      id: json['id'],
      examCategory: json['exam_category'],
      boardType: json['board_type'],
      weekNumber: json['week_number'],
      year: json['year'],
      isActive: json['is_active'] ?? true,
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'exam_category': examCategory,
        'board_type': boardType,
        'week_number': weekNumber,
        'year': year,
        'is_active': isActive,
        'created_at': createdAt.toIso8601String(),
      };
}

class PeerRoom {
  final String id;
  final String name;
  final String code;
  final String examCategory;
  final String createdBy;
  final int maxMembers;
  final bool isActive;
  final DateTime createdAt;

  PeerRoom({
    String? id,
    required this.name,
    required this.code,
    required this.examCategory,
    required this.createdBy,
    this.maxMembers = 10,
    this.isActive = true,
    DateTime? createdAt,
  })  : id = id ?? _uuid.v4(),
        createdAt = createdAt ?? DateTime.now();

  factory PeerRoom.fromJson(Map<String, dynamic> json) {
    return PeerRoom(
      id: json['id'],
      name: json['name'],
      code: json['code'],
      examCategory: json['exam_category'],
      createdBy: json['created_by'],
      maxMembers: json['max_members'] ?? 10,
      isActive: json['is_active'] ?? true,
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'code': code,
        'exam_category': examCategory,
        'created_by': createdBy,
        'max_members': maxMembers,
        'is_active': isActive,
        'created_at': createdAt.toIso8601String(),
      };
}
