import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:signals_flutter/signals_flutter.dart';

import '../../../core/di/dependency_injection.dart';
import '../../../core/routes/app_routes.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/theme/theme_controller.dart';
import '../../../core/utils/formatters.dart';
import '../../../domain/models/pessoa_entity.dart';
import '../../../domain/models/ranking_item.dart';
import '../../controllers/auth_viewmodel.dart';
import '../../controllers/pessoa_viewmodel.dart';
import '../../controllers/ranking_viewmodel.dart';

/// Área principal: lista de pessoas + menu lateral (Ranking Pessoal,
/// Ranking Global, Sobre, Tema e Logout).
class HomeView extends StatefulWidget {
  final PessoaViewModel pessoaViewModel;
  final RankingViewModel rankingViewModel;
  final AuthViewModel authViewModel;

  const HomeView({
    super.key,
    required this.pessoaViewModel,
    required this.rankingViewModel,
    required this.authViewModel,
  });

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _carregar());
  }

  Future<void> _carregar() async {
    await Future.wait([
      widget.pessoaViewModel.carregar(),
      widget.rankingViewModel.carregarGlobal(),
    ]);
    if (!mounted) return;
    final erro = widget.pessoaViewModel.message.value;
    if (erro != null) _mostrarMensagem(erro, erro: true);
  }

  void _mostrarMensagem(String texto, {bool erro = false}) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(
        content: Text(texto),
        backgroundColor: erro ? Colors.red.shade600 : Colors.green.shade600,
        behavior: SnackBarBehavior.floating,
      ));
  }

  Future<void> _logout() async {
    await widget.authViewModel.logout();
    if (!mounted) return;
    context.go(AppRoutes.login);
  }

  void _irPara(String rota) {
    Navigator.pop(context); // fecha o Drawer
    context.push(rota);
  }

  @override
  Widget build(BuildContext context) {
    final themeController = injector.get<ThemeController>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('PiramidGame IFPR-Pgua'),
        actions: [
          Watch((_) => IconButton(
                icon: Icon(themeController.isLightMode.value
                    ? Icons.dark_mode_outlined
                    : Icons.light_mode_outlined),
                tooltip: 'Alternar tema',
                onPressed: themeController.toggleTheme,
              )),
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Atualizar',
            onPressed: _carregar,
          ),
        ],
      ),
      drawer: _buildDrawer(themeController),
      body: Watch((_) {
        if (widget.pessoaViewModel.isLoading.value &&
            widget.pessoaViewModel.pessoas.value.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }
        final pessoas = widget.pessoaViewModel.pessoas.value;
        final meuUid = widget.authViewModel.currentUser.value?.uid;
        final globalPorPessoa = {
          for (final item in widget.rankingViewModel.global.value)
            item.pessoa.id: item,
        };

        if (pessoas.isEmpty) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('🏫', style: TextStyle(fontSize: 64)),
                const SizedBox(height: AppSpacing.md),
                Text('Nenhuma pessoa cadastrada ainda.',
                    style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: AppSpacing.sm),
                Text('Toque no + para cadastrar a primeira!',
                    style: Theme.of(context).textTheme.bodySmall),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: _carregar,
          child: ListView.builder(
            padding: AppSpacing.paddingMd.copyWith(bottom: 96),
            itemCount: pessoas.length,
            itemBuilder: (context, index) {
              final pessoa = pessoas[index];
              final souDono = pessoa.criadoPor == meuUid;
              return _PessoaCard(
                pessoa: pessoa,
                ranking: globalPorPessoa[pessoa.id],
                ehVoce: meuUid != null && pessoa.usuarioUid == meuUid,
                podeEditar: souDono,
                onTap: () => context.push(AppRoutes.pessoaDetail, extra: pessoa),
                onEdit: () => context.push(AppRoutes.pessoaForm, extra: pessoa),
                onDelete: () => _confirmarRemocao(pessoa),
              );
            },
          ),
        );
      }),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.primary,
        onPressed: () => context.push(AppRoutes.pessoaForm),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildDrawer(ThemeController themeController) {
    return Drawer(
      child: SafeArea(
        child: Column(
          children: [
            Watch((_) {
              final usuario = widget.authViewModel.currentUser.value;
              return UserAccountsDrawerHeader(
                decoration: const BoxDecoration(color: AppColors.primary),
                accountName: Text(usuario?.nome ?? ''),
                accountEmail: Text(usuario?.email ?? ''),
                currentAccountPicture: CircleAvatar(
                  backgroundColor: Colors.white,
                  backgroundImage:
                      usuario?.foto != null ? NetworkImage(usuario!.foto!) : null,
                  child: usuario?.foto == null
                      ? Text(
                          (usuario?.nome.isNotEmpty ?? false)
                              ? usuario!.nome[0].toUpperCase()
                              : '?',
                          style: const TextStyle(
                              color: AppColors.primary,
                              fontWeight: FontWeight.bold,
                              fontSize: 24),
                        )
                      : null,
                ),
              );
            }),
            ListTile(
              leading: const Icon(Icons.people_outline),
              title: const Text('Pessoas'),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              leading: const Icon(Icons.person_search_outlined),
              title: const Text('Ranking Pessoal'),
              onTap: () => _irPara(AppRoutes.rankingPessoal),
            ),
            ListTile(
              leading: const Icon(Icons.public),
              title: const Text('Ranking Global'),
              onTap: () => _irPara(AppRoutes.rankingGlobal),
            ),
            ListTile(
              leading: const Icon(Icons.info_outline),
              title: const Text('Sobre o App'),
              onTap: () => _irPara(AppRoutes.about),
            ),
            Watch((_) => SwitchListTile(
                  secondary: const Icon(Icons.brightness_6_outlined),
                  title: const Text('Tema escuro'),
                  value: !themeController.isLightMode.value,
                  onChanged: (_) => themeController.toggleTheme(),
                )),
            const Spacer(),
            const Divider(height: 1),
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.red),
              title: const Text('Sair', style: TextStyle(color: Colors.red)),
              onTap: _logout,
            ),
          ],
        ),
      ),
    );
  }

  void _confirmarRemocao(Pessoa pessoa) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Remover pessoa'),
        content: Text(
            'Deseja remover ${pessoa.nome} (${pessoa.apelido})? '
            'As avaliações recebidas por ela também serão apagadas.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancelar')),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              Navigator.pop(ctx);
              final result =
                  await widget.pessoaViewModel.remover(pessoa.id);
              if (!mounted) return;
              result.fold<void>(
                onSuccess: (_) {
                  _mostrarMensagem('Pessoa removida.');
                  widget.rankingViewModel.carregarGlobal();
                },
                onFailure: (err) => _mostrarMensagem(err.msg, erro: true),
              );
            },
            child: const Text('Remover'),
          ),
        ],
      ),
    );
  }
}

