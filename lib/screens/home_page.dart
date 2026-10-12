import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'chat_page.dart';
import 'chart_page.dart';
import '../services/api_service.dart';
import '../theme/astro_palette.dart';

const _turquoise1 = Color(0xFF7EE7E1);
const _turquoise2 = Color(0xFF58D5D0);
const _turquoise3 = Color(0xFF3FC6D4);
const _magenta1 = Color(0xFFFF7AD9);
const _magenta2 = Color(0xFFE96DFF);
const _magenta3 = Color(0xFFD45BFF);
const _accentTurquoiseSoft = Color(0xFFAEEFED);
const _accentMagentaSoft = Color(0xFFF1B3FF);
const _silver1 = Color(0xFFF3F2F7);
const _silver2 = Color(0xFFD8D7E2);
const _silver3 = Color(0xFFBBB9C9);

const _turquoiseGradient = LinearGradient(
  colors: [
    Color(0xFFAEEFED),
    Color(0xFFDCCBFF),
  ],
);

const _magentaGradient = LinearGradient(
  colors: [
    Color(0xFFF1B3FF),
    Color(0xFFD6C0FF),
  ],
);

const _cosmicAccentGradient = LinearGradient(
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
  colors: [
    Color(0xFF6FE3E1),
    Color(0xFFE96DFF),
  ],
);

const _silverGradient = LinearGradient(
  colors: [
    Color(0xFFF4F3F8),
    Color(0xFFD4D2DE),
  ],
);

class AstroHomePage extends StatefulWidget {
  const AstroHomePage({super.key});

  @override
  State<AstroHomePage> createState() => _AstroHomePageState();
}

class _AstroHomePageState extends State<AstroHomePage> {
  DailyEnergyResponse? _energy;
  final List<TransitItem> _transits = [];
  String _language = 'Eng';

  String _t(String key) {
    const copy = {
      'Eng': {
        'greeting': 'Good morning ✨',
        'upcomingTransits': 'Upcoming Transits',
        'viewAll': 'View all',
        'todayEnergy': "Today's Energy",
        'live': 'LIVE',
        'defaultHeadline': 'A day for clarity\nand new beginnings',
        'energyPhasePrefix': 'Action phase: Moon in',
        'defaultDescription':
            'The Moon in Aquarius brings fresh ideas and inspiration.',
        'fallbackTransit1Title': 'Moon Trine Mercury',
        'fallbackTransit1Subtitle':
            'Good time for communication and sharing ideas.',
        'fallbackTransit2Title': 'Venus Square Mars',
        'fallbackTransit2Subtitle': 'Watch for emotional intensity.',
        'home': 'Home',
        'chart': 'Chart',
        'insights': 'Insights',
        'profile': 'Profile',
      },
      'Rus': {
        'greeting': 'Доброе утро ✨',
        'upcomingTransits': 'Ближайшие транзиты',
        'viewAll': 'Смотреть все',
        'todayEnergy': 'Энергия дня',
        'live': 'LIVE',
        'defaultHeadline': 'День ясности\nи новых начинаний',
        'energyPhasePrefix': 'Фаза действия: Луна в',
        'defaultDescription':
            'Луна в Водолее приносит свежие идеи и вдохновение.',
        'fallbackTransit1Title': 'Луна тригон Меркурий',
        'fallbackTransit1Subtitle': 'Хорошее время для общения и обмена идеями.',
        'fallbackTransit2Title': 'Венера квадрат Марс',
        'fallbackTransit2Subtitle': 'Следите за эмоциональной напряженностью.',
        'home': 'Главная',
        'chart': 'Карта',
        'insights': 'Инсайты',
        'profile': 'Профиль',
      },
      'Heb': {
        'greeting': 'בוקר טוב ✨',
        'upcomingTransits': 'מעברים קרובים',
        'viewAll': 'לצפייה בהכל',
        'todayEnergy': 'אנרגיית היום',
        'live': 'LIVE',
        'defaultHeadline': 'יום של בהירות\nוהתחלות חדשות',
        'energyPhasePrefix': 'שלב פעולה: הירח ב',
        'defaultDescription': 'הירח בדלי מביא רעיונות רעננים והשראה.',
        'fallbackTransit1Title': 'ירח טריין מרקורי',
        'fallbackTransit1Subtitle': 'זמן טוב לתקשורת ולשיתוף רעיונות.',
        'fallbackTransit2Title': 'ונוס סקוור מרס',
        'fallbackTransit2Subtitle': 'שימו לב למתח רגשי.',
        'home': 'בית',
        'chart': 'מפה',
        'insights': 'תובנות',
        'profile': 'פרופיל',
      },
      'Spa': {
        'greeting': 'Buenos dias ✨',
        'upcomingTransits': 'Transitos proximos',
        'viewAll': 'Ver todo',
        'todayEnergy': 'Energia de hoy',
        'live': 'LIVE',
        'defaultHeadline': 'Un dia de claridad\ny nuevos comienzos',
        'energyPhasePrefix': 'Fase de accion: Luna en',
        'defaultDescription':
            'La Luna en Acuario trae ideas frescas e inspiracion.',
        'fallbackTransit1Title': 'Luna trigono Mercurio',
        'fallbackTransit1Subtitle':
            'Buen momento para comunicar y compartir ideas.',
        'fallbackTransit2Title': 'Venus cuadratura Marte',
        'fallbackTransit2Subtitle':
            'Atencion a la intensidad emocional.',
        'home': 'Inicio',
        'chart': 'Carta',
        'insights': 'Insights',
        'profile': 'Perfil',
      },
      'Fra': {
        'greeting': 'Bonjour ✨',
        'upcomingTransits': 'Transits à venir',
        'viewAll': 'Voir tout',
        'todayEnergy': 'Énergie du jour',
        'live': 'DIRECT',
        'defaultHeadline': 'Une journée de clarté\net de nouveaux départs',
        'energyPhasePrefix': 'Phase d’action : Lune en',
        'defaultDescription':
            'La Lune en Verseau apporte des idées nouvelles et de l’inspiration.',
        'fallbackTransit1Title': 'Lune trigone Mercure',
        'fallbackTransit1Subtitle':
            'Un bon moment pour communiquer et partager vos idées.',
        'fallbackTransit2Title': 'Vénus carré Mars',
        'fallbackTransit2Subtitle':
            'Restez attentif aux tensions émotionnelles.',
        'home': 'Accueil',
        'chart': 'Carte',
        'insights': 'Éclairages',
        'profile': 'Profil',
      },
    };

    return copy[_language]?[key] ?? copy['Eng']![key] ?? key;
  }

