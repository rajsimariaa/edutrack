import 'package:uuid/uuid.dart';

const _uuid = Uuid();

class PomodoroSession {
  final String id;
  final String userId;
  final String? topicId;
  final String? chapterId;
  final int durationMins;
  final DateTime startedAt;
  final DateTime? endedAt;
  final String status;
  final DateTime createdAt;

  PomodoroSession({
    String? id,
    required this.userId,
    this.topicId,
    this.chapterId,
    this.durationMins = 25,
    DateTime? startedAt,
    this.endedAt,
    this.status = 'running',
    DateTime? createdAt,
  })  : id = id ?? _uuid.v4(),
        startedAt = startedAt ?? DateTime.now(),
        createdAt = createdAt ?? DateTime.now();

  factory PomodoroSession.fromJson(Map<String, dynamic> json) {
    return PomodoroSession(
      id: json['id'],
      userId: json['user_id'],
      topicId: json['topic_id'],
      chapterId: json['chapter_id'],
      durationMins: json['duration_mins'] ?? 25,
      startedAt: DateTime.parse(json['started_at']),
      endedAt: json['ended_at'] != null ? DateTime.parse(json['ended_at']) : null,
      status: json['status'] ?? 'running',
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'user_id': userId,
        'topic_id': topicId,
        'chapter_id': chapterId,
        'duration_mins': durationMins,
        'started_at': startedAt.toIso8601String(),
        'ended_at': endedAt?.toIso8601String(),
        'status': status,
        'created_at': createdAt.toIso8601String(),
      };
}

class Note {
  final String id;
  final String userId;
  final String chapterId;
  final String? topicId;
  final String? title;
  final String contentMd;
  final bool isPinned;
  final DateTime createdAt;
  final DateTime updatedAt;

  Note({
    String? id,
    required this.userId,
    required this.chapterId,
    this.topicId,
    this.title,
    this.contentMd = '',
    this.isPinned = false,
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : id = id ?? _uuid.v4(),
        createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  factory Note.fromJson(Map<String, dynamic> json) {
    return Note(
      id: json['id'],
      userId: json['user_id'],
      chapterId: json['chapter_id'],
      topicId: json['topic_id'],
      title: json['title'],
      contentMd: json['content_md'] ?? '',
      isPinned: json['is_pinned'] ?? false,
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'user_id': userId,
        'chapter_id': chapterId,
        'topic_id': topicId,
        'title': title,
        'content_md': contentMd,
        'is_pinned': isPinned,
        'created_at': createdAt.toIso8601String(),
        'updated_at': updatedAt.toIso8601String(),
      };
}

class Habit {
  final String id;
  final String userId;
  final String name;
  final String frequency;
  final int targetCount;
  final bool isActive;
  final DateTime createdAt;

  Habit({
    String? id,
    required this.userId,
    required this.name,
    this.frequency = 'daily',
    this.targetCount = 1,
    this.isActive = true,
    DateTime? createdAt,
  })  : id = id ?? _uuid.v4(),
        createdAt = createdAt ?? DateTime.now();

  factory Habit.fromJson(Map<String, dynamic> json) {
    return Habit(
      id: json['id'],
      userId: json['user_id'],
      name: json['name'],
      frequency: json['frequency'] ?? 'daily',
      targetCount: json['target_count'] ?? 1,
      isActive: json['is_active'] ?? true,
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'user_id': userId,
        'name': name,
        'frequency': frequency,
        'target_count': targetCount,
        'is_active': isActive,
        'created_at': createdAt.toIso8601String(),
      };
}

class HabitEntry {
  final String id;
  final String habitId;
  final DateTime checkinDate;
  final int count;
  final String? note;
  final DateTime createdAt;

  HabitEntry({
    String? id,
    required this.habitId,
    required this.checkinDate,
    this.count = 1,
    this.note,
    DateTime? createdAt,
  })  : id = id ?? _uuid.v4(),
        createdAt = createdAt ?? DateTime.now();

  factory HabitEntry.fromJson(Map<String, dynamic> json) {
    return HabitEntry(
      id: json['id'],
      habitId: json['habit_id'],
      checkinDate: DateTime.parse(json['checkin_date']),
      count: json['count'] ?? 1,
      note: json['note'],
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'habit_id': habitId,
        'checkin_date': checkinDate.toIso8601String().split('T')[0],
        'count': count,
        'note': note,
        'created_at': createdAt.toIso8601String(),
      };
}

class ProgressCard {
  final String id;
  final String userId;
  final String cardType;
  final Map<String, dynamic> payloadJson;
  final String? imageUrl;
  final DateTime? sharedAt;
  final DateTime createdAt;

  ProgressCard({
    String? id,
    required this.userId,
    this.cardType = 'weekly',
    required this.payloadJson,
    this.imageUrl,
    this.sharedAt,
    DateTime? createdAt,
  })  : id = id ?? _uuid.v4(),
        createdAt = createdAt ?? DateTime.now();

  factory ProgressCard.fromJson(Map<String, dynamic> json) {
    return ProgressCard(
      id: json['id'],
      userId: json['user_id'],
      cardType: json['card_type'] ?? 'weekly',
      payloadJson: json['payload_json'] ?? {},
      imageUrl: json['image_url'],
      sharedAt: json['shared_at'] != null ? DateTime.parse(json['shared_at']) : null,
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'user_id': userId,
        'card_type': cardType,
        'payload_json': payloadJson,
        'image_url': imageUrl,
        'shared_at': sharedAt?.toIso8601String(),
        'created_at': createdAt.toIso8601String(),
      };
}
