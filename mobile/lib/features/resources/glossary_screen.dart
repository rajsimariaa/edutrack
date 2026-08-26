import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

class GlossaryScreen extends StatefulWidget {
  const GlossaryScreen({super.key});

  @override
  State<GlossaryScreen> createState() => _GlossaryScreenState();
}

class _GlossaryScreenState extends State<GlossaryScreen> {
  String _searchQuery = '';

  static const _glossaryTerms = <Map<String, String>>[
    {'term': 'Abatement', 'definition': 'Reduction or decrease, especially in tax liability or legal penalties.'},
    {'term': 'Accounting Standard', 'definition': 'Common set of accounting principles, standards and procedures that companies must follow when compiling financial statements.'},
    {'term': 'Accrual', 'definition': 'Revenue/expense recognition when earned/incurred, regardless of when cash is received/paid.'},
    {'term': 'Acquittance', 'definition': 'A legal document releasing a person from an obligation, typically a debt.'},
    {'term': 'Amortization', 'definition': 'Gradual write-off of an intangible asset\'s cost over its useful life.'},
    {'term': 'Arbitration', 'definition': 'Alternative dispute resolution where parties submit disputes to an impartial person/board for binding decision.'},
    {'term': 'Articles of Association', 'definition': 'Document defining the internal rules governing management of a company.'},
    {'term': 'Audit', 'definition': 'Independent examination of financial information of an entity for expressing an opinion.'},
    {'term': 'Audit Report', 'definition': 'Written opinion of auditor regarding accuracy and fairness of financial statements.'},
    {'term': 'Balance Sheet', 'definition': 'Financial statement showing assets, liabilities, and equity at a specific point in time.'},
    {'term': 'Bearer Paper', 'definition': 'Negotiable instrument payable to whoever holds/presents it.'},
    {'term': 'Benchmark', 'definition': 'Standard against which performance or quality may be compared.'},
    {'term': 'Bifurcation', 'definition': 'Division or splitting into two parts, commonly used in legal proceedings.'},
    {'term': 'Book Value', 'definition': 'Value of an asset according to its balance sheet account balance.'},
    {'term': 'Bylaws', 'definition': 'Rules adopted by an organization to govern its internal affairs.'},
    {'term': 'Capital Gain', 'definition': 'Profit earned on sale of capital asset exceeding its purchase price.'},
    {'term': 'Capital Market', 'definition': 'Market for buying and selling equity and debt instruments.'},
    {'term': 'Caveat Emptor', 'definition': 'Latin for "let the buyer beware" — buyer assumes risk of quality.'},
    {'term': 'Circular Resolution', 'definition': 'Resolution passed by company directors/members without a physical meeting.'},
    {'term': 'Company Registrar', 'definition': 'Government authority responsible for company registration and regulation.'},
    {'term': 'Compliance', 'definition': 'Act of adhering to laws, regulations, guidelines and specifications.'},
    {'term': 'Consideration', 'definition': 'Something of value exchanged between parties to a contract.'},
    {'term': 'Contingent Liability', 'definition': 'Potential liability that may occur depending on outcome of a future event.'},
    {'term': 'Copyright', 'definition': 'Legal right granting exclusive control over original works of authorship.'},
    {'term': 'Corporate Governance', 'definition': 'System of rules, practices and processes by which a company is directed.'},
    {'term': 'Depreciation', 'definition': 'Systematic allocation of tangible asset cost over its useful life.'},
    {'term': 'Due Diligence', 'definition': 'Comprehensive appraisal of a business undertaken by a prospective buyer.'},
    {'term': 'Duty', 'definition': 'Tax levied by government on import, export, or specific goods.'},
    {'term': 'Equity', 'definition': 'Owner\'s interest in company assets after deducting liabilities.'},
    {'term': 'Estoppel', 'definition': 'Legal principle preventing a party from denying facts they previously asserted.'},
    {'term': 'Excise Duty', 'definition': 'Tax levied on goods manufactured or produced within a country.'},
    {'term': 'Face Value', 'definition': 'Nominal value of a security printed on the certificate.'},
    {'term': 'Fiduciary', 'definition': 'Person holding assets in trust for another, with duty of good faith.'},
    {'term': 'Financial Statement', 'definition': 'Formal record of financial activities and position of a business.'},
    {'term': 'Fraud', 'definition': 'Intentional deception for unfair or unlawful gain.'},
    {'term': 'Going Concern', 'definition': 'Assumption that an entity will continue operating indefinitely.'},
    {'term': 'Goodwill', 'definition': 'Intangible asset arising from business reputation, customer base etc.'},
    {'term': 'GST', 'definition': 'Goods and Services Tax — comprehensive indirect tax on supply of goods and services.'},
    {'term': 'Holding Company', 'definition': 'Company that owns enough voting stock to control management of another company.'},
    {'term': 'Implied Authority', 'definition': 'Authority not expressly stated but reasonably inferred from position held.'},
    {'term': 'Indemnity', 'definition': 'Security against legal liability for damages.'},
    {'term': 'Insolvency', 'definition': 'Inability to pay debts when they fall due.'},
    {'term': 'Intellectual Property', 'definition': 'Creations of mind — patents, copyrights, trademarks, trade secrets.'},
    {'term': 'Internal Audit', 'definition': 'Independent assurance activity within an organization to improve operations.'},
    {'term': 'Joint Venture', 'definition': 'Business arrangement where two or more parties agree to pool resources.'},
    {'term': 'Jurisdiction', 'definition': 'Official power to make legal decisions and judgments.'},
    {'term': 'Liability', 'definition': 'Financial obligation or debt of a company.'},
    {'term': 'Liquidation', 'definition': 'Process of bringing a business to an end and distributing assets.'},
    {'term': 'Listing', 'definition': 'Process of shares being admitted for trading on a stock exchange.'},
    {'term': 'LOU', 'definition': 'Letter of Undertaking — bank guarantee for overseas borrowing.'},
    {'term': 'Majority Shareholder', 'definition': 'Shareholder holding more than 50% of company shares.'},
    {'term': 'Memorandum of Association', 'definition': 'Document defining the company\'s relationship with the outside world.'},
    {'term': 'Net Worth', 'definition': 'Total assets minus total liabilities.'},
    {'term': 'Nominee', 'definition': 'Person designated to act on behalf of another.'},
    {'term': 'Notarization', 'definition': 'Certification of document by notary public.'},
    {'term': 'Occupational Fraud', 'definition': 'Fraud committed by employees against their employer.'},
    {'term': 'OPC', 'definition': 'One Person Company — company with single member/director.'},
    {'term': 'Ordinary Resolution', 'definition': 'Resolution passed by simple majority (>50%) of shareholders.'},
    {'term': 'PAN', 'definition': 'Permanent Account Number — 10-digit ID for tax purposes in India.'},
    {'term': 'Partnership', 'definition': 'Business owned by two or more persons sharing profits and losses.'},
    {'term': 'Piercing Corporate Veil', 'definition': 'Holding directors/shareholders personally liable for company debts.'},
    {'term': 'POSCO', 'definition': 'Protection of Children from Sexual Offences Act, 2012.'},
    {'term': 'Precedent', 'definition': 'Previous court decision used as authority in subsequent cases.'},
    {'term': 'Presumption', 'definition': 'Assumption that a fact is true until proven otherwise.'},
    {'term': 'Proxy', 'definition': 'Person authorized to act for another in business/legal matters.'},
    {'term': 'Quorum', 'definition': 'Minimum number of members required to conduct valid business at a meeting.'},
    {'term': 'RBI', 'definition': 'Reserve Bank of India — central banking institution.'},
    {'term': 'Reserve Price', 'definition': 'Minimum price set for auction or sale.'},
    {'term': 'Retrospective Tax', 'definition': 'Tax imposed on transactions dating back to a previous date.'},
    {'term': 'SEBI', 'definition': 'Securities and Exchange Board of India — regulator for securities market.'},
    {'term': 'Special Resolution', 'definition': 'Resolution requiring 75% majority vote of shareholders.'},
    {'term': 'Stamp Duty', 'definition': 'Tax paid on legal documents as required by law.'},
    {'term': 'Standing Order', 'definition': 'Precedent decisions of courts used in subsequent cases.'},
    {'term': 'Subsidiary', 'definition': 'Company controlled by a holding company through majority ownership.'},
    {'term': 'Suo Motu', 'definition': 'Action taken by authority on its own motion, without complaint.'},
    {'term': 'Surcharge', 'definition': 'Additional charge or tax imposed on existing tax.'},
    {'term': 'Transfer Pricing', 'definition': 'Price charged between related entities for goods/services.'},
    {'term': 'Ultra Vires', 'definition': 'Beyond the legal power or authority of a person or body.'},
    {'term': 'Vacation of Office', 'definition': 'Cessation of holding of office by a director/officer.'},
    {'term': 'Valuation', 'definition': 'Process of determining worth of an asset, company, or security.'},
    {'term': 'Venture Capital', 'definition': 'Capital provided to early-stage high-potential startups.'},
    {'term': 'Winding Up', 'definition': 'Process of settling accounts and dissolving a company.'},
    {'term': 'Written Down Value', 'definition': 'Book value of an asset after accounting for depreciation.'},
  ];

