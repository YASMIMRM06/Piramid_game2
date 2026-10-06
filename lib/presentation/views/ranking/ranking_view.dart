import 'package:flutter/material.dart';
import 'package:signals_flutter/signals_flutter.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/utils/formatters.dart';
import '../../../domain/models/avaliacao_entity.dart';
import '../../../domain/models/ranking_item.dart';
import '../../controllers/ranking_viewmodel.dart';

/// Qual ranking exibir.
enum RankingType { pessoal, global }

class RankingView extends StatefulWidget {
  final RankingViewModel viewModel;
  final RankingType tipo;
  const RankingView({super.key, required this.viewModel, required this.tipo});

  @override
  State<RankingView> createState() => _RankingViewState();
}

class _RankingViewState extends State<RankingView> {
  bool get _ehGlobal => widget.tipo == RankingType.global;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _carregar());
  }

  Future<void> _carregar() =>
      _ehGlobal ? widget.viewModel.carregarGlobal() : widget.viewModel.carregarPessoal();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_ehGlobal ? 'Ranking Global' : 'Ranking Pessoal'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Atualizar',
            onPressed: _carregar,
          ),
        ],
      ),
      body: Watch((_) {
        final vm = widget.viewModel;
        if (vm.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }
        final ranking = _ehGlobal ? vm.global.value : vm.personal.value;
        if (ranking.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('🏆', style: TextStyle(fontSize: 64)),
                  const SizedBox(height: 16),
                  Text(
                    _ehGlobal
                        ? 'Ninguém foi avaliado ainda.'
                        : 'Você ainda não avaliou ninguém.',
                    textAlign: TextAlign.center,
                  ),
                  if (vm.message.value != null) ...[
                    const SizedBox(height: 8),
                    Text(vm.message.value!,
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: Colors.red)),
                  ],
                ],
              ),
            ),
          );
        }

        return CustomScrollView(
          slivers: [
            // ── Explicação do ranking ────────────────────────────
            SliverToBoxAdapter(child: _RankingBanner(global: _ehGlobal)),

            // ── Pódio top 3 ──────────────────────────────────────
            if (ranking.length >= 3)
              SliverToBoxAdapter(
                child: _PodiumSection(ranking: ranking),
              ),

            // ── Separador ────────────────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
                child: Row(
                  children: [
                    const Icon(Icons.star, size: 16, color: AppColors.primary),
                    const SizedBox(width: 6),
                    Text(
                      ranking.length >= 3
                          ? 'Outros participantes'
                          : 'Classificação',
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // ── Lista a partir do 4º (ou todos se < 3) ───────────
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, i) {
                    final startIndex = ranking.length >= 3 ? 3 : 0;
                    final item = ranking[startIndex + i];
                    final position = startIndex + i + 1;
                    return _RankingListTile(
                      position: position,
                      item: item,
                      mostrarQuantidade: _ehGlobal,
                    );
                  },
                  childCount: ranking.length >= 3
                      ? ranking.length - 3
                      : ranking.length,
                ),
              ),
            ),
          ],
        );
      }),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Pódio visual para 1º, 2º e 3º
// ─────────────────────────────────────────────────────────────
class _PodiumSection extends StatelessWidget {
  final List<RankingItem> ranking;
  const _PodiumSection({required this.ranking});

  @override
  Widget build(BuildContext context) {
    final first = ranking[0];
    final second = ranking[1];
    final third = ranking[2];

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primaryDark, AppColors.primary],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppRadius.lg),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.35),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          const Text(
            '🏆 Top 3 - Nível Lenda',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 15,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 20),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              // 2º lugar
              Expanded(child: _PodiumSlot(position: 2, item: second, height: 90)),
              const SizedBox(width: 8),
              // 1º lugar — mais alto
              Expanded(child: _PodiumSlot(position: 1, item: first, height: 120)),
              const SizedBox(width: 8),
              // 3º lugar
              Expanded(child: _PodiumSlot(position: 3, item: third, height: 70)),
            ],
          ),
        ],
      ),
    );
  }
}

class _PodiumSlot extends StatelessWidget {
  final int position;
  final RankingItem item;
  final double height;

