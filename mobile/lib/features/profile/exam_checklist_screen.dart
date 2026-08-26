import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../providers/auth_provider.dart';
import '../../theme/app_theme.dart';

class ExamChecklistScreen extends ConsumerStatefulWidget {
  const ExamChecklistScreen({super.key});

  @override
  ConsumerState<ExamChecklistScreen> createState() => _ExamChecklistScreenState();
}

class _ExamChecklistScreenState extends ConsumerState<ExamChecklistScreen> {
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

  List<Map<String, String>> _getRevisionNotes() {
    final profile = ref.read(authProvider).profile;
    final examCategory = profile?.examCategory ?? '';

    switch (examCategory) {
      case 'CA_FND':
        return [
          {'title': 'Accounting', 'content': 'Journal Entries, Ledger, Trial Balance, Cash/Bank Reconciliation, Depreciation'},
          {'title': 'Business Laws', 'content': 'Indian Contract Act, Sale of Goods Act, Partnership Act, LLP Act, Companies Act basics'},
          {'title': 'Cost Accounting', 'content': 'Material Cost, Labour Cost, Overheads, Cost Sheet, Unit Costing'},
          {'title': 'Business Mathematics', 'content': 'Ratio & Proportion, Indices, Logarithms, Linear Equations, Statistics'},
          {'title': 'Business Economics', 'content': 'Demand & Supply, Market Structures, National Income, Inflation, Money & Banking'},
        ];
      case 'CA_INT':
        return [
          {'title': 'Advanced Accounting', 'content': 'Amalgamation, Liquidation, Financial Statements, Partnership (Advanced)'},
          {'title': 'Corporate Laws', 'content': 'Companies Act 2013, SEBI Regulations, Insider Trading, Corporate Governance'},
          {'title': 'Taxation', 'content': 'Income Tax: Salary, House Property, Capital Gains, Business Income, Deductions'},
          {'title': 'Cost & Management Accounting', 'content': 'Budgeting, Standard Costing, Marginal Costing, Process Costing, Joint Products'},
          {'title': 'Auditing', 'content': 'Audit Planning, Vouching, Verification, Company Audit, Audit Report'},
        ];
      case 'CA_FIN':
        return [
          {'title': 'Financial Reporting', 'content': 'Ind AS (all 40+), Consolidation, Fair Value, Financial Instruments'},
          {'title': 'Strategic Financial Management', 'content': 'Portfolio Theory, Derivatives, Forex, Mergers & Acquisitions'},
          {'title': 'Advanced Auditing', 'content': 'Professional Ethics, Audit of Banks, Insurance, PSU, IT Audit'},
          {'title': 'Corporate & Economic Laws', 'content': 'Competition Act, FEMA, PMLA, Insolvency Code, SEBI'},
          {'title': 'Strategic Cost Management', 'content': 'Value Chain, Target Costing, Life Cycle Costing, Balanced Scorecard'},
        ];
      case 'CS_EXEC':
        return [
          {'title': 'Business Laws', 'content': 'Indian Contract Act, Sale of Goods, Negotiable Instruments, Companies Act'},
          {'title': 'Company Law', 'content': 'Incorporation, Share Capital, Board Meetings, Accounts, Audit'},
          {'title': 'Economic Laws', 'content': 'FEMA, Competition Act, SEBI, Insolvency Code, GST basics'},
          {'title': 'Strategic Management', 'content': 'SWOT, Porter\'s Model, BCG Matrix, Ansoff Matrix, Strategy Formulation'},
          {'title': 'Tax Laws', 'content': 'Income Tax basics, GST structure, TDS provisions, Filing procedures'},
        ];
      case 'CMA_FND':
        return [
          {'title': 'Business Laws & Ethics', 'content': 'Indian Contract Act, Company Law basics, Ethics frameworks'},
          {'title': 'Financial Accounting', 'content': 'Journal, Ledger, Trial Balance, Final Accounts, Depreciation'},
          {'title': 'Cost Accounting', 'content': 'Material Cost, Labour Cost, Overheads, Cost Sheet, Unit Costing'},
          {'title': 'Business Mathematics', 'content': 'Algebra, Matrices, Calculus basics, Statistics, Probability'},
          {'title': 'Business Economics', 'content': 'Demand Analysis, Production, Cost, Market Structures, National Income'},
        ];
      case 'CFA_L1':
        return [
          {'title': 'Ethics', 'content': 'Code of Ethics, Standards of Professional Conduct, GIPS'},
          {'title': 'Quantitative Methods', 'content': 'TVM, Statistics, Probability, Hypothesis Testing, Regression'},
          {'title': 'Economics', 'content': 'Micro & Macro, Currency, Fiscal/Monetary Policy, International Trade'},
          {'title': 'Financial Reporting', 'content': 'Income Statement, Balance Sheet, Cash Flows, Ratios, IFRS vs GAAP'},
          {'title': 'Corporate Finance', 'content': 'Capital Budgeting, Cost of Capital, Leverage, Working Capital'},
          {'title': 'Equity & Fixed Income', 'content': 'Market Organization, Security Valuation, Bond Pricing, Yield Curves'},
          {'title': 'Derivatives & Alternatives', 'content': 'Forwards, Futures, Options, Swaps, Real Estate, Commodities'},
        ];
      case 'JEE_MAIN':
        return [
          {'title': 'Physics', 'content': 'Mechanics, Thermodynamics, Optics, Electromagnetism, Modern Physics, Semiconductors'},
          {'title': 'Chemistry', 'content': 'Atomic Structure, Chemical Bonding, Thermodynamics, Equilibrium, Organic Reactions'},
          {'title': 'Mathematics', 'content': 'Calculus, Algebra, Coordinate Geometry, Trigonometry, Vectors, Probability'},
        ];
      case 'JEE_ADV':
        return [
          {'title': 'Physics (Advanced)', 'content': 'Rotational Dynamics, SHM, Electrostatics, Magnetism, EMI, Modern Physics'},
          {'title': 'Chemistry (Advanced)', 'content': 'Organic Mechanisms, Coordination Chemistry, Thermodynamics, Equilibrium'},
          {'title': 'Mathematics (Advanced)', 'content': 'Definite Integrals, Differential Equations, Matrices, Complex Numbers, Conics'},
        ];
      case 'NEET_UG':
        return [
          {'title': 'Physics', 'content': 'Mechanics, Thermodynamics, Optics, Waves, Electromagnetism, Modern Physics'},
          {'title': 'Chemistry', 'content': 'Periodic Table, Chemical Bonding, Organic Reactions, Biomolecules, Polymers'},
          {'title': 'Biology', 'content': 'Cell Biology, Genetics, Ecology, Human Physiology, Plant Physiology, Evolution'},
        ];
      default:
        return [
          {'title': 'Core Concepts', 'content': 'Review fundamental concepts, formulas, and key definitions'},
          {'title': 'Practice Problems', 'content': 'Focus on frequently asked questions and previous year patterns'},
          {'title': 'Quick Revision', 'content': 'Go through short notes, mnemonics, and memory techniques'},
          {'title': 'Time Management', 'content': 'Practice timed sections, work on speed and accuracy'},
          {'title': 'Mock Tests', 'content': 'Take at least 2 full-length mocks, analyze weak areas'},
        ];
    }
  }

