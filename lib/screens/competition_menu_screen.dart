import 'package:flutter/material.dart';
import 'two_player_screen.dart';
import 'ai_battle_screen.dart';
import 'online_battle_screen.dart';

class CompetitionMenuScreen extends StatelessWidget {
  const CompetitionMenuScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF1a1a2e), Color(0xFF16213e)],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                const Text('⚔️', style: TextStyle(fontSize: 70)),
                const SizedBox(height: 16),
                const Text('Соревнование',
                    style: TextStyle(color: Colors.white, fontSize: 30, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Text('Выбери режим игры',
                    style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 16)),
                const SizedBox(height: 50),
                _ModeCard(
                  emoji: '📱',
                  title: 'Два игрока',
                  subtitle: 'Соревнование на одном устройстве',
                  color: const Color(0xFF6C63FF),
                  onTap: () => Navigator.push(context,
                      MaterialPageRoute(builder: (_) => const TwoPlayerScreen())),
                ),
                const SizedBox(height: 16),
                _ModeCard(
                  emoji: '🌐',
                  title: 'Онлайн',
                  subtitle: 'Играй с другом через интернет',
                  color: const Color(0xFF43D9AD),
                  onTap: () => Navigator.push(context,
                      MaterialPageRoute(builder: (_) => const OnlineBattleScreen())),
                ),
                const SizedBox(height: 16),
                _ModeCard(
                  emoji: '🤖',
                  title: 'Против ИИ',
                  subtitle: 'Сыграй против искусственного интеллекта',
                  color: const Color(0xFFFF6584),
                  onTap: () => Navigator.push(context,
                      MaterialPageRoute(builder: (_) => const AiBattleScreen())),
                ),
                const Spacer(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ModeCard extends StatelessWidget {
  final String emoji;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  const _ModeCard({
    required this.emoji,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color.withOpacity(0.5), width: 1.5),
        ),
        child: Row(
          children: [
            Container(
              width: 60, height: 60,
              decoration: BoxDecoration(
                color: color.withOpacity(0.2),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Center(child: Text(emoji, style: const TextStyle(fontSize: 30))),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(title, style: const TextStyle(
                    color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text(subtitle, style: TextStyle(
                    color: Colors.white.withOpacity(0.5), fontSize: 12)),
              ]),
            ),
            Icon(Icons.arrow_forward_ios, color: color, size: 18),
          ],
        ),
      ),
    );
  }
}
