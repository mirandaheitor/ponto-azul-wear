import 'package:flutter_tts/flutter_tts.dart';

class TtsService {
  final FlutterTts _tts = FlutterTts();

  Future<void> falarPontoRegistrado() async {
    try {
      await _tts
          .setLanguage('pt-BR')
          .timeout(const Duration(milliseconds: 800));
      await _tts.setSpeechRate(0.45).timeout(const Duration(milliseconds: 800));
      await _tts
          .speak('Ponto registrado com sucesso')
          .timeout(const Duration(seconds: 2));
    } on Exception {
      return;
    }
  }
}
