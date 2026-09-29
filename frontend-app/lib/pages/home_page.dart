import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:organizacao_certificados/router/routes.dart';
import 'package:organizacao_certificados/core/di/injector.dart';
import 'package:organizacao_certificados/modules/auth/auth_service.dart';
import 'package:organizacao_certificados/widgets/top_table.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  Future<void> _logout(BuildContext context) async {
    await Injector.I.get<AuthService>().logOut();
    if (context.mounted) context.go(AppRoutes.login);
  }

  @override
  Widget build(BuildContext context) {
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
                  children: [
                    TopTableCard(
                      onCreate: () => context.push(AppRoutes.certificateCreate),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
