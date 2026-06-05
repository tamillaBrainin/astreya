import 'dart:math' as math;
import 'dart:ui';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import '../services/api_service.dart';
import '../theme/astro_palette.dart';

// ─── Premium lilac theme for showDatePicker / showTimePicker dialogs ─────────
const _lilacBg        = AstroPalette.appBgTop;
const _lilacSurface   = Color(0xFFFFFBFF);
const _lilacPrimary   = Color(0xFF8F73E8);
const _lilacSoft      = Color(0xFFEAD9FF);
const _lilacText      = AstroPalette.darkText;
const _lilacTextSoft  = AstroPalette.darkSecondary;
const _lilacBorder    = Color(0xFFEFE6FF);

Widget _lilacPickerTheme(BuildContext context, Widget? child) {
  final base = Theme.of(context);
  return Theme(
    data: base.copyWith(
      colorScheme: const ColorScheme.light(
        primary: _lilacPrimary,
        onPrimary: Colors.white,
        secondary: _lilacSoft,
        onSecondary: _lilacText,
        surface: _lilacSurface,
        onSurface: _lilacText,
        surfaceTint: _lilacSoft,
        outline: _lilacBorder,
      ),
      scaffoldBackgroundColor: _lilacBg,
      dialogBackgroundColor: _lilacSurface,
      dialogTheme: const DialogThemeData(
        backgroundColor: _lilacSurface,
        surfaceTintColor: _lilacSurface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(28)),
        ),
      ),
      datePickerTheme: DatePickerThemeData(
        backgroundColor: _lilacSurface,
        surfaceTintColor: _lilacSurface,
        headerBackgroundColor: _lilacPrimary,
        headerForegroundColor: Colors.white,
        headerHeadlineStyle: const TextStyle(
          fontSize: 26, fontWeight: FontWeight.w600, color: Colors.white,
        ),
        headerHelpStyle: const TextStyle(
          fontSize: 12, fontWeight: FontWeight.w600,
          letterSpacing: 0.8, color: Colors.white,
        ),
        weekdayStyle: const TextStyle(
          color: _lilacTextSoft, fontWeight: FontWeight.w600,
        ),
        dayStyle: const TextStyle(color: _lilacText, fontWeight: FontWeight.w500),
        dayForegroundColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return Colors.white;
          if (states.contains(WidgetState.disabled)) {
            return _lilacTextSoft.withOpacity(0.35);
          }
          return _lilacText;
        }),
        dayBackgroundColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return _lilacPrimary;
          return null;
        }),
        dayOverlayColor: WidgetStateProperty.all(_lilacSoft.withOpacity(0.45)),
        todayForegroundColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return Colors.white;
          return _lilacPrimary;
        }),
        todayBackgroundColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return _lilacPrimary;
          return Colors.transparent;
        }),
        todayBorder: const BorderSide(color: _lilacPrimary, width: 1.2),
        yearForegroundColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return Colors.white;
          return _lilacText;
        }),
        yearBackgroundColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return _lilacPrimary;
          return null;
        }),
        yearOverlayColor: WidgetStateProperty.all(_lilacSoft.withOpacity(0.45)),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(28)),
        ),
        dividerColor: _lilacBorder.withOpacity(0.6),
      ),
      timePickerTheme: TimePickerThemeData(
        backgroundColor: _lilacSurface,
        hourMinuteColor: _lilacSoft.withOpacity(0.55),
        hourMinuteTextColor: _lilacText,
        dayPeriodColor: _lilacSoft.withOpacity(0.55),
        dayPeriodTextColor: _lilacText,
        dayPeriodBorderSide: const BorderSide(color: _lilacBorder),
        dialBackgroundColor: _lilacSoft.withOpacity(0.45),
        dialHandColor: _lilacPrimary,
        dialTextColor: _lilacText,
        entryModeIconColor: _lilacPrimary,
        helpTextStyle: const TextStyle(
          color: _lilacTextSoft,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.8,
        ),
        hourMinuteShape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: _lilacBorder),
        ),
        dayPeriodShape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: const BorderSide(color: _lilacBorder),
        ),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(28)),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: _lilacBg,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: _lilacBorder),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: _lilacBorder),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: _lilacPrimary, width: 1.5),
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: _lilacPrimary,
          textStyle: const TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
      textTheme: base.textTheme.apply(
        bodyColor: _lilacText,
        displayColor: _lilacText,
      ),
    ),
    child: child ?? const SizedBox.shrink(),
  );
}

class AstroChartPage extends StatefulWidget {
  final String initialLanguage;
  const AstroChartPage({super.key, this.initialLanguage = 'Eng'});

  @override
  State<AstroChartPage> createState() => _AstroChartPageState();
}

class _AstroChartPageState extends State<AstroChartPage> {
  int selectedTab = 0;
  ChartResponse? _chart;
  bool _birthDataSubmitted = false;

  DateTime? _birthDate;
  TimeOfDay? _birthTime;
  String? _birthCity;
  TransitResponse? _transits;
  bool _isLoadingTransits = false;
  String? _transitsError;
  String _language = 'Eng';

  List<String> get _tabs {
    switch (_language) {
      case 'Rus': return ['Общее', 'Планеты', 'Аспекты', 'Конфигурации', 'Транзиты'];
      case 'Heb': return ['כללי', 'כוכבי לכת', 'אספקטים', 'קונפיגורציות', 'מעברים'];
      case 'Spa': return ['General', 'Planetas', 'Aspectos', 'Configuraciones', 'Tránsitos'];
      default:    return ['General', 'Planets', 'Aspects', 'Configurations', 'Transits'];
    }
  }

  void _onBirthSubmit(DateTime date, TimeOfDay time, String location) {
    setState(() {
      selectedTab = 0;
      _birthDataSubmitted = true;
      _birthDate = date;
      _birthTime = time;
      _birthCity = location;
      _chart = null;
      _transits = null;
      _isLoadingTransits = false;
      _transitsError = null;
    });
    _loadChart(date, time, location);
  }

  Future<void> _loadTransits() async {
    if (_birthDate == null || _birthTime == null || _birthCity == null) return;
    if (mounted) {
      setState(() {
        _isLoadingTransits = true;
        _transits = null;
        _transitsError = null;
      });
    }
    try {
      final result = await ApiService.getTransitsForChart(
        year: _birthDate!.year,
        month: _birthDate!.month,
        day: _birthDate!.day,
        hour: _birthTime!.hour,
        minute: _birthTime!.minute,
        city: _birthCity!,
        language: _language,
      );
      if (mounted) {
        setState(() {
          _transits = result;
          _isLoadingTransits = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _transits = TransitResponse(transits: const [], interpretation: '');
          _isLoadingTransits = false;
          _transitsError = '$e';
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Transits error: $e'),
            backgroundColor: AstroPalette.heroBottom,
            duration: const Duration(seconds: 8),
          ),
        );
      }
    }
  }

  @override
  void initState() {
    super.initState();
    _language = widget.initialLanguage;
  }