class _PessoaCard extends StatelessWidget {
  final Pessoa pessoa;
  final RankingItem? ranking;
  final bool ehVoce;
  final bool podeEditar;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _PessoaCard({
    required this.pessoa,
    required this.ranking,
    required this.ehVoce,
    required this.podeEditar,
    required this.onTap,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: ListTile(
        onTap: onTap,
        leading: CircleAvatar(
          backgroundColor: AppColors.primary,
          child: Text(
            pessoa.nome.isNotEmpty ? pessoa.nome[0].toUpperCase() : '?',
            style: const TextStyle(
                color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ),
        title: Row(
          children: [
            Flexible(
              child: Text(pessoa.nome,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontWeight: FontWeight.w600)),
            ),
            if (ehVoce) ...[
              const SizedBox(width: 6),
              const Chip(
                label: Text('Você', style: TextStyle(fontSize: 10)),
                visualDensity: VisualDensity.compact,
                padding: EdgeInsets.zero,
              ),
            ],
          ],
        ),
        subtitle: Text(
            '${pessoa.apelido} · ${pessoa.curso.displayName} ${pessoa.turmaAno}'),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  ranking == null ? '—' : formatarPontos(ranking!.pontuacao),
                  style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      color: AppColors.primary),
                ),
                Text(
                  ranking == null
                      ? 'sem avaliações'
                      : '${ranking!.quantidadeAvaliacoes} aval.',
                  style: const TextStyle(fontSize: 10, color: Colors.grey),
                ),
              ],
            ),
            if (podeEditar)
              PopupMenuButton<String>(
                onSelected: (value) {
                  if (value == 'edit') onEdit();
                  if (value == 'delete') onDelete();
                },
                itemBuilder: (_) => const [
                  PopupMenuItem(value: 'edit', child: Text('Editar')),
                  PopupMenuItem(
                      value: 'delete',
                      child:
                          Text('Remover', style: TextStyle(color: Colors.red))),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
