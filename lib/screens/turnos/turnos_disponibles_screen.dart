import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart'; // Asegúrate de tener esta dependencia en pubspec.yaml
import '../../provider/turno_provider.dart';
import '../../models/slot_turno.dart';
import '../../widgets/custom_app_bar.dart';

class TurnosDisponiblesScreen extends StatefulWidget {
  const TurnosDisponiblesScreen({Key? key}) : super(key: key);

  @override
  State<TurnosDisponiblesScreen> createState() => _TurnosDisponiblesScreenState();
}

class _TurnosDisponiblesScreenState extends State<TurnosDisponiblesScreen> {
  // Estado local para la UI (cuál cajita está pintada de azul)
  SlotTurno? _slotSeleccionado;

  @override
  void initState() {
    super.initState();
    // Cargar slots iniciales (fecha de hoy) después de que se construya el widget
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _cargarSlots();
    });
  }

  // Wrapper para llamar al provider
  Future<void> _cargarSlots() async {
    final provider = context.read<TurnoProvider>();
    // Si ya hay fecha en el provider, la usa, si no, usa hoy
    await provider.cargarSlotsDisponibles(provider.fechaSeleccionada);
    // Limpiamos la selección local al cambiar/recargar fecha
    if (mounted) {
      setState(() {
        _slotSeleccionado = null;
      });
    }
  }

  Future<void> _seleccionarFecha() async {
    final provider = context.read<TurnoProvider>();

    final DateTime? fecha = await showDatePicker(
      context: context,
      initialDate: provider.fechaSeleccionada,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 30)), // Permitir reservas a 30 días vista
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Theme.of(context).primaryColor, // Color del calendario
            ),
          ),
          child: child!,
        );
      },
    );

    if (fecha != null && fecha != provider.fechaSeleccionada) {
      await provider.cargarSlotsDisponibles(fecha);
      setState(() {
        _slotSeleccionado = null; // Resetear selección
      });
    }
  }

  Future<void> _reservarTurno() async {
    if (_slotSeleccionado == null) return;

    final provider = context.read<TurnoProvider>();
    final fechaFormat = DateFormat('dd/MM/yyyy').format(provider.fechaSeleccionada);

    // 1. Diálogo de confirmación
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar Reserva'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('¿Deseas reservar el siguiente turno?'),
            const SizedBox(height: 16),
            _infoFila(Icons.calendar_today, fechaFormat),
            const SizedBox(height: 8),
            _infoFila(Icons.access_time, _slotSeleccionado!.rangoHorario),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Confirmar'),
          ),
        ],
      ),
    );

    if (confirmar != true) return;

    // 2. Intentar reserva
    try {
      final turno = await provider.reservarTurno(
        fecha: provider.fechaSeleccionada,
        horaInicio: _slotSeleccionado!.horaInicio,
        horaFin: _slotSeleccionado!.horaFin,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('¡Turno reservado! Código: ${turno.codigo}'),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 3),
          ),
        );
        // Opcional: Navegar a "Mis Turnos" o volver al Home
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString().replaceAll('Exception: ', '')), // Limpiar mensaje
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Widget _infoFila(IconData icon, String texto) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Colors.grey[600]),
        const SizedBox(width: 8),
        Text(texto, style: const TextStyle(fontWeight: FontWeight.bold)),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: 'Reservar Turno'),
      body: Consumer<TurnoProvider>(
        builder: (context, provider, child) {
          return Column(
            children: [
              // === SECCIÓN 1: SELECTOR DE FECHA ===
              Container(
                padding: const EdgeInsets.all(16),
                color: Colors.grey[100],
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Fecha seleccionada:',
                              style: TextStyle(fontSize: 12, color: Colors.grey)),
                          Text(
                            DateFormat('EEEE d, MMMM yyyy', 'es').format(provider.fechaSeleccionada),
                            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                    ElevatedButton.icon(
                      onPressed: provider.isLoading ? null : _seleccionarFecha,
                      icon: const Icon(Icons.edit_calendar, size: 18),
                      label: const Text('Cambiar'),
                    ),
                  ],
                ),
              ),

              // === SECCIÓN 2: LISTA DE SLOTS ===
              Expanded(
                child: provider.isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : provider.error != null
                    ? _buildErrorView(provider)
                    : provider.slotsDisponibles.isEmpty
                    ? _buildEmptyView()
                    : _buildSlotsList(provider),
              ),

              // === SECCIÓN 3: BOTÓN RESERVAR ===
              if (!provider.isLoading && provider.slotsDisponibles.isNotEmpty)
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [BoxShadow(blurRadius: 5, color: Colors.black.withOpacity(0.1))],
                  ),
                  child: SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _slotSeleccionado == null ? null : _reservarTurno,
                      style: ElevatedButton.styleFrom(
                        disabledBackgroundColor: Colors.grey[300],
                      ),
                      child: const Text('CONFIRMAR RESERVA',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSlotsList(TurnoProvider provider) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: provider.slotsDisponibles.length,
      itemBuilder: (context, index) {
        final slot = provider.slotsDisponibles[index];
        final isSelected = _slotSeleccionado == slot;

        return Card(
          elevation: isSelected ? 4 : 1,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: isSelected
                ? BorderSide(color: Theme.of(context).primaryColor, width: 2)
                : BorderSide.none,
          ),
          color: isSelected ? Theme.of(context).primaryColor.withOpacity(0.05) : Colors.white,
          margin: const EdgeInsets.only(bottom: 12),
          child: InkWell(
            onTap: () {
              setState(() {
                _slotSeleccionado = slot;
              });
            },
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(
                          Icons.access_time,
                          color: isSelected ? Theme.of(context).primaryColor : Colors.grey
                      ),
                      const SizedBox(width: 12),
                      Text(
                        slot.rangoHorario,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          color: isSelected ? Theme.of(context).primaryColor : Colors.black87,
                        ),
                      ),
                    ],
                  ),
                  if (isSelected)
                    Icon(Icons.check_circle, color: Theme.of(context).primaryColor),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildErrorView(TurnoProvider provider) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 48, color: Colors.red),
          const SizedBox(height: 16),
          Text(provider.error ?? 'Error desconocido', textAlign: TextAlign.center),
          const SizedBox(height: 16),
          TextButton.icon(
            onPressed: _cargarSlots,
            icon: const Icon(Icons.refresh),
            label: const Text('Reintentar'),
          )
        ],
      ),
    );
  }

  Widget _buildEmptyView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.event_busy, size: 64, color: Colors.grey[300]),
          const SizedBox(height: 16),
          Text(
            'No hay turnos disponibles\npara esta fecha',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey[600], fontSize: 16),
          ),
        ],
      ),
    );
  }
}