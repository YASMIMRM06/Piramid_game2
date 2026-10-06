// ARQUIVO PLACEHOLDER — será SUBSTITUÍDO ao rodar `flutterfire configure`.
//
// Passos (na raiz do projeto, onde fica o pubspec.yaml):
//   dart pub global activate flutterfire_cli
//   flutterfire configure
//
// O comando gera o arquivo real com as chaves do SEU projeto Firebase
// (responda "yes" quando perguntar se deseja sobrescrever este arquivo).
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    throw UnsupportedError(
      'Firebase ainda não configurado. Rode `flutterfire configure` na raiz '
      'do projeto para gerar o lib/firebase_options.dart.',
    );
  }
}
