import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../theme/app_theme.dart';

class ExamChecklistScreen extends StatefulWidget {
  const ExamChecklistScreen({super.key});

  @override
  State<ExamChecklistScreen> createState() => _ExamChecklistScreenState();
}

class _ExamChecklistScreenState extends State<ExamChecklistScreen> {
  bool _isLoading = true;
  Map<int, bool> _checkedItems = {};
  DateTime? _examDate;
  final List<Map<String, dynamic>> _checklistItems = [
    {'icon': Icons.description_outlined, 'text': 'Admit card downloaded'},
    {'icon': Icons.credit_card_outlined, 'text': 'ID proof ready (Aadhaar/PAN)'},
    {'icon': Icons.edit_outlined, 'text': 'Stationery packed (pens, pencils, eraser)'},
    {'icon': Icons.calculate_outlined, 'text': 'Calculator allowed (if applicable)'},
    {'icon': Icons.directions_outlined, 'text': 'Route to exam center planned'},
    {'icon': Icons.location_on_outlined, 'text': 'Exam center visited/known'},
    {'icon': Icons.restaurant_outlined, 'text': 'Healthy dinner eaten'},
    {'icon': Icons.alarm_outlined, 'text': 'Alarm set'},
    {'icon': Icons.backpack_outlined, 'text': 'Exam essentials bag packed'},
    {'icon': Icons.menu_book_outlined, 'text': 'Notes reviewed'},
  ];

  final List<String> _tips = [
    'Reach 30 minutes early',
    'Carry extra pens',
    'Read all questions first',
    'Don\'t spend >2 min on any question',
    'Stay calm and confident',
  ];

