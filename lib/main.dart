import 'dart:async';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';

import 'database/ponto_database.dart';
import 'models/ponto_registro.dart';
import 'services/address_service.dart';
import 'services/location_service.dart';
import 'services/sync_service.dart';
import 'services/tts_service.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const PontoAzulApp());
}

class PontoAzulApp extends StatelessWidget {
  const PontoAzulApp({super.key});

  @override
  Widget build(BuildContext context) {
    const primaryColor = Color(0xFF1565C0);

    return MaterialApp(
      title: 'Ponto Azul',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: primaryColor),
        scaffoldBackgroundColor: const Color(0xFFF6F8FB),
        useMaterial3: true,
      ),
      home: const PontoHomePage(),
    );
  }
}

class PontoHomePage extends StatefulWidget {
  const PontoHomePage({super.key});

  @override
  State<PontoHomePage> createState() => _PontoHomePageState();
}

class _PontoHomePageState extends State<PontoHomePage> {
  final _database = PontoDatabase.instance;
  final _addressService = AddressService();
  final _locationService = LocationService();
  final _syncService = SyncService();
  final _ttsService = TtsService();
  final _uuid = const Uuid();
  final _dateTimeFormat = DateFormat('dd/MM/yyyy HH:mm:ss');
  final _historyFormat = DateFormat('dd/MM/yyyy HH:mm');

  late Timer _clockTimer;
  Timer? _messageTimer;
  DateTime _agora = DateTime.now();
  List<PontoRegistro> _historico = const [];
  String? _mensagemStatus;
  bool _mensagemStatusErro = false;
  bool _carregando = true;
  bool _registrando = false;
  bool _sincronizando = false;

