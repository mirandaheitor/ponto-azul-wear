# Entrega do Trabalho Prático - Ponto Azul

## Nome do projeto

Ponto Azul

## Disciplina

DGT2816 - Interação com sensores de smartphones e wearables

## Descrição resumida

Aplicativo Flutter para registro de ponto empresarial em Android/Wear OS. O app registra entrada e saída, captura data, hora e localização GPS, converte coordenadas em endereço, salva dados offline em SQLite e simula a sincronização posterior.

## Tecnologias usadas

Flutter, Dart, Android SDK, Wear OS Emulator, SQLite, geolocator, geocoding, connectivity_plus, permission_handler, intl, uuid e flutter_tts.

## Funcionalidades implementadas

- Registro de entrada e saída;
- Captura automática de data e hora;
- Captura de localização GPS;
- Conversão de coordenadas em endereço;
- Histórico de pontos;
- Cache local offline com SQLite;
- Status pendente ou sincronizado;
- Sincronização simulada;
- Feedback por voz;
- Compatibilidade visual com Android e Wear OS.

## Como executar

```bash
flutter pub get
flutter devices
flutter run
```

Para executar em um emulador específico:

```bash
flutter run -d ID_DO_EMULADOR
```

## Local da documentação

- `README.md`
- `docs/RELATORIO_DGT2816.md`

## Local das evidências

- `docs/evidencias`

## Observação

A sincronização é simulada localmente, sem backend real, sem Firebase e sem API externa. O objetivo é demonstrar sensores, persistência local, funcionamento offline e conectividade.
