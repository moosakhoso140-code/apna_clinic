import 'package:flutter/material.dart';

import 'cardiologist.dart';
import 'doctors.dart';
import 'premiumDashborad.dart';
import 'vision.dart';
import 'dental.dart';
import 'medcine.dart';
// Only import what we need so names like Doctor / Store can't clash with your other files.
import 'appoinments.dart'
    show AppointmentsScreen, clinicStore, doctorById, dayLabel, fmtTime;

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _Category {
  final String title;
  final IconData icon;
  final Color color;
  final Color accent;
  final Widget Function()? screen; // null = coming soon

  const _Category(this.title, this.icon, this.color, this.accent, this.screen);
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  static const double _maxWidth = 520; // keeps the UI phone-sized on web

  late final List<_Category> _categories = [
    _Category('Cardio', Icons.favorite_rounded, const Color(0xFFE0F2FE),
        const Color(0xFF0284C7), () => const CardioDoctorsScreen()),
    _Category('Vision', Icons.remove_red_eye_rounded, const Color(0xFFFCE7F3),
        const Color(0xFFDB2777), () => const VisionDoctorsScreen()),
    _Category('Dental', Icons.clean_hands_rounded, const Color(0xFFDCFCE7),
        const Color(0xFF16A34A), () => const DentalDoctorsScreen()),
    _Category('Medicine', Icons.medication_rounded, const Color(0xFFCCFBF1),
        const Color(0xFF0D9488), () => MedicineScreen()),
    _Category('Brain', Icons.psychology_rounded, const Color(0xFFEDE9FE),
        const Color(0xFF7C3AED), null),
    _Category('Skin', Icons.spa_rounded, const Color(0xFFFFEDD5),
        const Color(0xFFEA580C), null),
    _Category('Bones', Icons.accessibility_new_rounded, const Color(0xFFFEF9C3),
        const Color(0xFFCA8A04), null),
    // Replaces the old "More" tile so the grid stays 2 rows of 4.
    _Category('Appointments', Icons.event_available_rounded,
        const Color(0xFFE0E7FF), const Color(0xFF4F46E5),
        () => const AppointmentsScreen()),
  ];

  final List<List<String>> _doctors = const [
    ['Dr. Martin Wood', 'Cardio specialist', '4.8'],
    ['Dr. Jenny Wilson', 'Cardio specialist', '4.5'],
    ['Dr. Sara Khan', 'Eye specialist', '4.7'],
  ];

  Future<void> _open(Widget screen) {
    return Navigator.push(
        context, MaterialPageRoute(builder: (_) => screen));
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : const Color(0xFF111827);
    final cardColor = isDark ? const Color(0xFF1E293B) : Colors.white;
    final borderColor = isDark ? Colors.grey[800]! : const Color(0xFFE5E7EB);

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: _maxWidth),
            child: SingleChildScrollView(
              padding:
                  const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(isDark, textColor, cardColor, borderColor),
                  const SizedBox(height: 20),
                  _buildSearchBar(cardColor, borderColor),
                  const SizedBox(height: 20),
                  _buildAppointmentCard(),
                  const SizedBox(height: 24),
                  _sectionTitle('Categories', textColor, isDark),
                  const SizedBox(height: 14),
                  _buildCategoryGrid(isDark, textColor),
                  const SizedBox(height: 24),
                  _buildPremiumBanner(),
                  const SizedBox(height: 24),
                  _sectionTitle('Top Doctors', textColor, isDark),
                  const SizedBox(height: 14),
                  for (final d in _doctors) ...[
                    _buildDoctorTile(d[0], d[1], d[2], isDark),
                    const SizedBox(height: 12),
                  ],
                  const SizedBox(height: 8),
                ],
              ),
            ),
          ),
        ),
      ),
      bottomNavigationBar: _buildBottomNav(isDark),
    );
  }

  // ───────────────────────── HEADER ─────────────────────────
  Widget _buildHeader(
      bool isDark, Color textColor, Color cardColor, Color borderColor) {
    return Row(
      children: [
        Container(
          width: 46,
          height: 46,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: const Color(0xFFE2EEDD),
            border: Border.all(
                color: isDark ? Colors.grey[700]! : Colors.white, width: 2),
          ),
          child: const Icon(Icons.person, color: Color(0xFF72A371), size: 28),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Welcome back 👋',
                  style: TextStyle(fontSize: 12, color: Colors.grey[500])),
              const SizedBox(height: 2),
              Text(
                'Muhammad Moosa',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: textColor),
              ),
            ],
          ),
        ),
        _circleButton(
          icon: Icons.notifications_outlined,
          iconColor: isDark ? Colors.white : Colors.black87,
          cardColor: cardColor,
          borderColor: borderColor,
          showDot: true,
          onTap: () {},
        ),
        const SizedBox(width: 8),
        // _circleButton(
        //   icon: Icons.chat_bubble_outline_rounded,
        //   iconColor: const Color(0xFF86B09A),
        //   cardColor: cardColor,
        //   borderColor: borderColor,
        //   onTap: () => _open(const AIChatScreen()),
        // ),
        const SizedBox(width: 8),
        _circleButton(
          icon: Icons.dashboard_customize_rounded,
          iconColor: const Color(0xFF86B09A),
          cardColor: cardColor,
          borderColor: borderColor,
          onTap: () => _open(const DoctorBookingScreen()),
        ),
      ],
    );
  }

  Widget _circleButton({
    required IconData icon,
    required Color iconColor,
    required Color cardColor,
    required Color borderColor,
    required VoidCallback onTap,
    bool showDot = false,
  }) {
    return InkWell(
      onTap: onTap,
      customBorder: const CircleBorder(),
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: cardColor,
          border: Border.all(color: borderColor),
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Icon(icon, size: 20, color: iconColor),
            if (showDot)
              Positioned(
                top: 9,
                right: 10,
                child: Container(
                  width: 7,
                  height: 7,
                  decoration: const BoxDecoration(
                      color: Colors.red, shape: BoxShape.circle),
                ),
              ),
          ],
        ),
      ),
    );
  }

  // ───────────────────────── SEARCH ─────────────────────────
  Widget _buildSearchBar(Color cardColor, Color borderColor) {
    return Container(
      height: 52,
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: borderColor),
      ),
      child: Row(
        children: [
          const SizedBox(width: 16),
          Icon(Icons.search, color: Colors.grey[400], size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search doctors, specialities...',
                hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14),
                border: InputBorder.none,
                isDense: true,
              ),
            ),
          ),
          InkWell(
            
            borderRadius: BorderRadius.circular(20),
            child: Container(
              margin: const EdgeInsets.only(right: 6),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                    colors: [Color(0xFFE2EEDD), Color(0xFFF3E8FF)]),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Row(
                children: [
                  Icon(Icons.auto_awesome, size: 14, color: Color(0xFF8B5CF6)),
                  SizedBox(width: 4),
                  Text('AI Mode',
                      style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1F2937))),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ───────────────────────── NEXT APPOINTMENT (live) ─────────────────────────
  Widget _buildAppointmentCard() {
    return ListenableBuilder(
      listenable: clinicStore, // updates whenever you book, check in or cancel
      builder: (context, _) {
        final waiting = clinicStore.waiting;
        final upcoming = clinicStore.upcoming;

        String label = 'Next appointment';
        String text = 'No appointments yet · Tap to book';
        if (waiting.isNotEmpty) {
          final a = waiting.first;
          label = 'Waiting now · Ticket #${a.ticket}';
          text = '${a.name} · ${doctorById(a.doctorId).name}';
        } else if (upcoming.isNotEmpty) {
          final a = upcoming.first;
          text =
              '${doctorById(a.doctorId).name} · ${dayLabel(a.day)}, ${fmtTime(a.time)}';
        }

        return Material(
          borderRadius: BorderRadius.circular(22),
          clipBehavior: Clip.antiAlias,
          color: Colors.transparent,
          child: Ink(
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFB1D8B2), Color(0xFFD7E9C9)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(22),
            ),
            child: InkWell(
              onTap: () => _open(const AppointmentsScreen()),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.7),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Icon(Icons.event_available_rounded,
                          color: Color(0xFF272E1E)),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(label,
                              style: const TextStyle(
                                  fontSize: 11, color: Color(0xFF3F4A33))),
                          const SizedBox(height: 2),
                          Text(text,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF272E1E))),
                        ],
                      ),
                    ),
                    const Icon(Icons.chevron_right_rounded,
                        color: Color(0xFF272E1E)),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  // ───────────────────────── CATEGORIES ─────────────────────────
  Widget _sectionTitle(String title, Color textColor, bool isDark) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title,
            style: TextStyle(
                fontSize: 18, fontWeight: FontWeight.bold, color: textColor)),
        Text('View All',
            style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: isDark ? Colors.grey[400] : Colors.grey[500])),
      ],
    );
  }

  Widget _buildCategoryGrid(bool isDark, Color textColor) {
    return GridView.count(
      crossAxisCount: 4,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: 0.82,
      children: _categories.map((c) {
        final isAppointments = c.title == 'Appointments';
        return Material(
          color: isDark ? const Color(0xFF1E293B) : c.color,
          borderRadius: BorderRadius.circular(20),
          child: InkWell(
            borderRadius: BorderRadius.circular(20),
            onTap: () {
              if (c.screen != null) {
                _open(c.screen!());
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('${c.title} is coming soon')),
                );
              }
            },
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isDark
                            ? c.accent.withOpacity(0.15)
                            : Colors.white.withOpacity(0.8),
                      ),
                      child: Icon(c.icon, size: 22, color: c.accent),
                    ),
                    // Small badge: how many patients are waiting right now.
                    if (isAppointments)
                      Positioned(
                        top: -4,
                        right: -4,
                        child: ListenableBuilder(
                          listenable: clinicStore,
                          builder: (_, __) {
                            final n = clinicStore.waiting.length;
                            if (n == 0) return const SizedBox.shrink();
                            return Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 5, vertical: 1),
                              decoration: BoxDecoration(
                                color: Colors.deepOrange,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text('$n',
                                  style: const TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white)),
                            );
                          },
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(c.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: textColor)),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  // ───────────────────────── PREMIUM BANNER ─────────────────────────
  Widget _buildPremiumBanner() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: Container(
        width: double.infinity,
        height: 200,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF4F7F63), Color(0xFF86B09A)],
          ),
        ),
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image.asset(
              'images.png',
              fit: BoxFit.cover,
              alignment: Alignment.centerRight,
              errorBuilder: (_, __, ___) => const SizedBox.shrink(),
            ),
            Container(color: Colors.black.withOpacity(0.35)),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text('★ PREMIUM',
                        style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: Colors.white)),
                  ),
                  const SizedBox(height: 10),
                  const Text('Premium plan',
                      style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white)),
                  const SizedBox(height: 6),
                  const SizedBox(
                    width: 220,
                    child: Text(
                      'Unlimited AI consults and priority booking',
                      style: TextStyle(
                          fontSize: 12, color: Colors.white70, height: 1.3),
                    ),
                  ),
                  const SizedBox(height: 14),
                  ElevatedButton(
                    onPressed: () => _open(const PremiumDashboardScreen()),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFD7D8B1),
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 18, vertical: 10),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20)),
                    ),
                    child: const Text('Get started',
                        style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF272E1E))),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ───────────────────────── DOCTOR TILE ─────────────────────────
  Widget _buildDoctorTile(
      String name, String specialty, String rating, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
            color: isDark ? Colors.grey[800]! : const Color(0xFFF0F2F5)),
        boxShadow: isDark
            ? null
            : [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
      ),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: const Color(0xFFE2EEDD),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(Icons.person, color: Color(0xFF72A371), size: 30),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name,
                    style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color:
                            isDark ? Colors.white : const Color(0xFF111827))),
                const SizedBox(height: 2),
                Text(specialty,
                    style: TextStyle(fontSize: 11, color: Colors.grey[500])),
                const SizedBox(height: 6),
                Row(
                  children: [
                    const Icon(Icons.star_rounded,
                        size: 16, color: Colors.amber),
                    const SizedBox(width: 4),
                    Text(rating,
                        style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: isDark ? Colors.white : Colors.black87)),
                  ],
                ),
              ],
            ),
          ),
          InkWell(
            onTap: () => _open(const DoctorBookingScreen()),
            borderRadius: BorderRadius.circular(16),
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
              decoration: BoxDecoration(
                  color: const Color(0xFFB1D8B2),
                  borderRadius: BorderRadius.circular(16)),
              child: const Text('Book now',
                  style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF272E1E))),
            ),
          ),
        ],
      ),
    );
  }

  // ───────────────────────── BOTTOM NAV ─────────────────────────
  Widget _buildBottomNav(bool isDark) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        border: Border(
            top: BorderSide(
                color: isDark ? Colors.grey[800]! : const Color(0xFFF0F2F5))),
      ),
      child: SafeArea(
        top: false,
        child: Center(
          heightFactor: 1,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: _maxWidth),
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildNavItem(Icons.home_rounded, 0, isDark),
                  _buildNavItem(Icons.favorite_border_rounded, 1, isDark),
                  _buildNavItem(Icons.auto_awesome, 2, isDark),
                  _buildNavItem(Icons.bar_chart_rounded, 3, isDark),
                  _buildNavItem(Icons.person_outline_rounded, 4, isDark),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(IconData icon, int index, bool isDark) {
    final selected = _currentIndex == index;
    return GestureDetector(
      onTap: () => setState(() => _currentIndex = index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFFB1D8B2) : Colors.transparent,
          shape: BoxShape.circle,
        ),
        child: Icon(
          icon,
          size: 22,
          color: selected
              ? const Color(0xFF272E1E)
              : (isDark ? Colors.grey[400] : Colors.grey[600]),
        ),
      ),
    );
  }
}