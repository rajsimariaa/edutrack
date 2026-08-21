import 'package:uuid/uuid.dart';

const _uuid = Uuid();

class User {
  final String id;
  final String email;
  final String? phone;
  final String fullName;
  final String? avatarUrl;
  final bool isVerified;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  User({
    String? id,
    required this.email,
    this.phone,
    required this.fullName,
    this.avatarUrl,
    this.isVerified = false,
    this.isActive = true,
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : id = id ?? _uuid.v4(),
        createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      email: json['email'],
      phone: json['phone'],
      fullName: json['full_name'],
      avatarUrl: json['avatar_url'],
      isVerified: json['is_verified'] ?? false,
      isActive: json['is_active'] ?? true,
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'phone': phone,
      'full_name': fullName,
      'avatar_url': avatarUrl,
      'is_verified': isVerified,
      'is_active': isActive,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  User copyWith({
    String? email,
    String? phone,
    String? fullName,
    String? avatarUrl,
    bool? isVerified,
    bool? isActive,
  }) {
    return User(
      id: id,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      fullName: fullName ?? this.fullName,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      isVerified: isVerified ?? this.isVerified,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
    );
  }
}

class UserProfile {
  final String id;
  final String userId;
  final DateTime? dateOfBirth;
  final String? city;
  final String? institution;
  final String examCategory;
  final int? targetYear;
  final double? dailyStudyHrs;
  final String? preferredStart;
  final bool socialVisibility;
  final int onboardingStep;
  final double profilePct;
  final DateTime createdAt;
  final DateTime updatedAt;

  UserProfile({
    String? id,
    required this.userId,
    this.dateOfBirth,
    this.city,
    this.institution,
    required this.examCategory,
    this.targetYear,
    this.dailyStudyHrs,
    this.preferredStart,
    this.socialVisibility = true,
    this.onboardingStep = 0,
    this.profilePct = 0.0,
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : id = id ?? _uuid.v4(),
        createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['id'],
      userId: json['user_id'],
      dateOfBirth: json['date_of_birth'] != null
          ? DateTime.parse(json['date_of_birth'])
          : null,
      city: json['city'],
      institution: json['institution'],
      examCategory: json['exam_category'],
      targetYear: json['target_year'],
      dailyStudyHrs: (json['daily_study_hrs'] as num?)?.toDouble(),
      preferredStart: json['preferred_start'],
      socialVisibility: json['social_visibility'] ?? true,
      onboardingStep: json['onboarding_step'] ?? 0,
      profilePct: (json['profile_pct'] as num?)?.toDouble() ?? 0.0,
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'date_of_birth': dateOfBirth?.toIso8601String().split('T')[0],
      'city': city,
      'institution': institution,
      'exam_category': examCategory,
      'target_year': targetYear,
      'daily_study_hrs': dailyStudyHrs,
      'preferred_start': preferredStart,
      'social_visibility': socialVisibility,
      'onboarding_step': onboardingStep,
      'profile_pct': profilePct,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  double get profileCompletion {
    double pct = 0;
    if (dateOfBirth != null) pct += 20;
    if (examCategory.isNotEmpty) pct += 30;
    if (dailyStudyHrs != null) pct += 25;
    if (socialVisibility) pct += 25;
    return pct;
  }
}
