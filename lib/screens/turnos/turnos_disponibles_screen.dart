import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';
import '../../models/slot_turno.dart';
import '../../provider/turno_provider.dart';
import '../../models/turno.dart';
import '../../models/turno.dart';
import '../../utils/constants.dart';

class TurnosDisponiblesScreen extends StatefulWidget {
  const TurnosDisponiblesScreen({Key? key}) : super(key: key);

  @override
  State<TurnosDisponiblesScreen> createState() => _TurnosDisponiblesScreenState();
}

class _TurnosDisponiblesScreenState extends State<TurnosDisponiblesScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);

    // Cargar datos iniciales
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<TurnoProvider>();
      provider.cargarMisTurnos();
      provider.cargarSlotsDisponibles(DateTime.now());
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Tabs
        Container(
          color: Colors.white,
          child: TabBar(
            controller: _tabController,
            labelColor: Theme.of(context).primaryColor,
            unselectedLabelColor: Colors.grey,
            indicatorColor: Theme.of(context).primaryColor,
            tabs: const [
              Tab(text: 'Reservar Turno', icon: Icon(Icons.add_circle_outline)),
              Tab(text: 'Mis Turnos', icon: Icon(Icons.list)),
            ],
          ),
        ),

        // Tab Views
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: const [
              _ReservarTurnoTab(),
              _MisTurnosTab(),
            ],
          ),
        ),
      ],
    );
  }
}

// ============================================
// TAB: RESERVAR TURNO
// ============================================

class _ReservarTurnoTab extends StatelessWidget {
  const _ReservarTurnoTab({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<TurnoProvider>(
      builder: (context, provider, child) {
        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Calendario
              _buildCalendario(context, provider),

              const SizedBox(height: 24),

              // Slots disponibles
              Text(
                'Horarios Disponibles',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 12),

              _buildSlotsDisponibles(context, provider),
            ],
          ),
        );
      },
    );
  }

  Widget _buildCalendario(BuildContext context, TurnoProvider provider) {
    final ahora = DateTime.now();
    final primerDia = DateTime(ahora.year, ahora.month, ahora.day);
    final ultimoDia = primerDia.add(const Duration(days: 30));

    return Card(
      child: TableCalendar(
        firstDay: primerDia,
        lastDay: ultimoDia,
        focusedDay: provider.fechaSeleccionada,
        selectedDayPredicate: (day) {
          return isSameDay(provider.fechaSeleccionada, day);
        },
        onDaySelected: (selectedDay, focusedDay) {
          provider.seleccionarFecha(selectedDay);
        },
        calendarFormat: CalendarFormat.month,
        startingDayOfWeek: StartingDayOfWeek.monday,
        headerStyle: HeaderStyle(
          formatButtonVisible: false,
          titleCentered: true,
          titleTextStyle: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        calendarStyle: CalendarStyle(
          todayDecoration: BoxDecoration(
            color: Theme.of(context).primaryColor.withOpacity(0.5),
            shape: BoxShape.circle,
          ),
          selectedDecoration: BoxDecoration(
            color: Theme.of(context).primaryColor,
            shape: BoxShape.circle,
          ),
        ),
        locale: 'es_ES',
      ),
    );
  }

  Widget _buildSlotsDisponibles(BuildContext context, TurnoProvider provider) {
    if (provider.isLoadingSlots) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(32),
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (provider.errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              Icon(Icons.error_outline, size: 48, color: Colors.red[300]),
              const SizedBox(height: 12),
              Text(
                provider.errorMessage!,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.red),
              ),
            ],
          ),
        ),
      );
    }

    if (provider.slotsDisponibles.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            children: [
              Icon(Icons.event_busy, size: 64, color: Colors.grey[400]),
              const SizedBox(height: 16),
              Text(
                'No hay horarios disponibles para esta fecha',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey[600]),
              ),
            ],
          ),
        ),
      );
    }

    // Mostrar estadísticas
    final disponibles = provider.slotsLibres.length;
    final ocupados = provider.slotsOcupados.length;
    final total = provider.slotsDisponibles.length;

    return Column(
      children: [
        // Info card
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.blue.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatItem(
                icon: Icons.check_circle,
                color: Colors.green,
                value: disponibles.toString(),
                label: 'Disponibles',
              ),
              _buildStatItem(
                icon: Icons.cancel,
                color: Colors.red,
                value: ocupados.toString(),
                label: 'Ocupados',
              ),
              _buildStatItem(
                icon: Icons.event,
                color: Colors.blue,
                value: total.toString(),
                label: 'Total',
              ),
            ],
          ),
        ),

        const SizedBox(height: 16),

        // Lista de slots
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 2.5,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
          ),
          itemCount: provider.slotsDisponibles.length,
          itemBuilder: (context, index) {
            final slot = provider.slotsDisponibles[index];
            return _buildSlotCard(context, slot, provider);
          },
        ),
      ],
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required Color color,
    required String value,
    required String label,
  }) {
    return Column(
      children: [
        Icon(icon, color: color, size: 32),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: Colors.grey,
          ),
        ),
      ],
    );
  }

  Widget _buildSlotCard(
      BuildContext context,
      SlotDisponible slot,
      TurnoProvider provider,
      ) {
    return InkWell(
      onTap: slot.disponible
          ? () => _confirmarReserva(context, slot, provider)
          : null,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          color: slot.disponible
              ? Colors.green.withOpacity(0.1)
              : Colors.grey.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: slot.disponible
                ? Colors.green.withOpacity(0.5)
                : Colors.grey.withOpacity(0.5),
            width: 2,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              slot.disponible ? Icons.schedule : Icons.block,
              color: slot.disponible ? Colors.green : Colors.grey,
              size: 28,
            ),
            const SizedBox(height: 4),
            Text(
              slot.horaTexto,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: slot.disponible ? Colors.green[700] : Colors.grey,
                fontSize: 13,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 2),
            Text(
              slot.disponible ? 'Disponible' : 'Ocupado',
              style: TextStyle(
                fontSize: 11,
                color: slot.disponible ? Colors.green[600] : Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmarReserva(
      BuildContext context,
      SlotDisponible slot,
      TurnoProvider provider,
      ) {
    final dateFormat = DateFormat('EEEE, d \'de\' MMMM', 'es_ES');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar Reserva'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('¿Deseas reservar este turno?'),
            const SizedBox(height: 16),
            _buildInfoRowDialog(
              Icons.calendar_today,
              'Fecha',
              dateFormat.format(provider.fechaSeleccionada),
            ),
            _buildInfoRowDialog(
              Icons.schedule,
              'Horario',
              slot.horaTexto,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);

              // Mostrar loading
              showDialog(
                context: context,
                barrierDismissible: false,
                builder: (context) => const Center(
                  child: CircularProgressIndicator(),
                ),
              );

              // Reservar turno
              final success = await provider.reservarTurno(
                horaInicio: slot.horaInicio,
                horaFin: slot.horaFin,
              );

              if (context.mounted) {
                Navigator.pop(context); // Cerrar loading

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      success
                          ? '¡Turno reservado exitosamente!'
                          : provider.errorMessage ?? 'Error al reservar turno',
                    ),
                    backgroundColor: success ? Colors.green : Colors.red,
                  ),
                );
              }
            },
            child: const Text('Confirmar'),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRowDialog(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.grey[600]),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
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

