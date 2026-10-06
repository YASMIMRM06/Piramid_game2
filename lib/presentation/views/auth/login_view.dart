import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:signals_flutter/signals_flutter.dart';

import '../../../core/routes/app_routes.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/typedefs/types_defs.dart';
import '../../controllers/auth_viewmodel.dart';

/// Tela de Login. Também permite criar conta (alterna o modo) e entrar com Google.
class LoginView extends StatefulWidget {
  final AuthViewModel viewModel;
  const LoginView({super.key, required this.viewModel});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _senhaController = TextEditingController();
  final _confirmarController = TextEditingController();

  bool _isRegister = false;
  bool _obscure = true;

  @override
  void dispose() {
    _emailController.dispose();
    _senhaController.dispose();
    _confirmarController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final email = _emailController.text.trim();
    final senha = _senhaController.text;

    final result = _isRegister
        ? await widget.viewModel.register(email, senha)
        : await widget.viewModel.login(email, senha);
    _tratarResultado(result);
  }

  Future<void> _entrarComGoogle() async {
    _tratarResultado(await widget.viewModel.loginWithGoogle());
  }

  void _tratarResultado(UsuarioResult result) {
    if (!mounted) return;
    result.fold<void>(
      onSuccess: (_) => context.go(AppRoutes.home),
      onFailure: (err) {
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(
            SnackBar(
              content: Text(err.msg),
              backgroundColor: Colors.red.shade600,
              behavior: SnackBarBehavior.floating,
            ),
          );
      },
    );
  }

  void _alternarModo() {
    setState(() {
      _isRegister = !_isRegister;
      _confirmarController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: AppSpacing.paddingLg,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Center(
                        child: Text('🏆', style: TextStyle(fontSize: 64))),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      'PiramidGame',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                          ),
                    ),
                    Text(
                      'IFPR – Campus Paranaguá',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    const SizedBox(height: AppSpacing.xl),
                    Text(
                      _isRegister ? 'Criar conta' : 'Entrar',
                      style: Theme.of(context)
                          .textTheme
                          .titleMedium
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    TextFormField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      autofillHints: const [AutofillHints.email],
                      decoration: const InputDecoration(
                        labelText: 'E-mail',
                        prefixIcon: Icon(Icons.email_outlined),
                      ),
                      validator: (v) {
                        final valor = v?.trim() ?? '';
                        if (valor.isEmpty) return 'Informe o e-mail';
                        if (!valor.contains('@') || !valor.contains('.')) {
                          return 'E-mail inválido';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    TextFormField(
                      controller: _senhaController,
                      obscureText: _obscure,
                      decoration: InputDecoration(
                        labelText: 'Senha',
                        prefixIcon: const Icon(Icons.lock_outline),
                        suffixIcon: IconButton(
                          icon: Icon(_obscure
                              ? Icons.visibility_outlined
                              : Icons.visibility_off_outlined),
                          onPressed: () => setState(() => _obscure = !_obscure),
                        ),
                      ),
                      validator: (v) {
                        final valor = v ?? '';
                        if (valor.isEmpty) return 'Informe a senha';
                        if (_isRegister && valor.length < 6) {
                          return 'Mínimo de 6 caracteres';
                        }
                        return null;
                      },
                    ),
                    if (_isRegister) ...[
                      const SizedBox(height: AppSpacing.sm),
                      TextFormField(
                        controller: _confirmarController,
                        obscureText: _obscure,
                        decoration: const InputDecoration(
                          labelText: 'Confirmar senha',
                          prefixIcon: Icon(Icons.lock_outline),
                        ),
                        validator: (v) => v != _senhaController.text
                            ? 'As senhas não conferem'
                            : null,
                      ),
                    ],
                    const SizedBox(height: AppSpacing.lg),
                    Watch((_) {
                      final ocupado = widget.viewModel.isBusy.value;
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          ElevatedButton(
                            onPressed: ocupado ? null : _submit,
                            child: ocupado
                                ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                        strokeWidth: 2),
                                  )
                                : Text(_isRegister ? 'Criar conta' : 'Entrar'),
                          ),
                          const SizedBox(height: AppSpacing.sm),
                          TextButton(
                            onPressed: ocupado ? null : _alternarModo,
                            child: Text(_isRegister
                                ? 'Já tenho conta — Entrar'
                                : 'Não tem conta? Criar conta'),
                          ),
                          const Divider(height: AppSpacing.lg),
                          OutlinedButton.icon(
                            onPressed: ocupado ? null : _entrarComGoogle,
                            icon: const Icon(Icons.g_mobiledata, size: 28),
                            label: const Text('Entrar com Google'),
                          ),
                        ],
                      );
                    }),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
