import 'package:flutter/material.dart';

import 'package:auditchain/app/router/app_router.dart';
import 'package:auditchain/app/theme/app_theme.dart';

/// Raíz de la aplicación.
/// Usa MaterialApp.router para integrarse con go_router.
class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'AuditChain',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      routerConfig: goRouter,
    );
  }
}