  Future<void> _loadChart(DateTime date, TimeOfDay time, String location) async {
    try {
      final chart = await ApiService.getChart(
        year: date.year,
        month: date.month,
        day: date.day,
        hour: time.hour,
        minute: time.minute,
        city: location,
        language: _language,
      );
      if (mounted) {
        setState(() {
          _chart = chart;
        });
      }
      _loadTransits();
    } catch (e, stack) {
      // Print error and stack trace for debugging
      print('Chart error: $e');
      print('Stack trace: $stack');
      if (mounted) {
        // Reset so user can retry instead of being stuck on the loader.
        setState(() => _birthDataSubmitted = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Chart error: $e'),
            backgroundColor: AstroPalette.heroBottom,
            duration: const Duration(seconds: 12),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AstroPalette.appBgTop,
      body: Stack(
        children: [
          const _ChartBackground(),
          SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
                  child: _ChartTopBar(),
                ),
                const SizedBox(height: 20),
                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 28),
                    child: Column(
                      children: [
                        if (!_birthDataSubmitted)
                          _BirthInputCard(onSubmit: _onBirthSubmit)
                        else if (_chart == null)
                          const _ChartLoadingAnimation()
                        else ...[
                          _NatalChartWheel(chart: _chart),
                          const SizedBox(height: 18),
                          const _SummaryCard(),
                          const SizedBox(height: 18),
                          _TabsRow(
                            tabs: _tabs,
                            selectedIndex: selectedTab,
                            onTap: (index) {
                              setState(() => selectedTab = index);
                            },
                          ),
                          const SizedBox(height: 18),
                          _buildTabContent(),
                        ],
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _onLanguageChange(String lang) {
    if (lang == _language) return;
    setState(() {
      selectedTab = 0;
      _language = lang;
      _chart = null;
      _transits = null;
      _isLoadingTransits = false;
      _transitsError = null;
    });
    if (_birthDataSubmitted && _birthDate != null && _birthTime != null && _birthCity != null) {
      _loadChart(_birthDate!, _birthTime!, _birthCity!);
    }
  }

  Widget _buildLanguageSelector() {
    final langs = [
      {'code': 'Eng', 'flag': '🇬🇧', 'label': 'EN'},
      {'code': 'Rus', 'flag': '🇷🇺', 'label': 'RU'},
      {'code': 'Heb', 'flag': '🇮🇱', 'label': 'HE'},
      {'code': 'Spa', 'flag': '🇪🇸', 'label': 'ES'},
    ];
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
      child: Row(
        children: langs.map((l) {
          final code = l['code']!;
          final selected = _language == code;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: GestureDetector(
              onTap: () => _onLanguageChange(code),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  color: selected
                      ? null
                      : AstroPalette.lightGlassFill,
                  gradient: selected ? AstroPalette.activeSurface : null,
                  border: Border.all(
                    color: AstroPalette.glassBorder,
                  ),
                ),
                child: Text(
                  '${l['flag']} ${l['label']}',
                  style: TextStyle(
                    color: selected ? AstroPalette.darkText : AstroPalette.darkSecondary,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildTabContent() {
    switch (selectedTab) {
      case 0:
        return _GeneralTab(
          interpretation: _chart?.interpretation,
          language: _language,
        );
      case 1:
        return _PlanetsTab(
          planets: _chart?.planets,
          interpretations: _chart?.planetaryInterpretations ?? {},
          language: _language,
        );
      case 2:
        return _AspectsTab(
          planets: _chart?.planets,
          backendAspects: _chart?.aspects,
          aspectInterpretations: _chart?.aspectInterpretations ?? {},
          language: _language,
        );
      case 3:
        final backendPatterns = _chart?.patterns ?? [];
        final patterns = backendPatterns.isNotEmpty
            ? backendPatterns
            : _ConfigurationsTab.computeFromPlanets(_chart?.planets ?? []);
        return _ConfigurationsTab(
          patterns: patterns,
          patternInterpretations: _chart?.patternInterpretations ?? {},
          language: _language,
        );
      case 4:
        return _TransitsTab(
          response: _transits,
          language: _language,
          isLoading: _isLoadingTransits,
          error: _transitsError,
        );
      default:
        return const SizedBox.shrink();
    }
  }
}

class _ChartTopBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        GestureDetector(
          onTap: () => Navigator.pop(context),
          child: _glassCircle(
            const Icon(
              Icons.arrow_back_ios_new_rounded,
              size: 18,
              color: AstroPalette.accentStrong,
            ),
          ),
        ),
        const SizedBox(width: 14),
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Birth Chart',
                style: TextStyle(
                  color: AstroPalette.darkText,
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                ),
              ),
              SizedBox(height: 2),
              Text(
                'Natal chart',
                style: TextStyle(
                  color: AstroPalette.darkSecondary,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
        _glassCircle(
          const Icon(Icons.tune_rounded, color: Color(0xFF6E58C8)),
        ),
      ],
    );
  }

  Widget _glassCircle(Widget child) {
    return ClipOval(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
        child: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AstroPalette.lightGlassFill,
            border: Border.all(color: AstroPalette.glassBorder),
          ),
          child: Center(child: child),
        ),
      ),
    );
  }
}

class _NatalChartWheel extends StatelessWidget {
  final ChartResponse? chart;
  static const double _baseSize = 260;
  static const double _cx = _baseSize / 2;        // 130
  static const double _planetR = 72.0;            // radius for planet ring
  static const double _aspectR  = 52.0;           // radius for aspect line endpoints (inner)

  static const Map<String, String> _glyphs = {
    'Sun': '☉', 'Moon': '☽', 'Mercury': '☿', 'Venus': '♀',
    'Mars': '♂', 'Jupiter': '♃', 'Saturn': '♄', 'Uranus': '⛢',
    'Neptune': '♆', 'Pluto': '♇', 'Ascendant': '↑',
  };

  static const Map<String, Color> _colors = {
    'Sun':       Color(0xFFFFD080), 'Moon':    Color(0xFFB0C8FF),
    'Mercury':   Color(0xFFFFB8B8), 'Venus':   Color(0xFFFFD8E8),
    'Mars':      Color(0xFFFF9980), 'Jupiter': Color(0xFFD4FFAA),
    'Saturn':    Color(0xFFFFEEAA), 'Uranus':  Color(0xFFAAEEFF),
    'Neptune':   Color(0xFFCCAAFF), 'Pluto':   Color(0xFFE8CCFF),
    'Ascendant': Color(0xFFFFFFAA),
  };

  const _NatalChartWheel({this.chart});

  // Aries (0°) at top, clockwise
  static Offset _lonToOffset(double lon, double radius) {
    final a = (lon - 90) * math.pi / 180;
    return Offset(_cx + radius * math.cos(a), _cx + radius * math.sin(a));
  }

  @override
  Widget build(BuildContext context) {
    final planets = chart?.planets ?? [];
    final ascSign = chart?.ascendantSign ?? '';
    final label = ascSign.isNotEmpty ? 'ASC: $ascSign' : 'Natal Chart';

    return ClipRRect(
      borderRadius: BorderRadius.circular(28),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
        child: Container(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
          decoration: BoxDecoration(
            color: AstroPalette.darkGlassFill,
            borderRadius: BorderRadius.circular(28),
            border: Border.all(color: AstroPalette.glassBorder, width: 1.2),
          ),
          child: Column(
            children: [
              const Text(
                'Natal Chart',
                style: TextStyle(color: AstroPalette.lightTextSoft, fontSize: 18, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 12),
              LayoutBuilder(builder: (context, constraints) {
                final size = constraints.maxWidth;
                final scale = size / _baseSize;
                return SizedBox(
                  width: size,
                  height: size,
                  child: Stack(children: [
                    // Background image
                    Positioned.fill(
                      child: Image.asset('assets/images/natal_chart.png', fit: BoxFit.contain),
                    ),
                    // Aspect lines
                    if (planets.isNotEmpty)
                      Positioned.fill(
                        child: CustomPaint(
                          painter: _ChartAspectPainter(planets, scale, _aspectR),
                        ),
                      ),
                    // Planet dots
                    ...planets.map((p) {
                      final pos = _lonToOffset(p.longitude, _planetR);
                      return _dot(
                        pos.dx, pos.dy,
                        _glyphs[p.name] ?? '★',
                        p.sign.length >= 3 ? p.sign.substring(0, 3) : p.sign,
                        _colors[p.name] ?? const Color(0xFFCCCCFF),
                        scale,
                      );
                    }),
                  ]),
                );
              }),
              const SizedBox(height: 12),
              Text(
                label,
                style: const TextStyle(color: AstroPalette.lightTextSoft, fontSize: 13, fontWeight: FontWeight.w500),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _dot(double cx, double cy, String glyph, String sign, Color color, double scale) {
    final dotSize = 22.0 * scale;
    final fontSize = 11.0 * scale;
    final signFontSize = 7.0 * scale;
    return Positioned(
      left: cx * scale - dotSize / 2,
      top:  cy * scale - dotSize / 2 - 2,
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Container(
          width: dotSize, height: dotSize,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: color.withOpacity(0.92),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.28), blurRadius: 4, offset: const Offset(0, 1))],
          ),
          child: Center(child: Text(glyph, style: TextStyle(fontSize: fontSize, height: 1, color: const Color(0xFF2A1F50)))),
        ),
        SizedBox(height: 2 * scale),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 3 * scale, vertical: 1 * scale),
          decoration: BoxDecoration(color: color.withOpacity(0.88), borderRadius: BorderRadius.circular(4)),
          child: Text(sign, style: TextStyle(fontSize: signFontSize, fontWeight: FontWeight.w700, color: const Color(0xFF2A1F50), height: 1)),
        ),
      ]),
    );
  }
}

class _ChartAspectPainter extends CustomPainter {
  final List<PlanetPosition> planets;
  final double scale;
  final double radius;

  static const _aspectAngles = [0.0,   60.0,  90.0,   120.0,  150.0,  180.0];
  static const _aspectOrbs   = [8.0,   6.0,   8.0,    8.0,    3.0,    8.0];
  static const _aspectColors = [
    Color(0xFFBB99FF), Color(0xFF6DBD8C), Color(0xFFE86060),
    Color(0xFF6AACEE), Color(0xFFE0B050), Color(0xFFE87A50),
  ];

  const _ChartAspectPainter(this.planets, this.scale, this.radius);

  Offset _lonToOffset(double lon) {
    final a = (lon - 90) * math.pi / 180;
    return Offset(
      (_NatalChartWheel._cx + radius * math.cos(a)) * scale,
      (_NatalChartWheel._cx + radius * math.sin(a)) * scale,
    );
  }

  @override
  void paint(Canvas canvas, Size size) {
    for (int i = 0; i < planets.length; i++) {
      for (int j = i + 1; j < planets.length; j++) {
        final diff  = (planets[i].longitude - planets[j].longitude).abs();
        final angle = diff > 180 ? 360 - diff : diff;
        for (int k = 0; k < _aspectAngles.length; k++) {
          if ((angle - _aspectAngles[k]).abs() <= _aspectOrbs[k]) {
            final p1 = _lonToOffset(planets[i].longitude);
            final p2 = _lonToOffset(planets[j].longitude);
            canvas.drawLine(p1, p2,
              Paint()
                ..color = _aspectColors[k].withOpacity(0.55)
                ..strokeWidth = 1.0 * scale
                ..style = PaintingStyle.stroke,
            );
            break;
          }
        }
      }
    }
  }

  @override
  bool shouldRepaint(covariant _ChartAspectPainter old) =>
      old.planets != planets || old.scale != scale;
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard();

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: AstroPalette.darkGlassFill,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: AstroPalette.glassBorder,
              width: 1.2,
            ),
          ),
          child: const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Overall Portrait',
                style: TextStyle(
                  color: AstroPalette.lightTextSoft,
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
              SizedBox(height: 10),
              Text(
                'You come across as serious, composed, and deep. '
                'Inside, emotional restraint, strong will, and a need for '
                'stability are combined. Your chart shows an ability to move toward goals slowly but very steadily.',
                style: TextStyle(
                  color: AstroPalette.lightTextSoft,
                  fontSize: 14,
                  height: 1.45,
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(height: 14),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _TagChip(label: 'Practicality'),
                  _TagChip(label: 'Depth'),
                  _TagChip(label: 'Self-control'),
                  _TagChip(label: 'Ambition'),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TagChip extends StatelessWidget {
  final String label;

  const _TagChip({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(999),
        color: AstroPalette.accent.withOpacity(0.26),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: AstroPalette.darkText,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _TabsRow extends StatelessWidget {
  final List<String> tabs;
  final int selectedIndex;
  final ValueChanged<int> onTap;

  const _TabsRow({
    required this.tabs,
    required this.selectedIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(tabs.length, (index) {
        final selected = index == selectedIndex;

        return Expanded(
          child: Padding(
            padding: EdgeInsets.only(right: index == tabs.length - 1 ? 0 : 8),
            child: GestureDetector(
              onTap: () => onTap(index),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 220),
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(18),
                  gradient: selected
                      ? AstroPalette.activeSurface
                      : null,
                  color: selected ? null : AstroPalette.lightGlassFill,
                  border: Border.all(
                    color: AstroPalette.glassBorder,
                  ),
                ),
                child: Text(
                  tabs[index],
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: selected
                        ? AstroPalette.darkText
                        : AstroPalette.darkSecondary,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ),
        );
      }),
    );
  }
}

class _GeneralTab extends StatelessWidget {
  final String? interpretation;
  final bool isLoading;
  final String language;
  const _GeneralTab({
    this.interpretation,
    this.isLoading = false,
    this.language = 'Eng',
  });

  static const _emptyTitle = {
    'Eng': 'Interpretation unavailable',
    'Rus': 'Интерпретация недоступна',
    'Heb': 'הפרשנות אינה זמינה',
    'Spa': 'Interpretacion no disponible',
  };

  static const _emptyText = {
    'Eng': 'The chart data loaded, but the narrative interpretation did not return in time.',
    'Rus': 'Данные карты загрузились, но текстовая интерпретация не успела вернуться.',
    'Heb': 'נתוני המפה נטענו, אך הפרשנות הטקסטואלית לא חזרה בזמן.',
    'Spa': 'Los datos de la carta se cargaron, pero la interpretacion textual no regreso a tiempo.',
  };

  @override
  Widget build(BuildContext context) {
    final isRtl = language == 'Heb';
    if (isLoading) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.13),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.white.withOpacity(0.22)),
            ),
            child: const Center(
              child: CircularProgressIndicator(
                color: Color(0xFF9B7FD4),
                strokeWidth: 2,
              ),
            ),
          ),
        ),
      );
    }
    if (interpretation == null || interpretation!.trim().isEmpty) {
      final lang = _emptyTitle.containsKey(language) ? language : 'Eng';
      return _InfoCard(
        title: _emptyTitle[lang] ?? _emptyTitle['Eng']!,
        text: _emptyText[lang] ?? _emptyText['Eng']!,
      );
    }
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.13),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white.withOpacity(0.22)),
          ),
          child: Text(
            interpretation!,
            textDirection: isRtl ? TextDirection.rtl : TextDirection.ltr,
            textAlign: isRtl ? TextAlign.right : TextAlign.left,
            style: const TextStyle(
              color: Color(0xFF34285C),
              fontSize: 14,
              height: 1.7,
              fontWeight: FontWeight.w400,
            ),
          ),
        ),
      ),
    );
  }
}

