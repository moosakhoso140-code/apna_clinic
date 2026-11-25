import 'package:flutter/material.dart';
class PremiumDashboardScreen extends StatelessWidget {
  const PremiumDashboardScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: isDarkMode ? Colors.white : Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Premium Membership',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: isDarkMode ? Colors.white : Colors.black87,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Unlock Full AI Health Power',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: isDarkMode ? Colors.white : const Color(0xFF111827),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Choose a plan starting from \$10 up to \$100 that fits your healthcare needs.',
              style: TextStyle(
                fontSize: 13,
                color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
              ),
            ),
            const SizedBox(height: 20),
            
            // Tier 1: Basic Plan ($10)
            _buildPlanCard(
              context: context,
              title: 'Basic Health Plan',
              price: '\$10',
              period: '/month',
              description: 'Standard AI medical assistance and report scanning.',
              features: ['50 AI Queries / mo', 'Document Uploads', 'Standard Support'],
              isDarkMode: isDarkMode,
              popular: false,
            ),
            const SizedBox(height: 16),

            // Tier 2: Pro Plan ($45)
            _buildPlanCard(
              context: context,
              title: 'Pro Care Plan',
              price: '\$45',
              period: '/month',
              description: 'Advanced diagnostics, priority doctor booking & voice support.',
              features: ['Unlimited AI Queries', 'Priority Doctor Booking', 'Voice Input & Analysis', '24/7 Support'],
              isDarkMode: isDarkMode,
              popular: true,
            ),
            const SizedBox(height: 16),

            // Tier 3: Ultimate Elite Plan ($100)
            _buildPlanCard(
              context: context,
              title: 'Ultimate Elite Family Plan',
              price: '\$100',
              period: '/year',
              description: 'Complete family coverage with dedicated specialist consultations.',
              features: ['All Pro Features', 'Family Access (Up to 5 Members)', 'Direct Video Consultations', 'Dedicated AI Specialist'],
              isDarkMode: isDarkMode,
              popular: false,
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildPlanCard({
    required BuildContext context,
    required String title,
    required String price,
    required String period,
    required String description,
    required List<String> features,
    required bool isDarkMode,
    required bool popular,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDarkMode ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: popular 
              ? const Color(0xFF86B09A) 
              : (isDarkMode ? Colors.grey[800]! : const Color(0xFFE5E7EB)),
          width: popular ? 2 : 1,
        ),
        boxShadow: [
          if (!isDarkMode)
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (popular)
            Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFFB1D8B2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text(
                'Most Popular',
                style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF272E1E)),
              ),
            ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: isDarkMode ? Colors.white : const Color(0xFF111827),
                ),
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    price,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF86B09A),
                    ),
                  ),
                  Text(
                    period,
                    style: TextStyle(fontSize: 11, color: Colors.grey[500]),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            description,
            style: TextStyle(fontSize: 12, color: Colors.grey[500], height: 1.3),
          ),
          const SizedBox(height: 14),
          Divider(color: isDarkMode ? Colors.grey[800] : const Color(0xFFF0F2F5)),
          const SizedBox(height: 10),
          ...features.map((feature) => Padding(
            padding: const EdgeInsets.only(bottom: 6.0),
            child: Row(
              children: [
                const Icon(Icons.check_circle_rounded, size: 16, color: Color(0xFF86B09A)),
                const SizedBox(width: 8),
                Text(
                  feature,
                  style: TextStyle(
                    fontSize: 12,
                    color: isDarkMode ? Colors.grey[300] : Colors.grey[700],
                  ),
                ),
              ],
            ),
          )),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Selected $title ($price). Proceeding to checkout...')),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: popular ? const Color(0xFFB1D8B2) : (isDarkMode ? const Color(0xFF0F172A) : const Color(0xFFF4F8F1)),
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
              ),
              child: Text(
                'Upgrade Plan',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: popular || isDarkMode ? const Color(0xFF272E1E) : const Color(0xFF111827),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

