import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';

class AiBattleScreen extends StatefulWidget {
  const AiBattleScreen({super.key});

  @override
  State<AiBattleScreen> createState() => _AiBattleScreenState();
}

class _AiBattleScreenState extends State<AiBattleScreen> {
  final Random _random = Random();
  static const int totalQuestions = 5;
  String _difficulty = '';
  bool _difficultySelected = false;
  int _playerScore = 0;
  int _aiScore = 0;
  int _questionIndex = 0;
  int _timeLeft = 10;
  Timer? _timer;
  Timer? _aiTimer;
  int _num1 = 0, _num2 = 0;
  String _operator = '+';
  int _correctAnswer = 0;
  List<int> _options = [];
  bool _answered = false;
  String _aiStatus = '🤖 ИИ думает...';
  bool _gameover = false;

  @override
  void dispose() {
    _timer?.cancel();
    _aiTimer?.cancel();
    super.dispose();
  }

  void _selectDifficulty(String diff) {
    setState(() { _difficulty = diff; _difficultySelected = true; });
    _generateQuestion();
    _startTimer();
  }

  int get _aiDelay {
    switch (_difficulty) {
      case 'Лёгкий': return 5 + _random.nextInt(4);
      case 'Средний': return 3 + _random.nextInt(3);
      case 'Сложный': return 1 + _random.nextInt(2);
      default: return 4;
    }
  }

  double get _aiAccuracy {
    switch (_difficulty) {
      case 'Лёгкий': return 0.5;
      case 'Средний': return 0.75;
      case 'Сложный': return 0.95;
      default: return 0.7;
    }
  }

  void _generateQuestion() {
    final ops = ['+', '-', '×'];
    _operator = ops[_random.nextInt(ops.length)];
    _num1 = _random.nextInt(20) + 1;
    _num2 = _random.nextInt(10) + 1;
    switch (_operator) {
      case '+': _correctAnswer = _num1 + _num2; break;
      case '-': _correctAnswer = _num1 - _num2; break;
      case '×': _correctAnswer = _num1 * _num2; break;
    }
    final Set<int> opts = {_correctAnswer};
    while (opts.length < 4) {
      opts.add(_correctAnswer + _random.nextInt(11) - 5);
    }
    setState(() {
      _options = opts.toList()..shuffle();
      _answered = false;
      _aiStatus = '🤖 ИИ думает...';
      _timeLeft = 10;
    });
    _scheduleAiAnswer();
  }

