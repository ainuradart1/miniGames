import 'dart:math';
import 'package:flutter/material.dart';
import 'math_quiz_screen.dart';
import 'tap_game_screen.dart';
import 'memory_game_screen.dart';
import 'records_screen.dart';
import 'guess_number_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  void openRandomGame(BuildContext context) {
    final games = [
      const MathQuizScreen(),
      const TapGameScreen(),
      const MemoryGameScreen(),
      const GuessNumberScreen(),
    ];

    final randomGame = games[Random().nextInt(games.length)];

    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => randomGame),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF1a1a2e), Color(0xFF16213e), Color(0xFF0f3460)],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                const SizedBox(height: 30),
                const Text(
                  '🎮 Мини-Игры',
                  style: TextStyle(
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: 2,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Выбери игру и побей рекорд!',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white.withOpacity(0.6),
                  ),
                ),
                const SizedBox(height: 20),

                // Кнопка случайной игры
                ElevatedButton.icon(
                  onPressed: () => openRandomGame(context),
                  icon: const Icon(Icons.casino),
                  label: const Text("🎲 Случайная игра"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                ),

                const SizedBox(height: 30),

                Expanded(
                  child: GridView.count(
                    crossAxisCount: 1,
                    childAspectRatio: 2.8,
                    mainAxisSpacing: 16,
                    children: [
                      _GameCard(
                        title: '🧮 Математическая викторина',
                        subtitle: 'Реши примеры быстрее времени',
                        color: const Color(0xFF6C63FF),
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const MathQuizScreen()),
                        ),
                      ),
                      _GameCard(
                        title: '👆 Тап-игра',
                        subtitle: 'Нажимай как можно быстрее',
                        color: const Color(0xFFFF6584),
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const TapGameScreen()),
                        ),
                      ),
                      _GameCard(
                        title: '🃏 Игра на память',
                        subtitle: 'Найди одинаковые карточки',
                        color: const Color(0xFF43D9AD),
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const MemoryGameScreen()),
                        ),
                      ),
                      _GameCard(
                        title: '🎯 Угадай число',
                        subtitle: 'Попробуй угадать число',
                        color: const Color(0xFFFFA500),
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const GuessNumberScreen()),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const RecordsScreen()),
                    ),
                    icon: const Icon(Icons.emoji_events, color: Colors.amber),
                    label: const Text(
                      'Таблица рекордов',
                      style: TextStyle(color: Colors.amber, fontSize: 16),
                    ),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Colors.amber, width: 2),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
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

// ---------------------
// Виджет карточки игры
// ---------------------
class _GameCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  const _GameCard({
    required this.title,
    required this.subtitle,
    required this.color,
    required this.onTap,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.white70,
              ),
            ),
          ],
        ),
      ),
    );
  }
}