/// Escala de espaciado de AuditChain.
///
/// Múltiplos de 4 px. Úsese para padding, margin, gap y dimensiones de
/// componentes para mantener ritmo vertical y horizontal consistente en
/// todos los módulos (auditorías, evidencias, reportes, etc.).
///
///   xs   4    — separaciones mínimas (icono ↔ texto, chips internos)
///   sm   8    — densidad alta (tablas, listas)
///   md  12    — padding interno de inputs / cards densos
///   lg  16    — padding base de cards y secciones
///   xl  24    — separación entre bloques
///   xxl 32    — separación entre secciones mayores
///   xxxl 48   — márgenes de página / hero spacing
class AppSpacing {
  AppSpacing._();

  static const double xxs = 2;
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 24;
  static const double xxl = 32;
  static const double xxxl = 48;
}
