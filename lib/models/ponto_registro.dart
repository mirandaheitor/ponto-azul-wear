enum PontoTipo {
  entrada('Entrada'),
  saida('Saída');

  const PontoTipo(this.label);

  final String label;

  static PontoTipo fromValue(String value) {
    return PontoTipo.values.firstWhere(
      (tipo) => tipo.name == value,
      orElse: () => PontoTipo.entrada,
    );
  }
}

class PontoRegistro {
  const PontoRegistro({
    required this.id,
    required this.tipo,
    required this.dataHora,
    required this.latitude,
    required this.longitude,
    required this.endereco,
    required this.sincronizado,
  });

  final String id;
  final PontoTipo tipo;
  final DateTime dataHora;
  final double latitude;
  final double longitude;
  final String endereco;
  final bool sincronizado;

  Map<String, Object?> toMap() {
    return {
      'id': id,
      'tipo': tipo.name,
      'data_hora': dataHora.toIso8601String(),
      'latitude': latitude,
      'longitude': longitude,
      'endereco': endereco,
      'sincronizado': sincronizado ? 1 : 0,
    };
  }

  factory PontoRegistro.fromMap(Map<String, Object?> map) {
    return PontoRegistro(
      id: map['id'] as String,
      tipo: PontoTipo.fromValue(map['tipo'] as String),
      dataHora: DateTime.parse(map['data_hora'] as String),
      latitude: (map['latitude'] as num).toDouble(),
      longitude: (map['longitude'] as num).toDouble(),
      endereco: (map['endereco'] as String?) ?? 'Endereço não localizado',
      sincronizado: (map['sincronizado'] as int) == 1,
    );
  }
}
