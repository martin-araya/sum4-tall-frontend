import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// ─── COLORES SEMÁNTICOS ───────────────────────────────────────────────────────

const _kPrimary = Color(0xFF1E3A8A);

Color estadoTextColor(String e) {
  switch (e) {
    case 'completada':
    case 'activo':
      return const Color(0xFF065F46);
    case 'pendiente':
      return const Color(0xFF92400E);
    case 'con_observaciones':
      return const Color(0xFF075985);
    default:
      return const Color(0xFF475569);
  }
}

Color estadoBgColor(String e) {
  switch (e) {
    case 'completada':
    case 'activo':
      return const Color(0xFFD1FAE5);
    case 'pendiente':
      return const Color(0xFFFEF3C7);
    case 'con_observaciones':
      return const Color(0xFFE0F2FE);
    default:
      return const Color(0xFFF1F5F9);
  }
}

String _estadoLabel(String e) {
  switch (e) {
    case 'con_observaciones': return 'Con obs.';
    case 'completada': return 'Completada';
    case 'pendiente': return 'Pendiente';
    case 'activo': return 'Activo';
    case 'inactivo': return 'Inactivo';
    default: return e.replaceAll('_', ' ');
  }
}

Color _puntajeColor(int p) {
  if (p >= 90) return const Color(0xFF10B981);
  if (p >= 75) return const Color(0xFF06B6D4);
  if (p >= 60) return const Color(0xFFF59E0B);
  return const Color(0xFF94A3B8);
}

// ─── HELPERS ──────────────────────────────────────────────────────────────────

/// Convierte 'YYYY-MM-DD' a 'DD/MM/YYYY'. Si el formato no coincide, devuelve el original.
String formatFecha(String iso) {
  if (iso.isEmpty || iso == '—') return iso;
  try {
    final parts = iso.split('-');
    if (parts.length < 3) return iso;
    return '${parts[2]}/${parts[1]}/${parts[0]}';
  } catch (_) {
    return iso;
  }
}

void showSnack(BuildContext context, String msg, {bool error = false}) {
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
    content: Text(msg, style: GoogleFonts.inter()),
    backgroundColor: error ? const Color(0xFFEF4444) : const Color(0xFF10B981),
    duration: const Duration(seconds: 3),
    behavior: SnackBarBehavior.floating,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
  ));
}

Future<bool> confirmar(BuildContext context, String msg) async {
  return await showDialog<bool>(
        context: context,
        builder: (_) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          title: Text('Confirmar', style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
          content: Text(msg, style: GoogleFonts.inter()),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFEF4444),
                foregroundColor: Colors.white,
              ),
              child: const Text('Eliminar'),
            ),
          ],
        ),
      ) ??
      false;
}

// ─── PAGE LAYOUT ──────────────────────────────────────────────────────────────

class PageLayout extends StatelessWidget {
  final String title;
  final String subtitle;
  final VoidCallback onNew;
  final Widget child;

  const PageLayout({
    super.key,
    required this.title,
    required this.subtitle,
    required this.onNew,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: const Color(0xFFE2E8F0)),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: GoogleFonts.inter(
                fontSize: 17,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF0A2540),
              ),
            ),
            Text(
              subtitle,
              style: GoogleFonts.inter(fontSize: 12, color: const Color(0xFF94A3B8)),
            ),
          ],
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: ElevatedButton.icon(
              onPressed: onNew,
              icon: const Icon(Icons.add, size: 16),
              label: const Text('Nuevo'),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1400),
            child: child,
          ),
        ),
      ),
    );
  }
}

// ─── STATS ────────────────────────────────────────────────────────────────────

class StatsRow extends StatelessWidget {
  final List<StatCard> stats;
  const StatsRow({super.key, required this.stats});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: stats
          .map((s) => Expanded(
                child: Padding(padding: const EdgeInsets.only(right: 12), child: s),
              ))
          .toList(),
    );
  }
}

class StatCard extends StatelessWidget {
  final String label;
  final String value;
  final String sub;
  final Color? valueColor;

