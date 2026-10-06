import '../failure/failure.dart';
import '../patterns/result.dart';
import '../../domain/models/avaliacao_entity.dart';
import '../../domain/models/pessoa_entity.dart';
import '../../domain/models/ranking_item.dart';
import '../../domain/models/usuario_entity.dart';

// typedefs para Result
typedef UsuarioResult = Result<Usuario, Failure>;
typedef UsuarioOptionalResult = Result<Usuario?, Failure>;
typedef PessoaResult = Result<Pessoa, Failure>;
typedef ListPessoaResult = Result<List<Pessoa>, Failure>;
typedef AvaliacaoResult = Result<Avaliacao, Failure>;
typedef AvaliacaoOptionalResult = Result<Avaliacao?, Failure>;
typedef ListAvaliacaoResult = Result<List<Avaliacao>, Failure>;
typedef RankingResult = Result<List<RankingItem>, Failure>;
typedef BoolResult = Result<bool, Failure>;
typedef VoidResult = Result<void, Failure>;

// typedefs para parâmetros
typedef NoParams = ();
typedef CredenciaisParams = ({String email, String senha});
typedef PessoaParams = ({Pessoa pessoa});
typedef PessoaIdParams = ({String id});
typedef AvaliarParams = ({String pessoaId, Map<Criterio, int> notas});
