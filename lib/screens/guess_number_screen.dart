import 'dart:math';
import 'package:flutter/material.dart';

class GuessNumberScreen extends StatefulWidget {
  const GuessNumberScreen({super.key});

  @override
  State<GuessNumberScreen> createState() => _GuessNumberScreenState();
}

class _GuessNumberScreenState extends State<GuessNumberScreen> {

  final TextEditingController controller = TextEditingController();
  int secretNumber = Random().nextInt(100) + 1;
  String message = "Угадай число от 1 до 100";

  void checkNumber() {
    int userNumber = int.tryParse(controller.text) ?? 0;

    setState(() {
      if (userNumber == secretNumber) {
        message = "Ты угадал! 🎉";
      } else if (userNumber < secretNumber) {
        message = "Больше!";
      } else {
        message = "Меньше!";
      }
    });
  }

  void restartGame() {
    setState(() {
      secretNumber = Random().nextInt(100) + 1;
      message = "Угадай число от 1 до 100";
      controller.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Угадай число"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [

            Text(
              message,
              style: const TextStyle(fontSize: 22),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 20),

            TextField(
              controller: controller,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: "Введите число",
              ),
            ),

            const SizedBox(height: 20),

            ElevatedButton(
              onPressed: checkNumber,
              child: const Text("Проверить"),
            ),

            const SizedBox(height: 10),

            ElevatedButton(
              onPressed: restartGame,
              child: const Text("Новая игра"),
            ),
          ],
        ),
      ),
    );
  }
}