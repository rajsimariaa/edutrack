import '../models/gamification_model.dart';

class StreakUtils {
  static int computeCurrentStreak(List<HeatmapEntry> heatmap) {
    if (heatmap.isEmpty) return 0;
    final today = DateTime.now();
    int streak = 0;
    for (int i = 0; i < 365; i++) {
      final date = today.subtract(Duration(days: i));
      final hasEntry = heatmap.any((h) =>
          h.activityDate.year == date.year &&
          h.activityDate.month == date.month &&
          h.activityDate.day == date.day);
      if (hasEntry) {
        streak++;
      } else if (i > 0) {
        break;
      }
    }
    return streak;
  }

  static int computeLongestStreak(List<HeatmapEntry> heatmap) {
    if (heatmap.isEmpty) return 0;
    final sorted = List<HeatmapEntry>.from(heatmap)
      ..sort((a, b) => a.activityDate.compareTo(b.activityDate));

    int longest = 0;
    int temp = 0;
    DateTime? prev;
    for (final entry in sorted) {
      if (prev != null) {
        final diff = entry.activityDate.difference(prev).inDays;
        if (diff == 1) {
          temp++;
        } else {
          if (temp > longest) longest = temp;
          temp = 1;
        }
      } else {
        temp = 1;
      }
      prev = entry.activityDate;
    }
    if (temp > longest) longest = temp;
    return longest;
  }

  static int computeTotalDays(List<HeatmapEntry> heatmap) => heatmap.length;
}