  const _PodiumSlot({
    required this.position,
    required this.item,
    required this.height,
  });

  Color get _color {
    if (position == 1) return AppColors.gold;
    if (position == 2) return AppColors.silver;
    return AppColors.bronze;
  }

  String get _emoji {
    if (position == 1) return '🥇';
    if (position == 2) return '🥈';
    return '🥉';
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Avatar
        Container(
          width: 52,
          height: 52,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: _color,
            border: Border.all(color: Colors.white, width: 2.5),
            boxShadow: [
              BoxShadow(
                color: _color.withOpacity(0.5),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Center(
            child: Text(
              item.pessoa.nome.isNotEmpty ? item.pessoa.nome[0].toUpperCase() : '?',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          item.pessoa.nome.split(' ').first,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
            fontSize: 12,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.center,
        ),
        Text(
          '${formatarPontos(item.pontuacao)} pts',
          style: TextStyle(
            color: _color,
            fontWeight: FontWeight.bold,
            fontSize: 13,
          ),
        ),
        const SizedBox(height: 8),
        // Coluna do pódio
        Container(
          height: height,
          decoration: BoxDecoration(
            color: _color.withOpacity(0.25),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
            border: Border.all(color: _color.withOpacity(0.6), width: 1.5),
          ),
          child: Center(
            child: Text(
              _emoji,
              style: const TextStyle(fontSize: 28),
            ),
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Card para posições 4+ 
// ─────────────────────────────────────────────────────────────
class _RankingListTile extends StatelessWidget {
  final int position;
  final RankingItem item;
  final bool mostrarQuantidade;

  const _RankingListTile({
    required this.position,
    required this.item,
    required this.mostrarQuantidade,
  });

  @override
  Widget build(BuildContext context) {
    final percent = (item.pontuacao / Avaliacao.pontuacaoMax).clamp(0.0, 1.0);

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(AppRadius.md),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Número da posição
          SizedBox(
            width: 32,
            child: Text(
              '${position}º',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
                color: Colors.grey,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(width: 10),
          // Avatar
          CircleAvatar(
            radius: 20,
            backgroundColor: AppColors.primary.withOpacity(0.15),
            child: Text(
              item.pessoa.nome.isNotEmpty ? item.pessoa.nome[0].toUpperCase() : '?',
              style: const TextStyle(
                color: AppColors.primary,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
          const SizedBox(width: 12),
          // Nome + barra de progresso
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.pessoa.nome,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  '"${item.pessoa.apelido}" · ${item.pessoa.curso.displayName} ${item.pessoa.turmaAno}',
                  style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
                ),
                const SizedBox(height: 5),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: percent,
                    minHeight: 5,
                    backgroundColor: AppColors.primary.withOpacity(0.12),
                    valueColor: const AlwaysStoppedAnimation(AppColors.primaryLight),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          // Pontuação
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                formatarPontos(item.pontuacao),
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
              Text(
                mostrarQuantidade
                    ? '${item.quantidadeAvaliacoes} '
                        '${item.quantidadeAvaliacoes == 1 ? 'avaliação' : 'avaliações'}'
                    : 'pts',
                style: const TextStyle(fontSize: 10, color: Colors.grey),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Explica a diferença entre Ranking Pessoal e Ranking Global
// ─────────────────────────────────────────────────────────────
class _RankingBanner extends StatelessWidget {
  final bool global;
  const _RankingBanner({required this.global});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.08),
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: AppColors.primary.withOpacity(0.25)),
      ),
      child: Row(
        children: [
          Icon(global ? Icons.public : Icons.person_search_outlined,
              color: AppColors.primary),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  global
                      ? '"Na opinião dos usuários do aplicativo, quem possui o maior Nível Lenda?"'
                      : '"Na minha opinião, quem possui o maior Nível Lenda?"',
                  style: const TextStyle(
                      fontStyle: FontStyle.italic, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 4),
                Text(
                  global
                      ? 'Média das avaliações de todos os usuários.'
                      : 'Considera apenas as avaliações que você fez.',
                  style: const TextStyle(fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
