import 'package:geocoding/geocoding.dart';

class AddressService {
  static const enderecoNaoLocalizado = 'Endereço não localizado';

  Future<String> obterEndereco(double latitude, double longitude) async {
    try {
      final placemarks = await placemarkFromCoordinates(
        latitude,
        longitude,
      ).timeout(const Duration(seconds: 5));
      if (placemarks.isEmpty) {
        return enderecoNaoLocalizado;
      }

      final placemark = placemarks.first;
      final rua = _firstNotEmpty([placemark.thoroughfare, placemark.street]);
      final numero = _clean(placemark.subThoroughfare);
      final bairro = _clean(placemark.subLocality);
      final cidade = _firstNotEmpty([
        placemark.subAdministrativeArea,
        placemark.locality,
      ]);
      final uf = _clean(placemark.administrativeArea);

      final ruaNumero = _formatStreetNumber(rua, numero);
      final cidadeUf = _formatCityState(cidade, uf);
      final complemento = _joinWithComma([bairro, cidadeUf]);

      final endereco = _joinWithDash([ruaNumero, complemento]);
      return endereco.isEmpty ? enderecoNaoLocalizado : endereco;
    } on Exception {
      return enderecoNaoLocalizado;
    }
  }

  String _formatStreetNumber(String rua, String numero) {
    if (rua.isNotEmpty && numero.isNotEmpty) {
      return '$rua, $numero';
    }
    return rua.isNotEmpty ? rua : numero;
  }

  String _formatCityState(String cidade, String uf) {
    if (cidade.isNotEmpty && uf.isNotEmpty) {
      return '$cidade-$uf';
    }
    return cidade.isNotEmpty ? cidade : uf;
  }

  String _firstNotEmpty(List<String?> values) {
    for (final value in values) {
      final cleanValue = _clean(value);
      if (cleanValue.isNotEmpty) {
        return cleanValue;
      }
    }
    return '';
  }

  String _joinWithComma(List<String> values) {
    return values.where((value) => value.isNotEmpty).join(', ');
  }

  String _joinWithDash(List<String> values) {
    return values.where((value) => value.isNotEmpty).join(' - ');
  }

  String _clean(String? value) {
    return value?.trim() ?? '';
  }
}
