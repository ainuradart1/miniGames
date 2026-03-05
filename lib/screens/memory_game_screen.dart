import 'dart:async';
import 'package:flutter/material.dart';
import '../services/records_service.dart';
import 'result_screen.dart';

class MemoryGameScreen extends StatefulWidget {
  const MemoryGameScreen({super.key});

  @override
  State<MemoryGameScreen> createState() => _MemoryGameScreenState();
}

class _MemoryCard {
  final String emoji;
  bool isFlipped;
  bool isMatched;
  _MemoryCard({required this.emoji, this.isFlipped = false, this.isMatched = false});
}

class _MemoryGameScreenState extends State<MemoryGameScreen> {
  static const String gameKey = 'memory_game';
  final List<String> _emojis = ['🍎', '🌟', '🎸', '🦊', '🍕', '🚀', '🎯', '🌈'];

  List<_MemoryCard> _cards = [];
  List<int> _flipped = [];
  int _moves = 0;
  int _matches = 0;
  bool _waiting = false;
  late Stopwatch _stopwatch;
  Timer? _uiTimer;
  int _elapsed = 0;

  @override
  void initState() { super.initState(); _initGame(); }

  void _initGame() {
    final pairs = [..._emojis, ..._emojis];
    pairs.shuffle();
    _cards = pairs.map((e) => _MemoryCard(emoji: e)).toList();
    _flipped = []; _moves = 0; _matches = 0; _waiting = false;
    _stopwatch = Stopwatch()..start();
    _uiTimer?.cancel();
    _uiTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      setState(() => _elapsed = _stopwatch.elapsed.inSeconds);
    });
  }

  void _onCardTap(int index) {
    if (_waiting || _cards[index].isFlipped || _cards[index].isMatched) return;
    if (_flipped.length >= 2) return;
    setState(() { _cards[index].isFlipped = true; _flipped.add(index); });
    if (_flipped.length == 2) { _moves++; _checkMatch(); }
  }

  void _checkMatch() {
    final a = _flipped[0], b = _flipped[1];
    if (_cards[a].emoji == _cards[b].emoji) {
      setState(() {
        _cards[a].isMatched = true; _cards[b].isMatched = true;
        _matches++; _flipped = [];
      });
      if (_matches == _emojis.length) _finishGame();
    } else {
      _waiting = true;
      Future.delayed(const Duration(milliseconds: 900), () {
        setState(() {
          _cards[a].isFlipped = false; _cards[b].isFlipped = false;
          _flipped = []; _waiting = false;
        });
      });
    }
  }

  void _finishGame() async {
    _stopwatch.stop(); _uiTimer?.cancel();
    final score = (_moves <= 0) ? 1000 : (1000 - _moves * 10).clamp(0, 1000);
    await RecordsService.saveRecord(gameKey, score);
    final record = await RecordsService.getRecord(gameKey);
    if (!mounted) return;
    Navigator.pushReplacement(context, MaterialPageRoute(
      builder: (_) => ResultScreen(
        gameName: '🃏 Игра на память', score: _moves, record: record,
        scoreLabel: 'Ходов сделано',
        extraInfo: 'Время: ${_stopwatch.elapsed.inSeconds} сек',
        lowerIsBetter: true,
        onRestart: () => Navigator.pushReplacement(context,
            MaterialPageRoute(builder: (_) => const MemoryGameScreen())),
      ),
    ));
  }

  @override
  void dispose() { _stopwatch.stop(); _uiTimer?.cancel(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft, end: Alignment.bottomRight,
            colors: [Color(0xFF1a1a2e), Color(0xFF0d3b2e)],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(icon: const Icon(Icons.close, color: Colors.white),
                        onPressed: () { _stopwatch.stop(); _uiTimer?.cancel(); Navigator.pop(context); }),
                    const Text('🃏 Игра на память', style: TextStyle(
                        color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                    IconButton(icon: const Icon(Icons.refresh, color: Colors.white),
                        onPressed: () => setState(_initGame)),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _StatChip(label: 'Ходы', value: '$_moves', color: const Color(0xFF43D9AD)),
                    _StatChip(label: 'Пары', value: '$_matches/${_emojis.length}', color: const Color(0xFF43D9AD)),
                    _StatChip(label: 'Время', value: '${_elapsed}с', color: const Color(0xFF43D9AD)),
                  ],
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: GridView.builder(
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 4, mainAxisSpacing: 8, crossAxisSpacing: 8),
                    itemCount: _cards.length,
                    itemBuilder: (ctx, i) {
                      final card = _cards[i];
                      return GestureDetector(
                        onTap: () => _onCardTap(i),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          decoration: BoxDecoration(
                            color: card.isMatched
                                ? const Color(0xFF43D9AD).withValues(alpha: 0.3)
                                : card.isFlipped
                                    ? Colors.white.withValues(alpha: 0.15)
                                    : const Color(0xFF43D9AD).withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: card.isMatched
                                  ? const Color(0xFF43D9AD)
                                  : const Color(0xFF43D9AD).withValues(alpha: 0.3),
                              width: 1.5,
                            ),
                          ),
                          child: Center(
                            child: card.isFlipped || card.isMatched
                                ? Text(card.emoji, style: const TextStyle(fontSize: 32))
                                : const Text('❓', style: TextStyle(fontSize: 28)),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  const _StatChip({required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Column(children: [
        Text(value, style: TextStyle(color: color, fontSize: 20, fontWeight: FontWeight.bold)),
        Text(label, style: const TextStyle(color: Colors.white60, fontSize: 12)),
      ]),
    );
  }
}