// ============================================
// TAB: MIS TURNOS
// ============================================

class _MisTurnosTab extends StatelessWidget {
  const _MisTurnosTab({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<TurnoProvider>(
      builder: (context, provider, child) {
        return RefreshIndicator(
          onRefresh: () => provider.cargarMisTurnos(),
          child: _buildContent(context, provider),
        );
      },
    );
  }

  Widget _buildContent(BuildContext context, TurnoProvider provider) {
    if (provider.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (provider.misTurnos.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.event_note, size: 80, color: Colors.grey[400]),
              const SizedBox(height: 16),
              Text(
                'No tienes turnos reservados',
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: provider.misTurnos.length,
      itemBuilder: (context, index) {
        final turno = provider.misTurnos[index];
        return _buildTurnoCard(context, turno, provider);
      },
    );
  }

  Widget _buildTurnoCard(
      BuildContext context,
      Turno turno,
      TurnoProvider provider,
      ) {
    final dateFormat = DateFormat('EEEE, d \'de\' MMMM', 'es_ES');

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Expanded(
                  child: Text(
                    turno.codigo,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                _buildEstadoChip(turno),
              ],
            ),

            const SizedBox(height: 12),

            // Fecha y hora
            Row(
              children: [
                Icon(Icons.calendar_today, size: 18, color: Colors.grey[600]),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    dateFormat.format(turno.fecha),
                    style: TextStyle(color: Colors.grey[700]),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 8),

            Row(
              children: [
                Icon(Icons.schedule, size: 18, color: Colors.grey[600]),
                const SizedBox(width: 8),
                Text(
                  turno.horaCompletaTexto,
                  style: TextStyle(
                    color: Colors.grey[700],
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),

            // Botón cancelar
            if (turno.puedeSerCancelado) ...[
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () => _confirmarCancelacion(context, turno, provider),
                  icon: const Icon(Icons.cancel_outlined, size: 18),
                  label: const Text('Cancelar Turno'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.red,
                    side: const BorderSide(color: Colors.red),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildEstadoChip(Turno turno) {
    Color color;
    String texto;

    if (turno.esReservado) {
      color = Colors.blue;
      texto = 'Reservado';
    } else if (turno.esAtendido) {
      color = Colors.green;
      texto = 'Atendido';
    } else if (turno.esCancelado) {
      color = Colors.orange;
      texto = 'Cancelado';
    } else {
      color = Colors.grey;
      texto = 'Vencido';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(
        texto,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.w600,
          fontSize: 12,
        ),
      ),
    );
  }

  void _confirmarCancelacion(
      BuildContext context,
      Turno turno,
      TurnoProvider provider,
      ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cancelar Turno'),
        content: const Text(
          '¿Estás seguro que deseas cancelar este turno?\n\nEsta acción no se puede deshacer.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('No, mantener'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);

              // Mostrar loading
              showDialog(
                context: context,
                barrierDismissible: false,
                builder: (context) => const Center(
                  child: CircularProgressIndicator(),
                ),
              );

              // Cancelar turno
              final success = await provider.cancelarTurno(turno.id);

              if (context.mounted) {
                Navigator.pop(context); // Cerrar loading

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      success
                          ? 'Turno cancelado exitosamente'
                          : provider.errorMessage ?? 'Error al cancelar turno',
                    ),
                    backgroundColor: success ? Colors.green : Colors.red,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text('Sí, cancelar'),
          ),
        ],
      ),
    );
  }
}