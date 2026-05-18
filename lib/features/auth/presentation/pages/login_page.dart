import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:auditchain/app/theme/app_colors.dart';
import 'package:auditchain/core/auth/auth_state_notifier.dart';
import 'package:auditchain/core/storage/token_storage.dart';
import 'package:auditchain/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:auditchain/features/auth/data/models/auth_dto.dart';

/// Página de login de AuditChain.
///
/// Layout responsivo de dos columnas:
///  - Izquierda (420 px, fondo navy #0A2540): branding + bullets de propuesta de valor.
///  - Derecha (flex, fondo blanco): formulario de credenciales.
///
/// En viewports angostos (< 880 px) se colapsa a una sola columna y se oculta el panel
/// de branding para priorizar el formulario.
class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  late final TextEditingController _nombreCtrl = TextEditingController();
  late final TextEditingController _emailCtrl =
      TextEditingController(text: '');
  late final TextEditingController _passwordCtrl =
      TextEditingController(text: '');

  bool _isRegisterMode = false;
  String _rol = 'auditor';
  bool _isLoading = false;

  @override
  void dispose() {
    _nombreCtrl.dispose();
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_isLoading) return;

    if (_isRegisterMode && _nombreCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor, ingresa tu nombre.'),
          backgroundColor: AppColors.danger,
        ),
      );
      return;
    }

    if (_emailCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor, ingresa tu email.'),
          backgroundColor: AppColors.danger,
        ),
      );
      return;
    }

    if (_passwordCtrl.text.length < 8) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('La contraseña debe tener al menos 8 caracteres.'),
          backgroundColor: AppColors.danger,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      if (_isRegisterMode) {
        // Register first
        await AuthRemoteDatasource().register(
          nombre: _nombreCtrl.text.trim(),
          email: _emailCtrl.text.trim(),
          password: _passwordCtrl.text,
          rol: _rol,
        );

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('¡Usuario registrado! Ahora puedes iniciar sesión.'),
              backgroundColor: Colors.green,
            ),
          );
          // Switch back to login mode
          setState(() {
            _isRegisterMode = false;
            _isLoading = false;
            _passwordCtrl.clear();
          });
        }
        return; // Do not auto-login
      }

      // Log in
      final TokenResponse response = await AuthRemoteDatasource().login(
        _emailCtrl.text.trim(),
        _passwordCtrl.text,
      );

      await TokenStorage.saveTokens(
        accessToken: response.accessToken,
        refreshToken: response.refreshToken,
        userName: response.userName,
        userRole: response.userRole,
      );

      authStateNotifier.notifyAuthChange();
      if (mounted) context.go('/dashboard');
    } on Exception catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString().replaceFirst('Exception: ', '')),
            backgroundColor: AppColors.danger,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: LayoutBuilder(
        builder: (context, constraints) {
          final bool isWide = constraints.maxWidth >= 880;

          if (!isWide) {
            return SafeArea(
              child: Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 420),
                    child: _RightPanel(
                      nombreCtrl: _nombreCtrl,
                      emailCtrl: _emailCtrl,
                      passwordCtrl: _passwordCtrl,
                      isRegisterMode: _isRegisterMode,
                      selectedRol: _rol,
                      onRolChanged: (val) => setState(() => _rol = val ?? 'auditor'),
                      onToggleMode: () => setState(() {
                        _isRegisterMode = !_isRegisterMode;
                      }),
                      onSubmit: _submit,
                      isLoading: _isLoading,
                    ),
                  ),
                ),
              ),
            );
          }

          return Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              const SizedBox(
                width: 420,
                child: _LeftPanel(),
              ),
              Expanded(
                child: Center(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 64, vertical: 48),
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 400),
                      child: _RightPanel(
                        nombreCtrl: _nombreCtrl,
                        emailCtrl: _emailCtrl,
                        passwordCtrl: _passwordCtrl,
                        isRegisterMode: _isRegisterMode,
                        selectedRol: _rol,
                        onRolChanged: (val) => setState(() => _rol = val ?? 'auditor'),
                        onToggleMode: () => setState(() {
                          _isRegisterMode = !_isRegisterMode;
                        }),
                        onSubmit: _submit,
                        isLoading: _isLoading,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

// ─── PANEL IZQUIERDO ─────────────────────────────────────────────────────────

class _LeftPanel extends StatelessWidget {
  const _LeftPanel();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.primary900,
      padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 56),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          // Logo
          Row(
            children: const <Widget>[
              Icon(Icons.verified_outlined, color: AppColors.accent500, size: 32),
              SizedBox(width: 10),
              Text(
                'AuditChain',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 32,
                  fontWeight: FontWeight.w600,
                  letterSpacing: -0.5,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          // Tagline
          const Text(
            'Sistema de auditoría para redes de franquicias',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              height: 1.4,
              fontWeight: FontWeight.w400,
            ),
          ),
          const Spacer(),
          // Bullets
          const _Bullet(text: 'Monitoreo en tiempo real de sucursales'),
          const SizedBox(height: 14),
          const _Bullet(text: 'Reportes automáticos por región'),
          const SizedBox(height: 14),
          const _Bullet(text: 'Gestión de auditores de campo'),
          const Spacer(),
        ],
      ),
    );
  }
}

