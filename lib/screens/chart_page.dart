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
const _lilacSurface = Color(0xFFF8F1FF);
const _lilacPrimary = Color(0xFF8F73E8);
const _lilacSoft = Color(0xFFE6D4FF);
const _lilacText = AstroPalette.darkText;
const _lilacTextSoft = AstroPalette.darkSecondary;
const _lilacBorder = Color(0xFFEFE6FF);

const _chartCardSurface = Color(0xFFF8F3FF);
const _chartCardBorder = Color(0xFFDCCBED);
const _chartTextStrong = Color(0xFF2F2552);
const _chartTextBody = Color(0xFF6C5F91);

Widget _lilacPickerTheme(BuildContext context, Widget? child) {
  final base = Theme.of(context);
  return Theme(
    data: base.copyWith(
      useMaterial3: true,
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
      canvasColor: _lilacSurface,
      cardColor: _lilacSurface,
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
        shadowColor: Colors.transparent,
        headerBackgroundColor: _lilacSoft,
        headerForegroundColor: _lilacText,
        rangePickerBackgroundColor: _lilacSurface,
        rangePickerSurfaceTintColor: _lilacSurface,
        rangePickerHeaderBackgroundColor: _lilacSoft,
        rangePickerHeaderForegroundColor: _lilacText,
        headerHeadlineStyle: const TextStyle(
          fontSize: 26,
          fontWeight: FontWeight.w700,
          color: _lilacText,
        ),
        headerHelpStyle: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.8,
          color: _lilacTextSoft,
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
        dialTextStyle: const TextStyle(
          color: _lilacText,
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
        dayPeriodTextStyle: const TextStyle(
          color: _lilacText,
          fontWeight: FontWeight.w700,
        ),
        hourMinuteTextStyle: const TextStyle(
          color: _lilacText,
          fontWeight: FontWeight.w700,
        ),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(28)),
        ),
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

ThemeData _astreyaTimePickerTheme(BuildContext context) {
  final base = Theme.of(context);
  return base.copyWith(
    useMaterial3: true,
    colorScheme: const ColorScheme.light(
      primary: Color(0xFF9278E8),
      onPrimary: Colors.white,
      secondary: Color(0xFFC95AC4),
      onSecondary: Colors.white,
      surface: Color(0xFFF8F3FF),
      onSurface: Color(0xFF30254F),
    ),
    dialogTheme: const DialogThemeData(
      backgroundColor: Color(0xFFF8F3FF),
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(28)),
      ),
    ),
    timePickerTheme: TimePickerThemeData(
      backgroundColor: const Color(0xFFF8F3FF),
      hourMinuteColor: const Color(0xFFDCCBFF),
      hourMinuteTextColor: const Color(0xFF30254F),
      dialBackgroundColor: const Color(0xFFF0E7FF),
      dialHandColor: const Color(0xFF49C8CE),
      dialTextColor: WidgetStateColor.resolveWith((states) {
        if (states.contains(WidgetState.selected)) return Colors.white;
        return const Color(0xFF30254F);
      }),
      entryModeIconColor: const Color(0xFF9278E8),
      helpTextStyle: const TextStyle(
        color: Color(0xFF746796),
        fontSize: 13,
        fontWeight: FontWeight.w600,
      ),
      hourMinuteTextStyle: const TextStyle(
        color: Color(0xFF30254F),
        fontSize: 30,
        fontWeight: FontWeight.w700,
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
      cancelButtonStyle: TextButton.styleFrom(
        foregroundColor: const Color(0xFF8B7CA8),
        textStyle: const TextStyle(fontWeight: FontWeight.w600),
      ),
      confirmButtonStyle: TextButton.styleFrom(
        foregroundColor: const Color(0xFF49C8CE),
        textStyle: const TextStyle(fontWeight: FontWeight.w700),
      ),
    ),
  );
}

ThemeData _astreyaDatePickerTheme(BuildContext context) {
  final base = Theme.of(context);
  return base.copyWith(
    useMaterial3: true,
    colorScheme: const ColorScheme.light(
      primary: Color(0xFF49C8CE),
      onPrimary: Colors.white,
      secondary: Color(0xFF9278E8),
      onSecondary: Colors.white,
      surface: Color(0xFFFBF8FF),
      onSurface: Color(0xFF30254F),
    ),
    dialogTheme: const DialogThemeData(
      backgroundColor: Color(0xFFF8F3FF),
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(28)),
      ),
    ),
    datePickerTheme: DatePickerThemeData(
      backgroundColor: const Color(0xFFF8F3FF),
      surfaceTintColor: Colors.transparent,
      headerBackgroundColor: const Color(0xFFEDE2FF).withOpacity(0.78),
      headerForegroundColor: const Color(0xFF30254F),
      headerHeadlineStyle: const TextStyle(
        color: Color(0xFF30254F),
        fontSize: 26,
        fontWeight: FontWeight.w600,
      ),
      headerHelpStyle: const TextStyle(
        color: Color(0xFF746796),
        fontSize: 12,
        fontWeight: FontWeight.w600,
      ),
      weekdayStyle: const TextStyle(
        color: Color(0xFF746796),
        fontSize: 12,
        fontWeight: FontWeight.w600,
      ),
      dayStyle: const TextStyle(
        color: Color(0xFF30254F),
        fontSize: 13,
        fontWeight: FontWeight.w500,
      ),
      dayForegroundColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) return Colors.white;
        if (states.contains(WidgetState.disabled)) {
          return const Color(0xFFB8AEC9);
        }
        return const Color(0xFF30254F);
      }),
      dayBackgroundColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return const Color(0xFF49C8CE);
        }
        if (states.contains(WidgetState.hovered)) {
          return const Color(0xFFEDE2FF);
        }
        return Colors.transparent;
      }),
      todayForegroundColor: const WidgetStatePropertyAll(Color(0xFF9278E8)),
      todayBorder: const BorderSide(color: Color(0xFF9278E8), width: 1.3),
      dayShape: WidgetStatePropertyAll(
        RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      yearForegroundColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) return Colors.white;
        return const Color(0xFF30254F);
      }),
      yearBackgroundColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return const Color(0xFF49C8CE);
        }
        return Colors.transparent;
      }),
      yearShape: WidgetStatePropertyAll(
        RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
      cancelButtonStyle: TextButton.styleFrom(
        foregroundColor: const Color(0xFF9184AE),
        textStyle: const TextStyle(fontWeight: FontWeight.w600),
      ),
      confirmButtonStyle: TextButton.styleFrom(
        foregroundColor: const Color(0xFF49C8CE),
        textStyle: const TextStyle(fontWeight: FontWeight.w700),
      ),
      dividerColor: const Color(0xFFD7CAE9).withOpacity(0.55),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
    ),
  );
}

class AstroChartPage extends StatefulWidget {
  final String initialLanguage;
  final bool openBirthDateOnStart;
  const AstroChartPage({
    super.key,
    this.initialLanguage = 'Eng',
    this.openBirthDateOnStart = false,
  });

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
        return [
          'Общее',
          'Прогноз на сегодня',
          'Планеты',
          'Аспекты',
          'Главные темы',
        ];
      case 'Heb':
        return ['כללי', 'תחזית להיום', 'כוכבי לכת', 'היבטים', 'נושאים מרכזיים'];
      case 'Spa':
        return [
          'General',
          'Pronóstico para hoy',
          'Planetas',
          'Aspectos',
          'Temas clave',
        ];
      case 'Fra':
        return [
          'Général',
          'Prévisions pour aujourd’hui',
          'Planètes',
          'Aspects',
          'Thèmes clés',
        ];
      default:
        return [
          'General',
          "Today's Forecast",
          'Planets',
          'Aspects',
          'Key Themes',
        ];
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
                  child: _ChartTopBar(language: _language),
                ),
                const SizedBox(height: 20),
                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: EdgeInsets.fromLTRB(
                      20,
                      0,
                      20,
                      MediaQuery.paddingOf(context).bottom + 40,
                    ),
                    child: Column(
                      children: [
                        if (!_birthDataSubmitted)
                          _BirthInputCard(
                            onSubmit: _onBirthSubmit,
                            language: _language,
                            autoOpenDatePicker: widget.openBirthDateOnStart,
                          )
                        else if (_chart == null || _isWaitingForGeneral)
                          _ChartLoadingAnimation(language: _language)
                        else ...[
                          _NatalChartWheel(chart: _chart, language: _language),
                          const SizedBox(height: 18),
                          _SummaryCard(language: _language),
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
      {'code': 'Heb', 'flag': '🇮🇱', 'label': 'עברית'},
      {'code': 'Spa', 'flag': '🇪🇸', 'label': 'ES'},
      {'code': 'Fra', 'flag': '🇫🇷', 'label': 'FR'},
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
                        ? AstroPalette.accentStrong
                        : AstroPalette.mutedLabel,
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
        return _TransitsTab(
          response: _transits,
          language: _language,
          isLoading: _isLoadingTransits,
          error: _transitsError,
        );
      case 2:
        return _PlanetsTab(
          planets: _chart?.planets,
          interpretations: _chart?.planetaryInterpretations ?? {},
          language: _language,
        );
      case 3:
        return _AspectsTab(
          planets: _chart?.planets,
          backendAspects: _chart?.aspects,
          aspectInterpretations: _chart?.aspectInterpretations ?? {},
          language: _language,
        );
      case 4:
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
      default:
        return const SizedBox.shrink();
    }
  }
}

class _ChartTopBar extends StatelessWidget {
  final String language;
  const _ChartTopBar({required this.language});

  String get _title {
    switch (language) {
      case 'Rus':
        return 'Натальная карта';
      case 'Heb':
        return 'מפת לידה';
      case 'Spa':
        return 'Carta natal';
      case 'Fra':
        return 'Thème natal';
      default:
        return 'Birth Chart';
    }
  }

  String get _subtitle {
    switch (language) {
      case 'Rus':
        return 'Астрологический разбор';
      case 'Heb':
        return 'ניתוח אסטרולוגי';
      case 'Spa':
        return 'Analisis astrologico';
      case 'Fra':
        return 'Analyse astrologique';
      default:
        return 'Natal chart';
    }
  }

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
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _title,
                style: const TextStyle(
                  color: AstroPalette.darkText,
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                _subtitle,
                style: const TextStyle(
                  color: AstroPalette.darkSecondary,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
        _glassCircle(
          const Icon(Icons.tune_rounded, color: AstroPalette.accentMagenta),
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
            color: Colors.white.withOpacity(0.18),
            border: Border.all(color: Colors.white.withOpacity(0.34), width: 1),
          ),
          child: Center(child: child),
        ),
      ),
    );
  }
}

