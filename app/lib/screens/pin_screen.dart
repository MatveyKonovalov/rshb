/// Экран 2: ввод PIN-кода (демо-PIN: 1234).
library;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../state/app_state.dart';

class PinScreen extends StatefulWidget {
  const PinScreen({super.key});

  @override
  State<PinScreen> createState() => _PinScreenState();
}

class _PinScreenState extends State<PinScreen> {
  static const int pinLength = 4;
  String _entered = '';
  bool _error = false;

  void _tapDigit(String d) {
    if (_entered.length >= pinLength) return;
    setState(() {
      _entered += d;
      _error = false;
    });
    if (_entered.length == pinLength) _check();
  }

  void _backspace() {
    if (_entered.isEmpty) return;
    setState(() => _entered = _entered.substring(0, _entered.length - 1));
  }

  void _check() {
    final state = context.read<AppState>();
    if (_entered == state.demoPin) {
      Navigator.pushReplacementNamed(context, '/main');
    } else {
      setState(() {
        _error = true;
        _entered = '';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Вход по PIN')),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 24),
            Icon(Icons.lock_outline, size: 56, color: theme.colorScheme.primary),
            const SizedBox(height: 16),
            Text(_error ? 'Неверный PIN, попробуйте ещё раз' : 'Введите 4 цифры',
                key: const Key('pin_hint'),
                style: TextStyle(
                    color: _error ? theme.colorScheme.error : theme.textTheme.bodyLarge?.color,
                    fontWeight: FontWeight.w600)),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(pinLength, (i) {
                final filled = i < _entered.length;
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  margin: const EdgeInsets.symmetric(horizontal: 8),
                  width: 18,
                  height: 18,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: filled ? theme.colorScheme.primary : Colors.transparent,
                    border: Border.all(
                        color: _error
                            ? theme.colorScheme.error
                            : theme.colorScheme.primary,
                        width: 2),
                  ),
                );
              }),
            ),
            const Spacer(),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: Column(
                children: [
                  for (final row in const [
                    ['1', '2', '3'],
                    ['4', '5', '6'],
                    ['7', '8', '9'],
                  ])
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        for (final d in row)
                          Padding(
                            padding: const EdgeInsets.all(6),
                            child: SizedBox(
                              width: 80,
                              height: 64,
                              child: OutlinedButton(
                                key: Key('pin_key_$d'),
                                onPressed: () => _tapDigit(d),
                                child: Text(d, style: const TextStyle(fontSize: 24)),
                              ),
                            ),
                          ),
                      ],
                    ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      SizedBox(
                        width: 80,
                        height: 64,
                        child: TextButton(
                          onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Демо-PIN: 1234'))),
                          child: const Text('Забыли?', style: TextStyle(fontSize: 14)),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(6),
                        child: SizedBox(
                          width: 80,
                          height: 64,
                          child: OutlinedButton(
                            key: const Key('pin_key_0'),
                            onPressed: () => _tapDigit('0'),
                            child: const Text('0', style: TextStyle(fontSize: 24)),
                          ),
                        ),
                      ),
                      SizedBox(
                        width: 80,
                        height: 64,
                        child: IconButton(
                          key: const Key('pin_backspace'),
                          icon: const Icon(Icons.backspace_outlined),
                          onPressed: _backspace,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