class _Bullet extends StatelessWidget {
  const _Bullet({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        const Icon(Icons.check_circle, color: AppColors.accent500, size: 20),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              height: 1.4,
            ),
          ),
        ),
      ],
    );
  }
}

// ─── PANEL DERECHO ───────────────────────────────────────────────────────────

class _RightPanel extends StatelessWidget {
  const _RightPanel({
    required this.nombreCtrl,
    required this.emailCtrl,
    required this.passwordCtrl,
    required this.isRegisterMode,
    required this.selectedRol,
    required this.onRolChanged,
    required this.onToggleMode,
    required this.onSubmit,
    required this.isLoading,
  });

  final TextEditingController nombreCtrl;
  final TextEditingController emailCtrl;
  final TextEditingController passwordCtrl;
  final bool isRegisterMode;
  final String selectedRol;
  final ValueChanged<String?> onRolChanged;
  final VoidCallback onToggleMode;
  final VoidCallback onSubmit;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Text(
          isRegisterMode ? 'Crear cuenta' : 'Iniciar sesión',
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w600,
            color: AppColors.slate900,
            letterSpacing: -0.3,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          isRegisterMode
              ? 'Regístrate para comenzar a auditar'
              : 'Ingresa tus credenciales para continuar',
          style: const TextStyle(
              fontSize: 14, color: AppColors.slate500, height: 1.4),
        ),
        const SizedBox(height: 28),

        // Nombre (Sólo en registro)
        if (isRegisterMode) ...[
          const _FieldLabel(text: 'Nombre Completo'),
          const SizedBox(height: 6),
          TextField(
            controller: nombreCtrl,
            keyboardType: TextInputType.name,
            decoration: _decoration('Ej. Valentina Lagos'),
          ),
          const SizedBox(height: 16),
        ],

        // Email
        const _FieldLabel(text: 'Email'),
        const SizedBox(height: 6),
        TextField(
          controller: emailCtrl,
          keyboardType: TextInputType.emailAddress,
          decoration: _decoration('correo@ejemplo.com'),
        ),
        const SizedBox(height: 16),

        // Password
        const _FieldLabel(text: 'Contraseña'),
        const SizedBox(height: 6),
        TextField(
          controller: passwordCtrl,
          obscureText: true,
          decoration: _decoration('••••••••'),
        ),
        const SizedBox(height: 16),

        // Rol (Sólo en registro)
        if (isRegisterMode) ...[
          const _FieldLabel(text: 'Rol de Usuario'),
          const SizedBox(height: 6),
          DropdownButtonFormField<String>(
            value: selectedRol,
            onChanged: onRolChanged,
            decoration: _decoration(''),
            dropdownColor: Colors.white,
            items: const [
              DropdownMenuItem(value: 'auditor', child: Text('Auditor de Campo')),
              DropdownMenuItem(value: 'admin', child: Text('Administrador')),
            ],
          ),
          const SizedBox(height: 24),
        ] else ...[
          const SizedBox(height: 8),
        ],

        // Botón
        SizedBox(
          height: 44,
          child: ElevatedButton(
            onPressed: isLoading ? null : onSubmit,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary800,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              textStyle: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
            child: isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : Text(isRegisterMode ? 'Registrarme' : 'Entrar'),
          ),
        ),
        const SizedBox(height: 16),

        // Enlace para cambiar de modo
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              isRegisterMode ? '¿Ya tienes una cuenta? ' : '¿No tienes una cuenta? ',
              style: const TextStyle(fontSize: 13, color: AppColors.slate500),
            ),
            GestureDetector(
              onTap: isLoading ? null : onToggleMode,
              child: Text(
                isRegisterMode ? 'Iniciar sesión' : 'Regístrate aquí',
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primary800,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        // Nota de demostración
        Center(
          child: Text(
            isRegisterMode
                ? 'El registro creará una cuenta real en la base de datos'
                : 'Acceso de demostración — datos simulados',
            style: const TextStyle(
              fontSize: 11,
              color: AppColors.slate400,
              fontWeight: FontWeight.w400,
            ),
          ),
        ),
      ],
    );
  }

  InputDecoration _decoration(String hint) {
    return InputDecoration(
      isDense: true,
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      filled: true,
      fillColor: Colors.white,
      hintText: hint,
      hintStyle: const TextStyle(color: AppColors.slate300, fontSize: 13),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: AppColors.slate200),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: AppColors.slate200),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: AppColors.primary800, width: 1.5),
      ),
    );
  }
}

class _FieldLabel extends StatelessWidget {
  const _FieldLabel({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        color: AppColors.slate500,
        letterSpacing: 0.2,
      ),
    );
  }
}
