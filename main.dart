import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'dart:async';
import 'package:share_plus/share_plus.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart'; // para formatar datas
import 'dart:math' show exp, pow;
import 'package:flutter/services.dart' show rootBundle, Clipboard, ClipboardData;
import 'package:open_filex/open_filex.dart';
import 'package:file_picker/file_picker.dart';
import 'package:share_plus/share_plus.dart';
import 'package:intl/intl.dart';
import 'dart:math';
import 'package:intl/date_symbol_data_local.dart';

// versão com nivel de enfrentamento pronto

// Ponto de entrada da aplicação.
void main() async {
  // Garante que os bindings do Flutter estão inicializados
  WidgetsFlutterBinding.ensureInitialized();
  // Ativa o modo de ecrã cheio para ocultar a barra de navegação do sistema
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

  runApp(const MeuAppDeFinancas());
}

// O widget principal que configura a aplicação com design moderno.
class MeuAppDeFinancas extends StatelessWidget {
  const MeuAppDeFinancas({super.key});

  @override
  Widget build(BuildContext context) {

    // Tema Claro Fixo para uma aparência consistente
    final lightTheme = ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.teal,
          brightness: Brightness.light,
        ),
        scaffoldBackgroundColor: const Color(0xFFF5F7FA),
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.teal.shade700,
          foregroundColor: Colors.white,
          centerTitle: true,
          elevation: 2,
        ),
        // ADICIONADO: Tema para as abas
        tabBarTheme: TabBarThemeData( // CORRIGIDO AQUI
          labelColor: Colors.white, // Cor do texto da aba selecionada
          unselectedLabelColor: Colors.white.withOpacity(0.8), // Cor do texto das outras abas
          indicatorColor: Colors.white, // Cor da linha debaixo da aba selecionada
        ),
        cardTheme: CardThemeData(
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          filled: true,
          fillColor: Colors.white,
        ),
        bottomNavigationBarTheme: BottomNavigationBarThemeData(
          selectedItemColor: Colors.teal.shade600,
          unselectedItemColor: Colors.grey.shade600,
        )
    );

    return MaterialApp(
      title: 'Controle de Finanças',
      theme: lightTheme, // Usa apenas o tema claro
      home: const TelaLogin(),
      debugShowCheckedModeBanner: false,
    );
  }
}
// ===================================================================
// INÍCIO DO BLOCO DA TELA DE LOGIN
// ===================================================================
class TelaLogin extends StatefulWidget {
  const TelaLogin({super.key});

  @override
  State<TelaLogin> createState() => _TelaLoginState();
}

class _TelaLoginState extends State<TelaLogin> {
  final TextEditingController _senhaController = TextEditingController();
  String? _mensagemErro;

  void _verificarSenha() {
    if (_senhaController.text == '5') {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const ControleDasTelas()),
      );
    } else {
      setState(() {
        _mensagemErro = 'Preencha todos os campos';
        _senhaController.clear();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.lock, size: 80, color: Theme.of(context).colorScheme.primary),
              const SizedBox(height: 24),
              const Text('Acesso Restrito', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              const SizedBox(height: 32),
              TextField(
                controller: _senhaController,
                obscureText: true,
                maxLength: 4,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 24, letterSpacing: 16),
                decoration: InputDecoration(
                  counterText: "",
                  labelText: 'Senha',
                  errorText: _mensagemErro,
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _verificarSenha,
                child: const Text('Entrar'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
// ===================================================================
// FIM DO BLOCO DA TELA DE LOGIN
// ===================================================================

class ControleDasTelas extends StatefulWidget {
  const ControleDasTelas({super.key});

  @override
  State<ControleDasTelas> createState() => _ControleDasTelasState();
}

class _ControleDasTelasState extends State<ControleDasTelas> {
  int _indiceSelecionado = 0;
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: _indiceSelecionado);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  static final List<Widget> _telas = <Widget>[

    TelaApostas(),
//    TelaOrcamento(),
//    TelaReceitas(),
    TelaSobra1(),
    TelaSobra2(),
    TelaSobra3(),
    TelaDashboard(),
    TelaInvestimentos(),
    TelaCrypto(),
    TelaSobra4(),
    TelaAcademia(),
    TelaGastos(),
  ];

  void _aoTocarNoItem(int index) {
    setState(() {
      _indiceSelecionado = index;
      _pageController.animateToPage(
        index,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    });
  }

  void _aoArrastar(int index) {
    setState(() {
      _indiceSelecionado = index;
    });
  }

  // NOVO WIDGET para um item da barra de navegação
  Widget _buildNavItem(IconData icon, String label, int index) {
    final isSelected = _indiceSelecionado == index;
    final color = isSelected ? Theme.of(context).colorScheme.primary : Colors.grey[600];

    return GestureDetector(
      onTap: () => _aoTocarNoItem(index),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 4),
            Text(label, style: TextStyle(color: color, fontSize: 12, fontWeight: isSelected ? FontWeight.bold : FontWeight.normal)),
          ],
        ),
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        controller: _pageController,
        onPageChanged: _aoArrastar,
        children: _telas,
      ),
      bottomNavigationBar: Container(
        height: 80, // Altura aumentada para melhor toque
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [


              _buildNavItem(Icons.casino, 'Apostas', 0),
//              _buildNavItem(Icons.pie_chart, 'Orçamento', 5),
//              _buildNavItem(Icons.analytics, 'Análise', 6),
//              _buildNavItem(Icons.fitness_center, 'Academia', 7),
              _buildNavItem(Icons.analytics, 'EV+', 1),
              _buildNavItem(Icons.dashboard, 'Visão Geral', 2),
              _buildNavItem(Icons.receipt_long, 'Regras', 3),
              _buildNavItem(Icons.search, 'Pesquisa', 4),
              _buildNavItem(Icons.show_chart, 'Eventos', 5),
              _buildNavItem(Icons.science, 'Simulação', 6),
              _buildNavItem(Icons.psychology, 'Centro de Controle', 7),
              _buildNavItem(Icons.fitness_center, 'Scout', 8),
              _buildNavItem(Icons.receipt_long, 'Backup', 9),
            ],
          ),
        ),
      ),
    );
  }
}
// ===================================================================
// INÍCIO DE TODAS AS TELAS DE FUNCIONALIDADES
// ===================================================================


// ===================================================================
// INÍCIO DO BLOCO DA TELA DE APOSTAS (TELA 1)  Lucro real funcionando
// ===================================================================
class TelaApostas extends StatefulWidget {
  const TelaApostas({super.key});

  @override
  State<TelaApostas> createState() => _TelaApostasState();
}

class _TelaApostasState extends State<TelaApostas> with SingleTickerProviderStateMixin {
  // ---------------------------
  // Configurações e dados
  // ---------------------------
  double bancaInicial = 1000.0;
  List<Map<String, dynamic>> aportes = [];
  List<Map<String, dynamic>> saques = [];

  double valorPorCiclo = 100.0;
  bool usarPercentualDaBanca = true;
  double percentualRisco = 5.0;
  int qtdStakesPorCiclo = 5;
  double? valorStakeManual;

  // Dados principais
  List<Map<String, dynamic>> ciclos = [];
  List<Map<String, dynamic>> apostas = [];
  List<Map<String, dynamic>> historicoBanca = [];
  List<Map<String, dynamic>> metas = [];
  List<Map<String, dynamic>> playbooks = [];
  List<Map<String, dynamic>> preLancamentos = [];

  // UI
  late TabController _tabController;
  bool _isLoadingBackup = false; // Estado de loading para backup

  // Form state temporário
  final TextEditingController _tipoCtrl = TextEditingController();
  final TextEditingController _campeonatoCtrl = TextEditingController();
  final TextEditingController _timeCtrl = TextEditingController();
  final TextEditingController _oddCtrl = TextEditingController(text: "2.00");
  final TextEditingController _stakeCtrl = TextEditingController();
  final TextEditingController _margemCtrl = TextEditingController();
  final TextEditingController _comentariosCtrl = TextEditingController();
  final TextEditingController _playbookNomeCtrl = TextEditingController();
  final TextEditingController _playbookCriteriosCtrl = TextEditingController();
  final TextEditingController _playbookChecklistCtrl = TextEditingController();
  DateTime _dataAposta = DateTime.now();
  int? _selectedCicloIdForForm;
  int _resultadoSelecionado = -1;
  int? _nivelConfiancaSelecionado;
  bool? _evPositivoSelecionado;
  int? _playbookSelecionadoId;
  int? _preLancamentoOrigemId;

  // ---------------------------
  // Estado dos Filtros
  // ---------------------------
  String? _filtroTipoSelecionado;
  String? _filtroCampeonatoSelecionado;
  int? _filtroConfiancaSelecionado;
  int? _filtroPlaybookSelecionado;
  RangeValues? _filtroOddValues;
  List<Map<String, dynamic>> _apostasFiltradas = [];
  double _minOddDisponivel = 1.0;
  double _maxOddDisponivel = 3.0;

  // Estado para a aba de Análise
  String _analiseAssunto = 'Time';
  String _analiseMetrica = 'Retorno Financeiro';
  int? _rankingItemExpandido;

  // NOVOS ESTADOS PARA MÉTRICAS GLOBAIS
  List<Map<String, dynamic>> _drawdownHistory = [];
  Map<String, dynamic>? _maxDrawdown;
  double _oddMediaTotal = 0.0;
  double _taxaAcertoReal = 0.0; // Em decimal (ex: 0.55)

  // NOVO: Estado para o Calendário Heatmap
  DateTime _mesFocadoHeatmap = DateTime.now();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
    _tipoCtrl.addListener(_onFormularioMudou);
    _campeonatoCtrl.addListener(_onFormularioMudou);
    _timeCtrl.addListener(_onFormularioMudou);
    _oddCtrl.addListener(_onFormularioMudou);
    _stakeCtrl.addListener(_onFormularioMudou);
    _margemCtrl.addListener(_onFormularioMudou);
    _comentariosCtrl.addListener(_onFormularioMudou);
    _carregarDados();
  }

  void _onFormularioMudou() {
    if (!mounted) return;
    setState(() {});
  }

  @override
  void dispose() {
    _tabController.dispose();
    _tipoCtrl.removeListener(_onFormularioMudou);
    _campeonatoCtrl.removeListener(_onFormularioMudou);
    _timeCtrl.removeListener(_onFormularioMudou);
    _oddCtrl.removeListener(_onFormularioMudou);
    _stakeCtrl.removeListener(_onFormularioMudou);
    _margemCtrl.removeListener(_onFormularioMudou);
    _comentariosCtrl.removeListener(_onFormularioMudou);
    _tipoCtrl.dispose();
    _campeonatoCtrl.dispose();
    _timeCtrl.dispose();
    _oddCtrl.dispose();
    _stakeCtrl.dispose();
    _margemCtrl.dispose();
    _comentariosCtrl.dispose();
    _playbookNomeCtrl.dispose();
    _playbookCriteriosCtrl.dispose();
    _playbookChecklistCtrl.dispose();
    super.dispose();
  }

  // ---------------------------
  // Persistência JSON
  // ---------------------------
  Future<File> _getFile() async {
    final dir = await getApplicationDocumentsDirectory();
    return File("${dir.path}/apostas_data.json");
  }

  Future<File> _getDashboardFile() async {
    final dir = await getApplicationDocumentsDirectory();
    return File("${dir.path}/registros_apostas.json");
  }

  // MODIFICADO: Helper para criar o sumário de análise completo
  Map<String, dynamic> _gerarSumarioAnalise() {
    final Map<String, Map<String, dynamic>> porTime = {};
    final Map<String, Map<String, dynamic>> porCampeonato = {};
    final Map<String, Map<String, dynamic>> porTipo = {};
    final Map<String, Map<String, dynamic>> porEV = {};
    final Map<String, Map<String, dynamic>> porConfianca = {};
    final Map<String, Map<String, dynamic>> porMargem = {};
    final Map<String, Map<String, dynamic>> porComentarios = {};
    final Map<String, Map<String, dynamic>> porPlaybook = {};

    // Função auxiliar para atualizar os mapas de sumário
    void _atualizarSumario(Map<String, Map<String, dynamic>> mapa, String? chave, double lucro) {
      if (chave == null || chave.isEmpty) return; // Ignora chaves nulas ou vazias

      if (!mapa.containsKey(chave)) {
        mapa[chave] = {'lucro': 0.0, 'totalApostas': 0, 'vitorias': 0};
      }

      final dados = mapa[chave]!;
      dados['lucro'] = (dados['lucro'] as double) + lucro;
      dados['totalApostas'] = (dados['totalApostas'] as int) + 1;
      if (lucro > 0) {
        dados['vitorias'] = (dados['vitorias'] as int) + 1;
      }
    }

    for (var aposta in apostas) {
      final lucro = (aposta['lucro'] as num).toDouble();

      // Chaves padrão
      _atualizarSumario(porTime, aposta['time'] as String?, lucro);
      _atualizarSumario(porCampeonato, aposta['campeonato'] as String?, lucro);
      _atualizarSumario(porTipo, aposta['tipo'] as String?, lucro);
      _atualizarSumario(porPlaybook, aposta['playbookNome'] as String?, lucro);

      // Novas chaves qualitativas
      // CORREÇÃO: Trata os 3 casos (true, false, null)
      final bool? ev = aposta['evPositivo'] as bool?;
      if (ev == true) {
        _atualizarSumario(porEV, "Sim (EV+)", lucro);
      } else if (ev == false) {
        _atualizarSumario(porEV, "Não (EV-)", lucro);
      } else {
        _atualizarSumario(porEV, "N/A (Não Calculado)", lucro);
      }


      final int? confianca = (aposta['nivelConfianca'] as num?)?.toInt();
      if (confianca != null) {
        _atualizarSumario(porConfianca, "Nível $confianca", lucro);
      }

      final int? margem = (aposta['margem'] as num?)?.toInt();
      if (margem != null) {
        _atualizarSumario(porMargem, "Margem $margem", lucro);
      }

      final String? comentario = aposta['comentarios'] as String?;
      if (comentario != null && comentario.isNotEmpty) {
        _atualizarSumario(porComentarios, comentario, lucro);
      }
    }

    return {
      'porTime': porTime,
      'porCampeonato': porCampeonato,
      'porTipo': porTipo,
      'porEV': porEV,
      'porConfianca': porConfianca,
      'porMargem': porMargem,
      'porComentarios': porComentarios,
      'porPlaybook': porPlaybook,
    };
  }

  // MODIFICADO: Agora aceita 'forceNewRecord' e calcula TUDO para o snapshot
  Future<void> _salvarDadosDashboard({bool forceNewRecord = false}) async {
    try {
      final file = await _getDashboardFile();
      List<Map<String, dynamic>> records = [];

      // Se não estiver forçando, tenta ler. Se falhar (corrompido), trata como vazio.
      if (forceNewRecord == false && await file.exists()) {
        try {
          final content = await file.readAsString();
          if (content.isNotEmpty) {
            records = (jsonDecode(content) as List).cast<Map<String, dynamic>>();
          }
        } catch (e) {
          debugPrint("Arquivo de dashboard corrompido, será sobrescrito. Erro: $e");
          records = []; // Trata como vazio se estiver corrompido
        }
      }

      final now = DateTime.now();

      // DADOS DE ANÁLISE ADICIONADOS
      final ciclosVitoriosos = ciclos.where((c) => c['status'] == 'ganho').length;
      final ciclosPerdidos = ciclos.where((c) => c['status'] == 'perdido').length;
      final ciclosEmAndamento = ciclos.where((c) => c['status'] == 'em_andamento').length;

      // MODIFICADO: Chama a nova função de sumário completo
      final sumarioAnalise = _gerarSumarioAnalise();

      // --- CÁLCULOS COMPLETOS PARA O SNAPSHOT ---

      // 1. Yield e Profit Factor
      final double totalStaked = apostas.fold(0.0, (s, a) => s + (a['stake'] as num).toDouble());
      final double yieldPct = totalStaked > 0 ? (lucroTotalApostas / totalStaked) * 100 : 0.0;

      final double grossProfit = apostas.where((a) => (a['lucro'] as num) > 0).fold(0.0, (s, a) => s + (a['lucro'] as num).toDouble());
      final double grossLoss = apostas.where((a) => (a['lucro'] as num) < 0).fold(0.0, (s, a) => s + ((a['lucro'] as num).abs()).toDouble());
      final double profitFactor = grossLoss == 0 ? (grossProfit > 0 ? 999.0 : 0.0) : (grossProfit / grossLoss);

      // 2. Sequências (Streaks)
      int maxWinStreak = 0;
      int maxLoseStreak = 0;
      int currentW = 0;
      int currentL = 0;
      final sortedApostas = List<Map<String, dynamic>>.from(apostas)..sort((a, b) => a['data'].compareTo(b['data']));

      for (var a in sortedApostas) {
        final l = (a['lucro'] as num).toDouble();
        if (l > 0) {
          currentW++;
          currentL = 0;
          if (currentW > maxWinStreak) maxWinStreak = currentW;
        } else if (l < 0) {
          currentL++;
          currentW = 0;
          if (currentL > maxLoseStreak) maxLoseStreak = currentL;
        } else {
          currentW = 0;
          currentL = 0;
        }
      }

      // 3. Break-even e Odds
      final double somaOdds = apostas.fold(0.0, (s, a) => s + (a['odd'] as num).toDouble());
      final double oddMediaSnap = apostas.isNotEmpty ? (somaOdds / apostas.length) : 0.0;
      final double taxaNecessariaSnap = (oddMediaSnap > 0) ? (1 / oddMediaSnap) : 0.0;
      final double taxaAcertoSnap = _getTaxaAcertoReal(null); // decimal

      // 4. Faixas de Odds
      final Map<String, dynamic> oddsStatsSnap = {
        '1.01 - 1.50': {'lucro': 0.0, 'total': 0, 'wins': 0},
        '1.51 - 2.00': {'lucro': 0.0, 'total': 0, 'wins': 0},
        '2.01 - 3.00': {'lucro': 0.0, 'total': 0, 'wins': 0},
        '3.01+':       {'lucro': 0.0, 'total': 0, 'wins': 0},
      };

      for(var a in apostas) {
        final odd = (a['odd'] as num).toDouble();
        final lucro = (a['lucro'] as num).toDouble();
        String key = '3.01+';
        if(odd <= 1.50) key = '1.01 - 1.50';
        else if(odd <= 2.00) key = '1.51 - 2.00';
        else if(odd <= 3.00) key = '2.01 - 3.00';

        oddsStatsSnap[key]!['lucro'] += lucro;
        oddsStatsSnap[key]!['total']++;
        if(lucro > 0) oddsStatsSnap[key]!['wins']++;
      }

      // 5. Recalcular Drawdown Máximo Específico para o Snapshot (garante dado fresco)
      List<Map<String, dynamic>> transactionsSnap = [];
      // Aportes
      transactionsSnap.addAll(aportes.map((a) => {'data': DateTime.parse(a['data']), 'valor': (a['valor'] as num).toDouble()}));
      // Apostas
      transactionsSnap.addAll(apostas.map((a) => {'data': DateTime.parse(a['data']), 'valor': (a['lucro'] as num).toDouble()}));

      transactionsSnap.sort((a, b) => a['data'].compareTo(b['data']));

      double currentVirtualBalanceSnap = bancaInicial;
      double peakVirtualBalanceSnap = bancaInicial;
      double maxDrawdownPercentSnap = 0.0;
      String? maxDrawdownDateSnap;

      for (var item in transactionsSnap) {
        currentVirtualBalanceSnap += item['valor'] as double;
        if (currentVirtualBalanceSnap > peakVirtualBalanceSnap) {
          peakVirtualBalanceSnap = currentVirtualBalanceSnap;
        }
        double dd = 0.0;
        if (peakVirtualBalanceSnap > 0) {
          dd = (currentVirtualBalanceSnap - peakVirtualBalanceSnap) / peakVirtualBalanceSnap;
        }
        if (dd < maxDrawdownPercentSnap) {
          maxDrawdownPercentSnap = dd;
          maxDrawdownDateSnap = (item['data'] as DateTime).toIso8601String();
        }
      }

      final newRecord = {
        'dataAtualizacao': now.toIso8601String(),
        'ano': now.year,
        'mes': now.month,
        'bancaAtual': bancaAtual,
        'roi': roi,
        'lucroTotal': lucroTotalApostas,
        'investimentoTotal': investimentoTotal,
        'sumarioCiclos': {
          'vitoriosos': ciclosVitoriosos,
          'perdidos': ciclosPerdidos,
          'emAndamento': ciclosEmAndamento,
        },
        'sumarioAnalise': sumarioAnalise,
        'taxaAcerto': taxaAcertoSnap * 100.0,

        // --- NOVOS CAMPOS RICOS ---
        'yield': yieldPct,
        'profitFactor': profitFactor,
        'maxWinStreak': maxWinStreak,
        'maxLoseStreak': maxLoseStreak,
        'oddMedia': oddMediaSnap,
        'taxaNecessariaBreakEven': taxaNecessariaSnap * 100.0,
        'maxDrawdown': {
          'percentual': maxDrawdownPercentSnap,
          'data': maxDrawdownDateSnap
        },
        'statsPorOdd': oddsStatsSnap,
      };

      int existingIndex = -1; // Default: -1 (adiciona novo)

      // MODIFICADO: garante apenas um registro por mês (ano + mês).
      // se forceNewRecord for FALSO.
      if (forceNewRecord == false) {
        existingIndex = records.lastIndexWhere((r) {
          final int? recordYear = (r['ano'] as num?)?.toInt() ?? DateTime.tryParse(r['dataAtualizacao'] ?? '')?.year;
          final int? recordMonth = (r['mes'] as num?)?.toInt() ?? DateTime.tryParse(r['dataAtualizacao'] ?? '')?.month;
          if (recordYear == null || recordMonth == null) return false;
          return recordYear == now.year && recordMonth == now.month;
        });
      }

      if (existingIndex != -1) {
        records[existingIndex] = newRecord; // Atualiza o registro do mês
      } else {
        records.add(newRecord); // Adiciona um novo registro mensal
      }

      records.sort((a, b) => DateTime.parse(a['dataAtualizacao']).compareTo(DateTime.parse(b['dataAtualizacao'])));

      await file.writeAsString(jsonEncode(records));
      debugPrint("Dados do dashboard salvos (forceNewRecord: $forceNewRecord)");
    } catch (e) {
      debugPrint("Erro ao salvar dados do dashboard: $e");
    }
  }

  Future<void> _salvarDados() async {
    try {
      final file = await _getFile();
      final data = {
        "config": {
          "bancaInicial": bancaInicial,
          "aportes": aportes,
          "saques": saques,
          "valorPorCiclo": valorPorCiclo,
          "usarPercentualDaBanca": usarPercentualDaBanca,
          "percentualRisco": percentualRisco,
          "qtdStakesPorCiclo": qtdStakesPorCiclo,
          "valorStakeManual": valorStakeManual,
        },
        "ciclos": ciclos,
        "apostas": apostas,
        "historicoBanca": historicoBanca,
        "metas": metas,
        "playbooks": playbooks,
        "preLancamentos": preLancamentos,
      };
      await file.writeAsString(jsonEncode(data));
      // Salva o dashboard (sem forçar) e recalcula as métricas globais
      await _salvarDadosDashboard(forceNewRecord: false);
      _recalcularMetricasGlobais(); // Recalcula drawdown e break-even
    } catch (e) {
      debugPrint("Erro ao salvar dados: $e");
    }
  }

  Future<void> _carregarDados() async {
    bool needsSave = false;
    try {
      final file = await _getFile();
      if (await file.exists()) {
        final data = await file.readAsString();
        if (data.isNotEmpty) {
          final decodedData = jsonDecode(data);

          if (decodedData['config'] == null) {
            needsSave = true;
            debugPrint("[TelaApostas] 'config' não encontrado no JSON. Forçando salvamento inicial.");
          }

          setState(() {
            final cfg = decodedData['config'] ?? {};
            bancaInicial = (cfg["bancaInicial"] ?? bancaInicial).toDouble();
            aportes = (cfg["aportes"] ?? []).cast<Map<String, dynamic>>();
            saques = (cfg["saques"] ?? []).cast<Map<String, dynamic>>();
            valorPorCiclo = (cfg["valorPorCiclo"] ?? valorPorCiclo).toDouble();
            usarPercentualDaBanca = cfg["usarPercentualDaBanca"] ?? usarPercentualDaBanca;
            percentualRisco = (cfg["percentualRisco"] ?? percentualRisco).toDouble();
            qtdStakesPorCiclo = (cfg["qtdStakesPorCiclo"] ?? qtdStakesPorCiclo).toInt();
            valorStakeManual = cfg["valorStakeManual"] == null ? null : (cfg["valorStakeManual"] as num).toDouble();

            ciclos = (decodedData["ciclos"] ?? []).cast<Map<String, dynamic>>();
            apostas = (decodedData["apostas"] ?? []).cast<Map<String, dynamic>>();
            historicoBanca = (decodedData["historicoBanca"] ?? []).cast<Map<String, dynamic>>();
            metas = (decodedData["metas"] ?? []).cast<Map<String, dynamic>>();
            playbooks = (decodedData["playbooks"] ?? []).cast<Map<String, dynamic>>();
            preLancamentos = (decodedData["preLancamentos"] ?? []).cast<Map<String, dynamic>>();
          });
        } else {
          needsSave = true;
          debugPrint("[TelaApostas] Arquivo vazio. Forçando salvamento inicial.");
        }
      } else {
        needsSave = true;
        debugPrint("[TelaApostas] Arquivo não existe. Forçando salvamento inicial.");
      }
    } catch (e) {
      debugPrint("Erro ao carregar dados de apostas: $e");
      needsSave = true;
    }
    _atualizarStakeSugerida();
    _inicializarFiltros();
    _recalcularMetricasGlobais(); // Calcula drawdown e break-even no carregamento

    if (needsSave) {
      debugPrint("[TelaApostas] Executando _salvarDados() automático para criar 'config'.");
      await _salvarDados();
    }
  }

  // ---------------------------
  // Lógica de Filtros e Stakes
  // ---------------------------
  void _atualizarStakeSugerida() {
    if (_selectedCicloIdForForm == null) {
      _stakeCtrl.text = _stakeIndividualDefault().toStringAsFixed(2);
      return;
    }

    final cicloSelecionado = ciclos.firstWhere((c) => (c['id'] as num).toInt() == _selectedCicloIdForForm, orElse: () => {});
    if (cicloSelecionado.isEmpty) {
      _stakeCtrl.text = _stakeIndividualDefault().toStringAsFixed(2);
      return;
    }

    // MODIFICADO: Stake sempre fixa (valor inicial do ciclo), removendo a progressão automática
    final double stakePadraoCiclo = (cicloSelecionado['stakeIndividual'] as num).toDouble();
    _stakeCtrl.text = stakePadraoCiclo.toStringAsFixed(2);
  }

  void _inicializarFiltros() {
    if (apostas.isNotEmpty) {
      final odds = apostas.map((a) => (a['odd'] as num).toDouble()).toList();
      _minOddDisponivel = odds.reduce((a, b) => a < b ? a : b);
      _maxOddDisponivel = odds.reduce((a, b) => a > b ? a : b);
      if (_minOddDisponivel.toStringAsFixed(2) == _maxOddDisponivel.toStringAsFixed(2)) {
        _maxOddDisponivel += 1.0;
      }
    } else {
      _minOddDisponivel = 1.0;
      _maxOddDisponivel = 3.0;
    }
    _filtroOddValues = RangeValues(_minOddDisponivel, _maxOddDisponivel);
    _aplicarFiltros();
  }

  void _aplicarFiltros() {
    List<Map<String, dynamic>> resultado = List.from(apostas);

    if (_filtroTipoSelecionado != null) {
      resultado = resultado.where((a) => a['tipo'] == _filtroTipoSelecionado).toList();
    }

    if (_filtroCampeonatoSelecionado != null) {
      resultado = resultado.where((a) => a['campeonato'] == _filtroCampeonatoSelecionado).toList();
    }

    if (_filtroConfiancaSelecionado != null) {
      resultado = resultado.where((a) {
        final nc = a['nivelConfianca'];
        if (nc == null) return false;
        return (nc as num).toInt() == _filtroConfiancaSelecionado;
      }).toList();
    }

    if (_filtroPlaybookSelecionado != null) {
      resultado = resultado.where((a) {
        final pbId = a['playbookId'];
        if (pbId == null) return false;
        return (pbId as num).toInt() == _filtroPlaybookSelecionado;
      }).toList();
    }

    if (_filtroOddValues != null) {
      resultado = resultado.where((a) {
        final odd = (a['odd'] as num).toDouble();
        return odd >= _filtroOddValues!.start && odd <= _filtroOddValues!.end;
      }).toList();
    }

    setState(() {
      _apostasFiltradas = resultado;
    });
  }

  void _limparFiltros() {
    setState(() {
      _filtroTipoSelecionado = null;
      _filtroCampeonatoSelecionado = null;
      _filtroConfiancaSelecionado = null;
      _filtroPlaybookSelecionado = null;
      _filtroOddValues = RangeValues(_minOddDisponivel, _maxOddDisponivel);
      _aplicarFiltros();
    });
  }

  // ---------------------------
  // Cálculos e utilitários
  // ---------------------------

  // Função central para calcular métricas globais (Drawdown, Break-even)
  void _recalcularMetricasGlobais() {
    if (apostas.isEmpty) {
      setState(() {
        _drawdownHistory = [];
        _maxDrawdown = null;
        _oddMediaTotal = 0.0;
        _taxaAcertoReal = 0.0;
      });
      return;
    }

    // 1. Unificar transações para linha do tempo
    List<Map<String, dynamic>> transactions = [];
    transactions.addAll(aportes.map((a) => {
      'data': DateTime.parse(a['data']),
      'valor': (a['valor'] as num).toDouble(),
      'tipo': 'aporte'
    }));
    transactions.addAll(saques.map((s) => {
      'data': DateTime.parse(s['data']),
      'valor': -(s['valor'] as num).toDouble(),
      'tipo': 'saque'
    }));
    transactions.addAll(apostas.map((a) => {
      'data': DateTime.parse(a['data']),
      'valor': (a['lucro'] as num).toDouble(),
      'tipo': 'aposta'
    }));

    transactions.sort((a, b) => a['data'].compareTo(b['data']));

    // 2. Calcular Curva de Drawdown (Underwater Chart)
    // Usamos um "Saldo Virtual" que ignora saques para medir apenas a performance.
    // Se considerarmos saques, tirar dinheiro pareceria que você perdeu aposta.
    List<Map<String, dynamic>> underwaterCurve = [];
    double currentVirtualBalance = bancaInicial;
    double peakVirtualBalance = bancaInicial;
    Map<String, dynamic>? worstDrawdown;

    // Ponto inicial
    if (transactions.isNotEmpty) {
      underwaterCurve.add({
        'data': transactions.first['data'].subtract(const Duration(days: 1)).toIso8601String(),
        'percentual': 0.0
      });
    }

    for (var item in transactions) {
      final type = item['tipo'];
      final val = item['valor'] as double;
      final date = item['data'] as DateTime;

      if (type == 'saque') {
        // IMPORTANTE: Ignoramos saques no cálculo de Drawdown de PERFORMANCE.
        // Assim, sacar dinheiro não gera uma "queda" falsa no gráfico.
        continue;
      }

      // Aportes e Apostas somam ao saldo virtual de performance
      currentVirtualBalance += val;

      // Se superou o topo anterior, atualiza o topo (Peak)
      if (currentVirtualBalance > peakVirtualBalance) {
        peakVirtualBalance = currentVirtualBalance;
      }

      // Calcula a queda atual em relação ao topo histórico (High Water Mark)
      double dd = 0.0;
      if (peakVirtualBalance > 0) {
        dd = (currentVirtualBalance - peakVirtualBalance) / peakVirtualBalance;
      }

      // Adiciona ponto na curva (Data exata da transação)
      underwaterCurve.add({
        'data': date.toIso8601String(),
        'percentual': dd
      });

      // Rastreia o pior drawdown (Máxima Queda)
      if (worstDrawdown == null || dd < (worstDrawdown['percentual'] as double)) {
        worstDrawdown = {
          'data': date.toIso8601String(),
          'percentual': dd
        };
      }
    }

    // 3. Calcular Break-even
    final oddMedia = _getOddMediaTotal();
    final taxaReal = _getTaxaAcertoReal(null);

    setState(() {
      _drawdownHistory = underwaterCurve; // Histórico contínuo
      _maxDrawdown = worstDrawdown ?? {'percentual': 0.0, 'data': null};
      _oddMediaTotal = oddMedia;
      _taxaAcertoReal = taxaReal;
    });
  }

  // OBSOLETO: Função _calcularHistoricoDeDrawdowns foi removida/substituída pela lógica acima.

  double get bancaBase {
    final somaAportes = aportes.fold(0.0, (s, a) => s + (a["valor"] as num).toDouble());
    final somaSaques = saques.fold(0.0, (s, a) => s + (a["valor"] as num).toDouble());
    return bancaInicial + somaAportes - somaSaques;
  }

  double get investimentoTotal {
    final somaAportes = aportes.fold(0.0, (s, a) => s + (a["valor"] as num).toDouble());
    return bancaInicial + somaAportes;
  }

  double get roi {
    final totalInvestido = investimentoTotal;
    if (totalInvestido <= 0) return 0.0;
    return (lucroTotalApostas / totalInvestido) * 100;
  }

  double get lucroTotalApostas {
    return apostas.fold(0.0, (s, a) => s + (a["lucro"] as num).toDouble());
  }

  double get bancaAtual {
    return bancaBase + lucroTotalApostas;
  }

  double _calcularLucroTotal(List<Map<String, dynamic>> lista) {
    return lista.fold(0.0, (s, a) => s + (a["lucro"] as num).toDouble());
  }

  // MODIFICADO: Retorna o valor decimal (ex: 0.55)
  double _getTaxaAcertoReal(List<Map<String, dynamic>>? lista) {
    final apostasUsadas = lista ?? apostas; // Usa lista filtrada ou a total
    final total = apostasUsadas.length;
    if (total == 0) return 0.0;
    final ganhos = apostasUsadas.where((a) => (a["lucro"] as num).toDouble() > 0).length;
    return (ganhos / total);
  }

  // MODIFICADO: Retorna a string formatada
  String _formatarTaxaAcerto(List<Map<String, dynamic>> lista) {
    final taxaDecimal = _getTaxaAcertoReal(lista);
    final total = lista.length;
    final ganhos = lista.where((a) => (a["lucro"] as num).toDouble() > 0).length;
    return "${(taxaDecimal * 100).toStringAsFixed(1)}% ($ganhos / $total)";
  }

  // NOVO: Calcula a Odd Média total
  double _getOddMediaTotal() {
    if (apostas.isEmpty) return 0.0;
    final somaOdds = apostas.fold(0.0, (s, a) => s + (a["odd"] as num).toDouble());
    return somaOdds / apostas.length;
  }


  double _stakeIndividualDefault() {
    final qtd = qtdStakesPorCiclo > 0 ? qtdStakesPorCiclo : 5;
    final stake = valorPorCiclo / qtd;
    return double.parse(stake.toStringAsFixed(2));
  }

  int _nextCicloId() {
    if (ciclos.isEmpty) return 1;
    final ids = ciclos.map((c) => (c["id"] as num).toInt()).toList();
    return (ids.isEmpty ? 0 : (ids.reduce((a, b) => a > b ? a : b))) + 1;
  }

  void _criarCicloManual() {
    final id = _nextCicloId();

    double valorDoCiclo;
    if (usarPercentualDaBanca) {
      valorDoCiclo = bancaAtual * (percentualRisco / 100);
    } else {
      valorDoCiclo = valorStakeManual ?? valorPorCiclo;
    }

    final novo = {
      "id": id,
      "createdAt": DateTime.now().toIso8601String(),
      "valorPorCiclo": valorDoCiclo,
      "stakeIndividual": double.parse((valorDoCiclo / (qtdStakesPorCiclo > 0 ? qtdStakesPorCiclo : 5)).toStringAsFixed(2)),
      "apostasIds": <int>[],
      "lucroLiquido": 0.0,
      "perdaAcumulada": 0.0,
      "qtdStakesUsadas": 0,
      "status": "em_andamento",
    };
    setState(() {
      ciclos.add(novo);
      if (ciclos.isNotEmpty) _selectedCicloIdForForm = (ciclos.last["id"] as num).toInt();
      _atualizarStakeSugerida();
      _salvarDados();
    });
  }

  double _getStakeIndividualFromCiclo(Map<String, dynamic> ciclo) {
    if (ciclo.containsKey("stakeIndividual")) {
      return (ciclo["stakeIndividual"] as num).toDouble();
    }
    final valor = (ciclo["valorPorCiclo"] as num).toDouble();
    final stakeInd = valor / (qtdStakesPorCiclo > 0 ? qtdStakesPorCiclo : 5);
    return double.parse(stakeInd.toStringAsFixed(2));
  }

  void _atualizarCicloDepoisDeAposta(int cicloId) {
    final cicloIndex = ciclos.indexWhere((c) => (c["id"] as num).toInt() == cicloId);
    if (cicloIndex == -1) return;
    final ciclo = ciclos[cicloIndex];
    final statusAntigo = ciclo["status"];
    final apostaIds = (ciclo["apostasIds"] as List).cast<int>();
    final listaApostas = apostas.where((a) => apostaIds.contains((a["id"] as num).toInt())).toList();

    final lucroLiquido = listaApostas.fold(0.0, (s, a) => s + (a["lucro"] as num).toDouble());
    final perdaAcumulada = listaApostas.fold(0.0, (s, a) {
      final l = (a["lucro"] as num).toDouble();
      return s + (l < 0 ? -l : 0.0);
    });
    final qtdUsadas = listaApostas.length;

    final stakeIndividual = _getStakeIndividualFromCiclo(ciclo);
    String novoStatus = ciclo["status"];

    if (lucroLiquido >= stakeIndividual) {
      novoStatus = "ganho";
    } else if (perdaAcumulada >= (5 * stakeIndividual)) {
      novoStatus = "perdido";
    } else {
      novoStatus = "em_andamento";
    }

    if ((novoStatus == "ganho" || novoStatus == "perdido") && statusAntigo == "em_andamento") {
      // CORREÇÃO: Usa a data da última aposta para o registro no histórico
      DateTime dataRegistro = DateTime.now();
      if (listaApostas.isNotEmpty) {
        // Ordena temporariamente para garantir que pegamos a mais recente
        final sorted = List<Map<String, dynamic>>.from(listaApostas);
        sorted.sort((a, b) => DateTime.parse(a['data']).compareTo(DateTime.parse(b['data'])));
        dataRegistro = DateTime.parse(sorted.last['data']);
      }

      historicoBanca.add({
        "data": dataRegistro.toIso8601String(),
        "valorBanca": bancaAtual,
      });
    }

    setState(() {
      ciclos[cicloIndex]["lucroLiquido"] = double.parse(lucroLiquido.toStringAsFixed(2));
      ciclos[cicloIndex]["perdaAcumulada"] = double.parse(perdaAcumulada.toStringAsFixed(2));
      ciclos[cicloIndex]["qtdStakesUsadas"] = qtdUsadas;
      ciclos[cicloIndex]["status"] = novoStatus;
      _salvarDados();
    });
  }

  // ---------------------------
  // CRUD de Apostas
  // ---------------------------
  void _registrarAposta({
    required DateTime data,
    required String tipo,
    required String campeonato,
    required String time,
    required double odd,
    required double stakeUsada,
    required int resultado,
    required int cicloId,
    int? nivelConfianca,
    int? margem,
    String? comentarios,
    bool? evPositivo,
    int? playbookId,
    String? playbookNome,
  }) {
    double lucroCalculado;
    if (resultado == 1) {
      lucroCalculado = double.parse((stakeUsada * (odd - 1)).toStringAsFixed(2));
    } else {
      lucroCalculado = -double.parse(stakeUsada.toStringAsFixed(2));
    }

    final newId = apostas.isEmpty ? 1 : ((apostas.map((a) => (a["id"] as num).toInt()).reduce((x, y) => x > y ? x : y)) + 1);
    final aposta = <String, dynamic>{
      "id": newId,
      "data": data.toIso8601String(),
      "tipo": tipo,
      "campeonato": campeonato,
      "time": time,
      "odd": odd,
      "stake": stakeUsada,
      "lucro": lucroCalculado,
      "cicloId": cicloId,
    };

    if (nivelConfianca != null) aposta["nivelConfianca"] = nivelConfianca;
    if (margem != null) aposta["margem"] = margem;
    if (comentarios != null && comentarios.isNotEmpty) aposta["comentarios"] = comentarios;
    if (evPositivo != null) aposta["evPositivo"] = evPositivo;
    if (playbookId != null) aposta["playbookId"] = playbookId;
    if (playbookNome != null && playbookNome.isNotEmpty) aposta["playbookNome"] = playbookNome;


    setState(() {
      apostas.add(aposta);
      final cicloIndex = ciclos.indexWhere((c) => (c["id"] as num).toInt() == cicloId);
      if (cicloIndex != -1) {
        (ciclos[cicloIndex]["apostasIds"] as List).add(newId);
      }
      _atualizarCicloDepoisDeAposta(cicloId);
      _inicializarFiltros();
      _atualizarStakeSugerida();
    });
    _salvarDados();
  }

  void _atualizarAposta({
    required int id,
    required String tipo,
    required String campeonato,
    required String time,
    required double odd,
    required double stake,
    required int resultado,
    int? nivelConfianca,
    int? margem,
    String? comentarios,
    bool? evPositivo,
    int? playbookId,
    String? playbookNome,
  }) {
    final apostaIndex = apostas.indexWhere((a) => (a['id'] as num).toInt() == id);
    if (apostaIndex == -1) return;

    double lucroCalculado;
    if (resultado == 1) {
      lucroCalculado = double.parse((stake * (odd - 1)).toStringAsFixed(2));
    } else {
      lucroCalculado = -double.parse(stake.toStringAsFixed(2));
    }

    setState(() {
      apostas[apostaIndex]['tipo'] = tipo;
      apostas[apostaIndex]['campeonato'] = campeonato;
      apostas[apostaIndex]['time'] = time;
      apostas[apostaIndex]['odd'] = odd;
      apostas[apostaIndex]['stake'] = stake;
      apostas[apostaIndex]['lucro'] = lucroCalculado;

      apostas[apostaIndex]['nivelConfianca'] = nivelConfianca;
      apostas[apostaIndex]['margem'] = margem;
      apostas[apostaIndex]['comentarios'] = comentarios;
      apostas[apostaIndex]['evPositivo'] = evPositivo;
      apostas[apostaIndex]['playbookId'] = playbookId;
      apostas[apostaIndex]['playbookNome'] = playbookNome;

      final int cicloId = (apostas[apostaIndex]['cicloId'] as num).toInt();
      _atualizarCicloDepoisDeAposta(cicloId);
      _inicializarFiltros();
      _atualizarStakeSugerida();
    });
    _salvarDados();
  }

  void _adicionarPreLancamento() {
    final tipo = _tipoCtrl.text.trim().isEmpty ? "Geral" : _tipoCtrl.text.trim();
    final campeonato = _campeonatoCtrl.text.trim();
    final time = _timeCtrl.text.trim();
    final odd = double.tryParse(_oddCtrl.text.replaceAll(",", ".")) ?? 0.0;
    final stake = double.tryParse(_stakeCtrl.text.replaceAll(",", ".")) ?? _stakeIndividualDefault();
    final cicloId = _selectedCicloIdForForm;
    final margem = int.tryParse(_margemCtrl.text);
    final comentarios = _comentariosCtrl.text.trim();
    final playbookId = _playbookSelecionadoId;

    if (cicloId == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Selecione um ciclo para pré-lançar.")));
      return;
    }

    final int newId = preLancamentos.isEmpty
        ? 1
        : ((preLancamentos.map((p) => (p['id'] as num).toInt()).reduce((x, y) => x > y ? x : y)) + 1);

    final pre = <String, dynamic>{
      'id': newId,
      'dataCriacao': DateTime.now().toIso8601String(),
      'dataAposta': _dataAposta.toIso8601String(),
      'tipo': tipo,
      'campeonato': campeonato,
      'time': time,
      'odd': odd,
      'stake': stake,
      'cicloId': cicloId,
      'nivelConfianca': _nivelConfiancaSelecionado,
      'margem': margem,
      'comentarios': comentarios,
      'evPositivo': _evPositivoSelecionado,
      'resultado': _resultadoSelecionado,
      'playbookId': playbookId,
      'playbookNome': playbookId == null
          ? null
          : (playbooks.firstWhere((p) => (p['id'] as num).toInt() == playbookId, orElse: () => {})['nome'] as String?),
    };

    setState(() {
      preLancamentos.add(pre);
    });
    _salvarDados();

    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Aposta salva como pré-lançada.")));
  }

  void _usarPreLancamento(Map<String, dynamic> pre) {
    setState(() {
      _preLancamentoOrigemId = (pre['id'] as num).toInt();
      _tipoCtrl.text = (pre['tipo'] as String?) ?? '';
      _campeonatoCtrl.text = (pre['campeonato'] as String?) ?? '';
      _timeCtrl.text = (pre['time'] as String?) ?? '';
      _oddCtrl.text = ((pre['odd'] as num?)?.toDouble() ?? 2.0).toStringAsFixed(2);
      _stakeCtrl.text = ((pre['stake'] as num?)?.toDouble() ?? _stakeIndividualDefault()).toStringAsFixed(2);
      _selectedCicloIdForForm = (pre['cicloId'] as num?)?.toInt();
      _dataAposta = DateTime.tryParse((pre['dataAposta'] as String?) ?? '') ?? DateTime.now();
      _nivelConfiancaSelecionado = (pre['nivelConfianca'] as num?)?.toInt();
      _margemCtrl.text = pre['margem']?.toString() ?? '';
      _comentariosCtrl.text = (pre['comentarios'] as String?) ?? '';
      _evPositivoSelecionado = pre['evPositivo'] as bool?;
      _resultadoSelecionado = (pre['resultado'] as num?)?.toInt() ?? -1;
      _playbookSelecionadoId = (pre['playbookId'] as num?)?.toInt();
      _tabController.animateTo(2);
      _atualizarStakeSugerida();
    });
  }

  void _removerPreLancamentoPorId(int id) {
    setState(() {
      preLancamentos.removeWhere((p) => (p['id'] as num).toInt() == id);
      if (_preLancamentoOrigemId == id) {
        _preLancamentoOrigemId = null;
      }
    });
    _salvarDados();
  }

  Widget _buildCardAnalisePreLancamento() {
    final tipo = _tipoCtrl.text.trim();
    final campeonato = _campeonatoCtrl.text.trim();
    final time = _timeCtrl.text.trim();

    if (tipo.isEmpty && campeonato.isEmpty && time.isEmpty) {
      return const SizedBox.shrink();
    }

    final compativeis = apostas.where((a) {
      final mtTipo = tipo.isEmpty || ((a['tipo'] as String?) ?? '').toLowerCase() == tipo.toLowerCase();
      final mtCamp = campeonato.isEmpty || ((a['campeonato'] as String?) ?? '').toLowerCase() == campeonato.toLowerCase();
      final mtTime = time.isEmpty || ((a['time'] as String?) ?? '').toLowerCase() == time.toLowerCase();
      return mtTipo && mtCamp && mtTime;
    }).toList();

    final total = compativeis.length;
    final vitorias = compativeis.where((a) => ((a['lucro'] as num?)?.toDouble() ?? 0.0) > 0).length;
    final taxa = total > 0 ? (vitorias / total) * 100 : 0.0;
    final lucro = compativeis.fold<double>(0.0, (s, a) => s + ((a['lucro'] as num?)?.toDouble() ?? 0.0));
    final status = total == 0 ? 'Sem histórico suficiente' : (lucro >= 0 ? 'Perfil favorável' : 'Perfil de alerta');
    final cor = total == 0 ? Colors.grey.shade700 : (lucro >= 0 ? Colors.green.shade700 : Colors.red.shade700);

    return Card(
      color: cor.withOpacity(0.08),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Análise do pré-lançamento', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 6),
            Text('Base histórica compatível: $total aposta(s)'),
            Text('Taxa de acerto: ${taxa.toStringAsFixed(1)}%'),
            Text('Lucro acumulado: R\$ ${lucro.toStringAsFixed(2)}'),
            Text('Validador: $status', style: TextStyle(fontWeight: FontWeight.w600, color: cor)),
          ],
        ),
      ),
    );
  }

  void _adicionarPlaybook({
    required String nome,
    String? criterios,
    List<String>? checklist,
  }) {
    final newId = playbooks.isEmpty ? 1 : ((playbooks.map((p) => (p["id"] as num).toInt()).reduce((x, y) => x > y ? x : y)) + 1);
    final playbook = <String, dynamic>{
      "id": newId,
      "nome": nome,
      "criterios": (criterios ?? '').trim(),
      "checklist": checklist ?? <String>[],
      "criadoEm": DateTime.now().toIso8601String(),
    };

    setState(() {
      playbooks.add(playbook);
      _playbookSelecionadoId = newId;
      _salvarDados();
    });
  }

  Future<void> _mostrarDialogoPlaybook({
    Map<String, dynamic>? playbookParaEditar,
    bool duplicar = false,
  }) async {
    final bool isEditing = playbookParaEditar != null && !duplicar;
    final String nomeOriginal = playbookParaEditar?['nome']?.toString() ?? '';
    _playbookNomeCtrl.text = duplicar && nomeOriginal.isNotEmpty ? '$nomeOriginal (Cópia)' : nomeOriginal;
    _playbookCriteriosCtrl.text = playbookParaEditar?['criterios']?.toString() ?? '';
    final checklistAtual = ((playbookParaEditar?['checklist'] as List?) ?? const []).map((e) => e.toString()).join('\n');
    _playbookChecklistCtrl.text = checklistAtual;

    final salvar = await showDialog<bool>(
      context: context,
      builder: (c) => AlertDialog(
        title: Text(isEditing ? 'Editar Playbook' : (duplicar ? 'Duplicar Playbook' : 'Novo Playbook')),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _playbookNomeCtrl,
                decoration: const InputDecoration(labelText: 'Nome do playbook'),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _playbookCriteriosCtrl,
                decoration: const InputDecoration(labelText: 'Critérios (opcional)'),
                maxLines: 2,
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _playbookChecklistCtrl,
                decoration: const InputDecoration(labelText: 'Checklist (1 item por linha)'),
                maxLines: 5,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(c, false), child: const Text('Cancelar')),
          TextButton(onPressed: () => Navigator.pop(c, true), child: const Text('Salvar')),
        ],
      ),
    );

    if (salvar == true) {
      final nome = _playbookNomeCtrl.text.trim();
      if (nome.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Informe o nome do playbook.')));
        return;
      }

      final checklist = _playbookChecklistCtrl.text
          .split('\n')
          .map((e) => e.trim())
          .where((e) => e.isNotEmpty)
          .toList();

      if (isEditing) {
        final int id = (playbookParaEditar!['id'] as num).toInt();
        setState(() {
          final idx = playbooks.indexWhere((p) => (p['id'] as num).toInt() == id);
          if (idx != -1) {
            playbooks[idx]['nome'] = nome;
            playbooks[idx]['criterios'] = _playbookCriteriosCtrl.text.trim();
            playbooks[idx]['checklist'] = checklist;
            for (var a in apostas) {
              if ((a['playbookId'] as num?)?.toInt() == id) {
                a['playbookNome'] = nome;
              }
            }
          }
          _salvarDados();
        });
      } else {
        _adicionarPlaybook(nome: nome, criterios: _playbookCriteriosCtrl.text.trim(), checklist: checklist);
      }
    }
  }

  Future<void> _removerPlaybook(int id) async {
    final bool? ok = await _confirmDialog('Excluir playbook', 'Deseja excluir este playbook? As apostas vinculadas ficarão sem playbook.');
    if (ok != true) return;

    setState(() {
      playbooks.removeWhere((p) => (p['id'] as num).toInt() == id);
      for (var a in apostas) {
        if ((a['playbookId'] as num?)?.toInt() == id) {
          a.remove('playbookId');
          a.remove('playbookNome');
        }
      }
      if (_playbookSelecionadoId == id) _playbookSelecionadoId = null;
      if (_filtroPlaybookSelecionado == id) _filtroPlaybookSelecionado = null;
      _aplicarFiltros();
      _salvarDados();
    });
  }

  // ---------------------------
  // CRUD de Metas
  // ---------------------------
  void _adicionarMeta({
    required String nome,
    required String tipo,
    required double valor,
  }) {
    final newId = metas.isEmpty ? 1 : ((metas.map((m) => (m["id"] as num).toInt()).reduce((x, y) => x > y ? x : y)) + 1);
    final meta = {
      "id": newId,
      "nome": nome,
      "tipo": tipo,
      "valor": valor,
    };
    setState(() {
      metas.add(meta);
      _salvarDados();
    });
  }

  void _atualizarMeta({
    required int id,
    required String nome,
    required String tipo,
    required double valor,
  }) {
    final metaIndex = metas.indexWhere((m) => (m['id'] as num).toInt() == id);
    if (metaIndex == -1) return;
    setState(() {
      metas[metaIndex]['nome'] = nome;
      metas[metaIndex]['tipo'] = tipo;
      metas[metaIndex]['valor'] = valor;
      _salvarDados();
    });
  }

  void _excluirMeta(int id) {
    setState(() {
      metas.removeWhere((m) => (m['id'] as num).toInt() == id);
      _salvarDados();
    });
  }

  // ---------------------------
  // CRUD de Backup/Restore e EXPORTAÇÃO PARA IA
  // ---------------------------
  Future<void> _criarBackup() async {
    setState(() => _isLoadingBackup = true);
    try {
      final file = await _getFile();
      if (!await file.exists()) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Nenhum dado para salvar."), backgroundColor: Colors.orange),
        );
        return;
      }

      final String data = await file.readAsString();
      final String dataFormatada = DateFormat('yyyy-MM-dd_HH-mm').format(DateTime.now());
      final String nomeArquivo = 'backup_apostas_$dataFormatada.json';

      final tempDir = await getTemporaryDirectory();
      final backupFile = File('${tempDir.path}/$nomeArquivo');
      await backupFile.writeAsString(data);

      // Usa share_plus para compartilhar o arquivo
      await Share.shareXFiles(
        [XFile(backupFile.path)],
        subject: "Backup de Apostas - $dataFormatada",
        text: "Aqui está o seu backup de dados do app de apostas.",
      );

    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Erro ao criar backup: $e"), backgroundColor: Colors.red),
      );
    } finally {
      setState(() => _isLoadingBackup = false);
    }
  }

  // NOVO: Exportação de Relatório TXT para IA COMPLETO
  Future<void> _exportarRelatorioIA() async {
    setState(() => _isLoadingBackup = true);
    try {
      final sb = StringBuffer();
      final now = DateTime.now();
      final dateFormat = DateFormat('dd/MM/yyyy HH:mm');

      // --- CÁLCULOS PRÉVIOS ---

      // 1. Sequências (Streaks)
      int maxWinStreak = 0;
      int maxLoseStreak = 0;
      int currentW = 0;
      int currentL = 0;
      final sortedApostas = List<Map<String, dynamic>>.from(apostas)..sort((a, b) => a['data'].compareTo(b['data']));

      for (var a in sortedApostas) {
        final l = (a['lucro'] as num).toDouble();
        if (l > 0) {
          currentW++;
          currentL = 0;
          if (currentW > maxWinStreak) maxWinStreak = currentW;
        } else if (l < 0) {
          currentL++;
          currentW = 0;
          if (currentL > maxLoseStreak) maxLoseStreak = currentL;
        }
      }

      // 2. Break-even
      final oddMedia = _getOddMediaTotal();
      final taxaNecessaria = (oddMedia > 0) ? (1 / oddMedia) : 0.0;
      final taxaReal = _getTaxaAcertoReal(null);

      // 3. Faixa de Odds
      final Map<String, Map<String, dynamic>> oddsStats = {
        '1.01 - 1.50': {'lucro': 0.0, 'total': 0, 'wins': 0},
        '1.51 - 2.00': {'lucro': 0.0, 'total': 0, 'wins': 0},
        '2.01 - 3.00': {'lucro': 0.0, 'total': 0, 'wins': 0},
        '3.01+':       {'lucro': 0.0, 'total': 0, 'wins': 0},
      };

      for(var a in apostas) {
        final odd = (a['odd'] as num).toDouble();
        final lucro = (a['lucro'] as num).toDouble();
        String key = '3.01+';
        if(odd <= 1.50) key = '1.01 - 1.50';
        else if(odd <= 2.00) key = '1.51 - 2.00';
        else if(odd <= 3.00) key = '2.01 - 3.00';

        oddsStats[key]!['lucro'] += lucro;
        oddsStats[key]!['total']++;
        if(lucro > 0) oddsStats[key]!['wins']++;
      }

      // ---------------- ESCREVENDO O RELATÓRIO ----------------

      sb.writeln("=== RELATÓRIO COMPLETO DE PERFORMANCE (PARA ANÁLISE IA) ===");
      sb.writeln("Gerado em: ${dateFormat.format(now)}");
      sb.writeln("Banca Inicial: R\$ ${bancaInicial.toStringAsFixed(2)}");
      sb.writeln("");

      // BLOCO 1: RESUMO EXECUTIVO
      sb.writeln("--- 1. RESUMO FINANCEIRO E DE RISCO ---");
      sb.writeln("Banca Atual: R\$ ${bancaAtual.toStringAsFixed(2)}");
      sb.writeln("Lucro Líquido Total: R\$ ${lucroTotalApostas.toStringAsFixed(2)}");
      sb.writeln("ROI (sobre Banca Inicial+Aportes): ${roi.toStringAsFixed(2)}%");

      final double totalStaked = apostas.fold(0.0, (s, a) => s + (a['stake'] as num).toDouble());
      final double yieldPct = totalStaked > 0 ? (lucroTotalApostas / totalStaked) * 100 : 0.0;
      sb.writeln("Yield (sobre Turnover/Giro): ${yieldPct.toStringAsFixed(2)}%");

      final double grossProfit = apostas.where((a) => (a['lucro'] as num) > 0).fold(0.0, (s, a) => s + (a['lucro'] as num).toDouble());
      final double grossLoss = apostas.where((a) => (a['lucro'] as num) < 0).fold(0.0, (s, a) => s + ((a['lucro'] as num).abs()).toDouble());
      final double profitFactor = grossLoss == 0 ? (grossProfit > 0 ? 999.0 : 0.0) : (grossProfit / grossLoss);
      sb.writeln("Profit Factor: ${profitFactor >= 999 ? 'Infinito' : profitFactor.toStringAsFixed(2)}");

      final String maxDrawdownStr = ((_maxDrawdown?['percentual'] ?? 0.0) * 100).toStringAsFixed(1);
      final String maxDrawdownDataStr = _maxDrawdown?['data'] != null ? DateFormat('dd/MM/yyyy').format(DateTime.parse(_maxDrawdown!['data'])) : "N/D";
      sb.writeln("Máximo Drawdown (Queda): $maxDrawdownStr% (ocorrido em $maxDrawdownDataStr)");
      sb.writeln("");

      // BLOCO 2: MÉTRICAS ESTRUTURAIS
      sb.writeln("--- 2. MÉTRICAS ESTRUTURAIS (CONSISTÊNCIA) ---");
      sb.writeln("Odd Média Total: ${oddMedia.toStringAsFixed(2)}");
      sb.writeln("Taxa de Acerto Real: ${(taxaReal * 100).toStringAsFixed(2)}%");
      sb.writeln("Taxa de Acerto Necessária (Break-even): ${(taxaNecessaria * 100).toStringAsFixed(2)}%");
      sb.writeln("Status Break-even: ${taxaReal > taxaNecessaria ? "LUCRATIVO (Acima do necessário)" : "PREJUÍZO (Abaixo do necessário)"}");
      sb.writeln("Maior Sequência de Vitórias (Win Streak): $maxWinStreak");
      sb.writeln("Maior Sequência de Derrotas (Lose Streak): $maxLoseStreak");
      sb.writeln("");

      // BLOCO 3: EVOLUÇÃO MENSAL
      sb.writeln("--- 3. EVOLUÇÃO MENSAL (BASE: BANCA INICIAL DO MÊS + APORTES DO MÊS) ---");
      sb.writeln("Mês | Lucro (R\$) | Crescimento (%)");

      // Lógica de cálculo mensal (Replicada do gráfico para texto)
      final Map<String, double> lucroPorMes = {};
      final Map<String, double> aportesPorMes = {};
      final Map<String, double> saquesPorMes = {};
      final Set<String> mesesComAtividade = {};
      String getKey(String dateStr) {
        if (dateStr.isEmpty) return "";
        final d = DateTime.tryParse(dateStr);
        if (d == null) return "";
        return "${d.year}-${d.month.toString().padLeft(2, '0')}";
      }
      for (var a in apostas) {
        final key = getKey(a['data']);
        if (key.isNotEmpty) {
          lucroPorMes[key] = (lucroPorMes[key] ?? 0.0) + (a['lucro'] as num).toDouble();
          mesesComAtividade.add(key);
        }
      }
      for (var a in aportes) {
        final key = getKey(a['data']);
        if (key.isNotEmpty) {
          aportesPorMes[key] = (aportesPorMes[key] ?? 0.0) + (a['valor'] as num).toDouble();
          mesesComAtividade.add(key);
        }
      }
      for (var s in saques) {
        final key = getKey(s['data']);
        if (key.isNotEmpty) {
          saquesPorMes[key] = (saquesPorMes[key] ?? 0.0) + (s['valor'] as num).toDouble();
          mesesComAtividade.add(key);
        }
      }
      final mesesOrdenados = mesesComAtividade.toList()..sort();
      if (mesesOrdenados.isNotEmpty) {
        DateTime dataInicio = DateTime.parse("${mesesOrdenados.first}-01");
        DateTime dataFim = DateTime.now();
        if (DateTime.parse("${mesesOrdenados.last}-01").isAfter(dataFim)) dataFim = DateTime.parse("${mesesOrdenados.last}-01");
        double bancaRolante = bancaInicial;
        DateTime cursor = DateTime(dataInicio.year, dataInicio.month, 1);

        while (!cursor.isAfter(DateTime(dataFim.year, dataFim.month, 1))) {
          final key = "${cursor.year}-${cursor.month.toString().padLeft(2, '0')}";
          final double aportesDoMes = aportesPorMes[key] ?? 0.0;
          final double saquesDoMes = saquesPorMes[key] ?? 0.0;
          final double lucroDoMes = lucroPorMes[key] ?? 0.0;
          final double baseCalculo = bancaRolante + aportesDoMes;
          double crescimentoPct = 0.0;
          if (baseCalculo > 0) crescimentoPct = (lucroDoMes / baseCalculo) * 100;

          if (mesesComAtividade.contains(key)) {
            sb.writeln("$key | R\$ ${lucroDoMes.toStringAsFixed(2).padLeft(9)} | ${crescimentoPct.toStringAsFixed(2)}%");
          }
          bancaRolante = baseCalculo + lucroDoMes - saquesDoMes;
          cursor = DateTime(cursor.year, cursor.month + 1, 1);
        }
      } else {
        sb.writeln("(Sem dados mensais suficientes)");
      }
      sb.writeln("");

      // BLOCO 4: ANÁLISE POR FAIXA DE ODDS
      sb.writeln("--- 4. PERFORMANCE POR FAIXA DE ODDS ---");
      oddsStats.forEach((range, data) {
        final total = data['total'] as int;
        if(total > 0) {
          final wins = data['wins'] as int;
          final lucro = data['lucro'] as double;
          final winRate = (wins / total) * 100;
          sb.writeln("Faixa $range: $total apostas | Taxa: ${winRate.toStringAsFixed(1)}% | Resultado: R\$ ${lucro.toStringAsFixed(2)}");
        }
      });
      sb.writeln("");

      // BLOCO 5: CICLOS
      final ciclosGanhos = ciclos.where((c) => c['status'] == 'ganho').length;
      final ciclosPerdidos = ciclos.where((c) => c['status'] == 'perdido').length;
      final ciclosAndamento = ciclos.where((c) => c['status'] == 'em_andamento').length;
      sb.writeln("--- 5. GESTÃO DE CICLOS ---");
      sb.writeln("Total: ${ciclos.length} | Ganhos: $ciclosGanhos | Perdidos: $ciclosPerdidos | Em Andamento: $ciclosAndamento");
      sb.writeln("Últimos 10 ciclos:");
      final ultimosCiclos = ciclos.length > 10 ? ciclos.sublist(ciclos.length - 10) : ciclos;
      for(var c in ultimosCiclos.reversed) {
        sb.writeln("- ID ${c['id']}: Status=${c['status']} | Lucro Liq: R\$${(c['lucroLiquido'] as num).toStringAsFixed(2)}");
      }
      sb.writeln("");

      // BLOCO 6: TOP/BOTTOM PERFORMANCE
      sb.writeln("--- 6. DESTAQUES DE PERFORMANCE (TOP 3) ---");
      String _analisarCategoria(String categoria, String chaveJson) {
        final Map<String, double> lucroPorItem = {};
        for(var a in apostas) {
          dynamic item = a[chaveJson];
          // Tratamento especial para booleanos ou nulos
          if (item == null) continue;
          if (item is bool) item = item ? "Sim" : "Não";
          if (item is int) item = item.toString();

          if((item as String).isNotEmpty) {
            lucroPorItem[item] = (lucroPorItem[item] ?? 0.0) + (a['lucro'] as num).toDouble();
          }
        }
        final sortedKeys = lucroPorItem.keys.toList()..sort((k1, k2) => lucroPorItem[k2]!.compareTo(lucroPorItem[k1]!));
        final buffer = StringBuffer();
        buffer.writeln(">> $categoria:");
        if (sortedKeys.isEmpty) buffer.writeln("   (Sem dados)");
        else {
          for(var i=0; i<3 && i<sortedKeys.length; i++) {
            final key = sortedKeys[i];
            if(lucroPorItem[key]! > 0) buffer.writeln("   [+] $key: R\$ ${lucroPorItem[key]!.toStringAsFixed(2)}");
          }
          for(var i=sortedKeys.length-1; i>=0 && i >= sortedKeys.length - 3; i--) {
            final key = sortedKeys[i];
            if(lucroPorItem[key]! < 0) buffer.writeln("   [-] $key: R\$ ${lucroPorItem[key]!.toStringAsFixed(2)}");
          }
        }
        return buffer.toString();
      }

      sb.writeln(_analisarCategoria("Por Campeonato", "campeonato"));
      sb.writeln(_analisarCategoria("Por Time", "time"));
      sb.writeln(_analisarCategoria("Por Tipo de Aposta", "tipo"));
      sb.writeln(_analisarCategoria("Por Nível de Confiança", "nivelConfianca"));
      sb.writeln(_analisarCategoria("Por EV+ (Valor Esperado)", "evPositivo"));
      sb.writeln("");

      // BLOCO 7: HISTÓRICO
      sb.writeln("--- 7. HISTÓRICO RECENTE DE APOSTAS (Últimas 50) ---");
      sb.writeln("Data | Camp | Time | Tipo | Odd | Stake | Lucro | Margem | EV | Obs");
      final ultimasApostas = apostas.length > 50 ? apostas.sublist(apostas.length - 50) : apostas;
      for(var a in ultimasApostas.reversed) {
        final data = DateTime.parse(a['data']);
        final dStr = "${data.day}/${data.month}";
        final camp = a['campeonato'] ?? "-";
        final time = a['time'] ?? "-";
        final tipo = a['tipo'] ?? "-";
        final odd = (a['odd'] as num).toStringAsFixed(2);
        final stake = (a['stake'] as num).toStringAsFixed(2);
        final lucro = (a['lucro'] as num).toStringAsFixed(2);
        final margem = a['margem']?.toString() ?? "-";
        final ev = (a['evPositivo'] == true) ? "Sim" : (a['evPositivo'] == false ? "Não" : "-");
        final obs = (a['comentarios'] as String?)?.replaceAll('\n', ' ') ?? "";
        sb.writeln("$dStr | $camp | $time | $tipo | $odd | $stake | $lucro | $margem | $ev | $obs");
      }

      sb.writeln("");
      sb.writeln("--- FIM DO ARQUIVO ---");

      // Salvar e Compartilhar
      final nomeArquivo = 'Relatorio_Completo_Apostas_${DateFormat('yyyyMMdd_HHmm').format(now)}.txt';
      final tempDir = await getTemporaryDirectory();
      final file = File('${tempDir.path}/$nomeArquivo');
      await file.writeAsString(sb.toString());

      await Share.shareXFiles(
        [XFile(file.path)],
        subject: "Dossiê Completo de Apostas",
        text: "Relatório detalhado com todas as métricas para análise de IA.",
      );

    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Erro ao exportar relatório: $e"), backgroundColor: Colors.red),
      );
    } finally {
      setState(() => _isLoadingBackup = false);
    }
  }

  Future<void> _carregarBackup() async {
    final bool? confirmar = await _confirmDialog(
      "Restaurar Backup",
      "Isso irá APAGAR todos os dados atuais e substituí-los pelo arquivo de backup. Esta ação não pode ser desfeita.\n\nDeseja continuar?",
    );

    if (confirmar != true) return;

    setState(() => _isLoadingBackup = true);
    try {
      final FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['json'],
      );

      if (result != null && result.files.single.path != null) {
        final pickedFile = File(result.files.single.path!);
        final data = await pickedFile.readAsString();

        // Validação simples do JSON
        final decoded = jsonDecode(data);
        if (decoded is! Map || !decoded.containsKey('config') || !decoded.containsKey('apostas')) {
          throw Exception("Este não parece ser um arquivo de backup válido.");
        }

        // Se o JSON é válido, substitui o arquivo atual
        final appFile = await _getFile();
        await appFile.writeAsString(data);

        // Força o recarregamento dos dados
        await _carregarDados();

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Backup restaurado com sucesso!"), backgroundColor: Colors.green),
        );
      } else {
        // Usuário cancelou o seletor
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Restauração cancelada.")),
        );
      }

    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Erro ao restaurar backup: $e"), backgroundColor: Colors.red),
      );
    } finally {
      setState(() => _isLoadingBackup = false);
    }
  }

  // NOVO: Função para o botão "Registrar Snapshot"
  Future<void> _registrarHistoricoSnapshot() async {
    setState(() => _isLoadingBackup = true); // Reutiliza o loading do backup
    try {
      // Chama a função de salvar o dashboard forçando um novo registro
      await _salvarDadosDashboard(forceNewRecord: true);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Snapshot do histórico salvo com sucesso!"),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Erro ao salvar snapshot: $e"), backgroundColor: Colors.red),
      );
    } finally {
      setState(() => _isLoadingBackup = false);
    }
  }

  // NOVO: Função para forçar a recriação do arquivo de dashboard
  Future<void> _forcarRecriacaoDashboard() async {
    final bool? confirmar = await _confirmDialog(
      "Forçar Recriação do Sumário",
      "Isso irá deletar o arquivo 'registros_apostas.json' e criá-lo novamente com os dados atuais. Use isso se o arquivo de sumário parecer corrompido.\n\nDeseja continuar?",
    );

    if (confirmar != true) return;

    setState(() => _isLoadingBackup = true);
    try {
      final file = await _getDashboardFile();
      if (await file.exists()) {
        await file.delete(); // Deleta o arquivo corrompido
      }
      // Chama a função de salvar, que agora (sendo forçada)
      // irá criar um novo arquivo limpo.
      await _salvarDadosDashboard(forceNewRecord: true);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Arquivo de sumário recriado com sucesso!"),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Erro ao recriar arquivo: $e"), backgroundColor: Colors.red),
      );
    } finally {
      setState(() => _isLoadingBackup = false);
    }
  }


  // ---------------------------
  // UI helpers
  // ---------------------------
  Color _corStatus(String status) {
    switch (status) {
      case "ganho":
        return Colors.green.shade300;
      case "perdido":
        return Colors.red.shade300;
      default:
        return Colors.yellow.shade300;
    }
  }

  Future<bool?> _confirmDialog(String titulo, String mensagem) {
    return showDialog<bool>(
      context: context,
      builder: (c) => AlertDialog(
        title: Text(titulo),
        content: Text(mensagem),
        actions: [
          TextButton(onPressed: () => Navigator.pop(c, false), child: const Text("Cancelar")),
          TextButton(onPressed: () => Navigator.pop(c, true), child: const Text("Confirmar")),
        ],
      ),
    );
  }

  Future<void> _mostrarDialogoEditarAposta(Map<String, dynamic> apostaParaEditar) async {
    final tipoCtrl = TextEditingController(text: apostaParaEditar['tipo']);
    final campeonatoCtrl = TextEditingController(text: apostaParaEditar['campeonato'] ?? '');
    final timeCtrl = TextEditingController(text: apostaParaEditar['time'] ?? '');
    final oddCtrl = TextEditingController(text: (apostaParaEditar['odd'] as num).toString());
    final stakeCtrl = TextEditingController(text: (apostaParaEditar['stake'] as num).toString());
    int resultado = (apostaParaEditar['lucro'] as num) > 0 ? 1 : -1;
    int? nivelConfianca = (apostaParaEditar['nivelConfianca'] as num?)?.toInt();
    final margemCtrl = TextEditingController(text: apostaParaEditar['margem']?.toString() ?? '');
    final comentariosCtrl = TextEditingController(text: apostaParaEditar['comentarios'] ?? '');
    bool? evPositivo = apostaParaEditar['evPositivo'] as bool?;
    int? playbookId = (apostaParaEditar['playbookId'] as num?)?.toInt();

    final bool? salvar = await showDialog<bool>(
      context: context,
      builder: (c) => StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            title: const Text("Editar Aposta"),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(controller: tipoCtrl, decoration: const InputDecoration(labelText: "Tipo")),
                  TextFormField(controller: campeonatoCtrl, decoration: const InputDecoration(labelText: "Campeonato")),
                  TextFormField(controller: timeCtrl, decoration: const InputDecoration(labelText: "Time")),
                  TextFormField(controller: oddCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: "Odd")),
                  TextFormField(controller: stakeCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: "Stake")),
                  const SizedBox(height: 16),

                  // MODIFICADO: Dropdown agora aceita valor Nulo (int?)
                  DropdownButtonFormField<int?>(
                    decoration: const InputDecoration(labelText: "Nível de Confiança"),
                    value: nivelConfianca,
                    items: [
                      const DropdownMenuItem<int?>(
                        value: null,
                        child: Text("Não Informado (Vazio)", style: TextStyle(color: Colors.grey)),
                      ),
                      ...List.generate(10, (i) => DropdownMenuItem<int?>(
                          value: i + 1,
                          child: Text((i + 1).toString())
                      )),
                    ],
                    onChanged: (v) => setDialogState(() => nivelConfianca = v),
                  ),

                  const SizedBox(height: 16),
                  TextFormField(
                    controller: margemCtrl,
                    keyboardType: const TextInputType.numberWithOptions(signed: true),
                    decoration: const InputDecoration(labelText: "Margem (+/-) (Deixe vazio para remover)"),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: comentariosCtrl,
                    decoration: const InputDecoration(labelText: "Comentários"),
                    maxLines: 2,
                  ),
                  const SizedBox(height: 16),

                  // MODIFICADO: Substituído Checkbox por Dropdown para permitir "Nulo"
                  DropdownButtonFormField<bool?>(
                    decoration: const InputDecoration(labelText: "Aposta de Valor (EV+)"),
                    value: evPositivo,
                    items: const [
                      DropdownMenuItem<bool?>(
                        value: null,
                        child: Text("Não Informado / N/A", style: TextStyle(color: Colors.grey)),
                      ),
                      DropdownMenuItem<bool?>(
                        value: true,
                        child: Text("Sim (EV+)"),
                      ),
                      DropdownMenuItem<bool?>(
                        value: false,
                        child: Text("Não (EV-)"),
                      ),
                    ],
                    onChanged: (v) => setDialogState(() => evPositivo = v),
                  ),

                  const SizedBox(height: 16),
                  DropdownButtonFormField<int?>(
                    decoration: const InputDecoration(labelText: "Playbook usado"),
                    value: playbookId,
                    items: [
                      const DropdownMenuItem<int?>(
                        value: null,
                        child: Text("Sem playbook", style: TextStyle(color: Colors.grey)),
                      ),
                      ...playbooks.map((p) {
                        final id = (p['id'] as num).toInt();
                        final nome = p['nome'] as String;
                        return DropdownMenuItem<int?>(value: id, child: Text(nome));
                      }),
                    ],
                    onChanged: (v) => setDialogState(() => playbookId = v),
                  ),

                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text("Resultado: "),
                      const SizedBox(width: 8),
                      ChoiceChip(
                        label: const Text("Ganhou"),
                        selected: resultado == 1,
                        onSelected: (s) => setDialogState(() => resultado = s ? 1 : resultado),
                      ),
                      const SizedBox(width: 8),
                      ChoiceChip(
                        label: const Text("Perdeu"),
                        selected: resultado == -1,
                        onSelected: (s) => setDialogState(() => resultado = s ? -1 : resultado),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(c, false), child: const Text("Cancelar")),
              TextButton(onPressed: () => Navigator.pop(c, true), child: const Text("Salvar")),
            ],
          );
        },
      ),
    );

    if (salvar == true) {
      final tipo = tipoCtrl.text.trim().isEmpty ? "Geral" : tipoCtrl.text.trim();
      final campeonato = campeonatoCtrl.text.trim();
      final time = timeCtrl.text.trim();
      final odd = double.tryParse(oddCtrl.text.replaceAll(",", ".")) ?? 0.0;
      final stake = double.tryParse(stakeCtrl.text.replaceAll(",", ".")) ?? 0.0;
      final id = (apostaParaEditar['id'] as num).toInt();
      // Se o campo estiver vazio, int.tryParse retorna null, limpando o valor
      final margem = int.tryParse(margemCtrl.text);
      final comentarios = comentariosCtrl.text.trim();

      _atualizarAposta(
        id: id,
        tipo: tipo,
        campeonato: campeonato,
        time: time,
        odd: odd,
        stake: stake,
        resultado: resultado,
        nivelConfianca: nivelConfianca,
        margem: margem,
        comentarios: comentarios,
        evPositivo: evPositivo,
        playbookId: playbookId,
        playbookNome: playbookId == null ? null : (playbooks.firstWhere((p) => (p['id'] as num).toInt() == playbookId, orElse: () => {})['nome'] as String?),
      );
    }
  }

  Future<void> _mostrarDialogoMeta({Map<String, dynamic>? metaParaEditar}) async {
    final nomeCtrl = TextEditingController(text: metaParaEditar?['nome'] ?? '');
    final valorCtrl = TextEditingController(text: metaParaEditar?['valor']?.toString() ?? '');
    String tipoSelecionado = metaParaEditar?['tipo'] ?? 'ciclo';
    final isEditing = metaParaEditar != null;

    final bool? salvar = await showDialog<bool>(
      context: context,
      builder: (c) => StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            title: Text(isEditing ? "Editar Meta" : "Adicionar Meta"),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(controller: nomeCtrl, decoration: const InputDecoration(labelText: "Nome da meta")),
                DropdownButtonFormField<String>(
                  value: tipoSelecionado,
                  items: const [
                    DropdownMenuItem(value: "ciclo", child: Text("Por Ciclo")),
                    DropdownMenuItem(value: "total", child: Text("Total")),
                  ],
                  onChanged: (v) {
                    if (v != null) setDialogState(() => tipoSelecionado = v);
                  },
                  decoration: const InputDecoration(labelText: "Tipo de Meta"),
                ),
                TextFormField(controller: valorCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: "Valor (R\$)")),
              ],
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(c, false), child: const Text("Cancelar")),
              TextButton(
                onPressed: () {
                  final valor = double.tryParse(valorCtrl.text.replaceAll(",", ".")) ?? 0.0;
                  if (nomeCtrl.text.trim().isEmpty || valor <= 0) {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Preencha todos os campos corretamente.")));
                    return;
                  }
                  if (isEditing) {
                    _atualizarMeta(id: metaParaEditar!['id'], nome: nomeCtrl.text.trim(), tipo: tipoSelecionado, valor: valor);
                  } else {
                    _adicionarMeta(nome: nomeCtrl.text.trim(), tipo: tipoSelecionado, valor: valor);
                  }
                  Navigator.pop(c, true);
                },
                child: const Text("Salvar"),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildDetalhesExpandidos(String nome, String tipoRanking) {
    List<Map<String, dynamic>> apostasDoItem = [];

    switch (tipoRanking) {
      case 'Time':
        apostasDoItem = apostas.where((a) => (a['time'] as String?) == nome).toList();
        break;
      case 'Tipo de Aposta':
        apostasDoItem = apostas.where((a) => a['tipo'] == nome).toList();
        break;
      case 'Campeonato':
        apostasDoItem = apostas.where((a) => (a['campeonato'] as String?) == nome).toList();
        break;
      case 'Nível de Confiança':
        int? nivel;
        final parts = nome.split(' ');
        if (parts.length == 2 && parts.first.toLowerCase().startsWith('nível')) {
          nivel = int.tryParse(parts.last);
        } else {
          nivel = int.tryParse(nome);
        }
        apostasDoItem = apostas.where((a) {
          final nc = (a['nivelConfianca'] as num?)?.toInt();
          return nc != null && nc == nivel;
        }).toList();
        break;
      case 'Margem':
        int? margem;
        final parts = nome.split(' ');
        if (parts.length == 2 && parts.first.toLowerCase() == 'margem') {
          margem = int.tryParse(parts.last);
        }
        apostasDoItem = apostas.where((a) => (a['margem'] as num?)?.toInt() == margem).toList();
        break;
      case 'Comentários':
        apostasDoItem = apostas.where((a) => (a['comentarios'] as String?) == nome).toList();
        break;
      case 'Playbook':
        apostasDoItem = apostas.where((a) => (a['playbookNome'] as String?) == nome).toList();
        break;
    // CORREÇÃO: Lógica de 3 estados
      case 'EV+':
        if (nome == 'Sim (EV+)') {
          apostasDoItem = apostas.where((a) => (a['evPositivo'] as bool?) == true).toList();
        } else if (nome == 'Não (EV-)') {
          apostasDoItem = apostas.where((a) => (a['evPositivo'] as bool?) == false).toList();
        } else { // 'N/A (Não Calculado)'
          apostasDoItem = apostas.where((a) => a['evPositivo'] == null).toList();
        }
        break;
    }

    if (apostasDoItem.isEmpty) {
      return const Padding(padding: EdgeInsets.all(8.0), child: Text("Nenhuma aposta encontrada."));
    }

    // Lógica de exibição para Time
    if (tipoRanking == 'Time') {
      final Map<String, Map<String, dynamic>> porTipo = {};
      for (var aposta in apostasDoItem) {
        final tipo = aposta['tipo'] as String;
        if (!porTipo.containsKey(tipo)) {
          porTipo[tipo] = {'vitorias': 0, 'total': 0, 'retorno': 0.0};
        }
        porTipo[tipo]!['total']++;
        final lucro = (aposta['lucro'] as num).toDouble();
        porTipo[tipo]!['retorno'] += lucro;
        if (lucro > 0) porTipo[tipo]!['vitorias']++;
      }

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(padding: EdgeInsets.all(8.0), child: Text("Desempenho por Tipo de Aposta:", style: TextStyle(fontWeight: FontWeight.bold))),
          ...porTipo.entries.map((entry) {
            final tipo = entry.key;
            final vitorias = entry.value['vitorias'] as int;
            final total = entry.value['total'] as int;
            final retorno = (entry.value['retorno'] as num).toDouble();
            final taxa = total > 0 ? (vitorias / total * 100) : 0.0;

            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(child: Text(tipo)),
                  Text("${taxa.toStringAsFixed(1)}% ($vitorias/$total)"),
                  const SizedBox(width: 8),
                  Text("R\$ ${retorno.toStringAsFixed(2)}", style: TextStyle(color: retorno >= 0 ? Colors.green.shade700 : Colors.red.shade700, fontWeight: FontWeight.bold)),
                ],
              ),
            );
          }).toList(),

          const Divider(height: 20, thickness: 1, indent: 16, endIndent: 16),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
            child: Text(
              "Histórico de Comentários e Margens:",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          ...apostasDoItem.reversed.map((aposta) {
            final margem = aposta['margem'] as int?;
            final comentarios = aposta['comentarios'] as String?;
            final nivelConfianca = aposta['nivelConfianca'] as int?;
            final lucro = (aposta['lucro'] as num).toDouble();
            final data = DateTime.parse(aposta['data']);
            final dataFormatada = "${data.day.toString().padLeft(2, '0')}/${data.month.toString().padLeft(2, '0')}";
            final tipoAposta = aposta['tipo'] as String;

            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 6.0),
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Theme.of(context).brightness == Brightness.light ? Colors.grey.shade100 : Colors.grey.shade800,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            "$dataFormatada - $tipoAposta",
                            style: TextStyle(fontSize: 12, color: Colors.grey.shade600, fontWeight: FontWeight.bold),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Text(
                          "R\$ ${lucro.toStringAsFixed(2)}",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: lucro >= 0 ? Colors.green.shade700 : Colors.red.shade700,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    if (nivelConfianca != null)
                      Text(
                        "Confiança: $nivelConfianca/10",
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    if (margem != null)
                      Text(
                        "Margem: $margem",
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    if (comentarios != null && comentarios.isNotEmpty)
                      Text(
                        "Comentário: $comentarios",
                        style: const TextStyle(fontStyle: FontStyle.italic),
                      ),
                    if (margem == null && nivelConfianca == null && (comentarios == null || comentarios.isEmpty))
                      Text(
                        "Sem dados qualitativos registrados.",
                        style: TextStyle(fontStyle: FontStyle.italic, color: Colors.grey.shade500, fontSize: 12),
                      ),
                  ],
                ),
              ),
            );
          }).toList(),
          const SizedBox(height: 8), // Espaçamento final
        ],
      );
    }
    // Lógica de exibição para Tipo de Aposta
    else if (tipoRanking == 'Tipo de Aposta') {
      final Map<String, Map<String, dynamic>> porTime = {};
      for (var aposta in apostasDoItem) {
        final time = (aposta['time'] as String?) ?? 'Sem time';
        if (time.isEmpty) continue;
        if (!porTime.containsKey(time)) {
          porTime[time] = {'vitorias': 0, 'total': 0, 'retorno': 0.0};
        }
        porTime[time]!['total']++;
        final lucro = (aposta['lucro'] as num).toDouble();
        porTime[time]!['retorno'] += lucro;
        if (lucro > 0) porTime[time]!['vitorias']++;
      }

      final listaOrdenada = porTime.entries.toList()..sort((a, b) => (b.value['retorno'] as double).compareTo(a.value['retorno'] as double));

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(padding: EdgeInsets.all(8.0), child: Text("Desempenho por Time:", style: TextStyle(fontWeight: FontWeight.bold))),
          ...listaOrdenada.map((entry) {
            final time = entry.key;
            final vitorias = entry.value['vitorias'] as int;
            final total = entry.value['total'] as int;
            final retorno = (entry.value['retorno'] as num).toDouble();
            final taxa = total > 0 ? (vitorias / total * 100) : 0.0;

            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(child: Text(time)),
                  Text("${taxa.toStringAsFixed(1)}% ($vitorias/$total)"),
                  const SizedBox(width: 8),
                  Text("R\$ ${retorno.toStringAsFixed(2)}", style: TextStyle(color: retorno >= 0 ? Colors.green.shade700 : Colors.red.shade700, fontWeight: FontWeight.bold)),
                ],
              ),
            );
          }).toList(),
        ],
      );
    }
    // Lógica de exibição para Campeonato
    else if (tipoRanking == 'Campeonato') {
      final Map<String, Map<String, dynamic>> porTime = {};
      final Map<String, Map<String, dynamic>> porTipo = {};

      for (var aposta in apostasDoItem) {
        final time = (aposta['time'] as String?) ?? 'Sem time';
        final tipo = aposta['tipo'] as String;
        final lucro = (aposta['lucro'] as num).toDouble();

        if (time.isNotEmpty) {
          if (!porTime.containsKey(time)) {
            porTime[time] = {'vitorias': 0, 'total': 0, 'retorno': 0.0};
          }
          porTime[time]!['total']++;
          porTime[time]!['retorno'] += lucro;
          if (lucro > 0) porTime[time]!['vitorias']++;
        }

        if (!porTipo.containsKey(tipo)) {
          porTipo[tipo] = {'vitorias': 0, 'total': 0, 'retorno': 0.0};
        }
        porTipo[tipo]!['total']++;
        porTipo[tipo]!['retorno'] += lucro;
        if (lucro > 0) porTipo[tipo]!['vitorias']++;
      }

      final listaTimes = porTime.entries.toList()..sort((a, b) => (b.value['retorno'] as double).compareTo(a.value['retorno'] as double));
      final listaTipos = porTipo.entries.toList()..sort((a, b) => (b.value['retorno'] as double).compareTo(a.value['retorno'] as double));

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(padding: EdgeInsets.all(8.0), child: Text("Desempenho por Time:", style: TextStyle(fontWeight: FontWeight.bold))),
          ...listaTimes.map((entry) {
            final time = entry.key;
            final vitorias = entry.value['vitorias'] as int;
            final total = entry.value['total'] as int;
            final retorno = (entry.value['retorno'] as num).toDouble();
            final taxa = total > 0 ? (vitorias / total * 100) : 0.0;

            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(child: Text(time)),
                  Text("${taxa.toStringAsFixed(1)}% ($vitorias/$total)"),
                  const SizedBox(width: 8),
                  Text("R\$ ${retorno.toStringAsFixed(2)}", style: TextStyle(color: retorno >= 0 ? Colors.green.shade700 : Colors.red.shade700, fontWeight: FontWeight.bold)),
                ],
              ),
            );
          }).toList(),
          const Divider(height: 20),
          const Padding(padding: EdgeInsets.all(8.0), child: Text("Desempenho por Tipo de Aposta:", style: TextStyle(fontWeight: FontWeight.bold))),
          ...listaTipos.map((entry) {
            final tipo = entry.key;
            final vitorias = entry.value['vitorias'] as int;
            final total = entry.value['total'] as int;
            final retorno = (entry.value['retorno'] as num).toDouble();
            final taxa = total > 0 ? (vitorias / total * 100) : 0.0;

            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(child: Text(tipo)),
                  Text("${taxa.toStringAsFixed(1)}% ($vitorias/$total)"),
                  const SizedBox(width: 8),
                  Text("R\$ ${retorno.toStringAsFixed(2)}", style: TextStyle(color: retorno >= 0 ? Colors.green.shade700 : Colors.red.shade700, fontWeight: FontWeight.bold)),
                ],
              ),
            );
          }).toList(),
        ],
      );
    }
    // Lógica de exibição para Nível de Confiança, Margem, e Comentários
    else if (tipoRanking == 'Nível de Confiança' || tipoRanking == 'Margem' || tipoRanking == 'Comentários' || tipoRanking == 'EV+') {
      final Map<String, Map<String, dynamic>> porTipo = {};
      for (var aposta in apostasDoItem) {
        final tipo = aposta['tipo'] as String? ?? 'Geral';
        if (!porTipo.containsKey(tipo)) {
          porTipo[tipo] = {'vitorias': 0, 'total': 0, 'retorno': 0.0};
        }
        porTipo[tipo]!['total']++;
        final lucro = (aposta['lucro'] as num).toDouble();
        porTipo[tipo]!['retorno'] += lucro;
        if (lucro > 0) porTipo[tipo]!['vitorias']++;
      }

      final listaOrdenada = porTipo.entries.toList()..sort((a, b) => (b.value['retorno'] as double).compareTo(a.value['retorno'] as double));

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(padding: const EdgeInsets.all(8.0), child: Text("Desempenho por Tipo (dentro de '$nome')", style: const TextStyle(fontWeight: FontWeight.bold))),
          ...listaOrdenada.map((entry) {
            final tipo = entry.key;
            final vitorias = entry.value['vitorias'] as int;
            final total = entry.value['total'] as int;
            final retorno = (entry.value['retorno'] as num).toDouble();
            final taxa = total > 0 ? (vitorias / total * 100) : 0.0;

            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(child: Text(tipo)),
                  Text("${taxa.toStringAsFixed(1)}% ($vitorias/$total)"),
                  const SizedBox(width: 8),
                  Text("R\$ ${retorno.toStringAsFixed(2)}", style: TextStyle(color: retorno >= 0 ? Colors.green.shade700 : Colors.red.shade700, fontWeight: FontWeight.bold)),
                ],
              ),
            );
          }).toList(),
        ],
      );
    }

    return const SizedBox.shrink();
  }

  Widget _buildGraficoAnalise() {
    final Map<String, dynamic> dadosAgrupados = {};
    String? chaveAgrupamento;

    switch (_analiseAssunto) {
      case 'Campeonato':
        chaveAgrupamento = 'campeonato';
        break;
      case 'Tipo de Aposta':
        chaveAgrupamento = 'tipo';
        break;
      case 'Nível de Confiança':
        chaveAgrupamento = 'nivelConfianca';
        break;
      case 'Margem':
        chaveAgrupamento = 'margem';
        break;
      case 'Comentários':
        chaveAgrupamento = 'comentarios';
        break;
      case 'EV+':
        chaveAgrupamento = 'evPositivo';
        break;
      case 'Playbook':
        chaveAgrupamento = 'playbookNome';
        break;
      case 'Time':
      default:
        chaveAgrupamento = 'time';
        break;
    }

    for (var aposta in apostas) {
      dynamic chave;
      if (chaveAgrupamento == 'nivelConfianca') {
        if (!aposta.containsKey('nivelConfianca') || aposta['nivelConfianca'] == null) continue;
        chave = (aposta['nivelConfianca'] as num).toInt();
      } else if (chaveAgrupamento == 'margem') {
        if (!aposta.containsKey('margem') || aposta['margem'] == null) continue;
        chave = (aposta['margem'] as num).toInt();
      }
      // CORREÇÃO: Trata os 3 estados
      else if (chaveAgrupamento == 'evPositivo') {
        chave = aposta['evPositivo'] as bool?; // chave é bool? (true, false, ou null)
      } else { // 'time', 'campeonato', 'tipo', 'comentarios'
        chave = aposta[chaveAgrupamento] as String?;
        if (chave == null || (chave is String && chave.isEmpty)) continue;
      }

      String keyStr;
      if (chaveAgrupamento == 'nivelConfianca') {
        keyStr = "Nível $chave";
      } else if (chaveAgrupamento == 'margem') {
        keyStr = "Margem $chave";
      }
      // CORREÇÃO: Trata os 3 estados
      else if (chaveAgrupamento == 'evPositivo') {
        if (chave == true) {
          keyStr = "Sim (EV+)";
        } else if (chave == false) {
          keyStr = "Não (EV-)";
        } else { // chave é null
          keyStr = "N/A (Não Calculado)";
        }
      } else {
        keyStr = chave as String;
      }


      if (!dadosAgrupados.containsKey(keyStr)) {
        // MODIFICADO: Adicionado 'flatProfit' para cálculo de Desempenho Real
        dadosAgrupados[keyStr] = {'retorno': 0.0, 'vitorias': 0, 'derrotas': 0, 'totalApostas': 0, 'flatProfit': 0.0};
      }
      final lucro = (aposta['lucro'] as num).toDouble();
      dadosAgrupados[keyStr]['retorno'] += lucro;
      dadosAgrupados[keyStr]['totalApostas']++;

      // NOVO: Cálculo do Flat Stake (Desempenho Real)
      // Se ganhou: soma (odd - 1). Se perdeu: subtrai 1. Se void (lucro 0): soma 0.
      double flatUnit = 0.0;
      if (lucro > 0) {
        flatUnit = (aposta['odd'] as num).toDouble() - 1.0;
        dadosAgrupados[keyStr]['vitorias']++;
      } else if (lucro < 0) {
        flatUnit = -1.0;
        dadosAgrupados[keyStr]['derrotas']++;
      }
      dadosAgrupados[keyStr]['flatProfit'] += flatUnit;
    }

    final List<MapEntry<String, dynamic>> listaOrdenada = dadosAgrupados.entries.toList();

    // MODIFICADO: Lógica de ordenação para incluir a nova métrica
    if (_analiseMetrica == 'Retorno Financeiro') {
      listaOrdenada.sort((a, b) => (b.value['retorno'] as double).compareTo(a.value['retorno'] as double));
    } else if (_analiseMetrica == 'Desempenho Real (Flat Stake)') {
      listaOrdenada.sort((a, b) => (b.value['flatProfit'] as double).compareTo(a.value['flatProfit'] as double));
    } else {
      listaOrdenada.sort((a, b) => (b.value['vitorias'] - b.value['derrotas']).compareTo(a.value['vitorias'] - a.value['derrotas']));
    }

    if (listaOrdenada.isEmpty) {
      return const Center(child: Padding(padding: EdgeInsets.all(16), child: Text("Sem dados suficientes para a análise.")));
    }

    return ListView.builder(
      itemCount: listaOrdenada.length,
      itemBuilder: (context, index) {
        final entry = listaOrdenada[index];
        final nome = entry.key;
        final dados = entry.value;
        final retorno = (dados['retorno'] as num).toDouble();
        final flatProfit = (dados['flatProfit'] as num).toDouble(); // NOVO
        final vitorias = dados['vitorias'] as int;
        final derrotas = dados['derrotas'] as int;
        final totalApostas = dados['totalApostas'] as int;
        final saldo = vitorias - derrotas;
        final taxaAcerto = totalApostas > 0 ? (vitorias / totalApostas * 100) : 0.0;

        // MODIFICADO: Lógica de exibição baseada na métrica selecionada
        bool isPositivo;
        String valorPrincipal;

        if (_analiseMetrica == 'Retorno Financeiro') {
          isPositivo = retorno >= 0;
          valorPrincipal = 'R\$ ${retorno.toStringAsFixed(2)}';
        } else if (_analiseMetrica == 'Desempenho Real (Flat Stake)') {
          isPositivo = flatProfit >= 0;
          valorPrincipal = '${flatProfit > 0 ? "+" : ""}${flatProfit.toStringAsFixed(2)}u'; // Exibe em unidades "u"
        } else {
          isPositivo = saldo >= 0;
          valorPrincipal = 'Saldo: $saldo';
        }

        final cor = isPositivo ? Colors.green.shade100 : Colors.red.shade100;
        final isExpanded = _rankingItemExpandido == index;

        return Card(
          color: cor,
          margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          child: Column(
            children: [
              ListTile(
                leading: CircleAvatar(
                  backgroundColor: isPositivo ? Colors.green : Colors.red,
                  child: Text('${index + 1}', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                ),
                title: Text(nome, style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text('Vitórias: $vitorias | Derrotas: $derrotas | Taxa: ${taxaAcerto.toStringAsFixed(1)}%\nTotal de apostas: $totalApostas'),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(valorPrincipal, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: isPositivo ? Colors.green.shade900 : Colors.red.shade900)),
                    Icon(isExpanded ? Icons.expand_less : Icons.expand_more),
                  ],
                ),
                isThreeLine: true,
                onTap: () {
                  setState(() {
                    _rankingItemExpandido = isExpanded ? null : index;
                  });
                },
              ),
              if (isExpanded) ...[
                const Divider(height: 1),
                _buildDetalhesExpandidos(nome, _analiseAssunto),
                const SizedBox(height: 8),
              ],
            ],
          ),
        );
      },
    );
  }

  // ---------------------------
  // Build de Gráficos e Widgets
  // ---------------------------

  // NOVO: Widget do Calendário Heatmap
  Widget _buildGraficoHeatmapCalendario() {
    // 1. Preparar dados do mês focado
    // Como não podemos usar packages extras facilmente aqui, usamos lógica nativa
    final diasNoMes = DateTime(_mesFocadoHeatmap.year, _mesFocadoHeatmap.month + 1, 0).day;
    final primeiroDiaDoMes = DateTime(_mesFocadoHeatmap.year, _mesFocadoHeatmap.month, 1);

    // Ajuste para o Grid começar no Domingo (Weekday 7 no Dart vira índice 0 para Domingo)
    // Dart: Mon=1, Tue=2, ..., Sun=7
    // Grid: Sun=0, Mon=1, ...
    final primeiroDiaSemanaGrid = (primeiroDiaDoMes.weekday == 7) ? 0 : primeiroDiaDoMes.weekday;

    // 2. Agrupar apostas por dia deste mês e calcular total
    final Map<int, Map<String, dynamic>> dadosDoDia = {}; // Dia -> {lucro: double, count: int}
    double totalLucroMes = 0.0; // Variável para a soma do mês

    for (var aposta in apostas) {
      final dataAposta = DateTime.parse(aposta['data']);
      if (dataAposta.year == _mesFocadoHeatmap.year && dataAposta.month == _mesFocadoHeatmap.month) {
        final lucro = (aposta['lucro'] as num).toDouble();
        totalLucroMes += lucro; // Soma ao total do mês

        final dia = dataAposta.day;
        if (!dadosDoDia.containsKey(dia)) {
          dadosDoDia[dia] = {'lucro': 0.0, 'count': 0};
        }
        dadosDoDia[dia]!['lucro'] = (dadosDoDia[dia]!['lucro'] as double) + lucro;
        dadosDoDia[dia]!['count'] = (dadosDoDia[dia]!['count'] as int) + 1;
      }
    }

    // Lista de nomes de meses para exibição
    const meses = ['JANEIRO', 'FEVEREIRO', 'MARÇO', 'ABRIL', 'MAIO', 'JUNHO', 'JULHO', 'AGOSTO', 'SETEMBRO', 'OUTUBRO', 'NOVEMBRO', 'DEZEMBRO'];
    final nomeMes = meses[_mesFocadoHeatmap.month - 1];

    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 12),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Cabeçalho do Calendário
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: const Icon(Icons.chevron_left),
                  onPressed: () {
                    setState(() {
                      _mesFocadoHeatmap = DateTime(_mesFocadoHeatmap.year, _mesFocadoHeatmap.month - 1);
                    });
                  },
                ),
                Column(
                  children: [
                    Text(
                      "$nomeMes ${_mesFocadoHeatmap.year}",
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    const SizedBox(height: 4),
                    // EXIBIÇÃO DO TOTAL DO MÊS
                    Text(
                      totalLucroMes >= 0 ? "+ R\$ ${totalLucroMes.toStringAsFixed(2)}" : "R\$ ${totalLucroMes.toStringAsFixed(2)}",
                      style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: totalLucroMes >= 0 ? Colors.green.shade700 : Colors.red.shade700
                      ),
                    ),
                  ],
                ),
                IconButton(
                  icon: const Icon(Icons.chevron_right),
                  onPressed: () {
                    setState(() {
                      _mesFocadoHeatmap = DateTime(_mesFocadoHeatmap.year, _mesFocadoHeatmap.month + 1);
                    });
                  },
                ),
              ],
            ),
            const SizedBox(height: 12),
            // Dias da Semana
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: const [
                Text("D", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
                Text("S", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
                Text("T", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
                Text("Q", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
                Text("Q", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
                Text("S", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
                Text("S", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
              ],
            ),
            const SizedBox(height: 8),
            // Grid de Dias
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 7,
                crossAxisSpacing: 4,
                mainAxisSpacing: 4,
                childAspectRatio: 1.0, // Quadrado
              ),
              itemCount: 42, // 6 semanas * 7 dias fixo para alinhar
              itemBuilder: (context, index) {
                final diaCalculado = index - primeiroDiaSemanaGrid + 1;

                // Células vazias (antes do dia 1 ou depois do último dia)
                if (diaCalculado < 1 || diaCalculado > diasNoMes) {
                  return const SizedBox();
                }

                final temDados = dadosDoDia.containsKey(diaCalculado);
                final lucro = temDados ? dadosDoDia[diaCalculado]!['lucro'] as double : 0.0;
                final count = temDados ? dadosDoDia[diaCalculado]!['count'] as int : 0;

                Color corBg = Colors.grey.shade100;
                Color corTexto = Colors.black54;
                Border? border;

                if (temDados) {
                  if (lucro > 0) {
                    // Escala de verde baseada no lucro (ex: max R$ 500 para cor full)
                    final intensidade = (lucro / 200).clamp(0.3, 1.0);
                    corBg = Colors.green.withOpacity(intensidade);
                    corTexto = Colors.white;
                  } else if (lucro < 0) {
                    final intensidade = (lucro.abs() / 200).clamp(0.3, 1.0);
                    corBg = Colors.red.withOpacity(intensidade);
                    corTexto = Colors.white;
                  } else {
                    corBg = Colors.amber.shade300; // Empate/Reembolso
                    corTexto = Colors.black87;
                  }
                } else {
                  // Dia atual sem aposta
                  if (diaCalculado == DateTime.now().day &&
                      _mesFocadoHeatmap.month == DateTime.now().month &&
                      _mesFocadoHeatmap.year == DateTime.now().year) {
                    border = Border.all(color: Colors.blue, width: 2);
                  }
                }

                return Tooltip(
                  triggerMode: TooltipTriggerMode.tap, // Mostra ao clicar no mobile
                  message: temDados
                      ? "Dia $diaCalculado\nSaldo: R\$ ${lucro.toStringAsFixed(2)}\n$count aposta(s)"
                      : "Dia $diaCalculado\nSem apostas",
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(color: Colors.grey.shade800, borderRadius: BorderRadius.circular(8)),
                  textStyle: const TextStyle(color: Colors.white),
                  child: Container(
                    decoration: BoxDecoration(
                      color: corBg,
                      borderRadius: BorderRadius.circular(6),
                      border: border,
                    ),
                    child: Center(
                      child: Text(
                        "$diaCalculado",
                        style: TextStyle(
                          color: corTexto,
                          fontWeight: temDados ? FontWeight.bold : FontWeight.normal,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 12),
            // Legenda simples
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildLegendaDot(Colors.green, "Lucro"),
                _buildLegendaDot(Colors.red, "Prejuízo"),
                _buildLegendaDot(Colors.grey.shade300, "Sem jogo"),
                _buildLegendaDot(Colors.blue, "Hoje", isBorder: true),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLegendaDot(Color color, String label, {bool isBorder = false}) {
    return Row(
      children: [
        Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(
                color: isBorder ? null : color,
                border: isBorder ? Border.all(color: color, width: 2) : null,
                shape: BoxShape.circle
            )
        ),
        const SizedBox(width: 4),
        Text(label, style: const TextStyle(fontSize: 10)),
      ],
    );
  }

  Widget _buildGraficoEvolucaoBanca() {
    // MODIFICADO: Lógica de reconstrução dinâmica do histórico para garantir precisão
    // Isso ignora o 'historicoBanca' salvo que poderia estar bugado e recria
    // a curva baseada exatamente nas transações existentes.

    // 1. Coletar todas as transações
    List<Map<String, dynamic>> transacoes = [];

    // Aportes
    for (var a in aportes) {
      transacoes.add({
        'data': DateTime.parse(a['data']),
        'valor': (a['valor'] as num).toDouble(),
        'tipo': 'aporte'
      });
    }

    // Saques
    for (var s in saques) {
      transacoes.add({
        'data': DateTime.parse(s['data']),
        'valor': -(s['valor'] as num).toDouble(),
        'tipo': 'saque'
      });
    }

    // Apostas (Lucro/Prejuízo)
    for (var a in apostas) {
      transacoes.add({
        'data': DateTime.parse(a['data']),
        'valor': (a['lucro'] as num).toDouble(),
        'tipo': 'aposta'
      });
    }

    // Se não houver transações suficientes, mostra aviso
    if (transacoes.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 20),
          child: Text(
            "O gráfico aparecerá assim que houver apostas registradas.",
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    // 2. Ordenar por data
    transacoes.sort((a, b) => a['data'].compareTo(b['data']));

    // 3. Construir pontos do gráfico
    List<FlSpot> spotsBanca = [];
    List<FlSpot> spotsInvestimento = [];

    double saldoAtual = bancaInicial;
    double investimentoAtual = bancaInicial;

    // Ponto inicial (t=0)
    // Se a primeira transação for muito longe, podemos querer um ponto inicial na data dela ou antes.
    // Vamos adicionar um ponto inicial fictício um dia antes da primeira transação para estabilizar o gráfico
    if (transacoes.isNotEmpty) {
      spotsBanca.add(const FlSpot(0, 0)); // Será ajustado no mapeamento final ou usamos índice
      // Na verdade, melhor usar uma lista intermediária e depois converter para FlSpot com índice X
    }

    List<Map<String, dynamic>> pontosGrafico = [];

    // Adiciona estado inicial
    pontosGrafico.add({
      'data': transacoes.first['data'].subtract(const Duration(hours: 1)),
      'saldo': bancaInicial,
      'investimento': bancaInicial
    });

    for (var t in transacoes) {
      if (t['tipo'] == 'aporte') {
        investimentoAtual += t['valor'];
      } else if (t['tipo'] == 'saque') {
        // Saque reduz o saldo e também reduzimos do "investimento base" para manter a proporção visual,
        // ou mantemos o investimento fixo. Geralmente saque reduz banca.
        // O cálculo de investimentoTotal lá em cima não subtrai saques, mas aqui para o gráfico visual
        // faz sentido a linha amarela acompanhar a realidade do dinheiro investido disponível.
        // Vamos manter a lógica simples: Investimento = Banca Inicial + Aportes (linha de referência de capital injetado)
      }

      saldoAtual += t['valor'];

      pontosGrafico.add({
        'data': t['data'],
        'saldo': saldoAtual,
        'investimento': investimentoAtual
      });
    }

    // Amostragem para não sobrecarregar o gráfico se tiver muitos pontos
    List<Map<String, dynamic>> dadosFinais = [];
    if (pontosGrafico.length > 50) {
      final step = (pontosGrafico.length / 50).ceil();
      for (int i = 0; i < pontosGrafico.length; i += step) {
        dadosFinais.add(pontosGrafico[i]);
      }
      // Garante que o último ponto esteja presente
      if (dadosFinais.last != pontosGrafico.last) {
        dadosFinais.add(pontosGrafico.last);
      }
    } else {
      dadosFinais = pontosGrafico;
    }

    // Converter para Spots
    spotsBanca = dadosFinais.asMap().entries.map((e) {
      return FlSpot(e.key.toDouble(), (e.value['saldo'] as num).toDouble());
    }).toList();

    spotsInvestimento = dadosFinais.asMap().entries.map((e) {
      return FlSpot(e.key.toDouble(), (e.value['investimento'] as num).toDouble());
    }).toList();

    Widget legenda = Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Row(children: [
          Container(width: 10, height: 10, color: Colors.cyan),
          const SizedBox(width: 4),
          const Text("Banca"),
        ]),
        const SizedBox(width: 16),
        Row(children: [
          Container(width: 10, height: 2, color: Colors.amber),
          const SizedBox(width: 4),
          const Text("Investimento (Aportes)"),
        ]),
      ],
    );

    return Column(
      children: [
        legenda,
        AspectRatio(
          aspectRatio: 1.7,
          child: Padding(
            padding: const EdgeInsets.only(right: 18.0, top: 24, bottom: 12),
            child: LineChart(
              LineChartData(
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: true,
                  getDrawingHorizontalLine: (value) =>
                  const FlLine(color: Colors.white10, strokeWidth: 1),
                  getDrawingVerticalLine: (value) =>
                  const FlLine(color: Colors.white10, strokeWidth: 1),
                ),
                titlesData: FlTitlesData(
                  show: true,
                  rightTitles:
                  const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  topTitles:
                  const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 30,
                      interval: (dadosFinais.length / 6).ceilToDouble(), // Mostra ~6 datas
                      getTitlesWidget: (value, meta) {
                        final index = value.toInt();
                        if (index >= 0 && index < dadosFinais.length) {
                          final data = dadosFinais[index]['data'] as DateTime;
                          return SideTitleWidget(
                            axisSide: meta.axisSide,
                            child: Text(
                              '${data.day}/${data.month}',
                              style: const TextStyle(fontSize: 10),
                            ),
                          );
                        }
                        return const Text('');
                      },
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 42,
                      getTitlesWidget: (value, meta) {
                        return Text("R\$${value.toInt()}",
                            style: const TextStyle(fontSize: 10));
                      },
                    ),
                  ),
                ),
                borderData: FlBorderData(
                    show: true,
                    border: Border.all(color: const Color(0xff37434d), width: 1)),
                lineBarsData: [
                  LineChartBarData(
                    spots: spotsBanca,
                    isCurved: true,
                    gradient:
                    const LinearGradient(colors: [Colors.cyan, Colors.blue]),
                    barWidth: 3,
                    isStrokeCapRound: true,
                    dotData: const FlDotData(show: false),
                    belowBarData: BarAreaData(
                      show: true,
                      gradient: LinearGradient(colors: [
                        Colors.cyan.withOpacity(0.3),
                        Colors.blue.withOpacity(0.3)
                      ]),
                    ),
                  ),
                  LineChartBarData(
                    spots: spotsInvestimento,
                    isCurved: false,
                    gradient:
                    const LinearGradient(colors: [Colors.amber, Colors.orange]),
                    barWidth: 2,
                    dotData: const FlDotData(show: false),
                    dashArray: [5, 5],
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  // NOVO: Gráfico de Lucro Acumulado (Sem Aportes)
  Widget _buildGraficoLucroAcumulado() {
    List<Map<String, dynamic>> transacoes = [];

    // Coleta apenas as apostas
    for (var a in apostas) {
      transacoes.add({
        'data': DateTime.parse(a['data']),
        'valor': (a['lucro'] as num).toDouble(),
      });
    }

    if (transacoes.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 20),
          child: Text("Sem dados de lucro para exibir."),
        ),
      );
    }

    // Ordena por data
    transacoes.sort((a, b) => a['data'].compareTo(b['data']));

    List<Map<String, dynamic>> pontosGrafico = [];
    double lucroAccum = 0.0;

    // Ponto inicial (Data da primeira aposta ou antes)
    pontosGrafico.add({
      'data': transacoes.first['data'].subtract(const Duration(hours: 1)),
      'saldo': 0.0,
    });

    for (var t in transacoes) {
      lucroAccum += t['valor'];
      pontosGrafico.add({
        'data': t['data'],
        'saldo': lucroAccum,
      });
    }

    // Amostragem
    List<Map<String, dynamic>> dadosFinais = [];
    if (pontosGrafico.length > 50) {
      final step = (pontosGrafico.length / 50).ceil();
      for (int i = 0; i < pontosGrafico.length; i += step) {
        dadosFinais.add(pontosGrafico[i]);
      }
      if (dadosFinais.last != pontosGrafico.last) {
        dadosFinais.add(pontosGrafico.last);
      }
    } else {
      dadosFinais = pontosGrafico;
    }

    List<FlSpot> spots = dadosFinais.asMap().entries.map((e) {
      return FlSpot(e.key.toDouble(), (e.value['saldo'] as num).toDouble());
    }).toList();

    return Column(
      children: [
        // Legenda Simples
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(width: 10, height: 10, color: Colors.purple),
            const SizedBox(width: 4),
            const Text("Lucro Acumulado (Orgânico)"),
          ],
        ),
        AspectRatio(
          aspectRatio: 1.7,
          child: Padding(
            padding: const EdgeInsets.only(right: 18.0, top: 24, bottom: 12),
            child: LineChart(
              LineChartData(
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: true,
                  getDrawingHorizontalLine: (value) => const FlLine(color: Colors.white10, strokeWidth: 1),
                  getDrawingVerticalLine: (value) => const FlLine(color: Colors.white10, strokeWidth: 1),
                ),
                titlesData: FlTitlesData(
                  show: true,
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 30,
                      interval: (dadosFinais.length / 6).ceilToDouble(),
                      getTitlesWidget: (value, meta) {
                        final index = value.toInt();
                        if (index >= 0 && index < dadosFinais.length) {
                          final data = dadosFinais[index]['data'] as DateTime;
                          return SideTitleWidget(
                            axisSide: meta.axisSide,
                            child: Text('${data.day}/${data.month}', style: const TextStyle(fontSize: 10)),
                          );
                        }
                        return const Text('');
                      },
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 42,
                      getTitlesWidget: (value, meta) => Text("R\$${value.toInt()}", style: const TextStyle(fontSize: 10)),
                    ),
                  ),
                ),
                borderData: FlBorderData(show: true, border: Border.all(color: const Color(0xff37434d), width: 1)),
                lineBarsData: [
                  LineChartBarData(
                    spots: spots,
                    isCurved: true,
                    gradient: const LinearGradient(colors: [Colors.purple, Colors.deepPurpleAccent]),
                    barWidth: 3,
                    isStrokeCapRound: true,
                    dotData: const FlDotData(show: false),
                    belowBarData: BarAreaData(
                      show: true,
                      gradient: LinearGradient(colors: [Colors.purple.withOpacity(0.3), Colors.deepPurpleAccent.withOpacity(0.3)]),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildGraficoCrescimentoMensal() {
    if (apostas.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 20),
          child: Text("Sem apostas suficientes para calcular o crescimento mensal."),
        ),
      );
    }

    // 1. Mapear todas as transações por mês (Ano-Mês)
    final Map<String, double> lucroPorMes = {};
    final Map<String, double> aportesPorMes = {};
    final Map<String, double> saquesPorMes = {};
    final Set<String> mesesComAtividade = {};

    String getKey(String dateStr) {
      if (dateStr.isEmpty) return "";
      final d = DateTime.tryParse(dateStr);
      if (d == null) return "";
      return "${d.year}-${d.month.toString().padLeft(2, '0')}";
    }

    // Apostas
    for (var a in apostas) {
      final key = getKey(a['data']);
      if (key.isNotEmpty) {
        lucroPorMes[key] = (lucroPorMes[key] ?? 0.0) + (a['lucro'] as num).toDouble();
        mesesComAtividade.add(key);
      }
    }

    // Aportes
    for (var a in aportes) {
      final key = getKey(a['data']);
      if (key.isNotEmpty) {
        aportesPorMes[key] = (aportesPorMes[key] ?? 0.0) + (a['valor'] as num).toDouble();
        mesesComAtividade.add(key);
      }
    }

    // Saques
    for (var s in saques) {
      final key = getKey(s['data']);
      if (key.isNotEmpty) {
        saquesPorMes[key] = (saquesPorMes[key] ?? 0.0) + (s['valor'] as num).toDouble();
        mesesComAtividade.add(key);
      }
    }

    final mesesOrdenados = mesesComAtividade.toList()..sort();
    if (mesesOrdenados.isEmpty) return const SizedBox();

    // Determinar janela de tempo (do primeiro mês registrado até o atual)
    DateTime dataInicio = DateTime.parse("${mesesOrdenados.first}-01");
    DateTime dataFim = DateTime.now();

    // Se o último registro for futuro (erro de data), estendemos até lá
    if (DateTime.parse("${mesesOrdenados.last}-01").isAfter(dataFim)) {
      dataFim = DateTime.parse("${mesesOrdenados.last}-01");
    }

    List<Map<String, dynamic>> dadosMensais = [];
    double bancaRolante = bancaInicial; // Começa com a banca inicial configurada

    // Iterar mês a mês para manter a consistência do saldo acumulado
    DateTime cursor = DateTime(dataInicio.year, dataInicio.month, 1);
    while (!cursor.isAfter(DateTime(dataFim.year, dataFim.month, 1))) {
      final key = "${cursor.year}-${cursor.month.toString().padLeft(2, '0')}";

      final double aportesDoMes = aportesPorMes[key] ?? 0.0;
      final double saquesDoMes = saquesPorMes[key] ?? 0.0;
      final double lucroDoMes = lucroPorMes[key] ?? 0.0;

      // REGRA PEDIDA: Considerar banca no início do mês + aportes do mês como base
      final double baseCalculo = bancaRolante + aportesDoMes;

      double crescimentoPct = 0.0;
      if (baseCalculo > 0) {
        crescimentoPct = (lucroDoMes / baseCalculo) * 100;
      }

      // Só adiciona ao gráfico se houver atividade naquele mês (para não encher de zeros irrelevantes,
      // embora manter a linha contínua seja bom, vamos focar nos meses com dados se forem muitos)
      // Se quiser linha contínua, remova o `if`. Aqui mantemos se tiver atividade ou se for o mês atual.
      bool isMesAtual = (cursor.year == DateTime.now().year && cursor.month == DateTime.now().month);
      if (mesesComAtividade.contains(key) || isMesAtual) {
        dadosMensais.add({
          "mes": key,
          "crescimento": double.parse(crescimentoPct.toStringAsFixed(2)),
          "lucro": lucroDoMes,
          "base": baseCalculo
        });
      }

      // Atualiza a banca para o próximo mês (Carry over)
      // Saldo Final = (Saldo Inicial + Aportes) + Lucro - Saques
      bancaRolante = baseCalculo + lucroDoMes - saquesDoMes;

      // Avança cursor
      cursor = DateTime(cursor.year, cursor.month + 1, 1);
    }

    final mediaCrescimento = dadosMensais.isNotEmpty
        ? dadosMensais.map((e) => e['crescimento'] as double).reduce((a, b) => a + b) / dadosMensais.length
        : 0.0;

    // NOVO: Cálculo da média de lucro em dinheiro
    final mediaLucro = dadosMensais.isNotEmpty
        ? dadosMensais.map((e) => (e['lucro'] as num).toDouble()).reduce((a, b) => a + b) / dadosMensais.length
        : 0.0;

    final spots = dadosMensais.asMap().entries.map((e) {
      return FlSpot(e.key.toDouble(), (e.value["crescimento"] as num).toDouble());
    }).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const Text(
          "Performance Mensal (R\$ e %)",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 6),
        Text(
          "Média: ${mediaCrescimento.toStringAsFixed(2)}% (R\$ ${mediaLucro.toStringAsFixed(2)}) ao mês",
          style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: mediaCrescimento >= 0 ? Colors.green : Colors.red
          ),
        ),
        const SizedBox(height: 8),
        AspectRatio(
          aspectRatio: 1.7,
          child: Padding(
            padding: const EdgeInsets.only(right: 18.0, top: 24, bottom: 12),
            child: LineChart(
              LineChartData(
                gridData: FlGridData(show: true, drawVerticalLine: true),
                lineTouchData: LineTouchData(
                  touchTooltipData: LineTouchTooltipData(
                    getTooltipItems: (touchedSpots) {
                      return touchedSpots.map((LineBarSpot touchedSpot) {
                        final index = touchedSpot.x.toInt();
                        if (index >= 0 && index < dadosMensais.length) {
                          final dados = dadosMensais[index];
                          final lucro = (dados['lucro'] as num).toDouble();
                          final pct = (dados['crescimento'] as num).toDouble();
                          return LineTooltipItem(
                            "R\$ ${lucro.toStringAsFixed(2)}\n$pct%",
                            const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                          );
                        }
                        return null;
                      }).toList();
                    },
                  ),
                ),
                titlesData: FlTitlesData(
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 32,
                      interval: 1, // Mostra todos se couber, ou ajuste conforme necessidade
                      getTitlesWidget: (value, meta) {
                        final index = value.toInt();
                        if (index >= 0 && index < dadosMensais.length) {
                          final partes = (dadosMensais[index]['mes'] as String).split('-');
                          final mesNum = int.parse(partes[1]);
                          final ano = partes[0].substring(2);
                          const nomesMeses = ['Jan', 'Fev', 'Mar', 'Abr', 'Mai', 'Jun', 'Jul', 'Ago', 'Set', 'Out', 'Nov', 'Dez'];
                          return SideTitleWidget(
                            axisSide: meta.axisSide,
                            child: Text("${nomesMeses[mesNum - 1]}/$ano", style: const TextStyle(fontSize: 10)),
                          );
                        }
                        return const Text('');
                      },
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 40,
                      getTitlesWidget: (value, meta) =>
                          Text("${value.toStringAsFixed(0)}%", style: const TextStyle(fontSize: 10)),
                    ),
                  ),
                ),
                borderData: FlBorderData(show: true),
                lineBarsData: [
                  LineChartBarData(
                    spots: spots,
                    isCurved: true,
                    color: Colors.green,
                    barWidth: 3,
                    isStrokeCapRound: true,
                    dotData: const FlDotData(show: true),
                    belowBarData: BarAreaData(
                      show: true,
                      color: Colors.green.withOpacity(0.2),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildGraficoDistribuicaoStakes() {
    final ciclosEncerrados = ciclos.where((c) => c['status'] == 'ganho' || c['status'] == 'perdido').toList();

    if (ciclosEncerrados.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 20),
          child: Text("Nenhum ciclo encerrado para analisar a eficiência.", textAlign: TextAlign.center),
        ),
      );
    }

    final Map<int, int> contagem = {0: 0, 1: 0, 2: 0, 3: 0, 4: 0, 5: 0};
    for (var ciclo in ciclosEncerrados) {
      final apostasDoCiclo = apostas.where((a) => (ciclo['apostasIds'] as List).contains(a['id'])).toList();
      final perdasNoCiclo = apostasDoCiclo.where((a) => (a['lucro'] as num) < 0).length;

      if (perdasNoCiclo >= 5) {
        contagem[5] = (contagem[5] ?? 0) + 1;
      } else {
        contagem[perdasNoCiclo] = (contagem[perdasNoCiclo] ?? 0) + 1;
      }
    }

    final maiorContagem = contagem.values.isEmpty ? 0 : contagem.values.reduce((a, b) => a > b ? a : b);

    // Dynamic interval calculation
    double intervaloY = 1;
    if (maiorContagem > 10) {
      intervaloY = (maiorContagem / 5).ceilToDouble(); // Tenta manter aprox. 5 linhas de grade
    }

    return AspectRatio(
      aspectRatio: 1.7,
      child: Padding(
        padding: const EdgeInsets.only(right: 18.0, top: 24, bottom: 12),
        child: BarChart(
          BarChartData(
            alignment: BarChartAlignment.spaceAround,
            maxY: maiorContagem.toDouble() == 0 ? 5 : maiorContagem.toDouble() + 1,
            barTouchData: BarTouchData(enabled: false),
            titlesData: FlTitlesData(
              show: true,
              topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              leftTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 28,
                  interval: intervaloY, // Usa intervalo dinâmico
                  getTitlesWidget: (value, meta) {
                    if (value % 1 != 0) return const SizedBox.shrink(); // Apenas inteiros
                    return Text(value.toInt().toString(), style: const TextStyle(fontSize: 10));
                  },
                ),
              ),
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  getTitlesWidget: (value, meta) {
                    final index = value.toInt();
                    final text = index == 5 ? '5+' : index.toString();
                    return SideTitleWidget(axisSide: meta.axisSide, child: Text(text, style: const TextStyle(fontSize: 12)));
                  },
                  reservedSize: 30,
                ),
              ),
            ),
            gridData: FlGridData(
              show: true,
              drawVerticalLine: false,
              getDrawingHorizontalLine: (value) => const FlLine(color: Colors.white10, strokeWidth: 1),
            ),
            borderData: FlBorderData(show: false),
            barGroups: List.generate(6, (i) {
              final y = contagem[i]?.toDouble() ?? 0.0;
              return BarChartGroupData(
                x: i,
                barRods: [
                  BarChartRodData(
                      toY: y,
                      color: i == 0 ? Colors.green.shade300 : Colors.red.shade300,
                      width: 22,
                      borderRadius: BorderRadius.circular(4)
                  )
                ],
              );
            }),
          ),
        ),
      ),
    );
  }

  // NOVO: Gráfico de Drawdown
  Widget _buildGraficoDrawdowns() {
    if (_drawdownHistory.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 20),
          child: Text("Nenhuma aposta registrada para calcular quedas."),
        ),
      );
    }

    // Limitar pontos para não travar a UI se houver milhares de apostas
    List<Map<String, dynamic>> dadosParaGrafico = _drawdownHistory;
    if (_drawdownHistory.length > 300) {
      // Amostragem simples se tiver muitos dados
      dadosParaGrafico = [];
      final step = (_drawdownHistory.length / 300).ceil();
      for (int i = 0; i < _drawdownHistory.length; i += step) {
        dadosParaGrafico.add(_drawdownHistory[i]);
      }
      // Garante que o pior drawdown esteja no gráfico mesmo com amostragem
      if (_maxDrawdown != null && _maxDrawdown!['data'] != null) {
        bool containsMax = dadosParaGrafico.any((e) => e['data'] == _maxDrawdown!['data']);
        if (!containsMax) dadosParaGrafico.add(_maxDrawdown!);
      }
      dadosParaGrafico.sort((a, b) => DateTime.parse(a['data']).compareTo(DateTime.parse(b['data'])));
    }

    final spots = dadosParaGrafico.asMap().entries.map((entry) {
      final index = entry.key;
      final dataPoint = entry.value;
      // Multiplica por 100 para virar porcentagem (ex: -0.15 vira -15.0)
      final percent = (dataPoint['percentual'] as num).toDouble() * 100;
      return FlSpot(index.toDouble(), percent);
    }).toList();

    return AspectRatio(
      aspectRatio: 1.7,
      child: Padding(
        padding: const EdgeInsets.only(right: 18.0, top: 24, bottom: 12),
        child: LineChart(
          LineChartData(
            gridData: FlGridData(show: true, drawVerticalLine: true),
            titlesData: FlTitlesData(
              show: true,
              rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 32,
                  interval: (dadosParaGrafico.length / 5).ceilToDouble(), // Mostra ~5 datas
                  getTitlesWidget: (value, meta) {
                    final index = value.toInt();
                    if (index >= 0 && index < dadosParaGrafico.length) {
                      final dataStr = dadosParaGrafico[index]['data'] as String;
                      final data = DateTime.parse(dataStr);
                      return SideTitleWidget(
                        axisSide: meta.axisSide,
                        child: Text('${data.day}/${data.month}', style: const TextStyle(fontSize: 10)),
                      );
                    }
                    return const Text('');
                  },
                ),
              ),
              leftTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 40,
                  getTitlesWidget: (value, meta) => Text("${value.toStringAsFixed(0)}%", style: const TextStyle(fontSize: 10)),
                ),
              ),
            ),
            borderData: FlBorderData(show: true),
            // Define o range do Y para focar na parte negativa (quedas)
            minY: ((_maxDrawdown?['percentual'] ?? 0.0) * 100) * 1.1, // Um pouco abaixo do fundo
            maxY: 0, // Topo é sempre 0%
            lineBarsData: [
              LineChartBarData(
                spots: spots,
                isCurved: true,
                color: Colors.red,
                barWidth: 2,
                isStrokeCapRound: true,
                dotData: const FlDotData(show: false),
                belowBarData: BarAreaData(
                  show: true,
                  color: Colors.red.withOpacity(0.3),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ---------------------------
  // Build UI Abas
  // ---------------------------
  Widget _buildAbaMetas() {
    Map<String, dynamic>? cicloAtual = ciclos.lastWhere((c) => c['status'] == 'em_andamento', orElse: () => {});
    double lucroCicloAtual = cicloAtual.isNotEmpty ? (cicloAtual['lucroLiquido'] as num).toDouble() : 0.0;

    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: Column(
        children: [
          ElevatedButton.icon(
            onPressed: () => _mostrarDialogoMeta(),
            icon: const Icon(Icons.add),
            label: const Text("Adicionar Nova Meta"),
          ),
          const Divider(height: 24),
          Expanded(
            child: metas.isEmpty
                ? const Center(child: Text("Nenhuma meta cadastrada."))
                : ListView.builder(
              itemCount: metas.length,
              itemBuilder: (context, index) {
                final meta = metas[index];
                final nome = meta['nome'] as String;
                final tipo = meta['tipo'] as String;
                final valor = (meta['valor'] as num).toDouble();

                double progressoAtual = 0.0;
                if(tipo == 'total'){
                  progressoAtual = lucroTotalApostas;
                } else {
                  progressoAtual = lucroCicloAtual;
                }

                double percentual = (progressoAtual > 0 && valor > 0) ? (progressoAtual / valor) : 0.0;
                if(percentual < 0) percentual = 0;
                if(percentual > 1) percentual = 1;

                return Card(
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                nome,
                                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.edit, size: 20),
                              onPressed: () => _mostrarDialogoMeta(metaParaEditar: meta),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, size: 20),
                              onPressed: () async {
                                final ok = await _confirmDialog("Excluir Meta", "Deseja realmente excluir a meta '$nome'?");
                                if(ok == true){
                                  _excluirMeta(meta['id']);
                                }
                              },
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text("Tipo: ${tipo == 'ciclo' ? 'Ciclo Atual' : 'Total'} • Meta: R\$ ${valor.toStringAsFixed(2)}"),
                        const SizedBox(height: 8),
                        LinearProgressIndicator(
                          value: percentual,
                          minHeight: 10,
                          borderRadius: BorderRadius.circular(5),
                        ),
                        const SizedBox(height: 4),
                        Align(
                          alignment: Alignment.centerRight,
                          child: Text("R\$ ${progressoAtual.toStringAsFixed(2)} / R\$ ${valor.toStringAsFixed(2)} (${(percentual * 100).toStringAsFixed(1)}%)"),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAbaAnalise() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              DropdownButton<String>(
                value: _analiseAssunto,
                items: [
                  'Time',
                  'Campeonato',
                  'Tipo de Aposta',
                  'Nível de Confiança',
                  'Margem',
                  'Comentários',
                  'EV+',
                  'Playbook'
                ].map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                onChanged: (newValue) {
                  if (newValue != null) {
                    setState(() => _analiseAssunto = newValue);
                  }
                },
              ),
              DropdownButton<String>(
                value: _analiseMetrica,
                // MODIFICADO: Adicionado 'Desempenho Real (Flat Stake)'
                items: ['Retorno Financeiro', 'Saldo de Vitórias', 'Desempenho Real (Flat Stake)'].map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                onChanged: (newValue) {
                  if (newValue != null) {
                    setState(() => _analiseMetrica = newValue);
                  }
                },
              ),
            ],
          ),
        ),
        const Divider(),
        Expanded(child: _buildGraficoAnalise()),
      ],
    );
  }

  // NOVO: Widget helper para os KPIs
  Widget _buildKpiChip({required String label, required String value, required Color color}) {
    return Chip(
      label: RichText(
        textAlign: TextAlign.center,
        text: TextSpan(
          style: TextStyle(color: color, fontSize: 12),
          children: [
            TextSpan(text: "$label\n"),
            TextSpan(
              text: value,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
          ],
        ),
      ),
      backgroundColor: color.withOpacity(0.1),
      side: BorderSide(color: color.withOpacity(0.5)),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
    );
  }

  // ---------------------------
  // Build UI Principal
  // ---------------------------
  @override
  Widget build(BuildContext context) {
    final tiposUnicos = apostas.map((a) => a['tipo'] as String).toSet().toList();
    final campeonatosUnicos = apostas.map((a) => a['campeonato'] as String? ?? '').where((c) => c.isNotEmpty).toSet().toList();
    final timesUnicos = apostas.map((a) => a['time'] as String? ?? '').where((t) => t.isNotEmpty).toSet().toList();
    final comentariosUnicos = apostas.map((a) => a['comentarios'] as String? ?? '').where((c) => c.isNotEmpty).toSet().toList();
    final playbooksOrdenados = List<Map<String, dynamic>>.from(playbooks)..sort((a, b) => (a['nome'] as String).compareTo(b['nome'] as String));

    // ================== CÁLCULOS PARA ABA DE RESULTADOS ==================
    // Cálculo de Break-even
    final double oddMedia = _oddMediaTotal;
    final double taxaNecessaria = (oddMedia > 0) ? (1 / oddMedia) : 0.0;
    final double taxaReal = _taxaAcertoReal;
    final bool isLucrativo = (taxaReal > taxaNecessaria);

    // Cálculo de Drawdown
    final String maxDrawdownStr = ((_maxDrawdown?['percentual'] ?? 0.0) * 100).toStringAsFixed(1);
    final String maxDrawdownDataStr = _maxDrawdown?['data'] != null
        ? DateFormat('dd/MM/yy').format(DateTime.parse(_maxDrawdown!['data']))
        : "N/D";

    // --- CÁLCULOS AVANÇADOS (Yield, Profit Factor, Streaks) ---

    // 1. Yield
    final double totalStaked = apostas.fold(0.0, (s, a) => s + (a['stake'] as num).toDouble());
    final double yieldPct = totalStaked > 0 ? (lucroTotalApostas / totalStaked) * 100 : 0.0;

    // 2. Profit Factor
    final double grossProfit = apostas.where((a) => (a['lucro'] as num) > 0).fold(0.0, (s, a) => s + (a['lucro'] as num).toDouble());
    final double grossLoss = apostas.where((a) => (a['lucro'] as num) < 0).fold(0.0, (s, a) => s + ((a['lucro'] as num).abs()).toDouble());
    final double profitFactor = grossLoss == 0 ? (grossProfit > 0 ? 999.0 : 0.0) : (grossProfit / grossLoss); // 999 simboliza infinito/sem perdas

    // 3. Sequências (Streaks)
    int maxWinStreak = 0;
    int maxLoseStreak = 0;
    int currentW = 0;
    int currentL = 0;
    // Ordena temporariamente por data para calcular sequência
    final sortedApostasStreak = List<Map<String, dynamic>>.from(apostas)..sort((a, b) => a['data'].compareTo(b['data']));

    for (var a in sortedApostasStreak) {
      final l = (a['lucro'] as num).toDouble();
      if (l > 0) {
        currentW++;
        currentL = 0;
        if (currentW > maxWinStreak) maxWinStreak = currentW;
      } else if (l < 0) {
        currentL++;
        currentW = 0;
        if (currentL > maxLoseStreak) maxLoseStreak = currentL;
      } else {
        // Void/Reembolso geralmente não quebra sequência, mas vamos zerar para ser conservador
        // Ou mantenha comentado se quiser ignorar voids
        currentW = 0;
        currentL = 0;
      }
    }
    // ===================================================================

    return Scaffold(
      appBar: AppBar(
        title: const Text('Apostas'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  const Text("Banca Atual", style: TextStyle(fontSize: 10)),
                  Text(
                    "R\$ ${bancaAtual.toStringAsFixed(2)}",
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabs: const [
            Tab(text: "Resultados"),
            Tab(text: "Análise"),
            Tab(text: "Apostas"),
            Tab(text: "Controle de Ciclos"),
            Tab(text: "Configurações"),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // ---------- Resultados ----------
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: ListView(
              children: [
                // --- KPIs PRINCIPAIS ---
                Card(
                  elevation: 2,
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Desempenho Geral",
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 12),
                        // CORREÇÃO: Troca Row por Wrap
                        Wrap(
                          spacing: 8.0, // Espaçamento horizontal
                          runSpacing: 8.0, // Espaçamento vertical
                          alignment: WrapAlignment.spaceAround,
                          children: [
                            _buildKpiChip(
                              label: "Banca Atual",
                              value: "R\$ ${bancaAtual.toStringAsFixed(2)}",
                              color: Colors.blue.shade700,
                            ),
                            _buildKpiChip(
                              label: "Lucro Total",
                              value: "R\$ ${lucroTotalApostas.toStringAsFixed(2)}",
                              color: lucroTotalApostas >= 0 ? Colors.green.shade700 : Colors.red.shade700,
                            ),
                            _buildKpiChip(
                              label: "ROI (Banca)",
                              value: "${roi.toStringAsFixed(2)}%",
                              color: roi >= 0 ? Colors.green.shade700 : Colors.red.shade700,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                // --- NOVO: MÉTRICAS AVANÇADAS ---
                Card(
                  elevation: 2,
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Métricas Avançadas",
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 12),
                        Wrap(
                          spacing: 8.0,
                          runSpacing: 8.0,
                          alignment: WrapAlignment.spaceAround,
                          children: [
                            _buildKpiChip(
                              label: "Yield (Giro)",
                              value: "${yieldPct.toStringAsFixed(2)}%",
                              color: yieldPct >= 0 ? Colors.teal.shade700 : Colors.deepOrange.shade700,
                            ),
                            _buildKpiChip(
                              label: "Profit Factor",
                              value: profitFactor >= 999 ? "∞" : profitFactor.toStringAsFixed(2),
                              color: profitFactor >= 1.0 ? Colors.green.shade700 : Colors.red.shade700,
                            ),
                            _buildKpiChip(
                              label: "Seq. Vitórias",
                              value: "$maxWinStreak",
                              color: Colors.green.shade700,
                            ),
                            _buildKpiChip(
                              label: "Seq. Derrotas",
                              value: "$maxLoseStreak",
                              color: Colors.red.shade700,
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        const Center(child: Text("Yield: Lucro sobre total apostado • PF: Lucro Bruto / Perda Bruta", style: TextStyle(fontSize: 10, color: Colors.grey))),
                      ],
                    ),
                  ),
                ),

                // --- NOVO: ANÁLISE DE BREAK-EVEN ---
                Card(
                  elevation: 2,
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Análise de Ponto de Equilíbrio (Break-even)",
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 12),
                        // CORREÇÃO: Trocou Row por Wrap para evitar overflow em telas pequenas
                        Wrap(
                          spacing: 8.0, // Espaçamento horizontal
                          runSpacing: 8.0, // Espaçamento vertical (se quebrar a linha)
                          alignment: WrapAlignment.spaceAround,
                          children: [
                            _buildKpiChip(
                              label: "Odd Média",
                              value: oddMedia.toStringAsFixed(2),
                              color: Colors.blue.shade700,
                            ),
                            _buildKpiChip(
                              label: "Taxa Necessária (BE)",
                              value: "${(taxaNecessaria * 100).toStringAsFixed(1)}%",
                              color: Colors.orange.shade800,
                            ),
                            _buildKpiChip(
                              label: "Taxa Real",
                              value: "${(taxaReal * 100).toStringAsFixed(1)}%",
                              color: isLucrativo ? Colors.green.shade700 : Colors.red.shade700,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                // --- NOVO: ANÁLISE DE DRAWDOWN ---
                Card(
                  elevation: 2,
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Análise de Risco (Drawdown)",
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 12),
                        Center(
                          child: _buildKpiChip(
                            label: "Pior Queda (Pico ao Fundo)",
                            value: "$maxDrawdownStr% (em $maxDrawdownDataStr)",
                            color: Colors.red.shade700,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Histórico de Quedas (%)',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          textAlign: TextAlign.center,
                        ),
                        _buildGraficoDrawdowns(),
                      ],
                    ),
                  ),
                ),

                const Divider(height: 30),

                // --- INSERÇÃO DO NOVO CALENDÁRIO AQUI ---
                _buildGraficoHeatmapCalendario(),
                const Divider(height: 30),

                const Text('Evolução da Banca', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                _buildGraficoEvolucaoBanca(),
                const Divider(height: 30),

                const Text('Crescimento Orgânico (Sem Aportes)', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                _buildGraficoLucroAcumulado(),
                const Divider(height: 30),

                _buildGraficoCrescimentoMensal(),
                const Divider(height: 30),

                const Text('Eficiência dos Ciclos (por nº de perdas)', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                _buildGraficoDistribuicaoStakes(),
                const Divider(height: 30),

                const Text('Filtros de Análise', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),

                DropdownButtonFormField<String>(
                  value: _filtroTipoSelecionado,
                  hint: const Text("Filtrar por tipo de aposta"),
                  isExpanded: true,
                  items: tiposUnicos.map((tipo) => DropdownMenuItem(value: tipo, child: Text(tipo))).toList(),
                  onChanged: (val) { setState(() { _filtroTipoSelecionado = val; _aplicarFiltros(); }); },
                  decoration: InputDecoration(
                    suffixIcon: _filtroTipoSelecionado != null ? IconButton(icon: const Icon(Icons.clear), onPressed: (){ setState(() { _filtroTipoSelecionado = null; _aplicarFiltros(); }); },) : null,
                  ),
                ),
                const SizedBox(height: 8),

                DropdownButtonFormField<String>(
                  value: _filtroCampeonatoSelecionado,
                  hint: const Text("Filtrar por campeonato"),
                  isExpanded: true,
                  items: campeonatosUnicos.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                  onChanged: (val) { setState(() { _filtroCampeonatoSelecionado = val; _aplicarFiltros(); }); },
                  decoration: InputDecoration(
                    suffixIcon: _filtroCampeonatoSelecionado != null ? IconButton(icon: const Icon(Icons.clear), onPressed: (){ setState(() { _filtroCampeonatoSelecionado = null; _aplicarFiltros(); }); },) : null,
                  ),
                ),
                const SizedBox(height: 8),

                DropdownButtonFormField<int>(
                  value: _filtroConfiancaSelecionado,
                  hint: const Text("Filtrar por nível de confiança"),
                  isExpanded: true,
                  items: List.generate(10, (i) => DropdownMenuItem(value: i + 1, child: Text((i + 1).toString()))),
                  onChanged: (val) { setState(() { _filtroConfiancaSelecionado = val; _aplicarFiltros(); }); },
                  decoration: InputDecoration(
                    suffixIcon: _filtroConfiancaSelecionado != null ? IconButton(icon: const Icon(Icons.clear), onPressed: (){ setState(() { _filtroConfiancaSelecionado = null; _aplicarFiltros(); }); },) : null,
                  ),
                ),
                const SizedBox(height: 16),

                DropdownButtonFormField<int>(
                  value: _filtroPlaybookSelecionado,
                  hint: const Text("Filtrar por playbook"),
                  isExpanded: true,
                  items: playbooksOrdenados.map((p) {
                    final id = (p['id'] as num).toInt();
                    final nome = p['nome'] as String;
                    return DropdownMenuItem(value: id, child: Text(nome));
                  }).toList(),
                  onChanged: (val) { setState(() { _filtroPlaybookSelecionado = val; _aplicarFiltros(); }); },
                  decoration: InputDecoration(
                    suffixIcon: _filtroPlaybookSelecionado != null ? IconButton(icon: const Icon(Icons.clear), onPressed: (){ setState(() { _filtroPlaybookSelecionado = null; _aplicarFiltros(); }); },) : null,
                  ),
                ),
                const SizedBox(height: 16),

                if (_filtroOddValues != null) ...[
                  Text("Filtrar por Odd: ${_filtroOddValues!.start.toStringAsFixed(2)} - ${_filtroOddValues!.end.toStringAsFixed(2)}"),
                  RangeSlider(
                    values: _filtroOddValues!,
                    min: _minOddDisponivel,
                    max: _maxOddDisponivel,
                    divisions: (_maxOddDisponivel > _minOddDisponivel) ? ((_maxOddDisponivel - _minOddDisponivel) * 20).toInt().clamp(1, 200) : 1,
                    labels: RangeLabels(_filtroOddValues!.start.toStringAsFixed(2), _filtroOddValues!.end.toStringAsFixed(2)),
                    onChanged: (values) { setState(() { _filtroOddValues = values; }); },
                    onChangeEnd: (values) { _aplicarFiltros(); },
                  ),
                ],

                Align(
                  alignment: Alignment.centerRight,
                  child: ElevatedButton(
                    onPressed: _limparFiltros,
                    child: const Text("Limpar Filtros"),
                  ),
                ),
                const Divider(height: 30),

                const Text('Resultados Gerais e Filtrados', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                Card(child: ListTile(title: const Text("Lucro total (Filtrado)"), subtitle: Text("R\$ ${_calcularLucroTotal(_apostasFiltradas).toStringAsFixed(2)}"))),
                Card(child: ListTile(title: const Text("Taxa de acerto (Filtrado)"), subtitle: Text(_formatarTaxaAcerto(_apostasFiltradas)))),

                const SizedBox(height: 20),
                Text('Apostas Filtradas (${_apostasFiltradas.length})', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                if (_apostasFiltradas.isEmpty)
                  const Center(child: Text("Nenhuma aposta encontrada com os filtros selecionados.")),
                ..._apostasFiltradas.reversed.map((a) {
                  // CORREÇÃO: Variáveis definidas aqui
                  final lucro = (a['lucro'] as num).toDouble();
                  final stake = (a['stake'] as num).toDouble();
                  final retorno = lucro > 0 ? stake + lucro : 0.0;
                  final time = (a['time'] as String?) ?? '';
                  // FIM DA CORREÇÃO
                  final nivelTxt = (a['nivelConfianca'] != null) ? " • Nível: ${(a['nivelConfianca'] as num).toInt()}" : "";
                  final margemTxt = (a['margem'] != null) ? " • Margem: ${a['margem']}" : "";
                  final comentTxt = (a['comentarios'] != null && (a['comentarios'] as String).isNotEmpty) ? "\nComentário: ${a['comentarios']}" : "";
                  final evTxt = (a['evPositivo'] == true) ? " (EV+)" : "";
                  final playbookTxt = (a['playbookNome'] != null && (a['playbookNome'] as String).isNotEmpty) ? " • Playbook: ${a['playbookNome']}" : "";

                  return ListTile(
                    title: Text("${a['tipo']}$evTxt • ${a['campeonato'] ?? ''}${time.isNotEmpty ? ' • $time' : ''}"),
                    subtitle: Text(
                      "Stake: R\$ ${stake.toStringAsFixed(2)} • Odd: ${a['odd']} • Retorno: R\$ ${retorno.toStringAsFixed(2)}\nCiclo ${a['cicloId']} • Lucro: R\$ ${lucro.toStringAsFixed(2)} • Data: ${a['data'].toString().split('T').first}$nivelTxt$margemTxt$playbookTxt$comentTxt",
                    ),
                    isThreeLine: comentTxt.isNotEmpty,
                    trailing: Icon(lucro > 0 ? Icons.check_circle : Icons.cancel, color: lucro > 0 ? Colors.green : Colors.red, size: 20),
                  );
                }).toList(),
              ],
            ),
          ),

          // ---------- Análise ----------
          _buildAbaAnalise(),

          // ---------- Apostas ----------
          Padding(
            padding: const EdgeInsets.all(12),
            child: ListView(
              children: [
                const Text('Registrar Aposta', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Autocomplete<String>(
                  optionsBuilder: (textEditingValue) {
                    if (textEditingValue.text == '') return const Iterable<String>.empty();
                    return tiposUnicos.where((o) => o.toLowerCase().contains(textEditingValue.text.toLowerCase()));
                  },
                  onSelected: (s) => _tipoCtrl.text = s,
                  fieldViewBuilder: (context, controller, focusNode, onSubmitted) {
                    if (controller.text != _tipoCtrl.text) {
                      controller.value = _tipoCtrl.value;
                    }
                    return TextFormField(
                      controller: controller,
                      focusNode: focusNode,
                      onChanged: (_) => _tipoCtrl.value = controller.value,
                      onFieldSubmitted: (s) => onSubmitted(),
                      decoration: const InputDecoration(labelText: "Tipo (ex: Futebol)"),
                    );
                  },
                ),
                const SizedBox(height: 8),
                Autocomplete<String>(
                  optionsBuilder: (textEditingValue) {
                    if (textEditingValue.text == '') return const Iterable<String>.empty();
                    return campeonatosUnicos.where((o) => o.toLowerCase().contains(textEditingValue.text.toLowerCase()));
                  },
                  onSelected: (s) => _campeonatoCtrl.text = s,
                  fieldViewBuilder: (context, controller, focusNode, onSubmitted) {
                    if (controller.text != _campeonatoCtrl.text) {
                      controller.value = _campeonatoCtrl.value;
                    }
                    return TextFormField(
                      controller: controller,
                      focusNode: focusNode,
                      onChanged: (_) => _campeonatoCtrl.value = controller.value,
                      onFieldSubmitted: (s) => onSubmitted(),
                      decoration: const InputDecoration(labelText: "Campeonato (ex: Brasileirão)"),
                    );
                  },
                ),
                const SizedBox(height: 8),
                Autocomplete<String>(
                  optionsBuilder: (textEditingValue) {
                    if (textEditingValue.text == '') return const Iterable<String>.empty();
                    return timesUnicos.where((o) => o.toLowerCase().contains(textEditingValue.text.toLowerCase()));
                  },
                  onSelected: (s) => _timeCtrl.text = s,
                  fieldViewBuilder: (context, controller, focusNode, onSubmitted) {
                    if (controller.text != _timeCtrl.text) {
                      controller.value = _timeCtrl.value;
                    }
                    return TextFormField(
                      controller: controller,
                      focusNode: focusNode,
                      onChanged: (_) => _timeCtrl.value = controller.value,
                      onFieldSubmitted: (s) => onSubmitted(),
                      decoration: const InputDecoration(labelText: "Time (aposta em 1 time)"),
                    );
                  },
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(controller: _oddCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: "Odd")),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextFormField(controller: _stakeCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: "Stake (R\$)")),
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                DropdownButtonFormField<int>(
                  decoration: const InputDecoration(labelText: "Nível de Confiança (1–10)"),
                  value: _nivelConfiancaSelecionado,
                  items: List.generate(10, (i) => DropdownMenuItem(value: i + 1, child: Text((i + 1).toString()))),
                  onChanged: (v) => setState(() => _nivelConfiancaSelecionado = v),
                ),
                const SizedBox(height: 8),

                TextFormField(
                  controller: _margemCtrl,
                  keyboardType: const TextInputType.numberWithOptions(signed: true),
                  decoration: const InputDecoration(labelText: "Margem (+/-) (ex: 2, -1)"),
                ),
                const SizedBox(height: 8),

                Autocomplete<String>(
                  optionsBuilder: (textEditingValue) {
                    if (textEditingValue.text == '') return const Iterable<String>.empty();
                    return comentariosUnicos.where((o) => o.toLowerCase().contains(textEditingValue.text.toLowerCase()));
                  },
                  onSelected: (s) => _comentariosCtrl.text = s,
                  fieldViewBuilder: (context, controller, focusNode, onSubmitted) {
                    if (controller.text != _comentariosCtrl.text) {
                      controller.value = _comentariosCtrl.value;
                    }
                    return TextFormField(
                      controller: controller,
                      focusNode: focusNode,
                      onChanged: (_) => _comentariosCtrl.value = controller.value,
                      onFieldSubmitted: (s) => onSubmitted(),
                      decoration: const InputDecoration(labelText: "Comentários (ex: Bom valor)"),
                      maxLines: 2,
                    );
                  },
                ),
                const SizedBox(height: 8),

                DropdownButtonFormField<int>(
                  decoration: const InputDecoration(labelText: "Playbook usado"),
                  value: _playbookSelecionadoId,
                  items: playbooksOrdenados.map((p) {
                    final id = (p['id'] as num).toInt();
                    final nome = p['nome'] as String;
                    return DropdownMenuItem<int>(value: id, child: Text(nome));
                  }).toList(),
                  onChanged: (v) => setState(() => _playbookSelecionadoId = v),
                ),
                if (playbooksOrdenados.isEmpty)
                  Align(
                    alignment: Alignment.centerLeft,
                    child: TextButton.icon(
                      onPressed: () => _mostrarDialogoPlaybook(),
                      icon: const Icon(Icons.auto_awesome_motion),
                      label: const Text('Criar playbook'),
                    ),
                  ),
                const SizedBox(height: 8),

                // NOVO: Checkbox EV+
                CheckboxListTile(
                  title: const Text("Esta foi uma aposta de valor (EV+)"),
                  value: _evPositivoSelecionado ?? false,
                  onChanged: (val) {
                    setState(() {
                      _evPositivoSelecionado = val;
                    });
                  },
                ),

                const SizedBox(height: 8),

                Row(
                  children: [
                    const Text("Resultado: "),
                    const SizedBox(width: 8),
                    ChoiceChip(
                      label: const Text("Ganhou"),
                      selected: _resultadoSelecionado == 1,
                      onSelected: (s) => setState(() => _resultadoSelecionado = s ? 1 : _resultadoSelecionado),
                    ),
                    const SizedBox(width: 8),
                    ChoiceChip(
                      label: const Text("Perdeu"),
                      selected: _resultadoSelecionado == -1,
                      onSelected: (s) => setState(() => _resultadoSelecionado = s ? -1 : _resultadoSelecionado),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                _buildCardAnalisePreLancamento(),
                const SizedBox(height: 8),
                Row(
                  children: [
                    ElevatedButton(
                      onPressed: () async {
                        final d = await showDatePicker(context: context, initialDate: _dataAposta, firstDate: DateTime(2000), lastDate: DateTime(2100));
                        if (d != null) setState(() => _dataAposta = d);
                      },
                      child: Text("Data: ${_dataAposta.toIso8601String().split("T").first}"),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: DropdownButtonFormField<int>(
                        value: _selectedCicloIdForForm,
                        items: ciclos.map((c) {
                          final id = (c["id"] as num).toInt();
                          return DropdownMenuItem(value: id, child: Text("Ciclo $id (${c['status']})"));
                        }).toList(),
                        onChanged: (v) => setState(() {
                          _selectedCicloIdForForm = v;
                          _atualizarStakeSugerida();
                        }),
                        decoration: const InputDecoration(labelText: "ID do ciclo"),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: _adicionarPreLancamento,
                        icon: const Icon(Icons.playlist_add),
                        label: const Text("Pré-lançar"),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          final tipo = _tipoCtrl.text.trim().isEmpty ? "Geral" : _tipoCtrl.text.trim();
                          final campeonato = _campeonatoCtrl.text.trim();
                          final time = _timeCtrl.text.trim();
                          final odd = double.tryParse(_oddCtrl.text.replaceAll(",", ".")) ?? 0.0;
                          final stake = double.tryParse(_stakeCtrl.text.replaceAll(",", ".")) ?? _stakeIndividualDefault();
                          final cicloId = _selectedCicloIdForForm;

                          final margem = int.tryParse(_margemCtrl.text);
                          final comentarios = _comentariosCtrl.text.trim();
                          final playbookId = _playbookSelecionadoId;

                          if (cicloId == null) {
                            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Selecione um ciclo ou crie um novo.")));
                            return;
                          }

                          if (playbookId == null) {
                            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Selecione o playbook usado nesta aposta.")));
                            return;
                          }

                          final playbookSelecionado = playbooks.firstWhere((p) => (p['id'] as num).toInt() == playbookId, orElse: () => {});
                          if (playbookSelecionado.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Playbook inválido. Selecione novamente.")));
                            return;
                          }

                          final cicloSelecionado = ciclos.firstWhere((c) => (c['id'] as num).toInt() == cicloId);
                          if (cicloSelecionado['status'] == 'ganho' || cicloSelecionado['status'] == 'perdido') {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text("Este ciclo já está encerrado. Por favor, crie ou selecione um novo ciclo."),
                                backgroundColor: Colors.orange,
                              ),
                            );
                            return;
                          }

                          _registrarAposta(
                            data: _dataAposta,
                            tipo: tipo,
                            campeonato: campeonato,
                            time: time,
                            odd: odd,
                            stakeUsada: stake,
                            resultado: _resultadoSelecionado,
                            cicloId: cicloId,
                            nivelConfianca: _nivelConfiancaSelecionado,
                            margem: margem,
                            comentarios: comentarios,
                            evPositivo: _evPositivoSelecionado,
                            playbookId: playbookId,
                            playbookNome: playbookSelecionado['nome'] as String,
                          );

                          final origemId = _preLancamentoOrigemId;
                          if (origemId != null) {
                            _removerPreLancamentoPorId(origemId);
                          }

                          _tipoCtrl.clear();
                          _campeonatoCtrl.clear();
                          _timeCtrl.clear();
                          _oddCtrl.text = "2.00";
                          _nivelConfiancaSelecionado = null;
                          _margemCtrl.clear();
                          _comentariosCtrl.clear();
                          _evPositivoSelecionado = null;
                          _playbookSelecionadoId = null;
                          _preLancamentoOrigemId = null;
                          FocusScope.of(context).unfocus();
                        },
                        child: const Text("Registrar aposta"),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                const Text('Pré-lançadas', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                if (preLancamentos.isEmpty)
                  const Text('Nenhuma aposta pré-lançada no momento.'),
                ...preLancamentos.reversed.map((pre) {
                  final odd = ((pre['odd'] as num?)?.toDouble() ?? 0.0).toStringAsFixed(2);
                  final stake = ((pre['stake'] as num?)?.toDouble() ?? 0.0).toStringAsFixed(2);
                  final data = (pre['dataAposta'] as String? ?? '').split('T').first;
                  return Card(
                    child: ListTile(
                      title: Text("${pre['tipo'] ?? 'Geral'} • ${pre['campeonato'] ?? ''}${(pre['time'] as String?)?.isNotEmpty == true ? ' • ${pre['time']}' : ''}"),
                      subtitle: Text('Odd: $odd • Stake: R\$ $stake • Data: $data'),
                      trailing: Wrap(
                        spacing: 4,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.send),
                            tooltip: 'Lançar',
                            onPressed: () => _usarPreLancamento(pre),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete_outline),
                            tooltip: 'Excluir',
                            onPressed: () => _removerPreLancamentoPorId((pre['id'] as num).toInt()),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
                const Divider(),
                const Text('Histórico de apostas', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                ...apostas.reversed.map((a) {
                  final lucro = (a['lucro'] as num).toDouble();
                  final stake = (a['stake'] as num).toDouble();
                  final retorno = lucro > 0 ? stake + lucro : 0.0;
                  final time = (a['time'] as String?) ?? '';
                  final nivelTxt = (a['nivelConfianca'] != null) ? " • Nível: ${(a['nivelConfianca'] as num).toInt()}" : "";
                  final margemTxt = (a['margem'] != null) ? " • Margem: ${a['margem']}" : "";
                  final comentTxt = (a['comentarios'] != null && (a['comentarios'] as String).isNotEmpty) ? "\nComentário: ${a['comentarios']}" : "";
                  final evTxt = (a['evPositivo'] == true) ? " (EV+)" : "";
                  final playbookTxt = (a['playbookNome'] != null && (a['playbookNome'] as String).isNotEmpty) ? " • Playbook: ${a['playbookNome']}" : "";

                  return ListTile(
                    title: Text("${a['tipo']}$evTxt • ${a['campeonato'] ?? ''}${time.isNotEmpty ? ' • $time' : ''}"),
                    subtitle: Text(
                      "Stake: R\$ ${stake.toStringAsFixed(2)} • Odd: ${a['odd']} • Retorno: R\$ ${retorno.toStringAsFixed(2)}\nCiclo ${a['cicloId']} • Lucro: R\$ ${lucro.toStringAsFixed(2)} • Data: ${a['data'].toString().split('T').first}$nivelTxt$margemTxt$playbookTxt$comentTxt",
                    ),
                    isThreeLine: comentTxt.isNotEmpty,
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit, size: 20),
                          onPressed: () => _mostrarDialogoEditarAposta(a),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, size: 20),
                          onPressed: () async {
                            final ok = await _confirmDialog("Excluir aposta", "Confirma excluir esta aposta?");
                            if (ok == true) {
                              setState(() {
                                final int id = (a['id'] as num).toInt();
                                final int cicloIdDaAposta = (a['cicloId'] as num).toInt();
                                apostas.remove(a);
                                for (var c in ciclos) {
                                  (c['apostasIds'] as List).removeWhere((x) => x == id);
                                }
                                _atualizarCicloDepoisDeAposta(cicloIdDaAposta);
                                _inicializarFiltros();
                                _atualizarStakeSugerida();
                                _salvarDados();
                              });
                            }
                          },
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ],
            ),
          ),

          // ---------- Controle de Ciclos ----------
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              children: [
                Row(
                  children: [
                    const Expanded(child: Text('Controle de Ciclos', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold))),
                    ElevatedButton(
                      onPressed: () => _criarCicloManual(),
                      child: const Text("Criar novo ciclo"),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Expanded(
                  child: ListView.builder(
                    itemCount: ciclos.length,
                    itemBuilder: (context, i) {
                      final reversedIndex = ciclos.length - 1 - i;
                      final c = ciclos[reversedIndex];
                      final status = c['status'] as String;
                      final apostasDoCiclo = apostas.where((a) => (c['apostasIds'] as List).contains(a['id'])).toList();
                      final perdas = apostasDoCiclo.where((a) => (a['lucro'] as num) < 0).length;

                      // MODIFICADO: Lógica para pegar datas de início e fim
                      String intervaloDatas = "Sem apostas";
                      if (apostasDoCiclo.isNotEmpty) {
                        // Ordena para garantir
                        final sorted = List<Map<String, dynamic>>.from(apostasDoCiclo)
                          ..sort((a, b) => DateTime.parse(a['data']).compareTo(DateTime.parse(b['data'])));

                        final inicio = DateFormat('dd/MM').format(DateTime.parse(sorted.first['data']));
                        final fim = DateFormat('dd/MM/yy').format(DateTime.parse(sorted.last['data']));
                        intervaloDatas = "$inicio até $fim";
                      }

                      return Card(
                        color: _corStatus(status),
                        child: ListTile(
                          title: Text("Ciclo ${c['id']} • Stake individual: R\$ ${(c['stakeIndividual'] as num).toDouble().toStringAsFixed(2)}"),
                          subtitle: Text(
                            "Período: $intervaloDatas\nStatus: ${status.replaceAll('_', ' ')} • Perdas: $perdas • Lucro: R\$ ${(c['lucroLiquido'] as num).toDouble().toStringAsFixed(2)}\nApostas: ${(c['apostasIds'] as List).length}",
                          ),
                          isThreeLine: true,
                          trailing: PopupMenuButton<String>(
                            onSelected: (v) async {
                              if (v == "forcar_ganho") {
                                final ok = await _confirmDialog("Forçar encerrar", "Deseja forçar encerrar este ciclo como VITORIOSO?");
                                if (ok == true) {
                                  setState(() {
                                    final statusAntigo = ciclos[reversedIndex]['status'];
                                    ciclos[reversedIndex]["status"] = "ganho";
                                    if(statusAntigo == 'em_andamento'){
                                      // CORREÇÃO: Usa data da última aposta no encerramento forçado
                                      DateTime dataRegistro = DateTime.now();
                                      if (apostasDoCiclo.isNotEmpty) {
                                        final sorted = List<Map<String, dynamic>>.from(apostasDoCiclo);
                                        sorted.sort((a, b) => DateTime.parse(a['data']).compareTo(DateTime.parse(b['data'])));
                                        dataRegistro = DateTime.parse(sorted.last['data']);
                                      }
                                      historicoBanca.add({"data": dataRegistro.toIso8601String(), "valorBanca": bancaAtual});
                                    }
                                    _salvarDados();
                                  });
                                }
                              } else if (v == "forcar_encerrar") {
                                final ok = await _confirmDialog("Forçar encerrar", "Deseja forçar encerrar este ciclo como PERDIDO?");
                                if (ok == true) {
                                  setState(() {
                                    final statusAntigo = ciclos[reversedIndex]['status'];
                                    ciclos[reversedIndex]["status"] = "perdido";
                                    if(statusAntigo == 'em_andamento'){
                                      // CORREÇÃO: Usa data da última aposta no encerramento forçado
                                      DateTime dataRegistro = DateTime.now();
                                      if (apostasDoCiclo.isNotEmpty) {
                                        final sorted = List<Map<String, dynamic>>.from(apostasDoCiclo);
                                        sorted.sort((a, b) => DateTime.parse(a['data']).compareTo(DateTime.parse(b['data'])));
                                        dataRegistro = DateTime.parse(sorted.last['data']);
                                      }
                                      historicoBanca.add({"data": dataRegistro.toIso8601String(), "valorBanca": bancaAtual});
                                    }
                                    _salvarDados();
                                  });
                                }
                              } else if (v == "recalcular") {
                                _atualizarCicloDepoisDeAposta((c['id'] as num).toInt());
                              } else if (v == "excluir") {
                                final ok = await _confirmDialog("Excluir ciclo", "Confirma excluir este ciclo E TODAS AS SUAS APOSTAS?");
                                if (ok == true) {
                                  setState(() {
                                    final ids = (c['apostasIds'] as List).cast<int>();
                                    // Remove as apostas
                                    apostas.removeWhere((a) => ids.contains((a['id'] as num).toInt()));
                                    // Remove o ciclo
                                    ciclos.removeAt(reversedIndex);

                                    // NÃO recalcular outros ciclos, apenas salvar.
                                    _inicializarFiltros();
                                    _salvarDados();
                                  });
                                }
                              }
                            },
                            itemBuilder: (ctx) => [
                              const PopupMenuItem(value: "recalcular", child: Text("Recalcular")),
                              const PopupMenuItem(value: "forcar_ganho", child: Text("Forçar encerrar (ganho)")),
                              const PopupMenuItem(value: "forcar_encerrar", child: Text("Forçar encerrar (perdido)")),
                              const PopupMenuItem(value: "excluir", child: Text("Excluir ciclo e apostas")),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),

          // ---------- Configurações ----------
          Padding(
            padding: const EdgeInsets.all(12),
            child: ListView(
              children: [
                const Text('Configurações Gerais', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                TextFormField(
                  initialValue: bancaInicial.toStringAsFixed(2),
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: "Banca inicial (R\$)"),
                  onChanged: (v) {
                    final parsed = double.tryParse(v.replaceAll(",", ".")) ?? bancaInicial;
                    setState(() {
                      bancaInicial = parsed;
                      _salvarDados();
                    });
                  },
                ),
                const SizedBox(height: 12),
                const Divider(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Playbooks', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    TextButton.icon(
                      onPressed: () => _mostrarDialogoPlaybook(),
                      icon: const Icon(Icons.add),
                      label: const Text('Novo'),
                    ),
                  ],
                ),
                if (playbooks.isEmpty)
                  const ListTile(
                    title: Text('Nenhum playbook cadastrado.'),
                    subtitle: Text('Crie um playbook para tornar o campo obrigatório no registro da aposta.'),
                  ),
                ...playbooksOrdenados.map((p) {
                  final checklist = ((p['checklist'] as List?) ?? const []).map((e) => e.toString()).toList();
                  return ListTile(
                    leading: const Icon(Icons.auto_awesome_motion),
                    title: Text(p['nome'] as String),
                    subtitle: Text(
                      [
                        if ((p['criterios'] as String?)?.isNotEmpty == true) p['criterios'] as String,
                        if (checklist.isNotEmpty) 'Checklist: ${checklist.length} item(ns)',
                      ].join(' • '),
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.content_copy),
                          onPressed: () => _mostrarDialogoPlaybook(playbookParaEditar: p, duplicar: true),
                        ),
                        IconButton(
                          icon: const Icon(Icons.edit),
                          onPressed: () => _mostrarDialogoPlaybook(playbookParaEditar: p),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () => _removerPlaybook((p['id'] as num).toInt()),
                        ),
                      ],
                    ),
                  );
                }).toList(),

                const SizedBox(height: 12),
                const Text('Aportes (manuais)'),
                ...aportes.map((a) {
                  return ListTile(
                    title: Text("R\$ ${(a['valor'] as num).toDouble().toStringAsFixed(2)}"),
                    subtitle: Text(a['data'] ?? ""),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete),
                      onPressed: () async {
                        final ok = await _confirmDialog("Excluir aporte", "Confirma excluir este aporte?");
                        if (ok == true) {
                          setState(() {
                            aportes.remove(a);
                            _salvarDados();
                          });
                        }
                      },
                    ),
                  );
                }).toList(),
                ElevatedButton(
                  onPressed: () async {
                    final res = await showDialog<Map<String, dynamic>>(
                      context: context,
                      builder: (c) {
                        final ctrlValor = TextEditingController();
                        DateTime selected = DateTime.now();
                        return AlertDialog(
                          title: const Text("Adicionar aporte"),
                          content: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              TextFormField(controller: ctrlValor, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: "Valor (R\$)")),
                              const SizedBox(height: 8),
                              ElevatedButton(
                                onPressed: () async {
                                  final d = await showDatePicker(context: c, initialDate: DateTime.now(), firstDate: DateTime(2000), lastDate: DateTime(2100));
                                  if (d != null) selected = d;
                                },
                                child: const Text("Escolher data"),
                              ),
                            ],
                          ),
                          actions: [
                            TextButton(onPressed: () => Navigator.pop(c), child: const Text("Cancelar")),
                            TextButton(
                                onPressed: () {
                                  final v = double.tryParse(ctrlValor.text.replaceAll(",", ".")) ?? 0.0;
                                  Navigator.pop(c, {"valor": v, "data": selected.toIso8601String()});
                                },
                                child: const Text("Adicionar")),
                          ],
                        );
                      },
                    );
                    if (res != null) {
                      setState(() {
                        aportes.add(res);
                        _salvarDados();
                      });
                    }
                  },
                  child: const Text("Adicionar aporte"),
                ),
                const SizedBox(height: 12),
                const Text('Saques (manuais)'),
                ...saques.map((a) {
                  return ListTile(
                    title: Text("R\$ ${(a['valor'] as num).toDouble().toStringAsFixed(2)}"),
                    subtitle: Text(a['data'] ?? ""),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete),
                      onPressed: () async {
                        final ok = await _confirmDialog("Excluir saque", "Confirma excluir este saque?");
                        if (ok == true) {
                          setState(() {
                            saques.remove(a);
                            _salvarDados();
                          });
                        }
                      },
                    ),
                  );
                }).toList(),
                ElevatedButton(
                  onPressed: () async {
                    final res = await showDialog<Map<String, dynamic>>(
                      context: context,
                      builder: (c) {
                        final ctrlValor = TextEditingController();
                        DateTime selected = DateTime.now();
                        return AlertDialog(
                          title: const Text("Adicionar saque"),
                          content: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              TextFormField(controller: ctrlValor, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: "Valor (R\$)")),
                              const SizedBox(height: 8),
                              ElevatedButton(
                                onPressed: () async {
                                  final d = await showDatePicker(context: c, initialDate: DateTime.now(), firstDate: DateTime(2000), lastDate: DateTime(2100));
                                  if (d != null) selected = d;
                                },
                                child: const Text("Escolher data"),
                              ),
                            ],
                          ),
                          actions: [
                            TextButton(onPressed: () => Navigator.pop(c), child: const Text("Cancelar")),
                            TextButton(
                                onPressed: () {
                                  final v = double.tryParse(ctrlValor.text.replaceAll(",", ".")) ?? 0.0;
                                  Navigator.pop(c, {"valor": v, "data": selected.toIso8601String()});
                                },
                                child: const Text("Adicionar")),
                          ],
                        );
                      },
                    );
                    if (res != null) {
                      setState(() {
                        saques.add(res);
                        _salvarDados();
                      });
                    }
                  },
                  child: const Text("Adicionar saque"),
                ),
                const Divider(height: 24),
                const Text('Gerenciamento de Risco', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                SwitchListTile(
                  title: const Text("Usar % da banca para stake do ciclo"),
                  value: usarPercentualDaBanca,
                  onChanged: (bool value) {
                    setState(() {
                      usarPercentualDaBanca = value;
                      _salvarDados();
                    });
                  },
                ),
                if (usarPercentualDaBanca)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: TextFormField(
                      initialValue: percentualRisco.toString(),
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: "Percentual de risco por ciclo (%)"),
                      onChanged: (v) {
                        final parsed = double.tryParse(v.replaceAll(",", ".")) ?? percentualRisco;
                        setState(() {
                          percentualRisco = parsed;
                          _salvarDados();
                        });
                      },
                    ),
                  )
                else
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: TextFormField(
                      initialValue: valorPorCiclo.toStringAsFixed(2),
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: "Valor fixo por ciclo (R\$)"),
                      onChanged: (v) {
                        final parsed = double.tryParse(v.replaceAll(",", ".")) ?? valorPorCiclo;
                        setState(() {
                          valorPorCiclo = parsed;
                          _salvarDados();
                        });
                      },
                    ),
                  ),
                const SizedBox(height: 8),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: TextFormField(
                    initialValue: qtdStakesPorCiclo.toString(),
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: "Qtd. de stakes por ciclo (ex: 5)"),
                    onChanged: (v) {
                      final parsed = int.tryParse(v) ?? qtdStakesPorCiclo;
                      setState(() {
                        qtdStakesPorCiclo = parsed;
                        _stakeCtrl.text = _stakeIndividualDefault().toStringAsFixed(2);
                        _salvarDados();
                      });
                    },
                  ),
                ),

                const Divider(height: 24),
                const Text('Backup e Restauração', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                if (_isLoadingBackup)
                  const Center(child: Padding(
                    padding: EdgeInsets.all(8.0),
                    child: CircularProgressIndicator(),
                  ))
                else
                  Card(
                    elevation: 0,
                    color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.5),
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: ElevatedButton.icon(
                                  onPressed: _criarBackup,
                                  icon: const Icon(Icons.save_alt),
                                  label: const Text("Salvar Backup"),
                                  style: ElevatedButton.styleFrom(backgroundColor: Colors.blue.shade700, foregroundColor: Colors.white),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: ElevatedButton.icon(
                                  onPressed: _carregarBackup,
                                  icon: const Icon(Icons.folder_open),
                                  label: const Text("Carregar Backup"),
                                  style: ElevatedButton.styleFrom(backgroundColor: Colors.orange.shade800, foregroundColor: Colors.white),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          // NOVO BOTÃO DE EXPORTAÇÃO PARA IA (TXT)
                          ElevatedButton.icon(
                            onPressed: _isLoadingBackup ? null : _exportarRelatorioIA,
                            icon: const Icon(Icons.text_snippet_outlined),
                            label: const Text("Exportar Relatório para IA (TXT)"),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.purple.shade700,
                              foregroundColor: Colors.white,
                              minimumSize: const Size(double.infinity, 45), // Botão largo e um pouco mais alto
                            ),
                          ),
                          const SizedBox(height: 12),
                          // NOVO BOTÃO DE SNAPSHOT
                          ElevatedButton.icon(
                            onPressed: _isLoadingBackup ? null : _registrarHistoricoSnapshot,
                            icon: const Icon(Icons.camera_alt_outlined),
                            label: const Text("Registrar \"Snapshot\" no Histórico"),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.teal,
                              foregroundColor: Colors.white,
                              minimumSize: const Size(double.infinity, 40), // Botão largo
                            ),
                          ),
                          const SizedBox(height: 12),
                          // NOVO BOTÃO DE DEBUG (Recriar sumário)
                          ElevatedButton.icon(
                            onPressed: _isLoadingBackup ? null : _forcarRecriacaoDashboard,
                            icon: const Icon(Icons.bug_report_outlined),
                            label: const Text("Forçar Recriação do Sumário (Debug)"),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.grey.shade600,
                              foregroundColor: Colors.white,
                              minimumSize: const Size(double.infinity, 40),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () async {
                    final ok = await _confirmDialog("Limpar ciclos e apostas", "Deseja realmente remover todos os ciclos e apostas? Essa ação não altera as configurações.");
                    if (ok == true) {
                      setState(() {
                        ciclos.clear();
                        apostas.clear();
                        historicoBanca.clear();
                        metas.clear();
                        _salvarDados();
                      });
                    }
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.red.shade400),
                  child: const Text("Limpar todos os dados (Apostas/Ciclos/Metas)"),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
// ===================================================================
// FIM DO BLOCO DA TELA DE APOSTAS (TELA 1)
// ===================================================================


// ===================================================================
// INICIO DO BLOCO DA TELA EV+ (TELA 2 )  IA com analise de eficiencia
// ===================================================================

class TelaSobra1 extends StatefulWidget {
  const TelaSobra1({super.key});

  @override
  State<TelaSobra1> createState() => _TelaSobra1State();
}

class _TelaSobra1State extends State<TelaSobra1> with SingleTickerProviderStateMixin {
  // Controladores da Aba "Histórico"
  final TextEditingController _timeCasaCtrl = TextEditingController();
  final TextEditingController _timeForaCtrl = TextEditingController();
  final TextEditingController _tipoCtrl = TextEditingController();
  final TextEditingController _campeonatoCtrl = TextEditingController();
  final TextEditingController _oddCtrl = TextEditingController();

  // Controladores da Aba "Poisson Manual Pro"
  final TextEditingController _poissonCampeonatoCtrl = TextEditingController();
  final TextEditingController _poissonMandanteCtrl = TextEditingController();
  final TextEditingController _poissonVisitanteCtrl = TextEditingController();
  final TextEditingController _poissonMediaLigaCtrl = TextEditingController();
  final TextEditingController _poissonJogosMandanteCtrl = TextEditingController();
  final TextEditingController _poissonJogosVisitanteCtrl = TextEditingController();

  // NOVOS CONTROLES PARA XG SEPARADO
  final TextEditingController _poissonGMMandanteCtrl = TextEditingController(); // Gols Marcados Casa
  final TextEditingController _poissonXGMandanteCtrl = TextEditingController(); // xG Casa
  final TextEditingController _poissonGSMandanteCtrl = TextEditingController(); // Gols Sofridos Casa

  final TextEditingController _poissonGMVisitanteCtrl = TextEditingController(); // Gols Marcados Fora
  final TextEditingController _poissonXGVisitanteCtrl = TextEditingController(); // xG Fora
  final TextEditingController _poissonGSVisitanteCtrl = TextEditingController(); // Gols Sofridos Fora

  final TextEditingController _poissonOddCasaCtrl = TextEditingController();
  final TextEditingController _poissonOddEmpateCtrl = TextEditingController();
  final TextEditingController _poissonOddForaCtrl = TextEditingController();

  // Variáveis de estado da Aba "Poisson Manual Pro"
  double _poissonFatorCasa = 0.0;
  double _poissonFatorLiga = 1.00;
  double _poissonSuavizacao = 0.75;
  double _poissonAjusteZero = 0.0;
  double _poissonAjusteElasticidade = 0.0;
  double _poissonPesoEficacia = 0.50;
  Map<String, dynamic>? _resultadoPoisson;
  bool _nivelEnfrentamentoAtivo = false;
  final Map<int, double> _nivelEnfrentamentoPesosAtaque = {};
  final Map<int, double> _nivelEnfrentamentoPesosDefesa = {};
  final Map<int, TextEditingController> _nivelEnfrentamentoCtrlsAtaque = {};
  final Map<int, TextEditingController> _nivelEnfrentamentoCtrlsDefesa = {};
  final Map<String, Map<String, double>> _nivelEnfrentamentoResumo = {
    'mandante': {'gmRaw': 0.0, 'gmAdj': 0.0, 'xgRaw': 0.0, 'xgAdj': 0.0, 'gsRaw': 0.0, 'gsAdj': 0.0},
    'visitante': {'gmRaw': 0.0, 'gmAdj': 0.0, 'xgRaw': 0.0, 'xgAdj': 0.0, 'gsRaw': 0.0, 'gsAdj': 0.0},
  };

  // INTEGRAÇÃO SCOUT (Database)
  List<Map<String, dynamic>> _scoutPartidas = [];
  List<String> _scoutLigas = [];
  Map<String, List<String>> _scoutTimesPorLiga = {};

  // Lógica de Cards Poisson
  List<Map<String, dynamic>> _listaCardsPoisson = [];
  String? _idPoissonEmEdicao;

  // ===== VARIÁVEIS DA NOVA ABA "CONFIANÇA" =====
  final List<String> _perguntasConfianca = [
    "1° Chance de vitória de acordo com meu histórico maior que a odd oferecida?",
    "2° Cálculo de EV+ Poisson com probabilidade maior que a odd oferecida?",
    "3° Confronto direto favorável?",
    "4° Maioria das apostas anteriores nesse time com comentários positivos?",
    "5° Analise da IA com nota 8 ou mais?",
    "6° Algo coloca alguma dúvida nessa aposta?"
  ];
  List<bool> _respostasConfiancaBool = List.filled(6, false);
  List<bool> _perguntasAnuladasBool = List.filled(6, false);

  late List<TextEditingController> _obsConfiancaCtrl;
  final TextEditingController _confiancaTituloCtrl = TextEditingController();

  // Variáveis para controle de Edição e Rascunho
  String? _idCardEmEdicao;
  Timer? _debounceRascunho;

  List<Map<String, dynamic>> _listaCardsConfianca = [];
  bool _carregandoConfianca = false;

  Map<String, dynamic>? _analiseHistorico;
  String? _analiseIAResultado;
  bool _carregando = false;
  late TabController _tabController;

  List<String> _timesUnicos = [];
  List<String> _tiposUnicos = [];
  List<String> _campeonatosUnicos = [];

  List<Map<String, dynamic>> _regrasAposta = [];

  String? _geminiApiKey;

  // Helpers de formatação globais para a classe
  String _fmtPct(dynamic x) => "${((x as num).toDouble() * 100).toStringAsFixed(1)}%";
  String _fmt2(dynamic x) => (x as num).toDouble().toStringAsFixed(2);

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _carregarGeminiApiKey();
    _carregarDadosParaAutocomplete();
    _carregarRegras();
    _carregarScoutDb();

    _poissonMediaLigaCtrl.text = "2.40";
    _poissonJogosMandanteCtrl.text = "8";
    _poissonJogosVisitanteCtrl.text = "8";

    _poissonJogosMandanteCtrl.addListener(_tentaPreencherDadosComScout);
    _poissonJogosVisitanteCtrl.addListener(_tentaPreencherDadosComScout);

    _obsConfiancaCtrl = List.generate(6, (_) => TextEditingController());

    _confiancaTituloCtrl.addListener(_agendarSalvamentoRascunho);
    for (var ctrl in _obsConfiancaCtrl) {
      ctrl.addListener(_agendarSalvamentoRascunho);
    }

    _carregarCardsConfianca();
    _carregarRascunhoConfianca();
    _carregarCardsPoisson();
    _carregarConfigNivelEnfrentamento();
  }

  Future<void> _carregarGeminiApiKey() async {
    try {
      final key = await rootBundle.loadString('assets/api_key.txt');
      setState(() => _geminiApiKey = key.trim());
    } catch (e) {
      _mostrarErroIA("Não foi possível carregar a API key em assets/api_key.txt.\nErro: $e");
    }
  }

  @override
  void dispose() {
    _debounceRascunho?.cancel();
    _timeCasaCtrl.dispose();
    _timeForaCtrl.dispose();
    _tipoCtrl.dispose();
    _campeonatoCtrl.dispose();
    _oddCtrl.dispose();
    _tabController.dispose();

    _poissonCampeonatoCtrl.dispose();
    _poissonMandanteCtrl.dispose();
    _poissonVisitanteCtrl.dispose();
    _poissonMediaLigaCtrl.dispose();
    _poissonJogosMandanteCtrl.dispose();
    _poissonJogosVisitanteCtrl.dispose();

    _poissonGMMandanteCtrl.dispose();
    _poissonXGMandanteCtrl.dispose();
    _poissonGSMandanteCtrl.dispose();

    _poissonGMVisitanteCtrl.dispose();
    _poissonXGVisitanteCtrl.dispose();
    _poissonGSVisitanteCtrl.dispose();

    _poissonOddCasaCtrl.dispose();
    _poissonOddEmpateCtrl.dispose();
    _poissonOddForaCtrl.dispose();
    for (final ctrl in _nivelEnfrentamentoCtrlsAtaque.values) {
      ctrl.dispose();
    }
    for (final ctrl in _nivelEnfrentamentoCtrlsDefesa.values) {
      ctrl.dispose();
    }

    for (var ctrl in _obsConfiancaCtrl) {
      ctrl.dispose();
    }
    _confiancaTituloCtrl.dispose();

    super.dispose();
  }

  // ================== CARREGAMENTO SCOUT DATABASE ==================
  Future<void> _carregarScoutDb() async {
    try {
      final dir = await getApplicationDocumentsDirectory();
      final file = File("${dir.path}/database_campeonatos_pro.json");
      if (await file.exists()) {
        final content = await file.readAsString();
        if (content.isNotEmpty) {
          final json = jsonDecode(content);
          final listaPartidas = List<Map<String, dynamic>>.from(json['partidas'] ?? []);

          final metaCamps = List<Map<String, dynamic>>.from(json['campeonatos_metadata'] ?? []);
          final arquivados = metaCamps
              .where((m) => m['arquivado'] == true)
              .map((m) => m['nome'].toString())
              .toSet();

          final Set<String> ligas = {};
          final Map<String, Set<String>> timesPorLiga = {};

          for (var p in listaPartidas) {
            final camp = p['campeonato']?.toString() ?? "Desconhecido";

            if (!arquivados.contains(camp)) {
              ligas.add(camp);

              if (!timesPorLiga.containsKey(camp)) timesPorLiga[camp] = {};
              if (p['mandante'] != null) timesPorLiga[camp]!.add(p['mandante'].toString());
              if (p['visitante'] != null) timesPorLiga[camp]!.add(p['visitante'].toString());
            }
          }

          setState(() {
            _scoutPartidas = listaPartidas;
            _scoutPartidas.sort((a, b) => DateTime.parse(b['data']).compareTo(DateTime.parse(a['data'])));

            _scoutLigas = ligas.toList()..sort();
            _scoutTimesPorLiga = timesPorLiga.map((key, value) => MapEntry(key, value.toList()..sort()));
          });
        }
      }
    } catch (e) {
      debugPrint("Erro ao carregar Scout DB: $e");
    }
  }

  Future<File> _getPoissonNivelEnfrentamentoFile() async {
    final dir = await getApplicationDocumentsDirectory();
    return File("${dir.path}/poisson_nivel_enfrentamento.json");
  }

  Future<void> _carregarConfigNivelEnfrentamento() async {
    try {
      final file = await _getPoissonNivelEnfrentamentoFile();
      if (await file.exists()) {
        final data = await file.readAsString();
        if (data.isNotEmpty) {
          final json = jsonDecode(data) as Map<String, dynamic>;
          final pesosAtaque = json['pesosAtaque'] ?? json['pesos'];
          final pesosDefesa = json['pesosDefesa'];
          setState(() {
            _nivelEnfrentamentoAtivo = json['ativo'] == true;
            _nivelEnfrentamentoPesosAtaque.clear();
            _nivelEnfrentamentoPesosDefesa.clear();
            if (pesosAtaque is Map) {
              pesosAtaque.forEach((key, value) {
                final pos = int.tryParse(key.toString());
                final pct = (value as num?)?.toDouble();
                if (pos != null && pct != null) {
                  _nivelEnfrentamentoPesosAtaque[pos] = pct.clamp(0.0, 200.0);
                }
              });
            }
            if (pesosDefesa is Map) {
              pesosDefesa.forEach((key, value) {
                final pos = int.tryParse(key.toString());
                final pct = (value as num?)?.toDouble();
                if (pos != null && pct != null) {
                  _nivelEnfrentamentoPesosDefesa[pos] = pct.clamp(0.0, 200.0);
                }
              });
            } else {
              _nivelEnfrentamentoPesosAtaque.forEach((pos, atk) {
                _nivelEnfrentamentoPesosDefesa[pos] = (200.0 - atk).clamp(0.0, 200.0);
              });
            }
            _nivelEnfrentamentoPesosAtaque.forEach((pos, value) {
              if (_nivelEnfrentamentoCtrlsAtaque.containsKey(pos)) {
                _nivelEnfrentamentoCtrlsAtaque[pos]!.text = value.toStringAsFixed(0);
              }
            });
            _nivelEnfrentamentoPesosDefesa.forEach((pos, value) {
              if (_nivelEnfrentamentoCtrlsDefesa.containsKey(pos)) {
                _nivelEnfrentamentoCtrlsDefesa[pos]!.text = value.toStringAsFixed(0);
              }
            });
          });
        }
      }
    } catch (e) {
      debugPrint("Erro ao carregar nível de enfrentamento: $e");
    }
  }

  Future<void> _salvarConfigNivelEnfrentamento() async {
    try {
      final file = await _getPoissonNivelEnfrentamentoFile();
      final json = {
        'ativo': _nivelEnfrentamentoAtivo,
        'pesosAtaque': _nivelEnfrentamentoPesosAtaque.map((key, value) => MapEntry(key.toString(), value)),
        'pesosDefesa': _nivelEnfrentamentoPesosDefesa.map((key, value) => MapEntry(key.toString(), value)),
      };
      await file.writeAsString(jsonEncode(json));
    } catch (e) {
      debugPrint("Erro ao salvar nível de enfrentamento: $e");
    }
  }

  double _pesoNivelEnfrentamentoAtaque(int? posicao) {
    if (!_nivelEnfrentamentoAtivo || posicao == null || posicao <= 0) {
      return 1.0;
    }
    final pct = _nivelEnfrentamentoPesosAtaque[posicao] ?? 100.0;
    return (pct.clamp(0.0, 200.0)) / 100.0;
  }

  double _pesoNivelEnfrentamentoDefesa(int? posicao) {
    if (!_nivelEnfrentamentoAtivo || posicao == null || posicao <= 0) {
      return 1.0;
    }
    final pct = _nivelEnfrentamentoPesosDefesa[posicao] ??
        (200.0 - (_nivelEnfrentamentoPesosAtaque[posicao] ?? 100.0));
    return (pct.clamp(0.0, 200.0)) / 100.0;
  }

  void _atualizarPesoNivelEnfrentamento({
    required int posicao,
    required String valor,
    required bool defesa,
  }) {
    final parsed = double.tryParse(valor.replaceAll(',', '.'));
    if (parsed == null) return;
    final ajustado = parsed.clamp(0.0, 200.0);
    if (defesa) {
      _nivelEnfrentamentoPesosDefesa[posicao] = ajustado;
    } else {
      _nivelEnfrentamentoPesosAtaque[posicao] = ajustado;
    }
    _salvarConfigNivelEnfrentamento();
  }

  List<Map<String, dynamic>> _gerarClassificacaoScout(String liga) {
    final jogos = _scoutPartidas.where((p) => p['campeonato'] == liga).toList();
    final Map<String, Map<String, dynamic>> tabela = {};

    void initTime(String t) {
      if (!tabela.containsKey(t)) {
        tabela[t] = {'time': t, 'p': 0, 'j': 0, 'v': 0, 'e': 0, 'd': 0, 'gp': 0, 'gc': 0, 'sg': 0};
      }
    }

    for (var p in jogos) {
      final mand = p['mandante'].toString();
      final vis = p['visitante'].toString();
      final gm = (p['gm_casa'] as num).toInt();
      final gv = (p['gm_fora'] as num).toInt();

      initTime(mand);
      initTime(vis);

      tabela[mand]!['j']++;
      tabela[mand]!['gp'] += gm;
      tabela[mand]!['gc'] += gv;
      tabela[mand]!['sg'] += (gm - gv);

      tabela[vis]!['j']++;
      tabela[vis]!['gp'] += gv;
      tabela[vis]!['gc'] += gm;
      tabela[vis]!['sg'] += (gv - gm);

      if (gm > gv) {
        tabela[mand]!['p'] += 3;
        tabela[mand]!['v']++;
        tabela[vis]!['d']++;
      } else if (gv > gm) {
        tabela[vis]!['p'] += 3;
        tabela[vis]!['v']++;
        tabela[mand]!['d']++;
      } else {
        tabela[mand]!['p'] += 1;
        tabela[mand]!['e']++;
        tabela[vis]!['p'] += 1;
        tabela[vis]!['e']++;
      }
    }

    final lista = tabela.values.toList();
    lista.sort((a, b) {
      if (b['p'] != a['p']) return b['p'].compareTo(a['p']);
      if (b['v'] != a['v']) return b['v'].compareTo(a['v']);
      if (b['sg'] != a['sg']) return b['sg'].compareTo(a['sg']);
      return b['gp'].compareTo(a['gp']);
    });

    return lista;
  }

  Map<String, int> _mapaPosicoesLiga(String liga) {
    final classificacao = _gerarClassificacaoScout(liga);
    final posicoes = <String, int>{};
    for (int i = 0; i < classificacao.length; i++) {
      final time = classificacao[i]['time']?.toString() ?? '';
      if (time.isNotEmpty) {
        posicoes[time] = i + 1;
      }
    }
    return posicoes;
  }

  void _sincronizarControllersNivelEnfrentamento(int totalTimes) {
    for (int pos = 1; pos <= totalTimes; pos++) {
      if (!_nivelEnfrentamentoCtrlsAtaque.containsKey(pos)) {
        final valor = _nivelEnfrentamentoPesosAtaque[pos] ?? 100.0;
        _nivelEnfrentamentoCtrlsAtaque[pos] = TextEditingController(text: valor.toStringAsFixed(0));
      } else if (_nivelEnfrentamentoCtrlsAtaque[pos]!.text.isEmpty) {
        final valor = _nivelEnfrentamentoPesosAtaque[pos] ?? 100.0;
        _nivelEnfrentamentoCtrlsAtaque[pos]!.text = valor.toStringAsFixed(0);
      }
      if (!_nivelEnfrentamentoCtrlsDefesa.containsKey(pos)) {
        final valor = _nivelEnfrentamentoPesosDefesa[pos] ??
            (200.0 - (_nivelEnfrentamentoPesosAtaque[pos] ?? 100.0));
        _nivelEnfrentamentoCtrlsDefesa[pos] = TextEditingController(text: valor.toStringAsFixed(0));
      } else if (_nivelEnfrentamentoCtrlsDefesa[pos]!.text.isEmpty) {
        final valor = _nivelEnfrentamentoPesosDefesa[pos] ??
            (200.0 - (_nivelEnfrentamentoPesosAtaque[pos] ?? 100.0));
        _nivelEnfrentamentoCtrlsDefesa[pos]!.text = valor.toStringAsFixed(0);
      }
    }
  }

  List<Widget> _buildLinhasNivelEnfrentamento({
    required int totalTimes,
    required Map<int, TextEditingController> controllers,
    required Map<int, String> nomesTimes,
    required bool defesa,
  }) {
    return List.generate(totalTimes, (index) {
      final pos = index + 1;
      final time = nomesTimes[pos] ?? '';
      final ctrl = controllers[pos]!;
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 4.0),
        child: Row(
          children: [
            Expanded(
              flex: 2,
              child: Text("Posição $pos", style: const TextStyle(fontWeight: FontWeight.bold)),
            ),
            Expanded(
              flex: 4,
              child: Text(time.isEmpty ? "-" : time, overflow: TextOverflow.ellipsis),
            ),
            const SizedBox(width: 8),
            Expanded(
              flex: 3,
              child: TextField(
                controller: ctrl,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(
                  labelText: "% Peso",
                  border: OutlineInputBorder(),
                  isDense: true,
                  suffixText: "%",
                ),
                onChanged: (v) => _atualizarPesoNivelEnfrentamento(posicao: pos, valor: v, defesa: defesa),
              ),
            ),
          ],
        ),
      );
    });
  }

  void _abrirAjusteNivelEnfrentamento({
    required int totalTimes,
    required Map<int, String> nomesTimes,
  }) {
    _sincronizarControllersNivelEnfrentamento(totalTimes);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) {
        return DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.85,
          minChildSize: 0.5,
          maxChildSize: 0.95,
          builder: (context, scrollController) {
            return Material(
              child: ListView(
                controller: scrollController,
                padding: const EdgeInsets.all(16),
                children: [
                  const Text("⚙️ Ajuste por posição", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 8),
                  const Text("Esses percentuais são padrão e aplicam-se a qualquer campeonato."),
                  const SizedBox(height: 16),
                  const Text("Criação (Gols & xG)", style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  ..._buildLinhasNivelEnfrentamento(
                    totalTimes: totalTimes,
                    controllers: _nivelEnfrentamentoCtrlsAtaque,
                    nomesTimes: nomesTimes,
                    defesa: false,
                  ),
                  const Divider(height: 24),
                  const Text("Concedidos (Gols Sofridos)", style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  ..._buildLinhasNivelEnfrentamento(
                    totalTimes: totalTimes,
                    controllers: _nivelEnfrentamentoCtrlsDefesa,
                    nomesTimes: nomesTimes,
                    defesa: true,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    "Dica: use pesos mais altos contra adversários fortes para ataque e mais altos contra adversários fracos para fragilidade.",
                    style: TextStyle(color: Colors.grey, fontSize: 12),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildResumoNivelEnfrentamento() {
    final mandante = _nivelEnfrentamentoResumo['mandante'] ?? {};
    final visitante = _nivelEnfrentamentoResumo['visitante'] ?? {};
    final totalMandante = mandante.values.fold<double>(0.0, (sum, v) => sum + v);
    final totalVisitante = visitante.values.fold<double>(0.0, (sum, v) => sum + v);
    if (totalMandante == 0 && totalVisitante == 0) {
      return const Text("Sem dados suficientes para calcular os pesos.", style: TextStyle(color: Colors.grey));
    }
    String linha(String label, Map<String, double> dados) {
      final gmRaw = dados['gmRaw'] ?? 0;
      final gmAdj = dados['gmAdj'] ?? 0;
      final xgRaw = dados['xgRaw'] ?? 0;
      final xgAdj = dados['xgAdj'] ?? 0;
      final gsRaw = dados['gsRaw'] ?? 0;
      final gsAdj = dados['gsAdj'] ?? 0;
      final gmTxt = _nivelEnfrentamentoAtivo ? "${gmRaw.toStringAsFixed(1)} → ${gmAdj.toStringAsFixed(1)}" : gmRaw.toStringAsFixed(1);
      final xgTxt = _nivelEnfrentamentoAtivo ? "${xgRaw.toStringAsFixed(1)} → ${xgAdj.toStringAsFixed(1)}" : xgRaw.toStringAsFixed(1);
      final gsTxt = _nivelEnfrentamentoAtivo ? "${gsRaw.toStringAsFixed(1)} → ${gsAdj.toStringAsFixed(1)}" : gsRaw.toStringAsFixed(1);
      return "$label • GM $gmTxt | xG $xgTxt | GS $gsTxt";
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(linha("Mandante", mandante), style: const TextStyle(fontSize: 12)),
        const SizedBox(height: 4),
        Text(linha("Visitante", visitante), style: const TextStyle(fontSize: 12)),
      ],
    );
  }

  void _tentaPreencherDadosComScout() {
    final liga = _poissonCampeonatoCtrl.text.trim();
    final mandante = _poissonMandanteCtrl.text.trim();
    final visitante = _poissonVisitanteCtrl.text.trim();

    if (liga.isEmpty || mandante.isEmpty || visitante.isEmpty) return;

    final jogosLiga = _scoutPartidas.where((p) => p['campeonato'] == liga).toList();
    if (jogosLiga.isNotEmpty) {
      double totalGolsLiga = 0;
      for (var p in jogosLiga) {
        totalGolsLiga += ((p['gm_casa'] as num) + (p['gm_fora'] as num)).toDouble();
      }
      final mediaLiga = totalGolsLiga / jogosLiga.length;
      if (_poissonMediaLigaCtrl.text.isEmpty || _poissonMediaLigaCtrl.text == "2.40") {
        _poissonMediaLigaCtrl.text = mediaLiga.toStringAsFixed(2);
      }
    }

    int contagemZero = 0;
    int contagemCaos = 0;
    final posicoesLiga = _mapaPosicoesLiga(liga);

    int nCasa = int.tryParse(_poissonJogosMandanteCtrl.text) ?? 8;
    var jogosMandante = jogosLiga.where((p) => p['mandante'] == mandante).toList();
    if (jogosMandante.length > nCasa) jogosMandante = jogosMandante.sublist(0, nCasa);

    if (jogosMandante.isNotEmpty) {
      double sGM = 0, sXG = 0, sGS = 0;
      double sGMRaw = 0, sXGRaw = 0, sGSRaw = 0;
      for (var p in jogosMandante) {
        double gm = (p['gm_casa'] as num).toDouble();
        double gs = (p['gm_fora'] as num).toDouble();
        final xg = (p['xg_casa'] as num).toDouble();
        final adversario = p['visitante']?.toString();
        final posicao = posicoesLiga[adversario];
        final pesoAtk = _pesoNivelEnfrentamentoAtaque(posicao);
        final pesoDef = _pesoNivelEnfrentamentoDefesa(posicao);

        sGMRaw += gm;
        sXGRaw += xg;
        sGSRaw += gs;

        sGM += gm * pesoAtk;
        sXG += xg * pesoAtk;
        sGS += gs * pesoDef;

        double totalGolsJogo = gm + gs;
        if (totalGolsJogo == 0) contagemZero++;
        if (totalGolsJogo >= 6) contagemCaos++;
      }
      final gmConsiderado = _nivelEnfrentamentoAtivo ? sGM : sGMRaw;
      final xgConsiderado = _nivelEnfrentamentoAtivo ? sXG : sXGRaw;
      final gsConsiderado = _nivelEnfrentamentoAtivo ? sGS : sGSRaw;
      _poissonGMMandanteCtrl.text = _nivelEnfrentamentoAtivo ? gmConsiderado.toStringAsFixed(2) : gmConsiderado.toInt().toString();
      _poissonXGMandanteCtrl.text = xgConsiderado.toStringAsFixed(2);
      _poissonGSMandanteCtrl.text = _nivelEnfrentamentoAtivo ? gsConsiderado.toStringAsFixed(2) : gsConsiderado.toInt().toString();
      _nivelEnfrentamentoResumo['mandante'] = {
        'gmRaw': sGMRaw,
        'gmAdj': sGM,
        'xgRaw': sXGRaw,
        'xgAdj': sXG,
        'gsRaw': sGSRaw,
        'gsAdj': sGS,
      };
    } else {
      _nivelEnfrentamentoResumo['mandante'] = {
        'gmRaw': 0.0,
        'gmAdj': 0.0,
        'xgRaw': 0.0,
        'xgAdj': 0.0,
        'gsRaw': 0.0,
        'gsAdj': 0.0,
      };
    }

    int nFora = int.tryParse(_poissonJogosVisitanteCtrl.text) ?? 8;
    var jogosVisitante = jogosLiga.where((p) => p['visitante'] == visitante).toList();
    if (jogosVisitante.length > nFora) jogosVisitante = jogosVisitante.sublist(0, nFora);

    if (jogosVisitante.isNotEmpty) {
      double sGM = 0, sXG = 0, sGS = 0;
      double sGMRaw = 0, sXGRaw = 0, sGSRaw = 0;
      for (var p in jogosVisitante) {
        double gm = (p['gm_fora'] as num).toDouble();
        double gs = (p['gm_casa'] as num).toDouble();
        final xg = (p['xg_fora'] as num).toDouble();
        final adversario = p['mandante']?.toString();
        final posicao = posicoesLiga[adversario];
        final pesoAtk = _pesoNivelEnfrentamentoAtaque(posicao);
        final pesoDef = _pesoNivelEnfrentamentoDefesa(posicao);

        sGMRaw += gm;
        sXGRaw += xg;
        sGSRaw += gs;

        sGM += gm * pesoAtk;
        sXG += xg * pesoAtk;
        sGS += gs * pesoDef;

        double totalGolsJogo = gm + gs;
        if (totalGolsJogo == 0) contagemZero++;
        if (totalGolsJogo >= 6) contagemCaos++;
      }
      final gmConsiderado = _nivelEnfrentamentoAtivo ? sGM : sGMRaw;
      final xgConsiderado = _nivelEnfrentamentoAtivo ? sXG : sXGRaw;
      final gsConsiderado = _nivelEnfrentamentoAtivo ? sGS : sGSRaw;
      _poissonGMVisitanteCtrl.text = _nivelEnfrentamentoAtivo ? gmConsiderado.toStringAsFixed(2) : gmConsiderado.toInt().toString();
      _poissonXGVisitanteCtrl.text = xgConsiderado.toStringAsFixed(2);
      _poissonGSVisitanteCtrl.text = _nivelEnfrentamentoAtivo ? gsConsiderado.toStringAsFixed(2) : gsConsiderado.toInt().toString();
      _nivelEnfrentamentoResumo['visitante'] = {
        'gmRaw': sGMRaw,
        'gmAdj': sGM,
        'xgRaw': sXGRaw,
        'xgAdj': sXG,
        'gsRaw': sGSRaw,
        'gsAdj': sGS,
      };
    } else {
      _nivelEnfrentamentoResumo['visitante'] = {
        'gmRaw': 0.0,
        'gmAdj': 0.0,
        'xgRaw': 0.0,
        'xgAdj': 0.0,
        'gsRaw': 0.0,
        'gsAdj': 0.0,
      };
    }

    final ajusteZeroPassos = contagemZero ~/ 2;
    final ajusteCaosPassos = contagemCaos ~/ 2;
    double novoAjusteZero = (ajusteZeroPassos * 0.05).clamp(0.0, 0.30);
    double novoAjusteCaos = (ajusteCaosPassos * 0.05).clamp(0.0, 0.30);

    _poissonAjusteZero = novoAjusteZero;
    _poissonAjusteElasticidade = novoAjusteCaos;

    setState(() {});

    if (contagemZero > 0 || contagemCaos > 0) {
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("Ajuste automático: ${contagemZero}x 0-0 detectados | ${contagemCaos}x Goleadas detectadas"),
        duration: const Duration(seconds: 5),
        backgroundColor: Colors.indigo,
      ));
    }
  }

  // ================== GERENCIAMENTO DE ARQUIVOS ==================
  Future<File> _getApostasFile() async {
    final dir = await getApplicationDocumentsDirectory();
    return File("${dir.path}/apostas_data.json");
  }

  Future<File> _getRegrasFile() async {
    final dir = await getApplicationDocumentsDirectory();
    return File("${dir.path}/regras_apostas.json");
  }

  Future<File> _getDashboardFile() async {
    final dir = await getApplicationDocumentsDirectory();
    return File("${dir.path}/registros_apostas.json");
  }

  Future<File> _getConfiancaFile() async {
    final dir = await getApplicationDocumentsDirectory();
    return File("${dir.path}/confianca_data.json");
  }

  Future<File> _getPoissonCardsFile() async {
    final dir = await getApplicationDocumentsDirectory();
    return File("${dir.path}/poisson_cards.json");
  }

  Future<File> _getRascunhoConfiancaFile() async {
    final dir = await getApplicationDocumentsDirectory();
    return File("${dir.path}/confianca_rascunho.json");
  }

  // NOVO: Helper para carregar o arquivo de estatísticas globais
  Future<File> _getEstatisticasFile() async {
    final dir = await getApplicationDocumentsDirectory();
    return File("${dir.path}/estatisticas_globais.json");
  }

  Future<Map<String, dynamic>> _carregarEstatisticasGlobais() async {
    try {
      final file = await _getEstatisticasFile();
      if (await file.exists()) {
        final content = await file.readAsString();
        return jsonDecode(content) as Map<String, dynamic>;
      }
    } catch (e) {
      debugPrint("Erro ao carregar estatísticas globais: $e");
    }
    return {};
  }

  Future<Map<String, dynamic>> _carregarDadosDiarioIA() async {
    try {
      final dir = await getApplicationDocumentsDirectory();
      final file = File("${dir.path}/informacoes_para_IA.json");
      if (await file.exists()) {
        final content = await file.readAsString();
        if (content.isNotEmpty) {
          return jsonDecode(content) as Map<String, dynamic>;
        }
      }
    } catch (e) {
      debugPrint("Erro ao carregar dados do diário IA: $e");
    }
    return {};
  }

  // ================== LÓGICA DE CARDS POISSON ==================
  Future<void> _carregarCardsPoisson() async {
    try {
      final file = await _getPoissonCardsFile();
      if (await file.exists()) {
        final data = await file.readAsString();
        if (data.isNotEmpty) {
          setState(() {
            _listaCardsPoisson = (jsonDecode(data) as List).cast<Map<String, dynamic>>();
            _listaCardsPoisson.sort((a, b) => (b['data'] ?? '').compareTo(a['data'] ?? ''));
          });
        }
      }
    } catch (e) {
      debugPrint("Erro ao carregar cards poisson: $e");
    }
  }

  Future<void> _persistirCardsPoisson() async {
    try {
      final file = await _getPoissonCardsFile();
      await file.writeAsString(jsonEncode(_listaCardsPoisson));
    } catch (e) {
      debugPrint("Erro ao salvar cards poisson: $e");
    }
  }

  Future<void> _salvarCardPoisson() async {
    if (_resultadoPoisson == null) return;

    final novoCard = {
      'id': _idPoissonEmEdicao ?? DateTime.now().millisecondsSinceEpoch.toString(),
      'data': DateTime.now().toIso8601String(),
      'tipo': 'poisson_pro',
      'campeonato': _poissonCampeonatoCtrl.text,
      'mandante': _poissonMandanteCtrl.text,
      'visitante': _poissonVisitanteCtrl.text,
      'inputs': {
        'mediaLiga': _poissonMediaLigaCtrl.text,
        'jogosMandante': _poissonJogosMandanteCtrl.text,
        'jogosVisitante': _poissonJogosVisitanteCtrl.text,
        'gmMandante': _poissonGMMandanteCtrl.text,
        'xgMandante': _poissonXGMandanteCtrl.text,
        'gsMandante': _poissonGSMandanteCtrl.text,
        'gmVisitante': _poissonGMVisitanteCtrl.text,
        'xgVisitante': _poissonXGVisitanteCtrl.text,
        'gsVisitante': _poissonGSVisitanteCtrl.text,
        'oddCasa': _poissonOddCasaCtrl.text,
        'oddEmpate': _poissonOddEmpateCtrl.text,
        'oddFora': _poissonOddForaCtrl.text,
      },
      'ajustes': {
        'fatorCasa': _poissonFatorCasa,
        'fatorLiga': _poissonFatorLiga,
        'suavizacao': _poissonSuavizacao,
        'ajusteZero': _poissonAjusteZero,
        'ajusteElasticidade': _poissonAjusteElasticidade,
        'pesoEficacia': _poissonPesoEficacia,
      },
      'resultados': _resultadoPoisson,
      'linkedBetId': null,
    };

    setState(() {
      if (_idPoissonEmEdicao != null) {
        final index = _listaCardsPoisson.indexWhere((c) => c['id'] == _idPoissonEmEdicao);
        if (index != -1) {
          novoCard['linkedBetId'] = _listaCardsPoisson[index]['linkedBetId'];
          _listaCardsPoisson[index] = novoCard;
        }
        _idPoissonEmEdicao = null;
      } else {
        _listaCardsPoisson.insert(0, novoCard);
      }
    });

    await _persistirCardsPoisson();
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Card Poisson salvo!"), backgroundColor: Colors.green));
  }

  void _excluirCardPoisson(String id) async {
    setState(() {
      _listaCardsPoisson.removeWhere((c) => c['id'] == id);
      if (_idPoissonEmEdicao == id) {
        _idPoissonEmEdicao = null;
        _limparFormularioPoisson();
      }
    });
    await _persistirCardsPoisson();
  }

  void _editarCardPoisson(Map<String, dynamic> card) {
    final inputs = card['inputs'] as Map<String, dynamic>;
    final ajustes = card['ajustes'] as Map<String, dynamic>;

    setState(() {
      _idPoissonEmEdicao = card['id'];

      _poissonCampeonatoCtrl.text = card['campeonato'] ?? '';
      _poissonMandanteCtrl.text = card['mandante'] ?? '';
      _poissonVisitanteCtrl.text = card['visitante'] ?? '';

      _poissonMediaLigaCtrl.text = inputs['mediaLiga'] ?? '2.4';
      _poissonJogosMandanteCtrl.text = inputs['jogosMandante'] ?? '8';
      _poissonJogosVisitanteCtrl.text = inputs['jogosVisitante'] ?? '8';

      _poissonGMMandanteCtrl.text = inputs['gmMandante'] ?? '';
      _poissonXGMandanteCtrl.text = inputs['xgMandante'] ?? '';
      _poissonGSMandanteCtrl.text = inputs['gsMandante'] ?? '';

      _poissonGMVisitanteCtrl.text = inputs['gmVisitante'] ?? '';
      _poissonXGVisitanteCtrl.text = inputs['xgVisitante'] ?? '';
      _poissonGSVisitanteCtrl.text = inputs['gsVisitante'] ?? '';

      _poissonOddCasaCtrl.text = inputs['oddCasa'] ?? '';
      _poissonOddEmpateCtrl.text = inputs['oddEmpate'] ?? '';
      _poissonOddForaCtrl.text = inputs['oddFora'] ?? '';

      _poissonFatorCasa = (ajustes['fatorCasa'] as num?)?.toDouble() ?? 0.0;
      _poissonFatorLiga = (ajustes['fatorLiga'] as num?)?.toDouble() ?? 1.00;
      _poissonSuavizacao = (ajustes['suavizacao'] as num?)?.toDouble() ?? 0.75;
      _poissonAjusteZero = (ajustes['ajusteZero'] as num?)?.toDouble() ?? 0.0;
      _poissonAjusteElasticidade = (ajustes['ajusteElasticidade'] as num?)?.toDouble() ?? 0.0;
      _poissonPesoEficacia = (ajustes['pesoEficacia'] as num?)?.toDouble() ?? 0.50;
    });

    _onCalcularPoisson();
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Dados carregados para edição. Ajuste e salve.")));
  }

  // NOVO: Função para limpar completamente o formulário Poisson (Reset)
  void _limparFormularioPoissonCompleto() {
    setState(() {
      // Zera identificadores
      _poissonCampeonatoCtrl.clear();
      _poissonMandanteCtrl.clear();
      _poissonVisitanteCtrl.clear();

      // Reseta parâmetros para o padrão inicial
      _poissonMediaLigaCtrl.text = "2.40";
      _poissonJogosMandanteCtrl.text = "8";
      _poissonJogosVisitanteCtrl.text = "8";

      // Zera stats
      _poissonGMMandanteCtrl.clear();
      _poissonXGMandanteCtrl.clear();
      _poissonGSMandanteCtrl.clear();
      _poissonGMVisitanteCtrl.clear();
      _poissonXGVisitanteCtrl.clear();
      _poissonGSVisitanteCtrl.clear();

      // Zera odds
      _poissonOddCasaCtrl.clear();
      _poissonOddEmpateCtrl.clear();
      _poissonOddForaCtrl.clear();

      // Reseta sliders para os valores default
      _poissonFatorCasa = 0.0;
      _poissonFatorLiga = 1.00;
      _poissonSuavizacao = 0.75;
      _poissonAjusteZero = 0.0;
      _poissonAjusteElasticidade = 0.0;
      _poissonPesoEficacia = 0.50;

      // Limpa estado de cálculo e edição
      _resultadoPoisson = null;
      _idPoissonEmEdicao = null;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Todos os campos foram limpos."), duration: Duration(seconds: 1)),
    );
  }

  void _limparFormularioPoisson() {
    setState(() {
      _idPoissonEmEdicao = null;
      _resultadoPoisson = null;
    });
  }

  // ================== LÓGICA DE RASCUNHO E EDIÇÃO (CONFIANÇA) ==================
  void _agendarSalvamentoRascunho() {
    if (_debounceRascunho?.isActive ?? false) _debounceRascunho!.cancel();
    _debounceRascunho = Timer(const Duration(milliseconds: 1000), _salvarRascunhoConfianca);
  }

  Future<void> _salvarRascunhoConfianca() async {
    try {
      final rascunho = {
        'titulo': _confiancaTituloCtrl.text,
        'respostas': _respostasConfiancaBool,
        'anuladas': _perguntasAnuladasBool,
        'observacoes': _obsConfiancaCtrl.map((c) => c.text).toList(),
        'idEmEdicao': _idCardEmEdicao,
      };
      final file = await _getRascunhoConfiancaFile();
      await file.writeAsString(jsonEncode(rascunho));
    } catch (e) {
      debugPrint("Erro ao salvar rascunho: $e");
    }
  }

  Future<void> _carregarRascunhoConfianca() async {
    try {
      final file = await _getRascunhoConfiancaFile();
      if (await file.exists()) {
        final data = await file.readAsString();
        if (data.isNotEmpty) {
          final json = jsonDecode(data);
          setState(() {
            _confiancaTituloCtrl.text = json['titulo'] ?? '';
            if (json['respostas'] != null) {
              _respostasConfiancaBool = List<bool>.from(json['respostas']);
            }
            if (json['anuladas'] != null) {
              _perguntasAnuladasBool = List<bool>.from(json['anuladas']);
            }
            if (json['observacoes'] != null) {
              final obsList = List<String>.from(json['observacoes']);
              for (int i = 0; i < _obsConfiancaCtrl.length; i++) {
                if (i < obsList.length) _obsConfiancaCtrl[i].text = obsList[i];
              }
            }
            _idCardEmEdicao = json['idEmEdicao'];
          });
        }
      }
    } catch (e) {
      debugPrint("Erro ao carregar rascunho: $e");
    }
  }

  Future<void> _limparRascunhoConfianca() async {
    try {
      final file = await _getRascunhoConfiancaFile();
      if (await file.exists()) await file.delete();
    } catch (e) {
      debugPrint("Erro ao limpar rascunho: $e");
    }
  }

  void _limparFormularioConfianca() {
    setState(() {
      _confiancaTituloCtrl.clear();
      _respostasConfiancaBool = List.filled(6, false);
      _perguntasAnuladasBool = List.filled(6, false);
      for (var ctrl in _obsConfiancaCtrl) {
        ctrl.clear();
      }
      _idCardEmEdicao = null;
    });
    _limparRascunhoConfianca();
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Formulário limpo.")));
  }

  void _editarCardConfianca(Map<String, dynamic> card) {
    setState(() {
      _idCardEmEdicao = card['id'];
      _confiancaTituloCtrl.text = card['titulo'] ?? '';
      _respostasConfiancaBool = List<bool>.from(card['respostas'] ?? List.filled(6, false));
      _perguntasAnuladasBool = List<bool>.from(card['anuladas'] ?? List.filled(6, false));

      final obs = List<String>.from(card['observacoes'] ?? []);
      for (int i = 0; i < _obsConfiancaCtrl.length; i++) {
        if (i < obs.length) {
          _obsConfiancaCtrl[i].text = obs[i];
        } else {
          _obsConfiancaCtrl[i].clear();
        }
      }
    });
    _salvarRascunhoConfianca();
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Carregado para edição. Suba para alterar.")));
  }

  // ================== LOGICA DA ABA CONFIANÇA ==================
  Future<void> _carregarCardsConfianca() async {
    setState(() => _carregandoConfianca = true);
    try {
      final file = await _getConfiancaFile();
      if (await file.exists()) {
        final data = await file.readAsString();
        if (data.isNotEmpty) {
          final decoded = jsonDecode(data);
          if (decoded is List) {
            setState(() {
              _listaCardsConfianca = decoded.cast<Map<String, dynamic>>();
              _listaCardsConfianca.sort((a, b) => (b['data'] ?? '').compareTo(a['data'] ?? ''));
            });
          }
        }
      }
    } catch (e) {
      debugPrint("Erro ao carregar confiança: $e");
    } finally {
      setState(() => _carregandoConfianca = false);
    }
  }

  Future<void> _salvarCardConfianca() async {
    double pontosObtidos = 0.0;
    double pontosPossiveis = 0.0;
    final pesos = [2.0, 2.0, 1.0, 1.0, 2.0, 2.0];

    for (int i = 0; i < 6; i++) {
      if (!_perguntasAnuladasBool[i]) {
        pontosPossiveis += pesos[i];
        bool somaPontos = false;
        if (i == 5) {
          if (!_respostasConfiancaBool[i]) somaPontos = true;
        } else {
          if (_respostasConfiancaBool[i]) somaPontos = true;
        }
        if (somaPontos) {
          pontosObtidos += pesos[i];
        }
      }
    }

    double notaFinal = pontosPossiveis > 0 ? (pontosObtidos / pontosPossiveis) * 10.0 : 0.0;

    String titulo = _confiancaTituloCtrl.text.trim();
    if (titulo.isEmpty) {
      if (_timeCasaCtrl.text.isNotEmpty) {
        titulo = "${_timeCasaCtrl.text} x ${_timeForaCtrl.text}";
      } else if (_poissonMandanteCtrl.text.isNotEmpty) {
        titulo = "${_poissonMandanteCtrl.text} x ${_poissonVisitanteCtrl.text}";
      } else {
        titulo = "Análise Sem Nome";
      }
    }

    final cardData = {
      'id': _idCardEmEdicao ?? DateTime.now().millisecondsSinceEpoch.toString(),
      'data': DateTime.now().toIso8601String(),
      'titulo': titulo,
      'nota': notaFinal,
      'respostas': _respostasConfiancaBool,
      'anuladas': _perguntasAnuladasBool,
      'observacoes': _obsConfiancaCtrl.map((c) => c.text).toList(),
      'arquivado': false,
      'linkedBetId': null,
      'resultado': null,
    };

    setState(() {
      if (_idCardEmEdicao != null) {
        final index = _listaCardsConfianca.indexWhere((c) => c['id'] == _idCardEmEdicao);
        if (index != -1) {
          cardData['arquivado'] = _listaCardsConfianca[index]['arquivado'];
          cardData['resultado'] = _listaCardsConfianca[index]['resultado'];
          cardData['linkedBetId'] = _listaCardsConfianca[index]['linkedBetId'];
          _listaCardsConfianca[index] = cardData;
        }
      } else {
        _listaCardsConfianca.insert(0, cardData);
      }
      _limparFormularioConfianca();
    });

    await _persistirConfianca();
    ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_idCardEmEdicao != null ? "Análise atualizada!" : "Análise salva! Nota: ${notaFinal.toStringAsFixed(1)}/10"),
          backgroundColor: Colors.green,
        )
    );
  }

  Future<void> _excluirCardConfianca(String id) async {
    setState(() {
      _listaCardsConfianca.removeWhere((item) => item['id'] == id);
      if (_idCardEmEdicao == id) {
        _limparFormularioConfianca();
      }
    });
    await _persistirConfianca();
  }

  Future<void> _arquivarCardConfianca(String id) async {
    setState(() {
      final index = _listaCardsConfianca.indexWhere((item) => item['id'] == id);
      if (index != -1) {
        _listaCardsConfianca[index]['arquivado'] = true;
      }
    });
    await _persistirConfianca();
  }

  Future<void> _setarResultadoConfianca(String id, String resultado) async {
    setState(() {
      final index = _listaCardsConfianca.indexWhere((item) => item['id'] == id);
      if (index != -1) {
        _listaCardsConfianca[index]['resultado'] = resultado;
      }
    });
    await _persistirConfianca();
  }

  Future<void> _persistirConfianca() async {
    try {
      final file = await _getConfiancaFile();
      await file.writeAsString(jsonEncode(_listaCardsConfianca));
    } catch (e) {
      debugPrint("Erro ao salvar confiança: $e");
    }
  }

  Color _getCorNota(double nota) {
    if (nota >= 8) return Colors.green;
    if (nota >= 5) return Colors.orange;
    return Colors.red;
  }

  // ================== CARREGAR DADOS GERAIS ==================
  Future<List<Map<String, dynamic>>> _carregarApostas() async {
    try {
      final file = await _getApostasFile();
      if (await file.exists()) {
        final data = await file.readAsString();
        if (data.isNotEmpty) {
          final decoded = jsonDecode(data);
          final list = (decoded is Map && decoded["apostas"] is List)
              ? (decoded["apostas"] as List)
              : (decoded is List ? decoded : []);
          return list.cast<Map<String, dynamic>>();
        }
      }
    } catch (e) {
      debugPrint("Erro ao carregar apostas: $e");
    }
    return [];
  }

  Future<Map<String, dynamic>> _carregarConfig() async {
    try {
      final file = await _getApostasFile();
      if (await file.exists()) {
        final data = await file.readAsString();
        if (data.isNotEmpty) {
          final decoded = jsonDecode(data);
          final configData = decoded is Map ? decoded['config'] : null;
          if (configData != null && configData is Map) {
            return Map<String, dynamic>.from(configData);
          }
        }
      }
    } catch (e) {
      debugPrint("[_carregarConfig] ERRO ao carregar config: $e");
    }
    return {};
  }

  Future<Map<String, dynamic>> _carregarDadosDashboard() async {
    try {
      final file = await _getDashboardFile();
      if (await file.exists()) {
        final content = await file.readAsString();
        if (content.isNotEmpty) {
          final decoded = jsonDecode(content);
          if (decoded is List && decoded.isNotEmpty) {
            final last = decoded.last;
            if (last is Map) return last.cast<String, dynamic>();
          }
        }
      }
    } catch (e) {
      debugPrint("Erro ao carregar dados do dashboard: $e");
    }
    return {};
  }

  Future<void> _carregarDadosParaAutocomplete() async {
    final apostas = await _carregarApostas();
    if (apostas.isNotEmpty) {
      final times = <String>{};
      final tipos = <String>{};
      final campeonatos = <String>{};
      for (var aposta in apostas) {
        final timesNaAposta = (aposta['time'] as String?)?.split(RegExp(r'\s(x|vs)\s', caseSensitive: false)) ?? [];
        times.addAll(timesNaAposta.map((t) => t.trim()).where((t) => t.isNotEmpty));
        if ((aposta['tipo'] as String?)?.isNotEmpty == true) tipos.add((aposta['tipo'] ?? '').toString());
        if ((aposta['campeonato'] as String?)?.isNotEmpty == true) campeonatos.add((aposta['campeonato'] ?? '').toString());
      }
      setState(() {
        _timesUnicos = times.toList()..sort();
        _tiposUnicos = tipos.toList()..sort();
        _campeonatosUnicos = campeonatos.toList()..sort();
      });
    }
  }

  Future<void> _carregarRegras() async {
    try {
      final file = await _getRegrasFile();
      if (await file.exists()) {
        final data = await file.readAsString();
        if (data.isNotEmpty) {
          setState(() {
            final decoded = jsonDecode(data);
            if (decoded is List && decoded.isNotEmpty && decoded.first.containsKey('conjuntos')) {
              _regrasAposta = decoded.cast<Map<String, dynamic>>();
            } else if (decoded is List && decoded.isNotEmpty && decoded.first.containsKey('regras')) {
              _regrasAposta = [{
                'id': 'migrado',
                'titulo': 'Regras Migradas',
                'conjuntos': decoded,
                'isExpanded': true,
              }];
            } else {
              _regrasAposta = [];
            }
          });
        }
      }
    } catch (e) {
      debugPrint("Erro ao carregar regras: $e");
    }
  }

  // ================== ANÁLISE HISTÓRICO ==================
  Future<void> _analisarHistorico() async {
    setState(() => _carregando = true);
    final apostas = await _carregarApostas();
    if (apostas.isEmpty) {
      setState(() {
        _carregando = false;
        _analiseHistorico = {'erro': 'Nenhuma aposta no histórico'};
      });
      return;
    }

    final timeCasa = _timeCasaCtrl.text.trim();
    final timeFora = _timeForaCtrl.text.trim();
    final tipo = _tipoCtrl.text.trim();
    final campeonato = _campeonatoCtrl.text.trim();
    final oddString = _oddCtrl.text.trim().replaceAll(',', '.');

    if (timeCasa.isEmpty && timeFora.isEmpty && tipo.isEmpty && campeonato.isEmpty && oddString.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Preencha pelo menos um campo")));
      setState(() => _carregando = false);
      return;
    }

    final oddValue = double.tryParse(oddString);
    double? probabilidadeOdd = (oddValue != null && oddValue >= 1.0) ? (1 / oddValue) * 100 : null;

    final List<double> probabilidadesHistoricas = [];
    final Map<String, Map<String, dynamic>> detalhesHistorico = {};

    void addStat(String key, String value, Map<String, dynamic> Function(List<Map<String, dynamic>>, String) calculator) {
      if (value.isNotEmpty) {
        final estat = calculator(apostas, value);
        if (estat['total'] > 0) {
          probabilidadesHistoricas.add((estat['taxa'] as num).toDouble());
          detalhesHistorico[key] = estat;
        }
      }
    }

    addStat('Time Casa', timeCasa, _calcularEstatisticasTime);
    addStat('Time Fora', timeFora, _calcularEstatisticasTime);
    addStat('Tipo de Aposta', tipo, _calcularEstatisticasTipo);
    addStat('Campeonato', campeonato, _calcularEstatisticasCampeonato);

    if (oddValue != null) {
      final estat = _calcularEstatisticasPorFaixaDeOdd(apostas, oddValue);
      if (estat['total'] > 0) {
        probabilidadesHistoricas.add((estat['taxa'] as num).toDouble());
        detalhesHistorico['Faixa de Odd'] = estat;
      }
    }

    double probabilidadeHistoricoMedia = probabilidadesHistoricas.isNotEmpty ? probabilidadesHistoricas.reduce((a, b) => a + b) / probabilidadesHistoricas.length : 0;

    double probabilidadeFinal;
    if (probabilidadeOdd != null && probabilidadesHistoricas.isNotEmpty) {
      probabilidadeFinal = (probabilidadeHistoricoMedia * 0.5) + (probabilidadeOdd * 0.5);
    } else {
      probabilidadeFinal = probabilidadeOdd ?? probabilidadeHistoricoMedia;
    }

    setState(() {
      _analiseHistorico = {
        'probabilidadeOdd': probabilidadeOdd,
        'probabilidadeHistoricoMedia': probabilidadeHistoricoMedia,
        'probabilidadeFinal': probabilidadeFinal,
        'detalhesHistorico': detalhesHistorico,
      };
      _carregando = false;
    });
  }

  Map<String, dynamic> _calcularEstatisticasPorFaixaDeOdd(List<Map<String, dynamic>> apostas, double odd) {
    const double range = 0.05;
    final apostasNaFaixa = apostas.where((a) {
      final apostaOdd = num.tryParse(a['odd'].toString())?.toDouble();
      return apostaOdd != null && (apostaOdd >= odd - range && apostaOdd <= odd + range);
    }).toList();
    final total = apostasNaFaixa.length;
    final vitorias = apostasNaFaixa.where((a) => (a['lucro'] as num) > 0).length;
    return {'total': total, 'vitorias': vitorias, 'taxa': total > 0 ? (vitorias / total * 100) : 0.0};
  }

  Map<String, dynamic> _calcularEstatisticasTime(List<Map<String, dynamic>> apostas, String time) => _calcularEstatisticaGenerica(apostas, (a) => (a['time'] as String?)?.toLowerCase().contains(time.toLowerCase()) ?? false);
  Map<String, dynamic> _calcularEstatisticasTipo(List<Map<String, dynamic>> apostas, String tipo) => _calcularEstatisticaGenerica(apostas, (a) => (a['tipo'] as String?)?.toLowerCase().contains(tipo.toLowerCase()) ?? false);
  Map<String, dynamic> _calcularEstatisticasCampeonato(List<Map<String, dynamic>> apostas, String camp) => _calcularEstatisticaGenerica(apostas, (a) => (a['campeonato'] as String?)?.toLowerCase().contains(camp.toLowerCase()) ?? false);

  Map<String, dynamic> _calcularEstatisticaGenerica(List<Map<String, dynamic>> apostas, bool Function(Map<String, dynamic>) filtro) {
    final apostasFiltradas = apostas.where(filtro).toList();
    final total = apostasFiltradas.length;
    final vitorias = apostasFiltradas.where((a) => (a['lucro'] as num) > 0).length;
    return {'total': total, 'vitorias': vitorias, 'taxa': total > 0 ? (vitorias / total * 100) : 0.0};
  }

  // ================== AVALIAÇÃO COM GOOGLE GEMINI ==================
  Future<void> _copiarAnaliseIA() async {
    if (_analiseIAResultado != null && _analiseIAResultado!.isNotEmpty) {
      await Clipboard.setData(ClipboardData(text: _analiseIAResultado!));
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Copiado!"), backgroundColor: Colors.green));
    }
  }

  Future<void> _exportarApostasParaTXT() async {
    setState(() => _carregando = true);
    try {
      final apostas = await _carregarApostas();
      if (apostas.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Nenhuma aposta no histórico.")));
        setState(() => _carregando = false);
        return;
      }
      final StringBuffer sb = StringBuffer();
      sb.writeln("ID;Data;Tipo;Campeonato;Time;Odd;Stake;Lucro");
      for (var aposta in apostas) {
        sb.writeln("${aposta['id']};${aposta['data']};${aposta['tipo']};${aposta['campeonato']};${aposta['time']};${aposta['odd']};${aposta['stake']};${aposta['lucro']}");
      }
      final dir = await getApplicationDocumentsDirectory();
      final file = File("${dir.path}/export_apostas.txt");
      await file.writeAsString(sb.toString(), encoding: utf8);
      await OpenFilex.open(file.path);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Erro: $e")));
    } finally {
      setState(() => _carregando = false);
    }
  }

  // CORREÇÃO: Adicionado parâmetro opcional customQuery
  Future<void> _chamarGeminiAPI(String prompt) async {
    setState(() { _carregando = true; _analiseIAResultado = null; });

    const String model = "models/gemini-2.5-flash";
    final apiKey = _geminiApiKey;
    if (apiKey == null || apiKey.isEmpty) {
      _mostrarErroIA("API key não carregada. Verifique o arquivo assets/api_key.txt.");
      setState(() { _carregando = false; });
      return;
    }
    try {
      final url = Uri.parse("https://generativelanguage.googleapis.com/v1/$model:generateContent?key=$apiKey");
      final body = jsonEncode({"contents": [{"role": "user", "parts": [{"text": prompt}]}]});
      final response = await http.post(url, headers: {"Content-Type": "application/json"}, body: body);

      if (response.statusCode == 200) {
        final json = jsonDecode(utf8.decode(response.bodyBytes));
        final text = json["candidates"]?[0]?["content"]?["parts"]?[0]?["text"];
        setState(() => _analiseIAResultado = text ?? "Sem resposta.");
      } else {
        _mostrarErroIA(_formatarErroGemini(response));
      }
    } catch (e, stackTrace) {
      _mostrarErroIA("Erro: $e\n$stackTrace");
    }
    setState(() { _carregando = false; });
  }

  String _formatarErroGemini(http.Response response) {
    final status = response.statusCode;
    final reason = response.reasonPhrase;
    final bodyText = utf8.decode(response.bodyBytes);
    String? apiMessage;

    try {
      final decoded = jsonDecode(bodyText);
      apiMessage = decoded["error"]?["message"]?.toString();
    } catch (_) {}

    final buffer = StringBuffer("Erro $status");
    if (reason != null && reason.isNotEmpty) {
      buffer.write(" ($reason)");
    }
    if (apiMessage != null && apiMessage.isNotEmpty) {
      buffer.write("\nDetalhes: $apiMessage");
    } else if (bodyText.isNotEmpty) {
      buffer.write("\nResposta: $bodyText");
    }

    return buffer.toString().trim();
  }

  void _mostrarErroIA(String erro) {
    setState(() => _analiseIAResultado = erro);
  }

  // NOVO: Método Helper para Calcular Métricas Flat
  Map<String, dynamic> _calcularMetricasFlat(List<Map<String, dynamic>> apostas) {
    double flatProfit = 0.0;
    int resolvedBets = 0;

    for (var a in apostas) {
      final lucro = (a['lucro'] as num).toDouble();
      final odd = (a['odd'] as num).toDouble();

      if (lucro > 0) {
        flatProfit += (odd - 1.0);
        resolvedBets++;
      } else if (lucro < 0) {
        flatProfit -= 1.0;
        resolvedBets++;
      }
      // Void não conta
    }

    double flatROI = resolvedBets > 0 ? (flatProfit / resolvedBets) * 100 : 0.0;

    return {
      'flatProfit': flatProfit,
      'flatROI': flatROI,
      'totalBets': resolvedBets
    };
  }

  Map<String, dynamic> _calcularResumoApostasIA(List<Map<String, dynamic>> apostas) {
    final total = apostas.length;
    int wins = 0;
    int losses = 0;
    int voids = 0;
    double totalStake = 0.0;
    double totalLucro = 0.0;
    double somaOdds = 0.0;
    int oddsValidas = 0;

    for (final a in apostas) {
      final lucro = (a['lucro'] as num?)?.toDouble() ?? 0.0;
      final stake = (a['stake'] as num?)?.toDouble() ?? 0.0;
      final odd = num.tryParse(a['odd']?.toString() ?? '')?.toDouble();

      totalLucro += lucro;
      totalStake += stake;
      if (odd != null && odd > 0) {
        somaOdds += odd;
        oddsValidas++;
      }

      if (lucro > 0) {
        wins++;
      } else if (lucro < 0) {
        losses++;
      } else {
        voids++;
      }
    }

    final double yieldPct = totalStake > 0 ? (totalLucro / totalStake) * 100 : 0.0;
    final double avgStake = total > 0 ? totalStake / total : 0.0;
    final double avgOdd = oddsValidas > 0 ? somaOdds / oddsValidas : 0.0;
    final double avgLucro = total > 0 ? totalLucro / total : 0.0;
    final double winRate = total > 0 ? (wins / total) * 100 : 0.0;


        .fold(0.0, (s, a) => s + ((a['lucro'] as num).abs()).toDouble());
    final double profitFactor = grossLoss == 0 ? (grossProfit > 0 ? 999.0 : 0.0) : (grossProfit / grossLoss);

    int maxWinStreak = 0;
    int maxLoseStreak = 0;
    int currentW = 0;
    int currentL = 0;
    final sortedApostas = List<Map<String, dynamic>>.from(apostas)
      ..sort((a, b) => (a['data'] ?? '').compareTo(b['data'] ?? ''));
    for (final a in sortedApostas) {
      final l = (a['lucro'] as num?)?.toDouble() ?? 0.0;
      if (l > 0) {
        currentW++;
        currentL = 0;
        if (currentW > maxWinStreak) maxWinStreak = currentW;
      } else if (l < 0) {
        currentL++;
        currentW = 0;
        if (currentL > maxLoseStreak) maxLoseStreak = currentL;
      }
    }

    return {
      'totalApostas': total,
      'wins': wins,
      'losses': losses,
      'voids': voids,
      'winRate': winRate,
      'totalStake': totalStake,
      'totalLucro': totalLucro,
      'yieldPct': yieldPct,
      'avgStake': avgStake,
      'avgOdd': avgOdd,
      'avgLucro': avgLucro,
      'profitFactor': profitFactor >= 999 ? 'Infinito' : profitFactor.toStringAsFixed(2),
      'maxWinStreak': maxWinStreak,
      'maxLoseStreak': maxLoseStreak,
    };
  }

  Map<String, dynamic> _avaliarQualidadeDadosIA(List<Map<String, dynamic>> apostas) {
    final total = apostas.length;
    int semData = 0;
    int semOdd = 0;
    int semStake = 0;
    int semLucro = 0;
    int semTime = 0;
    int semTipo = 0;
    int semCampeonato = 0;
    int semNivelConfianca = 0;
    int semEV = 0;

    for (final a in apostas) {
      if ((a['data']?.toString() ?? '').isEmpty) semData++;
      if (num.tryParse(a['odd']?.toString() ?? '') == null) semOdd++;
      if (num.tryParse(a['stake']?.toString() ?? '') == null) semStake++;
      if (num.tryParse(a['lucro']?.toString() ?? '') == null) semLucro++;
      if ((a['time']?.toString() ?? '').isEmpty) semTime++;
      if ((a['tipo']?.toString() ?? '').isEmpty) semTipo++;
      if ((a['campeonato']?.toString() ?? '').isEmpty) semCampeonato++;
      if (a['nivelConfianca'] == null) semNivelConfianca++;
      if (a['evPositivo'] == null) semEV++;
    }

    double pct(int count) => total > 0 ? (count / total) * 100 : 0.0;

    return {
      'totalApostas': total,
      'camposAusentes': {
        'data': {'count': semData, 'pct': pct(semData)},
        'odd': {'count': semOdd, 'pct': pct(semOdd)},
        'stake': {'count': semStake, 'pct': pct(semStake)},
        'lucro': {'count': semLucro, 'pct': pct(semLucro)},
        'time': {'count': semTime, 'pct': pct(semTime)},
        'tipo': {'count': semTipo, 'pct': pct(semTipo)},
        'campeonato': {'count': semCampeonato, 'pct': pct(semCampeonato)},
        'nivelConfianca': {'count': semNivelConfianca, 'pct': pct(semNivelConfianca)},
        'evPositivo': {'count': semEV, 'pct': pct(semEV)},
      }
    };
  }

  Map<String, dynamic> _resumirSegmentosIA(List<Map<String, dynamic>> apostas, String campo, {int minApostas = 5}) {
    final Map<String, Map<String, dynamic>> stats = {};

    for (final a in apostas) {
      dynamic raw = a[campo];
      if (raw == null) continue;
      if (raw is bool) raw = raw ? "Sim" : "Não";
      final key = raw.toString().trim();
      if (key.isEmpty) continue;

      stats.putIfAbsent(key, () => {
        'total': 0,
        'wins': 0,
        'lucro': 0.0,
        'stake': 0.0,
      });

      final entry = stats[key]!;
      entry['total'] = (entry['total'] as int) + 1;
      final lucro = (a['lucro'] as num?)?.toDouble() ?? 0.0;
      final stake = (a['stake'] as num?)?.toDouble() ?? 0.0;
      entry['lucro'] = (entry['lucro'] as double) + lucro;
      entry['stake'] = (entry['stake'] as double) + stake;
      if (lucro > 0) entry['wins'] = (entry['wins'] as int) + 1;
    }

    List<Map<String, dynamic>> normalizar(List<MapEntry<String, Map<String, dynamic>>> entries) {
      return entries.map((e) {
        final total = e.value['total'] as int;
        final wins = e.value['wins'] as int;
        final lucro = e.value['lucro'] as double;
        final stake = e.value['stake'] as double;
        final winRate = total > 0 ? (wins / total) * 100 : 0.0;
        final roi = stake > 0 ? (lucro / stake) * 100 : 0.0;
        return {
          'chave': e.key,
          'total': total,
          'wins': wins,
          'winRate': winRate,
          'lucro': lucro,
          'roi': roi,
        };
      }).toList();
    }

    final filtrado = stats.entries.where((e) => (e.value['total'] as int) >= minApostas).toList();
    filtrado.sort((a, b) {
      final roiA = (a.value['stake'] as double) > 0 ? (a.value['lucro'] as double) / (a.value['stake'] as double) : 0.0;
      final roiB = (b.value['stake'] as double) > 0 ? (b.value['lucro'] as double) / (b.value['stake'] as double) : 0.0;
      return roiB.compareTo(roiA);
    });

    final top = filtrado.take(3).toList();
    final bottom = filtrado.reversed.take(3).toList();

    return {
      'minApostas': minApostas,
      'totalSegmentos': stats.length,
      'top': normalizar(top),
      'bottom': normalizar(bottom),
    };
  }

  Map<String, dynamic> _resumirJanelaTemporalIA(List<Map<String, dynamic>> apostas, int dias) {
    final limite = DateTime.now().subtract(Duration(days: dias));
    final filtradas = apostas.where((a) {
      final dataStr = a['data']?.toString() ?? '';
      final data = DateTime.tryParse(dataStr);
      return data != null && !data.isBefore(limite);
    }).toList();

    final resumo = _calcularResumoApostasIA(filtradas);
    resumo['dias'] = dias;
    resumo['totalApostas'] = filtradas.length;
    return resumo;
  }

  List<Map<String, dynamic>> _formatarHistoricoRecenteIA(List<Map<String, dynamic>> apostas, int limite) {
    final ordenadas = List<Map<String, dynamic>>.from(apostas)
      ..sort((a, b) => (b['data'] ?? '').compareTo(a['data'] ?? ''));
    return ordenadas.take(limite).map((a) {
      return {
        'data': a['data'],
        'time': a['time'],
        'tipo': a['tipo'],
        'campeonato': a['campeonato'],
        'odd': a['odd'],
        'stake': a['stake'],
        'lucro': a['lucro'],
        'nivelConfianca': a['nivelConfianca'],
        'evPositivo': a['evPositivo'],
        'margem': a['margem'],
        'comentarios': a['comentarios'],
      };
    }).toList();
  }

  Future<Map<String, dynamic>> _carregarResumoConfiancaIA() async {
    try {
      final file = await _getConfiancaFile();
      if (await file.exists()) {
        final content = await file.readAsString();
        if (content.isNotEmpty) {
          final decoded = jsonDecode(content);
          if (decoded is List) {
            final list = decoded.cast<Map<String, dynamic>>();
            final total = list.length;
            double somaNotas = 0.0;
            int notasAltas = 0;
            for (final item in list) {
              final nota = (item['nota'] as num?)?.toDouble() ?? 0.0;
              somaNotas += nota;
              if (nota >= 8) notasAltas++;
            }
            final media = total > 0 ? somaNotas / total : 0.0;
            final ultimos = list..sort((a, b) => (b['data'] ?? '').compareTo(a['data'] ?? ''));
            final ultimos10 = ultimos.take(10).map((e) {
              return {
                'data': e['data'],
                'titulo': e['titulo'],
                'nota': e['nota'],
                'resultado': e['resultado'],
                'arquivado': e['arquivado'],
              };
            }).toList();

            return {
              'totalCards': total,
              'mediaNota': media,
              'pctNotasAltas': total > 0 ? (notasAltas / total) * 100 : 0.0,
              'ultimosCards': ultimos10,
            };
          }
        }
      }
    } catch (e) {
      debugPrint("Erro ao resumir confiança IA: $e");
    }
    return {};
  }

  Future<Map<String, dynamic>> _carregarResumoPoissonIA() async {
    try {
      final file = await _getPoissonCardsFile();
      if (await file.exists()) {
        final content = await file.readAsString();
        if (content.isNotEmpty) {
          final decoded = jsonDecode(content);
          if (decoded is List) {
            final list = decoded.cast<Map<String, dynamic>>();
            final total = list.length;
            final ordenadas = list..sort((a, b) => (b['data'] ?? '').compareTo(a['data'] ?? ''));
            final ultimos5 = ordenadas.take(5).map((e) {
              return {
                'data': e['data'],
                'campeonato': e['campeonato'],
                'mandante': e['mandante'],
                'visitante': e['visitante'],
                'resultados': e['resultados'],
                'linkedBetId': e['linkedBetId'],
              };
            }).toList();
            return {
              'totalCards': total,
              'ultimosCards': ultimos5,
            };
          }
        }
      }
    } catch (e) {
      debugPrint("Erro ao resumir Poisson IA: $e");
    }
    return {};
  }

  Map<String, dynamic> _resumirScoutIA() {
    final totalPartidas = _scoutPartidas.length;
    final totalLigas = _scoutLigas.length;
    final ultimasPartidas = _scoutPartidas.take(5).map((p) {
      return {
        'data': p['data'],
        'campeonato': p['campeonato'],
        'mandante': p['mandante'],
        'visitante': p['visitante'],
        'placar': p['placar'],
      };
    }).toList();
    return {
      'totalPartidas': totalPartidas,
      'totalLigas': totalLigas,
      'ultimasPartidas': ultimasPartidas,
    };
  }

  String _montarPromptAnaliseAposta({
    required Map<String, dynamic> apostaAtual,
    required Map<String, dynamic> dashboardData,
    required Map<String, dynamic> metricasAvancadas,
    required Map<String, dynamic> statsEspecificas,
    required Map<String, dynamic> configData,
    required Map<String, dynamic> resumoApostas,
    required Map<String, dynamic> qualidadeDados,
    required Map<String, dynamic> segmentacoes,
    required Map<String, dynamic> janelasTempo,
    required Map<String, dynamic> diarioData,
    required Map<String, dynamic> confiancaResumo,
    required Map<String, dynamic> poissonResumo,
    required Map<String, dynamic> scoutResumo,
    required List<Map<String, dynamic>> historicoRecente,
    required String queryDaIA,
  }) {
    return """
Você é um analista profissional de apostas esportivas e gestão de risco.
Regras:
- Use apenas os dados fornecidos. Não invente estatísticas ou notícias externas.
- Se algum dado estiver ausente, indique claramente e explique o impacto na análise.
- Priorize amostras maiores e evite conclusões fortes com poucos dados.

Formato de resposta:
1) Diagnóstico rápido (3-5 bullets).
2) Padrões fortes e fracos (com dados de suporte).
3) Riscos atuais (técnicos e emocionais).
4) Recomendação prática: stake/abstenção, checklist e ajustes.
5) Nota final (0-10) + justificativa objetiva.

=== DADOS DA APOSTA ATUAL ===
${jsonEncode(apostaAtual)}

=== REGRAS INTERNAS DO USUÁRIO ===
${jsonEncode(_regrasAposta)}

=== SUMÁRIO FINANCEIRO (Dashboard) ===
${jsonEncode(dashboardData)}

=== MÉTRICAS AVANÇADAS ===
${jsonEncode(metricasAvancadas)}

=== ESTATÍSTICAS ESPECÍFICAS (Histórico agregado por time/campeonato/tipo) ===
${jsonEncode(statsEspecificas)}

=== RESUMO GERAL DO HISTÓRICO ===
${jsonEncode(resumoApostas)}

=== QUALIDADE DOS DADOS ===
${jsonEncode(qualidadeDados)}

=== SEGMENTAÇÕES (Top/Bottom por ROI) ===
${jsonEncode(segmentacoes)}

=== JANELAS TEMPORAIS (performance recente) ===
${jsonEncode(janelasTempo)}

=== CONTEXTO EMOCIONAL / DIÁRIO ===
${jsonEncode(diarioData)}

=== CONFIANÇA (cards) ===
${jsonEncode(confiancaResumo)}

=== POISSON (cards) ===
${jsonEncode(poissonResumo)}

=== SCOUT DATABASE (resumo) ===
${jsonEncode(scoutResumo)}

=== CONFIGURAÇÕES DO USUÁRIO ===
${jsonEncode(configData)}

=== HISTÓRICO RECENTE (últimas apostas) ===
${jsonEncode(historicoRecente)}

=== TAREFA ===
$queryDaIA
""";
  }

  Future<void> _compartilharPromptIA({String? customQuery}) async {
    setState(() => _carregando = true);
    try {
      await _carregarRegras();
      final apostas = await _carregarApostas();
      final dashboardData = await _carregarDadosDashboard();
      final configData = await _carregarConfig();
      // NOVO: Carregar Estatísticas Globais
      final globalStats = await _carregarEstatisticasGlobais();
      final diarioData = await _carregarDadosDiarioIA();
      final confiancaResumo = await _carregarResumoConfiancaIA();
      final poissonResumo = await _carregarResumoPoissonIA();

      if (apostas.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Histórico de apostas está vazio.")));
        return;
      }

      final apostaAtual = {
        'timeCasa': _timeCasaCtrl.text.trim(),
        'timeFora': _timeForaCtrl.text.trim(),
        'tipo': _tipoCtrl.text.trim(),
        'campeonato': _campeonatoCtrl.text.trim(),
        'odd': _oddCtrl.text.trim().replaceAll(',', '.'),
      };

      if (apostaAtual.values.every((v) => (v as String).isEmpty)) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Preencha os dados da aposta na aba 'Histórico'.")));
        return;
      }

      // Filtrar estatísticas específicas para a aposta atual
      final statsEspecificas = {
        'timeCasa': globalStats['porTime']?[_timeCasaCtrl.text.trim()] ?? "Sem dados acumulados",
        'timeFora': globalStats['porTime']?[_timeForaCtrl.text.trim()] ?? "Sem dados acumulados",
        'campeonato': globalStats['porCampeonato']?[_campeonatoCtrl.text.trim()] ?? "Sem dados acumulados",
        'tipoAposta': globalStats['porTipo']?[_tipoCtrl.text.trim()] ?? "Sem dados acumulados",
      };

      final double totalStaked = apostas.fold(0.0, (s, a) => s + (a['stake'] as num).toDouble());
      final double lucroTotal = apostas.fold(0.0, (s, a) => s + (a['lucro'] as num).toDouble());
      final double yieldPct = totalStaked > 0 ? (lucroTotal / totalStaked) * 100 : 0.0;

      final double grossProfit = apostas.where((a) => (a['lucro'] as num) > 0).fold(0.0, (s, a) => s + (a['lucro'] as num).toDouble());
      final double grossLoss = apostas.where((a) => (a['lucro'] as num) < 0).fold(0.0, (s, a) => s + ((a['lucro'] as num).abs()).toDouble());
      final double profitFactor = grossLoss == 0 ? (grossProfit > 0 ? 999.0 : 0.0) : (grossProfit / grossLoss);

      int maxWinStreak = 0;
      int maxLoseStreak = 0;
      int currentW = 0;
      int currentL = 0;
      final sortedApostas = List<Map<String, dynamic>>.from(apostas)..sort((a, b) => a['data'].compareTo(b['data']));

      for (var a in sortedApostas) {
        final l = (a['lucro'] as num).toDouble();
        if (l > 0) {
          currentW++;
          currentL = 0;
          if (currentW > maxWinStreak) maxWinStreak = currentW;
        } else if (l < 0) {
          currentL++;
          currentW = 0;
          if (currentL > maxLoseStreak) maxLoseStreak = currentL;
        }
      }

      final double somaOdds = apostas.fold(0.0, (s, a) => s + (a['odd'] as num).toDouble());
      final double oddMedia = apostas.isNotEmpty ? (somaOdds / apostas.length) : 0.0;
      final double taxaNecessaria = (oddMedia > 0) ? (1 / oddMedia) : 0.0;
      final int ganhos = apostas.where((a) => (a['lucro'] as num) > 0).length;
      final double taxaReal = apostas.isNotEmpty ? (ganhos / apostas.length) : 0.0;

      final Map<String, Map<String, dynamic>> oddsStats = {
        '1.01 - 1.50': {'lucro': 0.0, 'total': 0, 'wins': 0},
        '1.51 - 2.00': {'lucro': 0.0, 'total': 0, 'wins': 0},
        '2.01 - 3.00': {'lucro': 0.0, 'total': 0, 'wins': 0},
        '3.01+':       {'lucro': 0.0, 'total': 0, 'wins': 0},
      };

      for(var a in apostas) {
        final odd = (a['odd'] as num).toDouble();
        final lucro = (a['lucro'] as num).toDouble();
        String key = '3.01+';
        if(odd <= 1.50) key = '1.01 - 1.50';
        else if(odd <= 2.00) key = '1.51 - 2.00';
        else if(odd <= 3.00) key = '2.01 - 3.00';

        oddsStats[key]!['lucro'] += lucro;
        oddsStats[key]!['total']++;
        if(lucro > 0) oddsStats[key]!['wins']++;
      }

      final metricasAvancadas = {
        'yield': yieldPct,
        'profitFactor': profitFactor >= 999 ? 'Infinito' : profitFactor.toStringAsFixed(2),
        'maxWinStreak': maxWinStreak,
        'maxLoseStreak': maxLoseStreak,
        'oddMedia': oddMedia,
        'taxaNecessaria': taxaNecessaria * 100,
        'taxaReal': taxaReal * 100,
        'isLucrativo': taxaReal > taxaNecessaria,
        'oddsStats': oddsStats,
        'desempenhoRealFlat': _calcularMetricasFlat(apostas), // NOVO
      };

      final resumoApostas = _calcularResumoApostasIA(apostas);
      final qualidadeDados = _avaliarQualidadeDadosIA(apostas);
      final segmentacoes = {
        'porCampeonato': _resumirSegmentosIA(apostas, 'campeonato'),
        'porTipo': _resumirSegmentosIA(apostas, 'tipo'),
        'porTime': _resumirSegmentosIA(apostas, 'time'),
        'porNivelConfianca': _resumirSegmentosIA(apostas, 'nivelConfianca', minApostas: 3),
        'porEV': _resumirSegmentosIA(apostas, 'evPositivo', minApostas: 3),
      };
      final janelasTempo = {
        'ultimos7d': _resumirJanelaTemporalIA(apostas, 7),
        'ultimos30d': _resumirJanelaTemporalIA(apostas, 30),
        'ultimos90d': _resumirJanelaTemporalIA(apostas, 90),
      };
      final historicoRecente = _formatarHistoricoRecenteIA(apostas, 25);
      final scoutResumo = _resumirScoutIA();

      final queryDaIA = customQuery ?? """
Com base em todos os dados fornecidos, faça uma análise detalhada da aposta proposta.
Priorize dados internos (histórico, métricas e contexto emocional) e evite suposições externas.
Avalie:
1) Desempenho histórico do usuário com os times envolvidos.
2) Desempenho por tipo de aposta e campeonato (use segmentações + desempenhoRealFlat).
3) Histórico em odds semelhantes e em janelas temporais recentes.
4) Riscos detectados pela qualidade dos dados e possíveis vieses emocionais.
5) Nota final de 0 a 10 e recomendação prática.
""";

      final prompt = _montarPromptAnaliseAposta(
        apostaAtual: apostaAtual,
        dashboardData: dashboardData,
        metricasAvancadas: metricasAvancadas,
        statsEspecificas: statsEspecificas,
        configData: configData,
        resumoApostas: resumoApostas,
        qualidadeDados: qualidadeDados,
        segmentacoes: segmentacoes,
        janelasTempo: janelasTempo,
        diarioData: diarioData,
        confiancaResumo: confiancaResumo,
        poissonResumo: poissonResumo,
        scoutResumo: scoutResumo,
        historicoRecente: historicoRecente,
        queryDaIA: queryDaIA,
      );

      await Share.share(prompt, subject: "Prompt de Análise de Aposta");

    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Erro ao gerar prompt: $e")));
    } finally {
      setState(() => _carregando = false);
    }
  }

  Future<void> _gerarAnaliseFocada({String? customQuery}) async {
    await _carregarRegras();
    final apostas = await _carregarApostas();
    final dashboardData = await _carregarDadosDashboard();
    final configData = await _carregarConfig();
    // NOVO: Carregar Estatísticas Globais
    final globalStats = await _carregarEstatisticasGlobais();
    final diarioData = await _carregarDadosDiarioIA();
    final confiancaResumo = await _carregarResumoConfiancaIA();
    final poissonResumo = await _carregarResumoPoissonIA();

    if (apostas.isEmpty) {
      setState(() => _analiseIAResultado = "Seu histórico de apostas está vazio.");
      return;
    }

    final apostaAtual = {
      'timeCasa': _timeCasaCtrl.text.trim(),
      'timeFora': _timeForaCtrl.text.trim(),
      'tipo': _tipoCtrl.text.trim(),
      'campeonato': _campeonatoCtrl.text.trim(),
      'odd': _oddCtrl.text.trim().replaceAll(',', '.'),
    };

    if (apostaAtual.values.every((v) => (v as String).isEmpty)) {
      setState(() => _analiseIAResultado = "Preencha os dados da aposta na aba 'Histórico'.");
      return;
    }

    // Filtrar estatísticas específicas
    final statsEspecificas = {
      'timeCasa': globalStats['porTime']?[_timeCasaCtrl.text.trim()] ?? "Sem dados acumulados",
      'timeFora': globalStats['porTime']?[_timeForaCtrl.text.trim()] ?? "Sem dados acumulados",
      'campeonato': globalStats['porCampeonato']?[_campeonatoCtrl.text.trim()] ?? "Sem dados acumulados",
      'tipoAposta': globalStats['porTipo']?[_tipoCtrl.text.trim()] ?? "Sem dados acumulados",
    };

    final double totalStaked = apostas.fold(0.0, (s, a) => s + (a['stake'] as num).toDouble());
    final double lucroTotal = apostas.fold(0.0, (s, a) => s + (a['lucro'] as num).toDouble());
    final double yieldPct = totalStaked > 0 ? (lucroTotal / totalStaked) * 100 : 0.0;
    final double grossProfit = apostas.where((a) => (a['lucro'] as num) > 0).fold(0.0, (s, a) => s + (a['lucro'] as num).toDouble());
    final double grossLoss = apostas.where((a) => (a['lucro'] as num) < 0).fold(0.0, (s, a) => s + ((a['lucro'] as num).abs()).toDouble());
    final double profitFactor = grossLoss == 0 ? (grossProfit > 0 ? 999.0 : 0.0) : (grossProfit / grossLoss);

    int maxWinStreak = 0;
    int maxLoseStreak = 0;
    int currentW = 0;
    int currentL = 0;
    final sortedApostas = List<Map<String, dynamic>>.from(apostas)..sort((a, b) => a['data'].compareTo(b['data']));
    for (var a in sortedApostas) {
      final l = (a['lucro'] as num).toDouble();
      if (l > 0) {
        currentW++;
        currentL = 0;
        if (currentW > maxWinStreak) maxWinStreak = currentW;
      } else if (l < 0) {
        currentL++;
        currentW = 0;
        if (currentL > maxLoseStreak) maxLoseStreak = currentL;
      }
    }

    final double somaOdds = apostas.fold(0.0, (s, a) => s + (a['odd'] as num).toDouble());
    final double oddMedia = apostas.isNotEmpty ? (somaOdds / apostas.length) : 0.0;
    final double taxaNecessaria = (oddMedia > 0) ? (1 / oddMedia) : 0.0;
    final int ganhos = apostas.where((a) => (a['lucro'] as num) > 0).length;
    final double taxaReal = apostas.isNotEmpty ? (ganhos / apostas.length) : 0.0;

    final Map<String, Map<String, dynamic>> oddsStats = {
      '1.01 - 1.50': {'lucro': 0.0, 'total': 0, 'wins': 0},
      '1.51 - 2.00': {'lucro': 0.0, 'total': 0, 'wins': 0},
      '2.01 - 3.00': {'lucro': 0.0, 'total': 0, 'wins': 0},
      '3.01+':       {'lucro': 0.0, 'total': 0, 'wins': 0},
    };

    for(var a in apostas) {
      final odd = (a['odd'] as num).toDouble();
      final lucro = (a['lucro'] as num).toDouble();
      String key = '3.01+';
      if(odd <= 1.50) key = '1.01 - 1.50';
      else if(odd <= 2.00) key = '1.51 - 2.00';
      else if(odd <= 3.00) key = '2.01 - 3.00';
      oddsStats[key]!['lucro'] += lucro;
      oddsStats[key]!['total']++;
      if(lucro > 0) oddsStats[key]!['wins']++;
    }

    final metricasAvancadas = {
      'yield': yieldPct,
      'profitFactor': profitFactor >= 999 ? 'Infinito' : profitFactor.toStringAsFixed(2),
      'maxWinStreak': maxWinStreak,
      'maxLoseStreak': maxLoseStreak,
      'oddMedia': oddMedia,
      'taxaNecessaria': taxaNecessaria * 100,
      'taxaReal': taxaReal * 100,
      'isLucrativo': taxaReal > taxaNecessaria,
      'oddsStats': oddsStats,
      'desempenhoRealFlat': _calcularMetricasFlat(apostas), // NOVO
    };

    final resumoApostas = _calcularResumoApostasIA(apostas);
    final qualidadeDados = _avaliarQualidadeDadosIA(apostas);
    final segmentacoes = {
      'porCampeonato': _resumirSegmentosIA(apostas, 'campeonato'),
      'porTipo': _resumirSegmentosIA(apostas, 'tipo'),
      'porTime': _resumirSegmentosIA(apostas, 'time'),
      'porNivelConfianca': _resumirSegmentosIA(apostas, 'nivelConfianca', minApostas: 3),
      'porEV': _resumirSegmentosIA(apostas, 'evPositivo', minApostas: 3),
    };
    final janelasTempo = {
      'ultimos7d': _resumirJanelaTemporalIA(apostas, 7),
      'ultimos30d': _resumirJanelaTemporalIA(apostas, 30),
      'ultimos90d': _resumirJanelaTemporalIA(apostas, 90),
    };
    final historicoRecente = _formatarHistoricoRecenteIA(apostas, 25);
    final scoutResumo = _resumirScoutIA();

    final String queryDaIA = customQuery ?? """
Com base em todos os dados fornecidos, faça uma análise detalhada da aposta proposta.
Priorize dados internos (histórico, métricas e contexto emocional) e evite suposições externas.
Avalie:
1) Desempenho histórico do usuário com os times envolvidos.
2) Desempenho por tipo de aposta e campeonato (use segmentações + desempenhoRealFlat).
3) Histórico em odds semelhantes e em janelas temporais recentes.
4) Riscos detectados pela qualidade dos dados e possíveis vieses emocionais.
5) Nota final de 0 a 10 e recomendação prática.
""";

    final prompt = _montarPromptAnaliseAposta(
      apostaAtual: apostaAtual,
      dashboardData: dashboardData,
      metricasAvancadas: metricasAvancadas,
      statsEspecificas: statsEspecificas,
      configData: configData,
      resumoApostas: resumoApostas,
      qualidadeDados: qualidadeDados,
      segmentacoes: segmentacoes,
      janelasTempo: janelasTempo,
      diarioData: diarioData,
      confiancaResumo: confiancaResumo,
      poissonResumo: poissonResumo,
      scoutResumo: scoutResumo,
      historicoRecente: historicoRecente,
      queryDaIA: queryDaIA,
    );

    await _chamarGeminiAPI(prompt);
  }

  // MODIFICADO: Agora aceita estatísticas globais
  String _construirPromptAnaliseGeral({
    required Map<String, dynamic> dashboardData,
    required Map<String, dynamic> diarioData,
    required Map<String, dynamic> flatStats,
    required Map<String, dynamic> globalStats,
    required Map<String, dynamic> resumoApostas,
    required Map<String, dynamic> qualidadeDados,
    required Map<String, dynamic> segmentacoes,
    required Map<String, dynamic> janelasTempo,
    required Map<String, dynamic> confiancaResumo,
    required Map<String, dynamic> poissonResumo,
    required Map<String, dynamic> scoutResumo,
  }) {
    return """
Atue como um analista de desempenho esportivo e comportamental profissional (Coach de Apostas).
Regras:
- Use apenas os dados fornecidos. Não invente dados externos.
- Se houver lacunas, indique claramente.

Explicações rápidas dos dados:
- Nível de confiança: nota baseada em histórico, IA, Poisson, comentários e confronto direto.
- Margem: diferença de gols percebida no pós-jogo.
- EV+: cálculo Poisson ajustado com critérios pessoais.
- Metas: em andamento mesmo quando 0% (interprete com cautela).

=== 1. DADOS DE PERFORMANCE (Dashboard Financeiro) ===
${jsonEncode(dashboardData)}

=== 2. DESEMPENHO REAL (Flat Stake) ===
Lucro em Unidades: ${flatStats['flatProfit'].toStringAsFixed(2)}u
ROI (Flat): ${flatStats['flatROI'].toStringAsFixed(2)}%

=== 3. RESUMO GERAL DO HISTÓRICO ===
${jsonEncode(resumoApostas)}

=== 4. QUALIDADE DOS DADOS ===
${jsonEncode(qualidadeDados)}

=== 5. ESTATÍSTICAS GLOBAIS (Time/Liga/Tipo) ===
${jsonEncode(globalStats)}

=== 6. SEGMENTAÇÕES (Top/Bottom por ROI) ===
${jsonEncode(segmentacoes)}

=== 7. JANELAS TEMPORAIS (performance recente) ===
${jsonEncode(janelasTempo)}

=== 8. CONTEXTO PESSOAL (Diário de Bordo e Metas) ===
${jsonEncode(diarioData)}

=== 9. CONFIANÇA (cards) ===
${jsonEncode(confiancaResumo)}

=== 10. POISSON (cards) ===
${jsonEncode(poissonResumo)}

=== 11. SCOUT DATABASE (resumo) ===
${jsonEncode(scoutResumo)}

=== DIRETRIZES DA ANÁLISE ===
1. **Diagnóstico Financeiro:** Avalie ROI, gestão de banca e consistência baseada no dashboard.
2. **Desempenho Real:** Compare financeiro vs. flat stake; destaque problemas de stake se houver divergência.
3. **Padrões Específicos:** Identifique campeonatos/mercados com desempenho negativo e positivo. Cite nomes.
4. **Correlação Emocional:** Analise eventos do diário e impactos nos resultados.
5. **Status das Metas:** Explique se metas influenciam o risco assumido.
6. **Plano de Ação:** 3 conselhos práticos (Técnica, Mentalidade, Gestão).
""";
  }

  Future<void> _gerarAnaliseGeral() async {
    final dashboardData = await _carregarDadosDashboard();
    final diarioData = await _carregarDadosDiarioIA();
    final apostas = await _carregarApostas();
    // NOVO: Carregar stats
    final globalStats = await _carregarEstatisticasGlobais();
    final confiancaResumo = await _carregarResumoConfiancaIA();
    final poissonResumo = await _carregarResumoPoissonIA();

    if (dashboardData.isEmpty && diarioData.isEmpty && apostas.isEmpty) {
      setState(() => _analiseIAResultado = "Sem dados suficientes (Dashboard, Histórico ou Diário) para análise.");
      return;
    }

    final flatStats = _calcularMetricasFlat(apostas);
    final resumoApostas = _calcularResumoApostasIA(apostas);
    final qualidadeDados = _avaliarQualidadeDadosIA(apostas);
    final segmentacoes = {
      'porCampeonato': _resumirSegmentosIA(apostas, 'campeonato'),
      'porTipo': _resumirSegmentosIA(apostas, 'tipo'),
      'porTime': _resumirSegmentosIA(apostas, 'time'),
      'porNivelConfianca': _resumirSegmentosIA(apostas, 'nivelConfianca', minApostas: 3),
      'porEV': _resumirSegmentosIA(apostas, 'evPositivo', minApostas: 3),
    };
    final janelasTempo = {
      'ultimos7d': _resumirJanelaTemporalIA(apostas, 7),
      'ultimos30d': _resumirJanelaTemporalIA(apostas, 30),
      'ultimos90d': _resumirJanelaTemporalIA(apostas, 90),
    };
    final scoutResumo = _resumirScoutIA();

    final prompt = _construirPromptAnaliseGeral(
      dashboardData: dashboardData,
      diarioData: diarioData,
      flatStats: flatStats,
      globalStats: globalStats,
      resumoApostas: resumoApostas,
      qualidadeDados: qualidadeDados,
      segmentacoes: segmentacoes,
      janelasTempo: janelasTempo,
      confiancaResumo: confiancaResumo,
      poissonResumo: poissonResumo,
      scoutResumo: scoutResumo,
    );
    await _chamarGeminiAPI(prompt);
  }

  Future<void> _compartilharPromptGeral() async {
    setState(() => _carregando = true);
    try {
      final dashboardData = await _carregarDadosDashboard();
      final diarioData = await _carregarDadosDiarioIA();
      final apostas = await _carregarApostas();
      // NOVO: Carregar stats
      final globalStats = await _carregarEstatisticasGlobais();
      final confiancaResumo = await _carregarResumoConfiancaIA();
      final poissonResumo = await _carregarResumoPoissonIA();

      if (dashboardData.isEmpty && diarioData.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Sem dados suficientes.")));
        return;
      }

      final flatStats = _calcularMetricasFlat(apostas);
      final resumoApostas = _calcularResumoApostasIA(apostas);
      final qualidadeDados = _avaliarQualidadeDadosIA(apostas);
      final segmentacoes = {
        'porCampeonato': _resumirSegmentosIA(apostas, 'campeonato'),
        'porTipo': _resumirSegmentosIA(apostas, 'tipo'),
        'porTime': _resumirSegmentosIA(apostas, 'time'),
        'porNivelConfianca': _resumirSegmentosIA(apostas, 'nivelConfianca', minApostas: 3),
        'porEV': _resumirSegmentosIA(apostas, 'evPositivo', minApostas: 3),
      };
      final janelasTempo = {
        'ultimos7d': _resumirJanelaTemporalIA(apostas, 7),
        'ultimos30d': _resumirJanelaTemporalIA(apostas, 30),
        'ultimos90d': _resumirJanelaTemporalIA(apostas, 90),
      };
      final scoutResumo = _resumirScoutIA();

      final prompt = _construirPromptAnaliseGeral(
        dashboardData: dashboardData,
        diarioData: diarioData,
        flatStats: flatStats,
        globalStats: globalStats,
        resumoApostas: resumoApostas,
        qualidadeDados: qualidadeDados,
        segmentacoes: segmentacoes,
        janelasTempo: janelasTempo,
        confiancaResumo: confiancaResumo,
        poissonResumo: poissonResumo,
        scoutResumo: scoutResumo,
      );
      await Share.share(prompt, subject: "Prompt de Análise Geral + Diário");
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Erro: $e")));
    } finally {
      setState(() => _carregando = false);
    }
  }

  // ================== DIÁLOGOS ==================
  Future<void> _mostrarDialogoOpcoesAnalise() async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Analisar Aposta Atual"),
        content: const Text("Escolha o método:"),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _compartilharPromptIA();
            },
            child: const Text("Copiar Prompt"),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _mostrarDialogoPromptPersonalizado();
            },
            child: const Text("Personalizada"),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _gerarAnaliseFocada(customQuery: null);
            },
            child: const Text("Análise Padrão"),
          ),
        ],
      ),
    );
  }

  Future<void> _mostrarDialogoOpcoesAnaliseGeral() async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Gerar Análise Geral"),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _compartilharPromptGeral();
            },
            child: const Text("Copiar Prompt"),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _gerarAnaliseGeral();
            },
            child: const Text("Gerar"),
          ),
        ],
      ),
    );
  }

  Future<void> _mostrarDialogoPromptPersonalizado() async {
    final promptCtrl = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Análise Personalizada"),
        content: TextField(
          controller: promptCtrl,
          decoration: const InputDecoration(hintText: "Sua pergunta..."),
          maxLines: 4,
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancelar")),
          ElevatedButton(
            onPressed: () {
              if (promptCtrl.text.isNotEmpty) {
                Navigator.pop(context);
                _gerarAnaliseFocada(customQuery: promptCtrl.text.trim());
              }
            },
            child: const Text("Analisar"),
          ),
        ],
      ),
    );
  }

  // ================== INTERFACE ==================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Análise de Apostas'),
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabs: const [
            Tab(text: "Histórico", icon: Icon(Icons.history)),
            Tab(text: "IA Gemini", icon: Icon(Icons.psychology_alt)),
            Tab(text: "Poisson Pro", icon: Icon(Icons.calculate_outlined)),
            Tab(text: "Confiança", icon: Icon(Icons.check_circle_outline)),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildAbaHistorico(),
          _buildAbaIA(),
          _buildAbaPoisson(),
          _buildAbaConfianca(),
        ],
      ),
    );
  }

  // ================== ABA HISTÓRICO ==================
  Widget _buildAbaHistorico() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text("Dados da Aposta para Análise", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),

          LayoutBuilder(builder: (context, constraints) {
            return Autocomplete<String>(
              optionsBuilder: (TextEditingValue textEditingValue) {
                if (textEditingValue.text == '') return const Iterable<String>.empty();
                return _timesUnicos.where((String option) => option.toLowerCase().contains(textEditingValue.text.toLowerCase()));
              },
              onSelected: (String selection) => _timeCasaCtrl.text = selection,
              fieldViewBuilder: (context, controller, focusNode, onEditingComplete) {
                if (controller.text.isEmpty && _timeCasaCtrl.text.isNotEmpty) controller.text = _timeCasaCtrl.text;
                return TextField(
                  controller: controller,
                  focusNode: focusNode,
                  onEditingComplete: onEditingComplete,
                  onChanged: (val) => _timeCasaCtrl.text = val,
                  decoration: const InputDecoration(labelText: "Time Casa", border: OutlineInputBorder()),
                );
              },
            );
          }),
          const SizedBox(height: 12),

          LayoutBuilder(builder: (context, constraints) {
            return Autocomplete<String>(
              optionsBuilder: (TextEditingValue textEditingValue) {
                if (textEditingValue.text == '') return const Iterable<String>.empty();
                return _timesUnicos.where((String option) => option.toLowerCase().contains(textEditingValue.text.toLowerCase()));
              },
              onSelected: (String selection) => _timeForaCtrl.text = selection,
              fieldViewBuilder: (context, controller, focusNode, onEditingComplete) {
                if (controller.text.isEmpty && _timeForaCtrl.text.isNotEmpty) controller.text = _timeForaCtrl.text;
                return TextField(
                  controller: controller,
                  focusNode: focusNode,
                  onEditingComplete: onEditingComplete,
                  onChanged: (val) => _timeForaCtrl.text = val,
                  decoration: const InputDecoration(labelText: "Time Visitante", border: OutlineInputBorder()),
                );
              },
            );
          }),
          const SizedBox(height: 12),

          LayoutBuilder(builder: (context, constraints) {
            return Autocomplete<String>(
              optionsBuilder: (TextEditingValue textEditingValue) {
                if (textEditingValue.text == '') return const Iterable<String>.empty();
                return _tiposUnicos.where((String option) => option.toLowerCase().contains(textEditingValue.text.toLowerCase()));
              },
              onSelected: (String selection) => _tipoCtrl.text = selection,
              fieldViewBuilder: (context, controller, focusNode, onEditingComplete) {
                if (controller.text.isEmpty && _tipoCtrl.text.isNotEmpty) controller.text = _tipoCtrl.text;
                return TextField(
                  controller: controller,
                  focusNode: focusNode,
                  onEditingComplete: onEditingComplete,
                  onChanged: (val) => _tipoCtrl.text = val,
                  decoration: const InputDecoration(labelText: "Tipo de Aposta (Ex: Over 2.5)", border: OutlineInputBorder()),
                );
              },
            );
          }),
          const SizedBox(height: 12),

          LayoutBuilder(builder: (context, constraints) {
            return Autocomplete<String>(
              optionsBuilder: (TextEditingValue textEditingValue) {
                if (textEditingValue.text == '') return const Iterable<String>.empty();
                return _campeonatosUnicos.where((String option) => option.toLowerCase().contains(textEditingValue.text.toLowerCase()));
              },
              onSelected: (String selection) => _campeonatoCtrl.text = selection,
              fieldViewBuilder: (context, controller, focusNode, onEditingComplete) {
                if (controller.text.isEmpty && _campeonatoCtrl.text.isNotEmpty) controller.text = _campeonatoCtrl.text;
                return TextField(
                  controller: controller,
                  focusNode: focusNode,
                  onEditingComplete: onEditingComplete,
                  onChanged: (val) => _campeonatoCtrl.text = val,
                  decoration: const InputDecoration(labelText: "Campeonato", border: OutlineInputBorder()),
                );
              },
            );
          }),
          const SizedBox(height: 12),

          TextField(
            controller: _oddCtrl,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: const InputDecoration(labelText: "Odd (opcional)", border: OutlineInputBorder()),
          ),
          const SizedBox(height: 24),

          ElevatedButton.icon(
            onPressed: _carregando ? null : _analisarHistorico,
            icon: _carregando ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)) : const Icon(Icons.analytics),
            label: const Text("Analisar Histórico"),
            style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
          ),

          const SizedBox(height: 16),
          OutlinedButton.icon(
            onPressed: _carregando ? null : _exportarApostasParaTXT,
            icon: const Icon(Icons.file_download),
            label: const Text("Exportar Histórico para TXT"),
          ),

          if (_analiseHistorico != null) ...[
            const SizedBox(height: 24),
            _analiseHistorico!.containsKey('erro')
                ? Text(_analiseHistorico!['erro'], style: const TextStyle(color: Colors.red, fontSize: 16))
                : _buildResultadoHistorico(),
          ],
        ],
      ),
    );
  }

  // ================== WIDGET NOVA ABA CONFIANÇA ==================
  Widget _buildAbaConfianca() {
    final activeCards = _listaCardsConfianca.where((c) =>
    c['arquivado'] == false && c['linkedBetId'] == null
    ).toList();

    final archivedCards = _listaCardsConfianca.where((c) =>
    c['arquivado'] == true
    ).toList();

    final bool isEditing = _idCardEmEdicao != null;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  isEditing ? "✏️ Editando Análise" : "📝 Nova Análise de Confiança",
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: isEditing ? Colors.orange[800] : Colors.black
                  ),
                ),
              ),
              TextButton.icon(
                onPressed: _limparFormularioConfianca,
                icon: Icon(isEditing ? Icons.cancel : Icons.delete_sweep, color: Colors.grey),
                label: Text(isEditing ? "Cancelar" : "Limpar", style: const TextStyle(color: Colors.grey)),
              )
            ],
          ),

          if (isEditing)
            Container(
              padding: const EdgeInsets.all(8),
              margin: const EdgeInsets.only(bottom: 8),
              color: Colors.orange.shade50,
              child: const Text("Você está editando um card existente. As alterações irão substituir o card original ao salvar.", style: TextStyle(fontSize: 12, color: Colors.deepOrange)),
            ),

          const SizedBox(height: 8),

          TextField(
            controller: _confiancaTituloCtrl,
            onChanged: (_) => _agendarSalvamentoRascunho(),
            decoration: const InputDecoration(
              labelText: "Nome da Análise / Aposta (Opcional)",
              hintText: "Ex: Flamengo x Vasco - Back Casa",
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.label_outline),
            ),
          ),

          const Divider(height: 20),

          ...List.generate(_perguntasConfianca.length, (index) {
            final isAnulada = _perguntasAnuladasBool[index];

            return Card(
              margin: const EdgeInsets.symmetric(vertical: 8),
              elevation: 1,
              color: isAnulada ? Colors.grey.shade200 : Colors.white,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  children: [
                    Row(
                      children: [
                        IconButton(
                          icon: Icon(isAnulada ? Icons.restore_from_trash : Icons.block, color: isAnulada ? Colors.green : Colors.grey),
                          tooltip: isAnulada ? "Reativar Pergunta" : "Anular Pergunta (Ignorar na nota)",
                          onPressed: () {
                            setState(() {
                              _perguntasAnuladasBool[index] = !isAnulada;
                            });
                            _agendarSalvamentoRascunho();
                          },
                        ),

                        Expanded(
                          child: Text(
                            _perguntasConfianca[index],
                            style: TextStyle(
                              fontWeight: FontWeight.w500,
                              color: isAnulada ? Colors.grey : Colors.black,
                              decoration: isAnulada ? TextDecoration.lineThrough : null,
                            ),
                          ),
                        ),

                        Switch(
                          value: _respostasConfiancaBool[index],
                          onChanged: isAnulada ? null : (val) {
                            setState(() {
                              _respostasConfiancaBool[index] = val;
                            });
                            _agendarSalvamentoRascunho();
                          },
                          activeColor: index == 5 ? Colors.red : Colors.green,
                        ),
                      ],
                    ),

                    if (!isAnulada)
                      TextField(
                        controller: _obsConfiancaCtrl[index],
                        onChanged: (_) => _agendarSalvamentoRascunho(),
                        decoration: const InputDecoration(
                          labelText: "Observação (opcional)",
                          isDense: true,
                          border: OutlineInputBorder(),
                          contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                        ),
                        style: const TextStyle(fontSize: 13),
                      ),
                  ],
                ),
              ),
            );
          }),

          const SizedBox(height: 16),

          ElevatedButton.icon(
            onPressed: _salvarCardConfianca,
            icon: Icon(isEditing ? Icons.update : Icons.save_as),
            label: Text(isEditing ? "Atualizar Card" : "Calcular Nota e Criar Card"),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              backgroundColor: isEditing ? Colors.orange : Colors.blueAccent,
              foregroundColor: Colors.white,
            ),
          ),

          const Divider(height: 40, thickness: 2),

          const Text(
            "Cards Ativos",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          _carregandoConfianca
              ? const Center(child: CircularProgressIndicator())
              : activeCards.isEmpty
              ? const Center(child: Text("Nenhum card ativo.", style: TextStyle(color: Colors.grey)))
              : ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: activeCards.length,
            itemBuilder: (context, index) {
              final item = activeCards[index];
              final nota = (item['nota'] as num).toDouble();
              final obs = (item['observacoes'] as List).cast<String>();
              final bool isBeingEdited = item['id'] == _idCardEmEdicao;
              final anuladas = List<bool>.from(item['anuladas'] ?? List.filled(6, false));

              return Card(
                elevation: 3,
                margin: const EdgeInsets.only(bottom: 12),
                shape: isBeingEdited ? RoundedRectangleBorder(side: const BorderSide(color: Colors.orange, width: 2), borderRadius: BorderRadius.circular(12)) : null,
                child: ExpansionTile(
                  leading: CircleAvatar(
                    backgroundColor: _getCorNota(nota),
                    child: Text(
                      nota.toInt().toString(),
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                  ),
                  title: Text(item['titulo'] ?? "Análise"),
                  subtitle: Text(
                    "Data: ${DateTime.parse(item['data']).day}/${DateTime.parse(item['data']).month} - ${DateTime.parse(item['data']).hour}:${DateTime.parse(item['data']).minute}",
                    style: const TextStyle(fontSize: 12),
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.blue),
                        tooltip: "Editar",
                        onPressed: () => _editarCardConfianca(item),
                      ),
                      const Icon(Icons.expand_more),
                    ],
                  ),
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text("Resumo das Respostas:", style: TextStyle(fontWeight: FontWeight.bold)),
                          const SizedBox(height: 8),
                          ...List.generate(_perguntasConfianca.length, (i) {
                            if (anuladas[i]) {
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 4.0),
                                child: Row(
                                  children: [
                                    const Icon(Icons.block, size: 16, color: Colors.grey),
                                    const SizedBox(width: 8),
                                    Text("Q${i+1}: Anulada / Ignorada", style: const TextStyle(color: Colors.grey, fontStyle: FontStyle.italic)),
                                  ],
                                ),
                              );
                            }

                            final resp = (item['respostas'] as List)[i];
                            final txt = obs[i];

                            return Padding(
                              padding: const EdgeInsets.only(bottom: 4.0),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Icon(
                                    resp ? Icons.check : Icons.close,
                                    size: 16,
                                    color: resp ? (i==5 ? Colors.red : Colors.green) : Colors.grey,
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: RichText(
                                      text: TextSpan(
                                        style: const TextStyle(color: Colors.black87, fontSize: 12),
                                        children: [
                                          TextSpan(text: "Q${i+1}: ", style: const TextStyle(fontWeight: FontWeight.bold)),
                                          TextSpan(text: txt.isNotEmpty ? txt : (resp ? "Sim" : "Não")),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }),
                          const SizedBox(height: 12),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              TextButton.icon(
                                icon: const Icon(Icons.archive, size: 18, color: Colors.orange),
                                label: const Text("Arquivar", style: TextStyle(color: Colors.orange)),
                                onPressed: () => _arquivarCardConfianca(item['id']),
                              ),
                              TextButton.icon(
                                icon: const Icon(Icons.delete, size: 18, color: Colors.red),
                                label: const Text("Excluir", style: TextStyle(color: Colors.red)),
                                onPressed: () => _excluirCardConfianca(item['id']),
                              ),
                            ],
                          )
                        ],
                      ),
                    )
                  ],
                ),
              );
            },
          ),

          const SizedBox(height: 20),

          if (archivedCards.isNotEmpty)
            ExpansionTile(
              title: const Text("Itens Arquivados"),
              subtitle: Text("${archivedCards.length} itens"),
              children: [
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: archivedCards.length,
                  itemBuilder: (context, index) {
                    final item = archivedCards[index];
                    final nota = (item['nota'] as num).toDouble();
                    final resultado = item['resultado'];

                    Color cardColor = Colors.white;
                    if (resultado == 'win') cardColor = Colors.green.shade50;
                    if (resultado == 'loss') cardColor = Colors.red.shade50;

                    return Card(
                      color: cardColor,
                      margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                      child: ExpansionTile(
                        leading: CircleAvatar(
                          backgroundColor: _getCorNota(nota),
                          radius: 16,
                          child: Text(nota.toInt().toString(), style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
                        ),
                        title: Text(item['titulo'], style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                        subtitle: Text(
                            "Data: ${DateTime.parse(item['data']).day}/${DateTime.parse(item['data']).month} | ${resultado != null ? (resultado == 'win' ? 'GREEN ✅' : 'RED ❌') : 'Pendente'}",
                            style: const TextStyle(fontSize: 11)
                        ),
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                TextButton(onPressed: () => _setarResultadoConfianca(item['id'], 'win'), child: const Text("Green", style: TextStyle(color: Colors.green))),
                                TextButton(onPressed: () => _setarResultadoConfianca(item['id'], 'loss'), child: const Text("Red", style: TextStyle(color: Colors.red))),
                                IconButton(icon: const Icon(Icons.delete, color: Colors.red), onPressed: () => _excluirCardConfianca(item['id'])),
                              ],
                            ),
                          )
                        ],
                      ),
                    );
                  },
                )
              ],
            )
        ],
      ),
    );
  }

  // ================== HELPER POISSON ==================
  double? _p(String s) => double.tryParse(s.replaceAll(',', '.'));
  double _fatorial(int n) { double r = 1.0; for (int i = 2; i <= n; i++) r *= i; return r; }
  double _pois(int k, double lambda) => exp(-lambda) * pow(lambda, k) / _fatorial(k);

  Map<String, dynamic> _calcularProbabilidadesDeGols(Map<String, double> placares, double somaTotal) {
    double pOver15 = 0; double pOver25 = 0; double pOver35 = 0; double pOver45 = 0; double pBTTS_Sim = 0;

    placares.forEach((placar, prob) {
      final parts = placar.split(' x ');
      final hg = int.parse(parts[0]); final ag = int.parse(parts[1]);
      final total = hg + ag;

      if (total > 1.5) pOver15 += prob;
      if (total > 2.5) pOver25 += prob;
      if (total > 3.5) pOver35 += prob;
      if (total > 4.5) pOver45 += prob;
      if (hg > 0 && ag > 0) pBTTS_Sim += prob;
    });

    Map<String, dynamic> item(double p) {
      double prob = p / somaTotal;
      double odd = prob > 0 ? 1.0 / prob : 0.0;
      return {'prob': prob, 'oddJusta': odd};
    }

    return {
      'Over 1.5': item(pOver15),
      'Under 1.5': item(somaTotal - pOver15),
      'Over 2.5': item(pOver25),
      'Under 2.5': item(somaTotal - pOver25),
      'Over 3.5': item(pOver35),
      'Under 3.5': item(somaTotal - pOver35),
      'Over 4.5': item(pOver45),
      'Under 4.5': item(somaTotal - pOver45),
      'Ambos Marcam (Sim)': item(pBTTS_Sim),
      'Ambos Marcam (Não)': item(somaTotal - pBTTS_Sim),
    };
  }

  Map<String, dynamic> _calcularPoisson(Map<String, String> form) {
    final ligaMedia = _p(form['mediaLiga']!) ?? 2.4;
    final nCasa = (_p(form['jogosMandante']!) ?? 8).clamp(1, 100).toDouble();
    final nFora = (_p(form['jogosVisitante']!) ?? 8).clamp(1, 100).toDouble();

    // Gols Reais (GM)
    final gmCasa = _p(form['gmMandante']!) ?? 0.0;
    final gmFora = _p(form['gmVisitante']!) ?? 0.0;

    // Gols Esperados (xG) - Se vazio, assume igual aos gols reais (neutro)
    final xgCasaInput = _p(form['xgMandante']!);
    final xgForaInput = _p(form['xgVisitante']!);
    final xgCasa = xgCasaInput ?? gmCasa;
    final xgFora = xgForaInput ?? gmFora;

    final gsCasa = _p(form['gsMandante']!) ?? 0.0;
    final gsFora = _p(form['gsVisitante']!) ?? 0.0;

    // CÁLCULO DA MÉDIA BLENDADA (EFICÁCIA)
    // Combina a realidade (Gols) com a estatística subjacente (xG) baseado no peso
    final mGmCasaReal = (nCasa > 0) ? (gmCasa / nCasa) : 0.0;
    final mXgCasaReal = (nCasa > 0) ? (xgCasa / nCasa) : 0.0;
    final mGmCasa = (mGmCasaReal * _poissonPesoEficacia) + (mXgCasaReal * (1.0 - _poissonPesoEficacia));

    final mGmForaReal = (nFora > 0) ? (gmFora / nFora) : 0.0;
    final mXgForaReal = (nFora > 0) ? (xgFora / nFora) : 0.0;
    final mGmFora = (mGmForaReal * _poissonPesoEficacia) + (mXgForaReal * (1.0 - _poissonPesoEficacia));

    final mGsCasa = (nCasa > 0) ? (gsCasa / nCasa) : 0.0;
    final mGsFora = (nFora > 0) ? (gsFora / nFora) : 0.0;

    final ligaPorTime = (ligaMedia / 2.0) * _poissonFatorLiga;

    // Forças Brutas
    final atkCasaRaw = (ligaPorTime > 0) ? (mGmCasa / ligaPorTime) : 1.0;
    final defCasaRaw = (ligaPorTime > 0) ? (mGsCasa / ligaPorTime) : 1.0;
    final atkForaRaw = (ligaPorTime > 0) ? (mGmFora / ligaPorTime) : 1.0;
    final defForaRaw = (ligaPorTime > 0) ? (mGsFora / ligaPorTime) : 1.0;

    // APLICAÇÃO DA SUAVIZAÇÃO (Regressão à Média)
    final atkCasa = 1.0 + (atkCasaRaw - 1.0) * _poissonSuavizacao;
    final defCasa = 1.0 + (defCasaRaw - 1.0) * _poissonSuavizacao;
    final atkFora = 1.0 + (atkForaRaw - 1.0) * _poissonSuavizacao;
    final defFora = 1.0 + (defForaRaw - 1.0) * _poissonSuavizacao;

    double lambdaCasa = (ligaPorTime * atkCasa * defFora * (1 + _poissonFatorCasa)).clamp(0.05, 6.0);
    double lambdaFora = (ligaPorTime * atkFora * defCasa).clamp(0.05, 6.0);

    const maxGols = 7;
    double pH = 0, pD = 0, pA = 0;
    double bestP = -1;
    int bestHG = 0, bestAG = 0;
    final placares = <String, double>{};

    for (int hg = 0; hg <= maxGols; hg++) {
      final ph = _pois(hg, lambdaCasa);
      for (int ag = 0; ag <= maxGols; ag++) {
        final pa = _pois(ag, lambdaFora);
        final joint = ph * pa;
        placares["$hg x $ag"] = joint;
      }
    }

    // APLICAÇÃO DA CORREÇÃO 8 OU 80 INTELIGENTE (PRESERVA ZEBRA)
    if (_poissonAjusteZero > 0.0) {
      final p00Antigo = placares["0 x 0"] ?? 0.0;
      double boost = _poissonAjusteZero;

      // Limite de segurança
      if (p00Antigo + boost > 0.95) boost = 0.95 - p00Antigo;

      // Identifica placares "doadores" (Soma de gols >= 2)
      final doadores = placares.keys.where((k) {
        if (k == "0 x 0") return false;
        final parts = k.split(' x ');
        final totalGols = int.parse(parts[0]) + int.parse(parts[1]);
        return totalGols >= 2;
      }).toList();

      double somaDoadores = 0.0;
      for (var k in doadores) somaDoadores += placares[k]!;

      // Se houver "gordura" suficiente nos placares altos, tira só deles
      if (somaDoadores > boost) {
        final fatorReducao = (somaDoadores - boost) / somaDoadores;
        for (var k in doadores) {
          placares[k] = placares[k]! * fatorReducao;
        }
        // Aplica o boost no 0x0
        placares["0 x 0"] = p00Antigo + boost;
      } else {
        // Fallback
        double p00Novo = (p00Antigo + boost).clamp(0.0, 0.95);
        double fatorReducao = 1.0;
        if (p00Antigo < 1.0) fatorReducao = (1.0 - p00Novo) / (1.0 - p00Antigo);

        placares.forEach((key, val) {
          if (key == "0 x 0") placares[key] = p00Novo;
          else placares[key] = val * fatorReducao;
        });
      }
    }

    // APLICAÇÃO DA CORREÇÃO DE ELASTICIDADE (CAOS/GOLEADAS)
    if (_poissonAjusteElasticidade > 0.0) {
      final boost = _poissonAjusteElasticidade;

      // Recebedores: Total >= 4 (Jogos abertos)
      final receivers = placares.keys.where((k) {
        final parts = k.split(' x ');
        return (int.parse(parts[0]) + int.parse(parts[1])) >= 4;
      }).toList();

      // Doadores: 1 <= Total <= 3 (Jogos mornos)
      // Protege o 0x0
      final donors = placares.keys.where((k) {
        final parts = k.split(' x ');
        final t = int.parse(parts[0]) + int.parse(parts[1]);
        return t >= 1 && t <= 3;
      }).toList();

      double sumDonors = 0.0;
      for (var k in donors) sumDonors += placares[k]!;

      double sumReceivers = 0.0;
      for (var k in receivers) sumReceivers += placares[k]!;

      // Se tiver de onde tirar
      if (sumDonors > boost) {
        // Reduz probabilidade dos placares normais
        double factorRed = (sumDonors - boost) / sumDonors;
        for (var k in donors) placares[k] = placares[k]! * factorRed;

        // Aumenta probabilidade das goleadas
        if (sumReceivers > 0) {
          double factorInc = (sumReceivers + boost) / sumReceivers;
          for (var k in receivers) placares[k] = placares[k]! * factorInc;
        }
      }
    }

    // Recalcula somas e melhor placar após ajuste
    placares.forEach((key, val) {
      if (val > bestP) {
        bestP = val;
        final parts = key.split(' x ');
        bestHG = int.parse(parts[0]);
        bestAG = int.parse(parts[1]);
      }
      final parts = key.split(' x ');
      final hg = int.parse(parts[0]);
      final ag = int.parse(parts[1]);
      if (hg > ag) pH += val;
      else if (hg == ag) pD += val;
      else pA += val;
    });

    final somaTotalPlacares = pH + pD + pA;
    final probCasa = pH / somaTotalPlacares;
    final probEmpate = pD / somaTotalPlacares;
    final probFora = pA / somaTotalPlacares;

    // Double Chance (Chance Dupla)
    final prob1X = probCasa + probEmpate;
    final probX2 = probEmpate + probFora;
    final prob12 = probCasa + probFora;

    final probGols = _calcularProbabilidadesDeGols(placares, somaTotalPlacares);

    // Cálculo da Eficácia para exibição (Ratio simples)
    double eficaciaCasa = (mXgCasaReal > 0) ? (mGmCasaReal / mXgCasaReal) : 1.0;
    double eficaciaFora = (mXgForaReal > 0) ? (mGmForaReal / mXgForaReal) : 1.0;

    return {
      'lambdaCasa': lambdaCasa,
      'lambdaFora': lambdaFora,
      'pCasa': probCasa,
      'pEmpate': probEmpate,
      'pFora': probFora,
      'p1X': prob1X, // Novo
      'pX2': probX2, // Novo
      'p12': prob12, // Novo
      'placarProvavel': {'hg': bestHG, 'ag': bestAG, 'p': bestP},
      'placares': placares,
      'probGols': probGols,
      'eficacia': {'casa': eficaciaCasa, 'fora': eficaciaFora}
    };
  }

  void _onCalcularPoisson() {
    if ([_poissonGMMandanteCtrl, _poissonGSMandanteCtrl, _poissonGMVisitanteCtrl, _poissonGSVisitanteCtrl, _poissonJogosMandanteCtrl, _poissonJogosVisitanteCtrl, _poissonMediaLigaCtrl]
        .any((c) => (c.text.trim().isEmpty))) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Preencha: média da liga, jogos e gols.")),
      );
      return;
    }
    final form = {
      'campeonato': _poissonCampeonatoCtrl.text.trim(),
      'mandante': _poissonMandanteCtrl.text.trim(),
      'visitante': _poissonVisitanteCtrl.text.trim(),
      'mediaLiga': _poissonMediaLigaCtrl.text.trim(),
      'jogosMandante': _poissonJogosMandanteCtrl.text.trim(),
      'jogosVisitante': _poissonJogosVisitanteCtrl.text.trim(),
      'gmMandante': _poissonGMMandanteCtrl.text.trim(),
      'xgMandante': _poissonXGMandanteCtrl.text.trim(), // NOVO
      'gsMandante': _poissonGSMandanteCtrl.text.trim(),
      'gmVisitante': _poissonGMVisitanteCtrl.text.trim(),
      'xgVisitante': _poissonXGVisitanteCtrl.text.trim(), // NOVO
      'gsVisitante': _poissonGSVisitanteCtrl.text.trim(),
      'oddCasa': _poissonOddCasaCtrl.text.trim(),
      'oddEmpate': _poissonOddEmpateCtrl.text.trim(),
      'oddFora': _poissonOddForaCtrl.text.trim(),
    };

    setState(() {
      _resultadoPoisson = _calcularPoisson(form);
      final oc = _p(form['oddCasa']!);
      final od = _p(form['oddEmpate']!);
      final of = _p(form['oddFora']!);

      if (oc != null && od != null && of != null && oc >= 1 && od >= 1 && of >= 1) {
        final pH = (_resultadoPoisson!['pCasa'] as double);
        final pD = (_resultadoPoisson!['pEmpate'] as double);
        final pA = (_resultadoPoisson!['pFora'] as double);
        final fairH = 1 / pH;
        final fairD = 1 / pD;
        final fairA = 1 / pA;

        final Map<String, Map<String, double>> options = {
          'Casa':   {'odd': oc, 'fair': fairH, 'p': pH},
          'Empate': {'odd': od, 'fair': fairD, 'p': pD},
          'Fora':   {'odd': of, 'fair': fairA, 'p': pA},
        };

        String? melhorAposta;
        double bestEdge = -1e9;
        Map<String, double>? det;
        options.forEach((k, v) {
          final odd  = v['odd']  ?? 0.0;
          final fair = v['fair'] ?? 0.0;
          final edge = odd - fair;
          if (edge > bestEdge) {
            bestEdge = edge;
            melhorAposta = k;
            det = {'odd': odd, 'fair': fair, 'p': v['p'] ?? 0.0};
          }
        });
        _resultadoPoisson!['value'] = {'aposta': melhorAposta, 'detalhe': det, 'edge': bestEdge};
      }
    });
  }

  // --- Funções de IA removidas para manter manual ---

  Widget _buildAbaPoisson() {
    Color _corValor(double p) {
      if (p >= 0.5) return Colors.green;
      if (p >= 0.35) return Colors.orange;
      return Colors.red;
    }

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: ListView(
        children: [
          // MODIFICADO: Adicionado botão de limpeza no topo
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Expanded(
                child: Text("⚽ Análise Poisson Manual (Profissional)",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ),
              IconButton(
                icon: const Icon(Icons.cleaning_services_outlined, color: Colors.redAccent),
                tooltip: "Limpar Campos",
                onPressed: _limparFormularioPoissonCompleto,
              ),
            ],
          ),
          const SizedBox(height: 12),

          // --- INTEGRAÇÃO COM SCOUT (AUTOCOMPLETE INTELIGENTE) ---
          Autocomplete<String>(
            optionsBuilder: (textVal) {
              if(textVal.text.isEmpty) return _scoutLigas;
              return _scoutLigas.where((l) => l.toLowerCase().contains(textVal.text.toLowerCase()));
            },
            onSelected: (s) => _poissonCampeonatoCtrl.text = s,
            fieldViewBuilder: (ctx, ctrl, focus, onSubmit) {
              // CORREÇÃO: Sincronização bidirecional forçada para permitir limpeza
              if(ctrl.text != _poissonCampeonatoCtrl.text) {
                ctrl.text = _poissonCampeonatoCtrl.text;
                // Mantém o cursor no final se o texto não estiver vazio
                if (ctrl.text.isNotEmpty) {
                  ctrl.selection = TextSelection.fromPosition(TextPosition(offset: ctrl.text.length));
                }
              }
              return TextField(
                controller: ctrl, focusNode: focus,
                decoration: const InputDecoration(labelText: "Campeonato/Liga", border: OutlineInputBorder(), prefixIcon: Icon(Icons.emoji_events)),
                onChanged: (v) { _poissonCampeonatoCtrl.text = v; setState((){}); }, // Atualiza para filtrar times
              );
            },
          ),
          const SizedBox(height: 12),

          Row(
            children: [
              Expanded(
                child: Autocomplete<String>(
                  optionsBuilder: (textVal) {
                    final liga = _poissonCampeonatoCtrl.text;
                    final times = _scoutTimesPorLiga[liga] ?? [];
                    if(textVal.text.isEmpty) return times;
                    return times.where((t) => t.toLowerCase().contains(textVal.text.toLowerCase()));
                  },
                  onSelected: (s) { _poissonMandanteCtrl.text = s; _tentaPreencherDadosComScout(); },
                  fieldViewBuilder: (ctx, ctrl, focus, onSubmit) {
                    // CORREÇÃO: Sincronização bidirecional forçada
                    if(ctrl.text != _poissonMandanteCtrl.text) {
                      ctrl.text = _poissonMandanteCtrl.text;
                      if (ctrl.text.isNotEmpty) {
                        ctrl.selection = TextSelection.fromPosition(TextPosition(offset: ctrl.text.length));
                      }
                    }
                    return TextField(
                      controller: ctrl, focusNode: focus,
                      decoration: const InputDecoration(labelText: "Time Mandante", border: OutlineInputBorder()),
                      onChanged: (v) => _poissonMandanteCtrl.text = v,
                    );
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Autocomplete<String>(
                  optionsBuilder: (textVal) {
                    final liga = _poissonCampeonatoCtrl.text;
                    final times = _scoutTimesPorLiga[liga] ?? [];
                    if(textVal.text.isEmpty) return times;
                    return times.where((t) => t.toLowerCase().contains(textVal.text.toLowerCase()));
                  },
                  onSelected: (s) { _poissonVisitanteCtrl.text = s; _tentaPreencherDadosComScout(); },
                  fieldViewBuilder: (ctx, ctrl, focus, onSubmit) {
                    // CORREÇÃO: Sincronização bidirecional forçada
                    if(ctrl.text != _poissonVisitanteCtrl.text) {
                      ctrl.text = _poissonVisitanteCtrl.text;
                      if (ctrl.text.isNotEmpty) {
                        ctrl.selection = TextSelection.fromPosition(TextPosition(offset: ctrl.text.length));
                      }
                    }
                    return TextField(
                      controller: ctrl, focusNode: focus,
                      decoration: const InputDecoration(labelText: "Time Visitante", border: OutlineInputBorder()),
                      onChanged: (v) => _poissonVisitanteCtrl.text = v,
                    );
                  },
                ),
              ),
            ],
          ),

          const Divider(height: 30),
          const Text("📊 Parâmetros da Liga e Amostra"),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _poissonMediaLigaCtrl,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  decoration: const InputDecoration(labelText: "Média gols Liga", border: OutlineInputBorder()),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextField(
                  controller: _poissonJogosMandanteCtrl,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: "Jogos (Casa)", border: OutlineInputBorder()),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextField(
                  controller: _poissonJogosVisitanteCtrl,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: "Jogos (Fora)", border: OutlineInputBorder()),
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),
          const Text("⚽ Gols no Recorte"),
          const SizedBox(height: 8),

          // LINHA MANDANTE
          const Text("Mandante (Casa)", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.blue)),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _poissonGMMandanteCtrl,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  decoration: const InputDecoration(labelText: "Gols Feitos", border: OutlineInputBorder(), isDense: true),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: TextField(
                  controller: _poissonXGMandanteCtrl,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  decoration: const InputDecoration(labelText: "xG (Criado)", border: OutlineInputBorder(), isDense: true, fillColor: Color(0xFFF0F4C3), filled: true),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: TextField(
                  controller: _poissonGSMandanteCtrl,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  decoration: const InputDecoration(labelText: "Gols Sofridos", border: OutlineInputBorder(), isDense: true),
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // LINHA VISITANTE
          const Text("Visitante (Fora)", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.red)),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _poissonGMVisitanteCtrl,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  decoration: const InputDecoration(labelText: "Gols Feitos", border: OutlineInputBorder(), isDense: true),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: TextField(
                  controller: _poissonXGVisitanteCtrl,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  decoration: const InputDecoration(labelText: "xG (Criado)", border: OutlineInputBorder(), isDense: true, fillColor: Color(0xFFF0F4C3), filled: true),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: TextField(
                  controller: _poissonGSVisitanteCtrl,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  decoration: const InputDecoration(labelText: "Gols Sofridos", border: OutlineInputBorder(), isDense: true),
                ),
              ),
            ],
          ),

          const Divider(height: 30),
          const Text("🛡️ Nível de Enfrentamento"),
          const SizedBox(height: 8),
          SwitchListTile(
            value: _nivelEnfrentamentoAtivo,
            title: const Text("Ativar ajuste por posição do adversário"),
            subtitle: const Text("Quando ativo, gols/xG criados e gols sofridos são ponderados pela posição do adversário."),
            onChanged: (v) {
              setState(() => _nivelEnfrentamentoAtivo = v);
              _salvarConfigNivelEnfrentamento();
              _tentaPreencherDadosComScout();
            },
          ),
          Builder(
            builder: (context) {
              final liga = _poissonCampeonatoCtrl.text.trim();
              final classificacao = liga.isNotEmpty ? _gerarClassificacaoScout(liga) : <Map<String, dynamic>>[];
              final totalTimes = classificacao.isNotEmpty ? classificacao.length : 20;
              final nomesTimes = <int, String>{};
              for (int i = 0; i < classificacao.length; i++) {
                nomesTimes[i + 1] = classificacao[i]['time']?.toString() ?? '';
              }
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Configuração padrão (aplica a todas as ligas).", style: TextStyle(color: Colors.grey)),
                  const SizedBox(height: 8),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: TextButton.icon(
                      onPressed: () => _abrirAjusteNivelEnfrentamento(totalTimes: totalTimes, nomesTimes: nomesTimes),
                      icon: const Icon(Icons.tune),
                      label: const Text("Ajustar pesos por posição"),
                    ),
                  ),
                  const SizedBox(height: 8),
                  _buildResumoNivelEnfrentamento(),
                ],
              );
            },
          ),

          const Divider(height: 30),
          const Text("⚙️ Fatores e Ajustes"),
          const SizedBox(height: 8),

          // SLIDER PESO XG
          Row(
            children: [
              const Icon(Icons.science, color: Colors.teal),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Peso da Eficácia (Gols vs xG): ${(_poissonPesoEficacia * 100).toInt()}% Gols", style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.teal)),
                    Text(
                        _poissonPesoEficacia > 0.8 ? "Usa principalmente Gols Reais (Resultado)." :
                        _poissonPesoEficacia < 0.2 ? "Usa principalmente xG (Criação de jogadas)." :
                        "Equilibra sorte (Gols) e competência (xG).",
                        style: const TextStyle(fontSize: 11, color: Colors.grey)
                    ),
                  ],
                ),
              ),
            ],
          ),
          Slider(
            value: _poissonPesoEficacia,
            onChanged: (v) => setState(() => _poissonPesoEficacia = v),
            min: 0.0,
            max: 1.0,
            divisions: 10,
            activeColor: Colors.teal,
            label: "${(_poissonPesoEficacia * 100).toInt()}%",
          ),

          const SizedBox(height: 8),
          Text("Fator Casa: ${_poissonFatorCasa.toStringAsFixed(2)}"),
          Slider(
            value: _poissonFatorCasa,
            onChanged: (v) => setState(() => _poissonFatorCasa = v),
            min: 0.0,
            max: 0.2,
            divisions: 20,
            label: _poissonFatorCasa.toStringAsFixed(2),
          ),
          Text("Fator Liga: ${_poissonFatorLiga.toStringAsFixed(2)}"),
          Slider(
            value: _poissonFatorLiga,
            onChanged: (v) => setState(() => _poissonFatorLiga = v),
            min: 0.9,
            max: 1.1,
            divisions: 20,
            label: _poissonFatorLiga.toStringAsFixed(2),
          ),

          // CONTROLE: SUAVIZAÇÃO
          const Divider(),
          Row(
            children: [
              const Icon(Icons.blur_linear, color: Colors.blueGrey),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Suavização de Outliers: ${(_poissonSuavizacao * 100).toInt()}%", style: const TextStyle(fontWeight: FontWeight.bold)),
                    const Text("Reduz o impacto de goleadas atípicas (Regressão à Média).", style: TextStyle(fontSize: 11, color: Colors.grey)),
                  ],
                ),
              ),
            ],
          ),
          Slider(
            value: _poissonSuavizacao,
            onChanged: (v) => setState(() => _poissonSuavizacao = v),
            min: 0.5,
            max: 1.0,
            divisions: 10,
            activeColor: Colors.blueGrey,
            label: "${(_poissonSuavizacao * 100).toInt()}%",
          ),

          // NOVO CONTROLE: AJUSTE 0x0
          const Divider(),
          Row(
            children: [
              const Icon(Icons.lock_clock, color: Colors.deepOrange),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Correção '8 ou 80' (Inflação de 0x0): ${(_poissonAjusteZero * 100).toInt()}%", style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.deepOrange)),
                    const Text("Aumenta a chance de 0x0 para times inconstantes.", style: TextStyle(fontSize: 11, color: Colors.grey)),
                  ],
                ),
              ),
            ],
          ),
          Slider(
            value: _poissonAjusteZero,
            onChanged: (v) => setState(() => _poissonAjusteZero = v),
            min: 0.0,
            max: 0.30,
            divisions: 6,
            activeColor: Colors.deepOrange,
            label: "+${(_poissonAjusteZero * 100).toInt()}%",
          ),

          // NOVO CONTROLE: AJUSTE ELÁSTICO
          const Divider(),
          Row(
            children: [
              const Icon(Icons.flash_on, color: Colors.purpleAccent),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Fator Caos (Goleada/Elástico): ${(_poissonAjusteElasticidade * 100).toInt()}%", style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.purpleAccent)),
                    const Text("Simula jogos abertos (expulsão/descontrole) aumentando chances de 4+ gols.", style: TextStyle(fontSize: 11, color: Colors.grey)),
                  ],
                ),
              ),
            ],
          ),
          Slider(
            value: _poissonAjusteElasticidade,
            onChanged: (v) => setState(() => _poissonAjusteElasticidade = v),
            min: 0.0,
            max: 0.30,
            divisions: 6,
            activeColor: Colors.purpleAccent,
            label: "+${(_poissonAjusteElasticidade * 100).toInt()}%",
          ),

          const Divider(height: 30),
          const Text("💵 Odds (opcional)"),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _poissonOddCasaCtrl,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  decoration: const InputDecoration(labelText: "Odd Casa", border: OutlineInputBorder()),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextField(
                  controller: _poissonOddEmpateCtrl,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  decoration: const InputDecoration(labelText: "Odd Empate", border: OutlineInputBorder()),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextField(
                  controller: _poissonOddForaCtrl,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  decoration: const InputDecoration(labelText: "Odd Fora", border: OutlineInputBorder()),
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: _onCalcularPoisson,
            icon: const Icon(Icons.calculate),
            label: const Text("Calcular Probabilidades"),
            style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 12)),
          ),

          if (_resultadoPoisson != null) ...[
            const Divider(height: 30),

            // Botão de salvar card ao lado do título Resultados
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("📈 Resultados", style: TextStyle(fontWeight: FontWeight.bold)),
                ElevatedButton.icon(
                  onPressed: _salvarCardPoisson,
                  icon: Icon(_idPoissonEmEdicao != null ? Icons.update : Icons.save_alt, size: 16),
                  label: Text(_idPoissonEmEdicao != null ? "Atualizar Card" : "Gerar Card Vinculável"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.indigo,
                    foregroundColor: Colors.white,
                    visualDensity: VisualDensity.compact,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),

            Card(
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Média Liga: ${_poissonMediaLigaCtrl.text}"),

                    // Display xG vs Gols Info
                    _buildEficaciaInfo(_resultadoPoisson!['eficacia']),
                    const SizedBox(height: 8),

                    Text("Força Atk (Mix) — Casa: ${_fmt2(_resultadoPoisson!['lambdaCasa'])} | Fora: ${_fmt2(_resultadoPoisson!['lambdaFora'])}"),
                    const Divider(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Column(children: [
                          const Text("Casa"),
                          Text(_fmtPct(_resultadoPoisson!['pCasa']), style: TextStyle(color: _corValor(_resultadoPoisson!['pCasa']), fontWeight: FontWeight.bold, fontSize: 18)),
                          Text("Justa: ${_fmt2(1 / _resultadoPoisson!['pCasa'])}"),
                        ]),
                        Column(children: [
                          const Text("Empate"),
                          Text(_fmtPct(_resultadoPoisson!['pEmpate']), style: TextStyle(color: _corValor(_resultadoPoisson!['pEmpate']), fontWeight: FontWeight.bold, fontSize: 18)),
                          Text("Justa: ${_fmt2(1 / _resultadoPoisson!['pEmpate'])}"),
                        ]),
                        Column(children: [
                          const Text("Fora"),
                          Text(_fmtPct(_resultadoPoisson!['pFora']), style: TextStyle(color: _corValor(_resultadoPoisson!['pFora']), fontWeight: FontWeight.bold, fontSize: 18)),
                          Text("Justa: ${_fmt2(1 / _resultadoPoisson!['pFora'])}"),
                        ]),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _buildDoubleChanceItem("1X", _resultadoPoisson!['p1X']),
                          _buildDoubleChanceItem("12", _resultadoPoisson!['p12']),
                          _buildDoubleChanceItem("X2", _resultadoPoisson!['pX2']),
                        ],
                      ),
                    ),
                    const Divider(),
                    _finalProbabilidadesGols(_resultadoPoisson!),
                    const Divider(),
                    _finalPlacarPoisson(_resultadoPoisson!),
                    if (_resultadoPoisson!.containsKey('value')) ...[
                      const Divider(),
                      _finalValueBetPoisson(_resultadoPoisson!),
                    ],
                  ],
                ),
              ),
            ),
          ],

          const Divider(height: 40, thickness: 2),
          const Text("📚 Cards Poisson Salvos (Não Vinculados)", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          _buildListaCardsPoisson(),
        ],
      ),
    );
  }

  // Novo Widget para lista de cards Poisson
  Widget _buildListaCardsPoisson() {
    final unlinkedCards = _listaCardsPoisson.where((c) => c['linkedBetId'] == null).toList();

    if (unlinkedCards.isEmpty) {
      return const Center(child: Text("Nenhum card salvo.", style: TextStyle(color: Colors.grey)));
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: unlinkedCards.length,
      itemBuilder: (context, index) {
        final card = unlinkedCards[index];
        final res = card['resultados'] as Map<String, dynamic>;
        // Acessa as probabilidades de gols salvas
        final probGols = res['probGols'] as Map<String, dynamic>?;

        final mandante = card['mandante'] ?? 'Casa';
        final visitante = card['visitante'] ?? 'Fora';
        final camp = card['campeonato'] ?? '';

        return Card(
          elevation: 2,
          margin: const EdgeInsets.only(bottom: 8),
          child: ExpansionTile(
            tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            title: Text("$mandante x $visitante", style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (camp.isNotEmpty) Text(camp, style: const TextStyle(fontSize: 11, fontStyle: FontStyle.italic)),
                const SizedBox(height: 4),
                Text(
                  "1x2: ${_fmtPct(res['pCasa'])} - ${_fmtPct(res['pEmpate'])} - ${_fmtPct(res['pFora'])}",
                  style: const TextStyle(fontSize: 12, color: Colors.black87),
                ),
                Text(
                  "Justa (1x2): ${_fmt2(1/res['pCasa'])} - ${_fmt2(1/res['pEmpate'])} - ${_fmt2(1/res['pFora'])}",
                  style: const TextStyle(fontSize: 11, color: Colors.grey),
                ),
              ],
            ),
            children: [
              if (probGols != null)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                  child: Column(
                    children: [
                      const Divider(),
                      const Text("⚽ Probabilidades de Gols", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                      const SizedBox(height: 8),
                      _buildLinhaGolCard("1.5", probGols),
                      _buildLinhaGolCard("2.5", probGols),
                      _buildLinhaGolCard("3.5", probGols),
                      _buildLinhaGolCard("4.5", probGols),
                      const SizedBox(height: 8),
                      Text(
                        "BTTS (Sim): ${_fmtPct(probGols['Ambos Marcam (Sim)']['prob'])} (@${_fmt2(probGols['Ambos Marcam (Sim)']['oddJusta'])})",
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.indigo.shade700),
                      ),
                    ],
                  ),
                ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton.icon(
                      icon: const Icon(Icons.edit, size: 16, color: Colors.blue),
                      label: const Text("Editar"),
                      onPressed: () => _editarCardPoisson(card),
                    ),
                    TextButton.icon(
                      icon: const Icon(Icons.delete, size: 16, color: Colors.red),
                      label: const Text("Excluir"),
                      onPressed: () => _excluirCardPoisson(card['id']),
                    ),
                  ],
                ),
              )
            ],
          ),
        );
      },
    );
  }

  Widget _buildLinhaGolCard(String linha, Map<String, dynamic> probGols) {
    final over = probGols['Over $linha'];
    final under = probGols['Under $linha'];
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text("Over $linha: ${_fmtPct(over['prob'])} (@${_fmt2(over['oddJusta'])})", style: TextStyle(fontSize: 11, color: Colors.green.shade700)),
          Text("Under $linha: ${_fmtPct(under['prob'])} (@${_fmt2(under['oddJusta'])})", style: TextStyle(fontSize: 11, color: Colors.red.shade700)),
        ],
      ),
    );
  }

  Widget _buildDoubleChanceItem(String label, double prob) {
    return Column(
      children: [
        Text(label, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.grey)),
        Text("${(prob * 100).toStringAsFixed(1)}%", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
        Text("Odd: ${(1/prob).toStringAsFixed(2)}", style: const TextStyle(fontSize: 10, color: Colors.grey)),
      ],
    );
  }

  // Widget para mostrar badges de eficácia
  Widget _buildEficaciaInfo(Map<String, dynamic> eficacia) {
    double efCasa = eficacia['casa'];
    double efFora = eficacia['fora'];

    Widget badge(String label, double val) {
      Color c = Colors.grey;
      String t = "Normal";
      if (val > 1.15) { c = Colors.green; t = "Matador 🎯"; }
      else if (val < 0.85) { c = Colors.red; t = "Perdulário ⚠️"; }

      return Chip(
        label: Text("$label: ${val.toStringAsFixed(2)} ($t)", style: const TextStyle(fontSize: 10, color: Colors.white)),
        backgroundColor: c,
        visualDensity: VisualDensity.compact,
        padding: EdgeInsets.zero,
      );
    }

    return Wrap(
      spacing: 8,
      children: [
        badge("Efic. Casa", efCasa),
        badge("Efic. Fora", efFora),
      ],
    );
  }

  // ================== WIDGETS AUXILIARES ==================
  Widget _buildResultadoHistorico() {
    final analise = _analiseHistorico!;
    final probabilidadeFinal = analise['probabilidadeFinal'] as double;
    final probOdd = analise['probabilidadeOdd'] as double?;
    final probHist = analise['probabilidadeHistoricoMedia'] as double;
    final detalhes = analise['detalhesHistorico'] as Map<String, dynamic>;

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("📊 Resultado da Análise", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const Divider(height: 20),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: _getCorPorProbabilidade(probabilidadeFinal).withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
              child: Center(
                child: Column(
                  children: [
                    const Text("Probabilidade Final (Média)"),
                    Text("${probabilidadeFinal.toStringAsFixed(1)}%", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: _getCorPorProbabilidade(probabilidadeFinal))),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                if (detalhes.isNotEmpty) Expanded(child: _buildInfoChip("Histórico", "${probHist.toStringAsFixed(1)}%", Colors.blue)),
                if (probOdd != null) Expanded(child: _buildInfoChip("Odd Mercado", "${probOdd.toStringAsFixed(1)}%", Colors.purple)),
              ],
            ),
            if (detalhes.isNotEmpty) ...[
              const SizedBox(height: 16),
              const Text("🔎 Detalhes por Filtro:", style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              ...detalhes.entries.map((entry) {
                final estat = entry.value as Map<String, dynamic>;
                return ListTile(
                  dense: true,
                  leading: const Icon(Icons.bar_chart, size: 20),
                  title: Text(entry.key),
                  trailing: Text("${(estat['taxa'] as num).toStringAsFixed(1)}% (${estat['total']} jogos)"),
                );
              }).toList(),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildInfoChip(String label, String value, Color color) {
    return Column(
      children: [
        Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        Chip(
          label: Text(value, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          backgroundColor: color,
          padding: const EdgeInsets.symmetric(horizontal: 8),
        ),
      ],
    );
  }

  Widget _buildAbaIA() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Card(
            color: Colors.blue.shade50,
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                children: [
                  Icon(Icons.info_outline, color: Colors.blue.shade700),
                  const SizedBox(height: 8),
                  const Text(
                    "Use os botões abaixo para obter diferentes tipos de análise da IA com base no seu histórico.",
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 13),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _carregando ? null : _mostrarDialogoOpcoesAnalise,
                  icon: const Icon(Icons.center_focus_strong),
                  label: const Text("Analisar Aposta Atual"),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _carregando ? null : _mostrarDialogoOpcoesAnaliseGeral,
                  icon: const Icon(Icons.travel_explore),
                  label: const Text("Gerar Análise Geral"),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    backgroundColor: Colors.deepPurple,
                    foregroundColor: Colors.white,
                  ),
                ),
              ),
            ],
          ),
          const Divider(height: 32),
          Expanded(
            child: Card(
              elevation: 2,
              clipBehavior: Clip.antiAlias,
              child: Stack(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: _carregando
                        ? const Center(child: CircularProgressIndicator())
                        : _analiseIAResultado == null
                        ? const Center(child: Text("Clique em um dos botões acima para gerar uma análise."))
                        : SingleChildScrollView(
                      padding: const EdgeInsets.only(top: 40),
                      child: SelectableText(_analiseIAResultado!),
                    ),
                  ),
                  if (_analiseIAResultado != null && _analiseIAResultado!.isNotEmpty && !_carregando)
                    Positioned(
                      top: 8,
                      right: 8,
                      child: IconButton(
                        icon: const Icon(Icons.copy_all_outlined),
                        tooltip: "Copiar Análise",
                        onPressed: _copiarAnaliseIA,
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _getCorPorProbabilidade(double prob) {
    if (prob >= 65) return Colors.green;
    if (prob >= 55) return Colors.lightGreen;
    if (prob >= 45) return Colors.orange;
    return Colors.red;
  }

  Widget _finalPlacarPoisson(Map<String, dynamic> r) {
    final pp = r['placarProvavel'] as Map<String, dynamic>;
    final hg = pp['hg'] as int;
    final ag = pp['ag'] as int;
    final p = (pp['p'] as double);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("🔮 Placar Provável", style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 6),
        Text("$hg x $ag  (${_fmtPct(p)})"),
      ],
    );
  }

  Widget _finalValueBetPoisson(Map<String, dynamic> r) {
    final v = r['value'] as Map<String, dynamic>;
    final aposta = v['aposta'];
    final det = v['detalhe'] as Map<String, dynamic>;
    final odd = det['odd'] as double;
    final fair = det['fair'] as double;
    final edge = (odd - fair);
    String _fmt2(double x) => x.toStringAsFixed(2);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("💡 Value Bet", style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 6),
        Text("Sugestão: $aposta | Odd: ${_fmt2(odd)} | Justa: ${_fmt2(fair)} | Edge: ${_fmt2(edge)}"),
      ],
    );
  }

  Widget _finalProbabilidadesGols(Map<String, dynamic> r) {
    final probGols = r['probGols'] as Map<String, dynamic>;
    String _fmtPct(double x) => "${(x * 100).toStringAsFixed(1)}%";
    String _fmtOdd(double x) => x.toStringAsFixed(2);

    Widget rowStats(String title, String keyOver, String keyUnder) {
      final over = probGols[keyOver];
      final under = probGols[keyUnder];
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 4.0),
        child: Row(
          children: [
            SizedBox(width: 65, child: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
            Expanded(child: Text("Over: ${_fmtPct(over['prob'])} (@${_fmtOdd(over['oddJusta'])})", style: TextStyle(fontSize: 12, color: Colors.green[700]))),
            Expanded(child: Text("Under: ${_fmtPct(under['prob'])} (@${_fmtOdd(under['oddJusta'])})", style: TextStyle(fontSize: 12, color: Colors.red[700]))),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("📈 Mercados de Gols", style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        rowStats("1.5 Gols", 'Over 1.5', 'Under 1.5'),
        rowStats("2.5 Gols", 'Over 2.5', 'Under 2.5'),
        rowStats("3.5 Gols", 'Over 3.5', 'Under 3.5'),
        rowStats("4.5 Gols", 'Over 4.5', 'Under 4.5'),
        const SizedBox(height: 8),
        const Text("🥅 Ambos Marcam", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
        Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Sim: ${_fmtPct(probGols['Ambos Marcam (Sim)']['prob'])} (@${_fmtOdd(probGols['Ambos Marcam (Sim)']['oddJusta'])})"),
              Text("Não: ${_fmtPct(probGols['Ambos Marcam (Não)']['prob'])} (@${_fmtOdd(probGols['Ambos Marcam (Não)']['oddJusta'])})"),
            ]
        )
      ],
    );
  }
}
// ===================================================================
// FIM DO BLOCO DA TELA EV+ (TELA 2 )
// ===================================================================


// ===================================================================
// INÍCIO DO BLOCO DA TELA DE VISAO GERAL ( TELA 3 )
// ===================================================================

class TelaSobra2 extends StatefulWidget {
  const TelaSobra2({super.key});

  @override
  State<TelaSobra2> createState() => _TelaSobra2State();
}

class _TelaSobra2State extends State<TelaSobra2> with SingleTickerProviderStateMixin {
  bool _isLoading = true;
  List<Map<String, dynamic>> _snapshots = []; // snapshots brutos (podem conter dataObj)

  // Mês selecionado (ano + mês)
  int _selectedYear = DateTime.now().year;
  int _selectedMonth = DateTime.now().month;

  // Ordenados (chave: 'YYYY-MM')
  List<String> _availableMonths = [];

  // Para expansão das seções de detalhe
  bool _showDetalhes = false;

  // Controle de Gráficos
  late TabController _chartTabController;

  @override
  void initState() {
    super.initState();
    // Inicializa o TabController para as 3 abas de gráficos
    _chartTabController = TabController(length: 3, vsync: this);
    _carregarSnapshots();
  }

  @override
  void dispose() {
    _chartTabController.dispose();
    super.dispose();
  }

  Future<File> _getDashboardFile() async {
    final dir = await getApplicationDocumentsDirectory();
    return File('${dir.path}/registros_apostas.json');
  }

  // MODIFICADO: Lógica de carregamento agora inicializa o Locale para evitar erros
  Future<void> _carregarSnapshots() async {
    setState(() => _isLoading = true);

    // CORREÇÃO TELA VERMELHA: Inicializa dados do idioma pt_BR
    // Requer: import 'package:intl/date_symbol_data_local.dart'; no topo do arquivo
    try {
      await initializeDateFormatting('pt_BR', null);
    } catch (e) {
      debugPrint("Erro ao inicializar locale: $e");
    }

    try {
      final file = await _getDashboardFile();
      if (await file.exists()) {
        final content = await file.readAsString();
        if (content.isNotEmpty) {
          final List<dynamic> decoded = jsonDecode(content);
          final List<Map<String, dynamic>> parsed = decoded.cast<Map<String, dynamic>>().map((snapshot) {
            // Normaliza campos e adiciona helper dateObj e chave mês
            final copy = Map<String, dynamic>.from(snapshot);

            // Algumas versões podem ter 'dataAtualizacao' ou 'ano'/'mes'
            DateTime? dt;
            if (copy.containsKey('dataAtualizacao')) {
              try {
                dt = DateTime.parse(copy['dataAtualizacao']);
              } catch (_) {
                // fallback para string dd/MM/yyyy HH:mm
                try {
                  dt = DateFormat('dd/MM/yyyy HH:mm').parse(copy['dataAtualizacao']);
                } catch (_) {
                  dt = null;
                }
              }
            }
            if (dt == null && copy.containsKey('ano') && copy.containsKey('mes')) {
              final y = (copy['ano'] as num).toInt();
              final m = (copy['mes'] as num).toInt();
              dt = DateTime(y, m, 1);
            }

            if (dt != null) {
              copy['dataObj'] = dt;
              copy['ano'] = dt.year;
              copy['mes'] = dt.month;
              copy['monthKey'] = _monthKeyFromDate(dt);
            } else {
              // Se não tem data, ignora essa entrada
              copy['monthKey'] = null;
            }

            // Garantir números em double
            copy['bancaAtual'] = (copy['bancaAtual'] as num?)?.toDouble() ?? 0.0;
            copy['lucroTotal'] = (copy['lucroTotal'] as num?)?.toDouble() ?? 0.0;
            copy['roi'] = (copy['roi'] as num?)?.toDouble() ?? 0.0;
            copy['yield'] = (copy['yield'] as num?)?.toDouble() ?? 0.0;

            // Profit Factor (pode vir como string "Infinito" ou numero)
            if (copy['profitFactor'] is String) {
              copy['profitFactor'] = 999.0;
            } else {
              copy['profitFactor'] = (copy['profitFactor'] as num?)?.toDouble() ?? 0.0;
            }

            copy['maxWinStreak'] = (copy['maxWinStreak'] as num?)?.toInt() ?? 0;
            copy['maxLoseStreak'] = (copy['maxLoseStreak'] as num?)?.toInt() ?? 0;
            copy['oddMedia'] = (copy['oddMedia'] as num?)?.toDouble() ?? 0.0;
            copy['taxaNecessariaBreakEven'] = (copy['taxaNecessariaBreakEven'] as num?)?.toDouble() ?? 0.0;

            // Tratamento especial para Max Drawdown
            if (copy['maxDrawdown'] is Map) {
              copy['maxDrawdownPct'] = (copy['maxDrawdown']['percentual'] as num?)?.toDouble() ?? 0.0;
              // Se vier 0.15, converte para 15.0 se necessário, mas geralmente salvamos já em %
              // Ajuste conforme salvamento: no salvamento multiplicamos por 100.
            } else {
              copy['maxDrawdownPct'] = (copy['maxDrawdown'] as num?)?.toDouble() ?? 0.0;
            }

            // ================== CORREÇÃO TAXA DE ACERTO ==================
            double? taxaAcerto = (copy['taxaAcerto'] as num?)?.toDouble();
            if (taxaAcerto == null || taxaAcerto == 0.0) { // Tenta (re)calcular se for nulo ou zero
              final sumario = copy['sumarioAnalise'] as Map<String, dynamic>?;
              if (sumario != null && (sumario['porTipo'] != null || sumario['porCampeonato'] != null)) {
                int totalVitorias = 0;
                int totalApostas = 0;
                // Usa 'porTipo' como fonte principal para somar
                final mapa = (sumario['porTipo'] ?? sumario['porCampeonato']) as Map<String, dynamic>;

                mapa.forEach((key, value) {
                  totalVitorias += (value['vitorias'] as int?) ?? 0;
                  totalApostas += (value['totalApostas'] as int?) ?? 0;
                });
                taxaAcerto = (totalApostas > 0) ? (totalVitorias / totalApostas * 100.0) : 0.0;
              } else {
                // Fallback (se não houver sumário, usa o que veio)
                taxaAcerto = taxaAcerto ?? 0.0;
              }
            }
            copy['taxaAcerto'] = taxaAcerto ?? 0.0;
            // ================== FIM DA CORREÇÃO ==================

            return copy;
          }).where((s) => s['monthKey'] != null).toList();

          // Mantém apenas 1 snapshot por mês: se houver mais de 1, usa o último (por dataObj)
          final Map<String, Map<String, dynamic>> byMonth = {};
          for (final s in parsed) {
            final key = s['monthKey'] as String;
            if (!byMonth.containsKey(key)) byMonth[key] = s;
            else {
              final prev = byMonth[key]!;
              final prevDt = prev['dataObj'] as DateTime?;
              final curDt = s['dataObj'] as DateTime?;
              if (curDt != null && prevDt != null && curDt.isAfter(prevDt)) byMonth[key] = s;
            }
          }

          final List<Map<String, dynamic>> finalList = byMonth.values.toList();
          // Ordena por data crescente
          finalList.sort((a, b) => (a['dataObj'] as DateTime).compareTo(b['dataObj'] as DateTime));

          setState(() {
            _snapshots = finalList;
            _availableMonths = _snapshots.map((s) => s['monthKey'] as String).toList();
            if (_availableMonths.isNotEmpty) {
              // Verifica se o mês selecionado existe, senão seleciona o último
              if (!_availableMonths.contains(_monthKeyFromParts(_selectedYear, _selectedMonth))) {
                final lastKey = _availableMonths.last;
                final parts = lastKey.split('-');
                _selectedYear = int.parse(parts[0]);
                _selectedMonth = int.parse(parts[1]);
              }
            }
            _isLoading = false;
          });
          return;
        }
      }

      // arquivo não existe ou vazio
      setState(() {
        _snapshots = [];
        _availableMonths = [];
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('Erro ao carregar snapshots: $e');
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao ler histórico: $e'), backgroundColor: Colors.red),
      );
    }
  }

  // Salva _snapshots (mantendo apenas campos serializáveis)
  Future<void> _salvarSnapshots() async {
    try {
      final file = await _getDashboardFile();
      final List<Map<String, dynamic>> out = _snapshots.map((s) {
        final c = Map<String, dynamic>.from(s);
        c.remove('dataObj');
        c['monthKey'] = _monthKeyFromParts((c['ano'] ?? 0) as int, (c['mes'] ?? 0) as int);
        return c;
      }).toList();

      await file.writeAsString(jsonEncode(out));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao salvar: $e'), backgroundColor: Colors.red),
      );
    }
  }

  String _monthKeyFromDate(DateTime dt) => '${dt.year.toString().padLeft(4, '0')}-${dt.month.toString().padLeft(2, '0')}';
  String _monthKeyFromParts(int y, int m) => '${y.toString().padLeft(4, '0')}-${m.toString().padLeft(2, '0')}';

  // Helper para obter o snapshot do mês atualmente selecionado
  Map<String, dynamic>? _getCurrentSnapshot() {
    return _snapshotForMonth(_selectedYear, _selectedMonth);
  }

  Map<String, dynamic>? _snapshotForMonth(int year, int month) {
    final key = _monthKeyFromParts(year, month);
    try {
      return _snapshots.firstWhere((s) => s['monthKey'] == key);
    } catch (_) {
      return null;
    }
  }

  void _changeMonth(int direction) {
    setState(() {
      final dt = DateTime(_selectedYear, _selectedMonth + direction);
      _selectedYear = dt.year;
      _selectedMonth = dt.month;
    });
  }

  void _previousMonth() {
    _changeMonth(-1);
  }

  void _nextMonth() {
    _changeMonth(1);
  }

  // Gera lista de pontos para gráfico mensal (um ponto por mês disponível)
  List<FlSpot> _gerarSpotsMensais(String metric) {
    final List<FlSpot> spots = [];
    // Usamos índice 0..n para meses ordenados
    for (int i = 0; i < _availableMonths.length; i++) {
      final key = _availableMonths[i];
      final parts = key.split('-');
      final y = int.parse(parts[0]);
      final m = int.parse(parts[1]);
      final snap = _snapshotForMonth(y, m);
      double value = 0.0;
      if (snap != null) {
        if (metric == 'banca') value = (snap['bancaAtual'] as num?)?.toDouble() ?? 0.0;
        else if (metric == 'lucro') value = (snap['lucroTotal'] as num?)?.toDouble() ?? 0.0;
        else if (metric == 'roi') value = (snap['roi'] as num?)?.toDouble() ?? 0.0;
        else if (metric == 'yield') value = (snap['yield'] as num?)?.toDouble() ?? 0.0;
      }
      spots.add(FlSpot(i.toDouble(), value));
    }

    if (spots.isEmpty) return [const FlSpot(0, 0)];
    // Se tiver apenas um ponto, duplica para criar uma linha visível
    if (spots.length == 1) spots.add(FlSpot(1, spots[0].y));
    return spots;
  }

  // Widget do gráfico resumido mensal
  Widget _buildGraficoMensal({required String title, required String metric, required String yLabel}) {
    final spots = _gerarSpotsMensais(metric);
    final allY = spots.map((s) => s.y).toList();

    // Tratamento seguro para min/max
    double minY = 0.0;
    double maxY = 0.0;

    if (allY.isNotEmpty) {
      minY = allY.reduce(min);
      maxY = allY.reduce(max);
    }

    double range = maxY - minY;
    if (range.abs() < 1) {
      minY -= 1;
      maxY += 1;
    } else {
      minY -= range * 0.1;
      maxY += range * 0.1;
    }

    // Calcula maxX baseado no número de meses disponíveis
    // Se tivermos 1 mês (length 1), spots terá 2 pontos (0 e 1), então maxX deve ser 1
    double maxX = (_availableMonths.length - 1).toDouble();
    if (maxX < 1.0) maxX = 1.0;

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            SizedBox(
              height: 180,
              child: LineChart(
                LineChartData(
                  gridData: FlGridData(show: true),
                  titlesData: FlTitlesData(
                    bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, getTitlesWidget: (v, meta) {
                      final idx = v.toInt();
                      if (idx < 0 || idx >= _availableMonths.length) return const Text('');

                      // Evita poluição se houver muitos meses
                      if (_availableMonths.length > 6 && idx % 2 != 0) return const SizedBox();

                      final key = _availableMonths[idx];
                      final parts = key.split('-');
                      final y = int.parse(parts[0]);
                      final m = int.parse(parts[1]);
                      return SideTitleWidget(axisSide: meta.axisSide, child: Text(DateFormat('MM/yyyy').format(DateTime(y, m)), style: const TextStyle(fontSize: 10)));
                    }, reservedSize: 40)),
                    leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 45, getTitlesWidget: (v, meta) => Text('$yLabel${v.toInt()}', style: const TextStyle(fontSize: 10)))),
                    topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  ),
                  borderData: FlBorderData(show: true),
                  minX: 0,
                  maxX: maxX, // Usa o maxX corrigido
                  minY: minY,
                  maxY: maxY,
                  lineBarsData: [
                    LineChartBarData(
                      spots: spots,
                      isCurved: true,
                      color: Colors.indigo,
                      barWidth: 3,
                      isStrokeCapRound: true,
                      dotData: const FlDotData(show: false),
                      belowBarData: BarAreaData(show: true, color: Colors.blue.withOpacity(0.2)),
                    )
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  // --- WIDGETS DE PERFORMANCE E RANKING ---

  Widget _buildMetricCard(String label, String value, {Color? valueColor, IconData? icon, String? subValue, Color? subColor}) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              children: [
                Icon(icon ?? Icons.analytics, size: 16, color: Colors.grey),
                const SizedBox(width: 6),
                Expanded(child: Text(label, style: const TextStyle(fontSize: 11, color: Colors.grey, fontWeight: FontWeight.bold), overflow: TextOverflow.ellipsis)),
              ],
            ),
            const SizedBox(height: 8),
            Text(value, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: valueColor ?? Colors.black87)),
            if (subValue != null) ...[
              const SizedBox(height: 4),
              Text(subValue, style: TextStyle(fontSize: 10, color: subColor ?? Colors.grey.shade600)),
            ]
          ],
        ),
      ),
    );
  }

  Widget _buildPerformanceGrid(Map<String, dynamic> snap) {
    final banca = (snap['bancaAtual'] as num?)?.toDouble() ?? 0.0;
    final lucro = (snap['lucroTotal'] as num?)?.toDouble() ?? 0.0;
    final roi = (snap['roi'] as num?)?.toDouble() ?? 0.0;
    final yieldPct = (snap['yield'] as num?)?.toDouble() ?? 0.0;

    final pf = (snap['profitFactor'] as num?)?.toDouble() ?? 0.0;
    final taxaAcerto = (snap['taxaAcerto'] as num?)?.toDouble() ?? 0.0;
    final taxaBE = (snap['taxaNecessariaBreakEven'] as num?)?.toDouble() ?? 0.0;

    final dd = (snap['maxDrawdownPct'] as num?)?.toDouble() ?? 0.0;
    final winStreak = (snap['maxWinStreak'] as num?)?.toInt() ?? 0;
    final loseStreak = (snap['maxLoseStreak'] as num?)?.toInt() ?? 0;

    return Column(
      children: [
        Row(
          children: [
            Expanded(child: _buildMetricCard("BANCA", "R\$ ${banca.toStringAsFixed(0)}", icon: Icons.account_balance_wallet, valueColor: Colors.indigo)),
            Expanded(child: _buildMetricCard("LUCRO", "R\$ ${lucro.toStringAsFixed(0)}", icon: Icons.attach_money, valueColor: lucro >= 0 ? Colors.green : Colors.red)),
          ],
        ),
        Row(
          children: [
            Expanded(child: _buildMetricCard("ROI", "${roi.toStringAsFixed(1)}%", icon: Icons.trending_up, valueColor: roi >= 0 ? Colors.green.shade700 : Colors.red.shade700)),
            Expanded(child: _buildMetricCard("YIELD", "${yieldPct.toStringAsFixed(1)}%", icon: Icons.pie_chart, valueColor: Colors.blue.shade700)),
          ],
        ),

        const SizedBox(height: 16),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 8.0),
          child: Align(alignment: Alignment.centerLeft, child: Text("PERFORMANCE & RISCO", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey))),
        ),
        const SizedBox(height: 8),

        Row(
          children: [
            Expanded(child: _buildMetricCard("TAXA ACERTO", "${taxaAcerto.toStringAsFixed(1)}%", icon: Icons.check_circle, subValue: "Min: ${taxaBE.toStringAsFixed(1)}% (BE)", subColor: taxaAcerto > taxaBE ? Colors.green : Colors.red)),
            Expanded(child: _buildMetricCard("PROFIT FACTOR", pf > 100 ? ">100" : pf.toStringAsFixed(2), icon: Icons.scale, valueColor: pf >= 1.0 ? Colors.green : Colors.orange)),
          ],
        ),
        Row(
          children: [
            Expanded(child: _buildMetricCard("MAX DRAWDOWN", "${dd.toStringAsFixed(1)}%", icon: Icons.water_drop, valueColor: Colors.red)),
            Expanded(child: _buildMetricCard("SEQUÊNCIAS", "W:$winStreak / L:$loseStreak", icon: Icons.history_toggle_off, subValue: "Max Win / Max Loss")),
          ],
        ),
      ],
    );
  }

  Widget _buildRankingExpansion(Map<String, dynamic> snap) {
    final sum = snap['sumarioAnalise'] as Map<String, dynamic>?;
    if (sum == null) return const SizedBox.shrink();

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ExpansionTile(
        title: const Text("Destaques do Mês (Top 3)", style: TextStyle(fontWeight: FontWeight.bold)),
        leading: const Icon(Icons.emoji_events, color: Colors.amber),
        children: [
          _buildRankRow("Melhores Ligas", sum['porCampeonato'] as Map<String, dynamic>?),
          const Divider(),
          _buildRankRow("Melhores Mercados", sum['porTipo'] as Map<String, dynamic>?),
          const Divider(),
          _buildRankRow("Melhores Times", sum['porTime'] as Map<String, dynamic>?),
          const SizedBox(height: 12),
        ],
      ),
    );
  }

  Widget _buildRankRow(String title, Map<String, dynamic>? data) {
    if (data == null || data.isEmpty) return const Padding(padding: EdgeInsets.all(16), child: Text("Sem dados"));

    final sorted = data.entries.toList()..sort((a, b) => ((b.value['lucro'] as num?) ?? 0).compareTo((a.value['lucro'] as num?) ?? 0));
    final top3 = sorted.take(3).toList();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: TextStyle(fontSize: 12, color: Colors.grey.shade700, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          ...top3.map((e) {
            final lucro = (e.value['lucro'] as num?)?.toDouble() ?? 0.0;
            return Padding(
              padding: const EdgeInsets.only(bottom: 4.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(child: Text(e.key, style: const TextStyle(fontSize: 13), overflow: TextOverflow.ellipsis)),
                  Text(
                      "R\$ ${lucro.toStringAsFixed(0)}",
                      style: TextStyle(color: lucro >= 0 ? Colors.green : Colors.red, fontWeight: FontWeight.bold, fontSize: 13)
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  // Lista resumida de meses gravados (para controle e deleção)
  Widget _buildListaMeses() {
    if (_availableMonths.isEmpty) {
      return const Center(child: Text('Nenhum snapshot mensal registrado.'));
    }

    return Column(
      children: _availableMonths.reversed.map((key) {
        final parts = key.split('-');
        final y = int.parse(parts[0]);
        final m = int.parse(parts[1]);
        final snap = _snapshotForMonth(y, m);
        final banca = (snap?['bancaAtual'] as num?)?.toDouble() ?? 0.0;
        final lucro = (snap?['lucroTotal'] as num?)?.toDouble() ?? 0.0;
        final roi = (snap?['roi'] as num?)?.toDouble() ?? 0.0;

        return Card(
          margin: const EdgeInsets.symmetric(vertical: 6),
          child: ListTile(
            title: Text(DateFormat('MMMM yyyy').format(DateTime(y, m))),
            subtitle: Text('Banca: R\$ ${banca.toStringAsFixed(2)} | Lucro: R\$ ${lucro.toStringAsFixed(2)} | ROI: ${roi.toStringAsFixed(1)}%'),
            trailing: IconButton(
              icon: Icon(Icons.delete_outline, color: Theme.of(context).colorScheme.error),
              onPressed: () => _excluirMes(key),
              tooltip: 'Excluir mês',
            ),
            onTap: () {
              setState(() {
                _selectedYear = y;
                _selectedMonth = m;
              });
            },
          ),
        );
      }).toList(),
    );
  }

  Future<void> _excluirMes(String monthKey) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (c) => AlertDialog(
        title: const Text('Excluir Snapshot Mensal'),
        content: const Text('Deseja realmente excluir este mês do histórico?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(c, false), child: const Text('Cancelar')),
          TextButton(onPressed: () => Navigator.pop(c, true), child: const Text('Confirmar')),
        ],
      ),
    );

    if (confirm != true) return;

    setState(() {
      _snapshots.removeWhere((s) => s['monthKey'] == monthKey);
      _availableMonths.removeWhere((k) => k == monthKey);
      if (_availableMonths.isNotEmpty) {
        final last = _availableMonths.last;
        final p = last.split('-');
        _selectedYear = int.parse(p[0]);
        _selectedMonth = int.parse(p[1]);
      }
    });

    await _salvarSnapshots();
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Mês excluído'), backgroundColor: Colors.green));
  }

  // --- UI Principal ---
  @override
  Widget build(BuildContext context) {
    final currentSnap = _getCurrentSnapshot();

    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        title: const Text('Visão Geral da Performance'),
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black87,
        actions: [
          IconButton(onPressed: _carregarSnapshots, icon: const Icon(Icons.refresh)),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _snapshots.isEmpty
          ? const Center(child: Text("Nenhum histórico mensal encontrado."))
          : SingleChildScrollView(
        padding: const EdgeInsets.only(bottom: 40),
        child: Column(
          children: [
            // 1. SELETOR DE MÊS
            Container(
              color: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(onPressed: () => _changeMonth(-1), icon: const Icon(Icons.chevron_left)),
                  Text(
                    DateFormat('MMMM yyyy', 'pt_BR').format(DateTime(_selectedYear, _selectedMonth)).toUpperCase(),
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 1),
                  ),
                  IconButton(onPressed: () => _changeMonth(1), icon: const Icon(Icons.chevron_right)),
                ],
              ),
            ),

            if (currentSnap == null)
              Padding(
                padding: const EdgeInsets.all(32.0),
                child: Column(
                  children: [
                    Icon(Icons.query_stats, size: 60, color: Colors.grey.shade300),
                    const SizedBox(height: 16),
                    const Text("Sem dados registrados neste mês.", style: TextStyle(color: Colors.grey)),
                  ],
                ),
              )
            else ...[
              // 2. GRIDS DE KPI
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: _buildPerformanceGrid(currentSnap),
              ),

              // 3. GRÁFICOS
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
                child: Column(
                  children: [
                    TabBar(
                      controller: _chartTabController,
                      labelColor: Colors.indigo,
                      unselectedLabelColor: Colors.grey,
                      indicatorColor: Colors.indigo,
                      tabs: const [Tab(text: "Banca"), Tab(text: "ROI %"), Tab(text: "Yield %")],
                    ),
                    SizedBox(
                      height: 250,
                      child: TabBarView(
                        controller: _chartTabController,
                        children: [
                          _buildGraficoMensal(title: 'Evolução da Banca', metric: 'banca', yLabel: 'R\$ '),
                          _buildGraficoMensal(title: 'Evolução do ROI', metric: 'roi', yLabel: '% '),
                          _buildGraficoMensal(title: 'Evolução do Yield', metric: 'yield', yLabel: '% '),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // 4. RANKINGS (TOP 3)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12.0),
                child: _buildRankingExpansion(currentSnap),
              ),
            ],

            const SizedBox(height: 16),

            // 5. LISTA DE MESES PARA GESTÃO
            const Divider(),
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Text('Histórico de Meses', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
            ),
            _buildListaMeses(),

            // Botão de Exportação
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Center(
                child: ElevatedButton.icon(
                  onPressed: _showExportDialog,
                  icon: const Icon(Icons.download),
                  label: const Text('Exportar Todos os Dados JSON'),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildMonthSelectorBar() {
    final hasData = _availableMonths.isNotEmpty;

    return Row(
      children: [
        IconButton(onPressed: _previousMonth, icon: const Icon(Icons.arrow_left)),
        Expanded(
          child: Center(
            child: Text(
              DateFormat('MMMM yyyy').format(DateTime(_selectedYear, _selectedMonth)),
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
        ),
        IconButton(onPressed: _nextMonth, icon: const Icon(Icons.arrow_right)),
        const SizedBox(width: 8),
        DropdownButton<String>(
          hint: const Text('Ir para mês'),
          value: hasData ? _monthKeyFromParts(_selectedYear, _selectedMonth) : null,
          items: _availableMonths.map((k) {
            final p = k.split('-');
            final y = int.parse(p[0]);
            final m = int.parse(p[1]);
            return DropdownMenuItem(value: k, child: Text(DateFormat('MMMM yyyy').format(DateTime(y, m))));
          }).toList(),
          onChanged: (val) {
            if (val == null) return;
            final p = val.split('-');
            setState(() {
              _selectedYear = int.parse(p[0]);
              _selectedMonth = int.parse(p[1]);
            });
          },
        ),
      ],
    );
  }

  // Export simples JSON (abre diálogo com o conteúdo para copiar)
  void _showExportDialog() {
    final exportData = jsonEncode(_snapshots.map((s) {
      final c = Map<String, dynamic>.from(s);
      c.remove('dataObj');
      return c;
    }).toList());

    showDialog<void>(
      context: context,
      builder: (c) => AlertDialog(
        title: const Text('Exportar JSON'),
        content: SingleChildScrollView(child: SelectableText(exportData)),
        actions: [TextButton(onPressed: () => Navigator.pop(c), child: const Text('Fechar'))],
      ),
    );
  }
}
// ===================================================================
// FIM DO BLOCO DA TELA DE VISAO GERAL ( TELA 3 )
// ===================================================================


// ===================================================================
// INÍCIO DO BLOCO DA TELA REGRAS ( TELA 4 )
// ===================================================================
class TelaSobra3 extends StatefulWidget {
  const TelaSobra3({super.key});

  @override
  State<TelaSobra3> createState() => _TelaSobra3State();
}

class _TelaSobra3State extends State<TelaSobra3> with SingleTickerProviderStateMixin {
  List<Map<String, dynamic>> _blocosDeRegras = [];
  List<Map<String, dynamic>> _blocosFiltrados = [];
  List<Map<String, dynamic>> _playbooks = [];
  bool _isLoading = true;
  late TabController _tabController;

  // Controle de Busca
  final TextEditingController _searchCtrl = TextEditingController();
  final TextEditingController _playbookSearchCtrl = TextEditingController();
  String _termoBusca = "";
  String _termoBuscaPlaybook = "";

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _carregarRegras();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchCtrl.dispose();
    _playbookSearchCtrl.dispose();
    super.dispose();
  }

  // --- Funções de Leitura/Escrita de Arquivo ---
  Future<File> _getRegrasFile() async {
    final dir = await getApplicationDocumentsDirectory();
    return File("${dir.path}/regras_apostas.json");
  }

  Future<File> _getApostasFile() async {
    final dir = await getApplicationDocumentsDirectory();
    return File("${dir.path}/apostas_data.json");
  }

  Future<void> _carregarRegras() async {
    setState(() => _isLoading = true);
    try {
      final file = await _getRegrasFile();
      if (await file.exists()) {
        final data = await file.readAsString();
        if (data.isNotEmpty) {
          final decoded = jsonDecode(data);
          if (decoded is List) {
            if (decoded.isNotEmpty && decoded.first.containsKey('conjuntos')) {
              final blocosCarregados = decoded.cast<Map<String, dynamic>>();
              for (var bloco in blocosCarregados) {
                bloco.putIfAbsent('isExpanded', () => true);
                if (bloco['conjuntos'] != null) {
                  for (var conjunto in bloco['conjuntos']) {
                    // Garante campo de regras como lista
                    if (conjunto['regras'] is String) {
                      final str = conjunto['regras'] as String;
                      conjunto['regras'] = str.isEmpty ? <String>[] : str.split('\n');
                    } else if (conjunto['regras'] == null) {
                      conjunto['regras'] = <String>[];
                    }
                    // Garante flag isApostaDireta
                    conjunto.putIfAbsent('isApostaDireta', () => false);
                  }
                }
              }
              _blocosDeRegras = blocosCarregados;
            } else {
              _blocosDeRegras = [];
            }
          }
        }
      }
    } catch (e) {
      debugPrint("Erro ao carregar regras: $e");
    }
    await _carregarPlaybooks();
    _filtrarBlocos();
    setState(() => _isLoading = false);
  }

  Future<void> _carregarPlaybooks() async {
    try {
      final file = await _getApostasFile();
      if (!await file.exists()) {
        _playbooks = [];
        return;
      }
      final data = await file.readAsString();
      if (data.isEmpty) {
        _playbooks = [];
        return;
      }
      final decoded = jsonDecode(data);
      if (decoded is Map && decoded['playbooks'] is List) {
        _playbooks = List<Map<String, dynamic>>.from(decoded['playbooks']);
      } else {
        _playbooks = [];
      }
    } catch (e) {
      debugPrint("Erro ao carregar playbooks: $e");
      _playbooks = [];
    }
  }

  Future<void> _salvarPlaybooks() async {
    try {
      final file = await _getApostasFile();
      Map<String, dynamic> decoded = {};
      if (await file.exists()) {
        final content = await file.readAsString();
        if (content.isNotEmpty) {
          final parsed = jsonDecode(content);
          if (parsed is Map<String, dynamic>) {
            decoded = parsed;
          }
        }
      }

      decoded['playbooks'] = _playbooks;
      await file.writeAsString(jsonEncode(decoded));
    } catch (e) {
      debugPrint("Erro ao salvar playbooks: $e");
    }
  }

  Future<void> _salvarRegras() async {
    try {
      final file = await _getRegrasFile();
      await file.writeAsString(jsonEncode(_blocosDeRegras));
    } catch (e) {
      debugPrint("Erro ao salvar regras: $e");
    }
  }

  // --- Lógica de Busca ---
  void _filtrarBlocos() {
    if (_termoBusca.isEmpty) {
      setState(() => _blocosFiltrados = List.from(_blocosDeRegras));
    } else {
      final termo = _termoBusca.toLowerCase();
      setState(() {
        _blocosFiltrados = _blocosDeRegras.where((bloco) {
          final tituloBloco = (bloco['titulo'] ?? '').toLowerCase();
          final conjuntos = bloco['conjuntos'] as List? ?? [];
          final temConjuntoMatch = conjuntos.any((c) {
            final t = (c['titulo'] ?? '').toLowerCase();
            final rList = (c['regras'] as List? ?? []).join(' ').toLowerCase();
            return t.contains(termo) || rList.contains(termo);
          });
          return tituloBloco.contains(termo) || temConjuntoMatch;
        }).toList();
      });
    }
  }

  // --- Lógica de Drag & Drop ---
  void _onReorder(int oldIndex, int newIndex) {
    setState(() {
      if (newIndex > oldIndex) newIndex -= 1;
      final item = _blocosDeRegras.removeAt(oldIndex);
      _blocosDeRegras.insert(newIndex, item);
      _filtrarBlocos();
    });
    _salvarRegras();
  }

  // --- Funções de Diálogo (CRUD) ---

  Future<void> _dialogAdicionarEditarBloco({Map<String, dynamic>? blocoExistente}) async {
    final tituloCtrl = TextEditingController(text: blocoExistente?['titulo'] ?? '');
    final isEditing = blocoExistente != null;
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(isEditing ? "Editar Bloco" : "Novo Bloco"),
        content: TextField(
          controller: tituloCtrl,
          textCapitalization: TextCapitalization.sentences,
          decoration: const InputDecoration(labelText: "Título", border: OutlineInputBorder()),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancelar")),
          ElevatedButton(onPressed: () {
            if(tituloCtrl.text.isEmpty) return;
            setState(() {
              if(isEditing) {
                blocoExistente!['titulo'] = tituloCtrl.text;
              } else {
                _blocosDeRegras.add({
                  'id': 'bloco_${DateTime.now().millisecondsSinceEpoch}',
                  'titulo': tituloCtrl.text,
                  'conjuntos': [],
                  'isExpanded': true
                });
              }
            });
            _salvarRegras();
            _filtrarBlocos();
            Navigator.pop(context);
          }, child: const Text("Salvar")),
        ],
      ),
    );
  }

  Future<void> _dialogAdicionarEditarConjunto({required Map<String, dynamic> bloco, Map<String, dynamic>? conjuntoExistente}) async {
    final tituloCtrl = TextEditingController(text: conjuntoExistente?['titulo'] ?? '');
    List<dynamic> rawRegras = conjuntoExistente?['regras'] ?? [];
    List<TextEditingController> regrasCtrls = rawRegras.map((r) => TextEditingController(text: r.toString())).toList();
    if (regrasCtrls.isEmpty) regrasCtrls.add(TextEditingController());

    // Flag para modo sequencial
    bool isApostaDireta = conjuntoExistente?['isApostaDireta'] ?? false;

    await showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setStateDialog) => AlertDialog(
          title: Text(conjuntoExistente != null ? "Editar Regras" : "Nova Regra"),
          content: SizedBox(
            width: double.maxFinite,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                      controller: tituloCtrl,
                      textCapitalization: TextCapitalization.sentences,
                      decoration: const InputDecoration(labelText: "Título do Setup", border: OutlineInputBorder())
                  ),
                  const SizedBox(height: 12),
                  // SWITCH APOSTA DIRETA
                  SwitchListTile(
                    title: const Text("Modo Aposta Direta?"),
                    subtitle: const Text("Ativa validação sequencial (passo a passo)."),
                    value: isApostaDireta,
                    activeColor: Colors.purple,
                    contentPadding: EdgeInsets.zero,
                    onChanged: (val) => setStateDialog(() => isApostaDireta = val),
                  ),
                  const Divider(),
                  Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text("Regras:", style: TextStyle(fontWeight: FontWeight.bold)),
                        IconButton(icon: const Icon(Icons.add_circle, color: Colors.indigo), onPressed: () => setStateDialog(() => regrasCtrls.add(TextEditingController())))
                      ]
                  ),
                  ...regrasCtrls.asMap().entries.map((e) => Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Row(
                          children: [
                            const Icon(Icons.circle, size: 8, color: Colors.grey),
                            const SizedBox(width: 8),
                            Expanded(child: TextField(
                                controller: e.value,
                                textCapitalization: TextCapitalization.sentences,
                                decoration: InputDecoration(hintText: "Regra ${e.key+1}", isDense: true, border: const OutlineInputBorder())
                            )),
                            IconButton(icon: const Icon(Icons.close, color: Colors.red), onPressed: () => setStateDialog(() { if(regrasCtrls.length > 1) regrasCtrls.removeAt(e.key); else e.value.clear(); }))
                          ]
                      )
                  )),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancelar")),
            ElevatedButton(onPressed: () {
              if(tituloCtrl.text.isEmpty) return;
              final regras = regrasCtrls.map((c) => c.text.trim()).where((t) => t.isNotEmpty).toList();
              final novo = {
                'id': conjuntoExistente?['id'] ?? 'c_${DateTime.now().millisecondsSinceEpoch}',
                'titulo': tituloCtrl.text,
                'regras': regras,
                'isApostaDireta': isApostaDireta,
              };
              setState(() {
                final idx = _blocosDeRegras.indexOf(bloco);
                if (idx != -1) {
                  final listaConjuntos = (_blocosDeRegras[idx]['conjuntos'] as List);
                  if (conjuntoExistente != null) {
                    final cIdx = listaConjuntos.indexWhere((c) => c['id'] == conjuntoExistente['id']);
                    if(cIdx != -1) listaConjuntos[cIdx] = novo;
                  } else {
                    listaConjuntos.add(novo);
                  }
                }
              });
              _salvarRegras();
              _filtrarBlocos();
              Navigator.pop(context);
            }, child: const Text("Salvar")),
          ],
        ),
      ),
    );
  }

  Future<void> _dialogAdicionarEditarPlaybook({
    Map<String, dynamic>? playbookExistente,
    bool duplicar = false,
  }) async {
    final bool isEditing = playbookExistente != null && !duplicar;
    final String nomeOriginal = playbookExistente?['nome']?.toString() ?? '';
    final nomeCtrl = TextEditingController(text: duplicar && nomeOriginal.isNotEmpty ? '$nomeOriginal (Cópia)' : nomeOriginal);
    final estrategiaCtrl = TextEditingController(text: playbookExistente?['estrategia']?.toString() ?? '');
    final mercadoCtrl = TextEditingController(text: playbookExistente?['mercadoPrincipal']?.toString() ?? '');
    final gatilhosCtrl = TextEditingController(
      text: ((playbookExistente?['gatilhos'] as List?) ?? const []).map((e) => e.toString()).join('\n'),
    );
    final checklistCtrl = TextEditingController(
      text: ((playbookExistente?['checklist'] as List?) ?? const []).map((e) => e.toString()).join('\n'),
    );
    final riscoCtrl = TextEditingController(text: playbookExistente?['risco']?.toString() ?? '');
    final observacoesCtrl = TextEditingController(text: playbookExistente?['observacoes']?.toString() ?? '');

    await showDialog(
      context: context,
      builder: (c) => AlertDialog(
        title: Text(isEditing ? 'Editar Playbook' : (duplicar ? 'Duplicar Playbook' : 'Novo Playbook')),
        content: SizedBox(
          width: double.maxFinite,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(controller: nomeCtrl, decoration: const InputDecoration(labelText: 'Nome do playbook')),
                const SizedBox(height: 8),
                TextField(controller: estrategiaCtrl, decoration: const InputDecoration(labelText: 'Estratégia / cenário principal')),
                const SizedBox(height: 8),
                TextField(controller: mercadoCtrl, decoration: const InputDecoration(labelText: 'Mercado principal (ex: Over 2.5)')),
                const SizedBox(height: 8),
                TextField(controller: gatilhosCtrl, maxLines: 4, decoration: const InputDecoration(labelText: 'Gatilhos de entrada (1 por linha)')),
                const SizedBox(height: 8),
                TextField(controller: checklistCtrl, maxLines: 4, decoration: const InputDecoration(labelText: 'Checklist operacional (1 por linha)')),
                const SizedBox(height: 8),
                TextField(controller: riscoCtrl, decoration: const InputDecoration(labelText: 'Gestão de risco')),
                const SizedBox(height: 8),
                TextField(controller: observacoesCtrl, maxLines: 3, decoration: const InputDecoration(labelText: 'Observações / notas')),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(c), child: const Text('Cancelar')),
          ElevatedButton(
            onPressed: () {
              final nome = nomeCtrl.text.trim();
              if (nome.isEmpty) return;

              List<String> _linhas(String txt) => txt
                  .split('\n')
                  .map((e) => e.trim())
                  .where((e) => e.isNotEmpty)
                  .toList();

              final data = {
                'nome': nome,
                'estrategia': estrategiaCtrl.text.trim(),
                'mercadoPrincipal': mercadoCtrl.text.trim(),
                'gatilhos': _linhas(gatilhosCtrl.text),
                'checklist': _linhas(checklistCtrl.text),
                'risco': riscoCtrl.text.trim(),
                'observacoes': observacoesCtrl.text.trim(),
                'atualizadoEm': DateTime.now().toIso8601String(),
              };

              setState(() {
                if (isEditing) {
                  final idx = _playbooks.indexWhere((p) => (p['id'] as num?)?.toInt() == (playbookExistente!['id'] as num?)?.toInt());
                  if (idx != -1) {
                    final original = _playbooks[idx];
                    _playbooks[idx] = {
                      ...original,
                      ...data,
                    };
                  }
                } else {
                  final int newId = _playbooks.isEmpty
                      ? 1
                      : (_playbooks.map((p) => (p['id'] as num?)?.toInt() ?? 0).reduce((a, b) => a > b ? a : b) + 1);
                  _playbooks.add({
                    'id': newId,
                    'criadoEm': DateTime.now().toIso8601String(),
                    ...data,
                  });
                }
              });

              _salvarPlaybooks();
              Navigator.pop(c);
            },
            child: const Text('Salvar'),
          ),
        ],
      ),
    );
  }

  void _removerPlaybook(Map<String, dynamic> playbook) {
    _confirmarExclusao(
      titulo: playbook['nome']?.toString() ?? 'Playbook',
      onConfirm: () {
        setState(() => _playbooks.removeWhere((p) => (p['id'] as num?)?.toInt() == (playbook['id'] as num?)?.toInt()));
        _salvarPlaybooks();
      },
    );
  }

  Widget _buildTabPlaybooks() {
    final termo = _termoBuscaPlaybook.toLowerCase().trim();
    final filtrados = _playbooks.where((p) {
      if (termo.isEmpty) return true;
      final nome = (p['nome'] ?? '').toString().toLowerCase();
      final estrategia = (p['estrategia'] ?? '').toString().toLowerCase();
      final mercado = (p['mercadoPrincipal'] ?? '').toString().toLowerCase();
      return nome.contains(termo) || estrategia.contains(termo) || mercado.contains(termo);
    }).toList()
      ..sort((a, b) => ((a['nome'] ?? '').toString()).compareTo((b['nome'] ?? '').toString()));

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: TextField(
            controller: _playbookSearchCtrl,
            onChanged: (v) => setState(() => _termoBuscaPlaybook = v),
            decoration: InputDecoration(
              hintText: 'Buscar playbook por nome, estratégia ou mercado...',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: _termoBuscaPlaybook.isNotEmpty
                  ? IconButton(
                onPressed: () => setState(() {
                  _playbookSearchCtrl.clear();
                  _termoBuscaPlaybook = '';
                }),
                icon: const Icon(Icons.clear),
              )
                  : null,
            ),
          ),
        ),
        Expanded(
          child: filtrados.isEmpty
              ? Center(
            child: Text(
              _playbooks.isEmpty ? 'Nenhum playbook cadastrado.' : 'Nenhum playbook encontrado para a busca.',
              style: TextStyle(color: Colors.grey.shade600),
            ),
          )
              : ListView.builder(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            itemCount: filtrados.length,
            itemBuilder: (context, i) {
              final pb = filtrados[i];
              final gatilhos = ((pb['gatilhos'] as List?) ?? const []).map((e) => e.toString()).toList();
              final checklist = ((pb['checklist'] as List?) ?? const []).map((e) => e.toString()).toList();

              return Card(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(child: Text(pb['nome']?.toString() ?? 'Sem nome', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold))),
                          IconButton(
                            onPressed: () => _dialogAdicionarEditarPlaybook(playbookExistente: pb, duplicar: true),
                            icon: const Icon(Icons.content_copy),
                          ),
                          IconButton(onPressed: () => _dialogAdicionarEditarPlaybook(playbookExistente: pb), icon: const Icon(Icons.edit_outlined)),
                          IconButton(onPressed: () => _removerPlaybook(pb), icon: const Icon(Icons.delete_outline, color: Colors.redAccent)),
                        ],
                      ),
                      if ((pb['estrategia']?.toString().isNotEmpty ?? false)) Text('Estratégia: ${pb['estrategia']}'),
                      if ((pb['mercadoPrincipal']?.toString().isNotEmpty ?? false)) Text('Mercado: ${pb['mercadoPrincipal']}'),
                      if ((pb['risco']?.toString().isNotEmpty ?? false)) Text('Risco: ${pb['risco']}'),
                      const SizedBox(height: 8),
                      const Text('Gatilhos de entrada', style: TextStyle(fontWeight: FontWeight.w600)),
                      if (gatilhos.isEmpty)
                        const Text('• Não definido')
                      else
                        ...gatilhos.map((g) => Text('• $g')),
                      const SizedBox(height: 8),
                      const Text('Checklist operacional', style: TextStyle(fontWeight: FontWeight.w600)),
                      if (checklist.isEmpty)
                        const Text('• Não definido')
                      else
                        ...checklist.map((c) => Text('• $c')),
                      if ((pb['observacoes']?.toString().isNotEmpty ?? false)) ...[
                        const SizedBox(height: 8),
                        Text('Observações: ${pb['observacoes']}'),
                      ]
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  void _confirmarExclusao({required String titulo, required VoidCallback onConfirm}) {
    showDialog(context: context, builder: (ctx) => AlertDialog(
        title: const Text("Confirmar"),
        content: Text("Apagar '$titulo'?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Cancelar")),
          TextButton(onPressed: () { Navigator.pop(ctx); onConfirm(); }, child: const Text("Excluir", style: TextStyle(color: Colors.red)))
        ]
    ));
  }

  // --- MODO CHECKLIST (PADRÃO) ---
  void _abrirChecklistValidacao(Map<String, dynamic> conjunto) {
    final regras = (conjunto['regras'] as List?)?.cast<String>() ?? [];
    Map<int, bool> checks = {for (var i = 0; i < regras.length; i++) i: false};

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setSheetState) {
          final total = regras.length;
          final marcados = checks.values.where((v) => v).length;
          final progresso = total == 0 ? 0.0 : marcados / total;
          final validado = progresso == 1.0;

          return Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            ),
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
            height: MediaQuery.of(context).size.height * 0.85,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(2)))),
                const SizedBox(height: 24),
                Text(conjunto['titulo'], style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                LinearProgressIndicator(value: progresso, color: validado ? Colors.green : Colors.indigo, backgroundColor: Colors.grey.shade200),
                const SizedBox(height: 24),
                Expanded(
                  child: ListView.separated(
                    itemCount: regras.length,
                    separatorBuilder: (_, __) => const Divider(height: 1),
                    itemBuilder: (ctx, idx) {
                      return CheckboxListTile(
                        value: checks[idx],
                        activeColor: Colors.green,
                        title: Text(regras[idx], style: TextStyle(decoration: checks[idx]! ? TextDecoration.lineThrough : null, color: checks[idx]! ? Colors.grey : Colors.black87)),
                        onChanged: (val) => setSheetState(() => checks[idx] = val!),
                      );
                    },
                  ),
                ),
                if (validado)
                  ElevatedButton.icon(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.check_circle),
                    label: const Text("SETUP APROVADO"),
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.green, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 16)),
                  )
              ],
            ),
          );
        },
      ),
    );
  }

  // --- NOVO: MODO SEQUENCIAL (PARA APOSTA DIRETA) ---
  void _abrirModoSequencial(Map<String, dynamic> conjunto) {
    final regras = (conjunto['regras'] as List?)?.cast<String>() ?? [];
    if (regras.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Sem regras para validar.")));
      return;
    }

    showDialog(
      context: context,
      barrierDismissible: false, // Obriga a seguir o fluxo
      builder: (context) {
        int currentIndex = 0;
        return StatefulBuilder(
          builder: (context, setDialogState) {
            final isLast = currentIndex == regras.length - 1;
            final isFinished = currentIndex >= regras.length;

            // TELA FINAL DE SUCESSO
            if (isFinished) {
              return AlertDialog(
                backgroundColor: Colors.green.shade50,
                icon: const Icon(Icons.check_circle, color: Colors.green, size: 60),
                title: const Text("SETUP APROVADO!", style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
                content: const Text("Todas as regras foram confirmadas.\nVocê tem sinal verde para operar.", textAlign: TextAlign.center),
                actions: [
                  ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.green, foregroundColor: Colors.white),
                    child: const Text("VAMOS LUCRAR!"),
                  )
                ],
              );
            }

            // TELA DE PASSO A PASSO
            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              title: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("Regra ${currentIndex + 1}/${regras.length}", style: const TextStyle(fontSize: 14, color: Colors.grey)),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.grey),
                    onPressed: () => Navigator.pop(context), // Cancelar
                  )
                ],
              ),
              content: SizedBox(
                width: double.maxFinite,
                height: 200, // Altura fixa para foco
                child: Center(
                  child: SingleChildScrollView(
                    child: Text(
                      regras[currentIndex],
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, height: 1.3),
                    ),
                  ),
                ),
              ),
              actionsAlignment: MainAxisAlignment.spaceEvenly,
              actions: [
                // BOTÃO NÃO (ABORTAR)
                OutlinedButton.icon(
                  onPressed: () {
                    Navigator.pop(context); // Fecha tudo
                    ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text("Setup abortado na regra ${currentIndex + 1}."), backgroundColor: Colors.red)
                    );
                  },
                  icon: const Icon(Icons.cancel, color: Colors.red),
                  label: const Text("NÃO Confere", style: TextStyle(color: Colors.red)),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Colors.red),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  ),
                ),
                // BOTÃO SIM (PRÓXIMO)
                ElevatedButton.icon(
                  onPressed: () {
                    setDialogState(() {
                      currentIndex++;
                    });
                  },
                  icon: Icon(isLast ? Icons.check_circle : Icons.arrow_forward),
                  label: Text(isLast ? "FINALIZAR" : "PRÓXIMA"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.indigo,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _mostrarDetalhesRegra(Map<String, dynamic> bloco, Map<String, dynamic> conjunto) {
    final regrasList = (conjunto['regras'] as List?)?.cast<String>() ?? [];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        minChildSize: 0.4,
        maxChildSize: 0.95,
        expand: false,
        builder: (context, scrollController) {
          return Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              children: [
                Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(2)))),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(child: Text(conjunto['titulo'], style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold))),
                    IconButton(
                      icon: const Icon(Icons.copy, color: Colors.grey),
                      onPressed: () {
                        Clipboard.setData(ClipboardData(text: "${conjunto['titulo']}\n\n${regrasList.map((e) => '- $e').join('\n')}"));
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Copiado!")));
                      },
                    ),
                  ],
                ),
                if (conjunto['isApostaDireta'] == true)
                  Container(
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(color: Colors.purple.shade50, borderRadius: BorderRadius.circular(8)),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.flash_on, size: 16, color: Colors.purple),
                        SizedBox(width: 8),
                        Text("Modo Aposta Direta Ativo", style: TextStyle(color: Colors.purple, fontWeight: FontWeight.bold, fontSize: 12)),
                      ],
                    ),
                  ),

                Divider(color: Colors.grey.shade200, height: 32),

                Expanded(
                  child: regrasList.isEmpty
                      ? const Center(child: Text("Sem regras cadastradas.", style: TextStyle(color: Colors.grey)))
                      : ListView.separated(
                    controller: scrollController,
                    itemCount: regrasList.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (ctx, idx) {
                      return Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Padding(
                            padding: EdgeInsets.only(top: 6.0),
                            child: Icon(Icons.check_circle_outline, size: 16, color: Colors.green),
                          ),
                          const SizedBox(width: 12),
                          Expanded(child: Text(regrasList[idx], style: const TextStyle(fontSize: 16, height: 1.5, color: Colors.black87))),
                        ],
                      );
                    },
                  ),
                ),

                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    OutlinedButton.icon(
                      icon: const Icon(Icons.edit),
                      label: const Text("Editar"),
                      onPressed: () {
                        Navigator.pop(context);
                        _dialogAdicionarEditarConjunto(bloco: bloco, conjuntoExistente: conjunto);
                      },
                    ),
                    OutlinedButton.icon(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      label: const Text("Excluir", style: TextStyle(color: Colors.red)),
                      onPressed: () {
                        Navigator.pop(context);
                        _confirmarExclusao(
                            titulo: conjunto['titulo'],
                            onConfirm: () {
                              setState(() {
                                final blocoIndex = _blocosDeRegras.indexOf(bloco);
                                if (blocoIndex != -1) {
                                  (_blocosDeRegras[blocoIndex]['conjuntos'] as List).removeWhere((c) => c['id'] == conjunto['id']);
                                }
                              });
                              _salvarRegras();
                              _filtrarBlocos();
                            }
                        );
                      },
                    ),
                  ],
                )
              ],
            ),
          );
        },
      ),
    );
  }

  // --- Widgets de UI ---

  Widget _buildBlocoCard(Map<String, dynamic> bloco, int index) {
    final List<dynamic> conjuntos = bloco['conjuntos'] ?? [];
    final bool isExpanded = bloco['isExpanded'] ?? true;

    return Card(
      key: ValueKey(bloco['id']),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      margin: const EdgeInsets.only(bottom: 16.0),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          InkWell(
            onTap: () {
              setState(() => bloco['isExpanded'] = !isExpanded);
              _salvarRegras();
            },
            child: Container(
              color: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(color: Colors.indigo.shade50, borderRadius: BorderRadius.circular(8)),
                    child: Icon(isExpanded ? Icons.folder_open : Icons.folder, color: Colors.indigo, size: 20),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(bloco['titulo'], style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87)),
                        const SizedBox(height: 2),
                        Text("${conjuntos.length} setups", style: TextStyle(fontSize: 12, color: Colors.grey.shade500)),
                      ],
                    ),
                  ),
                  PopupMenuButton<String>(
                    icon: const Icon(Icons.more_horiz, color: Colors.grey),
                    onSelected: (value) {
                      if (value == 'editar') _dialogAdicionarEditarBloco(blocoExistente: bloco);
                      if (value == 'excluir') _confirmarExclusao(titulo: bloco['titulo'], onConfirm: () { setState(() => _blocosDeRegras.remove(bloco)); _salvarRegras(); _filtrarBlocos(); });
                      if (value == 'add_regra') _dialogAdicionarEditarConjunto(bloco: bloco);
                    },
                    itemBuilder: (context) => [
                      const PopupMenuItem(value: 'add_regra', child: Text("Novo Setup")),
                      const PopupMenuItem(value: 'editar', child: Text("Renomear")),
                      const PopupMenuItem(value: 'excluir', child: Text("Excluir Bloco", style: TextStyle(color: Colors.red))),
                    ],
                  ),
                  if (_termoBusca.isEmpty)
                    ReorderableDragStartListener(
                      index: index,
                      child: const Padding(padding: EdgeInsets.only(left: 8.0), child: Icon(Icons.drag_indicator, color: Colors.grey)),
                    ),
                ],
              ),
            ),
          ),

          if (isExpanded) ...[
            const Divider(height: 1),
            if (conjuntos.isEmpty)
              Padding(
                padding: const EdgeInsets.all(24.0),
                child: Center(
                  child: TextButton.icon(
                    onPressed: () => _dialogAdicionarEditarConjunto(bloco: bloco),
                    icon: const Icon(Icons.add_circle_outline),
                    label: const Text("Adicionar Setup"),
                  ),
                ),
              )
            else
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: conjuntos.length,
                separatorBuilder: (ctx, i) => Divider(height: 1, indent: 60, endIndent: 0, color: Colors.grey.shade100),
                itemBuilder: (context, i) {
                  final conj = Map<String, dynamic>.from(conjuntos[i]);
                  final regrasCount = (conj['regras'] as List?)?.length ?? 0;
                  final isApostaDireta = conj['isApostaDireta'] == true;

                  return InkWell(
                    onTap: () => _mostrarDetalhesRegra(bloco, conj),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      child: Row(
                        children: [
                          const SizedBox(width: 48),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    if(isApostaDireta) const Padding(padding: EdgeInsets.only(right: 6), child: Icon(Icons.flash_on, size: 14, color: Colors.purple)),
                                    Text(conj['titulo'], style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
                                  ],
                                ),
                                Text("$regrasCount regras definidas", style: TextStyle(color: Colors.grey.shade500, fontSize: 12)),
                              ],
                            ),
                          ),
                          // BOTÃO DE AÇÃO PRINCIPAL
                          IconButton(
                            // Se for Aposta Direta, usa o ícone de Play Sequencial. Se não, usa Checklist padrão.
                            icon: Icon(
                                isApostaDireta ? Icons.play_arrow_rounded : Icons.check_box_outlined,
                                color: isApostaDireta ? Colors.purple : Colors.green,
                                size: 32
                            ),
                            tooltip: isApostaDireta ? "Modo Sequencial (Focado)" : "Checklist Rápido",
                            onPressed: () {
                              if (isApostaDireta) {
                                _abrirModoSequencial(conj);
                              } else {
                                _abrirChecklistValidacao(conj);
                              }
                            },
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
          ],
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        title: const Text('Checklist & Setups', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: false,
        elevation: 0,
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Regras'),
            Tab(text: 'Playbooks'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          Column(
            children: [
              Container(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                decoration: const BoxDecoration(color: Colors.indigo, borderRadius: BorderRadius.vertical(bottom: Radius.circular(24))),
                child: TextField(
                  controller: _searchCtrl,
                  onChanged: (val) { _termoBusca = val; _filtrarBlocos(); },
                  style: const TextStyle(color: Colors.white),
                  cursorColor: Colors.white,
                  decoration: InputDecoration(
                    hintText: "Buscar setup ou regra...",
                    hintStyle: TextStyle(color: Colors.white.withOpacity(0.6)),
                    prefixIcon: Icon(Icons.search, color: Colors.white.withOpacity(0.8)),
                    suffixIcon: _termoBusca.isNotEmpty ? IconButton(icon: const Icon(Icons.clear, color: Colors.white), onPressed: () { _searchCtrl.clear(); setState(() { _termoBusca = ''; _filtrarBlocos(); }); }) : null,
                    filled: true,
                    fillColor: Colors.white.withOpacity(0.15),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                  ),
                ),
              ),
              Expanded(
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : _blocosFiltrados.isEmpty
                    ? Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.rule_folder, size: 64, color: Colors.grey.shade300), const SizedBox(height: 16), Text(_blocosDeRegras.isEmpty ? "Crie seu primeiro bloco de regras." : "Nenhum setup encontrado.", style: TextStyle(color: Colors.grey.shade500))]))
                    : _termoBusca.isEmpty
                    ? ReorderableListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _blocosFiltrados.length,
                  onReorder: _onReorder,
                  proxyDecorator: (child, index, animation) => Material(elevation: 8, color: Colors.transparent, borderRadius: BorderRadius.circular(16), child: child),
                  itemBuilder: (context, index) { final bloco = _blocosFiltrados[index]; return _buildBlocoCard(bloco, index); },
                )
                    : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _blocosFiltrados.length,
                  itemBuilder: (context, index) { final bloco = _blocosFiltrados[index]; return _buildBlocoCard(bloco, index); },
                ),
              ),
            ],
          ),
          _buildTabPlaybooks(),
        ],
      ),
      floatingActionButton: AnimatedBuilder(
        animation: _tabController,
        builder: (context, _) {
          final onPlaybooks = _tabController.index == 1;
          return FloatingActionButton.extended(
            onPressed: onPlaybooks ? () => _dialogAdicionarEditarPlaybook() : () => _dialogAdicionarEditarBloco(),
            backgroundColor: Colors.indigo,
            icon: Icon(onPlaybooks ? Icons.auto_awesome_motion : Icons.folder_open),
            label: Text(onPlaybooks ? "Novo Playbook" : "Novo Bloco"),
          );
        },
      ),
    );
  }
}
// ===================================================================
// FIM DO BLOCO DA TELA REGRAS ( TELA 4 )
// ===================================================================


// ===================================================================
// TELA DA TELA DE PESQUISA (Tela 5) Calculando eficiencia real
// ===================================================================

class TelaDashboard extends StatefulWidget {
  const TelaDashboard({super.key});

  @override
  State<TelaDashboard> createState() => _TelaDashboardState();
}

class _TelaDashboardState extends State<TelaDashboard> {
  // --- Estado de Dados ---
  // Helpers de formatação para esta tela também
  String _fmtPct(dynamic x) => "${((x as num).toDouble() * 100).toStringAsFixed(1)}%";
  String _fmt2(dynamic x) => (x as num).toDouble().toStringAsFixed(2);

  // CORREÇÃO: Declarando a variável _apostas que estava faltando
  List<Map<String, dynamic>> _apostas = [];
  List<Map<String, dynamic>> _apostasFiltradas = [];
  Map<String, dynamic> _dadosCompletosJSON = {};

  // Lista de cards carregados
  List<Map<String, dynamic>> _cardsConfianca = [];
  List<Map<String, dynamic>> _cardsPoisson = [];
  List<Map<String, dynamic>> _playbooks = [];

  // --- Perguntas de Confiança (Referência para filtro) ---
  final List<String> _perguntasConfianca = [
    "1° Chance de vitória de acordo com meu histórico maior que a odd oferecida?",
    "2° Cálculo de EV+ Poisson com probabilidade maior que a odd oferecida?",
    "3° Confronto direto favorável?",
    "4° Maioria das apostas anteriores nesse time com comentários positivos?",
    "5° Analise da IA com nota 8 ou mais?",
    "6° Algo coloca alguma dúvida nessa aposta?"
  ];

  // --- Estado de Pesquisa ---
  // 0 = Padrão, 1 = Análise Pré-Jogo, 2 = Poisson
  int _modoPesquisa = 0;

  // Variáveis Modo Padrão
  String _criterioSelecionado = 'Time';
  final TextEditingController _searchController = TextEditingController();

  // Variáveis Modos Avançados (Confiança)
  int _filtroPerguntaIndex = 0;
  int _respostaEsperada = 1;

  // Variáveis Modo Avançado (Poisson - Backtest)
  String _poissonMetric = 'pCasa'; // pCasa, pOver15, pOver25, pOver35, pBTTS, edge
  double _poissonMinVal = 0.50; // 50%
  String _oddRangeFilter = 'Todas'; // Faixas de odd

  // --- Filtros Extras (Comuns) ---
  DateTime? _startDate;
  DateTime? _endDate;
  String _filtroRapidoStatus = 'Todos'; // 'Todos', 'Green', 'Red', 'Sem Diário'
  int? _filtroPlaybookId;
  int? _compararPlaybookAId;
  int? _compararPlaybookBId;

  final List<String> _criteriosPadrao = [
    'Time',
    'Campeonato',
    'Tipo de Aposta',
    'ID da Aposta',
    'ID do Ciclo',
    'Playbook',
    'EV+ (Valor Esperado)',
    'Status (Ganho/Perdido)'
  ];

  bool _carregando = true;

  @override
  void initState() {
    super.initState();
    _carregarDados();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // ================== GERENCIAMENTO DE ARQUIVOS E DADOS ==================

  Future<File> _getApostasFile() async {
    final dir = await getApplicationDocumentsDirectory();
    return File("${dir.path}/apostas_data.json");
  }

  Future<File> _getConfiancaFile() async {
    final dir = await getApplicationDocumentsDirectory();
    return File("${dir.path}/confianca_data.json");
  }

  Future<File> _getPoissonCardsFile() async {
    final dir = await getApplicationDocumentsDirectory();
    return File("${dir.path}/poisson_cards.json");
  }

  // NOVO: Arquivo de estatísticas agregadas
  Future<File> _getEstatisticasFile() async {
    final dir = await getApplicationDocumentsDirectory();
    return File("${dir.path}/estatisticas_globais.json");
  }

  Future<void> _carregarDados() async {
    setState(() => _carregando = true);
    try {
      // 1. Carrega Apostas
      final fileApostas = await _getApostasFile();
      if (await fileApostas.exists()) {
        final content = await fileApostas.readAsString();
        if (content.isNotEmpty) {
          final json = jsonDecode(content);
          _dadosCompletosJSON = json;

          if (json['playbooks'] != null) {
            _playbooks = List<Map<String, dynamic>>.from(json['playbooks']);
          }

          if (json['apostas'] != null) {
            _apostas = List<Map<String, dynamic>>.from(json['apostas']);
            _apostas.sort((a, b) {
              final idA = (a['id'] as num).toInt();
              final idB = (b['id'] as num).toInt();
              return idB.compareTo(idA);
            });
          }
        }
      }

      // 2. Carrega Cards de Confiança
      final fileConfianca = await _getConfiancaFile();
      if (await fileConfianca.exists()) {
        final content = await fileConfianca.readAsString();
        if (content.isNotEmpty) {
          final decoded = jsonDecode(content);
          if (decoded is List) {
            _cardsConfianca = decoded.cast<Map<String, dynamic>>();
          }
        }
      }

      // 3. Carrega Cards Poisson
      final filePoisson = await _getPoissonCardsFile();
      if (await filePoisson.exists()) {
        final content = await filePoisson.readAsString();
        if (content.isNotEmpty) {
          final decoded = jsonDecode(content);
          if (decoded is List) {
            _cardsPoisson = decoded.cast<Map<String, dynamic>>();
          }
        }
      }

      // 4. NOVO: Gerar/Atualizar arquivo de estatísticas globais
      await _gerarEstatisticasGlobais();

    } catch (e) {
      debugPrint("Erro ao carregar dados: $e");
    } finally {
      if (mounted) {
        setState(() {
          _apostasFiltradas = List.from(_apostas);
          _carregando = false;
        });
        _aplicarTodosFiltros();
      }
    }
  }

  // --- NOVA FUNÇÃO: GERA O ARQUIVO JSON DE ESTATÍSTICAS ---
  Future<void> _gerarEstatisticasGlobais() async {
    try {
      // Estruturas de agregação
      final Map<String, Map<String, dynamic>> statsTimes = {};
      final Map<String, Map<String, dynamic>> statsCampeonatos = {};
      final Map<String, Map<String, dynamic>> statsTipos = {};

      // Função auxiliar para atualizar o mapa
      void atualizarMap(Map<String, Map<String, dynamic>> mapa, String chave, double lucro, double flat, bool isWin) {
        if (!mapa.containsKey(chave)) {
          mapa[chave] = {
            'jogos': 0,
            'vitorias': 0,
            'lucroFinanceiro': 0.0,
            'flatProfit': 0.0
          };
        }
        mapa[chave]!['jogos'] += 1;
        if (isWin) mapa[chave]!['vitorias'] += 1;
        mapa[chave]!['lucroFinanceiro'] += lucro;
        mapa[chave]!['flatProfit'] += flat;
      }

      for (var aposta in _apostas) {
        final time = aposta['time'] ?? 'Desconhecido';
        final campeonato = aposta['campeonato'] ?? 'Outros';
        final tipo = aposta['tipo'] ?? 'Geral';

        final lucro = (aposta['lucro'] as num).toDouble();
        final odd = (aposta['odd'] as num).toDouble();

        // Cálculo Flat Stake
        // Green: Odd - 1 | Red: -1 | Void: 0
        double flat = 0.0;
        bool isWin = false;

        if (lucro > 0) {
          flat = odd - 1.0;
          isWin = true;
        } else if (lucro < 0) {
          flat = -1.0;
        }

        atualizarMap(statsTimes, time, lucro, flat, isWin);
        atualizarMap(statsCampeonatos, campeonato, lucro, flat, isWin);
        atualizarMap(statsTipos, tipo, lucro, flat, isWin);
      }

      // Monta o objeto final
      final statsGlobal = {
        'metadata': {
          'updatedAt': DateTime.now().toIso8601String(),
          'totalApostas': _apostas.length
        },
        'porTime': statsTimes,
        'porCampeonato': statsCampeonatos,
        'porTipo': statsTipos
      };

      // Salva no arquivo
      final file = await _getEstatisticasFile();
      await file.writeAsString(jsonEncode(statsGlobal));
      debugPrint("Estatísticas globais atualizadas com sucesso!");

    } catch (e) {
      debugPrint("Erro ao gerar estatísticas globais: $e");
    }
  }

  Future<void> _salvarObservacao(
      int idAposta,
      String observacao, {
        int? placarCasa,
        int? placarFora,
      }) async {
    try {
      final index = _apostas.indexWhere((a) => a['id'] == idAposta);
      if (index != -1) {
        setState(() {
          _apostas[index]['observacaoPosJogo'] = observacao;
          _apostas[index]['placarCasa'] = placarCasa;
          _apostas[index]['placarFora'] = placarFora;
          _aplicarTodosFiltros();
        });

        if (_dadosCompletosJSON.containsKey('apostas')) {
          final listaJson = _dadosCompletosJSON['apostas'] as List;
          final indexJson = listaJson.indexWhere((a) => a['id'] == idAposta);
          if (indexJson != -1) {
            listaJson[indexJson]['observacaoPosJogo'] = observacao;
            listaJson[indexJson]['placarCasa'] = placarCasa;
            listaJson[indexJson]['placarFora'] = placarFora;
          }
        }

        final file = await _getApostasFile();
        await file.writeAsString(jsonEncode(_dadosCompletosJSON));

        // Atualiza as estatísticas globais após salvar o diário (caso mude algo relevante no futuro)
        _gerarEstatisticasGlobais();

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Diário salvo com sucesso!"), backgroundColor: Colors.green),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Erro ao salvar: $e"), backgroundColor: Colors.red),
        );
      }
    }
  }

  // ================== LÓGICA DE VÍNCULO (CONFIANÇA & POISSON) ==================

  Future<void> _salvarAlteracoesConfianca() async {
    try {
      final file = await _getConfiancaFile();
      await file.writeAsString(jsonEncode(_cardsConfianca));
    } catch (e) { debugPrint("Erro salvar confiança: $e"); }
  }

  Future<void> _salvarAlteracoesPoisson() async {
    try {
      final file = await _getPoissonCardsFile();
      await file.writeAsString(jsonEncode(_cardsPoisson));
    } catch (e) { debugPrint("Erro salvar poisson: $e"); }
  }

  // Confiança
  Future<void> _vincularCard(dynamic apostaId, String cardId) async {
    final index = _cardsConfianca.indexWhere((c) => c['id'] == cardId);
    if (index != -1) {
      setState(() { _cardsConfianca[index]['linkedBetId'] = apostaId.toString(); });
      await _salvarAlteracoesConfianca();
      if (_modoPesquisa == 1) _aplicarTodosFiltros();
      if (mounted) { Navigator.pop(context); ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Confiança vinculada!"))); }
    }
  }

  Future<void> _desvincularCard(String cardId) async {
    final index = _cardsConfianca.indexWhere((c) => c['id'] == cardId);
    if (index != -1) {
      setState(() { _cardsConfianca[index]['linkedBetId'] = null; });
      await _salvarAlteracoesConfianca();
      if (_modoPesquisa == 1) _aplicarTodosFiltros();
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Confiança desvinculada!")));
    }
  }

  // Poisson
  Future<void> _vincularCardPoisson(dynamic apostaId, String cardId) async {
    final index = _cardsPoisson.indexWhere((c) => c['id'] == cardId);
    if (index != -1) {
      setState(() { _cardsPoisson[index]['linkedBetId'] = apostaId.toString(); });
      await _salvarAlteracoesPoisson();
      if (_modoPesquisa == 2) _aplicarTodosFiltros();
      if (mounted) { Navigator.pop(context); ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Poisson vinculado!"))); }
    }
  }

  Future<void> _desvincularCardPoisson(String cardId) async {
    final index = _cardsPoisson.indexWhere((c) => c['id'] == cardId);
    if (index != -1) {
      setState(() { _cardsPoisson[index]['linkedBetId'] = null; });
      await _salvarAlteracoesPoisson();
      if (_modoPesquisa == 2) _aplicarTodosFiltros();
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Poisson desvinculado!")));
    }
  }

  // ================== LÓGICA DE FILTRAGEM CENTRALIZADA ==================

  void _aplicarTodosFiltros() {
    setState(() {
      _apostasFiltradas = _apostas.where((aposta) {
        bool matchPrincipal = true;
        final apostaIdStr = aposta['id'].toString();

        // --- MODO 0: PESQUISA PADRÃO ---
        if (_modoPesquisa == 0) {
          final query = _searchController.text.trim().toLowerCase();
          if (query.isNotEmpty) {
            String valor = '';
            bool usarBuscaExata = false;

            switch (_criterioSelecionado) {
              case 'Time': valor = aposta['time'] ?? ''; break;
              case 'Campeonato': valor = aposta['campeonato'] ?? ''; break;
              case 'Tipo de Aposta': valor = aposta['tipo'] ?? ''; break;
              case 'ID da Aposta': valor = aposta['id'].toString(); usarBuscaExata = true; break;
              case 'ID do Ciclo': valor = aposta['cicloId'].toString(); usarBuscaExata = true; break;
              case 'Playbook': valor = aposta['playbookNome'] ?? ''; break;
              case 'EV+ (Valor Esperado)':
                final ev = aposta['evPositivo'];
                if (ev == true) valor = "Sim (EV+)"; else if (ev == false) valor = "Não (EV-)"; else valor = "N/A";
                break;
              case 'Status (Ganho/Perdido)':
                final lucro = (aposta['lucro'] as num).toDouble();
                valor = lucro > 0 ? "Green (Ganho)" : (lucro < 0 ? "Red (Perdido)" : "Reembolso");
                break;
            }

            if (usarBuscaExata) {
              matchPrincipal = (valor.toLowerCase() == query);
            } else {
              matchPrincipal = valor.toLowerCase().contains(query);
            }
          }
        }
        // --- MODO 1: PESQUISA POR ANÁLISE PRÉ-JOGO ---
        else if (_modoPesquisa == 1) {
          Map<String, dynamic>? cardVinculado;
          try { cardVinculado = _cardsConfianca.firstWhere((c) => c['linkedBetId'] == apostaIdStr); } catch (_) {}

          if (cardVinculado == null) {
            matchPrincipal = false;
          } else {
            final respostas = cardVinculado['respostas'] as List;
            final anuladas = (cardVinculado['anuladas'] as List?) ?? List.filled(respostas.length, false);

            if (respostas.length > _filtroPerguntaIndex) {
              final bool respostaNoCard = respostas[_filtroPerguntaIndex];
              final bool isAnulada = anuladas.length > _filtroPerguntaIndex ? anuladas[_filtroPerguntaIndex] : false;

              if (_respostaEsperada == 2) {
                matchPrincipal = isAnulada;
              } else {
                if (isAnulada) matchPrincipal = false;
                else {
                  bool buscaSim = (_respostaEsperada == 1);
                  matchPrincipal = (respostaNoCard == buscaSim);
                }
              }
            } else {
              matchPrincipal = false;
            }
          }
        }
        // --- MODO 2: PESQUISA POISSON (BACKTEST AVANÇADO) ---
        else if (_modoPesquisa == 2) {
          Map<String, dynamic>? cardP;
          try { cardP = _cardsPoisson.firstWhere((c) => c['linkedBetId'] == apostaIdStr); } catch (_) {}

          if (cardP == null) {
            matchPrincipal = false;
          } else {
            final res = cardP['resultados'] as Map<String, dynamic>;
            final probGols = res['probGols'] as Map<String, dynamic>?;

            // 1. Extrair valor da métrica escolhida (AGORA COMPLETO)
            double valorNoCard = 0.0;
            switch (_poissonMetric) {
            // Match Odds (1x2)
              case 'pCasa': valorNoCard = (res['pCasa'] as num?)?.toDouble() ?? 0.0; break;
              case 'pEmpate': valorNoCard = (res['pEmpate'] as num?)?.toDouble() ?? 0.0; break;
              case 'pFora': valorNoCard = (res['pFora'] as num?)?.toDouble() ?? 0.0; break;

            // Chance Dupla
              case 'p1X': valorNoCard = (res['p1X'] as num?)?.toDouble() ?? 0.0; break;
              case 'p12': valorNoCard = (res['p12'] as num?)?.toDouble() ?? 0.0; break;
              case 'pX2': valorNoCard = (res['pX2'] as num?)?.toDouble() ?? 0.0; break;

            // Gols 1.5
              case 'pOver15': valorNoCard = (probGols?['Over 1.5']?['prob'] as num?)?.toDouble() ?? 0.0; break;
              case 'pUnder15': valorNoCard = (probGols?['Under 1.5']?['prob'] as num?)?.toDouble() ?? 0.0; break;

            // Gols 2.5
              case 'pOver25': valorNoCard = (probGols?['Over 2.5']?['prob'] as num?)?.toDouble() ?? 0.0; break;
              case 'pUnder25': valorNoCard = (probGols?['Under 2.5']?['prob'] as num?)?.toDouble() ?? 0.0; break;

            // Gols 3.5
              case 'pOver35': valorNoCard = (probGols?['Over 3.5']?['prob'] as num?)?.toDouble() ?? 0.0; break;
              case 'pUnder35': valorNoCard = (probGols?['Under 3.5']?['prob'] as num?)?.toDouble() ?? 0.0; break;

            // Gols 4.5
              case 'pOver45': valorNoCard = (probGols?['Over 4.5']?['prob'] as num?)?.toDouble() ?? 0.0; break;
              case 'pUnder45': valorNoCard = (probGols?['Under 4.5']?['prob'] as num?)?.toDouble() ?? 0.0; break;

            // Ambos Marcam (BTTS)
              case 'pBTTS_Sim': valorNoCard = (probGols?['Ambos Marcam (Sim)']?['prob'] as num?)?.toDouble() ?? 0.0; break;
              case 'pBTTS_Nao': valorNoCard = (probGols?['Ambos Marcam (Não)']?['prob'] as num?)?.toDouble() ?? 0.0; break;

            // Especiais
              case 'pPlacarExato': valorNoCard = (res['placarProvavel']?['p'] as num?)?.toDouble() ?? 0.0; break;
              case 'edge': valorNoCard = (res['value']?['edge'] as num?)?.toDouble() ?? -10.0; break;
            }

            // 2. Aplicar filtro de Mínimo (Backtest)
            bool passouMinimo = valorNoCard >= _poissonMinVal;

            // 3. Aplicar filtro de Faixa de Odd Real (Aposta feita)
            bool passouOdd = true;
            if (_oddRangeFilter != 'Todas') {
              final oddReal = double.tryParse(aposta['odd'].toString()) ?? 0.0;
              if (_oddRangeFilter == '1.01 - 1.50') passouOdd = oddReal >= 1.01 && oddReal <= 1.50;
              else if (_oddRangeFilter == '1.51 - 1.80') passouOdd = oddReal > 1.50 && oddReal <= 1.80;
              else if (_oddRangeFilter == '1.81 - 2.20') passouOdd = oddReal > 1.80 && oddReal <= 2.20;
              else if (_oddRangeFilter == '2.21+') passouOdd = oddReal > 2.20;
            }

            matchPrincipal = passouMinimo && passouOdd;
          }
        }

        // --- FILTROS COMUNS (Data e Status) ---
        bool matchData = true;
        if (_startDate != null && _endDate != null) {
          final dataAposta = DateTime.parse(aposta['data']);
          final endAdjusted = DateTime(_endDate!.year, _endDate!.month, _endDate!.day, 23, 59, 59);
          if (dataAposta.isBefore(_startDate!) || dataAposta.isAfter(endAdjusted)) {
            matchData = false;
          }
        }

        bool matchRapido = true;
        final lucro = (aposta['lucro'] as num).toDouble();
        if (_filtroRapidoStatus == 'Green') matchRapido = lucro > 0;
        else if (_filtroRapidoStatus == 'Red') matchRapido = lucro < 0;
        else if (_filtroRapidoStatus == 'Sem Diário') {
          final obs = aposta['observacaoPosJogo']?.toString() ?? '';
          matchRapido = obs.isEmpty;
        }

        bool matchPlaybook = true;
        if (_filtroPlaybookId != null) {
          matchPlaybook = (aposta['playbookId'] as num?)?.toInt() == _filtroPlaybookId;
        }

        return matchPrincipal && matchData && matchRapido && matchPlaybook;
      }).toList();
    });
  }

  Future<void> _selecionarPeriodo() async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      initialDateRange: _startDate != null && _endDate != null ? DateTimeRange(start: _startDate!, end: _endDate!) : null,
      builder: (context, child) {
        return Theme(data: Theme.of(context).copyWith(colorScheme: ColorScheme.light(primary: Colors.indigo, onPrimary: Colors.white, onSurface: Colors.black)), child: child!);
      },
    );

    if (picked != null) {
      setState(() { _startDate = picked.start; _endDate = picked.end; });
      _aplicarTodosFiltros();
    }
  }

  List<String> _getOpcoesAutocomplete(String query) {
    final Set<String> opcoes = {};
    final qLower = query.toLowerCase();
    for (var aposta in _apostas) {
      String? valor;
      switch (_criterioSelecionado) {
        case 'Time': valor = aposta['time']; break;
        case 'Campeonato': valor = aposta['campeonato']; break;
        case 'Tipo de Aposta': valor = aposta['tipo']; break;
        case 'ID da Aposta': valor = aposta['id'].toString(); break;
        case 'ID do Ciclo': valor = aposta['cicloId'].toString(); break;
        case 'Playbook': valor = aposta['playbookNome']; break;
      }
      if (valor != null && valor.toLowerCase().contains(qLower)) opcoes.add(valor);
    }
    return opcoes.toList()..sort();
  }

  Map<String, dynamic> _resumoPorPlaybook(int playbookId) {
    final filtradas = _apostas.where((a) => (a['playbookId'] as num?)?.toInt() == playbookId).toList();
    if (filtradas.isEmpty) {
      return {'qtd': 0, 'lucro': 0.0, 'winRate': 0.0, 'roi': 0.0};
    }

    final lucro = filtradas.fold(0.0, (s, a) => s + (a['lucro'] as num).toDouble());
    final wins = filtradas.where((a) => (a['lucro'] as num).toDouble() > 0).length;
    final stakeTotal = filtradas.fold(0.0, (s, a) => s + (a['stake'] as num).toDouble());
    final roi = stakeTotal > 0 ? (lucro / stakeTotal) * 100 : 0.0;

    return {
      'qtd': filtradas.length,
      'lucro': lucro,
      'winRate': filtradas.isNotEmpty ? (wins / filtradas.length) * 100 : 0.0,
      'roi': roi,
    };
  }

  Widget _buildComparacaoPlaybooks() {
    if (_compararPlaybookAId == null || _compararPlaybookBId == null || _compararPlaybookAId == _compararPlaybookBId) {
      return const SizedBox.shrink();
    }

    final a = _playbooks.firstWhere((p) => (p['id'] as num).toInt() == _compararPlaybookAId, orElse: () => {});
    final b = _playbooks.firstWhere((p) => (p['id'] as num).toInt() == _compararPlaybookBId, orElse: () => {});
    if (a.isEmpty || b.isEmpty) return const SizedBox.shrink();

    final ra = _resumoPorPlaybook(_compararPlaybookAId!);
    final rb = _resumoPorPlaybook(_compararPlaybookBId!);

    Widget col(String nome, Map<String, dynamic> r) {
      return Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(nome, style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text('Apostas: ${r['qtd']}'),
            Text('Lucro: R\$ ${(r['lucro'] as num).toStringAsFixed(2)}'),
            Text('ROI: ${(r['roi'] as num).toStringAsFixed(1)}%'),
            Text('Winrate: ${(r['winRate'] as num).toStringAsFixed(1)}%'),
          ],
        ),
      );
    }

    return Card(
      margin: const EdgeInsets.fromLTRB(16, 4, 16, 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Comparação de Estratégias (Playbooks)', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Row(children: [col(a['nome'] as String, ra), const SizedBox(width: 12), col(b['nome'] as String, rb)]),
          ],
        ),
      ),
    );
  }

  // ================== UI HELPERS ==================

  // Seleção de Vínculo Confiança
  void _mostrarDialogoSelecaoVinculo(dynamic apostaId) {
    final disponiveis = _cardsConfianca.where((c) => (c['arquivado'] == false || c['arquivado'] == null) && c['linkedBetId'] == null).toList();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Vincular Análise Pré-Jogo"),
        content: disponiveis.isEmpty ? const Text("Nenhuma análise disponível.") : SizedBox(width: double.maxFinite, child: ListView.builder(shrinkWrap: true, itemCount: disponiveis.length, itemBuilder: (context, index) {
          final card = disponiveis[index];
          final nota = (card['nota'] as num).toDouble();
          return ListTile(
            leading: CircleAvatar(backgroundColor: _getCorNota(nota), child: Text(nota.toInt().toString(), style: const TextStyle(color: Colors.white))),
            title: Text(card['titulo'] ?? "Sem título"),
            subtitle: Text(DateFormat('dd/MM HH:mm').format(DateTime.parse(card['data']))),
            onTap: () => _vincularCard(apostaId, card['id']),
          );
        })),
        actions: [TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Cancelar"))],
      ),
    );
  }

  // Seleção de Vínculo Poisson
  void _mostrarDialogoSelecaoVinculoPoisson(dynamic apostaId) {
    final disponiveis = _cardsPoisson.where((c) => c['linkedBetId'] == null).toList();
    // Ordenar recentes primeiro
    disponiveis.sort((a,b) => (b['data'] ?? '').compareTo(a['data'] ?? ''));

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Vincular Card Poisson"),
        content: disponiveis.isEmpty ? const Text("Nenhum card Poisson disponível.") : SizedBox(width: double.maxFinite, child: ListView.builder(shrinkWrap: true, itemCount: disponiveis.length, itemBuilder: (context, index) {
          final card = disponiveis[index];
          final res = card['resultados'] as Map<String, dynamic>;
          final pCasa = (res['pCasa'] as num).toDouble();
          return ListTile(
            leading: const Icon(Icons.calculate, color: Colors.indigo),
            title: Text("${card['mandante']} x ${card['visitante']}"),
            subtitle: Text("Prob Casa: ${(pCasa*100).toStringAsFixed(0)}% | ${DateFormat('dd/MM HH:mm').format(DateTime.parse(card['data']))}"),
            onTap: () => _vincularCardPoisson(apostaId, card['id']),
          );
        })),
        actions: [TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Cancelar"))],
      ),
    );
  }

  Color _getCorNota(double nota) {
    if (nota >= 8) return Colors.green;
    if (nota >= 5) return Colors.orange;
    return Colors.red;
  }

  // Helper para confirmar desvínculo
  void _confirmarDesvinculo(BuildContext context, VoidCallback onConfirm) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Desvincular Card?"),
        content: const Text("Isso removerá a conexão entre esta aposta e a análise. O card voltará para a lista de disponíveis."),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Cancelar")),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              onConfirm();
            },
            child: const Text("Desvincular", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  String _poissonMetricLabel(String metric) {
    switch (metric) {
      case 'pCasa':
        return "Vitória Casa";
      case 'pEmpate':
        return "Empate";
      case 'pFora':
        return "Vitória Fora";
      case 'p1X':
        return "Chance Dupla 1X";
      case 'pX2':
        return "Chance Dupla X2";
      case 'p12':
        return "Chance Dupla 12";
      case 'pOver15':
        return "Over 1.5";
      case 'pUnder15':
        return "Under 1.5";
      case 'pOver25':
        return "Over 2.5";
      case 'pUnder25':
        return "Under 2.5";
      case 'pOver35':
        return "Over 3.5";
      case 'pUnder35':
        return "Under 3.5";
      case 'pOver45':
        return "Over 4.5";
      case 'pUnder45':
        return "Under 4.5";
      case 'pBTTS_Sim':
        return "Ambos Marcam (Sim)";
      case 'pBTTS_Nao':
        return "Ambos Marcam (Não)";
      case 'edge':
        return "Edge (Value Bet)";
      default:
        return metric;
    }
  }

  bool? _resultadoAtendeValueBet(String aposta, int casa, int fora) {
    switch (aposta) {
      case 'Casa':
        return casa > fora;
      case 'Empate':
        return casa == fora;
      case 'Fora':
        return casa < fora;
      default:
        return null;
    }
  }

  bool? _resultadoAtendeMetricaPoisson(Map<String, dynamic> card, int casa, int fora, String metric) {
    switch (metric) {
      case 'pCasa':
        return casa > fora;
      case 'pEmpate':
        return casa == fora;
      case 'pFora':
        return casa < fora;
      case 'p1X':
        return casa >= fora;
      case 'pX2':
        return casa <= fora;
      case 'p12':
        return casa != fora;
      case 'pOver15':
        return (casa + fora) > 1;
      case 'pUnder15':
        return (casa + fora) <= 1;
      case 'pOver25':
        return (casa + fora) > 2;
      case 'pUnder25':
        return (casa + fora) <= 2;
      case 'pOver35':
        return (casa + fora) > 3;
      case 'pUnder35':
        return (casa + fora) <= 3;
      case 'pOver45':
        return (casa + fora) > 4;
      case 'pUnder45':
        return (casa + fora) <= 4;
      case 'pBTTS_Sim':
        return casa > 0 && fora > 0;
      case 'pBTTS_Nao':
        return casa == 0 || fora == 0;
      case 'edge':
        final String? aposta = card['resultados']?['value']?['aposta'] as String?;
        if (aposta == null) return null;
        return _resultadoAtendeValueBet(aposta, casa, fora);
      default:
        return null;
    }
  }

  void _mostrarDetalhesEDiario(Map<String, dynamic> aposta) {
    final observacaoCtrl = TextEditingController(text: aposta['observacaoPosJogo'] ?? '');
    final placarCasaCtrl = TextEditingController(text: aposta['placarCasa']?.toString() ?? '');
    final placarForaCtrl = TextEditingController(text: aposta['placarFora']?.toString() ?? '');
    final double lucro = (aposta['lucro'] as num).toDouble();
    final bool isGreen = lucro > 0;
    final bool isRed = lucro < 0;
    final Color corStatus = isGreen ? Colors.green : (isRed ? Colors.red : Colors.grey);
    final String apostaIdStr = aposta['id'].toString();

    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
            builder: (context, setStateDialog) {
              // Buscar vínculos em tempo real
              Map<String, dynamic>? cardConfianca;
              Map<String, dynamic>? cardPoisson;
              try { cardConfianca = _cardsConfianca.firstWhere((c) => c['linkedBetId'] == apostaIdStr); } catch (_) {}
              try { cardPoisson = _cardsPoisson.firstWhere((c) => c['linkedBetId'] == apostaIdStr); } catch (_) {}

              return AlertDialog(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                title: Row(children: [Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: corStatus.withOpacity(0.1), shape: BoxShape.circle), child: Icon(Icons.description, color: corStatus)), const SizedBox(width: 10), const Text("Detalhes & Diário", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold))]),
                content: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Cabeçalho da Aposta
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(colors: [corStatus.withOpacity(0.2), corStatus.withOpacity(0.05)], begin: Alignment.topLeft, end: Alignment.bottomRight),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: corStatus.withOpacity(0.3)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("${aposta['time']} (${aposta['campeonato']})", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                            const SizedBox(height: 6),
                            Text("${aposta['tipo']}", style: TextStyle(fontSize: 14, color: Colors.grey.shade800)),
                            const SizedBox(height: 12),
                            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [_buildMiniInfo("Odd", aposta['odd'].toString()), _buildMiniInfo("Stake", "R\$ ${(aposta['stake'] as num).toStringAsFixed(2)}"), _buildMiniInfo("Lucro", "R\$ ${lucro.toStringAsFixed(2)}", isBold: true, color: corStatus)]),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),

                      _buildInfoRow("Data", DateFormat('dd/MM/yyyy HH:mm').format(DateTime.parse(aposta['data']))),
                      _buildInfoRow("Ciclo", "ID ${aposta['cicloId']}"),
                      _buildInfoRow("Confiança (Manual)", "${aposta['nivelConfianca'] ?? '-'} / 10"),
                      _buildInfoRow("EV+ (Valor)", aposta['evPositivo'] == true ? "Sim" : "Não"),
                      const SizedBox(height: 12),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(color: Colors.grey.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                        child: Text(aposta['comentarios'] ?? "Nenhuma anotação prévia.", style: const TextStyle(fontSize: 13, fontStyle: FontStyle.italic)),
                      ),

                      // === SEÇÃO VÍNCULO CONFIANÇA ===
                      const Divider(height: 30),
                      Row(children: const [Icon(Icons.check_circle_outline, color: Colors.teal, size: 20), SizedBox(width: 6), Text("Análise de Confiança", style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.teal))]),
                      const SizedBox(height: 10),

                      if (cardConfianca == null)
                        OutlinedButton.icon(onPressed: () => _mostrarDialogoSelecaoVinculo(aposta['id']), icon: const Icon(Icons.link, size: 18), label: const Text("Vincular Análise"), style: OutlinedButton.styleFrom(foregroundColor: Colors.teal))
                      else
                        _buildCardConfiancaExpandivel(cardConfianca, () {
                          _confirmarDesvinculo(context, () {
                            _desvincularCard(cardConfianca!['id']);
                            setStateDialog(() {});
                          });
                        }),

                      // === SEÇÃO VÍNCULO POISSON (NOVO) ===
                      const SizedBox(height: 16),
                      Row(children: const [Icon(Icons.calculate_outlined, color: Colors.indigo, size: 20), SizedBox(width: 6), Text("Análise Poisson", style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.indigo))]),
                      const SizedBox(height: 10),

                      if (cardPoisson == null)
                        OutlinedButton.icon(onPressed: () => _mostrarDialogoSelecaoVinculoPoisson(aposta['id']), icon: const Icon(Icons.link, size: 18), label: const Text("Vincular Poisson"), style: OutlinedButton.styleFrom(foregroundColor: Colors.indigo))
                      else
                        _buildCardPoissonExpandivel(
                          cardPoisson,
                              () {
                            _confirmarDesvinculo(context, () {
                              _desvincularCardPoisson(cardPoisson!['id']);
                              setStateDialog(() {});
                            });
                          },
                          placarCasa: int.tryParse(placarCasaCtrl.text),
                          placarFora: int.tryParse(placarForaCtrl.text),
                          metric: _poissonMetric,
                        ),

                      const Divider(height: 30),
                      Row(children: const [Icon(Icons.scoreboard, color: Colors.deepPurple, size: 20), SizedBox(width: 6), Text("Placar Final", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.deepPurple))]),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: placarCasaCtrl,
                              keyboardType: TextInputType.number,
                              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                              onChanged: (_) => setStateDialog(() {}),
                              decoration: InputDecoration(labelText: "Casa", border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)), filled: true, fillColor: Colors.white),
                            ),
                          ),
                          const SizedBox(width: 12),
                          const Text("x", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                          const SizedBox(width: 12),
                          Expanded(
                            child: TextField(
                              controller: placarForaCtrl,
                              keyboardType: TextInputType.number,
                              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                              onChanged: (_) => setStateDialog(() {}),
                              decoration: InputDecoration(labelText: "Fora", border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)), filled: true, fillColor: Colors.white),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      Row(children: const [Icon(Icons.edit_note, color: Colors.indigo, size: 20), SizedBox(width: 6), Text("Diário Pós-Jogo", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.indigo))]),
                      const SizedBox(height: 8),
                      TextField(
                        controller: observacaoCtrl,
                        maxLines: 4,
                        style: const TextStyle(fontSize: 14),
                        decoration: InputDecoration(hintText: "Escreva suas conclusões...", border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)), filled: true, fillColor: Colors.white),
                      ),
                    ],
                  ),
                ),
                actions: [
                  TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Fechar", style: TextStyle(color: Colors.grey))),
                  ElevatedButton.icon(
                    icon: const Icon(Icons.check, size: 18),
                    label: const Text("Salvar Diário"),
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.indigo, foregroundColor: Colors.white),
                    onPressed: () {
                      final placarCasa = int.tryParse(placarCasaCtrl.text.trim());
                      final placarFora = int.tryParse(placarForaCtrl.text.trim());
                      _salvarObservacao(aposta['id'], observacaoCtrl.text, placarCasa: placarCasa, placarFora: placarFora);
                      Navigator.pop(ctx);
                    },
                  ),
                ],
              );
            }
        );
      },
    );
  }

  // --- WIDGETS AUXILIARES PARA CARDS VINCULADOS ---

  Widget _buildCardConfiancaExpandivel(Map<String, dynamic> card, VoidCallback onUnlink) {
    final nota = (card['nota'] as num).toDouble();
    final obs = (card['observacoes'] as List).cast<String>();
    final respostas = (card['respostas'] as List).cast<bool>();
    final anuladas = (card['anuladas'] as List?)?.cast<bool>() ?? List.filled(6, false);

    return Container(
      decoration: BoxDecoration(color: Colors.teal.shade50, borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.teal.shade200)),
      child: ExpansionTile(
        shape: const Border(),
        tilePadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 0),
        leading: CircleAvatar(radius: 14, backgroundColor: _getCorNota(nota), child: Text(nota.toInt().toString(), style: const TextStyle(fontSize: 11, color: Colors.white, fontWeight: FontWeight.bold))),
        title: Text(card['titulo'] ?? "Análise", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.teal)),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(icon: const Icon(Icons.link_off, color: Colors.red, size: 18), onPressed: onUnlink, tooltip: "Desvincular"),
            const Icon(Icons.expand_more, size: 20, color: Colors.teal),
          ],
        ),
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: List.generate(respostas.length, (i) {
                if (anuladas[i]) return const SizedBox.shrink();
                final txt = obs[i];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 4.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(respostas[i] ? Icons.check : Icons.close, size: 12, color: respostas[i] ? (i==5?Colors.red:Colors.green) : Colors.grey),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text("Q${i+1}: ${txt.isNotEmpty ? txt : (respostas[i] ? 'Sim' : 'Não')}", style: const TextStyle(fontSize: 11, color: Colors.black87)),
                      ),
                    ],
                  ),
                );
              }),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildCardPoissonExpandivel(
      Map<String, dynamic> card,
      VoidCallback onUnlink, {
        int? placarCasa,
        int? placarFora,
        String? metric,
      }) {
    final res = card['resultados'] as Map<String, dynamic>;
    final probGols = res['probGols'] as Map<String, dynamic>?;
    final placarProvavel = res['placarProvavel'] as Map<String, dynamic>?;

    // Helpers internos para exibição
    String p(dynamic v) => _fmtPct(v);
    String o(dynamic v) => _fmt2(v);

    return Container(
      decoration: BoxDecoration(color: Colors.indigo.shade50, borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.indigo.shade200)),
      child: ExpansionTile(
        shape: const Border(),
        tilePadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 0),
        leading: const Icon(Icons.bar_chart, size: 24, color: Colors.indigo),
        title: Text("${card['mandante']} x ${card['visitante']}", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.indigo)),
        subtitle: Text("Casa: ${p(res['pCasa'])} | Over 2.5: ${p(probGols?['Over 2.5']?['prob'] ?? 0)}", style: const TextStyle(fontSize: 11)),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(icon: const Icon(Icons.link_off, color: Colors.red, size: 18), onPressed: onUnlink, tooltip: "Desvincular"),
            const Icon(Icons.expand_more, size: 20, color: Colors.indigo),
          ],
        ),
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Divider(),
                const Text("Probabilidades Calculadas:", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11)),
                const SizedBox(height: 4),
                // Placar exato mais provável
                if (placarProvavel != null)
                  Text(
                    "🔮 Placar Provável: ${placarProvavel['hg']} x ${placarProvavel['ag']} (${p(placarProvavel['p'])})",
                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.indigo.shade800),
                  ),
                const SizedBox(height: 4),
                Text("1x2: ${p(res['pCasa'])} - ${p(res['pEmpate'])} - ${p(res['pFora'])}", style: const TextStyle(fontSize: 11)),

                if (probGols != null) ...[
                  const SizedBox(height: 4),
                  Text("Gols 1.5: Over ${p(probGols['Over 1.5']['prob'])} / Under ${p(probGols['Under 1.5']['prob'])}", style: const TextStyle(fontSize: 11)),
                  Text("Gols 2.5: Over ${p(probGols['Over 2.5']['prob'])} / Under ${p(probGols['Under 2.5']['prob'])}", style: const TextStyle(fontSize: 11)),
                  Text("Gols 3.5: Over ${p(probGols['Over 3.5']['prob'])} / Under ${p(probGols['Under 3.5']['prob'])}", style: const TextStyle(fontSize: 11)),
                  // Linha Over 4.5 Adicionada
                  Text(
                    "Gols 4.5: Over ${p(probGols['Over 4.5']['prob'])} / Under ${p(probGols['Under 4.5']['prob'])}",
                    style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 4),
                  Text("BTTS: Sim ${p(probGols['Ambos Marcam (Sim)']['prob'])} / Não ${p(probGols['Ambos Marcam (Não)']['prob'])}", style: const TextStyle(fontSize: 11)),
                ],

                if (res['value'] != null) ...[
                  const SizedBox(height: 6),
                  Text("Sugestão: ${res['value']['aposta']} (Edge: ${o(res['value']['edge'])})", style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.green.shade800)),
                ],
                if (placarCasa != null && placarFora != null) ...[
                  const Divider(),
                  Text("Resultado Real: $placarCasa x $placarFora", style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                  if (metric != null) ...[
                    const SizedBox(height: 4),
                    Builder(builder: (context) {
                      final confirmou = _resultadoAtendeMetricaPoisson(card, placarCasa, placarFora, metric);
                      if (confirmou == null) {
                        return Text("Métrica atual: ${_poissonMetricLabel(metric)} (sem veredito)", style: const TextStyle(fontSize: 11, color: Colors.grey));
                      }
                      return Text(
                        "Métrica atual: ${_poissonMetricLabel(metric)} — ${confirmou ? 'Confirmou' : 'Não confirmou'}",
                        style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: confirmou ? Colors.green : Colors.red),
                      );
                    }),
                  ],
                ],
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildMiniInfo(String label, String value, {bool isBold = false, Color? color}) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(label, style: const TextStyle(fontSize: 11, color: Colors.black54)), Text(value, style: TextStyle(fontWeight: isBold ? FontWeight.bold : FontWeight.normal, fontSize: 14, color: color ?? Colors.black87))]);
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(padding: const EdgeInsets.only(bottom: 6), child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text(label, style: TextStyle(fontSize: 13, color: Colors.grey.shade600, fontWeight: FontWeight.w500)), Text(value, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600))]));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(title: const Text('Pesquisa & Diário'), backgroundColor: Colors.white, foregroundColor: Colors.black87, elevation: 0),
      body: _carregarDataBody(),
    );
  }

  Widget _carregarDataBody() {
    if (_carregando) return const Center(child: CircularProgressIndicator());

    String textoPeriodo = _startDate != null && _endDate != null ? "${DateFormat('dd/MM').format(_startDate!)} - ${DateFormat('dd/MM').format(_endDate!)}" : "Filtrar por Data";
    final playbooksOrdenados = List<Map<String, dynamic>>.from(_playbooks)..sort((a, b) => (a['nome'] as String).compareTo(b['nome'] as String));

    return Column(
      children: [
        // === CABEÇALHO DE PESQUISA ===
        Container(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.only(bottomLeft: Radius.circular(24), bottomRight: Radius.circular(24)), boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, 4))]),
          child: Column(
            children: [
              // MODO SWITCH
              Padding(
                padding: const EdgeInsets.only(bottom: 12.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildModeToggle(title: "Padrão", isSelected: _modoPesquisa == 0, onTap: () => setState(() { _modoPesquisa = 0; _aplicarTodosFiltros(); })),
                    const SizedBox(width: 8),
                    _buildModeToggle(title: "Análise", isSelected: _modoPesquisa == 1, onTap: () => setState(() { _modoPesquisa = 1; _aplicarTodosFiltros(); })),
                    const SizedBox(width: 8),
                    _buildModeToggle(title: "Poisson", isSelected: _modoPesquisa == 2, onTap: () => setState(() { _modoPesquisa = 2; _aplicarTodosFiltros(); })),
                  ],
                ),
              ),

              // ÁREA DE FILTRO PRINCIPAL (CrossFade entre 3 modos seria complexo, usando Builder)
              Container(
                decoration: BoxDecoration(
                  color: _modoPesquisa == 0 ? Colors.grey.shade100 : (_modoPesquisa == 1 ? Colors.teal.shade50 : Colors.indigo.shade50),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: _modoPesquisa == 0 ? Colors.transparent : (_modoPesquisa == 1 ? Colors.teal.shade200 : Colors.indigo.shade200)),
                ),
                child: _buildFilterContent(),
              ),

              const SizedBox(height: 12),

              // Filtros Rápidos
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    InkWell(
                      onTap: _selecionarPeriodo,
                      borderRadius: BorderRadius.circular(20),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(color: _startDate != null ? Colors.indigo.withOpacity(0.1) : Colors.transparent, border: Border.all(color: _startDate != null ? Colors.indigo : Colors.grey.shade300), borderRadius: BorderRadius.circular(20)),
                        child: Row(children: [Icon(Icons.calendar_today, size: 14, color: _startDate != null ? Colors.indigo : Colors.grey.shade600), const SizedBox(width: 6), Text(textoPeriodo, style: TextStyle(fontSize: 12, color: _startDate != null ? Colors.indigo : Colors.grey.shade800, fontWeight: FontWeight.w500)), if (_startDate != null) ...[const SizedBox(width: 4), InkWell(onTap: () { setState(() { _startDate = null; _endDate = null; }); _aplicarTodosFiltros(); }, child: const Icon(Icons.close, size: 14, color: Colors.red))]]),
                      ),
                    ),
                    const SizedBox(width: 8),
                    _buildFilterChip('Todos'),
                    _buildFilterChip('Green'),
                    _buildFilterChip('Red'),
                    _buildFilterChip('Sem Diário'),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              DropdownButtonFormField<int?>(
                value: _filtroPlaybookId,
                isDense: true,
                decoration: const InputDecoration(labelText: 'Filtrar por playbook'),
                items: [
                  const DropdownMenuItem<int?>(value: null, child: Text('Todos os playbooks')),
                  ...playbooksOrdenados.map((p) => DropdownMenuItem<int?>(
                    value: (p['id'] as num).toInt(),
                    child: Text(p['nome'] as String),
                  )),
                ],
                onChanged: (v) => setState(() { _filtroPlaybookId = v; _aplicarTodosFiltros(); }),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<int>(
                      value: _compararPlaybookAId,
                      isDense: true,
                      decoration: const InputDecoration(labelText: 'Comparar A'),
                      items: playbooksOrdenados.map((p) => DropdownMenuItem<int>(value: (p['id'] as num).toInt(), child: Text(p['nome'] as String))).toList(),
                      onChanged: (v) => setState(() => _compararPlaybookAId = v),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: DropdownButtonFormField<int>(
                      value: _compararPlaybookBId,
                      isDense: true,
                      decoration: const InputDecoration(labelText: 'Comparar B'),
                      items: playbooksOrdenados.map((p) => DropdownMenuItem<int>(value: (p['id'] as num).toInt(), child: Text(p['nome'] as String))).toList(),
                      onChanged: (v) => setState(() => _compararPlaybookBId = v),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

        // === KPI RESUMO ===
        _buildResumoVisual(),
        _buildComparacaoPlaybooks(),

        // === LISTA DE APOSTAS ===
        Expanded(
          child: _apostasFiltradas.isEmpty
              ? Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.search_off_rounded, size: 80, color: Colors.grey.shade300), const SizedBox(height: 16), Text("Nenhum registro encontrado.", style: TextStyle(color: Colors.grey.shade500, fontSize: 16))]))
              : ListView.builder(
            padding: const EdgeInsets.only(top: 8, bottom: 20, left: 16, right: 16),
            itemCount: _apostasFiltradas.length,
            itemBuilder: (context, index) {
              return _buildApostaCard(_apostasFiltradas[index]);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildFilterContent() {
    // MODO 0: PADRÃO
    if (_modoPesquisa == 0) {
      return Row(
        children: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.tune, color: Colors.indigo),
            onSelected: (String val) { setState(() { _criterioSelecionado = val; _searchController.clear(); _aplicarTodosFiltros(); }); },
            itemBuilder: (context) => _criteriosPadrao.map((c) => PopupMenuItem(value: c, child: Text(c))).toList(),
          ),
          Expanded(
            child: Autocomplete<String>(
              optionsBuilder: (textVal) { if (textVal.text.isEmpty) return const Iterable<String>.empty(); return _getOpcoesAutocomplete(textVal.text); },
              onSelected: (selection) { _searchController.text = selection; _aplicarTodosFiltros(); FocusScope.of(context).unfocus(); },
              fieldViewBuilder: (context, controller, focusNode, onSubmit) {
                if (controller.text != _searchController.text) controller.text = _searchController.text;
                return TextField(controller: controller, focusNode: focusNode, decoration: InputDecoration(hintText: "Buscar por $_criterioSelecionado...", border: InputBorder.none, contentPadding: const EdgeInsets.symmetric(horizontal: 8)), onChanged: (val) { _searchController.text = val; _aplicarTodosFiltros(); });
              },
            ),
          ),
          if (_searchController.text.isNotEmpty) IconButton(icon: const Icon(Icons.clear, size: 18, color: Colors.grey), onPressed: () { _searchController.clear(); _aplicarTodosFiltros(); }),
        ],
      );
    }

    // MODO 2: POISSON (NOVO PAINEL DE BACKTEST)
    if (_modoPesquisa == 2) {
      return Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text("🔬 Validação de Cenários (Backtest)", style: TextStyle(color: Colors.indigo, fontWeight: FontWeight.bold, fontSize: 13)),
            const SizedBox(height: 12),

            // LINHA 1: MÉTRICA E FAIXA DE ODD
            Row(
              children: [
                Expanded(
                  flex: 3,
                  child: DropdownButtonFormField<String>(
                    value: _poissonMetric,
                    isDense: true,
                    isExpanded: true, // Garante que o texto não quebre layout
                    decoration: const InputDecoration(labelText: "Métrica Poisson", border: OutlineInputBorder(), contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 8)),
                    items: const [
                      DropdownMenuItem(value: 'pCasa', child: Text("Vitória Casa")),
                      DropdownMenuItem(value: 'pEmpate', child: Text("Empate")),
                      DropdownMenuItem(value: 'pFora', child: Text("Vitória Fora")),

                      DropdownMenuItem(value: 'p1X', child: Text("Chance Dupla 1X")),
                      DropdownMenuItem(value: 'pX2', child: Text("Chance Dupla X2")),
                      DropdownMenuItem(value: 'p12', child: Text("Chance Dupla 12")),

                      DropdownMenuItem(value: 'pOver15', child: Text("Over 1.5")),
                      DropdownMenuItem(value: 'pUnder15', child: Text("Under 1.5")),

                      DropdownMenuItem(value: 'pOver25', child: Text("Over 2.5")),
                      DropdownMenuItem(value: 'pUnder25', child: Text("Under 2.5")),

                      DropdownMenuItem(value: 'pOver35', child: Text("Over 3.5")),
                      DropdownMenuItem(value: 'pUnder35', child: Text("Under 3.5")),

                      DropdownMenuItem(value: 'pOver45', child: Text("Over 4.5")),
                      DropdownMenuItem(value: 'pUnder45', child: Text("Under 4.5")),

                      DropdownMenuItem(value: 'pBTTS_Sim', child: Text("Ambos Marcam (Sim)")),
                      DropdownMenuItem(value: 'pBTTS_Nao', child: Text("Ambos Marcam (Não)")),

                      DropdownMenuItem(value: 'pPlacarExato', child: Text("Prob. Placar Exato")),
                      DropdownMenuItem(value: 'edge', child: Text("Valor (Edge)")),
                    ],
                    onChanged: (v) => setState(() { _poissonMetric = v!; _aplicarTodosFiltros(); }),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  flex: 2,
                  child: DropdownButtonFormField<String>(
                    value: _oddRangeFilter,
                    isDense: true,
                    decoration: const InputDecoration(labelText: "Odd Real", border: OutlineInputBorder(), contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 8)),
                    items: const [
                      DropdownMenuItem(value: 'Todas', child: Text("Todas")),
                      DropdownMenuItem(value: '1.01 - 1.50', child: Text("1.01-1.50")),
                      DropdownMenuItem(value: '1.51 - 1.80', child: Text("1.51-1.80")),
                      DropdownMenuItem(value: '1.81 - 2.20', child: Text("1.81-2.20")),
                      DropdownMenuItem(value: '2.21+', child: Text("2.21+")),
                    ],
                    onChanged: (v) => setState(() { _oddRangeFilter = v!; _aplicarTodosFiltros(); }),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // LINHA 2: SLIDER DE PROBABILIDADE MÍNIMA
            Row(
              children: [
                const Icon(Icons.filter_list, size: 20, color: Colors.indigo),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _poissonMetric == 'edge'
                            ? "Edge Mínimo: ${_poissonMinVal.toStringAsFixed(2)}"
                            : "Probabilidade Mínima: ${(_poissonMinVal * 100).toInt()}%",
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                      ),
                      SliderTheme(
                        data: SliderTheme.of(context).copyWith(trackHeight: 2, thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6)),
                        child: Slider(
                          value: _poissonMinVal,
                          min: _poissonMetric == 'edge' ? 0.0 : 0.0,
                          max: _poissonMetric == 'edge' ? 0.50 : 1.0,
                          divisions: _poissonMetric == 'edge' ? 50 : 20,
                          activeColor: Colors.indigo,
                          onChanged: (v) => setState(() { _poissonMinVal = v; _aplicarTodosFiltros(); }),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const Text(
              "Dica: Ajuste os filtros e veja o 'LUCRO' acima para validar a estratégia.",
              style: TextStyle(fontSize: 10, fontStyle: FontStyle.italic, color: Colors.grey),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    // MODO 1: ANÁLISE PRÉ-JOGO (Mantido estrutura original)
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text("Filtrar por resposta na análise de confiança:", style: TextStyle(color: Colors.teal, fontWeight: FontWeight.bold, fontSize: 12)),
          const SizedBox(height: 8),
          DropdownButton<int>(
            isExpanded: true,
            value: _filtroPerguntaIndex < _perguntasConfianca.length ? _filtroPerguntaIndex : 0,
            isDense: true,
            underline: Container(),
            items: List.generate(_perguntasConfianca.length, (index) {
              return DropdownMenuItem(value: index, child: Text(_perguntasConfianca[index], style: const TextStyle(fontSize: 13), overflow: TextOverflow.ellipsis));
            }),
            onChanged: (val) { if (val != null) setState(() { _filtroPerguntaIndex = val; _aplicarTodosFiltros(); }); },
          ),
          const Divider(),
          Row(
            children: [
              const Text("Critério:", style: TextStyle(fontSize: 12)),
              const SizedBox(width: 12),
              ChoiceChip(label: const Text("Sim"), selected: _respostaEsperada == 1, onSelected: (val) => setState(() { _respostaEsperada = 1; _aplicarTodosFiltros(); }), selectedColor: Colors.green.shade100, labelStyle: TextStyle(color: _respostaEsperada == 1 ? Colors.green.shade900 : Colors.black)),
              const SizedBox(width: 8),
              ChoiceChip(label: const Text("Não"), selected: _respostaEsperada == 0, onSelected: (val) => setState(() { _respostaEsperada = 0; _aplicarTodosFiltros(); }), selectedColor: Colors.red.shade100, labelStyle: TextStyle(color: _respostaEsperada == 0 ? Colors.red.shade900 : Colors.black)),
              const SizedBox(width: 8),
              ChoiceChip(label: const Text("N/A"), selected: _respostaEsperada == 2, onSelected: (val) => setState(() { _respostaEsperada = 2; _aplicarTodosFiltros(); }), selectedColor: Colors.grey.shade300),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildModeToggle({required String title, required bool isSelected, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(color: isSelected ? (title == "Poisson" ? Colors.indigo : (title == "Análise" ? Colors.teal : Colors.indigo)) : Colors.grey.shade200, borderRadius: BorderRadius.circular(20)),
        child: Text(title, style: TextStyle(color: isSelected ? Colors.white : Colors.black54, fontWeight: FontWeight.bold, fontSize: 13)),
      ),
    );
  }

  Widget _buildFilterChip(String label) {
    final bool isSelected = _filtroRapidoStatus == label;
    return Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: FilterChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (bool selected) { setState(() { _filtroRapidoStatus = selected ? label : 'Todos'; if (!selected) _filtroRapidoStatus = 'Todos'; }); _aplicarTodosFiltros(); },
        backgroundColor: Colors.white,
        selectedColor: Colors.indigo.withOpacity(0.2),
        labelStyle: TextStyle(color: isSelected ? Colors.indigo : Colors.black87, fontSize: 12, fontWeight: isSelected ? FontWeight.bold : FontWeight.normal),
        showCheckmark: false,
      ),
    );
  }

  Widget _buildResumoVisual() {
    if (_apostasFiltradas.isEmpty) return const SizedBox.shrink();

    double lucroTotal = 0;
    double flatTotal = 0; // Variável para o KPI novo
    int wins = 0;
    int total = _apostasFiltradas.length;

    for (var a in _apostasFiltradas) {
      final l = (a['lucro'] as num).toDouble();
      final odd = (a['odd'] as num).toDouble();

      lucroTotal += l;
      if (l > 0) {
        wins++;
        flatTotal += (odd - 1.0); // Ganhou: Odd-1
      } else if (l < 0) {
        flatTotal -= 1.0; // Perdeu: -1
      }
      // Reembolso (void) soma 0, não faz nada
    }

    final winRate = total > 0 ? (wins / total * 100) : 0.0;

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Row(
        children: [
          Expanded(child: _buildKpiCard("JOGOS", "$total", Icons.sports_soccer, Colors.blue)),
          const SizedBox(width: 8),
          Expanded(child: _buildKpiCard("WINRATE", "${winRate.toStringAsFixed(0)}%", Icons.pie_chart, Colors.purple)),
          const SizedBox(width: 8),
          Expanded(child: _buildKpiCard("LUCRO", "R\$ ${lucroTotal.toStringAsFixed(0)}", Icons.attach_money, lucroTotal >= 0 ? Colors.green : Colors.red)),
          const SizedBox(width: 8),
          // NOVO KPI: Flat Stake
          Expanded(child: _buildKpiCard("FLAT (u)", "${flatTotal > 0 ? '+' : ''}${flatTotal.toStringAsFixed(1)}", Icons.bar_chart, flatTotal >= 0 ? Colors.teal : Colors.deepOrange)),
        ],
      ),
    );
  }

  Widget _buildKpiCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.grey.shade200), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 4, offset: const Offset(0, 2))]),
      child: Column(
          children: [
            Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(icon, size: 10, color: Colors.grey),
                  const SizedBox(width: 2),
                  Text(title, style: const TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Colors.grey)) // Fonte menor no título para caber 4
                ]
            ),
            const SizedBox(height: 4),
            Text(value, style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: color), textAlign: TextAlign.center, overflow: TextOverflow.ellipsis)
          ]
      ),
    );
  }

  Widget _buildApostaCard(Map<String, dynamic> aposta) {
    final lucro = (aposta['lucro'] as num).toDouble();
    final isGreen = lucro > 0;
    final isRed = lucro < 0;
    final Color statusColor = isGreen ? Colors.green : (isRed ? Colors.red : Colors.grey);
    final hasDiary = aposta['observacaoPosJogo'] != null && aposta['observacaoPosJogo'].toString().isNotEmpty;
    final String apostaIdStr = aposta['id'].toString();
    final hasLinkedConfidence = _cardsConfianca.any((c) => c['linkedBetId'] == apostaIdStr);
    final hasLinkedPoisson = _cardsPoisson.any((c) => c['linkedBetId'] == apostaIdStr);
    final int? placarCasa = (aposta['placarCasa'] as num?)?.toInt();
    final int? placarFora = (aposta['placarFora'] as num?)?.toInt();
    Map<String, dynamic>? cardPoisson;
    if (hasLinkedPoisson) {
      try { cardPoisson = _cardsPoisson.firstWhere((c) => c['linkedBetId'] == apostaIdStr); } catch (_) {}
    }
    final bool? validacaoPoisson = (cardPoisson != null && placarCasa != null && placarFora != null && _modoPesquisa == 2)
        ? _resultadoAtendeMetricaPoisson(cardPoisson, placarCasa, placarFora, _poissonMetric)
        : null;

    return Card(
      elevation: 0,
      color: Colors.white,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide(color: Colors.grey.shade200)),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => _mostrarDetalhesEDiario(aposta),
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(width: 6, decoration: BoxDecoration(color: statusColor, borderRadius: const BorderRadius.only(topLeft: Radius.circular(12), bottomLeft: Radius.circular(12)))),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                        Text(aposta['campeonato']?.toUpperCase() ?? 'CAMP', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: Colors.grey.shade500, letterSpacing: 0.5)),
                        Text(DateFormat('dd/MM HH:mm').format(DateTime.parse(aposta['data'])), style: TextStyle(fontSize: 11, color: Colors.grey.shade600)),
                      ],
                      ),
                      const SizedBox(height: 6),
                      Text(aposta['time'] ?? 'Time', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87), maxLines: 1, overflow: TextOverflow.ellipsis),
                      Text("${aposta['tipo']} @ ${aposta['odd']}", style: TextStyle(fontSize: 13, color: Colors.grey.shade700)),
                      if ((aposta['playbookNome'] as String?)?.isNotEmpty == true)
                        Text('Playbook: ${aposta['playbookNome']}', style: TextStyle(fontSize: 12, color: Colors.indigo.shade700, fontWeight: FontWeight.w600)),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(children: [
                            Container(padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2), decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(4)), child: Text("R\$ ${(aposta['stake'] as num).toStringAsFixed(0)}", style: const TextStyle(fontSize: 11, color: Colors.grey))),
                            const SizedBox(width: 8),
                            if (placarCasa != null && placarFora != null)
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(color: Colors.deepPurple.shade50, borderRadius: BorderRadius.circular(4)),
                                child: Text("$placarCasa x $placarFora", style: TextStyle(fontSize: 11, color: Colors.deepPurple.shade700, fontWeight: FontWeight.bold)),
                              ),
                            if (placarCasa != null && placarFora != null) const SizedBox(width: 8),
                            if (!hasDiary) Icon(Icons.edit_note, size: 16, color: Colors.grey.shade300) else const Icon(Icons.assignment, size: 16, color: Colors.indigo),
                            if (hasLinkedConfidence) ...[const SizedBox(width: 4), const Icon(Icons.link, size: 16, color: Colors.teal)],
                            if (hasLinkedPoisson) ...[const SizedBox(width: 4), const Icon(Icons.bar_chart, size: 16, color: Colors.indigo)],
                            if (_modoPesquisa == 2 && validacaoPoisson != null) ...[
                              const SizedBox(width: 4),
                              Icon(validacaoPoisson ? Icons.check_circle : Icons.cancel, size: 16, color: validacaoPoisson ? Colors.green : Colors.red),
                            ],
                          ],
                          ),
                          Text(isGreen ? "+ R\$ ${lucro.toStringAsFixed(2)}" : "R\$ ${lucro.toStringAsFixed(2)}", style: TextStyle(fontWeight: FontWeight.w800, fontSize: 15, color: statusColor)),
                        ],
                      ),
                    ],
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
// ===================================================================
// FIM DA TELA DE PESQUISA (Tela 5)
// ===================================================================



// ===================================================================
// INÍCIO DO BLOCO DA TELA DE EVENTOS ( TELA 6)
// ===================================================================

class TelaInvestimentos extends StatefulWidget {
  const TelaInvestimentos({super.key});

  @override
  State<TelaInvestimentos> createState() => _TelaInvestimentosState();
}

class _TelaInvestimentosState extends State<TelaInvestimentos> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // Dados Brutos
  List<Map<String, dynamic>> _eventos = [];
  Map<int, Map<String, dynamic>> _timelineMap = {}; // Mapa base (Transação a Transação)
  List<int> _timelineKeys = []; // Chaves ordenadas do mapa base

  // Dados Processados para o Gráfico (Agrupados)
  List<Map<String, dynamic>> _pontosGrafico = [];

  // Dados Metas
  List<Map<String, dynamic>> _listaMetas = [];

  // Filtros de Visualização
  String _filtroPeriodo = 'TUDO';
  String _filtroBusca = '';

  // Novos Filtros de Gráfico
  String _agrupamentoVisualizacao = 'Aposta'; // 'Aposta', 'Dia', 'Semana', 'Mês', 'Ano'
  bool _exibirEventos = true;
  bool _exibirMetas = true;
  bool _exibirRecordes = true;

  final _buscaCtrl = TextEditingController();

  // Controladores do Formulário de Eventos
  final _tituloCtrl = TextEditingController();
  final _descricaoCtrl = TextEditingController();

  // Estatísticas Gerais
  double _saldoAtual = 0.0;
  double _maiorSaldoHistorico = 0.0;
  double _drawdown = 0.0;
  int _qtdRecordes = 0;

  bool _carregando = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _carregarDadosCompletos();
  }

  @override
  void dispose() {
    _buscaCtrl.dispose();
    _tituloCtrl.dispose();
    _descricaoCtrl.dispose();
    _tabController.dispose();
    super.dispose();
  }

  Future<File> _getFile(String fileName) async {
    final dir = await getApplicationDocumentsDirectory();
    return File("${dir.path}/$fileName");
  }

  Future<void> _atualizarArquivoIA() async {
    try {
      final resumoParaIA = {
        "timestamp_atualizacao": DateTime.now().toIso8601String(),
        "dashboard_financeiro": {
          "saldo_atual": _saldoAtual,
          "maior_saldo_historico": _maiorSaldoHistorico,
          "drawdown_atual_percentual": _drawdown,
          "qtd_recordes_quebrados": _qtdRecordes,
          "filtro_visualizacao_ativo": _filtroPeriodo,
        },
        "resumo_metas": _listaMetas.map((m) {
          final atual = (m['atual'] as num?)?.toDouble() ?? 0.0;
          final alvo = (m['alvo'] as num?)?.toDouble() ?? 1.0;
          final porcentagem = (atual / (alvo == 0 ? 1 : alvo)) * 100;

          return {
            "titulo": m['titulo'],
            "tipo": m['tipo'],
            "status": m['concluida'] == true ? "CONCLUÍDA" : (m['perdida'] == true ? "PERDIDA" : "EM ANDAMENTO"),
            "progresso": "${porcentagem.toStringAsFixed(1)}%",
            "validade": m['validade'] ?? "Sem prazo"
          };
        }).toList(),
        "ultimos_eventos_diario": _eventos.take(10).map((e) => {
          "data": e['data'],
          "titulo": e['titulo'],
          "descricao": e['descricao'],
          "tipo": e['tipo']
        }).toList(),
      };

      final file = await _getFile("informacoes_para_IA.json");
      await file.writeAsString(jsonEncode(resumoParaIA));
    } catch (e) {
      debugPrint("Erro ao atualizar arquivo para IA: $e");
    }
  }

  Future<void> _carregarDadosCompletos({bool showLoading = true}) async {
    if (showLoading) setState(() => _carregando = true);
    if (!showLoading) await Future.delayed(const Duration(milliseconds: 500));

    await _carregarEventos();
    await _carregarMetas();

    await _processarDadosGrafico(apenasCalculoSaldo: true);
    await _atualizarStatusMetas();
    await _processarDadosGrafico(apenasCalculoSaldo: false);

    if (showLoading) {
      setState(() => _carregando = false);
    } else {
      setState(() {});
    }
  }

  // ... (Métodos de Metas e Arquivos mantidos iguais - omitidos para brevidade se não alterados, mas incluídos no contexto completo) ...
  // --- LÓGICA DE METAS ---
  Future<void> _carregarMetas() async {
    try {
      final file = await _getFile("metas_investimentos.json");
      if (await file.exists()) {
        final conteudo = await file.readAsString();
        if (conteudo.isNotEmpty) {
          final List<dynamic> jsonList = jsonDecode(conteudo);
          setState(() {
            _listaMetas = jsonList.map((e) => Map<String, dynamic>.from(e)).toList();
          });
        }
      }
    } catch (e) {
      debugPrint("Erro carregar metas: $e");
    }
  }

  Future<void> _salvarMetas() async {
    try {
      final file = await _getFile("metas_investimentos.json");
      await file.writeAsString(jsonEncode(_listaMetas));
    } catch (e) {
      debugPrint("Erro salvar metas: $e");
    }
  }

  Future<void> _salvarEventosArquivo() async {
    try {
      final file = await _getFile("eventos_timeline.json");
      await file.writeAsString(jsonEncode(_eventos));
    } catch (e) {
      debugPrint("Erro salvar eventos: $e");
    }
  }

  Future<void> _atualizarStatusMetas() async {
    bool houveMudanca = false;
    bool houveNovoEvento = false;
    final hoje = DateTime.now();

    for (var meta in _listaMetas) {
      bool concluida = meta['concluida'] ?? false;
      bool perdida = meta['perdida'] ?? false;

      if (concluida || perdida) continue;

      final tipo = meta['tipo'];

      if (tipo == 'financeira') {
        if (meta['subtipo'] == 'ganho') {
          double saldoInicial = (meta['saldoInicial'] as num?)?.toDouble() ?? 0.0;
          if (saldoInicial == 0 && meta['criadoEm'] == null) saldoInicial = _saldoAtual;
          meta['atual'] = _saldoAtual - saldoInicial;
        } else {
          meta['atual'] = _saldoAtual;
        }
        houveMudanca = true;
      }
      else if (tipo == 'checklist') {
        final rawItens = meta['checklistItens'] as List?;
        if (rawItens != null) {
          final itens = rawItens.map((e) => Map<String, dynamic>.from(e)).toList();
          int feitos = itens.where((i) => i['feito'] == true).length;
          meta['atual'] = feitos.toDouble();
          meta['alvo'] = itens.length.toDouble();
          houveMudanca = true;
        }
      }

      final atual = (meta['atual'] as num).toDouble();
      final alvo = (meta['alvo'] as num).toDouble();

      if (atual >= alvo && alvo > 0) {
        meta['concluida'] = true;
        meta['perdida'] = false;
        meta['dataConclusao'] = DateTime.now().toIso8601String();
        houveMudanca = true;
        continue;
      }

      if (meta['validade'] != null) {
        final validade = DateTime.parse(meta['validade']);
        if (hoje.isAfter(validade) && atual < alvo) {
          meta['perdida'] = true;
          meta['concluida'] = false;
          meta['dataConclusao'] = meta['validade'];
          houveMudanca = true;

          final novoEvento = {
            'id': DateTime.now().millisecondsSinceEpoch.toString(),
            'data': DateTime.now().toIso8601String(),
            'titulo': "Meta perdida: ${meta['titulo']}",
            'descricao': "A meta não foi atingida dentro do prazo.",
            'tipo': 'importante',
          };
          _eventos.insert(0, novoEvento);
          _eventos.sort((a, b) => DateTime.parse(b['data']).compareTo(DateTime.parse(a['data'])));
          houveNovoEvento = true;
        }
      }
    }

    if (houveMudanca) await _salvarMetas();
    if (houveNovoEvento) await _salvarEventosArquivo();
  }

  void _adicionarEditarMeta({Map<String, dynamic>? metaExistente}) {
    // Implementação simplificada para manter o foco na lógica do gráfico
    final nomeCtrl = TextEditingController(text: metaExistente?['titulo'] ?? '');
    final alvoCtrl = TextEditingController(text: metaExistente != null ? metaExistente['alvo'].toString() : '');
    final atualCtrl = TextEditingController(text: metaExistente != null ? metaExistente['atual'].toString() : '0');

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Gerenciar Meta"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: nomeCtrl, decoration: const InputDecoration(labelText: "Título")),
            const SizedBox(height: 8),
            TextField(controller: alvoCtrl, decoration: const InputDecoration(labelText: "Alvo")),
            TextField(controller: atualCtrl, decoration: const InputDecoration(labelText: "Atual")),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Cancelar")),
          ElevatedButton(
            onPressed: () async {
              if (nomeCtrl.text.isNotEmpty) {
                setState(() {
                  final novaMeta = {
                    'id': metaExistente?['id'] ?? DateTime.now().millisecondsSinceEpoch.toString(),
                    'titulo': nomeCtrl.text,
                    'tipo': 'financeira',
                    'alvo': double.tryParse(alvoCtrl.text) ?? 100.0,
                    'atual': double.tryParse(atualCtrl.text) ?? 0.0,
                    'concluida': false,
                    'perdida': false,
                  };
                  if (metaExistente != null) _listaMetas[_listaMetas.indexOf(metaExistente)] = novaMeta;
                  else _listaMetas.add(novaMeta);
                });
                await _salvarMetas();
                await _carregarDadosCompletos(showLoading: false);
                Navigator.pop(ctx);
              }
            },
            child: const Text("Salvar"),
          )
        ],
      ),
    );
  }

  void _atualizarProgressoMeta(Map<String, dynamic> meta, double valorAdicionar) async {
    if (meta['tipo'] == 'financeira') return;
    setState(() {
      double novoValor = (meta['atual'] as num).toDouble() + valorAdicionar;
      if (novoValor < 0) novoValor = 0;
      meta['atual'] = novoValor;
    });
    await _salvarMetas();
    await _carregarDadosCompletos(showLoading: false);
  }

  void _toggleChecklistItem(Map<String, dynamic> meta, int itemIndex, bool valor) async {
    final itens = (meta['checklistItens'] as List).map((e) => Map<String, dynamic>.from(e)).toList();
    itens[itemIndex]['feito'] = valor;
    setState(() { meta['checklistItens'] = itens; });
    await _salvarMetas();
    await _carregarDadosCompletos(showLoading: false);
  }

  void _excluirMeta(String id) async {
    setState(() {
      _listaMetas.removeWhere((m) => m['id'] == id);
    });
    await _salvarMetas();
    await _processarDadosGrafico();
  }

  // --- LÓGICA DE DADOS (TIMELINE E AGRUPAMENTO) ---
  Future<void> _carregarEventos() async {
    try {
      final file = await _getFile("eventos_timeline.json");
      if (await file.exists()) {
        final conteudo = await file.readAsString();
        if (conteudo.isNotEmpty) {
          final lista = jsonDecode(conteudo) as List;
          setState(() {
            _eventos = lista.cast<Map<String, dynamic>>();
            _eventos.sort((a, b) => DateTime.parse(b['data']).compareTo(DateTime.parse(a['data'])));
          });
        }
      }
    } catch (e) {
      debugPrint("Erro ao carregar eventos: $e");
    }
  }

  Future<void> _processarDadosGrafico({bool apenasCalculoSaldo = false}) async {
    try {
      // 1. Carrega dados brutos (apostas, config)
      final file = await _getFile("apostas_data.json");
      Map<String, dynamic> json = {};
      if (await file.exists()) {
        final conteudo = await file.readAsString();
        if (conteudo.isNotEmpty) json = jsonDecode(conteudo);
      }

      final apostas = (json['apostas'] as List?)?.cast<Map<String, dynamic>>() ?? [];
      final config = json['config'] as Map<String, dynamic>?;
      final aportes = (config?['aportes'] as List?)?.cast<Map<String, dynamic>>() ?? [];
      final saques = (config?['saques'] as List?)?.cast<Map<String, dynamic>>() ?? [];

      double bancaInicial = 1000.0;
      if (config != null && config['bancaInicial'] != null) {
        bancaInicial = (config['bancaInicial'] as num).toDouble();
      }

      // 2. Constrói _timelineMap (Transação por Transação - Base de tudo)
      final Map<int, Map<String, dynamic>> mapTemp = {};

      void ensureEntry(DateTime dt) {
        final ms = dt.millisecondsSinceEpoch;
        if (!mapTemp.containsKey(ms)) {
          mapTemp[ms] = {
            'dataObj': dt,
            'valorTransacao': 0.0,
            'saldoAcumulado': 0.0,
            'eventos': <Map<String, dynamic>>[],
            'metasConcluidas': <Map<String, dynamic>>[],
            'metasPerdidas': <Map<String, dynamic>>[],
            'isNovoRecorde': false,
          };
        }
      }

      // Inicializa com dados
      DateTime dataInicial = DateTime.now();
      List<DateTime> todasDatas = [];
      for(var a in apostas) todasDatas.add(DateTime.parse(a['data']));
      if (todasDatas.isNotEmpty) {
        todasDatas.sort((a,b) => a.compareTo(b));
        dataInicial = todasDatas.first.subtract(const Duration(days: 1));
      } else {
        dataInicial = DateTime.now().subtract(const Duration(days: 1));
      }
      ensureEntry(dataInicial);

      for (var a in apostas) {
        ensureEntry(DateTime.parse(a['data']));
        mapTemp[DateTime.parse(a['data']).millisecondsSinceEpoch]!['valorTransacao'] += (a['lucro'] as num).toDouble();
      }
      for (var a in aportes) {
        ensureEntry(DateTime.parse(a['data']));
        mapTemp[DateTime.parse(a['data']).millisecondsSinceEpoch]!['valorTransacao'] += (a['valor'] as num).toDouble();
      }
      for (var s in saques) {
        ensureEntry(DateTime.parse(s['data']));
        mapTemp[DateTime.parse(s['data']).millisecondsSinceEpoch]!['valorTransacao'] -= (s['valor'] as num).toDouble();
      }

      // Adiciona eventos e metas se não for apenas calculo
      if (!apenasCalculoSaldo) {
        for (var e in _eventos) {
          ensureEntry(DateTime.parse(e['data']));
          mapTemp[DateTime.parse(e['data']).millisecondsSinceEpoch]!['eventos'].add(e);
        }
        for (var m in _listaMetas) {
          if (m['dataConclusao'] != null) {
            ensureEntry(DateTime.parse(m['dataConclusao']));
            if (m['perdida'] == true) {
              mapTemp[DateTime.parse(m['dataConclusao']).millisecondsSinceEpoch]!['metasPerdidas'].add(m);
            } else {
              mapTemp[DateTime.parse(m['dataConclusao']).millisecondsSinceEpoch]!['metasConcluidas'].add(m);
            }
          }
        }
      }

      // Calcula saldos acumulados e recordes na linha do tempo bruta
      final sortedKeys = mapTemp.keys.toList()..sort();
      double saldoAtualLoop = bancaInicial;
      double maxSaldoSoFar = bancaInicial;
      double ultimoRecordeCelebrado = bancaInicial; // Controle para suavizar recordes
      int contadorRecordes = 0;

      for (int i = 0; i < sortedKeys.length; i++) {
        final key = sortedKeys[i];
        final dados = mapTemp[key]!;

        if (i == 0) {
          dados['saldoAcumulado'] = bancaInicial;
        } else {
          saldoAtualLoop += (dados['valorTransacao'] as double);
          dados['saldoAcumulado'] = saldoAtualLoop;

          // Nova Lógica de Recordes (Suavizada)
          // Só marca novo recorde se superar o topo histórico E for 1% maior que o último marco celebrado
          if (saldoAtualLoop > maxSaldoSoFar) {
            maxSaldoSoFar = saldoAtualLoop;

            // Evita spam de recordes: Exige crescimento de 1% sobre o último troféu para gerar um novo
            if (saldoAtualLoop >= ultimoRecordeCelebrado * 1.01) {
              dados['isNovoRecorde'] = true;
              contadorRecordes++;
              ultimoRecordeCelebrado = saldoAtualLoop;
            }
          }
        }
      }

      // Estatísticas Finais
      double drawdownAtual = 0.0;
      if (maxSaldoSoFar > 0) {
        drawdownAtual = ((saldoAtualLoop - maxSaldoSoFar) / maxSaldoSoFar) * 100;
      }

      setState(() {
        _saldoAtual = saldoAtualLoop;
        if (!apenasCalculoSaldo) {
          _timelineMap = mapTemp;
          _timelineKeys = sortedKeys;
          _maiorSaldoHistorico = maxSaldoSoFar;
          _qtdRecordes = contadorRecordes;
          _drawdown = drawdownAtual;

          // GERA OS PONTOS AGRUPADOS PARA O GRÁFICO
          _recalcularPontosGrafico();
        }
      });

      if (!apenasCalculoSaldo) await _atualizarArquivoIA();

    } catch (e) {
      debugPrint("Erro processamento gráfico: $e");
    }
  }

  // --- NOVA LÓGICA DE AGRUPAMENTO (MARKET STYLE) ---
  void _recalcularPontosGrafico() {
    if (_timelineKeys.isEmpty) {
      setState(() => _pontosGrafico = []);
      return;
    }

    // 1. Filtrar pelo período selecionado (Time Filter)
    DateTime agora = DateTime.now();
    DateTime dataCorte;
    switch (_filtroPeriodo) {
      case '7D': dataCorte = agora.subtract(const Duration(days: 7)); break;
      case '1M': dataCorte = agora.subtract(const Duration(days: 30)); break;
      case '3M': dataCorte = agora.subtract(const Duration(days: 90)); break;
      case '6M': dataCorte = agora.subtract(const Duration(days: 180)); break;
      case '1A': dataCorte = agora.subtract(const Duration(days: 365)); break;
      default:   dataCorte = DateTime(2000); break; // TUDO
    }

    final keysFiltradas = _timelineKeys.where((k) {
      final dt = _timelineMap[k]!['dataObj'] as DateTime;
      return dt.isAfter(dataCorte);
    }).toList();

    if (keysFiltradas.isEmpty && _timelineKeys.isNotEmpty) {
      // Se filtro excluiu tudo, pega ao menos os ultimos 2 para não quebrar
      keysFiltradas.addAll(_timelineKeys.sublist(max(0, _timelineKeys.length - 2)));
    }

    // 2. Agrupar dados com base em _agrupamentoVisualizacao
    Map<String, Map<String, dynamic>> grupos = {};

    // Formatter helpers
    String fmtKey(DateTime dt) {
      if (_agrupamentoVisualizacao == 'Dia') return DateFormat('yyyy-MM-dd').format(dt);
      if (_agrupamentoVisualizacao == 'Semana') return "${dt.year}-W${((int.parse(DateFormat("D").format(dt)) - dt.weekday + 10) / 7).floor()}";
      if (_agrupamentoVisualizacao == 'Mês') return DateFormat('yyyy-MM').format(dt);
      if (_agrupamentoVisualizacao == 'Ano') return DateFormat('yyyy').format(dt);
      return dt.millisecondsSinceEpoch.toString(); // Aposta (Transação)
    }

    String fmtLabel(DateTime dt) {
      if (_agrupamentoVisualizacao == 'Dia') return DateFormat('dd/MM').format(dt);
      if (_agrupamentoVisualizacao == 'Semana') return "Sem ${((int.parse(DateFormat("D").format(dt)) - dt.weekday + 10) / 7).floor()}";
      if (_agrupamentoVisualizacao == 'Mês') return DateFormat('MMM/yy').format(dt);
      if (_agrupamentoVisualizacao == 'Ano') return DateFormat('yyyy').format(dt);
      return DateFormat('dd/MM HH:mm').format(dt);
    }

    for (var k in keysFiltradas) {
      final dados = _timelineMap[k]!;
      final dt = dados['dataObj'] as DateTime;
      final key = fmtKey(dt);
      final saldo = (dados['saldoAcumulado'] as num).toDouble();

      if (!grupos.containsKey(key)) {
        grupos[key] = {
          'key': key,
          'label': fmtLabel(dt),
          'dataSort': dt, // Data do primeiro item do grupo para ordenação
          'saldoFechamento': saldo,
          'high': saldo,
          'low': saldo,
          'eventos': [],
          'metasConcluidas': [],
          'metasPerdidas': [],
          'temRecorde': false,
        };
      }

      final grupo = grupos[key]!;
      // Atualiza fechamento (sempre o último processado do grupo)
      grupo['saldoFechamento'] = saldo;

      // Atualiza High/Low
      if (saldo > (grupo['high'] as double)) grupo['high'] = saldo;
      if (saldo < (grupo['low'] as double)) grupo['low'] = saldo;

      // Agrega Eventos
      grupo['eventos'].addAll(dados['eventos']);
      grupo['metasConcluidas'].addAll(dados['metasConcluidas']);
      grupo['metasPerdidas'].addAll(dados['metasPerdidas']);
      if (dados['isNovoRecorde'] == true) grupo['temRecorde'] = true;
    }

    // 3. Converter para Lista Ordenada e Calcular Variações
    final listaOrdenada = grupos.values.toList()
      ..sort((a, b) => (a['dataSort'] as DateTime).compareTo(b['dataSort'] as DateTime));

    for (int i = 0; i < listaOrdenada.length; i++) {
      double anterior = i > 0 ? listaOrdenada[i-1]['saldoFechamento'] : listaOrdenada[i]['saldoFechamento'];
      double atual = listaOrdenada[i]['saldoFechamento'];
      listaOrdenada[i]['variacao'] = atual - anterior;
      listaOrdenada[i]['variacaoPct'] = anterior != 0 ? ((atual - anterior) / anterior) * 100 : 0.0;
    }

    setState(() {
      _pontosGrafico = listaOrdenada;
    });
  }

  // ... (Funções de Modal e Save Eventos mantidas, omitidas para brevidade) ...
  // Certifique-se de manter _salvarNovoEvento, _excluirEvento, _mostrarDetalhesEvento e _abrirModalNovoEvento no código final.

  Future<void> _salvarNovoEvento(DateTime data, String tipo, {String? id}) async {
    if (_tituloCtrl.text.trim().isEmpty) return;
    final eventoMap = {'id': id ?? DateTime.now().millisecondsSinceEpoch.toString(), 'data': data.toIso8601String(), 'titulo': _tituloCtrl.text.trim(), 'descricao': _descricaoCtrl.text.trim(), 'tipo': tipo};
    setState(() { if (id != null) { final index = _eventos.indexWhere((e) => e['id'] == id); if (index != -1) _eventos[index] = eventoMap; } else { _eventos.insert(0, eventoMap); } _eventos.sort((a, b) => DateTime.parse(b['data']).compareTo(DateTime.parse(a['data']))); });
    await _salvarEventosArquivo();
    await _processarDadosGrafico();
  }

  void _excluirEvento(String id) {
    showDialog(context: context, builder: (ctx) => AlertDialog(title: const Text("Excluir"), content: const Text("Apagar registro?"), actions: [TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Cancelar")), TextButton(onPressed: () async { setState(() => _eventos.removeWhere((e) => e['id'] == id)); await _salvarEventosArquivo(); await _processarDadosGrafico(); Navigator.pop(ctx); }, child: const Text("Excluir", style: TextStyle(color: Colors.red)))]));
  }

  void _mostrarDetalhesEvento(Map<String, dynamic> evento) {
    final tipo = evento['tipo'] ?? 'reflexao';
    final titulo = evento['titulo'] ?? '';
    final descricao = evento['descricao'] ?? '';
    DateTime data = DateTime.now();
    if (evento['data'] != null) { try { data = DateTime.parse(evento['data']); } catch (_) {} }
    showDialog(context: context, builder: (ctx) => AlertDialog(title: Row(children: [Icon(_getIconeTipo(tipo), color: _getCorTipo(tipo)), const SizedBox(width: 10), Expanded(child: Text(titulo, style: const TextStyle(fontSize: 18)))]), content: SingleChildScrollView(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(DateFormat("dd/MM/yyyy • HH:mm").format(data), style: TextStyle(color: Colors.grey.shade600, fontSize: 13)), const SizedBox(height: 16), Text(descricao, style: const TextStyle(fontSize: 16))])), actions: [TextButton(onPressed: () { Navigator.pop(ctx); _abrirModalNovoEvento(eventoParaEditar: evento); }, child: const Text("Editar")), TextButton(onPressed: () { Navigator.pop(ctx); _excluirEvento(evento['id']); }, child: const Text("Excluir", style: TextStyle(color: Colors.red))), TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Fechar"))]));
  }

  void _abrirModalNovoEvento({Map<String, dynamic>? eventoParaEditar}) {
    if (eventoParaEditar != null) { _tituloCtrl.text = eventoParaEditar['titulo'] ?? ''; _descricaoCtrl.text = eventoParaEditar['descricao'] ?? ''; } else { _tituloCtrl.clear(); _descricaoCtrl.clear(); }
    DateTime dataSelecionadaLocal = eventoParaEditar != null ? (DateTime.tryParse(eventoParaEditar['data']) ?? DateTime.now()) : DateTime.now();
    String tipoSelecionadoLocal = eventoParaEditar != null ? (eventoParaEditar['tipo'] ?? 'reflexao') : 'reflexao';
    showModalBottomSheet(context: context, isScrollControlled: true, shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))), builder: (ctx) {
      return StatefulBuilder(builder: (context, setModalState) {
        String hintTextDesc = "Descreva os detalhes...";
        if (tipoSelecionadoLocal == 'importante') hintTextDesc = "O que impactou sua decisão?";
        else if (tipoSelecionadoLocal == 'reflexao') hintTextDesc = "O que você pensou antes?";
        return Padding(padding: EdgeInsets.only(top: 24, left: 24, right: 24, bottom: MediaQuery.of(context).viewInsets.bottom + 24), child: Column(mainAxisSize: MainAxisSize.min, children: [
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text(eventoParaEditar != null ? "Editar Registro" : "Novo Registro", style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)), IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(context))]),
          const SizedBox(height: 16), TextField(controller: _tituloCtrl, decoration: const InputDecoration(labelText: "Título curto", border: OutlineInputBorder())),
          const SizedBox(height: 12), TextField(controller: _descricaoCtrl, maxLines: 3, decoration: InputDecoration(labelText: "O que aconteceu?", hintText: hintTextDesc, border: const OutlineInputBorder())),
          const SizedBox(height: 16), Row(children: [_buildChoiceChip("Reflexão", Icons.lightbulb_outline, Colors.teal, tipoSelecionadoLocal == 'reflexao', () => setModalState(() => tipoSelecionadoLocal = 'reflexao')), const SizedBox(width: 12), _buildChoiceChip("Importante", Icons.flag_rounded, Colors.deepPurple, tipoSelecionadoLocal == 'importante', () => setModalState(() => tipoSelecionadoLocal = 'importante'))]),
          const SizedBox(height: 16), InkWell(onTap: () async { final date = await showDatePicker(context: context, initialDate: dataSelecionadaLocal, firstDate: DateTime(2020), lastDate: DateTime.now().add(const Duration(days: 1))); if (date != null) { final time = await showTimePicker(context: context, initialTime: TimeOfDay.fromDateTime(dataSelecionadaLocal)); if (time != null) setModalState(() => dataSelecionadaLocal = DateTime(date.year, date.month, date.day, time.hour, time.minute)); } }, child: Container(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12), decoration: BoxDecoration(border: Border.all(color: Colors.grey.shade300), borderRadius: BorderRadius.circular(4)), child: Row(children: [const Icon(Icons.calendar_today, size: 18), const SizedBox(width: 8), Text(DateFormat("dd/MM/yyyy HH:mm").format(dataSelecionadaLocal))]))),
          const SizedBox(height: 24), ElevatedButton(onPressed: () { _salvarNovoEvento(dataSelecionadaLocal, tipoSelecionadoLocal, id: eventoParaEditar?['id']); Navigator.pop(context); }, style: ElevatedButton.styleFrom(backgroundColor: Colors.indigo, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 16)), child: const Text("SALVAR REGISTRO")),
        ]));
      });
    });
  }

  Widget _buildChoiceChip(String label, IconData icon, Color color, bool selected, VoidCallback onTap) {
    return FilterChip(label: Row(children: [Icon(icon, size: 16, color: selected ? Colors.white : color), const SizedBox(width: 6), Text(label)]), selected: selected, onSelected: (_) => onTap(), selectedColor: color, checkmarkColor: Colors.white, labelStyle: TextStyle(color: selected ? Colors.white : Colors.black87), backgroundColor: Colors.white);
  }

  Color _getCorTipo(String tipo) => tipo == 'importante' ? Colors.deepPurple : Colors.teal;
  IconData _getIconeTipo(String tipo) => tipo == 'importante' ? Icons.flag_rounded : Icons.lightbulb_outline;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
            SliverAppBar(
              title: const Text('Diário de Bordo'),
              pinned: true, floating: true, elevation: 0,
              backgroundColor: Colors.indigo, foregroundColor: Colors.white,
              bottom: TabBar(
                controller: _tabController, indicatorColor: Colors.white, indicatorWeight: 3, labelStyle: const TextStyle(fontWeight: FontWeight.bold),
                tabs: const [Tab(text: "DASHBOARD"), Tab(text: "HISTÓRICO"), Tab(text: "METAS")],
              ),
            ),
          ];
        },
        body: _carregando ? const Center(child: CircularProgressIndicator()) : TabBarView(
          controller: _tabController,
          children: [_buildAbaDashboard(), _buildAbaListaEventos(), _buildAbaMetas()],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          if (_tabController.index == 2) { _adicionarEditarMeta(); } else { _abrirModalNovoEvento(); }
        },
        backgroundColor: Colors.indigo, foregroundColor: Colors.white,
        icon: Icon(_tabController.index == 2 ? Icons.flag : Icons.add_comment_outlined),
        label: Text(_tabController.index == 2 ? "Nova Meta" : "Registrar"),
      ),
    );
  }

  // ABA 1: DASHBOARD
  Widget _buildAbaDashboard() {
    if (_pontosGrafico.isEmpty) return const Center(child: Text("Sem dados."));

    // Preparação dos dados do gráfico com base nos pontos agrupados
    List<FlSpot> spots = [];
    double minY = double.infinity, maxY = double.negativeInfinity;
    List<VerticalLine> linhasVerticais = [];

    for (int i = 0; i < _pontosGrafico.length; i++) {
      final ponto = _pontosGrafico[i];
      final valor = (ponto['saldoFechamento'] as num).toDouble();
      spots.add(FlSpot(i.toDouble(), valor));

      if (valor < minY) minY = valor;
      if (valor > maxY) maxY = valor;

      // Adiciona Marcadores se habilitados
      if (_exibirRecordes && ponto['temRecorde'] == true) {
        linhasVerticais.add(VerticalLine(x: i.toDouble(), color: Colors.amber.shade700, strokeWidth: 1.5, dashArray: [2, 2], label: VerticalLineLabel(show: true, alignment: Alignment.topCenter, padding: const EdgeInsets.only(top: 5), style: TextStyle(color: Colors.amber.shade800, fontSize: 10, fontWeight: FontWeight.bold), labelResolver: (line) => "🏆")));
      }

      if (_exibirMetas) {
        if ((ponto['metasConcluidas'] as List).isNotEmpty) {
          linhasVerticais.add(VerticalLine(x: i.toDouble(), color: Colors.green, strokeWidth: 2, label: VerticalLineLabel(show: true, alignment: Alignment.topCenter, padding: const EdgeInsets.only(top: 40), style: const TextStyle(color: Colors.green, fontSize: 14), labelResolver: (line) => "🏁")));
        }
        if ((ponto['metasPerdidas'] as List).isNotEmpty) {
          linhasVerticais.add(VerticalLine(x: i.toDouble(), color: Colors.red, strokeWidth: 2, dashArray: [4, 4], label: VerticalLineLabel(show: true, alignment: Alignment.bottomCenter, padding: const EdgeInsets.only(bottom: 20), style: const TextStyle(color: Colors.red, fontSize: 14), labelResolver: (line) => "☠️")));
        }
      }

      if (_exibirEventos && (ponto['eventos'] as List).isNotEmpty) {
        linhasVerticais.add(VerticalLine(x: i.toDouble(), color: Colors.teal.withOpacity(0.6), strokeWidth: 2, label: VerticalLineLabel(show: true, alignment: Alignment.topCenter, padding: const EdgeInsets.only(top: 25), style: TextStyle(color: Colors.teal, fontSize: 14), labelResolver: (line) => "📌")));
      }
    }

    // Ajuste de escala Y
    final intervaloY = (maxY - minY) * 0.1;
    minY -= intervaloY; maxY += intervaloY;
    if (_maiorSaldoHistorico > maxY) maxY = _maiorSaldoHistorico * 1.05;
    if (minY == maxY) { minY -= 10; maxY += 10; }

    double chartWidth = max(MediaQuery.of(context).size.width, _pontosGrafico.length * 40.0);
    final corGrafico = _drawdown < -10 ? Colors.orange.shade800 : Colors.blue;

    return RefreshIndicator(
      onRefresh: () => _carregarDadosCompletos(showLoading: false),
      child: SingleChildScrollView(
        child: Column(
          children: [
            Container(padding: const EdgeInsets.all(16), color: Colors.white, child: Column(children: [Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [_buildStatCard("Atual", "R\$ ${_saldoAtual.toStringAsFixed(2)}", Colors.black87), _drawdown < -0.5 ? _buildStatCard("Queda", "${_drawdown.toStringAsFixed(1)}%", Colors.red) : _buildStatCard("Recordes", "$_qtdRecordes", Colors.amber.shade800), _buildStatCard("Máxima", "R\$ ${_maiorSaldoHistorico.toStringAsFixed(2)}", Colors.green.shade700)])])),
            const SizedBox(height: 8),
            _buildResumoPeriodo(),

            // CONTROLES DE FILTRO E AGRUPAMENTO
            Container(
              color: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Column(
                children: [
                  // Linha 1: Período
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: ['7D', '1M', '3M', '6M', '1A', 'TUDO'].map((filtro) {
                        final isSelected = _filtroPeriodo == filtro;
                        return Padding(
                          padding: const EdgeInsets.only(right: 8.0),
                          child: ChoiceChip(
                            label: Text(filtro),
                            selected: isSelected,
                            onSelected: (s) { if(s) setState(() { _filtroPeriodo = filtro; _recalcularPontosGrafico(); }); },
                            selectedColor: Colors.indigo.shade100,
                            labelStyle: TextStyle(color: isSelected ? Colors.indigo : Colors.black87, fontSize: 12),
                            backgroundColor: Colors.white,
                            visualDensity: VisualDensity.compact,
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                  const SizedBox(height: 8),
                  // Linha 2: Agrupamento e Toggles
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        const Text("Agrupar: ", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                        DropdownButton<String>(
                          value: _agrupamentoVisualizacao,
                          isDense: true,
                          underline: Container(),
                          style: const TextStyle(color: Colors.indigo, fontSize: 13, fontWeight: FontWeight.bold),
                          onChanged: (v) {
                            if (v != null) setState(() { _agrupamentoVisualizacao = v; _recalcularPontosGrafico(); });
                          },
                          items: ['Aposta', 'Dia', 'Semana', 'Mês', 'Ano']
                              .map((v) => DropdownMenuItem(value: v, child: Text(v))).toList(),
                        ),
                        const SizedBox(width: 16),
                        _buildToggleIcon(Icons.emoji_events, Colors.amber, _exibirRecordes, () => setState(() => _exibirRecordes = !_exibirRecordes)),
                        _buildToggleIcon(Icons.flag, Colors.green, _exibirMetas, () => setState(() => _exibirMetas = !_exibirMetas)),
                        _buildToggleIcon(Icons.push_pin, Colors.teal, _exibirEventos, () => setState(() => _exibirEventos = !_exibirEventos)),
                      ],
                    ),
                  )
                ],
              ),
            ),

            Container(
                color: Colors.white,
                height: 350,
                child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Container(
                        width: chartWidth,
                        padding: const EdgeInsets.only(top: 30, bottom: 10, right: 20, left: 10),
                        child: LineChart(
                            LineChartData(
                                minY: minY,
                                maxY: maxY,
                                gridData: FlGridData(show: true, drawVerticalLine: true, verticalInterval: 1, getDrawingHorizontalLine: (v) => FlLine(color: Colors.grey.shade100), getDrawingVerticalLine: (v) => FlLine(color: Colors.grey.shade50)),
                                titlesData: FlTitlesData(show: true, rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)), topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)), leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 40, getTitlesWidget: (v, m) => Text(v.toInt().toString(), style: const TextStyle(fontSize: 10, color: Colors.grey)))), bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 30, interval: 1, getTitlesWidget: (v, m) {
                                  int idx = v.toInt();
                                  if (idx >= 0 && idx < _pontosGrafico.length) {
                                    if (_pontosGrafico.length > 20 && idx % 2 != 0) return const SizedBox.shrink();
                                    return Padding(padding: const EdgeInsets.only(top: 8.0), child: Text(_pontosGrafico[idx]['label'], style: const TextStyle(fontSize: 10, color: Colors.grey)));
                                  }
                                  return const SizedBox.shrink();
                                }))),
                                borderData: FlBorderData(show: false),

                                lineTouchData: LineTouchData(
                                    touchSpotThreshold: 20,
                                    touchCallback: (FlTouchEvent event, LineTouchResponse? touchResponse) {
                                      if (event is FlTapUpEvent && touchResponse != null && touchResponse.lineBarSpots != null && touchResponse.lineBarSpots!.isNotEmpty) {
                                        final index = touchResponse.lineBarSpots!.first.x.toInt();
                                        _onChartTap(index);
                                      }
                                    },
                                    handleBuiltInTouches: true,
                                    getTouchedSpotIndicator: (LineChartBarData barData, List<int> spotIndexes) {
                                      return spotIndexes.map((spotIndex) {
                                        return TouchedSpotIndicatorData(
                                          FlLine(color: Colors.indigo, strokeWidth: 2),
                                          FlDotData(getDotPainter: (spot, percent, barData, index) => FlDotCirclePainter(radius: 6, color: Colors.white, strokeWidth: 3, strokeColor: Colors.indigo)),
                                        );
                                      }).toList();
                                    },
                                    touchTooltipData: LineTouchTooltipData(
                                        getTooltipColor: (spot) => Colors.blueGrey,
                                        getTooltipItems: (List<LineBarSpot> touchedBarSpots) {
                                          return touchedBarSpots.map((barSpot) {
                                            final flSpot = barSpot;
                                            return LineTooltipItem('R\$ ${flSpot.y.toStringAsFixed(2)}', const TextStyle(color: Colors.white, fontWeight: FontWeight.bold));
                                          }).toList();
                                        }
                                    )
                                ),

                                extraLinesData: ExtraLinesData(verticalLines: linhasVerticais, horizontalLines: [HorizontalLine(y: _maiorSaldoHistorico, color: Colors.green.withOpacity(0.3), strokeWidth: 1, dashArray: [5, 5], label: HorizontalLineLabel(show: true, alignment: Alignment.topRight, style: TextStyle(color: Colors.green.withOpacity(0.8), fontSize: 10), labelResolver: (line) => "Máx: ${_maiorSaldoHistorico.toStringAsFixed(0)}"))]),
                                lineBarsData: [LineChartBarData(spots: spots, isCurved: true, curveSmoothness: 0.2, color: corGrafico, barWidth: 2, isStrokeCapRound: true, dotData: const FlDotData(show: true), belowBarData: BarAreaData(show: true, gradient: LinearGradient(colors: [corGrafico.withOpacity(0.2), corGrafico.withOpacity(0.0)], begin: Alignment.topCenter, end: Alignment.bottomCenter)))]
                            )
                        )
                    )
                )
            ),

            _buildLegendaGrafico(),
            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }

  Widget _buildToggleIcon(IconData icon, Color color, bool isActive, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: isActive ? color.withOpacity(0.1) : Colors.grey.shade100,
          shape: BoxShape.circle,
          border: Border.all(color: isActive ? color : Colors.grey.shade300),
        ),
        child: Icon(icon, size: 16, color: isActive ? color : Colors.grey),
      ),
    );
  }

  void _onChartTap(int index) {
    if (index < 0 || index >= _pontosGrafico.length) return;

    final ponto = _pontosGrafico[index];
    final eventos = (ponto['eventos'] as List?) ?? [];
    final metasConcluidas = (ponto['metasConcluidas'] as List?) ?? [];
    final metasPerdidas = (ponto['metasPerdidas'] as List?) ?? [];
    final bool isRecorde = ponto['temRecorde'] == true;

    final saldo = (ponto['saldoFechamento'] as num).toDouble();
    final variacao = (ponto['variacao'] as num).toDouble();
    final variacaoPct = (ponto['variacaoPct'] as num).toDouble();
    final high = (ponto['high'] as num).toDouble();
    final low = (ponto['low'] as num).toDouble();

    Color corVar = variacao >= 0 ? Colors.green : Colors.red;
    String txtVar = variacao >= 0 ? "+R\$ ${variacao.toStringAsFixed(2)}" : "R\$ ${variacao.toStringAsFixed(2)}";
    String txtPct = variacao >= 0 ? "+${variacaoPct.toStringAsFixed(1)}%" : "${variacaoPct.toStringAsFixed(1)}%";

    showModalBottomSheet(
        context: context,
        backgroundColor: Colors.transparent,
        isScrollControlled: true,
        builder: (ctx) {
          return DraggableScrollableSheet(
              initialChildSize: 0.5,
              minChildSize: 0.3,
              maxChildSize: 0.9,
              builder: (_, scrollController) {
                return Container(
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                  ),
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                  child: Column(
                    children: [
                      Container(width: 40, height: 4, margin: const EdgeInsets.only(bottom: 16), decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(2))),

                      // CABEÇALHO ESTILO MERCADO
                      Text(ponto['label'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text("Fechamento: R\$ ${saldo.toStringAsFixed(2)}", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Column(children: [const Text("Variação", style: TextStyle(fontSize: 10, color: Colors.grey)), Text("$txtVar ($txtPct)", style: TextStyle(fontWeight: FontWeight.bold, color: corVar, fontSize: 13))]),
                          Column(children: [const Text("High (Máx)", style: TextStyle(fontSize: 10, color: Colors.grey)), Text("R\$ ${high.toStringAsFixed(2)}", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13))]),
                          Column(children: [const Text("Low (Mín)", style: TextStyle(fontSize: 10, color: Colors.grey)), Text("R\$ ${low.toStringAsFixed(2)}", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13))]),
                        ],
                      ),
                      const Divider(height: 30),

                      Expanded(
                        child: ListView(
                          controller: scrollController,
                          children: [
                            if (isRecorde)
                              Card(color: Colors.amber.shade50, child: ListTile(leading: const CircleAvatar(backgroundColor: Colors.amber, child: Icon(Icons.emoji_events, color: Colors.white)), title: const Text("Novo Recorde!", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.amber)), subtitle: Text("Saldo Histórico Atingido"))),

                            if (metasConcluidas.isNotEmpty) ...[
                              const Padding(padding: EdgeInsets.symmetric(vertical: 8), child: Text("Metas Concluídas", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.green))),
                              ...metasConcluidas.map((m) => _buildMetaCardAdaptado(m, true, false)).toList(),
                            ],

                            if (metasPerdidas.isNotEmpty) ...[
                              const Padding(padding: EdgeInsets.symmetric(vertical: 8), child: Text("Metas Perdidas", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.red))),
                              ...metasPerdidas.map((m) => _buildMetaCardAdaptado(m, false, true)).toList(),
                            ],

                            if (eventos.isNotEmpty) ...[
                              const Padding(padding: EdgeInsets.symmetric(vertical: 8), child: Text("Diário de Bordo", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.indigo))),
                              ...eventos.map((e) => _buildTimelineItem(e, false)).toList(),
                            ],

                            if (!isRecorde && metasConcluidas.isEmpty && metasPerdidas.isEmpty && eventos.isEmpty)
                              const Padding(padding: EdgeInsets.all(20), child: Center(child: Text("Sem eventos registrados neste período.", style: TextStyle(color: Colors.grey)))),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              }
          );
        }
    );
  }

  Widget _buildMetaCardAdaptado(Map<String, dynamic> meta, bool concluida, bool perdida) {
    final tipo = meta['tipo'] ?? 'financeira';
    if (tipo == 'checklist') return _buildMetaChecklistCard(meta, concluida, perdida);
    if (tipo == 'tarefa') return _buildMetaTarefaCard(meta, concluida, perdida);
    return _buildMetaFinanceiraCard(meta, concluida, perdida);
  }

  // 1️⃣ e 2️⃣ MELHORIA: Resumo do Período com Estado Textual
  Widget _buildResumoPeriodo() {
    if (_pontosGrafico.isEmpty) return const SizedBox.shrink();

    // Dados do período visualizado
    final startBal = (_pontosGrafico.first['saldoFechamento'] as num).toDouble();
    final endBal = (_pontosGrafico.last['saldoFechamento'] as num).toDouble();
    final variacao = startBal > 0 ? ((endBal - startBal) / startBal) * 100 : 0.0;

    int eventosCount = 0;
    int metasConcluidas = 0;
    int metasPerdidas = 0;

    for (var p in _pontosGrafico) {
      eventosCount += (p['eventos'] as List).length;
      metasConcluidas += (p['metasConcluidas'] as List).length;
      metasPerdidas += (p['metasPerdidas'] as List).length;
    }

    final status = _getPeriodoStatus(_drawdown);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("Resumo do Período", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(color: status['color'].withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
                  child: Text(status['text'], style: TextStyle(color: status['color'], fontWeight: FontWeight.bold, fontSize: 12)),
                )
              ],
            ),
            const Divider(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Variação: ${variacao > 0 ? '+' : ''}${variacao.toStringAsFixed(1)}%", style: TextStyle(color: variacao >= 0 ? Colors.green : Colors.red, fontWeight: FontWeight.bold)),
                Text("Eventos: $eventosCount", style: const TextStyle(color: Colors.grey)),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.flag, size: 14, color: Colors.grey),
                const SizedBox(width: 4),
                Text("Metas: $metasConcluidas concluídas • $metasPerdidas perdidas", style: const TextStyle(fontSize: 12, color: Colors.grey)),
              ],
            )
          ],
        ),
      ),
    );
  }

  Map<String, dynamic> _getPeriodoStatus(double dd) {
    if (dd < -30) return {'text': '🔴 Crítico', 'color': Colors.red};
    if (dd < -10) return {'text': '🟠 Alerta', 'color': Colors.orange};
    return {'text': '🟢 Saudável', 'color': Colors.green};
  }

  // 3️⃣ MELHORIA: Legenda Viva
  Widget _buildLegendaGrafico() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Wrap(
        spacing: 16,
        runSpacing: 8,
        alignment: WrapAlignment.center,
        children: [
          _legendItem("🏆 Novo Recorde", Colors.amber.shade800),
          _legendItem("📌 Evento", Colors.teal),
          _legendItem("🏁 Meta Batida", Colors.green),
          _legendItem("☠️ Meta Perdida", Colors.red),
        ],
      ),
    );
  }

  Widget _legendItem(String text, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(width: 10, height: 10, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 4),
        Text(text, style: const TextStyle(fontSize: 12, color: Colors.grey)),
      ],
    );
  }

  Widget _buildStatCard(String label, String valor, Color cor) {
    return Column(children: [Text(label, style: TextStyle(color: Colors.grey.shade600, fontSize: 11)), const SizedBox(height: 4), Text(valor, style: TextStyle(color: cor, fontWeight: FontWeight.bold, fontSize: 16))]);
  }

  // ABA 2: LISTA DE EVENTOS
  Widget _buildAbaListaEventos() {
    final eventosFiltrados = _eventos.where((e) => (e['titulo'] ?? '').toLowerCase().contains(_filtroBusca.toLowerCase()) || (e['descricao'] ?? '').toLowerCase().contains(_filtroBusca.toLowerCase())).toList();
    return Column(children: [
      Container(padding: const EdgeInsets.all(12), color: Colors.white, child: TextField(controller: _buscaCtrl, onChanged: (v) => setState(() => _filtroBusca = v), decoration: const InputDecoration(hintText: "Buscar...", prefixIcon: Icon(Icons.search), border: OutlineInputBorder(), isDense: true))),
      Expanded(child: eventosFiltrados.isEmpty ? const Center(child: Text("Sem registros.")) : ListView.builder(padding: const EdgeInsets.all(16), itemCount: eventosFiltrados.length, itemBuilder: (ctx, i) => _buildTimelineItem(eventosFiltrados[i], i == eventosFiltrados.length - 1))),
    ]);
  }

  // 6️⃣ MELHORIA: Destaque visual para eventos importantes
  Widget _buildTimelineItem(Map<String, dynamic> evento, bool isLast) {
    DateTime data = DateTime.now(); try { data = DateTime.parse(evento['data']); } catch(_){}
    final tipo = evento['tipo'] ?? 'reflexao';
    final isImportante = tipo == 'importante';

    return IntrinsicHeight(child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Column(children: [Container(width: 12, height: 12, decoration: BoxDecoration(color: _getCorTipo(tipo), shape: BoxShape.circle)), if(!isLast) Expanded(child: Container(width: 2, color: Colors.grey.shade200))]),
      const SizedBox(width: 12),
      Expanded(child: Padding(padding: const EdgeInsets.only(bottom: 24.0), child: InkWell(onTap: () => _mostrarDetalhesEvento(evento), child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
              color: isImportante ? Colors.deepPurple.shade50 : Colors.white, // Fundo diferente
              borderRadius: BorderRadius.circular(8),
              border: isImportante ? Border.all(color: Colors.deepPurple.withOpacity(0.2)) : null, // Borda sutil
              boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4)]
          ),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              Text(DateFormat("dd MMM").format(data), style: TextStyle(fontSize: 10, color: Colors.grey)),
              const Spacer(),
              if(isImportante) const Icon(Icons.star, size: 14, color: Colors.deepPurple) // Ícone diferente
              else if(tipo=='reflexao') const Icon(Icons.lightbulb_outline, size: 14, color: Colors.teal)
            ]),
            const SizedBox(height: 4),
            Text(evento['titulo'], style: TextStyle(fontWeight: FontWeight.bold, color: isImportante ? Colors.deepPurple.shade900 : Colors.black)),
            Text(evento['descricao'], maxLines: 2, overflow: TextOverflow.ellipsis, style: TextStyle(color: isImportante ? Colors.deepPurple.shade700 : Colors.grey))
          ])))))
    ]));
  }

  // ABA 3: METAS
  Widget _buildAbaMetas() {
    if (_listaMetas.isEmpty) return const Center(child: Text("Defina sua primeira meta!"));

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
      itemCount: _listaMetas.length,
      itemBuilder: (context, index) {
        final meta = _listaMetas[index];
        final tipo = meta['tipo'] ?? 'financeira';
        final concluida = meta['concluida'] == true;
        final perdida = meta['perdida'] == true;

        if (tipo == 'checklist') return _buildMetaChecklistCard(meta, concluida, perdida);
        if (tipo == 'tarefa') return _buildMetaTarefaCard(meta, concluida, perdida);
        return _buildMetaFinanceiraCard(meta, concluida, perdida);
      },
    );
  }

  Widget _buildMetaFinanceiraCard(Map<String, dynamic> meta, bool concluida, bool perdida) {
    final atual = (meta['atual'] as num).toDouble();
    final alvo = (meta['alvo'] as num).toDouble();
    final progresso = (alvo > 0 ? atual / alvo : 0.0).clamp(0.0, 1.0);
    final subtipo = meta['subtipo'] ?? 'total';
    final tipo = meta['tipo'];

    Color corMeta = Colors.blue;
    IconData iconeMeta = Icons.attach_money;
    if (tipo == 'material') { corMeta = Colors.purple; iconeMeta = Icons.shopping_bag; }
    if (tipo == 'habito') { corMeta = Colors.orange; iconeMeta = Icons.self_improvement; }

    String statusText = "Em andamento";
    if (concluida) { corMeta = Colors.green; iconeMeta = Icons.emoji_events; statusText = "CONCLUÍDA! 🎉"; }
    else if (perdida) { corMeta = Colors.red; iconeMeta = Icons.sentiment_very_dissatisfied; statusText = "PERDIDA ❌"; }
    else { statusText = "Faltam ${tipo == 'habito' ? '' : 'R\$ '}${(alvo - atual).toStringAsFixed(0)}"; }

    String tipoDesc = "";
    if (tipo == 'financeira') {
      tipoDesc = subtipo == 'ganho' ? "Ganho Acumulado" : "Saldo Total";
    } else if (tipo == 'material') {
      tipoDesc = "Recompensa";
    } else {
      tipoDesc = "Hábito/Contador";
    }

    return _buildBaseCard(meta, corMeta, iconeMeta, statusText, tipoDesc,
        Column(
          children: [
            LinearProgressIndicator(value: progresso, backgroundColor: Colors.grey.shade200, color: corMeta, minHeight: 10, borderRadius: BorderRadius.circular(5)),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("${(progresso * 100).toStringAsFixed(0)}%", style: TextStyle(fontWeight: FontWeight.bold, color: corMeta)),
                Text("${atual.toStringAsFixed(0)} / ${alvo.toStringAsFixed(0)}", style: const TextStyle(fontSize: 12, color: Colors.grey)),
              ],
            ),
            if (!concluida && !perdida && tipo != 'financeira') ...[
              const Divider(),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  IconButton(icon: const Icon(Icons.remove_circle_outline, color: Colors.red), onPressed: () => _showUpdateDialog(meta, -1)),
                  TextButton(onPressed: () => _showUpdateDialog(meta, 0), child: const Text("Atualizar")),
                  IconButton(icon: const Icon(Icons.add_circle_outline, color: Colors.green), onPressed: () => _showUpdateDialog(meta, 1)),
                ],
              )
            ]
          ],
        )
    );
  }

  Widget _buildMetaChecklistCard(Map<String, dynamic> meta, bool concluida, bool perdida) {
    final rawItens = meta['checklistItens'] as List?;
    final itens = rawItens != null ? rawItens.map((e) => Map<String, dynamic>.from(e)).toList() : <Map<String, dynamic>>[];

    final feitos = itens.where((i) => i['feito'] == true).length;
    final total = itens.length;
    final progresso = total > 0 ? feitos / total : 0.0;

    String statusText = concluida ? "CONCLUÍDA! 🎉" : "$feitos de $total passos";
    Color corMeta = concluida ? Colors.green : Colors.indigo;

    return _buildBaseCard(meta, corMeta, Icons.list_alt, statusText, "Checklist de Rotina",
        Column(
          children: [
            LinearProgressIndicator(value: progresso, backgroundColor: Colors.grey.shade200, color: corMeta, minHeight: 6, borderRadius: BorderRadius.circular(5)),
            const SizedBox(height: 12),
            ...itens.take(5).toList().asMap().entries.map((entry) {
              final idx = entry.key;
              final item = entry.value;
              return CheckboxListTile(
                value: item['feito'],
                title: Text(item['texto'], style: TextStyle(fontSize: 14, decoration: item['feito'] ? TextDecoration.lineThrough : null, color: item['feito'] ? Colors.grey : Colors.black87)),
                dense: true,
                contentPadding: EdgeInsets.zero,
                activeColor: Colors.green,
                onChanged: (val) => _toggleChecklistItem(meta, idx, val!),
              );
            }),
            if (itens.length > 5)
              TextButton(onPressed: () => _adicionarEditarMeta(metaExistente: meta), child: const Text("Ver todos os itens"))
          ],
        )
    );
  }

  Widget _buildMetaTarefaCard(Map<String, dynamic> meta, bool concluida, bool perdida) {
    return _buildBaseCard(meta, concluida ? Colors.green : Colors.deepOrange, Icons.check_circle_outline,
        concluida ? "Finalizada" : "Pendente", "Tarefa Única",
        concluida
            ? const SizedBox(height: 8) // Já concluída
            : Padding(
          padding: const EdgeInsets.only(top: 8.0),
          child: SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              icon: const Icon(Icons.check),
              label: const Text("Marcar como Concluída"),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.green, foregroundColor: Colors.white),
              onPressed: () => _atualizarProgressoMeta(meta, 1),
            ),
          ),
        )
    );
  }

  Widget _buildBaseCard(Map<String, dynamic> meta, Color cor, IconData icone, String status, String tipoDesc, Widget content) {
    final validadeStr = meta['validade'];
    String infoValidade = "";
    if (validadeStr != null) {
      final valDt = DateTime.parse(validadeStr);
      final diff = valDt.difference(DateTime.now()).inDays;
      infoValidade = diff < 0 ? "Expirou" : "$diff dias restantes";
    }

    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 12),
      color: meta['perdida'] == true ? Colors.red.shade50 : (meta['concluida'] == true ? Colors.green.shade50 : Colors.white),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            Row(children: [
              CircleAvatar(backgroundColor: cor.withOpacity(0.1), child: Icon(icone, color: cor)),
              const SizedBox(width: 12),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(meta['titulo'], style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, decoration: (meta['concluida']==true || meta['perdida']==true) ? TextDecoration.lineThrough : null)),
                Row(children: [Text(status, style: TextStyle(color: cor, fontSize: 12, fontWeight: FontWeight.bold)), const SizedBox(width: 8), Text("($tipoDesc)", style: const TextStyle(fontSize: 10, color: Colors.grey))]),
                if(infoValidade.isNotEmpty) Text("Validade: $infoValidade", style: const TextStyle(color: Colors.grey, fontSize: 11)),
              ])),
              PopupMenuButton<String>(onSelected: (v) { if (v == 'edit') _adicionarEditarMeta(metaExistente: meta); if (v == 'delete') _excluirMeta(meta['id']); }, itemBuilder: (c) => [const PopupMenuItem(value: 'edit', child: Text("Editar")), const PopupMenuItem(value: 'delete', child: Text("Excluir", style: TextStyle(color: Colors.red)))])
            ]),
            const SizedBox(height: 12),
            content
          ],
        ),
      ),
    );
  }

  void _showUpdateDialog(Map<String, dynamic> meta, double quickVal) {
    final ctrl = TextEditingController();
    showDialog(context: context, builder: (ctx) => AlertDialog(title: Text("Atualizar: ${meta['titulo']}"), content: TextField(controller: ctrl, keyboardType: TextInputType.number, autofocus: true, decoration: const InputDecoration(hintText: "Valor a somar (ex: 50)")), actions: [TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Cancelar")), ElevatedButton(onPressed: () { final val = double.tryParse(ctrl.text.replaceAll(',', '.')); if (val != null) { _atualizarProgressoMeta(meta, val); Navigator.pop(ctx); } }, child: const Text("Confirmar"))]));
  }
}
// ===================================================================
// FIM DO BLOCO DA TELA DE EVENTOS ( TELA 6)
// ===================================================================




// ===================================================================
// INÍCIO DO BLOCO DA TELA DE SIMULAÇÃO ( TELA 7 )
// ===================================================================

class TelaCrypto extends StatefulWidget {
  const TelaCrypto({super.key});

  @override
  State<TelaCrypto> createState() => _TelaCryptoState();
}

class _TelaCryptoState extends State<TelaCrypto> with SingleTickerProviderStateMixin {
  // Dados do Simulador
  List<Map<String, dynamic>> _apostasSimuladas = [];
  double _bancaInicialSimulada = 1000.0;

  // Listas de Métodos para Autocomplete e Filtro
  List<String> _metodosDisponiveis = [];
  String? _filtroMetodoSelecionado;

  // Estatísticas Avançadas (Base)
  double _saldoAtual = 1000.0;
  double _roiSimulado = 0.0;
  double _taxaAcerto = 0.0;
  double _oddMediaGreen = 0.0;
  double _avgStake = 0.0;
  int _greens = 0;
  int _reds = 0;
  int _pendentes = 0;

  // Monte Carlo & Stress Test
  String _gradeEstrategia = "-";
  Color _corGrade = Colors.grey;
  List<FlSpot> _equityCurve = [];

  // NOVAS VARIÁVEIS PARA O GRÁFICO MELHORADO
  List<List<double>> _monteCarloDisplayPaths = []; // Amostra aleatória para fundo
  List<double> _mcMedianPath = []; // Caminho mediano (Azul)
  List<double> _mcP90Path = []; // Caminho otimista (Verde)
  List<double> _mcP10Path = []; // Caminho pessimista (Vermelho)

  String _probabilidadeQuebra = "...";

  // Variáveis de Stress Test (Simulação "E Se...")
  double _stressWinRateAdj = 0.0;
  double _stressOddAdj = 0.0;
  String _robustezScore = "Neutro";

  bool _isLoading = true;
  late TabController _tabController;

  // Controladores
  final _oddCtrl = TextEditingController();
  final _stakeCtrl = TextEditingController();
  final _obsCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _carregarDadosSimulador();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _oddCtrl.dispose();
    _stakeCtrl.dispose();
    _obsCtrl.dispose();
    super.dispose();
  }

  // ---------------------------
  // Persistência JSON
  // ---------------------------
  Future<File> _getFile() async {
    final dir = await getApplicationDocumentsDirectory();
    return File("${dir.path}/simulador_paper_betting.json");
  }

  Future<void> _carregarDadosSimulador() async {
    setState(() => _isLoading = true);
    try {
      final file = await _getFile();
      if (await file.exists()) {
        final content = await file.readAsString();
        if (content.isNotEmpty) {
          final json = jsonDecode(content);
          _bancaInicialSimulada = (json['bancaInicial'] as num?)?.toDouble() ?? 1000.0;
          _apostasSimuladas = (json['apostas'] as List?)?.cast<Map<String, dynamic>>() ?? [];

          _apostasSimuladas.sort((a, b) => (b['data'] ?? '').compareTo(a['data'] ?? ''));

          _atualizarMetodosDisponiveis();
        }
      }
      _calcularEstatisticas();
    } catch (e) {
      debugPrint("Erro ao carregar simulador: $e");
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _atualizarMetodosDisponiveis() {
    final metodos = _apostasSimuladas
        .map((e) => e['titulo'] as String)
        .where((t) => t.isNotEmpty)
        .toSet()
        .toList();
    metodos.sort();
    setState(() => _metodosDisponiveis = metodos);
  }

  Future<void> _salvarDados() async {
    try {
      final file = await _getFile();
      final data = {
        'bancaInicial': _bancaInicialSimulada,
        'apostas': _apostasSimuladas,
      };
      await file.writeAsString(jsonEncode(data));
      _atualizarMetodosDisponiveis();
      _calcularEstatisticas();
    } catch (e) {
      debugPrint("Erro ao salvar simulador: $e");
    }
  }

  // ---------------------------
  // CÁLCULOS AVANÇADOS (CORE)
  // ---------------------------
  void _calcularEstatisticas() {
    double lucroTotal = 0.0;
    double investidoTotal = 0.0;
    int g = 0;
    int r = 0;
    int p = 0;
    double somaOddsGreen = 0.0;

    final listaFiltrada = _filtroMetodoSelecionado == null
        ? _apostasSimuladas
        : _apostasSimuladas.where((a) => a['titulo'] == _filtroMetodoSelecionado).toList();

    final listaCronologica = List<Map<String, dynamic>>.from(listaFiltrada);
    listaCronologica.sort((a, b) => a['data'].compareTo(b['data']));

    List<FlSpot> curve = [const FlSpot(0, 0)];
    double acumuladoGrafico = 0.0;
    int indexGrafico = 1;

    for (var aposta in listaCronologica) {
      if (aposta['status'] != 'pendente') {
        final lucro = (aposta['lucro'] as num).toDouble();
        final stake = (aposta['stake'] as num).toDouble();
        final odd = (aposta['odd'] as num).toDouble();

        lucroTotal += lucro;
        investidoTotal += stake;
        acumuladoGrafico += lucro;

        curve.add(FlSpot(indexGrafico.toDouble(), acumuladoGrafico));
        indexGrafico++;

        if (lucro > 0) {
          g++;
          somaOddsGreen += odd;
        }
        if (lucro < 0) r++;
      } else {
        p++;
      }
    }

    double saldoFinal = _filtroMetodoSelecionado == null
        ? _bancaInicialSimulada + lucroTotal
        : lucroTotal;

    double roi = investidoTotal > 0 ? (lucroTotal / investidoTotal) * 100 : 0.0;
    int totalResolvidas = g + r;
    double winRate = totalResolvidas > 0 ? (g / totalResolvidas) : 0.0;
    double avgOddGreen = g > 0 ? somaOddsGreen / g : 0.0;
    double avgStake = totalResolvidas > 0 ? investidoTotal / totalResolvidas : 0.0;

    String grade = "-";
    Color corGrade = Colors.grey;

    if (totalResolvidas >= 5) {
      if (roi < -10) { grade = "F"; corGrade = Colors.red; }
      else if (roi < 0) { grade = "D"; corGrade = Colors.orange; }
      else if (roi < 5) { grade = "C"; corGrade = Colors.yellow.shade700; }
      else if (roi < 15) { grade = "B"; corGrade = Colors.blue; }
      else if (roi < 30) { grade = "A"; corGrade = Colors.green; }
      else { grade = "S"; corGrade = Colors.purpleAccent; }
    }

    setState(() {
      _saldoAtual = saldoFinal;
      _roiSimulado = roi;
      _greens = g;
      _reds = r;
      _pendentes = p;
      _taxaAcerto = winRate;
      _oddMediaGreen = avgOddGreen;
      _avgStake = avgStake;
      _equityCurve = curve;
      _gradeEstrategia = grade;
      _corGrade = corGrade;
    });

    if (totalResolvidas >= 5 && winRate > 0) {
      _rodarMonteCarlo();
    } else {
      setState(() {
        _monteCarloDisplayPaths = [];
        _mcMedianPath = [];
        _mcP10Path = [];
        _mcP90Path = [];
        _probabilidadeQuebra = "Dados insuficientes";
      });
    }
  }

  void _rodarMonteCarlo() {
    double simulWinRate = (_taxaAcerto + _stressWinRateAdj).clamp(0.01, 0.99);
    double simulOdd = (_oddMediaGreen + _stressOddAdj).clamp(1.01, 100.0);
    double simulStake = _avgStake > 0 ? _avgStake : 10.0;

    List<List<double>> allPaths = [];
    int ruinaCount = 0;
    int simulacoes = 1000; // Aumentei para ter estatística melhor
    int horizonte = 50;
    final random = Random();

    for (int i = 0; i < simulacoes; i++) {
      List<double> path = [0.0];
      double bancaSimulada = 0.0;
      bool quebrou = false;

      for (int j = 0; j < horizonte; j++) {
        bool win = random.nextDouble() < simulWinRate;

        if (win) {
          bancaSimulada += (simulStake * simulOdd) - simulStake;
        } else {
          bancaSimulada -= simulStake;
        }
        path.add(bancaSimulada);

        if (bancaSimulada < -_bancaInicialSimulada) quebrou = true;
      }
      if (quebrou) ruinaCount++;
      allPaths.add(path);
    }

    double probQuebra = (ruinaCount / simulacoes) * 100;

    // Organizar para visualização limpa
    // Ordena os caminhos pelo valor final para achar percentis
    allPaths.sort((a, b) => a.last.compareTo(b.last));

    // Seleciona caminhos chave
    List<double> p10 = allPaths[(simulacoes * 0.1).toInt()]; // Pessimista
    List<double> p50 = allPaths[(simulacoes * 0.5).toInt()]; // Mediana (Realista)
    List<double> p90 = allPaths[(simulacoes * 0.9).toInt()]; // Otimista

    // Seleciona amostra aleatória para fundo (não poluir)
    List<List<double>> displaySample = [];
    for(int k=0; k<30; k++) {
      displaySample.add(allPaths[random.nextInt(simulacoes)]);
    }

    String robustez = "Neutro";
    if (probQuebra == 0) robustez = "Antifrágil 💎";
    else if (probQuebra < 5) robustez = "Robusto 🛡️";
    else if (probQuebra < 20) robustez = "Moderado ⚠️";
    else robustez = "Frágil 🚩";

    setState(() {
      _monteCarloDisplayPaths = displaySample;
      _mcMedianPath = p50;
      _mcP10Path = p10;
      _mcP90Path = p90;
      _probabilidadeQuebra = "${probQuebra.toStringAsFixed(1)}%";
      _robustezScore = robustez;
    });
  }

  // ---------------------------
  // Ações CRUD
  // ---------------------------
  void _adicionarApostaSimulada() {
    _oddCtrl.clear();
    _stakeCtrl.clear();
    _obsCtrl.clear();
    String metodoDigitado = "";

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Novo Teste de Estratégia"),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Autocomplete<String>(
                optionsBuilder: (TextEditingValue textEditingValue) {
                  if (textEditingValue.text == '') return const Iterable<String>.empty();
                  return _metodosDisponiveis.where((String option) => option.toLowerCase().contains(textEditingValue.text.toLowerCase()));
                },
                onSelected: (String selection) => metodoDigitado = selection,
                fieldViewBuilder: (context, textEditingController, focusNode, onFieldSubmitted) {
                  textEditingController.addListener(() => metodoDigitado = textEditingController.text);
                  return TextField(
                    controller: textEditingController,
                    focusNode: focusNode,
                    onEditingComplete: onFieldSubmitted,
                    decoration: const InputDecoration(
                      labelText: "Estratégia / Método",
                      hintText: "Ex: Back Casa HT",
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.lightbulb_outline),
                    ),
                    textCapitalization: TextCapitalization.sentences,
                  );
                },
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _oddCtrl,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      decoration: const InputDecoration(labelText: "Odd Esperada", border: OutlineInputBorder()),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextField(
                      controller: _stakeCtrl,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      decoration: const InputDecoration(labelText: "Stake (R\$)", border: OutlineInputBorder()),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _obsCtrl,
                decoration: const InputDecoration(labelText: "Jogo / Notas", border: OutlineInputBorder()),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Cancelar")),
          ElevatedButton(
            onPressed: () {
              final titulo = metodoDigitado.trim();
              final odd = double.tryParse(_oddCtrl.text.replaceAll(',', '.')) ?? 0.0;
              final stake = double.tryParse(_stakeCtrl.text.replaceAll(',', '.')) ?? 0.0;

              if (titulo.isNotEmpty && odd > 1 && stake > 0) {
                setState(() {
                  _apostasSimuladas.insert(0, {
                    'id': DateTime.now().millisecondsSinceEpoch.toString(),
                    'data': DateTime.now().toIso8601String(),
                    'titulo': titulo,
                    'odd': odd,
                    'stake': stake,
                    'status': 'pendente',
                    'lucro': 0.0,
                    'obs': _obsCtrl.text.trim(),
                  });
                });
                _salvarDados();
                Navigator.pop(ctx);
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.indigo, foregroundColor: Colors.white),
            child: const Text("Iniciar Teste"),
          ),
        ],
      ),
    );
  }

  // NOVO: Função para editar qualquer aposta e alterar resultado
  void _editarAposta(Map<String, dynamic> aposta) {
    final tituloCtrl = TextEditingController(text: aposta['titulo']);
    final oddCtrl = TextEditingController(text: (aposta['odd'] as num).toString());
    final stakeCtrl = TextEditingController(text: (aposta['stake'] as num).toString());
    final obsCtrl = TextEditingController(text: aposta['obs'] ?? '');
    String statusSelecionado = aposta['status']; // pendente, win, loss, void

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text("Editar Aposta"),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: tituloCtrl,
                      decoration: const InputDecoration(labelText: "Estratégia / Método", border: OutlineInputBorder()),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(child: TextField(controller: oddCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: "Odd", border: OutlineInputBorder()))),
                        const SizedBox(width: 12),
                        Expanded(child: TextField(controller: stakeCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: "Stake", border: OutlineInputBorder()))),
                      ],
                    ),
                    const SizedBox(height: 12),
                    TextField(controller: obsCtrl, decoration: const InputDecoration(labelText: "Obs (Time/Jogo)", border: OutlineInputBorder())),
                    const SizedBox(height: 16),

                    // DROPDOWN PARA ALTERAR RESULTADO (CORRIGIR ERROS)
                    DropdownButtonFormField<String>(
                      value: statusSelecionado,
                      decoration: const InputDecoration(labelText: "Status / Resultado", border: OutlineInputBorder()),
                      items: const [
                        DropdownMenuItem(value: 'pendente', child: Text("Pendente (Em andamento)")),
                        DropdownMenuItem(value: 'win', child: Text("Green (Vitória)")),
                        DropdownMenuItem(value: 'loss', child: Text("Red (Derrota)")),
                        DropdownMenuItem(value: 'void', child: Text("Reembolso (Void)")),
                      ],
                      onChanged: (v) => setDialogState(() => statusSelecionado = v!),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Cancelar")),
                ElevatedButton(
                  onPressed: () {
                    final odd = double.tryParse(oddCtrl.text.replaceAll(',', '.')) ?? 0.0;
                    final stake = double.tryParse(stakeCtrl.text.replaceAll(',', '.')) ?? 0.0;

                    if (tituloCtrl.text.isNotEmpty && odd > 0 && stake > 0) {
                      setState(() {
                        aposta['titulo'] = tituloCtrl.text;
                        aposta['odd'] = odd;
                        aposta['stake'] = stake;
                        aposta['obs'] = obsCtrl.text;

                        // Recalcula lucro com base no novo status
                        double lucro = 0.0;
                        if (statusSelecionado == 'win') lucro = (stake * odd) - stake;
                        else if (statusSelecionado == 'loss') lucro = -stake;
                        else lucro = 0.0;

                        aposta['status'] = statusSelecionado;
                        aposta['lucro'] = lucro;
                      });

                      _salvarDados(); // Recalcula stats gerais
                      Navigator.pop(ctx);
                    }
                  },
                  child: const Text("Salvar Alterações"),
                ),
              ],
            );
          }
      ),
    );
  }

  void _resolverAposta(Map<String, dynamic> aposta, String resultado) {
    final stake = (aposta['stake'] as num).toDouble();
    final odd = (aposta['odd'] as num).toDouble();
    double lucro = 0.0;

    if (resultado == 'win') lucro = (stake * odd) - stake;
    else if (resultado == 'loss') lucro = -stake;

    setState(() {
      aposta['status'] = resultado;
      aposta['lucro'] = lucro;
    });
    _salvarDados();
  }

  void _excluirAposta(String id) {
    setState(() {
      _apostasSimuladas.removeWhere((a) => a['id'] == id);
    });
    _salvarDados();
  }

  Future<void> _excluirMetodoAtual() async {
    if (_filtroMetodoSelecionado == null) return;

    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text("Excluir Método '${_filtroMetodoSelecionado}'?"),
        content: const Text("Isso apagará TODAS as apostas (histórico e pendentes) vinculadas a esta estratégia.\n\nEssa ação não pode ser desfeita."),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text("Cancelar")),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text("Excluir Tudo", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      setState(() {
        _apostasSimuladas.removeWhere((a) => a['titulo'] == _filtroMetodoSelecionado);
        _filtroMetodoSelecionado = null;
      });
      _salvarDados();
    }
  }

  void _alterarBancaInicial() {
    final ctrl = TextEditingController(text: _bancaInicialSimulada.toString());
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Ajustar Banca Fictícia"),
        content: TextField(controller: ctrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: "Valor Inicial", border: OutlineInputBorder())),
        actions: [
          ElevatedButton(
            onPressed: () {
              final val = double.tryParse(ctrl.text.replaceAll(',', '.'));
              if (val != null && val > 0) {
                setState(() => _bancaInicialSimulada = val);
                _salvarDados();
                Navigator.pop(ctx);
              }
            },
            child: const Text("Salvar"),
          ),
        ],
      ),
    );
  }

  // ---------------------------
  // UI PRINCIPAL
  // ---------------------------
  @override
  Widget build(BuildContext context) {
    final listaExibicao = _filtroMetodoSelecionado == null
        ? _apostasSimuladas
        : _apostasSimuladas.where((a) => a['titulo'] == _filtroMetodoSelecionado).toList();

    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Laboratório de Estratégias 🧪", style: TextStyle(fontSize: 16)),
            Text(_filtroMetodoSelecionado ?? "Visão Geral", style: TextStyle(fontSize: 12, color: Colors.indigo.shade100)),
          ],
        ),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(icon: const Icon(Icons.account_balance_wallet), onPressed: _alterarBancaInicial),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          tabs: const [
            Tab(text: "Operações", icon: Icon(Icons.list)),
            Tab(text: "Equity", icon: Icon(Icons.show_chart)),
            Tab(text: "Stress Test", icon: Icon(Icons.speed)),
          ],
        ),
      ),
      body: _isLoading ? const Center(child: CircularProgressIndicator()) : Column(
        children: [
          // FILTRO DE MÉTODO
          Container(
            color: Colors.indigo,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                const Icon(Icons.filter_alt, color: Colors.white70, size: 18),
                const SizedBox(width: 8),
                Expanded(
                  child: Theme(
                    data: Theme.of(context).copyWith(canvasColor: Colors.indigo),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        isExpanded: true,
                        value: _filtroMetodoSelecionado,
                        hint: const Text("Filtrar por Método...", style: TextStyle(color: Colors.white)),
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                        icon: const Icon(Icons.arrow_drop_down, color: Colors.white),
                        items: [
                          const DropdownMenuItem<String>(value: null, child: Text("Todas as Estratégias (Global)")),
                          ..._metodosDisponiveis.map((m) => DropdownMenuItem(value: m, child: Text(m)))
                        ],
                        onChanged: (val) {
                          setState(() {
                            _filtroMetodoSelecionado = val;
                            _calcularEstatisticas();
                          });
                        },
                      ),
                    ),
                  ),
                ),
                if (_filtroMetodoSelecionado != null)
                  IconButton(
                    icon: const Icon(Icons.delete_forever, color: Colors.white70),
                    tooltip: "Excluir Método Inteiro",
                    onPressed: _excluirMetodoAtual,
                  ),
              ],
            ),
          ),

          // RESUMO RÁPIDO
          Container(
            padding: const EdgeInsets.all(12),
            color: Colors.white,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildMiniStat("Saldo", _filtroMetodoSelecionado == null ? "R\$ ${_saldoAtual.toStringAsFixed(0)}" : "R\$ ${_saldoAtual.toStringAsFixed(2)}", _saldoAtual >= (_filtroMetodoSelecionado == null ? _bancaInicialSimulada : 0) ? Colors.green : Colors.red),
                _buildMiniStat("ROI", "${_roiSimulado.toStringAsFixed(1)}%", _roiSimulado >= 0 ? Colors.green : Colors.red),
                _buildMiniStat("WinRate", "${(_taxaAcerto * 100).toStringAsFixed(0)}%", Colors.blue),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(color: _corGrade.withOpacity(0.2), shape: BoxShape.circle),
                  child: Text(_gradeEstrategia, style: TextStyle(fontWeight: FontWeight.bold, color: _corGrade, fontSize: 16)),
                )
              ],
            ),
          ),

          // CONTEÚDO DAS ABAS
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                // ABA 1: LISTA
                listaExibicao.isEmpty
                    ? _buildEmptyState()
                    : ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
                  itemCount: listaExibicao.length,
                  itemBuilder: (ctx, index) => _buildBetCard(listaExibicao[index]),
                ),

                // ABA 2: GRÁFICO EQUITY
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: _equityCurve.length > 1
                      ? LineChart(
                      LineChartData(
                          gridData: FlGridData(show: true, drawVerticalLine: false),
                          titlesData: FlTitlesData(
                            leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 40, getTitlesWidget: (v, m) => Text(v.toInt().toString(), style: const TextStyle(fontSize: 10)))),
                            bottomTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                          ),
                          borderData: FlBorderData(show: true, border: Border.all(color: Colors.grey.shade300)),
                          lineBarsData: [
                            LineChartBarData(
                              spots: _equityCurve,
                              isCurved: false,
                              color: _roiSimulado >= 0 ? Colors.green : Colors.red,
                              barWidth: 2,
                              dotData: const FlDotData(show: false),
                              belowBarData: BarAreaData(show: true, color: (_roiSimulado >= 0 ? Colors.green : Colors.red).withOpacity(0.1)),
                            )
                          ]
                      )
                  )
                      : const Center(child: Text("Realize mais testes para gerar o gráfico.")),
                ),

                // ABA 3: MONTE CARLO & STRESS TEST
                SingleChildScrollView(
                  child: Column(
                    children: [
                      Container(
                        color: Colors.orange.shade50,
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text("⚡ ANÁLISE DE SENSIBILIDADE", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.deepOrange)),
                            const SizedBox(height: 8),
                            const Text("Simule o que acontece se sua estratégia performar pior do que o esperado (Stress Test).", style: TextStyle(fontSize: 12, color: Colors.grey)),
                            const Divider(),

                            Text("Variação da Taxa de Acerto: ${(_stressWinRateAdj * 100).toStringAsFixed(0)}%"),
                            Slider(
                              value: _stressWinRateAdj,
                              min: -0.20,
                              max: 0.10,
                              divisions: 6,
                              label: "${(_stressWinRateAdj * 100).toStringAsFixed(0)}%",
                              activeColor: Colors.deepOrange,
                              onChanged: (val) {
                                setState(() {
                                  _stressWinRateAdj = val;
                                });
                                _rodarMonteCarlo();
                              },
                            ),

                            Text("Variação da Odd Média: ${_stressOddAdj > 0 ? '+' : ''}${_stressOddAdj.toStringAsFixed(2)}"),
                            Slider(
                              value: _stressOddAdj,
                              min: -0.50,
                              max: 0.50,
                              divisions: 10,
                              label: _stressOddAdj.toStringAsFixed(2),
                              activeColor: Colors.indigo,
                              onChanged: (val) {
                                setState(() {
                                  _stressOddAdj = val;
                                });
                                _rodarMonteCarlo();
                              },
                            ),

                            Center(
                              child: TextButton.icon(
                                icon: const Icon(Icons.refresh),
                                label: const Text("Resetar Parâmetros"),
                                onPressed: () {
                                  setState(() {
                                    _stressWinRateAdj = 0.0;
                                    _stressOddAdj = 0.0;
                                  });
                                  _rodarMonteCarlo();
                                },
                              ),
                            )
                          ],
                        ),
                      ),

                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Card(
                          color: Colors.black87,
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text("Risco de Quebra", style: TextStyle(color: Colors.white70, fontSize: 12)),
                                    const Text("(Simulação 1000x)", style: TextStyle(color: Colors.white30, fontSize: 10)),
                                    const SizedBox(height: 4),
                                    Text(_robustezScore, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
                                  ],
                                ),
                                Text(_probabilidadeQuebra, style: TextStyle(color: _getCorProbQuebra(), fontSize: 32, fontWeight: FontWeight.bold)),
                              ],
                            ),
                          ),
                        ),
                      ),

                      SizedBox(
                        height: 250,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
                          child: LineChart(
                              LineChartData(
                                gridData: FlGridData(show: false),
                                titlesData: const FlTitlesData(show: false),
                                borderData: FlBorderData(show: true, border: Border.all(color: Colors.grey.shade300)),
                                lineBarsData: [
                                  // Fundo (Ruído) - 30 linhas aleatórias suaves
                                  ..._monteCarloDisplayPaths.map((path) => LineChartBarData(
                                    spots: path.asMap().entries.map((e) => FlSpot(e.key.toDouble(), e.value)).toList(),
                                    isCurved: false,
                                    color: Colors.grey.withOpacity(0.1),
                                    barWidth: 1,
                                    dotData: const FlDotData(show: false),
                                  )),
                                  // Pessimista (P10) - Vermelho
                                  if (_mcP10Path.isNotEmpty) LineChartBarData(
                                    spots: _mcP10Path.asMap().entries.map((e) => FlSpot(e.key.toDouble(), e.value)).toList(),
                                    isCurved: false,
                                    color: Colors.redAccent.withOpacity(0.8),
                                    barWidth: 2,
                                    dotData: const FlDotData(show: false),
                                  ),
                                  // Otimista (P90) - Verde
                                  if (_mcP90Path.isNotEmpty) LineChartBarData(
                                    spots: _mcP90Path.asMap().entries.map((e) => FlSpot(e.key.toDouble(), e.value)).toList(),
                                    isCurved: false,
                                    color: Colors.greenAccent.withOpacity(0.8),
                                    barWidth: 2,
                                    dotData: const FlDotData(show: false),
                                  ),
                                  // Mediana (P50) - Azul Forte
                                  if (_mcMedianPath.isNotEmpty) LineChartBarData(
                                    spots: _mcMedianPath.asMap().entries.map((e) => FlSpot(e.key.toDouble(), e.value)).toList(),
                                    isCurved: false,
                                    color: Colors.indigo,
                                    barWidth: 3,
                                    dotData: const FlDotData(show: false),
                                  ),
                                ],
                              )
                          ),
                        ),
                      ),

                      const SizedBox(height: 8),
                      // LEGENDA DO GRÁFICO
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            Row(children: [Container(width: 10, height: 10, color: Colors.greenAccent), const SizedBox(width: 4), const Text("Otimista", style: TextStyle(fontSize: 10))]),
                            Row(children: [Container(width: 10, height: 10, color: Colors.indigo), const SizedBox(width: 4), const Text("Provável", style: TextStyle(fontSize: 10))]),
                            Row(children: [Container(width: 10, height: 10, color: Colors.redAccent), const SizedBox(width: 4), const Text("Pessimista", style: TextStyle(fontSize: 10))]),
                          ],
                        ),
                      ),

                      const SizedBox(height: 30),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _adicionarApostaSimulada,
        backgroundColor: Colors.indigo,
        icon: const Icon(Icons.add_task),
        label: const Text("Novo Teste"),
      ),
    );
  }

  Color _getCorProbQuebra() {
    if (_probabilidadeQuebra.contains("...")) return Colors.grey;
    double p = double.tryParse(_probabilidadeQuebra.replaceAll('%', '')) ?? 0.0;
    if (p == 0) return Colors.greenAccent;
    if (p < 5) return Colors.green;
    if (p < 20) return Colors.orange;
    return Colors.red;
  }

  Widget _buildMiniStat(String label, String value, Color color) {
    return Column(
      children: [
        Text(label, style: const TextStyle(fontSize: 10, color: Colors.grey)),
        const SizedBox(height: 2),
        Text(value, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: color)),
      ],
    );
  }

  Widget _buildBetCard(Map<String, dynamic> item) {
    final status = item['status'];
    Color statusColor = Colors.grey;
    IconData statusIcon = Icons.hourglass_empty;

    if (status == 'win') {
      statusColor = Colors.green;
      statusIcon = Icons.check_circle;
    } else if (status == 'loss') {
      statusColor = Colors.red;
      statusIcon = Icons.cancel;
    } else if (status == 'void') {
      statusColor = Colors.orange;
      statusIcon = Icons.do_not_disturb_on;
    }

    final lucro = (item['lucro'] as num).toDouble();
    final obs = item['obs'] ?? '';

    return Dismissible(
      key: Key(item['id']),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        color: Colors.red,
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      confirmDismiss: (direction) async {
        return await showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text("Excluir Aposta"),
            content: const Text("Tem certeza que deseja apagar este registro?"),
            actions: [
              TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text("Cancelar")),
              TextButton(
                onPressed: () => Navigator.pop(ctx, true),
                child: const Text("Excluir", style: TextStyle(color: Colors.red)),
              ),
            ],
          ),
        );
      },
      onDismissed: (direction) {
        _excluirAposta(item['id']);
      },
      child: Card(
        elevation: 2,
        margin: const EdgeInsets.only(bottom: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: statusColor.withOpacity(0.3), width: 1),
        ),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // LINHA 1: ÍCONE, TÍTULO (MÉTODO), RESULTADO e BOTÃO EDITAR
              Row(
                children: [
                  Icon(statusIcon, color: statusColor, size: 24),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      item['titulo'],
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                  ),
                  if (status != 'pendente')
                    Text(
                      lucro >= 0 ? "+R\$ ${lucro.toStringAsFixed(2)}" : "-R\$ ${lucro.abs().toStringAsFixed(2)}",
                      style: TextStyle(color: statusColor, fontWeight: FontWeight.bold, fontSize: 15),
                    ),

                  // BOTÃO DE EDITAR
                  const SizedBox(width: 4),
                  IconButton(
                    icon: const Icon(Icons.edit, size: 20, color: Colors.grey),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    tooltip: "Editar",
                    onPressed: () => _editarAposta(item),
                  ),
                ],
              ),

              // LINHA 2: OBSERVAÇÃO / TIME
              if (obs.isNotEmpty) ...[
                const SizedBox(height: 6),
                Padding(
                  padding: const EdgeInsets.only(left: 36.0),
                  child: Text(
                    obs,
                    style: TextStyle(color: Colors.indigo.shade800, fontSize: 14, fontWeight: FontWeight.w500),
                  ),
                ),
              ],

              const SizedBox(height: 12),

              // LINHA 3: BARRA DE INFORMAÇÕES
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("Odd: ${(item['odd'] as num).toStringAsFixed(2)}", style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                    Text("Stake: R\$ ${(item['stake'] as num).toStringAsFixed(2)}", style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                    Text(DateFormat('dd/MM HH:mm').format(DateTime.parse(item['data'])), style: const TextStyle(fontSize: 11, color: Colors.grey)),
                  ],
                ),
              ),

              // LINHA 4: BOTÕES DE AÇÃO (SE PENDENTE)
              if (status == 'pendente') ...[
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => _resolverAposta(item, 'win'),
                        icon: const Icon(Icons.check, size: 18),
                        label: const Text("Green"),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.green,
                          side: BorderSide(color: Colors.green.withOpacity(0.5)),
                          visualDensity: VisualDensity.compact,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => _resolverAposta(item, 'loss'),
                        icon: const Icon(Icons.close, size: 18),
                        label: const Text("Red"),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.red,
                          side: BorderSide(color: Colors.red.withOpacity(0.5)),
                          visualDensity: VisualDensity.compact,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      onPressed: () => _resolverAposta(item, 'void'),
                      icon: const Icon(Icons.undo, color: Colors.orange),
                      tooltip: "Anular / Devolvida",
                      visualDensity: VisualDensity.compact,
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.science_outlined, size: 64, color: Colors.grey.shade300),
          const SizedBox(height: 16),
          const Text("Nenhum dado para este método.", style: TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }
}
// ===================================================================
// FIM DO BLOCO DA TELA DE SIMULAÇÃO ( TELA 7 )
// ===================================================================


// ===================================================================
// INÍCIO DO BLOCO DA TELA CENTRO DE CONTROLE ( TELA 8 )
// ===================================================================


class TelaSobra4 extends StatefulWidget {
  const TelaSobra4({super.key});

  @override
  State<TelaSobra4> createState() => _TelaSobra4State();
}

class _TelaSobra4State extends State<TelaSobra4> with TickerProviderStateMixin {
  late TabController _tabController;

  // --- VARIÁVEIS RISCO DE RUÍNA ---
  final _ruinaWinRateCtrl = TextEditingController();
  final _ruinaOddCtrl = TextEditingController();
  final _ruinaRiscoCtrl = TextEditingController();

  // Estado Visual e Lógico
  String _resultadoRuina = "Aguardando cálculo...";
  Color _corRuina = Colors.grey;
  Map<String, dynamic> _detalhesRuina = {};
  List<BarChartGroupData> _histogramaDados = [];

  // Escala Visual do Histograma
  double _histoMin = 0.0;
  double _histoMax = 0.0;

  List<String> _alertasInteligentes = [];

  // Modo Interativo
  bool _modoInterativo = false;
  double _sliderWinRate = 50.0;
  double _sliderOdd = 2.0;
  double _sliderStake = 2.0;

  // Histórico e Comparação
  List<Map<String, dynamic>> _historicoSimulacoes = [];
  Map<String, dynamic>? _simulacaoComparacao;
  bool _isComparando = false;

  // --- VARIÁVEIS JUROS COMPOSTOS ---
  final _jurosBancaCtrl = TextEditingController();
  final _jurosMesesCtrl = TextEditingController(text: "12");
  final _jurosTaxaCtrl = TextEditingController(text: "10");
  final _jurosAporteCtrl = TextEditingController(text: "0");
  String _resultadoJuros = "";
  List<FlSpot> _graficoJuros = [];
  Map<String, double> _cenarios = {};

  // --- VARIÁVEIS ANÁLISE DE VARIÂNCIA ---
  List<double> _ultimosResultados = [];
  double _sharpeRatio = 0.0;
  double _maxDrawdown = 0.0;
  String _classificacaoConsistencia = "";

  // --- VARIÁVEIS MODO ZEN ---
  late AnimationController _breathingController;
  bool _zenAtivo = false;
  int _zenContador = 0;
  final int _zenDuracao = 60; // 60 segundos
  Timer? _zenTimer;

  // --- VARIÁVEIS DIÁRIO EMOCIONAL ---
  final _diarioCtrl = TextEditingController();
  List<Map<String, dynamic>> _registrosEmocionais = [];
  String _humorAtual = "Neutro";

  bool _isLoadingDados = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);

    _breathingController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    )..addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _breathingController.reverse();
      } else if (status == AnimationStatus.dismissed) {
        _breathingController.forward();
      }
    });

    _carregarDadosReais();
    _carregarDiarioEmocional();
    _carregarHistoricoSimulacoes();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _breathingController.dispose();
    _zenTimer?.cancel();
    _ruinaWinRateCtrl.dispose();
    _ruinaOddCtrl.dispose();
    _ruinaRiscoCtrl.dispose();
    _jurosBancaCtrl.dispose();
    _jurosMesesCtrl.dispose();
    _jurosTaxaCtrl.dispose();
    _jurosAporteCtrl.dispose();
    _diarioCtrl.dispose();
    super.dispose();
  }

  // --- PERSISTÊNCIA DE HISTÓRICO SIMULAÇÕES ---
  Future<File> _getHistoricoSimulacoesFile() async {
    final dir = await getApplicationDocumentsDirectory();
    return File("${dir.path}/historico_simulacoes.json");
  }

  Future<void> _carregarHistoricoSimulacoes() async {
    try {
      final file = await _getHistoricoSimulacoesFile();
      if (await file.exists()) {
        final content = await file.readAsString();
        if (content.isNotEmpty) {
          setState(() {
            _historicoSimulacoes = List<Map<String, dynamic>>.from(jsonDecode(content));
          });
        }
      }
    } catch (e) {
      debugPrint("Erro carregar histórico simulações: $e");
    }
  }

  Future<void> _salvarHistoricoSimulacoes() async {
    try {
      final file = await _getHistoricoSimulacoesFile();
      if (_historicoSimulacoes.length > 10) {
        _historicoSimulacoes = _historicoSimulacoes.sublist(0, 10);
      }
      await file.writeAsString(jsonEncode(_historicoSimulacoes));
    } catch (e) {
      debugPrint("Erro salvar histórico simulações: $e");
    }
  }

  void _adicionarAoHistorico() {
    if (_detalhesRuina.isEmpty) return;

    final novaSimulacao = {
      'id': DateTime.now().millisecondsSinceEpoch.toString(),
      'data': DateTime.now().toIso8601String(),
      'parametros': {
        'winRate': _modoInterativo ? _sliderWinRate : double.tryParse(_ruinaWinRateCtrl.text),
        'odd': _modoInterativo ? _sliderOdd : double.tryParse(_ruinaOddCtrl.text),
        'stake': _modoInterativo ? _sliderStake : double.tryParse(_ruinaRiscoCtrl.text),
      },
      'resultados': _detalhesRuina,
      'textoRisco': _resultadoRuina,
    };

    setState(() {
      _historicoSimulacoes.insert(0, novaSimulacao);
    });
    _salvarHistoricoSimulacoes();
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Simulação salva no histórico!")));
  }

  // --- INTEGRACAO IA (SALVAR DADOS MATEMÁTICOS E EMOCIONAIS) ---
  Future<void> _atualizarArquivoIA() async {
    try {
      final dir = await getApplicationDocumentsDirectory();
      final file = File("${dir.path}/informacoes_para_IA.json");

      Map<String, dynamic> dadosGerais = {};
      if (await file.exists()) {
        final content = await file.readAsString();
        if (content.isNotEmpty) {
          try {
            dadosGerais = jsonDecode(content);
          } catch (_) {}
        }
      }

      final dadosMenteMatematica = {
        "risco_ruina": {
          "probabilidade_texto": _resultadoRuina,
          "estatisticas": _detalhesRuina,
          "alertas": _alertasInteligentes,
        },
        "projecao_futura": {
          "cenario_base_valor": _resultadoJuros,
          "outros_cenarios": _cenarios,
          "configuracao": {
            "meses": _jurosMesesCtrl.text,
            "taxa_mensal": _jurosTaxaCtrl.text,
            "aporte": _jurosAporteCtrl.text
          }
        },
        "metricas_performance": {
          "sharpe_ratio": _sharpeRatio,
          "max_drawdown": _maxDrawdown,
          "consistencia_classificacao": _classificacaoConsistencia
        },
        "diario_emocional": {
          "humor_atual": _humorAtual,
          "ultimo_registro_texto": _registrosEmocionais.isNotEmpty ? _registrosEmocionais.first['texto'] : null,
          "ultimo_registro_data": _registrosEmocionais.isNotEmpty ? _registrosEmocionais.first['data'] : null
        }
      };

      dadosGerais["mente_matematica"] = dadosMenteMatematica;
      dadosGerais["timestamp_mente_matematica"] = DateTime.now().toIso8601String();

      await file.writeAsString(jsonEncode(dadosGerais));
    } catch (e) {
      debugPrint("Erro ao salvar dados IA (MenteMatematica): $e");
    }
  }

  // --- CARREGAMENTO DE DADOS ---
  Future<void> _carregarDadosReais() async {
    if (!mounted) return;
    setState(() => _isLoadingDados = true);

    try {
      final dir = await getApplicationDocumentsDirectory();
      final file = File("${dir.path}/apostas_data.json");

      if (await file.exists()) {
        final content = await file.readAsString();
        if (content.isNotEmpty) {
          final json = jsonDecode(content);
          final apostas = (json['apostas'] as List?)?.cast<Map<String, dynamic>>() ?? [];
          final config = json['config'] as Map<String, dynamic>?;

          final aportes = (config?['aportes'] as List?)?.cast<Map<String, dynamic>>() ?? [];
          final saques = (config?['saques'] as List?)?.cast<Map<String, dynamic>>() ?? [];

          double bancaInicial = 1000.0;
          if (config != null && config['bancaInicial'] != null) {
            bancaInicial = (config['bancaInicial'] as num).toDouble();
          }

          if (apostas.isNotEmpty) {
            _processarDadosApostas(apostas, aportes, saques, bancaInicial);
          } else {
            _definirValoresPadrao(bancaInicial);
          }
        }
      }
    } catch (e) {
      debugPrint("Erro ao carregar dados: $e");
    } finally {
      if (mounted) setState(() => _isLoadingDados = false);
    }
  }

  void _definirValoresPadrao(double bancaInicial) {
    if (mounted) {
      setState(() {
        _ruinaWinRateCtrl.text = "50";
        _ruinaOddCtrl.text = "2.00";
        _ruinaRiscoCtrl.text = "2.0";

        _sliderWinRate = 50.0;
        _sliderOdd = 2.0;
        _sliderStake = 2.0;

        _jurosBancaCtrl.text = bancaInicial.toStringAsFixed(2);
      });
      // Atualiza IA com valores padrão para não ficar vazio
      _atualizarArquivoIA();
    }
  }

  void _processarDadosApostas(List<Map<String, dynamic>> apostas, List<Map<String, dynamic>> aportes, List<Map<String, dynamic>> saques, double bancaInicial) {
    int wins = 0;
    double somaOdds = 0.0;
    double lucroTotalApostas = 0.0;
    double somaStakes = 0.0;
    List<double> resultados = [];

    List<Map<String, dynamic>> timeline = [];

    for (var a in apostas) {
      final lucro = (a['lucro'] as num?)?.toDouble() ?? 0.0;
      final odd = (a['odd'] as num?)?.toDouble() ?? 0.0;
      final stake = (a['stake'] as num?)?.toDouble() ?? 0.0;

      DateTime data;
      try { data = DateTime.parse(a['data']); } catch (_) { data = DateTime.now(); }

      if (lucro > 0) wins++;
      somaOdds += odd;
      lucroTotalApostas += lucro;
      somaStakes += stake;
      resultados.add(lucro);

      timeline.add({'data': data, 'valor': lucro, 'tipo': 'aposta'});
    }

    for (var a in aportes) {
      try { timeline.add({'data': DateTime.parse(a['data']), 'valor': (a['valor'] as num).toDouble(), 'tipo': 'aporte'}); } catch (_) {}
    }
    for (var s in saques) {
      try { timeline.add({'data': DateTime.parse(s['data']), 'valor': -(s['valor'] as num).toDouble(), 'tipo': 'saque'}); } catch (_) {}
    }

    timeline.sort((a, b) => (a['data'] as DateTime).compareTo(b['data'] as DateTime));

    double totalAportes = aportes.fold(0.0, (sum, item) => sum + (item['valor'] as num).toDouble());
    double totalSaques = saques.fold(0.0, (sum, item) => sum + (item['valor'] as num).toDouble());

    final bancaAtual = bancaInicial + lucroTotalApostas + totalAportes - totalSaques;

    // Cálculo Crescimento Mensal
    Map<String, double> lucroPorMes = {};
    Map<String, double> bancaInicioMes = {};
    double bancaCorrente = bancaInicial;
    String mesAtualKey = "";

    for (var evento in timeline) {
      DateTime dt = evento['data'];
      String key = "${dt.year}-${dt.month.toString().padLeft(2, '0')}";

      if (key != mesAtualKey) {
        if (!bancaInicioMes.containsKey(key)) bancaInicioMes[key] = bancaCorrente;
        mesAtualKey = key;
      }

      double valor = evento['valor'];
      bancaCorrente += valor;

      if (evento['tipo'] == 'aposta') {
        lucroPorMes[key] = (lucroPorMes[key] ?? 0.0) + valor;
      }
    }

    List<double> crescimentosMensais = [];
    bancaInicioMes.forEach((key, bancaIni) {
      if (bancaIni > 0 && lucroPorMes.containsKey(key)) {
        double lucroMes = lucroPorMes[key]!;
        double pct = (lucroMes / bancaIni) * 100;
        crescimentosMensais.add(pct);
      }
    });

    double mediaCrescimentoMensal = crescimentosMensais.isNotEmpty
        ? crescimentosMensais.reduce((a, b) => a + b) / crescimentosMensais.length
        : 5.0;
    if (mediaCrescimentoMensal <= 0) mediaCrescimentoMensal = 5.0;

    final totalBets = apostas.length;
    final winRate = totalBets > 0 ? (wins / totalBets) * 100 : 0.0;
    final oddMedia = totalBets > 0 ? somaOdds / totalBets : 0.0;
    final stakeMedia = totalBets > 0 ? somaStakes / totalBets : 0.0;
    final riscoMedioPct = bancaAtual > 0 ? (stakeMedia / bancaAtual) * 100 : 0.0;

    _calcularMetricasVariancia(resultados, bancaInicial);

    if (mounted) {
      setState(() {
        _ruinaWinRateCtrl.text = winRate.toStringAsFixed(1);
        _ruinaOddCtrl.text = oddMedia.toStringAsFixed(2);
        _ruinaRiscoCtrl.text = riscoMedioPct.toStringAsFixed(2);

        _sliderWinRate = winRate;
        _sliderOdd = oddMedia;
        _sliderStake = riscoMedioPct > 0 ? riscoMedioPct : 2.0;

        _jurosBancaCtrl.text = bancaAtual.toStringAsFixed(2);
        _jurosTaxaCtrl.text = mediaCrescimentoMensal.toStringAsFixed(2);

        _ultimosResultados = resultados;
      });

      if (totalBets > 0) {
        _calcularRiscoRuina(atualizarIA: false);
        _calcularJuros(atualizarIA: false);
        _atualizarArquivoIA();
      }
    }
  }

  // --- CÁLCULO RISCO DE RUÍNA AVANÇADO (COM CAOS E PSICOLOGIA) ---
  void _calcularRiscoRuina({bool atualizarIA = true}) {
    double wrInput, oddInput, riskPct;

    if (_modoInterativo) {
      wrInput = _sliderWinRate;
      oddInput = _sliderOdd;
      riskPct = _sliderStake;
    } else {
      wrInput = double.tryParse(_ruinaWinRateCtrl.text.replaceAll(',', '.')) ?? 0;
      oddInput = double.tryParse(_ruinaOddCtrl.text.replaceAll(',', '.')) ?? 0;
      riskPct = double.tryParse(_ruinaRiscoCtrl.text.replaceAll(',', '.')) ?? 0;
    }

    if (wrInput <= 0 || oddInput <= 1 || riskPct <= 0) {
      setState(() {
        _resultadoRuina = "Dados insuficientes";
        _detalhesRuina = {};
        _histogramaDados = [];
        _alertasInteligentes = [];
      });
      return;
    }

    int simulacoes = _modoInterativo ? 1000 : 5000;
    int horizonteApostas = 1000;
    int quebrasTotais = 0;
    int drawdownsSeveros = 0;
    int drawdownsModerados = 0;
    List<double> bancasFinais = [];
    List<double> pioresDrawdowns = [];
    double bancaBase = 1000.0;
    final random = Random();

    for (int i = 0; i < simulacoes; i++) {
      double bancaSimulada = bancaBase;
      double bancaMaxima = bancaBase;
      double piorDrawdown = 0.0;
      bool quebrouTotal = false;
      bool sofreuDrawdownSevero = false;
      bool sofreuDrawdownModerado = false;

      double variacaoSorte = (random.nextDouble() * 14) - 7;
      double wrBaseSimulacao = (wrInput + variacaoSorte).clamp(5.0, 95.0);

      double stakeBase = bancaBase * (riskPct / 100.0);
      double stakeAtual = stakeBase;
      int redsConsecutivos = 0;

      bool emFaseRuim = false;
      int jogosRestantesFaseRuim = 0;

      for (int j = 0; j < horizonteApostas; j++) {
        // Bad Run
        if (!emFaseRuim && random.nextDouble() < 0.005) {
          emFaseRuim = true;
          jogosRestantesFaseRuim = 40;
        }

        double wrAtual = wrBaseSimulacao;
        if (emFaseRuim) {
          wrAtual -= 12.0;
          jogosRestantesFaseRuim--;
          if (jogosRestantesFaseRuim <= 0) emFaseRuim = false;
        }

        bool win = (random.nextDouble() * 100) < wrAtual;

        if (win) {
          bancaSimulada += stakeAtual * (oddInput - 1);
          stakeAtual = stakeBase;
          redsConsecutivos = 0;
          if (bancaSimulada > bancaMaxima) bancaMaxima = bancaSimulada;
        } else {
          bancaSimulada -= stakeAtual;
          redsConsecutivos++;

          // Tilt
          if (redsConsecutivos >= 4 && random.nextDouble() < 0.30) {
            stakeAtual = stakeBase * 2.0;
          } else if (redsConsecutivos >= 2 && random.nextDouble() < 0.15) {
            stakeAtual = stakeBase * 1.5;
          } else {
            stakeAtual = stakeBase;
          }
        }

        if (bancaMaxima > 0) {
          double drawdownAtual = ((bancaMaxima - bancaSimulada) / bancaMaxima) * 100;
          if (drawdownAtual > piorDrawdown) piorDrawdown = drawdownAtual;
        }

        if (!sofreuDrawdownSevero && bancaSimulada <= (bancaMaxima * 0.5)) {
          drawdownsSeveros++;
          sofreuDrawdownSevero = true;
        }
        if (!sofreuDrawdownModerado && bancaSimulada <= (bancaMaxima * 0.7)) {
          drawdownsModerados++;
          sofreuDrawdownModerado = true;
        }

        if (bancaSimulada <= (bancaBase * 0.05)) {
          quebrouTotal = true;
          break;
        }
      }

      if (quebrouTotal) {
        quebrasTotais++;
        bancasFinais.add(0);
      } else {
        bancasFinais.add(bancaSimulada);
      }
      pioresDrawdowns.add(piorDrawdown);
    }

    double riscoRuinaPct = (quebrasTotais / simulacoes) * 100;
    double riscoDrawdownSeveroPct = (drawdownsSeveros / simulacoes) * 100;
    double riscoDrawdownModeradoPct = (drawdownsModerados / simulacoes) * 100;

    bancasFinais.sort();
    double medianaFinal = bancasFinais[bancasFinais.length ~/ 2];
    double p10 = bancasFinais[(bancasFinais.length * 0.1).toInt()];
    double p90 = bancasFinais[(bancasFinais.length * 0.9).toInt()];
    pioresDrawdowns.sort((a, b) => b.compareTo(a));
    double drawdownMedio = pioresDrawdowns.isNotEmpty
        ? pioresDrawdowns.reduce((a, b) => a + b) / pioresDrawdowns.length
        : 0.0;
    double evUnitario = (wrInput/100 * (oddInput - 1)) - ((1 - wrInput/100) * 1);

    _gerarHistograma(bancasFinais, bancaBase);

    List<String> alertas = [];
    if (riscoRuinaPct > 20) alertas.add("⚠️ Risco de Ruína CRÍTICO (>20%)");
    else if (riscoRuinaPct > 5) alertas.add("🟠 Risco de Ruína Elevado (>5%)");
    if (riscoDrawdownSeveroPct > 30) alertas.add("📉 Alta prob. de perder 50% da banca");
    if (riscoDrawdownModeradoPct > 60) alertas.add("🔥 Prepare o psicológico: Drawdowns de 30% são quase certos.");

    if (evUnitario < 0) alertas.add("⛔ Estratégia com EV Negativo");
    else if (evUnitario < 0.02) alertas.add("👀 EV Marginal");
    else alertas.add("✅ EV Positivo");

    setState(() {
      _detalhesRuina = {
        'ruina': riscoRuinaPct,
        'severo': riscoDrawdownSeveroPct,
        'moderado': riscoDrawdownModeradoPct,
        'mediana': medianaFinal,
        'percentil10': p10,
        'percentil90': p90,
        'drawdownMedio': drawdownMedio,
        'ev': evUnitario,
      };
      _alertasInteligentes = alertas;

      if (riscoRuinaPct <= 0.1 && riscoDrawdownSeveroPct <= 1.0) {
        _resultadoRuina = "< 0.1% (Antifrágil)";
        _corRuina = Colors.green;
      } else if (riscoRuinaPct <= 1.0) {
        _resultadoRuina = "${riscoRuinaPct.toStringAsFixed(1)}% (Sólido)";
        _corRuina = Colors.lightGreen.shade700;
      } else if (riscoRuinaPct <= 5.0) {
        _resultadoRuina = "${riscoRuinaPct.toStringAsFixed(1)}%";
        _corRuina = Colors.yellow.shade800;
      } else if (riscoRuinaPct <= 20.0) {
        _resultadoRuina = "${riscoRuinaPct.toStringAsFixed(1)}% (PERIGOSO)";
        _corRuina = Colors.orange;
      } else {
        _resultadoRuina = "${riscoRuinaPct.toStringAsFixed(1)}% (CRÍTICO)";
        _corRuina = Colors.red;
      }
    });

    if (atualizarIA) _atualizarArquivoIA();
  }

  void _gerarHistograma(List<double> dados, double base) {
    if (dados.isEmpty) return;
    double minVal = dados.first;
    double maxVal = dados.last;
    if (maxVal < 10) maxVal = 100;

    int numBuckets = 15;
    double range = maxVal - minVal;
    double bucketSize = range / numBuckets;
    if (bucketSize == 0) bucketSize = 1;

    List<int> counts = List.filled(numBuckets, 0);
    for (var val in dados) {
      int bucket = ((val - minVal) / bucketSize).floor();
      if (bucket >= numBuckets) bucket = numBuckets - 1;
      counts[bucket]++;
    }

    int maxCount = counts.reduce(max);
    List<BarChartGroupData> bars = [];

    for (int i = 0; i < numBuckets; i++) {
      double valorCentral = minVal + (i * bucketSize) + (bucketSize / 2);
      bool isLoss = valorCentral < base;
      bool isMostFrequent = counts[i] == maxCount;

      bars.add(
          BarChartGroupData(
            x: i,
            barRods: [
              BarChartRodData(
                toY: counts[i].toDouble(),
                color: isMostFrequent ? Colors.blueAccent : (isLoss ? Colors.red.withOpacity(0.6) : Colors.green.withOpacity(0.6)),
                width: 12,
                borderRadius: BorderRadius.circular(2),
              )
            ],
          )
      );
    }

    setState(() {
      _histogramaDados = bars;
      _histoMin = minVal;
      _histoMax = maxVal;
    });
  }

  // --- CÁLCULO JUROS COMPOSTOS ---
  void _calcularJuros({bool atualizarIA = true}) {
    double banca = double.tryParse(_jurosBancaCtrl.text.replaceAll(',', '.')) ?? 0;
    int meses = int.tryParse(_jurosMesesCtrl.text) ?? 0;
    double taxa = double.tryParse(_jurosTaxaCtrl.text.replaceAll(',', '.')) ?? 0;
    double aporte = double.tryParse(_jurosAporteCtrl.text.replaceAll(',', '.')) ?? 0;

    if (banca <= 0 || meses <= 0) return;

    List<FlSpot> spots = [];
    double valorAtual = banca;
    spots.add(FlSpot(0, valorAtual));

    for (int i = 1; i <= meses; i++) {
      valorAtual += valorAtual * (taxa / 100);
      valorAtual += aporte;
      spots.add(FlSpot(i.toDouble(), valorAtual));
    }

    double calcularCenario(double taxaMult) {
      double v = banca;
      double taxaEf = taxa * taxaMult;
      for (int i = 0; i < meses; i++) {
        v += v * (taxaEf / 100);
        v += aporte;
      }
      return v;
    }

    double cenarioOtimista = calcularCenario(1.5);
    double cenarioPessimista = calcularCenario(0.5);
    double cenarioConservador = calcularCenario(0.75);

    setState(() {
      _resultadoJuros = "R\$ ${valorAtual.toStringAsFixed(2)}";
      _graficoJuros = spots;
      _cenarios = {
        'otimista': cenarioOtimista,
        'pessimista': cenarioPessimista,
        'conservador': cenarioConservador,
      };
    });

    if (atualizarIA) _atualizarArquivoIA();
  }

  // --- CÁLCULO MÉTRICAS DE VARIÂNCIA ---
  void _calcularMetricasVariancia(List<double> resultados, double bancaInicial) {
    if (resultados.length < 10) {
      setState(() {
        _sharpeRatio = 0.0;
        _maxDrawdown = 0.0;
        _classificacaoConsistencia = "Dados insuficientes";
      });
      return;
    }

    double media = resultados.reduce((a, b) => a + b) / resultados.length;
    double variancia = resultados.map((r) => pow(r - media, 2)).reduce((a, b) => a + b) / resultados.length;
    double desvio = sqrt(variancia);

    double sharpe = desvio > 0.001 ? media / desvio : 0.0;

    double pico = bancaInicial;
    double maxDD = 0.0;
    double bancaAtual = bancaInicial;

    for (var resultado in resultados) {
      bancaAtual += resultado;
      if (bancaAtual > pico) pico = bancaAtual;
      if (pico > 0) {
        double dd = ((pico - bancaAtual) / pico) * 100;
        if (dd > maxDD) maxDD = dd;
      }
    }

    String classificacao;
    if (sharpe >= 2.0) {
      classificacao = "Excelente";
    } else if (sharpe >= 1.0) {
      classificacao = "Bom";
    } else if (sharpe >= 0.5) {
      classificacao = "Moderado";
    } else {
      classificacao = "Inconsistente";
    }

    setState(() {
      _sharpeRatio = sharpe;
      _maxDrawdown = maxDD;
      _classificacaoConsistencia = classificacao;
    });
  }

  // --- MODO ZEN E DIÁRIO EMOCIONAL ---
  void _toggleZenMode() {
    setState(() {
      _zenAtivo = !_zenAtivo;
      if (_zenAtivo) {
        _zenContador = 0;
        _breathingController.forward();
        _zenTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
          if (_zenContador >= _zenDuracao) {
            timer.cancel();
            _toggleZenMode();
            _mostrarDialogoZenCompleto();
          } else {
            setState(() => _zenContador++);
          }
        });
      } else {
        _breathingController.stop();
        _breathingController.reset();
        _zenTimer?.cancel();
      }
    });
  }

  void _mostrarDialogoZenCompleto() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("✨ Sessão Concluída"),
        content: const Text("Você completou 1 minuto de respiração consciente.\n\nAgora você está mais calmo para tomar decisões racionais."),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Continuar"),
          ),
        ],
      ),
    );
  }

  Future<void> _carregarDiarioEmocional() async {
    try {
      final dir = await getApplicationDocumentsDirectory();
      final file = File("${dir.path}/diario_emocional.json");

      if (await file.exists()) {
        final content = await file.readAsString();
        if (content.isNotEmpty) {
          final List<dynamic> json = jsonDecode(content);
          setState(() {
            _registrosEmocionais = json.cast<Map<String, dynamic>>();
          });
        }
      }
    } catch (e) {
      debugPrint("Erro ao carregar diário: $e");
    }
  }

  Future<void> _salvarRegistroEmocional() async {
    if (_diarioCtrl.text.isEmpty) return;

    final registro = {
      'data': DateTime.now().toIso8601String(),
      'humor': _humorAtual,
      'texto': _diarioCtrl.text,
    };

    setState(() {
      _registrosEmocionais.insert(0, registro);
    });

    try {
      final dir = await getApplicationDocumentsDirectory();
      final file = File("${dir.path}/diario_emocional.json");
      await file.writeAsString(jsonEncode(_registrosEmocionais));

      _diarioCtrl.clear();
      await _atualizarArquivoIA();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Registro salvo com sucesso!")),
        );
      }
    } catch (e) {
      debugPrint("Erro ao salvar registro: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _zenAtivo ? Colors.blueGrey.shade900 : Colors.grey.shade100,
      appBar: _zenAtivo
          ? null
          : AppBar(
        title: const Text("🧠 Centro de Controle"),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          Stack(
            children: [
              IconButton(icon: const Icon(Icons.history), tooltip: "Histórico de Simulações", onPressed: _abrirModalHistorico),
              if (_historicoSimulacoes.isNotEmpty)
                Positioned(right: 8, top: 8, child: Container(padding: const EdgeInsets.all(2), decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle), constraints: const BoxConstraints(minWidth: 14, minHeight: 14), child: Text('${_historicoSimulacoes.length}', style: const TextStyle(color: Colors.white, fontSize: 8), textAlign: TextAlign.center)))
            ],
          ),
          IconButton(icon: const Icon(Icons.refresh), tooltip: "Recarregar", onPressed: _carregarDadosReais)
        ],
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          indicatorColor: Colors.white,
          tabs: const [
            Tab(text: "Risco", icon: Icon(Icons.warning_amber, size: 20)),
            Tab(text: "Projeção", icon: Icon(Icons.trending_up, size: 20)),
            Tab(text: "Performance", icon: Icon(Icons.analytics, size: 20)),
            Tab(text: "Zen", icon: Icon(Icons.self_improvement, size: 20)),
            Tab(text: "Diário", icon: Icon(Icons.book, size: 20)),
          ],
        ),
      ),
      body: _zenAtivo ? _buildZenModeOverlay() : TabBarView(
        controller: _tabController,
        children: [
          _buildAbaRuina(),
          _buildAbaJuros(),
          _buildAbaPerformance(),
          _buildAbaZenIntro(),
          _buildAbaDiario(),
        ],
      ),
    );
  }

  // --- MODAL HISTÓRICO ---
  void _abrirModalHistorico() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        minChildSize: 0.4,
        maxChildSize: 0.9,
        expand: false,
        builder: (_, scrollController) {
          return StatefulBuilder(
            builder: (ctx, setModalState) {
              return Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text("Histórico de Simulações", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                        TextButton(onPressed: () { setState(() => _historicoSimulacoes.clear()); _salvarHistoricoSimulacoes(); setModalState((){}); }, child: const Text("Limpar", style: TextStyle(color: Colors.red)))
                      ],
                    ),
                    const Divider(),
                    Expanded(
                      child: _historicoSimulacoes.isEmpty
                          ? const Center(child: Text("Nenhuma simulação salva."))
                          : ListView.builder(
                        controller: scrollController,
                        itemCount: _historicoSimulacoes.length,
                        itemBuilder: (ctx, idx) {
                          final sim = _historicoSimulacoes[idx];
                          final params = sim['parametros'];
                          final res = sim['resultados'];
                          return Card(
                            margin: const EdgeInsets.only(bottom: 8),
                            child: ListTile(
                              dense: true,
                              title: Text("WR: ${params['winRate'].toStringAsFixed(1)}% | Odd: ${params['odd'].toStringAsFixed(2)} | Stake: ${params['stake'].toStringAsFixed(1)}%"),
                              subtitle: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(DateFormat('dd/MM HH:mm').format(DateTime.parse(sim['data']))), Text(sim['textoRisco'], style: TextStyle(color: (res['ruina'] < 1) ? Colors.green : Colors.red, fontWeight: FontWeight.bold))]),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(icon: const Icon(Icons.compare_arrows, color: Colors.blue), tooltip: "Comparar", onPressed: () { setState(() { _simulacaoComparacao = sim; _isComparando = true; }); Navigator.pop(context); }),
                                  IconButton(icon: const Icon(Icons.play_circle_fill, color: Colors.green), tooltip: "Aplicar", onPressed: () { setState(() { if(_modoInterativo){ _sliderWinRate = params['winRate']; _sliderOdd = params['odd']; _sliderStake = params['stake']; } else { _ruinaWinRateCtrl.text = params['winRate'].toString(); _ruinaOddCtrl.text = params['odd'].toString(); _ruinaRiscoCtrl.text = params['stake'].toString(); } }); _calcularRiscoRuina(atualizarIA: true); Navigator.pop(context); }),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    )
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  // --- ABA RISCO DE RUÍNA ---
  Widget _buildAbaRuina() {
    if (_isLoadingDados) return const Center(child: CircularProgressIndicator());

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (_alertasInteligentes.isNotEmpty)
            Container(
              margin: const EdgeInsets.only(bottom: 16),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: Colors.red.shade50, borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.red.shade200)),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: _alertasInteligentes.map((a) => Row(children: [const Icon(Icons.warning, size: 16, color: Colors.red), const SizedBox(width: 8), Expanded(child: Text(a, style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold)))])).toList()),
            ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("Parâmetros da Estratégia", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              FilterChip(label: const Text("Modo Interativo 🎛️"), selected: _modoInterativo, onSelected: (val) => setState(() => _modoInterativo = val))
            ],
          ),
          const SizedBox(height: 12),
          if (_modoInterativo) ...[
            _buildSliderControl("Win Rate", "${_sliderWinRate.toStringAsFixed(1)}%", _sliderWinRate, 1, 99, (v) => setState(() { _sliderWinRate = v; _calcularRiscoRuina(atualizarIA: false); })),
            _buildSliderControl("Odd Média", _sliderOdd.toStringAsFixed(2), _sliderOdd, 1.01, 10.0, (v) => setState(() { _sliderOdd = v; _calcularRiscoRuina(atualizarIA: false); })),
            _buildSliderControl("Stake %", "${_sliderStake.toStringAsFixed(1)}%", _sliderStake, 0.1, 20.0, (v) => setState(() { _sliderStake = v; _calcularRiscoRuina(atualizarIA: false); })),
          ] else ...[
            Row(children: [Expanded(child: _buildInput(_ruinaWinRateCtrl, "Win Rate (%)")), const SizedBox(width: 12), Expanded(child: _buildInput(_ruinaOddCtrl, "Odd Média"))]),
            const SizedBox(height: 12),
            _buildInput(_ruinaRiscoCtrl, "Stake Média (%)"),
            const SizedBox(height: 16),
            ElevatedButton.icon(onPressed: () => _calcularRiscoRuina(atualizarIA: true), icon: const Icon(Icons.play_arrow), label: const Text("SIMULAR CENÁRIOS"), style: ElevatedButton.styleFrom(backgroundColor: Colors.indigo, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 14))),
          ],
          const SizedBox(height: 24),
          if (_resultadoRuina.isNotEmpty) ...[
            Card(
              elevation: 4,
              color: _corRuina.withOpacity(0.1),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  children: [
                    const Text("Risco de Ruína (Quebra Total)", style: TextStyle(fontSize: 14, color: Colors.black54)),
                    Text(_resultadoRuina, textAlign: TextAlign.center, style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: _corRuina)),
                    if (!_modoInterativo) Padding(padding: const EdgeInsets.only(top: 8.0), child: OutlinedButton.icon(onPressed: _adicionarAoHistorico, icon: const Icon(Icons.save), label: const Text("Salvar no Histórico")))
                  ],
                ),
              ),
            ),
            if (_isComparando && _simulacaoComparacao != null) _buildCardComparacao(),
            if (_detalhesRuina.isNotEmpty) ...[
              const SizedBox(height: 16),
              const Text("📊 Distribuição de Resultados (3.000 Simulações)", style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              if (_histogramaDados.isNotEmpty)
                Column(
                  children: [
                    SizedBox(
                      height: 150,
                      child: BarChart(
                        BarChartData(
                          alignment: BarChartAlignment.spaceAround,
                          barGroups: _histogramaDados,
                          borderData: FlBorderData(show: false),
                          titlesData: FlTitlesData(show: false),
                          gridData: FlGridData(show: false),
                          barTouchData: BarTouchData(enabled: false),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    // ESCALA VISUAL GRADIENTE
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 12),
                      height: 6,
                      decoration: BoxDecoration(borderRadius: BorderRadius.circular(3), gradient: LinearGradient(colors: [Colors.red.withOpacity(0.6), Colors.green.withOpacity(0.6)], stops: const [0.1, 0.9])),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 4),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text("R\$ ${_histoMin.toStringAsFixed(0)}", style: TextStyle(fontSize: 10, color: Colors.red.shade700, fontWeight: FontWeight.bold)), Text("Prejuízo/Quebra", textAlign: TextAlign.left, style: TextStyle(fontSize: 10, color: Colors.red.shade700, fontWeight: FontWeight.bold))]),
                          Column(crossAxisAlignment: CrossAxisAlignment.end, children: [Text("R\$ ${_histoMax.toStringAsFixed(0)}", style: TextStyle(fontSize: 10, color: Colors.green.shade700, fontWeight: FontWeight.bold)), Text("Lucro Exponencial", textAlign: TextAlign.right, style: TextStyle(fontSize: 10, color: Colors.green.shade700, fontWeight: FontWeight.bold))]),
                        ],
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(mainAxisAlignment: MainAxisAlignment.center, children: [Container(width: 10, height: 10, decoration: const BoxDecoration(color: Colors.blueAccent, shape: BoxShape.circle)), const SizedBox(width: 6), const Text("Barra Azul = Cenário Mais Provável (Moda)", style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Colors.blueAccent))])
                  ],
                ),
              const SizedBox(height: 16),
              Card(child: Padding(padding: const EdgeInsets.all(16.0), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [_buildDetalheRisco("EV (Valor Esperado por aposta)", _detalhesRuina['ev'] > 0 ? "+${_detalhesRuina['ev'].toStringAsFixed(3)}" : _detalhesRuina['ev'].toStringAsFixed(3), _detalhesRuina['ev'] > 0 ? Colors.green : Colors.red), const Divider(), _buildDetalheRisco("Drawdown Severo (50%)", "${_detalhesRuina['severo'].toStringAsFixed(1)}%"), _buildDetalheRisco("Drawdown Médio Esperado", "${_detalhesRuina['drawdownMedio'].toStringAsFixed(1)}%"), const Divider(), _buildDetalheRisco("Pior Cenário (10% Piores)", "R\$ ${_detalhesRuina['percentil10'].toStringAsFixed(0)}", Colors.red.shade700), _buildDetalheRisco("Cenário Mediano", "R\$ ${_detalhesRuina['mediana'].toStringAsFixed(0)}", Colors.blue.shade800), _buildDetalheRisco("Melhor Cenário (10% Melhores)", "R\$ ${_detalhesRuina['percentil90'].toStringAsFixed(0)}", Colors.green.shade700)]))),
            ],
          ],
        ],
      ),
    );
  }

  Widget _buildSliderControl(String label, String valueLabel, double value, double min, double max, Function(double) onChanged) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text(label, style: const TextStyle(fontWeight: FontWeight.bold)), Text(valueLabel, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.indigo))]), Slider(value: value, min: min, max: max, onChanged: onChanged, activeColor: Colors.indigo)]);
  }

  Widget _buildCardComparacao() {
    final atual = _detalhesRuina;
    final comp = _simulacaoComparacao!['resultados'];
    Widget buildDiff(String key, bool lowerIsBetter) {
      double v1 = (atual[key] as num).toDouble();
      double v2 = (comp[key] as num).toDouble();
      double diff = v1 - v2;
      Color color = Colors.grey;
      IconData icon = Icons.remove;
      if (diff != 0) {
        bool improved = lowerIsBetter ? diff < 0 : diff > 0;
        color = improved ? Colors.green : Colors.red;
        icon = improved ? Icons.arrow_downward : Icons.arrow_upward;
        if (!lowerIsBetter) icon = improved ? Icons.arrow_upward : Icons.arrow_downward;
      }
      return Row(mainAxisSize: MainAxisSize.min, children: [Text("${v1.toStringAsFixed(1)} vs ${v2.toStringAsFixed(1)}", style: const TextStyle(fontSize: 12)), const SizedBox(width: 4), Icon(icon, size: 14, color: color)]);
    }
    return Card(color: Colors.indigo.shade50, margin: const EdgeInsets.symmetric(vertical: 8), child: Padding(padding: const EdgeInsets.all(12.0), child: Column(children: [Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [const Text("🔄 Comparando com Histórico", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.indigo)), IconButton(icon: const Icon(Icons.close, size: 16), onPressed: () => setState(() => _isComparando = false))]), const Divider(), Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [Column(children: [const Text("Ruína"), buildDiff('ruina', true)]), Column(children: [const Text("Mediana"), buildDiff('mediana', false)]), Column(children: [const Text("Drawdown"), buildDiff('drawdownMedio', true)])])])));
  }

  Widget _buildDetalheRisco(String label, String valor, [Color? corValor]) {
    return Padding(padding: const EdgeInsets.symmetric(vertical: 6.0), child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text(label, style: const TextStyle(fontSize: 13)), Text(valor, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: corValor))]));
  }

  Widget _buildCenario(String nome, double valor, Color cor) {
    return Padding(padding: const EdgeInsets.symmetric(vertical: 6.0), child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text(nome, style: TextStyle(fontSize: 13, color: cor)), Text("R\$ ${valor.toStringAsFixed(2)}", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: cor))]));
  }

  // --- ABA PERFORMANCE (REINTEGRADA) ---
  Widget _buildAbaPerformance() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        const Text("Análise de Performance", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
        const SizedBox(height: 8),
        const Text("Métricas avançadas do seu histórico", textAlign: TextAlign.center, style: TextStyle(color: Colors.grey, fontSize: 13)),
        const SizedBox(height: 24),
        Card(child: Padding(padding: const EdgeInsets.all(16.0), child: Column(children: [_buildMetrica("Sharpe Ratio", _sharpeRatio.toStringAsFixed(2), _getCorSharpe()), const Divider(), _buildMetrica("Max Drawdown", "${_maxDrawdown.toStringAsFixed(1)}%", _getCorDrawdown()), const Divider(), _buildMetrica("Consistência", _classificacaoConsistencia, _getCorConsistencia())]))),
        const SizedBox(height: 16),
        Card(color: Colors.blue.shade50, child: Padding(padding: const EdgeInsets.all(16.0), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [const Row(children: [Icon(Icons.info_outline, color: Colors.blue), SizedBox(width: 8), Text("Entendendo as Métricas", style: TextStyle(fontWeight: FontWeight.bold))]), const SizedBox(height: 12), const Text("• Sharpe Ratio: Mede retorno ajustado ao risco", style: TextStyle(fontSize: 12)), const Text("  > 2.0 = Excelente | > 1.0 = Bom | < 0.5 = Ruim", style: TextStyle(fontSize: 11, color: Colors.grey)), const SizedBox(height: 8), const Text("• Max Drawdown: Maior queda do pico", style: TextStyle(fontSize: 12)), const Text("  < 20% = Ótimo | < 40% = Aceitável | > 50% = Perigoso", style: TextStyle(fontSize: 11, color: Colors.grey))]))),
        if (_ultimosResultados.length >= 10) ...[const SizedBox(height: 16), Card(child: Padding(padding: const EdgeInsets.all(16.0), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [const Text("📊 Últimos Resultados", style: TextStyle(fontWeight: FontWeight.bold)), const SizedBox(height: 12), SizedBox(height: 60, child: ListView.builder(scrollDirection: Axis.horizontal, itemCount: _ultimosResultados.length.clamp(0, 20), itemBuilder: (context, index) { final resultado = _ultimosResultados[_ultimosResultados.length - 1 - index]; final cor = resultado > 0 ? Colors.green : Colors.red; return Container(width: 40, margin: const EdgeInsets.only(right: 4), decoration: BoxDecoration(color: cor.withOpacity(0.2), border: Border.all(color: cor), borderRadius: BorderRadius.circular(4)), child: Center(child: Text(resultado > 0 ? "✓" : "✗", style: TextStyle(color: cor, fontWeight: FontWeight.bold, fontSize: 20)))); }))])))]
      ]),
    );
  }

  Widget _buildMetrica(String label, String valor, Color cor) {
    return Padding(padding: const EdgeInsets.symmetric(vertical: 8.0), child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text(label, style: const TextStyle(fontSize: 15)), Text(valor, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: cor))]));
  }

  Color _getCorSharpe() { if(_sharpeRatio >= 2.0) return Colors.green; if(_sharpeRatio >= 1.0) return Colors.lightGreen; if(_sharpeRatio >= 0.5) return Colors.orange; return Colors.red; }
  Color _getCorDrawdown() { if(_maxDrawdown < 20) return Colors.green; if(_maxDrawdown < 40) return Colors.orange; return Colors.red; }
  Color _getCorConsistencia() { if(_classificacaoConsistencia == "Excelente") return Colors.green; if(_classificacaoConsistencia == "Bom") return Colors.lightGreen; if(_classificacaoConsistencia == "Moderado") return Colors.orange; return Colors.red; }

  // --- ABA JUROS COMPOSTOS (REINTEGRADO) ---
  Widget _buildAbaJuros() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text("Projeção de Crescimento", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
          const SizedBox(height: 8),
          const Text("Considerando rentabilidade + aportes mensais", textAlign: TextAlign.center, style: TextStyle(color: Colors.grey, fontSize: 13)),
          const SizedBox(height: 16),
          Row(children: [Expanded(child: _buildInput(_jurosBancaCtrl, "Banca Atual")), const SizedBox(width: 12), Expanded(child: _buildInput(_jurosMesesCtrl, "Meses"))]),
          const SizedBox(height: 12),
          Row(children: [Expanded(child: _buildInput(_jurosTaxaCtrl, "Lucro Mensal (%)")), const SizedBox(width: 12), Expanded(child: _buildInput(_jurosAporteCtrl, "Aporte Mensal (R\$)"))]),
          const SizedBox(height: 16),
          ElevatedButton.icon(onPressed: () => _calcularJuros(atualizarIA: true), icon: const Icon(Icons.rocket_launch), label: const Text("PROJETAR"), style: ElevatedButton.styleFrom(backgroundColor: Colors.green, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 14))),
          if (_resultadoJuros.isNotEmpty) ...[
            const SizedBox(height: 24),
            Card(elevation: 4, color: Colors.green.shade50, child: Padding(padding: const EdgeInsets.all(20.0), child: Column(children: [const Text("Valor Projetado", style: TextStyle(color: Colors.green, fontSize: 14)), const SizedBox(height: 8), Text(_resultadoJuros, style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.green))]))),
            if (_cenarios.isNotEmpty) ...[
              const SizedBox(height: 16),
              Card(child: Padding(padding: const EdgeInsets.all(16.0), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [const Text("📈 Cenários (Com Aportes)", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)), const Divider(), _buildCenario("Otimista (+50%)", _cenarios['otimista']!, Colors.green), _buildCenario("Base", double.parse(_resultadoJuros.replaceAll('R\$ ', '').replaceAll(',', '')), Colors.blue), _buildCenario("Conservador (-25%)", _cenarios['conservador']!, Colors.orange), _buildCenario("Pessimista (-50%)", _cenarios['pessimista']!, Colors.red)]))),
            ],
            const SizedBox(height: 16),
            SizedBox(height: 220, child: LineChart(LineChartData(gridData: FlGridData(show: true, drawVerticalLine: false), titlesData: FlTitlesData(leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)), rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)), topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)), bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 30, getTitlesWidget: (value, meta) => Text('${value.toInt()}m', style: const TextStyle(fontSize: 10))))), borderData: FlBorderData(show: false), lineBarsData: [LineChartBarData(spots: _graficoJuros, isCurved: true, color: Colors.green, barWidth: 3, dotData: FlDotData(show: true), belowBarData: BarAreaData(show: true, color: Colors.green.withOpacity(0.2)))]))),
          ],
        ],
      ),
    );
  }

  // --- ABA ZEN INTRO (REINTEGRADO) ---
  Widget _buildAbaZenIntro() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.spa, size: 80, color: Colors.teal),
            const SizedBox(height: 24),
            const Text("Controle Emocional", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            const Text("Tomou um red pesado?\nEstá com vontade de dobrar a stake?\nRespire por 60 segundos primeiro.", textAlign: TextAlign.center, style: TextStyle(color: Colors.grey, fontSize: 16, height: 1.5)),
            const SizedBox(height: 40),
            ElevatedButton.icon(onPressed: _toggleZenMode, icon: const Icon(Icons.play_arrow), label: const Text("INICIAR (60s)"), style: ElevatedButton.styleFrom(backgroundColor: Colors.teal, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16), textStyle: const TextStyle(fontSize: 16))),
          ],
        ),
      ),
    );
  }

  // --- ABA DIÁRIO (REINTEGRADO) ---
  Widget _buildAbaDiario() {
    return Column(
      children: [
        Container(
          color: Colors.white,
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text("Como você está se sentindo?", style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              Wrap(spacing: 8, children: ["😊 Ótimo", "😐 Neutro", "😠 Frustrado", "😰 Ansioso", "😔 Pessimista"].map((humor) {
                final selecionado = _humorAtual == humor;
                return ChoiceChip(label: Text(humor), selected: selecionado, onSelected: (selected) { setState(() => _humorAtual = humor); });
              }).toList()),
              const SizedBox(height: 16),
              TextField(controller: _diarioCtrl, maxLines: 3, decoration: const InputDecoration(hintText: "O que aconteceu hoje? Como foi sua sessão?", border: OutlineInputBorder(), filled: true, fillColor: Colors.white)),
              const SizedBox(height: 12),
              ElevatedButton.icon(onPressed: _salvarRegistroEmocional, icon: const Icon(Icons.save), label: const Text("SALVAR REGISTRO"), style: ElevatedButton.styleFrom(backgroundColor: Colors.indigo, foregroundColor: Colors.white)),
            ],
          ),
        ),
        Expanded(
          child: _registrosEmocionais.isEmpty ? const Center(child: Text("Nenhum registro ainda")) : ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: _registrosEmocionais.length,
            itemBuilder: (context, index) {
              final registro = _registrosEmocionais[index];
              final data = DateTime.parse(registro['data']);
              return Card(margin: const EdgeInsets.only(bottom: 12), child: ListTile(leading: Text(registro['humor'], style: const TextStyle(fontSize: 24)), title: Text(registro['texto']), subtitle: Text("${data.day}/${data.month}/${data.year} às ${data.hour}:${data.minute.toString().padLeft(2, '0')}", style: const TextStyle(fontSize: 11))));
            },
          ),
        ),
      ],
    );
  }

  // --- OVERLAY ZEN (REINTEGRADO) ---
  Widget _buildZenModeOverlay() {
    final progresso = _zenContador / _zenDuracao;
    return Stack(
      children: [
        Positioned.fill(child: Container(color: Colors.blueGrey.shade900)),
        Center(
          child: AnimatedBuilder(
            animation: _breathingController,
            builder: (context, child) {
              final val = _breathingController.value;
              final isInhaling = _breathingController.status == AnimationStatus.forward;
              final size = 150.0 + (val * 100);

              return Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(isInhaling ? "INSPIRE..." : "EXPIRE...", style: const TextStyle(color: Colors.white70, fontSize: 28, letterSpacing: 4)),
                  const SizedBox(height: 40),
                  Container(
                    width: size, height: size,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(colors: [Colors.tealAccent.withOpacity(0.6 * val), Colors.teal.withOpacity(0.2)]),
                      boxShadow: [BoxShadow(color: Colors.tealAccent.withOpacity(0.3), blurRadius: 20 + (val * 30), spreadRadius: val * 10)],
                    ),
                    child: const Center(child: Icon(Icons.self_improvement, color: Colors.white, size: 40)),
                  ),
                  const SizedBox(height: 60),
                  Text("${_zenDuracao - _zenContador}s restantes", style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  SizedBox(width: 200, child: LinearProgressIndicator(value: progresso, backgroundColor: Colors.white24, valueColor: const AlwaysStoppedAnimation<Color>(Colors.tealAccent))),
                ],
              );
            },
          ),
        ),
        Positioned(top: 40, right: 20, child: IconButton(icon: const Icon(Icons.close, color: Colors.white, size: 30), onPressed: _toggleZenMode)),
      ],
    );
  }

  Widget _buildInput(TextEditingController ctrl, String label) {
    return TextField(
      controller: ctrl,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      ),
    );
  }
}
// ===================================================================
// FIM DO BLOCO DA TELA CENTRO DE CONTROLE (TELA 8 )
// ===================================================================


// ===================================================================
// INICIO DO BLOCO DA TELA SCOUT (TELA 9)
// ===================================================================

class TelaAcademia extends StatefulWidget {
  const TelaAcademia({super.key});

  @override
  State<TelaAcademia> createState() => _TelaAcademiaState();
}

class _TelaAcademiaState extends State<TelaAcademia> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // Dados Globais
  List<Map<String, dynamic>> _todasPartidas = [];
  List<String> _listaCampeonatos = [];
  Set<String> _campeonatosArquivados = {};
  List<Map<String, dynamic>> _registrosPoissonScout = [];

  // Estado Atual
  String? _campeonatoSelecionado;

  // Controllers de Cadastro de Jogo
  final _campCadastroCtrl = TextEditingController();
  final _mandanteCtrl = TextEditingController();
  final _visitanteCtrl = TextEditingController();

  // Stats Gols
  final _golMandanteCtrl = TextEditingController();
  final _golVisitanteCtrl = TextEditingController();
  final _xgMandanteCtrl = TextEditingController();
  final _xgVisitanteCtrl = TextEditingController();

  // Stats Extras (Novos)
  final _finMandanteCtrl = TextEditingController();
  final _finVisitanteCtrl = TextEditingController();
  final _cantosMandanteCtrl = TextEditingController();
  final _cantosVisitanteCtrl = TextEditingController();

  DateTime _dataJogo = DateTime.now();
  String? _idEmEdicao;

  // Variáveis de Análise
  String? _timeSelecionadoAnalise;
  int _filtroQtdAnalise = 10;
  String _filtroMandoAnalise = "Geral"; // Geral, Casa, Fora

  bool _carregando = true;

  static const int _janelaPoissonScout = 8;
  static const double _poissonFatorCasaPadrao = 0.0;
  static const double _poissonFatorLigaPadrao = 1.00;
  static const double _poissonSuavizacaoPadrao = 0.75;
  static const double _poissonPesoEficaciaPadrao = 0.50;
  bool _nivelEnfrentamentoAtivo = false;
  final Map<int, double> _nivelEnfrentamentoPesosAtaque = {};
  final Map<int, double> _nivelEnfrentamentoPesosDefesa = {};

  @override
  void initState() {
    super.initState();
    // 4 Abas: Jogos, Times (Monitor), Tabela, Stats
    _tabController = TabController(length: 5, vsync: this);
    _carregarDatabase();
    _carregarRegistrosPoissonScout();
    _carregarConfigNivelEnfrentamento();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _campCadastroCtrl.dispose();
    _mandanteCtrl.dispose();
    _visitanteCtrl.dispose();
    _golMandanteCtrl.dispose();
    _golVisitanteCtrl.dispose();
    _xgMandanteCtrl.dispose();
    _xgVisitanteCtrl.dispose();
    _finMandanteCtrl.dispose();
    _finVisitanteCtrl.dispose();
    _cantosMandanteCtrl.dispose();
    _cantosVisitanteCtrl.dispose();
    super.dispose();
  }

  // ---------------------------
  // Persistência
  // ---------------------------
  Future<File> _getFile() async {
    final dir = await getApplicationDocumentsDirectory();
    return File("${dir.path}/database_campeonatos_pro.json");
  }

  Future<void> _carregarDatabase() async {
    setState(() => _carregando = true);
    try {
      final file = await _getFile();
      if (await file.exists()) {
        final content = await file.readAsString();
        if (content.isNotEmpty) {
          final json = jsonDecode(content);
          final lista = List<Map<String, dynamic>>.from(json['partidas'] ?? []);
          final arquivados = Set<String>.from(json['arquivados'] ?? []);

          final Set<String> camps = {};
          for (var p in lista) {
            if (p['campeonato'] != null) camps.add(p['campeonato'].toString());
          }

          setState(() {
            _todasPartidas = lista;
            _todasPartidas.sort((a, b) => DateTime.parse(b['data']).compareTo(DateTime.parse(a['data'])));
            _listaCampeonatos = camps.toList()..sort();
            _campeonatosArquivados = arquivados;

            if (_listaCampeonatos.isNotEmpty && _campeonatoSelecionado == null) {
              _campeonatoSelecionado = _listaCampeonatos.first;
            }
          });
        }
      }
    } catch (e) {
      debugPrint("Erro load DB: $e");
    } finally {
      if (mounted) setState(() => _carregando = false);
    }
  }

  Future<File> _getPoissonScoutFile() async {
    final dir = await getApplicationDocumentsDirectory();
    return File("${dir.path}/scout_poisson_registros.json");
  }

  Future<void> _carregarRegistrosPoissonScout() async {
    try {
      final file = await _getPoissonScoutFile();
      if (await file.exists()) {
        final content = await file.readAsString();
        if (content.isNotEmpty) {
          setState(() {
            _registrosPoissonScout = (jsonDecode(content) as List).cast<Map<String, dynamic>>();
            _registrosPoissonScout.sort((a, b) => (b['data'] ?? '').compareTo(a['data'] ?? ''));
          });
        }
      }
    } catch (e) {
      debugPrint("Erro ao carregar registros Poisson Scout: $e");
    }
  }

  Future<void> _salvarRegistrosPoissonScout() async {
    try {
      final file = await _getPoissonScoutFile();
      await file.writeAsString(jsonEncode(_registrosPoissonScout));
    } catch (e) {
      debugPrint("Erro ao salvar registros Poisson Scout: $e");
    }
  }

  Future<File> _getPoissonNivelEnfrentamentoFile() async {
    final dir = await getApplicationDocumentsDirectory();
    return File("${dir.path}/poisson_nivel_enfrentamento.json");
  }

  Future<void> _carregarConfigNivelEnfrentamento() async {
    try {
      final file = await _getPoissonNivelEnfrentamentoFile();
      if (await file.exists()) {
        final data = await file.readAsString();
        if (data.isNotEmpty) {
          final json = jsonDecode(data) as Map<String, dynamic>;
          final pesosAtaque = json['pesosAtaque'] ?? json['pesos'];
          final pesosDefesa = json['pesosDefesa'];
          setState(() {
            _nivelEnfrentamentoAtivo = json['ativo'] == true;
            _nivelEnfrentamentoPesosAtaque.clear();
            _nivelEnfrentamentoPesosDefesa.clear();
            if (pesosAtaque is Map) {
              pesosAtaque.forEach((key, value) {
                final pos = int.tryParse(key.toString());
                final pct = (value as num?)?.toDouble();
                if (pos != null && pct != null) {
                  _nivelEnfrentamentoPesosAtaque[pos] = pct.clamp(0.0, 200.0);
                }
              });
            }
            if (pesosDefesa is Map) {
              pesosDefesa.forEach((key, value) {
                final pos = int.tryParse(key.toString());
                final pct = (value as num?)?.toDouble();
                if (pos != null && pct != null) {
                  _nivelEnfrentamentoPesosDefesa[pos] = pct.clamp(0.0, 200.0);
                }
              });
            } else {
              _nivelEnfrentamentoPesosAtaque.forEach((pos, atk) {
                _nivelEnfrentamentoPesosDefesa[pos] = (200.0 - atk).clamp(0.0, 200.0);
              });
            }
          });
        }
      }
    } catch (e) {
      debugPrint("Erro ao carregar nível de enfrentamento: $e");
    }
  }

  double _pesoNivelEnfrentamentoAtaque(int? posicao) {
    if (!_nivelEnfrentamentoAtivo || posicao == null || posicao <= 0) {
      return 1.0;
    }
    final pct = _nivelEnfrentamentoPesosAtaque[posicao] ?? 100.0;
    return (pct.clamp(0.0, 200.0)) / 100.0;
  }

  double _pesoNivelEnfrentamentoDefesa(int? posicao) {
    if (!_nivelEnfrentamentoAtivo || posicao == null || posicao <= 0) {
      return 1.0;
    }
    final pct = _nivelEnfrentamentoPesosDefesa[posicao] ??
        (200.0 - (_nivelEnfrentamentoPesosAtaque[posicao] ?? 100.0));
    return (pct.clamp(0.0, 200.0)) / 100.0;
  }

  Future<void> _salvarDatabase() async {
    try {
      final file = await _getFile();
      final json = {
        'partidas': _todasPartidas,
        'arquivados': _campeonatosArquivados.toList(),
      };
      await file.writeAsString(jsonEncode(json));

      final Set<String> camps = {};
      for (var p in _todasPartidas) {
        if (p['campeonato'] != null) camps.add(p['campeonato'].toString());
      }
      setState(() {
        _listaCampeonatos = camps.toList()..sort();
        if (_campeonatoSelecionado == null && _listaCampeonatos.isNotEmpty) {
          _campeonatoSelecionado = _listaCampeonatos.first;
        }
      });
    } catch (e) {
      debugPrint("Erro save DB: $e");
    }
  }

  // ---------------------------
  // Gerenciamento de Ligas
  // ---------------------------
  void _renomearCampeonato(String antigoNome) async {
    final controller = TextEditingController(text: antigoNome);
    final novoNome = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Renomear Liga"),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            labelText: "Novo nome",
            border: OutlineInputBorder(),
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Cancelar"),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, controller.text.trim()),
            child: const Text("Renomear"),
          ),
        ],
      ),
    );

    if (novoNome != null && novoNome.isNotEmpty && novoNome != antigoNome) {
      setState(() {
        for (var partida in _todasPartidas) {
          if (partida['campeonato'] == antigoNome) {
            partida['campeonato'] = novoNome;
          }
        }
        for (var registro in _registrosPoissonScout) {
          if (registro['campeonato'] == antigoNome) {
            registro['campeonato'] = novoNome;
          }
        }
        if (_campeonatosArquivados.contains(antigoNome)) {
          _campeonatosArquivados.remove(antigoNome);
          _campeonatosArquivados.add(novoNome);
        }
        if (_campeonatoSelecionado == antigoNome) {
          _campeonatoSelecionado = novoNome;
        }
      });

      await _salvarDatabase();
      await _salvarRegistrosPoissonScout();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Liga renomeada de '$antigoNome' para '$novoNome'"),
            backgroundColor: Colors.green,
          ),
        );
      }
    }
  }

  void _toggleArquivarCampeonato(String nomeCamp) {
    setState(() {
      if (_campeonatosArquivados.contains(nomeCamp)) {
        _campeonatosArquivados.remove(nomeCamp);
      } else {
        _campeonatosArquivados.add(nomeCamp);
      }
    });

    _salvarDatabase();

    final status = _campeonatosArquivados.contains(nomeCamp) ? "arquivada" : "desarquivada";
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("Liga '$nomeCamp' $status"),
        backgroundColor: Colors.blue,
      ),
    );
  }

  void _excluirCampeonato(String nomeCamp) async {
    final qtdJogos = _todasPartidas.where((p) => p['campeonato'] == nomeCamp).length;

    final confirma = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Excluir Liga"),
        content: Text(
          "Tem certeza que deseja excluir a liga '$nomeCamp'?\n\n"
              "Isso irá apagar permanentemente $qtdJogos jogo(s) registrado(s).",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text("Cancelar"),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text("Excluir", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirma == true) {
      setState(() {
        _todasPartidas.removeWhere((p) => p['campeonato'] == nomeCamp);
        _registrosPoissonScout.removeWhere((r) => r['campeonato'] == nomeCamp);
        _campeonatosArquivados.remove(nomeCamp);

        if (_campeonatoSelecionado == nomeCamp) {
          _campeonatoSelecionado = _listaCampeonatos.isNotEmpty ? _listaCampeonatos.first : null;
        }
      });

      await _salvarDatabase();
      await _salvarRegistrosPoissonScout();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Liga '$nomeCamp' excluída ($qtdJogos jogos removidos)"),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _mostrarMenuGerenciarLigas() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) => Container(
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Text(
                "Gerenciar Ligas",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            const Divider(),
            if (_listaCampeonatos.isEmpty)
              const Padding(
                padding: EdgeInsets.all(24),
                child: Text(
                  "Nenhuma liga cadastrada ainda.",
                  style: TextStyle(color: Colors.grey),
                ),
              )
            else
              Flexible(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: _listaCampeonatos.length,
                  itemBuilder: (context, index) {
                    final camp = _listaCampeonatos[index];
                    final arquivado = _campeonatosArquivados.contains(camp);
                    final qtdJogos = _todasPartidas.where((p) => p['campeonato'] == camp).length;

                    return ListTile(
                      leading: Icon(
                        arquivado ? Icons.archive : Icons.emoji_events,
                        color: arquivado ? Colors.grey : Colors.amber,
                      ),
                      title: Text(
                        camp,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: arquivado ? Colors.grey : Colors.black,
                        ),
                      ),
                      subtitle: Text("$qtdJogos jogo(s)"),
                      trailing: PopupMenuButton(
                        icon: const Icon(Icons.more_vert),
                        onSelected: (value) {
                          Navigator.pop(ctx);
                          if (value == 'rename') {
                            _renomearCampeonato(camp);
                          } else if (value == 'archive') {
                            _toggleArquivarCampeonato(camp);
                          } else if (value == 'delete') {
                            _excluirCampeonato(camp);
                          }
                        },
                        itemBuilder: (context) => [
                          const PopupMenuItem(
                            value: 'rename',
                            child: Row(
                              children: [
                                Icon(Icons.edit, size: 20),
                                SizedBox(width: 8),
                                Text("Renomear"),
                              ],
                            ),
                          ),
                          PopupMenuItem(
                            value: 'archive',
                            child: Row(
                              children: [
                                Icon(
                                  arquivado ? Icons.unarchive : Icons.archive,
                                  size: 20,
                                ),
                                const SizedBox(width: 8),
                                Text(arquivado ? "Desarquivar" : "Arquivar"),
                              ],
                            ),
                          ),
                          const PopupMenuItem(
                            value: 'delete',
                            child: Row(
                              children: [
                                Icon(Icons.delete, size: 20, color: Colors.red),
                                SizedBox(width: 8),
                                Text("Excluir", style: TextStyle(color: Colors.red)),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }

  // ---------------------------
  // Lógica de Cadastro
  // ---------------------------
  void _salvarPartida() async {
    if (_campCadastroCtrl.text.isEmpty || _mandanteCtrl.text.isEmpty || _visitanteCtrl.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Preencha Campeonato e Times.")));
      return;
    }

    final campNome = _campCadastroCtrl.text.trim();

    if (_campeonatosArquivados.contains(campNome) && _idEmEdicao == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Não é possível adicionar jogos em liga arquivada."),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    // Auto-preenchimento
    String checkZero(String v) => v.isEmpty ? "0" : v;

    // VALIDAÇÃO DE XG (Range check)
    // Parse manual para checagem, a lógica de replace é a mesma usada na hora de salvar o objeto
    double xgCasa = double.tryParse(checkZero(_xgMandanteCtrl.text).replaceAll(',', '.')) ?? 0.0;
    double xgFora = double.tryParse(checkZero(_xgVisitanteCtrl.text).replaceAll(',', '.')) ?? 0.0;

    // Verifica se está fora do range (0.05 a 5.0) e se não é zero (zero pode significar não preenchido)
    bool xgCasaSuspeito = (xgCasa > 0 && (xgCasa < 0.05 || xgCasa > 5.0));
    bool xgForaSuspeito = (xgFora > 0 && (xgFora < 0.05 || xgFora > 5.0));

    if (xgCasaSuspeito || xgForaSuspeito) {
      bool? confirm = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text("⚠️ Alerta de Valor (xG)"),
          content: Text(
              "Os valores de xG parecem fora do padrão (0,05 a 5,0).\n\n"
                  "xG Casa: ${xgCasa.toStringAsFixed(2)}\n"
                  "xG Fora: ${xgFora.toStringAsFixed(2)}\n\n"
                  "Tem certeza que deseja salvar assim?"
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text("Cancelar e Corrigir"),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(ctx, true),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: const Text("Sim, Salvar Mesmo Assim", style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      );

      if (confirm != true) return; // Cancela salvamento se usuário fechar ou negar
    }

    // Prossegue com salvamento
    final isEdicao = _idEmEdicao != null;
    final novaPartida = {
      'id': _idEmEdicao ?? DateTime.now().millisecondsSinceEpoch.toString(),
      'data': _dataJogo.toIso8601String(),
      'campeonato': campNome,
      'mandante': _mandanteCtrl.text.trim(),
      'visitante': _visitanteCtrl.text.trim(),
      'gm_casa': double.tryParse(checkZero(_golMandanteCtrl.text).replaceAll(',', '.')) ?? 0.0,
      'gm_fora': double.tryParse(checkZero(_golVisitanteCtrl.text).replaceAll(',', '.')) ?? 0.0,
      'xg_casa': xgCasa,
      'xg_fora': xgFora,
      'fin_casa': double.tryParse(checkZero(_finMandanteCtrl.text).replaceAll(',', '.')) ?? 0.0,
      'fin_fora': double.tryParse(checkZero(_finVisitanteCtrl.text).replaceAll(',', '.')) ?? 0.0,
      'cantos_casa': double.tryParse(checkZero(_cantosMandanteCtrl.text).replaceAll(',', '.')) ?? 0.0,
      'cantos_fora': double.tryParse(checkZero(_cantosVisitanteCtrl.text).replaceAll(',', '.')) ?? 0.0,
    };

    final registroPoisson = isEdicao ? null : _gerarRegistroPoissonParaPartida(novaPartida);

    setState(() {
      if (isEdicao) {
        final idx = _todasPartidas.indexWhere((p) => p['id'] == _idEmEdicao);
        if (idx != -1) _todasPartidas[idx] = novaPartida;
        _idEmEdicao = null;
        _atualizarRegistroPoissonParaEdicao(novaPartida);
      } else {
        _todasPartidas.insert(0, novaPartida);
        if (registroPoisson != null) {
          _registrosPoissonScout.insert(0, registroPoisson);
        }
      }

      if (!_listaCampeonatos.contains(novaPartida['campeonato'])) {
        _campeonatoSelecionado = novaPartida['campeonato'].toString();
      }
    });

    _limparFormulario(manterCamp: true);
    _salvarDatabase();
    if (registroPoisson != null) {
      _salvarRegistrosPoissonScout();
    }
    if (!isEdicao && registroPoisson == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text("Jogo registrado! Sem Poisson (mínimo de 8 jogos por time)."),
        backgroundColor: Colors.orange,
      ));
      return;
    }
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Jogo registrado!"), backgroundColor: Colors.green));
    }
  }

  void _carregarParaEdicao(Map<String, dynamic> p) {
    setState(() {
      _idEmEdicao = p['id'].toString();
      _dataJogo = DateTime.parse(p['data']);
      _campCadastroCtrl.text = p['campeonato'].toString();
      _mandanteCtrl.text = p['mandante'].toString();
      _visitanteCtrl.text = p['visitante'].toString();

      _golMandanteCtrl.text = (p['gm_casa'] as num).toInt().toString();
      _golVisitanteCtrl.text = (p['gm_fora'] as num).toInt().toString();
      _xgMandanteCtrl.text = (p['xg_casa'] as num).toString();
      _xgVisitanteCtrl.text = (p['xg_fora'] as num).toString();

      _finMandanteCtrl.text = (p['fin_casa'] as num?)?.toInt().toString() ?? "0";
      _finVisitanteCtrl.text = (p['fin_fora'] as num?)?.toInt().toString() ?? "0";
      _cantosMandanteCtrl.text = (p['cantos_casa'] as num?)?.toInt().toString() ?? "0";
      _cantosVisitanteCtrl.text = (p['cantos_fora'] as num?)?.toInt().toString() ?? "0";
    });
    if (_tabController.index != 0) _tabController.animateTo(0);
  }

  void _excluirPartida(String id) {
    setState(() {
      _todasPartidas.removeWhere((p) => p['id'].toString() == id);
      _registrosPoissonScout.removeWhere((r) => r['matchId'].toString() == id);
    });
    _salvarDatabase();
    _salvarRegistrosPoissonScout();
  }

  void _limparFormulario({bool manterCamp = false}) {
    if (!manterCamp) _campCadastroCtrl.clear();
    _mandanteCtrl.clear();
    _visitanteCtrl.clear();
    _golMandanteCtrl.clear();
    _golVisitanteCtrl.clear();
    _xgMandanteCtrl.clear();
    _xgVisitanteCtrl.clear();
    _finMandanteCtrl.clear();
    _finVisitanteCtrl.clear();
    _cantosMandanteCtrl.clear();
    _cantosVisitanteCtrl.clear();
    _idEmEdicao = null;
    FocusScope.of(context).unfocus();
  }

  // ---------------------------
  // Helpers de Dados
  // ---------------------------
  List<String> _getTimesDoCampeonato(String? camp) {
    if (camp == null) return [];
    final Set<String> times = {};
    for (var p in _todasPartidas) {
      if (p['campeonato'] == camp) {
        times.add(p['mandante'].toString());
        times.add(p['visitante'].toString());
      }
    }
    return times.toList()..sort();
  }

  List<Map<String, dynamic>> _getPartidasDoCampeonato(String? camp) {
    if (camp == null) return [];
    return _todasPartidas.where((p) => p['campeonato'] == camp).toList();
  }

  List<Map<String, dynamic>> _getUltimosJogosTime({
    required String campeonato,
    required String time,
    required bool mandante,
    int limite = _janelaPoissonScout,
  }) {
    final jogos = _todasPartidas
        .where((p) => p['campeonato'] == campeonato && (mandante ? p['mandante'] == time : p['visitante'] == time))
        .toList();
    jogos.sort((a, b) => DateTime.parse(b['data']).compareTo(DateTime.parse(a['data'])));
    if (jogos.length > limite) {
      return jogos.sublist(0, limite);
    }
    return jogos;
  }

  Map<String, dynamic>? _gerarRegistroPoissonParaPartida(Map<String, dynamic> partida) {
    final camp = partida['campeonato']?.toString() ?? '';
    final mandante = partida['mandante']?.toString() ?? '';
    final visitante = partida['visitante']?.toString() ?? '';
    if (camp.isEmpty || mandante.isEmpty || visitante.isEmpty) return null;

    final jogosMandante = _getUltimosJogosTime(campeonato: camp, time: mandante, mandante: true, limite: _janelaPoissonScout);
    final jogosVisitante = _getUltimosJogosTime(campeonato: camp, time: visitante, mandante: false, limite: _janelaPoissonScout);

    if (jogosMandante.length < _janelaPoissonScout || jogosVisitante.length < _janelaPoissonScout) {
      return null;
    }

    final posicoesLiga = _mapaPosicoesLiga(camp);
    double somaGMandante = 0;
    double somaXGMandante = 0;
    double somaGSMandante = 0;
    double somaGMandanteRaw = 0;
    double somaXGMandanteRaw = 0;
    double somaGSMandanteRaw = 0;
    for (var p in jogosMandante) {
      final gm = (p['gm_casa'] as num).toDouble();
      final xg = (p['xg_casa'] as num).toDouble();
      final gs = (p['gm_fora'] as num).toDouble();
      final adversario = p['visitante']?.toString();
      final posicao = posicoesLiga[adversario];
      final pesoAtk = _pesoNivelEnfrentamentoAtaque(posicao);
      final pesoDef = _pesoNivelEnfrentamentoDefesa(posicao);

      somaGMandanteRaw += gm;
      somaXGMandanteRaw += xg;
      somaGSMandanteRaw += gs;

      somaGMandante += gm * pesoAtk;
      somaXGMandante += xg * pesoAtk;
      somaGSMandante += gs * pesoDef;
    }

    double somaGVisitante = 0;
    double somaXGVisitante = 0;
    double somaGSVisitante = 0;
    double somaGVisitanteRaw = 0;
    double somaXGVisitanteRaw = 0;
    double somaGSVisitanteRaw = 0;
    for (var p in jogosVisitante) {
      final gm = (p['gm_fora'] as num).toDouble();
      final xg = (p['xg_fora'] as num).toDouble();
      final gs = (p['gm_casa'] as num).toDouble();
      final adversario = p['mandante']?.toString();
      final posicao = posicoesLiga[adversario];
      final pesoAtk = _pesoNivelEnfrentamentoAtaque(posicao);
      final pesoDef = _pesoNivelEnfrentamentoDefesa(posicao);

      somaGVisitanteRaw += gm;
      somaXGVisitanteRaw += xg;
      somaGSVisitanteRaw += gs;

      somaGVisitante += gm * pesoAtk;
      somaXGVisitante += xg * pesoAtk;
      somaGSVisitante += gs * pesoDef;
    }

    final jogosLiga = _todasPartidas.where((p) => p['campeonato'] == camp).toList();
    double mediaLiga = 2.4;
    if (jogosLiga.isNotEmpty) {
      double totalGolsLiga = 0;
      for (var p in jogosLiga) {
        totalGolsLiga += ((p['gm_casa'] as num) + (p['gm_fora'] as num)).toDouble();
      }
      mediaLiga = totalGolsLiga / jogosLiga.length;
    }

    int contagemZero = 0;
    int contagemCaos = 0;
    final jogosParaAjuste = [...jogosMandante, ...jogosVisitante];
    for (var p in jogosParaAjuste) {
      final totalGols = ((p['gm_casa'] as num) + (p['gm_fora'] as num)).toDouble();
      if (totalGols == 0) contagemZero++;
      if (totalGols >= 6) contagemCaos++;
    }

    final ajusteZeroPassos = contagemZero ~/ 2;
    final ajusteCaosPassos = contagemCaos ~/ 2;
    final ajusteZero = (ajusteZeroPassos * 0.05).clamp(0.0, 0.30);
    final ajusteElasticidade = (ajusteCaosPassos * 0.05).clamp(0.0, 0.30);

    final resultado = _calcularPoissonScout(
      mediaLiga: mediaLiga,
      jogosMandante: _janelaPoissonScout.toDouble(),
      jogosVisitante: _janelaPoissonScout.toDouble(),
      gmMandante: somaGMandante,
      xgMandante: somaXGMandante,
      gsMandante: somaGSMandante,
      gmVisitante: somaGVisitante,
      xgVisitante: somaXGVisitante,
      gsVisitante: somaGSVisitante,
      fatorCasa: _poissonFatorCasaPadrao,
      fatorLiga: _poissonFatorLigaPadrao,
      suavizacao: _poissonSuavizacaoPadrao,
      ajusteZero: ajusteZero,
      ajusteElasticidade: ajusteElasticidade,
      pesoEficacia: _poissonPesoEficaciaPadrao,
    );

    return {
      'id': DateTime.now().millisecondsSinceEpoch.toString(),
      'matchId': partida['id'],
      'data': partida['data'],
      'campeonato': camp,
      'mandante': mandante,
      'visitante': visitante,
      'janela': _janelaPoissonScout,
      'inputs': {
        'mediaLiga': mediaLiga,
        'gmMandante': somaGMandante,
        'xgMandante': somaXGMandante,
        'gsMandante': somaGSMandante,
        'gmVisitante': somaGVisitante,
        'xgVisitante': somaXGVisitante,
        'gsVisitante': somaGSVisitante,
        'gmMandanteRaw': somaGMandanteRaw,
        'xgMandanteRaw': somaXGMandanteRaw,
        'gsMandanteRaw': somaGSMandanteRaw,
        'gmVisitanteRaw': somaGVisitanteRaw,
        'xgVisitanteRaw': somaXGVisitanteRaw,
        'gsVisitanteRaw': somaGSVisitanteRaw,
      },
      'ajustes': {
        'fatorCasa': _poissonFatorCasaPadrao,
        'fatorLiga': _poissonFatorLigaPadrao,
        'suavizacao': _poissonSuavizacaoPadrao,
        'ajusteZero': ajusteZero,
        'ajusteElasticidade': ajusteElasticidade,
        'pesoEficacia': _poissonPesoEficaciaPadrao,
      },
      'resultados': resultado,
      'resultadoReal': {
        'gm_casa': (partida['gm_casa'] as num).toDouble(),
        'gm_fora': (partida['gm_fora'] as num).toDouble(),
      },
    };
  }

  void _atualizarRegistroPoissonParaEdicao(Map<String, dynamic> partida) {
    final idx = _registrosPoissonScout.indexWhere((r) => r['matchId'].toString() == partida['id'].toString());
    if (idx == -1) return;
    _registrosPoissonScout[idx]['resultadoReal'] = {
      'gm_casa': (partida['gm_casa'] as num).toDouble(),
      'gm_fora': (partida['gm_fora'] as num).toDouble(),
    };
    _registrosPoissonScout[idx]['data'] = partida['data'];
    _registrosPoissonScout[idx]['campeonato'] = partida['campeonato'];
    _registrosPoissonScout[idx]['mandante'] = partida['mandante'];
    _registrosPoissonScout[idx]['visitante'] = partida['visitante'];
    _salvarRegistrosPoissonScout();
  }

  double _fatorial(int n) { double r = 1.0; for (int i = 2; i <= n; i++) r *= i; return r; }

  double _pois(int k, double lambda) => exp(-lambda) * pow(lambda, k) / _fatorial(k);

  Map<String, dynamic> _calcularProbabilidadesDeGols(Map<String, double> placares, double somaTotal) {
    double pOver15 = 0; double pOver25 = 0; double pOver35 = 0; double pOver45 = 0; double pBTTS_Sim = 0;

    placares.forEach((placar, prob) {
      final parts = placar.split(' x ');
      final hg = int.parse(parts[0]); final ag = int.parse(parts[1]);
      final total = hg + ag;

      if (total > 1.5) pOver15 += prob;
      if (total > 2.5) pOver25 += prob;
      if (total > 3.5) pOver35 += prob;
      if (total > 4.5) pOver45 += prob;
      if (hg > 0 && ag > 0) pBTTS_Sim += prob;
    });

    Map<String, dynamic> item(double p) {
      double prob = p / somaTotal;
      double odd = prob > 0 ? 1.0 / prob : 0.0;
      return {'prob': prob, 'oddJusta': odd};
    }

    return {
      'Over 1.5': item(pOver15),
      'Under 1.5': item(somaTotal - pOver15),
      'Over 2.5': item(pOver25),
      'Under 2.5': item(somaTotal - pOver25),
      'Over 3.5': item(pOver35),
      'Under 3.5': item(somaTotal - pOver35),
      'Over 4.5': item(pOver45),
      'Under 4.5': item(somaTotal - pOver45),
      'Ambos Marcam (Sim)': item(pBTTS_Sim),
      'Ambos Marcam (Não)': item(somaTotal - pBTTS_Sim),
    };
  }

  Map<String, dynamic> _calcularPoissonScout({
    required double mediaLiga,
    required double jogosMandante,
    required double jogosVisitante,
    required double gmMandante,
    required double xgMandante,
    required double gsMandante,
    required double gmVisitante,
    required double xgVisitante,
    required double gsVisitante,
    required double fatorCasa,
    required double fatorLiga,
    required double suavizacao,
    required double ajusteZero,
    required double ajusteElasticidade,
    required double pesoEficacia,
  }) {
    final ligaMedia = mediaLiga;
    final nCasa = jogosMandante.clamp(1, 100).toDouble();
    final nFora = jogosVisitante.clamp(1, 100).toDouble();

    final xgCasa = xgMandante == 0 ? gmMandante : xgMandante;
    final xgFora = xgVisitante == 0 ? gmVisitante : xgVisitante;

    final mGmCasaReal = (nCasa > 0) ? (gmMandante / nCasa) : 0.0;
    final mXgCasaReal = (nCasa > 0) ? (xgCasa / nCasa) : 0.0;
    final mGmCasa = (mGmCasaReal * pesoEficacia) + (mXgCasaReal * (1.0 - pesoEficacia));

    final mGmForaReal = (nFora > 0) ? (gmVisitante / nFora) : 0.0;
    final mXgForaReal = (nFora > 0) ? (xgFora / nFora) : 0.0;
    final mGmFora = (mGmForaReal * pesoEficacia) + (mXgForaReal * (1.0 - pesoEficacia));

    final mGsCasa = (nCasa > 0) ? (gsMandante / nCasa) : 0.0;
    final mGsFora = (nFora > 0) ? (gsVisitante / nFora) : 0.0;

    final ligaPorTime = (ligaMedia / 2.0) * fatorLiga;

    final atkCasaRaw = (ligaPorTime > 0) ? (mGmCasa / ligaPorTime) : 1.0;
    final defCasaRaw = (ligaPorTime > 0) ? (mGsCasa / ligaPorTime) : 1.0;
    final atkForaRaw = (ligaPorTime > 0) ? (mGmFora / ligaPorTime) : 1.0;
    final defForaRaw = (ligaPorTime > 0) ? (mGsFora / ligaPorTime) : 1.0;

    final atkCasa = 1.0 + (atkCasaRaw - 1.0) * suavizacao;
    final defCasa = 1.0 + (defCasaRaw - 1.0) * suavizacao;
    final atkFora = 1.0 + (atkForaRaw - 1.0) * suavizacao;
    final defFora = 1.0 + (defForaRaw - 1.0) * suavizacao;

    double lambdaCasa = (ligaPorTime * atkCasa * defFora * (1 + fatorCasa)).clamp(0.05, 6.0);
    double lambdaFora = (ligaPorTime * atkFora * defCasa).clamp(0.05, 6.0);

    const maxGols = 7;
    double pH = 0, pD = 0, pA = 0;
    double bestP = -1;
    int bestHG = 0, bestAG = 0;
    final placares = <String, double>{};

    for (int hg = 0; hg <= maxGols; hg++) {
      final ph = _pois(hg, lambdaCasa);
      for (int ag = 0; ag <= maxGols; ag++) {
        final pa = _pois(ag, lambdaFora);
        final joint = ph * pa;
        placares["$hg x $ag"] = joint;
      }
    }

    if (ajusteZero > 0.0) {
      final p00Antigo = placares["0 x 0"] ?? 0.0;
      double boost = ajusteZero;

      if (p00Antigo + boost > 0.95) boost = 0.95 - p00Antigo;

      final doadores = placares.keys.where((k) {
        if (k == "0 x 0") return false;
        final parts = k.split(' x ');
        final totalGols = int.parse(parts[0]) + int.parse(parts[1]);
        return totalGols >= 2;
      }).toList();

      double somaDoadores = 0.0;
      for (var k in doadores) somaDoadores += placares[k]!;

      if (somaDoadores > boost) {
        final fatorReducao = (somaDoadores - boost) / somaDoadores;
        for (var k in doadores) {
          placares[k] = placares[k]! * fatorReducao;
        }
        placares["0 x 0"] = p00Antigo + boost;
      } else {
        double p00Novo = (p00Antigo + boost).clamp(0.0, 0.95);
        double fatorReducao = 1.0;
        if (p00Antigo < 1.0) fatorReducao = (1.0 - p00Novo) / (1.0 - p00Antigo);

        placares.forEach((key, val) {
          if (key == "0 x 0") placares[key] = p00Novo;
          else placares[key] = val * fatorReducao;
        });
      }
    }

    if (ajusteElasticidade > 0.0) {
      final boost = ajusteElasticidade;

      final receivers = placares.keys.where((k) {
        final parts = k.split(' x ');
        return (int.parse(parts[0]) + int.parse(parts[1])) >= 4;
      }).toList();

      final donors = placares.keys.where((k) {
        final parts = k.split(' x ');
        final t = int.parse(parts[0]) + int.parse(parts[1]);
        return t >= 1 && t <= 3;
      }).toList();

      double sumDonors = 0.0;
      for (var k in donors) sumDonors += placares[k]!;

      double sumReceivers = 0.0;
      for (var k in receivers) sumReceivers += placares[k]!;

      if (sumDonors > boost) {
        double factorRed = (sumDonors - boost) / sumDonors;
        for (var k in donors) placares[k] = placares[k]! * factorRed;

        if (sumReceivers > 0) {
          double factorInc = (sumReceivers + boost) / sumReceivers;
          for (var k in receivers) placares[k] = placares[k]! * factorInc;
        }
      }
    }

    placares.forEach((key, val) {
      if (val > bestP) {
        bestP = val;
        final parts = key.split(' x ');
        bestHG = int.parse(parts[0]);
        bestAG = int.parse(parts[1]);
      }
      final parts = key.split(' x ');
      final hg = int.parse(parts[0]);
      final ag = int.parse(parts[1]);
      if (hg > ag) pH += val;
      else if (hg == ag) pD += val;
      else pA += val;
    });

    final somaTotalPlacares = pH + pD + pA;
    final probCasa = pH / somaTotalPlacares;
    final probEmpate = pD / somaTotalPlacares;
    final probFora = pA / somaTotalPlacares;

    final prob1X = probCasa + probEmpate;
    final probX2 = probEmpate + probFora;
    final prob12 = probCasa + probFora;

    final probGols = _calcularProbabilidadesDeGols(placares, somaTotalPlacares);

    double eficaciaCasa = (mXgCasaReal > 0) ? (mGmCasaReal / mXgCasaReal) : 1.0;
    double eficaciaFora = (mXgForaReal > 0) ? (mGmForaReal / mXgForaReal) : 1.0;

    return {
      'lambdaCasa': lambdaCasa,
      'lambdaFora': lambdaFora,
      'pCasa': probCasa,
      'pEmpate': probEmpate,
      'pFora': probFora,
      'p1X': prob1X,
      'pX2': probX2,
      'p12': prob12,
      'placarProvavel': {'hg': bestHG, 'ag': bestAG, 'p': bestP},
      'placares': placares,
      'probGols': probGols,
      'eficacia': {'casa': eficaciaCasa, 'fora': eficaciaFora},
    };
  }

  String _resultadoPrevisto(Map<String, dynamic> registro) {
    final resultados = registro['resultados'] as Map<String, dynamic>;
    final pCasa = (resultados['pCasa'] as num).toDouble();
    final pEmpate = (resultados['pEmpate'] as num).toDouble();
    final pFora = (resultados['pFora'] as num).toDouble();
    if (pCasa >= pEmpate && pCasa >= pFora) return 'Casa';
    if (pFora >= pCasa && pFora >= pEmpate) return 'Fora';
    return 'Empate';
  }

  String _resultadoReal(Map<String, dynamic> registro) {
    final real = registro['resultadoReal'] as Map<String, dynamic>;
    final casa = (real['gm_casa'] as num).toDouble();
    final fora = (real['gm_fora'] as num).toDouble();
    if (casa > fora) return 'Casa';
    if (fora > casa) return 'Fora';
    return 'Empate';
  }

  Widget _buildAbaExpectativasPoisson() {
    final registros = _registrosPoissonScout
        .where((r) => _campeonatoSelecionado == null || r['campeonato'] == _campeonatoSelecionado)
        .toList();
    registros.sort((a, b) => (b['data'] ?? '').compareTo(a['data'] ?? ''));

    if (registros.isEmpty) {
      return const Center(child: Text("Nenhum registro Poisson encontrado para esta liga."));
    }

    int acertosResultado = 0;
    int acertosPlacar = 0;
    double somaConfiancaPrevista = 0.0;
    double somaProbReal = 0.0;
    double somaBrier = 0.0;
    double somaLogLoss = 0.0;
    double somaErroGols = 0.0;
    double somaErroPlacar = 0.0;
    for (var r in registros) {
      final resultados = r['resultados'] as Map<String, dynamic>;
      final placar = resultados['placarProvavel'] as Map<String, dynamic>;
      final real = r['resultadoReal'] as Map<String, dynamic>;
      final pCasa = (resultados['pCasa'] as num).toDouble();
      final pEmpate = (resultados['pEmpate'] as num).toDouble();
      final pFora = (resultados['pFora'] as num).toDouble();
      final realCasa = (real['gm_casa'] as num).toInt();
      final realFora = (real['gm_fora'] as num).toInt();

      if (_resultadoPrevisto(r) == _resultadoReal(r)) {
        acertosResultado++;
      }
      if ((placar['hg'] as num).toInt() == realCasa &&
          (placar['ag'] as num).toInt() == realFora) {
        acertosPlacar++;
      }

      final maiorProb = [pCasa, pEmpate, pFora].reduce(max);
      somaConfiancaPrevista += maiorProb;

      final resultadoReal = _resultadoReal(r);
      final pReal = resultadoReal == 'Casa'
          ? pCasa
          : resultadoReal == 'Fora'
          ? pFora
          : pEmpate;
      somaProbReal += pReal;
      somaLogLoss += -log(pReal.clamp(1e-6, 1.0));

      final oCasa = resultadoReal == 'Casa' ? 1.0 : 0.0;
      final oEmpate = resultadoReal == 'Empate' ? 1.0 : 0.0;
      final oFora = resultadoReal == 'Fora' ? 1.0 : 0.0;
      somaBrier += pow(pCasa - oCasa, 2) + pow(pEmpate - oEmpate, 2) + pow(pFora - oFora, 2);

      final lambdaCasa = (resultados['lambdaCasa'] as num).toDouble();
      final lambdaFora = (resultados['lambdaFora'] as num).toDouble();
      final totalEsperado = lambdaCasa + lambdaFora;
      final totalReal = realCasa + realFora;
      somaErroGols += (totalEsperado - totalReal).abs();
      somaErroPlacar += ((placar['hg'] as num).toInt() - realCasa).abs() +
          ((placar['ag'] as num).toInt() - realFora).abs();
    }

    final total = registros.length;
    final taxaAcerto = total > 0 ? (acertosResultado / total) * 100 : 0.0;
    final taxaPlacar = total > 0 ? (acertosPlacar / total) * 100 : 0.0;
    final mediaConfianca = total > 0 ? (somaConfiancaPrevista / total) * 100 : 0.0;
    final mediaProbReal = total > 0 ? (somaProbReal / total) * 100 : 0.0;
    final mediaBrier = total > 0 ? somaBrier / total : 0.0;
    final mediaLogLoss = total > 0 ? somaLogLoss / total : 0.0;
    final mediaErroGols = total > 0 ? somaErroGols / total : 0.0;
    final mediaErroPlacar = total > 0 ? somaErroPlacar / total : 0.0;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Card(
          color: Colors.indigo.shade50,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("📊 Precisão do Poisson (Últimos registros)", style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Text("Total analisado: $total jogos"),
                Text("Acerto do resultado (1X2): $acertosResultado (${taxaAcerto.toStringAsFixed(1)}%)"),
                Text("Acerto do placar exato: $acertosPlacar (${taxaPlacar.toStringAsFixed(1)}%)"),
                Text("Confiança média (maior prob.): ${mediaConfianca.toStringAsFixed(1)}%"),
                Text("Prob. média do resultado real: ${mediaProbReal.toStringAsFixed(1)}%"),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        Card(
          color: Colors.blueGrey.shade50,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("📈 Métricas de calibração", style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Text("Brier Score (1X2): ${mediaBrier.toStringAsFixed(3)}"),
                Text("Log Loss (1X2): ${mediaLogLoss.toStringAsFixed(3)}"),
                Text("Erro médio de gols (λ vs real): ${mediaErroGols.toStringAsFixed(2)}"),
                Text("Erro médio de placar (gols): ${mediaErroPlacar.toStringAsFixed(2)}"),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        ...registros.map((r) {
          final resultados = r['resultados'] as Map<String, dynamic>;
          final placar = resultados['placarProvavel'] as Map<String, dynamic>;
          final real = r['resultadoReal'] as Map<String, dynamic>;
          final inputs = r['inputs'] as Map<String, dynamic>? ?? {};
          final pCasa = (resultados['pCasa'] as num).toDouble();
          final pEmpate = (resultados['pEmpate'] as num).toDouble();
          final pFora = (resultados['pFora'] as num).toDouble();
          final lambdaCasa = (resultados['lambdaCasa'] as num).toDouble();
          final lambdaFora = (resultados['lambdaFora'] as num).toDouble();
          final previsto = _resultadoPrevisto(r);
          final realRes = _resultadoReal(r);
          final acertou = previsto == realRes;
          final maiorProb = [pCasa, pEmpate, pFora].reduce(max);
          final pReal = realRes == 'Casa'
              ? pCasa
              : realRes == 'Fora'
              ? pFora
              : pEmpate;
          final data = DateTime.parse(r['data']);
          final erroPlacar = ((placar['hg'] as num).toInt() - (real['gm_casa'] as num).toInt()).abs() +
              ((placar['ag'] as num).toInt() - (real['gm_fora'] as num).toInt()).abs();
          String resumoConsiderado(String label, String rawKey, String adjKey) {
            final raw = (inputs[rawKey] as num?)?.toDouble();
            final adj = (inputs[adjKey] as num?)?.toDouble();
            if (raw == null || adj == null) return '';
            return "$label ${raw.toStringAsFixed(1)} → ${adj.toStringAsFixed(1)}";
          }
          final resumoCasa = [
            resumoConsiderado("GM", 'gmMandanteRaw', 'gmMandante'),
            resumoConsiderado("xG", 'xgMandanteRaw', 'xgMandante'),
            resumoConsiderado("GS", 'gsMandanteRaw', 'gsMandante'),
          ].where((t) => t.isNotEmpty).join(" | ");
          final resumoFora = [
            resumoConsiderado("GM", 'gmVisitanteRaw', 'gmVisitante'),
            resumoConsiderado("xG", 'xgVisitanteRaw', 'xgVisitante'),
            resumoConsiderado("GS", 'gsVisitanteRaw', 'gsVisitante'),
          ].where((t) => t.isNotEmpty).join(" | ");

          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "${r['mandante']} x ${r['visitante']}",
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text(DateFormat('dd/MM/yyyy').format(data), style: const TextStyle(fontSize: 11, color: Colors.grey)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Chip(
                        label: Text(acertou ? "Acertou Resultado ✅" : "Errou Resultado ❌"),
                        backgroundColor: acertou ? Colors.green.shade100 : Colors.red.shade100,
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text("Probabilidades: Casa ${(pCasa * 100).toStringAsFixed(1)}% | Empate ${(pEmpate * 100).toStringAsFixed(1)}% | Fora ${(pFora * 100).toStringAsFixed(1)}%"),
                  Text("Confiança prevista: ${(maiorProb * 100).toStringAsFixed(1)}% | Prob. do real: ${(pReal * 100).toStringAsFixed(1)}%"),
                  Text("Gols esperados (λ): ${lambdaCasa.toStringAsFixed(2)} x ${lambdaFora.toStringAsFixed(2)}"),
                  if (resumoCasa.isNotEmpty || resumoFora.isNotEmpty) ...[
                    const SizedBox(height: 6),
                    Text("Nível de enfrentamento (Casa): $resumoCasa", style: const TextStyle(fontSize: 11, color: Colors.black54)),
                    Text("Nível de enfrentamento (Fora): $resumoFora", style: const TextStyle(fontSize: 11, color: Colors.black54)),
                  ],
                  const SizedBox(height: 6),
                  Text("Placar provável: ${placar['hg']} x ${placar['ag']} (p ${((placar['p'] as num) * 100).toStringAsFixed(1)}%)"),
                  Text("Placar real: ${(real['gm_casa'] as num).toInt()} x ${(real['gm_fora'] as num).toInt()}"),
                  Text("Resultado previsto: $previsto | Resultado real: $realRes", style: const TextStyle(fontSize: 12, color: Colors.black54)),
                  Text("Erro de placar (gols): $erroPlacar", style: const TextStyle(fontSize: 12, color: Colors.black54)),
                ],
              ),
            ),
          );
        }),
      ],
    );
  }

  List<String> _getCampeonatosAtivos() {
    return _listaCampeonatos.where((c) => !_campeonatosArquivados.contains(c)).toList();
  }

  // GERA A TABELA DE CLASSIFICAÇÃO
  List<Map<String, dynamic>> _gerarClassificacao(String? camp) {
    if (camp == null) return [];
    final jogos = _getPartidasDoCampeonato(camp);
    final Map<String, Map<String, dynamic>> tabela = {};

    void initTime(String t) {
      if (!tabela.containsKey(t)) {
        tabela[t] = {'time': t, 'p': 0, 'j': 0, 'v': 0, 'e': 0, 'd': 0, 'gp': 0, 'gc': 0, 'sg': 0};
      }
    }

    for (var p in jogos) {
      final mand = p['mandante'].toString();
      final vis = p['visitante'].toString();
      final gm = (p['gm_casa'] as num).toInt();
      final gv = (p['gm_fora'] as num).toInt();

      initTime(mand);
      initTime(vis);

      tabela[mand]!['j']++;
      tabela[mand]!['gp'] += gm;
      tabela[mand]!['gc'] += gv;
      tabela[mand]!['sg'] += (gm - gv);

      tabela[vis]!['j']++;
      tabela[vis]!['gp'] += gv;
      tabela[vis]!['gc'] += gm;
      tabela[vis]!['sg'] += (gv - gm);

      if (gm > gv) {
        tabela[mand]!['p'] += 3;
        tabela[mand]!['v']++;
        tabela[vis]!['d']++;
      } else if (gv > gm) {
        tabela[vis]!['p'] += 3;
        tabela[vis]!['v']++;
        tabela[mand]!['d']++;
      } else {
        tabela[mand]!['p'] += 1;
        tabela[mand]!['e']++;
        tabela[vis]!['p'] += 1;
        tabela[vis]!['e']++;
      }
    }

    final lista = tabela.values.toList();
    lista.sort((a, b) {
      if (b['p'] != a['p']) return b['p'].compareTo(a['p']);
      if (b['v'] != a['v']) return b['v'].compareTo(a['v']);
      if (b['sg'] != a['sg']) return b['sg'].compareTo(a['sg']);
      return b['gp'].compareTo(a['gp']);
    });

    return lista;
  }

  Map<String, int> _mapaPosicoesLiga(String camp) {
    final classificacao = _gerarClassificacao(camp);
    final posicoes = <String, int>{};
    for (int i = 0; i < classificacao.length; i++) {
      final time = classificacao[i]['time']?.toString() ?? '';
      if (time.isNotEmpty) {
        posicoes[time] = i + 1;
      }
    }
    return posicoes;
  }

  // CALCULA STATS PARA O CARD DE POISSON
  Map<String, dynamic> _calcularStatsTime(String time, String camp) {
    var jogos = _getPartidasDoCampeonato(camp);

    if (_filtroMandoAnalise == 'Casa') jogos = jogos.where((p) => p['mandante'].toString() == time).toList();
    else if (_filtroMandoAnalise == 'Fora') jogos = jogos.where((p) => p['visitante'].toString() == time).toList();
    else jogos = jogos.where((p) => p['mandante'].toString() == time || p['visitante'].toString() == time).toList();

    if (jogos.length > _filtroQtdAnalise) jogos = jogos.sublist(0, _filtroQtdAnalise);

    if (jogos.isEmpty) return {};

    double sGM = 0, sGS = 0, sXG = 0, sXGA = 0, sFin = 0, sFinA = 0, sCan = 0, sCanA = 0;
    int over25 = 0, btts = 0, jogosZero = 0, jogosCaos = 0;

    for (var p in jogos) {
      bool souMandante = p['mandante'].toString() == time;

      double gp = souMandante ? (p['gm_casa'] as num).toDouble() : (p['gm_fora'] as num).toDouble();
      double gc = souMandante ? (p['gm_fora'] as num).toDouble() : (p['gm_casa'] as num).toDouble();
      double xgp = souMandante ? (p['xg_casa'] as num).toDouble() : (p['xg_fora'] as num).toDouble();
      double xgc = souMandante ? (p['xg_fora'] as num).toDouble() : (p['xg_casa'] as num).toDouble();

      double fin = souMandante ? (p['fin_casa'] as num?)?.toDouble() ?? 0 : (p['fin_fora'] as num?)?.toDouble() ?? 0;
      double fina = souMandante ? (p['fin_fora'] as num?)?.toDouble() ?? 0 : (p['fin_casa'] as num?)?.toDouble() ?? 0;
      double can = souMandante ? (p['cantos_casa'] as num?)?.toDouble() ?? 0 : (p['cantos_fora'] as num?)?.toDouble() ?? 0;
      double cana = souMandante ? (p['cantos_fora'] as num?)?.toDouble() ?? 0 : (p['cantos_casa'] as num?)?.toDouble() ?? 0;

      sGM += gp;
      sGS += gc;
      sXG += xgp;
      sXGA += xgc;
      sFin += fin;
      sFinA += fina;
      sCan += can;
      sCanA += cana;

      if (gp + gc > 2.5) over25++;
      if (gp > 0 && gc > 0) btts++;
      if (gp == 0 && gc == 0) jogosZero++;
      if (gp + gc >= 6) jogosCaos++;
    }

    int qtd = jogos.length;
    return {
      'jogos': qtd,
      'gm': sGM,
      'gs': sGS,
      'xg': sXG,
      'xga': sXGA,
      'gm_avg': sGM / qtd,
      'gs_avg': sGS / qtd,
      'fin_avg': sFin / qtd,
      'fina_avg': sFinA / qtd,
      'can_avg': sCan / qtd,
      'cana_avg': sCanA / qtd,
      'over25_pct': (over25 / qtd) * 100,
      'btts_pct': (btts / qtd) * 100,
      'zero_pct': (jogosZero / qtd) * 100,
      'caos_pct': (jogosCaos / qtd) * 100,
    };
  }

  // ---------------------------
  // UI Principal
  // ---------------------------
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Gestor de Campeonatos"),
        backgroundColor: Colors.indigo.shade900,
        foregroundColor: Colors.white,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          indicatorWeight: 3,
          labelStyle: const TextStyle(fontWeight: FontWeight.bold),
          tabs: const [
            Tab(text: "Jogos", icon: Icon(Icons.sports_soccer)),
            Tab(text: "Times", icon: Icon(Icons.radar)),
            Tab(text: "Tabela", icon: Icon(Icons.format_list_numbered)),
            Tab(text: "Stats", icon: Icon(Icons.analytics)),
            Tab(text: "Poisson", icon: Icon(Icons.auto_graph)),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            tooltip: "Gerenciar Ligas",
            onPressed: _mostrarMenuGerenciarLigas,
          ),
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: _campeonatoSelecionado,
                dropdownColor: Colors.indigo.shade800,
                hint: const Text("Selecione...", style: TextStyle(color: Colors.white70)),
                icon: const Icon(Icons.emoji_events, color: Colors.amber),
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                items: _listaCampeonatos.map((c) {
                  final arquivado = _campeonatosArquivados.contains(c);
                  return DropdownMenuItem(
                    value: c,
                    child: Row(
                      children: [
                        if (arquivado) ...[
                          const Icon(Icons.archive, size: 16, color: Colors.white54),
                          const SizedBox(width: 4),
                        ],
                        Text(c),
                      ],
                    ),
                  );
                }).toList(),
                onChanged: (v) {
                  setState(() {
                    _campeonatoSelecionado = v;
                    _timeSelecionadoAnalise = null;
                    _campCadastroCtrl.text = v ?? "";
                  });
                },
              ),
            ),
          )
        ],
      ),
      body: _carregando
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
        controller: _tabController,
        children: [
          _buildAbaJogos(),
          _buildAbaTimes(),
          _buildAbaTabela(),
          _buildAbaAnalise(),
          _buildAbaExpectativasPoisson(),
        ],
      ),
      floatingActionButton: _tabController.index == 0
          ? FloatingActionButton(
        onPressed: _mostrarModalCadastro,
        backgroundColor: Colors.indigo,
        child: const Icon(Icons.add),
      )
          : null,
    );
  }

  // ---------------------------
  // ABA 1: LISTA DE JOGOS
  // ---------------------------
  void _mostrarModalCadastro() {
    if (_campeonatoSelecionado != null && _campCadastroCtrl.text.isEmpty) {
      _campCadastroCtrl.text = _campeonatoSelecionado!;
    }

    final timesAtuais = _getTimesDoCampeonato(_campeonatoSelecionado ?? _campCadastroCtrl.text);
    final campeonatosDisponiveis = _getCampeonatosAtivos();

    showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
        builder: (ctx) => Padding(
          padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom, left: 16, right: 16, top: 16),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(_idEmEdicao != null ? "Editar Jogo" : "Novo Jogo", style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
                const SizedBox(height: 16),
                Autocomplete<String>(
                  optionsBuilder: (textVal) {
                    if (textVal.text.isEmpty) return campeonatosDisponiveis;
                    return campeonatosDisponiveis.where((c) => c.toLowerCase().contains(textVal.text.toLowerCase()));
                  },
                  onSelected: (s) => _campCadastroCtrl.text = s,
                  fieldViewBuilder: (ctx, ctrl, focus, onSubmit) {
                    if (ctrl.text != _campCadastroCtrl.text) ctrl.text = _campCadastroCtrl.text;
                    return TextField(
                        controller: ctrl,
                        focusNode: focus,
                        decoration: const InputDecoration(
                          labelText: "Campeonato",
                          border: OutlineInputBorder(),
                          isDense: true,
                          helperText: "Ligas arquivadas não aparecem aqui",
                          helperMaxLines: 2,
                        ),
                        onChanged: (v) => _campCadastroCtrl.text = v);
                  },
                ),
                const SizedBox(height: 12),
                InkWell(
                  onTap: () async {
                    final d = await showDatePicker(context: context, initialDate: _dataJogo, firstDate: DateTime(2020), lastDate: DateTime.now());
                    if (d != null) setState(() => _dataJogo = d);
                  },
                  child: InputDecorator(decoration: const InputDecoration(labelText: "Data", border: OutlineInputBorder(), isDense: true), child: Text(DateFormat('dd/MM/yyyy').format(_dataJogo))),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(child: _buildAutocompleteTime("Mandante", _mandanteCtrl, timesAtuais)),
                    const SizedBox(width: 8),
                    const Text("x", style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(width: 8),
                    Expanded(child: _buildAutocompleteTime("Visitante", _visitanteCtrl, timesAtuais)),
                  ],
                ),
                const SizedBox(height: 16),
                const Text("Placar & xG", style: TextStyle(fontWeight: FontWeight.bold)),
                Row(children: [
                  Expanded(child: _buildNumInput(_golMandanteCtrl, "Gols Casa")),
                  const SizedBox(width: 8),
                  // Usando o novo Input para xG com auto-vírgula
                  Expanded(child: _buildXGInput(_xgMandanteCtrl, "xG Casa")),
                  const SizedBox(width: 16),
                  // Usando o novo Input para xG com auto-vírgula
                  Expanded(child: _buildXGInput(_xgVisitanteCtrl, "xG Fora")),
                  const SizedBox(width: 8),
                  Expanded(child: _buildNumInput(_golVisitanteCtrl, "Gols Fora")),
                ]),
                const SizedBox(height: 12),
                const Text("Stats Extras (Opcional)", style: TextStyle(fontWeight: FontWeight.bold)),
                Row(children: [
                  Expanded(child: _buildNumInput(_finMandanteCtrl, "Chutes C")),
                  const SizedBox(width: 8),
                  Expanded(child: _buildNumInput(_cantosMandanteCtrl, "Cantos C")),
                  const SizedBox(width: 16),
                  Expanded(child: _buildNumInput(_cantosVisitanteCtrl, "Cantos F")),
                  const SizedBox(width: 8),
                  Expanded(child: _buildNumInput(_finVisitanteCtrl, "Chutes F")),
                ]),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    _salvarPartida();
                    Navigator.pop(ctx);
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.indigo, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 16)),
                  child: const Text("SALVAR"),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ));
  }

  // Novo Widget para Input de XG com auto-vírgula
  Widget _buildXGInput(TextEditingController ctrl, String label) {
    return TextField(
      controller: ctrl,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
        isDense: true,
      ),
      onChanged: (text) {
        // Se tem 1 caractere e é um número, adiciona a vírgula
        if (text.length == 1 && RegExp(r'^\d$').hasMatch(text)) {
          ctrl.text = '$text,';
          ctrl.selection = TextSelection.fromPosition(TextPosition(offset: ctrl.text.length));
        }
      },
    );
  }

  Widget _buildAutocompleteTime(String label, TextEditingController ctrl, List<String> sugestoes) {
    return Autocomplete<String>(
      optionsBuilder: (textVal) {
        if (textVal.text.isEmpty) return sugestoes;
        return sugestoes.where((t) => t.toLowerCase().contains(textVal.text.toLowerCase()));
      },
      onSelected: (s) => ctrl.text = s,
      fieldViewBuilder: (ctx, textCtrl, focus, onSubmit) {
        if (textCtrl.text.isEmpty && ctrl.text.isNotEmpty) textCtrl.text = ctrl.text;
        return TextField(
          controller: textCtrl,
          focusNode: focus,
          decoration: InputDecoration(labelText: label, border: const OutlineInputBorder(), isDense: true),
          onChanged: (v) => ctrl.text = v,
          textCapitalization: TextCapitalization.words,
        );
      },
    );
  }

  Widget _buildAbaJogos() {
    final jogos = _getPartidasDoCampeonato(_campeonatoSelecionado);

    if (_campeonatoSelecionado == null) return const Center(child: Text("Selecione ou crie um campeonato no topo."));

    if (_campeonatoSelecionado != null && _campeonatosArquivados.contains(_campeonatoSelecionado)) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.archive, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            Text(
              "Liga '$_campeonatoSelecionado' está arquivada",
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              "Ligas arquivadas são somente leitura",
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () => _toggleArquivarCampeonato(_campeonatoSelecionado!),
              icon: const Icon(Icons.unarchive),
              label: const Text("Desarquivar Liga"),
            ),
          ],
        ),
      );
    }

    if (jogos.isEmpty) {
      return Center(
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            const Icon(Icons.sports_soccer, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            Text("Nenhum jogo registrado em $_campeonatoSelecionado", style: const TextStyle(color: Colors.grey)),
            ElevatedButton(onPressed: _mostrarModalCadastro, child: const Text("Registrar Primeiro Jogo"))
          ]));
    }

    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: jogos.length,
      itemBuilder: (ctx, idx) {
        final p = jogos[idx];
        return Card(
          child: ListTile(
            leading: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(DateFormat('dd/MM').format(DateTime.parse(p['data'])), style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
              ],
            ),
            title: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Expanded(child: Text(p['mandante'].toString(), textAlign: TextAlign.right, style: const TextStyle(fontWeight: FontWeight.bold))),
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 8),
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(color: Colors.grey.shade200, borderRadius: BorderRadius.circular(4)),
                  child: Text("${(p['gm_casa'] as num).toInt()} x ${(p['gm_fora'] as num).toInt()}", style: const TextStyle(fontWeight: FontWeight.w900)),
                ),
                Expanded(child: Text(p['visitante'].toString(), textAlign: TextAlign.left, style: const TextStyle(fontWeight: FontWeight.bold))),
              ],
            ),
            subtitle: Center(child: Text("xG: ${p['xg_casa']} - ${p['xg_fora']}", style: const TextStyle(fontSize: 11))),
            trailing: PopupMenuButton(
                onSelected: (v) {
                  if (v == 'edit') {
                    _carregarParaEdicao(p);
                    _mostrarModalCadastro();
                  }
                  if (v == 'del') _excluirPartida(p['id'].toString());
                },
                itemBuilder: (c) => [const PopupMenuItem(value: 'edit', child: Text("Editar")), const PopupMenuItem(value: 'del', child: Text("Excluir", style: TextStyle(color: Colors.red)))]),
          ),
        );
      },
    );
  }

  // ---------------------------
  // ABA 2: MONITOR DE TIMES
  // ---------------------------
  Widget _buildAbaTimes() {
    final times = _getTimesDoCampeonato(_campeonatoSelecionado);
    if (times.isEmpty) return const Center(child: Text("Sem times neste campeonato."));

    times.sort((a, b) {
      final dtA = _getUltimaData(a);
      final dtB = _getUltimaData(b);
      return dtA.compareTo(dtB);
    });

    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: times.length,
      itemBuilder: (ctx, idx) {
        final time = times[idx];
        final ultData = _getUltimaData(time);
        final dias = DateTime.now().difference(ultData).inDays;

        Color corStatus;
        String msgStatus;
        if (dias > 7) {
          corStatus = Colors.red;
          msgStatus = "Desatualizado (+7 dias)";
        } else if (dias >= 3) {
          corStatus = Colors.amber;
          msgStatus = "Atenção ($dias dias)";
        } else {
          corStatus = Colors.green;
          msgStatus = "Atualizado";
        }

        return Card(
          elevation: 2,
          child: ListTile(
            leading: CircleAvatar(backgroundColor: corStatus.withOpacity(0.2), child: Icon(Icons.timer, color: corStatus)),
            title: Text(time, style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text("Último jogo: ${DateFormat('dd/MM/yyyy').format(ultData)}"),
            trailing: Chip(label: Text(msgStatus, style: const TextStyle(color: Colors.white, fontSize: 10)), backgroundColor: corStatus),
          ),
        );
      },
    );
  }

  DateTime _getUltimaData(String time) {
    final jogos = _todasPartidas.where((p) => p['mandante'].toString() == time || p['visitante'].toString() == time).toList();
    if (jogos.isEmpty) return DateTime(2000);
    return DateTime.parse(jogos.first['data']);
  }

  // ---------------------------
  // ABA 3: TABELA DE CLASSIFICAÇÃO
  // ---------------------------
  Widget _buildAbaTabela() {
    final classificacao = _gerarClassificacao(_campeonatoSelecionado);
    if (classificacao.isEmpty) return const Center(child: Text("Sem dados suficientes para tabela."));

    return SingleChildScrollView(
      scrollDirection: Axis.vertical,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          columnSpacing: 20,
          headingRowColor: MaterialStateProperty.all(Colors.indigo.shade50),
          columns: const [
            DataColumn(label: Text("#", style: TextStyle(fontWeight: FontWeight.bold))),
            DataColumn(label: Text("Time", style: TextStyle(fontWeight: FontWeight.bold))),
            DataColumn(label: Text("P", style: TextStyle(fontWeight: FontWeight.bold))),
            DataColumn(label: Text("J", style: TextStyle(fontWeight: FontWeight.bold))),
            DataColumn(label: Text("V", style: TextStyle(fontWeight: FontWeight.bold))),
            DataColumn(label: Text("E", style: TextStyle(fontWeight: FontWeight.bold))),
            DataColumn(label: Text("D", style: TextStyle(fontWeight: FontWeight.bold))),
            DataColumn(label: Text("SG", style: TextStyle(fontWeight: FontWeight.bold))),
          ],
          rows: List.generate(classificacao.length, (index) {
            final time = classificacao[index];
            return DataRow(cells: [
              DataCell(Text("${index + 1}º")),
              DataCell(Text(time['time'], style: const TextStyle(fontWeight: FontWeight.bold))),
              DataCell(Text("${time['p']}", style: const TextStyle(fontWeight: FontWeight.bold))),
              DataCell(Text("${time['j']}")),
              DataCell(Text("${time['v']}", style: const TextStyle(color: Colors.green))),
              DataCell(Text("${time['e']}")),
              DataCell(Text("${time['d']}", style: const TextStyle(color: Colors.red))),
              DataCell(Text("${time['sg']}")),
            ]);
          }),
        ),
      ),
    );
  }

  // ---------------------------
  // ABA 4: STATS / POISSON
  // ---------------------------
  Widget _buildAbaAnalise() {
    final times = _getTimesDoCampeonato(_campeonatoSelecionado);
    final stats = _timeSelecionadoAnalise != null ? _calcularStatsTime(_timeSelecionadoAnalise!, _campeonatoSelecionado!) : null;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.grey.shade300)),
            child: Column(
              children: [
                DropdownButtonFormField<String>(
                  value: _timeSelecionadoAnalise,
                  hint: const Text("Selecione um Time para Analisar"),
                  items: times.map((t) => DropdownMenuItem(value: t, child: Text(t))).toList(),
                  onChanged: (v) => setState(() => _timeSelecionadoAnalise = v),
                  decoration: const InputDecoration(border: OutlineInputBorder(), prefixIcon: Icon(Icons.analytics)),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: _filtroMandoAnalise,
                        items: const [DropdownMenuItem(value: 'Geral', child: Text("Geral")), DropdownMenuItem(value: 'Casa', child: Text("Em Casa")), DropdownMenuItem(value: 'Fora', child: Text("Fora"))],
                        onChanged: (v) => setState(() => _filtroMandoAnalise = v!),
                        decoration: const InputDecoration(labelText: "Filtro Local", border: OutlineInputBorder(), isDense: true),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: DropdownButtonFormField<int>(
                        value: _filtroQtdAnalise,
                        items: const [DropdownMenuItem(value: 5, child: Text("Últ. 5")), DropdownMenuItem(value: 10, child: Text("Últ. 10")), DropdownMenuItem(value: 20, child: Text("Últ. 20"))],
                        onChanged: (v) => setState(() => _filtroQtdAnalise = v!),
                        decoration: const InputDecoration(labelText: "Recorte", border: OutlineInputBorder(), isDense: true),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          if (stats != null && stats.isNotEmpty) ...[
            Container(
              decoration: BoxDecoration(gradient: LinearGradient(colors: [Colors.blue.shade900, Colors.blue.shade700]), borderRadius: BorderRadius.circular(16)),
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Text("$_timeSelecionadoAnalise (${_filtroMandoAnalise})", style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                  Text("${stats['jogos']} jogos na amostra", style: TextStyle(color: Colors.blue.shade100, fontSize: 12)),
                  const SizedBox(height: 16),

                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8)),
                    child: Column(
                      children: [
                        const Text("DADOS TOTAIS (Copie para Poisson)", style: TextStyle(fontSize: 10, color: Colors.grey, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 4),
                        SelectableText(
                          "GM: ${(stats['gm'] as num).toInt()} | xG: ${(stats['xg'] as num).toStringAsFixed(2)} | GS: ${(stats['gs'] as num).toInt()} | xGA: ${(stats['xga'] as num).toStringAsFixed(2)}",
                          style: const TextStyle(fontFamily: 'monospace', fontWeight: FontWeight.w900, fontSize: 14),
                          textAlign: TextAlign.center,
                        )
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildWhiteStat("Média Gols", stats['gm_avg']),
                      _buildWhiteStat("Média Sofridos", stats['gs_avg']),
                    ],
                  )
                ],
              ),
            ),

            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(child: _buildMetricCard("Jogos 0x0", "${(stats['zero_pct'] as num).toStringAsFixed(0)}%", Icons.block, Colors.grey)),
                const SizedBox(width: 12),
                Expanded(child: _buildMetricCard("Jogos Caos (6+)", "${(stats['caos_pct'] as num).toStringAsFixed(0)}%", Icons.flash_on, Colors.deepOrange)),
              ],
            ),
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildMiniTotal("Chutes/J", stats['fin_avg']),
                    _buildMiniTotal("Cedidos/J", stats['fina_avg']),
                    _buildMiniTotal("Cantos/J", stats['can_avg']),
                    _buildMiniTotal("Cedidos/J", stats['cana_avg']),
                  ],
                ),
              ),
            )
          ] else if (_timeSelecionadoAnalise != null) ...[
            const Center(child: Text("Sem dados para este filtro.", style: TextStyle(color: Colors.grey)))
          ]
        ],
      ),
    );
  }

  Widget _buildNumInput(TextEditingController ctrl, String label) {
    return TextField(controller: ctrl, keyboardType: const TextInputType.numberWithOptions(decimal: true), decoration: InputDecoration(labelText: label, border: const OutlineInputBorder(), isDense: true));
  }

  Widget _buildWhiteStat(String label, double val) {
    return Column(children: [Text(label, style: const TextStyle(color: Colors.white70, fontSize: 12)), Text(val.toStringAsFixed(2), style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold))]);
  }

  Widget _buildMetricCard(String title, String val, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.grey.shade200)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [Icon(icon, size: 16, color: color), const SizedBox(width: 6), Text(title, style: TextStyle(fontSize: 11, color: Colors.grey.shade700, fontWeight: FontWeight.bold))]),
        const SizedBox(height: 4),
        Text(val, style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: color))
      ]),
    );
  }

  Widget _buildMiniTotal(String label, double val) {
    return Column(children: [Text(label, style: const TextStyle(fontSize: 10, color: Colors.grey)), Text(val.toStringAsFixed(1), style: const TextStyle(fontWeight: FontWeight.bold))]);
  }
}
// ===================================================================
// FIM DO BLOCO DA TELA SCOUT ( TELA 9)
// ===================================================================

// ===================================================================
// TELA DE BACKUP E SEGURANÇA DE DADOS ( TELA 10)
// ===================================================================

class TelaGastos extends StatefulWidget {
  const TelaGastos({super.key});

  @override
  State<TelaGastos> createState() => _TelaGastosState();
}

class _TelaGastosState extends State<TelaGastos> {
  bool _processando = false;
  DateTime? _ultimaDataBackup; // Armazena a data do último backup

  @override
  void initState() {
    super.initState();
    _carregarUltimoBackup();
  }

  // ---------------------------------------------------------
  // Gerenciamento do Log de Backup
  // ---------------------------------------------------------
  Future<void> _carregarUltimoBackup() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/backup_log.json');
      if (await file.exists()) {
        final content = await file.readAsString();
        final json = jsonDecode(content);
        if (json['last_backup'] != null) {
          setState(() {
            _ultimaDataBackup = DateTime.parse(json['last_backup']);
          });
        }
      }
    } catch (e) {
      debugPrint("Erro ao carregar log de backup: $e");
    }
  }

  Future<void> _registrarBackupRealizado() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/backup_log.json');
      final now = DateTime.now();

      await file.writeAsString(jsonEncode({
        'last_backup': now.toIso8601String(),
        'version': '2.1'
      }));

      setState(() {
        _ultimaDataBackup = now;
      });
    } catch (e) {
      debugPrint("Erro ao registrar log de backup: $e");
    }
  }

  // ---------------------------------------------------------
  // Lógica de GERAÇÃO DO BACKUP (Passo 1)
  // ---------------------------------------------------------
  Future<void> _iniciarProcessoBackup() async {
    setState(() => _processando = true);
    try {
      final directory = await getApplicationDocumentsDirectory();
      final Map<String, dynamic> backupMap = {};
      int arquivosEncontrados = 0;

      // LISTAGEM DINÂMICA
      final List<FileSystemEntity> entities = await directory.list().toList();

      for (var entity in entities) {
        if (entity is File &&
            entity.path.toLowerCase().endsWith('.json') &&
            !entity.path.endsWith('backup_log.json')) {

          final String nomeArquivo = entity.uri.pathSegments.last;
          final content = await entity.readAsString();

          if (content.isNotEmpty) {
            try {
              backupMap[nomeArquivo] = jsonDecode(content);
              arquivosEncontrados++;
            } catch (e) {
              debugPrint("Arquivo ignorado: $nomeArquivo");
            }
          }
        }
      }

      if (arquivosEncontrados == 0) {
        _mostrarMsg("Nenhum arquivo de dados encontrado para salvar.", isError: true);
        setState(() => _processando = false);
        return;
      }

      // Adiciona metadados
      backupMap['metadata'] = {
        'timestamp': DateTime.now().toIso8601String(),
        'version': '2.0',
        'app': 'GestaoBancaPro',
        'file_count': arquivosEncontrados
      };

      // Cria o arquivo temporário único
      final String dataFormatada = DateFormat('yyyy-MM-dd_HH-mm').format(DateTime.now());
      final String nomeBackup = 'BACKUP_MASTER_$dataFormatada.json';
      final tempDir = await getTemporaryDirectory();
      final backupFile = File('${tempDir.path}/$nomeBackup');

      await backupFile.writeAsString(jsonEncode(backupMap));

      // Fim do processamento visual, agora vamos perguntar o destino
      setState(() => _processando = false);

      if (mounted) {
        _mostrarOpcoesDestino(backupFile, arquivosEncontrados);
      }

    } catch (e) {
      setState(() => _processando = false);
      _mostrarMsg("Erro ao gerar backup: $e", isError: true);
    }
  }

  // ---------------------------------------------------------
  // Lógica de DESTINO (Passo 2: Compartilhar ou Salvar)
  // ---------------------------------------------------------
  void _mostrarOpcoesDestino(File backupFile, int qtdArquivos) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                "Backup Gerado com Sucesso!",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text("$qtdArquivos módulos de dados prontos para salvar."),
              const SizedBox(height: 24),

              // OPÇÃO 1: COMPARTILHAR
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(color: Colors.blue.shade50, borderRadius: BorderRadius.circular(8)),
                  child: const Icon(Icons.share, color: Colors.blue),
                ),
                title: const Text("Compartilhar Arquivo"),
                subtitle: const Text("Enviar via WhatsApp, Email, Drive..."),
                onTap: () {
                  Navigator.pop(context); // Fecha o menu
                  _acaoCompartilhar(backupFile);
                },
              ),
              const Divider(),

              // OPÇÃO 2: SALVAR NO DISPOSITIVO
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(color: Colors.green.shade50, borderRadius: BorderRadius.circular(8)),
                  child: const Icon(Icons.folder_open, color: Colors.green),
                ),
                title: const Text("Salvar no Armazenamento"),
                subtitle: const Text("Escolher uma pasta no dispositivo"),
                onTap: () {
                  Navigator.pop(context); // Fecha o menu
                  _acaoSalvarLocalmente(backupFile);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _acaoCompartilhar(File backupFile) async {
    try {
      await Share.shareXFiles(
        [XFile(backupFile.path)],
        subject: "Backup GestaoBanca",
        text: "Segue backup dos dados.",
      );
      await _registrarBackupRealizado();
    } catch (e) {
      _mostrarMsg("Erro ao compartilhar: $e", isError: true);
    }
  }

  Future<void> _acaoSalvarLocalmente(File backupFile) async {
    try {
      // Abre seletor de diretório
      String? outputDirectory = await FilePicker.platform.getDirectoryPath(
        dialogTitle: "Escolha onde salvar o Backup",
      );

      if (outputDirectory != null) {
        final String novoCaminho = '$outputDirectory/${backupFile.uri.pathSegments.last}';

        try {
          // Tenta copiar o arquivo para o destino
          await backupFile.copy(novoCaminho);

          await _registrarBackupRealizado();
          _mostrarMsg("Backup salvo com sucesso em:\n$novoCaminho");
        } catch (e) {
          // Captura erro específico de permissão (comum no Android 11+)
          if (e.toString().contains('Permission denied') || e.toString().contains('OS Error: Operation not permitted')) {
            if (mounted) _mostrarAlertaPermissao();
          } else {
            rethrow; // Repassa outros erros para o catch externo
          }
        }
      } else {
        // Usuário cancelou a seleção de pasta
      }
    } catch (e) {
      _mostrarMsg("Erro ao salvar arquivo: $e", isError: true);
    }
  }

  // Novo método para explicar a restrição ao usuário de forma amigável
  void _mostrarAlertaPermissao() {
    showDialog(
      context: context,
      builder: (c) => AlertDialog(
        title: const Text("⚠️ Restrição do Sistema"),
        content: const Text(
          "O Android impediu a gravação direta nesta pasta devido às novas regras de segurança (Scoped Storage).\n\n"
              "COMO RESOLVER:\n"
              "Use a opção 'Compartilhar Arquivo' e selecione seu Gerenciador de Arquivos (Files/Arquivos) na lista. O sistema permitirá salvar por lá.",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(c),
            child: const Text("Entendi"),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------
  // Lógica de IMPORTAÇÃO (Restaurar Backup Dinâmico)
  // ---------------------------------------------------------
  Future<void> _restaurarBackup() async {
    // 1. Confirmação de segurança
    bool? confirm = await showDialog(
      context: context,
      builder: (c) => AlertDialog(
        title: const Text("⚠️ Atenção Crítica"),
        content: const Text(
          "Restaurar um backup irá SOBRESCREVER os dados atuais pelos dados do arquivo.\n\n"
              "Deseja continuar?",
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(c, false), child: const Text("Cancelar")),
          ElevatedButton(
            onPressed: () => Navigator.pop(c, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
            child: const Text("Sim, Restaurar"),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    setState(() => _processando = true);

    try {
      // 2. Selecionar arquivo
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['json'],
      );

      if (result != null && result.files.single.path != null) {
        final file = File(result.files.single.path!);
        final content = await file.readAsString();

        // 3. Validar JSON
        final Map<String, dynamic> dadosBackup = jsonDecode(content);

        // Verifica validade básica
        if (!dadosBackup.keys.any((k) => k.endsWith('.json'))) {
          throw Exception("O arquivo não parece conter dados válidos do app (nenhum .json interno encontrado).");
        }

        final directory = await getApplicationDocumentsDirectory();
        int arquivosRestaurados = 0;

        // 4. Restaurar Dinamicamente
        for (String chave in dadosBackup.keys) {
          if (chave == 'metadata') continue; // Pula metadados

          if (chave.endsWith('.json')) {
            final dadosDoArquivo = dadosBackup[chave];
            final targetFile = File('${directory.path}/$chave');

            // Escreve o conteúdo no arquivo original
            await targetFile.writeAsString(jsonEncode(dadosDoArquivo));
            arquivosRestaurados++;
            debugPrint("Arquivo restaurado: $chave");
          }
        }

        await _registrarBackupRealizado();

        _mostrarMsg("Sucesso! $arquivosRestaurados módulos restaurados. Reinicie o app.", isError: false);
      } else {
        _mostrarMsg("Seleção cancelada.");
      }
    } catch (e) {
      _mostrarMsg("Falha na restauração: $e", isError: true);
    } finally {
      setState(() => _processando = false);
    }
  }

  // ---------------------------------------------------------
  // Lógica de LIMPEZA (Reset Dinâmico)
  // ---------------------------------------------------------
  Future<void> _limparDadosGerais() async {
    bool? confirm = await showDialog(
      context: context,
      builder: (c) => AlertDialog(
        title: const Text("🔥 Apagar Tudo?"),
        content: const Text(
          "Esta ação é IRREVERSÍVEL. Ela vai deletar TODOS os arquivos JSON da pasta do app.",
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(c, false), child: const Text("Cancelar")),
          ElevatedButton(
            onPressed: () => Navigator.pop(c, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
            child: const Text("APAGAR TUDO"),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    setState(() => _processando = true);
    try {
      final directory = await getApplicationDocumentsDirectory();
      final List<FileSystemEntity> entities = await directory.list().toList();
      int apagados = 0;

      for (var entity in entities) {
        if (entity is File && entity.path.toLowerCase().endsWith('.json')) {
          await entity.delete();
          apagados++;
        }
      }

      setState(() {
        _ultimaDataBackup = null;
      });

      _mostrarMsg("Reset completo. $apagados arquivos apagados.");
    } catch (e) {
      _mostrarMsg("Erro ao limpar: $e", isError: true);
    } finally {
      setState(() => _processando = false);
    }
  }

  void _mostrarMsg(String msg, {bool isError = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: isError ? Colors.red : Colors.green,
        duration: const Duration(seconds: 4),
      ),
    );
  }

  // ---------------------------------------------------------
  // UI Principal
  // ---------------------------------------------------------
  @override
  Widget build(BuildContext context) {
    bool mostrarAlerta = false;
    int diasAtraso = 0;

    if (_ultimaDataBackup == null) {
      mostrarAlerta = true;
    } else {
      final diferenca = DateTime.now().difference(_ultimaDataBackup!);
      if (diferenca.inDays > 7) {
        mostrarAlerta = true;
        diasAtraso = diferenca.inDays;
      }
    }

    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        title: const Text('Central de Backup Universal'),
        backgroundColor: Colors.blueGrey.shade900,
        foregroundColor: Colors.white,
      ),
      body: _processando
          ? const Center(child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(),
          SizedBox(height: 16),
          Text("Processando dados...")
        ],
      ))
          : ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _buildHeader(),

          if (mostrarAlerta) ...[
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.red.shade200),
              ),
              child: Row(
                children: [
                  const Icon(Icons.warning_amber_rounded, color: Colors.red, size: 32),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _ultimaDataBackup == null
                              ? "Backup Pendente"
                              : "Backup Atrasado ($diasAtraso dias)",
                          style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.red, fontSize: 16),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          "Seus dados estão em risco. Recomendamos fazer um backup agora.",
                          style: TextStyle(color: Colors.redAccent, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],

          const SizedBox(height: 24),
          _buildActionCard(
            title: "Criar Backup Completo",
            desc: "Gera um arquivo único com todos os dados. Você poderá escolher compartilhar ou salvar no dispositivo.",
            icon: Icons.save_as, // Mudamos o ícone para representar salvamento/geração
            color: Colors.indigo,
            onTap: _iniciarProcessoBackup, // Agora chama a função que inicia o fluxo
          ),
          const SizedBox(height: 16),
          _buildActionCard(
            title: "Restaurar Backup",
            desc: "Selecione um arquivo de backup (.json) do armazenamento para recuperar seus dados.",
            icon: Icons.restore_page,
            color: Colors.teal,
            onTap: _restaurarBackup,
          ),

          const SizedBox(height: 16),
          if (_ultimaDataBackup != null)
            Center(
              child: Text(
                "Último backup realizado em: ${DateFormat('dd/MM/yyyy HH:mm').format(_ultimaDataBackup!)}",
                style: TextStyle(color: Colors.green.shade700, fontSize: 12, fontWeight: FontWeight.bold),
              ),
            ),

          const SizedBox(height: 40),
          const Text("ZONA DE PERIGO", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey, fontSize: 12)),
          const SizedBox(height: 8),
          _buildDangerZone(),

          const SizedBox(height: 40),
          const Center(
            child: Text(
              "Gestão Banca Pro v2.3\nBackup Dinâmico Ativado",
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey, fontSize: 11),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: Colors.blueGrey.withOpacity(0.1), shape: BoxShape.circle),
            child: const Icon(Icons.folder_special, size: 32, color: Colors.blueGrey),
          ),
          const SizedBox(width: 16),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Backup Universal", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                Text("Gera ou restaura dados de todo o aplicativo.", style: TextStyle(fontSize: 12, color: Colors.grey)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionCard({required String title, required String desc, required IconData icon, required Color color, required VoidCallback onTap}) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
                child: Icon(icon, color: color, size: 28),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    const SizedBox(height: 4),
                    Text(desc, style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
                  ],
                ),
              ),
              Icon(Icons.chevron_right, color: Colors.grey.shade400),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDangerZone() {
    return Card(
      color: Colors.red.shade50,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.red.withOpacity(0.2)),
      ),
      child: ListTile(
        onTap: _limparDadosGerais,
        leading: const Icon(Icons.delete_forever, color: Colors.red),
        title: const Text("Resetar Aplicativo", style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
        subtitle: const Text("Apaga TODOS os dados. Cuidado!", style: TextStyle(fontSize: 12, color: Colors.redAccent)),
      ),
    );
  }
}
// ===================================================================
// FIM DO BLOCO DA TELA DE BACKUP (TELA 10)
// ===================================================================


// INICIO DE TELAS OBSOLETAS //


// ===================================================================
// INÍCIO DO BLOCO DA TELA DE ORÇAMENTO
// ===================================================================
class TelaOrcamento extends StatefulWidget {
  const TelaOrcamento({super.key});

  @override
  State<TelaOrcamento> createState() => _TelaOrcamentoState();
}

class _TelaOrcamentoState extends State<TelaOrcamento> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // Dados de outras telas
  List<Map<String, dynamic>> _despesas = [];
  Map<String, dynamic> _dadosInvestimentos = {};

  // Dados desta tela (Orçamento)
  List<Map<String, dynamic>> _movimentos = []; // 'tipo': 'entrada' ou 'saida'

  // Estados para a aba de "Total" (Filtros)
  DateTimeRange _periodoSelecionado = DateTimeRange(
    start: DateTime(DateTime.now().year, DateTime.now().month, 1),
    end: DateTime.now(),
  );
  Set<String> _tiposMovimentoSelecionados = {'entrada', 'saida'};

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _carregarTodosOsDados();
  }

  // ---------------------------
  // Persistência JSON
  // ---------------------------
  Future<File> _getFile(String fileName) async {
    final directory = await getApplicationDocumentsDirectory();
    return File('${directory.path}/$fileName');
  }

  Future<void> _carregarTodosOsDados() async {
    try {
      // Carrega despesas (leitura)
      final gastosFile = await _getFile('gastos_data.json');
      if (await gastosFile.exists()) {
        final data = await gastosFile.readAsString();
        if(data.isNotEmpty) {
          _despesas = List<Map<String, dynamic>>.from(jsonDecode(data)['despesas'] ?? []);
        }
      }

      // Carrega movimentos de orçamento (leitura/escrita)
      final orcamentoFile = await _getFile('orcamento_data.json');
      if (await orcamentoFile.exists()) {
        final data = await orcamentoFile.readAsString();
        if(data.isNotEmpty) {
          _movimentos = List<Map<String, dynamic>>.from(jsonDecode(data) ?? []);
        }
      }

      // Carrega dados de investimentos (leitura) para os aportes
      final investimentosFile = await _getFile('investimentos_data.json');
      if (await investimentosFile.exists()) {
        final data = await investimentosFile.readAsString();
        if (data.isNotEmpty) {
          _dadosInvestimentos = jsonDecode(data);
        }
      }

      if(mounted) {
        setState(() {}); // Atualiza a UI com os dados carregados
      }
    } catch (e) {
      debugPrint("Erro ao carregar dados para o orçamento: $e");
    }
  }

  Future<void> _salvarDadosOrcamento() async {
    try {
      final file = await _getFile('orcamento_data.json');
      await file.writeAsString(jsonEncode(_movimentos));
      await _salvarResumoParaDashboard(); // Salva o resumo para o dashboard
    } catch (e) {
      debugPrint("Erro ao salvar dados do orçamento: $e");
    }
  }

  Future<void> _salvarResumoParaDashboard() async {
    try {
      final file = await _getFile('registro_orcamento.json');
      List<Map<String, dynamic>> records = [];

      if (await file.exists()) {
        final content = await file.readAsString();
        if (content.isNotEmpty) {
          records = (jsonDecode(content) as List).cast<Map<String, dynamic>>();
        }
      }

      final now = DateTime.now();
      final saldoTotal = _calcularSaldoCarteira('Vale') + _calcularSaldoCarteira('Banco') + _calcularSaldoCarteira('Dinheiro Vivo');
      final newRecord = {
        'dataAtualizacao': now.toIso8601String(),
        'saldoTotal': saldoTotal,
      };

      final isFirstHalf = now.day <= 15;

      final existingIndex = records.lastIndexWhere((r) {
        final recordDate = DateTime.parse(r['dataAtualizacao']);
        final isRecordInFirstHalf = recordDate.day <= 15;
        return recordDate.year == now.year &&
            recordDate.month == now.month &&
            isRecordInFirstHalf == isFirstHalf;
      });

      if (existingIndex != -1) {
        records[existingIndex] = newRecord;
      } else {
        records.add(newRecord);
      }

      records.sort((a, b) => DateTime.parse(a['dataAtualizacao']).compareTo(DateTime.parse(b['dataAtualizacao'])));

      await file.writeAsString(jsonEncode(records));
      debugPrint("Resumo de orçamento salvo com sucesso.");
    } catch (e) {
      debugPrint("Erro ao salvar resumo de orçamento: $e");
    }
  }

  // ---------------------------
  // Lógica de Negócio e Cálculos
  // ---------------------------
  List<Map<String, dynamic>> _getMovimentosCarteira(String nomeCarteira) {
    final List<Map<String, dynamic>> movimentosDaCarteira = [];

    // 1. Adiciona entradas e saídas manuais
    if (nomeCarteira == 'Total') {
      movimentosDaCarteira.addAll(_movimentos);
    } else {
      movimentosDaCarteira.addAll(_movimentos.where((m) => m['carteira'] == nomeCarteira));
    }


    // 2. Adiciona despesas automáticas
    List<String> metodosMapeados = [];
    if (nomeCarteira == 'Vale') metodosMapeados = ['Vale'];
    if (nomeCarteira == 'Banco') metodosMapeados = ['Crédito', 'Pix'];
    if (nomeCarteira == 'Dinheiro Vivo') metodosMapeados = ['Dinheiro'];
    if (nomeCarteira == 'Total') metodosMapeados = ['Vale', 'Crédito', 'Pix', 'Dinheiro'];


    _despesas
        .where((d) => metodosMapeados.contains(d['metodoPagamento']))
        .forEach((d) {
      movimentosDaCarteira.add({
        'id': 'despesa_${d['id']}',
        'tipo': 'saida',
        'descricao': d['descricao'],
        'valor': d['valor'],
        'data': d['data'],
        'tipoEntrada': d['categoria'], // Reutiliza o campo para mostrar a categoria do gasto
        'automatico': true,
      });
    });

    // 3. Adiciona movimentos de investimento na carteira "Banco"
    if (nomeCarteira == 'Banco' || nomeCarteira == 'Total') {
      _dadosInvestimentos.forEach((key, value) {
        final categoria = value ?? {};
        final nomeCategoriaInvestimento = key == 'futuro' ? 'Futuro' : (key == 'semUso' ? 'Sem Uso' : 'Bitcoin');

        // Aportes viram SAÍDAS
        final aportes = (categoria['aportes'] as List?)?.cast<Map<String, dynamic>>() ?? [];
        for (var aporte in aportes) {
          movimentosDaCarteira.add({
            'id': 'investimento_aporte_${aporte['data']}',
            'tipo': 'saida',
            'descricao': 'Aporte em Investimento',
            'valor': aporte['valor'],
            'data': aporte['data'],
            'tipoEntrada': 'Invest. ($nomeCategoriaInvestimento)',
            'carteira': 'Banco',
            'automatico': true,
          });
        }

        // Saques viram ENTRADAS
        final saques = (categoria['saques'] as List?)?.cast<Map<String, dynamic>>() ?? [];
        for (var saque in saques) {
          movimentosDaCarteira.add({
            'id': 'investimento_saque_${saque['data']}',
            'tipo': 'entrada',
            'descricao': 'Saque de Investimento',
            'valor': saque['valor'],
            'data': saque['data'],
            'tipoEntrada': 'Invest. ($nomeCategoriaInvestimento)',
            'carteira': 'Banco',
            'automatico': true,
          });
        }
      });
    }

    // Ordena por data
    movimentosDaCarteira.sort((a,b) => DateTime.parse(b['data']).compareTo(DateTime.parse(a['data'])));
    return movimentosDaCarteira;
  }

  double _calcularSaldoCarteira(String nomeCarteira) {
    final movimentos = _getMovimentosCarteira(nomeCarteira);
    double saldo = 0.0;
    for(var mov in movimentos) {
      if(mov['tipo'] == 'entrada') {
        saldo += (mov['valor'] as num).toDouble();
      } else {
        saldo -= (mov['valor'] as num).toDouble();
      }
    }
    return saldo;
  }

  Future<void> _excluirMovimento(String id) async {
    await _confirmarExclusao(
        "Apagar Movimento",
        "Tem a certeza que deseja apagar este registo manual?",
            () {
          setState(() {
            _movimentos.removeWhere((m) => m['id'] == id);
          });
          _salvarDadosOrcamento();
        }
    );
  }

  Future<void> _confirmarExclusao(String title, String content, VoidCallback onConfirm) async {
    final bool? confirmar = await showDialog<bool>(
      context: context,
      builder: (c) => AlertDialog(
        title: Text(title),
        content: Text(content),
        actions: [
          TextButton(onPressed: () => Navigator.pop(c, false), child: const Text("Cancelar")),
          ElevatedButton(
            onPressed: () => Navigator.pop(c, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text("Confirmar Exclusão"),
          ),
        ],
      ),
    );

    if (confirmar == true) {
      onConfirm();
    }
  }


  // ---------------------------
  // UI
  // ---------------------------
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Orçamento'),
        actions: [
          IconButton(
            icon: const Icon(Icons.sync),
            tooltip: "Atualizar Resumo para Dashboard",
            onPressed: () async {
              await _salvarResumoParaDashboard();
              if(mounted){
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Resumo para o Dashboard foi atualizado."), backgroundColor: Colors.green),
                );
              }
            },
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: "Total"),
            Tab(text: "Vale"),
            Tab(text: "Banco"),
            Tab(text: "Dinheiro Vivo"),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildAbaTotal(),
          _buildCarteiraAba("Vale", Colors.orange),
          _buildCarteiraAba("Banco", Colors.blue),
          _buildCarteiraAba("Dinheiro Vivo", Colors.green),
        ],
      ),
    );
  }

  Widget _buildCarteiraAba(String nomeCarteira, Color cor) {
    final movimentos = _getMovimentosCarteira(nomeCarteira);
    final saldo = _calcularSaldoCarteira(nomeCarteira);

    return Column(
      children: [
        Card(
          margin: const EdgeInsets.all(8),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Text("Saldo Atual em $nomeCarteira", style: const TextStyle(fontSize: 16)),
                Text("R\$ ${saldo.toStringAsFixed(2)}", style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold, color: cor)),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    ElevatedButton.icon(onPressed: () => _mostrarDialogoMovimento(nomeCarteira, 'entrada'), icon: const Icon(Icons.add), label: const Text("Entrada")),
                    ElevatedButton.icon(onPressed: () => _mostrarDialogoMovimento(nomeCarteira, 'saida'), icon: const Icon(Icons.remove), label: const Text("Saída")),
                  ],
                )
              ],
            ),
          ),
        ),
        _buildGraficoEvolucaoDiaria(movimentos, "Evolução do Saldo ($nomeCarteira)", cor),
        Expanded(
          child: ListView.builder(
            itemCount: movimentos.length,
            itemBuilder: (context, index){
              final mov = movimentos[index];
              final isEntrada = mov['tipo'] == 'entrada';
              final isAutomatico = mov['automatico'] ?? false;
              return ListTile(
                leading: Icon(
                  isEntrada ? Icons.arrow_upward : Icons.arrow_downward,
                  color: isEntrada ? Colors.green : Colors.red,
                ),
                title: Text(mov['descricao']),
                subtitle: Text("${mov['tipoEntrada'] ?? ''} • ${DateTime.parse(mov['data']).toLocal().toString().split(' ')[0]}"),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      "${isEntrada ? '+' : '-'} R\$ ${(mov['valor'] as num).toStringAsFixed(2)}",
                      style: TextStyle(color: isEntrada ? Colors.green : Colors.red, fontWeight: FontWeight.bold),
                    ),
                    if (!isAutomatico)
                      IconButton(
                        icon: const Icon(Icons.delete_outline, size: 20),
                        onPressed: () => _excluirMovimento(mov['id']),
                      ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildAbaTotal() {
    final todosMovimentos = _getMovimentosCarteira('Total');

    final movimentosFiltrados = todosMovimentos.where((m){
      final data = DateTime.parse(m['data']);
      final dentroDoPeriodo = !data.isBefore(_periodoSelecionado.start) && !data.isAfter(_periodoSelecionado.end.add(const Duration(days: 1)));
      final dentroDoTipo = _tiposMovimentoSelecionados.contains(m['tipo']);
      return dentroDoPeriodo && dentroDoTipo;
    }).toList();

    final totalEntradas = movimentosFiltrados.where((m) => m['tipo'] == 'entrada').fold(0.0, (sum, item) => sum + item['valor']);
    final totalSaidas = movimentosFiltrados.where((m) => m['tipo'] == 'saida').fold(0.0, (sum, item) => sum + item['valor']);
    final saldoPeriodo = totalEntradas - totalSaidas;

    return Column(
      children: [
        _buildGraficoEvolucaoDiaria(todosMovimentos, "Evolução do Saldo (Total)", Colors.blueGrey),
        const Divider(),
        Card(
          margin: const EdgeInsets.symmetric(horizontal: 8),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
                  _buildInfoColumn("Entradas", "R\$ ${totalEntradas.toStringAsFixed(2)}", Colors.green),
                  _buildInfoColumn("Saídas", "R\$ ${totalSaidas.toStringAsFixed(2)}", Colors.red),
                ]),
                const Divider(height: 20),
                const Text("Saldo do Período", style: TextStyle(fontSize: 16)),
                Text("R\$ ${saldoPeriodo.toStringAsFixed(2)}", style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold, color: saldoPeriodo >= 0 ? Colors.green : Colors.red)),
              ],
            ),
          ),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: movimentosFiltrados.length,
            itemBuilder: (context, index){
              final mov = movimentosFiltrados[index];
              final isEntrada = mov['tipo'] == 'entrada';
              return ListTile(
                leading: Icon(
                  isEntrada ? Icons.arrow_upward : Icons.arrow_downward,
                  color: isEntrada ? Colors.green : Colors.red,
                ),
                title: Text(mov['descricao']),
                subtitle: Text("${mov['carteira']} • ${DateTime.parse(mov['data']).toLocal().toString().split(' ')[0]}"),
                trailing: Text(
                    "${isEntrada ? '+' : '-'} R\$ ${(mov['valor'] as num).toStringAsFixed(2)}",
                    style: TextStyle(color: isEntrada ? Colors.green : Colors.red, fontWeight: FontWeight.bold)
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildGraficoEvolucaoDiaria(List<Map<String, dynamic>> movimentos, String title, Color cor) {
    final hoje = DateTime.now();
    final dataLimite = hoje.subtract(const Duration(days: 30));

    if (movimentos.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(16.0),
        child: SizedBox(
          height: 200,
          child: Center(child: Text("Sem dados para o gráfico.")),
        ),
      );
    }

    // 1. Calcula o saldo inicial, 30 dias atrás
    double saldoInicial = 0;
    movimentos.where((m) => DateTime.parse(m['data']).isBefore(dataLimite)).forEach((mov) {
      final valor = (mov['valor'] as num).toDouble();
      saldoInicial += mov['tipo'] == 'entrada' ? valor : -valor;
    });

    // 2. Agrupa os movimentos dos últimos 30 dias por dia
    final Map<DateTime, double> fluxoPorDia = {};
    movimentos.where((m) => !DateTime.parse(m['data']).isBefore(dataLimite)).forEach((mov) {
      final data = DateTime.parse(mov['data']);
      final diaNormalizado = DateTime(data.year, data.month, data.day);
      final valor = (mov['valor'] as num).toDouble();
      final valorComSinal = mov['tipo'] == 'entrada' ? valor : -valor;
      fluxoPorDia.update(diaNormalizado, (v) => v + valorComSinal, ifAbsent: () => valorComSinal);
    });

    // 3. Cria os pontos (spots) para o gráfico, acumulando o saldo
    List<FlSpot> spots = [];
    double saldoAcumulado = saldoInicial;
    for (int i = 0; i < 30; i++) {
      final diaAtual = hoje.subtract(Duration(days: 29 - i));
      final diaNormalizado = DateTime(diaAtual.year, diaAtual.month, diaAtual.day);

      saldoAcumulado += fluxoPorDia[diaNormalizado] ?? 0.0;
      spots.add(FlSpot(i.toDouble(), saldoAcumulado));
    }

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          Text(title, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 24),
          SizedBox(
            height: 200,
            child: LineChart(
              LineChartData(
                  gridData: FlGridData(show: true, drawVerticalLine: false, horizontalInterval: 50),
                  titlesData: FlTitlesData(
                    show: true,
                    topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 40)),
                    bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 22, getTitlesWidget: (value, meta) {
                      final index = value.toInt();
                      if (index % 5 == 0) {
                        final dia = hoje.subtract(Duration(days: 29 - index));
                        return Text(dia.day.toString(), style: const TextStyle(fontSize: 10));
                      }
                      return const Text('');
                    })),
                  ),
                  borderData: FlBorderData(show: false),
                  lineBarsData: [
                    LineChartBarData(
                      spots: spots,
                      isCurved: true,
                      color: cor,
                      barWidth: 3,
                      dotData: const FlDotData(show: false),
                      belowBarData: BarAreaData(
                        show: true,
                        color: cor.withOpacity(0.3),
                      ),
                    ),
                  ],
                  extraLinesData: ExtraLinesData(
                      horizontalLines: [
                        HorizontalLine(y: 0, color: Colors.grey.withOpacity(0.5), strokeWidth: 2, dashArray: [5, 5])
                      ]
                  )
              ),
            ),
          ),
        ],
      ),
    );
  }


  Widget _buildInfoColumn(String title, String value, Color color) {
    return Column(
      children: [
        Text(title, style: const TextStyle(fontSize: 14, color: Colors.grey)),
        const SizedBox(height: 4),
        Text(value, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: color)),
      ],
    );
  }


  Future<void> _mostrarDialogoMovimento(String nomeCarteira, String tipo) async {
    final descricaoCtrl = TextEditingController();
    final valorCtrl = TextEditingController();
    final tipoEntradaCtrl = TextEditingController();

    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (c) => AlertDialog(
        title: Text(tipo == 'entrada' ? "Nova Entrada" : "Nova Saída"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: descricaoCtrl, decoration: const InputDecoration(labelText: "Descrição")),
            TextField(controller: valorCtrl, decoration: const InputDecoration(labelText: "Valor (R\$)"), keyboardType: TextInputType.number),
            TextField(controller: tipoEntradaCtrl, decoration: InputDecoration(labelText: tipo == 'entrada' ? "Tipo de Entrada (ex: Salário)" : "Tipo de Saída (ex: Transferência)")),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(c), child: const Text("Cancelar")),
          ElevatedButton(
            onPressed: () {
              final valor = double.tryParse(valorCtrl.text.replaceAll(",", ".")) ?? 0.0;
              if (descricaoCtrl.text.isEmpty || valor <= 0) return;
              Navigator.pop(c, {
                'descricao': descricaoCtrl.text,
                'valor': valor,
                'tipoEntrada': tipoEntradaCtrl.text.isEmpty ? (tipo == 'saida' ? 'Saída Manual' : 'Entrada Manual') : tipoEntradaCtrl.text,
              });
            },
            child: const Text("Salvar"),
          ),
        ],
      ),
    );

    if (result != null) {
      setState(() {
        _movimentos.add({
          'id': DateTime.now().millisecondsSinceEpoch.toString(),
          'tipo': tipo,
          'descricao': result['descricao'],
          'valor': result['valor'],
          'tipoEntrada': result['tipoEntrada'],
          'carteira': nomeCarteira,
          'data': DateTime.now().toIso8601String(),
        });
      });
      _salvarDadosOrcamento();
    }
  }
}
// ===================================================================
// FIM DO BLOCO DA TELA DE ORÇAMENTO
// ===================================================================



// ===================================================================
// INÍCIO DO BLOCO DA TELA DE RECEITAS (ATUALIZADO)
// ===================================================================
class TelaReceitas extends StatefulWidget {
  const TelaReceitas({super.key});

  @override
  State<TelaReceitas> createState() => _TelaReceitasState();
}

class _TelaReceitasState extends State<TelaReceitas> {
  Future<Map<String, dynamic>>? _dadosFuturos;
  DateTime? _mesSelecionadoParaFiltro;
  List<DateTime> _mesesDisponiveis = [];

  @override
  void initState() {
    super.initState();
    _dadosFuturos = _carregarDadosDasFontes();
  }

  Future<File> _getFile(String fileName) async {
    final directory = await getApplicationDocumentsDirectory();
    return File('${directory.path}/$fileName');
  }

  Future<Map<String, dynamic>> _carregarDadosDasFontes() async {
    final Set<String> meses = {};
    final Map<String, dynamic> todosOsDados = {
      'apostas': [],
      'investimentos': {},
      'crypto': {},
      'despesas': [],
      'orcamento': [],
    };

    try {
      var file = await _getFile("apostas_data.json");
      if (await file.exists()) {
        final content = await file.readAsString();
        if (content.isNotEmpty) {
          final data = jsonDecode(content);
          todosOsDados['apostas'] = List<Map<String, dynamic>>.from(data['apostas'] ?? []);
          todosOsDados['apostas'].forEach((a) {
            final d = DateTime.parse(a['data']);
            meses.add("${d.year}-${d.month.toString().padLeft(2, '0')}");
          });
        }
      }

      file = await _getFile("investimentos_data.json");
      if (await file.exists()) {
        final content = await file.readAsString();
        if (content.isNotEmpty) {
          todosOsDados['investimentos'] = jsonDecode(content);
          (todosOsDados['investimentos'] as Map<String, dynamic>).forEach((key, value) {
            (value['historico'] as List?)?.forEach((h) {
              final d = DateTime.parse(h['data']);
              meses.add("${d.year}-${d.month.toString().padLeft(2, '0')}");
            });
          });
        }
      }

      file = await _getFile("crypto_data.json");
      if (await file.exists()) {
        final content = await file.readAsString();
        if (content.isNotEmpty) {
          todosOsDados['crypto'] = jsonDecode(content);
          (todosOsDados['crypto']['operacoes'] as List?)?.forEach((op) {
            final d = DateTime.parse(op['dataCompra']);
            meses.add("${d.year}-${d.month.toString().padLeft(2, '0')}");
          });
        }
      }

      file = await _getFile("gastos_data.json");
      if (await file.exists()) {
        final content = await file.readAsString();
        if (content.isNotEmpty) {
          todosOsDados['despesas'] = List<Map<String, dynamic>>.from(jsonDecode(content)['despesas'] ?? []);
          todosOsDados['despesas'].forEach((d) {
            final dt = DateTime.parse(d['data']);
            meses.add("${dt.year}-${dt.month.toString().padLeft(2, '0')}");
          });
        }
      }

      file = await _getFile("orcamento_data.json");
      if (await file.exists()) {
        final content = await file.readAsString();
        if (content.isNotEmpty) {
          todosOsDados['orcamento'] = (jsonDecode(content) as List).cast<Map<String, dynamic>>();
          todosOsDados['orcamento'].forEach((m) {
            final d = DateTime.parse(m['data']);
            meses.add("${d.year}-${d.month.toString().padLeft(2, '0')}");
          });
        }
      }

      _mesesDisponiveis = meses.map((m) => DateTime.parse("$m-01")).toList()..sort((a,b) => b.compareTo(a));

    } catch (e) {
      debugPrint("Erro ao carregar dados para Receitas: $e");
    }

    return todosOsDados;
  }

  Map<String, dynamic> _calcularDadosFiltrados(Map<String, dynamic> dadosBrutos) {
    double lucroApostas = 0;
    double lucroInvestimentos = 0;
    double lucroCrypto = 0;
    Map<String, double> despesasPorCategoria = {};
    Map<String, double> entradasManuaisPorTipo = {};

    final apostas = (dadosBrutos['apostas'] as List<Map<String, dynamic>>).where((a) => _mesSelecionadoParaFiltro == null || (DateTime.parse(a['data']).year == _mesSelecionadoParaFiltro!.year && DateTime.parse(a['data']).month == _mesSelecionadoParaFiltro!.month)).toList();
    lucroApostas = apostas.fold(0.0, (sum, item) => sum + (item['lucro'] as num));

    final investimentos = dadosBrutos['investimentos'] as Map<String, dynamic>;
    investimentos.forEach((key, value) {
      final categoria = value ?? {};
      final historico = (categoria['historico'] as List?)?.cast<Map<String, dynamic>>() ?? [];
      lucroInvestimentos += historico.where((h) => _mesSelecionadoParaFiltro == null || (DateTime.parse(h['data']).year == _mesSelecionadoParaFiltro!.year && DateTime.parse(h['data']).month == _mesSelecionadoParaFiltro!.month)).fold(0.0, (sum, h) => sum + (h['lucro'] as num).toDouble());
    });

    final crypto = dadosBrutos['crypto'] as Map<String, dynamic>;
    if (crypto.isNotEmpty) {
      final operacoes = List<Map<String, dynamic>>.from(crypto['operacoes'] ?? []);
      final cotacaoDolar = (crypto['config']['cotacaoDolar'] as num?)?.toDouble() ?? 1.0;
      lucroCrypto = operacoes
          .where((op) => op['status'] == 'fechada' && (_mesSelecionadoParaFiltro == null || (DateTime.parse(op['dataVenda']).year == _mesSelecionadoParaFiltro!.year && DateTime.parse(op['dataVenda']).month == _mesSelecionadoParaFiltro!.month)))
          .fold(0.0, (sum, op) => sum + (op['lucroUSD'] as num)) * cotacaoDolar;
    }

    final despesas = (dadosBrutos['despesas'] as List<Map<String, dynamic>>).where((d) => _mesSelecionadoParaFiltro == null || (DateTime.parse(d['data']).year == _mesSelecionadoParaFiltro!.year && DateTime.parse(d['data']).month == _mesSelecionadoParaFiltro!.month)).toList();
    for (var despesa in despesas) {
      final valor = (despesa['valor'] as num).toDouble();
      final categoria = despesa['categoria'] as String;
      despesasPorCategoria.update(categoria, (value) => value + valor, ifAbsent: () => valor);
    }

    final movimentos = (dadosBrutos['orcamento'] as List<Map<String, dynamic>>).where((m) => _mesSelecionadoParaFiltro == null || (DateTime.parse(m['data']).year == _mesSelecionadoParaFiltro!.year && DateTime.parse(m['data']).month == _mesSelecionadoParaFiltro!.month)).toList();
    for (var mov in movimentos) {
      if (mov['tipo'] == 'entrada') {
        final valor = (mov['valor'] as num).toDouble();
        final tipo = mov['tipoEntrada'] as String? ?? 'Outras Entradas';
        entradasManuaisPorTipo.update(tipo, (value) => value + valor, ifAbsent: () => valor);
      }
    }

    return {
      'lucroApostas': lucroApostas,
      'lucroInvestimentos': lucroInvestimentos,
      'lucroCrypto': lucroCrypto,
      'despesasPorCategoria': despesasPorCategoria,
      'entradasManuaisPorTipo': entradasManuaisPorTipo,
    };
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Análise de Fluxo de Caixa'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => setState(() => _dadosFuturos = _carregarDadosDasFontes()),
          )
        ],
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: _dadosFuturos,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError || !snapshot.hasData) {
            return const Center(child: Text("Erro ao carregar dados."));
          }

          final dadosFiltrados = _calcularDadosFiltrados(snapshot.data!);

          final lucroApostas = dadosFiltrados['lucroApostas'] as double;
          final lucroInvestimentos = dadosFiltrados['lucroInvestimentos'] as double;
          final lucroCrypto = dadosFiltrados['lucroCrypto'] as double;
          final despesasPorCategoria = dadosFiltrados['despesasPorCategoria'] as Map<String, double>;
          final entradasManuaisPorTipo = dadosFiltrados['entradasManuaisPorTipo'] as Map<String, double>;
          final totalDespesas = despesasPorCategoria.values.fold(0.0, (sum, item) => sum + item);

          final totalGanhos = lucroApostas + lucroInvestimentos + lucroCrypto + entradasManuaisPorTipo.values.fold(0.0, (sum, item) => sum + item);
          final resultadoLiquido = totalGanhos - totalDespesas;

          final Map<String, double> dadosPizzaGanhos = {};
          if(lucroApostas > 0) dadosPizzaGanhos['Apostas'] = lucroApostas;
          if(lucroInvestimentos > 0) dadosPizzaGanhos['Investimentos'] = lucroInvestimentos;
          if(lucroCrypto > 0) dadosPizzaGanhos['Crypto'] = lucroCrypto;
          entradasManuaisPorTipo.forEach((key, value) {
            if (value > 0) dadosPizzaGanhos[key] = value;
          });

          final Map<String, double> dadosPizzaPerdas = {};
          if(lucroApostas < 0) dadosPizzaPerdas['Apostas'] = -lucroApostas;
          if(lucroInvestimentos < 0) dadosPizzaPerdas['Investimentos'] = -lucroInvestimentos;
          if(lucroCrypto < 0) dadosPizzaPerdas['Crypto'] = -lucroCrypto;
          dadosPizzaPerdas.addAll(despesasPorCategoria);

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _buildFiltroMes(),
              const SizedBox(height: 16),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      const Text("Resultado Líquido do Período", style: TextStyle(fontSize: 16, color: Colors.grey)),
                      Text("R\$ ${resultadoLiquido.toStringAsFixed(2)}", style: Theme.of(context).textTheme.displaySmall?.copyWith(fontWeight: FontWeight.bold, color: resultadoLiquido >= 0 ? Colors.green : Colors.red)),
                      const SizedBox(height: 8),
                      Text("Entradas: R\$ ${totalGanhos.toStringAsFixed(2)} | Saídas: R\$ ${totalDespesas.toStringAsFixed(2)}", style: const TextStyle(fontSize: 14)),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Text("Origem das Entradas", style: Theme.of(context).textTheme.titleLarge),
              _buildGraficoPizza(dadosPizzaGanhos, "Ganhos"),
              const Divider(height: 32),
              Text("Origem das Saídas", style: Theme.of(context).textTheme.titleLarge),
              _buildGraficoPizza(dadosPizzaPerdas, "Perdas"),
            ],
          );
        },
      ),
    );
  }

  Widget _buildFiltroMes() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text("Período:", style: TextStyle(fontSize: 16)),
        const SizedBox(width: 16),
        DropdownButton<DateTime?>(
          value: _mesSelecionadoParaFiltro,
          hint: const Text("Geral"),
          items: [
            const DropdownMenuItem<DateTime?>(
              value: null,
              child: Text("Geral (Todos os Tempos)"),
            ),
            ..._mesesDisponiveis.map((mes) => DropdownMenuItem(
              value: mes,
              child: Text("${mes.month}/${mes.year}"),
            )),
          ],
          onChanged: (novoMes) {
            setState(() {
              _mesSelecionadoParaFiltro = novoMes;
            });
          },
        ),
      ],
    );
  }

  Widget _buildGraficoPizza(Map<String, double> data, String tipo) {
    if (data.isEmpty) return SizedBox(height: 250, child: Center(child: Text("Sem $tipo para exibir.")));

    final List<Color> colors = [Colors.cyan, Colors.purple, Colors.orange, Colors.blue, Colors.green, Colors.pink, Colors.amber];
    int colorIndex = 0;

    return SizedBox(
      height: 250,
      child: Column(
        children: [
          Expanded(
            child: PieChart(
              PieChartData(
                sections: data.entries.map((entry) {
                  final color = colors[colorIndex % colors.length];
                  colorIndex++;
                  return PieChartSectionData(
                    color: color,
                    value: entry.value,
                    title: '${(entry.value / data.values.reduce((a, b) => a + b) * 100).toStringAsFixed(0)}%',
                    radius: 80,
                    titleStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white, shadows: [Shadow(color: Colors.black, blurRadius: 2)]),
                  );
                }).toList(),
                sectionsSpace: 4,
                centerSpaceRadius: 40,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 16,
            runSpacing: 8,
            children: data.entries.map((entry) {
              final color = colors[data.keys.toList().indexOf(entry.key) % colors.length];
              return Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(width: 12, height: 12, color: color),
                  const SizedBox(width: 4),
                  Text(entry.key),
                ],
              );
            }).toList(),
          )
        ],
      ),
    );
  }
}
// ===================================================================
// FIM DO BLOCO DA TELA DE RECEITAS
// ===================================================================

// ===================================================================
// INÍCIO DO BLOCO DA TELA DE BACKUP (NOVA)
// ===================================================================
class TelaBackup extends StatefulWidget {
  const TelaBackup({super.key});

  @override
  State<TelaBackup> createState() => _TelaBackupState();
}

class _TelaBackupState extends State<TelaBackup> {
  bool _isLoading = false;

  Future<void> _criarEPartilharBackup() async {
    setState(() => _isLoading = true);
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("A criar o ficheiro de backup...")));

    final dir = await getApplicationDocumentsDirectory();
    final allFiles = dir.listSync();

    final jsonFiles = allFiles
        .where((file) => file is File && file.path.endsWith('.json'))
        .map((file) => file as File)
        .toList();

    final Map<String, dynamic> backupData = {
      'backupDate': DateTime.now().toIso8601String(),
    };

    for (var file in jsonFiles) {
      try {
        final content = await file.readAsString();
        final fileName = file.path.split('/').last;
        backupData[fileName] = jsonDecode(content);
      } catch (e) {
        backupData[file.path.split('/').last] = 'Error reading file: $e';
      }
    }

    final backupJsonString = jsonEncode(backupData);
    final tempDir = await getTemporaryDirectory();
    final now = DateTime.now();
    final backupFileName = 'financas_backup_${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}.json';
    final backupFile = File('${tempDir.path}/$backupFileName');
    await backupFile.writeAsString(backupJsonString);

    setState(() => _isLoading = false);
    if(mounted) {
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
    }

    await Share.shareXFiles(
      [XFile(backupFile.path)],
      text: 'Backup da sua aplicação de finanças de ${now.day}/${now.month}/${now.year}.',
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Backup e Restauro'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.cloud_upload_outlined, size: 100, color: Colors.blueGrey),
              const SizedBox(height: 24),
              const Text(
                'Proteja os Seus Dados',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              const Text(
                'Crie um ficheiro de backup com todos os seus dados. Guarde-o num local seguro (email, Google Drive, etc.) para poder restaurá-lo no futuro.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
              const SizedBox(height: 48),
              _isLoading
                  ? const CircularProgressIndicator()
                  : ElevatedButton.icon(
                icon: const Icon(Icons.share),
                label: const Text('Criar e Partilhar Backup'),
                onPressed: _criarEPartilharBackup,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
// ===================================================================
// FIM DO BLOCO DA TELA DE BACKUP
// ===================================================================