  String _signName(String sign) {
    final normalized = _normalizeSign(sign);
    const signs = {
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
        'Aries': 'Овне',
        'Taurus': 'Тельце',
        'Gemini': 'Близнецах',
        'Cancer': 'Раке',
        'Leo': 'Льве',
        'Virgo': 'Деве',
        'Libra': 'Весах',
        'Scorpio': 'Скорпионе',
        'Sagittarius': 'Стрельце',
        'Capricorn': 'Козероге',
        'Aquarius': 'Водолее',
        'Pisces': 'Рыбах',
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
        'Gemini': 'Geminis',
        'Cancer': 'Cancer',
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

    return signs[_language]?[normalized] ??
        signs['Eng']![normalized] ??
        normalized;
  }

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

  String _normalizeAstroTypos(String text) {
    return text
        .replaceAll(RegExp(r'\bSagitarius\b', caseSensitive: false), 'Sagittarius')
        .replaceAll(RegExp(r'\bSagitarrius\b', caseSensitive: false), 'Sagittarius');
  }

  String _extractMoonSign(DailyEnergyResponse energy) {
    final direct = _normalizeSign(energy.moonSign);
    if (direct.isNotEmpty) return direct;

    final headline = _normalizeAstroTypos(energy.headline);
    final m = RegExp(
      r'(?:Moon\s+in|in)\s+([A-Za-z]+)\b',
      caseSensitive: false,
    ).firstMatch(headline);
    if (m != null) {
      return _normalizeSign(m.group(1) ?? '');
    }
    return '';
  }

  String _phaseName(String phase) {
    const phases = {
      'Eng': {
        'New Moon': 'New Moon',
        'Waxing Crescent': 'Waxing Crescent',
        'First Quarter': 'First Quarter',
        'Waxing Gibbous': 'Waxing Gibbous',
        'Full Moon': 'Full Moon',
        'Waning Gibbous': 'Waning Gibbous',
        'Last Quarter': 'Last Quarter',
        'Waning Crescent': 'Waning Crescent',
      },
      'Rus': {
        'New Moon': 'Новолуние',
        'Waxing Crescent': 'Растущий серп',
        'First Quarter': 'Первая четверть',
        'Waxing Gibbous': 'Растущая луна',
        'Full Moon': 'Полнолуние',
        'Waning Gibbous': 'Убывающая луна',
        'Last Quarter': 'Последняя четверть',
        'Waning Crescent': 'Убывающий серп',
      },
      'Heb': {
        'New Moon': 'מולד הירח',
        'Waxing Crescent': 'סהר מתמלא',
        'First Quarter': 'רבע ראשון',
        'Waxing Gibbous': 'ירח מתמלא',
        'Full Moon': 'ירח מלא',
        'Waning Gibbous': 'ירח מתמעט',
        'Last Quarter': 'רבע אחרון',
        'Waning Crescent': 'סהר מתמעט',
      },
      'Spa': {
        'New Moon': 'Luna nueva',
        'Waxing Crescent': 'Creciente',
        'First Quarter': 'Cuarto creciente',
        'Waxing Gibbous': 'Gibosa creciente',
        'Full Moon': 'Luna llena',
        'Waning Gibbous': 'Gibosa menguante',
        'Last Quarter': 'Cuarto menguante',
        'Waning Crescent': 'Menguante',
      },
      'Fra': {
        'New Moon': 'Nouvelle Lune',
        'Waxing Crescent': 'Premier croissant',
        'First Quarter': 'Premier quartier',
        'Waxing Gibbous': 'Lune gibbeuse croissante',
        'Full Moon': 'Pleine Lune',
        'Waning Gibbous': 'Lune gibbeuse décroissante',
        'Last Quarter': 'Dernier quartier',
        'Waning Crescent': 'Dernier croissant',
      },
    };

    return phases[_language]?[phase] ?? phases['Eng']![phase] ?? phase;
  }

  String _localizedEnergyHeadline(DailyEnergyResponse energy) {
    final sign = _extractMoonSign(energy);
    if (sign.isNotEmpty) {
      final s = _signName(sign);
      switch (_language) {
        case 'Eng':
          return '${_t('energyPhasePrefix')} $s';
        case 'Rus':
          return '${_t('energyPhasePrefix')} $s';
        case 'Heb':
          return '${_t('energyPhasePrefix')}$s';
        case 'Spa':
          return '${_t('energyPhasePrefix')} $s';
        default:
          return '${_t('energyPhasePrefix')} $s';
      }
    }

    var text = _normalizeAstroTypos(energy.headline);
    const signs = [
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
    const phases = [
      'New Moon',
      'Waxing Crescent',
      'First Quarter',
      'Waxing Gibbous',
      'Full Moon',
      'Waning Gibbous',
      'Last Quarter',
      'Waning Crescent',
    ];
    for (final s in signs) {
      text = text.replaceAll(s, _signName(s));
    }
    for (final p in phases) {
      text = text.replaceAll(p, _phaseName(p));
    }
    return text;
  }

  String _localizedEnergyDescription(DailyEnergyResponse energy) {
    if (_language == 'Eng') return energy.description;

    final m = RegExp(
      r'Sun is in\s+([A-Za-z]+),\s*Moon in\s+([A-Za-z]+)',
      caseSensitive: false,
    ).firstMatch(energy.description);
    if (m != null) {
      final sun = _signName(m.group(1)!);
      final moon = _signName(m.group(2)!);
      switch (_language) {
        case 'Rus':
          return 'Солнце во $sun, Луна в $moon';
        case 'Heb':
          return 'השמש ב$sun, הירח ב$moon';
        case 'Spa':
          return 'Sol en $sun, Luna en $moon';
        case 'Fra':
          return 'Soleil en $sun, Lune en $moon';
        default:
          return energy.description;
      }
    }

    return energy.description;
  }

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final energy = await ApiService.getDailyEnergy(language: _language);
      if (mounted) setState(() => _energy = energy);
    } catch (_) {}
  }

