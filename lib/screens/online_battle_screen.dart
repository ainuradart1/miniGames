import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class OnlineBattleScreen extends StatefulWidget {
  const OnlineBattleScreen({super.key});

  @override
  State<OnlineBattleScreen> createState() => _OnlineBattleScreenState();
}

class _OnlineBattleScreenState extends State<OnlineBattleScreen> {
  final Random _random = Random();
  bool _isHost = false;
  bool _roomCreated = false;
  bool _gameStarted = false;
  bool _searching = false;
  String _roomCode = '';
  final TextEditingController _codeController = TextEditingController();
  int _playerScore = 0;
  int _opponentScore = 0;
  int _questionIndex = 0;
  int _timeLeft = 10;
  Timer? _timer;
  Timer? _opponentTimer;
  int _num1 = 0, _num2 = 0;
  String _operator = '+';
  int _correctAnswer = 0;
  List<int> _options = [];
  bool _answered = false;
  String _opponentStatus = '⏳ Соперник думает...';
  bool _gameover = false;
  static const int totalQuestions = 5;

  String _generateRoomCode() {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    return List.generate(6, (i) => chars[_random.nextInt(chars.length)]).join();
  }

  void _createRoom() {
    setState(() {
      _roomCode = _generateRoomCode();
      _roomCreated = true;
      _isHost = true;
      _searching = true;
    });
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) setState(() => _searching = false);
    });
  }

  void _startOnlineGame() {
    setState(() => _gameStarted = true);
    _generateQuestion();
    _startTimer();
  }

  void _joinRoom() {
    if (_codeController.text.length != 6) return;
    setState(() {
      _roomCode = _codeController.text.toUpperCase();
      _isHost = false;
      _gameStarted = true;
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
      _opponentStatus = '⏳ Соперник думает...';
      _timeLeft = 10;
    });
    _scheduleOpponentAnswer();
  }

  void _scheduleOpponentAnswer() {
    _opponentTimer?.cancel();
    final delay = 2 + _random.nextInt(6);
    _opponentTimer = Timer(Duration(seconds: delay), () {
      if (!_answered && mounted) {
        final correct = _random.nextDouble() < 0.7;
        setState(() {
          _answered = true;
          if (correct) { _opponentScore++; _opponentStatus = '⚡ Соперник ответил!'; }
          else { _opponentStatus = '❌ Соперник ошибся!'; }
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
    _opponentTimer?.cancel();
    _timer?.cancel();
    setState(() {
      _answered = true;
      if (answer == _correctAnswer) { _playerScore++; _opponentStatus = '✅ Ты ответил первым!'; }
      else { _opponentStatus = '❌ Неверный ответ!'; }
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
  void dispose() {
    _timer?.cancel();
    _opponentTimer?.cancel();
    _codeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_gameover) return _buildResultScreen();
    if (_gameStarted) return _buildGameScreen();
    return _buildLobbyScreen();
  }

  Widget _buildLobbyScreen() {
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
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                Row(children: [
                  IconButton(icon: const Icon(Icons.arrow_back, color: Colors.white),
                      onPressed: () => Navigator.pop(context)),
                ]),
                const Spacer(),
                const Text('🌐', style: TextStyle(fontSize: 70)),
                const SizedBox(height: 16),
                const Text('Онлайн игра', style: TextStyle(
                    color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold)),
                const SizedBox(height: 40),
                if (!_roomCreated) ...[
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _createRoom,
                      icon: const Icon(Icons.add),
                      label: const Text('Создать комнату', style: TextStyle(fontSize: 16)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF43D9AD), foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Row(children: [
                    Expanded(child: Divider(color: Colors.white24)),
                    Padding(padding: EdgeInsets.symmetric(horizontal: 12),
                        child: Text('или', style: TextStyle(color: Colors.white38))),
                    Expanded(child: Divider(color: Colors.white24)),
                  ]),
                  const SizedBox(height: 20),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFF43D9AD).withOpacity(0.3)),
                    ),
                    child: Column(children: [
                      TextField(
                        controller: _codeController,
                        textAlign: TextAlign.center,
                        textCapitalization: TextCapitalization.characters,
                        maxLength: 6,
                        style: const TextStyle(color: Colors.white, fontSize: 24,
                            letterSpacing: 8, fontWeight: FontWeight.bold),
                        decoration: const InputDecoration(
                          hintText: 'КОД КОМНАТЫ',
                          hintStyle: TextStyle(color: Colors.white38, fontSize: 18, letterSpacing: 4),
                          border: InputBorder.none, counterText: '',
                        ),
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton(
                          onPressed: _joinRoom,
                          style: OutlinedButton.styleFrom(
                            foregroundColor: const Color(0xFF43D9AD),
                            side: const BorderSide(color: Color(0xFF43D9AD)),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          child: const Text('Войти в комнату', style: TextStyle(fontSize: 16)),
                        ),
                      ),
                    ]),
                  ),
                ] else ...[
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: const Color(0xFF43D9AD).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: const Color(0xFF43D9AD).withOpacity(0.5)),
                    ),
                    child: Column(children: [
                      const Text('Код комнаты:',
                          style: TextStyle(color: Colors.white54, fontSize: 16)),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(_roomCode, style: const TextStyle(
                              color: Color(0xFF43D9AD), fontSize: 36,
                              fontWeight: FontWeight.bold, letterSpacing: 8)),
                          const SizedBox(width: 12),
                          IconButton(
                            icon: const Icon(Icons.copy, color: Color(0xFF43D9AD)),
                            onPressed: () {
                              Clipboard.setData(ClipboardData(text: _roomCode));
                              ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Код скопирован!')));
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      const Text('Поделись кодом с другом!',
                          style: TextStyle(color: Colors.white54, fontSize: 14)),
                      const SizedBox(height: 16),
                      if (_searching)
                        const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(width: 20, height: 20,
                                child: CircularProgressIndicator(
                                    color: Color(0xFF43D9AD), strokeWidth: 2)),
                            SizedBox(width: 12),
                            Text('Ждём соперника...',
                                style: TextStyle(color: Colors.white54)),
                          ],
                        )
                      else ...[
                        const Text('✅ Соперник подключился!',
                            style: TextStyle(color: Color(0xFF43D9AD), fontSize: 16)),
                        const SizedBox(height: 16),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: _startOnlineGame,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF43D9AD),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12)),
                            ),
                            child: const Text('Начать игру!', style: TextStyle(fontSize: 16)),
                          ),
                        ),
                      ],
                    ]),
                  ),
                ],
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
            colors: [Color(0xFF1a1a2e), Color(0xFF0d3b2e)],
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
                    Text('Вопрос ${_questionIndex + 1}/$totalQuestions',
                        style: const TextStyle(color: Colors.white60)),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                          color: const Color(0xFF43D9AD).withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12)),
                      child: Text('🔑 $_roomCode',
                          style: const TextStyle(color: Color(0xFF43D9AD), fontSize: 12)),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _ScoreBox(label: '👤 Ты', score: _playerScore,
                        color: const Color(0xFF43D9AD)),
                    const Text('VS', style: TextStyle(color: Colors.white38)),
                    _ScoreBox(label: '🌐 Соперник', score: _opponentScore,
                        color: Colors.orange),
                  ],
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(12)),
                  child: Text(_opponentStatus,
                      style: const TextStyle(color: Colors.white70, fontSize: 13)),
                ),
                const SizedBox(height: 12),
                LinearProgressIndicator(
                  value: _timeLeft / 10,
                  backgroundColor: Colors.white24,
                  valueColor: AlwaysStoppedAnimation<Color>(
                      _timeLeft > 5 ? const Color(0xFF43D9AD) : Colors.red),
                  minHeight: 8, borderRadius: BorderRadius.circular(4),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.all(36),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: const Color(0xFF43D9AD).withOpacity(0.4)),
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
                    Color btnColor = const Color(0xFF43D9AD).withOpacity(0.15);
                    if (_answered && opt == _correctAnswer) {
                      btnColor = Colors.green.withOpacity(0.4);
                    }
                    return GestureDetector(
                      onTap: _answered ? null : () => _onAnswer(opt),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        decoration: BoxDecoration(
                          color: btnColor, borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: const Color(0xFF43D9AD).withOpacity(0.5)),
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
    final playerWin = _playerScore > _opponentScore;
    final draw = _playerScore == _opponentScore;
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
              children: [
                const Spacer(),
                Text(draw ? '🤝' : playerWin ? '🏆' : '😔',
                    style: const TextStyle(fontSize: 80)),
                const SizedBox(height: 16),
                Text(
                  draw ? 'Ничья!' : playerWin ? 'Ты победил!' : 'Соперник победил!',
                  style: TextStyle(
                    color: playerWin ? Colors.amber : draw ? Colors.white : Colors.orange,
                    fontSize: 26, fontWeight: FontWeight.bold,
                  ),
                ),
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
                            color: playerWin ? Colors.amber : const Color(0xFF43D9AD),
                            fontSize: 48, fontWeight: FontWeight.bold)),
                      ]),
                      const Text('VS', style: TextStyle(color: Colors.white38, fontSize: 20)),
                      Column(children: [
                        const Text('🌐 Соперник', style: TextStyle(color: Colors.white70)),
                        Text('$_opponentScore', style: const TextStyle(
                            color: Colors.orange, fontSize: 48, fontWeight: FontWeight.bold)),
                      ]),
                    ],
                  ),
                ),
                const Spacer(),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () => Navigator.popUntil(context, (r) => r.isFirst),
                    icon: const Icon(Icons.home_outlined),
                    label: const Text('На главную', style: TextStyle(fontSize: 16)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF43D9AD), foregroundColor: Colors.white,
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

class _ScoreBox extends StatelessWidget {
  final String label;
  final int score;
  final Color color;
  const _ScoreBox({required this.label, required this.score, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15), borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withOpacity(0.5)),
      ),
      child: Column(children: [
        Text(label, style: const TextStyle(color: Colors.white70, fontSize: 12)),
        Text('$score', style: TextStyle(
            color: color, fontSize: 26, fontWeight: FontWeight.bold)),
      ]),
    );
  }
}
