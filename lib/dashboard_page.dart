import 'dart:async';
import 'package:flutter/material.dart';
import 'login_page.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage>
    with TickerProviderStateMixin {
  // Pet Stats
  int _hunger = 70;
  int _happiness = 85;
  int _energy = 60;
  int _health = 90;
  int _level = 3;
  int _exp = 240;
  int _expMax = 300;
  String _petMood = 'happy';

  late AnimationController _petBounce;
  late AnimationController _sparkleController;
  late Animation<double> _bounceAnim;
  late Animation<double> _sparkleAnim;

  Timer? _statTimer;

  final List<Map<String, dynamic>> _activityLog = [
    {'icon': '🍎', 'text': 'Diberi makan', 'time': '2 menit lalu'},
    {'icon': '🎮', 'text': 'Main bersama', 'time': '15 menit lalu'},
    {'icon': '💤', 'text': 'Tidur siang', 'time': '1 jam lalu'},
  ];

  @override
  void initState() {
    super.initState();

    _petBounce = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);
    _bounceAnim = Tween<double>(begin: 0, end: -10).animate(
      CurvedAnimation(parent: _petBounce, curve: Curves.easeInOut),
    );

    _sparkleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();
    _sparkleAnim = Tween<double>(begin: 0, end: 1).animate(_sparkleController);

    // Gradually decrease stats
    _statTimer = Timer.periodic(const Duration(seconds: 10), (_) {
      setState(() {
        _hunger = (_hunger - 2).clamp(0, 100);
        _energy = (_energy - 1).clamp(0, 100);
        _updateMood();
      });
    });
  }

  void _updateMood() {
    if (_hunger < 30 || _energy < 30) {
      _petMood = 'sad';
    } else if (_happiness > 75 && _hunger > 60) {
      _petMood = 'excited';
    } else {
      _petMood = 'happy';
    }
  }

  String get _petEmoji {
    switch (_petMood) {
      case 'sad':
        return '😢';
      case 'excited':
        return '🤩';
      default:
        return '😊';
    }
  }

  void _feed() {
    setState(() {
      _hunger = (_hunger + 20).clamp(0, 100);
      _happiness = (_happiness + 5).clamp(0, 100);
      _exp = (_exp + 10).clamp(0, _expMax);
      _activityLog.insert(0, {
        'icon': '🍎',
        'text': 'Diberi makan',
        'time': 'Baru saja',
      });
      if (_activityLog.length > 5) _activityLog.removeLast();
      _updateMood();
    });
    _showAction('Nyam nyam! 😋 +20 Kenyang');
  }

  void _play() {
    setState(() {
      _happiness = (_happiness + 20).clamp(0, 100);
      _energy = (_energy - 10).clamp(0, 100);
      _exp = (_exp + 15).clamp(0, _expMax);
      _activityLog.insert(0, {
        'icon': '🎮',
        'text': 'Main bersama',
        'time': 'Baru saja',
      });
      if (_activityLog.length > 5) _activityLog.removeLast();
      _checkLevelUp();
      _updateMood();
    });
    _showAction('Yeay! Seru banget! 🎉 +20 Bahagia');
  }

  void _sleep() {
    setState(() {
      _energy = (_energy + 30).clamp(0, 100);
      _health = (_health + 10).clamp(0, 100);
      _activityLog.insert(0, {
        'icon': '💤',
        'text': 'Tidur siang',
        'time': 'Baru saja',
      });
      if (_activityLog.length > 5) _activityLog.removeLast();
      _updateMood();
    });
    _showAction('Zzz... Istirahat dulu~ 💤 +30 Energi');
  }

  void _checkLevelUp() {
    if (_exp >= _expMax) {
      _exp = _exp - _expMax;
      _level++;
      _expMax = (_expMax * 1.3).round();
      _showLevelUp();
    }
  }

  void _showAction(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: const TextStyle(fontWeight: FontWeight.w600)),
        backgroundColor: const Color(0xFF6C63FF),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _showLevelUp() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        backgroundColor: Colors.white,
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('🎊', style: TextStyle(fontSize: 56)),
            const SizedBox(height: 12),
            Text(
              'Level Up!',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w900,
                color: const Color(0xFF6C63FF),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Peliharaanmu sekarang Level $_level!',
              textAlign: TextAlign.center,
              style: const TextStyle(color: Color(0xFF8B7AA8)),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF6C63FF),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('Keren! 🚀',
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _petBounce.dispose();
    _sparkleController.dispose();
    _statTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFFF0EEFF),
              Color(0xFFFFF0F9),
              Color(0xFFE8F8FF),
            ],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ---- Header ----
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Halo, Trainer! 👋',
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey.shade500,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const Text(
                          'TamaCare',
                          style: TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.w900,
                            color: Color(0xFF2D1B4E),
                            letterSpacing: -0.8,
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        // Level Badge
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: const Color(0xFF6C63FF),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            'Lv. $_level',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w800,
                              fontSize: 13,
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        // Logout Button
                        GestureDetector(
                          onTap: () {
                            Navigator.of(context).pushReplacement(
                              MaterialPageRoute(
                                  builder: (_) => const LoginPage()),
                            );
                          },
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.08),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: const Icon(Icons.logout_rounded,
                                size: 18, color: Color(0xFFFF6B9D)),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                // ---- Pet Card ----
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [Color(0xFF6C63FF), Color(0xFFB06BE8)],
                    ),
                    borderRadius: BorderRadius.circular(28),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF6C63FF).withOpacity(0.4),
                        blurRadius: 24,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      // Pet Emoji
                      AnimatedBuilder(
                        animation: _bounceAnim,
                        builder: (_, child) => Transform.translate(
                          offset: Offset(0, _bounceAnim.value),
                          child: child,
                        ),
                        child: Text(
                          _petEmoji,
                          style: const TextStyle(fontSize: 80),
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Piko',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      Text(
                        _petMood == 'sad'
                            ? 'Butuh perhatian... 🥺'
                            : _petMood == 'excited'
                                ? 'Sangat bahagia! 🎉'
                                : 'Baik-baik saja! 😊',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.85),
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(height: 16),

                      // EXP Bar
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'EXP',
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.8),
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              Text(
                                '$_exp / $_expMax',
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.8),
                                  fontSize: 11,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: LinearProgressIndicator(
                              value: _exp / _expMax,
                              backgroundColor: Colors.white.withOpacity(0.25),
                              valueColor: const AlwaysStoppedAnimation<Color>(
                                  Colors.white),
                              minHeight: 8,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // ---- Stats ----
                const Text(
                  'Status Peliharaan',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF2D1B4E),
                  ),
                ),
                const SizedBox(height: 12),

                GridView.count(
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 1.7,
                  children: [
                    _buildStatCard('🍔', 'Lapar', _hunger, const Color(0xFFFF6B9D)),
                    _buildStatCard('😄', 'Bahagia', _happiness, const Color(0xFFFFB347)),
                    _buildStatCard('⚡', 'Energi', _energy, const Color(0xFF4ECDC4)),
                    _buildStatCard('❤️', 'Kesehatan', _health, const Color(0xFF6C63FF)),
                  ],
                ),

                const SizedBox(height: 20),

                // ---- Action Buttons ----
                const Text(
                  'Aksi',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF2D1B4E),
                  ),
                ),
                const SizedBox(height: 12),

                Row(
                  children: [
                    Expanded(child: _buildActionButton('🍎', 'Beri Makan', _feed, const Color(0xFFFF6B9D))),
                    const SizedBox(width: 10),
                    Expanded(child: _buildActionButton('🎮', 'Main', _play, const Color(0xFF6C63FF))),
                    const SizedBox(width: 10),
                    Expanded(child: _buildActionButton('💤', 'Tidur', _sleep, const Color(0xFF4ECDC4))),
                  ],
                ),

                const SizedBox(height: 20),

                // ---- Activity Log ----
                const Text(
                  'Aktivitas Terbaru',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF2D1B4E),
                  ),
                ),
                const SizedBox(height: 12),

                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.06),
                        blurRadius: 16,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    children: List.generate(_activityLog.length, (i) {
                      final item = _activityLog[i];
                      return Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 12),
                            child: Row(
                              children: [
                                Container(
                                  width: 40,
                                  height: 40,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFF0EEFF),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Center(
                                    child: Text(item['icon'],
                                        style: const TextStyle(fontSize: 20)),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        item['text'],
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w700,
                                          color: Color(0xFF2D1B4E),
                                          fontSize: 14,
                                        ),
                                      ),
                                      Text(
                                        item['time'],
                                        style: const TextStyle(
                                          color: Color(0xFF8B7AA8),
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          if (i < _activityLog.length - 1)
                            Divider(
                              height: 1,
                              color: Colors.grey.shade100,
                              indent: 16,
                              endIndent: 16,
                            ),
                        ],
                      );
                    }),
                  ),
                ),

                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard(String icon, String label, int value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            children: [
              Text(icon, style: const TextStyle(fontSize: 18)),
              const SizedBox(width: 6),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 12,
                  color: Color(0xFF8B7AA8),
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              Text(
                '$value%',
                style: TextStyle(
                  fontSize: 13,
                  color: color,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: value / 100,
              backgroundColor: color.withOpacity(0.15),
              valueColor: AlwaysStoppedAnimation<Color>(color),
              minHeight: 7,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(
      String icon, String label, VoidCallback onTap, Color color) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.12),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: color.withOpacity(0.2), width: 1.5),
        ),
        child: Column(
          children: [
            Text(icon, style: const TextStyle(fontSize: 26)),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}