  String _getExamName() {
    final profile = ref.read(authProvider).profile;
    final examCategory = profile?.examCategory ?? '';

    switch (examCategory) {
      case 'CA_FND': return 'CA Foundation';
      case 'CA_INT': return 'CA Intermediate';
      case 'CA_FIN': return 'CA Final';
      case 'CS_EXEC': return 'CS Executive';
      case 'CMA_FND': return 'CMA Foundation';
      case 'CFA_L1': return 'CFA Level 1';
      case 'JEE_MAIN': return 'JEE Main';
      case 'JEE_ADV': return 'JEE Advanced';
      case 'NEET_UG': return 'NEET UG';
      default: return 'Your Exam';
    }
  }

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

    final revisionNotes = _getRevisionNotes();
    final examName = _getExamName();

    return Scaffold(
      appBar: AppBar(
        title: Text('$examName Checklist'),
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
            _buildRevisionSection(revisionNotes, examName),
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
        color: AppColors.surfaceOf(context),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.borderOf(context)),
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
                  color: AppColors.textSecondaryOf(context),
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
              backgroundColor: AppColors.borderOf(context),
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
              color: percentage == 100 ? AppColors.success : AppColors.textSecondaryOf(context),
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
        color: AppColors.surfaceOf(context),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.borderOf(context)),
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
                    color: isChecked ? AppColors.success : AppColors.textSecondaryOf(context),
                  ),
                  title: Text(
                    item['text'] as String,
                    style: TextStyle(
                      decoration: isChecked ? TextDecoration.lineThrough : null,
                      color: isChecked ? AppColors.textHintOf(context) : AppColors.textPrimaryOf(context),
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

  Widget _buildRevisionSection(List<Map<String, String>> notes, String examName) {
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
              Text(
                '$examName Revision',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.accent,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            'Key topics for $examName',
            style: TextStyle(
              fontSize: 12,
              color: AppColors.textSecondaryOf(context),
            ),
          ),
          const SizedBox(height: 12),
          ...notes.map((note) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.surfaceOf(context),
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
                      color: AppColors.textSecondaryOf(context),
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
