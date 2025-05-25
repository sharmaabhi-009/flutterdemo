import 'dart:async'; // Added import for Timer
import 'package:flutter/material.dart';
import '../services/mqtt_service.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import '../widget/stock_card.dart';

class StockHomePage extends StatefulWidget {
  const StockHomePage({super.key});

  @override
  StockHomePageState createState() => StockHomePageState();
}

class StockHomePageState extends State<StockHomePage> with TickerProviderStateMixin {
  bool _isLoading = true;
  final TextEditingController _searchController = TextEditingController();
  final MqttService mqttService = MqttService();
  List<Map<String, dynamic>> _filteredStocks = [];
  Timer? _loadingTimeout;

  late TabController _mainTabController;
  TabController? _marketTabController;
  TabController? _serviceTabController;

  final List<String> _mainTabs = ['Home', 'Market', 'Services'];
  final List<String> _marketTabs = ['NSE', 'BSE'];
  final List<String> _serviceTabs = ['bank', 'tech', 'auto', 'energy', 'infra'];

  @override
  void initState() {
    super.initState();
    _mainTabController = TabController(length: _mainTabs.length, vsync: this);
    _marketTabController = TabController(length: _marketTabs.length, vsync: this);
    _serviceTabController = TabController(length: _serviceTabs.length, vsync: this);

    _searchController.addListener(_filterStocks);
    mqttService.addListener(_onStockUpdate);

    _mainTabController.addListener(_handleMainTabChange);
    _marketTabController?.addListener(() {
      if (_mainTabController.index == 1 && !_marketTabController!.indexIsChanging) {
        _subscribeToMarket(_marketTabs[_marketTabController!.index]);
      }
    });
    _serviceTabController?.addListener(() {
      if (_mainTabController.index == 2 && !_serviceTabController!.indexIsChanging) {
        _subscribeToService(_serviceTabs[_serviceTabController!.index]);
      }
    });

    _subscribeToHome(); // Start with home
    _startLoadingTimeout();
  }

  void _startLoadingTimeout() {
    _loadingTimeout?.cancel();
    _loadingTimeout = Timer(const Duration(seconds: 10), () {
      if (mounted && _isLoading) {
        setState(() {
          _isLoading = false;
        });
      }
    });
  }

  void _handleMainTabChange() {
    setState(() {
      _isLoading = true;
      _filteredStocks = [];
      _searchController.clear();
    });
    _startLoadingTimeout();
    if (_mainTabController.index == 0) {
      _subscribeToHome();
    } else if (_mainTabController.index == 1) {
      _subscribeToMarket(_marketTabs[_marketTabController!.index]);
    } else if (_mainTabController.index == 2) {
      _subscribeToService(_serviceTabs[_serviceTabController!.index]);
    }
  }

  void _subscribeToHome() {
    mqttService.subscribeToTopic('Stock/#');
    // Optionally subscribe to more topics, if normal subscription dosent work
    // mqttService.subscribeToTopic('Stock/NSE/#');
    // mqttService.subscribeToTopic('Stock/BSE/#');
  }

  void _subscribeToMarket(String market) {
    String topic = 'Stock/$market/#';
    mqttService.subscribeToTopic(topic);
  }

  void _subscribeToService(String service) {
    String topic = 'Stock/+/$service/#';
    mqttService.subscribeToTopic(topic);
  }

  void _onStockUpdate() {
    setState(() {
      _isLoading = mqttService.stocks.isEmpty; // Only stop loading when data is received
      _filterStocks();
    });
  }

  void _filterStocks() {
    final query = _searchController.text.toLowerCase();
    final stocks = mqttService.stocks;
    setState(() {
      _filteredStocks = stocks.where((stock) {
        final symbol = stock['symbol']?.toString().toLowerCase() ?? '';
        final name = stock['name']?.toString().toLowerCase() ?? '';
        return symbol.contains(query) || name.contains(query);
      }).toList();
    });
  }

  @override
  void dispose() {
    _loadingTimeout?.cancel();
    mqttService.disposeService();
    mqttService.removeListener(_onStockUpdate);
    _searchController.dispose();
    _mainTabController.dispose();
    _marketTabController?.dispose();
    _serviceTabController?.dispose();
    super.dispose();
  }

  Widget _buildStockListView() {
    if (_isLoading) {
      return Center(
        child: LoadingAnimationWidget.staggeredDotsWave(
          color: Colors.green,
          size: 50,
        ),
      );
    } else if (_filteredStocks.isEmpty) {
      return const Center(child: Text("No matching stocks"));
    } else {
      return ListView.builder(
        itemCount: _filteredStocks.length,
        itemBuilder: (context, index) {
          final stock = _filteredStocks[index];
          return StockCard(
            symbol: stock['symbol'] ?? '',
            name: stock['name'] ?? '',
            price: stock['price']?.toDouble() ?? 0.0,
            change: stock['change']?.toDouble() ?? 0.0,
            stockTopic: stock['stockTopic'] ?? '',
          );
        },
      );
    }
  }

  Widget _buildNestedTabView(List<String> tabs, TabController? controller) {
    return Column(
      children: [
        TabBar.secondary(
          controller: controller,
          tabs: tabs.map((t) => Tab(text: t)).toList(),
        ),
        const SizedBox(height: 8),
        Expanded(child: _buildStockListView()),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: _mainTabs.length,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: const Color(0xFF06C692),
          foregroundColor: Colors.black,
          elevation: 0,
          title: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.asset(
                'assets/solly.png',
                height: 55,
                width: 55,
              ),
              const SizedBox(width: 10),
              const Text(
                "Live Stocks",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          bottom: TabBar(
            controller: _mainTabController,
            tabs: _mainTabs.map((tab) => Tab(text: tab)).toList(),
            labelColor: Colors.black,
            unselectedLabelColor: Colors.grey[700],
            indicatorColor: Colors.black,
          ),
        ),
        body: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            children: [
              TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Search stock...',
                  prefixIcon: const Icon(Icons.search),
                  filled: true,
                  fillColor: Colors.grey[200],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: TabBarView(
                  controller: _mainTabController,
                  children: [
                    _buildStockListView(),
                    _buildNestedTabView(_marketTabs, _marketTabController),
                    _buildNestedTabView(_serviceTabs, _serviceTabController),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}