  const StatCard({
    super.key,
    required this.label,
    required this.value,
    required this.sub,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label.toUpperCase(),
              style: GoogleFonts.inter(
                fontSize: 10,
                color: const Color(0xFF94A3B8),
                fontWeight: FontWeight.w600,
                letterSpacing: 0.8,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              value,
              style: GoogleFonts.inter(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: valueColor ?? const Color(0xFF0A2540),
              ),
            ),
            const SizedBox(height: 2),
            Text(
              sub,
              style: GoogleFonts.inter(fontSize: 11, color: const Color(0xFF94A3B8)),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── BADGE DE ESTADO ──────────────────────────────────────────────────────────

class EstadoBadge extends StatelessWidget {
  final String estado;
  const EstadoBadge({super.key, required this.estado});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
      decoration: BoxDecoration(
        color: estadoBgColor(estado),
        borderRadius: BorderRadius.circular(9999),
      ),
      child: Text(
        _estadoLabel(estado),
        overflow: TextOverflow.ellipsis,
        style: GoogleFonts.inter(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: estadoTextColor(estado),
        ),
      ),
    );
  }
}

// ─── TABLE CARD ───────────────────────────────────────────────────────────────

class TableCard extends StatefulWidget {
  final int count;
  final bool loading;
  final List<String> headers;
  final List<List<String>> rows;
  final Function(int) onEdit;
  final Function(int) onDelete;
  final int? puntajeCol;
  final int? estadoCol;
  final int pageSize;

  const TableCard({
    super.key,
    required this.count,
    required this.loading,
    required this.headers,
    required this.rows,
    required this.onEdit,
    required this.onDelete,
    this.puntajeCol,
    this.estadoCol,
    this.pageSize = 10,
  });

  @override
  State<TableCard> createState() => _TableCardState();
}

class _TableCardState extends State<TableCard> {
  int _page = 0;

  @override
  void didUpdateWidget(TableCard old) {
    super.didUpdateWidget(old);
    if (old.rows.length != widget.rows.length) _page = 0;
  }

  @override
  Widget build(BuildContext context) {
    final total = widget.rows.length;
    final totalPages = (total / widget.pageSize).ceil().clamp(1, 9999);
    final start = _page * widget.pageSize;
    final pageRows = widget.rows.skip(start).take(widget.pageSize).toList();
    final end = (start + pageRows.length).clamp(0, total);

    return Card(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'REGISTROS',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF94A3B8),
                  ),
                ),
                Text(
                  total == 0
                      ? '0 registros'
                      : 'Mostrando ${start + 1}–$end de $total',
                  style: GoogleFonts.inter(fontSize: 12, color: const Color(0xFF94A3B8)),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          if (widget.loading)
            const Padding(
              padding: EdgeInsets.all(40),
              child: CircularProgressIndicator(color: _kPrimary),
            )
          else if (widget.rows.isEmpty)
            Padding(
              padding: const EdgeInsets.all(40),
              child: Text(
                'No hay registros aún',
                style: GoogleFonts.inter(color: const Color(0xFF94A3B8)),
              ),
            )
          else
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                headingRowColor: WidgetStateProperty.all(const Color(0xFFF8FAFC)),
                dataRowMinHeight: 48,
                dataRowMaxHeight: 56,
                columns: widget.headers
                    .map((h) => DataColumn(
                          label: Text(
                            h,
                            style: GoogleFonts.inter(
                              fontSize: 11,
                              color: const Color(0xFF94A3B8),
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ))
                    .toList(),
                rows: List.generate(pageRows.length, (localI) {
                  final row = pageRows[localI];
                  final absoluteI = start + localI;
                  return DataRow(
                    cells: List.generate(row.length, (j) {
                      if (j == row.length - 1) {
                        return DataCell(Row(children: [
                          IconButton(
                            icon: const Icon(Icons.edit_rounded, size: 16),
                            onPressed: () => widget.onEdit(absoluteI),
                            color: const Color(0xFF94A3B8),
                            tooltip: 'Editar',
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete_rounded, size: 16),
                            onPressed: () => widget.onDelete(absoluteI),
                            color: const Color(0xFFEF4444),
                            tooltip: 'Eliminar',
                          ),
                        ]));
                      }
                      if (j == widget.estadoCol) {
                        return DataCell(EstadoBadge(estado: row[j]));
                      }
                      if (j == widget.puntajeCol) {
                        final p = int.tryParse(row[j].replaceAll('%', '')) ?? 0;
                        return DataCell(Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: _puntajeColor(p).withAlpha(26),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            row[j],
                            style: GoogleFonts.jetBrainsMono(
                              fontSize: 12,
                              color: _puntajeColor(p),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ));
                      }
                      return DataCell(Text(
                        row[j],
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          fontWeight: j == 0 ? FontWeight.w600 : FontWeight.normal,
                          color: j == 0 ? const Color(0xFF0A2540) : const Color(0xFF64748B),
                        ),
                      ));
                    }),
                  );
                }),
              ),
            ),
          if (!widget.loading && total > widget.pageSize)
            _buildPaginacion(totalPages),
        ],
      ),
    );
  }

  Widget _buildPaginacion(int totalPages) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Text(
            'Página ${_page + 1} de $totalPages',
            style: GoogleFonts.inter(fontSize: 12, color: const Color(0xFF94A3B8)),
          ),
          const SizedBox(width: 12),
          IconButton(
            icon: const Icon(Icons.chevron_left_rounded),
            onPressed: _page > 0 ? () => setState(() => _page--) : null,
            color: const Color(0xFF64748B),
            iconSize: 20,
          ),
          ...List.generate(totalPages.clamp(0, 5), (i) {
            final isActive = i == _page;
            return GestureDetector(
              onTap: () => setState(() => _page = i),
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 3),
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: isActive ? _kPrimary : Colors.transparent,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(
                    color: isActive ? _kPrimary : const Color(0xFFE2E8F0),
                  ),
                ),
                child: Center(
                  child: Text(
                    '${i + 1}',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: isActive ? Colors.white : const Color(0xFF64748B),
                    ),
                  ),
                ),
              ),
            );
          }),
          IconButton(
            icon: const Icon(Icons.chevron_right_rounded),
            onPressed: _page < totalPages - 1 ? () => setState(() => _page++) : null,
            color: const Color(0xFF64748B),
            iconSize: 20,
          ),
        ],
      ),
    );
  }
}