  @override
  void initState() {
    super.initState();
    _clockTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) {
        setState(() => _agora = DateTime.now());
      }
    });
    _carregarHistorico();
  }

  @override
  void dispose() {
    _clockTimer.cancel();
    _messageTimer?.cancel();
    super.dispose();
  }

  Future<void> _carregarHistorico() async {
    final historico = await _database.listarUltimos();
    if (!mounted) {
      return;
    }
    setState(() {
      _historico = historico;
      _carregando = false;
    });
  }

  Future<void> _registrarPonto(PontoTipo tipo) async {
    if (_registrando || _sincronizando) {
      return;
    }

    setState(() => _registrando = true);

    try {
      final position = await _locationService.obterLocalizacaoAtual();
      final endereco = await _addressService.obterEndereco(
        position.latitude,
        position.longitude,
      );
      final registro = PontoRegistro(
        id: _uuid.v4(),
        tipo: tipo,
        dataHora: DateTime.now(),
        latitude: position.latitude,
        longitude: position.longitude,
        endereco: endereco,
        sincronizado: false,
      );

      await _database.inserir(registro);
      await _carregarHistorico();
      unawaited(_ttsService.falarPontoRegistrado());
      _mostrarMensagem('Ponto registrado com sucesso.');
    } on LocationServiceException catch (error) {
      _mostrarMensagem(error.message, erro: true);
    } on Exception catch (error) {
      _mostrarMensagem(_mensagemErroRegistro(error), erro: true);
    } finally {
      if (mounted) {
        setState(() => _registrando = false);
      }
    }
  }

  Future<void> _sincronizar() async {
    if (_registrando || _sincronizando) {
      return;
    }

    setState(() => _sincronizando = true);

    try {
      final total = await _syncService.sincronizarPendentes();
      await _carregarHistorico();
      _mostrarMensagem(
        total == 0
            ? 'Nenhum ponto pendente para sincronizar.'
            : '$total ponto(s) sincronizado(s).',
      );
    } on SyncServiceException catch (error) {
      _mostrarMensagem(error.message, erro: true);
    } on Exception {
      _mostrarMensagem(_mensagemErroSincronizacao(), erro: true);
    } finally {
      if (mounted) {
        setState(() => _sincronizando = false);
      }
    }
  }

  String _mensagemErroRegistro(Exception error) {
    final message = error.toString();
    if (message.contains('LOCATION_SERVICES_DISABLED') ||
        message.contains('Location services are disabled')) {
      return 'Ative a localização do dispositivo.';
    }
    return 'Não foi possível registrar o ponto.';
  }

  String _mensagemErroSincronizacao() {
    return 'Não foi possível sincronizar agora.';
  }

  void _mostrarMensagem(String mensagem, {bool erro = false}) {
    if (!mounted) {
      return;
    }

    _messageTimer?.cancel();
    setState(() {
      _mensagemStatus = mensagem;
      _mensagemStatusErro = erro;
    });

    _messageTimer = Timer(Duration(seconds: erro ? 5 : 3), () {
      if (!mounted) {
        return;
      }
      setState(() => _mensagemStatus = null);
    });
  }

  @override
  Widget build(BuildContext context) {
    final isRound =
        MediaQuery.of(context).size.aspectRatio > 0.85 &&
        MediaQuery.of(context).size.aspectRatio < 1.15;

    return Scaffold(
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final compact =
                constraints.maxWidth < 360 || constraints.maxHeight < 420;
            final horizontalPadding = isRound
                ? constraints.maxWidth * 0.10
                : 16.0;
            final verticalPadding = isRound
                ? constraints.maxHeight * 0.06
                : 0.0;

            return Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 520),
                child: Padding(
                  padding: EdgeInsets.fromLTRB(
                    horizontalPadding,
                    verticalPadding,
                    horizontalPadding,
                    verticalPadding,
                  ),
                  child: CustomScrollView(
                    slivers: [
                      SliverToBoxAdapter(
                        child: _Header(
                          dataHora: _dateTimeFormat.format(_agora),
                          compact: compact,
                        ),
                      ),
                      if (_mensagemStatus != null)
                        SliverToBoxAdapter(
                          child: _StatusBanner(
                            mensagem: _mensagemStatus!,
                            erro: _mensagemStatusErro,
                            compact: compact,
                          ),
                        ),
                      SliverToBoxAdapter(
                        child: _AcoesPonto(
                          registrando: _registrando,
                          sincronizando: _sincronizando,
                          onEntrada: () => _registrarPonto(PontoTipo.entrada),
                          onSaida: () => _registrarPonto(PontoTipo.saida),
                          onSincronizar: _sincronizar,
                        ),
                      ),
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.only(top: 16, bottom: 8),
                          child: Text(
                            'Histórico',
                            style: Theme.of(context).textTheme.titleMedium
                                ?.copyWith(fontWeight: FontWeight.w700),
                          ),
                        ),
                      ),
                      if (_carregando)
                        const SliverFillRemaining(
                          hasScrollBody: false,
                          child: Center(child: CircularProgressIndicator()),
                        )
                      else if (_historico.isEmpty)
                        const SliverFillRemaining(
                          hasScrollBody: false,
                          child: Center(
                            child: Text(
                              'Nenhum ponto registrado.',
                              textAlign: TextAlign.center,
                            ),
                          ),
                        )
                      else
                        SliverList.separated(
                          itemBuilder: (context, index) {
                            final registro = _historico[index];
                            return _PontoTile(
                              registro: registro,
                              dataHora: _historyFormat.format(
                                registro.dataHora,
                              ),
                              compact: compact,
                            );
                          },
                          separatorBuilder: (context, index) =>
                              const SizedBox(height: 8),
                          itemCount: _historico.length,
                        ),
                      const SliverToBoxAdapter(child: SizedBox(height: 18)),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.dataHora, required this.compact});

  final String dataHora;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(top: compact ? 8 : 18, bottom: 12),
      child: Column(
        children: [
          Text(
            'Ponto Azul',
            textAlign: TextAlign.center,
            style:
                (compact
                        ? Theme.of(context).textTheme.titleLarge
                        : Theme.of(context).textTheme.headlineSmall)
                    ?.copyWith(
                      color: const Color(0xFF0D47A1),
                      fontWeight: FontWeight.w800,
                    ),
          ),
          const SizedBox(height: 6),
          Text(
            dataHora,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: const Color(0xFF334155),
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _AcoesPonto extends StatelessWidget {
  const _AcoesPonto({
    required this.registrando,
    required this.sincronizando,
    required this.onEntrada,
    required this.onSaida,
    required this.onSincronizar,
  });

  final bool registrando;
  final bool sincronizando;
  final VoidCallback onEntrada;
  final VoidCallback onSaida;
  final VoidCallback onSincronizar;

  @override
  Widget build(BuildContext context) {
    final busy = registrando || sincronizando;
    final compact = MediaQuery.of(context).size.width < 360;
    final buttonStyle = ButtonStyle(
      minimumSize: WidgetStatePropertyAll(Size.fromHeight(compact ? 42 : 48)),
      padding: WidgetStatePropertyAll(
        EdgeInsets.symmetric(horizontal: compact ? 10 : 16),
      ),
      textStyle: WidgetStatePropertyAll(
        TextStyle(fontSize: compact ? 13 : 14, fontWeight: FontWeight.w700),
      ),
    );

    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: FilledButton.icon(
                style: buttonStyle,
                onPressed: busy ? null : onEntrada,
                icon: const Icon(Icons.login),
                label: const Text('Registrar Entrada'),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: FilledButton.tonalIcon(
                style: buttonStyle,
                onPressed: busy ? null : onSaida,
                icon: const Icon(Icons.logout),
                label: const Text('Registrar Saída'),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                style: buttonStyle,
                onPressed: busy ? null : onSincronizar,
                icon: sincronizando
                    ? const SizedBox.square(
                        dimension: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.sync),
                label: Text(sincronizando ? 'Sincronizando' : 'Sincronizar'),
              ),
            ),
          ],
        ),
        if (registrando)
          const Padding(
            padding: EdgeInsets.only(top: 8),
            child: LinearProgressIndicator(minHeight: 3),
          ),
      ],
    );
  }
}

