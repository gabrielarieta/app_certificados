import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:organizacao_certificados/router/routes.dart';
import 'package:organizacao_certificados/core/di/injector.dart';
import 'package:organizacao_certificados/modules/auth/auth_service.dart';
import 'package:organizacao_certificados/widgets/top_table.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  void _logout(BuildContext context) {
    Injector.I.get<AuthService>().logOut();
    context.go(AppRoutes.login);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
        actions: [
          IconButton(
            tooltip: 'Logout',
            onPressed: () => _logout(context),
            icon: const Icon(Icons.logout, color: Colors.red),
          ),
        ],
      ),
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverPadding(
              padding: const EdgeInsets.all(16),
              sliver: SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: const [
                    TopTableCard(),
                  ],
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              sliver: SliverToBoxAdapter(
                child: Text('Activity history', style: theme.textTheme.titleLarge),
              ),
            ),
           /* SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
              sliver: _ActivityListSliver(items: []),
            ), */
          ],
        ),
      ),
    );
  }
}

/*
class _ActivityListSliver extends StatelessWidget {
  const _ActivityListSliver({required this.items});
  final List<ActivityItem> items;

  void _openDetail(BuildContext context, String id) {
    final path = '/certificate/${Uri.encodeComponent(id)}';
    context.push(path);
  }

  @override
  Widget build(BuildContext context) {
    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          final item = items[index];
          return Card(
            elevation: 0,
            margin: const EdgeInsets.only(bottom: 12),
            child: ListTile(
              leading: CircleAvatar(backgroundColor: Colors.blue.withValues(alpha: 0.12), child: Icon(item.icon, color: Colors.blue)),
              title: Text(item.title, overflow: TextOverflow.ellipsis),
              subtitle: Text(item.subtitle, overflow: TextOverflow.ellipsis),
              trailing: Text(item.timeLabel, style: Theme.of(context).textTheme.bodySmall),
              onTap: () => _openDetail(context, item.certId),
            ),
          );
        },
        childCount: items.length,
      ),
    );
  }
} */
