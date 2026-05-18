import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../app/theme/app_typography.dart';
import '../../../core/storage/token_storage.dart';

/// Barra superior de la aplicación.
///
/// - 64px de alto, fondo blanco, borde inferior slate200.
/// - Título dinámico según la ruta actual (Dashboard, Sucursales,
///   Auditorías, Auditores).
/// - Búsqueda visual (no funcional), campana con badge "3" y avatar dinámico.
class AppTopbar extends StatelessWidget implements PreferredSizeWidget {
  const AppTopbar({super.key});

  static const double _height = 64;

  @override
  Size get preferredSize => const Size.fromHeight(_height);

  @override
  Widget build(BuildContext context) {
    final String route = GoRouterState.of(context).uri.toString();
    final String title = _titleForRoute(route);

    return Material(
      color: Colors.white,
      elevation: 0,
      child: Container(
        height: _height,
        decoration: const BoxDecoration(
          color: Colors.white,
          border: Border(bottom: BorderSide(color: AppColors.slate200)),
        ),
        padding: EdgeInsets.symmetric(horizontal: AppSpacing.lg),
        child: Row(
          children: <Widget>[
            // Título dinámico
            Text(
              title,
              style: AppTypography.titleLarge.copyWith(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: AppColors.slate900,
                height: 1.2,
              ),
            ),
            SizedBox(width: AppSpacing.xl),
            // Buscador visual
            const Expanded(child: _SearchField()),
            SizedBox(width: AppSpacing.lg),
            // Notificaciones
            const _NotificationBell(count: 3),
            SizedBox(width: AppSpacing.md),
            // Avatar usuario
            const _UserAvatar(),
          ],
        ),
      ),
    );
  }

  static String _titleForRoute(String route) {
    if (route.startsWith('/dashboard')) return 'Dashboard';
    if (route.startsWith('/sucursales')) return 'Sucursales';
    if (route.startsWith('/audits')) return 'Auditorías';
    if (route.startsWith('/auditors')) return 'Auditores';
    return 'AuditChain';
  }
}

// ─── Buscador (solo UI) ──────────────────────────────────────────────────────

class _SearchField extends StatelessWidget {
  const _SearchField();

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 420),
      child: Container(
        height: 40,
        padding: EdgeInsets.symmetric(horizontal: AppSpacing.sm + 4),
        decoration: BoxDecoration(
          color: AppColors.slate50,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.slate200),
        ),
        child: Row(
          children: <Widget>[
            Icon(
              Icons.search,
              size: 18,
              color: AppColors.slate500,
            ),
            SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Text(
                'Buscar...',
                style: AppTypography.bodyMedium.copyWith(
                  color: AppColors.slate500,
                  fontSize: 14,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Campana con badge ───────────────────────────────────────────────────────

class _NotificationBell extends StatelessWidget {
  const _NotificationBell({required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 40,
      height: 40,
      child: Stack(
        clipBehavior: Clip.none,
        children: <Widget>[
          Positioned.fill(
            child: Material(
              color: Colors.transparent,
              shape: const CircleBorder(),
              child: InkWell(
                customBorder: const CircleBorder(),
                onTap: () {},
                child: Center(
                  child: Icon(
                    Icons.notifications_outlined,
                    size: 22,
                    color: AppColors.slate700,
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            top: 6,
            right: 4,
            child: Container(
              constraints: const BoxConstraints(
                minWidth: 18,
                minHeight: 18,
              ),
              padding: const EdgeInsets.symmetric(horizontal: 5),
              decoration: BoxDecoration(
                color: AppColors.danger,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 1.5),
              ),
              alignment: Alignment.center,
              child: Text(
                '$count',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  height: 1,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Avatar usuario ──────────────────────────────────────────────────────────

class _UserAvatar extends StatefulWidget {
  const _UserAvatar();

  @override
  State<_UserAvatar> createState() => _UserAvatarState();
}

class _UserAvatarState extends State<_UserAvatar> {
  String _initials = 'U';

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  Future<void> _loadUser() async {
    final name = await TokenStorage.getUserName() ?? '';
    final initials = name.isNotEmpty ? name.substring(0, 1).toUpperCase() : 'U';

    if (mounted) {
      setState(() {
        _initials = initials;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 36,
      height: 36,
      decoration: const BoxDecoration(
        color: AppColors.accent500,
        shape: BoxShape.circle,
      ),
      alignment: Alignment.center,
      child: Text(
        _initials,
        style: AppTypography.labelMedium.copyWith(
          color: Colors.white,
          fontSize: 13,
          fontWeight: FontWeight.w600,
          height: 1,
        ),
      ),
    );
  }
}
