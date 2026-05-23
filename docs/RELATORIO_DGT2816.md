# Relatório DGT2816 - Ponto Azul

## 1. Introdução

O Ponto Azul é um aplicativo Flutter desenvolvido para registrar ponto empresarial em dispositivos Android e Wear OS. O projeto foi construído com foco acadêmico, usando recursos reais de dispositivos móveis e wearables.

## 2. Objetivo

O objetivo do trabalho é demonstrar a interação com sensores e recursos de smartphones e wearables, principalmente localização GPS, permissões Android, armazenamento local offline, conectividade, sincronização posterior e feedback por áudio.

## 3. Contextualização

Sistemas de registro de ponto podem ser usados em cenários nos quais o funcionário precisa registrar entrada e saída fora de uma estação fixa. Nessas situações, o dispositivo móvel pode capturar automaticamente data, hora e localização, mantendo os dados salvos mesmo sem internet.

## 4. Tecnologias utilizadas

- Flutter;
- Dart;
- Android SDK;
- Wear OS Emulator;
- SQLite com sqflite;
- geolocator;
- geocoding;
- connectivity_plus;
- permission_handler;
- intl;
- uuid;
- flutter_tts.

## 5. Recursos e sensores utilizados

O principal recurso utilizado é a localização GPS, usada para capturar latitude e longitude no momento do registro. O projeto também utiliza conectividade de rede para simular sincronização, armazenamento local SQLite para funcionamento offline e síntese de voz para feedback ao usuário.

## 6. Funcionamento do aplicativo

O aplicativo apresenta uma tela simples com o nome Ponto Azul, data e hora atual, botões de registro de entrada, registro de saída e sincronização. Abaixo dos botões, o histórico mostra os últimos pontos registrados.

Cada registro contém tipo, data e hora, latitude, longitude, endereço formatado e status de sincronização.

## 7. Registro de ponto com GPS

Ao tocar em "Registrar Entrada" ou "Registrar Saída", o aplicativo solicita permissão de localização, tenta obter a posição atual do dispositivo e cria um registro com ID único. A data e a hora são capturadas automaticamente no momento do registro.

No Wear OS Emulator, o app utiliza tentativas compatíveis com o provedor Android de localização e também consulta a última posição conhecida quando necessário.

## 8. Conversão de localização em endereço

Após capturar latitude e longitude, o aplicativo utiliza geocodificação reversa com o pacote geocoding. O endereço é montado no formato:

```text
Rua, Número - Bairro, Cidade-UF
```

Quando algum campo não está disponível, o aplicativo evita vírgulas, hífens e espaços sobrando. Se não for possível resolver o endereço, o registro é salvo com o texto "Endereço não localizado".

## 9. Funcionamento offline

O app salva todos os registros localmente em SQLite. Mesmo sem internet, o ponto é registrado como pendente de sincronização. Isso demonstra cache local e funcionamento offline.

## 10. Sincronização simulada

A sincronização não usa backend, Firebase ou API externa. Ao tocar em "Sincronizar", o aplicativo verifica a conectividade. Se houver internet, os registros pendentes são marcados localmente como sincronizados no SQLite.

## 11. Permissões utilizadas

No AndroidManifest.xml, o projeto utiliza:

- ACCESS_FINE_LOCATION;
- ACCESS_COARSE_LOCATION;
- INTERNET;
- ACCESS_NETWORK_STATE;
- WAKE_LOCK;
- BODY_SENSORS;
- uses-feature `android.hardware.type.watch`, indicando suporte a Wear OS sem impedir execução em Android comum.

## 12. Testes realizados

Foram considerados os seguintes testes para entrega:

- Execução de `flutter pub get`;
- Execução de `flutter analyze`;
- Execução em emulador Android comum;
- Execução em emulador Wear OS;
- Registro de entrada;
- Registro de saída;
- Captura de GPS;
- Exibição de endereço no histórico;
- Funcionamento offline com registro pendente;
- Sincronização simulada com internet;
- Tratamento de ausência de permissão de localização;
- Tratamento de GPS indisponível;
- Tratamento de ausência de internet ao sincronizar.

## 13. Evidências

As evidências devem ser inseridas na pasta `docs/evidencias` antes da entrega final, usando prints do aplicativo em execução, dos emuladores e da análise estática sem erros.

## 14. Conclusão

O Ponto Azul atende à proposta da disciplina DGT2816 ao demonstrar uso de localização GPS, permissões Android, geocodificação reversa, armazenamento local SQLite, funcionamento offline, verificação de conectividade, sincronização simulada e feedback por voz. O aplicativo mantém uma interface simples e compatível com Android e Wear OS, adequada para apresentação acadêmica.
