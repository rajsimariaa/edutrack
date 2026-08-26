import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

class FormulaSheetsScreen extends StatefulWidget {
  const FormulaSheetsScreen({super.key});

  @override
  State<FormulaSheetsScreen> createState() => _FormulaSheetsScreenState();
}

class _FormulaSheetsScreenState extends State<FormulaSheetsScreen> {
  String _searchQuery = '';

  static const _formulaData = <Map<String, dynamic>>[
    {
      'subject': 'Accounting',
      'formulas': [
        {'name': 'Accounting Equation', 'formula': 'Assets = Liabilities + Equity'},
        {'name': 'Current Ratio', 'formula': 'Current Assets / Current Liabilities'},
        {'name': 'Quick Ratio', 'formula': '(Current Assets - Inventory) / Current Liabilities'},
        {'name': 'Debt to Equity Ratio', 'formula': 'Total Debt / Shareholders Equity'},
        {'name': 'Gross Profit', 'formula': 'Revenue - Cost of Goods Sold'},
        {'name': 'Net Profit Margin', 'formula': '(Net Income / Revenue) x 100'},
        {'name': 'Return on Equity', 'formula': '(Net Income / Shareholders Equity) x 100'},
        {'name': 'EPS', 'formula': 'Net Income / Number of Outstanding Shares'},
        {'name': 'Working Capital', 'formula': 'Current Assets - Current Liabilities'},
        {'name': 'Debtors Turnover', 'formula': 'Net Credit Sales / Average Accounts Receivable'},
        {'name': 'Inventory Turnover', 'formula': 'COGS / Average Inventory'},
        {'name': 'Cash Conversion Cycle', 'formula': 'DIO + DSO - DPO'},
      ],
    },
    {
      'subject': 'Taxation',
      'formulas': [
        {'name': 'Taxable Income', 'formula': 'Gross Income - Deductions - Exemptions'},
        {'name': 'Income Tax (Slab)', 'formula': 'Apply slab rates on taxable income'},
        {'name': 'GST (CGST + SGST)', 'formula': 'Value x GST Rate / 2'},
        {'name': 'GST (IGST)', 'formula': 'Value x GST Rate'},
        {'name': 'TDS', 'formula': 'Payment x TDS Rate'},
        {'name': 'Advance Tax', 'formula': 'Estimated Tax Liability - TDS'},
        {'name': 'Depreciation (WDV)', 'formula': 'WDV Rate x Book Value of Asset'},
        {'name': 'Capital Gains', 'formula': 'Sale Price - Acquisition Cost - Improvements'},
        {'name': 'Section 80C Deduction', 'formula': 'Up to Rs. 1,50,000 per year'},
        {'name': 'Presumptive Income (44AD)', 'formula': '8% of Turnover (Digital) / 6% (Cash)'},
      ],
    },
    {
      'subject': 'Cost Accounting',
      'formulas': [
        {'name': 'Prime Cost', 'formula': 'Direct Material + Direct Labor + Direct Expenses'},
        {'name': 'Factory Cost', 'formula': 'Prime Cost + Factory Overheads'},
        {'name': 'Cost of Production', 'formula': 'Factory Cost + Office & Admin Overheads'},
        {'name': 'Total Cost', 'formula': 'Cost of Production + Selling & Distribution Overheads'},
        {'name': 'Break-Even Point', 'formula': 'Fixed Costs / (Selling Price per Unit - Variable Cost per Unit)'},
        {'name': 'Contribution Margin', 'formula': 'Sales - Variable Costs'},
        {'name': 'Margin of Safety', 'formula': 'Actual Sales - Break-Even Sales'},
        {'name': 'P/V Ratio', 'formula': '(Contribution / Sales) x 100'},
        {'name': 'Activity Based Costing', 'formula': 'Cost Pool Total / Total Cost Driver Units'},
        {'name': 'Standard Cost Variance', 'formula': 'Standard Cost - Actual Cost'},
      ],
    },
    {
      'subject': 'Auditing',
      'formulas': [
        {'name': 'Materiality', 'formula': '5% of Profit Before Tax or 1% of Revenue'},
        {'name': 'Audit Risk', 'formula': 'Inherent Risk x Control Risk x Detection Risk'},
        {'name': 'Sampling Size', 'formula': 'Based on Confidence Level and Tolerable Error'},
        {'name': 'Confidence Factor', 'formula': '1 - Desired Confidence Level'},
        {'name': 'Acceptable Audit Risk', 'formula': 'Typically set at 5%'},
        {'name': 'Detection Risk', 'formula': 'Acceptable Risk / (IR x CR)'},
      ],
    },
    {
      'subject': 'Corporate Law',
      'formulas': [
        {'name': 'Authorized Capital', 'formula': 'Maximum shares company can issue'},
        {'name': 'Paid-up Capital', 'formula': 'Issued Capital - Unpaid Capital'},
        {'name': 'Dividend', 'formula': 'Profit Available for Distribution / Number of Shares'},
        {'name': 'ROE', 'formula': 'Net Income / Shareholders Equity'},
        {'name': 'Debt Service Coverage', 'formula': 'Net Operating Income / Total Debt Service'},
      ],
    },
    {
      'subject': 'Business Economics',
      'formulas': [
        {'name': 'Demand Elasticity', 'formula': '% Change in Quantity Demanded / % Change in Price'},
        {'name': 'Total Revenue', 'formula': 'Price x Quantity'},
        {'name': 'Marginal Revenue', 'formula': 'Change in Total Revenue / Change in Quantity'},
        {'name': 'Profit', 'formula': 'Total Revenue - Total Cost'},
        {'name': 'Marginal Cost', 'formula': 'Change in Total Cost / Change in Quantity'},
        {'name': 'Market Share', 'formula': ( 'Company Sales / Total Market Sales x 100')},
        {'name': 'Gini Coefficient', 'formula': 'Area between Line of Equality and Lorenz Curve'},
        {'name': 'National Income (Income Method)', 'formula': 'Compensation + Operating Surplus + Mixed Income'},
      ],
    },
  ];

  @override
  Widget build(BuildContext context) {
    final filtered = _searchQuery.isEmpty
        ? _formulaData
        : _formulaData
            .where((s) =>
                (s['subject'] as String).toLowerCase().contains(_searchQuery.toLowerCase()) ||
                (s['formulas'] as List).any((f) =>
                    (f['name'] as String).toLowerCase().contains(_searchQuery.toLowerCase()) ||
                    (f['formula'] as String).toLowerCase().contains(_searchQuery.toLowerCase())))
            .toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Formula Sheets'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              onChanged: (v) => setState(() => _searchQuery = v),
              decoration: InputDecoration(
                hintText: 'Search formulas...',
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
                      'No formulas found',
                      style: TextStyle(color: AppColors.textSecondaryOf(context)),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: filtered.length,
                    itemBuilder: (context, index) {
                      final subject = filtered[index];
                      return _buildSubjectSection(subject);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubjectSection(Map<String, dynamic> subject) {
    return ExpansionTile(
      tilePadding: EdgeInsets.zero,
      title: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.functions, color: AppColors.primary, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              subject['subject'],
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              '${(subject['formulas'] as List).length}',
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
      children: (subject['formulas'] as List).map<Widget>((f) {
        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.backgroundOf(context),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                f['name'],
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                  color: AppColors.textPrimaryOf(context),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                f['formula'],
                style: const TextStyle(
                  fontSize: 14,
                  color: AppColors.primary,
                  fontWeight: FontWeight.w500,
                  fontFamily: 'monospace',
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}
