import 'package:uuid/uuid.dart';

const _uuid = Uuid();

class Badge {
  final String id;
  final String name;
  final String slug;
  final String? description;
  final String? iconUrl;
  final String category;
  final String rarityTier;
  final Map<String, dynamic> criteriaJson;
  final int points;
  final bool isActive;
  final DateTime createdAt;

  Badge({
    String? id,
    required this.name,
    required this.slug,
    this.description,
    this.iconUrl,
    required this.category,
    this.rarityTier = 'common',
    required this.criteriaJson,
    this.points = 0,
    this.isActive = true,
    DateTime? createdAt,
  })  : id = id ?? _uuid.v4(),
        createdAt = createdAt ?? DateTime.now();

  factory Badge.fromJson(Map<String, dynamic> json) {
    return Badge(
      id: json['id'],
      name: json['name'],
      slug: json['slug'],
      description: json['description'],
      iconUrl: json['icon_url'],
      category: json['category'],
      rarityTier: json['rarity_tier'] ?? 'common',
      criteriaJson: json['criteria_json'] ?? {},
      points: json['points'] ?? 0,
      isActive: json['is_active'] ?? true,
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'slug': slug,
        'description': description,
        'icon_url': iconUrl,
        'category': category,
        'rarity_tier': rarityTier,
        'criteria_json': criteriaJson,
        'points': points,
        'is_active': isActive,
        'created_at': createdAt.toIso8601String(),
      };
}

class UserBadge {
  final String id;
  final String userId;
  final String badgeId;
  final DateTime unlockedAt;
  final bool isPinned;
  final int? pinOrder;

  UserBadge({
    String? id,
    required this.userId,
    required this.badgeId,
    DateTime? unlockedAt,
    this.isPinned = false,
    this.pinOrder,
  })  : id = id ?? _uuid.v4(),
        unlockedAt = unlockedAt ?? DateTime.now();

  factory UserBadge.fromJson(Map<String, dynamic> json) {
    return UserBadge(
      id: json['id'],
      userId: json['user_id'],
      badgeId: json['badge_id'],
      unlockedAt: DateTime.parse(json['unlocked_at']),
      isPinned: json['is_pinned'] ?? false,
      pinOrder: json['pin_order'],
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'user_id': userId,
        'badge_id': badgeId,
        'unlocked_at': unlockedAt.toIso8601String(),
        'is_pinned': isPinned,
        'pin_order': pinOrder,
      };
}

class Milestone {
  final String id;
  final String name;
  final String slug;
  final String category;
  final Map<String, dynamic> criteriaJson;
  final String? badgeId;
  final bool isActive;
  final DateTime createdAt;

  Milestone({
    String? id,
    required this.name,
    required this.slug,
    required this.category,
    required this.criteriaJson,
    this.badgeId,
    this.isActive = true,
    DateTime? createdAt,
  })  : id = id ?? _uuid.v4(),
        createdAt = createdAt ?? DateTime.now();

  factory Milestone.fromJson(Map<String, dynamic> json) {
    return Milestone(
      id: json['id'],
      name: json['name'],
      slug: json['slug'],
      category: json['category'],
      criteriaJson: json['criteria_json'] ?? {},
      badgeId: json['badge_id'],
      isActive: json['is_active'] ?? true,
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'slug': slug,
        'category': category,
        'criteria_json': criteriaJson,
        'badge_id': badgeId,
        'is_active': isActive,
        'created_at': createdAt.toIso8601String(),
      };
}

class UserMilestone {
  final String id;
  final String userId;
  final String milestoneId;
  final DateTime unlockedAt;
  final Map<String, dynamic>? evalPayload;

  UserMilestone({
    String? id,
    required this.userId,
    required this.milestoneId,
    DateTime? unlockedAt,
    this.evalPayload,
  })  : id = id ?? _uuid.v4(),
        unlockedAt = unlockedAt ?? DateTime.now();

  factory UserMilestone.fromJson(Map<String, dynamic> json) {
    return UserMilestone(
      id: json['id'],
      userId: json['user_id'],
      milestoneId: json['milestone_id'],
      unlockedAt: DateTime.parse(json['unlocked_at']),
      evalPayload: json['eval_payload'],
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'user_id': userId,
        'milestone_id': milestoneId,
        'unlocked_at': unlockedAt.toIso8601String(),
        'eval_payload': evalPayload,
      };
}