class _PlanetsTab extends StatelessWidget {
  final List<PlanetPosition>? planets;
  final Map<String, String> interpretations;
  final String language;

  const _PlanetsTab({this.planets, this.interpretations = const {}, this.language = 'Eng'});

  static const Map<String, String> _glyphs = {
    'Sun': '\u2600\ufe0f', 'Moon': '\ud83c\udf19', 'Mercury': '\u263f',
    'Venus': '\u2640', 'Mars': '\u2642', 'Jupiter': '\u2643',
    'Saturn': '\u2644', 'Uranus': '\u2645', 'Neptune': '\u2646', 'Pluto': '\u2647',
  };

  static const _names = {
    'Eng': {'Sun':'Sun','Moon':'Moon','Mercury':'Mercury','Venus':'Venus','Mars':'Mars','Jupiter':'Jupiter','Saturn':'Saturn','Uranus':'Uranus','Neptune':'Neptune','Pluto':'Pluto'},
    'Rus': {'Sun':'Солнце','Moon':'Луна','Mercury':'Меркурий','Venus':'Венера','Mars':'Марс','Jupiter':'Юпитер','Saturn':'Сатурн','Uranus':'Уран','Neptune':'Нептун','Pluto':'Плутон'},
    'Heb': {'Sun':'שמש','Moon':'ירח','Mercury':'כוכב חמה','Venus':'נוגה','Mars':'מאדים','Jupiter':'צדק','Saturn':'שבתאי','Uranus':'אורנוס','Neptune':'נפטון','Pluto':'פלוטו'},
    'Spa': {'Sun':'Sol','Moon':'Luna','Mercury':'Mercurio','Venus':'Venus','Mars':'Marte','Jupiter':'Júpiter','Saturn':'Saturno','Uranus':'Urano','Neptune':'Neptuno','Pluto':'Plutón'},
  };

  static const _signs = {
    'Eng': {'Aries':'Aries','Taurus':'Taurus','Gemini':'Gemini','Cancer':'Cancer','Leo':'Leo','Virgo':'Virgo','Libra':'Libra','Scorpio':'Scorpio','Sagittarius':'Sagittarius','Capricorn':'Capricorn','Aquarius':'Aquarius','Pisces':'Pisces'},
    'Rus': {'Aries':'Овен','Taurus':'Телец','Gemini':'Близнецы','Cancer':'Рак','Leo':'Лев','Virgo':'Дева','Libra':'Весы','Scorpio':'Скорпион','Sagittarius':'Стрелец','Capricorn':'Козерог','Aquarius':'Водолей','Pisces':'Рыбы'},
    'Heb': {'Aries':'טלה','Taurus':'שור','Gemini':'תאומים','Cancer':'סרטן','Leo':'אריה','Virgo':'בתולה','Libra':'מאזניים','Scorpio':'עקרב','Sagittarius':'קשת','Capricorn':'גדי','Aquarius':'דלי','Pisces':'דגים'},
    'Spa': {'Aries':'Aries','Taurus':'Tauro','Gemini':'Géminis','Cancer':'Cáncer','Leo':'Leo','Virgo':'Virgo','Libra':'Libra','Scorpio':'Escorpio','Sagittarius':'Sagitario','Capricorn':'Capricornio','Aquarius':'Acuario','Pisces':'Piscis'},
  };

  static const _houseLabel = {
    'Eng': 'House', 'Rus': 'Дом', 'Heb': 'בית', 'Spa': 'Casa',
  };

  String _fallbackDescription(PlanetPosition planet, String lang) {
    final sign = _signs[lang]?[planet.sign] ?? planet.sign;
    switch (lang) {
      case 'Heb':
        return '${_names[lang]?[planet.name] ?? planet.name} ב-$sign מדגיש ${_planetTheme(planet.name, lang)} דרך נושאי ${_houseTheme(planet.house, lang)}.';
      case 'Rus':
        return '${_names[lang]?[planet.name] ?? planet.name} в знаке $sign подчёркивает ${_planetTheme(planet.name, lang)} через темы ${_houseTheme(planet.house, lang)}.';
      case 'Spa':
        return '${_names[lang]?[planet.name] ?? planet.name} en $sign resalta ${_planetTheme(planet.name, lang)} a traves de ${_houseTheme(planet.house, lang)}.';
      default:
        return '${planet.name} in $sign highlights ${_planetTheme(planet.name, lang)} through ${_houseTheme(planet.house, lang)}.';
    }
  }

  String _planetTheme(String planet, String lang) {
    const themes = {
      'Eng': {
        'Sun': 'identity and purpose',
        'Moon': 'emotional needs and instincts',
        'Mercury': 'thinking and communication',
        'Venus': 'relationships and values',
        'Mars': 'drive and action',
        'Jupiter': 'growth and confidence',
        'Saturn': 'discipline and responsibility',
        'Uranus': 'change and independence',
        'Neptune': 'imagination and sensitivity',
        'Pluto': 'depth and transformation',
      },
      'Rus': {
        'Sun': 'личность и предназначение',
        'Moon': 'эмоции и инстинкты',
        'Mercury': 'мышление и общение',
        'Venus': 'отношения и ценности',
        'Mars': 'волю и действие',
        'Jupiter': 'рост и уверенность',
        'Saturn': 'дисциплину и ответственность',
        'Uranus': 'перемены и независимость',
        'Neptune': 'воображение и чувствительность',
        'Pluto': 'глубину и трансформацию',
      },
      'Heb': {
        'Sun': 'זהות ומטרה',
        'Moon': 'צרכים רגשיים ואינסטינקטים',
        'Mercury': 'חשיבה ותקשורת',
        'Venus': 'יחסים וערכים',
        'Mars': 'דחף ופעולה',
        'Jupiter': 'צמיחה ובטחון',
        'Saturn': 'משמעת ואחריות',
        'Uranus': 'שינוי ועצמאות',
        'Neptune': 'דמיון ורגישות',
        'Pluto': 'עומק וטרנספורמציה',
      },
      'Spa': {
        'Sun': 'identidad y proposito',
        'Moon': 'necesidades emocionales e instintos',
        'Mercury': 'pensamiento y comunicacion',
        'Venus': 'relaciones y valores',
        'Mars': 'impulso y accion',
        'Jupiter': 'crecimiento y confianza',
        'Saturn': 'disciplina y responsabilidad',
        'Uranus': 'cambio e independencia',
        'Neptune': 'imaginacion y sensibilidad',
        'Pluto': 'profundidad y transformacion',
      },
    };
    return themes[lang]?[planet] ?? themes['Eng']?[planet] ?? 'core traits';
  }

