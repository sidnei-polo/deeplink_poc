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
          path: ':supplierId',
          pageBuilder: (context, state) => MaterialPage(
            child: SupplierPage(supplierId: state.params['supplierId']!),
          ),
        ),
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
  final HomeTab? homeTab;
  final OrdersTab? ordersTab;

  const HomePage({this.homeTab, this.ordersTab, super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with SingleTickerProviderStateMixin, AutomaticKeepAliveClientMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: HomeTab.values.length,
      vsync: this,
      initialIndex: widget.homeTab?.index ?? HomeTab.suppliers.index,
    );
  }

  @override
  void didUpdateWidget(covariant HomePage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.homeTab != null) {
      _tabController.index = widget.homeTab!.index;
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final router = GoRouter.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(router.location)),
      body: TabBarView(
        physics: const NeverScrollableScrollPhysics(),
        controller: _tabController,
        children: [
          const SuppliersPage(),
          const Center(
            child: Text("Chat"),
          ),
          OrdersPage(ordersTab: widget.ordersTab),
          const Center(
            child: Text("Settings"),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _tabController.index,
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
  bool get wantKeepAlive => true;
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

class SupplierPage extends StatelessWidget {
  final String supplierId;

  const SupplierPage({required this.supplierId, super.key});

  @override
  Widget build(BuildContext context) {
    final router = GoRouter.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(router.location)),
      body: Center(
        child: Text(supplierId),
      ),
    );
  }
}

class OrdersPage extends StatefulWidget {
  final OrdersTab? ordersTab;

  const OrdersPage({this.ordersTab, super.key});

  @override
  State<OrdersPage> createState() => _OrdersPageState();
}

class _OrdersPageState extends State<OrdersPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: OrdersTab.values.length,
      vsync: this,
      initialIndex: widget.ordersTab?.index ?? OrdersTab.open.index,
    );
  }

  @override
  void didUpdateWidget(covariant OrdersPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.ordersTab != null) {
      _tabController.index = widget.ordersTab!.index;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TabBar(
          controller: _tabController,
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
            controller: _tabController,
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
