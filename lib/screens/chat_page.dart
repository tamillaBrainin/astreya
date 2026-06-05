import 'dart:ui';
import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../theme/astro_palette.dart';

class _ChatMessage {
  final String text;
  final bool isBot;
  _ChatMessage({required this.text, required this.isBot});
}

class AstroChatPage extends StatefulWidget {
  const AstroChatPage({super.key});

  @override
  State<AstroChatPage> createState() => _AstroChatPageState();
}

class _AstroChatPageState extends State<AstroChatPage> {
  final List<_ChatMessage> _messages = [
    _ChatMessage(
      text:
          'Hi! ✨ I am Astreya. I can help you with transits, compatibility, your natal chart, and your daily forecast.',
      isBot: true,
    ),
  ];
  bool _isTyping = false;
  final _controller = TextEditingController();
  final _scrollController = ScrollController();

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _send(String text) async {
    final trimmed = text.trim();
    if (trimmed.isEmpty) return;
    _controller.clear();
    setState(() {
      _messages.add(_ChatMessage(text: trimmed, isBot: false));
      _isTyping = true;
    });
    _scrollToBottom();
    try {
      final reply = await ApiService.sendChatMessage(trimmed);
      if (mounted) {
        setState(() {
          _isTyping = false;
          _messages.add(_ChatMessage(text: reply, isBot: true));
        });
        _scrollToBottom();
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _isTyping = false;
          _messages.add(_ChatMessage(
            text: 'Sorry, something went wrong. Please try again.',
            isBot: true,
          ));
        });
        _scrollToBottom();
      }
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final itemCount = _messages.length + (_isTyping ? 1 : 0) + 2;
    return Scaffold(
      backgroundColor: AstroPalette.appBgTop,
      resizeToAvoidBottomInset: true,
      body: Stack(
        children: [
          const _ChatBackground(),
          SafeArea(
            child: Column(
              children: [
                const Padding(
                  padding: EdgeInsets.fromLTRB(20, 12, 20, 0),
                  child: _ChatTopBar(),
                ),
                const SizedBox(height: 18),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  child: _ChatIntroCard(),
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: ListView.builder(
                    controller: _scrollController,
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
                    itemCount: itemCount,
                    itemBuilder: (context, i) {
                      // index 0 → quick prompts
                      if (i == 0) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: _QuickPromptRow(onTap: _send),
                        );
                      }
                      final msgIndex = i - 1;
                      // last item → spacing
                      if (msgIndex == _messages.length + (_isTyping ? 1 : 0)) {
                        return const SizedBox(height: 8);
                      }
                      // typing indicator
                      if (_isTyping && msgIndex == _messages.length) {
                        return const Padding(
                          padding: EdgeInsets.only(bottom: 12),
                          child: _TypingIndicator(),
                        );
                      }
                      final msg = _messages[msgIndex];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: msg.isBot
                            ? _BotMessage(text: msg.text)
                            : _UserMessage(text: msg.text),
                      );
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 18),
                  child: _ChatInputBar(
                    controller: _controller,
                    onSend: _send,
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

class _ChatTopBar extends StatelessWidget {
  const _ChatTopBar();

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
        const SizedBox(width: 12),
        Container(
          width: 46,
          height: 46,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: const LinearGradient(
              colors: [Color(0xFFF1E6FF), Color(0xFFB493F7)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.white.withOpacity(0.45),
                blurRadius: 16,
                spreadRadius: 1,
              ),
            ],
          ),
          child: const Icon(
            Icons.smart_toy_outlined,
            color: Colors.white,
            size: 24,
          ),
        ),
        const SizedBox(width: 12),
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Astreya',
                style: TextStyle(
                  color: AstroPalette.darkText,
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                ),
              ),
              SizedBox(height: 2),
              Text(
                'AI astrology assistant',
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
          const Icon(
            Icons.more_horiz_rounded,
            color: Color(0xFF6E58C8),
          ),
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
            border: Border.all(
              color: AstroPalette.glassBorder,
            ),
          ),
          child: Center(child: child),
        ),
      ),
    );
  }
}

class _ChatIntroCard extends StatelessWidget {
  const _ChatIntroCard();