  String _houseTheme(int house, String lang) {
    const themes = {
      'Eng': {
        1: 'self-expression', 2: 'security and resources', 3: 'learning and communication',
        4: 'home and roots', 5: 'creativity and romance', 6: 'work and daily routines',
        7: 'partnerships', 8: 'shared emotions and trust', 9: 'belief and exploration',
        10: 'career and public life', 11: 'friends and future goals', 12: 'inner life and healing',
      },
      'Rus': {
        1: 'самовыражения', 2: 'безопасности и ресурсов', 3: 'обучения и общения',
        4: 'дома и корней', 5: 'творчества и романтики', 6: 'работы и повседневных дел',
        7: 'партнерства', 8: 'доверия и глубинных процессов', 9: 'убеждений и расширения горизонтов',
        10: 'карьеры и статуса', 11: 'друзей и будущих целей', 12: 'внутреннего мира и исцеления',
      },
      'Heb': {
        1: 'ביטוי עצמי', 2: 'בטחון ומשאבים', 3: 'למידה ותקשורת',
        4: 'בית ושורשים', 5: 'יצירה ורומנטיקה', 6: 'עבודה ושגרה',
        7: 'שותפויות', 8: 'אמון ועומק רגשי', 9: 'אמונה והתרחבות',
        10: 'קריירה ותדמית ציבורית', 11: 'חברים ומטרות עתידיות', 12: 'עולם פנימי וריפוי',
      },
      'Spa': {
        1: 'expresion personal', 2: 'seguridad y recursos', 3: 'aprendizaje y comunicacion',
        4: 'hogar y raices', 5: 'creatividad y romance', 6: 'trabajo y rutina diaria',
        7: 'parejas y alianzas', 8: 'confianza y profundidad emocional', 9: 'creencias y expansion',
        10: 'carrera y vida publica', 11: 'amistades y metas futuras', 12: 'vida interior y sanacion',
      },
    };
    return themes[lang]?[house] ?? themes['Eng']?[house] ?? 'life themes';
  }

  @override
  Widget build(BuildContext context) {
    final lang = _names.containsKey(language) ? language : 'Eng';
    if (planets != null && planets!.isNotEmpty) {
      return Column(
        children: List.generate(planets!.length, (i) {
          final p = planets![i];
          final glyph = _glyphs[p.name] ?? '\u2605';
          final name = _names[lang]?[p.name] ?? p.name;
          final sign = _signs[lang]?[p.sign] ?? p.sign;
          final houseWord = _houseLabel[lang] ?? 'House';
          final house = lang == 'Rus' ? '$houseWord ${p.house}' : '$houseWord ${p.house}';
          final header = '$glyph $name';
            final description = (interpretations[p.name] ?? '').trim().isNotEmpty
              ? interpretations[p.name]!
              : _fallbackDescription(p, lang);
          return Padding(
            padding: EdgeInsets.only(bottom: i < planets!.length - 1 ? 12 : 0),
            child: _PlanetCard(
              planet: header,
              sign: sign,
              house: house,
              description: description,
            ),
          );
        }),
      );
    }
    return Column(
      children: const [
        _PlanetCard(
          planet: '☀️ Sun',
          sign: 'Capricorn',
          house: '3rd House',
          description:
              'Deep, ambitious drive. You build with patience and purpose.',
        ),
        SizedBox(height: 12),
        _PlanetCard(
          planet: '🌙 Moon',
          sign: 'Capricorn',
          house: '12th House',
          description:
              'Private emotions, inner strength, depth beneath the surface.',
        ),
        SizedBox(height: 12),
        _PlanetCard(
          planet: '☿ Mercury',
          sign: 'Gemini',
          house: '9th House',
          description:
              'Quick, curious mind drawn to philosophy and distant horizons.',
        ),
        SizedBox(height: 12),
        _PlanetCard(
          planet: '♀ Venus',
          sign: 'Cancer',
          house: '7th House',
          description:
              'Deep longing for emotional bonds and nurturing partnerships.',
        ),
        SizedBox(height: 12),
        _PlanetCard(
          planet: '♂ Mars',
          sign: 'Gemini',
          house: '8th House',
          description:
              'Sharp, restless energy. You pursue goals with wit and intensity.',
        ),
        SizedBox(height: 12),
        _PlanetCard(
          planet: '♃ Jupiter',
          sign: 'Aries',
          house: '10th House',
          description:
              'Bold ambition at the top. Career marked by leadership and growth.',
        ),
        SizedBox(height: 12),
        _PlanetCard(
          planet: '♄ Saturn',
          sign: 'Leo',
          house: '6th House',
          description:
              'Discipline through daily work. Mastery takes time but shines bright.',
        ),
        SizedBox(height: 12),
        _PlanetCard(
          planet: '♅ Uranus',
          sign: 'Aquarius',
          house: '2nd House',
          description:
              'Unconventional approach to finances and personal values.',
        ),
        SizedBox(height: 12),
        _PlanetCard(
          planet: '♆ Neptune',
          sign: 'Sagittarius',
          house: '3rd House',
          description:
              'Inspired, visionary communication. Dreams color every thought.',
        ),
      ],
    );
  }
}

class _AspectEntry {
  final String p1, p2, name, sym, keyword;
  final double orb;
  final Color color;
  _AspectEntry({
    required this.p1,
    required this.p2,
    required this.name,
    required this.sym,
    required this.orb,
    required this.color,
    required this.keyword,
  });
}

class _AspectsTab extends StatelessWidget {
  final List<PlanetPosition>? planets;
  final List<AspectInfo>? backendAspects;
  final Map<String, String> aspectInterpretations;
  final String language;
  const _AspectsTab({
    this.planets,
    this.backendAspects,
    this.aspectInterpretations = const {},
    this.language = 'Eng',
  });

  static const _aspectNames = {
    'Eng': {'Conjunction':'Conjunction','Sextile':'Sextile','Square':'Square','Trine':'Trine','Quincunx':'Quincunx','Opposition':'Opposition'},
    'Rus': {'Conjunction':'Соединение','Sextile':'Секстиль','Square':'Квадрат','Trine':'Трин','Quincunx':'Квинкункс','Opposition':'Оппозиция'},
    'Heb': {'Conjunction':'קונג׳אנקשן','Sextile':'סקסטיל','Square':'ריבוע','Trine':'טרין','Quincunx':'קווינקונקס','Opposition':'אופוזיציה'},
    'Spa': {'Conjunction':'Conjunción','Sextile':'Sextil','Square':'Cuadratura','Trine':'Trígono','Quincunx':'Quincuncio','Opposition':'Oposición'},
  };

  static const _aspectKeywords = {
    'Eng': {'Conjunction':'Merging energies','Sextile':'Opportunity & flow','Square':'Tension & growth','Trine':'Harmony & ease','Quincunx':'Adjustment needed','Opposition':'Balance & polarity'},
    'Rus': {'Conjunction':'Слияние энергий','Sextile':'Возможности и поток','Square':'Напряжение и рост','Trine':'Гармония и лёгкость','Quincunx':'Требуется коррекция','Opposition':'Баланс и полярность'},
    'Heb': {'Conjunction':'מיזוג אנרגיות','Sextile':'הזדמנות וזרימה','Square':'מתח וצמיחה','Trine':'הרמוניה וקלות','Quincunx':'נדרשת התאמה','Opposition':'איזון וקוטביות'},
    'Spa': {'Conjunction':'Fusión de energías','Sextile':'Oportunidad y flujo','Square':'Tensión y crecimiento','Trine':'Armonía y facilidad','Quincunx':'Ajuste necesario','Opposition':'Balance y polaridad'},
  };

  static const _planetNames = {
    'Eng': {'Sun':'Sun','Moon':'Moon','Mercury':'Mercury','Venus':'Venus','Mars':'Mars','Jupiter':'Jupiter','Saturn':'Saturn','Uranus':'Uranus','Neptune':'Neptune','Pluto':'Pluto','Ascendant':'Ascendant'},
    'Rus': {'Sun':'Солнце','Moon':'Луна','Mercury':'Меркурий','Venus':'Венера','Mars':'Марс','Jupiter':'Юпитер','Saturn':'Сатурн','Uranus':'Уран','Neptune':'Нептун','Pluto':'Плутон','Ascendant':'Асцендент'},
    'Heb': {'Sun':'שמש','Moon':'ירח','Mercury':'כוכב חמה','Venus':'נוגה','Mars':'מאדים','Jupiter':'צדק','Saturn':'שבתאי','Uranus':'אורנוס','Neptune':'נפטון','Pluto':'פלוטו','Ascendant':'אסצנדנט'},
    'Spa': {'Sun':'Sol','Moon':'Luna','Mercury':'Mercurio','Venus':'Venus','Mars':'Marte','Jupiter':'Júpiter','Saturn':'Saturno','Uranus':'Urano','Neptune':'Neptuno','Pluto':'Plutón','Ascendant':'Ascendente'},
  };

