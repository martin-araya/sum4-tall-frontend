import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dashboard_screen.dart';
import 'sucursales_screen.dart';
import 'auditores_screen.dart';
import 'auditorias_screen.dart';
import 'usuarios_screen.dart';
import 'reportes_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  static const _navItems = [
    _NavItem(icon: Icons.dashboard_rounded, label: 'Dashboard'),
    _NavItem(icon: Icons.store_rounded, label: 'Sucursales'),
    _NavItem(icon: Icons.person_search_rounded, label: 'Auditores'),
    _NavItem(icon: Icons.assignment_rounded, label: 'Auditorías'),
    _NavItem(icon: Icons.manage_accounts_rounded, label: 'Usuarios'),
    _NavItem(icon: Icons.bar_chart_rounded, label: 'Reportes'),
  ];

  static final _screens = [
    const DashboardScreen(),
    const SucursalesScreen(),
    const AuditoresScreen(),
    const AuditoriasScreen(),
    const UsuariosScreen(),
    const ReportesScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 800;
    if (isMobile) return _buildMobileLayout();
    return Scaffold(
      body: Row(
        children: [
          _buildSidebar(),
          Expanded(child: _screens[_selectedIndex]),
        ],
      ),
    );
  }

  Widget _buildMobileLayout() {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF0A2540),
        elevation: 0,
        titleSpacing: 16,
        title: Row(
          children: [
            Container(
              width: 30, height: 30,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(6),
              ),
              padding: const EdgeInsets.all(3),
              child: Image.asset('assets/logo.png', fit: BoxFit.contain),
            ),
            const SizedBox(width: 8),
            Text(
              'AuditChain',
              style: GoogleFonts.inter(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
      body: _screens[_selectedIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (i) => setState(() => _selectedIndex = i),
        backgroundColor: const Color(0xFF0A2540),
        indicatorColor: const Color(0xFF243B53),
        labelBehavior: NavigationDestinationLabelBehavior.onlyShowSelected,
        destinations: _navItems
            .map(
              (item) => NavigationDestination(
                icon: Icon(item.icon, color: const Color(0xFF9FB3C8)),
                selectedIcon: Icon(item.icon, color: const Color(0xFF06B6D4)),
                label: item.label,
              ),
            )
            .toList(),
      ),
    );
  }

  Widget _buildSidebar() {
    return Container(
      width: 240,
      color: const Color(0xFF0A2540),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildBrand(),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
            child: Text(
              'PRINCIPAL',
              style: GoogleFonts.inter(
                color: const Color(0xFF627D98),
                fontSize: 10,
                fontWeight: FontWeight.w600,
                letterSpacing: 1.2,
              ),
            ),
          ),
          ...List.generate(_navItems.length, _buildNavItem),
          const Spacer(),
          _buildUserChip(),
        ],
      ),
    );
  }

  Widget _buildBrand() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Color(0xFF243B53))),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.asset(
              'assets/logo.png',
              width: 36,
              height: 36,
              fit: BoxFit.contain,
            ),
          ),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'AuditChain',
                style: GoogleFonts.inter(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
              ),
              Text(
                'ADMIN PANEL',
                style: GoogleFonts.inter(
                  color: const Color(0xFF627D98),
                  fontSize: 10,
                  letterSpacing: 0.8,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem(int i) {
    final item = _navItems[i];
    final isSelected = _selectedIndex == i;
    return GestureDetector(
      onTap: () => setState(() => _selectedIndex = i),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF243B53) : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Icon(
              item.icon,
              size: 18,
              color: isSelected ? const Color(0xFF06B6D4) : const Color(0xFF9FB3C8),
            ),
            const SizedBox(width: 10),
            Text(
              item.label,
              style: GoogleFonts.inter(
                color: isSelected ? const Color(0xFF06B6D4) : const Color(0xFF9FB3C8),
                fontSize: 14,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
            if (isSelected) ...[
              const Spacer(),
              Container(
                width: 3,
                height: 3,
                decoration: const BoxDecoration(
                  color: Color(0xFF06B6D4),
                  shape: BoxShape.circle,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildUserChip() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: Color(0xFF243B53))),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 16,
            backgroundColor: const Color(0xFF334E68),
            child: Text(
              'A',
              style: GoogleFonts.inter(
                color: const Color(0xFF9FB3C8),
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Administrador',
                  style: GoogleFonts.inter(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  'admin@auditchain.cl',
                  style: GoogleFonts.inter(
                    color: const Color(0xFF627D98),
                    fontSize: 11,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _NavItem {
  final IconData icon;
  final String label;
  const _NavItem({required this.icon, required this.label});
}
