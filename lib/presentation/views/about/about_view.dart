import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';

class AboutView extends StatelessWidget {
  const AboutView({super.key});

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Sobre o App')),
      body: SingleChildScrollView(
        padding: AppSpacing.paddingMd,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Column(
                children: [
                  const Text('🏆', style: TextStyle(fontSize: 64)),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    'PiramidGame IFPR-Pgua',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    'Ranking de Popularidade do Campus',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
            _Section(
              icon: Icons.info_outline,
              title: 'Objetivo',
              content:
                  'O PiramidGame IFPR-Pgua é um aplicativo desenvolvido em Flutter para fins didáticos. '
                  'Ele permite cadastrar pessoas do IFPR – Campus Paranaguá e avaliá-las em '
                  'critérios descontraídos de convivência, destaque e participação.',
            ),
            _Section(
              icon: Icons.school_outlined,
              title: 'Contexto',
              content:
                  'O app é voltado para o IFPR – Campus Paranaguá, abrangendo os cursos '
                  'INFO, MEC, MAMB, PROD, TADS e TGA. Cada pessoa é vinculada ao seu curso '
                  'e turma/ano (1998 a 2026).',
            ),
            _Section(
              icon: Icons.star_outline,
              title: 'Critérios de Popularidade',
              content:
                  'Cada avaliação atribui notas de 1 a 5 estrelas em 15 categorias: Resenha, '
                  'Presença VIP, Aura, Modo Parceiro, Carisma Natural, Humor de Milhões, '
                  'Energia de Grupo, Criatividade Caótica, Modo Atleta, Talento de Palco, '
                  'Drip Escolar, Coração de Dorama, Queridinho dos Professores, Cérebro Turbo '
                  'e Caos Controlado.',
            ),
            _Section(
              icon: Icons.emoji_events_outlined,
              title: 'Nível Lenda',
              content:
                  'A soma das notas dos 15 critérios forma o Nível Lenda, de 15 (mínimo) a 75 '
                  '(máximo). Você não pode avaliar a si próprio e só pode ter uma avaliação '
                  'ativa por pessoa — para mudar de opinião, altere a avaliação existente.',
            ),
            _Section(
              icon: Icons.person_search_outlined,
              title: 'Ranking Pessoal',
              content:
                  'Baseado exclusivamente nas avaliações que você realizou. Responde: '
                  '"Na minha opinião, quem possui o maior Nível Lenda?"',
            ),
            _Section(
              icon: Icons.public,
              title: 'Ranking Global',
              content:
                  'Considera as avaliações de todos os usuários. A pontuação de cada pessoa é '
                  'a média das avaliações recebidas, ordenada da maior para a menor, junto com '
                  'a quantidade de avaliações.',
            ),
            _Section(
              icon: Icons.cloud_outlined,
              title: 'Firestore',
              content:
                  'Usuários, pessoas cadastradas e avaliações ficam armazenados remotamente no '
                  'Cloud Firestore, então você acessa os mesmos dados em qualquer dispositivo. '
                  'O SharedPreferences guarda apenas a preferência de tema.',
            ),
            _Section(
              icon: Icons.lock_outline,
              title: 'Firebase Authentication',
              content:
                  'O acesso é feito com e-mail e senha ou com conta Google, por meio do '
                  'Firebase Authentication. A senha nunca é armazenada no aparelho.',
            ),
            _Section(
              icon: Icons.brightness_6_outlined,
              title: 'Tema Claro e Escuro',
              content:
                  'O aplicativo suporta alternância entre tema claro e tema escuro em '
                  'tempo de execução pelo ícone na barra superior.',
            ),
            const SizedBox(height: AppSpacing.xl),
            Container(
              width: double.infinity,
              padding: AppSpacing.paddingMd,
              decoration: BoxDecoration(
                color: color.primaryContainer,
                borderRadius: BorderRadius.circular(AppRadius.md),
              ),
              child: Text(
                'Desenvolvido na disciplina de Dispositivos Móveis\nTADS – IFPR Campus Paranaguá',
                textAlign: TextAlign.center,
                style: TextStyle(
                    color: color.onPrimaryContainer, fontSize: 13),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
          ],
        ),
      ),
    );
  }
}

class _Section extends StatelessWidget {
  final IconData icon;
  final String title;
  final String content;

  const _Section({
    required this.icon,
    required this.title,
    required this.content,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: AppColors.primary, size: 20),
              const SizedBox(width: AppSpacing.sm),
              Text(
                title,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            content,
            style: Theme.of(context)
                .textTheme
                .bodyMedium
                ?.copyWith(height: 1.6),
          ),
        ],
      ),
    );
  }
}
