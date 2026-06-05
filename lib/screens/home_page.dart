import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'chat_page.dart';
import 'chart_page.dart';
import '../services/api_service.dart';
import '../theme/astro_palette.dart';

class AstroHomePage extends StatefulWidget {
  const AstroHomePage({super.key});

  @override
  State<AstroHomePage> createState() => _AstroHomePageState();
}

class _AstroHomePageState extends State<AstroHomePage> {
  DailyEnergyResponse? _energy;
  final List<TransitItem> _transits = [];
  String _language = 'Eng';

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final energy = await ApiService.getDailyEnergy();
      if (mounted) setState(() => _energy = energy);
    } catch (_) {}
  }

  static IconData _planetIcon(String planet) {
    switch (planet.toLowerCase()) {
      case 'moon':
        return Icons.nightlight_round;
      case 'venus':
        return Icons.favorite_border_rounded;
      case 'mars':
        return Icons.local_fire_department_rounded;
      case 'jupiter':
        return Icons.expand_rounded;
      case 'saturn':
        return Icons.access_time_rounded;
      case 'mercury':
        return Icons.chat_bubble_outline_rounded;
      default:
        return Icons.auto_awesome;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AstroPalette.appBgTop,
      body: Stack(
        children: [
          const _CosmicBackground(),
          SafeArea(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const _TopBar(),
                  const SizedBox(height: 14),
                  _LanguageSelector(
                    selected: _language,
                    onChanged: (lang) => setState(() => _language = lang),
                  ),
                  const SizedBox(height: 16),
                  _HeroSection(isLoading: _energy == null),
                  const SizedBox(height: 18),
                  _TodayEnergyCard(
                    headline: _energy?.headline ?? 'A day for clarity\nand new beginnings',
                    description: _energy?.description ?? 'The Moon in Aquarius brings fresh ideas and inspiration.',
                  ),
                  const SizedBox(height: 22),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: const [
                      Text(
                        'Upcoming Transits',
                        style: TextStyle(
                          color: AstroPalette.darkTextStrong,
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Text(
                        'View all',
                        style: TextStyle(
                          color: AstroPalette.darkSecondary,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  if (_transits.isEmpty) ...[
                    const _TransitCard(
                      icon: Icons.auto_awesome,
                      title: 'Moon Trine Mercury',
                      subtitle: 'Good time for communication and sharing ideas.',
                      time: '2h 34m',
                    ),
                    const SizedBox(height: 12),
                    const _TransitCard(
                      icon: Icons.star_rounded,
                      title: 'Venus Square Mars',
                      subtitle: 'Watch for emotional intensity.',
                      time: '5h 12m',
                    ),
                  ] else ...List.generate(_transits.length, (i) => Padding(
                    padding: EdgeInsets.only(
                        bottom: i < _transits.length - 1 ? 12 : 0),
                    child: _TransitCard(
                      icon: _planetIcon(_transits[i].transitPlanet),
                      title: _transits[i].title,
                      subtitle: _transits[i].description,
                      time: _transits[i].timeUntil,
                    ),
                  )),
                  const SizedBox(height: 22),
                  const _AskBotCard(),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: _BottomBar(language: _language),
    );
  }
}

class _TopBar extends StatelessWidget {
  const _TopBar();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const CircleAvatar(
          radius: 23,
          backgroundColor: Color(0x33FFFFFF),
          child: Icon(Icons.person_outline, color: Colors.white),
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text(
              'Good morning ✨',
              style: TextStyle(
                color: AstroPalette.darkSecondary,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 2),
            Text(
              'Astreya',
              style: TextStyle(
                color: AstroPalette.darkTextStrong,
                fontSize: 24,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
        const Spacer(),
        _GlassCircleIcon(icon: Icons.star_border_rounded),
      ],
    );
  }
}



class _HeroSection extends StatelessWidget {
  final bool isLoading;
  const _HeroSection({required this.isLoading});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(30),
      child: SizedBox(
        height: 290,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(18, 16, 18, 18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Spacer(),
              Text(
                'Let’s align with\nthe stars',
                style: TextStyle(
                  color: AstroPalette.lightText,
                  fontSize: 32,
                  fontWeight: FontWeight.w700,
                  height: 1.02,
                ),
              ),
              SizedBox(height: 10),
              SizedBox(
                width: 235,
                child: Text(
                  'AI-powered insights for your cosmic journey',
                  style: TextStyle(
                    color: AstroPalette.lightTextSoft,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    height: 1.3,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TodayEnergyCard extends StatelessWidget {
  final String headline;
  final String description;

  const _TodayEnergyCard({
    required this.headline,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: const EdgeInsets.all(18),
      borderRadius: 28,
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Text(
                      "Today's Energy",
                      style: TextStyle(
                        color: AstroPalette.darkSecondary,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(width: 8),
                    _LiveBadge(),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  headline,
                  style: const TextStyle(
                    height: 1.15,
                    color: AstroPalette.darkText,
                    fontSize: 28,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  description,
                  style: const TextStyle(
                    color: AstroPalette.darkSecondary,
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 14),
          Container(
            width: 88,
            height: 88,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const LinearGradient(
                colors: [Color(0xFFF1E6FF), Color(0xFFD9C5FF)],
              ),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x55FFFFFF),
                  blurRadius: 24,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: const Icon(
              Icons.waves_rounded,
              size: 42,
              color: AstroPalette.accentStrong,
            ),
          ),
        ],
      ),
    );
  }
}

class _TransitCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final String time;

  const _TransitCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.time,
  });

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: const EdgeInsets.all(16),
      borderRadius: 24,
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const LinearGradient(
                colors: [Color(0xFFF1E6FF), Color(0xFFD9C5FF)],
              ),
            ),
            child: Icon(icon, color: AstroPalette.accentStrong),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: AstroPalette.darkText,
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: const TextStyle(
                    color: AstroPalette.darkSecondary,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Text(
            time,
            style: const TextStyle(
              color: AstroPalette.darkSecondary,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _AskBotCard extends StatelessWidget {
  const _AskBotCard();

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: const EdgeInsets.all(18),
      borderRadius: 28,
      child: Row(
        children: [
          Container(
            width: 58,
            height: 58,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [Color(0xFFF1E6FF), Color(0xFFB493F7)],
              ),
              boxShadow: [
                BoxShadow(
                  color: Color(0x66FFFFFF),
                  blurRadius: 20,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: const Icon(
              Icons.smart_toy_outlined,
              color: Colors.white,
              size: 28,
            ),
          ),
          const SizedBox(width: 14),
          const Expanded(
            child: Text(
              "Ask Astreya about love, transits, money, or today's mood.",
              style: TextStyle(
                color: AstroPalette.darkText,
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const AstroChatPage(),
              ),
            ),
            child: Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AstroPalette.lightGlassFill,
              ),
              child: const Icon(
                Icons.arrow_forward_rounded,
                color: AstroPalette.accentStrong,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _BottomBar extends StatelessWidget {
  final String language;
  const _BottomBar({required this.language});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 18),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: AstroPalette.lightGlassFill,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: AstroPalette.glassBorder),
        boxShadow: const [
          BoxShadow(
            color: AstroPalette.glowWhiteLilac,
            blurRadius: 22,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          const _BottomNavItem(icon: Icons.home_rounded, label: 'Home', active: true),
          GestureDetector(
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => AstroChartPage(initialLanguage: language)),
            ),
            child: const _BottomNavItem(icon: Icons.blur_circular_rounded, label: 'Chart'),
          ),
          const _BottomNavItem(icon: Icons.auto_awesome_rounded, label: 'Insights'),
          const _BottomNavItem(icon: Icons.person_outline_rounded, label: 'Profile'),
        ],
      ),
    );
  }
}

class _BottomNavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool active;

  const _BottomNavItem({
    required this.icon,
    required this.label,
    this.active = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 46,
          height: 46,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: active
                ? const LinearGradient(
                    colors: [Color(0xFFE8D7FF), Color(0xFFB493F7)],
                  )
                : null,
            color: active ? null : Colors.transparent,
          ),
          child: Icon(
            icon,
            color: active ? AstroPalette.darkText : AstroPalette.darkSecondary,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            color: active ? AstroPalette.accentStrong : AstroPalette.darkSecondary,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

class _GlassCircleIcon extends StatelessWidget {
  final IconData icon;
  const _GlassCircleIcon({required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 46,
      height: 46,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: AstroPalette.lightGlassFill,
        border: Border.all(color: AstroPalette.glassBorder),
      ),
      child: Icon(icon, color: AstroPalette.accentStrong),
    );
  }
}

class _LiveBadge extends StatelessWidget {
  const _LiveBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: AstroPalette.accent.withOpacity(0.22),
        borderRadius: BorderRadius.circular(999),
      ),
      child: const Text(
        'LIVE',
        style: TextStyle(
          color: AstroPalette.accentStrong,
          fontSize: 11,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class GlassCard extends StatelessWidget {
  final Widget child;
  final EdgeInsets padding;
  final double borderRadius;

  const GlassCard({
    super.key,
    required this.child,
    required this.padding,
    this.borderRadius = 24,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
        child: Container(
          padding: padding,
          decoration: BoxDecoration(
            color: AstroPalette.lightGlassFill,
            borderRadius: BorderRadius.circular(borderRadius),
            border: Border.all(
              color: AstroPalette.glassBorder,
              width: 1.1,
            ),
            boxShadow: const [
              BoxShadow(
                color: AstroPalette.glowLilacBlue,
                blurRadius: 18,
                offset: Offset(0, 8),
              ),
            ],
          ),
          child: child,
        ),
      ),
    );
  }
}

class _CosmicBackground extends StatefulWidget {
  const _CosmicBackground();

  @override
  State<_CosmicBackground> createState() => _CosmicBackgroundState();
}

class _CosmicBackgroundState extends State<_CosmicBackground> {
  VideoPlayerController? _controller;
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    _initVideo();
  }

  Future<void> _initVideo() async {
    final controller = VideoPlayerController.asset('assets/videos/astro.mp4');
    _controller = controller;
    try {
      await controller.initialize();
      await controller.setLooping(true);
      await controller.setVolume(0);
      await controller.play();
      if (mounted) setState(() => _initialized = true);
    } catch (_) {}
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final showVideo = _initialized && _controller != null;
    return Stack(
      children: [
        Container(
          decoration: const BoxDecoration(gradient: AstroPalette.appBackground),
        ),
        // Fullscreen looping video.
        if (showVideo)
          Positioned.fill(
            child: FittedBox(
              fit: BoxFit.cover,
              child: SizedBox(
                width: _controller!.value.size.width,
                height: _controller!.value.size.height,
                child: VideoPlayer(_controller!),
              ),
            ),
          ),
        Positioned.fill(
          child: Container(color: const Color(0x22886CDA)),
        ),
        Positioned(
          top: -90,
          left: -40,
          child: _glowBall(
            220,
            AstroPalette.glowWhiteLilac,
          ),
        ),
        Positioned(
          top: 120,
          right: -60,
          child: _glowBall(
            180,
            AstroPalette.glowLilacBlue,
          ),
        ),
        Positioned(
          bottom: 130,
          left: -30,
          child: _glowBall(
            160,
            AstroPalette.glowLilacMint,
          ),
        ),
        Positioned.fill(
          child: CustomPaint(
            painter: _StarsPainter(),
          ),
        ),
        Positioned(
          top: 70,
          left: 40,
          right: 40,
          child: Opacity(
            opacity: 0.12,
            child: CustomPaint(
              size: const Size(double.infinity, 320),
              painter: _TopOrbitPainter(),
            ),
          ),
        ),
      ],
    );
  }

  Widget _glowBall(double size, Color color) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color,
        boxShadow: [
          BoxShadow(
            color: color,
            blurRadius: 60,
            spreadRadius: 14,
          ),
        ],
      ),
    );
  }
}

class _StarsPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = AstroPalette.lightText.withOpacity(0.65);

    final stars = <Offset>[
      Offset(size.width * 0.12, size.height * 0.10),
      Offset(size.width * 0.28, size.height * 0.17),
      Offset(size.width * 0.82, size.height * 0.12),
      Offset(size.width * 0.74, size.height * 0.22),
      Offset(size.width * 0.18, size.height * 0.32),
      Offset(size.width * 0.90, size.height * 0.42),
      Offset(size.width * 0.23, size.height * 0.58),
      Offset(size.width * 0.62, size.height * 0.66),
      Offset(size.width * 0.14, size.height * 0.80),
      Offset(size.width * 0.86, size.height * 0.84),
      Offset(size.width * 0.50, size.height * 0.92),
    ];

    for (final star in stars) {
      canvas.drawCircle(star, 1.8, paint);
      canvas.drawCircle(
        star,
        4.0,
        Paint()..color = AstroPalette.glowWhiteLilac.withOpacity(0.28),
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _TopOrbitPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()
      ..color = AstroPalette.lightText.withOpacity(0.78)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;

    final rect1 = Rect.fromCenter(
      center: Offset(size.width * 0.65, size.height * 0.55),
      width: size.width * 0.92,
      height: size.height * 0.70,
    );
    final rect2 = Rect.fromCenter(
      center: Offset(size.width * 0.65, size.height * 0.55),
      width: size.width * 0.72,
      height: size.height * 0.50,
    );
    final rect3 = Rect.fromCenter(
      center: Offset(size.width * 0.65, size.height * 0.55),
      width: size.width * 0.52,
      height: size.height * 0.34,
    );

    canvas.drawArc(rect1, 0.1, 3.3, false, p);
    canvas.drawArc(rect2, 0.1, 3.6, false, p);
    canvas.drawArc(rect3, 0.1, 4.2, false, p);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
class _LanguageSelector extends StatelessWidget {
  final String selected;
  final ValueChanged<String> onChanged;

  const _LanguageSelector({required this.selected, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    const langs = [
      {'code': 'Eng', 'label': 'EN'},
      {'code': 'Rus', 'label': 'RU'},
      {'code': 'Heb', 'label': 'HE'},
      {'code': 'Spa', 'label': 'ES'},
    ];
    return Row(
      children: langs.map((l) {
        final code = l['code']!;
        final isSelected = selected == code;
        return Padding(
          padding: const EdgeInsets.only(right: 8),
          child: GestureDetector(
            onTap: () => onChanged(code),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                color: isSelected
                    ? null
                    : AstroPalette.lightGlassFill,
                gradient: isSelected ? AstroPalette.activeSurface : null,
                border: Border.all(
                  color: isSelected
                      ? AstroPalette.glassBorder
                      : AstroPalette.glassBorder,
                ),
              ),
              child: Text(
                l['label']!,
                style: TextStyle(
                  color: isSelected ? AstroPalette.darkText : AstroPalette.darkSecondary,
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}