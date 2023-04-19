import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

const _scaffoldKey = ValueKey<String>('app_scaffold');

final router = GoRouter(
  initialLocation: '/',
  debugLogDiagnostics: true,
  routes: [
    GoRoute(
      path: '/',
      redirect: (context, state) => '/suppliers',
    ),
    GoRoute(
      path: '/suppliers',
      pageBuilder: (context, state) => const NoTransitionPage(
        key: _scaffoldKey,
        child: HomePage(homeTab: HomeTab.suppliers),
      ),
      routes: [
        GoRoute(
            path: 'catalogue/:supplierId',
            pageBuilder: (context, state) {
              final offset = double.tryParse(state.queryParams['offset'] ?? '');
              return MaterialPage(
                child: CataloguePage(supplierId: state.params['supplierId']!, offset: offset),
              );
            }),
      ],
    ),
    GoRoute(
      path: '/chat',
      pageBuilder: (context, state) => const NoTransitionPage(
        key: _scaffoldKey,
        child: HomePage(homeTab: HomeTab.chat),
      ),
    ),
    GoRoute(
      path: '/orders',
      redirect: (context, state) => '/orders/open',
    ),
    GoRoute(
      path: '/orders/:tab(open|past|draft)',
      pageBuilder: (context, state) => NoTransitionPage(
        key: _scaffoldKey,
        child: HomePage(homeTab: HomeTab.orders, ordersTab: state.params['tab']!.toOrdersTab()),
      ),
    ),
    GoRoute(
      path: '/settings',
      pageBuilder: (context, state) => const NoTransitionPage(
        key: _scaffoldKey,
        child: HomePage(homeTab: HomeTab.settings),
      ),
    ),
  ],
);

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      routerConfig: router,
    );
  }
}

class HomePage extends StatefulWidget {
  final HomeTab homeTab;
  final OrdersTab ordersTab;

  const HomePage({this.homeTab = HomeTab.suppliers, this.ordersTab = OrdersTab.open, super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with TickerProviderStateMixin {
  late TabController _homeTabController;
  late TabController _ordersTabController;

  @override
  void initState() {
    super.initState();
    _homeTabController = TabController(
      length: HomeTab.values.length,
      vsync: this,
      initialIndex: widget.homeTab.index,
    );
    _ordersTabController = TabController(
      length: OrdersTab.values.length,
      vsync: this,
      initialIndex: widget.ordersTab.index,
    );
  }

  @override
  void didUpdateWidget(covariant HomePage oldWidget) {
    super.didUpdateWidget(oldWidget);
    _homeTabController.index = widget.homeTab.index;
    _ordersTabController.index = widget.ordersTab.index;
  }

  @override
  Widget build(BuildContext context) {
    final router = GoRouter.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(router.location)),
      body: TabBarView(
        physics: const NeverScrollableScrollPhysics(),
        controller: _homeTabController,
        children: [
          const SuppliersPage(),
          const Center(
            child: Text("Chat"),
          ),
          OrdersPage(tabController: _ordersTabController),
          const Center(
            child: Text("Settings"),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _homeTabController.index,
        selectedItemColor: Colors.indigo,
        unselectedItemColor: Colors.grey,
        onTap: (index) => context.go(HomeTab.values[index].route),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            activeIcon: Icon(Icons.home),
            label: 'Suppliers',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            activeIcon: Icon(Icons.home),
            label: 'Chat',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            activeIcon: Icon(Icons.home),
            label: 'Orders',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            activeIcon: Icon(Icons.home),
            label: 'Settings',
          )
        ],
      ),
    );
  }

  @override
  void dispose() {
    _homeTabController.dispose();
    _ordersTabController.dispose();
    super.dispose();
  }
}

class SuppliersPage extends StatelessWidget {
  const SuppliersPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Center(
        child: TextField(onSubmitted: (route) => context.go(route)),
      ),
    );
  }
}

class CataloguePage extends StatefulWidget {
  final String supplierId;
  final double? offset;

  const CataloguePage({required this.supplierId, this.offset, super.key});

  @override
  State<CataloguePage> createState() => _CataloguePageState();
}

class _CataloguePageState extends State<CataloguePage> {
  late ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController(initialScrollOffset: widget.offset ?? 0);
  }

  @override
  void didUpdateWidget(covariant CataloguePage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.offset != widget.offset && widget.offset != null) {
      _scrollController.jumpTo(widget.offset!);
    }
  }

  @override
  Widget build(BuildContext context) {
    final router = GoRouter.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(router.location)),
      body: ListView.builder(
        controller: _scrollController,
        itemCount: 100,
        itemBuilder: (context, index) => Text(index.toString()),
      ),
    );
  }
}

class OrdersPage extends StatelessWidget {
  final TabController tabController;

  const OrdersPage({required this.tabController, super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TabBar(
          controller: tabController,
          labelColor: Colors.blue,
          onTap: (index) => context.go(OrdersTab.values[index].route),
          tabs: const [
            Tab(text: 'open'),
            Tab(text: 'past'),
            Tab(text: 'draft'),
          ],
        ),
        Expanded(
          child: TabBarView(
            controller: tabController,
            children: const [
              Center(child: Text('open')),
              Center(child: Text('past')),
              Center(child: Text('draft')),
            ],
          ),
        ),
      ],
    );
  }
}

enum HomeTab {
  suppliers('/suppliers'),
  chat('/chat'),
  orders('/orders'),
  settings('/settings');

  final String route;

  const HomeTab(this.route);
}

enum OrdersTab {
  open('/orders/open'),
  past('/orders/past'),
  draft('/orders/draft');

  final String route;

  const OrdersTab(this.route);
}

extension StringExtensions on String {
  OrdersTab toOrdersTab() {
    switch (this) {
      case 'past':
        return OrdersTab.past;
      case 'draft':
        return OrdersTab.draft;
      default:
        return OrdersTab.open;
    }
  }
}
