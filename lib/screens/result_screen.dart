import 'package:flutter/material.dart';

class ResultScreen extends StatelessWidget {
  final String gameName;
  final int score;
  final int record;
  final String scoreLabel;
  final String? extraInfo;
  final int? maxScore;
  final bool lowerIsBetter;
  final VoidCallback onRestart;

  const ResultScreen({
    super.key,
    required this.gameName,
    required this.score,
    required this.record,
    required this.scoreLabel,
    required this.onRestart,
    this.extraInfo,
    this.maxScore,
    this.lowerIsBetter = false,
  });

  bool get isNewRecord {
    if (lowerIsBetter) return score <= record || record == 0;
    return score >= record;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter, end: Alignment.bottomCenter,
            colors: [Color(0xFF1a1a2e), Color(0xFF16213e)],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Spacer(),
                Text(isNewRecord ? '🏆' : '🎮', style: const TextStyle(fontSize: 80)),
                const SizedBox(height: 16),
                Text(isNewRecord ? 'Новый рекорд!' : 'Игра окончена!',
                    style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold,
                        color: isNewRecord ? Colors.amber : Colors.white)),
                const SizedBox(height: 8),
                Text(gameName, style: const TextStyle(color: Colors.white60, fontSize: 16)),
                const SizedBox(height: 40),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.white.withOpacity(0.1)),
                  ),
                  child: Column(children: [
                    _ResultRow(label: scoreLabel,
                        value: maxScore != null ? '$score / $maxScore' : '$score',
                        valueColor: Colors.white),
                    if (extraInfo != null) ...[
                      const Divider(color: Colors.white12, height: 24),
                      _ResultRow(label: 'Доп. инфо', value: extraInfo!, valueColor: Colors.white70),
                    ],
                    const Divider(color: Colors.white12, height: 24),
                    _ResultRow(label: '🏆 Рекорд',
                        value: lowerIsBetter
                            ? (record == 0 ? '—' : '$record ходов')
                            : '$record',
                        valueColor: Colors.amber),
                  ]),
                ),
                const Spacer(),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: onRestart,
                    icon: const Icon(Icons.replay),
                    label: const Text('Играть снова', style: TextStyle(fontSize: 16)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF6C63FF),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () => Navigator.popUntil(context, (route) => route.isFirst),
                    icon: const Icon(Icons.home_outlined),
                    label: const Text('На главную', style: TextStyle(fontSize: 16)),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.white,
                      side: const BorderSide(color: Colors.white30),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ResultRow extends StatelessWidget {
  final String label;
  final String value;
  final Color valueColor;
  const _ResultRow({required this.label, required this.value, required this.valueColor});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(color: Colors.white60, fontSize: 16)),
        Text(value, style: TextStyle(color: valueColor, fontSize: 18, fontWeight: FontWeight.bold)),
      ],
    );
  }
}