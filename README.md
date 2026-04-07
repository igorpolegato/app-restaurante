# Quiosque — App de Pedidos

Aplicativo Flutter para realização de pedidos em restaurante/quiosque.

---

## Pré-requisitos

Antes de começar, certifique-se de ter instalado:

- [Flutter SDK](https://docs.flutter.dev/get-started/install) versão **3.11.4 ou superior**
- [Android Studio](https://developer.android.com/studio) (necessário para o emulador Android e as ferramentas de build)
- [Git](https://git-scm.com/)

Para verificar se o Flutter está corretamente instalado, execute:

```bash
flutter doctor
```

Todos os itens relevantes devem aparecer com o símbolo `✓`. Os mais importantes são:
- Flutter
- Android toolchain
- Android Studio (ou VS Code com extensão Flutter)

---

## 1. Clonar o repositório

```bash
git clone git@github.com:igorpolegato/app-restaurante.git
cd app
```

---

## 2. Instalar os pacotes

Dentro da pasta do projeto, execute:

```bash
flutter pub get
```

Esse comando baixa todas as dependências listadas no `pubspec.yaml`:
- `dio` — requisições HTTP
- `provider` — gerenciamento de estado
- `shared_preferences` — armazenamento local da sessão
- `google_fonts` — fontes personalizadas
- `cached_network_image` — cache de imagens da rede

---

## 3. Rodar no Emulador

### 3.1 Criar e iniciar um emulador Android

1. Abra o **Android Studio**
2. Vá em **Device Manager** (ícone de celular na barra lateral direita)
3. Clique em **Create Device**
4. Escolha um dispositivo (ex: Pixel 6) e clique em **Next**
5. Selecione uma imagem de sistema (ex: API 34 — Android 14) e clique em **Next** e depois **Finish**
6. Clique no botão **Play** para iniciar o emulador

### 3.2 Verificar se o emulador foi detectado

```bash
flutter devices
```

O emulador deve aparecer na lista, por exemplo:
```
sdk gphone64 x86 64 (mobile) • emulator-5554 • android-x86_64
```

### 3.3 Rodar o app

```bash
flutter run
```

O Flutter detecta automaticamente o dispositivo disponível e faz o deploy do app.

> Durante a execução, pressione `r` para **hot reload** (recarrega alterações de UI) ou `R` para **hot restart** (reinicia o app completamente, necessário para mudanças em lógica/providers).

---

## 4. Gerar o APK

Para instalar o app diretamente em um celular Android físico, gere o APK de release:

```bash
flutter build apk --release
```

O arquivo gerado estará em:

```
build/app/outputs/flutter-apk/app-release.apk
```

### 4.1 Instalar o APK no celular

**Via cabo USB:**

1. Conecte o celular ao computador via USB
2. Ative o **Modo Desenvolvedor** no celular:
   - Vá em *Configurações > Sobre o telefone*
   - Toque 7 vezes em **Número da versão**
3. Ative a **Depuração USB** nas opções de desenvolvedor
4. Execute:

```bash
flutter install
```

Ou instale manualmente copiando o APK para o celular e abrindo o arquivo. Pode ser necessário permitir **instalação de fontes desconhecidas** nas configurações de segurança do celular.

**Via ADB (alternativa):**

```bash
adb install build/app/outputs/flutter-apk/app-release.apk
```

---

## 5. Gerar APK de debug (para testes rápidos)

Se quiser apenas testar sem otimização de release:

```bash
flutter build apk --debug
```

O arquivo estará em:
```
build/app/outputs/flutter-apk/app-debug.apk
```

---

## Comandos úteis

| Comando | Descrição |
|---|---|
| `flutter pub get` | Instala os pacotes |
| `flutter devices` | Lista dispositivos disponíveis |
| `flutter run` | Roda o app no dispositivo/emulador conectado |
| `flutter run -d emulator-5554` | Roda em um emulador específico |
| `flutter build apk --release` | Gera o APK de produção |
| `flutter clean` | Limpa os arquivos de build (útil em caso de erros) |
| `flutter doctor` | Verifica se o ambiente está configurado corretamente |
