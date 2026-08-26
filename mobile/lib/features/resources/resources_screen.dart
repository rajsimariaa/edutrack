import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../providers/auth_provider.dart';
import '../../services/services.dart';
import '../../theme/app_theme.dart';

class ResourcesScreen extends ConsumerStatefulWidget {
  const ResourcesScreen({super.key});

  @override
  ConsumerState<ResourcesScreen> createState() => _ResourcesScreenState();
}

class _ResourcesScreenState extends ConsumerState<ResourcesScreen> {
  final _resourceService = ResourceService();
  List<Map<String, dynamic>> _pastPapers = [];
  List<Map<String, dynamic>> _youtubeLinks = [];
  bool _isLoading = true;

  static const _currentAffairs = [
    {
      'date': 'August 25, 2026',
      'title': 'SEBI tightens mutual fund disclosure norms',
      'summary': 'SEBI has issued new guidelines requiring mutual funds to disclose risk factors more prominently in all marketing materials.',
    },
    {
      'date': 'August 24, 2026',
      'title': 'GST Council meeting on rate rationalization',
      'summary': 'The 54th GST Council meeting is scheduled to discuss simplification of tax slabs and compliance easing for small businesses.',
    },
    {
      'date': 'August 23, 2026',
      'title': 'New Companies Amendment Bill introduced',
      'summary': 'A new bill to amend the Companies Act 2013 has been introduced in Parliament to ease compliance for OPCs and startups.',
    },
    {
      'date': 'August 22, 2026',
      'title': 'RBI circular on digital lending guidelines',
      'summary': 'RBI has released new guidelines for digital lenders mandating all loan disbursals through regulated bank accounts only.',
    },
    {
      'date': 'August 21, 2026',
      'title': 'Income Tax e-filing portal update',
      'summary': 'The IT department has updated the e-filing portal with pre-filled ITR forms and integrated TDS verification system.',
    },
    {
      'date': 'August 20, 2026',
      'title': 'MCA notifies new ROC filing deadlines',
      'summary': 'Ministry of Corporate Affairs has revised filing deadlines for annual returns and financial statements for FY 2025-26.',
    },
  ];

  static const _importantLaws = [
    {
      'name': 'Companies Act, 2013',
      'description': 'Governs incorporation, management and dissolution of companies in India.',
      'sections': [
        'Section 2 — Definitions',
        'Section 7 — Incorporation of Company',
        'Section 135 — Corporate Social Responsibility',
        'Section 149 — Board of Directors',
        'Section 166 — Duties of Directors',
        'Section 177 — Audit Committee',
        'Section 185 — Loan to Directors',
        'Section 245 — Class Action Suits',
      ],
    },
    {
      'name': 'Indian Contract Act, 1872',
      'description': 'Defines and amends the law relating to contracts in India.',
      'sections': [
        'Section 2 — Definitions',
        'Section 10 — Valid Contract',
        'Section 23 — Legality of Object',
        'Section 73 — Compensation for Breach',
        'Section 124 — Contract of Indemnity',
        'Section 147 — Contract of Guarantee',
      ],
    },
    {
      'name': 'Partnership Act, 1932',
      'description': 'Defines and amends the law relating to partnership firms.',
      'sections': [
        'Section 4 — Definition of Partnership',
        'Section 9 — Implied Authority',
        'Section 12 — Rights of Partners',
        'Section 16 — Liabilities of Partners',
        'Section 25 — Incoming Partner',
        'Section 33 — Dissolution by Notice',
      ],
    },
    {
      'name': 'Negotiable Instruments Act, 1881',
      'description': 'Defines and amends the law relating to promissory notes, bills of exchange and cheques.',
      'sections': [
        'Section 6 — Promissory Note',
        'Section 7 — Bill of Exchange',
        'Section 13 — Cheque',
        'Section 25 — Dishonour of Cheque',
        'Section 138 — Cheque Bounce',
      ],
    },
    {
      'name': 'Income Tax Act, 1961',
      'description': 'Comprehensive statute governing income tax in India.',
      'sections': [
        'Section 2 — Definitions',
        'Section 4 — Charge of Tax',
        'Section 80C — Deductions',
        'Section 80D — Health Insurance',
        'Section 92 — Transfer Pricing',
        'Section 143 — Assessment',
        'Section 147 — Reassessment',
        'Section 234A — Interest on Delay',
      ],
    },
    {
      'name': 'GST Acts (CGST/SGST/IGST)',
      'description': 'Unified indirect tax system on supply of goods and services.',
      'sections': [
        'Section 7 — Supply',
        'Section 9 — Levy and Collection',
        'Section 16 — Input Tax Credit',
        'Section 22 — Registration',
        'Section 31 — Tax Invoice',
        'Section 50 — Interest',
        'Section 73 — Non-Payment',
        'Section 129 — Detention/Seizure',
      ],
    },
    {
      'name': 'Sales of Goods Act, 1930',
      'description': 'Defines and amends the law relating to the sale of goods.',
      'sections': [
        'Section 4 — Contract of Sale',
        'Section 12 — Implied Conditions',
        'Section 13 — Implied Warranties',
        'Section 54 — Transfer of Title',
        'Section 56 — Delivery of Goods',
      ],
    },
  ];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final auth = ref.read(authProvider);
    if (auth.profile == null) return;