  List<_AspectEntry> _fromBackend(List<AspectInfo> src) {
    const symMap = {
      'Conjunction': '☌', 'Sextile': '⚹', 'Square': '□',
      'Trine': '△', 'Quincunx': '⚻', 'Opposition': '☍',
    };
    const colorMap = {
      'Conjunction': Color(0xFF9B7FD4), 'Sextile':  Color(0xFF5BAD8A),
      'Square':      Color(0xFFD45C5C), 'Trine':    Color(0xFF5B9BD4),
      'Quincunx':    Color(0xFFD4A85C), 'Opposition': Color(0xFFD47A5C),
    };
    final lang = _aspectKeywords.containsKey(language) ? language : 'Eng';
    return src.map((a) => _AspectEntry(
      p1: a.planet1, p2: a.planet2, name: a.aspect,
      sym:     symMap[a.aspect]  ?? '·',
      color:   colorMap[a.aspect] ?? const Color(0xFF9B7FD4),
      keyword: _aspectKeywords[lang]?[a.aspect] ?? '',
      orb: a.orb,
    )).toList();
  }

  List<_AspectEntry> _compute(List<PlanetPosition> ps) {
    const names    = ['Conjunction', 'Sextile', 'Square', 'Trine', 'Quincunx', 'Opposition'];
    const syms     = ['☌', '⚹', '□', '△', '⚻', '☍'];
    const angles   = [0.0, 60.0, 90.0, 120.0, 150.0, 180.0];
    const maxOrbs  = [8.0, 6.0,  8.0,  8.0,   3.0,   8.0];
    const colors   = [Color(0xFF9B7FD4), Color(0xFF5BAD8A), Color(0xFFD45C5C), Color(0xFF5B9BD4), Color(0xFFD4A85C), Color(0xFFD47A5C)];
    final lang = _aspectKeywords.containsKey(language) ? language : 'Eng';

    final results = <_AspectEntry>[];
    for (int i = 0; i < ps.length; i++) {
      for (int j = i + 1; j < ps.length; j++) {
        final diff  = (ps[i].longitude - ps[j].longitude).abs();
        final angle = diff > 180 ? 360 - diff : diff;
        for (int k = 0; k < names.length; k++) {
          final actualOrb = (angle - angles[k]).abs();
          if (actualOrb <= maxOrbs[k]) {
            results.add(_AspectEntry(
              p1: ps[i].name, p2: ps[j].name,
              name: names[k], sym: syms[k],
              orb: actualOrb, color: colors[k],
              keyword: _aspectKeywords[lang]?[names[k]] ?? '',
            ));
            break;
          }
        }
      }
    }
    results.sort((a, b) => a.orb.compareTo(b.orb));
    return results;
  }

  String _fallbackAspectDescription(_AspectEntry aspect, String p1Name, String p2Name, String aspectName) {
    switch (language) {
      case 'Heb':
        return '$p1Name ו-$p2Name יוצרים ${_aspectKeywords['Heb']?[aspect.name] ?? aspectName.toLowerCase()}, ולכן זהו נושא מרכזי במפה שדורש מודעות ודיוק.';
      case 'Rus':
        return '$p1Name и $p2Name создают тему «${_aspectKeywords['Rus']?[aspect.name] ?? aspectName.toLowerCase()}», поэтому этот аспект заметно влияет на характер и реакции.';
      case 'Spa':
        return '$p1Name y $p2Name forman una dinamica de ${_aspectKeywords['Spa']?[aspect.name] ?? aspectName.toLowerCase()}, por lo que este aspecto colorea de forma importante la experiencia personal.';
      default:
        return '$p1Name and $p2Name create a pattern of ${_aspectKeywords['Eng']?[aspect.name] ?? aspectName.toLowerCase()}, so this aspect meaningfully shapes the chart experience.';
    }
  }

  @override
  Widget build(BuildContext context) {
    if (planets == null && (backendAspects == null)) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.13),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.white.withOpacity(0.22)),
            ),
            child: const Center(
              child: CircularProgressIndicator(color: Color(0xFF9B7FD4), strokeWidth: 2),
            ),
          ),
        ),
      );
    }
    // Prefer backend aspects; fall back to client-side calculation
    final aspects = (backendAspects != null && backendAspects!.isNotEmpty)
        ? _fromBackend(backendAspects!)
        : (planets != null ? _compute(planets!) : <_AspectEntry>[]);

    if (aspects.isEmpty) {
      return const _InfoCard(
        title: 'No aspects found',
        text: 'No major aspects detected within standard orbs.',
      );
    }

    final aspectCards = List.generate(aspects.length, (i) {
      final a = aspects[i];
      final lang = _aspectNames.containsKey(language) ? language : 'Eng';
      final pLang = _planetNames.containsKey(language) ? language : 'Eng';
      final p1Name = _planetNames[pLang]?[a.p1] ?? a.p1;
      final p2Name = _planetNames[pLang]?[a.p2] ?? a.p2;
      final aspectName = _aspectNames[lang]?[a.name] ?? a.name;
      final descKey = '${a.p1} ${a.name} ${a.p2}';
        final desc = (aspectInterpretations[descKey] ?? '').trim().isNotEmpty
          ? aspectInterpretations[descKey]!
          : _fallbackAspectDescription(a, p1Name, p2Name, aspectName);
      return Padding(
        padding: EdgeInsets.only(bottom: i < aspects.length - 1 ? 10 : 0),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(18),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.18),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: Colors.white.withOpacity(0.30)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: a.color.withOpacity(0.18),
                        ),
                        child: Center(
                          child: Text(a.sym, style: TextStyle(fontSize: 16, color: a.color)),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '$p1Name  ${a.sym}  $p2Name',
                              style: const TextStyle(
                                color: Color(0xFF34285C),
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              '$aspectName · ${a.keyword} · ${a.orb.toStringAsFixed(1)}°',
                              style: const TextStyle(color: Color(0xFF7C6AAE), fontSize: 12),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  if (desc.isNotEmpty) ...[const SizedBox(height: 8),
                    Text(desc, style: const TextStyle(color: Color(0xFF5A4A8A), fontSize: 12.5, height: 1.55))],
                ],
              ),
            ),
          ),
        ),
      );
    });

    return Column(children: aspectCards);
  }
}

class _ConfigurationsTab extends StatelessWidget {
  final List<String> patterns;
  final Map<String, String> patternInterpretations;
  final String language;
  const _ConfigurationsTab({this.patterns = const [], this.patternInterpretations = const {}, this.language = 'Eng'});

  static const _emptyTitle = {
    'Eng': 'No configurations', 'Rus': 'Нет конфигураций',
    'Heb': 'אין קונפיגורציות', 'Spa': 'Sin configuraciones',
  };
  static const _emptyText = {
    'Eng': 'No major configurations (T-Square, Grand Trine, Yod, etc.) detected.',
    'Rus': 'Крупных конфигураций (Т-квадрат, Большой трин, Иод и др.) не обнаружено.',
    'Heb': 'לא נמצאו קונפיגורציות עיקריות (T-Square, Grand Trine, Yod וכד׳).',
    'Spa': 'No se detectaron configuraciones principales (T-Cuadrado, Gran Trígono, Yod, etc.).',
  };

  static const _patternIcons = {
    'T-Square':    '⚔️',
    'Grand Cross': '✚',
    'Grand Trine': '△',
    'Kite':        '🪁',
    'Yod':         '👆',
    'Bisextile':   '⚹',
    'Stellium':    '✨',
  };

  String _iconFor(String pattern) {
    for (final key in _patternIcons.keys) {
      if (pattern.startsWith(key)) return _patternIcons[key]!;
    }
    return '⭐';
  }

