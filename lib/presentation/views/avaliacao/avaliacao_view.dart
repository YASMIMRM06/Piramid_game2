import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_theme.dart';
import '../../../domain/models/avaliacao_entity.dart';
import '../../../domain/models/pessoa_entity.dart';
import '../../controllers/avaliacao_viewmodel.dart';
import '../../widgets/star_rating_widget.dart';

/// Interface para avaliar (ou alterar a avaliação de) uma pessoa:
/// 15 critérios com Star Rating de 1 a 5.
class AvaliacaoView extends StatefulWidget {
  final AvaliacaoViewModel viewModel;
  final Pessoa pessoa;
  final Avaliacao? avaliacaoExistente;

  const AvaliacaoView({
    super.key,
    required this.viewModel,
    required this.pessoa,
    this.avaliacaoExistente,
  });

  @override
  State<AvaliacaoView> createState() => _AvaliacaoViewState();
}

class _AvaliacaoViewState extends State<AvaliacaoView> {
  late final Map<Criterio, int> _notas;
  bool _salvando = false;

  bool get _isEditing => widget.avaliacaoExistente != null;

  int get _nivelLendaPreview => _notas.values.fold(0, (soma, n) => soma + n);

  @override
  void initState() {
    super.initState();
    final existente = widget.avaliacaoExistente;
    _notas = {
      for (final c in Criterio.values)
        c: existente?.notas[c] ?? Avaliacao.notaMin,
    };
  }

  Future<void> _salvar() async {
    setState(() => _salvando = true);

    final result = await widget.viewModel.salvarAvaliacao(
      pessoaId: widget.pessoa.id,
      notas: Map<Criterio, int>.from(_notas),
      jaAvaliada: _isEditing,
    );

    if (!mounted) return;
    setState(() => _salvando = false);

    result.fold<void>(
      onSuccess: (_) {
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(SnackBar(
            content: Text(_isEditing
                ? 'Avaliação atualizada com sucesso!'
                : 'Avaliação registrada com sucesso!'),
            backgroundColor: Colors.green.shade600,
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 2),
          ));
        context.pop(true); // informa a tela anterior que houve alteração
      },
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
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Alterar avaliação' : 'Avaliar pessoa'),
      ),
      body: SingleChildScrollView(
        padding: AppSpacing.paddingMd,
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Card(
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: AppColors.primary,
                      child: Text(
                        widget.pessoa.nome.isNotEmpty
                            ? widget.pessoa.nome[0].toUpperCase()
                            : '?',
                        style: const TextStyle(
                            color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                    ),
                    title: Text(widget.pessoa.nome,
                        style: const TextStyle(fontWeight: FontWeight.w600)),
                    subtitle: Text(
                        '${widget.pessoa.apelido} · ${widget.pessoa.curso.displayName} ${widget.pessoa.turmaAno}'),
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                Text('Critérios de Popularidade',
                    style: Theme.of(context)
                        .textTheme
                        .titleMedium
                        ?.copyWith(fontWeight: FontWeight.bold)),
                const SizedBox(height: AppSpacing.xs),
                Text('Avalie de 1 a 5 estrelas em cada critério',
                    style: Theme.of(context).textTheme.bodySmall),
                const SizedBox(height: AppSpacing.sm),
                Card(
                  child: Padding(
                    padding: AppSpacing.paddingMd,
                    child: Column(
                      children: Criterio.values
                          .map((c) => CriterioRow(
                                label: c.label,
                                value: _notas[c]!,
                                onChanged: (v) => setState(() => _notas[c] = v),
                              ))
                          .toList(),
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                Container(
                  width: double.infinity,
                  padding: AppSpacing.paddingMd,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(AppRadius.md),
                    border:
                        Border.all(color: AppColors.primary.withOpacity(0.3)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text('🏆 Nível Lenda: ',
                          style: TextStyle(fontWeight: FontWeight.w600)),
                      Text('$_nivelLendaPreview pontos',
                          style: const TextStyle(
                              color: AppColors.primary,
                              fontWeight: FontWeight.bold,
                              fontSize: 18)),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _salvando ? null : _salvar,
                    icon: _salvando
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2))
                        : Icon(_isEditing ? Icons.save_outlined : Icons.check),
                    label: Text(
                        _isEditing ? 'Salvar alterações' : 'Registrar avaliação'),
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