  @override
  Widget build(BuildContext context) {
    final filtered = _searchQuery.isEmpty
        ? _glossaryTerms
        : _glossaryTerms
            .where((t) =>
                t['term']!.toLowerCase().contains(_searchQuery.toLowerCase()) ||
                t['definition']!.toLowerCase().contains(_searchQuery.toLowerCase()))
            .toList();

    final grouped = <String, List<Map<String, String>>>{};
    for (final term in filtered) {
      final letter = term['term']![0].toUpperCase();
      grouped.putIfAbsent(letter, () => []).add(term);
    }

    final sortedLetters = grouped.keys.toList()..sort();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Glossary'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              onChanged: (v) => setState(() => _searchQuery = v),
              decoration: InputDecoration(
                hintText: 'Search terms...',
                prefixIcon: const Icon(Icons.search, size: 20),
                hintStyle: TextStyle(color: AppColors.textHintOf(context)),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
            ),
          ),
          Expanded(
            child: filtered.isEmpty
                ? Center(
                    child: Text(
                      'No terms found',
                      style: TextStyle(color: AppColors.textSecondaryOf(context)),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: sortedLetters.length,
                    itemBuilder: (context, index) {
                      final letter = sortedLetters[index];
                      final terms = grouped[letter]!;
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            child: Text(
                              letter,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: AppColors.primary,
                              ),
                            ),
                          ),
                          ...terms.map((t) => _buildTermCard(t)),
                        ],
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildTermCard(Map<String, String> term) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              term['term']!,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 14,
                color: AppColors.textPrimaryOf(context),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              term['definition']!,
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
  }
}
