import 'package:uuid/uuid.dart';

const _uuid = Uuid();

class Exam {
  final String id;
  final String name;
  final String code;
  final String category;
  final String? description;
  final bool isActive;
  final DateTime? nextExamDate;
  final DateTime createdAt;

  Exam({
    String? id,
    required this.name,
    required this.code,
    required this.category,
    this.description,
    this.isActive = true,
    this.nextExamDate,
    DateTime? createdAt,
  })  : id = id ?? _uuid.v4(),
        createdAt = createdAt ?? DateTime.now();

  factory Exam.fromJson(Map<String, dynamic> json) {
    return Exam(
      id: json['id'],
      name: json['name'],
      code: json['code'],
      category: json['category'],
      description: json['description'],
      isActive: json['is_active'] ?? true,
      nextExamDate: json['next_exam_date'] != null
          ? DateTime.parse(json['next_exam_date'])
          : null,
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'code': code,
        'category': category,
        'description': description,
        'is_active': isActive,
        'next_exam_date': nextExamDate?.toIso8601String(),
        'created_at': createdAt.toIso8601String(),
      };
}

class Subject {
  final String id;
  final String examId;
  final String name;
  final String? code;
  final int displayOrder;
  final DateTime createdAt;

  Subject({
    String? id,
    required this.examId,
    required this.name,
    this.code,
    this.displayOrder = 0,
    DateTime? createdAt,
  })  : id = id ?? _uuid.v4(),
        createdAt = createdAt ?? DateTime.now();

  factory Subject.fromJson(Map<String, dynamic> json) {
    return Subject(
      id: json['id'],
      examId: json['exam_id'],
      name: json['name'],
      code: json['code'],
      displayOrder: json['display_order'] ?? 0,
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'exam_id': examId,
        'name': name,
        'code': code,
        'display_order': displayOrder,
        'created_at': createdAt.toIso8601String(),
      };
}

class Module {
  final String id;
  final String subjectId;
  final String name;
  final String? description;
  final int displayOrder;
  final DateTime createdAt;

  Module({
    String? id,
    required this.subjectId,
    required this.name,
    this.description,
    this.displayOrder = 0,
    DateTime? createdAt,
  })  : id = id ?? _uuid.v4(),
        createdAt = createdAt ?? DateTime.now();

  factory Module.fromJson(Map<String, dynamic> json) {
    return Module(
      id: json['id'],
      subjectId: json['subject_id'],
      name: json['name'],
      description: json['description'],
      displayOrder: json['display_order'] ?? 0,
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'subject_id': subjectId,
        'name': name,
        'description': description,
        'display_order': displayOrder,
        'created_at': createdAt.toIso8601String(),
      };
}

class Chapter {
  final String id;
  final String moduleId;
  final String name;
  final String? description;
  final int displayOrder;
  final DateTime createdAt;

  Chapter({
    String? id,
    required this.moduleId,
    required this.name,
    this.description,
    this.displayOrder = 0,
    DateTime? createdAt,
  })  : id = id ?? _uuid.v4(),
        createdAt = createdAt ?? DateTime.now();

  factory Chapter.fromJson(Map<String, dynamic> json) {
    return Chapter(
      id: json['id'],
      moduleId: json['module_id'],
      name: json['name'],
      description: json['description'],
      displayOrder: json['display_order'] ?? 0,
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'module_id': moduleId,
        'name': name,
        'description': description,
        'display_order': displayOrder,
        'created_at': createdAt.toIso8601String(),
      };
}

class Topic {
  final String id;
  final String chapterId;
  final String name;
  final String? description;
  final String difficulty;
  final int displayOrder;
  final DateTime createdAt;

  Topic({
    String? id,
    required this.chapterId,
    required this.name,
    this.description,
    this.difficulty = 'medium',
    this.displayOrder = 0,
    DateTime? createdAt,
  })  : id = id ?? _uuid.v4(),
        createdAt = createdAt ?? DateTime.now();

  factory Topic.fromJson(Map<String, dynamic> json) {
    return Topic(
      id: json['id'],
      chapterId: json['chapter_id'],
      name: json['name'],
      description: json['description'],
      difficulty: json['difficulty'] ?? 'medium',
      displayOrder: json['display_order'] ?? 0,
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'chapter_id': chapterId,
        'name': name,
        'description': description,
        'difficulty': difficulty,
        'display_order': displayOrder,
        'created_at': createdAt.toIso8601String(),
      };
}

enum TopicStatus { notStarted, inProgress, mastered }

TopicStatus topicStatusFromString(String status) {
  switch (status) {
    case 'in_progress':
      return TopicStatus.inProgress;
    case 'mastered':
      return TopicStatus.mastered;
    default:
      return TopicStatus.notStarted;
  }
}

String topicStatusToString(TopicStatus status) {
  switch (status) {
    case TopicStatus.notStarted:
      return 'not_started';
    case TopicStatus.inProgress:
      return 'in_progress';
    case TopicStatus.mastered:
      return 'mastered';
  }
}

class UserTopicProgress {
  final String id;
  final String userId;
  final String topicId;
  final TopicStatus status;
  final DateTime? startedAt;
  final DateTime? masteredAt;
  final DateTime updatedAt;

  UserTopicProgress({
    String? id,
    required this.userId,
    required this.topicId,
    this.status = TopicStatus.notStarted,
    this.startedAt,
    this.masteredAt,
    DateTime? updatedAt,
  })  : id = id ?? _uuid.v4(),
        updatedAt = updatedAt ?? DateTime.now();

  factory UserTopicProgress.fromJson(Map<String, dynamic> json) {
    return UserTopicProgress(
      id: json['id'],
      userId: json['user_id'],
      topicId: json['topic_id'],
      status: topicStatusFromString(json['status'] ?? 'not_started'),
      startedAt: json['started_at'] != null
          ? DateTime.parse(json['started_at'])
          : null,
      masteredAt: json['mastered_at'] != null
          ? DateTime.parse(json['mastered_at'])
          : null,
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'user_id': userId,
        'topic_id': topicId,
        'status': topicStatusToString(status),
        'started_at': startedAt?.toIso8601String(),
        'mastered_at': masteredAt?.toIso8601String(),
        'updated_at': updatedAt.toIso8601String(),
      };

  UserTopicProgress copyWith({TopicStatus? status}) {
    final now = DateTime.now();
    return UserTopicProgress(
      id: id,
      userId: userId,
      topicId: topicId,
      status: status ?? this.status,
      startedAt: status == TopicStatus.inProgress ? now : startedAt,
      masteredAt: status == TopicStatus.mastered ? now : masteredAt,
      updatedAt: now,
    );
  }
}
