import 'package:flutter/material.dart';
import '../routes.dart';

class PinScreen extends StatefulWidget {
  const PinScreen({super.key});

  @override
  State<PinScreen> createState() => _PinScreenState();
}

class _PinScreenState extends State<PinScreen> {
  static const _testPin = '1234';
  static const _length = 4;

  String _pin = '';
  bool _wrong = false;

  void _press(String digit) {
    if (_pin.length >= _length) return;
    setState(() {
      _pin += digit;
      _wrong = false;
    });
    if (_pin.length == _length) {
      if (_pin == _testPin) {
        Navigator.pushNamedAndRemoveUntil(context, AppRoutes.main, (_) => false);
      } else {
        setState(() {
          _pin = '';
          _wrong = true;
        });
      }
    }
  }

  void _backspace() {
    if (_pin.isEmpty) return;
    setState(() => _pin = _pin.substring(0, _pin.length - 1));
  }

  Widget _key(String label, {VoidCallback? onTap, IconData? icon}) {
    return TextButton(
      onPressed: onTap,
      style: TextButton.styleFrom(shape: const CircleBorder(), padding: EdgeInsets.zero),
      child: icon != null
          ? Icon(icon, size: 26)
          : Text(label, style: const TextStyle(fontSize: 26)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Scaffold(
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.lock_outline, size: 48, color: scheme.primary),
            const SizedBox(height: 12),
            const Text('Введите PIN-код', style: TextStyle(fontSize: 20)),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(_length, (i) {
                final filled = i < _pin.length;
                return Container(
                  margin: const EdgeInsets.symmetric(horizontal: 8),
                  width: 16,
                  height: 16,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: filled ? scheme.primary : Colors.transparent,
                    border: Border.all(color: scheme.primary, width: 2),
                  ),
                );
              }),
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 20,
              child: _wrong ? Text('Неверный PIN', style: TextStyle(color: scheme.error)) : null,
            ),
            const Text('Тестовый PIN: 1234', style: TextStyle(fontSize: 12, color: Colors.grey)),
            const SizedBox(height: 16),
            SizedBox(
              width: 280,
              child: GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 3,
                children: [
                  for (final k in ['1', '2', '3', '4', '5', '6', '7', '8', '9'])
                    _key(k, onTap: () => _press(k)),
                  _key(''),
                  _key('0', onTap: () => _press('0')),
                  _key('', icon: Icons.backspace_outlined, onTap: _backspace),
                ],
              ),
            ),
            TextButton(
              onPressed: () => Navigator.pushReplacementNamed(context, AppRoutes.login),
              child: const Text('Выйти'),
            ),
          ],
        ),
      ),
    );
  }
}
