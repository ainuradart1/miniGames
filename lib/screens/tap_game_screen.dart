import 'dart:async';
import 'package:flutter/material.dart';
import '../services/records_service.dart';
import 'result_screen.dart';

class TapGameScreen extends StatefulWidget {
  const TapGameScreen({super.key});

  @override
  State<TapGameScreen> createState() => _TapGameScreenState();
}

class _TapGameScreenState extends State<TapGameScreen>
    with SingleTickerProviderStateMixin {
  static const String gameKey = 'tap_game';
  static const int gameDuration = 15;

  int _taps = 0;
  int _timeLeft = gameDuration;
  bool _started = false;
  bool _finished = false;
  Timer? _timer;
  late AnimationController _animController;
  late Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 80));
    _scaleAnim = Tween<double>(begin: 1.0, end: 0.88).animate(
        CurvedAnimation(parent: _animController, curve: Curves.easeInOut));
  }

  void _startGame() {
    setState(() => _started = true);
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (_timeLeft <= 1) { t.cancel(); _finishGame(); }
      else { setState(() => _timeLeft--); }
    });
  }

  void _onTap() {
    if (_finished) return;
    if (!_started) _startGame();
    _animController.forward().then((_) => _animController.reverse());
    setState(() => _taps++);
  }

  void _finishGame() async {
    setState(() => _finished = true);
    await RecordsService.saveRecord(gameKey, _taps);
    final record = await RecordsService.getRecord(gameKey);
    if (!mounted) return;
    Navigator.pushReplacement(context, MaterialPageRoute(
      builder: (_) => ResultScreen(
        gameName: '👆 Тап-игра',
        score: _taps,
        record: record,
        scoreLabel: 'Тапов за 15 секунд',
        onRestart: () => Navigator.pushReplacement(context,
            MaterialPageRoute(builder: (_) => const TapGameScreen())),
      ),
    ));
  }

  @override
  void dispose() { _timer?.cancel(); _animController.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft, end: Alignment.bottomRight,
            colors: [Color(0xFF1a1a2e), Color(0xFF3d0c2e)],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(icon: const Icon(Icons.close, color: Colors.white),
                        onPressed: () { _timer?.cancel(); Navigator.pop(context); }),
                    const Text('👆 Тап-игра', style: TextStyle(
                        color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                    const SizedBox(width: 48),
                  ],
                ),
                const SizedBox(height: 30),
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: const Color(0xFFFF6584).withOpacity(0.15),
                    border: Border.all(color: const Color(0xFFFF6584).withOpacity(0.5), width: 3),
                  ),
                  child: Column(children: [
                    Text('$_timeLeft', style: TextStyle(fontSize: 60,
                        fontWeight: FontWeight.bold,
                        color: _timeLeft <= 5 ? Colors.red : Colors.white)),
                    const Text('сек', style: TextStyle(color: Colors.white60, fontSize: 16)),
                  ]),
                ),
                const SizedBox(height: 20),
                Text('$_taps', style: const TextStyle(
                    fontSize: 72, fontWeight: FontWeight.bold, color: Color(0xFFFF6584))),
                const Text('тапов', style: TextStyle(color: Colors.white60, fontSize: 18)),
                const Spacer(),
                AnimatedBuilder(
                  animation: _scaleAnim,
                  builder: (ctx, child) => Transform.scale(scale: _scaleAnim.value, child: child),
                  child: GestureDetector(
                    onTapDown: (_) => _onTap(),
                    child: Container(
                      width: 220, height: 220,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: RadialGradient(colors: [
                          const Color(0xFFFF6584),
                          const Color(0xFFFF6584).withOpacity(0.6),
                        ]),
                        boxShadow: [BoxShadow(
                            color: const Color(0xFFFF6584).withOpacity(0.4),
                            blurRadius: 30, spreadRadius: 10)],
                      ),
                      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                        const Text('👆', style: TextStyle(fontSize: 60)),
                        Text(_started ? 'ТАП!' : 'СТАРТ', style: const TextStyle(
                            color: Colors.white, fontSize: 24,
                            fontWeight: FontWeight.bold, letterSpacing: 2)),
                      ]),
                    ),
                  ),
                ),
                const SizedBox(height: 40),
                if (!_started)
                  Text('Нажми кнопку, чтобы начать!',
                      style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 14)),
                const SizedBox(height: 30),
              ],
            ),
          ),
        ),
      ),
    );
  }
}