import 'package:flutter/material.dart';
import '../services/records_service.dart';

class RecordsScreen extends StatefulWidget {
  const RecordsScreen({super.key});

  @override
  State<RecordsScreen> createState() => _RecordsScreenState();
}

class _RecordsScreenState extends State<RecordsScreen> {
  Map<String, int> _records = {};
  bool _loading = true;

  @override
  void initState() { super.initState(); _loadRecords(); }

  Future<void> _loadRecords() async {
    final records = await RecordsService.getAllRecords();
    setState(() { _records = records; _loading = false; });
  }

  Future<void> _confirmClear() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1a1a2e),
        title: const Text('Сбросить рекорды?', style: TextStyle(color: Colors.white)),
        content: const Text('Все рекорды будут удалены.',
            style: TextStyle(color: Colors.white70)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Отмена')),
          TextButton(onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Сбросить', style: TextStyle(color: Colors.red))),
        ],
      ),
    );
    if (confirmed == true) { await RecordsService.clearAll(); await _loadRecords(); }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft, end: Alignment.bottomRight,
            colors: [Color(0xFF1a1a2e), Color(0xFF16213e)],
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
                    IconButton(icon: const Icon(Icons.arrow_back, color: Colors.white),
                        onPressed: () => Navigator.pop(context)),
                    const Text('🏆 Рекорды', style: TextStyle(
                        color: Colors.amber, fontSize: 24, fontWeight: FontWeight.bold)),
                    IconButton(icon: const Icon(Icons.delete_outline, color: Colors.red),
                        onPressed: _confirmClear),
                  ],
                ),
                const SizedBox(height: 30),
                if (_loading)
                  const CircularProgressIndicator(color: Colors.amber)
                else
                  Expanded(
                    child: Column(children: [
                      _RecordCard(emoji: '🧮', title: 'Математическая викторина',
                          subtitle: 'Правильных ответов', value: _records['math_quiz'] ?? 0,
                          maxValue: 10, color: const Color(0xFF6C63FF)),
                      const SizedBox(height: 16),
                      _RecordCard(emoji: '👆', title: 'Тап-игра',
                          subtitle: 'Тапов за 15 секунд', value: _records['tap_game'] ?? 0,
                          color: const Color(0xFFFF6584)),
                      const SizedBox(height: 16),
                      _RecordCard(emoji: '🃏', title: 'Игра на память',
                          subtitle: 'Лучший результат (очки)', value: _records['memory_game'] ?? 0,
                          color: const Color(0xFF43D9AD)),
                    ]),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _RecordCard extends StatelessWidget {
  final String emoji;
  final String title;
  final String subtitle;
  final int value;
  final int? maxValue;
  final Color color;

  const _RecordCard({required this.emoji, required this.title, required this.subtitle,
      required this.value, required this.color, this.maxValue});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.4), width: 1.5),
      ),
      child: Row(children: [
        Text(emoji, style: const TextStyle(fontSize: 40)),
        const SizedBox(width: 16),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(title, style: const TextStyle(
              color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text(subtitle, style: const TextStyle(color: Colors.white54, fontSize: 13)),
        ])),
        Text(value == 0 ? '—' : '$value${maxValue != null ? "/$maxValue" : ""}',
            style: TextStyle(color: value == 0 ? Colors.white38 : color,
                fontSize: 28, fontWeight: FontWeight.bold)),
      ]),
    );
  }
}