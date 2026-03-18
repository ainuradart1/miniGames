import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';

class TwoPlayerScreen extends StatefulWidget {
  const TwoPlayerScreen({super.key});

  @override
  State<TwoPlayerScreen> createState() => _TwoPlayerScreenState();
}

class _TwoPlayerScreenState extends State<TwoPlayerScreen> {
  final Random _random = Random();
  static const int totalQuestions = 5;
  static const int timePerQuestion = 10;

  String _player1Name = 'Игрок 1';
  String _player2Name = 'Игрок 2';
  int _player1Score = 0;
  int _player2Score = 0;
  int _currentPlayer = 1;
  int _questionIndex = 0;
  int _timeLeft = timePerQuestion;
  Timer? _timer;
  int _num1 = 0, _num2 = 0;
  String _operator = '+';
  int _correctAnswer = 0;
  List<int> _options = [];
  bool _answered = false;
  int? _selectedOption;
  bool _gameStarted = false;
  bool _player1Done = false;
  bool _gameover = false;

  final TextEditingController _p1Controller = TextEditingController(text: 'Игрок 1');
  final TextEditingController _p2Controller = TextEditingController(text: 'Игрок 2');

  @override
  void dispose() {
    _timer?.cancel();
    _p1Controller.dispose();
    _p2Controller.dispose();
    super.dispose();
  }

