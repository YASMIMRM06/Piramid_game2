import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/app_theme.dart';
import '../../../domain/models/pessoa_entity.dart';
import '../../controllers/auth_viewmodel.dart';
import '../../controllers/pessoa_viewmodel.dart';

/// Cadastro/edição de pessoa. A pessoa NÃO recebe notas aqui: as notas ficam
/// nas avaliações (tela de avaliar).
class PessoaFormView extends StatefulWidget {
  final PessoaViewModel viewModel;
  final AuthViewModel authViewModel;
  final Pessoa? pessoaToEdit;

  const PessoaFormView({
    super.key,
    required this.viewModel,
    required this.authViewModel,
    this.pessoaToEdit,
  });

  @override
  State<PessoaFormView> createState() => _PessoaFormViewState();
}

class _PessoaFormViewState extends State<PessoaFormView> {
  final _formKey = GlobalKey<FormState>();
  final _nomeController = TextEditingController();
  final _apelidoController = TextEditingController();

  Curso _cursoSelecionado = Curso.tads;
  int _turmaSelecionada = 2024;
  DateTime _dataNascimento = DateTime(2000, 1, 1);
  bool _souEu = false;
  bool _salvando = false;

  bool get _isEditing => widget.pessoaToEdit != null;
  String? get _meuUid => widget.authViewModel.currentUser.value?.uid;

  /// O checkbox "Esta pessoa sou eu" só aparece se ainda não houver vínculo
  /// com a conta de outro usuário.
  bool get _mostrarSouEu {
    final p = widget.pessoaToEdit;
    return p == null || p.usuarioUid == null || p.usuarioUid == _meuUid;
  }

  @override
  void initState() {
    super.initState();
    final p = widget.pessoaToEdit;
    if (p != null) {
      _nomeController.text = p.nome;
      _apelidoController.text = p.apelido;
      _cursoSelecionado = p.curso;
      _turmaSelecionada = p.turmaAno;
      _dataNascimento = p.dataNascimento;
      _souEu = p.usuarioUid != null && p.usuarioUid == _meuUid;
    }
  }

  @override
  void dispose() {
    _nomeController.dispose();
    _apelidoController.dispose();
    super.dispose();
  }

  Pessoa _buildPessoa() {
    final existente = widget.pessoaToEdit;
    return Pessoa(
      // No cadastro, o id e o criadoPor são definidos pelo use case.
      id: existente?.id ?? '',
      nome: _nomeController.text.trim(),
      apelido: _apelidoController.text.trim(),
      curso: _cursoSelecionado,
      turmaAno: _turmaSelecionada,
      dataNascimento: _dataNascimento,
      criadoPor: existente?.criadoPor ?? '',
      usuarioUid: _souEu ? _meuUid : null,
    );
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _salvando = true);

    final pessoa = _buildPessoa();
    final result = _isEditing
        ? await widget.viewModel.alterar(pessoa)
        : await widget.viewModel.cadastrar(pessoa);

    if (!mounted) return;
    setState(() => _salvando = false);

    result.fold<void>(
      onSuccess: (_) {
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(
            SnackBar(
              content: Text(_isEditing
                  ? 'Pessoa atualizada com sucesso!'
                  : 'Pessoa cadastrada com sucesso!'),
              backgroundColor: Colors.green.shade600,
              behavior: SnackBarBehavior.floating,
              duration: const Duration(seconds: 2),
            ),
          );
        context.pop();
      },
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

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _dataNascimento,
      firstDate: DateTime(1950),
      lastDate: DateTime.now(),
    );
    if (picked != null) setState(() => _dataNascimento = picked);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Editar Pessoa' : 'Nova Pessoa'),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: AppSpacing.paddingMd,
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 600),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Dados da Pessoa',
                      style: Theme.of(context)
                          .textTheme
                          .titleMedium
                          ?.copyWith(fontWeight: FontWeight.bold)),
                  const SizedBox(height: AppSpacing.sm),
                  TextFormField(
                    controller: _nomeController,
                    decoration: const InputDecoration(
                        labelText: 'Nome *',
                        prefixIcon: Icon(Icons.person_outline)),
                    validator: (v) => (v == null || v.trim().isEmpty)
                        ? 'Nome é obrigatório'
                        : null,
                    textCapitalization: TextCapitalization.words,
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  TextFormField(
                    controller: _apelidoController,
                    decoration: const InputDecoration(
                        labelText: 'Apelido',
                        prefixIcon: Icon(Icons.badge_outlined)),
                    textCapitalization: TextCapitalization.words,
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  DropdownButtonFormField<Curso>(
                    value: _cursoSelecionado,
                    decoration: const InputDecoration(
                        labelText: 'Curso',
                        prefixIcon: Icon(Icons.school_outlined)),
                    items: Curso.values
                        .map((c) => DropdownMenuItem(
                            value: c, child: Text(c.displayName)))
                        .toList(),
                    onChanged: (v) => setState(() => _cursoSelecionado = v!),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  DropdownButtonFormField<int>(
                    value: _turmaSelecionada,
                    decoration: const InputDecoration(
                        labelText: 'Turma/Ano',
                        prefixIcon: Icon(Icons.calendar_today_outlined)),
                    items: List.generate(
                            Pessoa.turmaMax - Pessoa.turmaMin + 1,
                            (i) => Pessoa.turmaMin + i)
                        .map((y) =>
                            DropdownMenuItem(value: y, child: Text('$y')))
                        .toList(),
                    onChanged: (v) => setState(() => _turmaSelecionada = v!),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                    leading: const Icon(Icons.cake_outlined),
                    title: const Text('Data de Nascimento'),
                    subtitle:
                        Text(DateFormat('dd/MM/yyyy').format(_dataNascimento)),
                    trailing: const Icon(Icons.edit_calendar_outlined),
                    onTap: _pickDate,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppRadius.sm),
                      side: BorderSide(color: Colors.grey.shade400),
                    ),
                  ),
                  if (_mostrarSouEu) ...[
                    const SizedBox(height: AppSpacing.md),
                    CheckboxListTile(
                      contentPadding: EdgeInsets.zero,
                      controlAffinity: ListTileControlAffinity.leading,
                      value: _souEu,
                      onChanged: (v) => setState(() => _souEu = v ?? false),
                      title: const Text('Esta pessoa sou eu'),
                      subtitle: const Text(
                          'Vincula o cadastro à sua conta e impede que você '
                          'avalie a si próprio.'),
                    ),
                  ],
                  const SizedBox(height: AppSpacing.lg),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _salvando ? null : _save,
                      icon: _salvando
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(strokeWidth: 2))
                          : Icon(_isEditing ? Icons.save_outlined : Icons.add),
                      label: Text(
                          _isEditing ? 'Salvar alterações' : 'Cadastrar pessoa'),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