  String _fallbackPatternDescription(String pattern) {
    if (language == 'Heb') {
      if (pattern.startsWith('Stellium')) return 'סטליום מדגיש ריכוז חזק של אנרגיה באותו אזור, ולכן הנושא הזה נעשה מרכזי מאוד בחיים.';
      if (pattern.startsWith('T-Square')) return 'טי-סקוור יוצר מתח יצירתי שמבקש פעולה, בגרות ויכולת לאזן בין כוחות מנוגדים.';
      if (pattern.startsWith('Grand Trine')) return 'גרנד טריין מצביע על זרימה טבעית וכישרון מולד, אך חשוב גם להפעיל אותו באופן מודע.';
      if (pattern.startsWith('Yod')) return 'יוד מצביע על מסלול עדין ומדויק של התאמות פנימיות, עם תחושת כיוון גורלית.';
      if (pattern.startsWith('Kite')) return 'קונפיגורציית עפיפון משלבת כישרון טבעי עם כיוון ברור לפעולה ולהגשמה.';
      return 'הקונפיגורציה הזו מדגישה דפוס חוזר במפה ומראה איך כמה כוחות פועלים יחד באותו נושא.';
    }
    if (language == 'Rus') {
      if (pattern.startsWith('Stellium')) return 'Стеллиум показывает сильную концентрацию энергии в одной теме жизни, поэтому она становится доминирующей.';
      if (pattern.startsWith('T-Square')) return 'Т-квадрат создает напряжение, которое подталкивает к росту, действию и внутреннему балансу.';
      if (pattern.startsWith('Grand Trine')) return 'Большой трин указывает на естественный поток и врожденный талант, который важно осознанно развивать.';
      if (pattern.startsWith('Yod')) return 'Йод говорит о тонкой настройке и судьбоносном направлении, которое раскрывается через корректировки.';
      if (pattern.startsWith('Kite')) return 'Кайт соединяет природные дары с явным вектором реализации и движения вперед.';
      return 'Эта конфигурация показывает повторяющийся узор карты и важное взаимодействие нескольких сил.';
    }
    if (language == 'Spa') {
      if (pattern.startsWith('Stellium')) return 'Un stellium concentra mucha energia en una misma zona de vida, por eso ese tema se vuelve dominante.';
      if (pattern.startsWith('T-Square')) return 'La T-cuadrada crea tension creativa que empuja al crecimiento, la accion y el equilibrio.';
      if (pattern.startsWith('Grand Trine')) return 'El gran trigono muestra fluidez natural y talento innato, aunque conviene usarlo conscientemente.';
      if (pattern.startsWith('Yod')) return 'El yod apunta a un camino de ajustes finos y a una direccion que se siente significativa.';
      if (pattern.startsWith('Kite')) return 'La configuracion cometa combina talento natural con una direccion clara para avanzar.';
      return 'Esta configuracion muestra un patron importante en la carta y como varias fuerzas trabajan juntas.';
    }
    if (pattern.startsWith('Stellium')) return 'A stellium concentrates a lot of energy in one area of life, making that theme especially dominant.';
    if (pattern.startsWith('T-Square')) return 'A T-square creates productive tension that pushes growth, action, and balance.';
    if (pattern.startsWith('Grand Trine')) return 'A grand trine points to natural flow and talent, though it works best when used consciously.';
    if (pattern.startsWith('Yod')) return 'A yod suggests a subtle path of adjustment and a direction that feels highly meaningful.';
    if (pattern.startsWith('Kite')) return 'A kite combines natural gifts with a clear vector for expression and forward movement.';
    return 'This configuration highlights a recurring chart pattern and shows how several forces work together.';
  }

  // ─── Client-side fallback pattern detection ───────────────────────────────
  // Used when the backend returns an empty `patterns` list. Uses slightly
  // looser orbs than the backend so configurations like a Yod still surface
  // (e.g. Neptune ⚹ Pluto → apex Moon with ~6° quincunx orbs).
  static List<String> computeFromPlanets(List<PlanetPosition> ps) {
    if (ps.length < 3) return const [];

    // Exclude Ascendant from pattern detection (treat angles separately).
    final planets = ps.where((p) => p.name != 'Ascendant').toList();

    double angleBetween(double a, double b) {
      final d = (a - b).abs() % 360;
      return d > 180 ? 360 - d : d;
    }
    bool near(double angle, double target, double orb) =>
        (angle - target).abs() <= orb;

    final results = <String>[];
    final seen = <String>{};
    void add(String s) { if (seen.add(s)) results.add(s); }

    // ── Stellium: 3+ planets in the same sign ───────────────────────────────
    final bySign = <String, List<String>>{};
    for (final p in planets) {
      bySign.putIfAbsent(p.sign, () => []).add(p.name);
    }
    bySign.forEach((sign, names) {
      if (names.length >= 3) add('Stellium in $sign: ${names.join(', ')}');
    });

    // ── Pairwise aspect lookups (looser orbs than backend) ──────────────────
    const opp = 180.0, sqr = 90.0, tri = 120.0, sxt = 60.0, qcx = 150.0;
    const oppOrb = 8.0, sqrOrb = 8.0, triOrb = 8.0, sxtOrb = 6.0, qcxOrb = 6.0;

    bool isOpposition(int i, int j) =>
        near(angleBetween(planets[i].longitude, planets[j].longitude), opp, oppOrb);
    bool isSquare(int i, int j) =>
        near(angleBetween(planets[i].longitude, planets[j].longitude), sqr, sqrOrb);
    bool isTrine(int i, int j) =>
        near(angleBetween(planets[i].longitude, planets[j].longitude), tri, triOrb);
    bool isSextile(int i, int j) =>
        near(angleBetween(planets[i].longitude, planets[j].longitude), sxt, sxtOrb);
    bool isQuincunx(int i, int j) =>
        near(angleBetween(planets[i].longitude, planets[j].longitude), qcx, qcxOrb);

    final n = planets.length;

    // ── T-Square: opposition + apex squaring both ───────────────────────────
    for (int i = 0; i < n; i++) {
      for (int j = i + 1; j < n; j++) {
        if (!isOpposition(i, j)) continue;
        for (int k = 0; k < n; k++) {
          if (k == i || k == j) continue;
          if (isSquare(k, i) && isSquare(k, j)) {
            add('T-Square: ${planets[i].name} ☍ ${planets[j].name} → apex ${planets[k].name}');
          }
        }
      }
    }

    // ── Grand Cross: two oppositions, all four squared ──────────────────────
    for (int i = 0; i < n; i++) {
      for (int j = i + 1; j < n; j++) {
        if (!isOpposition(i, j)) continue;
        for (int k = j + 1; k < n; k++) {
          for (int l = k + 1; l < n; l++) {
            if (!isOpposition(k, l)) continue;
            if (isSquare(i, k) && isSquare(i, l) && isSquare(j, k) && isSquare(j, l)) {
              add('Grand Cross: ${planets[i].name}, ${planets[k].name}, ${planets[j].name}, ${planets[l].name}');
            }
          }
        }
      }
    }

    // ── Grand Trine: three planets all trine each other ─────────────────────
    for (int i = 0; i < n; i++) {
      for (int j = i + 1; j < n; j++) {
        if (!isTrine(i, j)) continue;
        for (int k = j + 1; k < n; k++) {
          if (isTrine(i, k) && isTrine(j, k)) {
            add('Grand Trine: ${planets[i].name} △ ${planets[j].name} △ ${planets[k].name}');
          }
        }
      }
    }

    // ── Yod: sextile + both quincunx to apex ────────────────────────────────
    for (int i = 0; i < n; i++) {
      for (int j = i + 1; j < n; j++) {
        if (!isSextile(i, j)) continue;
        for (int k = 0; k < n; k++) {
          if (k == i || k == j) continue;
          if (isQuincunx(k, i) && isQuincunx(k, j)) {
            add('Yod: ${planets[i].name} ⚹ ${planets[j].name} → apex ${planets[k].name}');
          }
        }
      }
    }

    // ── Kite: Grand Trine + opposition from one corner to a 4th planet
    //         that sextiles the other two ─────────────────────────────────────
    for (int i = 0; i < n; i++) {
      for (int j = i + 1; j < n; j++) {
        for (int k = j + 1; k < n; k++) {
          if (!(isTrine(i, j) && isTrine(j, k) && isTrine(i, k))) continue;
          for (int l = 0; l < n; l++) {
            if (l == i || l == j || l == k) continue;
            final corners = [i, j, k];
            for (final c in corners) {
              final others = corners.where((x) => x != c).toList();
              if (isOpposition(l, c) &&
                  isSextile(l, others[0]) &&
                  isSextile(l, others[1])) {
                add('Kite: ${planets[i].name}, ${planets[j].name}, ${planets[k].name} + tail ${planets[l].name}');
              }
            }
          }
        }
      }
    }

    return results;
  }

  @override
  Widget build(BuildContext context) {
    if (patterns.isEmpty) {
      return _InfoCard(
        title: _emptyTitle[language] ?? _emptyTitle['Eng']!,
        text:  _emptyText[language]  ?? _emptyText['Eng']!,
      );
    }
    return Column(
      children: List.generate(patterns.length, (i) {
        final p = patterns[i];
        final desc = (patternInterpretations[p] ?? '').trim().isNotEmpty
          ? patternInterpretations[p]!
          : _fallbackPatternDescription(p);
        final icon = _iconFor(p);
        return Padding(
          padding: EdgeInsets.only(bottom: i < patterns.length - 1 ? 12 : 0),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(18),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF9B7FD4).withOpacity(0.15),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: const Color(0xFF9B7FD4).withOpacity(0.40)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(icon, style: const TextStyle(fontSize: 18)),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            p,
                            style: const TextStyle(
                              color: Color(0xFF34285C),
                              fontSize: 13.5,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                    if (desc.isNotEmpty) ...[const SizedBox(height: 8),
                      Text(desc, style: const TextStyle(color: Color(0xFF5A4A8A), fontSize: 12.5, height: 1.6))],
                  ],
                ),
              ),
            ),
          ),
        );
      }),
    );
  }
}

class _TransitsTab extends StatelessWidget {
  final TransitResponse? response;
  final String language;
  final bool isLoading;
  final String? error;
  const _TransitsTab({
    this.response,
    this.language = 'Eng',
    this.isLoading = false,
    this.error,
  });