class _StatusBanner extends StatelessWidget {
  const _StatusBanner({
    required this.mensagem,
    required this.erro,
    required this.compact,
  });

  final String mensagem;
  final bool erro;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final backgroundColor = erro
        ? const Color(0xFFFFF3E0)
        : const Color(0xFFE8F5E9);
    final borderColor = erro
        ? const Color(0xFFFFB74D)
        : const Color(0xFF81C784);
    final textColor = erro ? const Color(0xFF7C2D12) : const Color(0xFF1B5E20);
    final iconColor = erro ? const Color(0xFFE65100) : const Color(0xFF2E7D32);

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: backgroundColor,
          border: Border.all(color: borderColor),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: compact ? 10 : 12,
            vertical: compact ? 8 : 10,
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                erro ? Icons.info_outline : Icons.check_circle_outline,
                color: iconColor,
                size: compact ? 18 : 20,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  mensagem,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: textColor,
                    fontWeight: FontWeight.w700,
                    height: 1.25,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PontoTile extends StatelessWidget {
  const _PontoTile({
    required this.registro,
    required this.dataHora,
    required this.compact,
  });

  final PontoRegistro registro;
  final String dataHora;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final statusColor = registro.sincronizado
        ? const Color(0xFF2E7D32)
        : const Color(0xFFB45309);
    final statusText = registro.sincronizado ? 'Sincronizado' : 'Pendente';

    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: const Color(0xFFE2E8F0)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: EdgeInsets.all(compact ? 9 : 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Wrap(
              spacing: 8,
              runSpacing: 4,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      registro.tipo == PontoTipo.entrada
                          ? Icons.login
                          : Icons.logout,
                      size: 18,
                      color: const Color(0xFF1565C0),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      registro.tipo.label,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
                Text(
                  statusText,
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    color: statusColor,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(dataHora, style: Theme.of(context).textTheme.bodySmall),
            const SizedBox(height: 4),
            Text(
              registro.endereco,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: const Color(0xFF475569),
                height: 1.25,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
