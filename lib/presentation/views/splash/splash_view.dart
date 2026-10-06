import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/di/dependency_injection.dart';
import '../../../core/routes/app_routes.dart';
import '../../../core/theme/app_theme.dart';
import '../../controllers/auth_viewmodel.dart';

class SplashView extends StatefulWidget {
  const SplashView({super.key});

  @override
  State<SplashView> createState() => _SplashViewState();
}

class _SplashViewState extends State<SplashView>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _fade;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _fade = CurvedAnimation(parent: _controller, curve: Curves.easeIn);
    _scale = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutBack),
    );
    _controller.forward();
    _verificarAutenticacao();
  }

  /// Fluxo da Splash: verifica a autenticação (Firebase Auth) e direciona
  /// para a Home (usuário autenticado) ou para o Login.
  Future<void> _verificarAutenticacao() async {
    final auth = injector.get<AuthViewModel>();
    // Mantém a Splash visível por pelo menos 2s enquanto a sessão é verificada.
    await Future.wait([
      Future<void>.delayed(const Duration(seconds: 2)),
      auth.checkSession(),
    ]);
    if (!mounted) return;
    context.go(auth.isAuthenticated.value ? AppRoutes.home : AppRoutes.login);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      body: Center(
        child: FadeTransition(
          opacity: _fade,
          child: ScaleTransition(
            scale: _scale,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 110,
                  height: 110,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 16,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: const Center(
                    child: Text('🏆', style: TextStyle(fontSize: 56)),
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                const Text(
                  'PiramidGame',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                const Text(
                  'IFPR – Campus Paranaguá',
                  style: TextStyle(color: Colors.white70, fontSize: 14),
                ),
                const SizedBox(height: AppSpacing.sm),
                const Text(
                  'Ranking de Popularidade dos Alunos',
                  style: TextStyle(color: Colors.white60, fontSize: 12),
                ),
                const SizedBox(height: AppSpacing.xxl),
                const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                      color: Colors.white54, strokeWidth: 2),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
