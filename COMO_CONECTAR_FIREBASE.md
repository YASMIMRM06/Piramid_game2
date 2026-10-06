# Conectar o PiramidGame ao Firebase

## 1. Console do Firebase (uma vez)
1. Abra https://console.firebase.google.com e use o seu projeto (ou crie um).
2. **Build > Authentication > Começar > Sign-in method**: ative **E-mail/senha** e **Google**
   (no Google, escolha o e-mail de suporte do projeto).
3. **Build > Firestore Database > Criar banco de dados** (modo produção, região `southamerica-east1`).
4. Na aba **Regras** do Firestore, cole o conteúdo do arquivo `firestore.rules` e clique em **Publicar**.

## 2. No projeto Flutter (na pasta do pubspec.yaml)
```
flutter pub get
dart pub global activate flutterfire_cli
flutterfire configure
```
- Escolha o seu projeto e as plataformas (recomendado: **android** e **web**).
- Responda **yes** para sobrescrever `lib/firebase_options.dart`.
- Se o CLI não achar `flutterfire`, adicione `%LOCALAPPDATA%\Pub\Cache\bin` ao PATH do Windows.

## 3. Google Sign-In
- **Android**: cadastre a impressão digital SHA-1 em Configurações do projeto > seu app Android.
  Para pegar: `cd android` e `./gradlew signingReport` (Windows: `gradlew signingReport`).
  Depois rode `flutterfire configure` de novo (baixa o google-services.json atualizado).
- **Web**: em Authentication > Configurações > Domínios autorizados, `localhost` já vem liberado.
- **Windows/Linux (desktop)**: login com Google não é suportado — use Chrome ou Android para testar.

## 4. Rodar
```
flutter run -d chrome
```
(ou um emulador Android). Crie uma conta, cadastre pessoas, marque "Esta pessoa sou eu" no seu
cadastro e avalie os outros.