class _NatalChartWheel extends StatelessWidget {
  final ChartResponse? chart;
  final String language;
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
    'Sun': Color(0xFFE9DEFF),
    'Moon': Color(0xFFDCCBFF),
    'Mercury': Color(0xFFAEEFED),
    'Venus': Color(0xFFF1B3FF),
    'Mars': Color(0xFFE96DFF),
    'Jupiter': Color(0xFF7EE7E1),
    'Saturn': Color(0xFFD6C0FF),
    'Uranus': Color(0xFF58D5D0),
    'Neptune': Color(0xFFBFA8F3),
    'Pluto': Color(0xFFD45BFF),
    'Ascendant': Color(0xFFF8F3FF),
  };

  const _NatalChartWheel({this.chart, this.language = 'Eng'});

  String _loc(String key) {
    const copy = {
      'Eng': {'title': 'Natal Chart', 'asc': 'ASC'},
      'Rus': {'title': 'Натальная карта', 'asc': 'ASC'},
      'Heb': {'title': 'מפת לידה', 'asc': 'ASC'},
      'Spa': {'title': 'Carta natal', 'asc': 'ASC'},
      'Fra': {'title': 'Thème natal', 'asc': 'ASC'},
    };
    return copy[language]?[key] ?? copy['Eng']![key] ?? key;
  }

  // Aries (0°) at top, clockwise
  static Offset _lonToOffset(double lon, double radius) {
    final a = (lon - 90) * math.pi / 180;
    return Offset(_cx + radius * math.cos(a), _cx + radius * math.sin(a));
  }

  @override
  Widget build(BuildContext context) {
    final planets = chart?.planets ?? [];
    final ascSign = chart?.ascendantSign ?? '';
    final label = ascSign.isNotEmpty
        ? '${_loc('asc')}: $ascSign'
        : _loc('title');

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
              Text(
                _loc('title'),
                style: const TextStyle(
                  color: AstroPalette.darkText,
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
                            _colors[p.name] ?? const Color(0xFFDCCBFF),
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
                  color: AstroPalette.darkSecondary,
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
                  color: _chartTextStrong,
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
                color: _chartTextStrong,
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
    Color(0xFFD6C0FF),
    Color(0xFF58D5D0),
    Color(0xFFE96DFF),
    Color(0xFF7EE7E1),
    Color(0xFFF1B3FF),
    Color(0xFFD45BFF),
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
  final String language;
  const _SummaryCard({this.language = 'Eng'});

  String _loc(String key) {
    const copy = {
      'Eng': {
        'title': 'Overall Portrait',
        'text':
            'You come across as serious, composed, and deep. Inside, emotional restraint, strong will, and a need for stability are combined. Your chart shows an ability to move toward goals slowly but very steadily.',
        'chip1': 'Practicality',
        'chip2': 'Depth',
        'chip3': 'Self-control',
        'chip4': 'Ambition',
      },
      'Rus': {
        'title': 'Общий портрет',
        'text':
            'Вы производите впечатление серьезного, собранного и глубокого человека. Внутри сочетаются эмоциональная сдержанность, сильная воля и потребность в стабильности. Ваша карта показывает способность идти к целям медленно, но очень уверенно.',
        'chip1': 'Практичность',
        'chip2': 'Глубина',
        'chip3': 'Самоконтроль',
        'chip4': 'Амбиции',
      },
      'Heb': {
        'title': 'דיוקן כללי',
        'text':
            'אתם נתפסים כרציניים, מאוזנים ועמוקים. בפנים יש שילוב של איפוק רגשי, רצון חזק וצורך ביציבות. המפה שלכם מראה יכולת להתקדם למטרות לאט אבל בצורה יציבה מאוד.',
        'chip1': 'פרקטיות',
        'chip2': 'עומק',
        'chip3': 'שליטה עצמית',
        'chip4': 'שאפתנות',
      },
      'Spa': {
        'title': 'Retrato general',
        'text':
            'Das una impresion seria, serena y profunda. Por dentro se combinan contencion emocional, voluntad fuerte y necesidad de estabilidad. Tu carta muestra capacidad para avanzar hacia metas lentamente pero con gran constancia.',
        'chip1': 'Practicidad',
        'chip2': 'Profundidad',
        'chip3': 'Autocontrol',
        'chip4': 'Ambicion',
      },
      'Fra': {
        'title': 'Portrait général',
        'text':
            'Vous donnez une impression de sérieux, de maîtrise et de profondeur. Une volonté forte, une certaine retenue émotionnelle et un besoin de stabilité coexistent en vous. Vous avancez vers vos objectifs avec patience et constance.',
        'chip1': 'Pragmatisme',
        'chip2': 'Profondeur',
        'chip3': 'Maîtrise de soi',
        'chip4': 'Ambition',
      },
    };
    return copy[language]?[key] ?? copy['Eng']![key] ?? key;
  }

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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _loc('title'),
                style: const TextStyle(
                  color: AstroPalette.darkText,
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                _loc('text'),
                style: const TextStyle(
                  color: AstroPalette.darkSecondary,
                  fontSize: 14,
                  height: 1.45,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 14),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _TagChip(label: _loc('chip1')),
                  _TagChip(label: _loc('chip2')),
                  _TagChip(label: _loc('chip3')),
                  _TagChip(label: _loc('chip4')),
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
        color: AstroPalette.magentaSoft.withOpacity(0.34),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: AstroPalette.darkTextStrong,
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
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      child: Row(
        children: List.generate(tabs.length, (index) {
          final selected = index == selectedIndex;
          return Padding(
            padding: EdgeInsets.only(right: index == tabs.length - 1 ? 0 : 8),
            child: GestureDetector(
              onTap: () => onTap(index),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 220),
                constraints: const BoxConstraints(minWidth: 96),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
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
                        ? AstroPalette.darkTextStrong
                        : AstroPalette.darkSecondary,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          );
        }),
      ),
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
    'Fra': 'Interprétation indisponible',
  };

  static const _emptyText = {
    'Eng':
        'The chart data loaded, but the narrative interpretation did not return in time.',
    'Rus':
        'Данные карты загрузились, но текстовая интерпретация не успела вернуться.',
    'Heb': 'נתוני המפה נטענו, אך הפרשנות הטקסטואלית לא חזרה בזמן.',
    'Spa':
        'Los datos de la carta se cargaron, pero la interpretacion textual no regreso a tiempo.',
    'Fra':
        'Les données du thème sont chargées, mais l’interprétation n’est pas revenue à temps.',
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
    'Fra': {
      'Sun': 'Soleil',
      'Moon': 'Lune',
      'Mercury': 'Mercure',
      'Venus': 'Vénus',
      'Mars': 'Mars',
      'Jupiter': 'Jupiter',
      'Saturn': 'Saturne',
      'Uranus': 'Uranus',
      'Neptune': 'Neptune',
      'Pluto': 'Pluton',
      'Ascendant': 'Ascendant',
      'North Node': 'Nœud nord',
      'South Node': 'Nœud sud',
      'Lilith': 'Lilith',
      'Selena': 'Séléné',
    },
  };

  static const _aspectNames = {
    'Eng': {
      'Conjunction': 'Strong combination',
      'Sextile': 'Helpful opportunity',
      'Square': 'Growth challenge',
      'Trine': 'Natural strength',
      'Opposition': 'Finding balance',
    },
    'Rus': {
      'Conjunction': 'Сильное объединение',
      'Sextile': 'Благоприятная возможность',
      'Square': 'Вызов для роста',
      'Trine': 'Естественная сильная сторона',
      'Opposition': 'Поиск баланса',
    },
    'Heb': {
      'Conjunction': 'שילוב חזק',
      'Sextile': 'הזדמנות מועילה',
      'Square': 'אתגר שמוביל לצמיחה',
      'Trine': 'חוזקה טבעית',
      'Opposition': 'מציאת איזון',
    },
    'Spa': {
      'Conjunction': 'Combinación fuerte',
      'Sextile': 'Oportunidad favorable',
      'Square': 'Desafío para crecer',
      'Trine': 'Fortaleza natural',
      'Opposition': 'Búsqueda de equilibrio',
    },
    'Fra': {
      'Conjunction': 'Union puissante',
      'Sextile': 'Occasion favorable',
      'Square': 'Défi de croissance',
      'Trine': 'Force naturelle',
      'Opposition': 'Recherche d’équilibre',
    },
  };
  static const _signNames = {
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
    'Fra': {
      'Aries': 'Bélier',
      'Taurus': 'Taureau',
      'Gemini': 'Gémeaux',
      'Cancer': 'Cancer',
      'Leo': 'Lion',
      'Virgo': 'Vierge',
      'Libra': 'Balance',
      'Scorpio': 'Scorpion',
      'Sagittarius': 'Sagittaire',
      'Capricorn': 'Capricorne',
      'Aquarius': 'Verseau',
      'Pisces': 'Poissons',
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
    'Fra': {
      1: 'expression personnelle',
      2: 'ressources et valeurs',
      3: 'apprentissage et communication',
      4: 'foyer et racines',
      5: 'créativité et amour',
      6: 'travail et habitudes',
      7: 'relations et partenariats',
      8: 'liens profonds et confiance',
      9: 'convictions et ouverture',
      10: 'carrière et visibilité',
      11: 'amitiés et projets',
      12: 'vie intérieure et guérison',
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
      case 'Fra':
        return 'maison';
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

  String _withoutTechnicalSeparators(String value) {
    return value
        .split('\n')
        .where((line) => !RegExp(r'^\s*-{3,}\s*$').hasMatch(line))
        .join('\n')
        .trim();
  }

  List<String> _narrativeSections(String value) {
    final cleaned = _withoutTechnicalSeparators(value);
    return cleaned
        .split(RegExp(r'\n\s*\n'))
        .map((part) => part.trim())
        .where((part) => part.isNotEmpty)
        .toList();
  }

  List<MapEntry<String, String>> _portraitSections(String value) {
    final sections = <MapEntry<String, String>>[];
    var title = '';
    final body = StringBuffer();

    void addSection() {
      final text = body.toString().trim().replaceAll('**', '');
      if (text.isNotEmpty) {
        sections.add(MapEntry(title, text));
      }
      body.clear();
    }

    for (final line in _withoutTechnicalSeparators(value).split('\n')) {
      final markdownHeading = RegExp(
        r'^\s*#{1,6}\s+(.+?)\s*$',
      ).firstMatch(line);
      final boldHeading = RegExp(r'^\s*\*\*(.+?)\*\*\s*$').firstMatch(line);
      final heading = markdownHeading?.group(1) ?? boldHeading?.group(1);
      if (heading != null) {
        addSection();
        title = heading.trim();
      } else {
        body.writeln(line);
      }
    }
    addSection();

    return sections;
  }

  bool _isHouseInterpretationLine(String line) {
    return RegExp(
      r'^\s*-\s*(House|Дом|Casa|בית)\s+\d+',
      caseSensitive: false,
    ).hasMatch(line);
  }

  String _detailedInterpretation(String methodText) {
    return methodText
        .split('\n')
        .where((line) => !_isHouseInterpretationLine(line))
        .where((line) => !RegExp(r'^\s*-{3,}\s*$').hasMatch(line))
        .join('\n')
        .trim();
  }

  String _reportTitle(String key) {
    const copy = {
      'Eng': {
        'portrait': 'Psychological Portrait',
        'core': 'Core Signature',
        'themes': 'Main Life Themes',
        'overview': 'Analysis Overview',
        'details': 'Detailed Interpretation',
        'planets': 'planets',
        'aspects': 'major aspects',
        'configurations': 'configurations',
      },
      'Rus': {
        'portrait': 'Психологический портрет',
        'core': 'Главная сигнатура',
        'themes': 'Основные темы жизни',
        'overview': 'Обзор анализа',
        'details': 'Подробная интерпретация',
        'planets': 'планет',
        'aspects': 'мажорных аспектов',
        'configurations': 'конфигураций',
      },
      'Heb': {
        'portrait': 'דיוקן פסיכולוגי',
        'core': 'החתימה המרכזית',
        'themes': 'נושאי החיים המרכזיים',
        'overview': 'סקירת הניתוח',
        'details': 'פרשנות מפורטת',
        'planets': 'כוכבי לכת',
        'aspects': 'היבטים מרכזיים',
        'configurations': 'תצורות',
      },
      'Spa': {
        'portrait': 'Retrato psicológico',
        'core': 'Firma central',
        'themes': 'Temas principales de vida',
        'overview': 'Resumen del análisis',
        'details': 'Interpretación detallada',
        'planets': 'planetas',
        'aspects': 'aspectos mayores',
        'configurations': 'configuraciones',
      },
      'Fra': {
        'portrait': 'Portrait psychologique',
        'core': 'Signature centrale',
        'themes': 'Grands thèmes de vie',
        'overview': 'Vue d’ensemble',
        'details': 'Interprétation détaillée',
        'planets': 'planètes',
        'aspects': 'aspects majeurs',
        'configurations': 'configurations',
      },
    };
    return copy[language]?[key] ?? copy['Eng']![key] ?? key;
  }

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
              color: _chartCardSurface.withOpacity(0.88),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: _chartCardBorder.withOpacity(0.75)),
            ),
            child: const Center(
              child: CircularProgressIndicator(
                color: AstroPalette.accentMagenta,
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

    final portraitSections = _portraitSections(interpretation!);

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 980),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            for (var index = 0; index < portraitSections.length; index++) ...[
              if (index > 0) const SizedBox(height: 16),
              _AnalysisGlassSection(
                title: portraitSections[index].key.isEmpty
                    ? _reportTitle('portrait')
                    : portraitSections[index].key,
                text: portraitSections[index].value,
                accent: index.isEven
                    ? const Color(0xFF49C8CE)
                    : const Color(0xFF9278E8),
                isRtl: isRtl,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _AnalysisGlassSection extends StatelessWidget {
  final String title;
  final String text;
  final Color accent;
  final bool isRtl;
  final Widget? content;

  const _AnalysisGlassSection({
    required this.title,
    required this.text,
    required this.accent,
    required this.isRtl,
    this.content,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(26),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xE6FBF8FF), Color(0xD9F0E7FF)],
            ),
            borderRadius: BorderRadius.circular(26),
            border: Border.all(color: Colors.white.withOpacity(0.52)),
            boxShadow: const [
              BoxShadow(
                color: Color(0x183A2F61),
                blurRadius: 24,
                offset: Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 4,
                    height: 20,
                    decoration: BoxDecoration(
                      color: accent,
                      borderRadius: BorderRadius.circular(99),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      title,
                      textDirection: isRtl
                          ? TextDirection.rtl
                          : TextDirection.ltr,
                      textAlign: isRtl ? TextAlign.right : TextAlign.left,
                      style: const TextStyle(
                        color: Color(0xFF30254F),
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              if (content != null)
                content!
              else
                Text(
                  text,
                  textDirection: isRtl ? TextDirection.rtl : TextDirection.ltr,
                  textAlign: isRtl ? TextAlign.right : TextAlign.left,
                  style: const TextStyle(
                    color: Color(0xFF51456F),
                    fontSize: 14,
                    height: 1.55,
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

class _AnalysisMetrics extends StatelessWidget {
  final String title;
  final List<String> metrics;
  final bool isRtl;

  const _AnalysisMetrics({
    required this.title,
    required this.metrics,
    required this.isRtl,
  });

  @override
  Widget build(BuildContext context) {
    return _AnalysisGlassSection(
      title: title,
      text: '',
      accent: const Color(0xFF49C8CE),
      isRtl: isRtl,
      content: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: metrics
            .map(
              (metric) => Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFEDE2FF).withOpacity(0.72),
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(color: Colors.white.withOpacity(0.64)),
                ),
                child: Text(
                  metric,
                  style: const TextStyle(
                    color: Color(0xFF80739F),
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            )
            .toList(),
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
    'Fra': {
      'Sun': 'Soleil',
      'Moon': 'Lune',
      'Mercury': 'Mercure',
      'Venus': 'Vénus',
      'Mars': 'Mars',
      'Jupiter': 'Jupiter',
      'Saturn': 'Saturne',
      'Uranus': 'Uranus',
      'Neptune': 'Neptune',
      'Pluto': 'Pluton',
      'North Node': 'Nœud nord',
      'South Node': 'Nœud sud',
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
    'Fra': {
      'Aries': 'Bélier',
      'Taurus': 'Taureau',
      'Gemini': 'Gémeaux',
      'Cancer': 'Cancer',
      'Leo': 'Lion',
      'Virgo': 'Vierge',
      'Libra': 'Balance',
      'Scorpio': 'Scorpion',
      'Sagittarius': 'Sagittaire',
      'Capricorn': 'Capricorne',
      'Aquarius': 'Verseau',
      'Pisces': 'Poissons',
    },
  };

  static const _houseLabel = {
    'Eng': 'House',
    'Rus': 'Дом',
    'Heb': 'בית',
    'Spa': 'Casa',
    'Fra': 'Maison',
  };

  String _normalizeSign(String sign) {
    final token = sign.trim().toLowerCase().replaceAll(RegExp(r'[^a-z]'), '');
    const aliases = {
      'aries': 'Aries',
      'taurus': 'Taurus',
      'gemini': 'Gemini',
      'cancer': 'Cancer',
      'leo': 'Leo',
      'virgo': 'Virgo',
      'libra': 'Libra',
      'scorpio': 'Scorpio',
      'sagittarius': 'Sagittarius',
      'sagitarius': 'Sagittarius',
      'sagitarrius': 'Sagittarius',
      'capricorn': 'Capricorn',
      'aquarius': 'Aquarius',
      'pisces': 'Pisces',
    };

    return aliases[token] ?? sign.trim();
  }

  String _fallbackDescription(PlanetPosition planet, String lang) {
    final normalizedSign = _normalizeSign(planet.sign);
    final sign =
        _signs[lang]?[normalizedSign] ??
        _signs['Eng']?[normalizedSign] ??
        normalizedSign;
    switch (lang) {
      case 'Heb':
        return '${_names[lang]?[planet.name] ?? planet.name} ב-$sign מדגיש ${_planetTheme(planet.name, lang)} דרך נושאי ${_houseTheme(planet.house, lang)}.';
      case 'Rus':
        return '${_names[lang]?[planet.name] ?? planet.name} в знаке $sign подчёркивает ${_planetTheme(planet.name, lang)} через темы ${_houseTheme(planet.house, lang)}.';
      case 'Spa':
        return '${_names[lang]?[planet.name] ?? planet.name} en $sign resalta ${_planetTheme(planet.name, lang)} a traves de ${_houseTheme(planet.house, lang)}.';
      case 'Fra':
        return '${_names[lang]?[planet.name] ?? planet.name} en $sign met en valeur ${_planetTheme(planet.name, lang)} à travers ${_houseTheme(planet.house, lang)}.';
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
      'Fra': {
        'Sun': 'l’identité et le sens de la vie',
        'Moon': 'les besoins émotionnels et les instincts',
        'Mercury': 'la pensée et la communication',
        'Venus': 'les relations et les valeurs',
        'Mars': 'l’élan et l’action',
        'Jupiter': 'la croissance et la confiance',
        'Saturn': 'la discipline et la responsabilité',
        'Uranus': 'le changement et l’indépendance',
        'Neptune': 'l’imagination et la sensibilité',
        'Pluto': 'la profondeur et la transformation',
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
      'Fra': {
        1: 'l’expression personnelle',
        2: 'la sécurité et les ressources',
        3: 'l’apprentissage et la communication',
        4: 'le foyer et les racines',
        5: 'la créativité et l’amour',
        6: 'le travail et les habitudes quotidiennes',
        7: 'les relations et les partenariats',
        8: 'la confiance et la profondeur émotionnelle',
        9: 'les convictions et l’ouverture',
        10: 'la carrière et la vie publique',
        11: 'les amitiés et les projets futurs',
        12: 'la vie intérieure et la guérison',
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

  String _emptyT(String key) {
    const copy = {
      'Eng': {
        'noneTitle': 'No strong connections found',
        'noneText': 'No major planet-to-planet influences were detected.',
      },
      'Rus': {
        'noneTitle': 'Аспекты не найдены',
        'noneText': 'Значимые аспекты в стандартных орбисах не обнаружены.',
      },
      'Heb': {
        'noneTitle': 'לא נמצאו קשרים חזקים',
        'noneText': 'לא זוהו השפעות משמעותיות בין כוכבי הלכת.',
      },
      'Spa': {
        'noneTitle': 'No se encontraron conexiones fuertes',
        'noneText':
            'No se detectaron influencias importantes entre los planetas.',
      },
      'Fra': {
        'noneTitle': 'Aucun aspect majeur trouvé',
        'noneText':
            'Aucune influence importante entre les planètes n’a été détectée.',
      },
    };
    return copy[language]?[key] ?? copy['Eng']![key] ?? key;
  }

  static const _aspectNames = {
    'Eng': {
      'Conjunction': 'Strong combination',
      'Sextile': 'Helpful opportunity',
      'Square': 'Growth challenge',
      'Trine': 'Natural strength',
      'Quincunx': 'Needs adjustment',
      'Opposition': 'Finding balance',
    },
    'Rus': {
      'Conjunction': 'Сильное объединение',
      'Sextile': 'Благоприятная возможность',
      'Square': 'Вызов для роста',
      'Trine': 'Естественная сильная сторона',
      'Quincunx': 'Нужна корректировка',
      'Opposition': 'Поиск баланса',
    },
    'Heb': {
      'Conjunction': 'שילוב חזק',
      'Sextile': 'הזדמנות מועילה',
      'Square': 'אתגר שמוביל לצמיחה',
      'Trine': 'חוזקה טבעית',
      'Quincunx': 'נדרשת התאמה',
      'Opposition': 'מציאת איזון',
    },
    'Spa': {
      'Conjunction': 'Combinación fuerte',
      'Sextile': 'Oportunidad favorable',
      'Square': 'Desafío para crecer',
      'Trine': 'Fortaleza natural',
      'Quincunx': 'Necesita ajuste',
      'Opposition': 'Búsqueda de equilibrio',
    },
    'Fra': {
      'Conjunction': 'Union puissante',
      'Sextile': 'Occasion favorable',
      'Square': 'Défi de croissance',
      'Trine': 'Force naturelle',
      'Quincunx': 'Ajustement nécessaire',
      'Opposition': 'Recherche d’équilibre',
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
    'Fra': {
      'Conjunction': 'Fusion des énergies',
      'Sextile': 'Ouverture et fluidité',
      'Square': 'Tension et croissance',
      'Trine': 'Harmonie et aisance',
      'Quincunx': 'Réglage nécessaire',
      'Opposition': 'Équilibre et polarité',
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
    'Fra': {
      'Sun': 'Soleil',
      'Moon': 'Lune',
      'Mercury': 'Mercure',
      'Venus': 'Vénus',
      'Mars': 'Mars',
      'Jupiter': 'Jupiter',
      'Saturn': 'Saturne',
      'Uranus': 'Uranus',
      'Neptune': 'Neptune',
      'Pluto': 'Pluton',
      'Ascendant': 'Ascendant',
      'North Node': 'Nœud nord',
      'South Node': 'Nœud sud',
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
      'Conjunction': Color(0xFFD6C0FF),
      'Sextile': Color(0xFF58D5D0),
      'Square': Color(0xFFE96DFF),
      'Trine': Color(0xFF3FC6D4),
      'Quincunx': Color(0xFFF1B3FF),
      'Opposition': Color(0xFFD45BFF),
    };
    final lang = _aspectKeywords.containsKey(language) ? language : 'Eng';
    return src
        .map(
          (a) => _AspectEntry(
            p1: a.planet1,
            p2: a.planet2,
            name: a.aspect,
            sym: symMap[a.aspect] ?? '·',
            color: colorMap[a.aspect] ?? const Color(0xFFD6C0FF),
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
      Color(0xFFD6C0FF),
      Color(0xFF58D5D0),
      Color(0xFFE96DFF),
      Color(0xFF3FC6D4),
      Color(0xFFF1B3FF),
      Color(0xFFD45BFF),
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

  String? _russianAspectInsight(_AspectEntry aspect) {
    bool pair(String first, String second) =>
        (aspect.p1 == first && aspect.p2 == second) ||
        (aspect.p1 == second && aspect.p2 == first);

    if (aspect.name == 'Square' && pair('Sun', 'Jupiter')) {
      return 'Между желанием мыслить масштабно и необходимостью учитывать реальные возможности возникает постоянное напряжение. Большие цели мотивируют вас сильнее маленьких, но важно не переоценивать запас времени и сил.';
    }
    if (aspect.name == 'Trine' && pair('Venus', 'Mars')) {
      return 'Чувства и действия обычно поддерживают друг друга: вам легче показать симпатию поступком и превратить притяжение в живое взаимодействие. Это даёт естественное обаяние и хороший баланс мягкости с инициативой.';
    }
    if (aspect.name == 'Sextile' && pair('Neptune', 'Pluto')) {
      return 'Вы тонко чувствуете скрытые перемены и способны принимать глубокую внутреннюю перестройку без лишнего внешнего шума. Это поколенческий аспект, поэтому лично он особенно заметен, когда затрагивает ваши ценности и эмоциональные опоры.';
    }
    if (aspect.name == 'Conjunction' && pair('Mercury', 'Uranus')) {
      return 'Ваш ум работает быстро и нестандартно: вы замечаете связи, которые другие пропускают, и можете внезапно увидеть решение целиком. Иногда мысль опережает речь, поэтому окружающим нужны промежуточные объяснения.';
    }
    if (aspect.name == 'Conjunction' && pair('Saturn', 'Ascendant')) {
      return 'Вы производите серьёзное, собранное и надёжное впечатление, даже когда внутри чувствуете неуверенность. Высокие требования к себе помогают держать форму, но могут мешать быть спонтаннее и мягче к собственным ошибкам.';
    }
    if (aspect.name == 'Sextile' && pair('Saturn', 'Uranus')) {
      return 'Вы способны обновлять систему, не разрушая то, что уже работает. Практичность помогает проверять смелые идеи, а независимость не даёт дисциплине превратиться в слепое следование правилам.';
    }
    if (aspect.name == 'Square' && pair('Sun', 'Mars')) {
      return 'Внутри много воли и соревновательной энергии, поэтому промедление или чужое давление могут быстро вызывать раздражение. Когда у этой силы есть ясная цель, она превращается в смелость, выносливость и способность действовать там, где другие отступают.';
    }
    if (aspect.name == 'Conjunction' && pair('Mars', 'Jupiter')) {
      return 'Вы действуете с размахом и легче включаетесь в задачу, если видите в ней рост или вызов. Энтузиазм заразителен, но иногда ускоряет вас раньше, чем проверены детали и последствия.';
    }
    if (aspect.name == 'Square' && pair('Venus', 'Ascendant')) {
      return 'То, как вы выглядите со стороны, не всегда совпадает с тем, чего вы хотите от близости. Возможны попытки быть удобнее или сдержаннее, чем вам действительно комфортно; честная самоподача делает отношения заметно проще.';
    }
    if (aspect.name == 'Trine' && pair('Moon', 'Jupiter')) {
      return 'Эмоциональная щедрость и вера в лучшее помогают вам восстанавливаться после трудностей. Вы умеете поддержать другого, но иногда можете успокаивать себя слишком широкими обещаниями вместо разговора о конкретном чувстве.';
    }
    if (aspect.name == 'Trine' && pair('Venus', 'Jupiter')) {
      return 'Вам свойственны теплота, великодушие и способность видеть хорошее в людях. Удовольствие легко становится способом расширить жизнь, хотя временами хочется позволить себе больше, чем разумно.';
    }
    if (aspect.name == 'Quincunx' && pair('Moon', 'Neptune')) {
      return 'Высокая чувствительность помогает улавливать настроение людей, но иногда затрудняет понимание собственных эмоций. Вам полезно отделять интуитивный сигнал от тревоги, фантазии или чужого состояния.';
    }
    if (aspect.name == 'Quincunx' && pair('Sun', 'Moon')) {
      return 'Ваши сознательные цели и эмоциональные потребности не всегда движутся в одном ритме. Можно уверенно выбрать направление, а затем обнаружить внутреннее сопротивление; регулярная сверка с собственным состоянием помогает не жить через постоянное усилие.';
    }
    if (aspect.name == 'Sextile' && pair('Mercury', 'Saturn')) {
      return 'Вы умеете упорядочивать сложные мысли, проверять факты и говорить по существу. Серьёзность мышления особенно полезна в долгих проектах, хотя иногда делает формулировки строже, чем требуется ситуации.';
    }
    if (aspect.name == 'Opposition' && pair('Moon', 'Mercury')) {
      return 'Чувства и логика могут давать разные ответы: сначала возникает эмоциональная реакция, а затем ум пытается её объяснить или оспорить. Ваше преимущество появляется, когда вы не подавляете ни одну сторону и даёте им время договориться.';
    }
    if (aspect.name == 'Square' && pair('Saturn', 'Neptune')) {
      return 'Между потребностью в ясном порядке и верой в невидимый смысл возникает напряжение. Вы можете чередовать жёсткий контроль с усталостью от ограничений; зрелый путь состоит в том, чтобы давать мечте форму, не лишая её вдохновения.';
    }
    return null;
  }

  String? _leadingAspectInsight(_AspectEntry aspect) {
    bool pair(String first, String second) =>
        (aspect.p1 == first && aspect.p2 == second) ||
        (aspect.p1 == second && aspect.p2 == first);

    String localized({
      required String eng,
      required String rus,
      required String heb,
      required String spa,
      required String fra,
    }) {
      switch (language) {
        case 'Rus':
          return rus;
        case 'Heb':
          return heb;
        case 'Spa':
          return spa;
        case 'Fra':
          return fra;
        default:
          return eng;
      }
    }

    if (aspect.name == 'Square' && pair('Sun', 'Jupiter')) {
      return localized(
        eng:
            'There is a constant tension between thinking big and respecting real limits. Large goals motivate you, but you may overestimate your available time or energy.',
        rus:
            'Между желанием мыслить масштабно и необходимостью учитывать реальные возможности возникает постоянное напряжение. Большие цели мотивируют вас сильнее маленьких, но важно не переоценивать запас времени и сил.',
        heb:
            'קיים בכם מתח מתמיד בין הרצון לחשוב בגדול לבין הצורך להתחשב במגבלות אמיתיות. מטרות גדולות מניעות אתכם, אך לעיתים אתם מעריכים יתר על המידה את הזמן או האנרגיה הזמינים.',
        spa:
            'Existe una tensión constante entre pensar a lo grande y respetar los límites reales. Las metas ambiciosas te motivan, pero a veces puedes sobreestimar el tiempo o la energía disponibles.',
        fra:
            'Une tension constante existe entre votre envie de voir grand et la nécessité de respecter les limites réelles. Les objectifs ambitieux vous motivent, mais vous pouvez parfois surestimer le temps ou l’énergie disponibles.',
      );
    }
    if (aspect.name == 'Trine' && pair('Venus', 'Mars')) {
      return localized(
        eng:
            'Feelings and actions naturally support one another: you can show affection through action and turn attraction into genuine connection. This gives warmth, charm, and a healthy balance between softness and initiative.',
        rus:
            'Чувства и действия обычно поддерживают друг друга: вам легче показать симпатию поступком и превратить притяжение в живое взаимодействие. Это даёт естественное обаяние и хороший баланс мягкости с инициативой.',
        heb:
            'הרגש והפעולה תומכים זה בזה באופן טבעי: קל לכם להביע חיבה במעשים ולהפוך משיכה לקשר חי. הדבר מעניק חום, קסם ואיזון טוב בין רכות ליוזמה.',
        spa:
            'Los sentimientos y las acciones se apoyan de forma natural: te resulta fácil demostrar afecto con hechos y convertir la atracción en conexión real. Esto aporta calidez, encanto y equilibrio entre suavidad e iniciativa.',
        fra:
            'Les sentiments et les actes se soutiennent naturellement : vous exprimez facilement votre affection par des gestes et transformez l’attirance en lien réel. Cela donne de la chaleur, du charme et un bel équilibre entre douceur et initiative.',
      );
    }
    if (aspect.name == 'Conjunction' && pair('Mercury', 'Uranus')) {
      return localized(
        eng:
            'Your mind works quickly and unconventionally. You notice connections others miss and may see the complete solution before those around you understand the intermediate steps.',
        rus:
            'Ваш ум работает быстро и нестандартно. Вы замечаете связи, которые другие пропускают, и можете увидеть решение целиком раньше, чем окружающие поймут промежуточные шаги.',
        heb:
            'המחשבה שלכם מהירה ולא שגרתית. אתם מזהים קשרים שאחרים מפספסים ולעיתים רואים את הפתרון המלא לפני שהסביבה מבינה את שלבי הביניים.',
        spa:
            'Tu mente funciona con rapidez y de manera poco convencional. Detectas conexiones que otros pasan por alto y puedes ver la solución completa antes de que los demás comprendan los pasos intermedios.',
        fra:
            'Votre esprit fonctionne vite et de manière originale. Vous repérez des liens que d’autres ne voient pas et pouvez saisir la solution entière avant que votre entourage ne comprenne les étapes intermédiaires.',
      );
    }
    if (aspect.name == 'Square' && pair('Sun', 'Mars')) {
      return localized(
        eng:
            'You carry strong will and competitive energy, so delays or outside pressure can trigger irritation quickly. With a clear goal, that same force becomes courage, stamina, and decisive action.',
        rus:
            'Внутри много воли и соревновательной энергии, поэтому промедление или чужое давление могут быстро вызывать раздражение. При ясной цели эта сила превращается в смелость, выносливость и решительность.',
        heb:
            'יש בכם רצון חזק ואנרגיה תחרותית, ולכן עיכובים או לחץ חיצוני עלולים לעורר תסכול במהירות. כאשר המטרה ברורה, אותה עוצמה הופכת לאומץ, סיבולת ופעולה החלטית.',
        spa:
            'Tienes mucha voluntad y energía competitiva, por lo que los retrasos o la presión externa pueden irritarte con rapidez. Con una meta clara, esa fuerza se convierte en valor, resistencia y decisión.',
        fra:
            'Vous possédez une forte volonté et une énergie combative ; les retards ou la pression extérieure peuvent donc vous irriter rapidement. Avec un objectif clair, cette force devient courage, endurance et capacité d’action.',
      );
    }
    if (aspect.name == 'Trine' && pair('Moon', 'Jupiter')) {
      return localized(
        eng:
            'Emotional generosity and faith in improvement help you recover after difficulties. You know how to encourage others, though optimism can sometimes replace a direct conversation about what you truly feel.',
        rus:
            'Эмоциональная щедрость и вера в лучшее помогают вам восстанавливаться после трудностей. Вы умеете поддержать другого, но иногда оптимизм заменяет прямой разговор о собственных чувствах.',
        heb:
            'נדיבות רגשית ואמונה בטוב עוזרות לכם להתאושש מקשיים. אתם יודעים לעודד אחרים, אך לפעמים האופטימיות מחליפה שיחה ישירה על מה שאתם באמת מרגישים.',
        spa:
            'La generosidad emocional y la confianza en que las cosas pueden mejorar te ayudan a recuperarte. Sabes animar a otros, aunque a veces el optimismo sustituye una conversación directa sobre lo que sientes.',
        fra:
            'Votre générosité émotionnelle et votre confiance dans l’avenir vous aident à rebondir après les difficultés. Vous savez encourager les autres, même si l’optimisme remplace parfois une conversation directe sur vos propres émotions.',
      );
    }
    return null;
  }

  String _fallbackAspectDescription(
    _AspectEntry aspect,
    String p1Name,
    String p2Name,
    String aspectName,
    int p1Count,
    int p2Count,
  ) {
    final orb = aspect.orb;
    final isTight = orb <= 2.0;
    final isSignificant = orb > 2.0 && orb <= 4.0;

    String strengthLabel(String lang) {
      if (lang == 'Rus') {
        if (isTight) return 'Это точный и один из ключевых аспектов карты.';
        if (isSignificant)
          return 'Это заметный аспект, который ощутимо влияет на поведение.';
        return 'Это фоновый аспект: он работает мягче, но добавляет важный оттенок.';
      }
      if (lang == 'Heb') {
        if (isTight) return 'זהו היבט מדויק ומרכזי במפה.';
        if (isSignificant)
          return 'זהו היבט משמעותי עם השפעה ניכרת על ההתנהגות.';
        return 'זהו היבט רקע: עדין יותר, אך מוסיף שכבה חשובה.';
      }
      if (lang == 'Spa') {
        if (isTight) return 'Es un aspecto preciso y central de la carta.';
        if (isSignificant)
          return 'Es un aspecto significativo con impacto claro en la conducta.';
        return 'Es un aspecto de fondo: mas suave, pero aun relevante.';
      }
      if (lang == 'Fra') {
        if (isTight) return 'C’est un aspect précis et central du thème.';
        if (isSignificant) {
          return 'C’est un aspect important qui influence clairement le comportement.';
        }
        return 'C’est un aspect de fond : plus discret, mais toujours significatif.';
      }
      if (isTight) return 'This is a tight, defining aspect in the chart.';
      if (isSignificant)
        return 'This is a significant aspect with clear personality impact.';
      return 'This is a background aspect: subtler, but still meaningful.';
    }

    String aspectBehavior(String lang, String name) {
      final map = {
        'Eng': {
          'Conjunction': 'blends both energies into one dominant channel',
          'Sextile': 'opens a cooperative flow and practical opportunities',
          'Square': 'creates friction that pushes growth through challenge',
          'Trine': 'supports natural talent and easier expression',
          'Opposition': 'creates polarity and asks for conscious balance',
          'Quincunx': 'shows mismatch that requires adjustment and fine tuning',
        },
        'Rus': {
          'Conjunction': 'сливает две энергии в один ведущий канал',
          'Sextile': 'даёт рабочий поток и практичные возможности',
          'Square': 'создаёт напряжение, через которое приходит рост',
          'Trine': 'поддерживает естественный талант и лёгкое проявление',
          'Opposition': 'создаёт полярность и требует осознанного баланса',
          'Quincunx':
              'показывает нестыковку, требующую корректировки и настройки',
        },
        'Heb': {
          'Conjunction': 'ממזג את שתי האנרגיות לערוץ דומיננטי אחד',
          'Sextile': 'פותח זרימה שיתופית והזדמנויות מעשיות',
          'Square': 'יוצר חיכוך שמקדם צמיחה דרך אתגר',
          'Trine': 'תומך בכישרון טבעי ובהבעה זורמת',
          'Opposition': 'יוצר קוטביות ודורש איזון מודע',
          'Quincunx': 'מצביע על חוסר התאמה שמצריך כוונון והתאמה',
        },
        'Spa': {
          'Conjunction': 'fusiona ambas energias en un solo canal dominante',
          'Sextile': 'abre cooperacion y oportunidades practicas',
          'Square': 'crea friccion que impulsa crecimiento',
          'Trine': 'favorece talento natural y expresion fluida',
          'Opposition': 'marca polaridad y exige equilibrio consciente',
          'Quincunx': 'muestra desajuste que requiere correccion fina',
        },
        'Fra': {
          'Conjunction': 'réunit les deux énergies en un seul courant dominant',
          'Sextile':
              'ouvre une coopération fluide et des possibilités concrètes',
          'Square': 'crée une friction qui pousse à grandir',
          'Trine': 'soutient un talent naturel et une expression aisée',
          'Opposition': 'crée une polarité qui demande un équilibre conscient',
          'Quincunx':
              'révèle un décalage qui demande des ajustements réguliers',
        },
      };
      return map[lang]?[name] ?? map['Eng']?[name] ?? name.toLowerCase();
    }

    String planetRole(String lang, String planet) {
      final map = {
        'Eng': {
          'Sun': 'will and ego expression',
          'Moon': 'emotions and inner needs',
          'Mercury': 'thinking and communication',
          'Venus': 'love, values, and attraction',
          'Mars': 'action and desire',
          'Jupiter': 'growth and beliefs',
          'Saturn': 'discipline and limits',
          'Uranus': 'innovation and unpredictability',
          'Neptune': 'imagination and inspiration',
          'Pluto': 'transformation and power dynamics',
          'Ascendant': 'outward identity and style',
        },
        'Rus': {
          'Sun': 'воля и самовыражение',
          'Moon': 'эмоции и внутренние потребности',
          'Mercury': 'мышление и коммуникация',
          'Venus': 'ценности, симпатии и стиль близости',
          'Mars': 'действие и напор',
          'Jupiter': 'рост и убеждения',
          'Saturn': 'дисциплина и границы',
          'Uranus': 'новаторство и непредсказуемость',
          'Neptune': 'вдохновение и тонкая чувствительность',
          'Pluto': 'трансформация и контроль',
          'Ascendant': 'внешний образ и способ самоподачи',
        },
        'Heb': {
          'Sun': 'רצון וביטוי עצמי',
          'Moon': 'רגש וצרכים פנימיים',
          'Mercury': 'חשיבה ותקשורת',
          'Venus': 'ערכים, אהבה ומשיכה',
          'Mars': 'פעולה ודחף',
          'Jupiter': 'צמיחה ואמונות',
          'Saturn': 'משמעת וגבולות',
          'Uranus': 'חדשנות ואי־צפיות',
          'Neptune': 'השראה ורגישות עדינה',
          'Pluto': 'טרנספורמציה וכוח',
          'Ascendant': 'זהות חיצונית ואופן הצגה',
        },
        'Spa': {
          'Sun': 'voluntad y expresion del yo',
          'Moon': 'emociones y necesidades internas',
          'Mercury': 'pensamiento y comunicacion',
          'Venus': 'valores, amor y atraccion',
          'Mars': 'accion y deseo',
          'Jupiter': 'crecimiento y creencias',
          'Saturn': 'disciplina y limites',
          'Uranus': 'innovacion e imprevisibilidad',
          'Neptune': 'inspiracion y sensibilidad',
          'Pluto': 'transformacion y poder',
          'Ascendant': 'identidad externa y estilo social',
        },
        'Fra': {
          'Sun': 'volonté et expression personnelle',
          'Moon': 'émotions et besoins intérieurs',
          'Mercury': 'pensée et communication',
          'Venus': 'valeurs, affection et manière d’aimer',
          'Mars': 'action et désir',
          'Jupiter': 'croissance et convictions',
          'Saturn': 'discipline et limites',
          'Uranus': 'innovation et imprévisibilité',
          'Neptune': 'imagination et sensibilité',
          'Pluto': 'transformation et rapports de pouvoir',
          'Ascendant': 'image extérieure et manière de se présenter',
        },
      };
      return map[lang]?[planet] ?? map['Eng']?[planet] ?? planet;
    }

    final role1 = planetRole(language, aspect.p1);
    final role2 = planetRole(language, aspect.p2);
    final behavior = aspectBehavior(language, aspect.name);
    final leadingInsight = _leadingAspectInsight(aspect);
    if (leadingInsight != null) {
      return '$leadingInsight ${strengthLabel(language)}';
    }

    String aspectTypeLineRu() {
      switch (aspect.name) {
        case 'Conjunction':
          return 'энергии работают как единый поток: сильнее всего проявляется тема объединения мотивации и реакции';
        case 'Sextile':
          return 'между темами есть рабочая связка: легче замечать возможности и переводить их в конкретные шаги';
        case 'Square':
          return 'включается продуктивное напряжение: именно через внутренний конфликт здесь формируется рост и зрелость';
        case 'Trine':
          return 'есть естественная гармония: качества проявляются свободно и часто воспринимаются как врождённый талант';
        case 'Opposition':
          return 'формируется полюсность: важно не выбирать одну сторону, а настраивать баланс между ними';
        case 'Quincunx':
          return 'заметна нестыковка ритмов: аспект требует регулярной подстройки привычек и ожиданий';
        default:
          return 'темы взаимодействуют заметно и формируют отдельный поведенческий паттерн';
      }
    }

    String recurringNote() {
      final maxCount = p1Count > p2Count ? p1Count : p2Count;
      if (maxCount < 2) return '';
      switch (language) {
        case 'Rus':
          return ' Повторяющаяся тема: одна из этих планет участвует в нескольких аспектах, поэтому динамика усиливается и проявляется чаще.';
        case 'Heb':
          return ' נושא חוזר: אחד הכוכבים כאן מופיע במספר היבטים, ולכן הדינמיקה הזו מודגשת במיוחד במפה.';
        case 'Spa':
          return ' Tema recurrente: uno de estos planetas aparece en varios aspectos, por lo que esta dinamica se refuerza.';
        case 'Fra':
          return ' Thème récurrent : l’une de ces planètes participe à plusieurs aspects, ce qui renforce cette dynamique.';
        default:
          return ' Recurring theme: one of these planets appears in multiple aspects, so this dynamic becomes a repeating pattern.';
      }
    }

    switch (language) {
      case 'Heb':
        return '$p1Name ($role1) מול $p2Name ($role2): בהיבט $aspectName נוצרת דינמיקה שבה $behavior. '
            '${strengthLabel('Heb')} אורב ${orb.toStringAsFixed(1)}° מחדד עד כמה הדפוס הזה פעיל ביומיום.${recurringNote()}';
      case 'Rus':
        final specificInsight = _russianAspectInsight(aspect);
        if (specificInsight != null) {
          return '$specificInsight ${strengthLabel('Rus')}';
        }
        return '$p1Name ($role1) и $p2Name ($role2): $aspectName — ${aspectTypeLineRu()}. '
            '${strengthLabel('Rus')}';
      case 'Fra':
        return '$p1Name ($role1) et $p2Name ($role2) : $aspectName $behavior. '
            '${strengthLabel('Fra')} L’orbe de ${orb.toStringAsFixed(1)}° indique la force avec laquelle ce schéma tend à se manifester.${recurringNote()}';
      case 'Spa':
        return '$p1Name ($role1) y $p2Name ($role2): $aspectName $behavior. '
            '${strengthLabel('Spa')} El orbe ${orb.toStringAsFixed(1)}° marca la intensidad practica del patron.${recurringNote()}';
      default:
        return '$p1Name ($role1) with $p2Name ($role2): $aspectName $behavior. '
            '${strengthLabel('Eng')} Orb ${orb.toStringAsFixed(1)}° shows how strongly this pattern tends to manifest.${recurringNote()}';
    }
  }

  String _t(Map<String, String> m) => m[language] ?? m['Eng'] ?? '';

  String _groupTitleTight() => _t({
    'Eng': 'Strongest connections',
    'Rus': 'Самые сильные связи',
    'Heb': 'הקשרים החזקים ביותר',
    'Spa': 'Conexiones más fuertes',
    'Fra': 'Liens les plus puissants',
  });

  String _groupTitleSignificant() => _t({
    'Eng': 'Important connections',
    'Rus': 'Важные связи',
    'Heb': 'קשרים חשובים',
    'Spa': 'Conexiones importantes',
    'Fra': 'Liens importants',
  });

  String _groupTitleBackground() => _t({
    'Eng': 'Background connections',
    'Rus': 'Фоновые связи',
    'Heb': 'קשרים ברקע',
    'Spa': 'Conexiones de fondo',
    'Fra': 'Liens de fond',
  });

  String _overallTitle() => _t({
    'Eng': 'Overall Picture',
    'Rus': 'Общая картина',
    'Heb': 'התמונה הכוללת',
    'Spa': 'Panorama general',
    'Fra': 'Vue d’ensemble',
  });

  bool _isTenseAspect(String name) =>
      name == 'Square' || name == 'Opposition' || name == 'Quincunx';

  String _overallPictureText(List<_AspectEntry> aspects) {
    if (aspects.isEmpty) {
      return _t({
        'Eng': 'No major recurring themes were detected between the planets.',
        'Rus':
            'По текущему набору аспектов не выявлено выраженных повторяющихся тем.',
        'Heb': 'לא זוהו נושאים חוזרים בולטים בין כוכבי הלכת.',
        'Spa': 'No se detectaron temas recurrentes claros entre los planetas.',
      });
    }

    final byPlanet = <String, int>{};
    int tenseCount = 0;
    for (final a in aspects) {
      byPlanet[a.p1] = (byPlanet[a.p1] ?? 0) + 1;
      byPlanet[a.p2] = (byPlanet[a.p2] ?? 0) + 1;
      if (_isTenseAspect(a.name)) tenseCount++;
    }

    final dominant = byPlanet.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final dominantPlanet = dominant.isNotEmpty ? dominant.first.key : '';
    final dominantCount = dominant.isNotEmpty ? dominant.first.value : 0;
    final pLang = _planetNames.containsKey(language) ? language : 'Eng';
    final dominantName = _planetNames[pLang]?[dominantPlanet] ?? dominantPlanet;

    final tight = aspects.where((a) => a.orb <= 2.0).toList();
    final lead = tight.isNotEmpty ? tight.first : aspects.first;
    final aLang = _aspectNames.containsKey(language) ? language : 'Eng';
    final leadAspectName = _aspectNames[aLang]?[lead.name] ?? lead.name;
    final p1 = _planetNames[pLang]?[lead.p1] ?? lead.p1;
    final p2 = _planetNames[pLang]?[lead.p2] ?? lead.p2;

    switch (language) {
      case 'Rus':
        return 'Ключевая связка: $p1 $leadAspectName $p2 (орб ${lead.orb.toStringAsFixed(1)}°). '
            'Повторяющаяся тема: $dominantName участвует в $dominantCount аспектах, поэтому его функции выражены особенно ярко. '
            'Баланс карты: напряжённых аспектов $tenseCount из ${aspects.length}, что задаёт заметную динамику роста через задачи и настройку реакций.';
      case 'Heb':
        return 'הקשר המרכזי: $p1 ו-$p2 יוצרים $leadAspectName. '
            'נושא חוזר: $dominantName מופיע ב-$dominantCount קשרים ולכן ההשפעה שלו חזקה במיוחד. '
            'בתמונה הכוללת יש $tenseCount אתגרי צמיחה מתוך ${aspects.length} קשרים.';
      case 'Spa':
        return 'Conexión principal: $p1 y $p2 crean una dinámica de $leadAspectName. '
            'Tema recurrente: $dominantName aparece en $dominantCount conexiones, por lo que su influencia es especialmente fuerte. '
            'En general hay $tenseCount desafíos de crecimiento entre ${aspects.length} conexiones.';
      case 'Fra':
        return 'Lien principal : $p1 et $p2 forment une dynamique de type $leadAspectName. '
            'Thème récurrent : $dominantName participe à $dominantCount aspects, ce qui renforce son influence. '
            'Dans l’ensemble, $tenseCount aspects sur ${aspects.length} demandent un ajustement ou un effort de croissance.';
      default:
        return 'Main connection: $p1 and $p2 create a $leadAspectName dynamic. '
            'Recurring theme: $dominantName appears in $dominantCount connections, making its influence especially strong. '
            'Overall, there are $tenseCount growth challenges among ${aspects.length} connections.';
    }
  }

  Widget _sectionHeader(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          text,
          style: const TextStyle(
            color: _chartTextStrong,
            fontSize: 14,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }

  Widget _overallCard(String text) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(18),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: _chartCardSurface.withOpacity(0.9),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: _chartCardBorder.withOpacity(0.72)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _overallTitle(),
                style: const TextStyle(
                  color: _chartTextStrong,
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                text,
                style: const TextStyle(
                  color: _chartTextBody,
                  fontSize: 12.8,
                  height: 1.6,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
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
                color: AstroPalette.accentMagenta,
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
      return _InfoCard(title: _emptyT('noneTitle'), text: _emptyT('noneText'));
    }

    final planetFrequency = <String, int>{};
    for (final a in aspects) {
      planetFrequency[a.p1] = (planetFrequency[a.p1] ?? 0) + 1;
      planetFrequency[a.p2] = (planetFrequency[a.p2] ?? 0) + 1;
    }

    List<Widget> buildCards(
      List<_AspectEntry> src,
    ) => List.generate(src.length, (i) {
      final a = src[i];
      final lang = _aspectNames.containsKey(language) ? language : 'Eng';
      final pLang = _planetNames.containsKey(language) ? language : 'Eng';
      final p1Name = _planetNames[pLang]?[a.p1] ?? a.p1;
      final p2Name = _planetNames[pLang]?[a.p2] ?? a.p2;
      final aspectName = _aspectNames[lang]?[a.name] ?? a.name;
      final directKey = '${a.p1} ${a.name} ${a.p2}';
      final reverseKey = '${a.p2} ${a.name} ${a.p1}';
      final backendDescription =
          (aspectInterpretations[directKey] ??
                  aspectInterpretations[reverseKey] ??
                  '')
              .trim();
      final desc = backendDescription.isNotEmpty
          ? backendDescription
          : _fallbackAspectDescription(
              a,
              p1Name,
              p2Name,
              aspectName,
              planetFrequency[a.p1] ?? 1,
              planetFrequency[a.p2] ?? 1,
            );
      return Padding(
        padding: EdgeInsets.only(bottom: i < src.length - 1 ? 10 : 0),
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

    final tight = aspects.where((a) => a.orb <= 2.0).toList();
    final significant = aspects
        .where((a) => a.orb > 2.0 && a.orb <= 4.0)
        .toList();
    final background = aspects
        .where((a) => a.orb > 4.0 && a.orb <= 7.0)
        .toList();

    final sections = <Widget>[];

    if (tight.isNotEmpty) {
      sections.add(_sectionHeader(_groupTitleTight()));
      sections.addAll(buildCards(tight));
      sections.add(const SizedBox(height: 12));
    }
    if (significant.isNotEmpty) {
      sections.add(_sectionHeader(_groupTitleSignificant()));
      sections.addAll(buildCards(significant));
      sections.add(const SizedBox(height: 12));
    }
    if (background.isNotEmpty) {
      sections.add(_sectionHeader(_groupTitleBackground()));
      sections.addAll(buildCards(background));
      sections.add(const SizedBox(height: 12));
    }

    sections.add(_overallCard(_overallPictureText(aspects)));
    return Column(children: sections);
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
    'Fra': 'Aucune configuration',
  };
  static const _emptyText = {
    'Eng':
        'No major configurations (T-Square, Grand Trine, Yod, etc.) detected.',
    'Rus':
        'Крупных конфигураций (Т-квадрат, Большой трин, Иод и др.) не обнаружено.',
    'Heb': 'לא נמצאו קונפיגורציות עיקריות (T-Square, Grand Trine, Yod וכד׳).',
    'Spa':
        'No se detectaron configuraciones principales (T-Cuadrado, Gran Trígono, Yod, etc.).',
    'Fra':
        'Aucune configuration majeure (carré en T, grand trigone, yod, etc.) n’a été détectée.',
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
    if (language == 'Fra') {
      if (pattern.startsWith('Stellium'))
        return 'Un stellium concentre beaucoup d’énergie dans un même domaine de vie, qui devient alors particulièrement important.';
      if (pattern.startsWith('T-Square'))
        return 'Le carré en T crée une tension constructive qui pousse à grandir, agir et trouver un nouvel équilibre.';
      if (pattern.startsWith('Grand Trine'))
        return 'Le grand trigone révèle une aisance naturelle et un talent qu’il est utile de développer consciemment.';
      if (pattern.startsWith('Yod'))
        return 'Le yod indique un chemin d’ajustements subtils et une direction qui prend progressivement tout son sens.';
      if (pattern.startsWith('Kite'))
        return 'La configuration en cerf-volant relie les talents naturels à une direction claire pour avancer.';
      return 'Cette configuration révèle un schéma important du thème et la manière dont plusieurs forces agissent ensemble.';
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
    'Eng': 'What Today Brings',
    'Rus': 'Что вас ждёт сегодня',
    'Heb': 'מה מחכה לכם היום',
    'Spa': 'Qué te espera hoy',
    'Fra': 'Ce qui vous attend aujourd’hui',
  };
  static const _noneTitle = {
    'Eng': 'No active transits',
    'Rus': 'Нет активных транзитов',
    'Heb': 'אין מעברים פעילים',
    'Spa': 'Sin tránsitos activos',
    'Fra': 'Aucun transit actif',
  };
  static const _noneText = {
    'Eng': 'No significant transit aspects within 5° today.',
    'Rus': 'Сегодня нет значимых транзитных аспектов в пределах 5°.',
    'Heb': 'אין אספקטי מעבר משמעותיים בתוך 5° היום.',
    'Spa': 'Hoy no hay aspectos de tránsito significativos dentro de 5°.',
    'Fra': 'Aucun aspect de transit significatif à moins de 5° aujourd’hui.',
  };
  static const _errorTitle = {
    'Eng': 'Transits unavailable',
    'Rus': 'Транзиты недоступны',
    'Heb': 'המעברים אינם זמינים',
    'Spa': 'Transitos no disponibles',
    'Fra': 'Transits indisponibles',
  };
  static const _errorText = {
    'Eng':
        'Transit data could not be loaded. The natal chart is still available.',
    'Rus':
        'Не удалось загрузить транзиты. Натальная карта по-прежнему доступна.',
    'Heb': 'לא ניתן היה לטעון את נתוני המעברים. מפת הלידה עדיין זמינה.',
    'Spa':
        'No se pudieron cargar los transitos. La carta natal sigue disponible.',
    'Fra':
        'Les transits n’ont pas pu être chargés. Le thème natal reste disponible.',
  };
  static const _natalLabel = {
    'Eng': 'natal',
    'Rus': 'натальный',
    'Heb': 'נטלי',
    'Spa': 'natal',
    'Fra': 'natal',
  };
  static const _houseLabel = {
    'Eng': 'house',
    'Rus': 'дом',
    'Heb': 'בית',
    'Spa': 'casa',
    'Fra': 'maison',
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
    'Fra': {
      'Sun': 'Soleil',
      'Moon': 'Lune',
      'Mercury': 'Mercure',
      'Venus': 'Vénus',
      'Mars': 'Mars',
      'Jupiter': 'Jupiter',
      'Saturn': 'Saturne',
      'Uranus': 'Uranus',
      'Neptune': 'Neptune',
      'Pluto': 'Pluton',
      'Ascendant': 'Ascendant',
      'North Node': 'Nœud nord',
      'South Node': 'Nœud sud',
      'Lilith': 'Lilith',
    },
  };
  static const _aspectNames = {
    'Eng': {
      'Conjunction': 'Strong combination',
      'Sextile': 'Helpful opportunity',
      'Square': 'Growth challenge',
      'Trine': 'Natural strength',
      'Quincunx': 'Needs adjustment',
      'Opposition': 'Finding balance',
    },
    'Rus': {
      'Conjunction': 'Сильное объединение',
      'Sextile': 'Благоприятная возможность',
      'Square': 'Вызов для роста',
      'Trine': 'Естественная сильная сторона',
      'Quincunx': 'Нужна корректировка',
      'Opposition': 'Поиск баланса',
    },
    'Heb': {
      'Conjunction': 'שילוב חזק',
      'Sextile': 'הזדמנות מועילה',
      'Square': 'אתגר שמוביל לצמיחה',
      'Trine': 'חוזקה טבעית',
      'Quincunx': 'נדרשת התאמה',
      'Opposition': 'מציאת איזון',
    },
    'Spa': {
      'Conjunction': 'Combinación fuerte',
      'Sextile': 'Oportunidad favorable',
      'Square': 'Desafío para crecer',
      'Trine': 'Fortaleza natural',
      'Quincunx': 'Necesita ajuste',
      'Opposition': 'Búsqueda de equilibrio',
    },
    'Fra': {
      'Conjunction': 'Union puissante',
      'Sextile': 'Occasion favorable',
      'Square': 'Défi de croissance',
      'Trine': 'Force naturelle',
      'Quincunx': 'Ajustement nécessaire',
      'Opposition': 'Recherche d’équilibre',
    },
  };
  static const _signNames = {
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
    'Fra': {
      'Aries': 'Bélier',
      'Taurus': 'Taureau',
      'Gemini': 'Gémeaux',
      'Cancer': 'Cancer',
      'Leo': 'Lion',
      'Virgo': 'Vierge',
      'Libra': 'Balance',
      'Scorpio': 'Scorpion',
      'Sagittarius': 'Sagittaire',
      'Capricorn': 'Capricorne',
      'Aquarius': 'Verseau',
      'Pisces': 'Poissons',
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
              return '$transitPlanet ב-${_houseLabel[lang] ?? 'בית'} ${item.transitHouse} יוצר $aspect עם $natalPlanet (${_orbStrengthLabel(item.orb, lang)})';
            case 'Rus':
              return '$transitPlanet в ${_houseLabel[lang] ?? 'дом'} ${item.transitHouse} формирует $aspect к $natalPlanet';
            case 'Spa':
              return '$transitPlanet en ${_houseLabel[lang] ?? 'casa'} ${item.transitHouse} crea $aspect con $natalPlanet';
            case 'Fra':
              return '$transitPlanet en ${_houseLabel[lang] ?? 'maison'} ${item.transitHouse} forme $aspect avec $natalPlanet';
            default:
              return '$transitPlanet in ${_houseLabel[lang] ?? 'house'} ${item.transitHouse} forms a $aspect with $natalPlanet';
          }
        })
        .join(lang == 'Heb' ? ' • ' : '; ');

    switch (lang) {
      case 'Heb':
        return 'המעברים הפעילים היום מדגישים שילוב בין צרכים רגשיים, מערכות יחסים והחלטות מעשיות. '
            'כדאי לפעול בקצב מדורג: קודם דיוק פנימי, אחר כך תגובה חיצונית. '
            'מוקדי היום: $highlights.';
      case 'Rus':
        return 'Текущие транзиты подчёркивают темы отношений, эмоциональных реакций и практических решений. Главные акценты дня: $highlights.';
      case 'Spa':
        return 'Los transitos activos resaltan temas de relaciones, respuestas emocionales y decisiones practicas. Enfoques del dia: $highlights.';
      case 'Fra':
        return 'Les transits actifs mettent en lumière les relations, les réactions émotionnelles et les décisions concrètes. Points forts du jour : $highlights.';
      default:
        return 'The active transits currently emphasize relationships, emotional responses, and practical timing. Today\'s main highlights: $highlights.';
    }
  }

  String _displayInterpretation(String text, String lang) {
    var cleaned = text
        .replaceAll(RegExp(r'^\s*---+\s*$', multiLine: true), '')
        .replaceAll(RegExp(r'^\s*#{1,6}\s*', multiLine: true), '')
        .replaceAll('**', '')
        .replaceAll('*', '');
    if (lang == 'Rus') {
      cleaned = cleaned.replaceAll(
        RegExp(r'\borb\b', caseSensitive: false),
        'орбис',
      );
    }
    return cleaned.replaceAll(RegExp(r'\n{3,}'), '\n\n').trim();
  }

  bool _isTechnicalInterpretation(String text) {
    final normalized = text.toLowerCase();
    return normalized.contains('claude api') ||
        normalized.contains('fallback') ||
        normalized.contains('structural template') ||
        normalized.contains('structured guidance') ||
        normalized.contains('структурный разбор') ||
        normalized.contains('структуре при недоступном');
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
    'Conjunction': Color(0xFFD6C0FF),
    'Sextile': Color(0xFF58D5D0),
    'Square': Color(0xFFE96DFF),
    'Trine': Color(0xFF3FC6D4),
    'Quincunx': Color(0xFFF1B3FF),
    'Opposition': Color(0xFFD45BFF),
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
    'Fra': {
      1: 'identité et initiative personnelle',
      2: 'argent, valeurs et estime de soi',
      3: 'communication et déplacements quotidiens',
      4: 'foyer, racines et sécurité émotionnelle',
      5: 'créativité, amour et expression personnelle',
      6: 'travail, habitudes et bien-être',
      7: 'relations et coopération',
      8: 'ressources partagées, confiance et transformation',
      9: 'voyages, convictions et ouverture',
      10: 'carrière, réputation et orientation publique',
      11: 'communauté, amitiés et projets futurs',
      12: 'vie intérieure, guérison et lâcher-prise',
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

  String _orbStrengthLabel(double orb, String lang) {
    if (orb <= 1.5) {
      switch (lang) {
        case 'Heb':
          return 'השפעה חזקה מאוד';
        case 'Rus':
          return 'очень сильное влияние';
        case 'Spa':
          return 'influencia muy fuerte';
        case 'Fra':
          return 'influence très forte';
        default:
          return 'very strong influence';
      }
    }
    if (orb <= 3.0) {
      switch (lang) {
        case 'Heb':
          return 'השפעה מורגשת';
        case 'Rus':
          return 'заметное влияние';
        case 'Spa':
          return 'influencia notable';
        case 'Fra':
          return 'influence sensible';
        default:
          return 'noticeable influence';
      }
    }
    switch (lang) {
      case 'Heb':
        return 'השפעת רקע';
      case 'Rus':
        return 'фоновое влияние';
      case 'Spa':
        return 'influencia de fondo';
      case 'Fra':
        return 'influence de fond';
      default:
        return 'background influence';
    }
  }

  String _hebAspectGuidance(String aspect) {
    switch (aspect) {
      case 'Conjunction':
        return 'פותח התחלה חדשה ומבקש מיקוד בכיוון אחד ברור.';
      case 'Sextile':
        return 'יוצר הזדמנות שדורשת פעולה יזומה ועדינה.';
      case 'Square':
        return 'מעלה חיכוך בריא שדוחף לשינוי דפוס ישן.';
      case 'Trine':
        return 'זורם בטבעיות ומאפשר התקדמות עם פחות מאמץ.';
      case 'Quincunx':
        return 'מבקש כיוונון מחדש וסבלנות לפני החלטה.';
      case 'Opposition':
        return 'מדגיש קוטביות ודורש איזון בין שני צרכים.';
      default:
        return 'מדגיש צורך במודעות ובבחירה מדויקת.';
    }
  }

  String _transitMeaningLine(TransitItem item, String lang) {
    final planet =
        _planetNames[lang]?[item.transitPlanet] ?? item.transitPlanet;
    final natalPlanet =
        _planetNames[lang]?[item.natalPlanet] ?? item.natalPlanet;
    final aspectName = _aspectNames[lang]?[item.aspect] ?? item.aspect;
    final houseLabel = _houseLabel[lang] ?? 'house';
    final houseMeaning = _houseMeaning(item.transitHouse, lang);
    final planetTheme =
        _planetTransitThemes[lang]?[item.transitPlanet]?[item.transitHouse];

    switch (lang) {
      case 'Heb':
        return '$planet ב-$houseLabel ${item.transitHouse} מדגיש $houseMeaning. '
            '$aspectName מול $natalPlanet: ${_hebAspectGuidance(item.aspect)} '
            '(${_orbStrengthLabel(item.orb, lang)}).';
      case 'Rus':
        return planetTheme == null
            ? '$planet в доме ${item.transitHouse}: $houseMeaning'
            : '$planet в доме ${item.transitHouse}: $planetTheme';
      case 'Spa':
        return planetTheme == null
            ? '$planet en $houseLabel ${item.transitHouse}: $houseMeaning'
            : '$planet en $houseLabel ${item.transitHouse}: $planetTheme';
      case 'Fra':
        return planetTheme == null
            ? '$planet en maison ${item.transitHouse} : $houseMeaning'
            : '$planet en maison ${item.transitHouse} : $planetTheme';
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
                color: AstroPalette.accentMagenta,
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
    final backendInterpretation = response!.interpretation.trim();
    final interp =
        backendInterpretation.isNotEmpty &&
            !_isTechnicalInterpretation(backendInterpretation)
        ? backendInterpretation
        : _fallbackInterpretation(items, lang);
    final displayInterp = _displayInterpretation(interp, lang);
    final strongestItems = [...items]
      ..sort((first, second) => first.orb.compareTo(second.orb));
    final visibleItems = strongestItems.take(12).toList();
    final isRtl = lang == 'Heb';

    return Directionality(
      textDirection: isRtl ? TextDirection.rtl : TextDirection.ltr,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (displayInterp.isNotEmpty) ...[
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
                    border: Border.all(
                      color: _chartCardBorder.withOpacity(0.75),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _todayTitle[lang] ?? "Today's Transits",
                        textAlign: isRtl ? TextAlign.right : TextAlign.left,
                        style: const TextStyle(
                          color: _chartTextStrong,
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        displayInterp,
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
            ...List.generate(visibleItems.length, (i) {
              final t = visibleItems[i];
              final sym = _symMap[t.aspect] ?? '·';
              final color = _colorMap[t.aspect] ?? const Color(0xFFD6C0FF);
              return Padding(
                padding: EdgeInsets.only(
                  bottom: i < visibleItems.length - 1 ? 10 : 0,
                ),
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
                                  '${_aspectNames[lang]?[t.aspect] ?? t.aspect} · ${_signNames[lang]?[t.transitSign] ?? t.transitSign}, ${_houseLabel[lang] ?? 'house'} ${t.transitHouse} (${_houseMeaning(t.transitHouse, lang)}) · ${t.orb.toStringAsFixed(1)}°',
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
      ),
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
                  color: _chartTextStrong,
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
                  gradient: AstroPalette.iconBubble,
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
                            color: _chartTextStrong,
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
  final String language;
  final bool autoOpenDatePicker;
  const _BirthInputCard({
    required this.onSubmit,
    required this.language,
    this.autoOpenDatePicker = false,
  });

  @override
  State<_BirthInputCard> createState() => _BirthInputCardState();
}

class _BirthInputCardState extends State<_BirthInputCard> {
  DateTime? _date;
  TimeOfDay? _time;
  final _locationCtrl = TextEditingController();
  bool _didAutoOpenDatePicker = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_didAutoOpenDatePicker && widget.autoOpenDatePicker) {
      _didAutoOpenDatePicker = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && _date == null) {
          _pickDate();
        }
      });
    }
  }

  @override
  void dispose() {
    _locationCtrl.dispose();
    super.dispose();
  }

  bool get _canSubmit =>
      _date != null && _time != null && _locationCtrl.text.trim().isNotEmpty;

  static const _selectDateAction = {
    'Eng': 'Select',
    'Rus': 'Выбрать',
    'Heb': 'בחירה',
    'Spa': 'Seleccionar',
    'Fra': 'Sélectionner',
  };

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime(1990),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      confirmText: _selectDateAction[_lang] ?? _selectDateAction['Eng']!,
      builder: (context, child) {
        return Theme(data: _astreyaDatePickerTheme(context), child: child!);
      },
    );
    if (picked != null) setState(() => _date = picked);
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: const TimeOfDay(hour: 12, minute: 0),
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
          child: Theme(data: _astreyaTimePickerTheme(context), child: child!),
        );
      },
    );
    if (picked != null) setState(() => _time = picked);
  }

  static const _months = {
    'Eng': [
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
    ],
    'Rus': [
      '',
      'января',
      'февраля',
      'марта',
      'апреля',
      'мая',
      'июня',
      'июля',
      'августа',
      'сентября',
      'октября',
      'ноября',
      'декабря',
    ],
    'Heb': [
      '',
      'ינואר',
      'פברואר',
      'מרץ',
      'אפריל',
      'מאי',
      'יוני',
      'יולי',
      'אוגוסט',
      'ספטמבר',
      'אוקטובר',
      'נובמבר',
      'דצמבר',
    ],
    'Spa': [
      '',
      'enero',
      'febrero',
      'marzo',
      'abril',
      'mayo',
      'junio',
      'julio',
      'agosto',
      'septiembre',
      'octubre',
      'noviembre',
      'diciembre',
    ],
    'Fra': [
      '',
      'janvier',
      'février',
      'mars',
      'avril',
      'mai',
      'juin',
      'juillet',
      'août',
      'septembre',
      'octobre',
      'novembre',
      'décembre',
    ],
  };

  static const _selectDate = {
    'Eng': 'Select date',
    'Rus': 'Выберите дату',
    'Heb': 'בחר/י תאריך',
    'Spa': 'Selecciona fecha',
    'Fra': 'Choisir une date',
  };

  static const _selectTime = {
    'Eng': 'Select time',
    'Rus': 'Выберите время',
    'Heb': 'בחר/י שעה',
    'Spa': 'Selecciona hora',
    'Fra': 'Choisir une heure',
  };

  String _formatDate() {
    if (_date == null) return _selectDate[_lang] ?? _selectDate['Eng']!;
    final months = _months[_lang] ?? _months['Eng']!;
    return '${months[_date!.month]} ${_date!.day}, ${_date!.year}';
  }

  String _formatTime() => _time == null
      ? (_selectTime[_lang] ?? _selectTime['Eng']!)
      : '${_time!.hour.toString().padLeft(2, '0')}:${_time!.minute.toString().padLeft(2, '0')}';

  static const _introEyebrow = {
    'Eng': 'YOUR NATAL CHART',
    'Rus': 'ВАША НАТАЛЬНАЯ КАРТА',
    'Heb': 'מפת הלידה שלך',
    'Spa': 'TU CARTA NATAL',
    'Fra': 'VOTRE THÈME NATAL',
  };

  static const _introTitle = {
    'Eng': 'Begin with your birth details',
    'Rus': 'Начните с данных о рождении',
    'Heb': 'מתחילים עם פרטי הלידה',
    'Spa': 'Comienza con tus datos de nacimiento',
    'Fra': 'Commencez par vos données de naissance',
  };

  static const _introDescription = {
    'Eng':
        'Add your date, exact time, and birthplace to calculate your personal chart.',
    'Rus':
        'Укажите дату, точное время и место рождения, чтобы рассчитать личную карту.',
    'Heb': 'הוסיפו תאריך, שעה מדויקת ומקום לידה כדי לחשב את המפה האישית שלכם.',
    'Spa':
        'Añade tu fecha, hora exacta y lugar de nacimiento para calcular tu carta personal.',
    'Fra':
        'Indiquez votre date, votre heure exacte et votre lieu de naissance pour calculer votre thème personnel.',
  };

  static const _quickSteps = {
    'Eng': '3 quick steps',
    'Rus': '3 простых шага',
    'Heb': '3 שלבים קצרים',
    'Spa': '3 pasos rápidos',
    'Fra': '3 étapes simples',
  };

  static const _step1Label = {
    'Eng': 'DATE OF BIRTH',
    'Rus': 'ДАТА РОЖДЕНИЯ',
    'Heb': 'תאריך לידה',
    'Spa': 'FECHA DE NACIMIENTO',
    'Fra': 'DATE DE NAISSANCE',
  };

  static const _step2Label = {
    'Eng': 'TIME OF BIRTH',
    'Rus': 'ВРЕМЯ РОЖДЕНИЯ',
    'Heb': 'שעת לידה',
    'Spa': 'HORA DE NACIMIENTO',
    'Fra': 'HEURE DE NAISSANCE',
  };

  static const _placeLabel = {
    'Eng': 'PLACE OF BIRTH',
    'Rus': 'МЕСТО РОЖДЕНИЯ',
    'Heb': 'מקום לידה',
    'Spa': 'LUGAR DE NACIMIENTO',
    'Fra': 'LIEU DE NAISSANCE',
  };

  static const _placeHint = {
    'Eng': 'City, Country',
    'Rus': 'Город, Страна',
    'Heb': 'עיר, מדינה',
    'Spa': 'Ciudad, Pais',
    'Fra': 'Ville, Pays',
  };

  static const _calculateLabel = {
    'Eng': 'Create my natal chart',
    'Rus': 'Создать мою натальную карту',
    'Heb': 'יצירת מפת הלידה שלי',
    'Spa': 'Crear mi carta natal',
    'Fra': 'Créer mon thème natal',
  };

  String get _lang => widget.language;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 880),
        child: DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(28),
            boxShadow: const [
              BoxShadow(
                color: Color(0x183A2F61),
                blurRadius: 26,
                offset: Offset(0, 12),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(28),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0x38FFFFFF), Color(0x18DCCBFF)],
                  ),
                  borderRadius: BorderRadius.circular(28),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.32),
                    width: 1,
                  ),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            _introEyebrow[_lang] ?? _introEyebrow['Eng']!,
                            style: const TextStyle(
                              color: Color(0xFF49C8CE),
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 1.1,
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 5,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.14),
                            borderRadius: BorderRadius.circular(999),
                            border: Border.all(
                              color: Colors.white.withOpacity(0.26),
                              width: 1,
                            ),
                          ),
                          child: Text(
                            _quickSteps[_lang] ?? _quickSteps['Eng']!,
                            style: const TextStyle(
                              color: AstroPalette.darkSecondary,
                              fontSize: 11.5,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _introTitle[_lang] ?? _introTitle['Eng']!,
                      style: const TextStyle(
                        color: AstroPalette.darkText,
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        height: 1.1,
                      ),
                    ),
                    const SizedBox(height: 7),
                    Text(
                      _introDescription[_lang] ?? _introDescription['Eng']!,
                      style: const TextStyle(
                        color: AstroPalette.darkSecondary,
                        fontSize: 13.5,
                        fontWeight: FontWeight.w500,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 14),
                    _BirthFieldRow(
                      icon: Icons.calendar_month_rounded,
                      label: _step1Label[_lang] ?? _step1Label['Eng']!,
                      value: _formatDate(),
                      hasValue: _date != null,
                      onTap: _pickDate,
                    ),
                    const SizedBox(height: 12),
                    _BirthFieldRow(
                      icon: Icons.schedule_rounded,
                      label: _step2Label[_lang] ?? _step2Label['Eng']!,
                      value: _formatTime(),
                      hasValue: _time != null,
                      onTap: _pickTime,
                    ),
                    const SizedBox(height: 12),
                    _BirthLocationField(
                      controller: _locationCtrl,
                      label: _placeLabel[_lang] ?? _placeLabel['Eng']!,
                      hintText: _placeHint[_lang] ?? _placeHint['Eng']!,
                      onChanged: (_) => setState(() {}),
                    ),
                    const SizedBox(height: 20),
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
                        height: 54,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(18),
                          gradient: LinearGradient(
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                            colors: _canSubmit
                                ? const [
                                    Color(0xFF63D9D7),
                                    Color(0xFF9C88F2),
                                    Color(0xFFC968C4),
                                  ]
                                : const [
                                    Color(0x8063D9D7),
                                    Color(0x809C88F2),
                                    Color(0x80C968C4),
                                  ],
                          ),
                          boxShadow: const [
                            BoxShadow(
                              color: Color(0x2049C8CE),
                              blurRadius: 16,
                              offset: Offset(0, 7),
                            ),
                            BoxShadow(color: Color(0x16C95AC4), blurRadius: 14),
                          ],
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.auto_awesome_rounded,
                              color: Colors.white,
                              size: 18,
                            ),
                            const SizedBox(width: 9),
                            Text(
                              _calculateLabel[_lang] ?? _calculateLabel['Eng']!,
                              style: const TextStyle(
                                color: AstroPalette.darkText,
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
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
    final iconColor = icon == Icons.calendar_month_rounded
        ? const Color(0xFF49C8CE)
        : const Color(0xFF9C88F2);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 74,
        padding: const EdgeInsets.symmetric(horizontal: 14),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xB8FFFFFF), Color(0x96EEE7FF)],
          ),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: hasValue
                ? const Color(0xFF49C8CE).withOpacity(0.45)
                : Colors.white.withOpacity(0.48),
            width: 1,
          ),
          boxShadow: const [
            BoxShadow(
              color: Color(0x12382A62),
              blurRadius: 16,
              offset: Offset(0, 7),
            ),
          ],
        ),
        child: Row(
          children: [
            _StepIconBubble(icon, iconColor: iconColor),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: const TextStyle(
                      color: Color(0xFF7E719F),
                      fontSize: 10.5,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.7,
                    ),
                  ),
                  const SizedBox(height: 7),
                  Text(
                    value,
                    style: const TextStyle(
                      color: Color(0xFF30254F),
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            if (hasValue) ...[
              const Icon(
                Icons.check_circle_rounded,
                size: 16,
                color: Color(0xFF49C8CE),
              ),
              const SizedBox(width: 6),
            ],
            const Icon(
              Icons.chevron_right_rounded,
              color: Color(0xFF8E80AD),
              size: 18,
            ),
          ],
        ),
      ),
    );
  }
}

class _BirthLocationField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String hintText;
  final ValueChanged<String> onChanged;

  const _BirthLocationField({
    required this.controller,
    required this.label,
    required this.hintText,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final hasValue = controller.text.isNotEmpty;

    return Container(
      height: 74,
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xB8FFFFFF), Color(0x96EEE7FF)],
        ),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: hasValue
              ? const Color(0xFF49C8CE).withOpacity(0.45)
              : Colors.white.withOpacity(0.48),
          width: 1,
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x12382A62),
            blurRadius: 16,
            offset: Offset(0, 7),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const _StepIconBubble(
            Icons.location_on_rounded,
            iconColor: Color(0xFFC95AC4),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    color: Color(0xFF7E719F),
                    fontSize: 10.5,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.7,
                  ),
                ),
                const SizedBox(height: 7),
                TextField(
                  controller: controller,
                  onChanged: onChanged,
                  style: const TextStyle(
                    color: Color(0xFF30254F),
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    hintText: hintText,
                    hintStyle: const TextStyle(
                      color: Color(0xFF9184AE),
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                    isDense: true,
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
              ],
            ),
          ),
          if (hasValue) ...[
            const Icon(
              Icons.check_circle_rounded,
              size: 16,
              color: Color(0xFF49C8CE),
            ),
            const SizedBox(width: 6),
          ],
          const Icon(
            Icons.chevron_right_rounded,
            color: Color(0xFF8E80AD),
            size: 18,
          ),
        ],
      ),
    );
  }
}

class _StepIconBubble extends StatelessWidget {
  final IconData icon;
  final Color iconColor;

  const _StepIconBubble(this.icon, {required this.iconColor});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 38,
      height: 38,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFAEEFED), Color(0xFFDCCBFF)],
        ),
        border: Border.all(color: Colors.white.withOpacity(0.65)),
      ),
      child: Icon(icon, size: 18, color: iconColor),
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
        Positioned.fill(
          child: Container(
            decoration: const BoxDecoration(gradient: AstroPalette.heroOverlay),
          ),
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
        boxShadow: [BoxShadow(color: color, blurRadius: 70, spreadRadius: 18)],
      ),
    );
  }
}

// ── Natal chart loading animation ──────────────────────────────────────────

class _ChartLoadingAnimation extends StatefulWidget {
  final String language;

  const _ChartLoadingAnimation({required this.language});
  @override
  State<_ChartLoadingAnimation> createState() => _ChartLoadingAnimationState();
}

class _ChartLoadingAnimationState extends State<_ChartLoadingAnimation> {
  late VideoPlayerController _ctrl;
  bool _initialized = false;
  int _factIndex = 0;
  Timer? _factTimer;

  static const _sunFacts = {
    'Eng': [
      'Sun in Aries brings energy, confidence, and leadership.',
      'Sun in Taurus emphasizes stability, practicality, and comfort.',
      'Sun in Gemini highlights communication, curiosity, and adaptability.',
      'Sun in Cancer focuses on emotional security, home, and care.',
      'Sun in Leo brings creativity, confidence, and self-expression.',
      'Sun in Virgo emphasizes detail, service, and practical improvement.',
      'Sun in Libra focuses on relationships, balance, and harmony.',
      'Sun in Scorpio brings intensity, depth, and transformation.',
      'Sun in Sagittarius brings optimism, freedom, and broad horizons.',
      'Sun in Capricorn emphasizes discipline, ambition, and long-term goals.',
      'Sun in Aquarius highlights innovation, independence, and social vision.',
      'Sun in Pisces brings compassion, intuition, and spiritual depth.',
    ],
    'Rus': [
      'Солнце в Овне раскрывает силу действия и лидерства.',
      'Солнце в Тельце усиливает устойчивость и практичность.',
      'Солнце в Близнецах приносит гибкость мышления и общительность.',
      'Солнце в Раке подчёркивает чувствительность и связь с домом.',
      'Солнце во Льве усиливает творческий свет и уверенность.',
      'Солнце в Деве даёт точность, порядок и полезность.',
      'Солнце в Весах стремится к гармонии и партнёрству.',
      'Солнце в Скорпионе даёт глубину и трансформацию.',
      'Солнце в Стрельце несёт свободу, смысл и оптимизм.',
      'Солнце в Козероге усиливает дисциплину и стратегичность.',
      'Солнце в Водолее подчёркивает независимость и новаторство.',
      'Солнце в Рыбах усиливает интуицию и сострадание.',
    ],
    'Heb': [
      'שמש בטלה מביאה אנרגיה, אומץ ורצון להוביל.',
      'שמש בשור מדגישה יציבות, מעשיות ונאמנות.',
      'שמש בתאומים מביאה סקרנות, תקשורת וגמישות.',
      'שמש בסרטן מחזקת רגישות, חמלה וחיבור לבית.',
      'שמש באריה מדגישה ביטחון, יצירתיות וביטוי עצמי.',
      'שמש בבתולה מביאה דיוק, סדר ושירות.',
      'שמש במאזניים שואפת להרמוניה ואיזון ביחסים.',
      'שמש בעקרב מביאה עומק, עוצמה והתחדשות.',
      'שמש בקשת מדגישה חופש, חוכמה ואמת.',
      'שמש בגדי מחזקת משמעת, אחריות והישגיות.',
      'שמש בדלי מביאה חדשנות וחשיבה קהילתית.',
      'שמש בדגים מדגישה חמלה, השראה ורוחניות.',
    ],
  };

  static const _factTitle = {
    'Eng': 'Sun Facts While We Build Your Chart',
    'Rus': 'Факты о Солнце, пока строится карта',
    'Heb': 'עובדות על השמש בזמן בניית המפה',
    'Spa': 'Datos del Sol mientras se construye tu carta',
  };

  List<String> get _facts => _sunFacts[widget.language] ?? _sunFacts['Eng']!;

  String get _title => _factTitle[widget.language] ?? _factTitle['Eng']!;

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

    _factTimer = Timer.periodic(const Duration(seconds: 4), (_) {
      if (!mounted || _facts.isEmpty) return;
      setState(() {
        _factIndex = (_factIndex + 1) % _facts.length;
      });
    });
  }

  @override
  void dispose() {
    _factTimer?.cancel();
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final facts = _facts;
    final fact = facts.isEmpty ? '' : facts[_factIndex % facts.length];

    return Column(
      children: [
        _initialized
            ? AspectRatio(
                aspectRatio: _ctrl.value.aspectRatio,
                child: VideoPlayer(_ctrl),
              )
            : const SizedBox(
                height: 300,
                child: Center(
                  child: CircularProgressIndicator(
                    color: AstroPalette.accentMagenta,
                    strokeWidth: 2,
                  ),
                ),
              ),
        const SizedBox(height: 14),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: AstroPalette.darkGlassFill,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AstroPalette.glassBorder),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _title,
                style: const TextStyle(
                  color: AstroPalette.darkText,
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 8),
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 280),
                child: Text(
                  fact,
                  key: ValueKey<String>(fact),
                  style: const TextStyle(
                    color: AstroPalette.darkSecondary,
                    fontSize: 13,
                    height: 1.4,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
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
    (r: 40.0, s: 1.0, sz: 9.0, c: Color(0xFFD45BFF), a: 0.0),
    (r: 62.0, s: 1.55, sz: 7.0, c: Color(0xFFD6C0FF), a: 1.2),
    (r: 82.0, s: 2.1, sz: 6.0, c: Color(0xFF58D5D0), a: 2.5),
    (r: 100.0, s: 0.65, sz: 8.0, c: Color(0xFFF1B3FF), a: 0.8),
    (r: 118.0, s: 1.85, sz: 6.0, c: Color(0xFF7EE7E1), a: 3.9),
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
          ..color = const Color(0xFFD6C0FF).withOpacity(0.20)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 0.8,
      );
    }

    // Sun glow
    canvas.drawCircle(
      Offset(cx, cy),
      18 + 5 * pulse,
      Paint()
        ..color = const Color(0xFFE96DFF).withOpacity(0.15 + 0.15 * pulse)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 18),
    );
    // Sun
    canvas.drawCircle(
      Offset(cx, cy),
      12,
      Paint()..color = const Color(0xFFDCCBFF),
    );
    canvas.drawCircle(
      Offset(cx, cy),
      12,
      Paint()
        ..color = const Color(0xFF58D5D0).withOpacity(0.5)
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
