import 'package:flutter/material.dart';
import '../routes.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _login = TextEditingController(text: 'ivanov');
  final _password = TextEditingController(text: 'demo');
  bool _obscure = true;

  @override
  void dispose() {
    _login.dispose();
    _password.dispose();
    super.dispose();
  }

  void _submit() => Navigator.pushReplacementNamed(context, AppRoutes.pin);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 400),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Icon(Icons.agriculture, size: 72, color: theme.colorScheme.primary),
                  const SizedBox(height: 12),
                  Text('АгроКорм', textAlign: TextAlign.center, style: theme.textTheme.headlineMedium),
                  const SizedBox(height: 4),
                  const Text('Расчёт норм кормления', textAlign: TextAlign.center),
                  const SizedBox(height: 32),
                  TextField(
                    controller: _login,
                    decoration: const InputDecoration(
                      labelText: 'Логин или телефон',
                      prefixIcon: Icon(Icons.person_outline),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _password,
                    obscureText: _obscure,
                    decoration: InputDecoration(
                      labelText: 'Пароль',
                      prefixIcon: const Icon(Icons.lock_outline),
                      suffixIcon: IconButton(
                        icon: Icon(_obscure ? Icons.visibility : Icons.visibility_off),
                        onPressed: () => setState(() => _obscure = !_obscure),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  FilledButton(onPressed: _submit, child: const Text('Войти')),
                  TextButton(onPressed: () {}, child: const Text('Забыли пароль?')),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
