import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../app/theme/app_typography.dart';
import '../../../core/storage/token_storage.dart';

/// Sidebar lateral fija de 240px usada en el shell de AuditChain.
///
/// - Header con marca "AuditChain" y subtítulo "Red de franquicias".
/// - Lista de navegación con resaltado de la ruta activa basado en
///   [GoRouterState.of(context).uri.toString()].
/// - Footer pegado abajo con avatar de iniciales del usuario actual.
class AppSidebar extends StatelessWidget {
  const AppSidebar({super.key});

  static const double _width = 240;

  static const List<_NavEntry> _items = <_NavEntry>[
    _NavEntry(
      route: '/dashboard',
      icon: Icons.dashboard_outlined,
      iconActive: Icons.dashboard,
      label: 'Dashboard',
    ),
    _NavEntry(
      route: '/sucursales',
      icon: Icons.store_outlined,
      iconActive: Icons.store,
      label: 'Sucursales',
    ),
    _NavEntry(
      route: '/audits',
      icon: Icons.assignment_outlined,
      iconActive: Icons.assignment,
      label: 'Auditorías',
    ),
    _NavEntry(
      route: '/auditors',
      icon: Icons.person_outline,
      iconActive: Icons.person,
      label: 'Auditores',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final String currentRoute = GoRouterState.of(context).uri.toString();

    return Container(
      width: _width,
      height: double.infinity,
      color: AppColors.primary900,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          const _SidebarHeader(),
          SizedBox(height: AppSpacing.md),
          Expanded(
            child: ListView.separated(
              padding: EdgeInsets.symmetric(
                horizontal: AppSpacing.sm,
                vertical: AppSpacing.xs,
              ),
              itemCount: _items.length,
              separatorBuilder: (_, __) => SizedBox(height: AppSpacing.xxs),
              itemBuilder: (BuildContext context, int index) {
                final _NavEntry item = _items[index];
                final bool isActive = _isRouteActive(currentRoute, item.route);
                return _NavigationItem(
                  entry: item,
                  isActive: isActive,
                  onTap: () => context.go(item.route),
                );
              },
            ),
          ),
          const _SidebarFooter(),
        ],
      ),
    );
  }

  static bool _isRouteActive(String currentRoute, String itemRoute) {
    if (currentRoute == itemRoute) return true;
    return currentRoute.startsWith('$itemRoute/');
  }
}

// ─── Header ──────────────────────────────────────────────────────────────────

class _SidebarHeader extends StatelessWidget {
  const _SidebarHeader();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.lg,
        AppSpacing.lg,
        AppSpacing.md,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            'AuditChain',
            style: AppTypography.titleMedium.copyWith(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w500,
              height: 1.2,
            ),
          ),
          SizedBox(height: AppSpacing.xxs),
          Text(
            'Red de franquicias',
            style: AppTypography.bodySmall.copyWith(
              color: Colors.white.withOpacity(0.6),
              fontSize: 12,
              height: 1.3,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Item de navegación ──────────────────────────────────────────────────────

class _NavigationItem extends StatefulWidget {
  const _NavigationItem({
    required this.entry,
    required this.isActive,
    required this.onTap,
  });

  final _NavEntry entry;
  final bool isActive;
  final VoidCallback onTap;

  @override
  State<_NavigationItem> createState() => _NavigationItemState();
}

class _NavigationItemState extends State<_NavigationItem> {
  bool _hovering = false;

  @override
  Widget build(BuildContext context) {
    final Color background = widget.isActive
        ? AppColors.primary800
        : (_hovering ? AppColors.primary700 : Colors.transparent);

    final Color foreground =
        widget.isActive ? Colors.white : Colors.white.withOpacity(0.75);

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovering = true),
      onExit: (_) => setState(() => _hovering = false),
      child: GestureDetector(
        onTap: widget.onTap,
        behavior: HitTestBehavior.opaque,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 120),
          padding: EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.sm + 2,
          ),
          decoration: BoxDecoration(
            color: background,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: <Widget>[
              Icon(
                widget.isActive ? widget.entry.iconActive : widget.entry.icon,
                size: 20,
                color: foreground,
              ),
              SizedBox(width: AppSpacing.sm + 2),
              Expanded(
                child: Text(
                  widget.entry.label,
                  style: AppTypography.bodyMedium.copyWith(
                    color: foreground,
                    fontSize: 14,
                    fontWeight:
                        widget.isActive ? FontWeight.w500 : FontWeight.w400,
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

// ─── Footer ──────────────────────────────────────────────────────────────────

class _SidebarFooter extends StatefulWidget {
  const _SidebarFooter();

  @override
  State<_SidebarFooter> createState() => _SidebarFooterState();
}

class _SidebarFooterState extends State<_SidebarFooter> {
  String _initials = 'U';
  String _name = 'Usuario';
  String _role = 'Rol desconocido';

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  Future<void> _loadUser() async {
    final name = await TokenStorage.getUserName() ?? 'Usuario';
    final role = await TokenStorage.getUserRole() ?? 'Rol desconocido';
    final initials = name.isNotEmpty ? name.substring(0, 1).toUpperCase() : 'U';

    if (mounted) {
      setState(() {
        _name = name;
        _role = role;
        _initials = initials;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(color: Colors.white.withOpacity(0.08)),
        ),
      ),
      child: Row(
        children: <Widget>[
          Container(
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
          ),
          SizedBox(width: AppSpacing.sm + 2),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Text(
                  _name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.bodyMedium.copyWith(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    height: 1.2,
                  ),
                ),
                SizedBox(height: AppSpacing.xxs),
                Text(
                  _role,
                  style: AppTypography.bodySmall.copyWith(
                    color: Colors.white.withOpacity(0.6),
                    fontSize: 11,
                    height: 1.2,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _NavEntry {
  const _NavEntry({
    required this.route,
    required this.icon,
    required this.iconActive,
    required this.label,
  });

  final String route;
  final IconData icon;
  final IconData iconActive;
  final String label;
}
