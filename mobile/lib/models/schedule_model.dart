import 'package:uuid/uuid.dart';

const _uuid = Uuid();

class Schedule {
  final String id;
  final String userId;
  final String? title;
  final DateTime startDate;
  final DateTime endDate;
  final bool isActive;
  final bool aiGenerated;
  final DateTime createdAt;

  Schedule({
    String? id,
    required this.userId,
    this.title,
    required this.startDate,
    required this.endDate,
    this.isActive = true,
    this.aiGenerated = true,
    DateTime? createdAt,
  })  : id = id ?? _uuid.v4(),
        createdAt = createdAt ?? DateTime.now();

  factory Schedule.fromJson(Map<String, dynamic> json) {
    return Schedule(
      id: json['id'],
      userId: json['user_id'],
      title: json['title'],
      startDate: DateTime.parse(json['start_date']),
      endDate: DateTime.parse(json['end_date']),
      isActive: json['is_active'] ?? true,
      aiGenerated: json['ai_generated'] ?? true,
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'user_id': userId,
        'title': title,
        'start_date': startDate.toIso8601String().split('T')[0],
        'end_date': endDate.toIso8601String().split('T')[0],
        'is_active': isActive,
        'ai_generated': aiGenerated,
        'created_at': createdAt.toIso8601String(),
      };
}

enum ScheduleItemStatus { pending, completed, missed, rescheduled }

ScheduleItemStatus scheduleItemStatusFromString(String status) {
  switch (status) {
    case 'completed':
      return ScheduleItemStatus.completed;
    case 'missed':
      return ScheduleItemStatus.missed;
    case 'rescheduled':
      return ScheduleItemStatus.rescheduled;
    default:
      return ScheduleItemStatus.pending;
  }
}

String scheduleItemStatusToString(ScheduleItemStatus status) {
  switch (status) {
    case ScheduleItemStatus.pending:
      return 'pending';
    case ScheduleItemStatus.completed:
      return 'completed';
    case ScheduleItemStatus.missed:
      return 'missed';
    case ScheduleItemStatus.rescheduled:
      return 'rescheduled';
  }
}

class ScheduleItem {
  final String id;
  final String scheduleId;
  final String? topicId;
  final String title;
  final DateTime scheduledDate;
  final String? startTime;
  final String? endTime;
  final ScheduleItemStatus status;
  final DateTime? originalDate;
  final int priority;
  final DateTime createdAt;

  ScheduleItem({
    String? id,
    required this.scheduleId,
    this.topicId,
    required this.title,
    required this.scheduledDate,
    this.startTime,
    this.endTime,
    this.status = ScheduleItemStatus.pending,
    this.originalDate,
    this.priority = 1,
    DateTime? createdAt,
  })  : id = id ?? _uuid.v4(),
        createdAt = createdAt ?? DateTime.now();

  factory ScheduleItem.fromJson(Map<String, dynamic> json) {
    return ScheduleItem(
      id: json['id'],
      scheduleId: json['schedule_id'],
      topicId: json['topic_id'],
      title: json['title'],
      scheduledDate: DateTime.parse(json['scheduled_date']),
      startTime: json['start_time'],
      endTime: json['end_time'],
      status: scheduleItemStatusFromString(json['status'] ?? 'pending'),
      originalDate: json['original_date'] != null
          ? DateTime.parse(json['original_date'])
          : null,
      priority: json['priority'] ?? 1,
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'schedule_id': scheduleId,
        'topic_id': topicId,
        'title': title,
        'scheduled_date': scheduledDate.toIso8601String().split('T')[0],
        'start_time': startTime,
        'end_time': endTime,
        'status': scheduleItemStatusToString(status),
        'original_date': originalDate?.toIso8601String().split('T')[0],
        'priority': priority,
        'created_at': createdAt.toIso8601String(),
      };
}