  @override
  Widget build(BuildContext context) {
    return _GlassCard(
      borderRadius: 28,
      padding: const EdgeInsets.all(18),
      child: Row(
        children: [
          Container(
            width: 58,
            height: 58,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const LinearGradient(
                colors: [Color(0xFFF1E6FF), Color(0xFFD9C5FF)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.white.withOpacity(0.45),
                  blurRadius: 18,
                  spreadRadius: 1,
                ),
              ],
            ),
            child: const Icon(
              Icons.auto_awesome_rounded,
              color: AstroPalette.accentStrong,
              size: 28,
            ),
          ),
          const SizedBox(width: 14),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'What do you want to know?',
                  style: TextStyle(
                    color: AstroPalette.darkText,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(height: 6),
                Text(
                  'Ask about love, money, transits, compatibility, or your natal chart.',
                  style: TextStyle(
                    color: AstroPalette.darkSecondary,
                    fontSize: 14,
                    height: 1.35,
                    fontWeight: FontWeight.w500,
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

class _BotMessage extends StatelessWidget {
  final String text;

  const _BotMessage({required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: const LinearGradient(
              colors: [Color(0xFFF1E6FF), Color(0xFFB493F7)],
            ),
          ),
          child: const Icon(
            Icons.smart_toy_outlined,
            color: Colors.white,
            size: 20,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _GlassCard(
            borderRadius: 24,
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
            child: Text(
              text,
              style: const TextStyle(
                color: AstroPalette.darkText,
                fontSize: 15,
                height: 1.45,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _UserMessage extends StatelessWidget {
  final String text;

  const _UserMessage({required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Spacer(),
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 270),
          child: Container(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              gradient: const LinearGradient(
                colors: [Color(0xFFE8D7FF), Color(0xFFB493F7)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.white.withOpacity(0.35),
                  blurRadius: 14,
                  spreadRadius: 1,
                ),
              ],
            ),
            child: Text(
              text,
              style: const TextStyle(
                color: AstroPalette.darkText,
                fontSize: 15,
                height: 1.4,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _QuickPromptRow extends StatelessWidget {
  final void Function(String) onTap;
  const _QuickPromptRow({required this.onTap});

  @override
  Widget build(BuildContext context) {
    const prompts = ['Love', 'Career', 'Transits', 'Compatibility'];
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: prompts
          .map(
            (item) => GestureDetector(
              onTap: () => onTap(item),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(999),
                  color: AstroPalette.lightGlassFill,
                  border: Border.all(
                    color: AstroPalette.glassBorder,
                  ),
                ),
                child: Text(
                  item,
                  style: const TextStyle(
                    color: AstroPalette.darkSecondary,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          )
          .toList(),
    );
  }
}

class _TypingIndicator extends StatefulWidget {
  const _TypingIndicator();

  @override
  State<_TypingIndicator> createState() => _TypingIndicatorState();
}

class _TypingIndicatorState extends State<_TypingIndicator>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 38,
          height: 38,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            gradient:
                AstroPalette.activeSurface,
          ),
          child: const Icon(Icons.smart_toy_outlined,
              color: Colors.white, size: 20),
        ),
        const SizedBox(width: 10),
        ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              decoration: BoxDecoration(
                color: AstroPalette.darkGlassFill,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: AstroPalette.glassBorder, width: 1.1),
              ),
              child: AnimatedBuilder(
                animation: _ctrl,
                builder: (_, __) {
                  return Row(
                    mainAxisSize: MainAxisSize.min,
                    children: List.generate(3, (i) {
                      final phase = (_ctrl.value - i * 0.18).clamp(0.0, 1.0);
                      final opacity =
                          (0.5 + 0.5 * (phase < 0.5 ? phase * 2 : (1 - phase) * 2))
                              .clamp(0.3, 1.0);
                      return Padding(
                        padding: EdgeInsets.only(right: i < 2 ? 5 : 0),
                        child: Opacity(
                          opacity: opacity,
                          child: Container(
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: AstroPalette.accentStrong,
                            ),
                          ),
                        ),
                      );
                    }),
                  );
                },
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _ChatInputBar extends StatelessWidget {
  final TextEditingController controller;
  final void Function(String) onSend;

  const _ChatInputBar({required this.controller, required this.onSend});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(28),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
        child: Container(
          padding: const EdgeInsets.fromLTRB(16, 6, 8, 6),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(28),
            color: AstroPalette.darkGlassFill,
            border: Border.all(color: AstroPalette.glassBorder),
          ),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: controller,
                  minLines: 1,
                  maxLines: 4,
                  textCapitalization: TextCapitalization.sentences,
                  style: const TextStyle(
                    color: AstroPalette.darkText,
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                  ),
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    hintText: 'Ask Astreya...',
                    hintStyle: TextStyle(
                      color: AstroPalette.darkSecondary,
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                    ),
                    isDense: true,
                    contentPadding: EdgeInsets.symmetric(vertical: 10),
                  ),
                  onSubmitted: onSend,
                ),
              ),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: () => onSend(controller.text),
                child: Container(
                  width: 46,
                  height: 46,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [Color(0xFFE8D7FF), Color(0xFFB493F7)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: const Icon(Icons.arrow_upward_rounded,
                      color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _GlassCard extends StatelessWidget {
  final Widget child;
  final EdgeInsets padding;
  final double borderRadius;

  const _GlassCard({
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
                color: AstroPalette.glowWhiteLilac,
                blurRadius: 20,
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

class _ChatBackground extends StatelessWidget {
  const _ChatBackground();

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          decoration: const BoxDecoration(gradient: AstroPalette.appBackground),
        ),
        Positioned.fill(
          child: Image.asset(
            'assets/images/astrobot_bg.png',
            fit: BoxFit.cover,
            opacity: const AlwaysStoppedAnimation(0.10),
          ),
        ),
        Positioned(top: -90, left: -40, child: _glow(240, AstroPalette.glowWhiteLilac)),
        Positioned(top: 120, right: -60, child: _glow(200, AstroPalette.glowLilacBlue)),
        Positioned(bottom: 130, left: -30, child: _glow(180, AstroPalette.glowLilacMint)),
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
