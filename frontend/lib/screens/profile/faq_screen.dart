import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../config/colors.dart';

class FaqScreen extends StatefulWidget {
  const FaqScreen({super.key});

  @override
  State<FaqScreen> createState() => _FaqScreenState();
}

class _FaqScreenState extends State<FaqScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  final List<Map<String, String>> _servicesFaq = [
    {
      'question': 'What services does Israin Solutions offer?',
      'answer':
          'AI Development (chatbots, AI agents, document processing) and Digital Marketing (SEO, social media, PPC)',
    },
    {
      'question': 'How much do your services cost?',
      'answer':
          'Starting from \$1440 depending on the service and tier (Starter, Professional, Enterprise)',
    },
    {
      'question': 'How long does a typical project take?',
      'answer':
          '1-4 weeks depending on scope and complexity',
    },
  ];

  final List<Map<String, String>> _processFaq = [
    {
      'question': 'How do I start a project?',
      'answer':
          'Submit an inquiry through our app, choose your service, and our team will reach out within 24 hours',
    },
    {
      'question': 'Can I track my project progress?',
      'answer':
          'Yes, through the My Inquiries section you can chat with our team in real-time',
    },
    {
      'question': 'What if I\'m not satisfied?',
      'answer':
          'We offer revisions based on your plan. Contact our support team for any concerns',
    },
  ];

  final List<Map<String, String>> _accountFaq = [
    {
      'question': 'How do I create an account?',
      'answer': 'Sign up with your email and verify through OTP',
    },
    {
      'question': 'Can I change my plan after starting?',
      'answer':
          'Yes, contact our team through the chat to discuss plan changes',
    },
    {
      'question': 'How do I contact support?',
      'answer':
          'Use the Chat with AI feature for quick answers, or open a conversation from My Inquiries',
    },
  ];

  final List<Map<String, String>> _paymentsFaq = [
    {
      'question': 'What payment methods do you accept?',
      'answer': 'We accept bank transfers and online payments',
    },
    {
      'question': 'Do you offer refunds?',
      'answer':
          'Refund policies depend on the project stage. Contact us for details',
    },
  ];

  List<Map<String, String>> _filterFaq(List<Map<String, String>> faq) {
    if (_searchQuery.isEmpty) return faq;
    return faq
        .where((item) =>
            item['question']!.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            item['answer']!.toLowerCase().contains(_searchQuery.toLowerCase()))
        .toList();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final filteredServices = _filterFaq(_servicesFaq);
    final filteredProcess = _filterFaq(_processFaq);
    final filteredAccount = _filterFaq(_accountFaq);
    final filteredPayments = _filterFaq(_paymentsFaq);

    final bool hasResults = filteredServices.isNotEmpty ||
        filteredProcess.isNotEmpty ||
        filteredAccount.isNotEmpty ||
        filteredPayments.isNotEmpty;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) {
          Navigator.pushReplacementNamed(context, '/profile');
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: SafeArea(
          child: Column(
            children: [
              _buildHeader(context),
              _buildSearchBar(),
              Expanded(
                child: hasResults
                    ? SingleChildScrollView(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (filteredServices.isNotEmpty) ...[
                              _buildCategoryHeader('Services'),
                              ...filteredServices.map((faq) => _buildFaqTile(faq)),
                              const SizedBox(height: 8),
                            ],
                            if (filteredProcess.isNotEmpty) ...[
                              _buildCategoryHeader('Process'),
                              ...filteredProcess.map((faq) => _buildFaqTile(faq)),
                              const SizedBox(height: 8),
                            ],
                            if (filteredAccount.isNotEmpty) ...[
                              _buildCategoryHeader('Account'),
                              ...filteredAccount.map((faq) => _buildFaqTile(faq)),
                              const SizedBox(height: 8),
                            ],
                            if (filteredPayments.isNotEmpty) ...[
                              _buildCategoryHeader('Payments'),
                              ...filteredPayments.map((faq) => _buildFaqTile(faq)),
                              const SizedBox(height: 24),
                            ],
                          ],
                        ),
                      )
                    : Center(
                        child: Text(
                          'No results found',
                          style: GoogleFonts.poppins(
                            color: AppColors.onSurfaceVariant,
                            fontSize: 16,
                          ),
                        ),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          IconButton(
            icon: Icon(Icons.arrow_back_ios, color: AppColors.onSurface),
            onPressed: () {
              Navigator.pushReplacementNamed(context, '/profile');
            },
          ),
          Expanded(
            child: Text(
              'FAQ',
              style: GoogleFonts.poppins(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: AppColors.onSurface,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(width: 48),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: TextField(
        controller: _searchController,
        onChanged: (value) {
          setState(() {
            _searchQuery = value;
          });
        },
        style: GoogleFonts.poppins(color: AppColors.onSurface),
        decoration: InputDecoration(
          hintText: 'Search questions...',
          hintStyle: GoogleFonts.poppins(color: AppColors.onSurfaceVariant),
          prefixIcon: Icon(Icons.search, color: AppColors.onSurfaceVariant),
          suffixIcon: _searchQuery.isNotEmpty
              ? IconButton(
                  icon: Icon(Icons.clear, color: AppColors.onSurfaceVariant),
                  onPressed: () {
                    _searchController.clear();
                    setState(() {
                      _searchQuery = '';
                    });
                  },
                )
              : null,
          filled: true,
          fillColor: AppColors.surfaceContainerLow,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: AppColors.outlineVariant),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: AppColors.outlineVariant),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: AppColors.primary),
          ),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
      ),
    );
  }

  Widget _buildCategoryHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(top: 8, bottom: 8),
      child: Text(
        title,
        style: GoogleFonts.poppins(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: AppColors.primary,
        ),
      ),
    );
  }

  Widget _buildFaqTile(Map<String, String> faq) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.outlineVariant),
      ),
      child: ExpansionTile(
        tilePadding: const EdgeInsets.symmetric(horizontal: 16),
        childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        expandedCrossAxisAlignment: CrossAxisAlignment.start,
        iconColor: AppColors.primary,
        collapsedIconColor: AppColors.onSurfaceVariant,
        shape: const Border(),
        collapsedShape: const Border(),
        title: Text(
          faq['question']!,
          style: GoogleFonts.poppins(
            fontSize: 15,
            fontWeight: FontWeight.w500,
            color: AppColors.onSurface,
          ),
        ),
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              faq['answer']!,
              textAlign: TextAlign.left,
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: AppColors.onSurfaceVariant,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
