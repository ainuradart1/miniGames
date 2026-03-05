import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import '../services/records_service.dart';
import 'result_screen.dart';

class MathQuizScreen extends StatefulWidget {
  const MathQuizScreen({super.key});

  @override
  State<MathQuizScreen> createState() => _MathQuizScreenState();
}

class _MathQuizScreenState extends State<MathQuizScreen> {
  static const String gameKey = 'math_quiz';
  static const int totalQuestions = 10;
  static const int timePerQuestion = 10;

  final Random _random = Random();
  int _score = 0;
  int _questionIndex = 0;
  int _timeLeft = timePerQuestion;
  Timer? _timer;
  int _num1 = 0, _num2 = 0;
  String _operator = '+';
  int _correctAnswer = 0;
  List<int> _options = [];
  bool _answered = false;
  int? _selectedOption;

  @override
  void initState() {
    super.initState();
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
    _options = opts.toList()..shuffle();
    _answered = false;
    _selectedOption = null;
    _timeLeft = timePerQuestion;
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (_timeLeft <= 0) {
        _nextQuestion(null);
      } else {
        setState(() => _timeLeft--);
      }
    });
  }

  void _nextQuestion(int? selected) {
    _timer?.cancel();
    setState(() {
      _answered = true;
      _selectedOption = selected;
      if (selected == _correctAnswer) _score++;
    });

    Future.delayed(const Duration(milliseconds: 700), () {
      if (_questionIndex + 1 >= totalQuestions) {
        _finishGame();
      } else {
        setState(() {
          _questionIndex++;
          _generateQuestion();
        });
        _startTimer();
      }
    });
  }

  void _finishGame() async {
    _timer?.cancel();
    await RecordsService.saveRecord(gameKey, _score);
    final record = await RecordsService.getRecord(gameKey);
    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => ResultScreen(
          gameName: '🧮 Математическая викторина',
          score: _score,
          record: record,
          scoreLabel: 'Правильных ответов',
          maxScore: totalQuestions,
          onRestart: () => Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const MathQuizScreen()),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
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
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.white),
                      onPressed: () { _timer?.cancel(); Navigator.pop(context); },
                    ),
                    Text('Вопрос ${_questionIndex + 1}/$totalQuestions',
                        style: const TextStyle(color: Colors.white, fontSize: 16)),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: const Color(0xFF6C63FF).withOpacity(0.3),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text('Счёт: $_score',
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                LinearProgressIndicator(
                  value: _timeLeft / timePerQuestion,
                  backgroundColor: Colors.white24,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    _timeLeft > 5 ? const Color(0xFF6C63FF) : Colors.red,
                  ),
                  minHeight: 8,
                  borderRadius: BorderRadius.circular(4),
                ),
                const SizedBox(height: 8),
                Text('$_timeLeft сек',
                    style: TextStyle(
                        color: _timeLeft > 5 ? Colors.white60 : Colors.red, fontSize: 14)),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.all(40),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: const Color(0xFF6C63FF).withOpacity(0.4)),
                  ),
                  child: Text('$_num1 $_operator $_num2 = ?',
                      style: const TextStyle(
                          fontSize: 48, fontWeight: FontWeight.bold, color: Colors.white)),
                ),
                const Spacer(),
                GridView.count(
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio: 2.5,
                  children: _options.map((opt) {
                    Color btnColor = const Color(0xFF6C63FF).withOpacity(0.2);
                    if (_answered) {
                      if (opt == _correctAnswer) btnColor = Colors.green.withOpacity(0.4);
                      else if (opt == _selectedOption) btnColor = Colors.red.withOpacity(0.4);
                    }
                    return GestureDetector(
                      onTap: _answered ? null : () => _nextQuestion(opt),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        decoration: BoxDecoration(
                          color: btnColor,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: _answered && opt == _correctAnswer
                                ? Colors.green
                                : const Color(0xFF6C63FF).withOpacity(0.5),
                          ),
                        ),
                        alignment: Alignment.center,
                        child: Text('$opt',
                            style: const TextStyle(
                                color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 30),
              ],
            ),
          ),
        ),
      ),
    );
  }
}