  void _startGame() {
    setState(() {
      _player1Name = _p1Controller.text.isEmpty ? 'Игрок 1' : _p1Controller.text;
      _player2Name = _p2Controller.text.isEmpty ? 'Игрок 2' : _p2Controller.text;
      _gameStarted = true;
      _currentPlayer = 1;
      _questionIndex = 0;
      _player1Score = 0;
      _player2Score = 0;
      _player1Done = false;
      _gameover = false;
    });
    _generateQuestion();
    _startTimer();
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
      _selectedOption = null;
      _timeLeft = timePerQuestion;
    });
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (_timeLeft <= 0) { _nextQuestion(null); }
      else { setState(() => _timeLeft--); }
    });
  }

  void _nextQuestion(int? selected) {
    _timer?.cancel();
    setState(() {
      _answered = true;
      _selectedOption = selected;
      if (selected == _correctAnswer) {
        if (_currentPlayer == 1) _player1Score++;
        else _player2Score++;
      }
    });
    Future.delayed(const Duration(milliseconds: 700), () {
      if (_questionIndex + 1 >= totalQuestions) {
        if (_currentPlayer == 1) {
          setState(() { _player1Done = true; _currentPlayer = 2; _questionIndex = 0; });
          _showPlayerSwitch();
        } else {
          setState(() => _gameover = true);
        }
      } else {
        setState(() => _questionIndex++);
        _generateQuestion();
        _startTimer();
      }
    });
  }

  void _showPlayerSwitch() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1a1a2e),
        title: const Text('Передай телефон!',
            style: TextStyle(color: Colors.white, fontSize: 22), textAlign: TextAlign.center),
        content: Column(mainAxisSize: MainAxisSize.min, children: [
          Text('$_player1Name набрал $_player1Score очков!',
              style: const TextStyle(color: Colors.white70), textAlign: TextAlign.center),
          const SizedBox(height: 12),
          Text('Теперь очередь $_player2Name!',
              style: const TextStyle(color: Color(0xFFFF6584), fontSize: 18,
                  fontWeight: FontWeight.bold), textAlign: TextAlign.center),
        ]),
        actions: [
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                Navigator.pop(ctx);
                _generateQuestion();
                _startTimer();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFF6584),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: Text('Готов, $_player2Name!',
                  style: const TextStyle(color: Colors.white, fontSize: 16)),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!_gameStarted) return _buildStartScreen();
    if (_gameover) return _buildResultScreen();
    return _buildGameScreen();
  }

  Widget _buildStartScreen() {
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
                const Text('⚔️', style: TextStyle(fontSize: 70)),
                const SizedBox(height: 16),
                const Text('Соревнование', style: TextStyle(
                    color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold)),
                const Text('Два игрока — один телефон',
                    style: TextStyle(color: Colors.white54, fontSize: 16)),
                const SizedBox(height: 40),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF6C63FF).withOpacity(0.15),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFF6C63FF).withOpacity(0.5)),
                  ),
                  child: Row(children: [
                    const Text('👤', style: TextStyle(fontSize: 24)),
                    const SizedBox(width: 12),
                    Expanded(child: TextField(
                      controller: _p1Controller,
                      style: const TextStyle(color: Colors.white, fontSize: 16),
                      decoration: const InputDecoration(
                        hintText: 'Имя игрока 1',
                        hintStyle: TextStyle(color: Colors.white38),
                        border: InputBorder.none,
                      ),
                    )),
                  ]),
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFF6584).withOpacity(0.15),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFFFF6584).withOpacity(0.5)),
                  ),
                  child: Row(children: [
                    const Text('👤', style: TextStyle(fontSize: 24)),
                    const SizedBox(width: 12),
                    Expanded(child: TextField(
                      controller: _p2Controller,
                      style: const TextStyle(color: Colors.white, fontSize: 16),
                      decoration: const InputDecoration(
                        hintText: 'Имя игрока 2',
                        hintStyle: TextStyle(color: Colors.white38),
                        border: InputBorder.none,
                      ),
                    )),
                  ]),
                ),
                const Spacer(),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _startGame,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF6C63FF), foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 18),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                    child: const Text('⚔️ Начать соревнование!',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
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

  Widget _buildGameScreen() {
    final color = _currentPlayer == 1 ? const Color(0xFF6C63FF) : const Color(0xFFFF6584);
    final playerName = _currentPlayer == 1 ? _player1Name : _player2Name;
    final score = _currentPlayer == 1 ? _player1Score : _player2Score;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft, end: Alignment.bottomRight,
            colors: [const Color(0xFF1a1a2e), color.withOpacity(0.3)],
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
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: color.withOpacity(0.2), borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: color.withOpacity(0.5)),
                      ),
                      child: Text('👤 $playerName',
                          style: TextStyle(color: color, fontWeight: FontWeight.bold)),
                    ),
                    Text('Вопрос ${_questionIndex + 1}/$totalQuestions',
                        style: const TextStyle(color: Colors.white60, fontSize: 14)),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                          color: color.withOpacity(0.2), borderRadius: BorderRadius.circular(20)),
                      child: Text('⭐ $score',
                          style: TextStyle(color: color, fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                LinearProgressIndicator(
                  value: _timeLeft / timePerQuestion,
                  backgroundColor: Colors.white24,
                  valueColor: AlwaysStoppedAnimation<Color>(
                      _timeLeft > 5 ? color : Colors.red),
                  minHeight: 8, borderRadius: BorderRadius.circular(4),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.all(40),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: color.withOpacity(0.4)),
                  ),
                  child: Text('$_num1 $_operator $_num2 = ?',
                      style: const TextStyle(fontSize: 44, fontWeight: FontWeight.bold,
                          color: Colors.white)),
                ),
                const Spacer(),
                GridView.count(
                  crossAxisCount: 2, shrinkWrap: true,
                  mainAxisSpacing: 12, crossAxisSpacing: 12, childAspectRatio: 2.5,
                  children: _options.map((opt) {
                    Color btnColor = color.withOpacity(0.2);
                    if (_answered) {
                      if (opt == _correctAnswer) btnColor = Colors.green.withOpacity(0.4);
                      else if (opt == _selectedOption) btnColor = Colors.red.withOpacity(0.4);
                    }
                    return GestureDetector(
                      onTap: _answered ? null : () => _nextQuestion(opt),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        decoration: BoxDecoration(
                          color: btnColor, borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: color.withOpacity(0.5)),
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
    final p1Win = _player1Score > _player2Score;
    final draw = _player1Score == _player2Score;
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
                Text(draw ? '🤝' : '🏆', style: const TextStyle(fontSize: 80)),
                const SizedBox(height: 16),
                Text(draw ? 'Ничья!' : '${p1Win ? _player1Name : _player2Name} победил!',
                    style: const TextStyle(color: Colors.amber, fontSize: 26,
                        fontWeight: FontWeight.bold), textAlign: TextAlign.center),
                const SizedBox(height: 40),
                Container(
                  width: double.infinity, padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Column(children: [
                        Text(_player1Name, style: const TextStyle(color: Colors.white70)),
                        Text('$_player1Score', style: TextStyle(
                            color: p1Win ? Colors.amber : const Color(0xFF6C63FF),
                            fontSize: 48, fontWeight: FontWeight.bold)),
                      ]),
                      const Text('vs', style: TextStyle(color: Colors.white38, fontSize: 20)),
                      Column(children: [
                        Text(_player2Name, style: const TextStyle(color: Colors.white70)),
                        Text('$_player2Score', style: TextStyle(
                            color: !p1Win && !draw ? Colors.amber : const Color(0xFFFF6584),
                            fontSize: 48, fontWeight: FontWeight.bold)),
                      ]),
                    ],
                  ),
                ),
                const Spacer(),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () => setState(() => _gameStarted = false),
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