  static const _todayTitle = {
    'Eng': "Today's Transits", 'Rus': 'Транзиты сегодня',
    'Heb': 'מעברים היום', 'Spa': 'Tránsitos de hoy',
  };
  static const _noneTitle = {
    'Eng': 'No active transits', 'Rus': 'Нет активных транзитов',
    'Heb': 'אין מעברים פעילים', 'Spa': 'Sin tránsitos activos',
  };
  static const _noneText = {
    'Eng': 'No significant transit aspects within 5° today.',
    'Rus': 'Сегодня нет значимых транзитных аспектов в пределах 5°.',
    'Heb': 'אין אספקטי מעבר משמעותיים בתוך 5° היום.',
    'Spa': 'Hoy no hay aspectos de tránsito significativos dentro de 5°.',
  };
  static const _errorTitle = {
    'Eng': 'Transits unavailable',
    'Rus': 'Транзиты недоступны',
    'Heb': 'המעברים אינם זמינים',
    'Spa': 'Transitos no disponibles',
  };
  static const _errorText = {
    'Eng': 'Transit data could not be loaded. The natal chart is still available.',
    'Rus': 'Не удалось загрузить транзиты. Натальная карта по-прежнему доступна.',
    'Heb': 'לא ניתן היה לטעון את נתוני המעברים. מפת הלידה עדיין זמינה.',
    'Spa': 'No se pudieron cargar los transitos. La carta natal sigue disponible.',
  };
  static const _natalLabel = {
    'Eng': 'natal', 'Rus': 'натальный', 'Heb': 'נטלי', 'Spa': 'natal',
  };
  static const _houseLabel = {
    'Eng': 'house', 'Rus': 'дом', 'Heb': 'בית', 'Spa': 'casa',
  };
  static const _planetNames = {
    'Eng': {'Sun':'Sun','Moon':'Moon','Mercury':'Mercury','Venus':'Venus','Mars':'Mars','Jupiter':'Jupiter','Saturn':'Saturn','Uranus':'Uranus','Neptune':'Neptune','Pluto':'Pluto','Ascendant':'Ascendant'},
    'Rus': {'Sun':'Солнце','Moon':'Луна','Mercury':'Меркурий','Venus':'Венера','Mars':'Марс','Jupiter':'Юпитер','Saturn':'Сатурн','Uranus':'Уран','Neptune':'Нептун','Pluto':'Плутон','Ascendant':'Асцендент'},
    'Heb': {'Sun':'שמש','Moon':'ירח','Mercury':'כוכב חמה','Venus':'נוגה','Mars':'מאדים','Jupiter':'צדק','Saturn':'שבתאי','Uranus':'אורנוס','Neptune':'נפטון','Pluto':'פלוטו','Ascendant':'אסצנדנט'},
    'Spa': {'Sun':'Sol','Moon':'Luna','Mercury':'Mercurio','Venus':'Venus','Mars':'Marte','Jupiter':'Júpiter','Saturn':'Saturno','Uranus':'Urano','Neptune':'Neptuno','Pluto':'Plutón','Ascendant':'Ascendente'},
  };
  static const _aspectNames = {
    'Eng': {'Conjunction':'Conjunction','Sextile':'Sextile','Square':'Square','Trine':'Trine','Quincunx':'Quincunx','Opposition':'Opposition'},
    'Rus': {'Conjunction':'Соединение','Sextile':'Секстиль','Square':'Квадрат','Trine':'Трин','Quincunx':'Квинкункс','Opposition':'Оппозиция'},
    'Heb': {'Conjunction':'קונג׳אנקשן','Sextile':'סקסטיל','Square':'ריבוע','Trine':'טרין','Quincunx':'קווינקונקס','Opposition':'אופוזיציה'},
    'Spa': {'Conjunction':'Conjunción','Sextile':'Sextil','Square':'Cuadratura','Trine':'Trígono','Quincunx':'Quincuncio','Opposition':'Oposición'},
  };

  static const _symMap = {
    'Conjunction': '☌', 'Sextile': '⚹', 'Square': '□',
    'Trine': '△', 'Quincunx': '⚻', 'Opposition': '☍',
  };
  static const _colorMap = {
    'Conjunction': Color(0xFF9B7FD4), 'Sextile':    Color(0xFF5BAD8A),
    'Square':      Color(0xFFD45C5C), 'Trine':      Color(0xFF5B9BD4),
    'Quincunx':    Color(0xFFD4A85C), 'Opposition': Color(0xFFD47A5C),
  };

  @override
  Widget build(BuildContext context) {
    final lang = _todayTitle.containsKey(language) ? language : 'Eng';
    if (isLoading || (response == null && error == null)) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.13),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.white.withOpacity(0.22)),
            ),
            child: const Center(
              child: CircularProgressIndicator(color: Color(0xFF9B7FD4), strokeWidth: 2),
            ),
          ),
        ),
      );
    }
    if (error != null) {
      return _InfoCard(
        title: _errorTitle[lang] ?? _errorTitle['Eng']!,
        text: _errorText[lang] ?? _errorText['Eng']!,
      );
    }

    final items = response!.transits;
    final interp = response!.interpretation;

    return Column(
      children: [
        if (interp.isNotEmpty) ...[
          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.18),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.white.withOpacity(0.30)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _todayTitle[lang] ?? "Today's Transits",
                      style: const TextStyle(
                        color: Color(0xFF34285C),
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      interp,
                      style: const TextStyle(
                        color: Color(0xFF4A3B7C),
                        fontSize: 13.5,
                        height: 1.55,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 14),
        ],
        if (items.isEmpty)
          _InfoCard(
            title: _noneTitle[lang] ?? 'No active transits',
            text: _noneText[lang] ?? 'No significant transit aspects within 5° today.',
          )
        else
          ...List.generate(items.length, (i) {
            final t = items[i];
            final sym   = _symMap[t.aspect]  ?? '·';
            final color = _colorMap[t.aspect] ?? const Color(0xFF9B7FD4);
            return Padding(
              padding: EdgeInsets.only(bottom: i < items.length - 1 ? 10 : 0),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(18),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.18),
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: Colors.white.withOpacity(0.30)),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 36, height: 36,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: color.withOpacity(0.18),
                          ),
                          child: Center(
                            child: Text(sym, style: TextStyle(fontSize: 16, color: color)),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${_planetNames[lang]?[t.transitPlanet] ?? t.transitPlanet}  $sym  ${_planetNames[lang]?[t.natalPlanet] ?? t.natalPlanet} (${_natalLabel[lang] ?? 'natal'})',
                                style: const TextStyle(
                                  color: Color(0xFF34285C),
                                  fontSize: 13.5,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                '${_aspectNames[lang]?[t.aspect] ?? t.aspect} · ${t.transitSign}, ${_houseLabel[lang] ?? 'house'} ${t.transitHouse} · ${t.orb.toStringAsFixed(1)}°',
                                style: const TextStyle(color: Color(0xFF7C6AAE), fontSize: 12),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }),
      ],
    );
  }
}

class _HousesTab extends StatelessWidget {
  const _HousesTab();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: const [
        _InfoCard(
          title: 'House 1',
          text:
              'Shows how a person expresses themselves outwardly, what image they create, and how they begin new cycles.',
        ),
        SizedBox(height: 12),
        _InfoCard(
          title: 'House 2',
          text:
              'Values, money, a sense of stability, and the relationship with personal resources.',
        ),
        SizedBox(height: 12),
        _InfoCard(
          title: 'House 3',
          text:
              'Communication, thinking, environment, learning, and the style of conveying information.',
        ),
      ],
    );
  }
}

class _InfoCard extends StatelessWidget {
  final String title;
  final String text;