  void _scheduleAiAnswer() {
    _aiTimer?.cancel();
    _aiTimer = Timer(Duration(seconds: _aiDelay), () {
      if (!_answered && mounted) {
        final aiCorrect = _random.nextDouble() < _aiAccuracy;
        setState(() {
          _answered = true;
          if (aiCorrect) { _aiScore++; _aiStatus = '🤖 ИИ ответил правильно!'; }
          else { _aiStatus = '🤖 ИИ ошибся!'; }
        });
        Future.delayed(const Duration(milliseconds: 800), _nextQuestion);
      }
    });
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (_timeLeft <= 0) { t.cancel(); _nextQuestion(); }
      else { setState(() => _timeLeft--); }
    });
  }

  void _onAnswer(int answer) {
    if (_answered) return;
    _aiTimer?.cancel();
    _timer?.cancel();
    setState(() {
      _answered = true;
      if (answer == _correctAnswer) { _playerScore++; _aiStatus = '🤖 Ты успел раньше ИИ!'; }
      else { _aiStatus = '🤖 Ты ошибся!'; }
    });
    Future.delayed(const Duration(milliseconds: 800), _nextQuestion);
  }

  void _nextQuestion() {
    if (_questionIndex + 1 >= totalQuestions) { setState(() => _gameover = true); return; }
    setState(() => _questionIndex++);
    _generateQuestion();
    _startTimer();
  }

  @override
  Widget build(BuildContext context) {
    if (!_difficultySelected) return _buildDifficultyScreen();
    if (_gameover) return _buildResultScreen();
    return _buildGameScreen();
  }

  Widget _buildDifficultyScreen() {
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
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                Row(children: [
                  IconButton(icon: const Icon(Icons.arrow_back, color: Colors.white),
                      onPressed: () => Navigator.pop(context)),
                ]),
                const Spacer(),
                const Text('🤖', style: TextStyle(fontSize: 70)),
                const SizedBox(height: 16),
                const Text('Против ИИ', style: TextStyle(
                    color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                const Text('Выбери сложность',
                    style: TextStyle(color: Colors.white54, fontSize: 16)),
                const SizedBox(height: 40),
                _DiffCard(emoji: '😊', title: 'Лёгкий',
                    subtitle: 'ИИ медленный и часто ошибается',
                    color: Colors.green, onTap: () => _selectDifficulty('Лёгкий')),
                const SizedBox(height: 16),
                _DiffCard(emoji: '😐', title: 'Средний',
                    subtitle: 'ИИ иногда ошибается',
                    color: Colors.orange, onTap: () => _selectDifficulty('Средний')),
                const SizedBox(height: 16),
                _DiffCard(emoji: '😈', title: 'Сложный',
                    subtitle: 'ИИ почти не ошибается и очень быстрый',
                    color: Colors.red, onTap: () => _selectDifficulty('Сложный')),
                const Spacer(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildGameScreen() {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft, end: Alignment.bottomRight,
            colors: [Color(0xFF1a1a2e), Color(0xFF2d1b69)],
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
                        onPressed: () { _timer?.cancel(); _aiTimer?.cancel(); Navigator.pop(context); }),
                    Text('Вопрос ${_questionIndex + 1}/$totalQuestions',
                        style: const TextStyle(color: Colors.white60, fontSize: 14)),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                          color: Colors.red.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12)),
                      child: Text('🤖 $_difficulty',
                          style: const TextStyle(color: Colors.red, fontSize: 12)),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _ScoreBox(label: '👤 Ты', score: _playerScore, color: const Color(0xFF6C63FF)),
                    const Text('VS', style: TextStyle(color: Colors.white38, fontSize: 18)),
                    _ScoreBox(label: '🤖 ИИ', score: _aiScore, color: Colors.red),
                  ],
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(12)),
                  child: Text(_aiStatus,
                      style: const TextStyle(color: Colors.white70, fontSize: 13)),
                ),
                const SizedBox(height: 12),
                LinearProgressIndicator(
                  value: _timeLeft / 10,
                  backgroundColor: Colors.white24,
                  valueColor: AlwaysStoppedAnimation<Color>(
                      _timeLeft > 5 ? const Color(0xFF6C63FF) : Colors.red),
                  minHeight: 8,
                  borderRadius: BorderRadius.circular(4),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.all(36),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: const Color(0xFF6C63FF).withOpacity(0.4)),
                  ),
                  child: Text('$_num1 $_operator $_num2 = ?',
                      style: const TextStyle(
                          fontSize: 44, fontWeight: FontWeight.bold, color: Colors.white)),
                ),
                const Spacer(),
                GridView.count(
                  crossAxisCount: 2, shrinkWrap: true,
                  mainAxisSpacing: 12, crossAxisSpacing: 12, childAspectRatio: 2.5,
                  children: _options.map((opt) {
                    Color btnColor = const Color(0xFF6C63FF).withOpacity(0.2);
                    if (_answered && opt == _correctAnswer) btnColor = Colors.green.withOpacity(0.4);
                    return GestureDetector(
                      onTap: _answered ? null : () => _onAnswer(opt),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        decoration: BoxDecoration(
                          color: btnColor, borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: const Color(0xFF6C63FF).withOpacity(0.5)),
                        ),
                        alignment: Alignment.center,
                        child: Text('$opt', style: const TextStyle(
                            color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildResultScreen() {
    final playerWin = _playerScore > _aiScore;
    final draw = _playerScore == _aiScore;
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
                Text(draw ? '🤝' : playerWin ? '🏆' : '🤖',
                    style: const TextStyle(fontSize: 80)),
                const SizedBox(height: 16),
                Text(draw ? 'Ничья!' : playerWin ? 'Ты победил ИИ!' : 'ИИ победил!',
                    style: TextStyle(
                        color: playerWin ? Colors.amber : draw ? Colors.white : Colors.red,
                        fontSize: 26, fontWeight: FontWeight.bold)),
                const SizedBox(height: 40),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Column(children: [
                        const Text('👤 Ты', style: TextStyle(color: Colors.white70)),
                        Text('$_playerScore', style: TextStyle(
                            color: playerWin ? Colors.amber : const Color(0xFF6C63FF),
                            fontSize: 48, fontWeight: FontWeight.bold)),
                      ]),
                      const Text('VS', style: TextStyle(color: Colors.white38, fontSize: 20)),
                      Column(children: [
                        const Text('🤖 ИИ', style: TextStyle(color: Colors.white70)),
                        Text('$_aiScore', style: const TextStyle(
                            color: Colors.red, fontSize: 48, fontWeight: FontWeight.bold)),
                      ]),
                    ],
                  ),
                ),
                const Spacer(),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () => setState(() {
                      _difficultySelected = false; _gameover = false;
                      _playerScore = 0; _aiScore = 0; _questionIndex = 0;
                    }),
                    icon: const Icon(Icons.replay),
                    label: const Text('Играть снова', style: TextStyle(fontSize: 16)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF6C63FF), foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () => Navigator.popUntil(context, (r) => r.isFirst),
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

class _DiffCard extends StatelessWidget {
  final String emoji, title, subtitle;
  final Color color;
  final VoidCallback onTap;
  const _DiffCard({required this.emoji, required this.title,
      required this.subtitle, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withOpacity(0.5)),
        ),
        child: Row(children: [
          Text(emoji, style: const TextStyle(fontSize: 30)),
          const SizedBox(width: 16),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(title, style: TextStyle(color: color, fontSize: 18, fontWeight: FontWeight.bold)),
            Text(subtitle, style: const TextStyle(color: Colors.white54, fontSize: 12)),
          ])),
          Icon(Icons.arrow_forward_ios, color: color, size: 16),
        ]),
      ),
    );
  }
}

class _ScoreBox extends StatelessWidget {
  final String label;
  final int score;
  final Color color;
  const _ScoreBox({required this.label, required this.score, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15), borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withOpacity(0.5)),
      ),
      child: Column(children: [
        Text(label, style: const TextStyle(color: Colors.white70, fontSize: 13)),
        Text('$score', style: TextStyle(color: color, fontSize: 28, fontWeight: FontWeight.bold)),
      ]),
    );
  }
}