// ─── FORM DIALOG ─────────────────────────────────────────────────────────────

class FormDialog extends StatelessWidget {
  final String title;
  final bool saving;
  final VoidCallback onSave;
  final List<Widget> fields;

  const FormDialog({
    super.key,
    required this.title,
    required this.saving,
    required this.onSave,
    required this.fields,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Container(
        width: 480,
        padding: const EdgeInsets.all(24),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.inter(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF0A2540),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                    color: const Color(0xFF94A3B8),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              ...fields,
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cancelar'),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: saving ? null : onSave,
                    child: saving
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Text('Guardar'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── FORM FIELDS ──────────────────────────────────────────────────────────────

class FormField2 extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final bool obscure;
  final int maxLines;
  final Function(String)? onChanged;

  const FormField2({
    super.key,
    required this.label,
    required this.controller,
    this.obscure = false,
    this.maxLines = 1,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF64748B),
            ),
          ),
          const SizedBox(height: 6),
          TextField(
            controller: controller,
            obscureText: obscure,
            maxLines: maxLines,
            onChanged: onChanged,
            style: GoogleFonts.inter(fontSize: 14),
          ),
        ],
      ),
    );
  }
}

class DropdownField extends StatelessWidget {
  final String label;
  final String value;
  final List<String> items;
  final List<String>? labels;
  final Function(String?) onChanged;

  const DropdownField({
    super.key,
    required this.label,
    required this.value,
    required this.items,
    this.labels,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF64748B),
            ),
          ),
          const SizedBox(height: 6),
          DropdownButtonFormField<String>(
            initialValue: items.contains(value) ? value : items.isNotEmpty ? items[0] : null,
            isDense: true,
            style: GoogleFonts.inter(fontSize: 14, color: const Color(0xFF0A2540)),
            items: List.generate(
              items.length,
              (i) => DropdownMenuItem(
                value: items[i],
                child: Text(
                  labels != null ? labels![i] : items[i],
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}

// ─── DATE FIELD ───────────────────────────────────────────────────────────────

class DateField extends StatelessWidget {
  final String label;
  final String value;
  final Function(String) onChanged;

  const DateField({
    super.key,
    required this.label,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF64748B),
            ),
          ),
          const SizedBox(height: 6),
          InkWell(
            onTap: () async {
              final initial = DateTime.tryParse(value) ?? DateTime.now();
              final picked = await showDatePicker(
                context: context,
                initialDate: initial,
                firstDate: DateTime(2020),
                lastDate: DateTime(2030),
                builder: (ctx, child) => Theme(
                  data: Theme.of(ctx).copyWith(
                    colorScheme: const ColorScheme.light(primary: Color(0xFF1E3A8A)),
                  ),
                  child: child!,
                ),
              );
              if (picked != null) {
                onChanged(picked.toIso8601String().substring(0, 10));
              }
            },
            borderRadius: BorderRadius.circular(8),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              decoration: BoxDecoration(
                border: Border.all(color: const Color(0xFFCBD5E1)),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Icon(Icons.calendar_today_rounded,
                      size: 16, color: Color(0xFF94A3B8)),
                  const SizedBox(width: 10),
                  Text(
                    value.isEmpty ? 'Seleccionar fecha' : formatFecha(value),
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      color: value.isEmpty
                          ? const Color(0xFF94A3B8)
                          : const Color(0xFF0A2540),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
