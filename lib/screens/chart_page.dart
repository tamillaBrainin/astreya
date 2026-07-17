import 'dart:math' as math;
import 'dart:async';
import 'dart:ui';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import '../services/api_service.dart';
import '../services/astro_math.dart';
import '../theme/astro_palette.dart';

// ─── Premium lilac theme for showDatePicker / showTimePicker dialogs ─────────
const _lilacBg = AstroPalette.appBgTop;
const _lilacSurface = Color(0xFFFFFBFF);
const _lilacPrimary = Color(0xFF8F73E8);
const _lilacSoft = Color(0xFFEAD9FF);
const _lilacText = AstroPalette.darkText;
const _lilacTextSoft = AstroPalette.darkSecondary;
const _lilacBorder = Color(0xFFEFE6FF);

const _chartCardSurface = Color(0xFFF8F3FF);
const _chartCardBorder = Color(0xFFDCCBED);
const _chartTextStrong = Color(0xFF2E214F);
const _chartTextBody = Color(0xFF4F3D78);

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
          fontSize: 26,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
        headerHelpStyle: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.8,
          color: Colors.white,
        ),
        weekdayStyle: const TextStyle(
          color: _lilacTextSoft,
          fontWeight: FontWeight.w600,
        ),
        dayStyle: const TextStyle(
          color: _lilacText,
          fontWeight: FontWeight.w500,
        ),
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
  String? _chartInterpretation;
  bool _birthDataSubmitted = false;

  DateTime? _birthDate;
  TimeOfDay? _birthTime;
  String? _birthCity;
  TransitResponse? _transits;
  bool _isLoadingTransits = false;
  bool _isLoadingInterpretation = false;
  String? _transitsError;
  String _language = 'Eng';

  bool get _isWaitingForGeneral {
    return _birthDataSubmitted &&
        _chart != null &&
        _isLoadingInterpretation &&
        (_chartInterpretation == null || _chartInterpretation!.trim().isEmpty);
  }

  List<String> get _tabs {
    switch (_language) {
      case 'Rus':
        return ['Общее', 'Планеты', 'Аспекты', 'Конфигурации', 'Транзиты'];
      case 'Heb':
        return ['כללי', 'כוכבי לכת', 'אספקטים', 'קונפיגורציות', 'מעברים'];
      case 'Spa':
        return [
          'General',
          'Planetas',
          'Aspectos',
          'Configuraciones',
          'Tránsitos',
        ];
      default:
        return ['General', 'Planets', 'Aspects', 'Configurations', 'Transits'];
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
      _chartInterpretation = null;
      _transits = null;
      _isLoadingInterpretation = false;
      _isLoadingTransits = false;
      _transitsError = null;
    });
    _loadChart(date, time, location);
  }

  Future<void> _loadInterpretation(
    DateTime date,
    TimeOfDay time,
    String location,
  ) async {
    if (mounted) {
      setState(() {
        _isLoadingInterpretation = true;
        _chartInterpretation = null;
      });
    }
    try {
      final interpretation = await ApiService.getChartInterpretation(
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
          _chartInterpretation = interpretation;
          _isLoadingInterpretation = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _chartInterpretation = '';
          _isLoadingInterpretation = false;
        });
      }
    }
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

  Future<void> _loadEnrichment(
    DateTime date,
    TimeOfDay time,
    String location,
  ) async {
    if (_chart == null) return;
    try {
      final enrichment = await ApiService.getChartEnrichment(
        year: date.year,
        month: date.month,
        day: date.day,
        hour: time.hour,
        minute: time.minute,
        city: location,
        language: _language,
      );
      if (!mounted || _chart == null) return;
      setState(() {
        final current = _chart!;
        _chart = ChartResponse(
          ascendantSign: current.ascendantSign,
          ascendantDegrees: current.ascendantDegrees,
          mcSign: current.mcSign,
          mcDegrees: current.mcDegrees,
          houses: current.houses,
          planets: current.planets,
          patterns: current.patterns,
          aspects: current.aspects,
          interpretation: current.interpretation,
          planetaryInterpretations: enrichment.planetaryInterpretations,
          patternInterpretations: enrichment.patternInterpretations,
          aspectInterpretations: enrichment.aspectInterpretations,
        );
      });
    } catch (_) {
      // Keep UI responsive; enrichment is optional and loaded in background.
    }
  }

  @override
  void initState() {
    super.initState();
    _language = widget.initialLanguage;
  }

  Future<void> _loadChart(
    DateTime date,
    TimeOfDay time,
    String location,
  ) async {
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
          _chartInterpretation = null;
        });
      }
      // Queue expensive calls: General interpretation first.
      await _loadInterpretation(date, time, location);
      if (mounted) {
        // While user reads General, fetch secondary prompts in background.
        unawaited(_loadEnrichment(date, time, location));
        unawaited(_loadTransits());
      }
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
                        else if (_chart == null || _isWaitingForGeneral)
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
      _chartInterpretation = null;
      _transits = null;
      _isLoadingInterpretation = false;
      _isLoadingTransits = false;
      _transitsError = null;
    });
    if (_birthDataSubmitted &&
        _birthDate != null &&
        _birthTime != null &&
        _birthCity != null) {
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
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  color: selected ? null : AstroPalette.lightGlassFill,
                  gradient: selected ? AstroPalette.activeSurface : null,
                  border: Border.all(color: AstroPalette.glassBorder),
                ),
                child: Text(
                  '${l['flag']} ${l['label']}',
                  style: TextStyle(
                    color: selected
                        ? AstroPalette.darkText
                        : AstroPalette.darkSecondary,
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
        final backendPatterns = _chart?.patterns ?? [];
        final localPatterns = _ConfigurationsTab.computeFromPlanets(
          _chart?.planets ?? [],
        );
        final patterns = _ConfigurationsTab.mergePatterns(
          backendPatterns: backendPatterns,
          localPatterns: localPatterns,
        );
        return _GeneralTab(
          interpretation: _chartInterpretation,
          isLoading: _isLoadingInterpretation,
          language: _language,
          chart: _chart,
          configurations: patterns,
          detailLevel: 'deep',
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
        final localPatterns = _ConfigurationsTab.computeFromPlanets(
          _chart?.planets ?? [],
        );
        final patterns = _ConfigurationsTab.mergePatterns(
          backendPatterns: backendPatterns,
          localPatterns: localPatterns,
        );
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
        _glassCircle(const Icon(Icons.tune_rounded, color: Color(0xFF6E58C8))),
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
  static const double _cx = _baseSize / 2; // 130
  static const double _planetR = 72.0; // radius for planet ring
  static const double _aspectR =
      52.0; // radius for aspect line endpoints (inner)

  static const Map<String, String> _glyphs = {
    'Sun': '☉',
    'Moon': '☽',
    'Mercury': '☿',
    'Venus': '♀',
    'Mars': '♂',
    'Jupiter': '♃',
    'Saturn': '♄',
    'Uranus': '⛢',
    'Neptune': '♆',
    'Pluto': '♇',
    'Ascendant': '↑',
  };

  static const Map<String, Color> _colors = {
    'Sun': Color(0xFFFFD080),
    'Moon': Color(0xFFB0C8FF),
    'Mercury': Color(0xFFFFB8B8),
    'Venus': Color(0xFFFFD8E8),
    'Mars': Color(0xFFFF9980),
    'Jupiter': Color(0xFFD4FFAA),
    'Saturn': Color(0xFFFFEEAA),
    'Uranus': Color(0xFFAAEEFF),
    'Neptune': Color(0xFFCCAAFF),
    'Pluto': Color(0xFFE8CCFF),
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
                style: TextStyle(
                  color: AstroPalette.lightTextSoft,
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 12),
              LayoutBuilder(
                builder: (context, constraints) {
                  final size = constraints.maxWidth;
                  final scale = size / _baseSize;
                  return SizedBox(
                    width: size,
                    height: size,
                    child: Stack(
                      children: [
                        // Background image
                        Positioned.fill(
                          child: Image.asset(
                            'assets/images/natal_chart.png',
                            fit: BoxFit.contain,
                          ),
                        ),
                        // Aspect lines
                        if (planets.isNotEmpty)
                          Positioned.fill(
                            child: CustomPaint(
                              painter: _ChartAspectPainter(
                                planets,
                                scale,
                                _aspectR,
                              ),
                            ),
                          ),
                        // Planet dots
                        ...planets.map((p) {
                          final pos = _lonToOffset(p.longitude, _planetR);
                          return _dot(
                            pos.dx,
                            pos.dy,
                            _glyphs[p.name] ?? '★',
                            p.sign.length >= 3
                                ? p.sign.substring(0, 3)
                                : p.sign,
                            _colors[p.name] ?? const Color(0xFFCCCCFF),
                            scale,
                          );
                        }),
                      ],
                    ),
                  );
                },
              ),
              const SizedBox(height: 12),
              Text(
                label,
                style: const TextStyle(
                  color: AstroPalette.lightTextSoft,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _dot(
    double cx,
    double cy,
    String glyph,
    String sign,
    Color color,
    double scale,
  ) {
    final dotSize = 22.0 * scale;
    final fontSize = 11.0 * scale;
    final signFontSize = 7.0 * scale;
    return Positioned(
      left: cx * scale - dotSize / 2,
      top: cy * scale - dotSize / 2 - 2,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: dotSize,
            height: dotSize,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: color.withOpacity(0.92),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.28),
                  blurRadius: 4,
                  offset: const Offset(0, 1),
                ),
              ],
            ),
            child: Center(
              child: Text(
                glyph,
                style: TextStyle(
                  fontSize: fontSize,
                  height: 1,
                  color: const Color(0xFF2A1F50),
                ),
              ),
            ),
          ),
          SizedBox(height: 2 * scale),
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: 3 * scale,
              vertical: 1 * scale,
            ),
            decoration: BoxDecoration(
              color: color.withOpacity(0.88),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              sign,
              style: TextStyle(
                fontSize: signFontSize,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF2A1F50),
                height: 1,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ChartAspectPainter extends CustomPainter {
  final List<PlanetPosition> planets;
  final double scale;
  final double radius;

  static const _aspectAngles = [0.0, 60.0, 90.0, 120.0, 150.0, 180.0];
  static const _aspectOrbs = [8.0, 6.0, 8.0, 8.0, 3.0, 8.0];
  static const _aspectColors = [
    Color(0xFFBB99FF),
    Color(0xFF6DBD8C),
    Color(0xFFE86060),
    Color(0xFF6AACEE),
    Color(0xFFE0B050),
    Color(0xFFE87A50),
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
        final diff = angularDistance(
          planets[i].longitude,
          planets[j].longitude,
        );
        for (int k = 0; k < _aspectAngles.length; k++) {
          if ((diff - _aspectAngles[k]).abs() <= _aspectOrbs[k]) {
            final p1 = _lonToOffset(planets[i].longitude);
            final p2 = _lonToOffset(planets[j].longitude);
            canvas.drawLine(
              p1,
              p2,
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
            border: Border.all(color: AstroPalette.glassBorder, width: 1.2),
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
                  gradient: selected ? AstroPalette.activeSurface : null,
                  color: selected ? null : AstroPalette.lightGlassFill,
                  border: Border.all(color: AstroPalette.glassBorder),
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
  final ChartResponse? chart;
  final List<String> configurations;
  final String detailLevel;
  const _GeneralTab({
    this.interpretation,
    this.isLoading = false,
    this.language = 'Eng',
    this.chart,
    this.configurations = const [],
    this.detailLevel = 'deep',
  });

  static const _emptyTitle = {
    'Eng': 'Interpretation unavailable',
    'Rus': 'Интерпретация недоступна',
    'Heb': 'הפרשנות אינה זמינה',
    'Spa': 'Interpretacion no disponible',
  };

  static const _emptyText = {
    'Eng':
        'The chart data loaded, but the narrative interpretation did not return in time.',
    'Rus':
        'Данные карты загрузились, но текстовая интерпретация не успела вернуться.',
    'Heb': 'נתוני המפה נטענו, אך הפרשנות הטקסטואלית לא חזרה בזמן.',
    'Spa':
        'Los datos de la carta se cargaron, pero la interpretacion textual no regreso a tiempo.',
  };

  static const _planetNames = {
    'Eng': {
      'Sun': 'Sun',
      'Moon': 'Moon',
      'Mercury': 'Mercury',
      'Venus': 'Venus',
      'Mars': 'Mars',
      'Jupiter': 'Jupiter',
      'Saturn': 'Saturn',
      'Uranus': 'Uranus',
      'Neptune': 'Neptune',
      'Pluto': 'Pluto',
      'Ascendant': 'Ascendant',
      'North Node': 'North Node',
      'South Node': 'South Node',
      'Lilith': 'Lilith',
      'Selena': 'Selena',
    },
    'Rus': {
      'Sun': 'Солнце',
      'Moon': 'Луна',
      'Mercury': 'Меркурий',
      'Venus': 'Венера',
      'Mars': 'Марс',
      'Jupiter': 'Юпитер',
      'Saturn': 'Сатурн',
      'Uranus': 'Уран',
      'Neptune': 'Нептун',
      'Pluto': 'Плутон',
      'Ascendant': 'Асцендент',
      'North Node': 'Северный узел',
      'South Node': 'Южный узел',
      'Lilith': 'Лилит',
      'Selena': 'Селена',
    },
    'Heb': {
      'Sun': 'שמש',
      'Moon': 'ירח',
      'Mercury': 'כוכב חמה',
      'Venus': 'נוגה',
      'Mars': 'מאדים',
      'Jupiter': 'צדק',
      'Saturn': 'שבתאי',
      'Uranus': 'אורנוס',
      'Neptune': 'נפטון',
      'Pluto': 'פלוטו',
      'Ascendant': 'אסצנדנט',
      'North Node': 'הצומת הצפוני',
      'South Node': 'הצומת הדרומי',
      'Lilith': 'לילית',
      'Selena': 'סלנה',
    },
    'Spa': {
      'Sun': 'Sol',
      'Moon': 'Luna',
      'Mercury': 'Mercurio',
      'Venus': 'Venus',
      'Mars': 'Marte',
      'Jupiter': 'Júpiter',
      'Saturn': 'Saturno',
      'Uranus': 'Urano',
      'Neptune': 'Neptuno',
      'Pluto': 'Plutón',
      'Ascendant': 'Ascendente',
      'North Node': 'Nodo Norte',
      'South Node': 'Nodo Sur',
      'Lilith': 'Lilith',
      'Selena': 'Selena',
    },
  };

  static const _aspectNames = {
    'Eng': {
      'Conjunction': 'Conjunction',
      'Sextile': 'Sextile',
      'Square': 'Square',
      'Trine': 'Trine',
      'Opposition': 'Opposition',
    },
    'Rus': {
      'Conjunction': 'Соединение',
      'Sextile': 'Секстиль',
      'Square': 'Квадрат',
      'Trine': 'Трин',
      'Opposition': 'Оппозиция',
    },
    'Heb': {
      'Conjunction': 'קונג׳אנקשן',
      'Sextile': 'סקסטיל',
      'Square': 'ריבוע',
      'Trine': 'טרין',
      'Opposition': 'אופוזיציה',
    },
    'Spa': {
      'Conjunction': 'Conjunción',
      'Sextile': 'Sextil',
      'Square': 'Cuadratura',
      'Trine': 'Trígono',
      'Opposition': 'Oposición',
    },
  };

  static const _houseThemes = {
    'Eng': {
      1: 'self-expression',
      2: 'resources and values',
      3: 'learning and communication',
      4: 'home and roots',
      5: 'creativity and romance',
      6: 'work and routines',
      7: 'partnerships',
      8: 'shared bonds and trust',
      9: 'belief and expansion',
      10: 'career and visibility',
      11: 'friends and future goals',
      12: 'inner life and healing',
    },
    'Rus': {
      1: 'самовыражение',
      2: 'ресурсы и ценности',
      3: 'обучение и общение',
      4: 'дом и корни',
      5: 'творчество и романтика',
      6: 'работа и рутина',
      7: 'партнерство',
      8: 'глубина и доверие',
      9: 'убеждения и расширение',
      10: 'карьера и статус',
      11: 'друзья и цели',
      12: 'внутренний мир и исцеление',
    },
    'Heb': {
      1: 'ביטוי עצמי',
      2: 'משאבים וערכים',
      3: 'למידה ותקשורת',
      4: 'בית ושורשים',
      5: 'יצירה ורומנטיקה',
      6: 'עבודה ושגרה',
      7: 'שותפויות',
      8: 'עומק רגשי ואמון',
      9: 'אמונה והתרחבות',
      10: 'קריירה ונראות',
      11: 'חברים ומטרות עתידיות',
      12: 'עולם פנימי וריפוי',
    },
    'Spa': {
      1: 'expresion personal',
      2: 'recursos y valores',
      3: 'aprendizaje y comunicacion',
      4: 'hogar y raices',
      5: 'creatividad y romance',
      6: 'trabajo y rutina',
      7: 'pareja y alianzas',
      8: 'vinculos y confianza',
      9: 'creencias y expansion',
      10: 'carrera y visibilidad',
      11: 'amistades y metas',
      12: 'vida interior y sanacion',
    },
  };

  static const _signElements = {
    'Aries': 'fire',
    'Taurus': 'earth',
    'Gemini': 'air',
    'Cancer': 'water',
    'Leo': 'fire',
    'Virgo': 'earth',
    'Libra': 'air',
    'Scorpio': 'water',
    'Sagittarius': 'fire',
    'Capricorn': 'earth',
    'Aquarius': 'air',
    'Pisces': 'water',
  };

  String _pName(String name, String lang) =>
      _planetNames[lang]?[name] ?? _planetNames['Eng']?[name] ?? name;

  String _aName(String name, String lang) =>
      _aspectNames[lang]?[name] ?? _aspectNames['Eng']?[name] ?? name;

  String _t(Map<String, String> dictionary, String lang) =>
      dictionary[lang] ?? dictionary['Eng'] ?? '';

  String _byDetail(String shortText, String standardText, String deepText) {
    switch (detailLevel) {
      case 'short':
        return shortText;
      case 'standard':
        return standardText;
      default:
        return deepText;
    }
  }

  String _houseWord(String lang) {
    switch (lang) {
      case 'Heb':
        return 'בית';
      case 'Rus':
        return 'дом';
      case 'Spa':
        return 'casa';
      default:
        return 'house';
    }
  }

  static const _zodiacOrder = [
    'Aries',
    'Taurus',
    'Gemini',
    'Cancer',
    'Leo',
    'Virgo',
    'Libra',
    'Scorpio',
    'Sagittarius',
    'Capricorn',
    'Aquarius',
    'Pisces',
  ];

  static const _signRulers = {
    'Aries': 'Mars',
    'Taurus': 'Venus',
    'Gemini': 'Mercury',
    'Cancer': 'Moon',
    'Leo': 'Sun',
    'Virgo': 'Mercury',
    'Libra': 'Venus',
    'Scorpio': 'Pluto',
    'Sagittarius': 'Jupiter',
    'Capricorn': 'Saturn',
    'Aquarius': 'Uranus',
    'Pisces': 'Neptune',
  };

  PlanetPosition? _findPlanet(List<PlanetPosition> planets, String name) {
    for (final planet in planets) {
      if (planet.name == name) return planet;
    }
    return null;
  }

  String? _houseSignFromAscendant(String ascendantSign, int houseNumber) {
    final index = _zodiacOrder.indexOf(ascendantSign);
    if (index < 0) return null;
    return _zodiacOrder[(index + houseNumber - 1) % _zodiacOrder.length];
  }

  static const _signStyle = {
    'Eng': {
      'Aries':
          'active and pioneering — quick to initiate, independent, assertive',
      'Taurus':
          'steady and sensual — builds slowly, values security and comfort',
      'Gemini':
          'curious and communicative — seeks variety, duality, and mental exchange',
      'Cancer':
          'nurturing and protective — driven by emotion, seeks belonging and safety',
      'Leo':
          'expressive and confident — shines through creativity and self-presentation',
      'Virgo':
          'analytical and precise — serves through detail, refinement, and discernment',
      'Libra':
          'balanced and relational — seeks harmony, works through partnership and fairness',
      'Scorpio':
          'deep and transformative — intense, probes beneath the surface, regenerates',
      'Sagittarius':
          'expansive and optimistic — seeks meaning, freedom, and broad horizons',
      'Capricorn':
          'disciplined and ambitious — builds structures patiently, long-term oriented',
      'Aquarius':
          'innovative and independent — breaks patterns, community-oriented, forward-thinking',
      'Pisces':
          'intuitive and compassionate — dissolves boundaries, empathic, spiritually inclined',
    },
    'Rus': {
      'Aries':
          'активный и первопроходческий — быстро инициирует, независим, напорист',
      'Taurus':
          'устойчивый и чувственный — строит медленно, ценит безопасность и комфорт',
      'Gemini':
          'любознательный и общительный — ищет разнообразие и умственный обмен',
      'Cancer':
          'заботливый и защищающий — движется из эмоции, ищет принадлежность',
      'Leo':
          'выразительный и уверенный — сияет через творчество и самовыражение',
      'Virgo':
          'аналитический и точный — служит через детали, анализ и совершенствование',
      'Libra':
          'уравновешенный и реляционный — ищет гармонию, работает через партнёрство',
      'Scorpio':
          'глубокий и трансформирующий — интенсивный, исследует суть, обновляется',
      'Sagittarius':
          'расширяющийся и оптимистичный — ищет смысл, свободу и широкие горизонты',
      'Capricorn':
          'дисциплинированный и целеустремлённый — строит структуры терпеливо',
      'Aquarius':
          'инновационный и независимый — разрушает шаблоны, ориентирован на сообщество',
      'Pisces':
          'интуитивный и сострадательный — растворяет границы, эмпатичен, духовен',
    },
    'Heb': {
      'Aries': 'אקטיבי וחלוצי — מהיר ביוזמה, עצמאי, אסרטיבי',
      'Taurus': 'יציב וחושני — בונה לאט, מעריך ביטחון ונוחות',
      'Gemini': 'סקרן ותקשורתי — מחפש גיוון, כפולות, גמישות מנטלית',
      'Cancer': 'מטפח ומגן — מונע מרגש, מחפש שייכות וביטחון',
      'Leo': 'אקספרסיבי ובטוח — זורח דרך יצירתיות וביטוי עצמי',
      'Virgo': 'אנליטי ומדויק — משרת דרך פרטים, שיפור ואבחנה',
      'Libra': 'מאוזן וקשרי — מחפש הרמוניה, עובד דרך שותפות והוגנות',
      'Scorpio': 'עמוק וטרנספורמטיבי — עצים, חוקר לעומק, מתחדש',
      'Sagittarius': 'מתרחב ואופטימי — מחפש משמעות, חופש ואופקים רחבים',
      'Capricorn': 'ממושמע ושאפתן — בונה מבנים בסבלנות, מוכוון לטווח ארוך',
      'Aquarius': 'חדשני ועצמאי — שובר דפוסים, מוכוון קהילה, חושב קדימה',
      'Pisces': 'אינטואיטיבי ורחמן — מפרק גבולות, אמפתי, נוטה לרוחניות',
    },
    'Spa': {
      'Aries':
          'activo y pionero — rapido para iniciar, independiente, asertivo',
      'Taurus':
          'estable y sensual — construye lento, valora seguridad y comodidad',
      'Gemini':
          'curioso y comunicativo — busca variedad, perspectivas duales, agilidad mental',
      'Cancer':
          'nutritivo y protector — impulsado por emocion, busca pertenencia y seguridad',
      'Leo':
          'expresivo y seguro — brilla a traves de creatividad y autopresentacion',
      'Virgo':
          'analitico y preciso — sirve a traves de detalle, refinamiento y discernimiento',
      'Libra':
          'equilibrado y relacional — busca armonia, trabaja a traves de asociacion',
      'Scorpio':
          'profundo y transformador — intenso, sondea debajo de la superficie, regenera',
      'Sagittarius':
          'expansivo y optimista — busca significado, libertad y horizontes amplios',
      'Capricorn':
          'disciplinado y ambicioso — construye estructuras pacientemente',
      'Aquarius':
          'innovador e independiente — rompe patrones, orientado a la comunidad',
      'Pisces':
          'intuitivo y compasivo — disuelve limites, empatico, inclinado espiritualmente',
    },
  };

  static const _aspectTypeMeanings = {
    'Eng': {
      'Conjunction':
          'Two planetary forces merge into one unified field — their qualities are inseparable and amplify each other powerfully. This creates a core personality pattern that runs automatically through all daily behavior, decisions, and instinctive reactions.',
      'Opposition':
          'Two forces pull in opposite directions, creating a natural push-pull tension that often plays out through key relationships and life choices. What is not consciously owned tends to be projected onto others — integrating both sides is the central psychological task.',
      'Square':
          'Two forces create productive inner friction that demands action and resolution. The discomfort is real but generative — people with strong squares often accomplish significant things precisely because the tension pushes them beyond their comfort zone and into meaningful growth.',
      'Trine':
          'Two forces flow naturally and effortlessly together, creating a life area where things come without struggle. The gift is genuine but can become unconscious — the challenge is to actively and intentionally engage this ease rather than assuming it will always operate on its own.',
      'Sextile':
          'Two forces cooperate harmoniously when given the opportunity and a conscious push. Unlike a trine, this potential requires deliberate activation, but once engaged it creates productive, reliable, and lasting patterns in the relevant areas of life.',
    },
    'Rus': {
      'Conjunction':
          'Два планетарных начала сливаются в единое поле — их качества неразделимы и взаимно усиливаются. Это создаёт стержневую черту личности, которая работает автоматически и пронизывает всё поведение, реакции и повседневные решения.',
      'Opposition':
          'Два начала тянут в противоположные стороны, создавая качели напряжения, которые чаще всего разыгрываются через ключевые отношения и жизненные выборы. То, что не осознаётся внутри, проецируется на других — интеграция обеих сторон становится главной психологической задачей.',
      'Square':
          'Два начала создают продуктивное внутреннее трение, требующее действия и разрешения. Дискомфорт реален, но он генеративен — люди с сильными квадратами нередко достигают значительного именно потому, что напряжение выталкивает их за пределы зоны комфорта.',
      'Trine':
          'Два начала текут естественно и легко, создавая область жизни, где всё приходит без борьбы. Дар реален, но может стать неосознанным — вызов состоит в том, чтобы активно и намеренно задействовать эту лёгкость, а не принимать её как данность.',
      'Sextile':
          'Два начала гармонично сотрудничают при наличии возможности и сознательного усилия. В отличие от трина, этот потенциал требует намеренной активации, но при задействовании создаёт надёжные и устойчивые паттерны в соответствующих областях жизни.',
    },
    'Heb': {
      'Conjunction':
          'שני כוחות פלנטריים מתמזגים לשדה אחד — האיכויות שלהם בלתי ניתנות להפרדה ומגבירות זו את זו. זה יוצר תבנית אישיות מרכזית שפועלת אוטומטית ומחלחלת לכל ההתנהגות, התגובות וההחלטות של כל יום.',
      'Opposition':
          'שני כוחות מושכים לכיוונים מנוגדים — זה יוצר מתח טבעי שלעתים קרובות מתנגן ביחסים מרכזיים ובהחלטות חיים. מה שאינו מוכר פנימית נוטה להיות מוקרן על אחרים; האינטגרציה של שני הצדדים היא המשימה הפסיכולוגית המרכזית.',
      'Square':
          'שני כוחות יוצרים חיכוך פנימי פרודוקטיבי שדורש פעולה ופתרון. אי-הנוחות אמיתית אבל מניעה — אנשים עם ריבועים חזקים לעתים קרובות משיגים דברים משמעותיים דווקא משום שהמתח דוחף אותם מעבר לאזור הנוחות ולצמיחה ממשית.',
      'Trine':
          'שני כוחות זורמים בקלות ובטבעיות — זה יוצר אזור חיים שבו דברים מגיעים ללא מאבק. המתנה אמיתית אך עלולה להפוך ללא מודעת; האתגר הוא לעסוק בה באופן פעיל ומכוון ולא להניח שהיא תמיד תהיה שם.',
      'Sextile':
          'שני כוחות משתפים פעולה בהרמוניה כשניתנת הזדמנות ודחיפה מכוונת. בשונה מהטריין, הפוטנציאל הזה דורש הפעלה מודעת, אך ברגע שמעורב הוא יוצר דפוסים פרודוקטיביים ואמינים.',
    },
    'Spa': {
      'Conjunction':
          'Dos fuerzas planetarias se fusionan en un campo unificado — sus cualidades son inseparables y se amplifican mutuamente. Esto crea un patron de personalidad central que opera automaticamente y permea todo el comportamiento, reacciones y decisiones diarias.',
      'Opposition':
          'Dos fuerzas tiran en direcciones opuestas, creando una tension natural de sube y baja que suele jugarse en relaciones clave y elecciones de vida. Lo que no se posee conscientemente tiende a proyectarse en otros — integrar ambos lados se convierte en la tarea psicologica central.',
      'Square':
          'Dos fuerzas crean friccion interna productiva que exige accion y resolucion. La incomodidad es real pero generativa — las personas con cuadraturas fuertes a menudo logran cosas significativas precisamente porque la tension las empuja fuera de su zona de confort.',
      'Trine':
          'Dos fuerzas fluyen natural y facilmente juntas, creando un area de vida donde las cosas vienen sin esfuerzo. El don es genuino pero puede volverse inconsciente — el desafio es comprometerlo activa e intencionalmente.',
      'Sextile':
          'Dos fuerzas cooperan armoniosamente cuando se les da la oportunidad y un impulso consciente. A diferencia del trigono, este potencial requiere activacion deliberada, pero una vez comprometido crea patrones productivos y duraderos.',
    },
  };

  static const _configScenarios = {
    'Eng': {
      'T-Square':
          'A T-square creates a driven, restless dynamic: the opposition generates constant tension, and the apex planet acts as the pressure valve that must find expression. Life repeatedly cycles through themes of conflict, action, and release. Real achievement comes when the apex planet\'s area is actively developed rather than avoided.',
      'Grand Trine':
          'A grand trine creates a self-contained circuit of ease and natural talent — three areas of life that support each other effortlessly. The risk is self-sufficiency without growth; the gift becomes most powerful when it is deliberately offered outward rather than circulating internally.',
      'Yod':
          'A Yod (Finger of God) creates a precise, fated-feeling call to adjustment. The apex planet must continually recalibrate, redirecting its energy in ways that may feel unfamiliar or destabilizing. This is not a problem — it is a specialized life direction that unfolds through repeated, subtle corrections.',
      'Stellium':
          'A stellium concentrates multiple planetary energies in one sign or house, making that life theme overwhelmingly dominant. It is the chart\'s loudest voice — where the most learning, complexity, and potential are packed together. Working consciously with this area transforms the stellium from a source of overwhelm into a source of mastery.',
      'Grand Cross':
          'A grand cross involves four planets in a constant four-way tension that demands simultaneous movement on multiple fronts. Mastery comes through learning to balance and rotate attention across all four axes rather than trying to resolve any single one permanently.',
      'Kite':
          'A kite combines the ease of a grand trine with a focused outlet — one planet\'s opposition to the trine creates a directed channel for the talent to flow outward. This is a configuration of gift with direction, making it one of the more productive patterns in a chart.',
    },
    'Rus': {
      'T-Square':
          'Т-квадрат создаёт напряжённую, беспокойную динамику: оппозиция порождает постоянное напряжение, а апексная планета — клапан, который должен найти выражение. Жизнь циклически проходит через конфликт, действие и разрядку. Реальные достижения приходят, когда область апексной планеты активно развивается, а не избегается.',
      'Grand Trine':
          'Большой трин создаёт самодостаточную цепь лёгкости и природного таланта. Риск — самодостаточность без роста; дар становится наиболее мощным, когда его намеренно направляют вовне.',
      'Yod':
          'Йод — судьбоносный призыв к корректировке. Апексная планета должна постоянно перекалиброваться, направляя свою энергию непривычными путями. Это не проблема — это специализированное жизненное направление, раскрывающееся через тонкие повторяющиеся поправки.',
      'Stellium':
          'Стеллиум концентрирует несколько планетарных энергий в одном знаке или доме, делая эту тему жизни доминирующей. Это самый громкий голос карты — там сосредоточено наибольшее обучение, сложность и потенциал. Сознательная работа с этой областью превращает стеллиум из источника перегрузки в источник мастерства.',
      'Grand Cross':
          'Большой крест создаёт постоянное четырёхстороннее напряжение, требующее одновременного движения по нескольким направлениям. Мастерство приходит через умение балансировать и переключать внимание между всеми четырьмя осями.',
      'Kite':
          'Кайт сочетает лёгкость большого трина с направленным выходом — один из углов имеет оппозицию, создающую канал для таланта. Это конфигурация дара с направлением.',
    },
    'Heb': {
      'T-Square':
          'טי-סקוור יוצר דינמיקה נעה ולא שקטה: האופוזיציה מייצרת מתח קבוע, וכוכב האיקס פועל כשסתום לחץ שחייב למצוא ביטוי. החיים חוזרים שוב ושוב על מחזורים של קונפליקט, פעולה ושחרור. ההישגים האמיתיים מגיעים כשאזור כוכב האיקס מפותח באופן פעיל ולא נמנע.',
      'Grand Trine':
          'גרנד טריין יוצר מעגל עצמאי של קלות וכישרון טבעי — שלושה אזורי חיים שתומכים זה בזה ללא מאמץ. הסיכון הוא עצמאות ללא צמיחה; המתנה הופכת חזקה ביותר כשמציעים אותה החוצה באופן מכוון.',
      'Yod':
          'יוד (אצבע האלוהים) יוצר קריאה מדויקת ותחושת גורל להתאמה. כוכב האיקס חייב לכוון מחדש באופן מתמיד, להפנות אנרגיה בדרכים שעשויות להרגיש לא מוכרות. זו אינה בעיה — זה כיוון חיים מיוחד שמתגלה דרך תיקונים עדינים וחוזרים.',
      'Stellium':
          'סטליום מרכז כמה אנרגיות פלנטריות בסימן או בבית אחד, ועושה את נושא החיים הזה לדומיננטי. זהו הקול החזק ביותר במפה — שם ריכוז הלמידה, המורכבות והפוטנציאל הגדול ביותר. עבודה מודעת עם האזור הזה הופכת את הסטליום מדי-עומס לדי-שליטה.',
      'Grand Cross':
          'גרנד קרוס כולל ארבעה כוכבים במתח רב-כיווני קבוע שדורש תנועה בו-זמנית בכמה חזיתות. הבקיאות מגיעה דרך לימוד איזון וסיבוב תשומת הלב בין כל ארבע הצירים.',
      'Kite':
          'קייט משלב את קלות הגרנד טריין עם יציאה ממוקדת — כוכב אחד יוצר אופוזיציה שיוצרת ערוץ לכישרון לזרום החוצה. זוהי קונפיגורציה של מתנה עם כיוון.',
    },
    'Spa': {
      'T-Square':
          'Una T-cuadrada crea una dinamica impulsada e inquieta: la oposicion genera tension constante, y el planeta apex actua como valvula de presion que debe encontrar expresion. La vida cicla repetidamente a traves de conflicto, accion y liberacion.',
      'Grand Trine':
          'Un gran trigono crea un circuito autosuficiente de facilidad y talento natural. El riesgo es la autosuficiencia sin crecimiento; el don se vuelve mas poderoso cuando se ofrece deliberadamente hacia afuera.',
      'Yod':
          'Un Yod crea un llamado preciso y fatalista al ajuste. El planeta apex debe recalibrarse continuamente, redirigiendo su energia de maneras que pueden sentirse poco familiares. Esta es una direccion de vida especializada que se despliega a traves de correcciones sutiles y repetidas.',
      'Stellium':
          'Un stellium concentra multiples energias planetarias en un signo o casa, haciendo que ese tema de vida sea abrumadoramente dominante. Trabajar conscientemente con esta area transforma el stellium de una fuente de abrumamiento en una fuente de maestria.',
      'Grand Cross':
          'Una Cruz Grande involucra cuatro planetas en tension de cuatro vias que exige movimiento simultaneo en multiples frentes. El dominio viene al aprender a equilibrar y rotar la atencion entre los cuatro ejes.',
      'Kite':
          'Una cometa combina la facilidad de un gran trigono con una salida enfocada — la oposicion de un planeta crea un canal dirigido para que el talento fluya hacia afuera.',
    },
  };

  String _getSignStyle(String sign, String lang) =>
      _signStyle[lang]?[sign] ?? _signStyle['Eng']?[sign] ?? sign;

  String _getAspectTypeMeaning(String aspectType, String lang) =>
      _aspectTypeMeanings[lang]?[aspectType] ??
      _aspectTypeMeanings['Eng']?[aspectType] ??
      '';

  String _getConfigScenario(String cfg, String lang) {
    final key = _configScenarios[lang] ?? _configScenarios['Eng']!;
    for (final prefix in key.keys) {
      if (cfg.startsWith(prefix)) return key[prefix]!;
    }
    return _configScenarios['Eng']!.values.last;
  }

  String _houseRulerLine(
    String lang,
    int houseNumber,
    List<PlanetPosition> planets,
    String ascendantSign,
    String? houseSign,
  ) {
    final resolvedHouseSign = (houseSign != null && houseSign.isNotEmpty)
        ? houseSign
        : _houseSignFromAscendant(ascendantSign, houseNumber);
    if (resolvedHouseSign == null || resolvedHouseSign.isEmpty) {
      switch (lang) {
        case 'Heb':
          return '- בית $houseNumber: אין מספיק נתונים כדי לשחזר שליט בית משוער.';
        case 'Rus':
          return '- Дом $houseNumber: недостаточно данных для примерного определения управителя дома.';
        case 'Spa':
          return '- Casa $houseNumber: no hay datos suficientes para estimar el regente de la casa.';
        default:
          return '- House $houseNumber: not enough data to estimate a house ruler.';
      }
    }

    final ruler = _signRulers[resolvedHouseSign] ?? '';
    final rulerPlanet = _findPlanet(planets, ruler);
    final houseTheme =
        _houseThemes[lang]?[houseNumber] ?? _houseThemes['Eng']![houseNumber]!;
    final rulerName = _pName(ruler, lang);
    final rulerSign = rulerPlanet?.sign ?? '';
    final rulerHouseNum = rulerPlanet?.house ?? 0;
    final rulerHouseTheme = rulerHouseNum > 0
        ? (_houseThemes[lang]?[rulerHouseNum] ?? '')
        : '';
    final howStyle = _getSignStyle(resolvedHouseSign, lang);
    final styleStyle = rulerSign.isNotEmpty
        ? _getSignStyle(rulerSign, lang)
        : '';
    final notAvail =
        {
          'Heb': 'לא הוחזר מהשרת',
          'Rus': 'нет в ответе сервера',
          'Spa': 'no disponible',
        }[lang] ??
        'not in backend response';

    switch (lang) {
      case 'Heb':
        return '- בית $houseNumber ($resolvedHouseSign) — $houseTheme:\n'
            '  ➤ איך (HOW): $resolvedHouseSign — $howStyle\n'
            '  ➤ איפה (WHERE): $rulerName ${rulerHouseNum > 0 ? "בבית $rulerHouseNum${rulerHouseTheme.isNotEmpty ? " ($rulerHouseTheme)" : ""}" : notAvail} — כאן אנרגיית הבית מתממשת בפועל\n'
            '  ➤ סגנון (STYLE): $rulerName ${rulerSign.isNotEmpty ? "ב-$rulerSign — $styleStyle" : notAvail}';
      case 'Rus':
        return '- Дом $houseNumber ($resolvedHouseSign) — $houseTheme:\n'
            '  ➤ КАК: $resolvedHouseSign — $howStyle\n'
            '  ➤ ГДЕ: $rulerName ${rulerHouseNum > 0 ? "в доме $rulerHouseNum${rulerHouseTheme.isNotEmpty ? " ($rulerHouseTheme)" : ""}" : notAvail} — здесь реализуется энергия этого дома\n'
            '  ➤ СТИЛЬ: $rulerName ${rulerSign.isNotEmpty ? "в $rulerSign — $styleStyle" : notAvail}';
      case 'Spa':
        return '- Casa $houseNumber ($resolvedHouseSign) — $houseTheme:\n'
            '  ➤ COMO: $resolvedHouseSign — $howStyle\n'
            '  ➤ DONDE: $rulerName ${rulerHouseNum > 0 ? "en casa $rulerHouseNum${rulerHouseTheme.isNotEmpty ? " ($rulerHouseTheme)" : ""}" : notAvail} — ahi se concreta la energia de esta casa\n'
            '  ➤ ESTILO: $rulerName ${rulerSign.isNotEmpty ? "en $rulerSign — $styleStyle" : notAvail}';
      default:
        return '- House $houseNumber ($resolvedHouseSign) — $houseTheme:\n'
            '  ➤ HOW: $resolvedHouseSign — $howStyle\n'
            '  ➤ WHERE: $rulerName ${rulerHouseNum > 0 ? "in house $rulerHouseNum${rulerHouseTheme.isNotEmpty ? " ($rulerHouseTheme)" : ""}" : notAvail} — this is where the house energy concretely operates\n'
            '  ➤ STYLE: $rulerName ${rulerSign.isNotEmpty ? "in $rulerSign — $styleStyle" : notAvail}';
    }
  }

  String _buildMethodGeneralInfo(String lang) {
    final c = chart;
    if (c == null) return '';

    final planets = c.planets;
    final houseSignMap = {for (final h in c.houses) h.number: h.sign};
    final hasBackendHouseSigns = c.houses.isNotEmpty;
    final majorAspects =
        c.aspects
            .where(
              (a) => const {
                'Conjunction',
                'Opposition',
                'Square',
                'Trine',
                'Sextile',
              }.contains(a.aspect),
            )
            .toList()
          ..sort((a, b) => a.orb.compareTo(b.orb));

    final elementCounts = <String, int>{
      'fire': 0,
      'earth': 0,
      'air': 0,
      'water': 0,
    };
    for (final p in planets) {
      final element = _signElements[p.sign];
      if (element != null) {
        elementCounts[element] = (elementCounts[element] ?? 0) + 1;
      }
    }

    final stepTitles = {
      'Eng': [
        'Step 1 - Houses',
        'Step 2 - House Rulers',
        'Step 3 - Aspects',
        'Step 4 - Configurations',
        'Step 5 - Special Points',
        'Step 6 - Final Integration',
      ],
      'Rus': [
        'Шаг 1 - Дома',
        'Шаг 2 - Управители домов',
        'Шаг 3 - Аспекты',
        'Шаг 4 - Конфигурации',
        'Шаг 5 - Особые точки',
        'Шаг 6 - Итоговая интеграция',
      ],
      'Heb': [
        'שלב 1 - בתים',
        'שלב 2 - שליטי בתים',
        'שלב 3 - אספקטים',
        'שלב 4 - קונפיגורציות',
        'שלב 5 - נקודות מיוחדות',
        'שלב 6 - אינטגרציה סופית',
      ],
      'Spa': [
        'Paso 1 - Casas',
        'Paso 2 - Regentes de casas',
        'Paso 3 - Aspectos',
        'Paso 4 - Configuraciones',
        'Paso 5 - Puntos especiales',
        'Paso 6 - Integracion final',
      ],
    };

    final summaries = {
      'Eng': 'Structured analysis (based on your preferred method):',
      'Rus': 'Структурный анализ (по вашему методу):',
      'Heb': 'ניתוח מובנה ומורחב (לפי השיטה המועדפת שלך):',
      'Spa': 'Analisis estructurado (segun tu metodo preferido):',
    };

    final noAspects = {
      'Eng': 'No major aspects returned for this chart.',
      'Rus': 'Для этой карты не возвращены мажорные аспекты.',
      'Heb': 'לא הוחזרו אספקטים מרכזיים עבור מפה זו.',
      'Spa': 'No se devolvieron aspectos mayores para esta carta.',
    };

    final noConfigs = {
      'Eng': 'No major configurations detected.',
      'Rus': 'Крупные конфигурации не обнаружены.',
      'Heb': 'לא זוהו קונפיגורציות מרכזיות.',
      'Spa': 'No se detectaron configuraciones mayores.',
    };

    final sb = StringBuffer();
    final titleSet = stepTitles[lang] ?? stepTitles['Eng']!;
    sb.writeln(_t(summaries, lang));
    switch (lang) {
      case 'Heb':
        sb.writeln(
          _byDetail(
            'בסיס: ${planets.length} פלנטות, ${majorAspects.length} אספקטים, ${configurations.length} קונפיגורציות.',
            'בסיס הנתונים: ${planets.length} פלנטות, ${majorAspects.length} אספקטים מרכזיים, ${configurations.length} קונפיגורציות. המטרה כאן היא לחבר את הנתונים לקו התנהגותי ברור.',
            'בסיס הנתונים: ${planets.length} פלנטות, ${majorAspects.length} אספקטים מרכזיים, ${configurations.length} קונפיגורציות. המטרה כאן היא לא רק לתאר אלא גם לחבר בין הדפוסים לתמונה התנהגותית אחת, עם דגש על יישום בחיי יום-יום.',
          ),
        );
        break;
      case 'Rus':
        sb.writeln(
          _byDetail(
            'База анализа: ${planets.length} планет, ${majorAspects.length} аспектов, ${configurations.length} конфигураций.',
            'База анализа: ${planets.length} планет, ${majorAspects.length} мажорных аспектов, ${configurations.length} конфигураций. Ниже не список факторов, а связанная поведенческая модель.',
            'База анализа: ${planets.length} планет, ${majorAspects.length} мажорных аспектов, ${configurations.length} конфигураций. Ниже не просто список факторов, а связанная поведенческая модель: как это проявляется в решениях, отношениях и ежедневном ритме.',
          ),
        );
        break;
      case 'Spa':
        sb.writeln(
          _byDetail(
            'Base: ${planets.length} planetas, ${majorAspects.length} aspectos, ${configurations.length} configuraciones.',
            'Base del analisis: ${planets.length} planetas, ${majorAspects.length} aspectos mayores, ${configurations.length} configuraciones. Abajo veras una lectura integrada.',
            'Base del analisis: ${planets.length} planetas, ${majorAspects.length} aspectos mayores, ${configurations.length} configuraciones. Abajo no es solo una lista de factores, sino un modelo integrado de comportamiento y decisiones.',
          ),
        );
        break;
      default:
        sb.writeln(
          _byDetail(
            'Analysis base: ${planets.length} planets, ${majorAspects.length} aspects, ${configurations.length} configurations.',
            'Analysis base: ${planets.length} planets, ${majorAspects.length} major aspects, ${configurations.length} configurations. The goal is to integrate symbols into one usable pattern.',
            'Analysis base: ${planets.length} planets, ${majorAspects.length} major aspects, ${configurations.length} configurations. The goal below is not just listing symbols, but integrating them into one behavioral map you can apply in real life.',
          ),
        );
    }
    sb.writeln();

    sb.writeln(titleSet[0]);
    for (int house = 1; house <= 12; house++) {
      final inHouse = planets.where((p) => p.house == house).toList();
      final theme = _houseThemes[lang]?[house] ?? _houseThemes['Eng']![house]!;
      final cuspSign = hasBackendHouseSigns
          ? (houseSignMap[house] ?? '')
          : (_houseSignFromAscendant(c.ascendantSign, house) ?? '');
      final signStyleDesc = cuspSign.isNotEmpty
          ? _getSignStyle(cuspSign, lang)
          : '';
      final signLabel = cuspSign.isNotEmpty ? ' ($cuspSign)' : '';
      if (inHouse.isEmpty) {
        switch (lang) {
          case 'Heb':
            sb.writeln(
              '- בית $house$signLabel — $theme: $signStyleDesc. אין ריכוז כוכבים בבית זה, כך שהנושא פועל כרקע עדין. כדאי לבחון איך הסגנון של $cuspSign מתבטא בגישה לנושאים הקשורים ל-$theme.',
            );
            break;
          case 'Rus':
            sb.writeln(
              '- Дом $house$signLabel — $theme: $signStyleDesc. Концентрации планет здесь нет; тема работает как фоновый фильтр, окрашивая область $theme стилем $cuspSign.',
            );
            break;
          case 'Spa':
            sb.writeln(
              '- Casa $house$signLabel — $theme: $signStyleDesc. Sin concentracion planetaria; el tema opera como filtro de fondo, coloreando $theme a traves del estilo $cuspSign.',
            );
            break;
          default:
            sb.writeln(
              '- House $house$signLabel — $theme: $signStyleDesc. No planets concentrated here; this theme operates as a background filter coloring $theme through the $cuspSign style.',
            );
        }
      } else {
        final names = inHouse.map((p) => _pName(p.name, lang)).join(', ');
        switch (lang) {
          case 'Heb':
            sb.writeln(
              '- בית $house$signLabel — $theme: $signStyleDesc. כוכבים כאן: $names. ריכוז הכוכבים בבית זה הופך אותו לאזור חיים דומיננטי — נושאים של $theme נוכחים בעוצמה, מרוכבים, ודורשים מודעות פעילה, בחירות מכוונות וגישה הוליסטית.',
            );
            break;
          case 'Rus':
            sb.writeln(
              '- Дом $house$signLabel — $theme: $signStyleDesc. Планеты здесь: $names. Концентрация делает эту тему доминирующей зоной жизни — $theme присутствует с особой силой и требует активного осознания и работы.',
            );
            break;
          case 'Spa':
            sb.writeln(
              '- Casa $house$signLabel — $theme: $signStyleDesc. Planetas aqui: $names. La concentracion convierte este tema en una zona de vida dominante — $theme esta presente con fuerza y exige atencion activa.',
            );
            break;
          default:
            sb.writeln(
              '- House $house$signLabel — $theme: $signStyleDesc. Planets here: $names. This concentration makes the house a dominant life zone — $theme is strongly present, complex, and demands active awareness and intentional engagement.',
            );
        }
      }
    }
    switch (lang) {
      case 'Heb':
        sb.writeln(
          'מסקנות מעשיות (שלב 1): סדר עדיפויות לשבוע הקרוב צריך להתחיל מבתים דומיננטיים, ורק אחר כך מנושאי רקע. כך האנרגיה מושקעת במקום עם התשואה הגבוהה ביותר.',
        );
        break;
      case 'Rus':
        sb.writeln(
          'Практические выводы (Шаг 1): приоритизируйте задачи через доминирующие дома, а фоновые темы оставляйте на второй план. Это повышает эффективность и снижает внутренний шум.',
        );
        break;
      case 'Spa':
        sb.writeln(
          'Conclusiones practicas (Paso 1): prioriza decisiones y objetivos por casas dominantes; los temas de fondo van en segundo plano. Asi aumenta la claridad y el resultado.',
        );
        break;
      default:
        sb.writeln(
          'Practical conclusions (Step 1): prioritize weekly decisions through dominant houses first, and treat background houses as secondary. This keeps effort aligned with your strongest developmental zones.',
        );
    }
    sb.writeln();

    sb.writeln(titleSet[1]);
    final houses = c.houses;
    if (houses.isNotEmpty) {
      for (final house in houses) {
        sb.writeln(
          _houseRulerLine(
            lang,
            house.number,
            planets,
            c.ascendantSign,
            house.sign,
          ),
        );
      }
    } else {
      for (int house = 1; house <= 12; house++) {
        sb.writeln(
          _houseRulerLine(lang, house, planets, c.ascendantSign, null),
        );
      }
    }
    switch (lang) {
      case 'Heb':
        sb.writeln(
          'מסקנות מעשיות (שלב 2): כשנושא בית "תקוע", בדקו את מצב שליט הבית (בית+מזל) — שם נמצא מנגנון ההפעלה האמיתי והפתרון המעשי.',
        );
        break;
      case 'Rus':
        sb.writeln(
          'Практические выводы (Шаг 2): если тема дома не движется, смотрите на управителя (его дом и знак). Именно там находится рабочий рычаг для изменений.',
        );
        break;
      case 'Spa':
        sb.writeln(
          'Conclusiones practicas (Paso 2): cuando un tema de casa se bloquea, revisa el regente (casa + signo). Ahi esta la palanca real para destrabar el proceso.',
        );
        break;
      default:
        sb.writeln(
          'Practical conclusions (Step 2): when a house theme feels blocked, diagnose its ruler placement (house + sign). That is usually the real operational lever for progress.',
        );
    }
    sb.writeln();

    sb.writeln(titleSet[2]);
    if (majorAspects.isEmpty) {
      sb.writeln('- ${_t(noAspects, lang)}');
    } else {
      for (final a in majorAspects.take(12)) {
        final p1 = _pName(a.planet1, lang);
        final p2 = _pName(a.planet2, lang);
        final an = _aName(a.aspect, lang);
        final typeMeaning = _getAspectTypeMeaning(a.aspect, lang);
        final p1Obj = _findPlanet(planets, a.planet1);
        final p2Obj = _findPlanet(planets, a.planet2);
        final h1 = p1Obj?.house ?? 0;
        final h2 = p2Obj?.house ?? 0;
        final h1Theme = h1 > 0
            ? (_houseThemes[lang]?[h1] ?? _houseThemes['Eng']![h1]!)
            : '';
        final h2Theme = h2 > 0
            ? (_houseThemes[lang]?[h2] ?? _houseThemes['Eng']![h2]!)
            : '';
        switch (lang) {
          case 'Heb':
            sb.writeln(
              '- $p1 $an $p2 (אורב ${a.orb.toStringAsFixed(1)}°): $typeMeaning${h1 > 0 && h2 > 0 ? " תחומי ההפעלה המרכזיים: בית $h1 ($h1Theme) ובית $h2 ($h2Theme)." : ""}',
            );
            break;
          case 'Rus':
            sb.writeln(
              '- $p1 $an $p2 (орб ${a.orb.toStringAsFixed(1)}°): $typeMeaning${h1 > 0 && h2 > 0 ? " Ключевые сферы проявления: дом $h1 ($h1Theme) и дом $h2 ($h2Theme)." : ""}',
            );
            break;
          case 'Spa':
            sb.writeln(
              '- $p1 $an $p2 (orbe ${a.orb.toStringAsFixed(1)}°): $typeMeaning${h1 > 0 && h2 > 0 ? " Areas principales de expresion: casa $h1 ($h1Theme) y casa $h2 ($h2Theme)." : ""}',
            );
            break;
          default:
            sb.writeln(
              '- $p1 $an $p2 (orb ${a.orb.toStringAsFixed(1)}°): $typeMeaning${h1 > 0 && h2 > 0 ? " Core life arenas: house $h1 ($h1Theme) and house $h2 ($h2Theme)." : ""}',
            );
        }
      }
    }
    switch (lang) {
      case 'Heb':
        sb.writeln(
          'מסקנות מעשיות (שלב 3): אספקטים עם אורב קטן יותר עובדים חזק יותר כרגע. התחילו בזיהוי 2-3 אספקטים מובילים ותרגמו אותם להרגלים יומיומיים.',
        );
        break;
      case 'Rus':
        sb.writeln(
          'Практические выводы (Шаг 3): аспекты с меньшим орбом обычно ощущаются сильнее. Выберите 2-3 ведущих аспекта и превратите их в конкретные поведенческие правила.',
        );
        break;
      case 'Spa':
        sb.writeln(
          'Conclusiones practicas (Paso 3): los aspectos con orbe menor suelen sentirse con mayor intensidad. Elige 2-3 claves y conviertelas en habitos observables.',
        );
        break;
      default:
        sb.writeln(
          'Practical conclusions (Step 3): tighter orbs tend to dominate lived experience. Start with 2-3 strongest aspects and convert them into concrete behavioral routines.',
        );
    }
    sb.writeln();

    sb.writeln(titleSet[3]);
    if (configurations.isEmpty) {
      sb.writeln('- ${_t(noConfigs, lang)}');
    } else {
      for (final cfg in configurations) {
        final houses = <int>{};
        for (final p in planets) {
          if (cfg.contains(p.name)) houses.add(p.house);
        }
        final houseList = houses.toList()..sort();
        final houseText = houseList.isNotEmpty ? houseList.join(', ') : '';
        final scenario = _getConfigScenario(cfg, lang);
        switch (lang) {
          case 'Heb':
            sb.writeln(
              '- $cfg${houseText.isNotEmpty ? " | בתים: $houseText" : ""}:\n  $scenario',
            );
            break;
          case 'Rus':
            sb.writeln(
              '- $cfg${houseText.isNotEmpty ? " | дома: $houseText" : ""}:\n  $scenario',
            );
            break;
          case 'Spa':
            sb.writeln(
              '- $cfg${houseText.isNotEmpty ? " | casas: $houseText" : ""}:\n  $scenario',
            );
            break;
          default:
            sb.writeln(
              '- $cfg${houseText.isNotEmpty ? " | houses: $houseText" : ""}:\n  $scenario',
            );
        }
      }
    }
    switch (lang) {
      case 'Heb':
        sb.writeln(
          'מסקנות מעשיות (שלב 4): קונפיגורציה מרכזית היא "מערכת הפעלה" של המפה. כדאי לנסח עבורה אסטרטגיה אחת ברורה לניהול עומס, קונפליקט ותיעדוף.',
        );
        break;
      case 'Rus':
        sb.writeln(
          'Практические выводы (Шаг 4): ведущая конфигурация работает как «операционная система» карты. Под нее стоит выстроить отдельную стратегию нагрузки, фокуса и восстановления.',
        );
        break;
      case 'Spa':
        sb.writeln(
          'Conclusiones practicas (Paso 4): la configuracion principal funciona como sistema operativo de la carta. Conviene definir una estrategia clara de foco, carga y recuperacion.',
        );
        break;
      default:
        sb.writeln(
          'Practical conclusions (Step 4): your leading configuration behaves like the chart\'s operating system. Build one explicit strategy for focus, stress management, and recovery around it.',
        );
    }
    sb.writeln();

    sb.writeln(titleSet[4]);
    final nn = planets
        .where((p) => p.name == 'North Node')
        .cast<PlanetPosition?>()
        .firstWhere((p) => p != null, orElse: () => null);
    final sn = planets
        .where((p) => p.name == 'South Node')
        .cast<PlanetPosition?>()
        .firstWhere((p) => p != null, orElse: () => null);
    final lilith = planets
        .where((p) => p.name == 'Lilith')
        .cast<PlanetPosition?>()
        .firstWhere((p) => p != null, orElse: () => null);
    final selena = planets
        .where((p) => p.name == 'Selena')
        .cast<PlanetPosition?>()
        .firstWhere((p) => p != null, orElse: () => null);

    switch (lang) {
      case 'Heb':
        sb.writeln(
          '- אסצנדנט: ${c.ascendantSign} ${c.ascendantDegrees.toStringAsFixed(1)}° - ההתנהגות החיצונית, שפת הגוף ואופן הכניסה לחיים. האסצנדנט מראה איך אחרים פוגשים אותך וגם איך אתה/את נוטים להתחיל מצבים חדשים.',
        );
        sb.writeln(
          '- הצומת הצפוני: ${nn != null ? '${nn.sign} בית ${nn.house}' : 'לא זמין'} - כיוון צמיחה והתפתחות, המקום שבו כדאי לצאת מאזור הנוחות ולבנות מיומנות חדשה לאורך זמן.',
        );
        sb.writeln(
          '- הצומת הדרומי: ${sn != null ? '${sn.sign} בית ${sn.house}' : 'לא זמין'} - דפוסי עבר, נטייה מוכרת ואזור נוחות. זה המקום שבו יש כבר ידע טבעי, אבל גם סיכון להיתקע באוטומט ישן.',
        );
        sb.writeln(
          '- לילית: ${lilith != null ? '${lilith.sign} בית ${lilith.house}' : 'לא זמין'} - צל, עוצמה מוסתרת וגבולות. לילית מצביעה על מקום שבו עשויה להיות רגישות, דחייה או כוח לא ממומש שדורש הכרה מודעת.',
        );
        sb.writeln(
          '- סלנה: ${selena != null ? '${selena.sign} בית ${selena.house}' : 'אין נתון סלנה בתגובה מהשרת כרגע'} - אזור תמיכה והרמוניה, מקום שבו קל יותר לקבל עזרה, הגנה וזרימה טבעית.',
        );
        break;
      case 'Rus':
        sb.writeln(
          '- Асцендент: ${c.ascendantSign} ${c.ascendantDegrees.toStringAsFixed(1)}° - внешнее поведение, телесная подача и первичная стратегия входа в новые ситуации. Это точка, через которую мир считывает вас до того, как проявятся более глубокие пласты карты.',
        );
        sb.writeln(
          '- Северный узел: ${nn != null ? '${nn.sign}, дом ${nn.house}' : 'нет данных'} - вектор роста и зона, где важно нарабатывать новую компетенцию, даже если это некомфортно.',
        );
        sb.writeln(
          '- Южный узел: ${sn != null ? '${sn.sign}, дом ${sn.house}' : 'нет данных'} - автоматические прошлые сценарии и накопленный опыт; здесь уже есть легкость, но также риск застревания в привычном.',
        );
        sb.writeln(
          '- Лилит: ${lilith != null ? '${lilith.sign}, дом ${lilith.house}' : 'нет данных'} - теневая энергия, тема границ и непризнанной силы; именно здесь часто скрыт ресурс, который сначала переживается как напряжение.',
        );
        sb.writeln(
          '- Селена: ${selena != null ? '${selena.sign}, дом ${selena.house}' : 'данные о Селене пока не приходят от сервера'} - зона поддержки и внутренней этической опоры, где легче получать помощь и восстанавливать баланс.',
        );
        break;
      case 'Spa':
        sb.writeln(
          '- Ascendente: ${c.ascendantSign} ${c.ascendantDegrees.toStringAsFixed(1)}° - conducta externa, presencia corporal y forma de iniciar experiencias nuevas. Es el filtro de primera impresion en cualquier contexto.',
        );
        sb.writeln(
          '- Nodo Norte: ${nn != null ? '${nn.sign}, casa ${nn.house}' : 'sin datos'} - direccion de crecimiento y aprendizaje evolutivo; aqui conviene invertir energia consciente y sostenida.',
        );
        sb.writeln(
          '- Nodo Sur: ${sn != null ? '${sn.sign}, casa ${sn.house}' : 'sin datos'} - patrones conocidos del pasado y zona de comodidad; ofrece talento natural, pero tambien inercia.',
        );
        sb.writeln(
          '- Lilith: ${lilith != null ? '${lilith.sign}, casa ${lilith.house}' : 'sin datos'} - sombra, limites y poder no integrado; trabajar esta zona suele liberar mucha autonomia interna.',
        );
        sb.writeln(
          '- Selena: ${selena != null ? '${selena.sign}, casa ${selena.house}' : 'el backend no devuelve Selena por ahora'} - zona de soporte y armonia, donde es mas facil recuperar equilibrio y sentir proteccion.',
        );
        break;
      default:
        sb.writeln(
          '- Ascendant: ${c.ascendantSign} ${c.ascendantDegrees.toStringAsFixed(1)}° - outward behavior, body language, and default entry strategy in new situations. This is the first layer others perceive before deeper chart factors unfold.',
        );
        sb.writeln(
          '- North Node: ${nn != null ? '${nn.sign}, house ${nn.house}' : 'not available'} - developmental direction and the life territory where conscious effort produces long-term growth.',
        );
        sb.writeln(
          '- South Node: ${sn != null ? '${sn.sign}, house ${sn.house}' : 'not available'} - inherited comfort-patterns and familiar reflexes; strong native competence here can become stagnation if overused.',
        );
        sb.writeln(
          '- Lilith: ${lilith != null ? '${lilith.sign}, house ${lilith.house}' : 'not available'} - shadow dynamics, autonomy themes, and unintegrated intensity; naming this area usually unlocks hidden agency.',
        );
        sb.writeln(
          '- Selena: ${selena != null ? '${selena.sign}, house ${selena.house}' : 'not returned by backend yet'} - support and harmony zone, where recovery, trust, and ethical alignment come more naturally.',
        );
    }
    sb.writeln();

    sb.writeln(titleSet[5]);
    final houseCounts = <int, int>{};
    for (final p in planets) {
      houseCounts[p.house] = (houseCounts[p.house] ?? 0) + 1;
    }
    final dominantHouses = houseCounts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final topHouses = dominantHouses.take(3).map((e) => e.key).join(', ');
    final topAspect = majorAspects.isNotEmpty
        ? '${_pName(majorAspects.first.planet1, lang)} ${_aName(majorAspects.first.aspect, lang)} ${_pName(majorAspects.first.planet2, lang)}'
        : '';
    final topConfig = configurations.isNotEmpty ? configurations.first : '';
    final dominantElement = elementCounts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final elementName = dominantElement.isNotEmpty
        ? dominantElement.first.key
        : '';

    String localizedElement(String e) {
      switch (lang) {
        case 'Heb':
          return {
                'fire': 'אש',
                'earth': 'אדמה',
                'air': 'אוויר',
                'water': 'מים',
              }[e] ??
              e;
        case 'Rus':
          return {
                'fire': 'огонь',
                'earth': 'земля',
                'air': 'воздух',
                'water': 'вода',
              }[e] ??
              e;
        case 'Spa':
          return {
                'fire': 'fuego',
                'earth': 'tierra',
                'air': 'aire',
                'water': 'agua',
              }[e] ??
              e;
        default:
          return e;
      }
    }

    switch (lang) {
      case 'Heb':
        sb.writeln(
          '- דפוס אישיות ליבה: ריכוז בבתים $topHouses. זה רומז על מוקדי תשומת לב חזקים במיוחד ועל אזורים שבהם החיים חוזרים שוב ושוב כדי לחדד, ללמד ולהעמיק.',
        );
        sb.writeln(
          '- דינמיקה מרכזית: ${topAspect.isNotEmpty ? topAspect : 'ללא אספקט דומיננטי ברור'}${topConfig.isNotEmpty ? '; קונפיגורציה מובילה: $topConfig' : ''}. כאן רואים לא רק מה חזק, אלא גם איך הכוחות השונים במפה עובדים יחד, מתנגשים או משלימים זה את זה.',
        );
        sb.writeln(
          '- חתימת יסוד: ${elementName.isNotEmpty ? localizedElement(elementName) : 'לא זוהה יסוד דומיננטי'} — זה משפיע על סגנון תגובה: יוזמה, פרקטיות, חשיבה או רגש.',
        );
        sb.writeln(
          '- יישום מעשי: לאזן בין צרכים רגשיים, מערכות יחסים והחלטות מעשיות ביום-יום. בפועל, זה אומר להפוך את ההבנות מהמפה להתנהגות עקבית, לבחירות מדויקות ולסדר עדיפויות ברור, תוך בדיקה חודשית מה באמת עובד.',
        );
        sb.writeln(
          '- סיכונים עיקריים: פעולה אוטומטית מתוך דפוסים ישנים, פיזור תשומת לב בין יותר מדי מטרות, והזנחת התאוששות רגשית.',
        );
        sb.writeln(
          '- פיצוי מומלץ: לבחור 1-2 מוקדי עומק לרבעון, להגדיר גבולות אנרגטיים ברורים, ולעשות סקירה שבועית קצרה (מה קידם אותי ומה רוקן אותי).',
        );
        break;
      case 'Rus':
        sb.writeln(
          '- Базовый личностный узор: концентрация в домах $topHouses. Это главные сцены жизни, где вы принимаете ключевые решения и получаете наибольший объём опыта.',
        );
        sb.writeln(
          '- Главная динамика: ${topAspect.isNotEmpty ? topAspect : 'без явно доминирующего аспекта'}${topConfig.isNotEmpty ? '; ведущая конфигурация: $topConfig' : ''}. По сути это центральный внутренний двигатель карты: как формируется мотивация, где возникает напряжение и через что приходит разрядка.',
        );
        sb.writeln(
          '- Стихийный акцент: ${elementName.isNotEmpty ? localizedElement(elementName) : 'доминанта стихий не выражена'} — это задаёт базовый стиль реакции на стресс и на возможности.',
        );
        sb.writeln(
          '- Практическая интеграция: соединять эмоциональные потребности, отношения и повседневные решения в единую систему. Лучший результат даёт регулярная сверка: что из паттернов карты уже используется осознанно, а что пока проживается автоматически.',
        );
        sb.writeln(
          '- Ключевые риски: жить на автопилоте старых реакций, распыляться между несогласованными целями, игнорировать восстановление после перегрузки.',
        );
        sb.writeln(
          '- Компенсации: фиксировать 2 приоритета на период, внедрять границы по времени/энергии, и делать еженедельную ревизию поведения по фактам.',
        );
        break;
      case 'Spa':
        sb.writeln(
          '- Patron central de personalidad: concentracion en casas $topHouses. Estas son las areas donde se acumula mas aprendizaje y donde tus decisiones tienen mayor impacto.',
        );
        sb.writeln(
          '- Dinamica principal: ${topAspect.isNotEmpty ? topAspect : 'sin un aspecto dominante claro'}${topConfig.isNotEmpty ? '; configuracion lider: $topConfig' : ''}. Aqui se ve el motor interno de la carta: tension, compensacion y direccion de crecimiento.',
        );
        sb.writeln(
          '- Firma elemental: ${elementName.isNotEmpty ? localizedElement(elementName) : 'sin elemento dominante claro'} — marca el estilo base de respuesta frente a retos y oportunidades.',
        );
        sb.writeln(
          '- Aplicacion real: equilibrar necesidades emocionales, relaciones y decisiones practicas diarias, llevando la lectura de simbolos a habitos concretos y sostenibles.',
        );
        sb.writeln(
          '- Riesgos clave: actuar en automatico desde patrones viejos, dispersar energia en demasiados frentes y descuidar la recuperacion emocional.',
        );
        sb.writeln(
          '- Compensaciones: elegir 1-2 focos por ciclo, poner limites claros de energia/tiempo y revisar semanalmente que conductas realmente funcionan.',
        );
        break;
      default:
        sb.writeln(
          '- Core personality pattern: concentration in houses $topHouses. These life arenas become your primary developmental stage and decision pressure points.',
        );
        sb.writeln(
          '- Main dynamic: ${topAspect.isNotEmpty ? topAspect : 'no single dominant aspect'}${topConfig.isNotEmpty ? '; leading configuration: $topConfig' : ''}. This describes the engine of the chart: where tension builds, how it seeks resolution, and what growth path repeatedly opens.',
        );
        sb.writeln(
          '- Elemental signature: ${elementName.isNotEmpty ? localizedElement(elementName) : 'no clear dominant element'} — this shapes your default response style under pressure and opportunity.',
        );
        sb.writeln(
          '- Real-world application: balance emotional needs, relationships, and practical daily decisions by converting chart insight into repeatable habits, boundaries, and priorities.',
        );
        sb.writeln(
          '- Key risks: operating on old autopilot reactions, spreading attention across too many fronts, and neglecting emotional recovery cycles.',
        );
        sb.writeln(
          '- Compensation strategy: lock 1-2 strategic priorities per cycle, define clear energy boundaries, and run a weekly behavior audit based on outcomes.',
        );
    }

    return sb.toString().trim();
  }

  @override
  Widget build(BuildContext context) {
    final isRtl = language == 'Heb';
    final methodText = _buildMethodGeneralInfo(language);
    if (isLoading) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: _chartCardSurface.withOpacity(0.88),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: _chartCardBorder.withOpacity(0.75)),
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
    if ((interpretation == null || interpretation!.trim().isEmpty) &&
        methodText.trim().isEmpty) {
      final lang = _emptyTitle.containsKey(language) ? language : 'Eng';
      return _InfoCard(
        title: _emptyTitle[lang] ?? _emptyTitle['Eng']!,
        text: _emptyText[lang] ?? _emptyText['Eng']!,
      );
    }

    final methodHeader = {
      'Eng': 'Method-Based General Info',
      'Rus': 'Общая информация по методу',
      'Heb': 'מידע כללי לפי השיטה',
      'Spa': 'Informacion general por metodo',
    };
    final narrativeHeader = {
      'Eng': 'Narrative',
      'Rus': 'Нарратив',
      'Heb': 'נרטיב',
      'Spa': 'Narrativa',
    };
    final lang = methodHeader.containsKey(language) ? language : 'Eng';

    final combined = StringBuffer();
    if (interpretation != null && interpretation!.trim().isNotEmpty) {
      combined.writeln('${narrativeHeader[lang] ?? narrativeHeader['Eng']!}:');
      combined.writeln(interpretation!.trim());
      if (methodText.trim().isNotEmpty) {
        combined.writeln();
        combined.writeln('----------------------------------------');
        combined.writeln();
      }
    }
    if (methodText.trim().isNotEmpty) {
      combined.writeln('${methodHeader[lang] ?? methodHeader['Eng']!}:');
      combined.writeln(methodText.trim());
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: _chartCardSurface.withOpacity(0.88),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: _chartCardBorder.withOpacity(0.75)),
          ),
          child: Text(
            combined.toString().trim(),
            textDirection: isRtl ? TextDirection.rtl : TextDirection.ltr,
            textAlign: isRtl ? TextAlign.right : TextAlign.left,
            style: const TextStyle(
              color: _chartTextStrong,
              fontSize: 14,
              height: 1.75,
              fontWeight: FontWeight.w600,
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

  const _PlanetsTab({
    this.planets,
    this.interpretations = const {},
    this.language = 'Eng',
  });

  static const Map<String, String> _glyphs = {
    'Sun': '\u2600\ufe0f',
    'Moon': '\ud83c\udf19',
    'Mercury': '\u263f',
    'Venus': '\u2640',
    'Mars': '\u2642',
    'Jupiter': '\u2643',
    'Saturn': '\u2644',
    'Uranus': '\u2645',
    'Neptune': '\u2646',
    'Pluto': '\u2647',
    'North Node': '\u260a',
    'South Node': '\u260b',
    'Lilith': '\u26b8',
  };

  static const _names = {
    'Eng': {
      'Sun': 'Sun',
      'Moon': 'Moon',
      'Mercury': 'Mercury',
      'Venus': 'Venus',
      'Mars': 'Mars',
      'Jupiter': 'Jupiter',
      'Saturn': 'Saturn',
      'Uranus': 'Uranus',
      'Neptune': 'Neptune',
      'Pluto': 'Pluto',
      'North Node': 'North Node',
      'South Node': 'South Node',
      'Lilith': 'Lilith',
    },
    'Rus': {
      'Sun': 'Солнце',
      'Moon': 'Луна',
      'Mercury': 'Меркурий',
      'Venus': 'Венера',
      'Mars': 'Марс',
      'Jupiter': 'Юпитер',
      'Saturn': 'Сатурн',
      'Uranus': 'Уран',
      'Neptune': 'Нептун',
      'Pluto': 'Плутон',
      'North Node': 'Северный узел',
      'South Node': 'Южный узел',
      'Lilith': 'Лилит',
    },
    'Heb': {
      'Sun': 'שמש',
      'Moon': 'ירח',
      'Mercury': 'כוכב חמה',
      'Venus': 'נוגה',
      'Mars': 'מאדים',
      'Jupiter': 'צדק',
      'Saturn': 'שבתאי',
      'Uranus': 'אורנוס',
      'Neptune': 'נפטון',
      'Pluto': 'פלוטו',
      'North Node': 'הצומת הצפוני',
      'South Node': 'הצומת הדרומי',
      'Lilith': 'לילית',
    },
    'Spa': {
      'Sun': 'Sol',
      'Moon': 'Luna',
      'Mercury': 'Mercurio',
      'Venus': 'Venus',
      'Mars': 'Marte',
      'Jupiter': 'Júpiter',
      'Saturn': 'Saturno',
      'Uranus': 'Urano',
      'Neptune': 'Neptuno',
      'Pluto': 'Plutón',
      'North Node': 'Nodo Norte',
      'South Node': 'Nodo Sur',
      'Lilith': 'Lilith',
    },
  };

  static const _signs = {
    'Eng': {
      'Aries': 'Aries',
      'Taurus': 'Taurus',
      'Gemini': 'Gemini',
      'Cancer': 'Cancer',
      'Leo': 'Leo',
      'Virgo': 'Virgo',
      'Libra': 'Libra',
      'Scorpio': 'Scorpio',
      'Sagittarius': 'Sagittarius',
      'Capricorn': 'Capricorn',
      'Aquarius': 'Aquarius',
      'Pisces': 'Pisces',
    },
    'Rus': {
      'Aries': 'Овен',
      'Taurus': 'Телец',
      'Gemini': 'Близнецы',
      'Cancer': 'Рак',
      'Leo': 'Лев',
      'Virgo': 'Дева',
      'Libra': 'Весы',
      'Scorpio': 'Скорпион',
      'Sagittarius': 'Стрелец',
      'Capricorn': 'Козерог',
      'Aquarius': 'Водолей',
      'Pisces': 'Рыбы',
    },
    'Heb': {
      'Aries': 'טלה',
      'Taurus': 'שור',
      'Gemini': 'תאומים',
      'Cancer': 'סרטן',
      'Leo': 'אריה',
      'Virgo': 'בתולה',
      'Libra': 'מאזניים',
      'Scorpio': 'עקרב',
      'Sagittarius': 'קשת',
      'Capricorn': 'גדי',
      'Aquarius': 'דלי',
      'Pisces': 'דגים',
    },
    'Spa': {
      'Aries': 'Aries',
      'Taurus': 'Tauro',
      'Gemini': 'Géminis',
      'Cancer': 'Cáncer',
      'Leo': 'Leo',
      'Virgo': 'Virgo',
      'Libra': 'Libra',
      'Scorpio': 'Escorpio',
      'Sagittarius': 'Sagitario',
      'Capricorn': 'Capricornio',
      'Aquarius': 'Acuario',
      'Pisces': 'Piscis',
    },
  };

  static const _houseLabel = {
    'Eng': 'House',
    'Rus': 'Дом',
    'Heb': 'בית',
    'Spa': 'Casa',
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
        1: 'self-expression',
        2: 'security and resources',
        3: 'learning and communication',
        4: 'home and roots',
        5: 'creativity and romance',
        6: 'work and daily routines',
        7: 'partnerships',
        8: 'shared emotions and trust',
        9: 'belief and exploration',
        10: 'career and public life',
        11: 'friends and future goals',
        12: 'inner life and healing',
      },
      'Rus': {
        1: 'самовыражения',
        2: 'безопасности и ресурсов',
        3: 'обучения и общения',
        4: 'дома и корней',
        5: 'творчества и романтики',
        6: 'работы и повседневных дел',
        7: 'партнерства',
        8: 'доверия и глубинных процессов',
        9: 'убеждений и расширения горизонтов',
        10: 'карьеры и статуса',
        11: 'друзей и будущих целей',
        12: 'внутреннего мира и исцеления',
      },
      'Heb': {
        1: 'ביטוי עצמי',
        2: 'בטחון ומשאבים',
        3: 'למידה ותקשורת',
        4: 'בית ושורשים',
        5: 'יצירה ורומנטיקה',
        6: 'עבודה ושגרה',
        7: 'שותפויות',
        8: 'אמון ועומק רגשי',
        9: 'אמונה והתרחבות',
        10: 'קריירה ותדמית ציבורית',
        11: 'חברים ומטרות עתידיות',
        12: 'עולם פנימי וריפוי',
      },
      'Spa': {
        1: 'expresion personal',
        2: 'seguridad y recursos',
        3: 'aprendizaje y comunicacion',
        4: 'hogar y raices',
        5: 'creatividad y romance',
        6: 'trabajo y rutina diaria',
        7: 'parejas y alianzas',
        8: 'confianza y profundidad emocional',
        9: 'creencias y expansion',
        10: 'carrera y vida publica',
        11: 'amistades y metas futuras',
        12: 'vida interior y sanacion',
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
          final house = lang == 'Rus'
              ? '$houseWord ${p.house}'
              : '$houseWord ${p.house}';
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
    'Eng': {
      'Conjunction': 'Conjunction',
      'Sextile': 'Sextile',
      'Square': 'Square',
      'Trine': 'Trine',
      'Quincunx': 'Quincunx',
      'Opposition': 'Opposition',
    },
    'Rus': {
      'Conjunction': 'Соединение',
      'Sextile': 'Секстиль',
      'Square': 'Квадрат',
      'Trine': 'Трин',
      'Quincunx': 'Квинкункс',
      'Opposition': 'Оппозиция',
    },
    'Heb': {
      'Conjunction': 'קונג׳אנקשן',
      'Sextile': 'סקסטיל',
      'Square': 'ריבוע',
      'Trine': 'טרין',
      'Quincunx': 'קווינקונקס',
      'Opposition': 'אופוזיציה',
    },
    'Spa': {
      'Conjunction': 'Conjunción',
      'Sextile': 'Sextil',
      'Square': 'Cuadratura',
      'Trine': 'Trígono',
      'Quincunx': 'Quincuncio',
      'Opposition': 'Oposición',
    },
  };

  static const _aspectKeywords = {
    'Eng': {
      'Conjunction': 'Merging energies',
      'Sextile': 'Opportunity & flow',
      'Square': 'Tension & growth',
      'Trine': 'Harmony & ease',
      'Quincunx': 'Adjustment needed',
      'Opposition': 'Balance & polarity',
    },
    'Rus': {
      'Conjunction': 'Слияние энергий',
      'Sextile': 'Возможности и поток',
      'Square': 'Напряжение и рост',
      'Trine': 'Гармония и лёгкость',
      'Quincunx': 'Требуется коррекция',
      'Opposition': 'Баланс и полярность',
    },
    'Heb': {
      'Conjunction': 'מיזוג אנרגיות',
      'Sextile': 'הזדמנות וזרימה',
      'Square': 'מתח וצמיחה',
      'Trine': 'הרמוניה וקלות',
      'Quincunx': 'נדרשת התאמה',
      'Opposition': 'איזון וקוטביות',
    },
    'Spa': {
      'Conjunction': 'Fusión de energías',
      'Sextile': 'Oportunidad y flujo',
      'Square': 'Tensión y crecimiento',
      'Trine': 'Armonía y facilidad',
      'Quincunx': 'Ajuste necesario',
      'Opposition': 'Balance y polaridad',
    },
  };

  static const _planetNames = {
    'Eng': {
      'Sun': 'Sun',
      'Moon': 'Moon',
      'Mercury': 'Mercury',
      'Venus': 'Venus',
      'Mars': 'Mars',
      'Jupiter': 'Jupiter',
      'Saturn': 'Saturn',
      'Uranus': 'Uranus',
      'Neptune': 'Neptune',
      'Pluto': 'Pluto',
      'Ascendant': 'Ascendant',
      'North Node': 'North Node',
      'South Node': 'South Node',
      'Lilith': 'Lilith',
    },
    'Rus': {
      'Sun': 'Солнце',
      'Moon': 'Луна',
      'Mercury': 'Меркурий',
      'Venus': 'Венера',
      'Mars': 'Марс',
      'Jupiter': 'Юпитер',
      'Saturn': 'Сатурн',
      'Uranus': 'Уран',
      'Neptune': 'Нептун',
      'Pluto': 'Плутон',
      'Ascendant': 'Асцендент',
      'North Node': 'Северный узел',
      'South Node': 'Южный узел',
      'Lilith': 'Лилит',
    },
    'Heb': {
      'Sun': 'שמש',
      'Moon': 'ירח',
      'Mercury': 'כוכב חמה',
      'Venus': 'נוגה',
      'Mars': 'מאדים',
      'Jupiter': 'צדק',
      'Saturn': 'שבתאי',
      'Uranus': 'אורנוס',
      'Neptune': 'נפטון',
      'Pluto': 'פלוטו',
      'Ascendant': 'אסצנדנט',
      'North Node': 'הצומת הצפוני',
      'South Node': 'הצומת הדרומי',
      'Lilith': 'לילית',
    },
    'Spa': {
      'Sun': 'Sol',
      'Moon': 'Luna',
      'Mercury': 'Mercurio',
      'Venus': 'Venus',
      'Mars': 'Marte',
      'Jupiter': 'Júpiter',
      'Saturn': 'Saturno',
      'Uranus': 'Urano',
      'Neptune': 'Neptuno',
      'Pluto': 'Plutón',
      'Ascendant': 'Ascendente',
      'North Node': 'Nodo Norte',
      'South Node': 'Nodo Sur',
      'Lilith': 'Lilith',
    },
  };

  List<_AspectEntry> _fromBackend(List<AspectInfo> src) {
    const symMap = {
      'Conjunction': '☌',
      'Sextile': '⚹',
      'Square': '□',
      'Trine': '△',
      'Quincunx': '⚻',
      'Opposition': '☍',
    };
    const colorMap = {
      'Conjunction': Color(0xFF9B7FD4),
      'Sextile': Color(0xFF5BAD8A),
      'Square': Color(0xFFD45C5C),
      'Trine': Color(0xFF5B9BD4),
      'Quincunx': Color(0xFFD4A85C),
      'Opposition': Color(0xFFD47A5C),
    };
    final lang = _aspectKeywords.containsKey(language) ? language : 'Eng';
    return src
        .map(
          (a) => _AspectEntry(
            p1: a.planet1,
            p2: a.planet2,
            name: a.aspect,
            sym: symMap[a.aspect] ?? '·',
            color: colorMap[a.aspect] ?? const Color(0xFF9B7FD4),
            keyword: _aspectKeywords[lang]?[a.aspect] ?? '',
            orb: a.orb,
          ),
        )
        .toList();
  }

  List<_AspectEntry> _compute(List<PlanetPosition> ps) {
    const names = [
      'Conjunction',
      'Sextile',
      'Square',
      'Trine',
      'Quincunx',
      'Opposition',
    ];
    const syms = ['☌', '⚹', '□', '△', '⚻', '☍'];
    const angles = [0.0, 60.0, 90.0, 120.0, 150.0, 180.0];
    const maxOrbs = [8.0, 6.0, 8.0, 8.0, 3.0, 8.0];
    const colors = [
      Color(0xFF9B7FD4),
      Color(0xFF5BAD8A),
      Color(0xFFD45C5C),
      Color(0xFF5B9BD4),
      Color(0xFFD4A85C),
      Color(0xFFD47A5C),
    ];
    final lang = _aspectKeywords.containsKey(language) ? language : 'Eng';

    final results = <_AspectEntry>[];
    for (int i = 0; i < ps.length; i++) {
      for (int j = i + 1; j < ps.length; j++) {
        final diff = (ps[i].longitude - ps[j].longitude).abs();
        final angle = diff > 180 ? 360 - diff : diff;
        for (int k = 0; k < names.length; k++) {
          final actualOrb = (angle - angles[k]).abs();
          if (actualOrb <= maxOrbs[k]) {
            results.add(
              _AspectEntry(
                p1: ps[i].name,
                p2: ps[j].name,
                name: names[k],
                sym: syms[k],
                orb: actualOrb,
                color: colors[k],
                keyword: _aspectKeywords[lang]?[names[k]] ?? '',
              ),
            );
            break;
          }
        }
      }
    }
    results.sort((a, b) => a.orb.compareTo(b.orb));
    return results;
  }

  String _fallbackAspectDescription(
    _AspectEntry aspect,
    String p1Name,
    String p2Name,
    String aspectName,
  ) {
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
              color: _chartCardSurface.withOpacity(0.88),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: _chartCardBorder.withOpacity(0.75)),
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
                color: _chartCardSurface.withOpacity(0.86),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: _chartCardBorder.withOpacity(0.72)),
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
                          child: Text(
                            a.sym,
                            style: TextStyle(fontSize: 16, color: a.color),
                          ),
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
                                color: _chartTextStrong,
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              '$aspectName · ${a.keyword} · ${a.orb.toStringAsFixed(1)}°',
                              style: const TextStyle(
                                color: _chartTextBody,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  if (desc.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Text(
                      desc,
                      style: const TextStyle(
                        color: _chartTextBody,
                        fontSize: 12.5,
                        height: 1.65,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
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
  const _ConfigurationsTab({
    this.patterns = const [],
    this.patternInterpretations = const {},
    this.language = 'Eng',
  });

  static const _emptyTitle = {
    'Eng': 'No configurations',
    'Rus': 'Нет конфигураций',
    'Heb': 'אין קונפיגורציות',
    'Spa': 'Sin configuraciones',
  };
  static const _emptyText = {
    'Eng':
        'No major configurations (T-Square, Grand Trine, Yod, etc.) detected.',
    'Rus':
        'Крупных конфигураций (Т-квадрат, Большой трин, Иод и др.) не обнаружено.',
    'Heb': 'לא נמצאו קונפיגורציות עיקריות (T-Square, Grand Trine, Yod וכד׳).',
    'Spa':
        'No se detectaron configuraciones principales (T-Cuadrado, Gran Trígono, Yod, etc.).',
  };

  static const _patternIcons = {
    'T-Square': '⚔️',
    'Grand Cross': '✚',
    'Grand Trine': '△',
    'Kite': '🪁',
    'Yod': '👆',
    'Bisextile': '⚹',
    'Stellium': '✨',
  };

  String _iconFor(String pattern) {
    for (final key in _patternIcons.keys) {
      if (pattern.startsWith(key)) return _patternIcons[key]!;
    }
    return '⭐';
  }

  String _fallbackPatternDescription(String pattern) {
    if (language == 'Heb') {
      if (pattern.startsWith('Stellium'))
        return 'סטליום מדגיש ריכוז חזק של אנרגיה באותו אזור, ולכן הנושא הזה נעשה מרכזי מאוד בחיים.';
      if (pattern.startsWith('T-Square'))
        return 'טי-סקוור יוצר מתח יצירתי שמבקש פעולה, בגרות ויכולת לאזן בין כוחות מנוגדים.';
      if (pattern.startsWith('Grand Trine'))
        return 'גרנד טריין מצביע על זרימה טבעית וכישרון מולד, אך חשוב גם להפעיל אותו באופן מודע.';
      if (pattern.startsWith('Yod'))
        return 'יוד מצביע על מסלול עדין ומדויק של התאמות פנימיות, עם תחושת כיוון גורלית.';
      if (pattern.startsWith('Kite'))
        return 'קונפיגורציית עפיפון משלבת כישרון טבעי עם כיוון ברור לפעולה ולהגשמה.';
      return 'הקונפיגורציה הזו מדגישה דפוס חוזר במפה ומראה איך כמה כוחות פועלים יחד באותו נושא.';
    }
    if (language == 'Rus') {
      if (pattern.startsWith('Stellium'))
        return 'Стеллиум показывает сильную концентрацию энергии в одной теме жизни, поэтому она становится доминирующей.';
      if (pattern.startsWith('T-Square'))
        return 'Т-квадрат создает напряжение, которое подталкивает к росту, действию и внутреннему балансу.';
      if (pattern.startsWith('Grand Trine'))
        return 'Большой трин указывает на естественный поток и врожденный талант, который важно осознанно развивать.';
      if (pattern.startsWith('Yod'))
        return 'Йод говорит о тонкой настройке и судьбоносном направлении, которое раскрывается через корректировки.';
      if (pattern.startsWith('Kite'))
        return 'Кайт соединяет природные дары с явным вектором реализации и движения вперед.';
      return 'Эта конфигурация показывает повторяющийся узор карты и важное взаимодействие нескольких сил.';
    }
    if (language == 'Spa') {
      if (pattern.startsWith('Stellium'))
        return 'Un stellium concentra mucha energia en una misma zona de vida, por eso ese tema se vuelve dominante.';
      if (pattern.startsWith('T-Square'))
        return 'La T-cuadrada crea tension creativa que empuja al crecimiento, la accion y el equilibrio.';
      if (pattern.startsWith('Grand Trine'))
        return 'El gran trigono muestra fluidez natural y talento innato, aunque conviene usarlo conscientemente.';
      if (pattern.startsWith('Yod'))
        return 'El yod apunta a un camino de ajustes finos y a una direccion que se siente significativa.';
      if (pattern.startsWith('Kite'))
        return 'La configuracion cometa combina talento natural con una direccion clara para avanzar.';
      return 'Esta configuracion muestra un patron importante en la carta y como varias fuerzas trabajan juntas.';
    }
    if (pattern.startsWith('Stellium'))
      return 'A stellium concentrates a lot of energy in one area of life, making that theme especially dominant.';
    if (pattern.startsWith('T-Square'))
      return 'A T-square creates productive tension that pushes growth, action, and balance.';
    if (pattern.startsWith('Grand Trine'))
      return 'A grand trine points to natural flow and talent, though it works best when used consciously.';
    if (pattern.startsWith('Yod'))
      return 'A yod suggests a subtle path of adjustment and a direction that feels highly meaningful.';
    if (pattern.startsWith('Kite'))
      return 'A kite combines natural gifts with a clear vector for expression and forward movement.';
    return 'This configuration highlights a recurring chart pattern and shows how several forces work together.';
  }

  static const Set<String> _majorPatternPrefixes = {
    'Stellium',
    'T-Square',
    'Grand Cross',
    'Grand Trine',
    'Kite',
    'Yod',
  };

  static List<String> mergePatterns({
    required List<String> backendPatterns,
    required List<String> localPatterns,
  }) {
    final results = <String>[];
    final seen = <String>{};

    void addAll(Iterable<String> items) {
      for (final item in items) {
        if (seen.add(item)) results.add(item);
      }
    }

    bool isMajorPattern(String pattern) {
      for (final prefix in _majorPatternPrefixes) {
        if (pattern.startsWith(prefix)) return true;
      }
      return false;
    }

    // Trust local geometry for major configurations to avoid false positives
    // from loose backend orbs, then preserve backend-only minor patterns.
    addAll(localPatterns);
    addAll(backendPatterns.where((pattern) => !isMajorPattern(pattern)));
    return results;
  }

  // ─── Client-side fallback pattern detection ───────────────────────────────
  // Uses stricter geometry than the backend for major configurations so the
  // UI avoids false positives like very loose T-squares.
  static List<String> computeFromPlanets(List<PlanetPosition> ps) {
    if (ps.length < 3) return const [];

    // Exclude angles and auxiliary points from major pattern detection.
    const excludedNames = {'Ascendant', 'North Node', 'South Node', 'Lilith'};
    final planets = ps.where((p) => !excludedNames.contains(p.name)).toList();

    bool near(double angle, double target, double orb) =>
        isNearAspect(angle, target, orb);

    final results = <String>[];
    final seen = <String>{};
    void add(String s) {
      if (seen.add(s)) results.add(s);
    }

    // ── Stellium: 3+ planets in the same sign ───────────────────────────────
    final bySign = <String, List<String>>{};
    for (final p in planets) {
      bySign.putIfAbsent(p.sign, () => []).add(p.name);
    }
    bySign.forEach((sign, names) {
      if (names.length >= 3) add('Stellium in $sign: ${names.join(', ')}');
    });

    // ── Pairwise aspect lookups ─────────────────────────────────────────────
    const opp = 180.0, sqr = 90.0, tri = 120.0, sxt = 60.0, qcx = 150.0;
    const oppOrb = 4.0, sqrOrb = 4.0, triOrb = 4.0, sxtOrb = 4.0, qcxOrb = 3.0;

    bool isOpposition(int i, int j) => near(
      angularDistance(planets[i].longitude, planets[j].longitude),
      opp,
      oppOrb,
    );
    bool isSquare(int i, int j) => near(
      angularDistance(planets[i].longitude, planets[j].longitude),
      sqr,
      sqrOrb,
    );
    bool isTrine(int i, int j) => near(
      angularDistance(planets[i].longitude, planets[j].longitude),
      tri,
      triOrb,
    );
    bool isSextile(int i, int j) => near(
      angularDistance(planets[i].longitude, planets[j].longitude),
      sxt,
      sxtOrb,
    );
    bool isQuincunx(int i, int j) => near(
      angularDistance(planets[i].longitude, planets[j].longitude),
      qcx,
      qcxOrb,
    );

    final n = planets.length;

    // ── T-Square: opposition + apex squaring both ───────────────────────────
    for (int i = 0; i < n; i++) {
      for (int j = i + 1; j < n; j++) {
        if (!isOpposition(i, j)) continue;
        for (int k = 0; k < n; k++) {
          if (k == i || k == j) continue;
          if (isSquare(k, i) && isSquare(k, j)) {
            add(
              'T-Square: ${planets[i].name} ☍ ${planets[j].name} → apex ${planets[k].name}',
            );
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
            if (isSquare(i, k) &&
                isSquare(i, l) &&
                isSquare(j, k) &&
                isSquare(j, l)) {
              add(
                'Grand Cross: ${planets[i].name}, ${planets[k].name}, ${planets[j].name}, ${planets[l].name}',
              );
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
            add(
              'Grand Trine: ${planets[i].name} △ ${planets[j].name} △ ${planets[k].name}',
            );
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
            add(
              'Yod: ${planets[i].name} ⚹ ${planets[j].name} → apex ${planets[k].name}',
            );
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
                add(
                  'Kite: ${planets[i].name}, ${planets[j].name}, ${planets[k].name} + tail ${planets[l].name}',
                );
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
        text: _emptyText[language] ?? _emptyText['Eng']!,
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
                  color: _chartCardSurface.withOpacity(0.86),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: _chartCardBorder.withOpacity(0.72)),
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
                              color: _chartTextStrong,
                              fontSize: 13.5,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                    if (desc.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Text(
                        desc,
                        style: const TextStyle(
                          color: _chartTextBody,
                          fontSize: 12.5,
                          height: 1.65,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
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
    'Eng': "Today's Transits",
    'Rus': 'Транзиты сегодня',
    'Heb': 'מעברים היום',
    'Spa': 'Tránsitos de hoy',
  };
  static const _noneTitle = {
    'Eng': 'No active transits',
    'Rus': 'Нет активных транзитов',
    'Heb': 'אין מעברים פעילים',
    'Spa': 'Sin tránsitos activos',
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
    'Eng':
        'Transit data could not be loaded. The natal chart is still available.',
    'Rus':
        'Не удалось загрузить транзиты. Натальная карта по-прежнему доступна.',
    'Heb': 'לא ניתן היה לטעון את נתוני המעברים. מפת הלידה עדיין זמינה.',
    'Spa':
        'No se pudieron cargar los transitos. La carta natal sigue disponible.',
  };
  static const _natalLabel = {
    'Eng': 'natal',
    'Rus': 'натальный',
    'Heb': 'נטלי',
    'Spa': 'natal',
  };
  static const _houseLabel = {
    'Eng': 'house',
    'Rus': 'дом',
    'Heb': 'בית',
    'Spa': 'casa',
  };
  static const _planetNames = {
    'Eng': {
      'Sun': 'Sun',
      'Moon': 'Moon',
      'Mercury': 'Mercury',
      'Venus': 'Venus',
      'Mars': 'Mars',
      'Jupiter': 'Jupiter',
      'Saturn': 'Saturn',
      'Uranus': 'Uranus',
      'Neptune': 'Neptune',
      'Pluto': 'Pluto',
      'Ascendant': 'Ascendant',
      'North Node': 'North Node',
      'South Node': 'South Node',
      'Lilith': 'Lilith',
    },
    'Rus': {
      'Sun': 'Солнце',
      'Moon': 'Луна',
      'Mercury': 'Меркурий',
      'Venus': 'Венера',
      'Mars': 'Марс',
      'Jupiter': 'Юпитер',
      'Saturn': 'Сатурн',
      'Uranus': 'Уран',
      'Neptune': 'Нептун',
      'Pluto': 'Плутон',
      'Ascendant': 'Асцендент',
      'North Node': 'Северный узел',
      'South Node': 'Южный узел',
      'Lilith': 'Лилит',
    },
    'Heb': {
      'Sun': 'שמש',
      'Moon': 'ירח',
      'Mercury': 'כוכב חמה',
      'Venus': 'נוגה',
      'Mars': 'מאדים',
      'Jupiter': 'צדק',
      'Saturn': 'שבתאי',
      'Uranus': 'אורנוס',
      'Neptune': 'נפטון',
      'Pluto': 'פלוטו',
      'Ascendant': 'אסצנדנט',
      'North Node': 'הצומת הצפוני',
      'South Node': 'הצומת הדרומי',
      'Lilith': 'לילית',
    },
    'Spa': {
      'Sun': 'Sol',
      'Moon': 'Luna',
      'Mercury': 'Mercurio',
      'Venus': 'Venus',
      'Mars': 'Marte',
      'Jupiter': 'Júpiter',
      'Saturn': 'Saturno',
      'Uranus': 'Urano',
      'Neptune': 'Neptuno',
      'Pluto': 'Plutón',
      'Ascendant': 'Ascendente',
      'North Node': 'Nodo Norte',
      'South Node': 'Nodo Sur',
      'Lilith': 'Lilith',
    },
  };
  static const _aspectNames = {
    'Eng': {
      'Conjunction': 'Conjunction',
      'Sextile': 'Sextile',
      'Square': 'Square',
      'Trine': 'Trine',
      'Quincunx': 'Quincunx',
      'Opposition': 'Opposition',
    },
    'Rus': {
      'Conjunction': 'Соединение',
      'Sextile': 'Секстиль',
      'Square': 'Квадрат',
      'Trine': 'Трин',
      'Quincunx': 'Квинкункс',
      'Opposition': 'Оппозиция',
    },
    'Heb': {
      'Conjunction': 'קונג׳אנקשן',
      'Sextile': 'סקסטיל',
      'Square': 'ריבוע',
      'Trine': 'טרין',
      'Quincunx': 'קווינקונקס',
      'Opposition': 'אופוזיציה',
    },
    'Spa': {
      'Conjunction': 'Conjunción',
      'Sextile': 'Sextil',
      'Square': 'Cuadratura',
      'Trine': 'Trígono',
      'Quincunx': 'Quincuncio',
      'Opposition': 'Oposición',
    },
  };

  String _fallbackInterpretation(List<TransitItem> items, String lang) {
    if (items.isEmpty) return '';

    final topItems = items.take(3).toList();
    final highlights = topItems
        .map((item) {
          final transitPlanet =
              _planetNames[lang]?[item.transitPlanet] ?? item.transitPlanet;
          final natalPlanet =
              _planetNames[lang]?[item.natalPlanet] ?? item.natalPlanet;
          final aspect = _aspectNames[lang]?[item.aspect] ?? item.aspect;
          switch (lang) {
            case 'Heb':
              return '$transitPlanet ב-${_houseLabel[lang] ?? 'בית'} ${item.transitHouse} יוצר $aspect עם $natalPlanet';
            case 'Rus':
              return '$transitPlanet в ${_houseLabel[lang] ?? 'дом'} ${item.transitHouse} формирует $aspect к $natalPlanet';
            case 'Spa':
              return '$transitPlanet en ${_houseLabel[lang] ?? 'casa'} ${item.transitHouse} crea $aspect con $natalPlanet';
            default:
              return '$transitPlanet in ${_houseLabel[lang] ?? 'house'} ${item.transitHouse} forms a $aspect with $natalPlanet';
          }
        })
        .join(lang == 'Heb' ? ' • ' : '; ');

    switch (lang) {
      case 'Heb':
        return 'המעברים הפעילים מדגישים כרגע נושאים של קשרים, תגובות רגשיות ותזמון מעשי. מוקדי היום: $highlights.';
      case 'Rus':
        return 'Текущие транзиты подчёркивают темы отношений, эмоциональных реакций и практических решений. Главные акценты дня: $highlights.';
      case 'Spa':
        return 'Los transitos activos resaltan temas de relaciones, respuestas emocionales y decisiones practicas. Enfoques del dia: $highlights.';
      default:
        return 'The active transits currently emphasize relationships, emotional responses, and practical timing. Today\'s main highlights: $highlights.';
    }
  }

  static const _symMap = {
    'Conjunction': '☌',
    'Sextile': '⚹',
    'Square': '□',
    'Trine': '△',
    'Quincunx': '⚻',
    'Opposition': '☍',
  };
  static const _colorMap = {
    'Conjunction': Color(0xFF9B7FD4),
    'Sextile': Color(0xFF5BAD8A),
    'Square': Color(0xFFD45C5C),
    'Trine': Color(0xFF5B9BD4),
    'Quincunx': Color(0xFFD4A85C),
    'Opposition': Color(0xFFD47A5C),
  };

  static const _houseMeanings = {
    'Eng': {
      1: 'identity and personal initiative',
      2: 'money, values, and self-worth',
      3: 'communication and daily movement',
      4: 'home, roots, and emotional foundations',
      5: 'creativity, romance, and self-expression',
      6: 'work, routines, and wellbeing',
      7: 'relationships and cooperation',
      8: 'shared resources, trust, and transformation',
      9: 'travel, beliefs, and expansion',
      10: 'career, reputation, and public direction',
      11: 'community, friendships, and future goals',
      12: 'inner life, healing, and release',
    },
    'Rus': {
      1: 'личная идентичность и инициатива',
      2: 'деньги, ценности и самооценка',
      3: 'общение и повседневные контакты',
      4: 'дом, корни и эмоциональная опора',
      5: 'творчество, романтика и самовыражение',
      6: 'работа, режим и здоровье',
      7: 'отношения и сотрудничество',
      8: 'общие ресурсы, доверие и трансформация',
      9: 'путешествия, вера и расширение',
      10: 'карьера, репутация и публичное направление',
      11: 'сообщество, друзья и цели будущего',
      12: 'внутренний мир, исцеление и отпускание',
    },
    'Heb': {
      1: 'זהות אישית ויוזמה',
      2: 'כסף, ערכים ושווי עצמי',
      3: 'תקשורת ותנועה יומיומית',
      4: 'בית, שורשים ובסיס רגשי',
      5: 'יצירה, רומנטיקה וביטוי עצמי',
      6: 'עבודה, שגרה ורווחה',
      7: 'יחסים ושיתוף פעולה',
      8: 'משאבים משותפים, אמון וטרנספורמציה',
      9: 'מסע, אמונות והרחבת אופקים',
      10: 'קריירה, מוניטין וכיוון ציבורי',
      11: 'קהילה, חברויות ומטרות עתידיות',
      12: 'עולם פנימי, ריפוי ושחרור',
    },
    'Spa': {
      1: 'identidad e iniciativa personal',
      2: 'dinero, valores y autoestima',
      3: 'comunicacion y movimiento diario',
      4: 'hogar, raices y base emocional',
      5: 'creatividad, romance y expresion personal',
      6: 'trabajo, rutinas y bienestar',
      7: 'relaciones y cooperacion',
      8: 'recursos compartidos, confianza y transformacion',
      9: 'viajes, creencias y expansion',
      10: 'carrera, reputacion y direccion publica',
      11: 'comunidad, amistades y metas futuras',
      12: 'vida interior, sanacion y liberacion',
    },
  };

  static const _planetTransitThemes = {
    'Eng': {
      'Sun': {
        1: 'identity, visibility, and personal direction',
        2: 'self-worth, income, and stable resources',
        3: 'communication, study, and daily contacts',
        4: 'home, family, and private life',
        5: 'creativity, joy, and romance',
        6: 'work, health, and daily rhythm',
        7: 'relationships, cooperation, and agreements',
        8: 'shared resources, intimacy, and transformation',
        9: 'growth, travel, and beliefs',
        10: 'career visibility, leadership, and reputation',
        11: 'friends, community, and future goals',
        12: 'rest, healing, and inner renewal',
      },
      'Moon': {
        1: 'emotional focus, instincts, and self-care',
        2: 'security, comfort, and finances',
        3: 'talks, errands, and emotional expression',
        4: 'family needs and emotional grounding',
        5: 'romance, play, and personal enjoyment',
        6: 'habits, service, and health routines',
        7: 'partnership needs and relationship feelings',
        8: 'intimacy, vulnerability, and shared resources',
        9: 'learning, travel, and emotional perspective',
        10: 'public mood, career direction, and recognition',
        11: 'social circles, belonging, and hopes',
        12: 'reflection, healing, and emotional release',
      },
      'Mercury': {
        1: 'self-expression, ideas, and quick decisions',
        2: 'money thinking, planning, and values',
        3: 'communication, learning, and movement',
        4: 'family conversations and private planning',
        5: 'creative ideas, dating, and fun',
        6: 'work tasks, analysis, and routines',
        7: 'dialogue, negotiation, and agreements',
        8: 'research, deep talks, and shared matters',
        9: 'study, publishing, and broad ideas',
        10: 'career messaging, strategy, and visibility',
        11: 'networks, friends, and future plans',
        12: 'inner processing, rest, and reflection',
      },
      'Venus': {
        1: 'attraction, confidence, and personal style',
        2: 'money, comfort, and self-value',
        3: 'friendly talks, learning, and social ease',
        4: 'home harmony, family warmth, and comfort',
        5: 'romance, pleasure, and creativity',
        6: 'work relationships, ease, and wellbeing',
        7: 'love, agreements, and relationship balance',
        8: 'intimacy, trust, and shared resources',
        9: 'love of learning, travel, and inspiration',
        10: 'public appeal, career grace, and reputation',
        11: 'friendships, support, and social gains',
        12: 'private healing, compassion, and quiet love',
      },
      'Mars': {
        1: 'drive, courage, and personal action',
        2: 'earning drive, spending, and self-protection',
        3: 'bold speech, movement, and quick decisions',
        4: 'home action, family tensions, and repairs',
        5: 'passion, competition, and creative push',
        6: 'work effort, discipline, and physical stamina',
        7: 'assertion in partnerships and conflict handling',
        8: 'intense change, desire, and power dynamics',
        9: 'adventure, challenge, and strong beliefs',
        10: 'ambition, leadership, and career drive',
        11: 'group goals, activism, and social momentum',
        12: 'behind-the-scenes effort, restlessness, and release',
      },
      'Jupiter': {
        1: 'confidence, growth, and optimism',
        2: 'financial growth, abundance, and generosity',
        3: 'learning, teaching, and broad perspective',
        4: 'family growth, comfort, and inner support',
        5: 'joy, creativity, and lucky self-expression',
        6: 'work opportunity, health improvement, and service',
        7: 'helpful partnerships, agreements, and trust',
        8: 'shared growth, healing, and resources',
        9: 'travel, education, wisdom, and faith',
        10: 'career expansion, status, and opportunity',
        11: 'networks, allies, and future success',
        12: 'spiritual growth, retreat, and protection',
      },
      'Saturn': {
        1: 'discipline, responsibility, and self-definition',
        2: 'budgeting, restraint, and durable value',
        3: 'serious communication, study, and structure',
        4: 'family duties, foundations, and boundaries',
        5: 'creative discipline, maturity, and commitment',
        6: 'hard work, routines, and health maintenance',
        7: 'commitment, tests, and relationship structure',
        8: 'shared duties, fear work, and deep change',
        9: 'belief testing, study, and long-range plans',
        10: 'career responsibility, status, and endurance',
        11: 'long-term goals, duties, and dependable friends',
        12: 'solitude, healing, and karmic release',
      },
      'Uranus': {
        1: 'reinvention, freedom, and surprise',
        2: 'sudden changes in money, values, and priorities',
        3: 'new ideas, fast movement, and disruptions',
        4: 'changes in home, family patterns, and roots',
        5: 'creative breakthroughs, romance, and risk-taking',
        6: 'new work methods, health shifts, and routines',
        7: 'unusual partnerships and relationship freedom',
        8: 'sudden transformation, shocks, and insight',
        9: 'awakening, travel, and alternative beliefs',
        10: 'career change, independence, and public surprises',
        11: 'new communities, future visions, and innovation',
        12: 'inner liberation, intuition, and release',
      },
      'Neptune': {
        1: 'sensitivity, intuition, and blurred identity',
        2: 'idealism, uncertainty, and spiritual values',
        3: 'imagination, intuition, and mixed signals',
        4: 'dreams, compassion, and family sensitivity',
        5: 'romance, inspiration, and creative fantasy',
        6: 'healing, service, and unclear routines',
        7: 'idealized relationships and emotional merging',
        8: 'deep compassion, surrender, and mystery',
        9: 'spiritual searching, faith, and vision',
        10: 'public inspiration, vocation, and foggy goals',
        11: 'idealistic friendships and hopes',
        12: 'dream life, retreat, and spiritual healing',
      },
      'Pluto': {
        1: 'identity transformation and personal power',
        2: 'deep value changes, control, and resources',
        3: 'intense communication, focus, and insight',
        4: 'family transformation and inner power',
        5: 'creative intensity, passion, and self-expression',
        6: 'work overhaul, healing, and endurance',
        7: 'relationship power dynamics and deep truth',
        8: 'deep transformation, shared power, and rebirth',
        9: 'belief transformation and deep learning',
        10: 'career power, status change, and influence',
        11: 'group influence, alliances, and future change',
        12: 'subconscious clearing, healing, and release',
      },
    },
  };

  String _houseMeaning(int house, String lang) {
    return _houseMeanings[lang]?[house] ??
        _houseMeanings['Eng']?[house] ??
        'important life themes';
  }

  String _transitMeaningLine(TransitItem item, String lang) {
    final planet =
        _planetNames[lang]?[item.transitPlanet] ?? item.transitPlanet;
    final houseLabel = _houseLabel[lang] ?? 'house';
    final houseMeaning = _houseMeaning(item.transitHouse, lang);
    final planetTheme =
        _planetTransitThemes[lang]?[item.transitPlanet]?[item.transitHouse] ??
        _planetTransitThemes['Eng']?[item.transitPlanet]?[item.transitHouse];

    switch (lang) {
      case 'Heb':
        return planetTheme == null
            ? '$planet ב-$houseLabel ${item.transitHouse}: $houseMeaning'
            : '$planet ב-$houseLabel ${item.transitHouse}: $planetTheme';
      case 'Rus':
        return planetTheme == null
            ? '$planet в $houseLabel ${item.transitHouse}: $houseMeaning'
            : '$planet в $houseLabel ${item.transitHouse}: $planetTheme';
      case 'Spa':
        return planetTheme == null
            ? '$planet en $houseLabel ${item.transitHouse}: $houseMeaning'
            : '$planet en $houseLabel ${item.transitHouse}: $planetTheme';
      default:
        return planetTheme == null
            ? '$planet in $houseLabel ${item.transitHouse}: $houseMeaning'
            : '$planet in $houseLabel ${item.transitHouse}: $planetTheme';
    }
  }

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
              color: _chartCardSurface.withOpacity(0.88),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: _chartCardBorder.withOpacity(0.75)),
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
    if (error != null) {
      return _InfoCard(
        title: _errorTitle[lang] ?? _errorTitle['Eng']!,
        text: _errorText[lang] ?? _errorText['Eng']!,
      );
    }

    final items = response!.transits;
    final interp = response!.interpretation.trim().isNotEmpty
        ? response!.interpretation
        : _fallbackInterpretation(items, lang);
    final isRtl = lang == 'Heb';

    return Column(
      children: [
        if (interp.trim().isNotEmpty) ...[
          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: _chartCardSurface.withOpacity(0.88),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: _chartCardBorder.withOpacity(0.75)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _todayTitle[lang] ?? "Today's Transits",
                      style: const TextStyle(
                        color: _chartTextStrong,
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      interp,
                      textDirection: isRtl
                          ? TextDirection.rtl
                          : TextDirection.ltr,
                      textAlign: isRtl ? TextAlign.right : TextAlign.left,
                      style: const TextStyle(
                        color: _chartTextBody,
                        fontSize: 13.5,
                        height: 1.65,
                        fontWeight: FontWeight.w600,
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
            text:
                _noneText[lang] ??
                'No significant transit aspects within 5° today.',
          )
        else
          ...List.generate(items.length, (i) {
            final t = items[i];
            final sym = _symMap[t.aspect] ?? '·';
            final color = _colorMap[t.aspect] ?? const Color(0xFF9B7FD4);
            return Padding(
              padding: EdgeInsets.only(bottom: i < items.length - 1 ? 10 : 0),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(18),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 13,
                    ),
                    decoration: BoxDecoration(
                      color: _chartCardSurface.withOpacity(0.86),
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(
                        color: _chartCardBorder.withOpacity(0.72),
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: color.withOpacity(0.18),
                          ),
                          child: Center(
                            child: Text(
                              sym,
                              style: TextStyle(fontSize: 16, color: color),
                            ),
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
                                  color: _chartTextStrong,
                                  fontSize: 13.5,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                _transitMeaningLine(t, lang),
                                style: const TextStyle(
                                  color: _chartTextBody,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  height: 1.25,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                '${_aspectNames[lang]?[t.aspect] ?? t.aspect} · ${t.transitSign}, ${_houseLabel[lang] ?? 'house'} ${t.transitHouse} (${_houseMeaning(t.transitHouse, lang)}) · ${t.orb.toStringAsFixed(1)}°',
                                style: const TextStyle(
                                  color: _chartTextBody,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
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

  const _InfoCard({required this.title, required this.text});

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
            border: Border.all(color: AstroPalette.glassBorder, width: 1.2),
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
                  color: _chartTextBody,
                  fontSize: 14,
                  height: 1.52,
                  fontWeight: FontWeight.w600,
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
            color: _chartCardSurface.withOpacity(0.90),
            borderRadius: BorderRadius.circular(22),
            border: Border.all(
              color: _chartCardBorder.withOpacity(0.75),
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
                        color: _chartTextBody,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        height: 1.45,
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
    'January',
    'February',
    'March',
    'April',
    'May',
    'June',
    'July',
    'August',
    'September',
    'October',
    'November',
    'December',
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
            border: Border.all(color: AstroPalette.glassBorder, width: 1.2),
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
                    ? () => widget.onSubmit(
                        _date!,
                        _time!,
                        _locationCtrl.text.trim(),
                      )
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
                      color: _canSubmit
                          ? AstroPalette.glassBorder
                          : AstroPalette.glassBorder,
                    ),
                  ),
                  child: Text(
                    'Calculate Chart',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: _canSubmit
                          ? AstroPalette.darkText
                          : AstroPalette.mutedLabel,
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
          decoration: const BoxDecoration(gradient: AstroPalette.appBackground),
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
        Positioned.fill(child: Container(color: const Color(0x22886CDA))),
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
        boxShadow: [BoxShadow(color: color, blurRadius: 70, spreadRadius: 18)],
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
    (r: 40.0, s: 1.0, sz: 9.0, c: Color(0xFFFFD700), a: 0.0),
    (r: 62.0, s: 1.55, sz: 7.0, c: Color(0xFFB8A0FF), a: 1.2),
    (r: 82.0, s: 2.1, sz: 6.0, c: Color(0xFF60D0FF), a: 2.5),
    (r: 100.0, s: 0.65, sz: 8.0, c: Color(0xFFFF90BC), a: 0.8),
    (r: 118.0, s: 1.85, sz: 6.0, c: Color(0xFFFF6B6B), a: 3.9),
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
      canvas.drawCircle(
        Offset(cx, cy),
        o.r,
        Paint()
          ..color = const Color(0xFF9B7FD4).withOpacity(0.20)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 0.8,
      );
    }

    // Sun glow
    canvas.drawCircle(
      Offset(cx, cy),
      18 + 5 * pulse,
      Paint()
        ..color = const Color(0xFFFFD700).withOpacity(0.15 + 0.15 * pulse)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 18),
    );
    // Sun
    canvas.drawCircle(
      Offset(cx, cy),
      12,
      Paint()..color = const Color(0xFFFFE44D),
    );
    canvas.drawCircle(
      Offset(cx, cy),
      12,
      Paint()
        ..color = const Color(0xFFFFAA00).withOpacity(0.5)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6),
    );

    // Planets
    for (final o in _orbits) {
      final angle = o.a + orbit * o.s * 2 * math.pi;
      final px = cx + math.cos(angle) * o.r;
      final py = cy + math.sin(angle) * o.r;
      // glow
      canvas.drawCircle(
        Offset(px, py),
        o.sz + 4,
        Paint()
          ..color = o.c.withOpacity(0.35)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8),
      );
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