  const _InfoCard({
    required this.title,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(22),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AstroPalette.darkGlassFill,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(
              color: AstroPalette.glassBorder,
              width: 1.2,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: Color(0xFF3C2F67),
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                text,
                style: const TextStyle(
                  color: Color(0xFF74639F),
                  fontSize: 14,
                  height: 1.42,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PlanetCard extends StatelessWidget {
  final String planet;
  final String sign;
  final String house;
  final String description;

  const _PlanetCard({
    required this.planet,
    required this.sign,
    required this.house,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(22),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.22),
            borderRadius: BorderRadius.circular(22),
            border: Border.all(
              color: Colors.white.withOpacity(0.40),
              width: 1.2,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [Color(0xFFF1E6FF), Color(0xFFD9C5FF)],
                  ),
                ),
                child: Center(
                  child: Text(
                    planet.split(' ').first,
                    style: const TextStyle(fontSize: 22),
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          planet.split(' ').last,
                          style: const TextStyle(
                            color: Color(0xFF3C2F67),
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: AstroPalette.accent.withOpacity(0.26),
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Text(
                            sign,
                            style: const TextStyle(
                              color: AstroPalette.accentStrong,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          house,
                          style: const TextStyle(
                            color: AstroPalette.mutedLabel,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 5),
                    Text(
                      description,
                      style: const TextStyle(
                        color: AstroPalette.darkSecondary,
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        height: 1.35,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BirthInputCard extends StatefulWidget {
  final void Function(DateTime date, TimeOfDay time, String location) onSubmit;
  const _BirthInputCard({required this.onSubmit});

  @override
  State<_BirthInputCard> createState() => _BirthInputCardState();
}

class _BirthInputCardState extends State<_BirthInputCard> {
  DateTime? _date;
  TimeOfDay? _time;
  final _locationCtrl = TextEditingController();

  @override
  void dispose() {
    _locationCtrl.dispose();
    super.dispose();
  }

  bool get _canSubmit =>
      _date != null && _time != null && _locationCtrl.text.trim().isNotEmpty;

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime(1990),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      builder: (context, child) => _lilacPickerTheme(context, child),
    );
    if (picked != null) setState(() => _date = picked);
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: const TimeOfDay(hour: 12, minute: 0),
      builder: (context, child) => _lilacPickerTheme(context, child),
    );
    if (picked != null) setState(() => _time = picked);
  }

  static const _months = [
    '',
    'January', 'February', 'March', 'April', 'May', 'June',
    'July', 'August', 'September', 'October', 'November', 'December',
  ];

  String _formatDate() => _date == null
      ? 'Select date'
      : '${_months[_date!.month]} ${_date!.day}, ${_date!.year}';

  String _formatTime() => _time == null
      ? 'Select time'
      : '${_time!.hour.toString().padLeft(2, '0')}:${_time!.minute.toString().padLeft(2, '0')}';

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(28),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AstroPalette.darkGlassFill,
            borderRadius: BorderRadius.circular(28),
            border: Border.all(
              color: AstroPalette.glassBorder,
              width: 1.2,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Birth Data',
                style: TextStyle(
                  color: AstroPalette.lightText,
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'Enter your birth details to calculate your natal chart',
                style: TextStyle(
                  color: AstroPalette.lightTextSoft,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 20),
              _BirthFieldRow(
                icon: Icons.calendar_today_rounded,
                label: 'Date of birth',
                value: _formatDate(),
                hasValue: _date != null,
                onTap: _pickDate,
              ),
              const SizedBox(height: 12),
              _BirthFieldRow(
                icon: Icons.access_time_rounded,
                label: 'Time of birth',
                value: _formatTime(),
                hasValue: _time != null,
                onTap: _pickTime,
              ),
              const SizedBox(height: 12),
              _BirthLocationField(
                controller: _locationCtrl,
                onChanged: (_) => setState(() {}),
              ),
              const SizedBox(height: 24),
              GestureDetector(
                onTap: _canSubmit
                    ? () => widget.onSubmit(_date!, _time!, _locationCtrl.text.trim())
                    : null,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(18),
                    gradient: _canSubmit
                        ? const LinearGradient(
                            colors: [Color(0xFFE8D7FF), Color(0xFFB493F7)],
                          )
                        : null,
                    color: _canSubmit ? null : AstroPalette.lightGlassFill,
                    border: Border.all(
                      color: _canSubmit ? AstroPalette.glassBorder : AstroPalette.glassBorder,
                    ),
                  ),
                  child: Text(
                    'Calculate Chart',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: _canSubmit ? AstroPalette.darkText : AstroPalette.mutedLabel,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
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
}

class _BirthFieldRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final bool hasValue;
  final VoidCallback onTap;

  const _BirthFieldRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.hasValue,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.18),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: hasValue
                ? const Color(0xFF9B7EF5).withOpacity(0.50)
                : Colors.white.withOpacity(0.35),
          ),
        ),
        child: Row(
          children: [
            Icon(icon, size: 18, color: const Color(0xFF8B6EF0)),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: const TextStyle(
                      color: Color(0xFF9C8EC0),
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    value,
                    style: TextStyle(
                      color: hasValue
                          ? const Color(0xFF3C2F67)
                          : const Color(0xFFB0A0D0),
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.chevron_right_rounded,
              color: Color(0xFF9C8EC0),
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}

class _BirthLocationField extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String> onChanged;

  const _BirthLocationField({
    required this.controller,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(left: 14, right: 14, top: 10, bottom: 6),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.18),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: controller.text.isNotEmpty
              ? const Color(0xFF9B7EF5).withOpacity(0.50)
              : Colors.white.withOpacity(0.35),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Icon(
            Icons.location_on_rounded,
            size: 18,
            color: Color(0xFF8B6EF0),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Place of birth',
                  style: TextStyle(
                    color: Color(0xFF9C8EC0),
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                TextField(
                  controller: controller,
                  onChanged: onChanged,
                  style: const TextStyle(
                    color: Color(0xFF3C2F67),
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    hintText: 'City, Country',
                    hintStyle: TextStyle(
                      color: Color(0xFFB0A0D0),
                      fontSize: 15,
                      fontWeight: FontWeight.w400,
                    ),
                    isDense: true,
                    contentPadding: EdgeInsets.symmetric(vertical: 4),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ChartBackground extends StatefulWidget {
  const _ChartBackground();

  @override
  State<_ChartBackground> createState() => _ChartBackgroundState();
}

class _ChartBackgroundState extends State<_ChartBackground> {
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
          decoration: const BoxDecoration(
            gradient: AstroPalette.appBackground,
          ),
        ),
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
          child: _glow(240, AstroPalette.glowWhiteLilac),
        ),
        Positioned(
          top: 120,
          right: -60,
          child: _glow(200, AstroPalette.glowLilacBlue),
        ),
        Positioned(
          bottom: 130,
          left: -30,
          child: _glow(180, AstroPalette.glowLilacMint),
        ),
      ],
    );
  }

  Widget _glow(double size, Color color) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color,
        boxShadow: [
          BoxShadow(
            color: color,
            blurRadius: 70,
            spreadRadius: 18,
          ),
        ],
      ),
    );
  }
}

// ── Natal chart loading animation ──────────────────────────────────────────

class _ChartLoadingAnimation extends StatefulWidget {
  const _ChartLoadingAnimation();
  @override
  State<_ChartLoadingAnimation> createState() => _ChartLoadingAnimationState();
}

class _ChartLoadingAnimationState extends State<_ChartLoadingAnimation> {
  late VideoPlayerController _ctrl;
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    _ctrl = kIsWeb
        ? VideoPlayerController.networkUrl(
            Uri.parse('assets/assets/videos/astro_video_chrome.mp4'),
          )
        : VideoPlayerController.asset('assets/videos/astro_video_chrome.mp4');
    _ctrl
      ..setLooping(true)
      ..setVolume(0)
      ..initialize().then((_) {
        if (mounted) {
          _ctrl.play();
          setState(() => _initialized = true);
        }
      });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _initialized
        ? AspectRatio(
            aspectRatio: _ctrl.value.aspectRatio,
            child: VideoPlayer(_ctrl),
          )
        : const SizedBox(
            height: 300,
            child: Center(
              child: CircularProgressIndicator(
                color: Color(0xFF9B7FD4),
                strokeWidth: 2,
              ),
            ),
          );
  }
}

// ignore: unused_element
class _AstroPainter extends CustomPainter {
  final double orbit;
  final double pulse;
  final double star;
  _AstroPainter({required this.orbit, required this.pulse, required this.star});

  // radius, speed multiplier, planet size, color, start angle offset
  static const _orbits = [
    (r: 40.0,  s: 1.0,  sz: 9.0,  c: Color(0xFFFFD700), a: 0.0),
    (r: 62.0,  s: 1.55, sz: 7.0,  c: Color(0xFFB8A0FF), a: 1.2),
    (r: 82.0,  s: 2.1,  sz: 6.0,  c: Color(0xFF60D0FF), a: 2.5),
    (r: 100.0, s: 0.65, sz: 8.0,  c: Color(0xFFFF90BC), a: 0.8),
    (r: 118.0, s: 1.85, sz: 6.0,  c: Color(0xFFFF6B6B), a: 3.9),
  ];

  static final _stars = List.generate(30, (i) {
    final rng = math.Random(i * 193 + 11);
    return (
      a: rng.nextDouble() * 2 * math.pi,
      d: 125.0 + rng.nextDouble() * 15.0,
      sz: 0.8 + rng.nextDouble() * 2.2,
      ph: rng.nextDouble(),
    );
  });

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;

    // Stars
    for (final s in _stars) {
      final t = 0.3 + 0.7 * math.sin((star + s.ph) * 2 * math.pi);
      canvas.drawCircle(
        Offset(cx + math.cos(s.a) * s.d, cy + math.sin(s.a) * s.d),
        s.sz * t,
        Paint()..color = Colors.white.withOpacity(0.2 + 0.7 * t),
      );
    }

    // Orbit rings
    for (final o in _orbits) {
      canvas.drawCircle(Offset(cx, cy), o.r,
          Paint()
            ..color = const Color(0xFF9B7FD4).withOpacity(0.20)
            ..style = PaintingStyle.stroke
            ..strokeWidth = 0.8);
    }

    // Sun glow
    canvas.drawCircle(Offset(cx, cy), 18 + 5 * pulse,
        Paint()
          ..color = const Color(0xFFFFD700).withOpacity(0.15 + 0.15 * pulse)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 18));
    // Sun
    canvas.drawCircle(Offset(cx, cy), 12,
        Paint()..color = const Color(0xFFFFE44D));
    canvas.drawCircle(Offset(cx, cy), 12,
        Paint()
          ..color = const Color(0xFFFFAA00).withOpacity(0.5)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6));

    // Planets
    for (final o in _orbits) {
      final angle = o.a + orbit * o.s * 2 * math.pi;
      final px = cx + math.cos(angle) * o.r;
      final py = cy + math.sin(angle) * o.r;
      // glow
      canvas.drawCircle(Offset(px, py), o.sz + 4,
          Paint()
            ..color = o.c.withOpacity(0.35)
            ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8));
      // body
      canvas.drawCircle(Offset(px, py), o.sz, Paint()..color = o.c);
      // highlight
      canvas.drawCircle(
        Offset(px - o.sz * 0.3, py - o.sz * 0.3),
        o.sz * 0.3,
        Paint()..color = Colors.white.withOpacity(0.5),
      );
    }
  }

  @override
  bool shouldRepaint(_AstroPainter o) => true;
}

