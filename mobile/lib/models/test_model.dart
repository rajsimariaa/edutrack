import 'package:uuid/uuid.dart';

const _uuid = Uuid();

class Test {
  final String id;
  final String examId;
  final String title;
  final String? description;
  final int totalMarks;
  final int durationMins;
  final Map<String, dynamic>? markingScheme;
  final int? weekNumber;
  final int? year;
  final bool isPublished;
  final DateTime createdAt;

  Test({
    String? id,
    required this.examId,
    required this.title,
    this.description,
    required this.totalMarks,
    required this.durationMins,
    this.markingScheme,
    this.weekNumber,
    this.year,
    this.isPublished = false,
    DateTime? createdAt,
  })  : id = id ?? _uuid.v4(),
        createdAt = createdAt ?? DateTime.now();

  factory Test.fromJson(Map<String, dynamic> json) {
    return Test(
      id: json['id'],
      examId: json['exam_id'],
      title: json['title'],
      description: json['description'],
      totalMarks: json['total_marks'],
      durationMins: json['duration_mins'],
      markingScheme: json['marking_scheme'],
      weekNumber: json['week_number'],
      year: json['year'],
      isPublished: json['is_published'] ?? false,
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'exam_id': examId,
        'title': title,
        'description': description,
        'total_marks': totalMarks,
        'duration_mins': durationMins,
        'marking_scheme': markingScheme,
        'week_number': weekNumber,
        'year': year,
        'is_published': isPublished,
        'created_at': createdAt.toIso8601String(),
      };
}

class TestQuestion {
  final String id;
  final String testId;
  final String? topicId;
  final String questionText;
  final String questionType;
  final Map<String, dynamic> options;
  final String correctOption;
  final double marks;
  final String? explanation;
  final int displayOrder;

  TestQuestion({
    String? id,
    required this.testId,
    this.topicId,
    required this.questionText,
    this.questionType = 'mcq',
    required this.options,
    required this.correctOption,
    required this.marks,
    this.explanation,
    this.displayOrder = 0,
  }) : id = id ?? _uuid.v4();

  factory TestQuestion.fromJson(Map<String, dynamic> json) {
    final rawOptions = json['options'];
    Map<String, dynamic> parsedOptions;
    if (rawOptions is Map) {
      parsedOptions = Map<String, dynamic>.from(rawOptions);
    } else if (rawOptions is List) {
      parsedOptions = {};
      for (var i = 0; i < rawOptions.length; i++) {
        final opt = rawOptions[i];
        final key = String.fromCharCode(65 + i);
        if (opt is Map) {
          parsedOptions[key] = opt['text'] ?? opt[key] ?? opt.toString();
        } else {
          parsedOptions[key] = opt.toString();
        }
      }
    } else {
      parsedOptions = {};
    }

    return TestQuestion(
      id: json['id'],
      testId: json['test_id'],
      topicId: json['topic_id'],
      questionText: json['question_text'],
      questionType: json['question_type'] ?? 'mcq',
      options: parsedOptions,
      correctOption: json['correct_option'],
      marks: (json['marks'] as num).toDouble(),
      explanation: json['explanation'],
      displayOrder: json['display_order'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'test_id': testId,
        'topic_id': topicId,
        'question_text': questionText,
        'question_type': questionType,
        'options': options,
        'correct_option': correctOption,
        'marks': marks,
        'explanation': explanation,
        'display_order': displayOrder,
      };
}

class UserTestSubmission {
  final String id;
  final String userId;
  final String testId;
  final double? score;
  final double? percentile;
  final int? rankInCategory;
  final int? totalCorrect;
  final int? totalWrong;
  final int? totalUnattempted;
  final int? timeTakenMins;
  final DateTime submittedAt;

  UserTestSubmission({
    String? id,
    required this.userId,
    required this.testId,
    this.score,
    this.percentile,
    this.rankInCategory,
    this.totalCorrect,
    this.totalWrong,
    this.totalUnattempted,
    this.timeTakenMins,
    DateTime? submittedAt,
  })  : id = id ?? _uuid.v4(),
        submittedAt = submittedAt ?? DateTime.now();

  factory UserTestSubmission.fromJson(Map<String, dynamic> json) {
    return UserTestSubmission(
      id: json['id'],
      userId: json['user_id'],
      testId: json['test_id'],
      score: (json['score'] as num?)?.toDouble(),
      percentile: (json['percentile'] as num?)?.toDouble(),
      rankInCategory: json['rank_in_category'],
      totalCorrect: json['total_correct'],
      totalWrong: json['total_wrong'],
      totalUnattempted: json['total_unattempted'],
      timeTakenMins: json['time_taken_mins'],
      submittedAt: DateTime.parse(json['submitted_at']),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'user_id': userId,
        'test_id': testId,
        'score': score,
        'percentile': percentile,
        'rank_in_category': rankInCategory,
        'total_correct': totalCorrect,
        'total_wrong': totalWrong,
        'total_unattempted': totalUnattempted,
        'time_taken_mins': timeTakenMins,
        'submitted_at': submittedAt.toIso8601String(),
      };
}
