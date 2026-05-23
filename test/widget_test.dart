import 'package:flutter_test/flutter_test.dart';
import 'package:ponto_azul/models/ponto_registro.dart';

void main() {
  test('PontoRegistro serializa e desserializa corretamente', () {
    final registro = PontoRegistro(
      id: 'abc',
      tipo: PontoTipo.entrada,
      dataHora: DateTime(2026, 5, 23, 10, 30),
      latitude: -23.55,
      longitude: -46.63,
      endereco: 'Av. Paulista, 1000 - Bela Vista, São Paulo-SP',
      sincronizado: false,
    );

    final restaurado = PontoRegistro.fromMap(registro.toMap());

    expect(restaurado.id, 'abc');
    expect(restaurado.tipo, PontoTipo.entrada);
    expect(restaurado.dataHora, DateTime(2026, 5, 23, 10, 30));
    expect(restaurado.latitude, -23.55);
    expect(restaurado.longitude, -46.63);
    expect(
      restaurado.endereco,
      'Av. Paulista, 1000 - Bela Vista, São Paulo-SP',
    );
    expect(restaurado.sincronizado, isFalse);
  });
}
