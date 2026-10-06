import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';

class StarRatingWidget extends StatelessWidget {
  final int value;
  final ValueChanged<int>? onChanged;
  final double size;

  const StarRatingWidget({
    super.key,
    required this.value,
    this.onChanged,
    this.size = 28,
  });

  @override
  Widget build(BuildContext context) {
    // Trava de UI: são desenhadas exatamente 5 estrelas, com valores fixos
    // de 1 a 5 (index + 1). Não existe um "tap target" para 0 estrelas —
    // ou seja, é fisicamente impossível pelo toque selecionar uma nota
    // menor que 1. Isso garante, só pela construção da tela, a regra do
    // enunciado: "Cada critério deve possuir nota entre 1 e 5 estrelas".
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (index) {
        final starValue = index + 1; // 1, 2, 3, 4, 5 — nunca 0
        return GestureDetector(
          onTap: onChanged != null ? () => onChanged!(starValue) : null,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 2),
            child: Icon(
              starValue <= value ? Icons.star_rounded : Icons.star_outline_rounded,
              color: starValue <= value ? AppColors.starFilled : AppColors.starEmpty,
              size: size,
            ),
          ),
        );
      }),
    );
  }
}

/// Linha com label + star rating — usada no formulário e nos detalhes
class CriterioRow extends StatelessWidget {
  final String label;
  final int value;
  final ValueChanged<int>? onChanged;
  final bool readOnly;

  const CriterioRow({
    super.key,
    required this.label,
    required this.value,
    this.onChanged,
    this.readOnly = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
          StarRatingWidget(
            value: value,
            onChanged: readOnly ? null : onChanged,
            size: 24,
          ),
        ],
      ),
    );
  }
}
