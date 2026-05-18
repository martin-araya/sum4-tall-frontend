import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_typography.dart';
import '../../../../features/branches/data/datasources/sucursales_remote_datasource.dart';
import '../../../../features/branches/data/models/sucursal_dto.dart';
import '../../../../features/auditors/data/datasources/auditores_remote_datasource.dart';
import '../../../../features/auditors/data/models/auditor_dto.dart';
import '../../data/datasources/auditorias_remote_datasource.dart';

class AuditWizardPage extends StatefulWidget {
  const AuditWizardPage({super.key});

  @override
  State<AuditWizardPage> createState() => _AuditWizardPageState();
}

class _AuditWizardPageState extends State<AuditWizardPage> {
  final PageController _pageController = PageController();
  final _formKey = GlobalKey<FormState>();

  int _currentStep = 0;
  bool _isLoadingSources = true;
  bool _isSubmitting = false;
  String? _loadError;

  // Data lists
  List<SucursalDto> _sucursales = [];
  List<AuditorDto> _auditores = [];

  // Form Fields State
  String? _selectedSucursalId;
  String? _selectedAuditorId;
  DateTime _selectedDate = DateTime.now();
  final TextEditingController _observacionesCtrl = TextEditingController();

  // Checklist Items (each worth 25 points if YES)
  final List<Map<String, dynamic>> _checklist = [
    {
      'question': '¿La sucursal cumple con los estándares generales de limpieza e higiene?',
      'value': false,
    },
    {
      'question': '¿El personal cuenta con sus uniformes correspondientes y credenciales?',
      'value': false,
    },
    {
      'question': '¿La temperatura de las cámaras de refrigeración se encuentra dentro de rango?',
      'value': false,
    },
    {
      'question': '¿Todos los productos de exhibición cuentan con precios y rotulación legible?',
      'value': false,
    },
  ];