    try {
      final exam = await SyllabusService().getExamForCategory(auth.profile!.examCategory);
      if (exam != null) {
        _pastPapers = await _resourceService.getPastPapers(exam.id);
        _youtubeLinks = await _resourceService.getYoutubeLinks(examId: exam.id);
      }
      setState(() => _isLoading = false);
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Resources'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : DefaultTabController(
              length: 7,
              child: Column(
                children: [
                  const TabBar(
                    isScrollable: true,
                    tabAlignment: TabAlignment.start,
                    tabs: [
                      Tab(text: 'Past Papers'),
                      Tab(text: 'Videos'),
                      Tab(text: 'Formulas'),
                      Tab(text: 'Glossary'),
                      Tab(text: 'Notes'),
                      Tab(text: 'News'),
                      Tab(text: 'Laws'),
                    ],
                  ),
                  Expanded(
                    child: TabBarView(
                      children: [
                        _buildPastPapers(),
                        _buildYouTubeLinks(),
                        _buildFormulaSheets(),
                        _buildGlossary(),
                        _buildStudyNotes(),
                        _buildCurrentAffairs(),
                        _buildImportantLaws(),
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildPastPapers() {
    if (_pastPapers.isEmpty) {
      return const Center(child: Text('No past papers available'));
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _pastPapers.length,
      itemBuilder: (context, index) {
        final paper = _pastPapers[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            contentPadding: const EdgeInsets.all(16),
            leading: Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: AppColors.error.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.picture_as_pdf, color: AppColors.error),
            ),
            title: Text(
              paper['title'] ?? 'Untitled',
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            subtitle: Text(
              '${paper['year'] ?? ""} ${paper['term'] ?? ""}',
              style: TextStyle(fontSize: 12, color: AppColors.textSecondaryOf(context)),
            ),
            trailing: IconButton(
              icon: const Icon(Icons.download),
              onPressed: () async {
                final url = paper['file_url'];
                if (url != null) {
                  await launchUrl(Uri.parse(url));
                }
              },
            ),
          ),
        );
      },
    );
  }

  Widget _buildYouTubeLinks() {
    if (_youtubeLinks.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.play_circle_outline, size: 64, color: AppColors.textHintOf(context)),
              const SizedBox(height: 16),
              Text('No YouTube links yet', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: AppColors.textSecondaryOf(context))),
              const SizedBox(height: 8),
              Text('YouTube links will appear as they are added to chapters', textAlign: TextAlign.center, style: TextStyle(color: AppColors.textHintOf(context))),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _youtubeLinks.length,
      itemBuilder: (context, index) {
        final link = _youtubeLinks[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            contentPadding: const EdgeInsets.all(16),
            leading: Container(
              width: 48, height: 48,
              decoration: BoxDecoration(
                color: AppColors.error.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.play_circle, color: AppColors.error),
            ),
            title: Text(link['title'] ?? 'Untitled', style: const TextStyle(fontWeight: FontWeight.w600)),
            subtitle: Text(link['channel_name'] ?? '', style: TextStyle(fontSize: 12, color: AppColors.textSecondaryOf(context))),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.thumb_up, size: 16, color: AppColors.textHintOf(context)),
                const SizedBox(width: 4),
                Text('${link['upvotes'] ?? 0}', style: TextStyle(fontSize: 12, color: AppColors.textHintOf(context))),
              ],
            ),
            onTap: () async {
              final url = link['video_url'];
              if (url != null) await launchUrl(Uri.parse(url));
            },
          ),
        );
      },
    );
  }

  Widget _buildFormulaSheets() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildResourceCard(
          title: 'View All Formula Sheets',
          subtitle: 'Browse formulas organized by subject',
          icon: Icons.functions,
          color: AppColors.primary,
          onTap: () => context.push('/resources/formulas'),
        ),
        const SizedBox(height: 12),
        _buildSubjectFormulaCard('Accounting', '12 formulas'),
        _buildSubjectFormulaCard('Taxation', '10 formulas'),
        _buildSubjectFormulaCard('Cost Accounting', '10 formulas'),
        _buildSubjectFormulaCard('Auditing', '6 formulas'),
        _buildSubjectFormulaCard('Corporate Law', '5 formulas'),
        _buildSubjectFormulaCard('Business Economics', '8 formulas'),
      ],
    );
  }

  Widget _buildSubjectFormulaCard(String subject, String count) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Icon(Icons.functions, color: AppColors.primary, size: 20),
        ),
        title: Text(subject, style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14)),
        subtitle: Text(count, style: TextStyle(fontSize: 12, color: AppColors.textHintOf(context))),
        trailing: Icon(Icons.chevron_right, color: AppColors.textHintOf(context)),
        onTap: () => context.push('/resources/formulas'),
      ),
    );
  }

  Widget _buildGlossary() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildResourceCard(
          title: 'Browse Full Glossary',
          subtitle: 'Alphabetical list of legal and accounting terms',
          icon: Icons.menu_book_outlined,
          color: AppColors.accent,
          onTap: () => context.push('/resources/glossary'),
        ),
        const SizedBox(height: 16),
        Text(
          'Sample Terms',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.textSecondaryOf(context),
          ),
        ),
        const SizedBox(height: 8),
        _buildTermPreviewCard('Audit', 'Independent examination of financial information'),
        _buildTermPreviewCard('Depreciation', 'Systematic allocation of asset cost over useful life'),
        _buildTermPreviewCard('GST', 'Goods and Services Tax'),
        _buildTermPreviewCard('Liability', 'Financial obligation or debt of a company'),
        _buildTermPreviewCard('Piercing Corporate Veil', 'Holding directors personally liable for company debts'),
      ],
    );
  }

  Widget _buildTermPreviewCard(String term, String definition) {
    return Card(
      margin: const EdgeInsets.only(bottom: 6),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    term,
                    style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    definition,
                    style: TextStyle(fontSize: 12, color: AppColors.textSecondaryOf(context)),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: AppColors.textHintOf(context), size: 18),
          ],
        ),
      ),
    );
  }

  Widget _buildStudyNotes() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildResourceCard(
          title: 'Open Notes',
          subtitle: 'Access all your study notes',
          icon: Icons.note_add_outlined,
          color: AppColors.secondary,
          onTap: () => context.push('/focus/notes'),
        ),
        const SizedBox(height: 16),
        _buildResourceCard(
          title: 'Flashcards',
          subtitle: 'Study with interactive flashcards',
          icon: Icons.style_outlined,
          color: AppColors.primary,
          onTap: () => context.push('/focus/flashcards'),
        ),
      ],
    );
  }

  Widget _buildCurrentAffairs() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _currentAffairs.length,
      itemBuilder: (context, index) {
        final item = _currentAffairs[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.accent.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        item['date']!,
                        style: const TextStyle(
                          fontSize: 11,
                          color: AppColors.accent,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  item['title']!,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                    color: AppColors.textPrimaryOf(context),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  item['summary']!,
                  style: TextStyle(
                    fontSize: 13,
                    color: AppColors.textSecondaryOf(context),
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildImportantLaws() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _importantLaws.length,
      itemBuilder: (context, index) {
        final law = _importantLaws[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: ExpansionTile(
            tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            leading: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.gavel, color: AppColors.primary, size: 20),
            ),
            title: Text(
              law['name'] as String,
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
            ),
            subtitle: Text(
              law['description'] as String,
              style: TextStyle(fontSize: 12, color: AppColors.textSecondaryOf(context)),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            children: (law['sections'] as List).map<Widget>((section) {
              return Container(
                margin: const EdgeInsets.only(bottom: 6),
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.backgroundOf(context),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(Icons.article_outlined, size: 16, color: AppColors.textHintOf(context)),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        section,
                        style: TextStyle(fontSize: 13, color: AppColors.textPrimaryOf(context)),
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        );
      },
    );
  }

  Widget _buildResourceCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: TextStyle(fontSize: 12, color: AppColors.textSecondaryOf(context)),
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right, color: AppColors.textHintOf(context)),
            ],
          ),
        ),
      ),
    );
  }
}