  Future<void> _onLanguageChanged(String lang) async {
    if (lang == _language) return;
    setState(() {
      _language = lang;
      _energy = null;
    });
    await _loadData();
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
              padding: EdgeInsets.fromLTRB(
                20,
                0,
                20,
                MediaQuery.of(context).padding.bottom + 120,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _TopBar(greeting: _t('greeting')),
                  const SizedBox(height: 14),
                  _LanguageSelector(
                    selected: _language,
                    onChanged: _onLanguageChanged,
                  ),
                  const SizedBox(height: 16),
                  _HeroSection(
                    isLoading: _energy == null,
                    language: _language,
                    onStartBirthFlow: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => AstroChartPage(
                          initialLanguage: _language,
                          openBirthDateOnStart: true,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  _TodayEnergyCard(
                    title: _t('todayEnergy'),
                    liveLabel: _t('live'),
                    headline: _energy == null
                        ? _t('defaultHeadline')
                        : _localizedEnergyHeadline(_energy!),
                    description: _energy == null
                        ? _t('defaultDescription')
                        : _localizedEnergyDescription(_energy!),
                  ),
                  const SizedBox(height: 22),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _t('upcomingTransits'),
                        style: const TextStyle(
                          color: AstroPalette.darkTextStrong,
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Text(
                        _t('viewAll'),
                        style: const TextStyle(
                          color: AstroPalette.mutedLabel,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  if (_transits.isEmpty) ...[
                    _TransitCard(
                      icon: Icons.auto_awesome,
                      title: _t('fallbackTransit1Title'),
                      subtitle: _t('fallbackTransit1Subtitle'),
                      time: '2h 34m',
                    ),
                    const SizedBox(height: 12),
                    _TransitCard(
                      icon: Icons.star_rounded,
                      title: _t('fallbackTransit2Title'),
                      subtitle: _t('fallbackTransit2Subtitle'),
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
  final String greeting;
  const _TopBar({required this.greeting});

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
          children: [
            Text(
              greeting,
              style: const TextStyle(
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
  final String language;
  final VoidCallback onStartBirthFlow;

  const _HeroSection({
    required this.isLoading,
    required this.language,
    required this.onStartBirthFlow,
  });

  String get _startButtonText {
    switch (language) {
      case 'Rus':
        return 'Ввести дату рождения';
      case 'Heb':
        return 'להזין תאריך לידה';
      case 'Spa':
        return 'Ingresar fecha de nacimiento';
      case 'Fra':
        return 'Saisir ma date de naissance';
      default:
        return 'Create my birth chart';
    }
  }

  String get _heroTitle {
    switch (language) {
      case 'Rus':
        return 'Знаете свой гороскоп?\nНачните с даты рождения.';
      case 'Heb':
        return 'רוצים להכיר את ההורוסקופ שלכם?\nהתחילו מתאריך הלידה.';
      case 'Spa':
        return 'Conoces tu horoscopo?\nEmpieza con tu fecha de nacimiento.';
      case 'Fra':
        return 'Envie de découvrir votre thème ?\nCommencez par votre naissance.';
      default:
        return 'Know your horoscope?\nStart with your birth details.';
    }
  }

  String get _heroSubtitle {
    switch (language) {
      case 'Rus':
        return 'Введите дату, время и место рождения, чтобы открыть персональную и точную карту.';
      case 'Heb':
        return 'הזינו תאריך, שעה ומקום לידה כדי לפתוח מפה אישית ומדויקת.';
      case 'Spa':
        return 'Ingresa tu fecha, hora y lugar de nacimiento para desbloquear una carta personal y precisa.';
      case 'Fra':
        return 'Indiquez votre date, heure et lieu de naissance pour créer un thème personnel et précis.';
      default:
        return 'Enter your date, time, and place of birth to create a personal natal chart.';
    }
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(30),
      child: ConstrainedBox(
        constraints: const BoxConstraints(
          minHeight: 0,
          maxWidth: 350,
        ),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final compact = constraints.maxWidth < 380;
            return Stack(
              children: [
                Positioned.fill(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Color(0x665B49A4),
                          Color(0x446D5AB8),
                          Color(0x226FE3E0),
                        ],
                      ),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.28),
                        width: 1,
                      ),
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 18,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _heroTitle,
                        style: TextStyle(
                          color: const Color(0xFFF9F5FF),
                          fontSize: 25,
                          fontWeight: FontWeight.w700,
                          height: 1.05,
                          letterSpacing: -0.4,
                          shadows: const [
                            Shadow(
                              color: Color(0x992F2552),
                              blurRadius: 10,
                              offset: Offset(0, 2),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 10),
                      ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 310),
                        child: Text(
                          _heroSubtitle,
                          style: TextStyle(
                            color: const Color(0xFFE9E1F7),
                            fontSize: 13.5,
                            fontWeight: FontWeight.w500,
                            height: 1.4,
                            shadows: const [
                              Shadow(
                                color: Color(0x992F2552),
                                blurRadius: 8,
                                offset: Offset(0, 1),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 14),
                      GestureDetector(
                        onTap: onStartBirthFlow,
                        child: Container(
                          constraints: const BoxConstraints(minWidth: 206),
                          height: 50,
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(18),
                            gradient: const LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                Color(0x66FFFFFF),
                                Color(0x40CFE9F4),
                              ],
                            ),
                            border: Border.all(
                              color: const Color(0x66FFFFFF),
                              width: 1,
                            ),
                            boxShadow: const [
                              BoxShadow(
                                color: Color(0x4458D5D0),
                                blurRadius: 16,
                                spreadRadius: 1,
                                offset: Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 32,
                                height: 32,
                                decoration: const BoxDecoration(
                                  shape: BoxShape.circle,
                                  gradient: LinearGradient(
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                    colors: [
                                      Color(0xFFAEEFED),
                                      Color(0xFFDCCBFF),
                                    ],
                                  ),
                                ),
                                child: const Icon(
                                  Icons.auto_awesome_rounded,
                                  size: 17,
                                  color: Color(0xFF45C8CF),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Flexible(
                                child: Text(
                                  _startButtonText,
                                  style: const TextStyle(
                                    color: Color(0xFF392B5C),
                                    fontSize: 15,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 10),
                              const Icon(
                                Icons.arrow_forward_rounded,
                                size: 17,
                                color: Color(0xFFC65FC5),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _TodayEnergyCard extends StatelessWidget {
  final String title;
  final String liveLabel;
  final String headline;
  final String description;

  const _TodayEnergyCard({
    required this.title,
    required this.liveLabel,
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
                Row(
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                            color: AstroPalette.mutedLabel,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(width: 8),
                    _LiveBadge(label: liveLabel),
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
              gradient: _cosmicAccentGradient,
              border: Border.all(color: _magenta2.withOpacity(0.45), width: 1.0),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x22E96DFF),
                  blurRadius: 22,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: const Icon(
              Icons.waves_rounded,
              size: 42,
              color: Colors.white,
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
              gradient: _turquoiseGradient,
              border: Border.all(color: _turquoise1.withOpacity(0.7), width: 1.0),
            ),
            child: Icon(icon, color: _turquoise3),
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
                  color: AstroPalette.mutedLabel,
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
  final String language;

  const _AskBotCard({required this.language});

  String get _cardText {
    switch (language) {
      case 'Heb':
        return 'שאלו את אסטרייה על אהבה, מעברים, כסף או מצב הרוח של היום.';
      case 'Rus':
        return 'Спросите Астрею о любви, транзитах, деньгах или настроении дня.';
      case 'Spa':
        return 'Pregunta a Astreya sobre amor, transitos, dinero o el estado del dia.';
      default:
        return "Ask Astreya about love, transits, money, or today's mood.";
    }
  }

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
              gradient: _cosmicAccentGradient,
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
          Expanded(
            child: Text(
              _cardText,
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
                builder: (_) => AstroChatPage(language: language),
              ),
            ),
            child: Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AstroPalette.lightGlassFill,
                border: Border.all(color: _turquoise1.withOpacity(0.7), width: 1.0),
              ),
              child: const Icon(
                Icons.arrow_forward_rounded,
                color: _magenta2,
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

  String _label(String key) {
    const copy = {
      'Eng': {
        'home': 'Home',
        'chart': 'Chart',
        'insights': 'Insights',
        'profile': 'Profile',
      },
      'Rus': {
        'home': 'Главная',
        'chart': 'Карта',
        'insights': 'Инсайты',
        'profile': 'Профиль',
      },
      'Heb': {
        'home': 'בית',
        'chart': 'מפה',
        'insights': 'תובנות',
        'profile': 'פרופיל',
      },
      'Spa': {
        'home': 'Inicio',
        'chart': 'Carta',
        'insights': 'Insights',
        'profile': 'Perfil',
      },
      'Fra': {
        'home': 'Accueil',
        'chart': 'Carte',
        'insights': 'Éclairages',
        'profile': 'Profil',
      },
    };

    return copy[language]?[key] ?? copy['Eng']![key] ?? key;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 10),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
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
          _BottomNavItem(icon: Icons.home_rounded, label: _label('home'), active: true),
          GestureDetector(
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => AstroChartPage(initialLanguage: language)),
            ),
            child: _BottomNavItem(icon: Icons.blur_circular_rounded, label: _label('chart')),
          ),
          _BottomNavItem(icon: Icons.auto_awesome_rounded, label: _label('insights')),
          _BottomNavItem(icon: Icons.person_outline_rounded, label: _label('profile')),
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
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: active ? _cosmicAccentGradient : null,
            color: active ? null : Colors.transparent,
            border: Border.all(
              color: active ? _magenta2.withOpacity(0.35) : Colors.transparent,
              width: active ? 1.0 : 0,
            ),
            boxShadow: active
                ? const [
                    BoxShadow(
                      color: Color(0x33E96DFF),
                      blurRadius: 12,
                      spreadRadius: 1,
                    ),
                  ]
                : const [],
          ),
          child: Icon(
            icon,
            size: 22,
            color: active ? AstroPalette.accentStrong : AstroPalette.mutedLabel,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: TextStyle(
            color: active ? AstroPalette.accentStrong : AstroPalette.mutedLabel,
            fontSize: 11,
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
        gradient: _magentaGradient,
        border: Border.all(color: _magenta2.withOpacity(0.32), width: 0.9),
        boxShadow: const [
          BoxShadow(
            color: Color(0x22E96DFF),
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Icon(icon, color: Colors.white),
    );
  }
}

class _LiveBadge extends StatelessWidget {
  final String label;
  const _LiveBadge({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        gradient: _magentaGradient,
        border: Border.all(color: _magenta2.withOpacity(0.35), width: 0.8),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: AstroPalette.darkText,
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
              color: _silver2.withOpacity(0.8),
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
              child: Container(
                decoration: const BoxDecoration(gradient: AstroPalette.heroOverlay),
              ),
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
        Positioned(
          top: 200,
          right: 28,
          child: Container(
            width: 18,
            height: 18,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: _silver1.withOpacity(0.45),
              border: Border.all(color: _silver3.withOpacity(0.8), width: 0.8),
            ),
          ),
        ),
        Positioned(
          top: 240,
          right: 54,
          child: Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: _magenta1.withOpacity(0.65),
            ),
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
    final silverGlow = Paint()..color = _silver1.withOpacity(0.24);
    final accentGlow = Paint()..color = _accentMagentaSoft.withOpacity(0.34);

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
      canvas.drawCircle(star, 4.0, silverGlow);
    }

    // A few colored sparkles for a restrained premium celestial accent.
    final accentStars = <Offset>[
      Offset(size.width * 0.20, size.height * 0.14),
      Offset(size.width * 0.78, size.height * 0.18),
      Offset(size.width * 0.44, size.height * 0.27),
      Offset(size.width * 0.64, size.height * 0.74),
      Offset(size.width * 0.84, size.height * 0.58),
    ];
    for (var i = 0; i < accentStars.length; i++) {
      final star = accentStars[i];
      final accentColor = i.isEven ? _magenta2 : _turquoise2;
      canvas.drawCircle(star, 2.2, Paint()..color = accentColor.withOpacity(0.84));
      canvas.drawCircle(star, 5.2, accentGlow);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _TopOrbitPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()
      ..color = _silver2.withOpacity(0.75)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;

    final pAccent = Paint()
      ..shader = _cosmicAccentGradient.createShader(
        Rect.fromLTWH(0, 0, size.width, size.height),
      )
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

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

    final zodiacRect = Rect.fromCenter(
      center: Offset(size.width * 0.65, size.height * 0.55),
      width: size.width * 0.82,
      height: size.height * 0.60,
    );
    canvas.drawArc(zodiacRect, 0.7, 0.42, false, pAccent);
    canvas.drawArc(zodiacRect, 2.2, 0.36, false, pAccent);
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
      {'code': 'Heb', 'label': 'עברית'},
      {'code': 'Spa', 'label': 'ES'},
      {'code': 'Fra', 'label': 'FR'},
    ];
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: langs.map((l) {
        final code = l['code']!;
        final isSelected = selected == code;
        return Padding(
          padding: EdgeInsets.zero,
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
                gradient: isSelected ? AstroPalette.premiumAccentSurface : null,
                border: Border.all(
                  color: isSelected
                      ? AstroPalette.glassBorder
                      : AstroPalette.glassBorder,
                ),
              ),
              child: Text(
                l['label']!,
                style: TextStyle(
                  color: isSelected
                      ? AstroPalette.darkText
                      : AstroPalette.mutedLabel,
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