  @override
  void initState() {
    super.initState();
    _loadSources();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _observacionesCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadSources() async {
    setState(() {
      _isLoadingSources = true;
      _loadError = null;
    });

    try {
      final sucursalesPage = await SucursalesRemoteDatasource().getAll(size: 100);
      final auditoresPage = await AuditoresRemoteDatasource().getAll(size: 100);

      setState(() {
        _sucursales = sucursalesPage.items.where((s) => s.activo).toList();
        _auditores = auditoresPage.items;
        _isLoadingSources = false;
      });
    } catch (e) {
      // Fallback mocks if service is temporarily offline, to avoid locking the UI
      setState(() {
        _sucursales = [
          SucursalDto(
            id: '3fa85f64-5717-4562-b3fc-2c963f66afa6',
            nombre: 'Sucursal Central (Demo)',
            region: 'Metropolitana',
            direccion: 'Av. Providencia 1234',
            puntajePromedio: 85.0,
            activo: true,
            creadoEn: DateTime.now(),
          ),
          SucursalDto(
            id: '3fa85f64-5717-4562-b3fc-2c963f66afa7',
            nombre: 'Sucursal Viña del Mar (Demo)',
            region: 'Valparaíso',
            direccion: 'Libertad 456',
            puntajePromedio: 72.0,
            activo: true,
            creadoEn: DateTime.now(),
          ),
        ];
        _auditores = [
          AuditorDto(
            id: 'e6b08d24-3fa8-4177-88ff-c9417f63efb1',
            usuarioId: 'u6b08d24-3fa8-4177-88ff-c9417f63efb1',
            nombre: 'Valentina Lagos',
            email: 'valentina.lagos@auditchain.cl',
            region: 'Metropolitana',
            activo: true,
            creadoEn: DateTime.now(),
          ),
          AuditorDto(
            id: 'e6b08d24-3fa8-4177-88ff-c9417f63efb2',
            usuarioId: 'u6b08d24-3fa8-4177-88ff-c9417f63efb2',
            nombre: 'Rodrigo Muñoz',
            email: 'rodrigo.munoz@auditchain.cl',
            region: 'Valparaíso',
            activo: true,
            creadoEn: DateTime.now(),
          ),
        ];
        _isLoadingSources = false;
      });
    }
  }

  int get _score {
    int yesCount = _checklist.where((item) => item['value'] == true).length;
    return yesCount * 25;
  }

  void _nextStep() {
    if (_currentStep == 0) {
      if (_formKey.currentState?.validate() ?? false) {
        setState(() => _currentStep++);
        _pageController.nextPage(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      }
    } else if (_currentStep < 2) {
      setState(() => _currentStep++);
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _prevStep() {
    if (_currentStep > 0) {
      setState(() => _currentStep--);
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  Future<void> _submitAudit() async {
    if (_isSubmitting) return;

    setState(() => _isSubmitting = true);

    try {
      final data = {
        'sucursal_id': _selectedSucursalId,
        'auditor_id': _selectedAuditorId,
        'fecha_programada': _selectedDate.toUtc().toIso8601String(),
        'puntaje': _score.toDouble(),
        'observaciones': _observacionesCtrl.text.trim(),
      };

      await AuditoriasRemoteDatasource().create(data);

      if (mounted) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => AlertDialog(
            title: Row(
              children: const [
                Icon(Icons.check_circle_rounded, color: Colors.green, size: 28),
                SizedBox(width: 10),
                Text('Auditoría Completada'),
              ],
            ),
            content: Text(
              'La auditoría se ha registrado exitosamente con un puntaje de $_score%.',
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(); // pop dialog
                  context.go('/dashboard'); // Go back to dashboard
                },
                child: const Text('Entendido'),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString().replaceFirst('Exception: ', '')),
            backgroundColor: AppColors.danger,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoadingSources) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.slate50,
      appBar: AppBar(
        title: const Text('Crear auditoría'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/dashboard'),
        ),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 800),
            child: Card(
              elevation: 4,
              shadowColor: Colors.black12,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Step Indicator Header
                  _buildStepIndicator(),
                  const Divider(height: 1),
                  
                  // Wizard Body
                  SizedBox(
                    height: 480,
                    child: Form(
                      key: _formKey,
                      child: PageView(
                        controller: _pageController,
                        physics: const NeverScrollableScrollPhysics(),
                        children: [
                          _buildGeneralInfoStep(),
                          _buildChecklistStep(),
                          _buildSummaryStep(),
                        ],
                      ),
                    ),
                  ),
                  
                  // Control Buttons
                  const Divider(height: 1),
                  _buildControls(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ─── STEP INDICATOR HEADER ──────────────────────────────────────────────────

  Widget _buildStepIndicator() {
    final List<String> stepNames = ['Información', 'Checklist', 'Resultado'];

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(stepNames.length * 2 - 1, (index) {
          if (index.isOdd) {
            // Line separator
            final int lineIndex = index ~/ 2;
            final bool isPassed = _currentStep > lineIndex;
            return Container(
              width: 50,
              height: 2,
              color: isPassed ? AppColors.primary800 : AppColors.slate200,
            );
          }

          final int stepIndex = index ~/ 2;
          final bool isCurrent = _currentStep == stepIndex;
          final bool isPassed = _currentStep > stepIndex;

          return Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircleAvatar(
                radius: 16,
                backgroundColor: isCurrent
                    ? AppColors.primary800
                    : (isPassed ? AppColors.primary100 : Colors.white),
                child: isPassed
                    ? const Icon(Icons.check, color: AppColors.primary800, size: 16)
                    : Text(
                        '${stepIndex + 1}',
                        style: TextStyle(
                          color: isCurrent ? Colors.white : AppColors.slate500,
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
              const SizedBox(width: 8),
              Text(
                stepNames[stepIndex],
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: isCurrent ? FontWeight.bold : FontWeight.w500,
                  color: isCurrent ? AppColors.slate900 : AppColors.slate400,
                ),
              ),
            ],
          );
        }),
      ),
    );
  }

  // ─── STEP 1: GENERAL INFO ───────────────────────────────────────────────────

  Widget _buildGeneralInfoStep() {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'Información General',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.slate900),
          ),
          const SizedBox(height: 6),
          const Text(
            'Selecciona la sucursal, el auditor asignado y programa la fecha de evaluación.',
            style: TextStyle(fontSize: 13, color: AppColors.slate500),
          ),
          const SizedBox(height: 28),

          // Sucursal Dropdown
          const Text('Sucursal a evaluar', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.slate600)),
          const SizedBox(height: 6),
          DropdownButtonFormField<String>(
            value: _selectedSucursalId,
            validator: (value) => value == null ? 'Por favor, selecciona una sucursal' : null,
            onChanged: (value) => setState(() => _selectedSucursalId = value),
            decoration: _inputDecoration('Selecciona Sucursal'),
            dropdownColor: Colors.white,
            items: _sucursales.map((s) {
              return DropdownMenuItem(
                value: s.id,
                child: Text('${s.nombre} (${s.region})'),
              );
            }).toList(),
          ),
          const SizedBox(height: 16),

          // Auditor Dropdown
          const Text('Auditor Asignado', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.slate600)),
          const SizedBox(height: 6),
          DropdownButtonFormField<String>(
            value: _selectedAuditorId,
            validator: (value) => value == null ? 'Por favor, selecciona un auditor' : null,
            onChanged: (value) => setState(() => _selectedAuditorId = value),
            decoration: _inputDecoration('Selecciona Auditor'),
            dropdownColor: Colors.white,
            items: _auditores.map((a) {
              return DropdownMenuItem(
                value: a.id,
                child: Text('${a.nombre} (${a.region})'),
              );
            }).toList(),
          ),
          const SizedBox(height: 16),

          // Fecha Picker
          const Text('Fecha Programada', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.slate600)),
          const SizedBox(height: 6),
          InkWell(
            onTap: _selectDate,
            child: InputDecorator(
              decoration: _inputDecoration(''),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(DateFormat('dd/MM/yyyy - HH:mm').format(_selectedDate)),
                  const Icon(Icons.calendar_today, size: 18, color: AppColors.slate400),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _selectDate() async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now().subtract(const Duration(days: 30)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (pickedDate != null && mounted) {
      final TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(_selectedDate),
      );

      if (pickedTime != null) {
        setState(() {
          _selectedDate = DateTime(
            pickedDate.year,
            pickedDate.month,
            pickedDate.day,
            pickedTime.hour,
            pickedTime.minute,
          );
        });
      }
    }
  }

  // ─── STEP 2: CHECKLIST STEP ─────────────────────────────────────────────────

  Widget _buildChecklistStep() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'Checklist de Evaluación',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.slate900),
          ),
          const SizedBox(height: 6),
          const Text(
            'Responde afirmativa o negativamente a cada uno de los siguientes estándares.',
            style: TextStyle(fontSize: 13, color: AppColors.slate500),
          ),
          const SizedBox(height: 20),

          Expanded(
            child: ListView.separated(
              itemCount: _checklist.length,
              separatorBuilder: (context, index) => const Divider(height: 16),
              itemBuilder: (context, index) {
                final item = _checklist[index];
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Pregunta ${index + 1}',
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: AppColors.primary800,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              item['question'],
                              style: const TextStyle(
                                fontSize: 13.5,
                                color: AppColors.slate800,
                                fontWeight: FontWeight.w500,
                                height: 1.3,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 20),
                      Switch.adaptive(
                        value: item['value'],
                        activeColor: AppColors.primary800,
                        onChanged: (val) {
                          setState(() {
                            _checklist[index]['value'] = val;
                          });
                        },
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // ─── STEP 3: SUMMARY & COMMENTS STEP ────────────────────────────────────────

  Widget _buildSummaryStep() {
    final int scoreValue = _score;
    final Color scoreColor = scoreValue >= 75 ? Colors.green : Colors.orange;

    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'Resultado y Observaciones',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.slate900),
          ),
          const SizedBox(height: 20),

          // Score Gauge card
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: scoreColor.withOpacity(0.08),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: scoreColor.withOpacity(0.2), width: 1.5),
            ),
            child: Row(
              children: [
                // Circle Score
                Container(
                  width: 72,
                  height: 72,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: scoreColor,
                    shape: BoxShape.circle,
                  ),
                  child: Text(
                    '$scoreValue%',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        scoreValue >= 75 ? 'AUDITORÍA APROBADA' : 'AUDITORÍA CON OBSERVACIONES',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: scoreColor,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        scoreValue >= 75
                            ? 'La sucursal cumple con la mayoría de los estándares mínimos establecidos.'
                            : 'Se requiere formular un plan de acción para corregir las deficiencias detectadas.',
                        style: const TextStyle(fontSize: 12, color: AppColors.slate600, height: 1.3),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Observaciones input
          const Text(
            'Observaciones Adicionales',
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.slate600),
          ),
          const SizedBox(height: 6),
          Expanded(
            child: TextField(
              controller: _observacionesCtrl,
              maxLines: null,
              minLines: 4,
              keyboardType: TextInputType.multiline,
              decoration: _inputDecoration('Registrar observaciones detalladas, fallas o planes de acción recomendados...'),
            ),
          ),
        ],
      ),
    );
  }

  // ─── CONTROL BUTTONS ────────────────────────────────────────────────────────

  Widget _buildControls() {
    final bool isLast = _currentStep == 2;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Anterior button
          TextButton(
            onPressed: _currentStep == 0 || _isSubmitting ? null : _prevStep,
            style: TextButton.styleFrom(
              foregroundColor: AppColors.slate600,
            ),
            child: const Text('Anterior'),
          ),
          
          // Siguiente / Finalizar button
          ElevatedButton(
            onPressed: _isSubmitting ? null : (isLast ? _submitAudit : _nextStep),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary800,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: _isSubmitting
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                  )
                : Text(isLast ? 'Finalizar Auditoría' : 'Siguiente'),
          ),
        ],
      ),
    );
  }

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      isDense: true,
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
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
