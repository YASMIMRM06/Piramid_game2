import 'package:signals_flutter/signals_flutter.dart';

import '../../core/typedefs/types_defs.dart';
import '../../domain/facades/pessoa_facade_usecases_interface.dart';
import '../../domain/models/pessoa_entity.dart';
import '../commands/pessoa_commands.dart';

/// ViewModel do cadastro de pessoas.
class PessoaViewModel {
  final IPessoaFacadeUseCases _facade;

  PessoaViewModel(this._facade);

  // ── Estado reativo ─────────────────────────────────────────────
  final pessoas = signal<List<Pessoa>>([]);
  final isLoading = signal<bool>(false);
  final message = signal<String?>(null);

  // ── Commands ───────────────────────────────────────────────────
  late final listarCommand = ListarPessoasCommand(_facade);
  late final cadastrarCommand = CadastrarPessoaCommand(_facade);
  late final alterarCommand = AlterarPessoaCommand(_facade);
  late final removerCommand = RemoverPessoaCommand(_facade);
  late final vincularCommand = VincularPessoaCommand(_facade);

  // ── Ações chamadas pela UI ─────────────────────────────────────
  Future<void> carregar() async {
    message.value = null;
    isLoading.value = true;
    final result = await listarCommand.executeWith(());
    result.fold<void>(
      onSuccess: (lista) {
        pessoas.value = lista;
      },
      onFailure: (falha) {
        message.value = falha.msg;
      },
    );
    isLoading.value = false;
  }

  Future<PessoaResult> cadastrar(Pessoa pessoa) async {
    message.value = null;
    final result = await cadastrarCommand.executeWith((pessoa: pessoa));
    result.fold<void>(
      onSuccess: (nova) {
        pessoas.value = _ordenar([...pessoas.value, nova]);
      },
      onFailure: (falha) {
        message.value = falha.msg;
      },
    );
    return result;
  }

  Future<PessoaResult> alterar(Pessoa pessoa) async {
    message.value = null;
    final result = await alterarCommand.executeWith((pessoa: pessoa));
    result.fold<void>(
      onSuccess: (atualizada) {
        pessoas.value = _ordenar(pessoas.value
            .map((p) => p.id == atualizada.id ? atualizada : p)
            .toList());
      },
      onFailure: (falha) {
        message.value = falha.msg;
      },
    );
    return result;
  }

  Future<VoidResult> remover(String id) async {
    message.value = null;
    final result = await removerCommand.executeWith((id: id));
    result.fold<void>(
      onSuccess: (_) {
        pessoas.value = pessoas.value.where((p) => p.id != id).toList();
      },
      onFailure: (falha) {
        message.value = falha.msg;
      },
    );
    return result;
  }

  Future<PessoaResult> vincular(String id) async {
    message.value = null;
    final result = await vincularCommand.executeWith((id: id));
    result.fold<void>(
      onSuccess: (vinculada) {
        pessoas.value = pessoas.value
            .map((p) => p.id == vinculada.id ? vinculada : p)
            .toList();
      },
      onFailure: (falha) {
        message.value = falha.msg;
      },
    );
    return result;
  }

  List<Pessoa> _ordenar(List<Pessoa> lista) => lista
    ..sort((a, b) => a.nome.toLowerCase().compareTo(b.nome.toLowerCase()));
}
