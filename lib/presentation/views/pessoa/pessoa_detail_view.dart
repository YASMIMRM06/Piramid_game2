import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:signals_flutter/signals_flutter.dart';

import '../../../core/routes/app_routes.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/formatters.dart';
import '../../../domain/models/avaliacao_entity.dart';
import '../../../domain/models/pessoa_entity.dart';
import '../../../domain/models/ranking_item.dart';
import '../../controllers/auth_viewmodel.dart';
import '../../controllers/avaliacao_viewmodel.dart';
import '../../controllers/pessoa_viewmodel.dart';
import '../../controllers/ranking_viewmodel.dart';
import '../../widgets/star_rating_widget.dart';

class PessoaDetailView extends StatefulWidget {
  final PessoaViewModel pessoaViewModel;
  final AvaliacaoViewModel avaliacaoViewModel;
  final RankingViewModel rankingViewModel;
  final AuthViewModel authViewModel;
  final Pessoa pessoa;

  const PessoaDetailView({
    super.key,
    required this.pessoaViewModel,
    required this.avaliacaoViewModel,
    required this.rankingViewModel,
    required this.authViewModel,
    required this.pessoa,
  });

  @override
  State<PessoaDetailView> createState() => _PessoaDetailViewState();
}

class _PessoaDetailViewState extends State<PessoaDetailView> {
  Avaliacao? _minhaAvaliacao;
  bool _ehVoce = false;
  bool _carregando = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _carregar());
  }

  Future<void> _carregar() async {
    setState(() => _carregando = true);
    final id = widget.pessoa.id;
    final resultados = await Future.wait([
      widget.avaliacaoViewModel.verificarAutoavaliacao(id),
      widget.avaliacaoViewModel.consultar(id),
      widget.rankingViewModel.carregarGlobal(),
    ]);
    if (!mounted) return;
    setState(() {
      _ehVoce = resultados[0] as bool;
      _minhaAvaliacao = resultados[1] as Avaliacao?;
      _carregando = false;
    });
  }

  Future<void> _avaliar(Pessoa pessoa) async {
    final alterou = await context.push<bool>(
      AppRoutes.avaliar,
      extra: (pessoa: pessoa, avaliacao: _minhaAvaliacao),
    );
    if (alterou == true) _carregar();
  }

  Future<void> _vincular(Pessoa pessoa) async {
    final result = await widget.pessoaViewModel.vincular(pessoa.id);
    if (!mounted) return;
    result.fold<void>(
      onSuccess: (_) => _carregar(),
      onFailure: (err) {
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(SnackBar(
            content: Text(err.msg),
            backgroundColor: Colors.red.shade600,
            behavior: SnackBarBehavior.floating,
          ));
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Watch((context) {
      final meuUid = widget.authViewModel.currentUser.value?.uid;
      // Versão mais recente da pessoa (o vínculo "sou eu" pode mudar).
      final pessoa = widget.pessoaViewModel.pessoas.value.firstWhere(
        (p) => p.id == widget.pessoa.id,
        orElse: () => widget.pessoa,
      );
      final souDono = pessoa.criadoPor == meuUid;
      final jaTenhoVinculo = widget.pessoaViewModel.pessoas.value
          .any((p) => p.usuarioUid != null && p.usuarioUid == meuUid);
      final podeVincular = pessoa.usuarioUid == null && !jaTenhoVinculo;

      final ranking = widget.rankingViewModel.global.value
          .where((r) => r.pessoa.id == pessoa.id)
          .firstOrNull;

      return Scaffold(
        appBar: AppBar(
          title: Text(pessoa.nome),
          actions: [
            if (souDono)
              IconButton(
                icon: const Icon(Icons.edit_outlined),
                tooltip: 'Editar',
                onPressed: () =>
                    context.push(AppRoutes.pessoaForm, extra: pessoa),
              ),
          ],
        ),
        body: SingleChildScrollView(
          padding: AppSpacing.paddingMd,
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 600),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(context, pessoa),
                  const SizedBox(height: AppSpacing.md),
                  _buildNivelLendaGlobal(context, ranking),
                  const SizedBox(height: AppSpacing.lg),
                  Text('Minha avaliação',
                      style: Theme.of(context)
                          .textTheme
                          .titleMedium
                          ?.copyWith(fontWeight: FontWeight.bold)),
                  const SizedBox(height: AppSpacing.sm),
                  if (_carregando)
                    const Center(
                        child: Padding(
                      padding: EdgeInsets.all(AppSpacing.md),
                      child: CircularProgressIndicator(),
                    ))
                  else
                    _buildMinhaAvaliacao(context, pessoa, podeVincular),
                  const SizedBox(height: AppSpacing.lg),
                ],
              ),
            ),
          ),
        ),
      );
    });
  }

  Widget _buildHeader(BuildContext context, Pessoa pessoa) {
    return Card(
      child: Padding(
        padding: AppSpacing.paddingLg,
        child: Row(
          children: [
            CircleAvatar(
              radius: 36,
              backgroundColor: AppColors.primary,
              child: Text(
                pessoa.nome.isNotEmpty ? pessoa.nome[0].toUpperCase() : '?',
                style: const TextStyle(
                    fontSize: 28,
                    color: Colors.white,
                    fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(pessoa.nome,
                      style: Theme.of(context)
                          .textTheme
                          .titleLarge
                          ?.copyWith(fontWeight: FontWeight.bold)),
                  if (pessoa.apelido.isNotEmpty)
                    Text('"${pessoa.apelido}"',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            fontStyle: FontStyle.italic, color: Colors.grey)),
                  const SizedBox(height: AppSpacing.xs),
                  Text('${pessoa.curso.displayName} · ${pessoa.turmaAno}'),
                  Text(
                    DateFormat('dd/MM/yyyy').format(pessoa.dataNascimento),
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNivelLendaGlobal(BuildContext context, RankingItem? ranking) {
    return Container(
      width: double.infinity,
      padding: AppSpacing.paddingMd,
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      child: Column(
        children: [
          const Text('🏆', style: TextStyle(fontSize: 36)),
          const SizedBox(height: AppSpacing.xs),
          Text('Nível Lenda Global',
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(color: Colors.white70)),
          Text(
            ranking == null
                ? 'Sem avaliações'
                : '${formatarPontos(ranking.pontuacao)} pontos',
            style: Theme.of(context)
                .textTheme
                .headlineMedium
                ?.copyWith(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            ranking == null
                ? '(mín: ${Avaliacao.pontuacaoMin} · máx: ${Avaliacao.pontuacaoMax})'
                : 'média de ${ranking.quantidadeAvaliacoes} '
                    '${ranking.quantidadeAvaliacoes == 1 ? 'avaliação' : 'avaliações'}',
            style: Theme.of(context)
                .textTheme
                .bodySmall
                ?.copyWith(color: Colors.white54),
          ),
        ],
      ),
    );
  }

  Widget _buildMinhaAvaliacao(
      BuildContext context, Pessoa pessoa, bool podeVincular) {
    if (_ehVoce) {
      return Card(
        child: Padding(
          padding: AppSpacing.paddingMd,
          child: Row(
            children: [
              const Icon(Icons.block, color: Colors.orange),
              const SizedBox(width: AppSpacing.sm),
              const Expanded(
                child: Text(
                    'Este cadastro é você. Não é permitido avaliar a si próprio.'),
              ),
            ],
          ),
        ),
      );
    }

    final avaliacao = _minhaAvaliacao;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (avaliacao == null)
          Card(
            child: Padding(
              padding: AppSpacing.paddingMd,
              child: Text('Você ainda não avaliou ${pessoa.nome}.',
                  style: Theme.of(context).textTheme.bodyMedium),
            ),
          )
        else
          Card(
            child: Padding(
              padding: AppSpacing.paddingMd,
              child: Column(
                children: [
                  Text(
                    'Sua nota: ${avaliacao.pontuacaoTotal} pontos',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: AppColors.primary, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  ...Criterio.values.map((c) => CriterioRow(
                        label: c.label,
                        value: avaliacao.notas[c] ?? Avaliacao.notaMin,
                        readOnly: true,
                      )),
                ],
              ),
            ),
          ),
        const SizedBox(height: AppSpacing.md),
        ElevatedButton.icon(
          onPressed: () => _avaliar(pessoa),
          icon: Icon(avaliacao == null ? Icons.star_outline : Icons.edit_outlined),
          label: Text(
              avaliacao == null ? 'Avaliar pessoa' : 'Alterar minha avaliação'),
        ),
        if (podeVincular) ...[
          const SizedBox(height: AppSpacing.sm),
          TextButton.icon(
            onPressed: () => _vincular(pessoa),
            icon: const Icon(Icons.person_pin_outlined),
            label: const Text('Esta pessoa sou eu'),
          ),
        ],
      ],
    );
  }
}