  final List<Map<String, String>> _revisionNotes = [
    {'title': 'Mathematics', 'content': 'Integration, Differentiation, Matrices, Probability, Trigonometry'},
    {'title': 'Physics', 'content': 'Newton\'s Laws, Thermodynamics, Optics, Electromagnetism, Modern Physics'},
    {'title': 'Chemistry', 'content': 'Periodic Table, Organic Reactions, Chemical Bonding, Equilibrium, Electrochemistry'},
    {'title': 'General', 'content': 'Current Affairs, Logical Reasoning, Data Interpretation, Reading Comprehension'},
  ];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedState = prefs.getStringList('exam_checklist_state');
      if (savedState != null) {
        for (var item in savedState) {
          final parts = item.split(':');
          if (parts.length == 2) {
            final index = int.tryParse(parts[0]);
            final checked = parts[1] == 'true';
            if (index != null) {
              _checkedItems[index] = checked;
            }
          }
        }
      }
      final examDateStr = prefs.getString('exam_date');
      if (examDateStr != null) {
        _examDate = DateTime.tryParse(examDateStr);
      }
    } catch (_) {}
    setState(() => _isLoading = false);
  }

  Future<void> _saveData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedState = _checkedItems.entries
          .map((e) => '${e.key}:${e.value}')
          .toList();
      await prefs.setStringList('exam_checklist_state', savedState);
      if (_examDate != null) {
        await prefs.setString('exam_date', _examDate!.toIso8601String());
      }
    } catch (_) {}
  }

  void _toggleItem(int index) {
    setState(() {
      _checkedItems[index] = !(_checkedItems[index] ?? false);
    });
    _saveData();
  }

  void _showSetExamDateDialog() {
    final controller = TextEditingController(
      text: _examDate != null
          ? '${_examDate!.year}-${_examDate!.month.toString().padLeft(2, '0')}-${_examDate!.day.toString().padLeft(2, '0')}'
          : '',
    );

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Set Exam Date'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            hintText: 'YYYY-MM-DD',
            labelText: 'Exam Date',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              final date = DateTime.tryParse(controller.text);
              if (date != null) {
                setState(() => _examDate = date);
                _saveData();
              }
              Navigator.pop(context);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  double get _completionPercentage {
    if (_checklistItems.isEmpty) return 0;
    final checked = _checkedItems.values.where((v) => v).length;
    return checked / _checklistItems.length * 100;
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: const Text('Exam Checklist')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Exam Checklist'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildExamCountdown(),
            const SizedBox(height: 16),
            _buildProgressSection(),
            const SizedBox(height: 16),
            _buildChecklist(),
            const SizedBox(height: 16),
            _buildTipsSection(),
            const SizedBox(height: 16),
            _buildRevisionSection(),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildExamCountdown() {
    final daysLeft = _examDate != null
        ? _examDate!.difference(DateTime.now()).inDays
        : null;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primary, AppColors.primaryDark],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          if (daysLeft != null && daysLeft > 0) ...[
            Text(
              '$daysLeft',
              style: const TextStyle(
                fontSize: 48,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const Text(
              'days until exam',
              style: TextStyle(
                color: Colors.white70,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '${_examDate!.day}/${_examDate!.month}/${_examDate!.year}',
              style: const TextStyle(
                color: Colors.white60,
                fontSize: 14,
              ),
            ),
          ] else ...[
            const Icon(Icons.event_outlined, color: Colors.white, size: 40),
            const SizedBox(height: 8),
            const Text(
              'Set your exam date',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'Tap to set exam date for countdown',
              style: TextStyle(
                color: Colors.white70,
                fontSize: 12,
              ),
            ),
          ],
          const SizedBox(height: 12),
          ElevatedButton.icon(
            onPressed: _showSetExamDateDialog,
            icon: const Icon(Icons.edit, size: 18),
            label: Text(daysLeft != null ? 'Change Date' : 'Set Date'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: AppColors.primary,
              minimumSize: const Size(150, 40),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressSection() {
    final percentage = _completionPercentage;
    final checked = _checkedItems.values.where((v) => v).length;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Checklist Progress',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              Text(
                '$checked/${_checklistItems.length} completed',
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 14,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: percentage / 100,
              backgroundColor: AppColors.border,
              valueColor: AlwaysStoppedAnimation(
                percentage == 100 ? AppColors.success : AppColors.primary,
              ),
              minHeight: 12,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '${percentage.toStringAsFixed(0)}% complete',
            style: TextStyle(
              color: percentage == 100 ? AppColors.success : AppColors.textSecondary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChecklist() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.all(16),
            child: Text(
              'Checklist',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
          ...List.generate(_checklistItems.length, (index) {
            final item = _checklistItems[index];
            final isChecked = _checkedItems[index] ?? false;

            return Column(
              children: [
                if (index > 0) const Divider(height: 1),
                ListTile(
                  leading: Icon(
                    item['icon'] as IconData,
                    color: isChecked ? AppColors.success : AppColors.textSecondary,
                  ),
                  title: Text(
                    item['text'] as String,
                    style: TextStyle(
                      decoration: isChecked ? TextDecoration.lineThrough : null,
                      color: isChecked ? AppColors.textHint : AppColors.textPrimary,
                    ),
                  ),
                  trailing: Checkbox(
                    value: isChecked,
                    onChanged: (_) => _toggleItem(index),
                    activeColor: AppColors.success,
                  ),
                  onTap: () => _toggleItem(index),
                ),
              ],
            );
          }),
        ],
      ),
    );
  }

  Widget _buildTipsSection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.warning.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.warning.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.lightbulb_outline, color: AppColors.warning),
              const SizedBox(width: 8),
              const Text(
                'Exam Day Tips',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.warning,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ..._tips.map((tip) => Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.check_circle_outline, size: 18, color: AppColors.warning),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    tip,
                    style: const TextStyle(fontSize: 14),
                  ),
                ),
              ],
            ),
          )),
        ],
      ),
    );
  }

  Widget _buildRevisionSection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.accent.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.accent.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.menu_book_outlined, color: AppColors.accent),
              const SizedBox(width: 8),
              const Text(
                'Last-Minute Revision',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.accent,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ..._revisionNotes.map((note) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    note['title']!,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    note['content']!,
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          )),
        ],
      ),
    );
  }
}
