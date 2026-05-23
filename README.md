# Ponto Azul

## Descrição

O Ponto Azul é um aplicativo Flutter para registro de ponto empresarial em Android e Wear OS. O app registra entrada e saída, captura data, hora e localização GPS, converte latitude e longitude em endereço, salva os dados offline em SQLite e simula a sincronização dos registros pendentes quando há conexão com a internet.

## Objetivo Acadêmico

O projeto foi desenvolvido para a disciplina DGT2816 - Interação com sensores de smartphones e wearables. O objetivo é demonstrar o uso de sensores e recursos de dispositivos móveis e vestíveis, incluindo localização GPS, permissões Android, armazenamento local, conectividade e feedback por voz.

## Funcionalidades

- Registro de entrada;
- Registro de saída;
- Captura de data e hora;
- Captura de localização GPS;
- Conversão de latitude/longitude em endereço;
- Histórico de pontos;
- Funcionamento offline;
- Cache local com SQLite;
- Sincronização simulada;
- Feedback por voz;
- Compatibilidade com Android/Wear OS.

## Tecnologias Utilizadas

- Flutter;
- Dart;
- Android SDK;
- Wear OS Emulator;
- SQLite;
- geolocator;
- geocoding;
- connectivity_plus;
- permission_handler;
- intl;
- uuid;
- flutter_tts.

## Estrutura do Projeto

- `lib/main.dart`: interface principal, fluxo de registro, sincronização e histórico.
- `lib/models`: modelo `PontoRegistro`, usado para representar cada ponto registrado.
- `lib/database`: camada SQLite responsável por salvar e consultar os registros locais.
- `lib/services`: serviços de localização, endereço, sincronização e feedback por voz.
- `docs`: relatório acadêmico e evidências da execução do app.

## Como Executar o Projeto

Instale as dependências:

```bash
flutter pub get
```

Liste os dispositivos disponíveis:

```bash
flutter devices
```

Execute o aplicativo:

```bash
flutter run
```

## Como Executar no Emulador Wear OS

1. Abra o Android Studio.
2. Acesse `Device Manager`.
3. Crie ou inicie um emulador Wear OS.
4. No terminal, rode:

```bash
flutter devices
```

5. Execute usando o ID do emulador:

```bash
flutter run -d ID_DO_EMULADOR
```

No emulador Wear OS, envie uma posição em `Extended Controls > Location` antes de testar o registro com GPS.

## Testes Realizados

- `flutter pub get`;
- `flutter analyze`;
- execução em emulador Android;
- execução planejada/testada em Wear OS;
- registro de entrada e saída;
- exibição do histórico;
- sincronização simulada dos registros pendentes.

## Evidências

Os prints da entrega devem ser adicionados na pasta `docs/evidencias`, incluindo:

- App aberto;
- Registro de entrada;
- Registro de saída;
- Histórico;
- Endereço obtido por GPS;
- Sincronização;
- Emulador Android/Wear OS;
- `flutter analyze`.

## Autor

Nome: Heitor Maschio

## Observação

A sincronização é simulada localmente, sem backend real, sem Firebase e sem API externa. Essa escolha atende ao objetivo acadêmico de demonstrar sensores, persistência local e conectividade sem expor dados reais de funcionários.
